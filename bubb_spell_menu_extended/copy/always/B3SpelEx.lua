
B3Spell_DebugDisable = false

-----------------
-- Keybindings --
-----------------

-- Replace "" with the key you want to use to open the corresponding menu.
-- Example: B3Spell_CastSpellKey = "f"
B3Spell_CastSpellKey = ""
B3Spell_CastInnateKey = ""
B3Spell_ToggleSearchBarFocusKey = EEex_Key_GetFromName("Left Ctrl")

function B3Spell_KeyPressedListener(keyPressed)

	if worldScreen ~= e:GetActiveEngine() or not Infinity_IsMenuOnStack("WORLD_ACTIONBAR") then
		return
	end

	if Infinity_IsMenuOnStack("B3Spell_Menu") then

		if Infinity_TextEditHasFocus() == 0 then

			-- Preempt the world screen and handle spell keybindings myself
			-- whenever the spell menu is open. This is to make sure the
			-- spell menu is "in the loop" about the spell being cast.
			local spellData = B3Spell_KeyToSpellData[keyPressed]
			if spellData then
				B3Spell_CastSpellData(spellData)
				return true -- consume keypress so world screen doesn't see it
			elseif keyPressed == B3Spell_ToggleSearchBarFocusKey then
				B3Spell_Menu_AttemptFocusSearchBar()
				return
			end

		elseif keyPressed == B3Spell_ToggleSearchBarFocusKey and B3Spell_IsSearchBarCaptured() then
			Infinity_FocusTextEdit()
			return
		end

		if B3Spell_AlwaysOpen == 0 then
			return
		end

	elseif Infinity_IsMenuOnStack("B3Spell_Menu_Options") or Infinity_IsMenuOnStack("B3Spell_Menu_SelectSlotArea") then
		return
	end

	local keyToCode = function(string)
		return #string ~= 0 and string:byte() or -1
	end

	local keyToType = {
		[keyToCode(B3Spell_CastSpellKey)] = 3,
		[keyToCode(B3Spell_CastInnateKey)] = 10,
	}

	local typeToPress = keyToType[keyPressed]
	if typeToPress then
		for i = 0, 11, 1 do
			if buttonArray:GetButtonType(i) == typeToPress then
				buttonArray:OnLButtonPressed(i)
			end
		end
	end
end
EEex_Key_AddPressedListener(B3Spell_KeyPressedListener)

--------------------
-- Hook Actionbar --
--------------------

function B3Spell_CheckActionbarButtonHighlightState(mode)
	if mode == B3Spell_Modes.Quick then
		-- If quick-spell selection was resumed, (say, if the sprite was deselected then selected again),
		-- highlight the corresponding quick spell button again.
		B3Spell_HighlightQuickSpellButton()
	end
end

