--[[
	Core module, 
	this module is loaded automatically
]]
fw_addModule('fw',[[
-- general debug flag
debug = {
	enabled = false
}
hooks = {}
hooks.doors = {}
hooks.monsters = {}
hooks.party = {}
hooks.items = {}

hookOrder = {}
hookVars = {}
currentHook = ''
repeatingTimers = {}

lists = {}

function debugPrint(message)
	if fw.debug.enabled then print(message) end
end

function debugPrintHookOrder(namespace)
	for i,v in ipairs(hookOrder[namespace]) do
		fw.debugPrint(i..":"..v)
	end
end

function repeatFunction(count,interval,callbackargs,callback,instant)
	local timer = spawn('timer',party.level,0,0,0)
	repeatingTimers[timer.id] = {}
	repeatingTimers[timer.id].args = callbackargs
	repeatingTimers[timer.id].count = count
	repeatingTimers[timer.id].callback = callback
	timer:setTimerInterval(interval)
	timer:addConnector('activate','fw','executeRepatingTimer') 
	timer:activate()
	if (instant) then
		executeRepatingTimer(timer)
	end
end

function executeRepatingTimer(timer)
	local args = repeatingTimers[timer.id].args
	repeatingTimers[timer.id].callback(unpack(args))
	repeatingTimers[timer.id].count =  repeatingTimers[timer.id].count -1
	if repeatingTimers[timer.id].count < 1 then
		repeatingTimers[timer.id] = nil
		timer:deactivate()
		timer:destroy()
	end
end 

function delayCall(interval,callback,callbackargs)
   if callbackargs == nill then callbackargs = {} end
   fw.repeatFunction(1, interval, callbackargs, callback, false)
end

function addHooks(hookNamespace,hooksId,hookFunctions,ordinal)
	if (not fw.hooks[hookNamespace]) then
		fw.hooks[hookNamespace] = {}
	end
	if (fw.hooks[hookNamespace][hooksId]) then 
		print("Hooks "..hookNamespace..'.'..hooksId..' already defined')
		return false
	end
	if not fw.hookOrder[hookNamespace] then
		 fw.hookOrder[hookNamespace] = {}
	end
	if (ordinal) then
		table.insert(fw.hookOrder[hookNamespace],ordinal,hooksId)
	else
		table.insert(fw.hookOrder[hookNamespace],hooksId)
	end
	fw.hooks[hookNamespace][hooksId] = hookFunctions

end

function setHook(hookIdString,func,ordinal)
	local parts = help.split(hookIdString,'.')
	local hookNamespace = parts[1]
	local hooksId = parts[2]
	local hookFuncName = parts[3]
	if (not fw.hooks[hookNamespace]) then
		fw.hooks[hookNamespace] = {}
	end
	if (not fw.hooks[hookNamespace][hooksId]) then
		fw.hooks[hookNamespace][hooksId] = {}
	end	
	if fw.hooks[hookNamespace][hooksId][hookFuncName] then
		fw.debugPrint('Warning: Hook '..hookIdString..' was owerwritten')
	else
		setHookOrder(hookNamespace,hooksId,ordinal)
	end
	fw.hooks[hookNamespace][hooksId][hookFuncName] = func
end

function hooksExists(hookNamespace,hooksId)
	if (fw.hooks[hookNamespace] and fw.hooks[hookNamespace][hooksId]) then
		return true
	end
	return false
end


function removeHook(hookIdString)
	hookIdString = hookIdString or currentHook
	local parts = help.split(hookIdString,'.')
	local hookNamespace = parts[1]
	local hooksId = parts[2]
	local hookFuncName = parts[3]
	if fw.hooks[hookNamespace] and fw.hooks[hookNamespace][hooksId] then
		fw.hooks[hookNamespace][hooksId][hookFuncName] = nil
		if #fw.hooks[hookNamespace][hooksId] == 0 then
			removeHooks(hookNamespace,hooksId)
		end
	end
end

function setHookOrder(hookNamespace,hooksId,ordinal)
	if not fw.hookOrder[hookNamespace] then
		 fw.hookOrder[hookNamespace] = {}
	end	
	if (ordinal) then
		table.insert(fw.hookOrder[hookNamespace],ordinal,hooksId)
	else
		table.insert(fw.hookOrder[hookNamespace],hooksId)
	end	
end




function getId(entityOrChampion)
	if entityOrChampion.getOrdinal then
		return 'champion_'..entityOrChampion:getOrdinal()
	end
	return entityOrChampion.id
end

function getById(id)
	local entity = findEntity(id)
	if not entity and string.sub(id,1,9) == 'champion_' then
		return party:getChampion(string.sub(id,-1)+0)
	end
	return entity
end


function setHookVars(hookNamespace,hooksId,hookFunction,vars)
	hookVars[hookNamespace..'.'..hooksId..'.'..hookFunction] = vars
end

function getHookVars()
	return hookVars[currentHook]
end

function removeHooks(hookNamespace,hooksId)
	if (not fw.hooks[hookNamespace]) then return end
	removeHookOrder(hookNamespace,hooksId)
	fw.hooks[hookNamespace][hooksId] = nil
end

function removeHookOrder(hookNamespace,hooksId)
	for i,v in pairs(fw.hookOrder[hookNamespace]) do
	  if v == hooksId then
		table.remove(fw.hookOrder[hookNamespace],i)
		break
	  end
	end
end



function executeHooks(hookNamespace,methodName,entity,p1,p2,p3,p4)
	if not fw.hooks[hookNamespace] then return end
	local returnValue = nil
	local finalReturnValue = nil
	if fw.hookOrder[hookNamespace] then
		local id = ''
		for i=1, # fw.hookOrder[hookNamespace] do
			id = fw.hookOrder[hookNamespace][i]
			if fw.hooks[hookNamespace][id] then
				
				currentHook = hookNamespace..'.'..id..'.'..methodName
				
				local hookFunction = fw.hooks[hookNamespace][id][methodName]
				if type(hookFunction) == "function" then 
					--fw.debugPrint("Hook "..hookNamespace..'.'..id..'.'..methodName..' executed')
					returnValue = hookFunction(entity,p1,p2,p3,p4)
					if returnValue == false then return false end
					if returnValue == true then finalReturnValue = true end
				end
			end
		end
	end
	return finalReturnValue
end

function executeEntityHooks(entityType,methodName,entity,p1,p2,p3)
	local finalRetVal = executeHooks(entity.id,methodName,entity,p1,p2,p3)
	if finalRetVal == false then return false end
	
	local retVal = executeHooks(entity.name,methodName,entity,p1,p2,p3)
	if retVal == false then return false end
	if retVal ~= nil then finalRetVal = retVal end
	
	retVal = executeHooks(entityType,methodName,entity,p1,p2,p3)
	if retVal ~= nil then finalRetVal = retVal end
	
	return finalRetVal
end	

-- custom hooks
	-- item:onPickup
	fw.addHooks('party','CustomItemOnPickup',
		{
			onPickUpItem = function(self,item)
				return fw.executeEntityHooks('items','onPickUp',item,self)
			end
		}
	)

--Vanilla hooks copied from asset pack lua-files ++

	addHooks('spider','default',
		{
		  onDealDamage = function(self, champion, damage)
			if math.random() <= 0.3 then
			  champion:setConditionCumulative("poison", 30)
			end
		  end
		}
	)

	addHooks('ogre','default',
		{
		  onDealDamage = function(self, champion, damage)
			party:shakeCamera(0.5, 0.3)
			party:playScreenEffect("damage_screen")
		  end
		}
	)

	addHooks('tentacles','default',{  
		onDealDamage = function(self, champion, damage)
			if math.random() <= 0.2 then
			  champion:setConditionCumulative("paralyzed", 10)
			end
		  end
		}
	)

	addHooks('shrakk_torr','default',{
		onDealDamage = function(self, champion, damage)
			if math.random() <= 0.35 then
			  champion:setConditionCumulative("diseased", 30)
			end
		  end
		}
	)

	addHooks('warden','default',{
		onDealDamage = function(self, champion, damage)
			party:shakeCamera(0.5, 0.3)
			party:playScreenEffect("damage_screen")
		  end
		}
	)

	addHooks('green_slime','default',{
		onDealDamage = function(self, champion, damage)
			if math.random() <= 0.2 then
			  champion:setConditionCumulative("diseased", 30)
			end
		  end
		}
	)
	addHooks('rotten_pitroot_bread','default',{
		onUseItem = function(self, champion)
			playSound("consume_food")
			if math.random() < 0.5 then
				champion:setCondition("diseased", 20)
			end
			champion:modifyFood(250)
			return true
		end
		}
	)
	addHooks('tome_health','default',{
		onUseItem = function(self, champion)
			playSound("level_up")
			hudPrint(champion:getName().." gained Health +25.")
			champion:modifyStatCapacity("health", 25)
			champion:modifyStat("health", 25)
			return true
		end
		}
	)
	addHooks('tome_wisdom','default',{
		onUseItem = function(self, champion)
			playSound("level_up")
			hudPrint(champion:getName().." gained 5 skillpoints.")
			champion:addSkillPoints(5)
			return true
		end
		}
	)		
	addHooks('tome_fire','default',{
		onUseItem = function(self, champion)
			playSound("level_up")
			hudPrint(champion:getName().." gained Resist Fire +10.")
			champion:trainSkill("fire_magic", 3, true)
			champion:modifyStatCapacity("resist_fire", 10)
			champion:modifyStat("resist_fire", 10)
			return true
		end
		}
	)

	addHooks('water_flask','default',{		
		onUseItem = function(self, champion)
			playSound("consume_potion")
			return true
		end
		}
	)

	addHooks('potion_healing','default',{
		onUseItem = function(self, champion)
			playSound("consume_potion")
			champion:modifyStat("health", 75)
			return true
		end
		}
	)	
	addHooks('potion_energy','default',{
		onUseItem = function(self, champion)
			playSound("consume_potion")
			champion:modifyStat("energy", 75)
			return true
		end
		}
	)	
	addHooks('potion_poison','default',{
		onUseItem = function(self, champion)
			playSound("consume_potion")
			champion:setConditionCumulative("poison", 50)
			return true
		end
		}
	)	
	addHooks('potion_cure_poison','default',{
		onUseItem = function(self, champion)
			playSound("consume_potion")
			champion:setCondition("poison", 0)
			return true
		end
		}
	)	
	addHooks('potion_cure_disease','default',{
		onUseItem = function(self, champion)
			playSound("consume_potion")
			champion:setCondition("diseased", 0)
			champion:setCondition("paralyzed", 0)
			return true
		end
		}
	)	
	addHooks('potion_rage','default',{
		onUseItem = function(self, champion)
			playSound("consume_potion")
			champion:setCondition("rage", 60)
			return true
		end
		}
	)	
	addHooks('potion_speed','default',{
		onUseItem = function(self, champion)
			playSound("consume_potion")
			champion:setCondition("haste", 50)
			return true
		end
		}
	)		
-- Vanilla hooks copied from asset pack lua-files --	
		]]
)

