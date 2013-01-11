--[[
Status: WIP but works
TODO: Balance and more spells

Adds AD&D spells and a spellbook, which is automatically spawned to every mages inventory. Spellbooks can't be removed.
See defineSpells-function for included spells

]]
fw_loadModule('fw_magic')
fw_addModule('add_spells',[[
settings = {}

function activate()
	fw_magic.enableSpellBook()
	defineSpells()
	
	for i,champ in ipairs(help.getChampions()) do
		if champ:getClass() == 'Mage' then
			initChampion(champ)
		end
	end

	fw.setHook('items_spell_book.fw_magic.onLearnSpell',add_spells.onLearnSpell)
end



function defineSpells()

	fw_magic.defineSpell{
		name='magic_missile',
		uiname='Magic missile',
		runes='A',
		level=1,
		book_page=1,
		skill='spellcraft',
		projectile='spell_projectile',
		sound='fireball_launch',
		onHitSound='fireball_hit',
		particleEffect='magic_missile',
		onHitParticleEffect='magic_missile_hit',
		speed=12,
		damageType = 'physical',
		calculateDamage=function(caster)
			local modifier = math.ceil(caster:getLevel()/2)
			return math.random(modifier*2,5 * modifier)
		end
	}
	
	fw_magic.defineSpell{
		name='fireball',
		level=3,
		book_page=3,
		projectile='spell_projectile',
		sound='fireball_launch',
		onHitSound='fireball_hit',
		particleEffect='fireball',
		onHitParticleEffect='fireball_hit',
		speed=14,
		damageType = 'fire',
		calculateDamage=function(caster)
			local damage = 6
			damage = math.random(caster:getLevel()*2,damage * caster:getLevel())
			return damage
		end
	}	
	
	fw_magic.defineSpell{
		name='flame_arrow',
		level=3,
		book_page=3,
		projectile='arrow',
		sound='frostbolt_launch',
		onHitSound='fireball_hit',
		particleEffect='fireball',
		onHitParticleEffect='fireball_hit',
		speed=14,
		damageType = 'fire',
		calculateDamage=function(caster)
			local modifier = 1			
			local damage = 3	
			if caster:getLevel() > 9 then modifier = 2 end
			damage = math.random(damage * modifier,damage * 10 * modifier)
			return damage
		end
	}		
	
	
	fw_magic.defineSpell{
		name='melfs_acid_arrow',
		level=3,
		book_page=3,
		projectile='spell_projectile',
		sound='poison_bolt_launch',
		onHitSound='poison_bolt_hit',
		particleEffect='poison_bolt',
		onHitParticleEffect='hit_slime',
		speed=14,
		onHit = add_spells.melfs_acid_arrow_onHit
	}	
	
	fw_magic.defineSpell{
		name='lightning_bolt',
		level=3,
		book_page=3,
		projectile='spell_projectile',
		sound='lightning_bolt_launch',
		onHitSound='lightning_bolt_hit',
		particleEffect='lightning_bolt',
		onHitParticleEffect='lightning_bolt_hit',
		speed=14,
		area = {from={0,0},to={1,0}},
		damageType = 'shock',
		calculateDamage=function(caster)
			local damage = 6
			damage = math.random(caster:getLevel(),caster:getLevel()*damage)	
			return damage
		end		
	}		
	
	fw_magic.defineSpell{
		name='cone_of_cold',
		level=5,
		book_page=3,
		sound='frostbolt_launch',
		onHitSound='frostbolt_hit',
		particleEffect='frostbolt',
		onHitParticleEffect='frostbolt_hit',
		speed=14,
		area = {from={0,0},to={2,0}},
		damageType = 'cold',
		calculateDamage=function(caster)
			local damage = 5
			damage = math.random(caster:getLevel()*2,caster:getLevel()*damage)	
			return damage
		end,		
		onCast = function(caster)
			local entity = caster
			if caster.getOrdinal then
				entity = party
			end
			local x,y = help.getCoordsOfTileAtDir(entity,entity.facing,1)
			fw_magic.dealSpellDamage('cone_of_cold',caster,x,y)
		end
	}			
	
	fw_magic.defineSpell{
		name='ice_storm',
		level=4,
		book_page=4,
		sound='frostbolt_launch',
		onHitSound='frostbolt_hit',
		particleEffect='ice_shards',
		onHitParticleEffect='ice_shards',
		speed=14,
		area = {from={-1,-1},to={1,1}},
		damageType = 'cold',
		calculateDamage=function(caster)
			return math.random(3,30)
		end,		
		onCast = function(caster)

			local entity = caster
			range = caster:getLevel()
			
			if caster.getOrdinal then
				entity = party				
			end
			if range < 4 then range = 4 end
			
			local target = help.nextEntityAheadOf(entity, range,'monster',true)	
			local x,y = 0,0	
			if target then
				x = target.x
				y = target.y
			else
				x,y = help.getCoordsOfTileAtDir(entity,entity.facing,range)
			end
			-- cross shaped damage area hack --
			fw_magic.spells['ice_storm'].area = {from={-1,0},to={1,0}}
			fw_magic.dealSpellDamage('ice_storm',caster,x,y)
			fw_magic.spells['ice_storm'].area = {from={0,1},to={0,1}}
			fw_magic.dealSpellDamage('ice_storm',caster,x,y)
			fw_magic.spells['ice_storm'].area = {from={0,-1},to={0,-1}}
			fw_magic.dealSpellDamage('ice_storm',caster,x,y)
		end
	}	
		
	fw_magic.defineSpell{
		name='shield',
		level=1,
		book_page=1,
		onCast = add_spells.shield
	}		
	
	fw_magic.defineSpell{
		name='armor',
		level=1,
		book_page=1,
		onCast = add_spells.armor
	}	
		
	fw_magic.defineSpell{
		name='haste',
		level=3,
		book_page=3,
		onCast = add_spells.haste
	}	

	fw_magic.defineSpell{
		name='invisibility',
		level=2,
		book_page=2,
		onCast = add_spells.invisibility
	}		
	fw_magic.defineSpell{
		name='invisibility_10_radius',
		level=3,
		book_page=3,
		onCast = add_spells.invisibility_10_radius
	}	

	fw_magic.defineSpell{
		name='hold_monster',
		level=5,
		book_page=5,
		onCast = add_spells.hold_monster
	}				

	
	fw_magic.defineSpell{
		name='burning_hands',
		level=1,
		book_page=1,
		onCast = function(caster, x, y, direction, skill)
			local dx,dy = getForward(direction)
			playSoundAt("fireburst",party.level,x,y)
			local originator = 2 ^ (caster:getOrdinal()+1) 
			local skill = caster:getLevel()
			damageTile(party.level, x+dx, y+dy, direction, originator, 'fire', 3+skill*2)
		end
	}	

	fw_magic.defineSpell{
		name='stoneskin',
		level=4,
		book_page=4,
		onCast = add_spells.stoneskin
	}						

end

-- SPELLS ++

melfs_acid_arrow_onHit = function(projectile,target,damage,damageType)
			if target.getOrdinal then
				target = party
			end
			local caster = fw.getById(data.get(projectile,'caster_id')) 
		
			local callback = function(caster_id,target_id)
					local target = fw.getById(target_id) 
					local caster = fw.getById(caster_id) 
					local originator = 0 
					local modifier = math.ceil(caster:getLevel()/2)
					local damage = math.random(2,6)	
					
					if caster.getOrdinal then
						originator = 2 ^ (caster:getOrdinal()+1) 
					end
							
					damageTile(target.level,target.x,target.y,(target.facing + 2)%4,originator+1, 'physical',damage)
					local fx = spawn('fx',target.level,target.x,target.y,target.facing)
					fx:setParticleSystem('hit_slime')
					fx:translate(0,1,0)		
			end
			local attacks = math.ceil(caster:getLevel()/3)	
			fw.repeatFunction(attacks,1,{fw.getId(caster),fw.getId(target)},callback,true)			
			return false
end

-- SHIELD --

settings.shield = {}
settings.shield.level = 1
settings.shield.duration = 5 --seconds + (skill/2)
settings.shield.missiles = 6 -- how many damagepoints are subtracted (max value)
settings.shield.throwing = 8 -- how many damagepoints are subtracted (max value)

function shield(caster, x, y, direction, skill)
	skill = 1
	if (caster.getLevel) then
	 	skill = caster:getLevel() 
	end
	
	local timerId = fw_magic.createSpellTimer(caster,settings.shield.duration+skill/2,{'add_spells','shieldDestructor'})
	playSoundAt("fireball_launch",party.level,x,y)
	
	fw.addHooks(fw.getId(caster),timerId,{
		onProjectileHit = function(champion,projectile,damage,damageType)
			if projectile.name == 'magic_missile'  then
				hudPrint('Magic missile deflected')
				return false
			end
			if help.isEntityType(projectile,'item_missileweapon') then
				champion:damage(damage - math.random(add_spells.settings.shield.missiles), damageType)
				hudPrint('Shield spell deflected some damage')
				champion:playDamageSound()
				return false
			end
			if help.isEntityType(projectile,'item_throwingweapon') then
				champion:damage(damage - math.random(add_spells.settings.shield.throwing), damageType)
				hudPrint('Shield spell deflected some damage')
				champion:playDamageSound()
				return false
			end			
		
		end
	}
	)
end

function shieldDestructor(timer)
	fw_magic.spellTimerDestructor(timer)
	hudPrint('The effect of the shield spell has worn out.')
end

-- STONESKIN--


function stoneskin(caster, x, y, direction, skill)
	local selector = fw_magic.createTargetSelector()
	selector.skill = caster:getLevel()
	selector.onSelectChampion = add_spells.castStoneskin
end

function castStoneskin(target,skill)	
	
	skill = math.random(1,4) + math.floor(skill/2)
	playSoundAt("generic_spell",party.level,party.x,party.y)

	data.set(target,'add_spells_stoneskin_count',skill)
	target:setCondition('fire_shield',10000)
	fw.addHooks(fw.getId(target),'add_spells_stoneskin',{
		onProjectileHit = function(champion,projectile,damage,damageType)
			return add_spells.stoneskinCheck(champion,damageType,projectile)
		end,
		onDamage = function(champion,damage,damageType)
			return add_spells.stoneskinCheck(champion,damageType)
		end		
	}
	)
end

function stoneskinCheck(champion,damageType,projectile)
	if projectile and projectile.name == 'spell_projectile' then
		return
	end	

	if damageType == 'physical' then 
		local count = data.get(champion,'add_spells_stoneskin_count')
		count = count - 1
		data.set(champion,'add_spells_stoneskin_count',count)
		hudPrint('('..champion:getName()..') Stoneskin spell prevented the attack.')
		
		if count < 1 then
			fw.removeHooks(fw.getId(champion),'add_spells_stoneskin')
			champion:setCondition('fire_shield',0)
			hudPrint('('..champion:getName()..') Stoneskin spell has worn out.')
			data.unset(champion,'add_spells_stoneskin_count')
		end	
		
		return false 
	end
end

-- HOLD MONSTER --

settings.hold_monster = {}
settings.hold_monster.level = 5
settings.hold_monster.duration = 9 --seconds + (skill/2)	
settings.hold_monster.immune= {
	skeleton_archer=true,
	skeleton_warrior=true
}


function hold_monster(caster, x, y, direction, skill)

	skill = caster:getLevel()
	if caster.getOrdinal then
		caster = party
	end	
	
	local target = help.nextEntityAheadOf(caster,3,{'monster','party'})
	
	if not target then return false end
	if add_spells.settings.hold_monster.immune[target.name] then return false end
	
	playSoundAt("frostbolt_launch",caster.level,caster.x,caster.y)

	
	--dynamically add hooks which prevents monster to attack or move	
	-- use timerId as hook-id so the hook can be removed on destructor
	local hold_monsterHook = function() return false end
	
	local timerId = fw_magic.createSpellTimer(target,add_spells.settings.hold_monster.duration+skill)
	
	local fx = spawn('fx',target.level,target.x,target.y,target.facing)
	fx:setParticleSystem('hold_monster')
	fx:translate(0,1,0)			
	
	fw.addHooks(target.id,timerId,{
		onMove = hold_monsterHook,
		onAttack = hold_monsterHook,
		onRangedAttack = hold_monsterHook,
		onTurn = hold_monsterHook
	},
	1)
	return true
end


-- HASTE --


settings.haste = {}
settings.haste.level = 3
settings.haste.duration = 10
 
settings.haste.count = 0
function haste(caster, x, y, direction, skill)
	local selector = fw_magic.createTargetSelector()
	selector.skill = caster:getLevel()
	selector.caster_id = fw.getId(caster)
	if settings.haste.count == 0 then
		settings.haste.count = caster:getLevel()
		if settings.haste.count > 4 then
			settings.haste.count = 4
		end
	end
	selector.onSelectChampion = add_spells.castHaste
	selector.afterCast = add_spells.hasteAfterCast
end

function castHaste(target,skill,caster_id)
	target:setCondition('haste',settings.haste.duration + skill)
	playSoundAt('generic_spell',party.level,party.x,party.y)

end

function hasteAfterCast(caster_id)
	settings.haste.count = settings.haste.count - 1
	
	if settings.haste.count > 0 then
		add_spells.haste(fw.getById(caster_id))
	end
end


-- ARMOR --

settings.armor = {}
-- threshold + skill (how much damage champion can get before spell is deactivated)
settings.armor.threshold = 8 
settings.armor.protection = 6 -- sets protection stat to this level


function armor(caster, x, y, direction, skill)
	local selector = fw_magic.createTargetSelector()
	selector.skill = caster:getLevel()
	selector.onSelectChampion = add_spells.castArmor
end


function castArmor(champion,skill)
	if champion:getStat('protection') >= add_spells.settings.armor.protection then
		hudPrint('Armor spell has no effect on '..champion:getName())
		return false
	end
	
	skill = champion:getLevel() 

	playSoundAt("generic_spell",party.level,party.x,party.y)
	data.set(champion,'spell_armor_orig_protection',champion:getStat('protection'))
	data.set(champion,'spell_armor_max_protection',champion:getStatMax('protection'))	
	champion:setStatMax('protection',add_spells.settings.armor.protection)
	champion:setStat('protection',add_spells.settings.armor.protection)

	data.set(champion,'spell_armor_damage_threshold',add_spells.settings.armor.threshold + skill)
	
	fw.addHooks(fw.getId(champion),'spell_armor',{
	
		onDamage = function(champion,damage)
			local damageThreshold = data.get(champion,'spell_armor_damage_threshold') - damage
			if damageThreshold < 1 then
				fw.removeHooks(fw.getId(champion),'spell_armor')
				champion:setStat('protection',data.get(champion,'spell_armor_orig_protection'))
				champion:setStatMax('protection',data.get(champion,'spell_armor_max_protection'))
				hudPrint('Effect of armor spell worn out.')				
			else
				data.set(champion,'spell_armor_damage_threshold',damageThreshold)
			end
		end
	
	})	
	
end

-- INVISIBILITY --

settings.invisibility = {}
settings.invisibility.level = 2


function invisibility(caster, x, y, direction, skill)
	local selector = fw_magic.createTargetSelector()
	selector.skill = skill
	selector.onSelectChampion = add_spells.castInvisibility	
end

function castInvisibility(champion,skill)
	champion:setCondition('invisibility',10000)
	playSoundAt('generic_spell',party.level,party.x,party.y)
	fw.addHooks(fw.getId(champion),'spell_inivisibility',{
		onDamage = function(self)
			self:setCondition('invisibility',0)
			fw.removeHooks(fw.getId(self),'spell_inivisibility')
		end 
	})
end

-- INVISIBILITY 10' RADIUS --

settings.invisibility_10_radius = {}
settings.invisibility_10_radius.level = 3

function invisibility_10_radius(caster, x, y, direction, skill)
	for i,champ in ipairs(help.getChampions()) do
		castInvisibility(champ)
	end
end

-- SPELLS --

function initChampion(champ)
	
	data.set(champ,'spellPoints',{0,0,0,0,0})
	updateSpellPoints(champ)
	updateSpellBookDescription(champ)
	
	fw.addHooks(fw.getId(champ),'add_spells_level_up',{
			onLevelUp = function(champ)
				add_spells.updateSpellPoints(champ)
			end
		}	
	)
end

function updateSpellPoints(champ)
	if champ:getLevel() > 14 then
		return
	end
	local progressionTable = {
	{1},
	{1},
	{0, 1},
	{1, 1},
	{1, 0, 1},
	{0, 0, 1},
	{0, 1, 0, 1},
	{0, 0, 1, 1},
	{0, 0, 0, 0, 1},
	{0, 1, 0, 0, 1},
	{0, 0, 1, 1, 1},
	{0, 0, 0, 1, 1},
	{1, 1, 1, 0, 0},
	{0, 0, 0, 1, 1},
}
	local spellPoints = data.get(champ,'spellPoints')
	
	for spellLevel,points in ipairs(progressionTable[champ:getLevel()]) do
		spellPoints[spellLevel] = points + (spellPoints[spellLevel] or 0)
	end
	
	data.set(champ,'spellPoints',spellPoints)
	updateSpellBookDescription(champ)
end

function updateSpellBookDescription(champ)
	local sp = data.get(champ,'spellPoints')
	local book = champ:getItem(11)
	local description = 'Available spell points\n'
	for level,points in ipairs(sp) do
		description = description.."\nLevel "..level..":  "..points
	end
	description = description.."\nYou can learn spells by right clicking the\ndesired spell scroll from this book."
	book:setScrollText(description)
end

function onLearnSpell(scroll,champion)
	local spellName = string.sub(scroll.name,12)
	local sp = data.get(champion,'spellPoints')
	local sl = fw_magic.spells[spellName].level
	if (sp[sl] < 1) then
		hudPrint('Not enough spell points.')
		return false
	end
	sp[sl] = sp[sl] - 1
	data.set(champion,'spellPoints',sp)
	-- overwrite the onLearnSpell-hook
	fw_magic.learnSpell(spellName,champion,scroll)
	add_spells.updateSpellBookDescription(champion)
	return true
end
]])

