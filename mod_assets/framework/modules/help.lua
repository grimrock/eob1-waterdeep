--[[
	this module is loaded automatically
]]
fw_addModule('help',[[

function freezeWorld()
   if fw.hooksExists('monsters','fw_freezeWorld') then
		return false
   end
   fw.addHooks('monsters','fw_freezeWorld',{
         onMove = function() return false end,
         onTurn = function() return false end,      
         onAttack = function() return false end,
         onRangedAttack = function() return false end,
      },
	  1
   )
   
   fw.addHooks('party','fw_freezeWorld',{
         onMove = function() return false end,
         onTurn = function() return false end,      
         onAttack = function() return false end,
         onCastSpell = function() return false end,
      },
	  1
   )
end

function unfreezeWorld()
   fw.removeHooks('monsters','fw_freezeWorld')
   fw.removeHooks('party','fw_freezeWorld')
end


-- splits string by delimeter
-- Example: help.split('split.me.ok','.')
function split(p,d)
  local t, ll
  t={}
  ll=0
  if(#p == 1) then return {p} end
    while true do
      l=string.find(p,d,ll,true) -- find the next d in the string
      if l~=nil then -- if "not not" found then..
        table.insert(t, string.sub(p,ll,l-1)) -- Save it in our array.
        ll=l+1 -- save just after where we found it for searching next time.
      else
        table.insert(t, string.sub(p,ll)) -- Save what's left in our array.
        break -- Break at end, as it should be, according to the lua manual.
      end
    end
  return t
end

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
		if stopToBarrier and isWall(coords.level,coords.x,  coords.y) then return false end	
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
-- also entity names are supported help.isEntityType(crowern_1,'crowern') return true
function isEntityType(entity,checktype)
		if type(checktype) == 'table' then
			for _,chkt in ipairs(checktype) do
				if isEntityType(entity,chkt) then
					return true
				end
			end
			return false
		end
		if entity.name == checktype then return true end
		if fw.lists[checktype] and fw.lists[checktype][entity.name] then return true end
		--if checktype == 'party' and entity.name == 'party' then return true end
		
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



--slots: 
--1 (head), 2 (torso), 3 (legs), 4 (feet), 5 (cloak), 6 (neck), 
--7 (left hand), 8 (right hand), 9 (gaunlets), 10 (bracers), 11-31 (backpack slots).

function modifyChampion(def)
	local champ = party:getChampion(def.id)
	if def.items then
		for slot,item in pairs(def.items) do
			if (type(slot) == "string") then
				slot = grimq.inventory[slot]
			end
			
			champ:removeItem(slot)
			
			if type(item) == 'string' then 
				local parts = help.split(item,'*')
				item = spawn(parts[1])
				if parts[2] then
					item:setStackSize(0+parts[2])
				end
				champ:insertItem(slot,item)
			elseif type(item) == 'table' then
			   
				item = grimq.respawnItem(item)
				if item then
					champ:insertItem(slot,item)
				end
			end
		end
	end
	if def.levelUp then
		for i=1,def.levelUp do
			champ:levelUp()
		end
	end
	if def.statsUp then
		for stat,valueUp in pairs(def.statsUp) do
			champ:modifyStat(stat,valueUp)
		end	
	end
	if def.skillsUp then
		for skill,valueUp in pairs(def.skillsUp) do
		    if champ:getSkillPoints() < valueUp then 
				valueUp = champ:getSkillPoints() 
			end
			champ:trainSkill(skill,valueUp,false)
		end	
	end	
	
end
-- remove existing item from dungeon and recreate it with same id
function recreateItem(item,x,y,facing,level)
	if item == nil then 
		print('item not found')
		return  
	end
	local id = item.id
	local name = item.name
	local scrollText = item:getScrollText()
	local fuel = item:getFuel()
	local charges = item:getCharges()
	local stack = item:getStackSize()
	facing = facing or item.facing or 1
	item:destroy()
	if (x and y) then
		level = level or party.level
		item = spawn(name,level,x,y,facing,id)
	else
		item = spawn(name,nil,nil,nil,nil,id)
	end
	if scrollText then item:setScrollText(scrollText) end
	if fuel > 0 then item:setFuel(fuel) end
	if charges > 0 then item:setCharges(charges) end
	if stack > 0 then item:setStackSize(stack) end
	return item
end



-- WIP
function getEntityType(entity)
	if type(entity.addPullChain) == "function" then return "door" end
end			
]])

