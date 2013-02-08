LoadModule("Dialog",[[



tDialog = {
	dialogs = {},			-- Contrains definition of all defined dialogs
--	activeDialog = nil,		-- ID of dialog currently on screen
	startedAt = nil,		-- Time_played the dialog was first shown
}

-- This method creates a gw_element that represents a dialog.
-- It is not really a proper gw_element, but it is sufficient to have its drawSelf
-- method called. That is enough for now to plug Dialog into grimwidgets.
function create(x, y, width, height)
	local elem = gw_element.create("Dialog", x, y, width, height)
	elem.drawSelf = onDraw
	elem.dialog = { id = Util.String_GenerateUUID("dlg_"),
		        text = "",
			buttons = {},
			npc = nil,
			callBack = nil}
	table.insert(tDialog.dialogs, s_newDialog)
	tDialog.startedAt = getStatistic("play_time")

	return elem
end

function new(s_text, s_buttonText, s_npc, s_id)

	-- Check parameters; mandatory and/or type checking
	if type(s_text) == "string" and type(s_buttonText) == "string" and (s_npc == nil or type(s_npc) == "string") and (s_id == nil or type(s_id) == "string") then

		-- if no id is given, create a random one
		if s_id == "" or s_id == nil then
			s_id = Util.String_GenerateUUID("dlg_")
		end

		-- Get definition of existing dialog with that id
		if getDialog(s_id) == nil then
		
			-- Create a new dialog if none exists with that id
			local s_newDialog = { id = s_id,
								  text = s_text,
								  buttons = {s_buttonText},
								  npc = s_npc,
								  callBack = nil,
								}
			table.insert(tDialog.dialogs, s_newDialog)
		end
		
		return s_id
	else
		print("Calling dialog.new() with wrong number and/or type of parameters.")
	end
end


function addButton(s_id, s_buttonText)

	-- Check parameters; mandatory and/or type checking
	if type(s_id) == "string" and type(s_id) == "string" then
	
		table.insert(getDialog(s_id).buttons, 1, s_buttonText)
		
	else
		print("Calling dialog.addButton() with wrong number and/or type of parameters.")
	end
end


function activate(s_id, f_callBack)

	-- Check parameters; mandatory and/or type checking
	if type(s_id) == "string" and (f_callBack == nil or type(f_callBack)=="function") then

		-- Get dialog definition
		local t_dlg = getDialog(s_id)
		if t_dlg then
			
			-- Make fetched dialog the active dialog
			t_dlg.callBack = f_callBack
			tDialog.startedAt = getStatistic("play_time")

			-- We need to create a gw_element. It will be called from gw framework.
	                -- It will not draw anything on its own, just will call onDraw() method. It
                        -- will be removed when deactivate() method is called.

                        -- x, y, width, height all set to -1 (set it automatically)
                        local h_glue = create(-1, -1, -1, -1)
                        h_glue.dialog = t_dlg
                        gw.addElement(h_glue, 'gui')

		end
	else
		print("Calling dialog.activate() with wrong number and/or type of parameters.")
		return
	end

end

function deactivate()
	-- remove any active dialog (if any)
	tDialog.startedAt = nil

	-- remove active hooks from grimwidgets. Dialog.onDraw() method will no longer
	-- be called
	gw.removeElement("Dialog", 'gui')
end

function quickYesNoDialog(s_text, f_callBack, s_npc)

	-- Check parameters; mandatory and/or type checking
	if type(s_text) == "string" and (f_callBack == nil or type(f_callBack == "function")) and (s_npc == nil or type(s_npc)=="string") then
	
		-- Use standard id and get current dialogdefinition
		local s_id = "dlgQuickYesNo"
		local t_dlg = getDialog(s_id)

		-- Make a new dialogdefinition if none is found
		if t_dlg == nil then
			s_id = new(s_text, "Yes", s_npc, s_id)
			addButton(s_id, "No")
		else
			-- And replace text and npc if a dialogdefinition was found
			t_dlg.text = s_text
			t_dlg.npc = s_npc
		end
		
		-- Show the dialog
		activate(s_id, f_callBack)
		
	else
		print("Calling dialog.quickYesNoDialog() with wrong number and/or type of parameters.")
	end
end


function quickDialog(s_text, f_callBack, s_npc)

	-- Check parameters; mandatory and/or type checking
	if type(s_text) == "string" and (f_callBack == nil or type(f_callBack == "function")) and (s_npc == nil or type(s_npc)=="string") then

		-- Use standard id and get current dialogdefinition
		local s_id = "dlgQuickClose"
		local t_dlg = getDialog(s_id)
		
		-- Make a new dialogdefinition if none is found
		if t_dlg == nil then
			s_id = new(s_text, "Close", s_npc, s_id)
		else
			-- And replace text and npc if a dialogdefinition was found
			t_dlg.text = s_text
			t_dlg.npc = s_npc
		end

		-- Show the dialog
		activate(s_id, f_callBack)
		
	else
		print("Calling dialog.quickDialog() with wrong number and/or type of parameters.")
	end
end


function isActivated(s_id)
	if s_id and type(s_id)=="string" then
		return gw.getElement(s_id) ~= s_id
	else
		print("isActivated() requires exactly one string parameter (id)")
	end
end

function getActiveDialogNpc()

	-- Check parameters; mandatory and/or type checking
	if id and type(s_id)=="string" then
	
		return tDialog.activeDialog.npc
		
	end
	
	return nil
end


function getDialog(s_id) 

	-- return dialogdefinition by id
	for _, t_dlg in pairs(tDialog.dialogs) do
		if t_dlg.id == s_id then
			return t_dlg
		end
	end
end

function calculateDimensions(t_dlg)
	-- Define bunch of constants we'll use while drawing
	local n_minWindowWidth = 80
	local n_dialogPixelWidth = 8.5
	local n_dialogPixelHeight = 24
	local n_portraitSize = 128

	-- Calculate window width, starting with minimum width and adding pixels depending on content
	local n_windowWidth = n_minWindowWidth

	-- Add pixels to width for every character in the widest line of the text.
	-- But if there's a npc portrait take the largest of either: 1) text from first few lines + pictures width or 2) width of the widest line of all lines
	if t_dlg.npc and NPC.Exists(t_dlg.npc) then
		n_windowWidth = n_windowWidth + math.max(charWidth(t_dlg.text) * n_dialogPixelWidth, charWidth(t_dlg.text, 6) * n_dialogPixelWidth + n_portraitSize + 8)
	else
		n_windowWidth = n_windowWidth + charWidth(t_dlg.text) * n_dialogPixelWidth
	end

	-- Check if the buttons can fit and adjust width if needed
	local n_buttonWidth = -20
	for _, n_btn in pairs(t_dlg.buttons) do			
		n_buttonWidth = n_buttonWidth + getButtonWidth(charWidth(n_btn)) + 20
	end
	n_windowWidth = math.max(n_windowWidth, n_minWindowWidth + n_buttonWidth)


	-- Calculate window height, starting with minimum height and adding pixels depending on content
	local n_windowHeight = 80
	-- Add pixels if an npc is talking, but only if there are less than 6 lines of text
	if t_dlg.npc and NPC.Exists(t_dlg.npc) and NPC.GetAttr(t_dlg.npc, "Portrait") and countLines(t_dlg.text) < 6 then
		n_windowHeight = n_windowHeight + n_portraitSize + 30		
		-- Add 24 pixels to height for each line, but the first 5 lines are free
		n_windowHeight = n_windowHeight + math.max(0, (countLines(t_dlg.text) - 6) * n_dialogPixelHeight)
	else
		n_windowHeight = n_windowHeight + math.max(0, countLines(t_dlg.text) * n_dialogPixelHeight)
	end


	-- Calculate needed height for buttons. First the basic height, then add extra height for evert line of buttontext
	n_windowHeight = n_windowHeight + 16
	n_windowHeight = n_windowHeight + getButtonMaxLines(t_dlg.buttons) * n_dialogPixelHeight
	
	return n_windowWidth, n_windowHeight
end

function onDraw(h_gwelement, h_gui)


		local t_dlg = h_gwelement.dialog
		if (t_dlg == nil) then
		   print("#### dialog is nil")
		   return
		end
		local s_response = nil
		local n_windowTileSize = 128
		
		local n_windowWidth = 0
		local n_windowHeight = 0
		n_windowWidth, n_windowHeight = calculateDimensions(t_dlg)

		
		if (h_gwelement.width ~= -1) then
		   n_windowWidth = h_gwelement.width
		end
		if (h_gwelement.height ~= -1) then
		   n_windowHeight = h_gwelement.height
		end

		-- Round width and height to the nearest higher whole factor of 64
		n_windowWidth = math.ceil(n_windowWidth / 64) * 64
		n_windowHeight = math.ceil(n_windowHeight / 64) * 64

		-- Detemine if the width is a multiple of 128 or 64 (needed for drawing the window in right size); yields either 64 or 128
		local n_multipleWidth = 128 - (64 * ((n_windowWidth / 64) % 2))
		local n_multipleHeight = 128 - (64 * ((n_windowHeight / 64) % 2))
		
		-- Calculate offset of the window (position it in the middle of the screen)
		local n_windowOffsetX = (h_gui.width - n_windowWidth) / 2
		local n_windowOffsetY = (h_gui.height - n_windowHeight) / 2

		-- Update gw_element if it was set to auto
		if (h_gwelement.x == -1) then
		   h_gwelement.x = n_windowOffsetX
		end
		if (h_gwelement.y == -1) then
		   h_gwelement.y = n_windowOffsetY
		end
		if (h_gwelement.width == -1) then
		   h_gwelement.width = n_windowWidth
		end
		if (h_gwelement.height == -1) then
		   h_gwelement.height = n_windowHeight
		end

		-- Draw Window in tiles
		local n_maxX = math.floor(n_windowWidth / n_windowTileSize) - 1
		if n_multipleWidth == 64 then
			n_maxX = n_maxX + 1
		end		
		local n_maxY = math.floor(n_windowHeight / n_windowTileSize) - 1
		if n_multipleHeight == 64 then
			n_maxY = n_maxY + 1
		end
		h_gui.color(255, 255, 255, 255)				
		for n_y = 0, n_maxY do
			for n_x = 0, n_maxX do
				h_gui.drawImage("mod_assets/lnr/textures/dialog/window_"..getTileName(n_x, n_maxX, n_y, n_maxY, n_multipleWidth, n_multipleHeight, n_windowTileSize)..".tga", n_windowOffsetX + n_x * n_windowTileSize, n_windowOffsetY + n_y * n_windowTileSize)
			end
		end

		-- Draw NPC portrait
		if t_dlg.npc then
			if NPC.Exists(t_dlg.npc) then
				h_gui.drawImage(NPC.GetAttr(t_dlg.npc, "Portrait"), n_windowOffsetX + n_windowWidth - 40 - 128, n_windowOffsetY + 40)
				h_gui.font("tiny")
				h_gui.color(255, 255, 255, 255)
				h_gui.drawText(NPC.GetAttr(t_dlg.npc, "Name"), n_windowOffsetX + n_windowWidth - 40 - 128 + (128 - charWidth(NPC.GetAttr(t_dlg.npc, "Name")) * 8) / 2, n_windowOffsetY + 40 + 128 + 14)
			end
		end


		-- Draw text
	if (t_dlg.text and string.len(t_dlg.text)) then
		drawText(h_gui, t_dlg.text, n_windowOffsetX + 40, n_windowOffsetY + 40)
	end


		-- Draw buttons
		local n_maxLines = math.max(0, getButtonMaxLines(t_dlg.buttons) -1);
		local n_buttonOffsetX = n_windowWidth - 40
		local n_buttonOffsetY = n_windowHeight - 72 - n_maxLines * 25;
		
		for _, n_btn in pairs(t_dlg.buttons) do
		
			-- Calculate width, height and other numbers
			local n_buttonWidth = getButtonWidth(n_btn)
			local n_buttonHeight = math.ceil(32 + n_maxLines * 25)
			-- Round buttonheight to next higher divider of 16
			n_buttonHeight = math.ceil(n_buttonHeight / 16) * 16
			-- Calculate how many tiles are needed
			local n_maxX = math.ceil(n_buttonWidth / 16) - 1
			local n_maxY = math.ceil(n_buttonHeight / 16) -1

			-- Draw the button, made up of 16x16 tiles
			n_buttonX = n_windowOffsetX + n_buttonOffsetX - n_buttonWidth
			n_buttonY = n_windowOffsetY + n_buttonOffsetY 
			for n_y = 0, n_maxY do
				for n_x = 0, n_maxX do
					h_gui.drawImage("mod_assets/lnr/textures/dialog/button_"..getTileName(n_x, n_maxX, n_y, n_maxY, 16, 16, 16)..".tga", n_buttonX + n_x * 16, n_buttonY + n_y * 16)
				end
			end

			-- Write the buttontext
			h_gui.font("small")
			h_gui.color(255, 255, 255, 255)
			local n_buttonTextX = n_windowOffsetX + n_buttonOffsetX - n_buttonWidth + (n_buttonWidth - (charWidth(n_btn) + .5) * 7) / 2
			local n_buttonTextY = n_windowOffsetY + n_buttonOffsetY + 6 + (n_buttonHeight - (countLines(n_btn)-1) * 16) / 2
			h_gui.drawText(n_btn, n_buttonTextX, n_buttonTextY)

			-- Check if the button has been pressed
			if h_gui.button(n_btn, n_buttonX, n_buttonY, n_buttonWidth, n_buttonHeight) then
				s_response = n_btn
			end
			n_buttonOffsetX = n_buttonOffsetX - n_buttonWidth - 20
		end

		-- Handle if one of the buttons is pressed
		if s_response then
			
			-- close the current dialog
			deactivate()
			if t_dlg.callBack then
				t_dlg.callBack(s_response)
			end
			
		end
		
		-- See if the window itself is pressed
		if h_gui.button(t_dlg.id, n_windowOffsetX, n_windowOffsetY, n_windowWidth, n_windowHeight - 70) then
			tDialog.startedAt = -1000
		end
		
end


function getTileName(n_x, n_n_maxX, n_y, n_n_maxY, n_width, n_height, n_maxSize)
	-- Determine what image to use to draw
	local s_tileName = ""
	if n_y == 0 then
		if n_x == 0 then
			s_tileName = ""..n_maxSize.."_top_left"
		else
			if n_x == n_n_maxX then
				s_tileName = ""..n_width.."_"..n_maxSize.."_top_right"							
			else
				s_tileName = ""..n_maxSize.."_top_middle"
			end
		end
	else
		if n_y == n_n_maxY then
			if n_x == 0 then
				s_tileName = ""..n_maxSize.."_"..n_height.."_bottom_left"
			else
				if n_x == n_n_maxX then
					s_tileName = ""..n_width.."_"..n_height.."_bottom_right"							
				else
					s_tileName = ""..n_maxSize.."_"..n_height.."_bottom_middle"
				end
			end
		else
			if n_x == 0 then
				s_tileName = ""..n_maxSize.."_middle_left"
			else
				if n_x == n_n_maxX then
					s_tileName = ""..n_width.."_"..n_maxSize.."_middle_right"							
				else
					s_tileName = ""..n_maxSize.."_middle_middle"
				end
			end
		end
	end
	return s_tileName
end


function drawText(h_gui, s_text, n_areaX, n_areaY)

	-- Set font size and color
	h_gui.font("medium")
	h_gui.color(255, 255, 255, 255)
	
	-- Determine what part of the text we need to write
	local n_textLength = math.floor((getStatistic("play_time") - tDialog.startedAt) * 50)

	h_gui.drawText(string.sub(s_text, 1, n_textLength), n_areaX, n_areaY + 17)
end


function charWidth(s_text, n_maxLine)

	local n_maxLen = 0
	local n_curLen = 0
	local n_lineCount = 0

	for n_Nr = 1, string.len(s_text) do		
		if n_maxLine == nil or n_lineCount <= n_maxLine then
			if string.sub(s_text, n_Nr, n_Nr) == "\n" then
				n_curLen = 0
				n_lineCount = n_lineCount + 1
			else
				n_curLen = n_curLen + 1
			end
			if n_curLen > n_maxLen then 
				n_maxLen = n_curLen
			end
		end
	end
	return n_maxLen

end


function countLines(s_text)
	return string.len(s_text) - string.len(string.gsub(s_text, "\n", "")) + 1
end


function getButtonMaxLines(t_buttons)
	local n_maxLines = 0
	for _, s_btn in pairs(t_buttons) do
		if countLines(s_btn) > n_maxLines then
			n_maxLines = countLines(s_btn)
		end
	end
	return n_maxLines
end

function getButtonWidth(s_caption)
	-- Calculate with, starting with base width
	local n_width = 64
	-- 	Add pixels depending on character width, but first 2 characters are free
	n_width = n_width + math.max(0, charWidth(s_caption) * 8)
	-- Round to first whole number of 16
	n_width = math.ceil(n_width / 16) * 16
	return n_width
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Backward compatibility functions
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function SetOpen(s_id, bOpen)
	print("dialog.SetOpen is not supported an_ymore. Use dialog.activate() and dialog.deactivate() instead")
end

function SetState(sState)
	print("SetState is not supported an_ymore! If you think you need states, consult Mahric.")
end

function GetState()
	print("GetState is not supported an_ymore. Instead use isActivated()")
	return ""
end

]]);