function B3Spell_ReactToActionbar(config, state, manualReopen)

	if B3Spell_DebugDisable or (e:GetActiveEngine() == worldScreen and EEex_Area_GetVisible() == nil) then
		-- This happens when quickloading - calling Infinity_PushMenu() / Infinity_PopMenu() while in this state CRASHES THE GAME.
		return false
	end

	local selectedList = EngineGlobals.g_pBaldurChitin.m_pObjectGame.m_group.m_memberList
	if selectedList.m_nCount ~= 1 then
		Infinity_PopMenu("B3Spell_Menu")
		return false
	end

	if EEex_Actionbar_IsThievingHotkeyOpeningSpecialAbilities() or not Infinity_IsMenuOnStack("WORLD_ACTIONBAR") then
		return false
	end

	if config == 23 and B3Spell_IgnoreSpecialAbilities == 1 and B3Spell_AlwaysOpen == 1 then
		-- Pop the spell menu if it is in "Always Open" mode and special abilities are ignored
		Infinity_PopMenu("B3Spell_Menu")
		return false
	end

	local spriteID = selectedList.m_pNodeHead.data

	-- Cast Spell               = 21, State(s) 102(Quick) and 103
	-- Special Abilities        = 23, State(s) 106
	-- Opcode #214              = 28, State(s) 111
	-- Cast Spell - Cleric/Mage = 30, State(s) 113 and 114(Quick)

	local quickStates = {
		[102] = true,
		[114] = true,
	}

	local decideMode = function()

		local toReturn = nil

		local castConfigs = {
			[21] = true,
			[30] = true,
		}

		-- Select mode based on the current actionbar state
		if     quickStates[state]  then toReturn = B3Spell_Modes.Quick
		elseif castConfigs[config] then toReturn = B3Spell_MonolithicDisplayMode == 0 and B3Spell_Modes.Normal or B3Spell_Modes.Monolithic
		elseif config == 23        then toReturn = B3Spell_MonolithicDisplayMode == 0 and B3Spell_Modes.Innate or B3Spell_Modes.Monolithic
		elseif config == 28        then toReturn = B3Spell_Modes.Opcode214
		else
			-- Actionbar isn't in a state that opens the spell menu, and yet I'm launching... I must
			-- be operating under the "Always Open" option - attempt to open the previous mode.
			toReturn = B3Spell_GetTransferMode(spriteID)
		end

		B3Spell_CheckActionbarButtonHighlightState(toReturn)
		return toReturn
	end

	local restoreActionbar = function()
		if not quickStates[state] then
			B3Spell_UnselectCurrentButton()
		end
		EEex_Actionbar_RestoreLastState()
	end

	local launchedFromActionbar = ({
		[21] = true,                                -- Cast Spell
		[23] = B3Spell_IgnoreSpecialAbilities == 0, -- Special Abilities
		[28] = true,                                -- Opcode #214
		[30] = true,                                -- Cast Spell - Cleric/Mage
	})[config]

	local toReturn = false

	if B3Spell_AlwaysOpen == 1 then
		-- "Always Open" mode
		toReturn = B3Spell_LaunchSpellMenu(decideMode(), spriteID)
		if launchedFromActionbar then
			restoreActionbar()
		end

	elseif launchedFromActionbar then
		-- Not "Always Open" mode, but the menu was invoked by the actionbar
		toReturn = B3Spell_LaunchSpellMenu(decideMode(), spriteID)
		restoreActionbar()

	elseif manualReopen or Infinity_IsMenuOnStack("B3Spell_Menu") then
		-- Not "Always Open" mode, not invoked by the actionbar, but the menu was already open.
		-- Somehow the user bypassed the exit background and altered the actionbar state. Just
		-- relaunch the menu to update it.
		toReturn = B3Spell_LaunchSpellMenu(decideMode(), spriteID)
	end

	return toReturn
end

function B3Spell_ActionbarListener(config, state)
	B3Spell_ReactToActionbar(config, state)
end
EEex_Actionbar_AddListener(B3Spell_ActionbarListener)

