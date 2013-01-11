fw_loadModule('fw_fx')
fw_addModule('fw_magic',[[
activeSpells = {}
selector = {
	skill = 0,
	onSelectChampion = nil,
	caster_id = nil
}

spells = {}

mages = {}

testMode = false

function setTestMode(enabled)
	testMode = enabled
end

function getSpells()
	return spells
end

function activate()
	-- scroll hook --
	
	fw.addHooks('scrolls','fw_magic',{
		onReadScroll = function(scroll,champ) 
			local spellName = string.sub(scroll.name,8)
			if champ:getClass() ~= 'Mage' or fw_magic.spells[spellName].level > champ:getLevel() then
				return false
			end
			fw.executeHooks(spellName,'onCast',champ, party.x, party.y, party.facing, champ:getLevel())
			return true
		end
	})	
	

	
end

function enableSpellBook()
	for i,champ in ipairs(help.getChampions()) do
		if champ:getClass() == 'Mage' then
			data.set(champ,'learnedSpells',{})	
			addSpellBookToChampion(champ)
		end
	end	
	
	if not testMode then
		fw.addHooks('party','fw_magic',{
			onCastSpell = fw_magic.canCast
		},1)
	end		
	fw.addHooks('items_spell_book','fw_magic',{
		onLearnSpell = fw_magic.onLearnSpell
	})	
end

function onLearnSpell(scroll,champion)
	local spellName = string.sub(scroll.name,12)
	local spellDef = fw_magic.spells[spellName]
	if spellDef.skill then
		if champion:getSkillLevel(spellDef.skill) < spellDef.level then
			hudPrint("Not skilled enough to learn this spell")
			return false
		end
	elseif champion:getLevel() < spellDef.level then
		hudPrint("Not skillfull enough to learn this spell")
		return false	
	end
	learnSpell(spellName,champion,scroll)

	return true
end

function learnSpell(spellName,champion,scroll)
	local spells = data.get(champion,'learnedSpells')
	spells[spellName] = true
	data.set(champion,'learnedSpells',spells)
	hudPrint('Learned a new spell: '..scroll:getUIName())
	playSound('discover_spell')
	--spawnSpellBook(champion)
end


function defineSpell(spellDef)
	spells[spellDef.name] = spellDef
	
	if not spellDef.onCast then
		fw.setHookVars(spellDef.name,'fw_magic_spells','onCast',spellDef.name)
		spellDef.onCast = function(caster)
		 	local spellName = fw.getHookVars()
			fw_magic.shootSpell(spellName,caster)
		end
	end
	
	--default onHit-hook
	
	if spellDef.projectile and not spellDef.onHit then
		spellDef.onHit = function(projectile,target,damage,damageType)
			if target.getOrdinal then
				target = party
			end	
			local spellName = fw.getHookVars()
			local caster = fw.getById(data.get(projectile,'caster_id')) 
			fw_magic.dealSpellDamage(spellName,caster,target.x,target.y)
			return false
		end	
	end

	fw.addHooks(spellDef.name,'fw_magic_spells',{
		onCast = spellDef.onCast
	})		
	for i=1, #mages do
		spawnSpellBook(party:getChampion(mages[i]))
	end

end

function dealSpellDamage(spellName,caster,target_x,target_y)
	
		local dir = caster.facing
		if caster.getOrdinal then	
			dir = party.facing		
		end

			local damageArea = fw_magic.spells[spellName].area
					
			if (damageArea) then
				
				local from_x,to_x,from_y,to_y = 0,0,0,0
				if dir == 0 then
					from_x = damageArea.from[2]
					to_x =  damageArea.to[2]
					from_y = - damageArea.to[1]
					to_y =  - damageArea.from[1]					
				elseif dir == 1 then
					from_x = damageArea.from[1]
					to_x =  damageArea.to[1]
					from_y = damageArea.from[2]
					to_y =  damageArea.to[2]					
				elseif dir == 2 then
					from_x = damageArea.from[2]
					to_x =  damageArea.to[2]
					from_y = damageArea.from[1]
					to_y =  damageArea.to[1]						
				else
					from_x = -damageArea.to[1]
					to_x =  -damageArea.from[1]
					from_y = -damageArea.to[2]
					to_y =  -damageArea.from[2]					
				end
				
				for x = from_x,to_x do
					for y = from_y,to_y do
						fw_magic.doDamage(spellName,caster,target_x + x, target_y + y)		
					end
				end 
			else
				fw_magic.doDamage(spellName,caster,target_x,target_y)	
			end
		
end

function doDamage(spellName,caster,x,y)
		local originator = 0
		local damage = fw_magic.spells[spellName].calculateDamage(caster)
		local damageType = fw_magic.spells[spellName].damageType
		
		if caster.getOrdinal then
			originator = 2 ^ (caster:getOrdinal()+1) 	
			caster = party		
		end
		
		damageTile(caster.level,x, y,(caster.facing + 2)%4,originator+1, damageType,damage)
		local fxName = fw_magic.spells[spellName].onHitParticleEffect
		local fx = spawn('fx',caster.level,x ,y ,0)		
		fx:setParticleSystem(fxName)
		fx:translate(0,1,0)				
		local light = fw_fx.getLightPreset(spellName..'_hit')
		if light then
			fx:setLight(unpack(light))	
		end

		if fw_magic.spells[spellName].onHitSound then
			playSoundAt(fw_magic.spells[spellName].onHitSound,caster.level,x,y)
		end 		
			
end


function addSpell(spellName,hookFunction,projectileName)
	fw.addHooks(spellName,'fw_magic_spells',{
			onCast = hookFunction
		}
	)
	
	local onHitHook = function(projectile,target,damage,damageType)
			if target.getOrdinal then
				target = party
			end	
			local caster = fw.getById(data.get(projectile,'caster_id')) 
			
			if caster.getOrdinal then
				local originator = 2 ^ (caster:getOrdinal()+1) 			
				damageTile(target.level,target.x,target.y,(target.facing + 2)%4,originator, damageType,damage)
				return false
			end
			
		end	
	
	if projectileName then
		fw.addHooks(projectileName,'fw_magic_spells',{
			onHit = onHitHook
		})	
	end
end


function createTargetSelector()
	if inventory_scanner then
		destroyTargetSelector()	
	end
	local selectorCursor = spawn('spell_selector',nil,nil,nil,nil,'spell_selector')
	setMouseItem(selectorCursor)
	spawn('timer',party.level,0,0,0,'inventory_scanner')
	inventory_scanner:setTimerInterval(0.1)
	inventory_scanner:addConnector('activate','fw_magic','scanInventory')
	inventory_scanner:activate()
	return selector
end

function destroyTargetSelector()
		local selectorCursor = findEntity('spell_selector')
		if (selectorCursor) then
			selectorCursor:destroy()
		end
		inventory_scanner:deactivate()
		inventory_scanner:destroy()	
end

function scanInventory()
	
	for ordinal, champ in ipairs(help.getChampions()) do
		for slot=1,31 do 
			local item = champ:getItem(slot)
			if item and item.name == 'spell_selector' then
				champ:removeItem(slot)
				selector.onSelectChampion(champ,selector.skill,selector.caster_id)
				if (getMouseItem() and getMouseItem().name == 'spell_selector') then
					setMouseItem()
				elseif getMouseItem() then
					champ:insertItem(slot,getMouseItem())
					setMouseItem()
				end
				item:destroy()
				break
			end
		end
	end
	if getMouseItem() == nil or getMouseItem().name ~= 'spell_selector' then
		destroyTargetSelector()	
		if selector.afterCast then
			selector.afterCast(selector.caster_id)
		end
	end
end

-- creates a  spell timer
-- entity = affected entity, 
-- time = how many seconds spells effect  lasts 
-- destructorName = name of the function which is called when the effect of the spell is worn out.
--                  {script_entity_name,function_name}
-- returns id of timer
function createSpellTimer(entity,time,destructorName)
	local timer = spawn('timer',party.level,0,0,0)
	timer:setTimerInterval(time)
	-- store entity.id to table indexed by timer.id so we can access it in spell-destructor
	activeSpells[timer.id] = fw.getId(entity)
	
	if (not destructorName) then
		destructorName = {'fw_magic','spellTimerDestructor'}
	end
	
	timer:addConnector('activate',destructorName[1],destructorName[2])
	timer:activate()
	return timer.id
end

function spellTimerDestructor(timer)
	fw.removeHooks(fw_magic.activeSpells[timer.id],timer.id)
	fw.debugPrint(fw_magic.activeSpells[timer.id]..' spell effect ended')
	fw_magic.activeSpells[timer.id] = nil
	timer:deactivate()
	timer:destroy()

end

function castSpell(spellName,caster)
	fw.executeHooks(spellName,'onCast',caster)
end

function shootSpell(spellName,caster,speed,damage,fx,onHitFx,sound,onHitSound,area)

	local spellDef = spells[spellName]
	sound = sound or spellDef.sound
	onHitSound = onHitSound or spellDef.onHitSound
	speed = speed or spellDef.speed
	
	if spellDef.calculateDamage then
		damage = spellDef.calculateDamage(caster) 
	else
		damage = damage or 0
	end
	
	fx = fx or spellDef.particleEffect
	onHitFx = onHitFx or spellDef.onHitParticleEffect

    local caster_id = fw.getId(caster)

	if caster.getOrdinal then 
		caster = party 
	end

	shootProjectile(spellDef.projectile, caster.level, caster.x, caster.y, caster.facing, speed, 0, 0, 0, 0, 0,
		damage, caster, true)

	local projectile = nil
	for ent in entitiesAt(caster.level, caster.x, caster.y) do
		if ent.name == spellDef.projectile then
			projectile = ent
			break
		end
	end
	data.set(projectile,'caster_id',caster_id)
	
	fw.setHookVars(projectile.id,'fw_magic_spells','onHit',spellDef.name)
	fw.addHooks(projectile.id,'fw_magic_spells',{
		onHit=spellDef.onHit
	})
	if fx then
    	local effect = fw_fx.addProjectileEffect(projectile,fx,speed,onHitFx,sound,onHitSound)
	end
	
	return projectile 	
end

function canCast(caster,spellName)
	if data.get(caster,'learnedSpells')[spellName] then return true end
	hudPrint(caster:getName().." haven't learned this spell yet")
	playSound('swipe')
	return false	
end

-- SPELL BOOK ++

function addSpellBookToChampion(champion)
	spawnSpellBook(champion)
	table.insert(mages,champion:getOrdinal())
	preventPickingUpSpellBook()
end

function spawnSpellBook(champion)
	local champId = '_'..champion:getOrdinal()

	local book = champion:getItem(11)
	if book and string.sub(book.name,1,11) == 'spell_book_' then
		champion:removeItem(11)
		-- this is the only way to close the container gui if it's opened
		for c in book:containedItems() do
			champion:insertItem(11,c)
			champion:removeItem(11)
		end
	end
	
	book = spawn('spell_book_mage',nil,nil,nil,nil,'spell_book_mage'..champId)
	
	for i=1,5 do 
		local chapter = spawn('spell_book_level_'..i,nil,nil,nil,nil,'spell_book_level'..i..champId)
		book:addItem(chapter)
		for spellName,properties in pairs(fw_magic.spells) do
			if properties.book_page == i then
				if data.get(champion,'learnedSpells')[spellName] then
					chapter:addItem(spawn('spell_book_'..spellName..'_learned',nil,nil,nil,nil,'spell_book_'..spellName..champId))
				else
					chapter:addItem(spawn('spell_book_'..spellName,nil,nil,nil,nil,'spell_book_'..spellName..champId))	
				end
			end
		end
	end
	
	local item = champion:getItem(11)
	if (item) then
		if string.sub(item.name,1,11) ~= 'spell_book_' then
			setMouseItem(item)
		end
		champion:removeItem(11)
	end
	champion:insertItem(11,book)	
end



function preventPickingUpSpellBook()
	if spell_book_timer then
		return
	end
	local sbtimer = timers:create('spell_book_timer') 

	sbtimer:setTimerInterval(0.2)
	sbtimer:addConnector('activate','fw_magic','spellBookScanner')
	sbtimer:setConstant()
	sbtimer:activate()
end

function spellBookScanner()
	local mouseItem = getMouseItem()
	for _,i in ipairs(mages) do
		local book = findEntity('spell_book_mage_'..i)
		-- respawn spell book if it is in dungeon or 
		-- the book or any of it pages is set as mouse item
		if book or (mouseItem and string.sub(mouseItem.name,1,11) == 'spell_book_') then
			if book then
				book:destroy()
			end	
			setMouseItem()
			spawnSpellBook(party:getChampion(i))
		end
	end
	
end

-- monsters spell support

function addSpellsToMonsters(monsterNamespace,spellName,amount,targets,range,propability,cooldown)

	local spellHook = function(monster,dir)
			if data.get(monster,'spell_cooldown') then
				return false
			end
			local v = fw.getHookVars()
			if math.random() > v.prop then return end
			if (help.nextEntityAheadOf(monster, v.range,v.targets,true)) then				
				local count = data.get(monster,v.spellName..'_count') or v.amount
				if count < 1 then
					return
				end
				fw.executeHooks(v.spellName,'onCast',monster)
				data.set(monster,v.spellName..'_count',count - 1)
				data.set(monster,'spell_cooldown',true)
				fw.repeatFunction(1,v.cooldown,{monster.id},function(monster_id)
						local monster = fw.getById(monster_id)
						if monster then
							data.unset(monster,'spell_cooldown')
						end
					end
				)
				return false
			end
		end
		
	local vars = {}
	vars.spellName=spellName
	vars.amount=amount
	vars.targets=targets		
	vars.range = range or 5
	vars.prop = propability or 0.5
	vars.cooldown = cooldown or 2
	
	fw.setHookVars(monsterNamespace,'fw_magic_monsters_'..spellName,'onMove',vars)
	fw.setHookVars(monsterNamespace,'fw_magic_monsters_'..spellName,'onTurn',vars)	
	
	fw.addHooks(monsterNamespace,'fw_magic_monsters_'..spellName,{
		onMove = spellHook,
		onTurn = spellHook
	})
end
]])

