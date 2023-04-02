
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

-------------
-- Options --
-------------

B3Spell_AlignCenter                   = Infinity_GetINIValue('Bubbs Spell Menu Extended', 'Align Center',                     1)
B3Spell_AutoPause                     = Infinity_GetINIValue('Bubbs Spell Menu Extended', 'Auto-Pause',                       1)
B3Spell_AutoFocusSearchBar            = Infinity_GetINIValue('Bubbs Spell Menu Extended', 'Automatically Focus Search Bar',   1)
B3Spell_AutomaticallyOptimizeSlotSize = Infinity_GetINIValue('Bubbs Spell Menu Extended', 'Automatically Optimize Slot Size', 1)
B3Spell_DarkenBackground              = Infinity_GetINIValue('Bubbs Spell Menu Extended', 'Darken Background',                0)
B3Spell_DisableControlBar             = Infinity_GetINIValue('Bubbs Spell Menu Extended', 'Disable Control Bar',              0)
B3Spell_DisableSearchBar              = Infinity_GetINIValue('Bubbs Spell Menu Extended', 'Disable Search Bar',               0)
B3Spell_IgnoreSpecialAbilities        = Infinity_GetINIValue('Bubbs Spell Menu Extended', 'Ignore Special Abilities',         0)
B3Spell_Modal                         = Infinity_GetINIValue('Bubbs Spell Menu Extended', 'Modal',                            1)
B3Spell_ShowKeyBindings               = Infinity_GetINIValue('Bubbs Spell Menu Extended', 'Show Key Bindings',                0)

function B3Spell_SetAlignCenter(newVal)
	B3Spell_AlignCenter = newVal
	Infinity_SetINIValue('Bubbs Spell Menu Extended', 'Align Center', B3Spell_AlignCenter)
end

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

B3Spell_SlotSizeMinimum   = 5
B3Spell_SlotsGapX         = 1
B3Spell_SlotsGapY         = 2
B3Spell_SlotsGapYFlowover = 1

-----------
-- State --
-----------

B3Spell_Mode = nil

B3Spell_ActionbarDisable     = false
B3Spell_PausedOnOpen         = false
B3Spell_SlotsSuppressOnOpen  = false
B3Spell_SlotsSuppressOnClose = false

B3Spell_SearchEdit             = ""
B3Spell_OldSearchEdit          = ""
B3Spell_AutoFocusSearchBarTick = -1

B3Spell_SpellListInfo         = {}
B3Spell_KeyToSpellData        = {}
B3Spell_FilteredSpellListInfo = {}
B3Spell_SlotRowInfo           = {}
B3Spell_QuickSpellData        = nil

B3Spell_SlotSize       = 52
B3Spell_SlotSizeSlider = B3Spell_SlotSize - B3Spell_SlotSizeMinimum

B3Spell_SlotsAvailable    = nil
B3Spell_LinesAvailable    = nil
B3Spell_UsedVerticalSpace = nil

-------------------------
-- Menu Initialization --
-------------------------

