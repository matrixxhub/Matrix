-- Matrix Hub - Visual UI Demo (Roblox Studio LocalScript)
-- UI-only sample: no executor APIs, remote code loading, gameplay automation, or anti-cheat evasion.
-- Place this file in StarterPlayer > StarterPlayerScripts as a LocalScript.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local oldGui = playerGui:FindFirstChild("MatrixHubVisualDemo")
if oldGui then
    oldGui:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "MatrixHubVisualDemo"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 50
gui.Parent = playerGui

local function make(className, properties, parent)
    local object = Instance.new(className)
    for key, value in pairs(properties) do
        object[key] = value
    end
    object.Parent = parent
    return object
end

local panel = make("Frame", {
    Name = "Panel",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(340, 220),
    BackgroundColor3 = Color3.fromRGB(12, 18, 15),
    BorderSizePixel = 0,
    Visible = true,
}, gui)
make("UICorner", { CornerRadius = UDim.new(0, 12) }, panel)
make("UIStroke", { Color = Color3.fromRGB(0, 190, 90), Thickness = 1.5 }, panel)

local title = make("TextLabel", {
    Name = "Title",
    Position = UDim2.fromOffset(18, 14),
    Size = UDim2.new(1, -36, 0, 34),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    Text = "MATRIX HUB",
    TextColor3 = Color3.fromRGB(120, 255, 175),
    TextSize = 22,
    TextXAlignment = Enum.TextXAlignment.Left,
}, panel)

make("TextLabel", {
    Name = "Description",
    Position = UDim2.fromOffset(18, 58),
    Size = UDim2.new(1, -36, 0, 48),
    BackgroundTransparency = 1,
    Font = Enum.Font.Gotham,
    Text = "Demostración visual para Roblox Studio.\nEste panel no modifica la partida.",
    TextColor3 = Color3.fromRGB(205, 215, 208),
    TextSize = 13,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
}, panel)

local status = make("TextLabel", {
    Name = "Status",
    Position = UDim2.fromOffset(18, 118),
    Size = UDim2.new(1, -36, 0, 22),
    BackgroundTransparency = 1,
    Font = Enum.Font.Code,
    Text = "ESTADO: INTERFAZ ACTIVA",
    TextColor3 = Color3.fromRGB(0, 220, 110),
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
}, panel)

local toggleButton = make("TextButton", {
    Name = "TogglePanel",
    Position = UDim2.fromOffset(18, 156),
    Size = UDim2.fromOffset(142, 42),
    BackgroundColor3 = Color3.fromRGB(0, 105, 55),
    BorderSizePixel = 0,
    Font = Enum.Font.GothamBold,
    Text = "OCULTAR",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 13,
}, panel)
make("UICorner", { CornerRadius = UDim.new(0, 8) }, toggleButton)

local closeButton = make("TextButton", {
    Name = "CloseDemo",
    Position = UDim2.fromOffset(174, 156),
    Size = UDim2.fromOffset(148, 42),
    BackgroundColor3 = Color3.fromRGB(75, 35, 35),
    BorderSizePixel = 0,
    Font = Enum.Font.GothamBold,
    Text = "CERRAR DEMO",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 13,
}, panel)
make("UICorner", { CornerRadius = UDim.new(0, 8) }, closeButton)

local floatingButton = make("TextButton", {
    Name = "FloatingButton",
    AnchorPoint = Vector2.new(1, 1),
    Position = UDim2.new(1, -20, 1, -20),
    Size = UDim2.fromOffset(48, 48),
    BackgroundColor3 = Color3.fromRGB(0, 95, 48),
    BorderSizePixel = 0,
    Font = Enum.Font.GothamBlack,
    Text = "M",
    TextColor3 = Color3.fromRGB(180, 255, 205),
    TextSize = 22,
    Visible = false,
}, gui)
make("UICorner", { CornerRadius = UDim.new(1, 0) }, floatingButton)
make("UIStroke", { Color = Color3.fromRGB(0, 220, 105), Thickness = 1.5 }, floatingButton)

local closed = false
local function cleanup()
    if closed then return end
    closed = true
    gui:Destroy()
end

toggleButton.Activated:Connect(function()
    panel.Visible = false
    floatingButton.Visible = true
end)

floatingButton.Activated:Connect(function()
    if closed then return end
    panel.Visible = true
    floatingButton.Visible = false
end)

closeButton.Activated:Connect(cleanup)

-- Emergency close: five consecutive presses of RightShift within two seconds.
local presses = {}
local inputConnection
inputConnection = UserInputService.InputBegan:Connect(function(input, processed)
    if processed or closed or input.KeyCode ~= Enum.KeyCode.RightShift then
        return
    end

    local now = os.clock()
    table.insert(presses, now)
    while #presses > 0 and now - presses[1] > 2 do
        table.remove(presses, 1)
    end

    if #presses >= 5 then
        cleanup()
    end
end)

gui.Destroying:Connect(function()
    closed = true
    if inputConnection then
        inputConnection:Disconnect()
        inputConnection = nil
    end
end)
