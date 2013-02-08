fw_addModule('gw_util',[[
--- gwElements utiltity functions

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
	color = gw.getDefaultColor()
	ctx.color(color[1], color[2], color[3], color[4])
end
]])