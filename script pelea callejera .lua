--// Servicios
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")
local root = char:WaitForChild("HumanoidRootPart")

local atmFolder = workspace:WaitForChild("ATMs")
local moneyFolder = workspace:WaitForChild("Spawned"):WaitForChild("Money")

--// Variables
local activoFarm = false
local activoRecolect = false
local toolName = "Fists"

local coloresRGB = {
	Color3.fromRGB(255, 80, 80),
	Color3.fromRGB(80, 255, 80),
	Color3.fromRGB(80, 170, 255),
	Color3.fromRGB(255, 255, 80),
	Color3.fromRGB(255, 80, 255),
	Color3.fromRGB(255, 140, 0)
}
local rgbIndex = 1

--// GUI
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "AutoFarmAndRecolector"
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 240, 0, 130)
frame.Position = UDim2.new(0.5, -120, 0.15, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

-- Marca de agua arriba
local marcaAgua = Instance.new("TextLabel", frame)
marcaAgua.Size = UDim2.new(1, 0, 0, 15)
marcaAgua.Position = UDim2.new(0, 0, 0, -15)
marcaAgua.BackgroundTransparency = 1
marcaAgua.Text = " by Adriansitoghz"
marcaAgua.TextColor3 = coloresRGB[1]
marcaAgua.TextScaled = true
marcaAgua.Font = Enum.Font.GothamSemibold

-- Título
local titulo = Instance.new("TextLabel", frame)
titulo.Size = UDim2.new(1, 0, 0, 25)
titulo.Position = UDim2.new(0, 0, 0, 0)
titulo.BackgroundTransparency = 1
titulo.Text = " AutoFarm & Recolector"
titulo.TextColor3 = Color3.fromRGB(255, 255, 255)
titulo.TextScaled = true
titulo.Font = Enum.Font.GothamBlack

-- Botón AutoFarm
local botonFarm = Instance.new("TextButton", frame)
botonFarm.Size = UDim2.new(0.9, 0, 0, 30)
botonFarm.Position = UDim2.new(0.05, 0, 0, 30)
botonFarm.BackgroundColor3 = Color3.fromRGB(40, 170, 90)
botonFarm.Text = " Activar AutoFarm"
botonFarm.TextColor3 = Color3.new(1, 1, 1)
botonFarm.TextScaled = true
botonFarm.Font = Enum.Font.GothamBold

-- Botón AutoRecolector
local botonRecolect = Instance.new("TextButton", frame)
botonRecolect.Size = UDim2.new(0.9, 0, 0, 30)
botonRecolect.Position = UDim2.new(0.05, 0, 0, 65)
botonRecolect.BackgroundColor3 = Color3.fromRGB(40, 170, 90)
botonRecolect.Text = " Activar AutoRecolector"
botonRecolect.TextColor3 = Color3.new(1, 1, 1)
botonRecolect.TextScaled = true
botonRecolect.Font = Enum.Font.GothamBold

-- Estado general
local estado = Instance.new("TextLabel", frame)
estado.Size = UDim2.new(0.9, 0, 0, 20)
estado.Position = UDim2.new(0.05, 0, 0, 100)
estado.BackgroundTransparency = 1
estado.Text = "Estado: Inactivo"
estado.TextColor3 = Color3.fromRGB(200, 200, 200)
estado.TextScaled = true
estado.Font = Enum.Font.Gotham

-- Efecto RGB suave
task.spawn(function()
	while true do
		marcaAgua.TextColor3 = coloresRGB[rgbIndex]
		estado.TextColor3 = coloresRGB[rgbIndex]
		rgbIndex = rgbIndex % #coloresRGB + 1
		task.wait(0.4)
	end
end)

-- Funciones AutoFarm (golpear + recoger)

local cooldownATM = {}

local function equiparTool()
	local backpack = player:WaitForChild("Backpack")
	local tool = backpack:FindFirstChild(toolName)
	if tool then
		humanoid:EquipTool(tool)
	end
end

local function golpearATM(atm)
	if not atm:IsA("Model") then return end
	if cooldownATM[atm] and tick() - cooldownATM[atm] < 30 then return end

	local parte = atm:FindFirstChildWhichIsA("BasePart", true)
	if not parte then return end

	root.CFrame = parte.CFrame + Vector3.new(0, 2, 0)
	task.wait(0.2)

	equiparTool()
	local tool = char:FindFirstChild(toolName)
	if not tool then return end

	local duracion = 6
	local inicio = tick()

	while tick() - inicio < duracion and activoFarm do
		local restante = math.ceil(duracion - (tick() - inicio))
		estado.Text = " Golpeando ATM (" .. restante .. "s)"
		tool:Activate()
		task.wait(0.5)
	end

	cooldownATM[atm] = tick()
end

local function recogerDineroFarm()
	local duracion = 5
	local inicio = tick()

	while tick() - inicio < duracion and activoFarm do
		local restante = math.ceil(duracion - (tick() - inicio))
		estado.Text = " Recolectando dinero (" .. restante .. "s)"

		for _, dinero in pairs(moneyFolder:GetChildren()) do
			if dinero:IsA("BasePart") then
				root.CFrame = dinero.CFrame + Vector3.new(0, 2, 0)
				task.wait(0.1)
				local prompt = dinero:FindFirstChildWhichIsA("ProximityPrompt", true)
				if prompt then
					pcall(function()
						fireproximityprompt(prompt)
					end)
				end
			end
		end
		task.wait(0.3)
	end
end

local function comenzarFarm()
	while activoFarm do
		for _, atm in ipairs(atmFolder:GetChildren()) do
			if not activoFarm then return end
			golpearATM(atm)
			task.wait(1)
			recogerDineroFarm()
			task.wait(1)
		end
		task.wait(1)
	end
end

-- Funciones AutoRecolector (dinero del suelo)

local function recogerDinero(dinero)
	local prompt
	for _, d in ipairs(dinero:GetDescendants()) do
		if d:IsA("ProximityPrompt") then
			prompt = d
			break
		end
	end
	if not prompt then return false end

	local partePrompt = prompt.Parent
	while partePrompt and not partePrompt:IsA("BasePart") do
		partePrompt = partePrompt.Parent
	end
	if not partePrompt then return false end

	char:MoveTo(partePrompt.Position)

	repeat task.wait(0.1)
	until not activoRecolect or not prompt.Parent or (root.Position - partePrompt.Position).Magnitude <= prompt.MaxActivationDistance + 1

	if activoRecolect and prompt.Parent then
		pcall(function()
			fireproximityprompt(prompt)
		end)
		task.wait(0.3)
		return true
	end

	return false
end

local function iniciarRecolector()
	while activoRecolect do
		local encontrados = false

		for _, money in pairs(moneyFolder:GetChildren()) do
			if not activoRecolect then break end
			if money:IsA("Model") or money:IsA("BasePart") then
				local recogido = recogerDinero(money)
				if recogido then
					encontrados = true
				end
			end
		end

		if not encontrados then
			estado.Text = " No hay dinero visible"
			task.wait(1)
		else
			estado.Text = " Recolectando dinero del suelo..."
			task.wait(0.1)
		end
	end
end

-- Eventos botones

botonFarm.MouseButton1Click:Connect(function()
	activoFarm = not activoFarm
	if activoFarm then
		botonFarm.Text = " Detener AutoFarm"
		botonFarm.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
		estado.Text = " Iniciando AutoFarm..."
		task.spawn(comenzarFarm)
	else
		botonFarm.Text = " Activar AutoFarm"
		botonFarm.BackgroundColor3 = Color3.fromRGB(40, 170, 90)
		estado.Text = "Estado: Inactivo"
	end
end)

botonRecolect.MouseButton1Click:Connect(function()
	activoRecolect = not activoRecolect
	if activoRecolect then
		botonRecolect.Text = " Detener AutoRecolector"
		botonRecolect.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
		estado.Text = " Iniciando AutoRecolector..."
		task.spawn(iniciarRecolector)
	else
		botonRecolect.Text = " Activar AutoRecolector"
		botonRecolect.BackgroundColor3 = Color3.fromRGB(40, 170, 90)
		estado.Text = "Estado: Inactivo"
	end
end)