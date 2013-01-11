fw_loadModule('fw_magic')
fw_addModule('default_spells',[[
function activate()
fw_magic.defineSpell{
	name = "light",
	uiName = "Light",
	book_page = 5,
	skill = "spellcraft",
	level = 5,
	runes = "BE",
	manaCost = 25,
}

fw_magic.defineSpell{
	name = "darkness",
	uiName = "Darkness",
	book_page = 5,
	skill = "spellcraft",
	level = 5,
	runes = "EH",
	manaCost = 25,
}

-- fire magic
fw_magic.defineSpell{ 
	name = "fireburst",
	uiName = "Fireburst",
	book_page = 1,
	skill = "fire_magic",
	level = 2,
	runes = "A",
	manaCost = 15,
}

fw_magic.defineSpell{
	name = "fireball",
	uiName = "Fireball",
	book_page = 1,
	skill = "fire_magic",
	level = 13,
	runes = "ACF",
	manaCost = 33,
}

fw_magic.defineSpell{
	name = "fire_shield",
	uiName = "Fire Shield",
	book_page = 1,
	skill = "fire_magic",
	level = 16,
	runes = "AE",
	manaCost = 50,
}

fw_magic.defineSpell{
	name = "enchant_fire_arrow",
	uiName = "Enchant Fire Arrow",
	book_page = 1,
	skill = "fire_magic",
	level = 7,
	runes = "ABFH",
	manaCost = 20,
}

-- ice magic
fw_magic.defineSpell{
	name = "ice_shards",
	uiName = "Ice Shards",
	book_page = 3,
	skill = "ice_magic",
	level = 3,
	runes = "GI",
	manaCost = 24,
}

fw_magic.defineSpell{
	name = "frostbolt",
	uiName = "Frostbolt",
	book_page = 3,
	skill = "ice_magic",
	level = 13,
	runes = "CI",
	manaCost = 29,
}

fw_magic.defineSpell{
	name = "frost_shield",
	uiName = "Frost Shield",
	book_page = 3,
	skill = "ice_magic",
	level = 19,
	runes = "EI",
	manaCost = 45,
}

fw_magic.defineSpell{
	name = "enchant_frost_arrow",
	uiName = "Enchant Frost Arrow",
	book_page = 3,
	skill = "ice_magic",
	level = 7,
	runes = "BFHI",
	manaCost = 20,
}

-- air magic		
fw_magic.defineSpell{
	name = "shock",
	uiName = "Shock",
	book_page = 2,
	skill = "air_magic",
	level = 4,
	runes = "C",
	manaCost = 21,
}

fw_magic.defineSpell{
	name = "invisibility",
	uiName = "Invisibility",
	book_page = 2,
	skill = "air_magic",
	level = 19,
	runes = "CEH",
	manaCost = 35,
}

fw_magic.defineSpell{
	name = "lightning_bolt",
	uiName = "Lightning Bolt",
	book_page = 2,
	skill = "air_magic",
	level = 14,
	runes = "CD",
	manaCost = 40,
}

fw_magic.defineSpell{
	name = "shock_shield",
	uiName = "Shock Shield",
	book_page = 2,
	skill = "air_magic",
	level = 22,
	runes = "CE",
	manaCost = 55,
}

fw_magic.defineSpell{
	name = "enchant_shock_arrow",
	uiName = "Enchant Lightning Arrow",
	book_page = 2,
	skill = "air_magic",
	level = 9,
	runes = "BCFH",
	manaCost = 20,
}

-- earth magic
fw_magic.defineSpell{
	name = "poison_cloud",
	uiName = "Poison Cloud",
	book_page = 4,
	skill = "earth_magic",
	level = 3,
	runes = "G",
	manaCost = 17,
}

fw_magic.defineSpell{
	name = "poison_bolt",
	uiName = "Poison Bolt",
	book_page = 4,
	skill = "earth_magic",
	level = 7,
	manaCost = 22,
}

fw_magic.defineSpell{
	name = "poison_shield",
	uiName = "Poison Shield",
	book_page = 4,
	skill = "earth_magic",
	level = 13,
	runes = "EG",
	manaCost = 35,
}

fw_magic.defineSpell{
	name = "enchant_poison_arrow",
	uiName = "Enchant Poison Arrow",
	book_page = 4,
	skill = "earth_magic",
	level = 11,
	runes = "BFGH",
	manaCost = 20,
}

end
]])
createSpell{
	name = "light",
	uiName = "Light",
	skill = "spellcraft",
	level = 5,
	runes = "BE",
	manaCost = 25,
	onCast = "light",
}

