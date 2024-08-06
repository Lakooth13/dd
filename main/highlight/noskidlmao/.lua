local player = game.Players.LocalPlayer
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Create the main frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 300) -- Adjust size as needed
frame.Position = UDim2.new(0.5, -200, 0.5, -150) -- Centered position
frame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
frame.Parent = screenGui

-- Add UI corner for rounded edges
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 12) -- Adjust corner radius as needed
uiCorner.Parent = frame

-- Create the main TextLabel for the Highlight ESP
local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.new(0, 120, 0, 30) -- Adjusted size to fit within the frame
textLabel.Position = UDim2.new(0, 35, 0, 20) -- Moved slightly more to the left
textLabel.BackgroundTransparency = 1
textLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- White text color
textLabel.TextStrokeTransparency = 0.8 -- Adds a slight outline to the text for better visibility
textLabel.TextSize = 18 -- Adjust text size as needed
textLabel.Text = "Highlight ESP"
textLabel.Parent = frame

-- Create the toggle button to the right of the "Highlight ESP" title
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 40, 0, 40) -- Smaller size for the button
toggleButton.Position = UDim2.new(0, 200, 0, 15) -- Moved further to the left
toggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Default color (red)
toggleButton.Text = ""
toggleButton.Parent = frame

-- Add UI corner for rounded edges to the button
local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 6) -- Adjust corner radius as needed
buttonCorner.Parent = toggleButton

-- Tween service for smooth color transitions
local tweenService = game:GetService("TweenService")

-- Create tween info
local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

-- Create color tweens
local hoverTween = tweenService:Create(toggleButton, tweenInfo, {BackgroundColor3 = Color3.fromRGB(200, 0, 0)}) -- Darker red on hover
local clickTweenOn = tweenService:Create(toggleButton, tweenInfo, {BackgroundColor3 = Color3.fromRGB(0, 255, 0)}) -- Green when clicked
local clickTweenOff = tweenService:Create(toggleButton, tweenInfo, {BackgroundColor3 = Color3.fromRGB(255, 0, 0)}) -- Red when not clicked

-- Track toggle state
local isToggled = false
local highlightEffects = {}

-- Function to create Highlight effects
local function createHighlight()
    local players = game.Players:GetPlayers()
    for i, v in pairs(players) do
        if v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local esp = Instance.new("Highlight")
            esp.Name = v.Name
            esp.FillTransparency = 0.5
            esp.FillColor = Color3.new(0, 0, 0) -- Black fill color
            esp.OutlineColor = Color3.new(1, 1, 1) -- White outline color
            esp.OutlineTransparency = 0
            esp.Parent = v.Character
            
            highlightEffects[v] = esp
            
            -- Debug message
            print("Highlight created for:", v.Name)
        else
            -- Debug message
            print("Character or HumanoidRootPart not found for:", v.Name)
        end
    end
end

-- Function to remove Highlight effects
local function removeHighlight()
    for _, highlight in pairs(highlightEffects) do
        highlight:Destroy()
    end
    highlightEffects = {}
    -- Debug message
    print("Highlights removed")
end

-- Function to handle the click effect
local function onClick()
    isToggled = not isToggled
    if isToggled then
        clickTweenOn:Play()
        createHighlight()
    else
        clickTweenOff:Play()
        removeHighlight()
    end
    -- Debug message
    print("Toggle state:", isToggled)
end

-- Function to handle the hover effect
local function onHover()
    if not isToggled then -- Only change color on hover if not toggled
        hoverTween:Play()
    end
end

-- Function to handle the end of hover effect
local function onUnhover()
    if isToggled then
        clickTweenOn:Play()
    else
        clickTweenOff:Play()
    end
end

-- Connect events for button interactions
toggleButton.MouseEnter:Connect(onHover)
toggleButton.MouseLeave:Connect(onUnhover)
toggleButton.MouseButton1Click:Connect(onClick)

