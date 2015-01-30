-- This file has been generated by EobConverter v0.9.9

--======================--
--== Default monsters ==--
--======================--

cloneObject {
	name = "eob_kobold",
	baseObject = "skeleton_warrior",
}

cloneObject {
	name = "eob_leech",
	baseObject = "snail",
}

cloneObject {
	name = "eob_zombie",
	baseObject = "skeleton_warrior",
}

cloneObject {
	name = "eob_skeleton",
	baseObject = "skeleton_warrior",
}

cloneObject {
	name = "eob_kuotoa",
	baseObject = "herder_big",
}

cloneObject {
	name = "eob_flind",
	baseObject = "uggardian",
}

cloneObject {
	name = "eob_spider",
	baseObject = "spider",
}

cloneObject {
	name = "eob_dwarf",
	baseObject = "skeleton_warrior",
-- if you attack any of the dwarves in game
-- then remove the dwarven camp blockers and dwarven dialogs
   onDamage = function(self, damage, damageType)
		--counter_dwarf_camp_attacked:increment()
		script_entity_dwarven_camp_attacked.attackDwarves()
	     end
}

cloneObject {
	name = "eob_kenku",
	baseObject = "skeleton_archer",
}

cloneObject {
	name = "eob_mage",
	baseObject = "uggardian",
}

cloneObject {
	name = "eob_drowelf",
	baseObject = "uggardian",
   	onDamage = function(self, damage, damageType)
		for e  in allEntities(7)
		do
		  if string.find(e.name,"eob_drowelf")
		  then e:setAIState("default")
			--hudPrint("activating: " .. e.id)
		  end
	 	  if string.find(e.name,"eob_blocker_drow_patrol") 
		  then 
			hudPrint("destroying: " .. e.id)
			e:destroy()
		  end
		end	
	     end
}

cloneObject {
	name = "eob_skelwar",
	baseObject = "skeleton_warrior",
}

cloneObject {
	name = "eob_drider",
	baseObject = "crab",
}

cloneObject {
	name = "eob_hellhnd",
	baseObject = "shrakk_torr",
}

cloneObject {
	name = "eob_rust",
	baseObject = "crab",
}

cloneObject {
	name = "eob_disbeast",
	baseObject = "ice_lizard",
}

cloneObject {
	name = "eob_shindia",
	baseObject = "skeleton_warrior",
}

cloneObject {
	name = "eob_mantis",
	baseObject = "ogre",
}

cloneObject {
	name = "eob_xorn",
	baseObject = "crab",
}

cloneObject {
	name = "eob_mflayer",
	baseObject = "goromorg",
}

cloneObject {
	name = "eob_xanath",
	baseObject = "cube",
}

cloneObject {
	name = "eob_golem",
	baseObject = "warden",
}

--========================--
--== Generated monsters ==--
--========================--

----------------
--- Level 01 ---
----------------

cloneObject {
	name = "eob_kobold1_1",
	baseObject = "eob_kobold",
	lootDrop = {50, "eob_dagger"},
}

cloneObject {
	name = "eob_kobold2_1",
	baseObject = "eob_kobold",
	lootDrop = {50, "eob_dagger"},
}

defineObject {
	name = "eob_kobold2_1_group",
	class = "MonsterGroup",
	monsterType = "eob_kobold2_1",
	count = 2,
}

cloneObject {
	name = "eob_kobold4_1",
	baseObject = "eob_kobold",
	lootDrop = {50, "eob_dagger"},
}

defineObject {
	name = "eob_kobold4_1_group",
	class = "MonsterGroup",
	monsterType = "eob_kobold4_1",
	count = 4,
}

cloneObject {
	name = "eob_kobold1_2",
	baseObject = "eob_kobold",
	lootDrop = {50, "eob_dagger", 100, "eob_rations_u"},
}

cloneObject {
	name = "eob_kobold1_3",
	baseObject = "eob_kobold",
	lootDrop = {50, "eob_dagger", 100, "eob_mage_scroll_detect_magic"},
}

----------------
--- Level 02 ---
----------------

cloneObject {
	name = "eob_skeleton2_1",
	baseObject = "eob_skeleton",
	lootDrop = {50, "eob_axe_u"},
}

defineObject {
	name = "eob_skeleton2_1_group",
	class = "MonsterGroup",
	monsterType = "eob_skeleton2_1",
	count = 2,
}

cloneObject {
	name = "eob_skeleton2_2",
	baseObject = "eob_skeleton",
	lootDrop = {50, "eob_dwarven_helmet_u"},
}

defineObject {
	name = "eob_skeleton2_2_group",
	class = "MonsterGroup",
	monsterType = "eob_skeleton2_2",
	count = 2,
}

cloneObject {
	name = "eob_skeleton1_1",
	baseObject = "eob_skeleton",
	lootDrop = {50, "eob_axe_u"},
}

