fw_addModule('gw_events',[[
-- processes events that are located in the same
-- location as party
function processEvents(ctx)

	local items=""
    for i in entitiesAt(party.level, party.x, party.y) do
		if i.name == "gw_event" then
			
			processEncounter(ctx, i)
		end
    end
end

function processEncounter(ctx, eventScript)
	if not sanityCheck(eventScript) then
		help.unfreezeWorld()
		return
	end
	help.freezeWorld()

	local state = eventScript.state
	if state == nil then
		state = 1
	end


	-- Check if image is defined for this event
	local image_x = eventScript.x
	local image_y = eventScript.y
	if not image_x then
	    image_x = 20
	end
	if not image_y then
		image_y = 20
	end
	if eventScript.image then
	   ctx.drawImage(eventScript.image, image_x, image_y)
	end
	
	
	-- Ok, now write a text
	local text_x = eventScript.text_x
	local text_y = eventScript.text_y
	if not text_x then
		text_x = 200
	end
	if not text_y then
		text_y = 50
	end
	
	stateData = eventScript.states[state]
	ctx.color(255, 255, 255)
	ctx.drawText(stateData[2], text_x, text_y)
		
	local tbl = eventScript.actions
		
	local buttons_x = eventScript.buttons_x
	local buttons_y = eventScript.buttons_y
	local buttons_width = eventScript.buttons_width
		
	printChoices(ctx, state, tbl, buttons_x, buttons_y, buttons_width)
end

function printChoices(ctx, current_state, states, x, y, width)
	for key1,value in pairs(states) do
		if value[1] == current_state then
			showButton(ctx, x, y, width, value[2], value[3])
			y = y + 30
		end
	end

end

function sanityCheck(e)
	if e.name ~= "gw_event" then
		return false
	end
    if e.states == nil then
		return false
	end
	
	if e.actions == nill then
		return false
	end
	
	if (e.enabled ~= true) then
		return false
	end
	
	return true

end

function showButton(ctx, x, y, width, text, callback)
    -- draw button1 with text
    ctx.color(128, 128, 128)
    ctx.drawRect(x, y, width, 20)
    ctx.color(255, 255, 255)
    ctx.drawText(text, x + 10, y + 15)
	local name="button"..x..y
	local height = 30
    if ctx.button("button1", x, y, width, height) then
		callback(ctx)
	end
end
]])

-- This new type of objects can be easily placed in the dungeon
-- using dungeon editor. Examples of such events are: meeting
-- a NPC, buying/selling in a shop, discussion with arch-enemy, etc.
cloneObject{
	name = "gw_event",
	baseObject = "script_entity",
	editorIcon = 148

}