function B3Spell_LaunchSpellMenu(mode)

	B3Spell_Mode = mode

	if not worldScreen:CheckIfPaused() then
		B3Spell_PausedOnOpen = false
		if B3Spell_AutoPause == 1 then
			worldScreen:TogglePauseGame(true)
		end
	else
		B3Spell_PausedOnOpen = true
	end

	Infinity_PushMenu('B3Spell_Menu')
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

	-- Calculate slotsRenderXOffset
	local slotsRenderXOffset = nil
	if B3Spell_AlignCenter == 1 then
		local horizontalAvailableSpace = B3Spell_GetAvailableHorizontalSpace()
		local longestCount = B3Spell_GetLongestSlotCount()
		local horizontalAreaUsed = longestCount * (B3Spell_SlotSize + B3Spell_SlotsGapX) - B3Spell_SlotsGapX
		local horizontalMarginSpace = horizontalAvailableSpace - horizontalAreaUsed
		slotsRenderXOffset = B3Spell_SidebarWidth + (horizontalMarginSpace / 2)
	else
		slotsRenderXOffset = B3Spell_SidebarWidth
	end

	-- Calculate currentYOffset
	local _, screenHeight = Infinity_GetScreenSize()
	local verticalAreaUsed = B3Spell_UsedVerticalSpace
	local verticalMarginSpace = screenHeight - B3Spell_GetMinY() - verticalAreaUsed
	local currentYOffset = B3Spell_GetMinY() + (verticalMarginSpace / 2)

	-- Destroy all the slots I've already spawned
	B3Spell_DestroyInstances("B3Spell_Menu")

	B3Spell_CreateNamedSlotBamButton("B3Spell_Menu_FilterSlotsMage",   "GUIBTACT", 68, B3Spell_Tooltip_Mage_Spells,   B3Spell_Menu_FilterSlotsMage_Action,   0, 0, 52, 52)
	B3Spell_CreateNamedSlotBamButton("B3Spell_Menu_FilterSlotsAll",    "GUIBTACT", 12, B3Spell_Tooltip_All_Spells,    B3Spell_Menu_FilterSlotsAll_Action,    0, 0, 52, 52)
	B3Spell_CreateNamedSlotBamButton("B3Spell_Menu_FilterSlotsCleric", "GUIBTACT", 70, B3Spell_Tooltip_Cleric_Spells, B3Spell_Menu_FilterSlotsCleric_Action, 0, 0, 52, 52)

	if B3Spell_AlignCenter == 1 then

		B3Spell_CreateNamedSlotBamButton("B3Spell_Menu_MoveSlotsLeft", "GUIBTACT", 64, B3Spell_Tooltip_Align_Left, B3Spell_Menu_MoveSlotsLeft_Action, 0, 0, 52, 52)

		B3Spell_CenterItemsX(
		{
			{ ['name'] = 'B3Spell_Menu_MoveSlotsLeft',          ['x'] = 0   },
			{ ['name'] = 'B3Spell_Menu_MoveSlotsLeft_Slot',     ['x'] = 0   },
			{ ['name'] = 'B3Spell_Menu_FilterSlotsMage',        ['x'] = 52  },
			{ ['name'] = 'B3Spell_Menu_FilterSlotsMage_Slot',   ['x'] = 52  },
			{ ['name'] = 'B3Spell_Menu_FilterSlotsAll',         ['x'] = 104 },
			{ ['name'] = 'B3Spell_Menu_FilterSlotsAll_Slot',    ['x'] = 104 },
			{ ['name'] = 'B3Spell_Menu_FilterSlotsCleric',      ['x'] = 156 },
			{ ['name'] = 'B3Spell_Menu_FilterSlotsCleric_Slot', ['x'] = 156 },
			{
				['name'] = 'B3Spell_Menu_SlotSizeSlider',
				['x'] = 208,
				['y'] = B3Spell_Menu_SlotSizeSlider_Y,
				['width'] = B3Spell_Menu_SlotSizeSlider_W,
				['height'] = B3Spell_Menu_SlotSizeSlider_H,
			},
			{
				['name'] = 'B3Spell_Menu_OptimizeSlotSize',
				['x'] = B3Spell_Menu_OptimizeSlotSize_AlignmentX,
				['y'] = B3Spell_Menu_OptimizeSlotSize_Y,
				['width'] = B3Spell_Menu_OptimizeSlotSize_W,
				['height'] = B3Spell_Menu_OptimizeSlotSize_H,
			},
		})

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
	else
		B3Spell_CreateNamedSlotBamButton("B3Spell_Menu_MoveSlotsRight", "GUIBTACT", 66, B3Spell_Tooltip_Align_Center, B3Spell_Menu_MoveSlotsRight_Action, 0, 0, 52, 52)

		Infinity_SetArea('B3Spell_Menu_FilterSlotsMage',        B3Spell_SidebarWidth,       nil, nil, nil)
		Infinity_SetArea('B3Spell_Menu_FilterSlotsMage_Slot',   B3Spell_SidebarWidth,       nil, nil, nil)
		Infinity_SetArea('B3Spell_Menu_FilterSlotsAll',         B3Spell_SidebarWidth + 52,  nil, nil, nil)
		Infinity_SetArea('B3Spell_Menu_FilterSlotsAll_Slot',    B3Spell_SidebarWidth + 52,  nil, nil, nil)
		Infinity_SetArea('B3Spell_Menu_FilterSlotsCleric',      B3Spell_SidebarWidth + 104, nil, nil, nil)
		Infinity_SetArea('B3Spell_Menu_FilterSlotsCleric_Slot', B3Spell_SidebarWidth + 104, nil, nil, nil)
		Infinity_SetArea('B3Spell_Menu_MoveSlotsRight',         B3Spell_SidebarWidth + 156, nil, nil, nil)
		Infinity_SetArea('B3Spell_Menu_MoveSlotsRight_Slot',    B3Spell_SidebarWidth + 156, nil, nil, nil)

		Infinity_SetArea('B3Spell_Menu_SlotSizeSlider',    B3Spell_SidebarWidth + 208,                                      B3Spell_Menu_SlotSizeSlider_Y,   B3Spell_Menu_SlotSizeSlider_W,   B3Spell_Menu_SlotSizeSlider_H)
		Infinity_SetArea('B3Spell_Menu_OptimizeSlotSize',  B3Spell_SidebarWidth + B3Spell_Menu_OptimizeSlotSize_AlignmentX, B3Spell_Menu_OptimizeSlotSize_Y, B3Spell_Menu_OptimizeSlotSize_W, B3Spell_Menu_OptimizeSlotSize_H)

		local searchBackgroundTop = B3Spell_DisableControlBar == 0 and 57 or (55 - B3Spell_Menu_SearchBackground_H) / 2
		Infinity_SetArea('B3Spell_Menu_SearchBackground', B3Spell_SidebarWidth, searchBackgroundTop,                               B3Spell_Menu_SearchBackground_W, B3Spell_Menu_SearchBackground_H)
		Infinity_SetArea('B3Spell_Menu_Search',           B3Spell_SidebarWidth, searchBackgroundTop + B3Spell_Menu_Search_YOffset, B3Spell_Menu_SearchBackground_W, nil)
	end

	B3Spell_QuickSpellData = nil
	local foundGreen = false
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

		if not slotRowInfo.isFlowover then
			if rowInfoMode == B3Spell_InfoModes.Spells then
				B3Spell_CreateBam("B3NUM", numSequence, rowInfo.spellLevel - 1, currentXOffset, currentYOffset, B3Spell_SlotSize, B3Spell_SlotSize)
			else
				local iconDef = B3Spell_InfoModeIcons[rowInfoMode]
				B3Spell_CreateSlotBamBam(iconDef[1], 0, iconDef[2], currentXOffset, currentYOffset, B3Spell_SlotSize, B3Spell_SlotSize)
			end
		end
		currentXOffset = currentXOffset + B3Spell_SlotSize + B3Spell_SlotsGapX

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
		end

		-- Move to next row
		local nextSlotLevelInfo = B3Spell_SlotRowInfo[row + 1]
		if nextSlotLevelInfo and nextSlotLevelInfo.isFlowover then
			currentYOffset = currentYOffset + B3Spell_SlotSize + B3Spell_SlotsGapYFlowover
		else
			currentYOffset = currentYOffset + B3Spell_SlotSize + B3Spell_SlotsGapY
		end
	end
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

