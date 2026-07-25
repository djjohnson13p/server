/*
===========================================================================

  Copyright (c) 2026 LandSandBoat Dev Teams

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

===========================================================================
*/

#include <catch2/catch_test_macros.hpp>

#include "map/conquest_system.h"

TEST_CASE("Conquest region influence bonus preserves truncation semantics", "[retail-parity][conquest]")
{
    CHECK(conquest::ApplyRegionInfluenceBonus(100, 0) == 100);
    CHECK(conquest::ApplyRegionInfluenceBonus(100, 10) == 110);
    CHECK(conquest::ApplyRegionInfluenceBonus(100, 100) == 200);
    CHECK(conquest::ApplyRegionInfluenceBonus(3, 10) == 3);
    CHECK(conquest::ApplyRegionInfluenceBonus(10, 15) == 11);
    CHECK(conquest::ApplyRegionInfluenceBonus(0, 100) == 0);
    CHECK(conquest::ApplyRegionInfluenceBonus(100, -10) == 100);
}
