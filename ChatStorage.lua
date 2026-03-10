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

-- Events ------------------------------
local function OnEvent(_, event, ...)
	if event == "PLAYER_LOGIN" then
		InitDB()

		if ChatStorageDB.options.enableOnLogin then
			if not IsLogging() then
				ChatStorage.Enable()
				print("|cff33ff99" .. ADDON_NAME .. ":|r |cff55ff55chat logging enabled automatically.|r")
			end
		end

		DebugPrint("Loaded.")
	end
end

CS:RegisterEvent("PLAYER_LOGIN")
CS:SetScript("OnEvent", OnEvent)