local TeleportService = game:GetService("TeleportService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- 🖼️ สร้างหน้าต่าง UI ฟังก์ชันหลัก
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "AutoKeyGui"

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 450)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -225)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 6
mainFrame.BorderColor3 = Color3.fromRGB(0, 255, 0)  -- ขอบสีเขียวที่หรูหรา
mainFrame.Active = true
mainFrame.Draggable = true  -- ทำให้สามารถลาก UI ได้
mainFrame.Visible = true  -- แสดง UI หลัก
mainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner", mainFrame)
UICorner.CornerRadius = UDim.new(0, 8)

local UIListLayout = Instance.new("UIListLayout", mainFrame)
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.FillDirection = Enum.FillDirection.Vertical
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- 🔘 ฟังก์ชันสร้างปุ่ม
local function createButton(text)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -20, 0, 30)
	btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 18
	btn.Text = text
	btn.Parent = mainFrame

	local corner = Instance.new("UICorner", btn)
	corner.CornerRadius = UDim.new(0, 6)

	return btn
end

-- ℹ️ ป้ายบอกการใช้ LeftCtrl
local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, -20, 0, 25)
infoLabel.BackgroundTransparency = 1
infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
infoLabel.Font = Enum.Font.SourceSans
infoLabel.TextSize = 14
infoLabel.Text = "กด LeftCtrl เพื่อซ่อน/แสดง UI ✨"
infoLabel.Parent = mainFrame

-- 🛠️ Auto F / R / Q / E
local buttons = {
	{name = "Auto F ⚡", key = Enum.KeyCode.F, enabled = false},
	{name = "Auto R 🔁", key = Enum.KeyCode.R, enabled = false},
	{name = "Auto Q 🔥", key = Enum.KeyCode.Q, enabled = false},
	{name = "Auto E 🌪️", key = Enum.KeyCode.E, enabled = false},
}

for _, info in ipairs(buttons) do
	local btn = createButton(info.name .. ": OFF")

	btn.MouseButton1Click:Connect(function()
		info.enabled = not info.enabled
		btn.Text = info.name .. ": " .. (info.enabled and "ON ✅" or "OFF ❌")
		btn.BackgroundColor3 = info.enabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(60, 60, 60)
	end)

	coroutine.wrap(function()
		while true do
			if info.enabled then
				VirtualInputManager:SendKeyEvent(true, info.key, false, game)
				wait(0.05)
				VirtualInputManager:SendKeyEvent(false, info.key, false, game)
			end
			wait(0.5)
		end
	end)()
end

-- 🏠 ปุ่มกลับบ้าน
local homePlaceId = 125503319883299
local homeButton = createButton("กลับบ้าน 🏡")
homeButton.MouseButton1Click:Connect(function()
	TeleportService:Teleport(homePlaceId, LocalPlayer)
end)

-- 💀 ปุ่มฆ่าตัวตาย (Reset)
local resetButton = createButton("ฆ่าตัวตาย ☠️")
resetButton.MouseButton1Click:Connect(function()
	if LocalPlayer.Character then
		LocalPlayer.Character:BreakJoints() -- reset character
	end
end)

-- 🎮 Toggle UI ด้วย LeftCtrl
local uiVisible = true
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.LeftControl then
		uiVisible = not uiVisible
		mainFrame.Visible = uiVisible
	end
end)
