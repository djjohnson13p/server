/*
===========================================================================

  Copyright (c) 2026 LandSandBoat Dev Teams

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

===========================================================================
*/

#include <catch2/catch_approx.hpp>
#include <catch2/catch_test_macros.hpp>

#include "map/utils/fishingutils.h"

TEST_CASE("Fishing moon patterns 4 and 5 use their configured curves", "[retail-parity][fishing]")
{
    for (uint8 moonPhase = MOONPHASE_NEW; moonPhase <= MOONPHASE_WANING_CRESCENT; ++moonPhase)
    {
        CHECK(fishingutils::GetMoonModifier(4, moonPhase) == Catch::Approx(MOONPATTERN_4(moonPhase) + 0.25f));
        CHECK(fishingutils::GetMoonModifier(5, moonPhase) == Catch::Approx(MOONPATTERN_5(moonPhase) + 0.25f));
    }

    CHECK(fishingutils::GetMoonModifier(4, MOONPHASE_NEW) != Catch::Approx(fishingutils::GetMoonModifier(5, MOONPHASE_NEW)));
}

TEST_CASE("Waders survive fishing gear filtering and affect lucky timing", "[retail-parity][fishing]")
{
    fishing_gear_t gear;

    CHECK(fishingutils::GetFishingFeetGear(FISHERMANS_BOOTS) == FISHERMANS_BOOTS);
    CHECK(fishingutils::GetFishingFeetGear(ANGLERS_BOOTS) == ANGLERS_BOOTS);
    CHECK(fishingutils::GetFishingFeetGear(WADERS) == WADERS);
    CHECK(fishingutils::GetFishingFeetGear(1) == 0);

    gear.feet = FISHERMANS_BOOTS;
    CHECK(fishingutils::GetLuckyTimingGearBonus(gear) == Catch::Approx(0.5f));

    gear.feet = ANGLERS_BOOTS;
    CHECK(fishingutils::GetLuckyTimingGearBonus(gear) == Catch::Approx(1.0f));

    gear.feet = WADERS;
    CHECK(fishingutils::GetLuckyTimingGearBonus(gear) == Catch::Approx(2.0f));

    gear.feet = fishingutils::GetFishingFeetGear(1);
    CHECK(fishingutils::GetLuckyTimingGearBonus(gear) == Catch::Approx(0.0f));
}
