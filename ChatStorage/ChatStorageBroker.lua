-- LibDataBroker and LibDBIcon integration for ChatStorage
local LDB = LibStub("LibDataBroker-1.1", true)
local LDBIcon = LibStub("LibDBIcon-1.0", true)

if not LDB then return end

local function BuildTooltip(tooltip)
	tooltip:AddLine("|cffffd700ChatStorage|r")
	if LoggingChat and LoggingChat() then
		tooltip:AddLine("|cff55ff55Chat logging: ON|r")
	else
		tooltip:AddLine("|cffff5555Chat logging: OFF|r")
	end
	tooltip:AddLine(" ")
	tooltip:AddLine("|cffeda55fLeft-click|r to toggle logging")
	if ChatStorage.settingsCategory then
		tooltip:AddLine("|cffeda55fRight-click|r to open settings")
	else
		tooltip:AddLine("|cffeda55fRight-click|r to print help")
	end
end

local dataobj = LDB:NewDataObject("ChatStorage", {
	type = "data source",
	label = "Chat Storage",
	text = "OFF",
	icon = "Interface\\Icons\\ui_chat",
	OnClick = function(self, button)
		if button == "LeftButton" then
			ChatStorage.Toggle()
			ChatStorageBroker.UpdateIcon()
			local onEnter = self:GetScript("OnEnter")
			if onEnter then onEnter(self) end
		elseif button == "RightButton" then
			if ChatStorage.settingsCategory then
				Settings.OpenToCategory(ChatStorage.settingsCategory.ID)
			else
				ChatStorage.PrintHelp()
			end
		end
	end,
	OnTooltipShow = BuildTooltip,
})

ChatStorageBroker = {}

function ChatStorageBroker.ShowMinimapIcon()
	if LDBIcon then LDBIcon:Show("ChatStorage") end
end

function ChatStorageBroker.HideMinimapIcon()
	if LDBIcon then LDBIcon:Hide("ChatStorage") end
end

function ChatStorageBroker.UpdateIcon()
	local logging = LoggingChat and LoggingChat()
	dataobj.text = logging and "ON" or "OFF"
	if not LDBIcon then return end
	local button = LDBIcon:GetMinimapButton("ChatStorage")
	if not button or not button.icon then return end
	if logging then
		button.icon:SetVertexColor(1, 1, 1)
	else
		button.icon:SetVertexColor(1, 0.3, 0.3)
	end
end

local brokerFrame = CreateFrame("Frame")
brokerFrame:RegisterEvent("PLAYER_LOGIN")
brokerFrame:SetScript("OnEvent", function(_, event)
	if event == "PLAYER_LOGIN" then
		if LDBIcon then
			LDBIcon:Register("ChatStorage", dataobj, ChatStorageDB.minimapIcon)
		end
		ChatStorageBroker.UpdateIcon()
	end
end)

-- Hook state changes to keep the icon color current
local origEnable = ChatStorage.Enable
function ChatStorage.Enable()
	origEnable()
	ChatStorageBroker.UpdateIcon()
end

local origDisable = ChatStorage.Disable
function ChatStorage.Disable()
	origDisable()
	ChatStorageBroker.UpdateIcon()
end

local origToggle = ChatStorage.Toggle
function ChatStorage.Toggle()
	origToggle()
	ChatStorageBroker.UpdateIcon()
end
