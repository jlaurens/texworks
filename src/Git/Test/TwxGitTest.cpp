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

#include "TwxGitTest.h"

#include "GitRev.h"

#include "Git/TwxGitRev.h"

#include <QDebug>

namespace Twx {
namespace Git {
namespace Test {

void Main::testGit()
{
	QVERIFY(hash.length()>0);
	QVERIFY(date.length()>0);
	QVERIFY(branch.length()>0);
	QVERIFY(QStringLiteral("GIT_COMMIT_HASH").length()>0);
	QVERIFY(QStringLiteral("GIT_COMMIT_DATE").length()>0);
	QVERIFY(QStringLiteral("GIT_COMMIT_BRANCH").length()>0);
}

} // namespace Test
} // namespace Git
} // namespace Twx

QTEST_MAIN(Twx::Git::Test::Main)
