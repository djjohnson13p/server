SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

--
-- Explicit mob-skill start-message policies.
--
-- No row preserves the legacy default: positive preparation time readies with
-- message 43, while a zero-time skill starts silently. A zero message
-- explicitly suppresses the start action. A nonzero message emits one
-- SkillStart battle action with that message. Pool 0 is the skill-wide policy;
-- a nonzero pool ID overrides it for that pool only.
--

DROP TABLE IF EXISTS `mob_skill_start_messages`;
CREATE TABLE IF NOT EXISTS `mob_skill_start_messages` (
  `mob_skill_id` smallint(4) unsigned NOT NULL,
  `mob_pool_id` smallint(5) unsigned NOT NULL DEFAULT '0',
  `start_message` smallint(4) unsigned NOT NULL,
  PRIMARY KEY (`mob_skill_id`,`mob_pool_id`)
) ENGINE=Aria TRANSACTIONAL=0 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

SET @NO_START_MESSAGE = 0;
SET @READIES_WEAPONSKILL = 43;

-- Zero-time humanoid skills that historically emitted a scripted ready message.
INSERT INTO `mob_skill_start_messages` VALUES (19,0,@READIES_WEAPONSKILL);   -- Gust Slash
INSERT INTO `mob_skill_start_messages` VALUES (32,0,@READIES_WEAPONSKILL);   -- Fast Blade
INSERT INTO `mob_skill_start_messages` VALUES (33,0,@READIES_WEAPONSKILL);   -- Burning Blade
INSERT INTO `mob_skill_start_messages` VALUES (34,0,@READIES_WEAPONSKILL);   -- Red Lotus Blade
INSERT INTO `mob_skill_start_messages` VALUES (35,0,@READIES_WEAPONSKILL);   -- Flat Blade
INSERT INTO `mob_skill_start_messages` VALUES (36,0,@READIES_WEAPONSKILL);   -- Shining Blade
INSERT INTO `mob_skill_start_messages` VALUES (37,0,@READIES_WEAPONSKILL);   -- Seraph Blade
INSERT INTO `mob_skill_start_messages` VALUES (38,0,@READIES_WEAPONSKILL);   -- Circle Blade
INSERT INTO `mob_skill_start_messages` VALUES (39,0,@READIES_WEAPONSKILL);   -- Spirits Within
INSERT INTO `mob_skill_start_messages` VALUES (40,0,@READIES_WEAPONSKILL);   -- Vorpal Blade
INSERT INTO `mob_skill_start_messages` VALUES (41,0,@READIES_WEAPONSKILL);   -- Swift Blade
INSERT INTO `mob_skill_start_messages` VALUES (42,0,@READIES_WEAPONSKILL);   -- Savage Blade
INSERT INTO `mob_skill_start_messages` VALUES (165,0,@READIES_WEAPONSKILL);  -- Skullbreaker
INSERT INTO `mob_skill_start_messages` VALUES (166,0,@READIES_WEAPONSKILL);  -- True Strike
INSERT INTO `mob_skill_start_messages` VALUES (229,0,@READIES_WEAPONSKILL);  -- Fast Blade II
INSERT INTO `mob_skill_start_messages` VALUES (238,0,@READIES_WEAPONSKILL);  -- Uriel Blade
INSERT INTO `mob_skill_start_messages` VALUES (938,0,@READIES_WEAPONSKILL);  -- Ark Angel HM Circle Blade
INSERT INTO `mob_skill_start_messages` VALUES (939,0,@READIES_WEAPONSKILL);  -- Ark Angel HM Swift Blade
INSERT INTO `mob_skill_start_messages` VALUES (942,0,@READIES_WEAPONSKILL);  -- Ark Angel EV Spirits Within
INSERT INTO `mob_skill_start_messages` VALUES (943,0,@READIES_WEAPONSKILL);  -- Ark Angel EV Vorpal Blade
INSERT INTO `mob_skill_start_messages` VALUES (3502,0,@READIES_WEAPONSKILL); -- Nott

-- Existing encounter dialogue replaces the ordinary ready line for these pools.
INSERT INTO `mob_skill_start_messages` VALUES (968,4006,@NO_START_MESSAGE); -- Qu'Bia Arena Trion: Red Lotus Blade
INSERT INTO `mob_skill_start_messages` VALUES (969,4006,@NO_START_MESSAGE); -- Qu'Bia Arena Trion: Flat Blade
INSERT INTO `mob_skill_start_messages` VALUES (970,4006,@NO_START_MESSAGE); -- Qu'Bia Arena Trion: Savage Blade
INSERT INTO `mob_skill_start_messages` VALUES (973,4249,@NO_START_MESSAGE); -- Throne Room Volker: Red Lotus Blade
INSERT INTO `mob_skill_start_messages` VALUES (974,4249,@NO_START_MESSAGE); -- Throne Room Volker: Spirits Within
INSERT INTO `mob_skill_start_messages` VALUES (975,4249,@NO_START_MESSAGE); -- Throne Room Volker: Vorpal Blade