createSpell{
	name = "darkness",
	uiName = "Darkness",
	skill = "spellcraft",
	level = 5,
	runes = "EH",
	manaCost = 25,
	onCast = "darkness",
}

-- fire magic
createSpell{ 
	name = "fireburst",
	uiName = "Fireburst",
	skill = "fire_magic",
	level = 2,
	runes = "A",
	manaCost = 15,
	onCast = "fireburst",
}

createSpell{
	name = "fireball",
	uiName = "Fireball",
	skill = "fire_magic",
	level = 13,
	runes = "ACF",
	manaCost = 33,
	onCast = "fireball",
}

createSpell{
	name = "fire_shield",
	uiName = "Fire Shield",
	skill = "fire_magic",
	level = 16,
	runes = "AE",
	manaCost = 50,
	onCast = "fireShield",
}

createSpell{
	name = "enchant_fire_arrow",
	uiName = "Enchant Fire Arrow",
	skill = "fire_magic",
	level = 7,
	runes = "ABFH",
	manaCost = 20,
	onCast = "enchantFireArrow",
}

-- ice magic
createSpell{
	name = "ice_shards",
	uiName = "Ice Shards",
	skill = "ice_magic",
	level = 3,
	runes = "GI",
	manaCost = 24,
	onCast = "iceShards",
}

createSpell{
	name = "frostbolt",
	uiName = "Frostbolt",
	skill = "ice_magic",
	level = 13,
	runes = "CI",
	manaCost = 29,
	onCast = "frostbolt",
}

createSpell{
	name = "frost_shield",
	uiName = "Frost Shield",
	skill = "ice_magic",
	level = 19,
	runes = "EI",
	manaCost = 45,
	onCast = "frostShield",
}

createSpell{
	name = "enchant_frost_arrow",
	uiName = "Enchant Frost Arrow",
	skill = "ice_magic",
	level = 7,
	runes = "BFHI",
	manaCost = 20,
	onCast = "enchantFrostArrow",
}

-- air magic		
createSpell{
	name = "shock",
	uiName = "Shock",
	skill = "air_magic",
	level = 4,
	runes = "C",
	manaCost = 21,
	onCast = "shock",
}

createSpell{
	name = "invisibility",
	uiName = "Invisibility",
	skill = "air_magic",
	level = 19,
	runes = "CEH",
	manaCost = 35,
	onCast = "invisibility",
}

createSpell{
	name = "lightning_bolt",
	uiName = "Lightning Bolt",
	skill = "air_magic",
	level = 14,
	runes = "CD",
	manaCost = 40,
	onCast = "lightningBolt",
}

createSpell{
	name = "shock_shield",
	uiName = "Shock Shield",
	skill = "air_magic",
	level = 22,
	runes = "CE",
	manaCost = 55,
	onCast = "shockShield",
}

createSpell{
	name = "enchant_shock_arrow",
	uiName = "Enchant Lightning Arrow",
	skill = "air_magic",
	level = 9,
	runes = "BCFH",
	manaCost = 20,
	onCast = "enchantShockArrow",
}

-- earth magic
createSpell{
	name = "poison_cloud",
	uiName = "Poison Cloud",
	skill = "earth_magic",
	level = 3,
	runes = "G",
	manaCost = 17,
	onCast = "poisonCloud",
}

createSpell{
	name = "poison_bolt",
	uiName = "Poison Bolt",
	skill = "earth_magic",
	level = 7,
	runes = "CG",
	manaCost = 22,
	onCast = "poisonBolt",
}

createSpell{
	name = "poison_shield",
	uiName = "Poison Shield",
	skill = "earth_magic",
	level = 13,
	runes = "EG",
	manaCost = 35,
	onCast = "poisonShield",
}

createSpell{
	name = "enchant_poison_arrow",
	uiName = "Enchant Poison Arrow",
	skill = "earth_magic",
	level = 11,
	runes = "BFGH",
	manaCost = 20,
	onCast = "enchantPoisonArrow",
}

-- can only be cast with power weapon
createSpell{
	name = "powerbolt",
	uiName = "Powerbolt",
	skill = "air_magic",
	level = 0,
	runes = nil,
	manaCost = 0,
	onCast = "powerbolt",
}
