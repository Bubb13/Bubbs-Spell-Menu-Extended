
--------------------
-- Hook Actionbar --
--------------------

function B3Spell_InstallActionbarEnabledHook()

	EEex_LoadMenuFile("B3Spell")

	local actionbarItems = EEex_FindActionbarMenuItems("WORLD_ACTIONBAR")
	for _, actionbarItem in ipairs(actionbarItems) do
		local oldEnable = EEex_GetMenuItemVariantFunction(actionbarItem, "enabled")
		EEex_SetMenuItemVariantFunction(actionbarItem, "enabled", function()
			return not B3Spell_ActionbarDisable and oldEnable()
		end)
	end
end
EEex_AddUIMenuLoadListener(B3Spell_InstallActionbarEnabledHook)

function B3Spell_ActionbarListener(config, state)

	-- Cast Spell               = 21, State(s) 102(Quick) and 103
	-- Special Abilities        = 23, State(s) 106
	-- Opcode #214              = 28, State(s) 111
	-- Cast Spell (cleric/mage) = 30, State(s) 113 and 114(Quick)

	local launchConfigs = {
		[21] = true,
		[23] = true,
		[28] = true,
		[30] = true,
	}

	local launchStates = {
		[102] = true,
		[114] = true,
	}

	if launchConfigs[config] or launchStates[state] then

		local quickStates = {
			[102] = true,
			[114] = true,
		}

		local mode = nil
		-- Please ignore this monstrosity
		if     quickStates[state] then mode = B3Spell_Modes.Quick
		elseif config == 23       then mode = B3Spell_Modes.Innate
		elseif config == 28       then mode = B3Spell_Modes.Opcode214
		else                           mode = B3Spell_Modes.Normal
		end

		EEex_SetActionbarState(EEex_GetLastActionbarState())
		B3Spell_LaunchSpellMenu(mode)
	end
end
EEex_AddActionbarListener(B3Spell_ActionbarListener)

---------------------------------
-- Softcoded Actionbar Actions --
---------------------------------

-- Internal to this file
function B3Spell_GetQuickButtons(m_CGameSprite, buttonType, existanceCheck)
	return EEex_Call(EEex_Label("CGameSprite::GetQuickButtons"), {existanceCheck, buttonType}, m_CGameSprite, 0x0)
end

-- Internal to this file
function B3Spell_SetQuickSlot(m_CGameSprite, m_CButtonData, nButton, nType)
	EEex_Call(EEex_Label("CInfButtonArray::SetQuickSlot"), {nType, nButton, m_CButtonData}, nil, 0xC)
end

-- Internal to this file
function B3Spell_ReadySpell(m_CGameSprite, m_CButtonData, instantUse)
	local stackArgs = {}
	table.insert(stackArgs, instantUse) -- 0 = Cast, 1 = Choose (for quickslot type things)
	for i = 0x30, 0x0, -0x4 do
		table.insert(stackArgs, EEex_ReadDword(m_CButtonData + i))
	end
	EEex_Call(EEex_Label("CGameSprite::ReadySpell"), stackArgs, m_CGameSprite, 0x0)
end

-- Internal to this file
function B3Spell_UseCGameButtonList(m_CGameSprite, m_CGameButtonList, resref, offInternal)

	local found = false
	EEex_IterateCPtrList(m_CGameButtonList, function(m_CButtonData)

		-- m_CButtonData.m_abilityId.m_res
		local m_res = EEex_ReadLString(m_CButtonData + 0x22, 0x8)

		if m_res == resref then

			local stackArgs = {}
			table.insert(stackArgs, 0x0) -- 0 = Cast, 1 = Choose (for quickslot type things)
			for i = 0x30, 0x0, -0x4 do
				table.insert(stackArgs, EEex_ReadDword(m_CButtonData + i))
			end

			if not offInternal then
				EEex_Call(EEex_Label("CGameSprite::ReadySpell"), stackArgs, m_CGameSprite, 0x0)
			else
				EEex_Call(EEex_Label("CGameSprite::ReadyOffInternalList"), stackArgs, m_CGameSprite, 0x0)
			end

			found = true
			return true -- breaks out of EEex_IterateCPtrList()
		end
	end)

	EEex_FreeCPtrList(m_CGameButtonList)
	return found
end

-- Used in M_B3Spel.lua
function B3Spell_UnselectCurrentButton()
	local g_pBaldurChitin = EEex_ReadDword(EEex_Label("g_pBaldurChitin"))
	local m_pObjectGame = EEex_ReadDword(g_pBaldurChitin + EEex_Label("CBaldurChitin::m_pObjectGame"))
	local m_cButtonArray = m_pObjectGame + 0x2654
	EEex_WriteDword(m_cButtonArray + 0x1608, 0x64)
end

-- Used in M_B3Spel.lua
function B3Spell_IsThievingDisabled()
	local actorID = EEex_GetActorIDSelected()
	if not EEex_IsSprite(actorID) then return false end
	local m_CGameSprite = EEex_GetActorShare(actorID)
	local activeStats = EEex_Call(EEex_Label("CGameSprite::GetActiveStats"), {}, m_CGameSprite, 0x0)
	return EEex_ReadDword(activeStats + 0x82C) == 1