-- Fills (via proxy of B3Spell_CalculateLines()):
--     B3Spell_SlotsAvailable
--     B3Spell_LinesAvailable
--     B3Spell_UsedVerticalSpace
function B3Spell_OptimizeSlotSize()
	for tempSlotSize = 52, B3Spell_SlotSizeMinimum, -1 do
		B3Spell_SlotSize = tempSlotSize
		if B3Spell_CalculateLines() then break end
	end
	B3Spell_SlotSizeSlider = B3Spell_SlotSize - B3Spell_SlotSizeMinimum
end

-- Fills:
--     B3Spell_SlotsAvailable
--     B3Spell_LinesAvailable
--     B3Spell_UsedVerticalSpace
function B3Spell_CalculateLines()

	local _, screenHeight = Infinity_GetScreenSize()
	local verticalAreaAvailable = screenHeight - B3Spell_GetMinY()
	local totalLinesNeeded = 0

	local paddingSpaceRequired = 0
	local lastPaddingType = -1

	-- Calculate the amount of space used by the current state
	local calcUsedSpace = function()
		if lastPaddingType == 0 then
			return totalLinesNeeded * B3Spell_SlotSize + paddingSpaceRequired - B3Spell_SlotsGapY
		elseif lastPaddingType == 1 then
			return totalLinesNeeded * B3Spell_SlotSize + paddingSpaceRequired - B3Spell_SlotsGapYFlowover
		else
			error("[B3Spell_CalculateLines] (ASSERT) Unexpected 'lastPaddingType' state: "..tostring(lastPaddingType))
		end
	end

	-- Check if I've exceeded the available vertical space.
	-- If I have, return true and update the relevant global state.
	local currentUsedSpace = 0
	local checkSpace = function()
		local usedSpace = calcUsedSpace()
		if verticalAreaAvailable >= usedSpace then
			currentUsedSpace = usedSpace
			return false
		else
			-- There wasn't enough space to fit everything, settle with the maximum line amount.
			B3Spell_LinesAvailable = totalLinesNeeded - 1
			B3Spell_UsedVerticalSpace = currentUsedSpace
			return true
		end
	end

	-- Calculate the number of slots that I can fit horizontally across the screen
	local horizontalAvailableSpace = B3Spell_GetAvailableHorizontalSpace()
	B3Spell_SlotsAvailable = math.floor(horizontalAvailableSpace / (B3Spell_SlotSize + B3Spell_SlotsGapX))
	B3Spell_SlotsAvailable = B3Spell_SlotsAvailable + math.floor(B3Spell_SlotsGapX / B3Spell_SlotSize)

	for i = 1, #B3Spell_FilteredSpellListInfo, 1 do

		local spellCountForLevel = #B3Spell_FilteredSpellListInfo[i]

		-- Update local state with a new line, accounting for gapSize
		local processLine = function(gapSize)
			spellCountForLevel = spellCountForLevel - B3Spell_SlotsAvailable + 1
			totalLinesNeeded = totalLinesNeeded + 1
			paddingSpaceRequired = paddingSpaceRequired + gapSize
		end

		if spellCountForLevel > 0 then

			-- Process normal line
			processLine(B3Spell_SlotsGapY)
			lastPaddingType = 0
			if checkSpace() then return false end

			-- Process flowover lines
			while spellCountForLevel > 0 do
				processLine(B3Spell_SlotsGapYFlowover)
				lastPaddingType = 1
				if checkSpace() then return false end
			end
		end
	end

	-- There was enough space to fit all spells on the screen!
	B3Spell_LinesAvailable = totalLinesNeeded
	B3Spell_UsedVerticalSpace = currentUsedSpace
	return true
