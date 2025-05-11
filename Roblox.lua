-- Получаем игрока и персонажа
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local VU = game:GetService("VirtualUser")

-- ==== НАСТРОЙКИ КЛАВИШ ====
local settings = {
    ToggleAFK = Enum.KeyCode.Eight,
    ToggleFly = Enum.KeyCode.F,
    IncreaseSpeed = Enum.KeyCode.LeftShift,
    SuperSpeed = Enum.KeyCode.LeftControl
}

-- ==== GUI (красивая панель) ====
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "AutoFlyAFKGui"
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 110)
mainFrame.Position = UDim2.new(0, 20, 0, 20)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BackgroundTransparency = 0.3
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 12)
uiCorner.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🚀 Auto Fly + Anti-AFK"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 18
titleLabel.Parent = mainFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -10, 1, -30)
statusLabel.Position = UDim2.new(0, 5, 0, 30)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 16
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.TextYAlignment = Enum.TextYAlignment.Top
statusLabel.Text = "Загрузка..."
statusLabel.Parent = mainFrame

-- ==== АНТИ-АФК ====
local antiAFKEnabled = false
local function toggleAFK()
    antiAFKEnabled = not antiAFKEnabled
    if antiAFKEnabled then
        VU:Button2Down(Vector2.new())
        task.wait(1)
        VU:Button2Up(Vector2.new())
        player.Idled:Connect(function()
            if antiAFKEnabled then
                VU:Button2Down(Vector2.new())
                task.wait(1)
                VU:Button2Up(Vector2.new())
            end
        end)
    end
    updateStatus()
end

-- ==== ПОЛЁТ ====
local flying = false
local speed = 50
local maxSpeed = 100
local superSpeed = 200
local moveVector = Vector3.zero
local keys = {
    Forward = false, Left = false, Backward = false, Right = false,
    Up = false, Down = false
}

local bv, bg

local function updateMovement()
    local cam = workspace.CurrentCamera
    local direction = Vector3.zero

    if keys.Forward then direction += cam.CFrame.LookVector end
    if keys.Backward then direction -= cam.CFrame.LookVector end
    if keys.Left then direction -= cam.CFrame.RightVector end
    if keys.Right then direction += cam.CFrame.RightVector end
    if keys.Up then direction += cam.CFrame.UpVector end
    if keys.Down then direction -= cam.CFrame.UpVector end

    moveVector = direction.Magnitude > 0 and direction.Unit * speed or Vector3.zero
end

local function startFlying()
    if flying then return end
    flying = true

    bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bv.Velocity = Vector3.zero
    bv.Parent = hrp

    bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    bg.P = 1e5
    bg.CFrame = hrp.CFrame
    bg.Parent = hrp

    RS.Heartbeat:Connect(function()
        if flying then
            updateMovement()
            bv.Velocity = moveVector
            bg.CFrame = workspace.CurrentCamera.CFrame
        end
    end)

    updateStatus()
end

local function stopFlying()
    flying = false
    if bv then bv:Destroy() end
    if bg then bg:Destroy() end
    updateStatus()
end

local function toggleFly()
    if flying then stopFlying() else startFlying() end
end

-- ==== ОБНОВЛЕНИЕ СТАТУСА ====
function updateStatus()
    statusLabel.Text = 
        "[F] Полёт: " .. (flying and "ВКЛЮЧЕН" or "ВЫКЛЮЧЕН") ..
        "\n[8] Анти-АФК: " .. (antiAFKEnabled and "ВКЛЮЧЕН" or "ВЫКЛЮЧЕН") ..
        "\n[Shift] Ускорение, [Ctrl] Супер-бег"
end
updateStatus()

-- ==== УПРАВЛЕНИЕ ====
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    local code = input.KeyCode

    if code == settings.ToggleFly then toggleFly() end
    if code == settings.ToggleAFK then toggleAFK() end

    if code == Enum.KeyCode.W then keys.Forward = true end
    if code == Enum.KeyCode.A then keys.Left = true end
    if code == Enum.KeyCode.S then keys.Backward = true end
    if code == Enum.KeyCode.D then keys.Right = true end
    if code == Enum.KeyCode.Space then keys.Up = true end

    if code == settings.IncreaseSpeed then
        keys.Down = true
        speed = maxSpeed
    end
    if code == settings.SuperSpeed then
        speed = superSpeed
    end
end)

UIS.InputEnded:Connect(function(input)
    local code = input.KeyCode

    if code == Enum.KeyCode.W then keys.Forward = false end
    if code == Enum.KeyCode.A then keys.Left = false end
    if code == Enum.KeyCode.S then keys.Backward = false end
    if code == Enum.KeyCode.D then keys.Right = false end
    if code == Enum.KeyCode.Space then keys.Up = false end

    if code == settings.IncreaseSpeed then
        keys.Down = false
        speed = 50
    end
    if code == settings.SuperSpeed then
        speed = 50
    end
end)