fw_defineObject{
	name = "spell_projectile",
	class = "Item",
	uiName = "Spell projectile",
	model = "mod_assets/framework/models/null.fbx",
	gfxIndex = 109,
	attackPower = 1,
	impactSound = "",
	attackSound = "",
	stackable = false,
	sharpProjectile = false,
	castShadow = false,
	projectileRotationY = 0,
	weight = 0,	
}

defineMaterial{
	name = "mtl_null",
	diffuseMap = "mod_assets/framework/textures/null.tga",
	specularMap = "mod_assets/framework/textures/null.tga",
	normalMap = "mod_assets/framework/textures/null.tga",
	doubleSided = false,
	lighting = false,
	alphaTest = true,
	blendMode = "Opaque",
	textureAddressMode = "Wrap",
	glossiness = 40,
	depthBias = 0,
}

defineObject{
		name = "spell_selector",
		class = "Item",
		uiName = "Select target by touching (left click) desired champions hand",
		model = "assets/models/items/apprentice_orb.fbx",
		description = "Left click champions hand",
		gfxIndex = 69,
		impactSound = "impact_blunt",
		weight = 0,
}	



function createSpell(spellDef,createScroll)
	
	if spellDef.onCast == nil then
		spellDef.onCast = function(champ, x, y, direction, skill) return fw.executeHooks(spellDef.name,"onCast",champ, x, y, direction, skill) end
	end
	defineSpell{
	   name = spellDef.name,
	   uiName = spellDef.uiName,
	   skill =  spellDef.skill,
	   level = spellDef.level,
	   runes = spellDef.runes,
	   manaCost = spellDef.manaCost,
	   onCast = spellDef.onCast	
	}
	if spellDef.runes == nil then
		return
	end
	
	fw_defineObject{
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
			if fw.executeHooks('items_spell_book','onLearnSpell',self,p1,p2,p3) == false then 
				return false 
			end
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
			return false
		end
	}
	
	-- automatically create a scroll for every spell
	fw_defineObject{
		name = "scroll_"..spellDef.name,
		class = "Item",
		uiName = "Scroll of "..spellDef.uiName,
		model = "assets/models/items/scroll_spell.fbx",
		gfxIndex = 113,
		scroll = true,
		weight = 0.3,
		onUseItem = function(scroll,champ)
			return fw.executeHooks('scrolls',"onReadScroll",scroll,champ)
		end,
	}
end

function createSpellBook()
	fw_defineObject{
		name = "spell_book_mage",
		class = "Item",
		uiName = "Spell book",
		model = "assets/models/items/tome.fbx",
		gfxIndex = 30,
		weight = 1,
		scroll = true,
		container = true,
		containerType = "chest",
		capacity = 10,
	}
	local magics = {'Fire','Air','Ice','Earth','Spellcraft'}
	for i=1,#magics do
		fw_defineObject{
			name = "spell_book_level_"..i,
			class = "Item",
			uiName = magics[i],
			model = "assets/models/items/tome.fbx",
			gfxIndex = 30,
			weight = 0,
			scroll = true,
			container = true,	
			containerType = "chest",
			capacity = 10,	
		}	
	end	
end

createSpellBook()
