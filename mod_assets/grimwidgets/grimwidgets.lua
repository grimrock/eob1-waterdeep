-- Basic hooks for GUI related calls (GUI, inventory, skills, stats)
cloneObject{
	name='party',
	baseObject='party',
	onDrawGui = function(g)
	   gw.draw(g)
	end, 
	onDrawInventory = function(g,champ)
	   gw.drawInventory(g,champ)
	end, 
	onDrawSkills = function(g,champ)
	   gw.drawSkills(g,champ)
	end, 
	onDrawStats  = function(g,champ)
	   gw.drawStats(g,champ)
	end	
}

-- This new type of objects can be easily placed in the dungeon
-- using dungeon editor. Examples of such events are: meeting
-- a NPC, buying/selling in a shop, discussion with arch-enemy, etc.
cloneObject{
	name = "gw_event",
	baseObject = "script_entity",
	editorIcon = 148

}
