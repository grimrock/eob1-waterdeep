fw_addModule('illusion_walls',[[
activeWalls = {}

stayOpenAfterPartyPass = true

function isIllusionWall(entity)
	return string.sub(entity.name,-13) == 'illusion_wall'
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
)


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

