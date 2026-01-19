--[[
    TREDICT INVICTUS ~ EXECUTOR (MOBILE SUPPORT)
    Version: 4.0.0
    Author: Xatanical
    GitHub: github.com/xatanical/clover
    Platform: Android/iOS/PC
--]]

-- Platform Detection
local IS_MOBILE = false
local IS_IOS = false
local IS_ANDROID = false
local HAS_TOUCH = game:GetService("UserInputService").TouchEnabled

if HAS_TOUCH then
    IS_MOBILE = true
    if string.find(identifyexecutor() or "", "iOS") then
        IS_IOS = true
    else
        IS_ANDROID = true
    end
end

print("Platform: " .. (IS_MOBILE and "MOBILE" .. (IS_IOS and " (iOS)" or " (Android)") or "PC"))

-- Mobile-Safe GUI Library
local success, Library = pcall(function()
    if IS_MOBILE then
        -- Mobile-optimized GUI
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/xatanical/clover/main/MobileUiLib.lua"))()
    else
        -- Standard GUI for PC
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/xatanical/clover/main/UiLib.lua"))()
    end
end)

if not success then
    -- Fallback simple GUI for mobile
    Library = {
        CreateWindow = function(title, subtitle)
            local Window = {
                Tabs = {},
                CreateTab = function(self, name)
                    print("[Mobile GUI] Tab: " .. name)
                    local Tab = {
                        CreateToggle = function(self, text, default, callback)
                            print("[Toggle] " .. text .. ": " .. tostring(default))
                            return { Set = function(self, val) callback(val) end }
                        end,
                        CreateSlider = function(self, text, min, max, default, precise, callback)
                            print("[Slider] " .. text .. ": " .. default .. " (" .. min .. "-" .. max .. ")")
                            return { Set = function(self, val) callback(val) end }
                        end,
                        CreateButton = function(self, text, callback)
                            print("[Button] " .. text)
                            return { Fire = function() callback() end }
                        end,
                        CreateLabel = function(self, text, id)
                            print("[Label] " .. text)
                            return id or ""
                        end,
                        UpdateLabel = function(self, id, text)
                            print("[Update Label] " .. id .. ": " .. text)
                        end
                    }
                    table.insert(self.Tabs, Tab)
                    return Tab
                end,
                ToggleUI = function()
                    print("[Mobile] Toggle UI - Use touch controls")
                end,
                Notify = function(msg)
                    warn("[Tredict] " .. msg)
                end
            }
            return Window
        end
    }
end

local Window = Library:CreateWindow("Tredict Invictus Mobile", "v4.0.0")

