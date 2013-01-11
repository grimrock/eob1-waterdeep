fw_addModule('gw_util',[[
--- gwElements utiltity functions

-- draws whole element, including all its children
function drawAll(self, ctx)
	self.drawSelf(self, ctx)
	if (self.onPress ~= nil) and (ctx.button(self.id, self.x, self.y, self.width, self.height)) then
		self:onPress()
	end

	-- we manage onClick ourselves
	if (ctx.mouseDown(0)) then
		if (self.firstMousePressPoint == nil) and isPointInBox(ctx.mouseX, ctx.mouseY, self.x, self.y, self.width, self.height) then
			self.firstMousePressPoint = { x = ctx.mouseX, y = ctx.mouseY }
		end
	else
		if (self.firstMousePressPoint ~= nil) then
			if (self.onClick ~= nil) and (isPointInBox(ctx.mouseX, ctx.mouseY, self.x, self.y, self.width, self.height)) then
				self:onClick()
			end
			self.firstMousePressPoint = nil
		end
	end

	for key,child in pairs(self.children) do
		child.x = child.x + self.x -- calculate proper offset
		child.y = child.y + self.y
		child.draw(child, ctx) -- draw child element
		child.x = child.x - self.x -- revert back to normal coordinates
		child.y = child.y - self.y
	end
end

function drawNone()
end

function drawRect(self, ctx)
	if (self.color) then
    	ctx.color(self.color[1], self.color[2], self.color[3], self.color[4])
	end
    ctx.drawRect(self.x, self.y, self.width, self.height)
end

function drawBevel(self, ctx, protruding, fillbutton, highlight)
	local color = defaultValue(self.color, {128, 128,128})
	local light, dark, fill
	
	if (protruding) then
		light = changeBrightness(color, 1.4)
		dark = changeBrightness(color, 0.6)
	else
		light = changeBrightness(color, 0.6)
		dark = changeBrightness(color, 1.4)
	end
	
	
	if (highlight) then
		fill = changeBrightness(color, 1.2)
	else
		fill = color
	end
	
	if (fillbutton) then
		setColor(ctx, fill)
		ctx.drawRect(self.x, self.y, self.width, self.height)
	end	
	
	setColor(ctx, light)
	ctx.drawRect(self.x, self.y, self.width, 2)
	ctx.drawRect(self.x, self.y, 2, self.height)

	setColor(ctx, dark)
	ctx.drawRect(self.x, self.y + self.height - 2, self.width, 2)
	ctx.drawRect(self.x + self.width - 2, self.y, 2, self.height)
end

function drawButton(self, ctx)
	drawRect(self, ctx)
	resetColor(ctx)
	ctx.drawText(self.text, self.x + 5, self.y + 13 + 5)
end

function drawButton3D(self, ctx)
	local hl = isPointInBox(ctx.mouseX, ctx.mouseY, self.x, self.y, self.width, self.height)
	local down = ctx.mouseDown(0) and hl

	gw_util.drawBevel(self, ctx, not down, true, hl)
	
	resetColor(ctx)
	ctx.drawText(self.text, self.x + 5, self.y + 13 + 5)
end

function stringWidth(text)
	local len = 0
	for i = 1, string.len(text) do
		local char = string.sub(text, i, i)
		if char>='A' and char<='Z' then
			len = len + 12 -- capital letters
		elseif char>='a' and char<='z' then
			len = len + 9 -- small letters
		elseif char == ' ' then
			len = len + 5 -- space
		elseif char>='0' and char<='9' then
			len = len + 9
		elseif char>='!' and char<='/' then
			len = len + 8
		else
			len = len + 10		
		end
	end
	return len
end

function defaultValue(curvalue, defvalue)
	if (curvalue == nil) then
		return defvalue
	else
		return curvalue
	end
end

function rgb2yuv(rgb)
	return {
		0.299 * rgb[1] + 0.587 * rgb[2] + 0.114 * rgb[3] ,
		-0.147 * rgb[1] - 0.289 * rgb[2] + 0.436 * rgb[3],
		0.615 * rgb[1] - 0.515 * rgb[2] - 0.1 * rgb[3],
		rgb[4]
	}
end

function normalizeColorComponent(c)
	return math.max(0, math.min(255, math.floor(c + 0.5)))
end

function yuv2rgb(yuv)
	return {
		normalizeColorComponent(yuv[1] + 1.402 * yuv[3]),
		normalizeColorComponent(yuv[1] - 0.344 * yuv[2] - 0.714 * yuv[3]),
		normalizeColorComponent(yuv[1] + 1.772 * yuv[2]),
		yuv[4]
	}
end

function changeBrightness(color, factor)
	local yuv = rgb2yuv(color)
	yuv[1] = factor * yuv[1]
	return yuv2rgb(yuv)
end

function isPointInBox(px, py, bx, by, bw, bh)
	return (px >= bx) and (px <= bx + bw) and (py >= by) and (py <= by + bh)
end

function setColor(ctx, color)
	ctx.color(color[1], color[2], color[3], color[4])
end

function resetColor(ctx)
	ctx.color(255, 255, 255, 255)
end


]])