-- Create a description TextLabel below the main title
local descriptionLabel = Instance.new("TextLabel")
descriptionLabel.Size = UDim2.new(0, 300, 0, 40) -- Adjust size for the smaller text
descriptionLabel.Position = UDim2.new(0, 15, 0, 60) -- Positioned directly below the main text label
descriptionLabel.BackgroundTransparency = 1
descriptionLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- White text color
descriptionLabel.TextStrokeTransparency = 0.8 -- Adds a slight outline to the text for better visibility
descriptionLabel.TextSize = 12 -- Much smaller text size
descriptionLabel.Text = "Highlights Every Player Using Instance.new('Highlight')"
descriptionLabel.TextTransparency = 0.5 -- 50% opacity
descriptionLabel.TextWrapped = true -- Allows text to wrap within the label
descriptionLabel.TextXAlignment = Enum.TextXAlignment.Left -- Align text to the left
descriptionLabel.TextYAlignment = Enum.TextYAlignment.Top -- Align text to the top
descriptionLabel.Parent = frame

-- Dragging variables
local dragToggle = false
local dragStart = nil
local startPos = nil

local function updateInput(input)
    local delta = input.Position - dragStart
    frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X * 0.5, startPos.Y.Scale, startPos.Y.Offset + delta.Y * 0.5) -- Adjust smoothing factor here
end

local function onInputBegan(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and frame.AbsolutePosition.X <= input.Position.X and input.Position.X <= frame.AbsolutePosition.X + frame.AbsoluteSize.X and frame.AbsolutePosition.Y <= input.Position.Y and input.Position.Y <= frame.AbsolutePosition.Y + frame.AbsoluteSize.Y then
        dragToggle = true
        dragStart = input.Position
        startPos = frame.Position
    end
end

local function onInputChanged(input)
    if dragToggle and input.UserInputType == Enum.UserInputType.MouseMovement then
        updateInput(input)
    end
end

local function onInputEnded(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragToggle = false
    end
end

-- Create a function to handle hiding/showing the GUI with Right Shift
local function onKeyPress(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        frame.Visible = not frame.Visible
    end
end

-- Connect input events to global services
game:GetService("UserInputService").InputBegan:Connect(onInputBegan)
game:GetService("UserInputService").InputChanged:Connect(onInputChanged)
game:GetService("UserInputService").InputEnded:Connect(onInputEnded)
game:GetService("UserInputService").InputBegan:Connect(onKeyPress)

-- Initial Highlight update
if isToggled then
    createHighlight()
end


Below the Highlight Esp Toggle, Description, and Title, We going to make another below it. called "Tracers" The Title will be "Tracer ESP" Description will be "Draws tracers from the bottom of the users screen" and the toggle will draw the tracers to everyone but the localplayer

local player = game.Players.LocalPlayer
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Create the main frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 300) -- Adjust size as needed
frame.Position = UDim2.new(0.5, -200, 0.5, -150) -- Centered position
frame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
frame.Parent = screenGui

-- Add UI corner for rounded edges
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 12) -- Adjust corner radius as needed
uiCorner.Parent = frame

-- Create the main TextLabel for the Highlight ESP
local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.new(0, 120, 0, 30) -- Adjusted size to fit within the frame
textLabel.Position = UDim2.new(0, 35, 0, 20) -- Moved slightly more to the left
textLabel.BackgroundTransparency = 1
textLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- White text color
textLabel.TextStrokeTransparency = 0.8 -- Adds a slight outline to the text for better visibility
textLabel.TextSize = 18 -- Adjust text size as needed
textLabel.Text = "Highlight ESP"
textLabel.Parent = frame

-- Create the toggle button to the right of the "Highlight ESP" title
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 40, 0, 40) -- Smaller size for the button
toggleButton.Position = UDim2.new(0, 200, 0, 15) -- Moved further to the left
toggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Default color (red)
toggleButton.Text = ""
toggleButton.Parent = frame

-- Add UI corner for rounded edges to the button
local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 6) -- Adjust corner radius as needed
buttonCorner.Parent = toggleButton

-- Tween service for smooth color transitions
local tweenService = game:GetService("TweenService")

-- Create tween info
local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

-- Create color tweens
local hoverTween = tweenService:Create(toggleButton, tweenInfo, {BackgroundColor3 = Color3.fromRGB(200, 0, 0)}) -- Darker red on hover
local clickTweenOn = tweenService:Create(toggleButton, tweenInfo, {BackgroundColor3 = Color3.fromRGB(0, 255, 0)}) -- Green when clicked
local clickTweenOff = tweenService:Create(toggleButton, tweenInfo, {BackgroundColor3 = Color3.fromRGB(255, 0, 0)}) -- Red when not clicked

