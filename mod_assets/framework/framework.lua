--[[
LoG Scripting framework
Created by: JKos
Documentation: http://www.grimrock.net/forum/viewtopic.php?f=14&t=3321

INSTALLATION 

iclude this file to your init.lua after stadard_assets.lua

Like this:
[code]
-- import standard assets
import "assets/scripts/standard_assets.lua"

-- import custom assets
import "framework/framework.lua"
-- load desired framework modules
fw_loadModule('illusion_walls')

-- import custom assets
import "mod_assets/scripts/items.lua"
import "mod_assets/scripts/monsters.lua"
import "mod_assets/scripts/objects.lua"
import "mod_assets/scripts/wall_sets.lua"
import "mod_assets/scripts/recipes.lua"
import "mod_assets/scripts/materials.lua"
import "mod_assets/scripts/sounds.lua"

[/code]

create script entity named logfw_init
and put this code to it:
----------------

spawn("LoGFramework", 1,1,1,0,'fwInit')
fwInit:open() -- this loads all script entites defined in framework.lua
-- timer will call this method automatically 
-- 0.1 seconds after the game is started
-- you can also set debug-flag on here
function main()
   timers:setLevels(1) 
   fw.debug.enabled = true
   fwInit:close() --must be called
end

-----------------

DONE
]]

local showWarnings = true

local modules = {}	
local loadOrder = {}
local moduleInitFunction = {}

--  Set to false if you dont wan't to see warnings about module scripts copy pasted to dungeon
function fw_setShowWarnings(show)
	showWarnings = show
end

function fw_addModule(name,script)
	modules[name] = script
	loadOrder[#loadOrder+1] = name 
end
function fw_addModuleInitCallback(modulename,callback)
	moduleInitFunction[modulename] = callback
end

function fw_loadModule(name)
	if modules[name] then return end
	import('mod_assets/framework/modules/'..name..'.lua')
end

function tableToSet(list)
  local set = {}
  for _, l in ipairs(list) do set[l] = true end
  return set
end
fw_loadModule('timers')
fw_loadModule('grimq')
fw_loadModule('fw')
fw_loadModule('data')
fw_loadModule('help')



cloneObject{
	name = "LoGFramework",
	baseObject = "dungeon_door_metal",
	onOpen = function()
		-- load modules
		
		for moduleName,source in pairs(modules) do
			local script = findEntity(moduleName)
			if not script then 
				spawn("script_entity", party.level,1,1,0,moduleName) 
				script = findEntity(moduleName)
				script:setSource(source)
			else
				if showWarnings then
					print('script entity "'..moduleName..'" found from dungeon, the module from lua file was not loaded')
				end
			end
		end
		spawn('timer',party.level,0,0,0,'logfw_inittimer')
		logfw_inittimer:addConnector('activate','logfw_init','main')
		logfw_inittimer:setTimerInterval(0.1)
		logfw_inittimer:activate()
	end,
	onClose = function()
		for _,moduleName in ipairs(loadOrder) do
			local moduleEntity = findEntity(moduleName)	
			if moduleInitFunction[moduleName] then
				moduleInitFunction[moduleName](moduleEntity,grimq)
			end
			
			if moduleEntity and moduleEntity.activate then
				moduleEntity.activate()
			end
		end		
		logfw_inittimer:deactivate()
		logfw_inittimer:destroy()
		fwInit:destroy()	
	end
}










