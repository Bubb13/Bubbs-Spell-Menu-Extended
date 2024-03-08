
Infinity_DoFile("B3SplWei")
Infinity_DoFile("B3SpelEx")

-----------------------
-- Instance Creation --
-----------------------

B3Spell_InstanceIDs = {}

function B3Spell_CreateInstance(menuName, templateName, x, y, w, h)

	local menuEntry = B3Spell_InstanceIDs[menuName]
	if not menuEntry then
		menuEntry = {}
		B3Spell_InstanceIDs[menuName] = menuEntry
	end

	local entry = menuEntry[templateName]
	if not entry then
		entry = {["maxID"] = 0, ["instanceData"] = {}}
		menuEntry[templateName] = entry
	end

	local newID = entry.maxID + 1
	entry.maxID = newID

	local instanceEntry = {["id"] = newID}
	entry.instanceData[newID] = instanceEntry

	local oldAnimationID = currentAnimationID
	currentAnimationID = newID
	Infinity_InstanceAnimation(templateName, nil, x, y, w, h, nil, nil)
	currentAnimationID = oldAnimationID

	return instanceEntry
end

function B3Spell_DestroyInstances(menuName)
	for templateName, entry in pairs(B3Spell_InstanceIDs[menuName] or {}) do
		for i = 1, entry.maxID, 1 do
			Infinity_DestroyAnimation(templateName, i)
		end
		entry.maxID = 0
		entry.instanceData = {}
	end
end

----------------------
-- Global Variables --
----------------------

---------------
-- Constants --
---------------

B3Spell_CheatMode = false

B3Spell_Modes = {
	["Normal"]    = 0,
	["Innate"]    = 1,
	["Quick"]     = 2,
	["Opcode214"] = 3,
}

B3Spell_ForbiddenTransferModes = {
	[B3Spell_Modes.Quick] = true,
	[B3Spell_Modes.Opcode214] = true,
}

B3Spell_FillFunctions = {
	[B3Spell_Modes.Normal]    = B3Spell_FillFromMemorized,
	[B3Spell_Modes.Innate]    = B3Spell_FillFromMemorized,
	[B3Spell_Modes.Quick]     = B3Spell_FillFromMemorized,
	[B3Spell_Modes.Opcode214] = B3Spell_FillFromMemorized,
}

B3Spell_CastFunctions = {
	[B3Spell_Modes.Normal]    = B3Spell_CastResref,
	[B3Spell_Modes.Innate]    = B3Spell_CastResref,
	[B3Spell_Modes.Quick]     = B3Spell_SetQuickSlotToResref,
	[B3Spell_Modes.Opcode214] = B3Spell_CastResrefInternal,
}

B3Spell_CheatFillFunctions = {
	[B3Spell_Modes.Normal]    = B3Spell_FillFromKnown,
	[B3Spell_Modes.Innate]    = B3Spell_FillFromKnown,
	[B3Spell_Modes.Quick]     = B3Spell_FillFromMemorized,
	[B3Spell_Modes.Opcode214] = B3Spell_FillFromMemorized,
}

B3Spell_CheatCastFunctions = {
	[B3Spell_Modes.Normal]    = EEex_PlayerCastResrefNoDec,
	[B3Spell_Modes.Innate]    = EEex_PlayerCastResrefNoDec,
	[B3Spell_Modes.Quick]     = B3Spell_SetQuickSlotToResref,
	[B3Spell_Modes.Opcode214] = B3Spell_CastResrefInternal,
}

B3Spell_InfoModes = {
	["Abilities"]   = 0,
	["BelowSpells"] = 1,
	["Spells"]      = 2,
	["AboveSpells"] = 3,
}

B3Spell_InfoModeIcons = {
	[B3Spell_InfoModes.Abilities]   = {"GUIBTACT", 38},
	[B3Spell_InfoModes.BelowSpells] = {"GUIBTACT", 52},
	[B3Spell_InfoModes.AboveSpells] = {"GUIBTACT", 53},
}

B3Spell_SlotSizeHardMinimum       = 5
B3Spell_SlotSizeHardMaximum       = 52
B3Spell_SlotSizeAlwaysOpenMinimum = 36
B3Spell_SlotsGapX                 = 1
B3Spell_SlotsGapY                 = 2
B3Spell_SlotsGapYFlowover         = 1

-------------
-- Options --
-------------

B3Spell_AlwaysOpen                    = Infinity_GetINIValue('Bubbs Spell Menu Extended', 'Always Open',                      0)
B3Spell_AutoPause                     = Infinity_GetINIValue('Bubbs Spell Menu Extended', 'Auto-Pause',                       1)
B3Spell_AutoFocusSearchBar            = Infinity_GetINIValue('Bubbs Spell Menu Extended', 'Automatically Focus Search Bar',   1)
B3Spell_AutomaticallyOptimizeSlotSize = Infinity_GetINIValue('Bubbs Spell Menu Extended', 'Automatically Optimize Slot Size', 1)
B3Spell_DarkenBackground              = Infinity_GetINIValue('Bubbs Spell Menu Extended', 'Darken Background',                0)
B3Spell_DisableControlBar             = Infinity_GetINIValue('Bubbs Spell Menu Extended', 'Disable Control Bar',              0)
B3Spell_DisableSearchBar              = Infinity_GetINIValue('Bubbs Spell Menu Extended', 'Disable Search Bar',               0)
-- 0 = Left, 1 = Center, 2 = Right
B3Spell_HorizontalAlignment           = Infinity_GetINIValue('Bubbs Spell Menu Extended', 'Horizontal Alignment',             1)
B3Spell_IgnoreSpecialAbilities        = Infinity_GetINIValue('Bubbs Spell Menu Extended', 'Ignore Special Abilities',         0)
B3Spell_Modal                         = Infinity_GetINIValue('Bubbs Spell Menu Extended', 'Modal',                            1)
B3Spell_MoveSlotHeadersToTheRight     = Infinity_GetINIValue('Bubbs Spell Menu Extended', 'Move Slot Headers To The Right',   0)
B3Spell_ShowKeyBindings               = Infinity_GetINIValue('Bubbs Spell Menu Extended', 'Show Key Bindings',                1)
B3Spell_SlotsAreaX                    = Infinity_GetINIValue('Bubbs Spell Menu Extended', 'Slots Area X',                    -1)
B3Spell_SlotsAreaY                    = Infinity_GetINIValue('Bubbs Spell Menu Extended', 'Slots Area Y',                    -1)
B3Spell_SlotsAreaW                    = Infinity_GetINIValue('Bubbs Spell Menu Extended', 'Slots Area W',                    -1)
B3Spell_SlotsAreaH                    = Infinity_GetINIValue('Bubbs Spell Menu Extended', 'Slots Area H',                    -1)
-- 0 = Top, 1 = Center, 2 = Bottom
B3Spell_VerticalAlignment             = Infinity_GetINIValue('Bubbs Spell Menu Extended', 'Vertical Alignment',               1)

function B3Spell_SetSlotsArea(x, y, w, h)
	B3Spell_SlotsAreaX = x
	B3Spell_SlotsAreaY = y
	B3Spell_SlotsAreaW = w
	B3Spell_SlotsAreaH = h
	Infinity_SetINIValue("Bubbs Spell Menu Extended", "Slots Area X", B3Spell_SlotsAreaX)
	Infinity_SetINIValue("Bubbs Spell Menu Extended", "Slots Area Y", B3Spell_SlotsAreaY)
	Infinity_SetINIValue("Bubbs Spell Menu Extended", "Slots Area W", B3Spell_SlotsAreaW)
	Infinity_SetINIValue("Bubbs Spell Menu Extended", "Slots Area H", B3Spell_SlotsAreaH)
end

if B3Spell_SlotsAreaX == -1 or B3Spell_SlotsAreaY == -1 or B3Spell_SlotsAreaW == -1 or B3Spell_SlotsAreaH == -1 then
	local screenW, screenH = Infinity_GetScreenSize()
	B3Spell_SetSlotsArea(0, 0, screenW, screenH)
end

-----------
-- State --
-----------

B3Spell_Mode         = B3Spell_Modes.Normal
B3Spell_PreviousMode = B3Spell_Mode
B3Spell_SpriteID     = nil

B3Spell_ActionbarDisable     = false
B3Spell_PausedOnOpen         = false
B3Spell_SlotsSuppressOnOpen  = false
B3Spell_SlotsSuppressOnClose = false

B3Spell_SearchEdit             = ""
B3Spell_OldSearchEdit          = ""
B3Spell_AutoFocusSearchBarTick = -1

B3Spell_SpellListInfo         = {}
B3Spell_SpellResrefToData     = {}
B3Spell_KeyToSpellData        = {}
B3Spell_FilteredSpellListInfo = {}
B3Spell_SlotRowInfo           = {}
B3Spell_QuickSpellData        = nil

B3Spell_SlotSizeMinimum = B3Spell_AlwaysOpen == 1 and B3Spell_SlotSizeAlwaysOpenMinimum or B3Spell_SlotSizeHardMinimum
B3Spell_SlotSizeMaximum = 52
B3Spell_SlotSize        = 52
B3Spell_SlotSizeSlider  = B3Spell_SlotSize - B3Spell_SlotSizeMinimum

function B3Spell_SetSlotSizeMinimum(newVal)
	B3Spell_SlotSizeMinimum = math.max(B3Spell_SlotSizeHardMinimum, newVal)
	B3Spell_SlotSize = math.max(B3Spell_SlotSizeMinimum, B3Spell_SlotSize)
	B3Spell_SlotSizeSlider = B3Spell_SlotSize - B3Spell_SlotSizeMinimum
end

function B3Spell_SetSlotSizeMaximum(newVal)
	B3Spell_SlotSizeMaximum = math.min(newVal, B3Spell_SlotSizeHardMaximum)
	B3Spell_SlotSize = math.min(B3Spell_SlotSize, B3Spell_SlotSizeMaximum)
	B3Spell_SlotSizeSlider = B3Spell_SlotSize - B3Spell_SlotSizeMinimum
end

B3Spell_SlotsAvailable    = nil
B3Spell_LinesAvailable    = nil
B3Spell_UsedVerticalSpace = nil

-------------------------
-- Menu Initialization --
-------------------------

function B3Spell_LaunchSpellMenu(mode, spriteID)

	if Infinity_IsMenuOnStack("B3Spell_Menu") then

		if spriteID == B3Spell_SpriteID and mode == B3Spell_Mode then
			-- Attempting to launch the same mode again
			return
		end

		-- Refresh menu
		B3Spell_PreviousMode = B3Spell_Mode
		B3Spell_Mode = mode
		B3Spell_SpriteID = spriteID
		B3Spell_RefreshMenu()
	else

		if Infinity_IsMenuOnStack("B3Spell_Menu_Options") or Infinity_IsMenuOnStack("B3Spell_Menu_SelectSlotArea") then
			-- Don't allow the spell menu to open while the options panel is being displayed...
			return
		end

		if mode ~= B3Spell_Mode then
			-- Starting a new mode
			B3Spell_PreviousMode = B3Spell_Mode
			B3Spell_Mode = mode
		end

		B3Spell_SpriteID = spriteID
		Infinity_PushMenu("B3Spell_Menu")
	end
end

function B3Spell_RefreshMenu()
	B3Spell_FillSpellListInfo()
	B3Spell_InitializeSlots()
end

function B3Spell_GetTransferMode(spriteID)
	return (spriteID == B3Spell_SpriteID or not B3Spell_ForbiddenTransferModes[B3Spell_Mode])
		and B3Spell_Mode        -- Opening the previous mode
		or B3Spell_Modes.Normal -- Previous mode was forbidden, fallback to normal...