end

-- Used in M_B3Spel.lua
function B3Spell_DoThieving()
	local g_pBaldurChitin = EEex_ReadDword(EEex_Label("g_pBaldurChitin"))
	local m_pObjectGame = EEex_ReadDword(g_pBaldurChitin + EEex_Label("CBaldurChitin::m_pObjectGame"))
	EEex_Call(EEex_Label("CInfGame::SetState"), {0x0, 0x2}, m_pObjectGame, 0x0)
	EEex_Call(EEex_Label("CInfGame::SetIconIndex"), {0x24}, m_pObjectGame, 0x0)
	EEex_SetActionbarState(EEex_GetLastActionbarState())
end

-- Used in M_B3Spel.lua
function B3Spell_CastResref(resref, buttonType)
	if worldScreen == e:GetActiveEngine() then
		local actorID = EEex_GetActorIDSelected()
		if EEex_IsSprite(actorID) then
			local m_CGameSprite = EEex_GetActorShare(actorID)
			local spellButtonDataList = B3Spell_GetQuickButtons(m_CGameSprite, buttonType, 0)
			B3Spell_UseCGameButtonList(m_CGameSprite, spellButtonDataList, resref, false)
		end
	end
end

-- Used in M_B3Spel.lua
function B3Spell_CastResrefInternal(resref)
	if worldScreen == e:GetActiveEngine() then
		local actorID = EEex_GetActorIDSelected()
		if EEex_IsSprite(actorID) then
			local m_CGameSprite = EEex_GetActorShare(actorID)
			local spellButtonDataList = EEex_Call(EEex_Label("CGameSprite::GetInternalButtonList"), {}, m_CGameSprite, 0x0)
			B3Spell_UseCGameButtonList(m_CGameSprite, spellButtonDataList, resref, true)
			EEex_SetActionbarState(EEex_GetLastActionbarState())
		end
	end
end

-- Used in M_B3Spel.lua
function B3Spell_SetQuickSlotToResref(resref)

	if worldScreen == e:GetActiveEngine() then

		local actorID = EEex_GetActorIDSelected()
		if EEex_IsSprite(actorID) then

			local m_CGameSprite = EEex_GetActorShare(actorID)
			local m_CGameButtonList = B3Spell_GetQuickButtons(m_CGameSprite, 2, 0)

			EEex_IterateCPtrList(m_CGameButtonList, function(m_CButtonData)

				-- m_CButtonData.m_abilityId.m_res
				local m_res = EEex_ReadLString(m_CButtonData + 0x1C + 0x6, 0x8)

				if m_res == resref then

					-- TODO: Externalize this fetch
					local g_pBaldurChitin = EEex_ReadDword(EEex_Label("g_pBaldurChitin"))
					local m_pObjectGame = EEex_ReadDword(g_pBaldurChitin + EEex_Label("CBaldurChitin::m_pObjectGame"))
					local m_cButtonArray = m_pObjectGame + 0x2654
					local m_quickButtonToConfigure = EEex_ReadDword(m_cButtonArray + 0x1600)
					B3Spell_SetQuickSlot(m_CGameSprite, m_CButtonData, m_quickButtonToConfigure, 2)
					B3Spell_ReadySpell(m_CGameSprite, m_CButtonData, 1)

					return true -- breaks out of EEex_IterateCPtrList()
				end
			end)

			EEex_FreeCPtrList(m_CGameButtonList)
		end
	end
end

-------------------------------------------------------------------
-- Filling B3Spell_SpellListInfo / B3Spell_FilteredSpellListInfo --
-------------------------------------------------------------------

