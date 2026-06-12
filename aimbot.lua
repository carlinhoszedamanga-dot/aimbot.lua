-- // Bibliotecas
local uis = game:GetService("UserInputService")
local plrs = game:GetService("Players")
local run = game:GetService("RunService")
local tween = game:GetService("TweenService")
local http = game:GetService("HttpService")

-- // Variáveis Globais
local localPlayer = plrs.LocalPlayer
local camera = workspace.CurrentCamera
local connections = {}

-- // Configurações (CONFIGURE AQUI)
local config = {
AimBot = {
Enabled = false,
Smoothness = 20, -- Quanto menor, mais rápido.
ShowFOV = false,
FOVSize = 100,
FOVCircleColor = Color3.fromRGB(255, 0, 0),
AimKey = Enum.KeyCode.MouseButton2, -- Botão direito do mouse
},
ESP = {
Enabled = false,
Box = true,
Name = true,
Health = true,
Level = true,
Color = Color3.fromRGB(0, 255, 0),
BoxOutlineColor = Color3.fromRGB(0, 0, 0),
},
Tracers = {
Enabled = false,
},
}

-- // Aimbot
local function aimAt(target, smoothness)
if not config.AimBot.Enabled or not target.Character then return end
local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
if not targetRoot then return end

local aimPos = targetRoot.Position
local screenPoint = camera:WorldToScreenPoint(aimPos)
local mousePos = uis:GetMouseLocation()

-- FOV (Campo de Visão)
if config.AimBot.ShowFOV then
if not aimFOVCircle then
aimFOVCircle = Drawing.new("Circle")
aimFOVCircle.Color = config.AimBot.FOVCircleColor
aimFOVCircle.Thickness = 2
aimFOVCircle.Radius = config.AimBot.FOVSize
aimFOVCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
aimFOVCircle.Visible = true
end

local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - mousePos).Magnitude
if distance <= config.AimBot.FOVSize then
local newMousePos = Vector2.new(screenPoint.X, screenPoint.Y)
uis.MouseDelta = Vector2.new((newMousePos.X - mousePos.X) / smoothness, (newMousePos.Y - mousePos.Y) / smoothness)
end
else
local newMousePos = Vector2.new(screenPoint.X, screenPoint.Y)
uis.MouseDelta = Vector2.new((newMousePos.X - mousePos.X) / smoothness, (newMousePos.Y - mousePos.Y) / smoothness)
end
end

-- // ESP
local function createESP()
for _, player in ipairs(plrs:GetPlayers()) do
if player ~= localPlayer then
local esp = {}
local billboard = Drawing.new("BillboardGui")
billboard.Visible = false
billboard.Size = UDim2.new(4, 0, 1.5, 0)
billboard.StudsOffset = Vector3.new(0, 3, 0)
billboard.Adornee = nil
billboard.Parent = nil

local boxOutline = Drawing.new("Square")
boxOutline.Visible = false
boxOutline.Color = config.ESP.BoxOutlineColor
boxOutline.Filled = false
boxOutline.Thickness = 2

local username = Drawing.new("Text")
username.Visible = false
username.Center = true
username.Color = Color3.fromRGB(255, 255, 255)

local health = Drawing.new("Text")
health.Visible = false
health.Center = true

local level = Drawing.new("Text")
level.Visible = false
level.Center = true
level.Color = Color3.fromRGB(255, 0, 0)

local function updateEsp()
if not player.Character then
billboard.Parent = nil
boxOutline.Visible = false
username.Visible = false
health.Visible = false
level.Visible = false
return
end

local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
if not rootPart then return end

-- Coordinates
local rootPos, onScreen = camera:WorldToViewportPoint(rootPart.Position)
if not onScreen then
billboard.Parent = nil
boxOutline.Visible = false
username.Visible = false
health.Visible = false
level.Visible = false
return
end

-- Billboard
if not billboard.Adornee then
billboard.Adornee = rootPart
billboard.Parent = workspace
end

-- Box
local humanoid = player.Character:FindFirstChild("Humanoid")
local healthPercent = humanoid and humanoid.Health / (humanoid.MaxHealth or 100) or 0
local boxSize = Vector2.new(5, 6 * (rootPart.Position.Y - (rootPart.Position.Y - 5))) -- Voilá, box
local boxPos = Vector2.new(rootPos.X - boxSize.X / 2, rootPos.Y - boxSize.Y / 2)

boxOutline.Size = boxSize
boxOutline.Position = boxPos
boxOutline.Visible = config.ESP.Enabled and config.ESP.Box

