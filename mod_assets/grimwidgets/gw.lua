fw_addModule('gw',[[
keyHooks = {}
elements = {
	gui = {},
	stats = {},
	skills = {},
	inventory = {}
}

defaultColor = {255,255,255,255}
defaultTextColor = {255,255,255,255}

function _drawGUI(g)
	_processKeyHooks(g)
	_drawElements(g,'gui')
	gw_events.processEvents(g)

end

function _drawInventory(g,champ)
	_drawElements(g,'inventory',champ)
end

function _drawStats(g,champ)
	_drawElements(g,'stats',champ)
end

function _drawSkills(g,champ)
	_drawElements(g,'skills',champ)
end

function _drawElements(g,hookName,champion)
	hookName = hookName or 'gui'
	local hasDeletedElements = false
	
	for i,elem in ipairs(elements[hookName]) do
		if elem.deleted then
			hasDeletedElements = true
		else
			elem:draw(g,champion)
		end
	end
	-- safely delete elements marked as deleted
	-- maintaining indexes. This way a element can delete itself without crash
	if hasDeletedElements and #elements[hookName] > 0 then
		for i = #elements[hookName], 1, -1 do
			if (elements[hookName][i].deleted) then
				table.remove(elements[hookName],i)	
			end
		end	
	
	end
	
	
end

function _processKeyHooks(g)
	for key,hookDef in pairs(keyHooks) do
		if hookDef.toggle then
			-- toggle key state and add small threshold so the state doesn't change immediately
			if not keyToggleThresholdTimer and g.keyDown(key) then
				hookDef.active = not hookDef.active
				local t = spawn('timer',party.level,0,0,1,'keyToggleThresholdTimer')
				t:setTimerInterval(0.3)
				t:addConnector('activate','gw','_destroyKeyToggleThresholdTimer')
				t:activate()
			end
			if hookDef.active then
				hookDef.callback(g)
			end	
		elseif g.keyDown(key) then
			hookDef.callback(g)
		end
	end
end

function _destroyKeyToggleThresholdTimer()
	keyToggleThresholdTimer:destroy()
end


function setKeyHook(key,ptoggle,pcallback)
	keyHooks[key] = {callback=pcallback,toggle=ptoggle,active=false}
end

function addElement(element,hookName)
	hookName = hookName or 'gui'
	removeElement(element.id,hookName)
   	table.insert(elements[hookName],element)
end

function getElement(id,hookName)
	hookName = hookName or 'gui'
	for i,elem in ipairs(elements[hookName]) do
		if elem.id == id then
			return elem
		end
	end	
end

function removeElement(id,hookName)
	local elem = getElement(id,hookName)
	if elem then elem.deleted = true end
end

-- general element factory method
function create(elementType,id,arg1,arg2,arg3,arg4,arg5,arg6)
	if type(elementType) ~= 'string' then
		print('Element type must be string')
		return false
	end
	local elementFactory = findEntity('gw_'..elementType)
	if (not elementFactory or elementFactory.create == nil) then
		print('Invalid grimwidgets element type: '..elementType)
		return false
	end
	return elementFactory.create(id,arg1,arg2,arg3,arg4,arg5,arg6)
end

function new(def)
	local elem = gw.create(def[1])
	for prop,value in pairs(def) do
		if (prop ~= 1) then
			elem[prop] = value		
		end
	end
	return elem
end

function setDefaultColor(color)
	defaultColor = color
end

function getDefaultColor()
	return defaultColor
end

function setDefaultTextColor(color)
	defaultTextColor = color
end

function getDefaultTextColor()
	return defaultTextColor
end

]])