createSpell{
	   name = "magic_missile",
	   uiName = "Magic missile",
	   skill = "fire_magic",
	   level = 0,
	   runes = "A",
	   manaCost = 15,
	   description = [[Range:Long
Duration:Instantaneous
Area of Effect:One target 

The mage creates a bolt of magic force that unerringly strikes one target. Magic Missiles do greater damage as a mage increases in level. Initially, Magic Missile does two to five points of damage, and for every two extra levels the spell does two to five more points. So a first or second-level mage does two to fivepoints of damage, but a third or fourth-level mage does four to ten, and so on.]]
	}

createSpell{
	   name = "burning_hands",
	   uiName = "Burning hands",
	   skill = "fire_magic",
	   level = 0,
	   runes = "B",
	   manaCost = 10,
	   description = [[Range:Close
Duration:Instantaneous
Area of Effect:One target

When a mage casts this spell, a jet of searing flame shoots from hisfingertips. The damage inflicted bu the flame increases as the mage increases in level and gains power. The spell does one to three points of damage plus two points per level of the caster. For example, a 10th level mage would do 21-23 points of damage.]]
	}

createSpell{
	   name = "shield",
	   uiName = "Shield",
	   skill = "fire_magic",
	   level = 0,
	   runes = "D",
	   manaCost = 10,
	   description = [[Range:0
Duration:Short to medium
Area of Effect:Spell-caster

This spell produves an invisible barrier in front of the mage that totally blocks Magic Missile attacks. It also offers AC2 against hurled weapons (darts, spears) and AC 3 against propelled missiles (arrows, sling-stones). The spell does not have a cumulative effect with the Armor spell. THe spell duration increases with the level of the caster. ]]
	}
