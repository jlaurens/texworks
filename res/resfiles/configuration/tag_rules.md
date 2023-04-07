# TeXworks: rules for tag recognition

## Purpose

Defining rules to recognize and manage some tags.
A tag is a full hard line of text matching some syntax.
This file is parsed by `Tw::Document::Tag::Parser`.

## Syntax of `tag_rules.txt`
This is an UTF-8 encoded text file with a very lightweight syntax.
The file must start with
```
<first line> ::= "version:" <sep>? <digit>*
```
where
```
<sep>       ::= horizontal spaces
```

Next comes 2 kinds of lines, everything else is ignored.

### Rules
A rule line like
```
rule: Bookmark.0  0  ^%(?<subtype>MARK|TODO)?:\s*(?<content>.+)
```
follows the general syntax
```
"rule:" <sep>? <unique id> <sep> <level> <sep> <pattern> <EOL>
```
where
```
<unique id> ::= <category> "." <name>
<category>  ::= non void string with no space nor "."
<name>      ::= non void string with no space
<level>     ::= "+" | non negative integer
<pattern>   ::= PCRE
```
The `<category>` may be logically shared by different rule lines. If the same `<unique id>` is used on different lines, the latter takes precedence on the former.
The `<category>`and the `<name>` are case sensitive.

`<pattern>` is a perl compatible regular expression as
recognized by `QRegularExpression`. It will be prepended by the `^` indicating that tags always start lines. The recognized capture group names are "type" and "content".

The category name "Tags" is forbidden.
The category names "Magic", "Bookmark" and "Outline" are known and localized. More recognized category names may appear in the future.

The order in which rules are defined is very important. The first one that applies takes precedence.

### Modes
Modes are strings used to filter out rules.
A mode switch line like one of
```
mode: latex
mode: dtx
mode: latex|dtx
```
follows the general syntax
```
"mode:" <sep>? <filter> <EOL>
```
where
```
<filter>  ::= <name> | <filter> "|" <name>
```
The starting mode is a void string indicating that forthcoming rules are never filtered out.
Standard mode names include "plain", "latex", "dtx" and "context".
More mode names may be recognized in the future.
These mode names are case insensitive.

Rules are applied in the context of a mode identified by its unique name. For example, rules following
```
mode: latex|dtx
```
will apply in both `latex` and `dtx` modes. .