local lists = {}

lists.monster = {
	"crab","crowern","cube","goromorg","green_slime","herder","herder_big",
	"herder_small","herder_swarm","ice_lizard","ogre","scavenger","scavenger_swarm",
	"shrakk_torr","skeleton_archer","skeleton_archer_patrol","skeleton_patrol",
	"skeleton_warrior","snail","spider","tentacles","uggardian","warden","wyvern"
}


lists.door = { 
	"dungeon_door_iron","dungeon_door_metal","dungeon_door_ornament",
	"dungeon_door_portcullis","dungeon_door_wooden","dungeon_door_wooden_locked",
	"temple_door_iron","temple_door_metal","temple_door_ornament",
	"temple_door_portcullis","temple_door_wooden","temple_door_wooden_locked",
	"dungeon_secret_door","prison_secret_door","temple_secret_door",
	"dungeon_wall_grating","temple_wall_grating"
}
lists.item = {
	weapon = { "torch","torch_everburning","machete","long_sword","cutlass","nex_sword","dismantler","cudgel","knoffer","warhammer","flail","ogre_hammer","icefall_hammer","hand_axe","battle_axe","great_axe","ancient_axe","knife","dagger","fist_dagger","assassin_dagger","legionary_spear","venom_edge","venom_edge_empty","lightning_blade","lightning_blade_empty","lightning_rod","lightning_rod_empty","fire_blade","fire_blade_empty","power_weapon"},
	shield = {"legionary_shield","round_shield","heavy_shield","shield_elements","shield_valor"},
	accessory = {"frostbite_necklace","bone_amulet","fire_torc","spirit_mirror_pendant","gear_necklace","hardstone_bracelet","bracelet_tirin","brace_fortitude","huntsman_cloak","tattered_cloak","scaled_cloak","diviner_cloak","serpent_bracer","pit_gauntlets","nomad_mittens","leather_gloves"},
	bomb = {"fire_bomb","shock_bomb","frost_bomb","poison_bomb"},
	food = {"snail_slice","herder_cap","pitroot_bread","rotten_pitroot_bread","rat_shank","boiled_beetle","baked_maggot","ice_lizard_steak","mole_jerky","blueberry_pie"},
	missileweapon = {  "sling","short_bow","crossbow","longbow","arrow","fire_arrow","cold_arrow","poison_arrow","shock_arrow","quarrel","fire_quarrel","cold_quarrel","poison_quarrel","shock_quarrel"},
	tome = {"tome_health","tome_wisdom","tome_fire"},
	armor = {  "hide_vest","leather_brigandine","leather_greaves","leather_cap","leather_boots","ring_mail","ring_greaves","ring_gauntlets","ring_boots","legionary_helmet","iron_basinet","chitin_mail","chitin_greaves","chitin_boots","chitin_mask","plate_cuirass","plate_greaves","full_helmet","plate_gauntlets","plate_boots","cuirass_valor","greaves_valor","helmet_valor","gauntlets_valor","boots_valor"},
	cloth = {  "peasant_breeches","peasant_tunic","peasant_cap","loincloth","leather_pants","doublet","silk_hose","flarefeather_cap","conjurers_hat","circlet_war","lurker_pants","lurker_vest","lurker_hood","lurker_boots","sandals","pointy_shoes","nomad_boots"},
	herb = {"grim_cap","tar_bead","cave_nettle","slime_bell","blooddrop_blossom","milkreed"},
	machinepart = {  "machine_part_north","machine_part_east","machine_part_south","machine_part_west","machine_junk1","machine_junk2","machine_junk3","machine_junk4","machine_junk5","machine_junk6"},
	potion = { "flask","water_flask","potion_healing","potion_energy","potion_poison","potion_cure_poison","potion_cure_disease","potion_rage","potion_speed"},
	staff = {"whitewood_wand","magic_orb","shaman_staff","zhandul_orb"},
	treasure = {"golden_chalice","golden_figure","golden_goromorg","golden_dragon","golden_crown","golden_orb","ancient_apparatus"},
	container = {"sack","wooden_box","mortar"},
	key = {"iron_key","brass_key","gold_key","round_key","ornate_key","gear_key","prison_key"},
	miscitem = { "skull","blue_gem","green_gem","red_gem","compass","remains_of_toorum"},
	scroll = {  "scroll","note","scroll_light","scroll_darkness","scroll_fireburst","scroll_shock","scroll_fireball","scroll_frostbolt","scroll_ice_shards","scroll_poison_bolt","scroll_poison_cloud","scroll_lightning_bolt","scroll_enchant_fire_arrow","scroll_fire_shield","scroll_frost_shield","scroll_poison_shield","scroll_shock_shield","scroll_invisibility"},
	throwingweapon = { "rock","throwing_knife","shuriken","throwing_axe"},
	consumable = {"snail_slice","herder_cap","pitroot_bread","rotten_pitroot_bread","rat_shank","boiled_beetle","baked_maggot","ice_lizard_steak","mole_jerky","blueberry_pie",
		"grim_cap","water_flask","potion_healing","potion_energy","potion_poison","potion_cure_poison","potion_cure_disease","potion_rage","potion_speed"
	},
	custom = {}
}	
lists.button = {"wall_button","dungeon_secret_button_large","dungeon_secret_button_small","temple_secret_button_large",
 "temple_secret_button_small","temple_secret_button_tiny","prison_secret_button_small"} 
