-- This file has been generated by Dungeon Editor beta-1.2.6

-- Eye of the Beholder Items --

-- ==================================== --
-- ============= LEVEL 01 ============= --
-- ==================================== --

cloneObject{
	name = "eob_rock",
	baseObject = "rock",
	uiName = "Rock",
}

cloneObject {
	name = "eob_rock_glowing",
	baseObject = "eob_rock",
	uiName = "Igneous Rock",
}

cloneObject{
	name = "eob_note_commission",
	baseObject = "note",
	uiName = "Letter",
	description = "Commission and Letter of Marque",
}

cloneObject{
	name = "eob_rations",
	baseObject = "pitroot_bread",
	uiName = "Rations",
	nutritionValue = 270,
	weight = 0.5,
}
cloneObject{
	name = "eob_iron_rations",
	baseObject = "pitroot_bread",
	uiName = "Iron Rations",
	nutritionValue = 650,
	weight = 0.9,
}

cloneObject{
	name = "eob_lock_picks",
	baseObject = "machine_part_south",
	uiName = "Lock Picks",
	description = "Set of a special Lock Picks",
	gfxIndex = 1,
    gfxAtlas = "mod_assets/textures/gui/items_3.tga",
	model = "mod_assets/models/items/lockpick/eob_lockpicks.fbx",
	key = true,
	weight = 0.5,
}

cloneObject{
	name = "eob_remains_of_tod_uphill",
	baseObject = "remains_of_toorum",
	uiName = "Halfling Bones",
	description = "Remains of Tod Uphill, a brave halfling thief.",
}

cloneObject{
	name = "eob_short_sword",
	baseObject = "machete",
	uiName = "Short Sword",
}

cloneObject{
	name = "eob_dagger",
	baseObject = "dagger",
	uiName = "Dagger",
	description = "Throwing Dagger",
	skill = "throwing_weapons",
	key = true,
	throwingWeapon = true,
	attackMethod = "throwAttack",
	attackSound = "swipe",
	impactSound = "impact_blade",
	stackable = true,
	sharpProjectile = true,
	projectileRotationSpeed = -15,
	--projectileRotationX = 90,
	--projectileRotationY = 90,
    projectileRotationZ = 90,
	weight = 0.3,
}

defineObject{
	name = "eob_dagger_guinsoo",
	class = "Item",
	uiName = "Guinsoo",
	model = "assets/models/items/assassin_dagger.fbx",
	description = "Powerfull throwing dagger called Guinsoo.",
	skill = "throwing_weapons",
	throwingWeapon = true,
	damageType = "physical",
	gfxIndex = 142,
	attackPower = 11,
	accuracy = 8,
	coolDownTime = 2.8,
	attackMethod = "throwAttack",
	attackSound = "swipe_light",
	impactSound = "impact_blade",
	sharpProjectile = true,
	projectileRotationSpeed = -10,
	-- projectileRotationX = 90,
	-- projectileRotationY = 90,
	projectileRotationZ = 90,
	weight = 0.8,
}

cloneObject{
	name = "eob_scroll_detect_magic",
	baseObject = "scroll",
	uiName = "Scroll of Detect Magic",
	description = "Mage scroll of Detect Magic.",
}
--[[
cloneObject{
	name = "eob_scroll_armor",
	baseObject = "scroll_armor",
	uiName = "Scroll of Armor",
	description = "Mage scroll of Armor.",
}]]
cloneObject{
	name = "eob_scroll_bless",
	baseObject = "scroll",
	uiName = "Scroll of Bless",
	description = "Cleric scroll of Bless.",
}

cloneObject{
	name = "eob_dart_2",
	baseObject = "shuriken",
	uiName = "Dart +2",
}

cloneObject{
	name = "eob_arrow",
	baseObject = "arrow",
	uiName = "Arrow",
}

cloneObject{
	name = "eob_shield",
	baseObject = "round_shield",
	uiName = "Shield",
}

-- ==================================== --
-- ============= LEVEL 02 ============= --
-- ==================================== --

cloneObject{
	name = "eob_stone_dagger",
	baseObject = "dagger",
	uiName = "Stone Dagger",
	gfxIndex = 0,
    gfxAtlas = "mod_assets/textures/gui/items_3.tga",
	model = "mod_assets/models/items/stone_dagger.fbx",
	key = true,
	attackPower = 5,
	accuracy = 3,
	weight = 0.5,
	glitterEffect = "magic_glow_blue",
}