-- MOBILE-OPTIMIZED CONTROLS
local MobileControls = {
    -- Touch gesture detection
    LastTouch = Vector2.new(0, 0),
    TouchStart = nil,
    GestureRecognized = false,
    
    -- Mobile-specific buttons
    VirtualButtons = {
        SpeedUp = {Position = UDim2.new(0.8, 0, 0.7, 0), Size = UDim2.new(0.1, 0, 0.1, 0)},
        SpeedDown = {Position = UDim2.new(0.7, 0, 0.7, 0), Size = UDim2.new(0.1, 0, 0.1, 0)},
        JumpUp = {Position = UDim2.new(0.8, 0, 0.8, 0), Size = UDim2.new(0.1, 0, 0.1, 0)},
        JumpDown = {Position = UDim2.new(0.7, 0, 0.8, 0), Size = UDim2.new(0.1, 0, 0.1, 0)}
    },
    
    Init = function(self)
        if IS_MOBILE then
            -- Touch input handling
            game:GetService("UserInputService").TouchStarted:Connect(function(touch, gameProcessed)
                self.TouchStart = touch.Position
                self.LastTouch = touch.Position
            end)
            
            game:GetService("UserInputService").TouchMoved:Connect(function(touch, gameProcessed)
                self.LastTouch = touch.Position
                self:CheckGestures(touch)
            end)
            
            -- Create on-screen controls
            self:CreateVirtualButtons()
        end
    end,
    
    CheckGestures = function(self, touch)
        if self.TouchStart then
            local delta = touch.Position - self.TouchStart
            
            -- Swipe Right: Enable all hacks
            if delta.X > 100 and math.abs(delta.Y) < 50 then
                if not self.GestureRecognized then
                    self.GestureRecognized = true
                    self:OnSwipeRight()
                end
            end
            
            -- Swipe Left: Disable all hacks
            if delta.X < -100 and math.abs(delta.Y) < 50 then
                if not self.GestureRecognized then
                    self.GestureRecognized = true
                    self:OnSwipeLeft()
                end
            end
            
            -- Swipe Up: Increase speed
            if delta.Y < -100 and math.abs(delta.X) < 50 then
                if not self.GestureRecognized then
                    self.GestureRecognized = true
                    self:OnSwipeUp()
                end
            end
            
            -- Swipe Down: Decrease speed
            if delta.Y > 100 and math.abs(delta.X) < 50 then
                if not self.GestureRecognized then
                    self.GestureRecognized = true
                    self:OnSwipeDown()
                end
            end
        end
    end,
    
    OnSwipeRight = function(self)
        Library:Notify("Enabled All Hacks (Swipe Right)")
        -- Enable all features
        if SpeedToggle then SpeedToggle:Set(true) end
        if JumpToggle then JumpToggle:Set(true) end
        if FlyToggle then FlyToggle:Set(true) end
    end,
    
    OnSwipeLeft = function(self)
        Library:Notify("Disabled All Hacks (Swipe Left)")
        -- Disable all features
        if SpeedToggle then SpeedToggle:Set(false) end
        if JumpToggle then JumpToggle:Set(false) end
        if FlyToggle then FlyToggle:Set(false) end
    end,
    
    OnSwipeUp = function(self)
        if SpeedSlider then
            local current = SpeedValue or 50
            local newValue = math.min(100, current + 10)
            SpeedSlider:Set(newValue)
            Library:Notify("Speed +10: " .. newValue)
        end
    end,
    
    OnSwipeDown = function(self)
        if SpeedSlider then
            local current = SpeedValue or 50
            local newValue = math.max(1, current - 10)
            SpeedSlider:Set(newValue)
            Library:Notify("Speed -10: " .. newValue)
        end
    end,
    
    CreateVirtualButtons = function(self)
        if IS_MOBILE then
            local ScreenGui = Instance.new("ScreenGui")
            ScreenGui.Name = "TredictMobileControls"
            ScreenGui.Parent = game:GetService("CoreGui")
            
            -- Toggle Button
            local ToggleBtn = Instance.new("TextButton")
            ToggleBtn.Name = "ToggleMenu"
            ToggleBtn.Text = "☰"
            ToggleBtn.Size = UDim2.new(0.1, 0, 0.08, 0)
            ToggleBtn.Position = UDim2.new(0.02, 0, 0.02, 0)
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
            ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            ToggleBtn.Font = Enum.Font.SourceSansBold
            ToggleBtn.TextSize = 24
            ToggleBtn.Parent = ScreenGui
            
            ToggleBtn.MouseButton1Click:Connect(function()
                Library:ToggleUI()
            end)
            
            -- Auto Click Toggle
            local AutoClickBtn = Instance.new("TextButton")
            AutoClickBtn.Name = "AutoClick"
            AutoClickBtn.Text = "⚡"
            AutoClickBtn.Size = UDim2.new(0.1, 0, 0.08, 0)
            AutoClickBtn.Position = UDim2.new(0.14, 0, 0.02, 0)
            AutoClickBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
            AutoClickBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            AutoClickBtn.Font = Enum.Font.SourceSansBold
            AutoClickBtn.TextSize = 24
            AutoClickBtn.Parent = ScreenGui
            
            AutoClickBtn.MouseButton1Click:Connect(function()
                if AutoClickEnabled then
                    AutoClickEnabled = false
                    AutoClickBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
                    Library:Notify("AutoClick: OFF")
                else
                    AutoClickEnabled = true
                    AutoClickBtn.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
                    Library:Notify("AutoClick: ON")
                    StartAutoClick()
                end
            end)
        end
    end
}

-- SERVICES (MOBILE-COMPATIBLE)
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

-- MOBILE INPUT EMULATION
local VirtualInputService = game:GetService("VirtualInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")

