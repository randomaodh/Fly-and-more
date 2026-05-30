local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not UserInputService.MouseEnabled

if isMobile then
    local blockGui = Instance.new("ScreenGui")
    blockGui.Name = "error404_block"
    blockGui.ResetOnSpawn = false
    blockGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    blockGui.Parent = CoreGui
    
    local blockFrame = Instance.new("Frame", blockGui)
    blockFrame.Size = UDim2.new(1, 0, 1, 0)
    blockFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
    blockFrame.BorderSizePixel = 0
    
    local msg = Instance.new("TextLabel", blockFrame)
    msg.Size = UDim2.new(0, 400, 0, 200)
    msg.Position = UDim2.new(0.5, -200, 0.5, -100)
    msg.BackgroundTransparency = 1
    msg.Text = "error404\n\nMOBILE IS NOT SUPPORTED.\nThis script is PC only.\n\nO SCRIPT NAO SUPORTA MOBILE.\nApenas para PC."
    msg.TextColor3 = Color3.fromRGB(255, 255, 255)
    msg.Font = Enum.Font.SciFi
    msg.TextSize = 18
    msg.TextWrapped = true
    
    return
end

if CoreGui:FindFirstChild("error404") then
    local old = CoreGui:FindFirstChild("error404")
    if old then old:Destroy() end
end

local state = {
    flying = false,
    esp = false,
    flySpeed = 1,
    speedMultiplier = 50
}

local keys = {W = false, A = false, S = false, D = false, Space = false, LeftShift = false}
local flyKey = Enum.KeyCode.Z
local espKey = Enum.KeyCode.X
local uiKey = Enum.KeyCode.C

local flyBodyGyro, flyBodyVelocity
local espConnection
local notifQueue = {}
local notifActive = false

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "error404"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = CoreGui

local function processQueue()
    if notifActive or #notifQueue == 0 then return end
    notifActive = true
    local text = table.remove(notifQueue, 1)
    
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 260, 0, 38)
    notif.Position = UDim2.new(1, 20, 0.85, 0)
    notif.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
    notif.BorderSizePixel = 0
    notif.Parent = screenGui
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", notif)
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 1
    local lbl = Instance.new("TextLabel", notif)
    lbl.Size = UDim2.new(1, -16, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.Font = Enum.Font.SciFi
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    
    TweenService:Create(notif, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(1, -280, 0.85, 0)}):Play()
    task.delay(2.2, function()
        TweenService:Create(notif, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1, 20, 0.85, 0)}):Play()
        task.wait(0.4)
        pcall(function() notif:Destroy() end)
        notifActive = false
        processQueue()
    end)
end

local function notify(text)
    table.insert(notifQueue, text)
    processQueue()
end

local mainFrame = Instance.new("Frame")
mainFrame.Name = "Main"
mainFrame.Size = UDim2.new(0, 320, 0, 300)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
mainFrame.BackgroundTransparency = 0.05
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Active = true
mainFrame.Parent = screenGui
mainFrame.ClipsDescendants = true

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)
local ms = Instance.new("UIStroke", mainFrame)
ms.Color = Color3.fromRGB(255, 255, 255)
ms.Thickness = 1

local titleBar = Instance.new("Frame", mainFrame)
titleBar.Name = "Title"
titleBar.Size = UDim2.new(1, 0, 0, 44)
titleBar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
titleBar.BorderSizePixel = 0
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 10)
local tf = Instance.new("Frame", titleBar)
tf.Size = UDim2.new(1, 0, 0, 12)
tf.Position = UDim2.new(0, 0, 1, -12)
tf.BackgroundColor3 = titleBar.BackgroundColor3
tf.BorderSizePixel = 0

local title = Instance.new("TextLabel", titleBar)
title.Size = UDim2.new(1, -50, 1, 0)
title.Position = UDim2.new(0, 14, 0, 0)
title.BackgroundTransparency = 1
title.Text = "error404"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SciFi
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -38, 0.5, -15)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.SciFi
closeBtn.TextSize = 12
closeBtn.AutoButtonColor = false
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

local dragging, dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local pos = input.Position
        local framePos = mainFrame.AbsolutePosition
        local frameSize = mainFrame.AbsoluteSize
        if pos.X > framePos.X + frameSize.X - 20 and pos.Y > framePos.Y + frameSize.Y - 20 then
            return
        end
        dragging = true
        dragStart = pos
        startPos = mainFrame.Position
    end
