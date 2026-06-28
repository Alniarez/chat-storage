local MAJOR, MINOR = "LibDBIcon-1.0", 37
local lib, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end

lib.objects = lib.objects or {}

local function getAngle()
	local mx, my = Minimap:GetCenter()
	local scale = UIParent:GetEffectiveScale()
	local cx, cy = GetCursorPosition()
	cx = cx / scale
	cy = cy / scale
	return math.deg(math.atan2(cy - my, cx - mx))
end

local function updatePosition(button, angle)
	local rads = math.rad(angle or 220)
	local x = math.cos(rads) * 80
	local y = math.sin(rads) * 80
	button:ClearAllPoints()
	button:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

local function createButton(name, ldbobj, db)
	local buttonName = "LibDBIcon10_" .. name
	local button = CreateFrame("Button", buttonName, Minimap)
	button:SetFrameStrata("MEDIUM")
	button:SetFrameLevel(8)
	button:SetSize(31, 31)
	button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	button:RegisterForDrag("LeftButton")

	local bg = button:CreateTexture(nil, "BACKGROUND")
	bg:SetPoint("TOPLEFT", 2, -2)
	bg:SetPoint("BOTTOMRIGHT", -2, 2)
	bg:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Background")

	local iconTex = button:CreateTexture(nil, "ARTWORK")
	iconTex:SetPoint("TOPLEFT", 4, -4)
	iconTex:SetPoint("BOTTOMRIGHT", -4, 4)
	local iconPath = ldbobj.icon or "Interface\\Icons\\ui_chat"
	if type(iconPath) == "number" then
		iconTex:SetTexture(iconPath)
	else
		iconTex:SetTexture(iconPath)
	end
	button.icon = iconTex

	local border = button:CreateTexture(nil, "OVERLAY")
	border:SetSize(54, 54)
	border:SetPoint("TOPLEFT", -10, 10)
	border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")

	local hl = button:CreateTexture(nil, "HIGHLIGHT")
	hl:SetAllPoints()
	hl:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

	button:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:ClearLines()
		if ldbobj.OnTooltipShow then
			ldbobj.OnTooltipShow(GameTooltip)
		elseif ldbobj.tooltip then
			GameTooltip:SetText(ldbobj.tooltip)
		elseif ldbobj.text then
			GameTooltip:SetText(ldbobj.text)
		end
		GameTooltip:Show()
	end)

	button:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	button:SetScript("OnClick", function(self, btn)
		if ldbobj.OnClick then
			ldbobj.OnClick(self, btn)
		end
	end)

	button:SetScript("OnDragStart", function(self)
		self.dragging = true
		self:LockHighlight()
		self:SetScript("OnUpdate", function(self)
			if not self.dragging then return end
			local angle = getAngle()
			db.minimapPos = angle
			updatePosition(self, angle)
		end)
	end)

	button:SetScript("OnDragStop", function(self)
		self.dragging = false
		self:UnlockHighlight()
		self:SetScript("OnUpdate", nil)
	end)

	db.minimapPos = db.minimapPos or 220
	updatePosition(button, db.minimapPos)

	if db.hide then
		button:Hide()
	else
		button:Show()
	end

	return button
end

function lib:Register(name, ldbobj, db)
	if lib.objects[name] then return end
	db.minimapPos = db.minimapPos or 220
	local button = createButton(name, ldbobj, db)
	lib.objects[name] = { button = button, ldbobj = ldbobj, db = db }
end

function lib:Unregister(name)
	if not lib.objects[name] then return end
	lib.objects[name].button:Hide()
	lib.objects[name].button:SetParent(nil)
	lib.objects[name] = nil
end

function lib:Hide(name)
	if not lib.objects[name] then return end
	lib.objects[name].db.hide = true
	lib.objects[name].button:Hide()
end

function lib:Show(name)
	if not lib.objects[name] then return end
	lib.objects[name].db.hide = false
	lib.objects[name].button:Show()
end

function lib:IsRegistered(name)
	return lib.objects[name] ~= nil
end

function lib:Refresh(name, newdb)
	if not lib.objects[name] then return end
	local obj = lib.objects[name]
	if newdb then obj.db = newdb end
	if obj.db.hide then
		obj.button:Hide()
	else
		obj.button:Show()
	end
	updatePosition(obj.button, obj.db.minimapPos or 220)
end

function lib:GetMinimapButton(name)
	if lib.objects[name] then
		return lib.objects[name].button
	end
end