-- PLAYER REFERENCES
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- CONFIGURATION (MOBILE OPTIMIZED)
local Config = {
    SpeedValue = 50,
    JumpValue = 50,
    ClickSpeedValue = 30, -- Slower for mobile
    FlySpeedValue = 50,
    
    -- Mobile-optimized ranges
    GetWalkSpeed = function(self)
        if IS_MOBILE then
            -- Smaller range for mobile safety
            return 16 + (self.SpeedValue * 2.5) -- 16 to 266
        else
            return 16 + (self.SpeedValue * 4.84) -- 16 to 500
        end
    end,
    
    GetJumpPower = function(self)
        if IS_MOBILE then
            return 50 + (self.JumpValue * 4.5) -- 50 to 500
        else
            return 50 + (self.JumpValue * 9.5) -- 50 to 1000
        end
    end,
    
    GetClickInterval = function(self)
        if IS_MOBILE then
            return 0.1 - (self.ClickSpeedValue * 0.0005) -- 0.1 to 0.05
        else
            return 0.1 - (self.ClickSpeedValue * 0.00099) -- 0.1 to 0.001
        end
    end,
    
    GetFlySpeed = function(self)
        if IS_MOBILE then
            return 30 + (self.FlySpeedValue * 2.2) -- 30 to 250
        else
            return 50 + (self.FlySpeedValue * 4.5) -- 50 to 500
        end
    end
}

-- MOBILE AUTO CLICK SYSTEM
local AutoClickEnabled = false
local function StartAutoClick()
    spawn(function()
        while AutoClickEnabled do
            -- Simulate tap for mobile
            if IS_MOBILE then
                -- Mobile touch simulation
                local touchPos = Vector2.new(
                    math.random(100, 500),
                    math.random(200, 800)
                )
                
                -- Send touch input
                VirtualInputManager:SendTouchEvent(1, Enum.UserInputState.Begin, touchPos)
                wait(0.05)
                VirtualInputManager:SendTouchEvent(1, Enum.UserInputState.End, touchPos)
            else
                -- PC mouse click
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                wait(0.05)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
            end
            
            wait(Config:GetClickInterval())
        end
    end)
end

-- SPEED HACK (MOBILE SAFE)
local SpeedHack = {
    Enabled = false,
    OriginalWalkSpeed = 16,
    
    Toggle = function(self, enabled, value)
        self.Enabled = enabled
        if enabled then
            local targetSpeed = Config:GetWalkSpeed()
            Humanoid.WalkSpeed = targetSpeed
            
            -- Mobile: Slower updates to save battery
            local updateInterval = IS_MOBILE and 0.5 or 0.1
            
            local connection
            connection = RunService.Heartbeat:Connect(function()
                if Humanoid and Humanoid.WalkSpeed ~= targetSpeed then
                    Humanoid.WalkSpeed = targetSpeed
                end
                wait(updateInterval)
                if not self.Enabled then
                    connection:Disconnect()
                end
            end)
        else
            Humanoid.WalkSpeed = self.OriginalWalkSpeed
        end
    end,
    
    SetValue = function(self, value)
        Config.SpeedValue = value
        if self.Enabled then
            self:Toggle(true, value)
        end
    end
}

-- JUMP HACK (MOBILE SAFE)
local JumpHack = {
    Enabled = false,
    OriginalJumpPower = 50,
    
    Toggle = function(self, enabled, value)
        self.Enabled = enabled
        if enabled then
            local targetPower = Config:GetJumpPower()
            Humanoid.JumpPower = targetPower
            
            local connection
            connection = RunService.Heartbeat:Connect(function()
                if Humanoid and Humanoid.JumpPower ~= targetPower then
                    Humanoid.JumpPower = targetPower
                end
                wait(0.3) -- Less frequent checks for mobile
                if not self.Enabled then
                    connection:Disconnect()
                end
            end)
        else
            Humanoid.JumpPower = self.OriginalJumpPower
        end
    end,
    
    SetValue = function(self, value)
        Config.JumpValue = value
        if self.Enabled then
            self:Toggle(true, value)
        end
    end
}