lists.alcove = {"dungeon_alcove","temple_alcove","prison_alcove", "eye_socket_left","eye_socket_right","mouth_socket"}   
lists.blockage = {"barrel_crate_block","spider_eggs","metal_junk_block","dragon_statue","goromorg_fourway","goromorg_fourway_dark","dungeon_cave_in","temple_cave_in","prison_cave_in"}
lists.spell = {"fireburst","shockburst","frostburst","fireball","fireball_greater","poison_bolt","poison_bolt_greater","frostbolt","improved_frostbolt","ice_shards","lightning_bolt","lightning_bolt_greater","powerbolt","poison_cloud","blob"}


function fw_getHooks(entityClass,itemSubtype)
	entityClass = string.lower(entityClass)
	if entityClass == 'item' then
		itemSubtype = itemSubtype or 'custom'
		return {
			onUseItem = function(self,p1,p2,p3)
				local retVal = fw.executeHooks('items_'..itemSubtype,'onUseItem',self,p1,p2,p3)
				if retVal == false then return false end
				retVal = fw.executeEntityHooks("items","onUseItem",self,p1,p2,p3)
				if retVal == false then return false end
				if retVal == nil and fw.lists.item.consumable[self.name] then
					return true
				end
				return retVal
			end,
			onEquipItem = function(champion, slot)
				-- check that the fw script is loaded (in editor this is called before the fw is loaded because the everburning torch is spawned to the inventory instantly)
				if not fw or fw.executeEntityHooks == nil then return end 
				local item = champion:getItem(slot)
				local retVal = fw.executeEntityHooks("items","onEquipItem",item,champion,slot)
				return retVal
			end,
			onUnequipItem = function(champion, slot)
				if not fw or fw.executeEntityHooks == nil then return end 
				local item = champion:getItem(slot)
				local retVal = fw.executeEntityHooks("items","onUnequipItem",item,champion,slot)
				return retVal
			end,	
		}
	end
	if entityClass == 'monster' then
		return {
			onMove = function(self,p1,p2,p3) return fw.executeEntityHooks("monsters","onMove",self,p1,p2,p3) end,
			onTurn = function(self,p1,p2,p3) return fw.executeEntityHooks("monsters","onTurn",self,p1,p2,p3) end,
			onAttack = function(self,p1,p2,p3) return fw.executeEntityHooks("monsters","onAttack",self,p1,p2,p3) end,
			onRangedAttack = function(self,p1,p2,p3) return fw.executeEntityHooks("monsters","onRangedAttack",self,p1,p2,p3) end,
			onDamage = function(self,p1,p2,p3) return fw.executeEntityHooks("monsters","onDamage",self,p1,p2,p3) end,
			onDealDamage = function(self,p1,p2,p3) return fw.executeEntityHooks("monsters","onDealDamage",self,p1,p2,p3) end,	
			onDie = function(self,p1,p2,p3) return fw.executeEntityHooks("monsters","onDie",self,p1,p2,p3) end,
			onProjectileHit = function(monster,projectile,damage,damageType) 
				if fw.executeEntityHooks("projectiles","onHit",projectile,monster,damage,damageType) == false then return false end
				return fw.executeEntityHooks("monsters","onProjectileHit",monster,projectile,damage,damageType) 
			end
		}
	end	
	if entityClass == 'door' then
		return {
			onClose = function(self,p1,p2,p3) return fw.executeEntityHooks("doors","onClose",self,p1,p2,p3) end,
			onOpen = function(self,p1,p2,p3) return fw.executeEntityHooks("doors","onOpen",self,p1,p2,p3) end,		
		}	
	end
	if entityClass == 'blockage' then	
		return {
			onDamage = function(self,p1,p2,p3) return fw.executeEntityHooks("blockages","onDamage",self,p1,p2,p3) end,	
			onProjectileHit = function(blockage,projectile,damage,damageType) 
				if fw.executeEntityHooks("projectiles","onHit",blockage,champion,damage,damageType) == false then return false end
				return fw.executeEntityHooks("blockages","onProjectileHit",blockage,projectile,damage,damageType) 
			end,
			onDie = function(self,p1,p2,p3) return fw.executeEntityHooks("blockages","onDie",self,p1,p2,p3) end,	
		}	
	end		
	if entityClass == 'alcove' then	
		return {
			onInsertItem = function(self,p1,p2,p3) 
				if fw.executeEntityHooks("alcoves","onInsertItem",self,p1,p2,p3) == false then return false  end
				return true
			end,		
		}	
	end			
	return {}
