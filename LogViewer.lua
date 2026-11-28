-- MATRIX HUB // LOG VIEWER V2
-- Cliente: Roblox LogService
-- Funciones: ocultar/mostrar, copiar registro individual, copiar todo y limpiar.
-- Nota: solo muestra mensajes que el cliente expone mediante LogService.

local Players = game:GetService("Players")
local LogService = game:GetService("LogService")

local player = Players.LocalPlayer
if not player then return end

local playerGui = player:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("MatrixLogViewer")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "MatrixLogViewer"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 900
gui.Parent = playerGui

local logs = {}
local MAX_LOGS = 150
local hidden = false

local function copyText(value)
    local fn = setclipboard or toclipboard
    if type(fn) ~= "function" then
        return false
    end
    return pcall(fn, tostring(value))
end

local function corner(object, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = object
end

local function makeButton(parent, text, size, position, color)
    local b = Instance.new("TextButton")
    b.Size = size
    b.Position = position
    b.BackgroundColor3 = color or Color3.fromRGB(37, 46, 58)
    b.BorderSizePixel = 0
    b.Text = text
    b.TextColor3 = Color3.fromRGB(240, 245, 250)
    b.TextSize = 12
    b.Font = Enum.Font.GothamBold
    b.AutoButtonColor = true
    b.Parent = parent
    corner(b, 7)
    return b
end

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.new(0.9, 0, 0.58, 0)
panel.Position = UDim2.new(0.05, 0, 0.2, 0)
panel.BackgroundColor3 = Color3.fromRGB(19, 22, 29)
panel.BorderSizePixel = 0
panel.Parent = gui
corner(panel, 12)

local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, -20, 0, 32)
header.Position = UDim2.fromOffset(10, 5)
header.BackgroundTransparency = 1
header.Text = "MATRIX HUB  /  LOG VIEWER"
header.TextColor3 = Color3.fromRGB(75, 225, 160)
header.TextSize = 15
header.Font = Enum.Font.GothamBold
header.TextXAlignment = Enum.TextXAlignment.Left
header.Parent = panel

local clearButton = makeButton(panel, "CLEAR", UDim2.fromOffset(58, 30), UDim2.new(1, -8, 0, 7), Color3.fromRGB(120, 55, 60))
clearButton.AnchorPoint = Vector2.new(1, 0)

local copyAllButton = makeButton(panel, "COPY ALL", UDim2.fromOffset(78, 30), UDim2.new(1, -72, 0, 7))
copyAllButton.AnchorPoint = Vector2.new(1, 0)

local hideButton = makeButton(panel, "HIDE", UDim2.fromOffset(55, 30), UDim2.new(1, -158, 0, 7))
hideButton.AnchorPoint = Vector2.new(1, 0)

local scroll = Instance.new("ScrollingFrame")
scroll.Name = "LogList"
scroll.Position = UDim2.new(0, 9, 0, 43)
scroll.Size = UDim2.new(1, -18, 1, -52)
scroll.BackgroundColor3 = Color3.fromRGB(11, 13, 18)
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 5
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.Parent = panel
corner(scroll, 8)

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 5)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scroll

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 6)
padding.PaddingBottom = UDim.new(0, 6)
padding.PaddingLeft = UDim.new(0, 5)
padding.PaddingRight = UDim.new(0, 5)
padding.Parent = scroll

local toggle = makeButton(gui, "M", UDim2.fromOffset(48, 48), UDim2.new(0, 14, 0.45, 0), Color3.fromRGB(20, 165, 112))
toggle.Name = "Toggle"
toggle.TextSize = 20
toggle.Visible = false
corner(toggle, 24)

local function addLog(message, messageType)
    local entry = {
        message = tostring(message),
        messageType = tostring(messageType)
    }
    table.insert(logs, entry)

    if #logs > MAX_LOGS then
        table.remove(logs, 1)
        local firstRow = scroll:FindFirstChild("LogRow")
        if firstRow then firstRow:Destroy() end
    end

    local row = Instance.new("Frame")
    row.Name = "LogRow"
    row.Size = UDim2.new(1, -2, 0, 62)
    row.BackgroundColor3 = Color3.fromRGB(27, 32, 41)
    row.BorderSizePixel = 0
    row.Parent = scroll
    corner(row, 7)

    local label = Instance.new("TextLabel")
    label.Position = UDim2.fromOffset(8, 4)
    label.Size = UDim2.new(1, -83, 1, -8)
    label.BackgroundTransparency = 1
    label.Text = "[" .. entry.messageType .. "] " .. entry.message
    label.TextColor3 = Color3.fromRGB(220, 226, 235)
    label.TextSize = 11
    label.Font = Enum.Font.Code
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = row

    local copyButton = makeButton(row, "COPY", UDim2.fromOffset(65, 29), UDim2.new(1, -7, 0.5, 0), Color3.fromRGB(28, 125, 91))
    copyButton.AnchorPoint = Vector2.new(1, 0.5)
    copyButton.Activated:Connect(function()
        local ok = copyText("[" .. entry.messageType .. "] " .. entry.message)
        copyButton.Text = ok and "COPIED" or "N/A"
        task.delay(1.2, function()
            if copyButton.Parent then copyButton.Text = "COPY" end
        end)
    end)

    task.defer(function()
        scroll.CanvasPosition = Vector2.new(0, math.max(0, layout.AbsoluteContentSize.Y))
    end)
end

for _, entry in ipairs(LogService:GetLogHistory()) do
    addLog(entry.message, entry.messageType)
end

LogService.MessageOut:Connect(addLog)

copyAllButton.Activated:Connect(function()
    local lines = {}
    for _, entry in ipairs(logs) do
        table.insert(lines, "[" .. entry.messageType .. "] " .. entry.message)
    end
    local ok = copyText(table.concat(lines, "\n"))
    copyAllButton.Text = ok and "COPIED" or "N/A"
    task.delay(1.2, function()
        if copyAllButton.Parent then copyAllButton.Text = "COPY ALL" end
    end)
end)

clearButton.Activated:Connect(function()
    table.clear(logs)
    for _, child in ipairs(scroll:GetChildren()) do
        if child.Name == "LogRow" then child:Destroy() end
    end
end)

hideButton.Activated:Connect(function()
    panel.Visible = false
    toggle.Visible = true
end)

toggle.Activated:Connect(function()
    panel.Visible = true
    toggle.Visible = false
end)