-- Name
username.Text = player.Name
username.Position = Vector2.new(rootPos.X, rootPos.Y - 20)
username.Visible = config.ESP.Enabled and config.ESP.Name

-- Health
health.Text = humanoid and "HP: ".. math.floor(humanoid.Health) or "HP: N/A"
health.Position = Vector2.new(rootPos.X, rootPos.Y - 5)
health.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
health.Visible = config.ESP.Enabled and config.ESP.Health

-- Level (Blox Fruits)
local levelData = player:FindFirstChild("Data") and player.Data:FindFirstChild("Level")
level.Text = levelData and "Level: ".. levelData.Value or "Level: N/A"
level.Position = Vector2.new(rootPos.X, rootPos.Y + 10)
level.Visible = config.ESP.Enabled and config.ESP.Level
end

connections[player] = run.Heartbeat:Connect(updateEsp)

-- Loop para excluir na morte
player.CharacterAdded:Connect(function(char)
billboard.Parent = workspace
esp(char)
end)
end
end
end

-- // Painel Flutuante (Tween Smooth)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BloxFruitsCheat"
screenGui.ResetOnSpawn = false
screenGui.Parent = plrs.LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 200, 0, 250)
mainFrame.Position = UDim2.new(0.5, -100, 0.5, -125)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 4)
uiCorner.Parent = mainFrame

local dragFrame = Instance.new("Frame")
dragFrame.Name = "DragFrame"
dragFrame.Size = UDim2.new(1, 0, 0, 30)
dragFrame.BackgroundTransparency = 1
dragFrame.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Blox Fruits Cheat"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = dragFrame

-- // Toggle: Aimbot
local aimbotToggle = Instance.new("TextButton")
aimbotToggle.Name = "ToggleAimbot"
aimbotToggle.Size = UDim2.new(0.8, 0, 0, 25)
aimbotToggle.Position = UDim2.new(0.1, 0, 0.15, 0)
aimbotToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
aimbotToggle.Text = "Aimbot "
aimbotToggle.TextColor3 = Color3.fromRGB(255, 0, 0)
aimbotFocus = Drawing.new("Circle")

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 4)
toggleCorner.Parent = aimbotToggle

aimbotToggle.Parent = mainFrame

-- // Toggle: ESP
local espToggle = Instance.new("TextButton")
espToggle.Name = "ToggleESP"
espToggle.Size = UDim2.new(0.8, 0, 0, 25)
espToggle.Position = UDim2.new(0.1, 0, 0.3, 0)
espToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
espToggle.Text = "ESP "
espToggle.TextColor3 = Color3.fromRGB(0, 255, 0)

local espCorner = Instance.new("UICorner")
espCorner.CornerRadius = UDim.new(0.1, 0)
espCorner.Parent = espToggle

espToggle.Parent = mainFrame

-- // Toggle: Aimbot Camera Follow
local camToggle = Instance.new("TextButton")
camToggle.Name = "ToggleCam"
camToggle.Size = UDim2.new(0.8, 0, 0.0, 25)
camToggle.Position = UDim2.new(0.1, 0, 0.45, 0)
camToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
camToggle.Text = "Aimbot Cam "
camToggle.TextColor3 = Color3.fromRGB(255, 255, 0)

local camCorner = Instance.new("UICorner")
camCorner.CornerRadius = UDim.new(0, 4)
camCorner.Parent = camToggle

camToggle.Parent = mainFrame

-- // Slider: Smoothness
local smoothnessLabel = Instance.new("TextLabel")
smoothnessLabel.Name = "SmoothLabel"
smoothnessLabel.Size = UDim2.new(0.8, 0, 0.0, 20)
smoothnessLabel.Position = UDim2.new(0.1, 0, 0.6, 0)
smoothnessLabel.BackgroundTransparency = 1
smoothnessLabel.Text = "Smoothness: ".. config.AimBot.Smoothness
smoothnessLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
smoothnessLabel.TextScaled = true
smoothnessLabel.Font = Enum.Font.Gotham
smoothnessLabel.Parent = mainFrame

local smoothnessSlider = Instance.new("TextButton")
smoothnessSlider.Name = "SmoothSlider"
smoothnessSlider.Size = UDim2.new(0.8, 0, 0.0, 15)
smoothnessSlider.Position = UDim2.new(0.1, 0, 0.65, 0)
smoothnessSlider.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
smoothnessSlider.Text = ""
smoothnessSlider.Parent = mainFrame

