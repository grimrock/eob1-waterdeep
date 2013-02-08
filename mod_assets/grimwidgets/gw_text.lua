fw_addModule('gw_text',[[
function create(id, x, y, width, height, text)
	local elem = gw_element.create(id, x, y, width, height)
	elem.text = text
	elem.calculateHeight = _calculateHeight
	return elem
end

function _calculateHeight(self)
	local lines = gw_string.wrap(self.text, self.width,self.textSize)
	local sizes = {tiny=10,small=14,medium=20,large=20}
	local size = sizes[self.textSize]
	self.height = size * #lines
end
]])
