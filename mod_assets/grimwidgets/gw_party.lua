fw_addModule('gw_party',[[
function addChampion(newguy)

	-- first let's check if there is empty slot
	for i=1,4 do
		if not party:getChampion(i):getEnabled() then
			chosen(i, newguy)
			return
		end
	end

	-- background border
	local dialog = Dialog.create(-1, -1, 680, 280)
	dialog.color = {128, 128, 128, 200}
	gw.addElement(dialog, 'gui')

	dialog.dialog.text = newguy.name .. " would like to join your party, but since there\n" ..
	        "is already four of you, someone else would have to go.\n" ..
		"Please pick who will be left behind:"

	for i=1,4 do	
		local info = showChampion(i, party:getChampion(i))
		dialog:addChild(info)
		info.x = 30 + (i-1)*130
		info.y = 120
		info.onPress = function(self) chosen(i, newguy) end

		-- we could use info:setRelativePosition({'after','info'..(i-1)}) here,
		-- but that would make the rectangles to touch each other without any
		-- borders or margins
	end
	
	local info = showCandidate(newguy)
	dialog:addChild(info)
	info.x = 30 + 4*130
	info.y = 120
	info.onPress = function(self) chosen(5, newguy) end

end

function chosen(id, newguy)
	
	-- someone from the old party has to go
	if (id >= 1 and id <= 4) then
		setNewChampion(id, newguy)
	end
	
	-- the new guy has to go
	if (id == 5) then
		local tmp
		if newguy.sex == "male" then
			tmp = "him"
		else
			tmp = "her"
		end
		hudPrint(newguy.name .. " turns back and goes away. You never seen "..tmp.." again.")
	end

	gw.removeElement('Dialog', 'gui')
end

function dropAllItems(champion)
	for slot=1,31 do
		local item = champion:getItem(slot)
		if item then
			local saveditem = grimq.saveItem(item)
			champion:removeItem(slot)
			grimq.loadItem(saveditem, party.level, party.x, party.y, party.facing, saveditem.id)			
		end	
	end
end

function addItems(champion, items)
	slot = 31
	for key,val in pairs(items) do
		if val > 0 then
			champion:insertItem(val, spawn(key))
		else
			champion:insertItem(slot, spawn(key))
			slot = slot - 1 
		end
	end
end

function setLevel(champion, level)
	while (champion:getLevel() < level) do
		champion:gainExp(50)
	end

	champion:addSkillPoints(-champion:getSkillPoints())	
end

function resetSkills(champion)
	local names = { "air_magic", "armors", "assassination", "athletics", "axes", "daggers", "dodge",
		     	    "earth_magic", "fire_magic", "ice_magic", "maces", "missile_weapons", "spellcraft",
			        "staves", "swords", "throwing_weapons", "unarmed_combat" }

	-- let's clear out any existing skills
	for i,name in ipairs(names) do
		x = champion:getSkillLevel(name)
		if x > 0 then
			champion:trainSkill(name, -x, false)
		end
	end
end

function setStats(champion, newguy)

	champion:setStatMax("health", newguy.health)
	champion:setStat("health", newguy.current_health)
	
	champion:setStatMax("energy", newguy.energy)
	champion:setStat("energy", newguy.current_energy)
	
	champion:setStatMax("strength", newguy.strength)
	champion:setStatMax("dexterity", newguy.dexterity)
	champion:setStatMax("vitality", newguy.vitality)
	champion:setStatMax("willpower", newguy.willpower)
	champion:setStatMax("protection", newguy.protection)
	champion:setStatMax("evasion", newguy.evasion)

	champion:setStat("strength", newguy.strength)
	champion:setStat("dexterity", newguy.dexterity)
	champion:setStat("vitality", newguy.vitality)
	champion:setStat("willpower", newguy.willpower)
	champion:setStat("protection", newguy.protection)
	champion:setStat("evasion", newguy.evasion)
	
	champion:setStatMax("resist_fire", newguy.resist_fire)
	champion:setStatMax("resist_cold", newguy.resist_cold)
	champion:setStatMax("resist_poison", newguy.resist_poison)
	champion:setStatMax("resist_shock", newguy.resist_shock)

	champion:setStat("resist_fire", newguy.resist_fire)
	champion:setStat("resist_cold", newguy.resist_cold)
	champion:setStat("resist_poison", newguy.resist_poison)
	champion:setStat("resist_shock", newguy.resist_shock)
end

function setSkills(champion, skills)
	
	-- Now let's set skills specified by user
	for key,val in pairs(skills) do
		champion:trainSkill(key, val, false)
	end
end

function resetTraits(champion)
	local traits = { "aggressive", "agile", "athletic", "aura", "cold_resistant", "evasive", "fire_resistant",
					"fist_fighter", "head_hunter", "healthy", "lightning_speed", "natural_armor", "poison_resistant", "skilled", "strong_mind", "tough" }
	for i,name in pairs(traits) do
		if champion:hasTrait(name) then
			champion:removeTrait(name)
		end
	end

end

function setTraits(champion, traits)
	for key, val in pairs(traits) do
		champion:addTrait(val)
	end
end

function setFood(champion, food)
	champion:modifyFood(-champion:getFood())
	champion:modifyFood(food)
end

function setNewChampion(id, newguy)
	
	local x = party:getChampion(id)
	local old_name = x:getName()
	local empty_slot = x:getEnabled()
	x:setName(newguy.name)
	x:setRace(newguy.race)
	x:setClass(newguy.class)
	x:setSex(newguy.sex)
	x:setEnabled(true)
	x:setPortrait(newguy.portrait)
	
	dropAllItems(x)
	addItems(x, newguy.items)
	
	setLevel(x, newguy.level)

	resetSkills(x)
	setSkills(x, newguy.skills)
	
	resetTraits(x)
	setTraits(x, newguy.traits)

	setFood(x, newguy.food)
	
	setStats(x, newguy)
	
	hudPrint(newguy.name.." joins your party. "..old_name.. " will be remembered as a good fellow.")
	gw.removeElement('dialog', 'gui')

end

function showChampion(id, champion)
	local info = gw_button3D.create("info"..id, 0, 0, champion:getName(), 120, 50)
	info.color = {128, 160, 128} -- slightly g
	
	local details = gw_rectangle.create("details"..id, 0, 50, 120, 100)
	details.color = { 192, 192, 255, 50}
	info:addChild(details)
	details.text = champion:getRace() .. "\n" 
	            .. champion:getClass() .. "\n"
	            .. champion:getSex() .. "\n"
				.. champion:getLevel() .. " level"
	details.dontwrap = true
	            	
	return info
end

function showCandidate(champion)
	local info = gw_button3D.create("info5", 0, 0, champion.name, 120, 50 )
	info.color = {128,128,160}
	
	local details = gw_rectangle.create("details5", 0, 50, 120, 100)
	details.color = { 192, 192, 255, 50}
	info:addChild(details)
	details.text = champion.race .. "\n" 
	            .. champion.class .. "\n"
	            .. champion.sex .. "\n"
		    .. champion.level .. " level"
	details.dontwrap = true
	return info
end
]])
