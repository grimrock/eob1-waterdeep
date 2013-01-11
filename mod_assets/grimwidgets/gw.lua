fw_addModule('gw',[[
keyHooks = {}
elements = {
	gui = {},
	stats = {},
	skills = {},
	inventory = {}
}

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
	for id,element in pairs(elements[hookName]) do
		element:draw(g,champion)
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

function _addChild(parent, child,id,x,y,width,height)
	if type(child) == 'string' then
		child = gw['create'..child](id,x,y,width,height)
	end 

	table.insert(parent.children, child)
	return child
end

function setKeyHook(key,ptoggle,pcallback)
	keyHooks[key] = {callback=pcallback,toggle=ptoggle,active=false}
end

function addElement(element,hookName)
	hookName = hookName or 'gui'
   	table.insert(elements[hookName],element)
end

function removeElement(id,hookName)
	hookName = hookName or 'gui'
	for i,elem in ipairs(elements[hookName]) do
		if elem.id == id then
			table.remove(elements[hookName],i)
			return
		end
	end
end

function createElement(id, x, y, width, height)
    local elem = {}
    elem.id = id
	elem.x = x
	elem.y = y
	elem.width = width
	elem.height = height
	elem.parent = nil
	elem.children = {}
	elem.addChild = _addChild
	elem.drawSelf = gw_util.drawNone
	elem.draw = gw_util.drawAll
	elem.onPress = nil
	elem.onClick = nil
	elem.firstMousePressPoint = nil
	return elem
end

function createRectangle(id, x, y, width, height)
	local elem = createElement(id, x, y, width, height)
	elem.drawSelf = gw_util.drawRect
	return elem
end

function createButton(id, x, y, text)
	local width = gw_util.stringWidth(text)
	local elem = createRectangle(id, x, y, width, 23)
	elem.text = text
	elem.drawSelf = gw_util.drawButton
	return elem
end
 
function createButton3D(id, x, y, text, width, height, color)
	width = gw_util.defaultValue(width, gw_util.stringWidth(text))
	height = gw_util.defaultValue(height, 27)
	
	local elem = createRectangle(id, x, y, width, height)
	elem.text = text
	elem.drawSelf = gw_util.drawButton3D
	elem.color = gw_util.defaultValue(color, { 128, 128, 128 })
	return elem
end
]])