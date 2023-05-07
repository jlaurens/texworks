/*
	This is part of TeXworks, an environment for working with TeX documents
	Copyright (C) 2023  Stefan Löffler, Jérôme Laurens

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.

	For links to further information, or to contact the authors,
	see <http://www.tug.org/texworks/>.
*/

#include "TwxCoreTest.h"

#include "Core/TwxInfo.h"

namespace Twx {
namespace Core {
namespace Test {

// Main::Main()
// {
// }

// Main::~Main()
// {
// }

void Main::testInfo()
{
	QCOMPARE(Info::name(), QStringLiteral("TwxCoreTest"));
	QCOMPARE(Info::authors(), QString::fromUtf8("Ò∂ƒﬁ🥹"));
	QCOMPARE(Info::copyrightYears(), QString::fromUtf8("1234-5678"));
	QCOMPARE(Info::copyrightHolders(), QString::fromUtf8("æê®†\"Úºîœπ‡Ò∂\"ƒﬁÌÏÈ"));

	QCOMPARE(Info::versionMajor(), 1);
	QCOMPARE(Info::versionMinor(), 7);
	QCOMPARE(Info::versionPatch(), 8);
	QCOMPARE(Info::versionTweak(), 9);
}

} // namespace Test
} // namespace Core
} // namespace Twx

QTEST_MAIN(Twx::Core::Test::Main)
