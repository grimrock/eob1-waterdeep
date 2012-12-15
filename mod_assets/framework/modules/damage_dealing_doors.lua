fw_addModule('damage_dealing_doors',[[
damagePowers = {
		wooden=10,iron=25,ornament=15,
		metal=20,portcullis=15,secret=35
	}
	
function deactivate()
	fw.removeHooks('doors','damage_dealing_doors')
	fw.removeHooks('monsters','damage_dealing_doors')
end
	
function activate()
	fw.addHooks('doors','damage_dealing_doors',
		{
			onClose = function(door)
				if data.get(door,'opening') then
					return true
				end			
				local damagePower = 10 --default for custom doors
				for doorType,damage in pairs(damage_dealing_doors.damagePowers) do
					if string.find(door.name,doorType) then
						damagePower = damage
					end
				end
				data.set(door,'closing',1)
				fw.repeatFunction(1,1,{door.id},function(door_id) data.removeEntity(door_id) end)
				damage_dealing_doors.dealDamage(door,damagePower)
			end,
			onOpen = function(door)
				if data.get(door,'closing') then
					return true
				end
				data.set(door,'opening',1)
				fw.repeatFunction(1,1.5,{door.id},function(door_id) data.removeEntity(door_id) end)				
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

	-- do some damage to monsters at other side of the door if it's moving through it	
	
	local monstersAtOtherSideOfDoor =  help.entitiesAtAhead(door)	
	local door_opposite_facing = help.getOppositeFacing(door)
	for monst in monstersAtOtherSideOfDoor do
		if door_opposite_facing == data.get(monst,"dir") then
			damageTile(monst.level,monst.x,monst.y,door_opposite_facing,5,"physical",damagePower)
		end
	end	
end
]]
)