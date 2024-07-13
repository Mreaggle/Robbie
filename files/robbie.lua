-- Função para salvar a instância completa do jogo no diretório do Script
saveinstance()

-- Função para carregar scripts externos de forma mais segura e com logs
local function loadScript(scriptUrl)
  local success, result = pcall(function()
    return loadstring(game:HttpGet(scriptUrl))()
  end)

  if success then
    print("Script carregado com sucesso:", scriptUrl)
  else
    warn("Erro ao carregar script:", scriptUrl, result)
  end
end

-- Carrega os scripts de bypass apenas uma vez
if game.PlaceId == 10525259646 then
  loadScript("https://raw.githubusercontent.com/BlastingStone/MyLuaStuff/master/ttd3bypass.lua")
end
loadScript("https://raw.githubusercontent.com/BlastingStone/MyLuaStuff/master/universal_antisteal_bypass.lua")

-- Adiciona um atraso para garantir que o jogo carregue antes de criar a interface
task.wait(2)

-- Função para gerar nomes aleatórios para variáveis e funções
local function randomString(length)
  local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  local str = ""
  for i = 1, length do
    str = str .. string.sub(chars, math.random(1, #chars), math.random(1, #chars))
  end
  return str
end

-- Interface
local screenName = randomString(10) -- Nome aleatório para a ScreenGui
local screen = Instance.new("ScreenGui")
screen.Name = screenName
screen.Parent = game.CoreGui

local dragName = randomString(8) -- Nome aleatório para o Frame
local drag = Instance.new("Frame")
drag.Name = dragName
drag.BackgroundColor3 = Color3.fromRGB(114, 137, 218)
drag.BorderSizePixel = 0
drag.Position = UDim2.new(0.107, 0, 0.216, 0)
drag.Size = UDim2.new(0, 256, 0, 20)
drag.Parent = screen

-- Scroll Frame
local scrollName = randomString(7)
local scroll = Instance.new("ScrollingFrame")
scroll.Name = scrollName
scroll.BackgroundColor3 = Color3.fromRGB(44, 47, 51)
scroll.BorderSizePixel = 0
scroll.Position = UDim2.new(0, 0, 1, 0)
scroll.Size = UDim2.new(1, 0, 0, 319)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.ScrollBarThickness = 4
scroll.Parent = drag

-- UI List Layout
local listName = randomString(6)
local uilist = Instance.new("UIListLayout")
uilist.Name = listName
uilist.Padding = UDim.new(0, 1)
uilist.Parent = scroll

-- Função para criar botões com ofuscação
local function criarBotao(id)
  local buttonName = randomString(6) -- Nome aleatório para o botão
  local button = Instance.new("TextButton")
  button.Name = buttonName
  button.BorderSizePixel = 0
  button.BackgroundColor3 = Color3.fromRGB(35, 39, 42)
  button.Size = UDim2.new(1, 0, 0, 50)
  button.Text = ""
  button.Parent = scroll -- Adiciona o botão ao scroll

  local nomeLabel = randomString(5) -- Nome aleatório para o label do nome
  local name = Instance.new("TextLabel")
  name.Name = nomeLabel
  name.BackgroundTransparency = 1
  name.Size = UDim2.new(1, 0, 0.5, 0)
  name.TextSize = 16
  name.Font = Enum.Font.Gotham
  name.TextColor3 = Color3.fromRGB(255, 255, 255)
  name.TextXAlignment = Enum.TextXAlignment.Left
  name.Parent = button

  local idLabel = randomString(4) -- Nome aleatório para o label do ID
  local idLabelInstance = name:Clone()
  idLabelInstance.Name = idLabel
  idLabelInstance.AnchorPoint = Vector2.new(0, 1)
  idLabelInstance.Position = UDim2.new(0, 0, 1, 0)
  idLabelInstance.Text = tostring(id)
  idLabelInstance.Parent = button

  local success, result = pcall(function()
    return game:GetService("MarketplaceService"):GetProductInfo(id)
  end)
  if success then
    name.Text = result.Name
  else
    warn("Erro ao obter informações do item:", id, result)
    name.Text = "Erro ao obter nome"
  end

  button.Activated:Connect(function()
    setclipboard(tostring(id))
  end)
end

-- Função para salvar os IDs em um arquivo .txt no diretório do script
local function salvarIDsEmTXT(ids)
  local scriptPath = debug.getinfo(1, "S").source:sub(2) -- Obtém o caminho do script atual
  local scriptDirectory = scriptPath:match("(.*[/\\])") or "" -- Extrai o diretório do script
  local filePath = scriptDirectory .. "animationIDs.txt" -- Define o caminho completo do arquivo

  local file, errorMessage = io.open(filePath, "w")
  if file then
    for _, id in pairs(ids) do
      file:write(id .. "\n")
    end
    file:close()
    print("IDs salvos com sucesso em:", filePath)
  else
    warn("Erro ao salvar IDs:", errorMessage)
  end
end

-- Loop principal com verificação de erros e controle de fluxo
local animationTable = {}
local lastUpdate = 0
local updateInterval = 0.5 -- Intervalo de atualização em segundos

game:GetService("RunService").Heartbeat:Connect(function()
  local currentTime = tick()
  if currentTime - lastUpdate >= updateInterval then
    local localPlayer = game:GetService("Players").LocalPlayer
    if localPlayer and localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") then
      local humanoid = localPlayer.Character:FindFirstChild("Humanoid")
      local playingTracks = humanoid:GetPlayingAnimationTracks()

      for _, track in pairs(playingTracks) do
        local animationId = track.Animation.AnimationId
        if not table.find(animationTable, animationId) then
          table.insert(animationTable, animationId)
          pcall(function()
            criarBotao(animationId)
          end)
        end
      end

      -- Salva os IDs no arquivo .txt
      salvarIDsEmTXT(animationTable)
    end
    lastUpdate = currentTime
  end
end)

-- Função para tornar o frame arrastável (reutilizando a função original)
local UIS = game:GetService("UserInputService")
local function dragify(Frame)
  local frameToMove = Frame
  local dragToggle, dragInput, dragStart, startPos
  local dragSpeed = 0
  local function updateInput(input)
    local Delta = input.Position - dragStart
    frameToMove.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + Delta.X, startPos.Y.Scale, startPos.Y.Offset + Delta.Y)
  end
  Frame.InputBegan:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and UIS:GetFocusedTextBox() == nil then
      dragToggle = true
      dragStart = input.Position
      startPos = frameToMove.Position
      input.Changed:Connect(function()
        if input.UserInputState == Enum.UserInputState.End then
          dragToggle = false
        end
      end)	
    end
  end)
  Frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
      dragInput = input
    end
  end)
  UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragToggle then
      updateInput(input)
    end
  end)
end

-- Torna o frame arrastável
dragify(drag)