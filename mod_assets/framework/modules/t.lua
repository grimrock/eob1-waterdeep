fw_addModule('t',[[
-- this script is for testing purposes only, you can call these functions from console. 
-- Eg. type t.to(floor_dirt_13) to console and the party is moved to the location of floor_dirt_13
-- or t.t(22,16,1) moves the party to location level x=22,y=16,level=1. Level is optional (default is party.level)

-- move party to x,y,[level]
-- if the first argument is an entity then teleport to it's location
function to(x,y,level)
	local to_level = level or party.level
	local to_x = x
	local to_y = y
	local to_facing = party.facing
	if x == nil then 
		print('Invalid entity name')
		return
	end
	
	if (type(x) == 'table' and x.x) then
		to_x = x.x
		to_y = x.y
		to_level = x.level
		to_facing = x.facing
	end
	
	party:setPosition(to_x, to_y, to_facing,to_level)
end

-- teleports party to testpoint location and executes testpoint.activate function if defined
-- eg. t.run(testpoint_1)
function run(testpoint)
	if type(testpoint) ~= 'table' or testpoint.name ~= 'testpoint'  then 
		print('Invalid testpoint')
		return
	end
	to(testpoint)
	if testpoint.activate then
		testpoint.activate()
	end
end

-- lists all entities whose name matches to entityName (even partially)
-- eg. t.list('scroll',3) list all entities whose name contains a string 'scroll'
function list(entityName,plevel)
	grimq.fromAllEntitiesInWorld():where(
		function(e) 
			if string.find(e.name, entityName) and (not plevel or e.level == plevel) then
				print('X:'..e.x..', Y:'..e.y..', L:'..e.level..', N:'..e.name..' ID:'..e.id)
			end 
		end
	)
end
]])
cloneObject{
	name = "testpoint",
	baseObject = "script_entity",
	editorIcon = 32,
}