end

function B3Spell_GetMinY()
	local total = 0
	if B3Spell_DisableControlBar == 0 then total = total + 52 + 5 end
	if B3Spell_DisableSearchBar == 0 then total = total + B3Spell_Menu_SearchBackground_H + 5 end
	if total < 55 then total = 55 end
	return total
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
		for slotColumn, slotData in ipairs(slotRowInfo.slotInstances) do
			local newSlotData = B3Spell_GetDataForSlot(slotRow, slotColumn)
			local iconData = B3Spell_InstanceIDs["B3Spell_Menu"]["B3Spell_Menu_TEMPLATE_Icon"].instanceData[slotData.pairedIconID]
			slotData.spellData = newSlotData
			iconData.icon = newSlotData.spellIcon
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

function B3Spell_GetAvailableHorizontalSpace()
	local screenWidth, _ = Infinity_GetScreenSize()
	local horizontalAvailableSpace = screenWidth - (B3Spell_SidebarWidth * 2)
	return horizontalAvailableSpace
end

function B3Spell_CenterItemsX(itemEntries)
	local greatestX = 0
	for _, itemEntry in ipairs(itemEntries) do
		if nameToItem[itemEntry.name] then
			local width = itemEntry.width and itemEntry.width or select(3, Infinity_GetArea(itemEntry.name))
			local itemRightEdge = (itemEntry.x or 0) + width
			if itemRightEdge > greatestX then greatestX = itemRightEdge end
		end
	end
	local screenWidth, _ = Infinity_GetScreenSize()
	local centerXStart = screenWidth / 2 - greatestX / 2
	for _, itemEntry in ipairs(itemEntries) do
		if nameToItem[itemEntry.name] then
			Infinity_SetArea(itemEntry.name, centerXStart + (itemEntry.x or 0), itemEntry.y, itemEntry.width, itemEntry.height)
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

	Infinity_PopMenu("B3Spell_Menu")
	local castFunction = (B3Spell_CheatMode and B3Spell_CheatCastFunctions or B3Spell_CastFunctions)[B3Spell_Mode]

	if B3Spell_Mode == B3Spell_Modes.Normal then
		castFunction(spellData.spellResref, 2)
	elseif B3Spell_Mode == B3Spell_Modes.Innate then
		castFunction(spellData.spellResref, 4)
	else
		castFunction(spellData.spellResref)
	end
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

		B3Spell_ActionbarDisable = true

		local screenWidth, screenHeight = Infinity_GetScreenSize()

		Infinity_SetArea('B3Spell_Menu_ExitBackground', nil, nil, screenWidth, screenHeight)
		Infinity_SetArea('B3Spell_Menu_ExitBackgroundDark', nil, nil, screenWidth + 4, screenHeight + 4)
		Infinity_SetArea('B3Spell_Menu_OptionsButton', screenWidth - B3Spell_SidebarWidth - 72, nil, nil, nil)

		B3Spell_OldSearchEdit = ''
		B3Spell_SearchEdit = ''

		B3Spell_FillSpellListInfo()
		B3Spell_InitializeSlots()

	end
