cloneObject{
	name='party',
	baseObject='party',
	onDrawGui = function(g)
	   gui.draw(g)
	end, 
	onDrawInventory = function(g,champ)
	   gui.drawInventory(g,champ)
	end, 
	onDrawSkills = function(g,champ)
	   gui.drawSkills(g)
	end, 
	onDrawStats  = function(g,champ)
	   gui.drawStats(g)
	end	
}