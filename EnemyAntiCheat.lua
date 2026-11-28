-- MATRIX HUB // ENEMY ANTI-CHEAT TEST
-- Standalone client-side observer. Does not modify the game's scripts.
-- Detects replicated enemy kill-stat jumps and rapid vertical displacement.
-- Client visibility is limited to data replicated by the game.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then return end

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local old = PlayerGui:FindFirstChild("MatrixEnemyAntiCheat")
if old then old:Destroy() end

local GUI = Instance.new("ScreenGui")
GUI.Name = "MatrixEnemyAntiCheat"
GUI.ResetOnSpawn = false
GUI.Parent = PlayerGui

local panel = Instance.new("Frame")
panel.Size = UDim2.fromOffset(310, 150)
panel.Position = UDim2.new(0, 12, 0.25, 0)
panel.BackgroundColor3 = Color3.fromRGB(18, 21, 28)
panel.BorderSizePixel = 0
panel.Parent = GUI
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -16, 0, 30)
title.Position = UDim2.fromOffset(8, 5)
title.BackgroundTransparency = 1
title.Text = "MATRIX HUB // ANTI-CHEAT"
title.TextColor3 = Color3.fromRGB(75, 225, 160)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = panel

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -16, 0, 24)
status.Position = UDim2.fromOffset(8, 35)
status.BackgroundTransparency = 1
status.Text = "Observando datos replicados..."
status.TextColor3 = Color3.fromRGB(205, 212, 225)
status.Font = Enum.Font.Gotham
status.TextSize = 11
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = panel

local list = Instance.new("ScrollingFrame")
list.Position = UDim2.fromOffset(8, 62)
list.Size = UDim2.new(1, -16, 1, -70)
list.BackgroundColor3 = Color3.fromRGB(11, 13, 18)
list.BorderSizePixel = 0
list.ScrollBarThickness = 4
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.CanvasSize = UDim2.new()
list.Parent = panel
Instance.new("UICorner", list).CornerRadius = UDim.new(0, 7)

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 4)
layout.Parent = list

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.fromOffset(44, 44)
toggle.Position = UDim2.new(0, 12, 0.25, 0)
toggle.Text = "M"
toggle.Visible = false
toggle.BackgroundColor3 = Color3.fromRGB(20, 165, 112)
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 19
toggle.Parent = GUI
Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)

local hide = Instance.new("TextButton")
hide.Size = UDim2.fromOffset(48, 25)
hide.Position = UDim2.new(1, -56, 0, 7)
hide.Text = "OCULTAR"
hide.BackgroundColor3 = Color3.fromRGB(43, 51, 63)
hide.TextColor3 = Color3.new(1, 1, 1)
hide.Font = Enum.Font.GothamBold
hide.TextSize = 9
hide.Parent = panel
Instance.new("UICorner", hide).CornerRadius = UDim.new(0, 5)

hide.Activated:Connect(function()
    panel.Visible = false
    toggle.Visible = true
end)
toggle.Activated:Connect(function()
    panel.Visible = true
    toggle.Visible = false
end)

local function notify(text, color)
    local row = Instance.new("TextLabel")
    row.Size = UDim2.new(1, -8, 0, 42)
    row.BackgroundColor3 = Color3.fromRGB(29, 34, 44)
    row.BorderSizePixel = 0
    row.Text = text
    row.TextWrapped = true
    row.TextColor3 = color or Color3.fromRGB(235, 235, 240)
    row.Font = Enum.Font.Gotham
    row.TextSize = 11
    row.Parent = list
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
    task.defer(function()
        list.CanvasPosition = Vector2.new(0, math.max(0, layout.AbsoluteContentSize.Y))
    end)
end

local KILL_NAMES = {
    kills = true, kill = true, kos = true, ko = true,
    eliminations = true, elimination = true
}
local function findKillStat(player)
    for _, obj in ipairs(player:GetDescendants()) do
        if (obj:IsA("IntValue") or obj:IsA("NumberValue")) and KILL_NAMES[string.lower(obj.Name)] then
            return obj
        end
    end
    return nil
end

local roundStart = os.clock()
local killSnapshots = {}
local lastKillAlert = {}
local lastPosition = {}
local lastMoveAlert = {}
local connections = {}
local running = true

local function watchPlayer(player)
    if player == LocalPlayer then return end
    local stat = findKillStat(player)
    if stat then
        killSnapshots[player] = stat.Value
        local conn = stat:GetPropertyChangedSignal("Value"):Connect(function()
            if not running then return end
            local previous = killSnapshots[player] or stat.Value
            local current = stat.Value
            local delta = current - previous
            killSnapshots[player] = current
            local now = os.clock()
            if delta > 0 then
                local elapsed = now - roundStart
                if elapsed <= 2.5 and (lastKillAlert[player] or 0) + 1.5 < now then
                    lastKillAlert[player] = now
                    notify(string.format("POSIBLE KILL RÁPIDO | %s | +%d kills | %.2fs desde inicio", player.Name, delta, elapsed), Color3.fromRGB(255, 190, 90))
                elseif delta >= 2 then
                    notify(string.format("AUMENTO DE KILLS | %s | +%d", player.Name, delta), Color3.fromRGB(255, 190, 90))
                end
            end
        end)
        table.insert(connections, conn)
    end
end

local function bindCharacter(player, character)
    if player == LocalPlayer then return end
    local root = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart", 5)
    if not root then return end
    lastPosition[player] = { y = root.Position.Y, t = os.clock() }
end

for _, player in ipairs(Players:GetPlayers()) do
    watchPlayer(player)
    if player.Character then bindCharacter(player, player.Character) end
    table.insert(connections, player.CharacterAdded:Connect(function(char)
        bindCharacter(player, char)
    end))
end

table.insert(connections, Players.PlayerAdded:Connect(function(player)
    watchPlayer(player)
    table.insert(connections, player.CharacterAdded:Connect(function(char)
        bindCharacter(player, char)
    end))
end))

table.insert(connections, Players.PlayerRemoving:Connect(function(player)
    killSnapshots[player] = nil
    lastPosition[player] = nil
    lastMoveAlert[player] = nil
end))

table.insert(connections, RunService.Heartbeat:Connect(function()
    if not running then return end
    local now = os.clock()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            if root then
                local oldPos = lastPosition[player]
                if oldPos then
                    local dt = now - oldPos.t
                    local dy = root.Position.Y - oldPos.y
                    if dt > 0 and dt <= 1 and math.abs(dy) >= 50 and (lastMoveAlert[player] or 0) + 3 < now then
                        lastMoveAlert[player] = now
                        local kind = dy < 0 and "POSIBLE FANTASMA" or "POSIBLE FLY"
                        notify(string.format("%s | %s | %.1f studs en %.2fs", kind, player.Name, dy, dt), Color3.fromRGB(255, 125, 115))
                    end
                end
                lastPosition[player] = { y = root.Position.Y, t = now }
            end
        end
    end
end))

notify("Detector activo. Umbral vertical: 50 studs / 1 segundo.")
status.Text = "Kills replicadas + movimiento vertical"