end

function B3Spell_Menu_OnClose()

	if not B3Spell_SlotsSuppressOnClose then

		if B3Spell_AutoPause == 1 and not B3Spell_PausedOnOpen and worldScreen:CheckIfPaused() then
			worldScreen:TogglePauseGame(true)
		end

		B3Spell_ActionbarDisable = false
	end
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
	return B3Spell_DarkenBackground == 0
end

function B3Spell_Menu_ExitBackground_Action()
	B3Spell_UnselectCurrentButton()
	Infinity_PopMenu('B3Spell_Menu')
end

-------------------------------------
-- B3Spell_Menu_ExitBackgroundDark --
-------------------------------------

function B3Spell_Menu_ExitBackgroundDark_Enabled()
	return B3Spell_DarkenBackground == 1
end

function B3Spell_Menu_ExitBackgroundDark_Action()
	B3Spell_UnselectCurrentButton()
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
	B3Spell_SlotSize = B3Spell_SlotSizeSlider + B3Spell_SlotSizeMinimum
	B3Spell_SliderChangeQueued = true
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

--------------------------------
-- B3Spell_Menu_OptionsButton --
--------------------------------

function B3Spell_Menu_OptionsButton_Action()
	B3Spell_SlotsSuppressOnClose = true
	Infinity_PopMenu('B3Spell_Menu')
	B3Spell_SlotsSuppressOnClose = false
	Infinity_PushMenu('B3Spell_Menu_Options')
end

----------------------------------
-- B3Spell_Menu_FilterSlotsMage --
----------------------------------

function B3Spell_Menu_FilterSlotsMage_Enabled()
	return B3Spell_DisableControlBar == 0
end

function B3Spell_Menu_FilterSlotsMage_Action()
	B3Spell_FilterSpellListInfoMage()
	B3Spell_OldSearchEdit = ''
	B3Spell_SearchEdit = ''
end

---------------------------------
-- B3Spell_Menu_FilterSlotsAll --
---------------------------------

function B3Spell_Menu_FilterSlotsAll_Enabled()
	return B3Spell_DisableControlBar == 0
end

function B3Spell_Menu_FilterSlotsAll_Action()
	B3Spell_FilterSpellListInfoAll()
	B3Spell_OldSearchEdit = ''
	B3Spell_SearchEdit = ''
end

------------------------------------
-- B3Spell_Menu_FilterSlotsCleric --
------------------------------------

function B3Spell_Menu_FilterSlotsCleric_Enabled()
	return B3Spell_DisableControlBar == 0
end

function B3Spell_Menu_FilterSlotsCleric_Action()
	B3Spell_FilterSpellListInfoCleric()
	B3Spell_OldSearchEdit = ''
	B3Spell_SearchEdit = ''
end

--------------------------------
-- B3Spell_Menu_MoveSlotsLeft --
--------------------------------