createSpell{
	   name = "hold_monster",
	   uiName = "Hold monster",
	   skill = "spellcraft",
	   level = 0,
	   runes = "E",
	   manaCost = 50,
	   description = [[Range:Long
Duration:Medium
Area of Effect:One square

This spell is similar to the Hold Person spell except that if affects a wider range of creatures. The spell does not affect undead creatures. The spell's duration increases with the level of the caster. ]]
	}	
createSpell{
	   name = "armor",
	   uiName = "Armor",
	   skill = "spellcraft",
	   level = 0,
	   runes = "F",
	   manaCost = 15,
	   description = [[Range:0
Duration:Special
Area of Effect:Once Character

With this spell the mage can surround a character with a magical field that protects as chain mail (AC 6). The spell has no effect on characters who already have AC 6 or greater and it does not have a cumulative effect with the Shield spell. The spell lasts until the character suffers 8 points + 1 per level of the caster of damage or a Dispel Magic is cast. ]]
	}		
	
createSpell{
	   name = "invisibility",
	   uiName = "Invisibility",
	   skill = "spellcraft",
	   level = 0,
	   runes = "H",
	   manaCost = 20,
	   description = [[Range:0
Duration:Special
Area of Effect:One target

This spell causes the target to vanish from sight. The invisible character remains unseen until he attacks a monster or is hit. Certain powerful monsters can sense invisible characters, or even see them outright. ]]
	}		
createSpell{
	name = "invisibility_10_radius",
	uiName = "Invisibility 10' radius",
	skill = "air_magic",
	level = 0,
	runes = "I",
	manaCost = 35,
	description = [[Range:0
Duration:Special
Area of Effect:Entire party

This spell is similar to the second-level invisibility spell, except that the entire party is affected. If an individual character is hit while under the spell's effect, that character becomes visible. If any character in the party attacks, the spell is broken for all. ]]
}	
createSpell{
	name = "melfs_acid_arrow",
	uiName = "Melf's Acid Arrow",
	skill = "air_magic",
	level = 0,
	runes = "AB",
	manaCost = 20,
	description = [[Range:Long
Duration:Special
Area of Effect:One target

This spell creates a magical arrow that launches itself at a target as though it were fired by a fighter of the same level as the mage. The arrow is not affect by distance. The arrow does two to eight points of damage per attack. For every three levels the mage has earned, the arrow gains an additional attack. For example, at 3rd to 5th level the arrow attacks twice, and at 6th to 8th level the arrow attacks 3 times. ]],
}	

createSpell{
	name = "flame_arrow",
	uiName = "Flame Arrow",
	skill = "air_magic",
	level = 0,
	runes = "AC",
	manaCost = 20,
	description = [[Range:Long
Duration:Special
Area of Effect:One target

The caster of this spell can fire a flaming energy 'arrow' that does 3 to 30 hit points of damage. When the mage reaches 10th level the amount of damage is doubled to 6 to 60 points. ]],
}	

createSpell{
	name = "fireball",
	uiName = "Fireball",
	skill = "air_magic",
	level = 0,
	runes = "AD",
	manaCost = 35,
	description = [[Range:Long
Duration:Instantaneous
Area of Effect:Target square

A fireball is an explosive blast of flame that damages everything in the target square. The explosion does one to six points of damage for every level of the caster to a maximum of 10th level. For example a 10th level mage does 10-60 points of damage.
 ]],
}	


createSpell{
	name = "lightning_bolt",
	uiName = "Lightning bolt",
	skill = "air_magic",
	level = 0,
	runes = "AE",
	manaCost = 35,
	description = [[Range:Long
Duration:Instantaneous
Area of Effect:2 square

This spell alows the mage to cast a powerful bolt of electrical energy. The spell flies to its first target and then continues into the next square. The bolt does one to six points of damge for every level of the caster to a maximum of 10th level. For example, a 10th level mage does 10-60 points of damage.
 ]],
}	

createSpell{
	name = "haste",
	uiName = "Haste",
	skill = "air_magic",
	level = 0,
	runes = "AF",
	manaCost = 35,
	description = [[Range:0
Duration: Medium
Area of Effect: One target per caster level 

This spell causes all targets to move and fight at double their normal rate. The spell's duration increases with the level of the caster.]],
}	
createSpell{
	name = "cone_of_cold",
	uiName = "cone of cold",
	skill = "air_magic",
	level = 0,
	runes = "AH",
	manaCost = 40,
	description = [[Range:0
Duration:Instantaneous
Area of Effect:3 squares

This spell causes the mage to project a chilling cone of sub-zero cold. The numbing cone causes two to five points of damage per level of the caster. For example, a 10th level mage would be 20-50 points of damage.]],
}	

createSpell{
	name = "ice_storm",
	uiName = "Ice Storm",
	skill = "air_magic",
	level = 0,
	runes = "AI",
	manaCost =  50,
	description = [[Range:Medium to long
Duration:Instantaneous
Area of Effect:A cross-shaped area of 3x3 squares
  
The magically created storn this spell produces is a pounding torrent of huge hailstones. The spell pummels the targets with 3-30 points of damage. The range of this spell is based on the caster's level.]],
}	

createSpell{
	name = "stoneskin",
	uiName = "Stoneskin",
	skill = "air_magic",
	level = 0,
	runes = "BC",
	manaCost = 60,
	description = [[Range:0
Duration:Special
Area of Effect:1 character

This spell grants the recipient virtual immunity to any attack by cut, blow, projectile, or the like. Stoneskin protects the user from almost any non-magical attack and also gives +35 resistance to fire. The spell lasts for one to four attacks plus one for every two levels of the caster. For example, a 9th level mage casting Stoneskin would protect against 5 to 8 attacks.]],
}	

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

for i=1,10 do
	fw_defineObject{
		name = "spell_book_level_"..i,
		class = "Item",
		uiName = "Level "..i.." spells",
		model = "assets/models/items/tome.fbx",
		gfxIndex = 30,
		weight = 0,
		scroll = true,
		container = true,	
		containerType = "chest",
		capacity = 10,	
	}	
end	



defineParticleSystem{
	name = "magic_missile",
	emitters = {
		-- flames
		{
			emissionRate = 50,
			emissionTime = 0,
			maxParticles = 50,
			boxMin = {-0.0, -0.0, 0.0},
			boxMax = { 0.0, 0.0,  -0.0},
			sprayAngle = {0,360},
			velocity = {0.3, 0.3},
			texture = "assets/textures/particles/torch_flame.tga",
			frameRate = 35,
			frameSize = 64,
			frameCount = 16,
			lifetime = {0.8, 0.8},
			colorAnimation = true,
			color0 = {1, 1, 1},
			opacity = 1,
			fadeIn = 0.15,
			fadeOut = 0.3,
			size = {0.125, 0.25},
			gravity = {0,0,0},
			airResistance = 1,
			rotationSpeed = 1,
			blendMode = "Additive",
			objectSpace = true,
		},

		-- glow
		{
			spawnBurst = true,
			emissionRate = 1,
			emissionTime = 0,
			maxParticles = 1,
			boxMin = {-0.0, -0.0, 0.0},
			boxMax = { 0.0, 0.0,  -0.0},
			sprayAngle = {0,30},
			velocity = {0,0},
			texture = "assets/textures/particles/glow.tga",
			lifetime = {1000000, 1000000},
			colorAnimation = false,
			color0 = {1, 1, 1},
			opacity = 1,
			fadeIn = 0.1,
			fadeOut = 0.1,
			size = {0.8, 0.8},
			gravity = {0,0,0},
			airResistance = 1,
			rotationSpeed = 2,
			blendMode = "Additive",
			objectSpace = true,
		}
	}
}
defineParticleSystem{
	name = "magic_missile_hit",
	emitters = {
		-- fog
		{
			spawnBurst = true,
			maxParticles = 30,
			sprayAngle = {0,360},
			velocity = {0,3},
			objectSpace = true,
			texture = "assets/textures/particles/fog.tga",
			lifetime = {0.4,0.6},
			color0 = {1, 1, 1},
			opacity = 0.7,
			fadeIn = 0.1,
			fadeOut = 0.3,
			size = {1, 2},
			gravity = {0,0,0},
			airResistance = 0.5,
			rotationSpeed = 1,
			blendMode = "Additive",
		},

		-- glow
		{
			spawnBurst = true,
			emissionRate = 1,
			emissionTime = 0,
			maxParticles = 1,
			boxMin = {0,0,-0.1},
			boxMax = {0,0,-0.1},
			sprayAngle = {0,30},
			velocity = {0,0},
			texture = "assets/textures/particles/glow.tga",
			lifetime = {0.5, 0.5},
			colorAnimation = false,
			color0 = {1, 1, 1},
			opacity = 1,
			fadeIn = 0.01,
			fadeOut = 0.5,
			size = {1, 1},
			gravity = {0,0,0},
			airResistance = 1,
			rotationSpeed = 2,
			blendMode = "Additive",
		}
	}
}

defineParticleSystem{
	name = "hold_monster",
	emitters = {
		-- stars
		{
			emissionRate = 200,
			emissionTime = 0,
			maxParticles = 1000,
			boxMin = {-1.5,-0.5,-1.5},
			boxMax = { 1.5, 2.5, 1.5},
			sprayAngle = {0,30},
			velocity = {0.5,1.5},
			objectSpace = true,
			texture = "assets/textures/particles/teleporter.tga",
			lifetime = {1,1},
			color0 = {1.8,1.8,1.8},
			opacity = 1,
			fadeIn = 0.1,
			fadeOut = 0.1,
			size = {0.1, 0.3},
			gravity = {0,-1,0},
			airResistance = 0.1,
			rotationSpeed = 2,
			blendMode = "Additive",
		},

		-- small stars
		{
			emissionRate = 300,
			emissionTime = 0,
			maxParticles = 1000,
			boxMin = {-1.5,-0.5,-1.5},
			boxMax = { 1.5, 2.5, 1.5},
			sprayAngle = {0,30},
			velocity = {0.5,1.0},
			objectSpace = true,
			texture = "assets/textures/particles/teleporter.tga",
			lifetime = {1,1},
			color0 = {1.6,1.8,1.8},
			opacity = 1,
			fadeIn = 0.1,
			fadeOut = 0.1,
			size = {0.05, 0.1},
			gravity = {0,-0.5,0},
			airResistance = 0.1,
			rotationSpeed = 2,
			blendMode = "Additive",
		}
	}
}


