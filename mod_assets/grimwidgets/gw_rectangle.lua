fw_addModule('gw_rectangle',[[
function create(id, x, y, width, height)
	local elem = gw_element.create(id, x, y, width, height)
	elem.drawSelf = _draw
	return elem
end

function _draw(self, ctx)

    ctx.drawRect(self.x, self.y, self.width, self.height)
end

]])