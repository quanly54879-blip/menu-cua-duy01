-- Tải thư viện UI Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "duy54879",
    LoadingTitle = "Đang tải giao diện của duy54879.",
    LoadingSubtitle = "tác giả duy54879v1",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false,
    Theme = "Default"
})

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

----------------------------------------------------------------
-- NÚT BẬT / TẮT UI NỔI
----------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
local ToggleButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

ScreenGui.Name = "DeltaMenuToggleGui"
ScreenGui.ResetOnSpawn = false

ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ToggleButton.Position = UDim2.new(0.02, 0, 0.2, 0)
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Text = "⚙️"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 25
ToggleButton.Active = true
ToggleButton.Draggable = true

UICorner.CornerRadius = UDim.new(0, 25)
UICorner.Parent = ToggleButton

local UIVisible = true
local function ToggleMainUI()
    UIVisible = not UIVisible
    pcall(function()
        local targetParent = CoreGui:FindFirstChild("Rayfield") or LocalPlayer.PlayerGui:FindFirstChild("Rayfield")
        if not targetParent then
            for _, v in pairs(CoreGui:GetChildren()) do
                if v:FindFirstChild("Main") then targetParent = v break end
            end
        end
        if targetParent then targetParent.Enabled = UIVisible end
    end)
end
ToggleButton.MouseButton1Click:Connect(ToggleMainUI)

----------------------------------------------------------------
-- TAB 1: TELEPORT
----------------------------------------------------------------
local TeleportTab = Window:CreateTab("📍 Teleport", 4483362458)
local SelectedTargetName = ""
local TargetInput = ""

local TargetDropdown = TeleportTab:CreateDropdown({
    Name = "Chọn người chơi trong Server",
    Options = {"Đang tải..."},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "PlayerDropdown",
    Callback = function(Option)
        if type(Option) == "table" then
            SelectedTargetName = Option[1] or ""
        else
            SelectedTargetName = tostring(Option)
        end
    end,
})

local function UpdatePlayerList()
    local playerNames = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(playerNames, player.Name)
        end
    end
    if #playerNames == 0 then playerNames = {"Không có người chơi khác"} end
    TargetDropdown:Refresh(playerNames)
end

Players.PlayerAdded:Connect(UpdatePlayerList)
Players.PlayerRemoving:Connect(UpdatePlayerList)
task.spawn(UpdatePlayerList)

TeleportTab:CreateButton({
    Name = "🔄 Cập nhật danh sách người chơi",
    Callback = UpdatePlayerList
})

TeleportTab:CreateInput({
    Name = "Nhập tên người chơi thủ công",
    PlaceholderText = "Username hoặc DisplayName...",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text) TargetInput = Text end,
})

TeleportTab:CreateButton({
    Name = "🚀 Dịch chuyển (Theo danh sách)",
    Callback = function()
        if SelectedTargetName ~= "" and SelectedTargetName ~= "Không có người chơi khác" then
            local targetPlayer = Players:FindFirstChild(SelectedTargetName)
            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
                    Rayfield:Notify({Title = "Thành công", Content = "Đã dịch chuyển đến: " .. targetPlayer.Name, Duration = 2})
                    return
                end
            end
        end
        Rayfield:Notify({Title = "Lỗi", Content = "Người chơi không hợp lệ!", Duration = 2})
    end,
})

TeleportTab:CreateButton({
    Name = "🚀 Dịch chuyển (Theo tên đã nhập)",
    Callback = function()
        if TargetInput ~= "" then
            local searchStr = string.lower(TargetInput)
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and (string.find(string.lower(player.Name), searchStr) or string.find(string.lower(player.DisplayName), searchStr)) then
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame
                        Rayfield:Notify({Title = "Thành công", Content = "Đã dịch chuyển đến " .. player.Name, Duration = 2})
                        return
                    end
                end
            end
            Rayfield:Notify({Title = "Lỗi", Content = "Không tìm thấy người chơi phù hợp!", Duration = 2})
        end
    end,
})

----------------------------------------------------------------
-- TAB 2: MOVEMENT & SURVIVAL
----------------------------------------------------------------
local MovementTab = Window:CreateTab("🕊️ Nhân vật & Bay", 4483362458)
local GodModeEnabled = false

