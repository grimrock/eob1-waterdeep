--[[ 

Status: WIP Not recommended to use yet

]]
fw_addModule('turn_based',[[
monsterMoves = {}
championMoves = {}

partysTurn = true
partyCanMove = true
storedChampStats = {}
skipOnAttack = false
updateStats = false
previousChamp = nil
usedItems = {}

function setPartyCanMove(bool)
	partyCanMove = bool
end

function setSkipOnAttack(bool)
	skipOnAttack = bool
end

function setUpdateStats(bool)
	updateStats = bool
end

function setPreviousChamp(champion)
	previousChamp = champion
end

function startMonstersTurn()
	for monst_id,hasMoved in pairs(turn_based.monsterMoves) do
		turn_based.monsterMoves[monst_id] = false
	end
	hudPrint('Monsters turn')
	turn_based_delaytimer:deactivate()
	turn_based_timer:activate()
	
	unfreezeStats()
end

function endMonstersTurn()
	turn_based_timer:deactivate()
	turn_based.startPartysTurn()
	for id,moved in pairs(monsterMoves) do
		print('active: '..id,moved)
	end
end

function startPartysTurn()
	freezeStats()
	partysTurn = true
	partyCanMove = true
	turn_based_timer:deactivate()
	for n,champ in ipairs(help.getAliveChampions()) do
		championMoves[champ:getOrdinal()] = false
		champ:setCondition('paralyzed', 0)
	end
	hudPrint('Your turn')
end

function endPartysTurn()
	unfreezeStats()
	partysTurn = false
	usedItems = {}
	turn_based_delaytimer:activate()
end

function freezeStats()
	fw.debugPrint('freezed')
	storeStats()
	turn_based_freezetimer:activate()
end

function unfreezeStats()
	turn_based_freezetimer:deactivate()
	fw.debugPrint('unfreezed')
end

function storeStats()
		for i,champ in pairs(help.getAliveChampions()) do
			storedChampStats[champ:getOrdinal()] = {
				energy=champ:getStat('energy'),
				health=champ:getStat('health'),
				slot=i
			}
		end	
end

function resetStats()
	if updateStats then
		updateStats = false
		storeStats()
	end
	local swapChamps = {}
	for i,champ in pairs(help.getChampions()) do
		champ:setStat('energy',storedChampStats[champ:getOrdinal()].energy)
		champ:setStat('health',storedChampStats[champ:getOrdinal()].health)	
		local slot = storedChampStats[champ:getOrdinal()].slot
		
		if slot ~= i and swapChamps[1] == nil then
			if championIsMoved(champ) or championIsMoved(party:getChampion(slot)) then
				swapChamps[1] = slot
				swapChamps[2] = i
			else
				setChampionIsMoved(champ)
				setChampionIsMoved(party:getChampion(slot))
				storeStats()
			end
		end
	end
	if swapChamps[1] then
		party:swapChampions(swapChamps[1],swapChamps[2])
	end
	if isAllChampionsMoved() then
		endPartysTurn()
	end
end

function championIsMoved(champ)
	return championMoves[champ:getOrdinal()]

end

function setChampionIsMoved(champ)
	championMoves[champ:getOrdinal()] = true
	champ:setCondition('paralyzed', 1000)
end

function isAllChampionsMoved()
		for n,champ in ipairs(help.getAliveChampions()) do
			if championMoves[champ:getOrdinal()] == false then return false end
		end
		return true
end

-- returns true if all active monsters have moved, false if not
function isAllMonstersMoved()
	for i,v in pairs(monsterMoves) do 
		if v == false then
			return false 
		end
	end
	return true
end

function reset()
	partysTurn = true
	monsterMoves = {}
	championMoves = {}
	partyCanMove = true
	turn_based_freezetimer:deactivate()
	turn_based_timer:deactivate()	
	usedItems = {}
	for n,champ in ipairs(help.getAliveChampions()) do
		champ:setCondition('paralyzed', 0)
		championMoves[champ:getOrdinal()] = false
	end	
end

-- HOOKS --

partyHook = function(self)
	if not turn_based.partysTurn then
		hudPrint("You can't move while it's monsters turn.")
		return false 
	end
	
	 if not turn_based.partyCanMove  then 
		hudPrint("Party can't move anymore. Attack with all champions or press rest key (R by default) to end your turn.")
		return false 
	end
	turn_based.endPartysTurn()
end

function championHook(champion,p1)
	if not turn_based.partysTurn or turn_based.championMoves[champion:getOrdinal()]  then 
		hudPrint("You can't move while it's monsters turn.")
		return false 
	end
	turn_based.setUpdateStats(true)
	turn_based.setPartyCanMove(false)
	turn_based.setChampionIsMoved(champion)
	if (turn_based.isAllChampionsMoved()) then 
		
		turn_based.endPartysTurn() 
	end
	
end

monstersHook = function(self)
	-- only the monsters on the same level as the party are in turn based mode
	if self.level ~= party.level then return end
	if help.getDistance(party,self) > 8 then return end
	if turn_based.partysTurn then 
		return false 
	end	
	--already moved
	if turn_based.monsterMoves[self.id] == true then
		return false
	end
	-- set as moved
	turn_based.monsterMoves[self.id] = true
	fw.debugPrint(self.id..' moves')
	-- end monsters turn if all monsters have moved
	if turn_based.isAllMonstersMoved() then
		turn_based.endMonstersTurn()
	end
end

function activate()
	local scroll = spawn('scroll')
	local text =  "Use this scroll to enable or disable turn based combat.\n" 
	text = text.."In turn based combat you can move your party one\n"  
	text = text.."tile or act with all champions once.\n"  
	text = text.."Press the rest key (usually R) if you want to end your turn.\n" 
	text = text.."If you press R at the beginning of your turn\n" 
	text = text.."turn based mode will be deactivated. But it\n" 
	text = text.."will be activated again if any monster attacks you.\n" 

	scroll:setScrollText(text)
	
	party:getChampion(1):insertItem(11, scroll)
	--spawn a scroll 
	fw.addHooks(scroll.id,'turn_based',{
		onUseItem = function(item)
			if (fw.hooks.monsters['turn_based_activator']) then
				turn_based.disable()
			else
				turn_based.enable()
			end
		end
	})
	--enable by default
	turn_based.enable()
end

function enable()
	hudPrint('Turn based combat enabled')
	fw.addHooks('monsters','turn_based_activator',{
	   onAttack = function(self)
		  turn_based.startTurnBasedCombat(self)
	   end,
	   onDie = function()
		   turn_based.endTurnBasedCombat()
	   end		
	})	
end
function disable()
	hudPrint('Turn based combat disabled')
	fw.removeHooks('monsters','turn_based_activator')
end

function startTurnBasedCombat()
	if (fw.hooks.monsters.turn_based) then return end
	
	spawn('timer',party.level,0,0,0,'turn_based_timer')
	-- monster turn lasts at most 3 seconds
	turn_based_timer:addConnector('activate','turn_based','endMonstersTurn')
	turn_based_timer:setTimerInterval(3)
	
	-- freezes the party stats
	spawn('timer',party.level,0,0,0,'turn_based_freezetimer')
	turn_based_freezetimer:setTimerInterval(0.1)
	turn_based_freezetimer:addConnector('activate','turn_based','resetStats')
	
	-- add a small delay to the end of the partys turn
	spawn('timer',party.level,0,0,0,'turn_based_delaytimer')
	turn_based_delaytimer:setTimerInterval(0.5)
	turn_based_delaytimer:addConnector('activate','turn_based','startMonstersTurn')	
	
	reset()
	freezeStats()
	
	fw.addHooks('monsters','turn_based',{
		onMove = turn_based.monstersHook,
		onTurn = function(self)
			if self.level ~= party.level then return end
			if help.getDistance(party,self) > 8 then return end
			if turn_based.monsterMoves[self.id] == nil then
				turn_based.monsterMoves[self.id] = false
			end
			if turn_based.partysTurn then return false end
		end,		
		onAttack = turn_based.monstersHook,
		onDie = function(self)
			turn_based.monsterMoves[self.id] = nil
		end
		},
		1
	)
	
	fw.addHooks('party','turn_based',{
			onMove = turn_based.partyHook,	
			onAttack = function (champ,item)
				if turn_based.skipOnAttack and turn_based.previousChamp == champ:getOrdinal() then 
					turn_based.setSkipOnAttack(false)
					return 
				end
				turn_based.setSkipOnAttack(false)
				return turn_based.championHook(champ,item)
			end,
			onCastSpell = turn_based.championHook,
			
			-- onUseItem is called before onAttack when right-clicking item so we have to skip it
			onUseItem = function(champ,item)
				if not turn_based.partysTurn then
					return false
				end
				if (turn_based.usedItems[item.id]) then
					hudPrint('You can use items only once/turn')
					return false
				end
				
				turn_based.usedItems[item.id] = true
				
				turn_based.setSkipOnAttack(true)
				turn_based.setPreviousChamp(champ:getOrdinal())
				return turn_based.championHook(champ,item)
			end,
			
			onRest = function()
				if turn_based.partysTurn then	
					if turn_based.partyCanMove then
						turn_based.endTurnBasedCombat()
					else
						turn_based.endPartysTurn()
					end
				end
				return false
			
			end					
		},
		1
	)
	if (illusion_walls) then	
		illusion_walls_timer:setTimerInterval(500)
	end
	hudPrint('Battle begins')
end

function endTurnBasedCombat()

	hudPrint('Battle ends')
	if not fw.hooks.monsters.turn_based then return end
	fw.debugPrint('turn based mode disabled')
	reset()
	turn_based_timer:destroy()
	turn_based_freezetimer:destroy()
	turn_based_delaytimer:destroy()		
	if (illusion_walls) then
		illusion_walls_timer:setTimerInterval(2)
		illusion_walls:closeWalls()
	end
	fw.removeHooks('party','turn_based')
	fw.removeHooks('monsters','turn_based')

end
]])