cloneObject{
	name = "eob_silver_key",
	baseObject = "round_key",
	uiName = "Silver Key",
	description = "Silver Key.",
}
cloneObject{
	name = "eob_gold_key",
	baseObject = "gold_key",
	uiName = "Gold Key",
	description = "Gold Key.",
}
--[[
cloneObject{
	name = "eob_scroll_shield",
	baseObject = "scroll_shield",
	uiName = "Scroll of Shield",
	description = "Mage scroll of Shield.",
}
cloneObject{
	name = "eob_scroll_invisibility",
	baseObject = "scroll_invisibility",
	uiName = "Scroll of Invisibility",
	description = "Mage scroll of Invisibility.",
}
]]

cloneObject{
	name = "eob_sling",
	baseObject = "sling",
	uiName = "Sling",
}

cloneObject{
	name = "eob_bow",
	baseObject = "short_bow",
	uiName = "Bow",
}

cloneObject{
	name = "eob_leather_boots",
	baseObject = "leather_boots",
	uiName = "Leather boots",
}

cloneObject{
	-- potion of healing with blue icon --
	name = "eob_potion_healing",
	baseObject = "potion_healing",
	uiName = "Potion of Healing",
	gfxIndex = 145,
	onUseItem = function(self, champion)
		playSound("consume_potion")
		champion:modifyStat("health", 50)
		return true
	end,
	weight = 0.6,
}
cloneObject{
	-- potion of extra healing with blue icon --
	name = "eob_potion_healing_extra",
	baseObject = "potion_healing",
	uiName = "Potion of Extra Healing",
	gfxIndex = 145,
	onUseItem = function(self, champion)
		playSound("consume_potion")
		champion:modifyStat("health", 100)
		return true
	end,
	weight = 0.9,
}

cloneObject{
	-- potion of extra healing with green icon --
	name = "eob_potion_vitality",
	baseObject = "potion_healing",
	uiName = "Potion of Vitality",
	description = "Refresh a hungry character.",
	gfxIndex = 147,
	onUseItem = function(self, champion)
		playSound("consume_potion")
		champion:modifyFood(1000)
		hudPrint(champion:getName().." feels no longer hungry!")
		return true
	end,
	weight = 0.6,
}

cloneObject{
	name = "eob_potion_giant_strength",
	baseObject = "potion_healing",
	uiName = "Potion of Giant Strength",
	description = "After drink, character obtain the Giant Strenght for 1 minute.",
	gfxIndex = 149,
	onUseItem = function(self, champion)
		playSound("consume_potion")
		local effect = "strBoost"
		local amount = 10
		local duration = 60
		local str_old = champion:getStatMax("strength")
		local isActive = scriptEffects.activateEffect( effect, champion:getOrdinal(), amount, duration)
		if isActive then
			champion:modifyStatCapacity("strength", amount)
			champion:modifyStat("strength", amount)
			fw.debugPrint("Actual Str="..str_old..", Max="..champion:getStatMax("strength"))
			hudPrint(champion:getName().." feels much stronger!")
		else
			hudPrint(champion:getName().." can use only one effect of Giant Strength at the same time!")
		end
		return true
	end,
	weight = 0.6,
}

-- ==================================== --
-- ============= LEVEL 03 ============= --
-- ==================================== --
cloneObject{
	name = "eob_mace",
	baseObject = "knoffer",
	uiName = "Mace",
}

cloneObject{
	name = "eob_scroll_cause_light_wnds",
	baseObject = "scroll",
	uiName = "Scroll of Cause Light Wnds",
	description = "Cleric Scroll of Cause Light Wounds.",
}

cloneObject{
	name = "eob_gem_red",
	baseObject = "red_gem",
	uiName = "Red Gem",
}
cloneObject{
	name = "eob_gem_blue",
	baseObject = "blue_gem",
	uiName = "Blue Gem",
}

cloneObject{
	name = "eob_dagger_backstabber",
	baseObject = "eob_dagger_guinsoo",
	uiName = "Backstabber",
	model = "assets/models/items/assassin_dagger.fbx",
	description = "Throwing dagger called `Backstabber`.",
	attackPower = 12,
	accuracy = 9,
	coolDownTime = 2.5,
	weight = 0.8,
}

-- ==================================== --
-- ====  New Items - Experimental ===== --
-- ==================================== --

cloneObject{
	name = "eob_note_map_level1",
	baseObject = "note",
	uiName = "Sewer System Map - Level 1",
}

-- + Wently's Notes defined in notes.lua + --
-- --------------------------------------- --
--	name = "wentlys_note",
--	baseObject = "note",
--	uiName = "Wently's note",
-- --------------------------------------- --


-- carlos

	defineObject{
		name = "torch",
		class = "Item",
		uiName = "Torch",
		model = "assets/models/items/torch.fbx",
		gfxIndex = 130,
		torch = true,
		fuel = 1100,
		attackPower = 4,
		accuracy = 0,
		coolDownTime = 3,
		attackMethod = "meleeAttack",
		attackSwipe = "vertical",
		attackSound = "swipe",
		impactSound = "impact_blunt",
		weight = 1.2,
	}