local sliderFill = Instance.new("Frame")
sliderFill.Name = "SliderFill"
sliderFill.Size = UDim2.new(0, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
sliderFill.Parent = smoothnessSlider

-- // Botão de Seleção de Alvo
local targetButton = Instance.new("TextButton")
targetButton.Name = "TargetButton"
targetButton.Size = UDim2.new(0.8, 0, 0.0, 25)
targetButton.Position = UDim2.new(0.1, 0, 0.8, 0)
targetButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
targetButton.Text = "Selec. Alvo"
targetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
targetButton.Parent = mainFrame

local targetCorner = Instance.new("UICorner")
targetCorner.CornerRadius = UDim.new(0, 4)
targetCorner.Parent = targetButton

-- // Seleção de Alvo (Auto-Target)
local currentTarget = nil
targetButton.MouseButton1Click:Connect(function()
currentTarget = nil
local closestDistance = math.huge
for _, player in ipairs(plrs:GetPlayers()) do
if player ~= localPlayer and player.Character then
local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
if rootPart then
local distance = (rootPart.Position - localPlayer.Character.HumanoidRootPart.Position).Magnitude
if distance < closestDistance then
closestDistance = distance
currentTarget = player
end
end
end
end
if currentTarget then print("Alvo selecionado:", currentTarget.Name) end
end)

-- // Toggle Aimbot
aimbotToggle.MouseButton1Click:Connect(function()
config.AimBot.Enabled = not config.AimBot.Enabled
aimbotToggle.Text = "Aimbot [".. (config.AimBot.Enabled and "ON" or "OFF").. "]"
aimbotToggle.TextColor3 = config.AimBot.Enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
if not config.AimBot.Enabled then
aimAt(nil, 0)
end
end)

-- // Toggle ESP
espToggle.MouseButton1Click:Connect(function()
config.ESP.Enabled = not config.ESP.Enabled
espToggle.Text = "ESP [".. (config.ESP.Enabled and "ON" or "OFF").. "]"
espToggle.TextColor3 = config.ESP.Enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
if config.ESP.Enabled then
createESP()
else
for _, v in pairs(Drawing.getObjects()) do
if v then v:Remove() end
end
end
end)

-- // Toggle Aimbot Camera
camToggle.MouseButton1Click:Connect(function()
config.AimBot.CameraFollow = not config.AimBot.CameraFollow
camToggle.Text = "Aimbot Cam [".. (config.AimBot.CameraFollow and "ON" or "OFF").. "]"
camToggle.TextColor3 = config.AimBot.CameraFollow and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 0)
end)

-- // Arraste do Painel
local dragging
local dragInput
local dragStart
local startPos

local function updateInput(input)
local delta = input.Position - dragStart
mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

dragFrame.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 then
dragging = true
dragStart = input.Position
startPos = mainFrame.Position
input.Changed:Connect(function()
if input.UserInputState == Enum.UserInputState.End then
dragging = false
end
end)
end
end)

dragFrame.InputChanged:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseMovement then
dragInput = input
end
end)

uis.InputChanged:Connect(function(input)
if input == dragInput and dragging then
updateInput(input)
end
end)

-- // Slider de Smoothness
smoothnessSlider.MouseButton1Down:Connect(function()
local conn
conn = uis.InputChanged:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseMovement then
local mousePos = uis:GetMouseLocation().X
local sliderPos = smoothnessSlider.AbsolutePosition.X
local sliderSize = smoothnessSlider.AbsoluteSize.X
local percent = math.clamp((mousePos - sliderPos) / sliderSize, 0, 1)
sliderFill.Size = UDim2.new(percent, 0, 1, 0)
config.AimBot.Smoothness = math.floor(1 + 50 * percent) -- 1-50
smoothnessLabel.Text = "Smoothness: ".. config.AimBot.Smoothness
end
end)
uis.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 then
conn:Disconnect()
end
end)
end)

-- // Loop Principal
run.Heartbeat:Connect(function()
if config.AimBot.Enabled and currentTarget then
aimAt(currentTarget, config.AimBot.Smoothness)
if config.AimBot.CameraFollow then
workspace.CurrentCamera.CoordinateFrame = CFrame.lookAt(
camera.CFrame.Position,
currentTarget.Character.HumanoidRootPart.Position
)
end
end
end)

-- // Feche tudo ao reset
plrs.LocalPlayer.CharacterRemoving:Connect(function()
for _, v in pairs(Drawing.getObjects()) do
if v then v:Remove() end
end
for _, conn in pairs(connections) do
conn:Disconnect()
end
end)
