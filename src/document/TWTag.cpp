/*
	This is part of TeXworks, an environment for working with TeX documents
	Copyright (C) 2019-2023  Stefan Löffler, Jérôme Laurens

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	( at your option ) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.

	For links to further information, or to contact the authors,
	see <http://www.tug.org/texworks/>.
*/

#include "TWString.h"
#include "document/TextDocument.h"
#include "document/TWTag.h"
#include <QDebug>

namespace Tw {
namespace Document {

const QString Tag::TypeName::Any      = QStringLiteral( "Any" );
const QString Tag::TypeName::Bookmark = QStringLiteral( "Bookmark" );
const QString Tag::TypeName::Outline  = QStringLiteral( "Outline" );

const QString Tag::SubtypeName::Any           = QStringLiteral( "Any" );
// This is the list of recognized anchor subtypes
const QString Tag::SubtypeName::MARK          = QStringLiteral( "MARK" );
const QString Tag::SubtypeName::TODO          = QStringLiteral( "TODO" );
const QString Tag::SubtypeName::BEGIN_CONTENT = QStringLiteral( "BEGIN_CONTENT" );
const QString Tag::SubtypeName::START_CONTENT = QStringLiteral( "START_CONTENT" );
const QString Tag::SubtypeName::END_CONTENT   = QStringLiteral( "END_CONTENT" );
const QString Tag::SubtypeName::STOP_CONTENT  = QStringLiteral( "STOP_CONTENT" );

// name of a capture group, should be defined more globally because file "tag-patterns.txt" relies on it.
namespace __ {
static const QString kKeyContent = QStringLiteral( "content" );
static const QString kKeyType = QStringLiteral( "type" );
}

//MARK: Tag
Tag::Type Tag::typeForName( const QString &name ) {
    if ( name == TypeName::Outline ) {
        return Type::Outline;
    }
    if ( name == TypeName::Bookmark ) {
        return Type::Bookmark;
    }
    return Type::Any;
}

const QString Tag::nameForType( Tag::Type type ) {
    if ( type == Type::Outline ) {
        return TypeName::Outline;
    }
    if ( type == Type::Bookmark ) {
        return TypeName::Bookmark;
    }
    return TypeName::Any;
}

Tag::Subtype Tag::subtypeForName( const QString &name ) {
    if ( name == SubtypeName::MARK ) {
        return Subtype::MARK;
    }
    if ( name == SubtypeName::TODO ) {
        return Subtype::TODO;
    }
    if ( name == SubtypeName::BEGIN_CONTENT ) {
        return Subtype::BEGIN_CONTENT;
    }
    if ( name == SubtypeName::END_CONTENT ) {
        return Subtype::END_CONTENT;
    }
    if ( name == SubtypeName::START_CONTENT ) {
        return Subtype::BEGIN_CONTENT;
    }
    if ( name == SubtypeName::STOP_CONTENT ) {
        return Subtype::END_CONTENT;
    }
    return Subtype::Any;
}

const QString Tag::nameForSubtype( Tag::Subtype subtype ) {
    if ( subtype == Subtype::MARK ) {
        return SubtypeName::MARK;
    }
    if ( subtype == Subtype::TODO ) {
        return SubtypeName::TODO;
    }
    if ( subtype == Subtype::BEGIN_CONTENT ) {
        return SubtypeName::BEGIN_CONTENT;
    }
    if ( subtype == Subtype::END_CONTENT ) {
        return SubtypeName::END_CONTENT;
    }
    return SubtypeName::Any;
}

Tag::Tag( const Type     type,
         const Subtype  subtype,
         const int      level,
         const QTextCursor & cursor,
         const QString& text,
         const QString& tooltip,
         TagBank *parent /* = nullptr */ ):
QObject( parent ),
__type( type ),
__subtype( subtype ),
__level( level ),
__cursor( cursor ),
__text( text ),
__tooltip( tooltip )
{
    Q_ASSERT( !__cursor.isNull() );
}

Tag::Tag( const QTextCursor &cursor,
         const int level,
         const QString &text,
         TagBank *parent /* = nullptr */ ):
QObject( parent ),
__type( Type::Any ),
__subtype( Subtype::Any ),
__level( level ),
__cursor( cursor ),
__text( text ),
__tooltip( QString() )
{
    Q_ASSERT( !cursor.isNull() );
}

Tag::Tag( const Tag::Type type,
         const int level,
         const QTextCursor &cursor,
         const QRegularExpressionMatch & match,
         TagBank *parent /* = nullptr */ ):
QObject( parent ),
__type( type ),
__level( level ),
__cursor( cursor )
{
    Q_ASSERT( !cursor.isNull() );
    QString s = match.captured( __::kKeyType );
    __subtype = Tag::subtypeForName( s );
    int end = __cursor.selectionEnd();
    __cursor.movePosition( QTextCursor::StartOfBlock );
    __cursor.setPosition( end, QTextCursor::KeepAnchor );
    __cursor.movePosition( QTextCursor::EndOfBlock, QTextCursor::KeepAnchor );
    s = match.captured( __::kKeyContent );
    if ( s.isEmpty() ) {
        s = match.captured( 1 );
    }
    if ( s.isEmpty() ) {
        __text = match.captured( 0 );
        __tooltip = QString();
    } else {
        __text = s;
        __tooltip = match.captured( 0 );
    }
}

const TagBank *Tag::bank() const
{
    return static_cast<TagBank *>( parent() );
}

TextDocument *Tag::document() const
{
    return bank()->document();
}

//MARK: TagSuite

TagSuite::TagSuite( TagBank *bank, Filter f ): QObject( bank ), __filter( f )
{
    Q_ASSERT( bank );
    __active     = false;
}

const TagBank *TagSuite::bank() const
{
    return static_cast<TagBank *>( parent() );
}

TextDocument *TagSuite::document() const
{
    return bank()->document();
}

QList<const Tag *> TagSuite::tags()
{
    update( true );
    return QList<const Tag *>( __tags );
}

/// \note
void TagSuite::update( bool activate/* = false */ )
{
    if ( activate )
        __active = true;
    if ( __active ) {
        const QList<const Tag *> tags = bank()->tags();
        foreach( const Tag *tag, tags ) {
            if ( tag && __filter( tag ) )
                __tags << tag;
        }
        emit changed();
    }
}

const Tag *TagSuite::get( const int i )
{
    update( true );
    return 0 <= i && i < __tags.count() ? __tags[i] : nullptr;
}

/// \brief manage the cursor for a contiguous selection
/// \param yorn select when true , deselect when false
/// \param cursor
void TagSuite::select( bool yorn, const QTextCursor &cursor )
{
    if ( cursor.isNull() ) {
        if ( yorn ) {
            __cursor = QTextCursor( document() );
            __cursor.movePosition( QTextCursor::Start );
            __cursor.movePosition( QTextCursor::End, QTextCursor::KeepAnchor );
        }
        return;
    }
    int start =  0;
    int end   = -1;
    if ( yorn ) {
        if ( __cursor.isNull() ) {
            __cursor = cursor;
            start = __cursor.selectionStart();
            end   = __cursor.selectionEnd();
heaven:
            if ( start < end ) {
                __cursor.setPosition( start );
                __cursor.movePosition( QTextCursor::StartOfBlock );
                __cursor.setPosition( end, QTextCursor::KeepAnchor );
                __cursor.movePosition( QTextCursor::EndOfBlock, QTextCursor::KeepAnchor );
                return;
            }
            __cursor = QTextCursor();
            return;
        }
        // expand the selection
        start = std::min( cursor.selectionStart(), __cursor.selectionStart() );
        end =   std::max( cursor.selectionEnd(),   __cursor.selectionEnd() );
        goto heaven;
    }
    if ( __cursor.isNull() ) {
        return;
    }
    // cut off the selection
    if ( cursor.selectionStart()>=__cursor.selectionEnd() ) {
        __cursor = QTextCursor();
        return;
    }
    if ( __cursor.selectionStart()>=cursor.selectionEnd() ) {
        __cursor = QTextCursor();
        return;
    }
    start = __cursor.selectionStart();
    end   =   cursor.selectionStart();
    if ( start < end ) {
        goto heaven;
    }
    start =   cursor.selectionEnd();
    end   = __cursor.selectionEnd();
    if ( start < end ) {
        goto heaven;
    }
    __cursor = QTextCursor();
}
bool TagSuite::isSelected( const Tag *tag ) const
{
    if ( __cursor.isNull() || !tag ) return false;
    int i = tag->selectionStart();
    return __cursor.selectionStart() <= i && i <= __cursor.selectionEnd();
}

//MARK: TagBank
TagBank::TagBank( TextDocument *parent ) : QObject( parent )
{
    _suiteTag      = new TagSuite( this, []( const Tag *tag ) {
        return tag;
    } );
    _suiteBookmark = new TagSuite( this, []( const Tag *tag ) {
        return tag && ( tag->isBookmark() || tag->isCONTENT() );
    } );
    _suiteOutline  = new TagSuite( this, []( const Tag *tag ) {
        return tag && ( tag->isOutline() || tag->isCONTENT() );
    } );
}

TextDocument *TagBank::document() const
{
    return static_cast<TextDocument *>( parent() );
}

bool TagBank::addTag( Tag *tag )
{
    if ( !tag ) return false;
    tag->setParent( this ); // take ownership
    auto index = tag->selectionStart();
    auto it = _tags.rbegin();
    while( it != _tags.rend() && ( *it )->selectionStart() > index ) {
        ++it;
    }
    _tags.insert( it.base(), tag );
    tag->setParent( this );
    emit changed();
    _suiteTag->update();
    _suiteBookmark->update();
    _suiteOutline->update();
    return true;
}

void TagBank::addTag( const QTextCursor & c, const int level, const QString & text )
{
    Tag *tag = new Tag( c, level, text, this )
    if ( ! addTag( tag ) ) delete tag;
}

void TagBank::addTag( const Tag::Type type,
                     const int level,
                     const int index,
                     const int length,
                     const QRegularExpressionMatch & match )
{
    QTextCursor c = QTextCursor( document() );
    c.setPosition( index );
    c.setPosition( index+length, QTextCursor::KeepAnchor );
    c.movePosition( QTextCursor::StartOfBlock );
    Tag *tag = new Tag( type, level, c, match, this )
    if ( ! addTag( tag ) ) delete tag;
}
unsigned int TagBank::removeTags( int offset, int len )
{
    unsigned int removed = 0;
    auto start = _tags.begin();
    while( start != _tags.end() && ( *start )->selectionStart() < offset ) {
        ++start;
    }
    auto end = start;
    offset += len;
    while( end != _tags.end() && ( *end )->selectionStart() < offset ) {
        delete *end;
        ++removed;
        ++end;
    }
    if ( removed > 0 ) {
        _tags.erase( start, end );
        emit changed();
        _suiteTag->update();
        _suiteBookmark->update();
        _suiteOutline->update();
    }
    return removed;
}

} // namespace Document
} // namespace Tw
