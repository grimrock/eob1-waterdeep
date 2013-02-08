fw_addModule('gw_button',[[
function create(id, x, y, text)
	local width = gw_string.stringWidth(text)
	local elem = gw_rectangle.create(id, x, y, width, 23)
	elem.text = text
	elem.drawSelf = _draw
	return elem
end

function _draw(self, ctx)
	gw_rectangle._draw(self, ctx)
	gw_util.resetColor(ctx)
end
]])