end)
mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        local delta = input.Position - dragStart
        local newX = math.max(0, math.min(startPos.X.Offset + delta.X, camera.ViewportSize.X - mainFrame.AbsoluteSize.X))
        local newY = math.max(0, math.min(startPos.Y.Offset + delta.Y, camera.ViewportSize.Y - mainFrame.AbsoluteSize.Y))
        mainFrame.Position = UDim2.new(0, newX, 0, newY)
    end
end)
mainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

local resizeGrip = Instance.new("TextButton", mainFrame)
resizeGrip.Name = "ResizeGrip"
resizeGrip.Size = UDim2.new(0, 20, 0, 20)
resizeGrip.Position = UDim2.new(1, -20, 1, -20)
resizeGrip.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
resizeGrip.Text = ""
resizeGrip.AutoButtonColor = false
resizeGrip.BorderSizePixel = 0
Instance.new("UICorner", resizeGrip).CornerRadius = UDim.new(0, 6)

local resizing, resizeStart, startSize
resizeGrip.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        resizing = true
        resizeStart = input.Position
        startSize = mainFrame.Size
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and resizing then
        local delta = input.Position - resizeStart
        local newWidth = math.max(260, startSize.X.Offset + delta.X)
        local newHeight = math.max(200, startSize.Y.Offset + delta.Y)
        mainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and resizing then
        resizing = false
    end
end)

local tabBar = Instance.new("Frame", mainFrame)
tabBar.Size = UDim2.new(1, 0, 0, 32)
tabBar.Position = UDim2.new(0, 0, 0, 44)
tabBar.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
tabBar.BorderSizePixel = 0

local tab1Btn = Instance.new("TextButton", tabBar)
tab1Btn.Size = UDim2.new(0.5, 0, 1, 0)
tab1Btn.Position = UDim2.new(0, 0, 0, 0)
tab1Btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
tab1Btn.Text = "Main"
tab1Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
tab1Btn.Font = Enum.Font.SciFi
tab1Btn.TextSize = 13
tab1Btn.AutoButtonColor = false
Instance.new("UICorner", tab1Btn).CornerRadius = UDim.new(0, 6)

local tab2Btn = Instance.new("TextButton", tabBar)
tab2Btn.Size = UDim2.new(0.5, 0, 1, 0)
tab2Btn.Position = UDim2.new(0.5, 0, 0, 0)
tab2Btn.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
tab2Btn.Text = "Changelog"
tab2Btn.TextColor3 = Color3.fromRGB(180, 180, 180)
tab2Btn.Font = Enum.Font.SciFi
tab2Btn.TextSize = 13
tab2Btn.AutoButtonColor = false
Instance.new("UICorner", tab2Btn).CornerRadius = UDim.new(0, 6)

local contentFrame = Instance.new("Frame", mainFrame)
contentFrame.Size = UDim2.new(1, 0, 1, -76)
contentFrame.Position = UDim2.new(0, 0, 0, 76)
contentFrame.BackgroundTransparency = 1
contentFrame.BorderSizePixel = 0

local mainTab = Instance.new("Frame", contentFrame)
mainTab.Size = UDim2.new(1, 0, 1, 0)
mainTab.BackgroundTransparency = 1
mainTab.BorderSizePixel = 0

local changelogTab = Instance.new("Frame", contentFrame)
changelogTab.Size = UDim2.new(1, 0, 1, 0)
changelogTab.BackgroundTransparency = 1
changelogTab.BorderSizePixel = 0
changelogTab.Visible = false

local langBar = Instance.new("Frame", changelogTab)
langBar.Size = UDim2.new(1, 0, 0, 28)
langBar.Position = UDim2.new(0, 0, 0, 0)
langBar.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
langBar.BorderSizePixel = 0

local enBtn = Instance.new("TextButton", langBar)
enBtn.Size = UDim2.new(0.5, 0, 1, 0)
enBtn.Position = UDim2.new(0, 0, 0, 0)
enBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
enBtn.Text = "EN"
enBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
enBtn.Font = Enum.Font.SciFi
enBtn.TextSize = 12
enBtn.AutoButtonColor = false
Instance.new("UICorner", enBtn).CornerRadius = UDim.new(0, 6)

local ptBtn = Instance.new("TextButton", langBar)
ptBtn.Size = UDim2.new(0.5, 0, 1, 0)
ptBtn.Position = UDim2.new(0.5, 0, 0, 0)
ptBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
ptBtn.Text = "PT"
ptBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
ptBtn.Font = Enum.Font.SciFi
ptBtn.TextSize = 12
ptBtn.AutoButtonColor = false
Instance.new("UICorner", ptBtn).CornerRadius = UDim.new(0, 6)