cloneObject {
	name = "eob_skeleton4_1",
	baseObject = "eob_skeleton",
	lootDrop = {},
	onDie = function(monster)
		if findEntity("eob_skeleton4_1_c") == nil then
			spawn("counter", 2, 0, 0, 0, "eob_skeleton4_1_c")
		end
		if eob_skeleton4_1_c:getValue() % 4 < 2 then
			if math.random(0,99) < 50 then
				spawn("eob_axe_u", monster.level, monster.x, monster.y, monster.facing, "eob_axe_u_2_8_"..eob_skeleton4_1_c:getValue())
			end
		elseif eob_skeleton4_1_c:getValue() % 4 < 4 then
			if math.random(0,99) < 50 then
				spawn("eob_dwarven_helmet_u", monster.level, monster.x, monster.y, monster.facing, "eob_dwarven_helmet_u_2_8_"..eob_skeleton4_1_c:getValue())
			end
		end
		eob_skeleton4_1_c:increment()
	end,
}

defineObject {
	name = "eob_skeleton4_1_group",
	class = "MonsterGroup",
	monsterType = "eob_skeleton4_1",
	count = 4,
}

----------------
--- Level 03 ---
----------------

cloneObject {
	name = "eob_kuotoa1_1",
	baseObject = "eob_kuotoa",
	lootDrop = {50, "eob_rations_u"},
}

cloneObject {
	name = "eob_flind1_1",
	baseObject = "eob_flind",
	lootDrop = {50, "eob_mace_u", 100, "eob_key_silver_u"},
}

cloneObject {
	name = "eob_flind1_2",
	baseObject = "eob_flind",
	lootDrop = {50, "eob_mace_u"},
}

cloneObject {
	name = "eob_flind2_1",
	baseObject = "eob_flind",
	lootDrop = {50, "eob_mace_u"},
}

defineObject {
	name = "eob_flind2_1_group",
	class = "MonsterGroup",
	monsterType = "eob_flind2_1",
	count = 2,
}

----------------
--- Level 04 ---
----------------

----------------
--- Level 05 ---
----------------

cloneObject {
	name = "eob_dwarf1_1",
	baseObject = "eob_dwarf",
	lootDrop = {50, "eob_dwarven_helmet_u", 100, "eob_rations_u"},


}

cloneObject {
	name = "eob_dwarf2_1",
	baseObject = "eob_dwarf",
	lootDrop = {50, "eob_dwarven_helmet_u", 100, "eob_rations_u"},
}

defineObject {
	name = "eob_dwarf2_1_group",
	class = "MonsterGroup",
	monsterType = "eob_dwarf2_1",
	count = 2,
}

cloneObject {
	name = "eob_dwarf1_2",
	baseObject = "eob_dwarf",
	lootDrop = {50, "eob_axe_u", 100, "eob_rations_u"},
}

cloneObject {
	name = "eob_dwarf4_1",
	baseObject = "eob_dwarf",
	lootDrop = {},
	onDie = function(monster)
		if findEntity("eob_dwarf4_1_c") == nil then
			spawn("counter", 5, 0, 0, 0, "eob_dwarf4_1_c")
		end
		if eob_dwarf4_1_c:getValue() % 4 < 1 then
			if math.random(0,99) < 50 then
				spawn("eob_axe_u", monster.level, monster.x, monster.y, monster.facing, "eob_axe_u_18_14_"..eob_dwarf4_1_c:getValue())
			end
			spawn("eob_rations_u", monster.level, monster.x, monster.y, monster.facing, "eob_rations_u_1"..eob_dwarf4_1_c:getValue())
		elseif eob_dwarf4_1_c:getValue() % 4 < 4 then
			if math.random(0,99) < 50 then
				spawn("eob_dwarven_helmet_u", monster.level, monster.x, monster.y, monster.facing, "eob_dwarven_helmet_u_18_14_"..eob_dwarf4_1_c:getValue())
			end
			spawn("eob_rations_u", monster.level, monster.x, monster.y, monster.facing, "eob_rations_u_2"..eob_dwarf4_1_c:getValue())
		end
		eob_dwarf4_1_c:increment()
	end,
}

defineObject {
	name = "eob_dwarf4_1_group",
	class = "MonsterGroup",
	monsterType = "eob_dwarf4_1",
	count = 4,
}

----------------
--- Level 06 ---
----------------

cloneObject {
	name = "eob_kenku1_1",
	baseObject = "eob_kenku",
	lootDrop = {50, "eob_staff"},
}

cloneObject {
	name = "eob_kenku1_2",
	baseObject = "eob_kenku",
	lootDrop = {50, "eob_rations_u"},
}

cloneObject {
	name = "eob_kenku2_1",
	baseObject = "eob_kenku",
	lootDrop = {},
	onDie = function(monster)
		if findEntity("eob_kenku2_1_c") == nil then
			spawn("counter", 6, 0, 0, 0, "eob_kenku2_1_c")
		end
		if eob_kenku2_1_c:getValue() % 2 < 1 then
			if math.random(0,99) < 50 then
				spawn("eob_rations_u", monster.level, monster.x, monster.y, monster.facing, "eob_rations_u_13_17_"..eob_kenku2_1_c:getValue())
			end
		elseif eob_kenku2_1_c:getValue() % 2 < 2 then
			if math.random(0,99) < 50 then
				spawn("eob_staff", monster.level, monster.x, monster.y, monster.facing, "eob_staff_13_17_"..eob_kenku2_1_c:getValue())
			end
		end
		eob_kenku2_1_c:increment()
	end,
}

