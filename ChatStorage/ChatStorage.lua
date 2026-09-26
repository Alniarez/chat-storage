local ADDON_NAME = ...
local CS = CreateFrame("Frame")

-- Configuration ------------------------------
local DEBUG = false

-- SavedVariables ------------------------------
local function InitDB()
	ChatStorageDB = ChatStorageDB or {}
	ChatStorageDB.options = ChatStorageDB.options or {}

	if ChatStorageDB.options.enableOnLogin == nil then
		ChatStorageDB.options.enableOnLogin = true
	end

	if ChatStorageDB.options.chatLoggingEnabled == nil then
		ChatStorageDB.options.chatLoggingEnabled = true
	end

	-- Clean up leftovers from the old minimap icon
	ChatStorageDB.options.showMinimapIcon = nil
	ChatStorageDB.minimapIcon = nil
end

-- Helper functions ------------------------------
local function DebugPrint(...)
	if not DEBUG then
		return
	end
	print("|cff33ff99" .. ADDON_NAME .. ":|r", ...)
end

local function IsLogging()
	if LoggingChat then
		return LoggingChat()
	end
	return false
end

local function SetLogging(state)
	if LoggingChat then
		LoggingChat(state)
	end
end

local function PrintStatus()
	local prefix = "|cff33ff99" .. ADDON_NAME .. ":|r "

	if IsLogging() then
		print(prefix .. "|cff55ff55chat logging enabled.|r")
	else
		print(prefix .. "|cffff5555chat logging disabled.|r")
	end
end

local function PrintHelp()
	print("|cff33ff99ChatStorage commands:|r")

	print("|cffffff00/chatstorage|r " .. "|cffbbbbbb- show current state and commands|r")
	print("|cffffff00/chatstorage toggle|r " .. "|cffbbbbbb- toggle chat logging|r")
	print("|cffffff00/chatstorage true|r " .. "|cffbbbbbb- enable chat logging|r")
	print("|cffffff00/chatstorage false|r " .. "|cffbbbbbb- disable chat logging|r")
end

-- ChatStorage API ------------------------------
ChatStorage = {}
ChatStorage.PrintHelp = PrintHelp

function ChatStorage.Enable()
	SetLogging(true)
	ChatStorageDB.options.chatLoggingEnabled = true
	DebugPrint("Chat logging enabled.")
end

function ChatStorage.Disable()
	SetLogging(false)
	ChatStorageDB.options.chatLoggingEnabled = false
	DebugPrint("Chat logging disabled.")
end

function ChatStorage.Toggle()
	local state = not IsLogging()
	SetLogging(state)
	ChatStorageDB.options.chatLoggingEnabled = state
	DebugPrint("Chat logging toggled.")
end

-- Slash commands ------------------------------
SLASH_CHATSTORAGE1 = "/chatstorage"

SlashCmdList["CHATSTORAGE"] = function(msg)
	msg = msg:lower():match("^%s*(.-)%s*$")

	if msg == "" then
		PrintStatus()
		PrintHelp()
		return
	end

	if msg == "toggle" then
		ChatStorage.Toggle()
		PrintStatus()
		return
	end

	if msg == "true" then
		ChatStorage.Enable()
		PrintStatus()
		return
	end

	if msg == "false" then
		ChatStorage.Disable()
		PrintStatus()
		return
	end

	print("|cffff5555Unknown command.|r")
	PrintHelp()
end

-- AddOn Compartment ------------------------------
local function ShowCompartmentTooltip(button)
	GameTooltip:SetOwner(button, "ANCHOR_LEFT")
	GameTooltip:AddLine("Chat Storage", 1, 0.82, 0)
	if IsLogging() then
		GameTooltip:AddLine("Chat logging: ON", 0.33, 1, 0.33)
	else
		GameTooltip:AddLine("Chat logging: OFF", 1, 0.33, 0.33)
	end
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine("Left-click: toggle logging", 1, 1, 1)
	if ChatStorage.settingsCategory then
		GameTooltip:AddLine("Right-click: open settings", 1, 1, 1)
	else
		GameTooltip:AddLine("Right-click: print help", 1, 1, 1)
	end
	GameTooltip:Show()
end

local function RegisterCompartment()
	if not AddonCompartmentFrame then
		return
	end

	AddonCompartmentFrame:RegisterAddon({
		text                = "Chat Storage",
		icon                = "Interface\\Icons\\ui_chat",
		registerForAnyClick = true,
		func                = function()
			if GetMouseButtonClicked() == "RightButton" then
				if ChatStorage.settingsCategory then
					Settings.OpenToCategory(ChatStorage.settingsCategory.ID)
				else
					PrintHelp()
				end
			else
				ChatStorage.Toggle()
				PrintStatus()
			end
		end,
		funcOnEnter = ShowCompartmentTooltip,
		funcOnLeave = function() GameTooltip:Hide() end,
	})
end

-- Events ------------------------------
local function OnEvent(_, event, ...)
	if event == "ADDON_LOADED" then
		local addonName = ...
		if addonName == ADDON_NAME then
			InitDB()
			RegisterCompartment()
			CS:UnregisterEvent("ADDON_LOADED")
			DebugPrint("Loaded.")
		end
	elseif event == "PLAYER_LOGIN" then
		if ChatStorageDB.options.enableOnLogin then
			if not IsLogging() then
				ChatStorage.Enable()
				DebugPrint("|cff33ff99" .. ADDON_NAME .. ":|r |cff55ff55chat logging enabled automatically.|r")
			end
		end
	end
end

CS:RegisterEvent("ADDON_LOADED")
CS:RegisterEvent("PLAYER_LOGIN")
CS:SetScript("OnEvent", OnEvent)
