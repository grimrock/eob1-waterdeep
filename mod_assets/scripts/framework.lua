--[[
LoG Scripting framework
Created by: JKos
Documentation: http://www.grimrock.net/forum/viewtopic.php?f=14&t=3321

INSTALLATION 
iclude this file to your init.lua after stadard_assets.lua
Like this:
-- import standard assets
import "assets/scripts/standard_assets.lua"

-- import custom assets
import "mod_assets/scripts/framework.lua"


create script entity named logfw_init
and put this code to it:
----------------
options = {}
-- load modules
options.modules = {
   monsters_can_open_doors = false,
   damage_dealing_doors = true,
   illusion_walls = true,
   talk = true,
}

spawn("LoGFramework", 1,1,1,0,'fwInit')
fwInit:open() -- this loads all script entites defined in framework.lua

-- timer will call this method automatically 
-- 0.5 second after the game is started
-- activate loaded modules here
-- you can also set debug-flag on here
function main()
   fw.debug.enabled = true
   talk.activate()
   illusion_walls.activate()
   damage_dealing_doors.activate()
   fwInit:close() --must be called
end
-----------------

DONE
]]

local framework = {}
-- fw ++	
framework.fw = [[
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
	for i,v in pairs(fw.hookOrder[hookNamespace]) do
	  if v == hooksId then
		table.remove(fw.hookOrder[hookNamespace],i)
		break
	  end
	end
	fw.hooks[hookNamespace][hooksId] = nil
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
				-- fw.debugPrint("Hook "..hookNamespace..'.'..id..'.'..methodName..' executed')
				currentHook = hookNamespace..'.'..id..'.'..methodName
				
				local hookFunction = fw.hooks[hookNamespace][id][methodName]
				if type(hookFunction) == "function" then 
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
	local finalRetVal = executeHooks(entityType,methodName,entity,p1,p2,p3)
	if finalRetVal == false then return false end
	
	retVal = executeHooks(entity.name,methodName,entity,p1,p2,p3)
	if retVal == false then return false end
	if retVal ~= nil then finalRetVal = retVal end
	retVal = executeHooks(entity.id,methodName,entity,p1,p2,p3)
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
-- fw --

-- help ++	
framework.help = [[
-- returns all entities at ahead of entity based on it's facing
function entitiesAtAhead(entity,distance)
	local x,  y = getCoordsOfTileAtDir(entity,entity.facing)
	return entitiesAt(entity.level, x, y)
end

function entitiesAtDir(entity,dir,distance)
	local x = 0
	local y = 0
	x,  y = getCoordsOfTileAtDir(entity,dir,distance)
	return entitiesAt(entity.level, x, y)
end

-- returns all entities from entity to dir + distance
function entitiesFromEntityTo(entity,dir, distance)
	local result = {}
	for i = 1,distance do
		for ent in help.entitiesAtDir(entity,dir,i) do
			table.insert(result,ent)
		end
	end
	return result
end

-- searches first entity from  location fromEntity.x,fromEntity.y to fromEntity.facing direction
-- fromEntity can also be regular lua table, but it must have x,y,lavel and facing values {x=3,y=2,level=1,facing=0}
-- distance = how many tiles ahead
-- entityType = filters result by type
-- stopToBarrier = if true(default) search will stop on doors and walls
-- Example: find next monster ahead of party, but at most 5 tiles ahead.
-- nextEntityAheadOf(party,5,'monster')
function nextEntityAheadOf(fromEntity, distance,entityType,stopToBarrier)
	if stopToBarrier == nil then stopToBarrier = true end
	-- copy values to regular table so they can be modified
	local coords = {
		['x']=fromEntity.x,
		['y']=fromEntity.y,
		['level']=fromEntity.level,
		['facing']=fromEntity.facing
	}
	-- check if there is a closed door facing to same direction
	-- on same tile and stop searching immediately
	if stopToBarrier then
		for ent in help.entitiesAtSameTile(coords) do
			if ent.facing == coords.facing and help.isEntityType(ent,'door') and ent:isClosed() then
				return false
			end
		end
	end
	
	for i = 1,distance do
		coords.x,  coords.y = help.getCoordsOfTileAtDir(coords,coords.facing,1)
		for ent in entitiesAt(coords.level, coords.x, coords.y) do
			if stopToBarrier and help.isEntityType(ent,'door') and ent:isClosed() then
				return false
			end
			if help.isEntityType(ent,entityType) then
				return ent
			end			
		end
		if stopToBarrier and help.isWall(coords.x,  coords.y) then return false end	
	end
	return false
end


function joinTables(t1,t2)
	for i,v in pairs(t2)  do
		table.insert(t1,v)
	end
	return t1
end

function getCoordsOfTileAtDir(entity,dir,distance)
	distance = distance or 1
	local dirmodifiers = {
		{x=0,y=-distance},
		{x=distance,y=0},
		{x=0,y=distance},
		{x=-distance,y=0},
	}
	return (entity.x + dirmodifiers[dir+1].x),(entity.y + dirmodifiers[dir+1].y)

end

function entitiesAtSameTile(entity)
	return entitiesAt(entity.level,entity.x ,entity.y)
end

-- returs opposite facing direction of entity. For example if entity is facing 0 (north) returns 2 (south)
function getOppositeFacing(entity)
	return (entity.facing + 2)%4
end
-- checks if entity is a door
function isDoor(entity)
	return type(entity.addPullChain) == "function"
end
--returns table of champions which are alive
function getAliveChampions()
	local result = {}
	for i=1,4 do
		local champ = party:getChampion(i)
		if party:getChampion(i):isAlive() then
			table.insert(result,champ)
		end
	end
	return result
end

function getChampions()
	local result = {}
	for i=1,4 do
		result[i] = party:getChampion(i)
	end
	return result
end

--(obj1 and obj2), in squares. (Thanks to cromcrom)
function getDistance(obj1,obj2)
	local distance = 0
	local XNumber = math.max(obj1.x,obj2.x) - math.min(obj1.x,obj2.x)
	local YNumber = math.max(obj1.y,obj2.y) - math.min(obj1.y,obj2.y)
	distance = XNumber + YNumber
	return distance
end

-- converts list table to set {'value1','value2'} => {'value1'=true,'value2'=true}
function tableToSet(list)
  local set = {}
  for _, l in ipairs(list) do set[l] = true end
  return set
end

--checks if table t has value searchvalue
function tableHasValue(t,searchvalue)
	for _,v in ipairs(t) do
	  if v == searchvalue then
		return true
	  end
	end
	return false
end

-- returns true if entity is of type checktype 
-- item subcategories is also supported eg. item_weapon, item_food or item_consumable
-- eg. help.isEntityType(snail_1,'monster') returns true
-- help.isEntityType(snail_1,'item') returns false
function isEntityType(entity,checktype)

		if fw.lists[checktype] and fw.lists[checktype][entity.name] then return true end
		--check item types
		if string.sub(checktype,1,4) ~= 'item' then return false end
		for itemType, itemList in pairs(fw.lists.item) do
			if (checktype == 'item_'..itemType or checktype == 'item') and itemList[entity.name] then return true end
		end
		return false
end

-- returns an iterator which iterates all entities at level filtered by names-list. 
-- If level is not defined, entites at party.level are iterated
-- Example: 
-- for entity in help.iEntitiesByName('snail') do
--		print(entity.id)
-- end	
-- 
-- for entity in help.iEntitiesByName({'snail','crowern'}) do ...

function iEntitiesByName (names,level)
	if type(names) == 'string' then names = {names} end
	level = level or party.level
	local allEntsIt = allEntities(level)
	names = help.tableToSet(names)	
	local iter = function()
		local nextEnt = allEntsIt() 
		while nextEnt do 
			if names[nextEnt.name] then
				return nextEnt
			end
			nextEnt = allEntsIt()
		end	
	end
	return iter
end
-- checks if tile x,y is a wall
-- thanks to Edsploration

function isWall(x,y)
   spawn("spawner", party.level, x, y, 0, "probe_spawner"):setSpawnedEntity("probe"):activate()
   probe_spawner:destroy()
   for e in entitiesAt(party.level, x, y) do
      if e.name == "probe" then
         e:destroy()
		 return false
      end
	end	
	return e == nil
end

-- WIP
function getEntityType(entity)
	if type(entity.addPullChain) == "function" then return "door" end
end			
		]]
-- help --	

-- data ++
framework.data = [[
registry = {}

function set(entity,key,value)
	if not data.registry[fw.getId(entity)] then data.addEntity(entity) end
	data.registry[fw.getId(entity)][key] = value
end

function addEntity(entity)
	data.registry[fw.getId(entity)] = {}
end

function removeEntity(entity)
	data.registry[fw.getId(entity)] = nil
end

function get(entity,key)
	if not data.registry[fw.getId(entity)] then return nil end
	return data.registry[fw.getId(entity)][key]
end

function unset(entity,key)
	if data.registry[fw.getId(entity)] == nil then return end
	data.registry[fw.getId(entity)][key]=nil
end
]]

	-- data --	

	-- illusion_walls ++
local modules = {}	
modules.illusion_walls =[[
activeWalls = {}

stayOpenAfterPartyPass = true

function isIllusionWall(entity)
	return (string.sub(entity.name,-13) == 'illusion_wall' or string.sub(entity.name,-18) == 'illusion_wall_rune')
end

function activate()
	spawn("timer", 1, 0, 0, 0, "illusion_walls_timer")
	illusion_walls_timer:addConnector('activate','illusion_walls','closeWalls')
	illusion_walls_timer:setTimerInterval(2)
	
	fw.addHooks('party','illusion_walls',{
			onMove = function(self,dir)
				for e in help.entitiesAtDir(self,dir) do
					if (illusion_walls.isIllusionWall(e) and e.facing == (dir + 2)%4) then
						illusion_walls.doTheMagic(e,self)
					end
				end
				for e in help.entitiesAtSameTile(self) do
					if (illusion_walls.isIllusionWall(e) and e.facing == dir) then
						illusion_walls.doTheMagic(e,self)
					end
				end			
			end,
			onAttack = function(champion,weapon)
				fw.hooks.party.illusion_walls.onMove(party,party.facing)
			end
		}
	)

	fw.addHooks('monsters','illusion_walls',{
		onMove = function(self,dir)
				-- for monsters we have to get entities at 2 tiles ahead also, because if the door is facing towards the monster
				-- it can't move to that tile
				for e in help.entitiesAtDir(self,self.facing,2) do
					if (illusion_walls.isIllusionWall(e) and e.facing == (dir + 2)%4) then
						illusion_walls.doTheMagic(e,self)
					end
				end
				for e in help.entitiesAtAhead(self) do
					if (illusion_walls.isIllusionWall(e)) then
						illusion_walls.doTheMagic(e,self)
					end
				end		
				for e in help.entitiesAtSameTile(self) do
					if (illusion_walls.isIllusionWall(e)) then
						illusion_walls.doTheMagic(e,self)
					end
				end			
			end
		}
	)
	

end --activate

function doTheMagic(wall,opener)
	if fw.executeEntityHooks('doors','onPass',wall,opener) == false then
		data.unset(wall,'found')
		wall:setDoorState('closed')
		return
	end
	if data.get(wall,'found') then return end
	wall:setDoorState('open')
	if not findEntity(wall.id..'_fake') then
		spawn(wall.name.."_fake", wall.level, wall.x, wall.y, wall.facing, wall.id..'_fake')
	end	
	if stayOpenAfterPartyPass and opener.name == 'party' then
		data.set(wall,'found',true)
		return
	end
	illusion_walls_timer:activate()
	illusion_walls.activeWalls[wall.id] = true

end

function closeWalls()
	illusion_walls_timer:deactivate()
	for wall_id,_ in pairs(illusion_walls.activeWalls) do
		findEntity(wall_id):setDoorState('closed')
		illusion_walls.activeWalls[wall_id] = nil
	end

end
]]
-- illusion_walls --

-- damage_dealing_doors ++
modules.damage_dealing_doors =[[

damagePowers = {
		wooden=10,iron=30,ornament=15,
		metal=30,portcullis=15,secret=50
	}
	
function deactivate()
	fw.removeHooks('doors','damage_dealing_doors')
	fw.removeHooks('monsters','damage_dealing_doors')
end
	
function activate()
	fw.addHooks('doors','damage_dealing_doors',
		{
			onClose = function(door)
				local damagePower = 10 --default for custom doors
				for doorType,damage in pairs(damage_dealing_doors.damagePowers) do
					if string.find(door.name,doorType) then
						damagePower = damage
					end
				end
				damage_dealing_doors.dealDamage(door,damagePower)
			end
		}
	)

	fw.addHooks('monsters','damage_dealing_doors',
		{
			onMove=function(monst,dir)
				data.set(monst,"dir",dir)
			end,
			onDie = function(monst)
				-- clear dead monsters from data-table
				data.removeEntity(monst)
			end,
			onAttack = function (monst, attack)
				data.set(monst,"dir",monst.facing)
			end,
			onDamage = function(monst)
				 data.unset(monst,"dir")
			end,
		}
	)
end

function dealDamage(door, damagePower)
	-- do some damage to monsters on same tile as the door and moving through it
	local monstersAtDoor = entitiesAt(door.level,door.x,door.y)
	
	for monst in monstersAtDoor do
		if door.facing == data.get(monst,"dir") then
			damageTile(door.level,door.x,door.y,door.facing,5,"physical",damagePower)
		end
	end

	-- do some damage to monsters at other side of the door and moving through it	
	
	local monstersAtOtherSideOfDoor =  help.entitiesAtAhead(door)	
	local door_opposite_facing = help.getOppositeFacing(door)
	for monst in monstersAtOtherSideOfDoor do
		if door_opposite_facing == data.get(monst,"dir") then
			damageTile(monst.level,monst.x,monst.y,door_opposite_facing,5,"physical",damagePower)
		end
	end	
end
]]

--  monsters_can_open_doors ++
modules.monsters_can_open_doors = [[
-- put names of monsters which can open doors here
canOpenDoors = {}

-- put id:s of individual door which can be openend by monsters here. example dungeon_door_metal_1=true
canBeOpened = {}

	fw.addHooks('monsters','monsters_can_open_doors',
		{
			onMove=function(monst,dir)
				monsters_can_open_doors.openDoorAhead(monst)
			end,
			onTurn = function(monst)
				monsters_can_open_doors.openDoorAhead(monst)
			end,
		}
	)

function openDoorAhead(monster)
	if not self.canOpenDoors[monster.name] then return false end
	for e in entitiesAt(monster.level,monster.x,monster.y) do
		if help.isDoor(e) then		
			if monster.facing == e.facing then
				if canBeOpened[e.id] then
					e:open()
				end
			end
		end
	end
	
	for e in help.entitiesAtAhead(monster) do
		if help.isDoor(e) then	
			if help.getOppositeFacing(e) == monster.facing then
				if canBeOpened[e.id] then
					e:open()
				end
			end
		end
	end	

end
]]
--  monsters_can_open_doors --

--  talk ++
modules.talk = [[
spawn('timer',1,0,0,0,'talk_timer')
queue = {}
lastSpeaker = 0

function activate()
	talk_timer:addConnector('activate','talk','printNextFromQueue')
end

function addTalkHook(entity_id,hookName,text,interval,sameAsLastOne,callback)
	if not fw.hooks[entity_id] then
		fw.hooks[entity_id] = {}
	end
	local namespace = 'talk'
	local i = 0
	while fw.hooks[entity_id][namespace] do
		i = i + 1
		namespace = 'talk_'..i
	end
	
	v = {}
	v.text = text
	v.interval = interval
	v.sameAsLastOne = sameAsLastOne
	v.entity_id = entity_id
	v.namespace = namespace
	v.hookName = hookName
	v.callback = callback
	
	fw.addHooks(entity_id,namespace,{})
	fw.setHookVars(entity_id,namespace,hookName,v)
	
	fw.hooks[entity_id][namespace][hookName] = function(self,p1,p2,p3)
		local v = fw.getHookVars()
		talk.championSays(v.text,v.interval,nil,v.sameAsLastOne,v.callback,{self,p1,p2,p3})
		fw.hooks[v.entity_id][v.namespace][v.hookName] = nil
		fw.setHookVars(v.entity_id,v.namespace,v.hookName,nil)
		
	end
	
end

function recreateTimer()
	talk_timer:destroy()
	spawn('timer',1,0,0,0,'talk_timer')
	talk_timer:addConnector('activate','talk','printNextFromQueue')
end

function championSays(text,interval,champNumber,sameAsLastOne,callback,callbackargs)
	interval = interval or 0
	if not champNumber then
		champNumber = talk.getChampionNumber(sameAsLastOne)
	end
	lastSpeaker = champNumber
	local champName = party:getChampion(champNumber):getName()
	
	table.insert(talk.queue,{
			['text']=champName..': '..text,
			['interval']=interval,
			['callback']=callback,
			['args']=callbackargs
		}
	)
	if not talk_timer:isActivated() then
		talk_timer:setTimerInterval(interval)
		talk_timer:activate()
	end
end

function getChampionNumber(sameAsLastOne)
	if (sameAsLastOne) then
		return lastSpeaker
	end
	
	local aliveChampions = help.getAliveChampions()
	if (# aliveChampions == 1) then return aliveChampions[1] end
	
	local n = math.random(# aliveChampions)
	local ok = false
	while n == lastSpeaker do
		n = math.random(4)
	end
	return n
end

function printNextFromQueue()
	talk_timer:deactivate()
	if talk.queue[1].callback then
		if talk.queue[1].callback(unpack(talk.queue[1].args)) then
			hudPrint(talk.queue[1].text)
		end
	else
		hudPrint(talk.queue[1].text)
	end 
	
	table.remove(talk.queue,1)
	if (talk.queue[1]) then
		talk.recreateTimer()
		talk_timer:setTimerInterval(talk.queue[1].interval)
		talk_timer:activate()
	end
end
]]

local monstersList = {
	"crab","crowern","cube","goromorg","green_slime","herder","herder_big",
	"herder_small","herder_swarm","ice_lizard","ogre","scavenger","scavenger_swarm",
	"shrakk_torr","skeleton_archer","skeleton_archer_patrol","skeleton_patrol",
	"skeleton_warrior","snail","spider","tentacles","uggardian","warden","wyvern",
	"eob_kobold","eob_leech","eob_zombie","eob_skeleton","eob_skeleton_g4","eob_kuotoa","eob_flind"
}


local doorsList = { 
	"dungeon_door_iron","dungeon_door_metal","dungeon_door_ornament",
	"dungeon_door_portcullis","dungeon_door_wooden","dungeon_door_wooden_locked",
	"temple_door_iron","temple_door_metal","temple_door_ornament",
	"temple_door_portcullis","temple_door_wooden","temple_door_wooden_locked",
	"dungeon_secret_door","prison_secret_door","temple_secret_door",
	"dungeon_wall_grating","temple_wall_grating", "dungeon_illusion_wall"
}
local itemsList = {
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
	}
}	
 local buttonsList = {"wall_button","dungeon_secret_button_large","dungeon_secret_button_small","temple_secret_button_large",
 "temple_secret_button_small","temple_secret_button_tiny","prison_secret_button_small"} 
local leversList =  {"lever"}  
local pressurePlatesList =  {"dungeon_pressure_plate","temple_pressure_plate","prison_pressure_plate","pressure_plate_hidden"} 
local alcovesList = {"dungeon_alcove","temple_alcove","prison_alcove", "eye_socket_left","eye_socket_right","mouth_socket"}   
local torchHoldersList =  {"torch_holder"} 
local lightSourcesList = {"temple_ceiling_lamp","prison_ceiling_lamp"}  
local pitsList = {"dungeon_pit","temple_pit","prison_pit"} 
local teleportersList = {"teleporter"}
local stairsList = {"dungeon_stairs_down","dungeon_stairs_up","temple_stairs_down","temple_stairs_up","prison_stairs_down","prison_stairs_up"}
local wallTextsList = {"dungeon_wall_text","dungeon_wall_text_long","temple_wall_text","temple_wall_text_long","prison_wall_text","prison_wall_text_long"} 
local decorationsList = { "daemon_head_eye_slots","dungeon_floor_drainage","dungeon_wall_drainage","temple_floor_drainage",
"temple_wall_drainage","prison_floor_drainage","dungeon_ceiling_shaft","temple_ceiling_shaft","prison_ceiling_shaft",
"daemon_head","prison_bench","floor_corpse","floor_dirt","dungeon_spider_web_1",
"dungeon_spider_web_2","dungeon_spider_web_3","dungeon_spider_web_4",
"dungeon_ivy_1","dungeon_ivy_2","dungeon_ceiling_root_1", "dungeon_ceiling_root_2","dungeon_ceiling_root_3",
"dungeon_wall_dirt_1", "dungeon_wall_dirt_2","dungeon_cave_in_ceiling","temple_cave_in_ceiling","prison_cave_in_ceiling",
"dungeon_goromorg_statue","temple_goromorg_statue","prison_goromorg_statue", 
"temple_gladiator_statue_spear", "temple_gladiator_statue_flail", "temple_gladiator_statue_sword",
"temple_gladiator_statue_axe","dungeon_catacomb_empty","dungeon_catacomb_skeleton_up","dungeon_catacomb_skeleton_down",
"temple_catacomb_empty","temple_catacomb_skeleton_up","temple_catacomb_skeleton_down","dungeon_pillar","temple_pillar",
"prison_pillar", "temple_mosaic_wall_1", "temple_mosaic_wall_2", "temple_glass_wall_1", "temple_glass_wall_2", "temple_glass_wall_3",
"prison_wall_1","prison_wall_2", "prison_wall_3", "prison_wall_4", "prison_wall_5", "prison_wall_6", "prison_wall_7"}

local locksList = { "lock","lock_round","lock_ornate","lock_golden","lock_gear","lock_prison"}
local blockagesList = {"barrel_crate_block","spider_eggs","metal_junk_block","dragon_statue","goromorg_fourway","goromorg_fourway_dark","dungeon_cave_in","temple_cave_in","prison_cave_in"}
local receptorsList = {"receptor","receptor_hidden"}
local spellsList = {"fireburst","shockburst","frostburst","fireball","fireball_greater","poison_bolt","poison_bolt_greater","frostbolt","improved_frostbolt","ice_shards","lightning_bolt","lightning_bolt_greater","powerbolt","poison_cloud","blob"}

cloneObject{
	name = "LoGFramework",
	baseObject = "dungeon_door_metal",
	onOpen = function()
		-- load framework sources to script entities
		spawn("script_entity", 1,1,1,0,'fw')
		fw:setSource(framework.fw)
		spawn("script_entity", 1,1,1,0,'help')
		help:setSource(framework.help)
		spawn("script_entity", 1,1,1,0,'data')
		data:setSource(framework.data)		
		-- load modules
		for moduleName,source in pairs(modules) do
			if (logfw_init.options.modules[moduleName]) then
				spawn("script_entity", 1,1,1,0,moduleName)
				script = findEntity(moduleName)
				script:setSource(source)
			end
		end
		spawn('timer',1,0,0,0,'logfw_inittimer')
		logfw_inittimer:addConnector('activate','logfw_init','main')
		logfw_inittimer:setTimerInterval(0.5)
		logfw_inittimer:activate()
	end,
	onClose = function()
		fw.lists['monster'] = help.tableToSet(monstersList)
		fw.lists['door'] = help.tableToSet(doorsList)
		fw.lists['button'] = help.tableToSet(buttonsList)
		fw.lists['blockage'] = help.tableToSet(blockagesList)
		fw.lists['item'] = {}
		for i,v in pairs(itemsList) do
			fw.lists['item'][i] = help.tableToSet(v)
		end
		logfw_inittimer:deactivate()
		logfw_inittimer:destroy()
		fwInit:destroy()		
	
	end
}

cloneObject{
	name = "probe",
	baseObject = "snail",
}

cloneObject{
	name = "dungeon_illusion_wall",
	baseObject = "dungeon_secret_door",
}

defineObject{
   name = "dungeon_illusion_wall_fake",
   class = "Decoration",
   model = "assets/models/env/dungeon_secret_door.fbx",
   placement = "wall",
   editorIcon = 92,
}




for i=1,# monstersList do 
	cloneObject{
		name = monstersList[i],
		baseObject = monstersList[i],
		onMove = function(self,p1,p2,p3) return fw.executeEntityHooks("monsters","onMove",self,p1,p2,p3) end,
		onTurn = function(self,p1,p2,p3) return fw.executeEntityHooks("monsters","onTurn",self,p1,p2,p3) end,
		onAttack = function(self,p1,p2,p3) return fw.executeEntityHooks("monsters","onAttack",self,p1,p2,p3) end,
		onRangedAttack = function(self,p1,p2,p3) return fw.executeEntityHooks("monsters","onRangedAttack",self,p1,p2,p3) end,
		onDamage = function(self,p1,p2,p3) return fw.executeEntityHooks("monsters","onDamage",self,p1,p2,p3) end,
		onDealDamage = function(self,p1,p2,p3) return fw.executeEntityHooks("monsters","onDealDamage",self,p1,p2,p3) end,	
		onDie = function(self,p1,p2,p3) return fw.executeEntityHooks("monsters","onDie",self,p1,p2,p3) end,
		onProjectileHit = function(self,p1,p2,p3) return fw.executeEntityHooks("monsters","onProjectileHit",self,p1,p2,p3) end,		
	}
end

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
	onProjectileHit = function(self,p1,p2,p3) 
		if fw.executeHooks("champion_"..self:getOrdinal(),"onProjectileHit",self,p1,p2,p3) == false then return false end
		return fw.executeHooks("party","onProjectileHit",self,p1,p2,p3) 
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

for i=1,# doorsList do 
	cloneObject{
		name = doorsList[i],
		baseObject = doorsList[i],
		onClose = function(self,p1,p2,p3) return fw.executeEntityHooks("doors","onClose",self,p1,p2,p3) end,
		onOpen = function(self,p1,p2,p3) return fw.executeEntityHooks("doors","onOpen",self,p1,p2,p3) end,		
	}
end

for category,list in pairs(itemsList) do
	if (category ~= 'container') then
		for i=1,# list do 
			cloneObject{
				name = list[i],
				baseObject = list[i],
				-- call item category hooks first eg. 'item_consumable'
				-- then other hooks
				-- if hook returns false other hooks are skipped and item is not consumed even if it's consumable
				-- if hook returns true, item is consumed even it is not consumable
				-- consumable items are consumed by default (if return value is nil or true or there is no custom hooks)
				onUseItem = function(self,p1,p2,p3)
					local retVal = fw.executeHooks('items_'..category,'onUseItem',self,p1,p2,p3)
					
					if retVal == false then return false end
					
					retVal = fw.executeEntityHooks("items","onUseItem",self,p1,p2,p3)
					if retVal == false then return false end
					
					if retVal == nil and fw.lists.item.consumable[self.name] then
						return true
					end
					return retVal

				end,
			}
		end
	end
end

for i=1,# alcovesList do 
	cloneObject{
		name = alcovesList[i],
		baseObject = alcovesList[i],
		onInsertItem = function(self,p1,p2,p3) 
			if fw.executeEntityHooks("alcoves","onInsertItem",self,p1,p2,p3) == false then return false  end
			return true
		end,	
	}
end

for i=1,# blockagesList do 
	cloneObject{
		name = blockagesList[i],
		baseObject = blockagesList[i],
		onDamage = function(self,p1,p2,p3) return fw.executeEntityHooks("blockages","onDamage",self,p1,p2,p3) end,	
		onProjectileHit = function(self,p1,p2,p3) return fw.executeEntityHooks("blockages","onProjectileHit",self,p1,p2,p3) end,
		onDie = function(self,p1,p2,p3) return fw.executeEntityHooks("blockages","onDie",self,p1,p2,p3) end,
	}
end

function createSpell(spellDef)
	defineSpell{
	   name = spellDef.name,
	   uiName = spellDef.uiName,
	   skill =  spellDef.skill,
	   level = spellDef.level,
	   runes = spellDef.runes,
	   manaCost = spellDef.manaCost,
	   onCast = function(champ, x, y, direction, skill) return fw.executeHooks(spellDef.name,"onCast",champ, x, y, direction, skill) end,	
	}
	spellsList[#spellsList+1] = spellDef.name
	
	defineObject{
	   name = 'spell_book_'..spellDef.name,
	   uiName = spellDef.uiName,
		class = "Item",
		model = "assets/models/items/scroll_spell.fbx",
		gfxIndex = 113,
		emptyItem = 'spell_book_'..spellDef.name..'_learned',
		consumable = true,
		weight = 0,
		description = spellDef.description,
	    onUseItem = function(self,p1,p2,p3)
			if fw.executeHooks('items_spell_book','onLearnSpell',self,p1,p2,p3) == false then return false end
			if fw.executeEntityHooks("items","onUseItem",self,p1,p2,p3)  == false then return false end
			return true
		end,	
	}	
	
	cloneObject{
		name = 'spell_book_'..spellDef.name..'_learned',
		baseObject = 'spell_book_'..spellDef.name,
		gfxIndex = 114,
		consumable = false,
		scroll = true,
		spell = spellDef.name,	
		onUseItem = function(self,p1,p2,p3)
			
		end
	}
	
end


