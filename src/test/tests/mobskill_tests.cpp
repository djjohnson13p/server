/*
===========================================================================

  Copyright (c) 2026 LandSandBoat Dev Teams

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see http://www.gnu.org/licenses/

===========================================================================
*/

#include "map/mobskill.h"

#include <catch2/catch_test_macros.hpp>

TEST_CASE("Mob-skill start messages preserve legacy defaults", "[mobskill][start-message]")
{
    CMobSkill skill(1);

    CHECK(skill.getStartMessage(std::chrono::milliseconds(0), 0) == MsgBasic::None);
    CHECK(skill.getStartMessage(std::chrono::milliseconds(1), 0) == MsgBasic::ReadiesWeaponskill);
}

TEST_CASE("Mob-skill start messages support explicit standard and alternate messages", "[mobskill][start-message]")
{
    CMobSkill standard(1);
    standard.setStartMessage(0, MsgBasic::ReadiesWeaponskill);
    CHECK(standard.getStartMessage(std::chrono::milliseconds(0), 1234) == MsgBasic::ReadiesWeaponskill);

    CMobSkill alternate(2);
    alternate.setStartMessage(0, MsgBasic::ReadiesSkill);
    CHECK(alternate.getStartMessage(std::chrono::milliseconds(0), 1234) == MsgBasic::ReadiesSkill);

    const CMobSkill copied(alternate);
    CHECK(copied.getStartMessage(std::chrono::milliseconds(0), 1234) == MsgBasic::ReadiesSkill);
}

TEST_CASE("Mob-skill pool overrides and no-start flag resolve independently", "[mobskill][start-message]")
{
    CMobSkill skill(1);
    skill.setStartMessage(0, MsgBasic::ReadiesWeaponskill);
    skill.setStartMessage(4006, MsgBasic::None);

    CHECK(skill.getStartMessage(std::chrono::milliseconds(0), 4006) == MsgBasic::None);
    CHECK(skill.getStartMessage(std::chrono::milliseconds(0), 5905) == MsgBasic::ReadiesWeaponskill);

    skill.setFlag(SKILLFLAG_NO_START_MSG);
    CHECK(skill.getStartMessage(std::chrono::milliseconds(1), 5905) == MsgBasic::None);

    CMobSkill noFinish(2);
    noFinish.setStartMessage(0, MsgBasic::ReadiesWeaponskill);
    noFinish.setFlag(SKILLFLAG_NO_FINISH_MSG);
    CHECK(noFinish.getStartMessage(std::chrono::milliseconds(0), 5905) == MsgBasic::ReadiesWeaponskill);
}