-- FLY HACK (MOBILE ADAPTED)
local FlyHack = {
    Flying = false,
    BodyVelocity = nil,
    
    Toggle = function(self, enabled)
        if enabled and not self.Flying then
            self.Flying = true
            local flySpeed = Config:GetFlySpeed()
            
            self.BodyVelocity = Instance.new("BodyVelocity")
            self.BodyVelocity.Velocity = Vector3.new(0, 0, 0)
            self.BodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
            self.BodyVelocity.P = 1000
            self.BodyVelocity.Parent = HumanoidRootPart
            
            local Camera = Workspace.CurrentCamera
            
            -- Mobile control scheme
            if IS_MOBILE then
                -- Virtual joystick for mobile
                spawn(function()
                    while self.Flying and HumanoidRootPart do
                        local direction = Vector3.new()
                        
                        -- Mobile tilt controls (simulated)
                        if VirtualInputService:GetKeysPressed()[Enum.KeyCode.W] then
                            direction = direction + Camera.CFrame.LookVector
                        end
                        if VirtualInputService:GetKeysPressed()[Enum.KeyCode.S] then
                            direction = direction - Camera.CFrame.LookVector
                        end
                        
                        self.BodyVelocity.Velocity = direction * flySpeed
                        RunService.RenderStepped:Wait()
                    end
                end)
            else
                -- PC controls
                spawn(function()
                    while self.Flying and HumanoidRootPart do
                        local direction = Vector3.new()
                        
                        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                            direction = direction + Camera.CFrame.LookVector
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                            direction = direction - Camera.CFrame.LookVector
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                            direction = direction - Camera.CFrame.RightVector
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                            direction = direction + Camera.CFrame.RightVector
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                            direction = direction + Vector3.new(0, 1, 0)
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                            direction = direction - Vector3.new(0, 1, 0)
                        end
                        
                        self.BodyVelocity.Velocity = direction * flySpeed
                        RunService.RenderStepped:Wait()
                    end
                end)
            end
            
        elseif not enabled and self.Flying then
            self.Flying = false
            if self.BodyVelocity then
                self.BodyVelocity:Destroy()
                self.BodyVelocity = nil
            end
        end
    end,
    
    SetSpeed = function(self, value)
        Config.FlySpeedValue = value
    end
}

-- MOBILE EGG FARM
local EggFarm = {
    Farming = false,
    
    Start = function(self)
        if IS_MOBILE then
            Library:Notify("Egg Farm started (Mobile Mode)")
        end
        
        self.Farming = true
        spawn(function()
            while self.Farming do
                for _, egg in pairs(Workspace:GetDescendants()) do
                    if egg:IsA("Model") and egg.Name:lower():find("egg") then
                        -- Mobile-safe teleport
                        local target = egg:GetPivot()
                        HumanoidRootPart.CFrame = target + Vector3.new(0, 5, 0)
                        
                        -- Mobile tap simulation
                        if IS_MOBILE then
                            -- Touch the egg
                            firetouchinterest(HumanoidRootPart, egg.PrimaryPart, 0)
                            wait(0.1)
                            firetouchinterest(HumanoidRootPart, egg.PrimaryPart, 1)
                        else
                            -- Click the egg
                            fireclickdetector(egg:FindFirstChildOfClass("ClickDetector"))
                        end
                        
                        wait(0.5) -- Slower for mobile
                    end
                end
                wait(1)
            end
        end)
    end,
    
    Stop = function(self)
        self.Farming = false
    end
}

-- MOBILE TELEPORT SYSTEM
local TeleportSystem = {
    TeleportTo = function(self, position)
        if IS_MOBILE then
            -- Safer teleport for mobile
            local tween = game:GetService("TweenService"):Create(
                HumanoidRootPart,
                TweenInfo.new(1, Enum.EasingStyle.Linear),
                {CFrame = position}
            )
            tween:Play()
            Library:Notify("Teleporting...")
        else
            HumanoidRootPart.CFrame = position
        end
    end
}

-- CREATE GUI (MOBILE ADAPTED)
local MainTab = Window:CreateTab("Main")

-- Speed Control
MainTab:CreateLabel(IS_MOBILE and "Speed (Swipe Up/Down)" or "Speed Hack")

SpeedToggle = MainTab:CreateToggle("Speed Hack", false, function(state)
    SpeedHack:Toggle(state, Config.SpeedValue)
end)

SpeedSlider = MainTab:CreateSlider("Speed Value", 1, 100, 50, true, function(value)
    SpeedHack:SetValue(value)
    SpeedValue = value
    local speed = math.floor(Config:GetWalkSpeed())
    Library:Notify("Speed: " .. speed .. " (" .. value .. ")")
end)

-- Jump Control
MainTab:CreateLabel("Jump Hack")

JumpToggle = MainTab:CreateToggle("Jump Hack", false, function(state)
    JumpHack:Toggle(state, Config.JumpValue)
end)

JumpSlider = MainTab:CreateSlider("Jump Value", 1, 100, 50, true, function(value)
    JumpHack:SetValue(value)
    local jump = math.floor(Config:GetJumpPower())
    Library:Notify("Jump: " .. jump .. " (" .. value .. ")")
end)

-- Fly Control
MainTab:CreateLabel("Fly Hack")

FlyToggle = MainTab:CreateToggle("Fly Hack", false, function(state)
    FlyHack:Toggle(state)
end)

FlySlider = MainTab:CreateSlider("Fly Speed", 1, 100, 50, true, function(value)
    FlyHack:SetSpeed(value)
    local fly = math.floor(Config:GetFlySpeed())
    Library:Notify("Fly Speed: " .. fly .. " (" .. value .. ")")
end)