-- This should be a part of EEex
function B3Spell_GetActionbarConfigFromState(state)
	return ({
		[1]   = 0,  -- Mage / Sorcerer
		[2]   = 1,  -- Fighter
		[3]   = 2,  -- Cleric
		[4]   = 3,  -- Thief
		[5]   = 4,  -- Bard
		[6]   = 5,  -- Paladin
		[7]   = 6,  -- Fighter Mage
		[8]   = 7,  -- Fighter Cleric
		[9]   = 8,  -- Fighter Thief
		[10]  = 9,  -- Fighter Mage Thief
		[11]  = 10, -- Druid
		[12]  = 11, -- Ranger
		[13]  = 12, -- Mage Thief
		[14]  = 13, -- Cleric Mage
		[15]  = 14, -- Cleric Thief
		[16]  = 15, -- Fighter Druid
		[17]  = 16, -- Fighter Mage Cleric
		[18]  = 17, -- Cleric Ranger
		[20]  = 18, -- Monk
		[21]  = 19, -- Shaman
		[101] = 20, -- Select Weapon Ability
		[102] = 21, -- Spells (Select Quick Spell)
		[103] = 21, -- Spells (Cast)
		[104] = 22, -- Select Quick Item Ability
		[105] = 22, -- Use Item
		[106] = 23, -- Special Abilities
		[107] = 24, -- Select Quick Formation
		[108] = 25, -- Defunct Select Quick Formation (Not used)
		[109] = 26, -- Group Selected
		[110] = 27, -- Unknown (No buttons defined; not used?)
		[111] = 28, -- Internal List (Opcode #214)
		[112] = 29, -- Controlled (Class doesn't have a dedicated state)
		[113] = 30, -- Cleric / Mage Spells (Cast)
		[114] = 30, -- Cleric / Mage Spells (Select Quick Spell)
	})[state]
end

function B3Spell_AttemptLaunchSpellMenu(manualReopen)
	local state = EEex_Actionbar_GetState()
	return B3Spell_ReactToActionbar(B3Spell_GetActionbarConfigFromState(state), state, manualReopen)
end

function B3Spell_OnActionbarOpened()
	B3Spell_AttemptLaunchSpellMenu()
end

function B3Spell_OnActionbarClosed()
	-- "B3Spell_Menu_SelectSlotArea" has to be popped before "B3Spell_Menu_Options", since it opens "B3Spell_Menu_Options" on close
	Infinity_PopMenu("B3Spell_Menu_SelectSlotArea")
	-- "B3Spell_Menu_Options" has to be popped before "B3Spell_Menu", since it opens "B3Spell_Menu" on close
	Infinity_PopMenu("B3Spell_Menu_Options")
	Infinity_PopMenu("B3Spell_Menu")
end

function B3Spell_IsSpellMenuOpenForSprite(sprite)
	return sprite.m_id == B3Spell_SpriteID and Infinity_IsMenuOnStack("B3Spell_Menu")
end

function B3Spell_OnSpellCountChanged(sprite, resref, changeAmount)
	if not B3Spell_IsSpellMenuOpenForSprite(sprite) then return end
	B3Spell_UpdateSpellCastableCount(resref, changeAmount)
end
EEex_Sprite_AddQuickListsCheckedListener(B3Spell_OnSpellCountChanged)

function B3Spell_OnSpellCountsReset(sprite)
	if not B3Spell_IsSpellMenuOpenForSprite(sprite) then return end
	B3Spell_ResetSpellCastableCounts()
end
EEex_Sprite_AddQuickListCountsResetListener(B3Spell_OnSpellCountsReset)

function B3Spell_OnSpellRemoved(sprite, resref)
	if not B3Spell_IsSpellMenuOpenForSprite(sprite) then return end
	B3Spell_RefreshMenu()
end
EEex_Sprite_AddQuickListNotifyRemovedListener(B3Spell_OnSpellRemoved)

function B3Spell_OnSpellDisableStateChanged(sprite)
	if not B3Spell_IsSpellMenuOpenForSprite(sprite) then return end
	B3Spell_RefreshMenu()
end
EEex_Sprite_AddSpellDisableStateChangedListener(B3Spell_OnSpellDisableStateChanged)

function B3Spell_OnGameDestroyed()
	-- Reset these global variables when a game is destroyed so
	-- they don't confuse the spell menu on next loaded save
	B3Spell_SpriteID = nil
	B3Spell_Mode = B3Spell_GetDefaultMode()
end
EEex_GameState_AddDestroyedListener(B3Spell_OnGameDestroyed)

-----------------------
-- General Functions --
-----------------------

-- Used in M_B3Spel.lua
function B3Spell_IsCaptureActive()
	return EngineGlobals.capture.item ~= nil
end

-- Internal to this file
function B3Spell_IsSearchBarCaptured()
	local captured = EngineGlobals.capture.item
	return captured ~= nil and EEex_UDToLightUD(captured) == nameToItem["B3Spell_Menu_Search"]
end

---------------
-- Hook Menu --
---------------

function B3Spell_OnWindowSizeChanged(screenW, screenH)
	B3Spell_ValidateSlotsArea(screenW, screenH)
end
EEex_Menu_AddWindowSizeChangedListener(B3Spell_OnWindowSizeChanged)

function B3Spell_DrawSelectSlotsAreaRect(item)
	EEex.DrawSlicedRect("B3Spell_SelectSlotsAreaRect", {item:getArea()})
end

EEex_Once("B3SpelEx_Once", function()
	EEex.RegisterSlicedRect("B3Spell_SelectSlotsAreaRect", {
		["topLeft"]     = {0x00, 0x00, 0x40, 0x40},
		["top"]         = {0x40, 0x00, 0x80, 0x40},
		["topRight"]    = {0xC0, 0x00, 0x40, 0x40},
		["right"]       = {0xC0, 0x40, 0x40, 0x80},
		["bottomRight"] = {0xC0, 0xC0, 0x40, 0x40},
		["bottom"]      = {0x40, 0xC0, 0x80, 0x40},
		["bottomLeft"]  = {0x00, 0xC0, 0x40, 0x40},
		["left"]        = {0x00, 0x40, 0x40, 0x80},
		["center"]      = {0x80, 0x80, 0x02, 0x02},
		["dimensions"]  = {0x100, 0x100},
		["resref"]      = "B3SPLBOX",
		["flags"]       = 1,
	})
	EEex_Menu_AddBeforeUIItemRenderListener("B3Spell_Menu_SelectSlotArea_Rect", B3Spell_DrawSelectSlotsAreaRect)
end)

function B3Spell_InstallActionbarEnabledHook()

	EEex_Menu_LoadFile("B3Spell")

	local menu = EEex_Menu_Find("WORLD_ACTIONBAR")

	local listenToEngineEvent = function(eventRef, listener)
		local oldFunc = EEex_Menu_GetItemFunction(eventRef) or function() end
		EEex_Menu_SetItemFunction(eventRef, function()
			oldFunc()
			listener()
		end)
	end

	listenToEngineEvent(menu.reference_onOpen, B3Spell_OnActionbarOpened)
	listenToEngineEvent(menu.reference_onClose, B3Spell_OnActionbarClosed)

	local item = menu.items

	while item do
		local actionbar = item.button.actionBar
		if actionbar then
			local enabledRef = item.reference_enabled
			local oldEnable = EEex_Menu_GetItemFunction(enabledRef) or function() return true end
			EEex_Menu_SetItemFunction(enabledRef, function()
				return not B3Spell_ActionbarDisable and oldEnable()
			end)
		end
		item = item.next
	end
end
EEex_Menu_AddMainFileLoadedListener(B3Spell_InstallActionbarEnabledHook)

---------------------------------
-- Softcoded Actionbar Actions --
---------------------------------

-- Internal to this file
function B3Spell_HighlightQuickSpellButton()
	local actionbarArray = EEex_Actionbar_GetArray()
	actionbarArray.m_nSelectedButton = EEex_Actionbar_ButtonType.QUICK_SPELL_1 + actionbarArray.m_quickButtonToConfigure
end

-- Internal to this file
function B3Spell_UnselectCurrentButton()
	EEex_Actionbar_GetArray().m_nSelectedButton = CButtonType.NONE
end

-- Internal to this file
function B3Spell_SetQuickSlot(m_CButtonData, nButton, nType)
	EEex_CInfButtonArray.SetQuickSlot(m_CButtonData, nButton, nType)
end

-- Internal to this file
function B3Spell_UseCGameButtonList(m_CGameSprite, m_CGameButtonList, resref, offInternal)

	local found = false

	EEex_Utility_IterateCPtrList(m_CGameButtonList, function(m_CButtonData)
		local m_res = m_CButtonData.m_abilityId.m_res:get()
		if m_res == resref then
			if not offInternal then
				m_CGameSprite:ReadySpell(m_CButtonData, 0)
			else
				m_CGameSprite:ReadyOffInternalList(m_CButtonData, 0)
			end
			found = true
			return true -- breaks out of EEex_Utility_IterateCPtrList()
		end
	end)

	EEex_Utility_FreeCPtrList(m_CGameButtonList)
	return found
end

-- Used in M_B3Spel.lua
function B3Spell_CheckHighlightModeButton(mode)

	local cursorState = EngineGlobals.g_pBaldurChitin.m_pObjectGame.m_nState

	if     cursorState == 1 -- Any point within range (4)
		or cursorState == 2 -- Living actor (1) / Dead actor (3)
	then
		local highlightButtonTypeMap = {
			[B3Spell_Modes.Normal]    = EEex_Actionbar_ButtonType.CAST_SPELL,
			[B3Spell_Modes.Innate]    = EEex_Actionbar_ButtonType.SPECIAL_ABILITIES,
			[B3Spell_Modes.Quick]     = EEex_Actionbar_ButtonType.CAST_SPELL,
		}

		local highlightButtonType = mode == B3Spell_Modes.Opcode214
			and highlightButtonTypeMap[B3Spell_Mode] -- op214 should have already reverted the spell menu mode
			or  highlightButtonTypeMap[mode]

		if highlightButtonType then
			EEex_Actionbar_GetArray().m_nSelectedButton = highlightButtonType
		end
	end
end

-- Used in M_B3Spel.lua
function B3Spell_IsThievingDisabled()
	local object = EEex_GameObject_GetSelected()
	if not object or not object:isSprite() then return false end
	return object:getActiveStats().m_disabledButtons:get(EEex_DerivedStats_DisabledButtonType.BUTTON_THIEVING) == 1
end

-- Used in M_B3Spel.lua
function B3Spell_DoThieving()
	local game = EEex_EngineGlobal_CBaldurChitin.m_pObjectGame
	game:SetState(2, false)
	game:SetIconIndex(0x24)
end

-- Used in M_B3Spel.lua
function B3Spell_CastResref(resref, buttonType)
	if worldScreen == e:GetActiveEngine() then
		local object = EEex_GameObject_GetSelected()
		if object:isSprite() then
			local spellButtonDataList = object:GetQuickButtons(buttonType, 0)
			B3Spell_UseCGameButtonList(object, spellButtonDataList, resref, false)
		end
	end
end

-- Used in M_B3Spel.lua
function B3Spell_CastResrefInternal(resref)
	if worldScreen == e:GetActiveEngine() then
		local object = EEex_GameObject_GetSelected()
		if object:isSprite() then
			B3Spell_UseCGameButtonList(object, object:GetInternalButtonList(), resref, true)
		end
	end
end

-- Used in M_B3Spel.lua
function B3Spell_SetQuickSlotToResref(resref, quickButtonType)

	if worldScreen == e:GetActiveEngine() then

		local object = EEex_GameObject_GetSelected()
		if object:isSprite() then

			local m_CGameButtonList = object:GetQuickButtons(quickButtonType, 0)

			EEex_Utility_IterateCPtrList(m_CGameButtonList, function(m_CButtonData)
				local m_res = m_CButtonData.m_abilityId.m_res:get()
				if m_res == resref then
					B3Spell_SetQuickSlot(m_CButtonData, EEex_Actionbar_GetArray().m_quickButtonToConfigure, 2)
					object:ReadySpell(m_CButtonData, 1)
					return true -- breaks out of EEex_Utility_IterateCPtrList()
				end
			end)

			EEex_Utility_FreeCPtrList(m_CGameButtonList)
		end
	end
end

------------------------------------------------------------------------------------------------------------------------
-- Filling B3Spell_SpellListInfo / B3Spell_SpellResrefToData / B3Spell_KeyToSpellData / B3Spell_FilteredSpellListInfo --
------------------------------------------------------------------------------------------------------------------------

-- Used in M_B3Spel.lua
function B3Spell_FillSpellListInfo()
	(B3Spell_CheatMode and B3Spell_CheatFillFunctions or B3Spell_FillFunctions)[B3Spell_Mode]()
end

function B3Spell_FillFromMemorized()

	B3Spell_SpellListInfo = {}
	B3Spell_SpellResrefToData = {}
	B3Spell_KeyToSpellData = {}
	local belowSpellsIndex = nil
	local levelToIndex = {}
	local aboveSpellsIndex = nil

	-- Every level table is filled with a number of spell entries:
	--     ["spellCastableCount"] = The number of times the spell can still be cast,
	--     ["spellIcon"]          = The icon displayed for the spell in the actionbar,
	--     ["spellLevel"]         = The spell's level,
	--     ["spellName"]          = The spell's true name,
	--     ["spellResref"]        = The spell's resref,
	--     ["spellType"]          = The spell's type: Special (0), Wizard (1), Priest (2), Psionic (3), Innate (4), Bard song (5)

	local sprite = EEex_GameObject_GetSelected()
	if not sprite:isSprite() then
		error("[B3Spell_FillSpellListInfo] (ASSERT) Invalid actorID")
		return
	end

	local spellNameToKey = B3Spell_CacheSpellNameToKeyBindings()

	local buttonType = nil
	if B3Spell_Mode == B3Spell_Modes.Innate or B3Spell_Mode == B3Spell_Modes.Monolithic then

		-- Cleric-thief abilities row
		if sprite:getClass() == 15 then

			local thievingTooltip = Infinity_FetchString(0xF000E2)
			local levelToFill = {
				["infoMode"] = B3Spell_InfoModes.Abilities,
			}

			if not B3Spell_IsThievingDisabled() then
				table.insert(levelToFill, {
					["bam"] = "GUIBTACT",
					["frame"] = 26,
					["disableTint"] = false,
					["tooltip"] = thievingTooltip,
					["func"] = function()
						if B3Spell_AlwaysOpen == 0 then
							Infinity_PopMenu("B3Spell_Menu")
						end
						B3Spell_DoThieving()
						EEex_Actionbar_GetArray().m_nSelectedButton = EEex_Actionbar_ButtonType.SPECIAL_ABILITIES
					end,
				})
			else
				table.insert(levelToFill, {
					["bam"] = "GUIBTACT",
					["frame"] = 26,
					["disableTint"] = true,
					["tooltip"] = thievingTooltip,
					["func"] = function() end,
				})
			end

			table.insert(B3Spell_SpellListInfo, levelToFill)
		end
	end

	local fillFromQuickButtons = function(quickButtons, actualModeType, quickButtonType)

		EEex_Utility_IterateCPtrList(quickButtons, function(m_CButtonData)

			local resref = m_CButtonData.m_abilityId.m_res:get()

			if resref ~= "" then

				local abilityNum = m_CButtonData.m_abilityId.m_abilityNum

				if abilityNum == -1 then

					local nameStrref = m_CButtonData.m_name
					local name = Infinity_FetchString(nameStrref)

					local spellHeader = EEex_Resource_Demand(resref, "SPL")
					local level = spellHeader.spellLevel

					local levelToFill = {}

					if level <= 0 then

						if not belowSpellsIndex then
							levelToFill = {
								["infoMode"] = B3Spell_InfoModes.BelowSpells,
							}
							belowSpellsIndex = #B3Spell_SpellListInfo + 1
							table.insert(B3Spell_SpellListInfo, levelToFill)
						else
							levelToFill = B3Spell_SpellListInfo[belowSpellsIndex]
						end

					elseif level <= 9 then

						local levelInfoIndex = levelToIndex[level]
						if not levelInfoIndex then
							levelToFill = {
								["infoMode"] = B3Spell_InfoModes.Spells,
								["spellLevel"] = level,
							}
							levelToIndex[level] = #B3Spell_SpellListInfo + 1
							table.insert(B3Spell_SpellListInfo, levelToFill)
						else
							levelToFill = B3Spell_SpellListInfo[levelInfoIndex]
						end

					else

						if not aboveSpellsIndex then
							levelToFill = {
								["infoMode"] = B3Spell_InfoModes.AboveSpells,
							}
							aboveSpellsIndex = #B3Spell_SpellListInfo + 1
							table.insert(B3Spell_SpellListInfo, levelToFill)
						else
							levelToFill = B3Spell_SpellListInfo[aboveSpellsIndex]
						end

					end

					-- if B3Spell_Mode == B3Spell_Modes.Monolithic then
					-- 	if quickButtonType == 2 then
					-- 		levelToFill.hasNormalHeader = true
					-- 	elseif quickButtonType == 4 then
					-- 		levelToFill.hasInnateHeader = true
					-- 	end
					-- end

					local slotOrderType = B3Spell_SlotOrderTypes.Group1
					local key = spellNameToKey[name]

					if B3Spell_Mode == B3Spell_Modes.Monolithic or B3Spell_Mode == B3Spell_Modes.Quick then
						if B3Spell_MonolithicDisplaySortMode == B3Spell_MonolithicDisplaySortModes.InnatesFirst then
							slotOrderType = quickButtonType == 4 and B3Spell_SlotOrderTypes.Group1 or B3Spell_SlotOrderTypes.Group2
						elseif B3Spell_MonolithicDisplaySortMode == B3Spell_MonolithicDisplaySortModes.SpellsFirst then
							slotOrderType = quickButtonType == 2 and B3Spell_SlotOrderTypes.Group1 or B3Spell_SlotOrderTypes.Group2
						end
					end

					local spellData = {
						["slotOrderType"]        = slotOrderType,
						["spellCastableCount"]   = B3Spell_Mode ~= B3Spell_Modes.Opcode214 and m_CButtonData.m_count or 0,
						["spellDescription"]     = spellHeader.genericDescription,
						["spellDisabled"]        = m_CButtonData.m_bDisabled == 1,
						["spellIcon"]            = m_CButtonData.m_icon:get(),
						["spellKeyBindingName"]  = key and B3Spell_GetKeyBindingKeyName(key) or "",
						["spellLevel"]           = level,
						["spellModeType"]        = actualModeType,
						["spellName"]            = name,
						["spellNameStrref"]      = nameStrref,
						["spellQuickButtonType"] = quickButtonType,
						["spellRealNameStrref"]  = spellHeader.genericName,
						["spellResref"]          = resref,
						["spellType"]            = spellHeader.itemType,
					}

					table.insert(levelToFill, spellData)
					B3Spell_SpellResrefToData[resref] = {
						["spellData"] = spellData,
					}

					if key and not B3Spell_KeyToSpellData[key] then
						B3Spell_KeyToSpellData[key] = spellData
					end
				else
					print("[B3Spell_FillSpellListInfo] (ASSERT) Not implemented, report to @Bubb")
				end
			else
				print("[B3Spell_FillSpellListInfo] (ASSERT) Empty resref, report to @Bubb")
			end
		end)
	end

	local fillFromQuickButtonType = function(quickButtonType, actualModeType)
		fillFromQuickButtons(sprite:GetQuickButtons(quickButtonType, 0), actualModeType, quickButtonType)
	end

	({
		[B3Spell_Modes.Normal] = function()
			fillFromQuickButtonType(2, B3Spell_Modes.Normal)
		end,
		[B3Spell_Modes.Innate] = function()
			fillFromQuickButtonType(4, B3Spell_Modes.Innate)
		end,
		[B3Spell_Modes.Quick] = function()
			fillFromQuickButtonType(2, B3Spell_Modes.Quick)
			fillFromQuickButtonType(4, B3Spell_Modes.Quick)
		end,
		[B3Spell_Modes.Opcode214] = function()
			fillFromQuickButtons(sprite:GetInternalButtonList(), B3Spell_Modes.Opcode214)
		end,
		[B3Spell_Modes.Monolithic] = function()
			fillFromQuickButtonType(2, B3Spell_Modes.Normal)
			fillFromQuickButtonType(4, B3Spell_Modes.Innate)
		end,
	})[B3Spell_Mode]()

	-- for _, levelToFill in ipairs(B3Spell_SpellListInfo) do
	-- 	if levelToFill.hasNormalHeader then
	-- 		table.insert(levelToFill, {
	-- 			["slotOrderType"] = B3Spell_SlotOrderTypes.InlineHeader1,
	-- 			["bam"] = "GUIBTACT",
	-- 			["frame"] = 12,
	-- 		})
	-- 	end
	-- 	if levelToFill.hasInnateHeader then
	-- 		table.insert(levelToFill, {
	-- 			["slotOrderType"] = B3Spell_SlotOrderTypes.InlineHeader2,
	-- 			["bam"] = "GUIBTACT",
	-- 			["frame"] = 38,
	-- 		})
	-- 	end
	-- end

	table.sort(B3Spell_SpellListInfo, function(a, b)
		return a.infoMode < b.infoMode or (a.infoMode == B3Spell_InfoModes.Spells and b.infoMode == B3Spell_InfoModes.Spells and a.spellLevel < b.spellLevel)
	end)

	B3Spell_FilteredSpellListInfo = B3Spell_SpellListInfo
	B3Spell_SortFilteredSpellListInfo()
end

-----------
-- Menus --
-----------

-- Used in M_B3Spel.lua
function B3Spell_UpdateSlotPressedState()

	-- The following synchronizes the spell's icon so that it offsets along with the button press.
	-- Have to do this manually, as the coupled-uiItem implementation that
	-- the engine normally uses to render slots isn't exposed.

	local data = B3Spell_InstanceIDs["B3Spell_Menu"]["B3Spell_Menu_TEMPLATE_Action"].instanceData[instanceId]

	if not data.enabled then
		return false
	end

	local capture = EngineGlobals.capture.item

	if capture and capture.templateName:get() == "B3Spell_Menu_TEMPLATE_Action" and capture.instanceId == instanceId then

		if not data.didOffset then

			local slotData = B3Spell_InstanceIDs["B3Spell_Menu"]["B3Spell_Menu_TEMPLATE_Bam"].instanceData[data.pairedSlotID]

			if not RgUISkin then
				slotData.bam = data.isGreen and "B3SLOTGD" or "B3SLOTD"
			else
				-- Infinity UI++
				slotData.bam = data.isGreen and "RGDB3SLX" or "RGDB3SLD"
			end

			EEex_Menu_StoreTemplateInstance("B3Spell_Menu", "B3Spell_Menu_TEMPLATE_Icon", data.pairedIconID, "B3Spell_StoredInstance")
			local iconX, iconY, iconWidth, iconHeight = Infinity_GetArea("B3Spell_StoredInstance")
			Infinity_SetArea("B3Spell_StoredInstance", iconX + 2, iconY + 2, iconWidth - 2, iconHeight - 2)

			EEex_Menu_StoreTemplateInstance("B3Spell_Menu", "B3Spell_Menu_TEMPLATE_Bam", data.pairedInnateMarkerID, "B3Spell_StoredInstance")
			local innateMarkerX, innateMarkerY, _, _ = Infinity_GetArea("B3Spell_StoredInstance")
			Infinity_SetArea("B3Spell_StoredInstance", innateMarkerX + 1, innateMarkerY + 1, nil, nil)

			data.didOffset = true
		end

	elseif data.didOffset then

		local slotData = B3Spell_InstanceIDs["B3Spell_Menu"]["B3Spell_Menu_TEMPLATE_Bam"].instanceData[data.pairedSlotID]

		if not RgUISkin then
			slotData.bam = data.isGreen and "B3SLOTG" or "B3SLOT"
		else
			-- Infinity UI++
			slotData.bam = data.isGreen and "RGDB3SLG" or "RGDB3SL"
		end

		EEex_Menu_StoreTemplateInstance("B3Spell_Menu", "B3Spell_Menu_TEMPLATE_Icon", data.pairedIconID, "B3Spell_StoredInstance")
		local iconX, iconY, iconWidth, iconHeight = Infinity_GetArea("B3Spell_StoredInstance")
		Infinity_SetArea("B3Spell_StoredInstance", iconX - 2, iconY - 2, iconWidth + 2, iconHeight + 2)

		EEex_Menu_StoreTemplateInstance("B3Spell_Menu", "B3Spell_Menu_TEMPLATE_Bam", data.pairedInnateMarkerID, "B3Spell_StoredInstance")
		local innateMarkerX, innateMarkerY, _, _ = Infinity_GetArea("B3Spell_StoredInstance")
		Infinity_SetArea("B3Spell_StoredInstance", innateMarkerX - 1, innateMarkerY - 1, nil, nil)

		data.didOffset = false
	end

	return true

end
