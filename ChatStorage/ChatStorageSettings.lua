local ADDON_NAME = ...
local addon = {}

-- Ensure SavedVariables exist (options UI may load early)
ChatStorageDB = ChatStorageDB or {}
ChatStorageDB.options = ChatStorageDB.options or {}

-- Helpers ------------------------------
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

-- Settings category ------------------------------
local category, layout = Settings.RegisterVerticalLayoutCategory("ChatStorage")
addon.settingsCategory = category
ChatStorage.settingsCategory = category

local function InitializeSettings()

	-- Current logging state ------------------------------
	local loggingSetting = Settings.RegisterAddOnSetting(
		category,
		"CS_CHATLOG_STATE",
		"chatLoggingEnabled",
		ChatStorageDB.options,
		Settings.VarType.Boolean,
		"Log chat",
		Settings.Default.True
	)

	Settings.CreateCheckbox(
		category,
		loggingSetting,
		"Enable or disable WoW chat logging."
	)

	Settings.SetOnValueChangedCallback("CS_CHATLOG_STATE", function()
		local value = Settings.GetValue("CS_CHATLOG_STATE")
		ChatStorageDB.options.chatLoggingEnabled = value
		SetLogging(value)
	end)

	-- Enable on login ------------------------------
	local loginSetting = Settings.RegisterAddOnSetting(
		category,
		"CS_ENABLE_ON_LOGIN",
		"enableOnLogin",
		ChatStorageDB.options,
		Settings.VarType.Boolean,
		"Enable on character login",
		Settings.Default.True
	)

	Settings.CreateCheckbox(
		category,
		loginSetting,
		"If enabled, ChatStorage will automatically enable chat logging when you log in."
	)

	Settings.SetOnValueChangedCallback("CS_ENABLE_ON_LOGIN", function()
		ChatStorageDB.options.enableOnLogin = Settings.GetValue("CS_ENABLE_ON_LOGIN")
	end)

	-- Show minimap icon ------------------------------
	local minimapSetting = Settings.RegisterAddOnSetting(
		category,
		"CS_SHOW_MINIMAP_ICON",
		"showMinimapIcon",
		ChatStorageDB.options,
		Settings.VarType.Boolean,
		"Show minimap icon",
		Settings.Default.True
	)

	Settings.CreateCheckbox(
		category,
		minimapSetting,
		"Show or hide the ChatStorage icon on the minimap."
	)

	Settings.SetOnValueChangedCallback("CS_SHOW_MINIMAP_ICON", function()
		local value = Settings.GetValue("CS_SHOW_MINIMAP_ICON")
		ChatStorageDB.options.showMinimapIcon = value
		ChatStorageDB.minimapIcon.hide = not value
		if value then
			ChatStorageBroker.ShowMinimapIcon()
		else
			ChatStorageBroker.HideMinimapIcon()
		end
	end)

	Settings.RegisterAddOnCategory(category)
end

InitializeSettings()