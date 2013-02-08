fw_addModule('gw_image',[[
function create(id, x, y, width, height, filename)
	local elem = gw_element.create(id, x, y, width, height)
	elem.image = filename
	elem.drawSelf = _draw
	return elem
end

function _draw(self, ctx)
    ctx.drawImage(self.image, self.x, self.y)
	gw_util.resetColor(ctx)
end
]])