function B3Spell_Menu_MoveSlotsLeft_Enabled()
	return B3Spell_DisableControlBar == 0 and B3Spell_AlignCenter == 1
end

function B3Spell_Menu_MoveSlotsLeft_Action()
	B3Spell_SetAlignCenter(0)
	B3Spell_InitializeSlots()
end

---------------------------------
-- B3Spell_Menu_MoveSlotsRight --
---------------------------------

function B3Spell_Menu_MoveSlotsRight_Enabled()
	return B3Spell_DisableControlBar == 0 and B3Spell_AlignCenter == 0
end

function B3Spell_Menu_MoveSlotsRight_Action()
	B3Spell_SetAlignCenter(1)
	B3Spell_InitializeSlots()
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

B3Spell_Options_SlotsNeedReinit = false

B3Spell_Options = {
	{B3Spell_Tooltip_Auto_Pause,
		["set"] = function(newVal) B3Spell_AutoPause = newVal end,
		["get"] = function() return B3Spell_AutoPause end,
		["write"] = function() Infinity_SetINIValue('Bubbs Spell Menu Extended', 'Auto-Pause', B3Spell_AutoPause) end,
	},
	{B3Spell_Tooltip_Automatically_Focus_Search_Bar,
		["set"] = function(newVal) B3Spell_AutoFocusSearchBar = newVal end,
		["get"] = function() return B3Spell_AutoFocusSearchBar end,
		["write"] = function() Infinity_SetINIValue('Bubbs Spell Menu Extended', 'Automatically Focus Search Bar', B3Spell_AutoFocusSearchBar) end,
	},
	{B3Spell_Tooltip_Automatically_Optimize_Slot_Size,
		["set"] = function(newVal) B3Spell_AutomaticallyOptimizeSlotSize = newVal end,
		["get"] = function() return B3Spell_AutomaticallyOptimizeSlotSize end,
		["write"] = function() Infinity_SetINIValue('Bubbs Spell Menu Extended', 'Automatically Optimize Slot Size', B3Spell_AutomaticallyOptimizeSlotSize) end,
	},
	{B3Spell_Tooltip_Darken_Background,
		["set"] = function(newVal) B3Spell_DarkenBackground = newVal end,
		["get"] = function() return B3Spell_DarkenBackground end,
		["write"] = function() Infinity_SetINIValue('Bubbs Spell Menu Extended', 'Darken Background', B3Spell_DarkenBackground) end
	},
	{B3Spell_Tooltip_Disable_Control_Bar,
		["set"] = function(newVal) B3Spell_DisableControlBar = newVal end,
		["get"] = function() return B3Spell_DisableControlBar end,
		["write"] = function() Infinity_SetINIValue('Bubbs Spell Menu Extended', 'Disable Control Bar', B3Spell_DisableControlBar) end,
		["onChange"] = function() B3Spell_Options_SlotsNeedReinit = true end,
	},
	{B3Spell_Tooltip_Disable_Search_Bar,
		["set"] = function(newVal) B3Spell_DisableSearchBar = newVal end,
		["get"] = function() return B3Spell_DisableSearchBar end,
		["write"] = function() Infinity_SetINIValue('Bubbs Spell Menu Extended', 'Disable Search Bar', B3Spell_DisableSearchBar) end,
		["onChange"] = function() B3Spell_Options_SlotsNeedReinit = true end,
	},
	{B3Spell_Tooltip_Ignore_Special_Abilities,
		["set"] = function(newVal) B3Spell_IgnoreSpecialAbilities = newVal end,
		["get"] = function() return B3Spell_IgnoreSpecialAbilities end,
		["write"] = function() Infinity_SetINIValue('Bubbs Spell Menu Extended', 'Ignore Special Abilities', B3Spell_IgnoreSpecialAbilities) end,
	},
	{B3Spell_Tooltip_Modal,
		["set"] = function(newVal) B3Spell_Modal = newVal end,
		["get"] = function() return B3Spell_Modal end,
		["write"] = function() Infinity_SetINIValue('Bubbs Spell Menu Extended', 'Modal', B3Spell_Modal) end,
	},
	{B3Spell_Tooltip_Show_Key_Bindings,
		["set"] = function(newVal) B3Spell_ShowKeyBindings = newVal end,
		["get"] = function() return B3Spell_ShowKeyBindings end,
		["write"] = function() Infinity_SetINIValue('Bubbs Spell Menu Extended', 'Show Key Bindings', B3Spell_ShowKeyBindings) end,
		["onChange"] = function() B3Spell_Options_SlotsNeedReinit = true end,
	},
}

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

	for _, option in ipairs(B3Spell_Options) do
		option.old = option.get()
	end

	B3Spell_DestroyInstances('B3Spell_Menu_Options')

	local screenW, screenH = Infinity_GetScreenSize()
	Infinity_SetArea('B3Spell_Menu_Options_ExitBackground', nil, nil, screenW, screenH)
	Infinity_SetArea('B3Spell_Menu_Options_ExitBackgroundDark', nil, nil, screenW + 4, screenH + 4)

	local font = styles["normal"].font
	local fontPoint = styles["normal"].point

	local oneLineHeight = Infinity_GetContentHeight(font, 0, '', fontPoint, 0)
	local textData = {}

	local currentY = 8
	local maxWidth = 0

	for _, option in ipairs(B3Spell_Options) do
		local textW, textH = B3Spell_GetTextWidthHeight(font, fontPoint, option[1])
		if textW > maxWidth then maxWidth = textW end
		table.insert(textData, {['text'] = option[1], ['yOffset'] = currentY, ['w'] = textW, ['h'] = textH})
		currentY = currentY + textH + 20
	end

	local backgroundWidth = maxWidth + 87
	local backgroundHeight = (oneLineHeight + 20) * #B3Spell_Options + 37

	local startingX = (screenW - backgroundWidth) / 2
	local startingY = (screenH - backgroundHeight) / 2

	Infinity_SetArea('B3Spell_Menu_Options_OptionsBackground', startingX, startingY, backgroundWidth, backgroundHeight)

	local innerOffsetX = 23
	local innerOffsetY = 22

	for i, data in ipairs(textData) do
		B3Spell_CreateText(data.text, startingX + innerOffsetX, startingY + data.yOffset + innerOffsetY, data.w, data.h)
	end

	currentY = startingY + innerOffsetY
	local toggleX = startingX + maxWidth + 10 + innerOffsetX
	for _, option in ipairs(B3Spell_Options) do
		B3Spell_CreateToggle(option, toggleX, currentY, 32, 32)
		currentY = currentY + oneLineHeight + 20
	end

