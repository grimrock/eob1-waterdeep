-- This file has been generated by Dungeon Editor beta-1.2.6

-- Eye of the Beholder Monsters --

-- ==================================== --
-- ============= LEVEL 01 ============= --
-- ==================================== --

cloneObject{
   name = "eob_kobold",
   baseObject = "snail",
   model = "mod_assets/models/monsters/snail_red.fbx",
   health = 60,
   exp = 60,
   lootDrop = { }
}

cloneObject{
   name = "eob_leech",
   baseObject = "herder",
   health = 70,
   exp = 70,
   lootDrop = { }
}

-- ==================================== --
-- ============= LEVEL 02 ============= --
-- ==================================== --

cloneObject{
   name = "eob_zombie",
   baseObject = "skeleton_warrior",
   health = 70,
   accuracy = 9,
   protection = 4,
   coolDown = { 1, 4 },
   exp = 80,
   lootDrop = { }
}

cloneObject{
   name = "eob_skeleton",
   baseObject = "skeleton_warrior",
   health = 90,
   attackPower = 9,
   accuracy = 10,
   protection = 5,
   coolDown = { 1, 4 },
   exp = 85,
   lootDrop = { 50, "hand_axe"}
}
defineObject{
	name = "eob_skeleton_g4",
	class = "MonsterGroup",
	monsterType = "eob_skeleton",
	count = 4,
}

-- ==================================== --
-- ============= LEVEL 03 ============= --
-- ==================================== --

cloneObject{
	name = "eob_kuotoa",
	baseObject = "ice_lizard",
	health = 150,
	exp = 125,
	attackPower = 14,
	protection = 5,
	evasion = 6,
	accuracy = 15,
	movementCoolDown = 3,
	coolDown = { 1, 4 },
	healthIncrement = 20,
	attackPowerIncrement = 5,
	lootDrop = { }
}

cloneObject{
	name = "eob_flind",
	baseObject = "warden",
	health = 160,
	exp = 160,
	attackPower = 16,
	protection = 6,
	evasion = 7,
	accuracy = 18,
	movementCoolDown = 2,
	coolDown = { 1, 4 },
	healthIncrement = 20,
	attackPowerIncrement = 10,
	lootDrop = { }
}