-- Track toggle state
local isToggled = false
local highlightEffects = {}

-- Function to create Highlight effects
local function createHighlight()
    local players = game.Players:GetPlayers()
    for i, v in pairs(players) do
        if v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local esp = Instance.new("Highlight")
            esp.Name = v.Name
            esp.FillTransparency = 0.5
            esp.FillColor = Color3.new(0, 0, 0) -- Black fill color
            esp.OutlineColor = Color3.new(1, 1, 1) -- White outline color
            esp.OutlineTransparency = 0
            esp.Parent = v.Character
            
            highlightEffects[v] = esp
            
            -- Debug message
            print("Highlight created for:", v.Name)
        else
            -- Debug message
            print("Character or HumanoidRootPart not found for:", v.Name)
        end
    end
end

-- Function to remove Highlight effects
local function removeHighlight()
    for _, highlight in pairs(highlightEffects) do
        highlight:Destroy()
    end
    highlightEffects = {}
    -- Debug message
    print("Highlights removed")
end

-- Function to handle the click effect
local function onClick()
    isToggled = not isToggled
    if isToggled then
        clickTweenOn:Play()
        createHighlight()
    else
        clickTweenOff:Play()
        removeHighlight()
    end
    -- Debug message
    print("Toggle state:", isToggled)
end

-- Function to handle the hover effect
local function onHover()
    if not isToggled then -- Only change color on hover if not toggled
        hoverTween:Play()
    end
end

-- Function to handle the end of hover effect
local function onUnhover()
    if isToggled then
        clickTweenOn:Play()
    else
        clickTweenOff:Play()
    end
end

-- Connect events for button interactions
toggleButton.MouseEnter:Connect(onHover)
toggleButton.MouseLeave:Connect(onUnhover)
toggleButton.MouseButton1Click:Connect(onClick)

-- Create a description TextLabel below the main title
local descriptionLabel = Instance.new("TextLabel")
descriptionLabel.Size = UDim2.new(0, 300, 0, 40) -- Adjust size for the smaller text
descriptionLabel.Position = UDim2.new(0, 15, 0, 60) -- Positioned directly below the main text label
descriptionLabel.BackgroundTransparency = 1
descriptionLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- White text color
descriptionLabel.TextStrokeTransparency = 0.8 -- Adds a slight outline to the text for better visibility
descriptionLabel.TextSize = 12 -- Much smaller text size
descriptionLabel.Text = "Highlights Every Player Using Instance.new('Highlight')"
descriptionLabel.TextTransparency = 0.5 -- 50% opacity
descriptionLabel.TextWrapped = true -- Allows text to wrap within the label
descriptionLabel.TextXAlignment = Enum.TextXAlignment.Left -- Align text to the left
descriptionLabel.TextYAlignment = Enum.TextYAlignment.Top -- Align text to the top
descriptionLabel.Parent = frame

-- Dragging variables
local dragToggle = false
local dragStart = nil
local startPos = nil

local function updateInput(input)
    local delta = input.Position - dragStart
    frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X * 0.5, startPos.Y.Scale, startPos.Y.Offset + delta.Y * 0.5) -- Adjust smoothing factor here
end

local function onInputBegan(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and frame.AbsolutePosition.X <= input.Position.X and input.Position.X <= frame.AbsolutePosition.X + frame.AbsoluteSize.X and frame.AbsolutePosition.Y <= input.Position.Y and input.Position.Y <= frame.AbsolutePosition.Y + frame.AbsoluteSize.Y then
        dragToggle = true
        dragStart = input.Position
        startPos = frame.Position
    end
end

local function onInputChanged(input)
    if dragToggle and input.UserInputType == Enum.UserInputType.MouseMovement then
        updateInput(input)
    end
end

local function onInputEnded(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragToggle = false
    end
end

-- Create a function to handle hiding/showing the GUI with Right Shift
local function onKeyPress(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        frame.Visible = not frame.Visible
    end
end

-- Connect input events to global services
game:GetService("UserInputService").InputBegan:Connect(onInputBegan)
game:GetService("UserInputService").InputChanged:Connect(onInputChanged)
game:GetService("UserInputService").InputEnded:Connect(onInputEnded)
game:GetService("UserInputService").InputBegan:Connect(onKeyPress)

-- Initial Highlight update
if isToggled then
    createHighlight()
end