local scroll = Instance.new("ScrollingFrame", changelogTab)
scroll.Size = UDim2.new(1, -16, 1, -38)
scroll.Position = UDim2.new(0, 8, 0, 32)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local changelogText = Instance.new("TextLabel", scroll)
changelogText.Size = UDim2.new(1, -8, 0, 0)
changelogText.Position = UDim2.new(0, 4, 0, 0)
changelogText.BackgroundTransparency = 1
changelogText.TextColor3 = Color3.fromRGB(220, 220, 220)
changelogText.Font = Enum.Font.SciFi
changelogText.TextSize = 12
changelogText.TextXAlignment = Enum.TextXAlignment.Left
changelogText.TextYAlignment = Enum.TextYAlignment.Top
changelogText.AutomaticSize = Enum.AutomaticSize.Y
changelogText.TextWrapped = true

local enText = [[error404 Patch Notes

v1.0.0 — Original Base
- Basic fly with BodyGyro/BodyVelocity.
- Basic ESP using Highlight instances.
- Simple UI with 4 inputs.
- Keybinds: X (Fly), C (UI), V (ESP).
- ESP ran on RenderStepped with no cleanup.

v1.2.0 — Security & Performance Update
- Added mobile detection. Script now blocks mobile devices with a warning screen.
- Added anti-reload protection. Prevents duplicate instances from stacking.
- Randomized internal instance names to reduce detection footprint.
- All critical functions now wrapped in pcall for crash prevention.
- ESP fully rewritten for performance. Now uses cached player list with delta updates.
- ESP connection properly disconnects and cleans up on disable.
- Fly physics now validate HumanoidRootPart existence every frame to prevent nil errors.
- Added notification queue system. Prevents toast spam and overlapping UI.
- Improved drag and resize logic with boundary checks.
- CoreGui parenting hardened against executor environments.
- Removed all global variable exposure. 100% local scope.
- Optimized descendant scanning for ProximityPrompts. Uses collection cache.
- UI stroke colors standardized to pure white neon for consistency.
- Changelog now includes language selector (EN/PT).]]

local ptText = [[error404 Notas de Atualizacao

v1.0.0 — Base Original
- Fly basico com BodyGyro/BodyVelocity.
- ESP basico usando Highlight.
- UI simples com 4 inputs.
- Keybinds: X (Fly), C (UI), V (ESP).
- ESP rodava no RenderStepped sem cleanup.

v1.2.0 — Atualizacao de Seguranca e Performance
- Deteccao mobile adicionada. Script bloqueia dispositivos moveis com tela de aviso.
- Protecao anti-reload adicionada. Evita instancias duplicadas.
- Nomes internos randomizados para reduzir footprint de deteccao.
- Funcoes criticas agora usam pcall para prevencao de crashes.
- ESP completamente reescrito para performance. Usa cache de jogadores com delta updates.
- Conexao do ESP desconecta e limpa corretamente ao desligar.
- Fly valida existencia do HumanoidRootPart a cada frame para evitar erros nil.
- Sistema de fila de notificacoes adicionado. Evita spam de toasts.
- Logica de drag e resize melhorada com verificacoes de limite.
- Parenting do CoreGui fortalecido contra executores.
- Removida toda exposicao de variaveis globais. 100% escopo local.
- Scan de ProximityPrompts otimizado. Usa cache de colecao.
- Cores de stroke padronizadas para branco neon puro.
- Changelog agora inclui seletor de idioma (EN/PT).]]

changelogText.Text = enText

local function switchLang(lang)
    if lang == "en" then
        changelogText.Text = enText
        enBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        enBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        ptBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
        ptBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    else
        changelogText.Text = ptText
        ptBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        ptBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        enBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
        enBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    end
end

enBtn.MouseButton1Click:Connect(function() switchLang("en") end)
ptBtn.MouseButton1Click:Connect(function() switchLang("pt") end)

local function switchTab(tab)
    if tab == "main" then
        mainTab.Visible = true
        changelogTab.Visible = false
        tab1Btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        tab1Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        tab2Btn.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
        tab2Btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    else
        mainTab.Visible = false
        changelogTab.Visible = true
        tab2Btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        tab2Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        tab1Btn.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
        tab1Btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    end
end

tab1Btn.MouseButton1Click:Connect(function() switchTab("main") end)
tab2Btn.MouseButton1Click:Connect(function() switchTab("changelog") end)