defineObject {
	name = "eob_kenku2_1_group",
	class = "MonsterGroup",
	monsterType = "eob_kenku2_1",
	count = 2,
}

----------------
--- Level 07 ---
----------------

cloneObject {
	name = "eob_skelwar2_1",
	baseObject = "eob_skelwar",
	lootDrop = {50, "eob_long_sword_sharp_u"},
}

defineObject {
	name = "eob_skelwar2_1_group",
	class = "MonsterGroup",
	monsterType = "eob_skelwar2_1",
	count = 2,
}

cloneObject {
	name = "eob_skelwar1_1",
	baseObject = "eob_skelwar",
	lootDrop = {50, "eob_long_sword_sharp_u"},
}

cloneObject {
	name = "eob_skelwar1_2",
	baseObject = "eob_skelwar",
	lootDrop = {50, "eob_robe"},
}

cloneObject {
	name = "eob_drowelf1_1",
	baseObject = "eob_drowelf",
	lootDrop = {50, "eob_long_sword_sharp_u"},
   	onDamage = function(self, damage, damageType)
		for e  in allEntities(7)
		do
		  if string.find(e.name,"eob_drowelf")
		  then e:setAIState("default")
			--hudPrint("activating: " .. e.id)
	 	  elseif string.find(e.id,"eob_blocker_drow_patrol") 
		  then 
			--hudPrint("destroying: " .. e.id)
			e:destroy()
		  end
		end	
	      end,
}

cloneObject {
	name = "eob_drowelf2_1",
	baseObject = "eob_drowelf",
	lootDrop = {50, "eob_long_sword_sharp_u"},
   	onDamage = function(self, damage, damageType)
		for e  in allEntities(7)
		do
		  if string.find(e.name,"eob_drowelf")
		  then e:setAIState("default")
			--hudPrint("activating: " .. e.id)
	 	  elseif string.find(e.id,"eob_blocker_drow_patrol") 
		  then 
			--hudPrint("destroying: " .. e.id)
			e:destroy()
		  end
		end	
	     end,
}

defineObject {
	name = "eob_drowelf2_1_group",
	class = "MonsterGroup",
	monsterType = "eob_drowelf2_1",
	count = 2,
   	onDamage = function(self, damage, damageType)
		for e  in allEntities(7)
		do
		  if string.find(e.name,"eob_drowelf")
		  then e:setAIState("default")
			--hudPrint("activating: " .. e.id)
	 	  elseif string.find(e.id,"eob_blocker_drow_patrol") 
		  then 
			--hudPrint("destroying: " .. e.id)
			e:destroy()
		  end
		end	
	     end,
}

defineObject {
	name = "eob_skelwar2_2_group",
	class = "MonsterGroup",
	monsterType = "eob_skelwar2_2",
	count = 2,
}

cloneObject {
	name = "eob_skelwar2_2",
	baseObject = "eob_skelwar",
	lootDrop = {},
	onDie = function(monster)
		if findEntity("eob_skelwar2_2_c") == nil then
			spawn("counter", 7, 0, 0, 0, "eob_skelwar2_2_c")
		end
		if eob_skelwar2_2_c:getValue() % 2 < 1 then
			if math.random(0,99) < 50 then
				spawn("eob_long_sword_sharp_u", monster.level, monster.x, monster.y, monster.facing, "eob_long_sword_sharp_u_30_25_"..eob_skelwar2_2_c:getValue())
			end
		elseif eob_skelwar2_2_c:getValue() % 2 < 2 then
			if math.random(0,99) < 50 then
				spawn("eob_robe", monster.level, monster.x, monster.y, monster.facing, "eob_robe_30_25_"..eob_skelwar2_2_c:getValue())
			end
		end
		eob_skelwar2_2_c:increment()
	end,
}
----------------
--- Level 08 ---
----------------

cloneObject {
	name = "eob_drider1_1",
	baseObject = "eob_drider",
	lootDrop = {50, "eob_spear_u", 100, "eob_spear_u"},
}

defineObject {
	name = "eob_hellhnd_group",
	class = "MonsterGroup",
	monsterType = "eob_hellhnd",
	count = 2,
}

----------------
--- Level 09 ---
----------------

----------------
--- Level 10 ---
----------------

cloneObject {
	name = "eob_mantis1_1",
	baseObject = "eob_mantis",
	lootDrop = {50, "eob_dagger"},
}

cloneObject {
	name = "eob_mantis1_2",
	baseObject = "eob_mantis",
	lootDrop = {50, "eob_halberd_u"},
}

----------------
--- Level 11 ---
----------------

cloneObject {
	name = "eob_mflayer1_1",
	baseObject = "eob_mflayer",
	lootDrop = {50, "eob_robe"},
}

----------------
--- Level 12 ---
----------------

cloneObject {
	name = "eob_golem1_1",
	baseObject = "eob_golem",
	lootDrop = {100, "eob_key_skull_u"},
}