end

function B3Spell_Menu_Options_OnClose()

	for _, option in ipairs(B3Spell_Options) do
		option.write()
		if option.onChange and option.get() ~= option.old then
			option.onChange()
		end
	end

	if B3Spell_Options_SlotsNeedReinit then
		B3Spell_Options_SlotsNeedReinit = false
		B3Spell_InitializeSlots()
	end

	B3Spell_SlotsSuppressOnOpen = true
	Infinity_PushMenu('B3Spell_Menu')
	B3Spell_SlotsSuppressOnOpen = false
end

function B3Spell_Menu_Options_Modal()
	return B3Spell_Modal == 1
end

-----------------------------------------
-- B3Spell_Menu_Options_ExitBackground --
-----------------------------------------

function B3Spell_Menu_Options_ExitBackground_Enabled()
	return B3Spell_DarkenBackground == 0
end

function B3Spell_Menu_Options_ExitBackground_Action()
	Infinity_PopMenu('B3Spell_Menu_Options')
end

---------------------------------------------
-- B3Spell_Menu_Options_ExitBackgroundDark --
---------------------------------------------

function B3Spell_Menu_Options_ExitBackgroundDark_Enabled()
	return B3Spell_DarkenBackground == 1
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
	return B3Spell_InstanceIDs['B3Spell_Menu_Options']['TEMPLATE_B3Spell_Menu_Options_Toggle'].instanceData[instanceId].optionData.get() == 0 and 0 or 2
end

function B3Spell_Menu_Options_TEMPLATE_Toggle_Action()
	local optionData = B3Spell_InstanceIDs['B3Spell_Menu_Options']['TEMPLATE_B3Spell_Menu_Options_Toggle'].instanceData[instanceId].optionData
	optionData.set(optionData.get() == 0 and 1 or 0)
end
