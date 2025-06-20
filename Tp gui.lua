-- Variáveis globais
local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local savedPosition = nil

-- Variáveis para o sistema de arrastar
local isDragging = false
local dragStartPos = Vector2.new(0, 0)
local initialFramePos = UDim2.new(0, 0, 0, 0)

-- Função para criar a GUI
local function createGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "TeleportGUI"
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")

    -- Frame principal (fundo preto)
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 220, 0, 80) -- Tamanho ajustado para caber tudo
    MainFrame.Position = UDim2.new(0.5, -110, 0.5, -40) -- Posição inicial centralizada
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- Fundo preto
    MainFrame.BorderColor3 = Color3.fromRGB(10, 10, 10)
    MainFrame.BorderSizePixel = 2
    MainFrame.Parent = ScreenGui

    -- Barra de Título (parte arrastável e com texto)
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 25) -- 100% largura, 25 pixels altura
    TitleBar.Position = UDim2.new(0, 0, 0, 0)
    TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30) -- Um pouco mais claro que o fundo
    TitleBar.BorderColor3 = Color3.fromRGB(15, 15, 15)
    TitleBar.BorderSizePixel = 1
    TitleBar.Parent = MainFrame

    -- Texto "created by tali098766"
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, 0, 1, 0)
    TitleLabel.Position = UDim2.new(0, 0, 0, 0)
    TitleLabel.BackgroundTransparency = 1 -- Fundo transparente
    TitleLabel.Font = Enum.Font.SourceSansBold
    TitleLabel.Text = "created by tali098766"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- Cor inicial (será mudada)
    TitleLabel.TextSize = 16
    TitleLabel.Parent = TitleBar

    -- Container para os botões (para organização)
    local ButtonsFrame = Instance.new("Frame")
    ButtonsFrame.Size = UDim2.new(1, 0, 1, -25) -- Ocupa o resto do MainFrame (100% largura, altura total - 25 da TitleBar)
    ButtonsFrame.Position = UDim2.new(0, 0, 0, 25) -- Começa abaixo da TitleBar
    ButtonsFrame.BackgroundTransparency = 1 -- Fundo transparente
    ButtonsFrame.Parent = MainFrame

    -- Botão "Set" (Vermelho)
    local SetButton = Instance.new("TextButton")
    SetButton.Size = UDim2.new(0.5, -5, 1, -10) -- Metade da largura, com um pequeno espaço
    SetButton.Position = UDim2.new(0, 5, 0, 5) -- 5 pixels da esquerda e do topo
    SetButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Vermelho
    SetButton.BorderColor3 = Color3.fromRGB(150, 30, 30)
    SetButton.BorderSizePixel = 1
    SetButton.Font = Enum.Font.SourceSansBold
    SetButton.Text = "Set"
    SetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SetButton.TextSize = 20
    SetButton.Parent = ButtonsFrame

    -- Botão "TP" (Verde)
    local TeleportButton = Instance.new("TextButton")
    TeleportButton.Size = UDim2.new(0.5, -5, 1, -10) -- Metade da largura, com um pequeno espaço
    TeleportButton.Position = UDim2.new(0.5, 0, 0, 5) -- Começa à direita do SetButton, 5 pixels do topo
    TeleportButton.BackgroundColor3 = Color3.fromRGB(50, 180, 50) -- Verde
    TeleportButton.BorderColor3 = Color3.fromRGB(30, 130, 30)
    TeleportButton.BorderSizePixel = 1
    TeleportButton.Font = Enum.Font.SourceSansBold
    TeleportButton.Text = "TP"
    TeleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    TeleportButton.TextSize = 20
    TeleportButton.Parent = ButtonsFrame

    -- --- Lógica de Arrastar a GUI ---
    local UserInputService = game:GetService("UserInputService")

    -- Quando o mouse/toque pressiona a barra de título
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            dragStartPos = UserInputService:GetMouseLocation()
            initialFramePos = MainFrame.Position
        end
    end)

    -- Enquanto o mouse/toque se move
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local currentMousePos = UserInputService:GetMouseLocation()
            local delta = currentMousePos - dragStartPos

            local newX = initialFramePos.X.Offset + delta.X
            local newY = initialFramePos.Y.Offset + delta.Y

            MainFrame.Position = UDim2.new(0, newX, 0, newY)
        end
    end)

    -- Quando o mouse/toque é liberado
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)

    -- --- Lógica de Texto Rainbow ---
    local hue = 0 -- Começa em 0 (vermelho)
    task.spawn(function() -- Usamos task.spawn para não bloquear o resto do script
        while true do
            TitleLabel.TextColor3 = Color3.fromHSV(hue, 1, 1) -- Hue varia, Saturation e Value ficam em 1
            hue = hue + 0.01 -- Pequeno incremento para transição suave
            if hue >= 1 then
                hue = 0 -- Reinicia o ciclo de cores quando atinge o fim
            end
            task.wait(0.01) -- Pequena pausa para a transição ser visível
        end
    end)

    -- --- Conecta as funções dos botões (inalterado) ---
    SetButton.MouseButton1Click:Connect(function()
        savedPosition = HumanoidRootPart.CFrame
        SetButton.Text = "SET!" -- Feedback visual
        task.wait(0.5)
        SetButton.Text = "Set"
    end)

    TeleportButton.MouseButton1Click:Connect(function()
        if savedPosition then
            HumanoidRootPart.CFrame = savedPosition
            TeleportButton.Text = "TP!" -- Feedback visual
            task.wait(0.5)
            TeleportButton.Text = "TP"
        else
            TeleportButton.Text = "ERRO!" -- Feedback visual
            task.wait(0.5)
            TeleportButton.Text = "TP"
        end
    end)
end

-- Chama a função para criar a GUI
createGUI()
