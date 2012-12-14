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

The mage creates a bolt of magic force that unerringly strikes one target. Magic Missiles do greater damage as amage increases in level. Initially, Magic Missile does two to five points of damage, and for every two extra levels the spell does two to five more points. So a first or second-level mage does two to fivepoints of damage, but a third or fourth-level mage does four to ten, and so on.]]
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

	defineObject{
		name = "spell_book_mage",
		class = "Item",
		uiName = "Spell book",
		model = "assets/models/items/tome.fbx",
		gfxIndex = 30,
		weight = 1,
		scroll = true,
		container = true,
		containerType = "chest",
		capacity = 6,
	}
	
	for i=1,5 do
		cloneObject{
			name = "spell_book_level_"..i,
			baseObject = "sack",
			uiName = "Level "..i.." spells",
			model = "assets/models/items/tome.fbx",
			gfxIndex = 30,
			weight = 0,
		}	
	end	

defineMaterial{
	name = "magic_missile",
	diffuseMap = "assets/textures/common/white.tga",
	specularMap = "assets/textures/common/white.tga",
	doubleSided = false,
	lighting = true,
	alphaTest = false,
	blendMode = "Opaque",
	textureAddressMode = "Wrap",
	glossiness = 20,
	depthBias = 0,
}
defineObject{
	name = "acid_arrow",
	class = "Item",
	uiName = "Melf's Acid Arrow",
	model = "assets/models/items/arrow.fbx",
	gfxIndex = 109,
	weight = 0.0,
	projectileRotationY = 90,
	particleEffect = "poison_bolt",
	hitParticleEffect = "poison_bolt_hit",
	lightColor = vec(0.25, 0.6, 0.2),
	lightBrightness = 4,
	lightRange = 4,
	lightHitBrightness = 4,
	lightHitRange = 5,
	launchSound = "poison_bolt_launch",
	projectileSound = "poison_bolt",
	impactSound = "poison_bolt_hit",
	projectileSpeed = 7.5,
	attackPower = 20,
	damageType = "poison",
	--cameraShake = true,
	tags = { "spell" },
}

defineObject{
		name = "magic_missile",
		class = "Item",
		uiName = "Magic missile",
		model = "assets/models/items/arrow.fbx",
		--ammoType = "arrow",
		gfxIndex = 109,
		attackPower = 1,
		impactSound = "fireball_hit",
		particleEffect = "magic_missile",
		stackable = false,
		sharpProjectile = false,
		projectileRotationY = 90,
		weight = 0.1,
}
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
			boxMin = {0,0,-0.1},
			boxMax = {0,0,-0.1},
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
