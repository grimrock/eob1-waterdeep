fw_addModule('gw_events',[[

-- This array holds the states of the events that were encountered
-- so far. It should use event-id as a key and the value is a string
-- representation of the state, e.g. "wounded_dwarf" = "talk"
-- means that wounded_dwarf event is in talk state.
--
-- There are 2 names with special meanings:
-- "end" means that the event reached its end and is no longer active
-- "aborted" means that the user aborted it, e.g. clicked leave or
-- run away. This state will be forgotten once the party moves to a
-- different square. This effectively allows restarting an event by
-- clicking leave, moving and then returning to the event location.
tEvents = {}

-- This is a location of the last place where event has ocurred. It 
-- is used to remove states in "aborted" state.
tLocation = {
	x = 0,
	y = 0,
	level = 0
}

-- processes events that are located in the same
-- location as party
function processEvents(ctx)
    local items=""
    for i in entitiesAt(party.level, party.x, party.y) do

		updateEvents(ctx)

        if i.name == "gw_event" then
            processEncounter(ctx, i)
        end
    end
end

-- Updates existing event states and removes "aborted" state
-- if the party has moved
function updateEvents(ctx)
	if (tLocation.x ~= party.x or
		tLocation.y ~= party.y or
		tLocation.level ~= party.level) then
		removeAborted(ctx)
	end
	tLocation.x = party.x
	tLocation.y = party.y
	tLocation.level = party.level
end

-- removes as states in the aborted state
function removeAborted(ctx)
	for id, value in pairs(tEvents) do
		if value == "abort" then
			tEvents[id] = nil
		end
	end
end

function processEncounter(ctx, eventScript)
    if not sanityCheck(eventScript) then
        help.unfreezeWorld()
        return
    end
	
	local id = eventScript.id

	if tEvents[id] == nil then
		-- Get the first event
		tEvents[id] = eventScript.states[1][1]
	end
	
	local state = tEvents[id]
	if (state == "end" or state == "abort") then
		return
	end
	
	help.freezeWorld()

	-- This is a valid, active event. Let's process it
	
	local descr = ""
	for name, stateInfo in pairs(eventScript.states) do
		if stateInfo[1] == state then
			descr = stateInfo[2]
			break
		end
	end
		
	-- we don't want to keep adding 60 boxes per seconds
	if gw.getElement("Dialog") == nil then
		gw.setDefaultColor({200,200,200,255})
		gw.setDefaultTextColor({255,255,255,255})

		-- It's not possible to use relative position for root element, 
		-- so let's calculate center of the screen automatically
		local bg = Dialog.create(-1, -1, 600, 400)

	    bg.dialog.text = descr
	
		-- Check if image is defined for this event
		local image_width = 0
		local image_height = 0
		if eventScript.image then
			image_width = eventScript.image_width
			image_height = eventScript.image_height
			if not image_width then
		 		image_width = 128
			end
		if not image_height then
			image_height = 128
		end

		local img = gw_image.create('img1', 0, 0, image_width, image_height, eventScript.image)
		img.marginTop = 30
		bg:addChild(img)
		img:setRelativePosition({'top','right'})
	end
		
	-- Ok, now write a text
	printChoices(ctx, id, state, eventScript.actions, bg)

	gw.addElement(bg, 'gui')
	end
end

function printChoices(ctx, event_id, current_state, actions, window)
	number = 0
	for key1, action in pairs(actions) do
		if action[1] == current_state then
			-- action[2] = next_state, action[3] = text, action[4] = callback (optional)
			showButton(ctx, event_id, number, window, action[2], action[3], action[4])
			number = number + 1
		end
	end

end

-- checks if the event definition is valid
function sanityCheck(e)
	if e.name ~= "gw_event" then
		return false
	end
    if e.states == nil or type(e.states) ~= "table" then
		return false
	end
	
	if e.actions == nil or type(e.actions) ~= "table" then
		return false
	end
	
	-- todo: check that all actions correspond to existing states
	
	return true
end

-- Called when the buttons action is clicked
function callback(button)
	local user_state = nil
	if (button.user_callback) then
		user_state = button:user_callback()
		if user_state then
			-- print("User callback return:"..user_state)
		else
			-- print("User callback (no returned value)")
		end
	end
	if user_state then 
		tEvents[button.event_id] = user_state
	else
		tEvents[button.event_id] = button.next_state
	end
	
	if tEvents[button.event_id] == "end" or
	   tEvents[button.event_id] == "abort" then
		-- print("Unfreeze")
		help.unfreezeWorld()
	end
	
	gw.removeElement("Dialog", 'gui')
end 

function showButton(ctx, event_id, number, window, next_state, text, userCallback)

	local x = 30 + 170*number
	local y = 350 
	local width = 150
	local height = 25
	
	-- print("Adding button "..next_state..", txt="..text.." callback="..type(userCallback).." event_id="..event_id)

	local button = gw_button3D.create("button_"..next_state, x, y, text, width, height)
	window:addChild(button)
	button.onClick = callback
	button.event_id = event_id
	button.next_state = next_state
	button.user_callback = userCallback
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