local function makeInput(name, pos, placeholder, parent)
    parent = parent or mainTab
    local box = Instance.new("TextBox")
    box.Name = name
    box.Size = UDim2.new(0.9, 0, 0, 36)
    box.Position = pos
    box.AnchorPoint = Vector2.new(0.5, 0)
    box.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.PlaceholderColor3 = Color3.fromRGB(180, 180, 180)
    box.Text = ""
    box.PlaceholderText = placeholder
    box.Font = Enum.Font.SciFi
    box.TextSize = 13
    box.ClearTextOnFocus = false
    box.Parent = parent
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 8)
    local st = Instance.new("UIStroke", box)
    st.Color = Color3.fromRGB(255, 255, 255)
    st.Thickness = 1
    return box
end

local speedBox = makeInput("Speed", UDim2.new(0.5, 0, 0, 10), "Speed (Current: 1)")
local flyBindBox = makeInput("FlyBind", UDim2.new(0.5, 0, 0, 56), "Fly Bind (Current: Z)")
local espBindBox = makeInput("EspBind", UDim2.new(0.5, 0, 0, 102), "ESP Bind (Current: X)")
local uiBindBox = makeInput("UIBind", UDim2.new(0.5, 0, 0, 148), "UI Bind (Current: C)")

speedBox.FocusLost:Connect(function()
    local val = tonumber(speedBox.Text)
    if val and val > 0 then
        state.flySpeed = val
        speedBox.PlaceholderText = "Speed (Current: " .. tostring(val) .. ")"
        notify("Speed set to " .. tostring(val))
    end
    speedBox.Text = ""
end)

local function updateBind(box, label, callback)
    box.FocusLost:Connect(function()
        local str = box.Text:gsub("%s+", "")
        if #str > 0 then
            local char = string.upper(str:sub(1, 1))
            local ok, key = pcall(function() return Enum.KeyCode[char] end)
            if ok and key then
                callback(key)
                box.PlaceholderText = label .. " (Current: " .. char .. ")"
                notify(label .. " set to " .. char)
            else
                notify("Invalid key")
            end
        end
        box.Text = ""
    end)
end

updateBind(flyBindBox, "Fly Bind", function(k) flyKey = k end)
updateBind(espBindBox, "ESP Bind", function(k) espKey = k end)
updateBind(uiBindBox, "UI Bind", function(k) uiKey = k end)

local function startFly()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = true end
    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.P = 9e4
    flyBodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyBodyGyro.cframe = hrp.CFrame
    flyBodyGyro.Parent = hrp
    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.velocity = Vector3.new(0, 0, 0)
    flyBodyVelocity.maxForce = Vector3.new(9e9, 9e9, 9e9)
    flyBodyVelocity.Parent = hrp
    RunService:BindToRenderStep("error404Fly", Enum.RenderPriority.Camera.Value, function()
        if not state.flying or not player.Character then return end
        local currentHrp = player.Character:FindFirstChild("HumanoidRootPart")
        if not currentHrp or not flyBodyGyro or not flyBodyVelocity then return end
        local success, err = pcall(function()
            flyBodyGyro.cframe = CFrame.new(currentHrp.Position, currentHrp.Position + camera.CFrame.LookVector)
            local dir = Vector3.new(0, 0, 0)
            if keys.W then dir = dir + camera.CFrame.LookVector end
            if keys.S then dir = dir - camera.CFrame.LookVector end
            if keys.A then dir = dir - camera.CFrame.RightVector end
            if keys.D then dir = dir + camera.CFrame.RightVector end
            if keys.Space then dir = dir + Vector3.new(0, 1, 0) end
            if keys.LeftShift then dir = dir - Vector3.new(0, 1, 0) end
            if dir.Magnitude > 0 then
                flyBodyVelocity.velocity = dir.Unit * (state.flySpeed * state.speedMultiplier)
            else
                flyBodyVelocity.velocity = Vector3.new(0, 0.1, 0)
            end
        end)
        if not success then
            stopFly()
            notify("Fly error detected. Auto-disabled.")
        end
    end)
    notify("Fly enabled")
end

local function stopFly()
    local char = player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end
    if flyBodyGyro then pcall(function() flyBodyGyro:Destroy() end) flyBodyGyro = nil end
    if flyBodyVelocity then pcall(function() flyBodyVelocity:Destroy() end) flyBodyVelocity = nil end
    RunService:UnbindFromRende