end

B3Spell_KeyBindingCategory = {
	["PRIEST_SPELLS"] = 5,
	["MAGE_SPELLS"] = 6,
}

function B3Spell_GetKeyBindingName(category, keybinding)
	local toReturn = ""
	local name = keybinding[4]
	if category < 5 then
		toReturn = t(name)
		if toReturn == name then
			toReturn = Infinity_FetchString(name)
		end
	else
		toReturn = Infinity_FetchString(name)
	end
	return toReturn
end

function B3Spell_GetKeyBindingKeyName(key)
	return key >= 33 and key <= 126 and string.format("%c", key) or t("SDL_"..key)
end

function B3Spell_CacheSpellNameToKeyBindings()
	local spellNameToKey = {}
	for _, category in ipairs({
		B3Spell_KeyBindingCategory.PRIEST_SPELLS,
		B3Spell_KeyBindingCategory.MAGE_SPELLS
	})
	do
		for _, keybinding in ipairs(keybindings[category]) do
			local key = keybinding[6]
			local keybindingName = B3Spell_GetKeyBindingName(category, keybinding)
			if not spellNameToKey[keybindingName] then
				spellNameToKey[keybindingName] = key
			end
		end
	end
	return spellNameToKey
end

-- Fills: B3Spell_SlotRowInfo
function B3Spell_FillSlotRowInfo()

	B3Spell_SlotRowInfo = {}
	local flowoverLinesCounter = B3Spell_LinesAvailable - #B3Spell_FilteredSpellListInfo

	for i = 1, #B3Spell_FilteredSpellListInfo, 1 do

		-- Number of spells(slots) I want to display for this spell level
		local spellCount = #B3Spell_FilteredSpellListInfo[i]

		-- There are actually spells in this level
		if spellCount > 0 then

			-- B3Spell_FilteredSpellListInfo should be accessed starting from this offset for this slot row
			local currentSpellAccessStart = 0
			-- The current row I'm on to completely display this spell level
			local levelRowCount = 0

			while true do

				levelRowCount = levelRowCount + 1
				local spellLevelInfo = {
					["originatingRow"] = i,
					["slotCount"] = -1, -- Filled down below
					["scrollBase"] = currentSpellAccessStart,
					["scrollOffset"] = 0,
					["isFlowover"] = false, -- (Possibly) Updated down below
					["hasArrows"] = false,  -- (Possibly) Updated down below
					["slotInstances"] = {},
					["visibleSpellResrefs"] = {},
				}

				-- The current spell level has taken more than one row to display
				if levelRowCount > 1 then

					-- I don't have any more flowover lines to spare
					if flowoverLinesCounter < 1 then

						-- The previous slot row has to carry the burden, as I have no more space
						local previousSlotRow = B3Spell_SlotRowInfo[#B3Spell_SlotRowInfo]
						previousSlotRow.slotCount = previousSlotRow.slotCount + spellCount
						previousSlotRow.hasArrows = true

						-- Slot row over
						break
					end

					spellLevelInfo.isFlowover = true
					flowoverLinesCounter = flowoverLinesCounter - 1
				end

				-- There aren't enough horizontal slots available to display all of this spell level
				if spellCount >= B3Spell_SlotsAvailable then

					-- Use max slot count for this slot row
					spellLevelInfo.slotCount = B3Spell_SlotsAvailable
					table.insert(B3Spell_SlotRowInfo, spellLevelInfo)

					-- The next slot row should access B3Spell_FilteredSpellListInfo starting from this offset
					currentSpellAccessStart = currentSpellAccessStart + B3Spell_SlotsAvailable - 1

					-- Subtract out how many spells I just displayed
					spellCount = spellCount - B3Spell_SlotsAvailable + 1

				-- There *was* enough horizontal slots available to display all of this spell level
				else

					-- Match slot count to how many spells there were in this spell level
					spellLevelInfo.slotCount = spellCount + 1
					table.insert(B3Spell_SlotRowInfo, spellLevelInfo)

					-- Slot row over
					break
				end
			end
		end
	end
end

function B3Spell_InitializeSlots()

	-- Recalculate the maximum slot size that can fit at least 1 line per category, and, if needed, that can fit arrows.
	-- This is needed to prevent smaller-than-normal slot areas from allowing slot sizes that cause the slots to go off-screen.
	B3Spell_CalculateMaxSlotSize()

	if B3Spell_AutomaticallyOptimizeSlotSize == 1 then
		-- Shrink B3Spell_SlotSize down from 52 until all spells fit on the screen,
		-- (calls B3Spell_CalculateLines() internally)
		B3Spell_OptimizeSlotSize()
	else
		-- Calculate rows based on current B3Spell_SlotSize
		B3Spell_CalculateLines()
	end

	-- Now that the slot layout has been calculated by the above,
	-- fill in the exact slots configuration for instantiation.
	B3Spell_FillSlotRowInfo()

	local longestSlotCount = B3Spell_GetLongestSlotCount()

	-- Calculate slotsRenderXOffset
	local slotsRenderXOffset = nil
	if B3Spell_HorizontalAlignment == 0 then
		slotsRenderXOffset = B3Spell_SlotsAreaX
	else
		local horizontalAvailableSpace = B3Spell_GetAvailableHorizontalSpace()
		local horizontalAreaUsed = longestSlotCount * (B3Spell_SlotSize + B3Spell_SlotsGapX) - B3Spell_SlotsGapX
		local horizontalMarginSpace = horizontalAvailableSpace - horizontalAreaUsed
		if B3Spell_HorizontalAlignment == 1 then
			slotsRenderXOffset = B3Spell_SlotsAreaX + (horizontalMarginSpace / 2)
		else
			slotsRenderXOffset = B3Spell_SlotsAreaX + horizontalMarginSpace
		end
	end

	-- Calculate currentYOffset
	local currentYOffset = nil
	if B3Spell_VerticalAlignment == 0 then
		currentYOffset = math.max(B3Spell_GetMinY(), B3Spell_SlotsAreaY)
	else
		local verticalMarginSpace = B3Spell_GetAvailableVerticalSpace() - B3Spell_UsedVerticalSpace
		if B3Spell_VerticalAlignment == 1 then
			currentYOffset = math.max(B3Spell_GetMinY(), B3Spell_SlotsAreaY) + (verticalMarginSpace / 2)
		else
			currentYOffset = math.max(B3Spell_GetMinY(), B3Spell_SlotsAreaY) + verticalMarginSpace
		end
	end

	-- Destroy all the slots I've already spawned
	B3Spell_DestroyInstances("B3Spell_Menu")

	if B3Spell_DisableControlBar == 0 then
		B3Spell_CreateNamedSlotBamButton("B3Spell_Menu_FilterSlotsMage",   "GUIBTACT", 68, B3Spell_Tooltip_Mage_Spells,   B3Spell_Menu_FilterSlotsMage_Action,   0, 0, 52, 52)
		B3Spell_CreateNamedSlotBamButton("B3Spell_Menu_FilterSlotsAll",    "GUIBTACT", 12, B3Spell_Tooltip_All_Spells,    B3Spell_Menu_FilterSlotsAll_Action,    0, 0, 52, 52)
		B3Spell_CreateNamedSlotBamButton("B3Spell_Menu_FilterSlotsCleric", "GUIBTACT", 70, B3Spell_Tooltip_Cleric_Spells, B3Spell_Menu_FilterSlotsCleric_Action, 0, 0, 52, 52)
	end

	if B3Spell_DisableControlBar == 0 then

		B3Spell_CenterItemsX(
		{
			{ ['name'] = 'B3Spell_Menu_FilterSlotsMage',        ['x'] = 0  },
			{ ['name'] = 'B3Spell_Menu_FilterSlotsMage_Slot',   ['x'] = 0  },
			{ ['name'] = 'B3Spell_Menu_FilterSlotsAll',         ['x'] = 52 },
			{ ['name'] = 'B3Spell_Menu_FilterSlotsAll_Slot',    ['x'] = 52 },
			{ ['name'] = 'B3Spell_Menu_FilterSlotsCleric',      ['x'] = 104 },
			{ ['name'] = 'B3Spell_Menu_FilterSlotsCleric_Slot', ['x'] = 104 },
			{
				['name'] = 'B3Spell_Menu_SlotSizeSlider',
				['x'] = 156,
				['y'] = B3Spell_Menu_SlotSizeSlider_Y,
				['width'] = B3Spell_Menu_SlotSizeSlider_W,
				['height'] = B3Spell_Menu_SlotSizeSlider_H,
			},
			{
				['name'] = 'B3Spell_Menu_OptimizeSlotSize',
				['x'] = 156 + B3Spell_Menu_SlotSizeSlider_W,
				['y'] = B3Spell_Menu_OptimizeSlotSize_Y,
				['width'] = B3Spell_Menu_OptimizeSlotSize_W,
				['height'] = B3Spell_Menu_OptimizeSlotSize_H,
			},
		})
	end

	local searchBackgroundTop = B3Spell_DisableControlBar == 0 and 57 or (55 - B3Spell_Menu_SearchBackground_H) / 2
	B3Spell_CenterItemsX(
	{
		{
			['name'] = 'B3Spell_Menu_SearchBackground',
			['y'] = searchBackgroundTop,
			['width'] = B3Spell_Menu_SearchBackground_W,
			['height'] = B3Spell_Menu_SearchBackground_H,
		},
		{
			['name'] = 'B3Spell_Menu_Search',
			['y'] = searchBackgroundTop + B3Spell_Menu_Search_YOffset,
			['width'] = B3Spell_Menu_SearchBackground_W,
		}
	})

	B3Spell_QuickSpellData = nil
	local foundGreen = B3Spell_DisableSearchBar == 1
	local numSequence = B3Spell_GetNumSequence()

	local slotRowCount = #B3Spell_SlotRowInfo

	for row = 1, slotRowCount, 1 do

		local currentXOffset = slotsRenderXOffset
		local slotRowInfo = B3Spell_SlotRowInfo[row]
		local rowInfo = B3Spell_FilteredSpellListInfo[slotRowInfo.originatingRow]
		local rowInfoMode = rowInfo.infoMode

		local spellSlotCount = slotRowInfo.slotCount
		if spellSlotCount > B3Spell_SlotsAvailable then spellSlotCount = B3Spell_SlotsAvailable end
		-- Always going to leave room for the spell level
		spellSlotCount = spellSlotCount - 1

		local createSlotHeader = function()
			if not slotRowInfo.isFlowover then
				if rowInfoMode == B3Spell_InfoModes.Spells then
					B3Spell_CreateBam("B3NUM", numSequence, rowInfo.spellLevel - 1, currentXOffset, currentYOffset, B3Spell_SlotSize, B3Spell_SlotSize)
				else
					local iconDef = B3Spell_InfoModeIcons[rowInfoMode]
					B3Spell_CreateSlotBamBam(iconDef[1], 0, iconDef[2], currentXOffset, currentYOffset, B3Spell_SlotSize, B3Spell_SlotSize)
				end
			end
			currentXOffset = currentXOffset + B3Spell_SlotSize + B3Spell_SlotsGapX
		end

		if B3Spell_MoveSlotHeadersToTheRight == 0 then
			createSlotHeader()
		else
			local numBlankSlots = longestSlotCount - spellSlotCount - 1
			currentXOffset = currentXOffset + numBlankSlots * (B3Spell_SlotSize + B3Spell_SlotsGapX)
		end

		-- Spawn Left Arrows
		if slotRowInfo.hasArrows then
			local arrowData = B3Spell_CreateSlotBamButton("GUIBTACT", 64, "", false, B3Spell_ArrowLeft, currentXOffset, currentYOffset, B3Spell_SlotSize, B3Spell_SlotSize)
			arrowData.row = row
			-- Spawn 2 fewer spell slots, (to make room for the arrows)
			spellSlotCount = spellSlotCount - 2
			currentXOffset = currentXOffset + B3Spell_SlotSize + B3Spell_SlotsGapX
		end

		if rowInfoMode == B3Spell_InfoModes.Abilities then
			for column = 1, spellSlotCount, 1 do
				local data = B3Spell_GetDataForSlot(row, column)
				local abilityData = B3Spell_CreateSlotBamButton(data.bam, data.frame, data.tooltip, data.disableTint, data.func, currentXOffset, currentYOffset, B3Spell_SlotSize, B3Spell_SlotSize)
				slotRowInfo.slotInstances[column] = abilityData
				currentXOffset = currentXOffset + B3Spell_SlotSize + B3Spell_SlotsGapX
			end
		else
			for column = 1, spellSlotCount, 1 do

				local data = B3Spell_GetDataForSlot(row, column)

				-- Initialize the visible spell resrefs associated with the row
				table.insert(slotRowInfo.visibleSpellResrefs, data.spellResref)

				if not foundGreen and not data.spellDisabled then
					local slotData = B3Spell_CreateSpell(data, true, currentXOffset, currentYOffset, B3Spell_SlotSize, B3Spell_SlotSize)
					slotRowInfo.slotInstances[column] = slotData
					B3Spell_QuickSpellData = data
					foundGreen = true
				else
					local slotData = B3Spell_CreateSpell(data, false, currentXOffset, currentYOffset, B3Spell_SlotSize, B3Spell_SlotSize)
					slotRowInfo.slotInstances[column] = slotData
				end
				currentXOffset = currentXOffset + B3Spell_SlotSize + B3Spell_SlotsGapX
			end
		end

		-- Spawn Right Arrows
		if slotRowInfo.hasArrows then
			local arrowData = B3Spell_CreateSlotBamButton("GUIBTACT", 66, "", false, B3Spell_ArrowRight, currentXOffset, currentYOffset, B3Spell_SlotSize, B3Spell_SlotSize)
			arrowData.row = row
			currentXOffset = currentXOffset + B3Spell_SlotSize + B3Spell_SlotsGapX
		end

		if B3Spell_MoveSlotHeadersToTheRight == 1 then
			createSlotHeader()
		end

		-- Move to next row
		local nextSlotLevelInfo = B3Spell_SlotRowInfo[row + 1]
		if nextSlotLevelInfo and nextSlotLevelInfo.isFlowover then
			currentYOffset = currentYOffset + B3Spell_SlotSize + B3Spell_SlotsGapYFlowover
		else
			currentYOffset = currentYOffset + B3Spell_SlotSize + B3Spell_SlotsGapY
		end
	end

	-- Creating the options button as a template so that it renders above the slots. If the user is careless they can cover the options
	-- button by moving the slots area when the control bar is disabled, (which allows the slots to be placed near the top of the screen).
	B3Spell_CreateInstance("B3Spell_Menu", "B3Spell_Menu_TEMPLATE_OptionsButton", Infinity_GetScreenSize() - B3Spell_SidebarWidth - 74, nil, nil, nil)
end

------------------
-- Slot Details --
------------------

function B3Spell_GetSlotInfoOffset(slotRow, slotColumn)
	local slotInfo = B3Spell_SlotRowInfo[slotRow]
	return slotInfo.scrollBase + slotInfo.scrollOffset + slotColumn
end

function B3Spell_GetDataForSlot(slotRow, slotColumn)
	local originatingRow = B3Spell_SlotRowInfo[slotRow].originatingRow
	return B3Spell_FilteredSpellListInfo[originatingRow][B3Spell_GetSlotInfoOffset(slotRow, slotColumn)]
end

function B3Spell_GetLongestSlotCount()
	local maxLength = -1
	for i = 1, #B3Spell_SlotRowInfo, 1 do
		local length = B3Spell_SlotRowInfo[i].slotCount
		if length > maxLength then maxLength = length end
	end
	if maxLength > B3Spell_SlotsAvailable then maxLength = B3Spell_SlotsAvailable end
	return maxLength
end

---------------------------
-- Slot Area Calculation --
---------------------------

-- Fills:
--     B3Spell_SlotSizeMaximum
--     B3Spell_SlotSize
--     B3Spell_SlotSizeSlider
function B3Spell_CalculateMaxSlotSize()

	-- Ensure categories can display (header + left arrow + slot + right arrow) if needed
	local longestCategory = 0
	for _, category in ipairs(B3Spell_FilteredSpellListInfo) do
		local categoryLen = #category
		if categoryLen > longestCategory then
			longestCategory = categoryLen
		end
	end
	local minNeededSlotsHorizontally = math.min(longestCategory + 1, 4)
	local maxSlotSizeForCategoryX = math.floor((B3Spell_GetAvailableHorizontalSpace() + B3Spell_SlotsGapX) / minNeededSlotsHorizontally - B3Spell_SlotsGapX)

	-- Ensure at least one line can be displayed for every category
	local maxSlotSizeForCategoryY = math.floor((B3Spell_GetAvailableVerticalSpace() + B3Spell_SlotsGapY) / #B3Spell_FilteredSpellListInfo - B3Spell_SlotsGapY)

	-- Set max slot size
	local maxSlotSize = math.min(maxSlotSizeForCategoryX, maxSlotSizeForCategoryY)
	B3Spell_SetSlotSizeMaximum(maxSlotSize)
end

-- Fills (via proxy of B3Spell_CalculateLines()):
--     B3Spell_SlotsAvailable
--     B3Spell_LinesAvailable
--     B3Spell_UsedVerticalSpace
function B3Spell_OptimizeSlotSize()

	if B3Spell_AlwaysOpen == 0 then
		for tempSlotSize = B3Spell_SlotSizeMaximum, B3Spell_SlotSizeMinimum, -1 do
			B3Spell_SlotSize = tempSlotSize
			if B3Spell_CalculateLines() then break end
		end
	else

		-- The "Always Open" mode needs to be more conservative with how willing it is to
		-- grow vertically. The following only allows larger slots if the spell menu fits
		-- within 50% of the available vertical space. Otherwise it shrinks the slots
		-- down to a predetermined minimum, stopping when it finds the largest slot size
		-- that fits.

		local desiredUsedVerticalSpace = B3Spell_GetAvailableVerticalSpace() / 2

		for tempSlotSize = B3Spell_SlotSizeMaximum, B3Spell_SlotSizeMinimum, -1 do
			B3Spell_SlotSize = tempSlotSize
			if B3Spell_CalculateLines() and B3Spell_UsedVerticalSpace <= desiredUsedVerticalSpace then
				break
			end
		end
	end

	B3Spell_SlotSizeSlider = B3Spell_SlotSize - B3Spell_SlotSizeMinimum
end

-- Fills:
--     B3Spell_SlotsAvailable
--     B3Spell_LinesAvailable
--     B3Spell_UsedVerticalSpace
function B3Spell_CalculateLines()

	local verticalAreaAvailable = B3Spell_GetAvailableVerticalSpace()
	local numCategories = #B3Spell_FilteredSpellListInfo

	local totalLinesNeeded = 0
	-- Ignore the first attempt to add padding...
	local numGaps = -1
	local numFlowoverGaps = 0

	local calcUsedSpace = function()
		return totalLinesNeeded * B3Spell_SlotSize + numGaps * B3Spell_SlotsGapY + numFlowoverGaps * B3Spell_SlotsGapYFlowover
	end

	-- Check if I've exceeded the available vertical space.
	-- If I have, return true and update the relevant global state.
	local lastUsedSpace = 0
	local checkSpace = function()
		local usedSpace = calcUsedSpace()
		if verticalAreaAvailable >= usedSpace then
			lastUsedSpace = usedSpace
			return false
		else
			-- There wasn't enough space to fit everything, settle with the maximum line amount.
			totalLinesNeeded = totalLinesNeeded - 1
			numGaps = numCategories - 1
			numFlowoverGaps = math.min(numFlowoverGaps, math.max(0, totalLinesNeeded - numCategories))
			B3Spell_LinesAvailable = totalLinesNeeded
			B3Spell_UsedVerticalSpace = calcUsedSpace()
			return true
		end
	end

	-- Calculate the number of slots that I can fit horizontally across the screen
	local horizontalAvailableSpace = B3Spell_GetAvailableHorizontalSpace()
	B3Spell_SlotsAvailable = math.floor((horizontalAvailableSpace + B3Spell_SlotsGapX) / (B3Spell_SlotSize + B3Spell_SlotsGapX))

	for _, category in ipairs(B3Spell_FilteredSpellListInfo) do

		local spellCountForCategory = #category

		-- Update local state with a new line
		local processLine = function(gapSize)
			totalLinesNeeded = totalLinesNeeded + 1
			spellCountForCategory = spellCountForCategory - B3Spell_SlotsAvailable + 1
		end

		if spellCountForCategory > 0 then

			-- Process normal line
			numGaps = numGaps + 1
			processLine()
			if checkSpace() then return false end

			-- Process flowover lines
			while spellCountForCategory > 0 do
				numFlowoverGaps = numFlowoverGaps + 1
				processLine()
				if checkSpace() then return false end
			end
		end
	end

	-- There was enough space to fit all spells on the screen!
	B3Spell_LinesAvailable = totalLinesNeeded
	B3Spell_UsedVerticalSpace = lastUsedSpace
	return true
end

function B3Spell_GetMinY()
	local minY = 0
	if B3Spell_DisableControlBar == 0 then minY = minY + 52 + 5 end
	if B3Spell_DisableSearchBar == 0 then minY = minY + B3Spell_Menu_SearchBackground_H + 5 end
	return math.max(minY, B3Spell_SlotsAreaY)
end

function B3Spell_GetAvailableHorizontalSpace()
	return B3Spell_SlotsAreaW
end

function B3Spell_GetAvailableVerticalSpace()
	local diff = B3Spell_GetMinY() - B3Spell_SlotsAreaY
	if diff > 0 then
		return B3Spell_SlotsAreaH - diff
	else
		return B3Spell_SlotsAreaH
	end
end

-------------------------------------------------------------------
-- Filling B3Spell_SpellListInfo / B3Spell_FilteredSpellListInfo --
-------------------------------------------------------------------

-- Fill B3Spell_FilteredSpellListInfo from B3Spell_SpellListInfo with only mage spells.
function B3Spell_FilterSpellListInfoMage()
	B3Spell_FilteredSpellListInfo = {}
	for i = 1, #B3Spell_SpellListInfo, 1 do
		local infoRow = B3Spell_SpellListInfo[i]
		local currentLevel = {
			["infoMode"] = infoRow.infoMode,
			["spellLevel"] = infoRow.spellLevel,
		}
		for j = 1, #infoRow, 1 do
			local spell = infoRow[j]
			if spell.spellType == 1 then
				table.insert(currentLevel, spell)
			end
		end
		if #currentLevel > 0 then
			table.insert(B3Spell_FilteredSpellListInfo, currentLevel)
		end
	end
	B3Spell_SortFilteredSpellListInfo()
	B3Spell_InitializeSlots()
end

-- Fill B3Spell_FilteredSpellListInfo from B3Spell_SpellListInfo.
function B3Spell_FilterSpellListInfoAll()
	B3Spell_FilteredSpellListInfo = B3Spell_SpellListInfo
	B3Spell_SortFilteredSpellListInfo()
	B3Spell_InitializeSlots()
end

-- Fill B3Spell_FilteredSpellListInfo from B3Spell_SpellListInfo with only cleric spells.
function B3Spell_FilterSpellListInfoCleric()
	B3Spell_FilteredSpellListInfo = {}
	for i = 1, #B3Spell_SpellListInfo, 1 do
		local infoRow = B3Spell_SpellListInfo[i]
		local currentLevel = {
			["infoMode"] = infoRow.infoMode,
			["spellLevel"] = infoRow.spellLevel,
		}
		for j = 1, #infoRow, 1 do
			local spell = infoRow[j]
			if spell.spellType == 2 then
				table.insert(currentLevel, spell)
			end
		end
		if #currentLevel > 0 then
			table.insert(B3Spell_FilteredSpellListInfo, currentLevel)
		end
	end
	B3Spell_SortFilteredSpellListInfo()
	B3Spell_InitializeSlots()
end

-- Fill B3Spell_FilteredSpellListInfo from B3Spell_SpellListInfo with only spells that contain fragment of B3Spell_SearchEdit.
function B3Spell_FilterSpellListInfoSearch()
	B3Spell_FilteredSpellListInfo = {}
	for i = 1, #B3Spell_SpellListInfo, 1 do
		local infoRow = B3Spell_SpellListInfo[i]
		if infoRow.infoMode ~= B3Spell_InfoModes.Abilities then
			local currentLevel = {
				["infoMode"] = infoRow.infoMode,
				["spellLevel"] = infoRow.spellLevel,
			}
			for j = 1, #infoRow, 1 do
				local spell = infoRow[j]
				if string.find(string.lower(spell.spellName), string.lower(B3Spell_SearchEdit), 1, true) ~= nil then
					table.insert(currentLevel, spell)
				end
			end
			if #currentLevel > 0 then
				table.insert(B3Spell_FilteredSpellListInfo, currentLevel)
			end
		end
	end
	B3Spell_SortFilteredSpellListInfo()
	B3Spell_InitializeSlots()
end

-- Perform alphanumeric sort on B3Spell_FilteredSpellListInfo levels according to spell names.
function B3Spell_SortFilteredSpellListInfo()
	for i = 1, #B3Spell_FilteredSpellListInfo, 1 do
		B3Spell_AlphanumericSortSpellInfo(B3Spell_FilteredSpellListInfo[i])
	end
end

-- Perform alphanumeric sort on B3Spell_FilteredSpellListInfo level according to spell names.
function B3Spell_AlphanumericSortSpellInfo(o)
	local conv = function(s)
		local res, dot = "", ""
		for n, m, c in tostring(s):gmatch("(0*(%d*))(.?)") do
			if n == "" then
				dot, c = "", dot..c
			else
				res = res..(dot == "" and ("%03d%s"):format(#m, m) or "."..n)
				dot, c = c:match("(%.?)(.*)")
			end
			res = res..c:gsub(".", "\0%0")
		end
		return res
	end
	if o.infoMode == B3Spell_InfoModes.Abilities then
		table.sort(o, function(a, b)
			local ca, cb = conv(a.tooltip), conv(b.tooltip)
			return ca <= cb and a.tooltip < b.tooltip
		end)
	else
		table.sort(o, function(a, b)
			local ca, cb = conv(a.spellName), conv(b.spellName)
			return (a.spellLevel <= b.spellLevel) and (ca <= cb and a.spellName < b.spellName)
		end)
	end
	return o
end

---------------------------
-- B3_Menu Row Scrolling --
---------------------------

function B3Spell_DecrementRowOffset(slotRow)
	local rowOffset = B3Spell_SlotRowInfo[slotRow].scrollOffset - B3Spell_SlotsAvailable + 3
	if rowOffset < 0 then rowOffset = 0 end
	B3Spell_SlotRowInfo[slotRow].scrollOffset = rowOffset
end

function B3Spell_IncrementRowOffset(slotRow)
	local rowOffset = B3Spell_SlotRowInfo[slotRow].scrollOffset + B3Spell_SlotsAvailable - 3
	local maxOffset = B3Spell_SlotRowInfo[slotRow].slotCount - B3Spell_SlotsAvailable + 2
	if rowOffset > maxOffset then rowOffset = maxOffset end
	B3Spell_SlotRowInfo[slotRow].scrollOffset = rowOffset
end

function B3Spell_UpdateRow(slotRow)

	local slotRowInfo = B3Spell_SlotRowInfo[slotRow]
	local rowInfoMode = B3Spell_FilteredSpellListInfo[slotRowInfo.originatingRow].infoMode

	if rowInfoMode == B3Spell_InfoModes.Abilities then
		for slotColumn, slotData in ipairs(slotRowInfo.slotInstances) do
			local newSlotData = B3Spell_GetDataForSlot(slotRow, slotColumn)
			local bamButtonInstanceData = B3Spell_InstanceIDs["B3Spell_Menu"]["B3Spell_Menu_TEMPLATE_BamButton"].instanceData
			bamButtonInstanceData[slotData.id] = newSlotData
		end
	else

		-- Clear the iconData references associated with the row (to rebuild below)
		for _, resref in ipairs(slotRowInfo.visibleSpellResrefs) do
			B3Spell_SpellResrefToData[resref].iconData = nil
		end

		-- Clear the visible spell resrefs associated with the row (to rebuild below)
		slotRowInfo.visibleSpellResrefs = {}

		for slotColumn, slotData in ipairs(slotRowInfo.slotInstances) do

			local newSlotData = B3Spell_GetDataForSlot(slotRow, slotColumn)

			-- Rebuild the visible spell resrefs associated with the row
			table.insert(slotRowInfo.visibleSpellResrefs, newSlotData.spellResref)

			local iconData = B3Spell_InstanceIDs["B3Spell_Menu"]["B3Spell_Menu_TEMPLATE_Icon"].instanceData[slotData.pairedIconID]
			slotData.spellData = newSlotData
			iconData.icon = newSlotData.spellIcon
			iconData.count = newSlotData.spellCastableCount

			-- Rebuild the iconData references associated with the row
			B3Spell_SpellResrefToData[newSlotData.spellResref].iconData = iconData
		end
	end
end

function B3Spell_ArrowLeft()
	local slotRow = B3Spell_InstanceIDs["B3Spell_Menu"]["B3Spell_Menu_TEMPLATE_BamButton"].instanceData[instanceId].row
	B3Spell_DecrementRowOffset(slotRow)
	B3Spell_UpdateRow(slotRow)
end

function B3Spell_ArrowRight()
	local slotRow = B3Spell_InstanceIDs["B3Spell_Menu"]["B3Spell_Menu_TEMPLATE_BamButton"].instanceData[instanceId].row
	B3Spell_IncrementRowOffset(slotRow)
	B3Spell_UpdateRow(slotRow)
end

-----------------------
-- Alignment Utility --
-----------------------

function B3Spell_FindGreatestItemEntryX(itemEntries)
	local greatestX = 0
	for _, itemEntry in ipairs(itemEntries) do
		if nameToItem[itemEntry.name] then
			local width = itemEntry.width and itemEntry.width or select(3, Infinity_GetArea(itemEntry.name))
			local itemRightEdge = (itemEntry.x or 0) + width
			if itemRightEdge > greatestX then greatestX = itemRightEdge end
		end
	end
	return greatestX
end

function B3Spell_FindGreatestItemEntryY(itemEntries)
	local greatestY = 0
	for _, itemEntry in ipairs(itemEntries) do
		if nameToItem[itemEntry.name] then
			local height = itemEntry.height and itemEntry.height or select(4, Infinity_GetArea(itemEntry.name))
			local itemBottomEdge = (itemEntry.y or 0) + height
			if itemBottomEdge > greatestY then greatestY = itemBottomEdge end
		end
	end
	return greatestY
end

function B3Spell_CenterItemsX(itemEntries, rectX, rectW)
	rectX = rectX or 0
	rectW = rectW or Infinity_GetScreenSize()
	local greatestX = B3Spell_FindGreatestItemEntryX(itemEntries)
	local centerXStart = rectX + rectW / 2 - greatestX / 2
	for _, itemEntry in ipairs(itemEntries) do
		if nameToItem[itemEntry.name] then
			Infinity_SetArea(itemEntry.name, centerXStart + (itemEntry.x or 0), itemEntry.y, itemEntry.width, itemEntry.height)
		end
	end
end

function B3Spell_AlignItemsRight(itemEntries, rectX, rectW)
	rectX = rectX or 0
	rectW = rectW or Infinity_GetScreenSize()
	local greatestX = B3Spell_FindGreatestItemEntryX(itemEntries)
	local startX = rectX + rectW - greatestX
	for _, itemEntry in ipairs(itemEntries) do
		if nameToItem[itemEntry.name] then
			Infinity_SetArea(itemEntry.name, startX + (itemEntry.x or 0), itemEntry.y, itemEntry.width, itemEntry.height)
		end
	end
end

function B3Spell_CenterItemsXY(names)
	local greatestX = 0
	local greatestY = 0
	for i = 1, #names, 1 do
		local name = names[i]
		local itemRightEdge = name.x + name.width
		if itemRightEdge > greatestX then greatestX = itemRightEdge end
		local itemBottomEdge = name.y + name.height
		if itemBottomEdge > greatestY then greatestY = itemBottomEdge end
	end
	local screenWidth, screenHeight = Infinity_GetScreenSize()
	local centerXStart = screenWidth / 2 - greatestX / 2
	local centerYStart = screenHeight / 2 - greatestY / 2
	for i = 1, #names, 1 do
		local name = names[i]
		Infinity_SetArea(name.name, centerXStart + name.x, centerYStart + name.y, name.width, name.height)
	end
end

------------------------
-- START B3Spell_Menu --
------------------------

------------------
-- General Code --
------------------

B3Spell_LastManualSliderChange = 0
B3Spell_SliderChangeQueued = false

function B3Spell_CastSpellData(spellData)

	local modeBeforeRevert = B3Spell_Mode

	if B3Spell_AlwaysOpen == 0 then
		Infinity_PopMenu("B3Spell_Menu")
	elseif B3Spell_ForbiddenTransferModes[B3Spell_Mode] then
		-- The current mode is temporary and only allows one interaction, revert to the previous mode.
		-- This has to be before `castFunction` is called in case it launches the spell menu.
		B3Spell_LaunchSpellMenu(B3Spell_PreviousMode, B3Spell_SpriteID)
	end

	local castFunction = (B3Spell_CheatMode and B3Spell_CheatCastFunctions or B3Spell_CastFunctions)[modeBeforeRevert]

	if modeBeforeRevert == B3Spell_Modes.Normal then
		castFunction(spellData.spellResref, 2)
	elseif modeBeforeRevert == B3Spell_Modes.Innate then
		castFunction(spellData.spellResref, 4)
	else
		castFunction(spellData.spellResref)
	end

	B3Spell_CheckHighlightModeButton(modeBeforeRevert)
end

function B3Spell_CreateIcon(icon, count, disableTint, x, y, w, h)
	local instanceData = B3Spell_CreateInstance("B3Spell_Menu", "B3Spell_Menu_TEMPLATE_Icon", x, y, w, h)
	instanceData.icon = icon
	instanceData.count = count
	instanceData.disableTint = disableTint
	return instanceData
end

function B3Spell_CreateBam(bam, sequence, frame, x, y, w, h)
	local instanceData = B3Spell_CreateInstance("B3Spell_Menu", "B3Spell_Menu_TEMPLATE_Bam", x, y, w, h)
	instanceData.bam = bam
	instanceData.sequence = sequence
	instanceData.frame = frame
	return instanceData
end

function B3Spell_CreateKeyBindingText(text, x, y)
	local textW, textH
	local pointSize = 1
	repeat
		textW, textH = B3Spell_GetTextWidthHeight("MODESTOM", pointSize, text.." ") -- space for wrapping to get width
		pointSize = pointSize + 1
	until textH >= B3Spell_SlotSize * 1/2
	local instanceData = B3Spell_CreateInstance("B3Spell_Menu", "B3Spell_Menu_TEMPLATE_Text", x + B3Spell_SlotSize * 5/52, y + B3Spell_SlotSize * 2/52, textW, textH)
	instanceData.text = text
	instanceData.color = 0x00FF00
	return instanceData
end

function B3Spell_CreateSlotBam(isGreen, x, y, w, h)

	local slotBam
	local slotSequence
	local slotFrame

	if RgUISkin then
		-- Infinity UI++
		slotBam = isGreen and "B3SLOTG" or "rgdslot"
		slotSequence = RgUISkin
		slotFrame = 0
	else
		slotBam = isGreen and "B3SLOTG" or "B3SLOT"
		slotSequence = 1
		slotFrame = 1
	end

	return B3Spell_CreateBam(slotBam, slotSequence, slotFrame, x, y, w, h)
end

function B3Spell_CreateSlotBamBam(bam, sequence, frame, x, y, w, h)
	if RgUISkin then
		-- Infinity UI++
		B3Spell_CreateSlotBam(false, x, y, w, h)
	end
	return B3Spell_CreateBam(bam, sequence, frame, x, y, w, h)
end

function B3Spell_CreateSpell(data, isGreen, x, y, w, h)

	local slotData = B3Spell_CreateSlotBam(isGreen, x, y, w, h)

	local iconData = B3Spell_CreateIcon(data.spellIcon, data.spellCastableCount, data.spellDisabled, x, y, w, h)
	B3Spell_SpellResrefToData[data.spellResref].iconData = iconData

	if B3Spell_ShowKeyBindings == 1 then
		B3Spell_CreateKeyBindingText(data.spellKeyBindingName, x, y)
	end

	local actionInstance = B3Spell_CreateInstance("B3Spell_Menu", "B3Spell_Menu_TEMPLATE_Action", x, y, w, h)
	actionInstance.spellData = data
	actionInstance.pairedSlotID = slotData.id
	actionInstance.pairedIconID = iconData.id
	actionInstance.isGreen = isGreen
	return actionInstance
end

function B3Spell_UpdateSpellCastableCount(spellResref, countDelta)

	local resrefData = B3Spell_SpellResrefToData[spellResref]
	if not resrefData then
		-- I don't know about this spell, refresh the menu
		B3Spell_RefreshMenu()
		return
	end

	-- Update internal castable count
	local spellData = resrefData.spellData
	local newCastCount = spellData.spellCastableCount + countDelta

	if newCastCount == 0 then
		-- Reinitialize slots if the spell was brought to 0 remaining memorization slots
		B3Spell_RefreshMenu()
		return
	end

	spellData.spellCastableCount = newCastCount

	-- Update displayed castable count
	local iconData = resrefData.iconData
	if iconData ~= nil then
		iconData.count = iconData.count + countDelta
	end
end

function B3Spell_ResetSpellCastableCounts()

	for resref, resrefData in pairs(B3Spell_SpellResrefToData) do

		resrefData.spellData.spellCastableCount = 0

		-- Update displayed castable count
		local iconData = resrefData.iconData
		if iconData ~= nil then
			iconData.count = 0
		end
	end
end

function B3Spell_CreateBamButton(bam, frame, tooltip, disableTint, func, x, y, w, h)
	local instanceData = B3Spell_CreateInstance("B3Spell_Menu", "B3Spell_Menu_TEMPLATE_BamButton", x, y, w, h)
	instanceData.bam = bam
	instanceData.frame = frame
	instanceData.tooltip = tooltip
	instanceData.disableTint = disableTint
	instanceData.func = func
	return instanceData
end

function B3Spell_CreateSlotBamButton(bam, frame, tooltip, disableTint, func, x, y, w, h)
	if RgUISkin then
		-- Infinity UI++
		B3Spell_CreateSlotBam(false, x, y, w, h)
	end
	return B3Spell_CreateBamButton(bam, frame, tooltip, disableTint, func, x, y, w, h)
end

function B3Spell_CreateNamedSlotBamButton(name, bam, frame, tooltip, func, x, y, w, h)

	if RgUISkin then
		-- Infinity UI++
		local instanceData = B3Spell_CreateSlotBam(false, x, y, w, h)
		EEex_Menu_StoreTemplateInstance("B3Spell_Menu", "B3Spell_Menu_TEMPLATE_Bam", instanceData.id, name.."_Slot")
	end

	local instanceData = B3Spell_CreateBamButton(bam, frame, tooltip, false, func, x, y, w, h)
	EEex_Menu_StoreTemplateInstance("B3Spell_Menu", "B3Spell_Menu_TEMPLATE_BamButton", instanceData.id, name)
end

function B3Spell_GetNumSequence()
	if RgUISkin then
		-- Infinity UI++
		return ({
			[0] = 2, -- BG:EE - Dragonspear
			[1] = 4, -- IWD:EE
			[2] = 0, -- BG:EE - Grey Stone
			[3] = 3, -- BG2:EE
		})[RgUISkin]
	else
		return B3Spell_NumberSequence
	end
end

------------------
-- UI Functions --
------------------

------------------
-- B3Spell_Menu --
------------------

function B3Spell_Menu_OnOpen()

	if not B3Spell_SlotsSuppressOnOpen then

		if not worldScreen:CheckIfPaused() then
			B3Spell_PausedOnOpen = false
			if B3Spell_AutoPause == 1 then
				worldScreen:TogglePauseGame(true)
			end
		else
			B3Spell_PausedOnOpen = true
		end

		if B3Spell_AlwaysOpen == 0 then
			B3Spell_ActionbarDisable = true
		end
	end

	local screenWidth, screenHeight = Infinity_GetScreenSize()

	Infinity_SetArea('B3Spell_Menu_ExitBackground', nil, nil, screenWidth, screenHeight)
	Infinity_SetArea('B3Spell_Menu_ExitBackgroundDark', nil, nil, screenWidth + 4, screenHeight + 4)

	B3Spell_OldSearchEdit = ''
	B3Spell_SearchEdit = ''

	B3Spell_RefreshMenu()
end

function B3Spell_Menu_OnClose()

	if B3Spell_SlotsSuppressOnClose then
		return
	end

	if B3Spell_AutoPause == 1 and not B3Spell_PausedOnOpen and worldScreen:CheckIfPaused() then
		worldScreen:TogglePauseGame(true)
	end

	B3Spell_ActionbarDisable = false
end

function B3Spell_Menu_Modal()
	return B3Spell_Modal == 1
end

function B3Spell_Menu_FocusSearchBar()
	if B3Spell_DisableSearchBar == 0 then
		Infinity_FocusTextEdit('B3Spell_Menu_Search')
	end
end

function B3Spell_Menu_AttemptFocusSearchBar()
	if B3Spell_AutoFocusSearchBarTick == -1 and not B3Spell_IsCaptureActive() then
		B3Spell_AutoFocusSearchBarTick = 0
	end
end

-- Used to update slots based on current search field
function B3Spell_Menu_Tick()

	if B3Spell_AutoFocusSearchBar == 1 then
		B3Spell_Menu_AttemptFocusSearchBar()
	end

	if B3Spell_AutoFocusSearchBarTick >= 0 then
		if B3Spell_AutoFocusSearchBarTick >= 1 then
			if not B3Spell_IsCaptureActive() then
				B3Spell_Menu_FocusSearchBar()
			end
			B3Spell_AutoFocusSearchBarTick = -1
		else
			B3Spell_AutoFocusSearchBarTick = B3Spell_AutoFocusSearchBarTick + 1
		end
	end

	local currentTick = Infinity_GetClockTicks()
	if B3Spell_SliderChangeQueued and currentTick - B3Spell_LastManualSliderChange >= 33 then
		B3Spell_SliderChangeQueued = false
		B3Spell_LastManualSliderChange = currentTick
		local savedValue = B3Spell_AutomaticallyOptimizeSlotSize
		B3Spell_AutomaticallyOptimizeSlotSize = false
		B3Spell_InitializeSlots()
		B3Spell_AutomaticallyOptimizeSlotSize = savedValue
	end

	if B3Spell_SearchEdit ~= B3Spell_OldSearchEdit then
		if B3Spell_SearchEdit ~= '' then
			B3Spell_FilterSpellListInfoSearch()
		else
			B3Spell_FilterSpellListInfoAll()
		end
		B3Spell_OldSearchEdit = B3Spell_SearchEdit
	end

	return false
end

---------------------------------
-- B3Spell_Menu_ExitBackground --
---------------------------------

function B3Spell_Menu_ExitBackground_Enabled()
	return B3Spell_AlwaysOpen == 0 and B3Spell_DarkenBackground == 0
end

function B3Spell_Menu_ExitBackground_Action()
	Infinity_PopMenu('B3Spell_Menu')
end

-------------------------------------
-- B3Spell_Menu_ExitBackgroundDark --
-------------------------------------

function B3Spell_Menu_ExitBackgroundDark_Enabled()
	return B3Spell_DarkenBackground == 1
end

function B3Spell_Menu_ExitBackgroundDark_Action()
	Infinity_PopMenu('B3Spell_Menu')
end

-----------------------------------
-- B3Spell_Menu_SearchBackground --
-----------------------------------

function B3Spell_Menu_SearchBackground_Enabled()
	return B3Spell_DisableSearchBar == 0
end

function B3Spell_Menu_SearchBackground_Sequence()
	if RgUISkin then
		-- Infinity UI++
		return RgUISkin
	else
		return 0
	end
end

-------------------------
-- B3Spell_Menu_Search --
-------------------------

function B3Spell_Menu_Search_Enabled()
	return B3Spell_DisableSearchBar == 0
end

function B3Spell_Menu_Search_Action()
	if not key_pressed then return 1 end
	if key_pressed == 27 then
		Infinity_PopMenu('B3Spell_Menu')
	elseif key_pressed == 13 then
		if B3Spell_QuickSpellData then
			B3Spell_CastSpellData(B3Spell_QuickSpellData)
		end
		return 0
	else
		return 1
	end
end

---------------------------------
-- B3Spell_Menu_SlotSizeSlider --
---------------------------------

function B3Spell_Menu_SlotSizeSlider_Enabled()
	return B3Spell_DisableControlBar == 0
end

function B3Spell_Menu_SlotSizeSlider_Tooltip()
	return B3Spell_Tooltip_Slot_Size..B3Spell_SlotSize
end

function B3Spell_Menu_SlotSizeSlider_Action()
	B3Spell_SlotSize = B3Spell_SlotSizeMinimum + B3Spell_SlotSizeSlider
	B3Spell_SliderChangeQueued = true
end

function B3Spell_Menu_SlotSizeSlider_Settings()
	return B3Spell_SlotSizeMaximum - B3Spell_SlotSizeMinimum + 1
end

-----------------------------------
-- B3Spell_Menu_OptimizeSlotSize --
-----------------------------------

function B3Spell_Menu_OptimizeSlotSize_Enabled()
	return B3Spell_DisableControlBar == 0
end

function B3Spell_Menu_OptimizeSlotSize_Action()
	local savedValue = B3Spell_AutomaticallyOptimizeSlotSize
	B3Spell_AutomaticallyOptimizeSlotSize = 1
	B3Spell_InitializeSlots()
	B3Spell_AutomaticallyOptimizeSlotSize = savedValue
end

function B3Spell_Menu_OptimizeSlotSize_Sequence()
	if RgUISkin then
		-- Infinity UI++
		return RgUISkin
	else
		return 0
	end
end

-----------------------------------------
-- B3Spell_Menu_TEMPLATE_OptionsButton --
-----------------------------------------

function B3Spell_Menu_TEMPLATE_OptionsButton_Action()
	B3Spell_SlotsSuppressOnClose = true
	Infinity_PopMenu('B3Spell_Menu')
	B3Spell_SlotsSuppressOnClose = false
	Infinity_PushMenu('B3Spell_Menu_Options')
end

----------------------------------
-- B3Spell_Menu_FilterSlotsMage --
----------------------------------

function B3Spell_Menu_FilterSlotsMage_Action()
	B3Spell_FilterSpellListInfoMage()
	B3Spell_OldSearchEdit = ''
	B3Spell_SearchEdit = ''
end

---------------------------------
-- B3Spell_Menu_FilterSlotsAll --
---------------------------------

function B3Spell_Menu_FilterSlotsAll_Action()
	B3Spell_FilterSpellListInfoAll()
	B3Spell_OldSearchEdit = ''
	B3Spell_SearchEdit = ''
end

------------------------------------
-- B3Spell_Menu_FilterSlotsCleric --
------------------------------------

function B3Spell_Menu_FilterSlotsCleric_Action()
	B3Spell_FilterSpellListInfoCleric()
	B3Spell_OldSearchEdit = ''
	B3Spell_SearchEdit = ''
end

----------------------------------
-- B3Spell_Menu_TEMPLATE_Action --
----------------------------------

function B3Spell_Menu_TEMPLATE_Action_Action()
	local spellData = B3Spell_InstanceIDs["B3Spell_Menu"]["B3Spell_Menu_TEMPLATE_Action"].instanceData[instanceId].spellData
	if spellData.spellDisabled then return end
	B3Spell_CastSpellData(spellData)
end

function B3Spell_Menu_TEMPLATE_Action_ActionAlt()

	local spellData = B3Spell_InstanceIDs["B3Spell_Menu"]["B3Spell_Menu_TEMPLATE_Action"].instanceData[instanceId].spellData
	local castIcon = spellData.spellIcon
	local icon = castIcon:sub(1, #castIcon - 1).."B"

	-- Harcoded arguments:
	-- 16189
	-- CSpell::GetGenericName
	-- CSpell::GetDescription
	-- CSpell::GetIcon (change last letter to B)
	popupDetails(16189, spellData.spellRealNameStrref, spellData.spellDescription, icon)
end

function B3Spell_Menu_TEMPLATE_Action_Tooltip()
	local spellData = B3Spell_InstanceIDs["B3Spell_Menu"]["B3Spell_Menu_TEMPLATE_Action"].instanceData[instanceId].spellData
	return B3Spell_ShowKeyBindings == 1 and spellData.spellKeyBindingName ~= ""
		and spellData.spellKeyBindingName.." : "..spellData.spellName
		or spellData.spellName
end

function B3Spell_Menu_TEMPLATE_Action_Tick()
	return B3Spell_UpdateSlotPressedState()
end

-------------------------------------
-- B3Spell_Menu_TEMPLATE_Text_Text --
-------------------------------------

function B3Spell_Menu_TEMPLATE_Text_Text()
	return B3Spell_InstanceIDs["B3Spell_Menu"]["B3Spell_Menu_TEMPLATE_Text"].instanceData[instanceId].text
end

function B3Spell_Menu_TEMPLATE_Text_Color()
	return B3Spell_InstanceIDs["B3Spell_Menu"]["B3Spell_Menu_TEMPLATE_Text"].instanceData[instanceId].color
end

-------------------------------
-- B3Spell_Menu_TEMPLATE_Bam --
-------------------------------

function B3Spell_Menu_TEMPLATE_Bam_Bam()
	return B3Spell_InstanceIDs["B3Spell_Menu"]["B3Spell_Menu_TEMPLATE_Bam"].instanceData[instanceId].bam
end

function B3Spell_Menu_TEMPLATE_Bam_Sequence()
	return B3Spell_InstanceIDs["B3Spell_Menu"]["B3Spell_Menu_TEMPLATE_Bam"].instanceData[instanceId].sequence
end

function B3Spell_Menu_TEMPLATE_Bam_Frame()
	return B3Spell_InstanceIDs["B3Spell_Menu"]["B3Spell_Menu_TEMPLATE_Bam"].instanceData[instanceId].frame
end

--------------------------------
-- B3Spell_Menu_TEMPLATE_Icon --
--------------------------------

function B3Spell_Menu_TEMPLATE_Icon_Icon()
	return B3Spell_InstanceIDs["B3Spell_Menu"]["B3Spell_Menu_TEMPLATE_Icon"].instanceData[instanceId].icon
end

function B3Spell_Menu_TEMPLATE_Icon_Count()
	return B3Spell_InstanceIDs["B3Spell_Menu"]["B3Spell_Menu_TEMPLATE_Icon"].instanceData[instanceId].count
end

function B3Spell_Menu_TEMPLATE_Icon_DisableTint()
	return B3Spell_InstanceIDs["B3Spell_Menu"]["B3Spell_Menu_TEMPLATE_Icon"].instanceData[instanceId].disableTint
end

-------------------------------------
-- B3Spell_Menu_TEMPLATE_BamButton --
-------------------------------------

function B3Spell_Menu_TEMPLATE_BamButton_Bam()
	return B3Spell_InstanceIDs["B3Spell_Menu"]["B3Spell_Menu_TEMPLATE_BamButton"].instanceData[instanceId].bam
end

function B3Spell_Menu_TEMPLATE_BamButton_Frame()
	return B3Spell_InstanceIDs["B3Spell_Menu"]["B3Spell_Menu_TEMPLATE_BamButton"].instanceData[instanceId].frame
end

function B3Spell_Menu_TEMPLATE_BamButton_Tooltip()
	return B3Spell_InstanceIDs["B3Spell_Menu"]["B3Spell_Menu_TEMPLATE_BamButton"].instanceData[instanceId].tooltip
end

function B3Spell_Menu_TEMPLATE_BamButton_DisableTint()
	return B3Spell_InstanceIDs["B3Spell_Menu"]["B3Spell_Menu_TEMPLATE_BamButton"].instanceData[instanceId].disableTint
end

function B3Spell_Menu_TEMPLATE_BamButton_Action()
	return B3Spell_InstanceIDs["B3Spell_Menu"]["B3Spell_Menu_TEMPLATE_BamButton"].instanceData[instanceId].func()
end

--------------------------------
-- START B3Spell_Menu_Options --
--------------------------------

------------------
-- General Code --
------------------

B3Spell_Menu_Options_SuppressOnOpenReset = false
B3Spell_Menu_Options_SuppressOnClose = false

B3Spell_Options = {
	{
		{"AutoPause", B3Spell_Tooltip_Auto_Pause,
			["set"] = function(newVal) B3Spell_AutoPause = newVal end,
			["get"] = function() return B3Spell_AutoPause end,
			["write"] = function() Infinity_SetINIValue('Bubbs Spell Menu Extended', 'Auto-Pause', B3Spell_AutoPause) end,
			["forceOthers"] = {
				[true] = {
					{"AlwaysOpen", false},
				},
			},
		},
		{"AutomaticallyFocusSearchBar", B3Spell_Tooltip_Automatically_Focus_Search_Bar,
			["set"] = function(newVal) B3Spell_AutoFocusSearchBar = newVal end,
			["get"] = function() return B3Spell_AutoFocusSearchBar end,
			["write"] = function() Infinity_SetINIValue('Bubbs Spell Menu Extended', 'Automatically Focus Search Bar', B3Spell_AutoFocusSearchBar) end,
		},
		{"AutomaticallyOptimizeSlotSize", B3Spell_Tooltip_Automatically_Optimize_Slot_Size,
			["set"] = function(newVal) B3Spell_AutomaticallyOptimizeSlotSize = newVal end,
			["get"] = function() return B3Spell_AutomaticallyOptimizeSlotSize end,
			["write"] = function() Infinity_SetINIValue('Bubbs Spell Menu Extended', 'Automatically Optimize Slot Size', B3Spell_AutomaticallyOptimizeSlotSize) end,
			["forceOthers"] = {
				[false] = {
					{"AlwaysOpen", false},
				},
			},
		},
		{"DarkenBackground", B3Spell_Tooltip_Darken_Background,
			["set"] = function(newVal) B3Spell_DarkenBackground = newVal end,
			["get"] = function() return B3Spell_DarkenBackground end,
			["write"] = function() Infinity_SetINIValue('Bubbs Spell Menu Extended', 'Darken Background', B3Spell_DarkenBackground) end,
			["forceOthers"] = {
				[true] = {
					{"AlwaysOpen", false},
				},
			},
		},
		{"DisableControlBar", B3Spell_Tooltip_Disable_Control_Bar,
			["set"] = function(newVal) B3Spell_DisableControlBar = newVal end,
			["get"] = function() return B3Spell_DisableControlBar end,
			["write"] = function() Infinity_SetINIValue('Bubbs Spell Menu Extended', 'Disable Control Bar', B3Spell_DisableControlBar) end,
			["forceOthers"] = {
				[false] = {
					{"AlwaysOpen", false},
				},
			},
		},
		{"DisableSearchBar", B3Spell_Tooltip_Disable_Search_Bar,
			["set"] = function(newVal) B3Spell_DisableSearchBar = newVal end,
			["get"] = function() return B3Spell_DisableSearchBar end,
			["write"] = function() Infinity_SetINIValue('Bubbs Spell Menu Extended', 'Disable Search Bar', B3Spell_DisableSearchBar) end,
			["forceOthers"] = {
				[false] = {
					{"AlwaysOpen", false},
				},
			},
		},
		{"IgnoreSpecialAbilities", B3Spell_Tooltip_Ignore_Special_Abilities,
			["set"] = function(newVal) B3Spell_IgnoreSpecialAbilities = newVal end,
			["get"] = function() return B3Spell_IgnoreSpecialAbilities end,
			["write"] = function() Infinity_SetINIValue('Bubbs Spell Menu Extended', 'Ignore Special Abilities', B3Spell_IgnoreSpecialAbilities) end,
		},
		{"Modal", B3Spell_Tooltip_Modal,
			["set"] = function(newVal) B3Spell_Modal = newVal end,
			["get"] = function() return B3Spell_Modal end,
			["write"] = function() Infinity_SetINIValue('Bubbs Spell Menu Extended', 'Modal', B3Spell_Modal) end,
			["forceOthers"] = {
				[true] = {
					{"AlwaysOpen", false},
				},
			},
		},
		{"AlwaysOpen", B3Spell_Tooltip_Overlay_Mode,
			["set"] = function(newVal) B3Spell_AlwaysOpen = newVal end,
			["get"] = function() return B3Spell_AlwaysOpen end,
			["write"] = function() Infinity_SetINIValue('Bubbs Spell Menu Extended', 'Always Open', B3Spell_AlwaysOpen) end,
			["forceOthers"] = {
				[true] = {
					{"AutoPause", false},
					{"AutomaticallyOptimizeSlotSize", true},
					{"DarkenBackground", false},
					{"DisableControlBar", true},
					{"DisableSearchBar", true},
					{"Modal", false},
				},
			},
			["specialHeight"] = function()
				return B3Spell_Menu_OptimizeSlotSize_H
			end,
			["doSpecialLayout"] = function(innerX, currentY, innerWidth)
				local centeredX = innerX + (innerWidth / 2 - B3Spell_Menu_OptimizeSlotSize_W / 2)
				Infinity_SetArea("B3Spell_Menu_Options_SelectSlotArea", centeredX, currentY, B3Spell_Menu_OptimizeSlotSize_W, B3Spell_Menu_OptimizeSlotSize_H)
			end,
			["onChange"] = function(self)
				if self.get() == 0 then
					B3Spell_SetSlotSizeMinimum(B3Spell_SlotSizeHardMinimum)
					B3Spell_ActionbarDisable = true
				else
					B3Spell_SetSlotSizeMinimum(B3Spell_SlotSizeAlwaysOpenMinimum)
					B3Spell_ActionbarDisable = false
				end
			end
		},
		{"ShowKeyBindings", B3Spell_Tooltip_Show_Key_Bindings,
			["set"] = function(newVal) B3Spell_ShowKeyBindings = newVal end,
			["get"] = function() return B3Spell_ShowKeyBindings end,
			["write"] = function() Infinity_SetINIValue('Bubbs Spell Menu Extended', 'Show Key Bindings', B3Spell_ShowKeyBindings) end,
		},
	},
	{
		{"HorizontalAlignment", B3Spell_Tooltip_HorizontalSlotsAlignment,
			["set"] = function(newVal) B3Spell_HorizontalAlignment = newVal end,
			["get"] = function() return B3Spell_HorizontalAlignment end,
			["write"] = function() Infinity_SetINIValue('Bubbs Spell Menu Extended', 'Horizontal Alignment', B3Spell_HorizontalAlignment) end,
			["noToggle"] = true,
			["suboptions"] = {
				{"Left", B3Spell_Tooltip_Left,
					["deferTo"] = "HorizontalAlignment",
					["disallowToggleOff"] = true,
					["toggleValue"] = 0,
					["forceOthers"] = {
						[true] = {
							{"HorizontalAlignment.Center", false},
							{"HorizontalAlignment.Right", false},
						},
					},
				},
				{"Center", B3Spell_Tooltip_Center,
					["deferTo"] = "HorizontalAlignment",
					["disallowToggleOff"] = true,
					["toggleValue"] = 1,
					["forceOthers"] = {
						[true] = {
							{"HorizontalAlignment.Left", false},
							{"HorizontalAlignment.Right", false},
						},
					},
				},
				{"Right", B3Spell_Tooltip_Right,
					["deferTo"] = "HorizontalAlignment",
					["disallowToggleOff"] = true,
					["toggleValue"] = 2,
					["forceOthers"] = {
						[true] = {
							{"HorizontalAlignment.Left", false},
							{"HorizontalAlignment.Center", false},
						},
					},
				},
			},
		},
		{"VerticalAlignment", B3Spell_Tooltip_VerticalSlotsAlignment,
			["set"] = function(newVal) B3Spell_VerticalAlignment = newVal end,
			["get"] = function() return B3Spell_VerticalAlignment end,
			["write"] = function() Infinity_SetINIValue('Bubbs Spell Menu Extended', 'Vertical Alignment', B3Spell_VerticalAlignment) end,
			["noToggle"] = true,
			["suboptions"] = {
				{"Top", B3Spell_Tooltip_Top,
					["deferTo"] = "VerticalAlignment",
					["disallowToggleOff"] = true,
					["toggleValue"] = 0,
					["forceOthers"] = {
						[true] = {
							{"VerticalAlignment.Center", false},
							{"VerticalAlignment.Bottom", false},
						},
					},
				},
				{"Center", B3Spell_Tooltip_Center,
					["deferTo"] = "VerticalAlignment",
					["disallowToggleOff"] = true,
					["toggleValue"] = 1,
					["forceOthers"] = {
						[true] = {
							{"VerticalAlignment.Top", false},
							{"VerticalAlignment.Bottom", false},
						},
					},
				},
				{"Bottom", B3Spell_Tooltip_Bottom,
					["deferTo"] = "VerticalAlignment",
					["disallowToggleOff"] = true,
					["toggleValue"] = 2,
					["forceOthers"] = {
						[true] = {
							{"VerticalAlignment.Top", false},
							{"VerticalAlignment.Center", false},
						},
					},
				},
			},
		},
		{"MoveSlotHeadersToTheRight", B3Spell_Tooltip_MoveSlotHeadersToTheRight,
			["set"] = function(newVal) B3Spell_MoveSlotHeadersToTheRight = newVal end,
			["get"] = function() return B3Spell_MoveSlotHeadersToTheRight end,
			["write"] = function() Infinity_SetINIValue('Bubbs Spell Menu Extended', 'Move Slot Headers To The Right', B3Spell_MoveSlotHeadersToTheRight) end,
		},
	},
}

B3Spell_Options_Map = {}

EEex_Utility_NewScope(function()

	local handleGroup
	handleGroup = function(group, parentName)

		for _, option in ipairs(group) do

			if not option.noToggle then
				local mainOption = option.deferTo and B3Spell_Options_Map[option.deferTo] or option
				option.toggleState = mainOption.get() == (option.toggleValue or 1)
			end

			local optionName = string.format("%s%s", parentName, option[1])
			B3Spell_Options_Map[optionName] = option

			if option.suboptions then
				handleGroup(option.suboptions, string.format("%s.", optionName))
			end
		end
	end

	for _, columnGroup in ipairs(B3Spell_Options) do
		handleGroup(columnGroup, "")
	end
end)

function B3Spell_GetTextWidthHeight(font, pointSize, text)
	local oneLineHeight = Infinity_GetContentHeight(font, 0, "", pointSize, 0)
	local currentWidth = 0
	local currentHeight = nil
	repeat
		currentWidth = currentWidth + 1
		currentHeight = Infinity_GetContentHeight(font, currentWidth, text, pointSize, 0)
	until currentHeight <= oneLineHeight
	return currentWidth, oneLineHeight
end

function B3Spell_CreateText(text, x, y, w, h)
	local instanceData = B3Spell_CreateInstance('B3Spell_Menu_Options', 'TEMPLATE_B3Spell_Menu_Options_Text', x, y, w, h)
	instanceData.text = text
end

function B3Spell_CreateToggle(optionData, x, y, w, h)
	local instanceData = B3Spell_CreateInstance('B3Spell_Menu_Options', 'TEMPLATE_B3Spell_Menu_Options_Toggle', x, y, w, h)
	instanceData.optionData = optionData
end

------------------
-- UI Functions --
------------------

--------------------------
-- B3Spell_Menu_Options --
--------------------------

function B3Spell_Menu_Options_OnOpen()

	if not B3Spell_Menu_Options_SuppressOnOpenReset then

		local handleGroup
		handleGroup = function(group)

			for _, option in ipairs(group) do

				if not option.deferTo then
					option.old = option.get()
				end

				if option.suboptions then
					handleGroup(option.suboptions)
				end
			end
		end

		for _, columnGroup in ipairs(B3Spell_Options) do
			handleGroup(columnGroup, "")
		end
	end

	B3Spell_DestroyInstances("B3Spell_Menu_Options")

	local screenW, screenH = Infinity_GetScreenSize()
	Infinity_SetArea("B3Spell_Menu_Options_ExitBackground", nil, nil, screenW, screenH)
	Infinity_SetArea("B3Spell_Menu_Options_ExitBackgroundDark", nil, nil, screenW + 4, screenH + 4)

	local font = styles["normal"].font
	local fontPoint = styles["normal"].point

	local toggleOffsetFromText = 10

	local columnInfos = {}
	local totalColumnWidth = 0
	local maxColumnHeight = 0

	for i, columnGroup in ipairs(B3Spell_Options) do

		local columnTextDatas = {}
		local maxTextWidth = 0
		local currentHeight = 0

		local handleGroup
		handleGroup = function(group, layer)

			for _, option in ipairs(group) do

				local xOffset = layer * 20
				local textW, textH = B3Spell_GetTextWidthHeight(font, fontPoint, option[2])
				local effectiveTextW = xOffset + textW

				if effectiveTextW > maxTextWidth then
					maxTextWidth = effectiveTextW
				end

				table.insert(columnTextDatas, { ["text"] = option[2], ["xOffset"] = xOffset, ["w"] = textW, ["h"] = textH })

				currentHeight = currentHeight + textH + 20
				if option.specialHeight then
					currentHeight = currentHeight + option.specialHeight()
				end

				if option.suboptions then
					handleGroup(option.suboptions, layer + 1)
				end
			end
		end
		handleGroup(columnGroup, 0)

		if currentHeight > maxColumnHeight then
			maxColumnHeight = currentHeight
		end

		local columnWidth = maxTextWidth + toggleOffsetFromText + 32
		totalColumnWidth = totalColumnWidth + columnWidth

		columnInfos[i] = {
			["textDatas"] = columnTextDatas,
			["maxTextWidth"] = maxTextWidth,
			["width"] = columnWidth,
			["height"] = currentHeight,
		}
	end

	local oneLineHeight = Infinity_GetContentHeight(font, 0, "", fontPoint, 0)
	local toggleYOffset = oneLineHeight / 2 - 16
	local innerXOffset = 16 + 10
	local innerYOffset = innerXOffset - toggleYOffset

	local columnGap = 20
	local backgroundWidth = 2 * innerXOffset + totalColumnWidth + (#B3Spell_Options - 1) * columnGap
	local backgroundHeight = 2 * innerYOffset + maxColumnHeight
	local startingX = (screenW - backgroundWidth) / 2
	local startingY = (screenH - backgroundHeight) / 2
	Infinity_SetArea("B3Spell_Menu_Options_OptionsBackground", startingX, startingY, backgroundWidth, backgroundHeight)

	local curColumnX = startingX + innerXOffset

	for columnI, columnGroup in ipairs(B3Spell_Options) do

		local columnInfo = columnInfos[columnI]
		local textDatas = columnInfo.textDatas

		local textX = curColumnX
		local toggleX = curColumnX + columnInfo.maxTextWidth + toggleOffsetFromText
		local columnWidth = columnInfo.width

		local i = 1
		local currentY = startingY + innerYOffset
		local handleGroup
		handleGroup = function(group)

			for _, option in ipairs(group) do

				local textData = textDatas[i]
				B3Spell_CreateText(textData.text, textX + textData.xOffset, currentY, textData.w, textData.h)

				if not option.noToggle then
					B3Spell_CreateToggle(option, toggleX, currentY + toggleYOffset, 32, 32)
				end
				currentY = currentY + oneLineHeight

				if option.doSpecialLayout then
					currentY = currentY + 20
					option.doSpecialLayout(curColumnX, currentY, columnWidth)
					currentY = currentY + option.specialHeight()
				end
				currentY = currentY + 20

				i = i + 1
				if option.suboptions then
					handleGroup(option.suboptions)
				end
			end
		end
		handleGroup(columnGroup)

		curColumnX = curColumnX + columnWidth + columnGap
	end
end

function B3Spell_Menu_Options_OnClose()

	if B3Spell_Menu_Options_SuppressOnClose then
		return
	end

	local handleGroup
	handleGroup = function(group)

		for _, option in ipairs(group) do

			if not option.deferTo then
				option.write()
				if option.onChange and option.get() ~= option.old then
					option:onChange()
				end
			end

			if option.suboptions then
				handleGroup(option.suboptions)
			end
		end
	end

	for _, columnGroup in ipairs(B3Spell_Options) do
		handleGroup(columnGroup)
	end

	local spriteID = EEex_Sprite_GetSelectedID()
	if spriteID ~= -1 then
		-- Attempt to relaunch the spell menu
		B3Spell_SlotsSuppressOnOpen = true
		B3Spell_LaunchSpellMenu(B3Spell_GetTransferMode(spriteID), spriteID)
		B3Spell_SlotsSuppressOnOpen = false
	else
		-- Can't relaunch the spell menu, so close it out logically...
		B3Spell_Menu_OnClose()
	end
end

function B3Spell_Menu_Options_Modal()
	return B3Spell_Modal == 1
end

-----------------------------------------
-- B3Spell_Menu_Options_ExitBackground --
-----------------------------------------

function B3Spell_Menu_Options_ExitBackground_Enabled()
	return B3Spell_AlwaysOpen == 0 and B3Spell_DarkenBackground == 0
end

function B3Spell_Menu_Options_ExitBackground_Action()
	Infinity_PopMenu('B3Spell_Menu_Options')
end

---------------------------------------------
-- B3Spell_Menu_Options_ExitBackgroundDark --
---------------------------------------------

function B3Spell_Menu_Options_ExitBackgroundDark_Enabled()
	return B3Spell_AlwaysOpen == 1 or B3Spell_DarkenBackground == 1
end

function B3Spell_Menu_Options_ExitBackgroundDark_Action()
	Infinity_PopMenu('B3Spell_Menu_Options')
end

----------------------------------------
-- B3Spell_Menu_Options_TEMPLATE_Text --
----------------------------------------

function B3Spell_Menu_Options_TEMPLATE_Text_Text()
	return B3Spell_InstanceIDs['B3Spell_Menu_Options']['TEMPLATE_B3Spell_Menu_Options_Text'].instanceData[instanceId].text
end

------------------------------------------
-- B3Spell_Menu_Options_TEMPLATE_Toggle --
------------------------------------------

function B3Spell_Menu_Options_TEMPLATE_Toggle_Frame()
	local optionData = B3Spell_InstanceIDs['B3Spell_Menu_Options']['TEMPLATE_B3Spell_Menu_Options_Toggle'].instanceData[instanceId].optionData
	return optionData.toggleState and 2 or 0
end

function B3Spell_Menu_Options_TEMPLATE_Toggle_Action()

	local optionData = B3Spell_InstanceIDs['B3Spell_Menu_Options']['TEMPLATE_B3Spell_Menu_Options_Toggle'].instanceData[instanceId].optionData
	local newToggleState = not optionData.toggleState

	if not newToggleState and optionData.disallowToggleOff then
		return
	end

	optionData.toggleState = newToggleState

	local forceOthers = optionData.forceOthers
	if forceOthers then

		for _, forceEntry in ipairs(forceOthers[optionData.toggleState] or {}) do

			local forceData = B3Spell_Options_Map[forceEntry[1]]
			local newForceToggleState = forceEntry[2]
			forceData.toggleState = newForceToggleState

			if newForceToggleState or not forceData.disallowToggleOff then
				local mainForceData = forceData.deferTo and B3Spell_Options_Map[forceData.deferTo] or forceData
				local newForceVal = newForceToggleState and (forceData.toggleValue or 1) or 0
				mainForceData.set(newForceVal)
			end
		end
	end

	local mainOptionData = optionData.deferTo and B3Spell_Options_Map[optionData.deferTo] or optionData
	local newVal = newToggleState and (optionData.toggleValue or 1) or 0
	mainOptionData.set(newVal)
end

-----------------------------------------
-- B3Spell_Menu_Options_SelectSlotArea --
-----------------------------------------

function B3Spell_Menu_Options_SelectSlotArea_Action()
	B3Spell_Menu_Options_SuppressOnClose = true
	Infinity_PopMenu("B3Spell_Menu_Options")
	B3Spell_Menu_Options_SuppressOnClose = false
	Infinity_PushMenu("B3Spell_Menu_SelectSlotArea")
end

---------------------------------------
-- START B3Spell_Menu_SelectSlotArea --
---------------------------------------

------------------
-- General Code --
------------------

B3Spell_TempSlotAreaX = nil
B3Spell_TempSlotAreaY = nil
B3Spell_TempSlotAreaW = nil
B3Spell_TempSlotAreaH = nil

function B3Spell_Menu_SelectSlotArea_Recalculate(deltaX, deltaY, deltaW, deltaH)

	local minWidth = B3Spell_SlotSizeAlwaysOpenMinimum * 4 + B3Spell_SlotsGapX * 3
	local minHeight = B3Spell_SlotSizeAlwaysOpenMinimum * 12 + B3Spell_SlotsGapY * 11

	B3Spell_TempSlotAreaX = B3Spell_TempSlotAreaX + deltaX
	B3Spell_TempSlotAreaY = B3Spell_TempSlotAreaY + deltaY
	B3Spell_TempSlotAreaW = B3Spell_TempSlotAreaW + deltaW
	B3Spell_TempSlotAreaH = B3Spell_TempSlotAreaH + deltaH

	local screenW, screenH = Infinity_GetScreenSize()

	if B3Spell_TempSlotAreaX < 0 then
		B3Spell_TempSlotAreaX = 0
	end

	if B3Spell_TempSlotAreaY < 0 then
		B3Spell_TempSlotAreaY = 0
	end

	if B3Spell_TempSlotAreaW < minWidth then
		B3Spell_TempSlotAreaW = minWidth
	end

	if B3Spell_TempSlotAreaX + B3Spell_TempSlotAreaW > screenW then
		B3Spell_TempSlotAreaW = screenW - B3Spell_TempSlotAreaX
	end

	if B3Spell_TempSlotAreaW < minWidth then
		local diff = minWidth - B3Spell_TempSlotAreaW
		B3Spell_TempSlotAreaX = B3Spell_TempSlotAreaX - diff
		B3Spell_TempSlotAreaW = B3Spell_TempSlotAreaW + diff
	end

	if B3Spell_TempSlotAreaH < minHeight then
		B3Spell_TempSlotAreaH = minHeight
	end

	if B3Spell_TempSlotAreaY + B3Spell_TempSlotAreaH > screenH then
		B3Spell_TempSlotAreaH = screenH - B3Spell_TempSlotAreaY
	end

	if B3Spell_TempSlotAreaH < minHeight then
		local diff = minHeight - B3Spell_TempSlotAreaH
		B3Spell_TempSlotAreaY = B3Spell_TempSlotAreaY - diff
		B3Spell_TempSlotAreaH = B3Spell_TempSlotAreaH + diff
	end

	Infinity_SetArea("B3Spell_Menu_SelectSlotArea_Rect",
		B3Spell_TempSlotAreaX,
		B3Spell_TempSlotAreaY,
		B3Spell_TempSlotAreaW,
		B3Spell_TempSlotAreaH
	)

	Infinity_SetArea("B3Spell_Menu_SelectSlotArea_TopHandle",
		B3Spell_TempSlotAreaX,
		B3Spell_TempSlotAreaY,
		B3Spell_TempSlotAreaW,
		16
	)

	Infinity_SetArea("B3Spell_Menu_SelectSlotArea_RightHandle",
		B3Spell_TempSlotAreaX + B3Spell_TempSlotAreaW - 16,
		B3Spell_TempSlotAreaY,
		16,
		B3Spell_TempSlotAreaH
	)

	Infinity_SetArea("B3Spell_Menu_SelectSlotArea_BottomHandle",
		B3Spell_TempSlotAreaX,
		B3Spell_TempSlotAreaY + B3Spell_TempSlotAreaH - 16,
		B3Spell_TempSlotAreaW,
		16
	)

	Infinity_SetArea("B3Spell_Menu_SelectSlotArea_LeftHandle",
		B3Spell_TempSlotAreaX,
		B3Spell_TempSlotAreaY,
		16,
		B3Spell_TempSlotAreaH
	)

	local acceptW = math.min(B3Spell_TempSlotAreaW - 16 - 16 - 10 - 10, B3Spell_Menu_OptimizeSlotSize_W)
	local acceptH = math.min(B3Spell_TempSlotAreaH - 16 - 16 - 10 - 10, B3Spell_Menu_OptimizeSlotSize_H)
	Infinity_SetArea("B3Spell_Menu_SelectSlotArea_Accept",
		B3Spell_TempSlotAreaX + (B3Spell_TempSlotAreaW / 2 - acceptW / 2),
		B3Spell_TempSlotAreaY + (B3Spell_TempSlotAreaH / 2 - acceptH / 2),
		acceptW,
		acceptH
	)
end

------------------
-- UI Functions --
------------------

---------------------------------
-- B3Spell_Menu_SelectSlotArea --
---------------------------------

function B3Spell_Menu_SelectSlotArea_OnOpen()
	B3Spell_TempSlotAreaX = B3Spell_SlotsAreaX
	B3Spell_TempSlotAreaY = B3Spell_SlotsAreaY
	B3Spell_TempSlotAreaW = B3Spell_SlotsAreaW
	B3Spell_TempSlotAreaH = B3Spell_SlotsAreaH
	B3Spell_Menu_SelectSlotArea_Recalculate(0, 0, 0, 0)
end

function B3Spell_Menu_SelectSlotArea_OnClose()
	B3Spell_Menu_Options_SuppressOnOpenReset = true
	Infinity_PushMenu("B3Spell_Menu_Options")
	B3Spell_Menu_Options_SuppressOnOpenReset = false
end

-------------------------------------------
-- B3Spell_Menu_SelectSlotArea_TopHandle --
-------------------------------------------

function B3Spell_Menu_SelectSlotArea_TopHandle_ActionDrag()
	B3Spell_Menu_SelectSlotArea_Recalculate(0, motionY, 0, 0)
end

---------------------------------------------
-- B3Spell_Menu_SelectSlotArea_RightHandle --
---------------------------------------------

function B3Spell_Menu_SelectSlotArea_RightHandle_ActionDrag()
	B3Spell_Menu_SelectSlotArea_Recalculate(0, 0, motionX, 0)
end

----------------------------------------------
-- B3Spell_Menu_SelectSlotArea_BottomHandle --
----------------------------------------------

function B3Spell_Menu_SelectSlotArea_BottomHandle_ActionDrag()
	B3Spell_Menu_SelectSlotArea_Recalculate(0, 0, 0, motionY)
end

--------------------------------------------
-- B3Spell_Menu_SelectSlotArea_LeftHandle --
--------------------------------------------

function B3Spell_Menu_SelectSlotArea_LeftHandle_ActionDrag()
	B3Spell_Menu_SelectSlotArea_Recalculate(motionX, 0, 0, 0)
end

-----------------------------------------------
-- B3Spell_Menu_SelectSlotArea_Accept_Action --
-----------------------------------------------

function B3Spell_Menu_SelectSlotArea_Accept_Action()
	Infinity_PopMenu("B3Spell_Menu_SelectSlotArea")
	B3Spell_SetSlotsArea(B3Spell_TempSlotAreaX, B3Spell_TempSlotAreaY, B3Spell_TempSlotAreaW, B3Spell_TempSlotAreaH)
end
