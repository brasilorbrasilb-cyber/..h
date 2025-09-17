local Players = game:GetService("Players")
local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")
local gui = Instance.new("ScreenGui", pg)
gui.ResetOnSpawn = false

local button = Instance.new("TextButton", gui)
button.Size = UDim2.new(0,60,0,60)
button.Position = UDim2.new(0.5, -30, 0.8, 0)
button.BackgroundColor3 = Color3.fromRGB(20,20,20)
button.BackgroundTransparency = 0.15
button.Text = "OFF"
button.TextColor3 = Color3.new(1,1,1)
button.Font = Enum.Font.GothamBold
button.TextSize = 14
button.Active = true
button.Draggable = true
local uic = Instance.new("UICorner", button)
uic.CornerRadius = UDim.new(1,0)
local stroke = Instance.new("UIStroke", button)
stroke.Thickness = 3
task.spawn(function()
	local t = 0
	while button.Parent do
		t = (t + 0.01) % 1
		stroke.Color = Color3.fromHSV(t,1,1)
		task.wait(0.03)
	end
end)

local on = false
local connections = {}
local hipClones = {}
local shopHighlights = {}
local notifY = 0

local colors = {Color3.fromRGB(255,0,0),Color3.fromRGB(255,127,0),Color3.fromRGB(255,255,0),
	Color3.fromRGB(0,255,0),Color3.fromRGB(0,255,255),Color3.fromRGB(0,0,255),Color3.fromRGB(255,0,255)}

local function notify(msg)
	local nf = Instance.new("Frame", gui)
	nf.Size = UDim2.new(0,250,0,80)
	nf.Position = UDim2.new(1,-270,1,-120 - notifY)
	nf.BackgroundColor3 = Color3.fromRGB(0,0,0)
	nf.BackgroundTransparency = 0.3
	Instance.new("UICorner", nf).CornerRadius = UDim.new(0,12)
	local label = Instance.new("TextLabel", nf)
	label.Size = UDim2.new(1,-10,1,-10)
	label.Position = UDim2.new(0,5,0,5)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1,1,1)
	label.TextSize = 18
	label.Font = Enum.Font.GothamBold
	label.Text = msg
	label.TextWrapped = true
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.TextYAlignment = Enum.TextYAlignment.Center
	local sound = Instance.new("Sound", nf)
	sound.SoundId = "rbxassetid://3398620867"
	sound.Volume = 1
	sound:Play()
	notifY = notifY + 85
	game:GetService("Debris"):AddItem(nf,2)
	task.delay(2,function() notifY = notifY - 85 end)
end

local function stopAnimations(char)
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if humanoid then
		for _, anim in ipairs(humanoid:GetPlayingAnimationTracks()) do anim:Stop() end
	end
	local animate = char:FindFirstChild("Animate")
	if animate then animate:Destroy() end
end

local function hideFace(char)
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("Decal") and part.Name == "face" then part:Destroy() end
	end
end

local function hideToTorso(char)
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			if part.Name=="Torso" or part.Name=="UpperTorso" then part.Transparency=0
			else part.Transparency=1 end
		elseif part:IsA("Motor6D") then
			if part.Name=="Left Hip" or part.Name=="Right Hip" then
				local clone=part:Clone()
				table.insert(hipClones,clone)
				part:Destroy()
			end
		end
	end
	hideFace(char)
end

local function restoreCharacter(char)
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Transparency=0
			part.Anchored=false
		end
	end
	for _, hip in ipairs(hipClones) do hip.Parent=char end
	table.clear(hipClones)
end

local function protect(char)
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end
	table.insert(connections,humanoid.HealthChanged:Connect(function()
		if on and humanoid.Health < humanoid.MaxHealth then humanoid.Health = humanoid.MaxHealth end
	end))
end

local function unprotect()
	for _, c in ipairs(connections) do
		if c and c.Disconnect then pcall(function() c:Disconnect() end) end
	end
	table.clear(connections)
end

local function highlightShops(enable)
	local shops = {}
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") and obj.Name:lower():find("machine") then table.insert(shops,obj) end
	end
	if enable then
		for _, part in ipairs(shops) do
			local h = Instance.new("Highlight")
			h.Adornee = part
			h.FillColor = Color3.fromRGB(50,50,50)
			h.FillTransparency = 0.5
			h.OutlineTransparency = 1
			h.Parent = part
			table.insert(shopHighlights, h)
		end
	else
		for _, h in ipairs(shopHighlights) do pcall(function() h:Destroy() end) end
		table.clear(shopHighlights)
	end
end

local function showLoadingAndActivate(char)
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local cover = Instance.new("Frame", gui)
	cover.Size = UDim2.new(1,0,1,0)
	cover.BackgroundColor3 = Color3.new(0,0,0)
	local title = Instance.new("TextLabel", cover)
	title.AnchorPoint = Vector2.new(0.5,0.5)
	title.Position = UDim2.new(0.5,0,0.4,0)
	title.Size = UDim2.new(0,400,0,60)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBold
	title.TextScaled = false
	title.TextSize = 28
	title.Text = "@1860.1100"
	local pct = Instance.new("TextLabel", cover)
	pct.AnchorPoint = Vector2.new(0.5,0.5)
	pct.Position = UDim2.new(0.5,0,0.55,0)
	pct.Size = UDim2.new(0,200,0,40)
	pct.BackgroundTransparency = 1
	pct.Font = Enum.Font.GothamBold
	pct.TextScaled = false
	pct.TextSize = 20
	pct.Text = "0%"
	pct.TextColor3 = Color3.new(1,1,1)
	local running = true
	task.spawn(function()
		local i = 1
		while cover.Parent and running do
			title.TextColor3 = colors[i]
			i = i % #colors + 1
			task.wait(0.1)
		end
	end)
	hrp.Anchored = true
	hrp.CFrame = hrp.CFrame + Vector3.new(0,10000,0)
	for i=0,100 do
		pct.Text = "Loading "..i.."%"
		task.wait(0.01)
	end
	hrp.CFrame = hrp.CFrame - Vector3.new(0,10000,0)
	hrp.Anchored = false
	running = false
	cover:Destroy()
	on = true
	button.Text = "ON"
	hideToTorso(char)
	stopAnimations(char)
	protect(char)
	highlightShops(true)
	notify("Anti-Hit Activated")
	if math.random() < 0.5 then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then hum.PlatformStand = true
			task.delay(2,function() hum.PlatformStand=false end)
		end
	end
end

button.MouseButton1Click:Connect(function()
	local char = player.Character or player.CharacterAdded:Wait()
	if not char then return end
	if not on then
		showLoadingAndActivate(char)
	else
		on = false
		button.Text = "OFF"
		unprotect()
		restoreCharacter(char)
		highlightShops(false)
		local humanoid = char:FindFirstChildOfClass("Humanoid")
		if humanoid then humanoid.Health=0 end
		notify("Anti-Hit Deactivated")
	end
end)

player.CharacterAdded:Connect(function(char)
	task.wait(1)
	if on then
		hideToTorso(char)
		stopAnimations(char)
		protect(char)
	end
end)
