
-- import the framework if it's not loaded
if not fw_loadModule then
	import('mod_assets/framework/framework.lua')
end
function gw_loadModule(name)
	import('mod_assets/grimwidgets/'..name..'.lua')
end

-- this is a simple wrapper for modules from LotNR. They use LoadModule instead of
-- fw_addModule(), but the approach is essentially the same.
function LoadModule(name, code)
	 fw_addModule(name, code)
end

-- Basic hooks for GUI related calls (GUI, inventory, skills, stats)
cloneObject{
	name='party',
	baseObject='party',
	onDrawGui = function(g)
	   gw._drawGUI(g)
	end, 
	onDrawInventory = function(g,champ)
	   gw._drawInventory(g,champ)
	end, 
	onDrawSkills = function(g,champ)
	   gw._drawSkills(g,champ)
	end, 
	onDrawStats  = function(g,champ)
	   gw._drawStats(g,champ)
	end	
}
gw_loadModule('gw')
gw_loadModule('gw_util')
gw_loadModule('gw_element')
gw_loadModule('gw_rectangle')
gw_loadModule('gw_button3D')
gw_loadModule('gw_image')
gw_loadModule('gw_button')
gw_loadModule('gw_events')
gw_loadModule('gw_text')
gw_loadModule('gw_string')

gw_loadModule('gw_party')
gw_loadModule('gw_book')

-- these are modules from LotNR. They use different naming
-- convention.
gw_loadModule('Dialog')
gw_loadModule('Util')