end


function fw_defineObject(def)
	local itemSubtype = def.itemCategory or 'custom'
	def.itemCategory = nil
	local hooks = fw_getHooks(def.class,itemSubtype)
	for hookName,hookFunc in pairs(hooks) do
	
		if def[hookName] == nil then
			def[hookName] = hookFunc
		end
	end
	-- Container:onUseItem not supported
	if def.container then
		def.onUseItem = nil	
	end
	
	if entityType == 'item' then	
		-- add item to the items list by subtype
		lists.item[itemSubtype][#lists.item[itemSubtype]] = entityName
		
	end		
	defineObject(def)
end

function fw_addHooks(entityName,entityType,itemSubtype)
	local def = fw_getHooks(entityType,itemSubtype)
	def.name = entityName
	def.baseObject = entityName
	cloneObject(def)	
end


for _,monsterName in pairs(lists.monster) do 
	fw_addHooks(monsterName,'monster')
end

for _,doorName in pairs(lists.door) do 
	fw_addHooks(doorName,'door')
end

for _,blockageName in pairs(lists.blockage) do 
	fw_addHooks(blockageName,'blockage')
end

for _,alcoveName in pairs(lists.alcove) do 
	fw_addHooks(alcoveName,'alcove')
end


for category,list in pairs(lists.item) do
    -- containers and food disabled for now because their behaviour seems to be hard coded 
	if (category ~= 'container' and category ~= 'food' and category ~= 'consumable') then
		for i=1,# list do 
			fw_addHooks(list[i],'item',category)
		end
	end
end

for i=1,# lists.alcove do 
	fw_addHooks(lists.alcove[i],'alcove')
end

for i=1,# lists.blockage do 
	fw_addHooks(lists.blockage[i],'blockage')
end

-- Party hooks
cloneObject{
	name = "party",
	baseObject = "party",
	onAttack = function(self,p1,p2,p3) 
		if fw.executeHooks("champion_"..self:getOrdinal(),"onAttack",self,p1,p2,p3) == false then return false end	
		return fw.executeHooks("party","onAttack",self,p1,p2,p3) 
	end,
	onDamage = function(self,p1,p2,p3)
		if fw.executeHooks("champion_"..self:getOrdinal(),"onDamage",self,p1,p2,p3) == false then return false end	
		return fw.executeHooks("party","onDamage",self,p1,p2,p3) 
	end,
	onDie = function(self,p1,p2,p3) 
		if fw.executeHooks("champion_"..self:getOrdinal(),"onDie",self,p1,p2,p3) == false then return false end
		return fw.executeHooks("party","onDie",self,p1,p2,p3) 
	end,
	onProjectileHit = function(champion,projectile,damage,damageType) 
		if fw.executeEntityHooks("projectiles","onHit",projectile,champion,damage,damageType)  == false then return false end
		if fw.executeHooks("champion_"..champion:getOrdinal(),"onProjectileHit",champion,projectile,damage,damageType) == false then return false end
		return fw.executeHooks("party","onProjectileHit",champion,projectile,damage,damageType) 
	end,
	onUseItem = function(self,p1,p2,p3) 
		if fw.executeHooks("champion_"..self:getOrdinal(),"onUseItem",self,p1,p2,p3) == false then return false end
		return fw.executeHooks("party","onUseItem",self,p1,p2,p3) 
	end,
	onReceiveCondition = function(self,p1,p2,p3) 
		if fw.executeHooks("champion_"..self:getOrdinal(),"onReceiveCondition",self,p1,p2,p3) == false then return false end
		return fw.executeHooks("party","onReceiveCondition",self,p1,p2,p3) 
	end,
	onCastSpell = function(self,p1,p2,p3) 
		if fw.executeHooks("champion_"..self:getOrdinal(),"onCastSpell",self,p1,p2,p3) == false then return false end
		return fw.executeHooks("party","onCastSpell",self,p1,p2,p3) 
	end,
	onLevelUp = function(self,p1,p2,p3) 
		if fw.executeHooks("champion_"..self:getOrdinal(),"onLevelUp",self,p1,p2,p3) == false then return false end
		return fw.executeHooks("party","onLevelUp",self,p1,p2,p3) 
	end,
	onPickUpItem = function(self,p1,p2,p3) return fw.executeHooks("party","onPickUpItem",self,p1,p2,p3) end,
	onRest = function(self,p1,p2,p3) return fw.executeHooks("party","onRest",self,p1,p2,p3) end,	
	onWakeUp = function(self,p1,p2,p3) return fw.executeHooks("party","onWakeUp",self,p1,p2,p3) end,	
	onMove = function(self,p1,p2,p3) return fw.executeHooks("party","onMove",self,p1,p2,p3) end,
	onTurn = function(self,p1,p2,p3) return fw.executeHooks("party","onTurn",self,p1,p2,p3) end,	
}

-- this function is called automatically after the fw script entity is initialized
fw_addModuleInitCallback('fw',function(fw,grimq)
		fw.lists['monster'] = tableToSet(lists.monster)
		fw.lists['door'] = tableToSet(lists.door)
		fw.lists['button'] = tableToSet(lists.button)
		fw.lists['blockage'] = tableToSet(lists.blockage)
		fw.lists['item'] = {}
		for i,v in pairs(lists.item) do
			fw.lists['item'][i] = tableToSet(v)
		end
		grimq.fromAllEntitiesInWorld()
			:foreach(function(e)
					if grimq.isMonster(e) then
						fw.lists['monster'][e.name] = true
					end
					if grimq.isItem(e) then
						local found = false
						for itemType, itemList in pairs(fw.lists.item) do
							if itemList[e.name] then 
								found = true
								break
							end
						end
						if not found then
							fw.lists['item']['custom'][e.name] = true
						end
					end		
					if grimq.isDoor(e) then
						fw.lists['door'][e.name] = true
					end			
				end
			)		
end
)




