--  monsters_can_open_doors ++
fw_addModule('monsters_can_open_doors',[[
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
]])




--  monsters_can_open_doors --