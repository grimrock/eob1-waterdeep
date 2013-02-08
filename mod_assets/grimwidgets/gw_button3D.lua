fw_addModule('gw_button3D',[[
function create(id, x, y, text, width, height, color)
	width = gw_util.defaultValue(width, gw_string.stringWidth(text))
	height = gw_util.defaultValue(height, 27)
	
	local elem = gw_rectangle.create(id, x, y, width, height)
	elem.text = text
	elem.drawSelf = _draw
	elem.color = gw_util.defaultValue(color, { 128, 128, 128 })
	return elem
end

function _draw(self, ctx)
	local hl = gw_util.isPointInBox(ctx.mouseX, ctx.mouseY, self.x, self.y, self.width, self.height)
	local down = ctx.mouseDown(0) and hl
	gw_util.drawBevel(self, ctx, not down, true, hl)
	gw_util.resetColor(ctx)
end

]])