-- Used in M_B3Spel.lua
function B3Spell_FillSpellListInfo()

	B3Spell_SpellListInfo = {[0] = {}, [1] = {}, [2] = {}, [3] = {}, [4] = {}, [5] = {}, [6] = {}, [7] = {}, [8] = {}, [9] = {}}

	-- Every level table is filled with a number of spell entries:
	--     ["spellCastableCount"] = The number of times the spell can still be cast,
	--     ["spellIcon"]          = The icon displayed for the spell in the actionbar,
	--     ["spellLevel"]         = The spell's level,
	--     ["spellName"]          = The spell's true name,
	--     ["spellResref"]        = The spell's resref,
	--     ["spellType"]          = The spell's type: Special (0), Wizard (1), Priest (2), Psionic (3), Innate (4), Bard song (5)

	local actorID = EEex_GetActorIDSelected()
	if not EEex_IsSprite(actorID) then
		error("[B3Spell_FillSpellListInfo] (ASSERT) Invalid actorID")
		return
	end
	local share = EEex_GetActorShare(actorID)

	local buttonType = nil
	if B3Spell_Mode == B3Spell_Modes.Innate then

		-- TODO: Hack (cleric-thief 0th line abilities row)
		if EEex_GetActorClass(actorID) == 15 then

			local thievingTooltip = Infinity_FetchString(0xF000E2)

			if not B3Spell_IsThievingDisabled() then
				table.insert(B3Spell_SpellListInfo[0], {
					["bam"] = "GUIBTACT",
					["frame"] = 26,
					["disableTint"] = false,
					["tooltip"] = thievingTooltip,
					["func"] = function()
						Infinity_PopMenu("B3Spell_Menu")
						B3Spell_DoThieving()
					end,
				})
			else
				table.insert(B3Spell_SpellListInfo[0], {
					["bam"] = "GUIBTACT",
					["frame"] = 26,
					["disableTint"] = true,
					["tooltip"] = thievingTooltip,
					["func"] = function() end,
				})
			end
		end

		buttonType = 4
	else
		buttonType = 2
	end

	local mainSpells = B3Spell_Mode == B3Spell_Modes.Opcode214
		and EEex_Call(EEex_Label("CGameSprite::GetInternalButtonList"), {}, share, 0x0)
		or  B3Spell_GetQuickButtons(share, buttonType, 0)

	EEex_IterateCPtrList(mainSpells, function(m_CButtonData)

		local resref = EEex_ReadLString(m_CButtonData + 0x22, 8)

		if resref ~= "" then

			local abilityNum = EEex_ReadSignedWord(m_CButtonData + 0x20, 0)

			if abilityNum == -1 then

				local nameStrref = EEex_ReadDword(m_CButtonData + 0x8)
				local name = Infinity_FetchString(nameStrref)

				local spellData = EEex_DemandResData(resref, "SPL")
				local level = EEex_ReadDword(spellData + 0x34)

				if level ~= 0 then
					table.insert(B3Spell_SpellListInfo[level], {
						["spellCastableCount"]  = B3Spell_Mode ~= B3Spell_Modes.Opcode214 and EEex_ReadWord(m_CButtonData + 0x18, 0) or 0,
						["spellDescription"]    = EEex_ReadDword(spellData + 0x50),
						["spellDisabled"]       = EEex_ReadByte(m_CButtonData + 0x30, 0) == 1,
						["spellIcon"]           = EEex_ReadLString(m_CButtonData, 0x8),
						["spellLevel"]          = level,
						["spellName"]           = name,
						["spellNameStrref"]     = nameStrref,
						["spellRealNameStrref"] = EEex_ReadDword(spellData + 0x8),
						["spellResref"]         = resref,
						["spellType"]           = EEex_ReadWord(spellData + 0x1C, 0),
					})
				else
					print("[B3Spell_FillSpellListInfo] (ASSERT) Spell with level 0 encountered: '"..name.."'")
					Infinity_DisplayString("[Bubb's Spell Menu] Didn't display a level-0 spell: '"..name.."'. \z
					Please report this error to @Bubb if you have encountered it during normal play.")
				end
			else
				print("[B3Spell_FillSpellListInfo] (ASSERT) Not implemented, report to @Bubb")
			end

		else
			print("[B3Spell_FillSpellListInfo] (ASSERT) Empty resref, report to @Bubb")
		end
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
	local capture = EEex_ReadDword(EEex_Label("capture") + 0xC)

	if capture ~= 0x0 then

		local captureInstance = EEex_ReadDword(capture + 0xC)
		local captureTemplate = EEex_ReadString(EEex_ReadDword(capture + 0x10))

		if captureTemplate == "B3Spell_Menu_TEMPLATE_Action" and captureInstance == instanceId and not data.didOffset then

			local slotData = B3Spell_InstanceIDs["B3Spell_Menu"]["B3Spell_Menu_TEMPLATE_Bam"].instanceData[data.pairedSlotID]

			slotData.bam = data.isGreen and "B3SLOTGD" or "B3SLOTD"

			EEex_StoreTemplateInstance("B3Spell_Menu", "B3Spell_Menu_TEMPLATE_Icon", data.pairedIconID, "B3Spell_StoredInstance")
			local iconX, iconY, iconWidth, iconHeight = Infinity_GetArea("B3Spell_StoredInstance")
			Infinity_SetArea("B3Spell_StoredInstance", iconX + 2, iconY + 2, iconWidth - 2, iconHeight - 2)

			data.didOffset = true
		end

	elseif data.didOffset then

		local slotData = B3Spell_InstanceIDs["B3Spell_Menu"]["B3Spell_Menu_TEMPLATE_Bam"].instanceData[data.pairedSlotID]
		slotData.bam = data.isGreen and "B3SLOTG" or "B3SLOT"

		EEex_StoreTemplateInstance("B3Spell_Menu", "B3Spell_Menu_TEMPLATE_Icon", data.pairedIconID, "B3Spell_StoredInstance")
		local iconX, iconY, iconWidth, iconHeight = Infinity_GetArea("B3Spell_StoredInstance")
		Infinity_SetArea("B3Spell_StoredInstance", iconX - 2, iconY - 2, iconWidth + 2, iconHeight + 2)

		data.didOffset = false
	end

	return true

end