-- Auto Farm Tab
local AutoFarmTab = Window:CreateTab("Auto Farm")

AutoFarmTab:CreateToggle("Auto Hatch Eggs", false, function(state)
    if state then
        EggFarm:Start()
    else
        EggFarm:Stop()
    end
end)

AutoFarmTab:CreateToggle("Auto Click", false, function(state)
    AutoClickEnabled = state
    if state then
        StartAutoClick()
    end
end)

AutoFarmTab:CreateSlider("Click Speed", 1, 100, 30, true, function(value)
    Config.ClickSpeedValue = value
    Library:Notify("Click Speed: " .. value)
end)

-- Mobile Quick Actions Tab
local QuickTab = Window:CreateTab("Quick Actions")

QuickTab:CreateButton("Enable All", function()
    SpeedToggle:Set(true)
    JumpToggle:Set(true)
    FlyToggle:Set(true)
    Library:Notify("All hacks enabled!")
end)

QuickTab:CreateButton("Disable All", function()
    SpeedToggle:Set(false)
    JumpToggle:Set(false)
    FlyToggle:Set(false)
    Library:Notify("All hacks disabled!")
end)

QuickTab:CreateButton("Max Speed", function()
    SpeedSlider:Set(100)
    SpeedToggle:Set(true)
    Library:Notify("Max speed activated!")
end)

QuickTab:CreateButton("Super Jump", function()
    JumpSlider:Set(100)
    JumpToggle:Set(true)
    Library:Notify("Super jump activated!")
end)

-- MOBILE GESTURE HELP
if IS_MOBILE then
    local HelpTab = Window:CreateTab("Mobile Help")
    
    HelpTab:CreateLabel("Gesture Controls:")
    HelpTab:CreateLabel("→ Swipe Right: Enable All")
    HelpTab:CreateLabel("← Swipe Left: Disable All")
    HelpTab:CreateLabel("↑ Swipe Up: Speed +10")
    HelpTab:CreateLabel("↓ Swipe Down: Speed -10")
    HelpTab:CreateLabel("Tap : Toggle Auto Click")
    HelpTab:CreateLabel("Tap : Toggle Menu")
end

-- MOBILE KEYBIND EMULATION
if IS_MOBILE then
    -- Volume button detection (Android)
    spawn(function()
        while wait(1) do
            -- Simulate volume button presses as hotkeys
            -- This is conceptual - actual implementation requires
            -- additional mobile-specific APIs
        end
    end)
else
    -- PC Hotkeys
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.F1 then
            SpeedToggle:Set(not SpeedHack.Enabled)
        elseif input.KeyCode == Enum.KeyCode.F2 then
            JumpToggle:Set(not JumpHack.Enabled)
        elseif input.KeyCode == Enum.KeyCode.F3 then
            FlyToggle:Set(not FlyHack.Flying)
        end
    end)
end

-- INITIALIZE MOBILE CONTROLS
MobileControls:Init()

-- CHARACTER RESPAWN HANDLER
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = Character:WaitForChild("Humanoid")
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    
    -- Re-apply hacks
    if SpeedHack.Enabled then
        SpeedHack:Toggle(true, Config.SpeedValue)
    end
    if JumpHack.Enabled then
        JumpHack:Toggle(true, Config.JumpValue)
    end
    if FlyHack.Flying then
        FlyHack:Toggle(true)
    end
end)

-- STARTUP MESSAGE
print([[
    ████████╗██████╗ ███████╗██████╗ ██╗ ██████╗████████╗
    ╚══██╔══╝██╔══██╗██╔════╝██╔══██╗██║██╔════╝╚══██╔══╝
       ██║   ██████╔╝█████╗  ██║  ██║██║██║        ██║   
       ██║   ██╔══██╗██╔══╝  ██║  ██║██║██║        ██║   
       ██║   ██║  ██║███████╗██████╔╝██║╚██████╗   ██║   
       ╚═╝   ╚═╝  ╚═╝╚══════╝╚═════╝ ╚═╝ ╚═════╝   ╚═╝   
           TREDICT INVICTUS - EXECUTE ]] .. (IS_MOBILE and "Android/iOS" or "PC"))

Library:Notify("Tredict Invictus Mobile!")
Library:Notify("Platform: " .. (IS_MOBILE and "Mobile" or "PC"))

if IS_MOBILE then
    Library:Notify("Use gestures: Swipe Right/Left for quick toggle")
    Library:Notify("Tap buttons on screen for controls")
end