MovementTab:CreateSection("Tính năng Bất Tử")
MovementTab:CreateToggle({
    Name = "Bật / Tắt Bất Tử (God Mode Client)",
    CurrentValue = false,
    Flag = "GodModeToggle",
    Callback = function(Value) GodModeEnabled = Value end,
})

RunService.Stepped:Connect(function()
    if GodModeEnabled and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.Health = hum.MaxHealth
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        end
    end
end)

MovementTab:CreateSection("Menu Bay (FlyGui V3)")
MovementTab:CreateButton({
    Name = "🚀 Tải FlyGui V3 (XNEOFF)",
    Callback = function()
        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
        end)
        if success then
            Rayfield:Notify({Title = "Thành công", Content = "Đã bật giao diện FlyGui V3!", Duration = 2})
        else
            Rayfield:Notify({Title = "Lỗi", Content = "Không thể tải FlyGui V3", Duration = 2})
        end
    end,
})

MovementTab:CreateSection("Đi xuyên tường (Noclip Tối Ưu High FPS)")
local NoclipEnabled = false
local NoclipConnection

MovementTab:CreateToggle({
    Name = "Bật / Tắt Noclip",
    CurrentValue = false,
    Flag = "NoclipToggle",
    Callback = function(Value)
        NoclipEnabled = Value
        if NoclipEnabled then
            if NoclipConnection then NoclipConnection:Disconnect() end
            NoclipConnection = RunService.Stepped:Connect(function()
                if NoclipEnabled and LocalPlayer.Character then
                    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else
            if NoclipConnection then
                NoclipConnection:Disconnect()
                NoclipConnection = nil
            end
        end
    end,
})

----------------------------------------------------------------
-- TAB 3: BẮN XUYÊN TƯỜNG & ESP
----------------------------------------------------------------
local CombatTab = Window:CreateTab("🎯 Chiến Đấu & ESP", 4483362458)

------------------- 1. BẮN XUYÊN TƯỜNG (WALLBANG) -------------------
CombatTab:CreateSection("Bắn Xuyên Tường (Wallbang)")

local WallbangEnabled = false
local OriginalCanCollideMap = {}

local function ToggleWallbang(enable)
    WallbangEnabled = enable
    if WallbangEnabled then
        for _, object in pairs(workspace:GetDescendants()) do
            if object:IsA("BasePart") and not object:IsDescendantOf(LocalPlayer.Character) then
                local isOtherPlayer = false
                for _, player in pairs(Players:GetPlayers()) do
                    if player.Character and object:IsDescendantOf(player.Character) then
                        isOtherPlayer = true
                        break
                    end
                end
               
                if not isOtherPlayer then
                    OriginalCanCollideMap[object] = object.CanCollide
                    object.CanCollide = false
                end
            end
        end
        Rayfield:Notify({Title = "Bắn Xuyên Tường", Content = "Đã BẬT! Đạn có thể đi xuyên qua vật cản.", Duration = 2})
    else
        for object, originalState in pairs(OriginalCanCollideMap) do
            if object and object.Parent then
                object.CanCollide = originalState
            end
        end
        OriginalCanCollideMap = {}
        Rayfield:Notify({Title = "Bắn Xuyên Tường", Content = "Đã TẮT!", Duration = 2})
    end
end

CombatTab:CreateToggle({
    Name = "Bật / Tắt Bắn Xuyên Tường",
    CurrentValue = false,
    Flag = "WallbangToggle",
    Callback = function(Value)
        ToggleWallbang(Value)
    end,
})

------------------- 2. ESP TRACKER / ĐỊNH VỊ -------------------
CombatTab:CreateSection("📍 Định Vị Người Chơi (ESP)")

local ESPEnabled = false

local function ApplyESP(player)
    if player == LocalPlayer then return end
    local function AddHighlight(char)
        if char and not char:FindFirstChild("ESPHighlight") then
            local highlight = Instance.new("Highlight")
            highlight.Name = "ESPHighlight"
            highlight.Adornee = char
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.FillTransparency = 0.5
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.OutlineTransparency = 0
            highlight.Parent = char
        end
    end
   
    if player.Character then AddHighlight(player.Character) end
    player.CharacterAdded:Connect(AddHighlight)
end

local function RemoveESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("ESPHighlight") then
            player.Character.ESPHighlight:Destroy()
        end
    end
end

CombatTab:CreateToggle({
    Name = "Bật / Tắt Định Vị Người Chơi (ESP)",
    CurrentValue = false,
    Flag = "ESPToggle",
    Callback = function(Value)
        ESPEnabled = Value
        if ESPEnabled then
            for _, player in pairs(Players:GetPlayers()) do ApplyESP(player) end
            Rayfield:Notify({Title = "Định Vị", Content = "Đã bật định vị!", Duration = 2})
        else
            RemoveESP()
            Rayfield:Notify({Title = "Định Vị", Content = "Đã tắt định vị.", Duration = 2})
        end
    end,
})

Players.PlayerAdded:Connect(function(player)
    if ESPEnabled then ApplyESP(player) end
end)

----------------------------------------------------------------
-- TAB 4: VẬT PHẨM (ITEMS - CÓ DANH SÁCH + Ô NHẬP)
----------------------------------------------------------------
local ItemTab = Window:CreateTab("🎒 Vật phẩm", 4483362458)
local ItemInputName = ""
local SelectedDropdownItem = ""

-- Hàm xử lý để Tool hoạt động bình thường trên Client
local function FixToolProperties(tool)
    if not tool or not tool:IsA("Tool") then return end
    tool.CanBeDropped = true
   
    if not tool:FindFirstChild("Handle") then
        tool.RequiresHandle = false
    end

    for _, scriptObj in pairs(tool:GetDescendants()) do
        if scriptObj:IsA("LocalScript") then
            scriptObj.Disabled = false
        end
    end
end

-- Hàm thực hiện lấy vật phẩm theo tên
local function GiveItemByName(itemName)
    if itemName == "" or itemName == "Không tìm thấy vật phẩm" then
        Rayfield:Notify({Title = "Lỗi", Content = "Vui lòng chọn hoặc nhập tên vật phẩm!", Duration = 2})
        return
    end

    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if not backpack then
        Rayfield:Notify({Title = "Lỗi", Content = "Không tìm thấy kho đồ (Backpack)!", Duration = 2})
        return
    end

    local foundCount = 0
    local searchContainers = {ReplicatedStorage, Lighting, workspace}

    for _, container in pairs(searchContainers) do
        for _, item in pairs(container:GetDescendants()) do
            if item:IsA("Tool") and string.lower(item.Name) == string.lower(itemName) then
                local clonedTool = item:Clone()
                FixToolProperties(clonedTool)
                clonedTool.Parent = backpack
                foundCount = foundCount + 1
            end
        end
    end

    -- Tìm kiếm trong các givers/shop bằng cách chạm Client
    if foundCount == 0 and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("TouchTransmitter") and string.find(string.lower(obj.Parent.Name), string.lower(itemName)) then
                firetouchinterest(LocalPlayer.Character.HumanoidRootPart, obj.Parent, 0)
                task.wait(0.1)
                firetouchinterest(LocalPlayer.Character.HumanoidRootPart, obj.Parent, 1)
                foundCount = foundCount + 1
            end
        end
    end

    if foundCount > 0 then
        Rayfield:Notify({Title = "Thành công", Content = "Đã thêm " .. foundCount .. " vật phẩm (" .. itemName .. ") vào túi!", Duration = 2})
    else
        Rayfield:Notify({Title = "Lỗi", Content = "Không tìm thấy vật phẩm có tên: " .. itemName, Duration = 2})
    end
end

ItemTab:CreateSection("Danh Sách & Nhập Tên Vật Phẩm")

-- Dropdown danh sách vật phẩm
local ItemDropdown = ItemTab:CreateDropdown({
    Name = "Chọn vật phẩm có sẵn trong Map",
    Options = {"Đang quét vật phẩm..."},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "ItemDropdownFlag",
    Callback = function(Option)
        if type(Option) == "table" then
            SelectedDropdownItem = Option[1] or ""
        else
            SelectedDropdownItem = tostring(Option)
        end
    end,
})

-- Hàm quét và cập nhật danh sách Tool trong Game
local function ScanAndRefreshItems()
    local itemSet = {}
    local itemList = {}
    local searchContainers = {ReplicatedStorage, Lighting, workspace}

    for _, container in pairs(searchContainers) do
        for _, item in pairs(container:GetDescendants()) do
            if item:IsA("Tool") and not itemSet[item.Name] then
                itemSet[item.Name] = true
                table.insert(itemList, item.Name)
            end
        end
    end

    if #itemList == 0 then itemList = {"Không tìm thấy vật phẩm"} end
    table.sort(itemList)
    ItemDropdown:Refresh(itemList)
end

task.spawn(ScanAndRefreshItems)

ItemTab:CreateButton({
    Name = "🔄 Quét lại danh sách vật phẩm trong Map",
    Callback = ScanAndRefreshItems
})

ItemTab:CreateButton({
    Name = "🎁 Lấy vật phẩm (Đã chọn trong danh sách)",
    Callback = function()
        GiveItemByName(SelectedDropdownItem)
    end,
})

ItemTab:CreateSection("Nhập Tên Thủ Công")

ItemTab:CreateInput({
    Name = "Nhập tên vật phẩm/Tool",
    PlaceholderText = "Tên chính xác của vật phẩm...",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        ItemInputName = Text
    end,
})

ItemTab:CreateButton({
    Name = "🎁 Lấy vật phẩm (Theo tên đã nhập)",
    Callback = function()
        GiveItemByName(ItemInputName)
    end,
})

ItemTab:CreateSection("Tính Năng Mở Rộng Kho Đồ")

ItemTab:CreateButton({
    Name = "⚡ Kích hoạt tất cả Nút Nhặt Đồ (Touch/Click Givers)",
    Callback = function()
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local count = 0

        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("TouchTransmitter") and obj.Parent then
                firetouchinterest(hrp, obj.Parent, 0)
                task.wait(0.02)
                firetouchinterest(hrp, obj.Parent, 1)
                count = count + 1
            elseif obj:IsA("ClickDetector") then
                fireclickdetector(obj)
                count = count + 1
            end
        end

        Rayfield:Notify({Title = "Hoàn tất", Content = "Đã thử tương tác với " .. count .. " điểm nhặt đồ trên Map!", Duration = 2})
    end,
})

ItemTab:CreateButton({
    Name = "🤲 Sao chép & Sửa lỗi Tool người chơi khác",
    Callback = function()
        local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
        if not backpack then return end

        local count = 0
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                for _, item in pairs(player.Character:GetChildren()) do
                    if item:IsA("Tool") then
                        local clonedTool = item:Clone()
                        FixToolProperties(clonedTool)
                        clonedTool.Parent = backpack
                        count = count + 1
                    end
                end
               
                local targetBackpack = player:FindFirstChildOfClass("Backpack")
                if targetBackpack then
                    for _, item in pairs(targetBackpack:GetChildren()) do
                        if item:IsA("Tool") then
                            local clonedTool = item:Clone()
                            FixToolProperties(clonedTool)
                            clonedTool.Parent = backpack
                            count = count + 1
                        end
                    end
                end
            end
        end

        if count > 0 then
            Rayfield:Notify({Title = "Thành công", Content = "Đã sao chép " .. count .. " vật phẩm có thể dùng!", Duration = 2})
        else
            Rayfield:Notify({Title = "Thông báo", Content = "Không tìm thấy vật phẩm hợp lệ.", Duration = 2})
        end
    end,
})

----------------------------------------------------------------
-- TAB 5: SETTINGS
----------------------------------------------------------------
local SettingsTab = Window:CreateTab("⚙️ Settings", 4483362458)

SettingsTab:CreateKeybind({
    Name = "Phím tắt Bật/Tắt Menu (PC)",
    CurrentKeybind = "K",
    HoldToInteract = false,
    Flag = "ToggleUIKeybind",
    Callback = function()
        if not UserInputService:GetFocusedTextBox() then
            ToggleMainUI()
        end
    end,
})

SettingsTab:CreateToggle({
    Name = "Hiện/Ẩn Nút Nổi Trên Màn Hình",
    CurrentValue = true,
    Flag = "FloatingButtonToggle",
    Callback = function(Value)
        ToggleButton.Visible = Value
    end,
})
