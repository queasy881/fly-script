-- Vertex Hub - Vertical Redesign
-- Modern Vertical UI | Essential Features Only

-- ===========================================================================
-- SERVICES
-- ===========================================================================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

-- ===========================================================================
-- GLOBAL REFERENCES
-- ===========================================================================
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ===========================================================================
-- UTILITY FUNCTIONS
-- ===========================================================================
local function GetCharacter()
    return LocalPlayer.Character
end

local function GetRootPart()
    local Char = GetCharacter()
    return Char and Char:FindFirstChild("HumanoidRootPart")
end

local function GetHumanoid()
    local Char = GetCharacter()
    return Char and Char:FindFirstChildOfClass("Humanoid")
end

local function Tween(Object, Properties, Duration)
    local TweenInfo = TweenInfo.new(Duration or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local Tween = TweenService:Create(Object, TweenInfo, Properties)
    Tween:Play()
    return Tween
end

local function WorldToScreen(Position)
    local Vector, OnScreen = Camera:WorldToViewportPoint(Position)
    return Vector2.new(Vector.X, Vector.Y), OnScreen, Vector.Z
end

-- ===========================================================================
-- STATE MANAGEMENT
-- ===========================================================================
local State = {
    WalkSpeed = {
        Enabled = false,
        Value = 16
    },
    SlideBoost = {
        Enabled = false,
        Value = 50,
        Cooldown = 1
    },
    Fly = {
        Enabled = false,
        Speed = 50,
        Legit = false
    },
    Noclip = false,
    InfiniteJump = false,
    AimAssist = {
        Enabled = false,
        Smoothness = 0.1,
        FOV = 100
    },
    ESP = {
        Enabled = false,
        Boxes = true,
        Names = true,
        Health = true,
        Distance = true,
        MaxDistance = 1000,
        TeamCheck = false
    },
    SilentAim = {
        Enabled = false,
        HitChance = 100,
        FOV = 100,
        Prediction = false,
        PredictionAmount = 0.1
    }
}

-- ===========================================================================
-- ENTITY MANAGEMENT
-- ===========================================================================
local EntityCache = {
    Players = {},
    LastUpdate = 0
}

local function UpdateEntityCache()
    if tick() - EntityCache.LastUpdate < 0.5 then return end
    EntityCache.LastUpdate = tick()
    
    -- Clear old cache
    for Name, Data in pairs(EntityCache.Players) do
        if not Data.Player or not Data.Player.Parent then
            EntityCache.Players[Name] = nil
        end
    end
    
    -- Update player cache
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer then
            if not EntityCache.Players[Player.Name] then
                EntityCache.Players[Player.Name] = {
                    Player = Player,
                    Team = Player.Team
                }
            end
            
            local Data = EntityCache.Players[Player.Name]
            Data.Team = Player.Team
            
            if Player.Character and not Data.Character then
                Data.Character = Player.Character
                Data.Humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
                Data.RootPart = Player.Character:FindFirstChild("HumanoidRootPart")
                Data.Head = Player.Character:FindFirstChild("Head")
            end
        end
    end
end

-- ===========================================================================
-- FLY SYSTEM (Camera-Relative)
-- ===========================================================================
local FlySystem = {
    BodyGyro = nil,
    BodyVelocity = nil,
    CurrentVelocity = Vector3.new(0, 0, 0)
}

function FlySystem:Enable()
    local Root = GetRootPart()
    if not Root then return end
    
    local Humanoid = GetHumanoid()
    if Humanoid then
        Humanoid.PlatformStand = true
    end
    
    self.BodyGyro = Instance.new("BodyGyro")
    self.BodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    self.BodyGyro.P = 10000
    self.BodyGyro.CFrame = Camera.CFrame
    self.BodyGyro.Parent = Root
    
    self.BodyVelocity = Instance.new("BodyVelocity")
    self.BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    self.BodyVelocity.Velocity = Vector3.new(0, 0, 0)
    self.BodyVelocity.Parent = Root
    
    self.CurrentVelocity = Vector3.new(0, 0, 0)
end

function FlySystem:Disable()
    local Humanoid = GetHumanoid()
    if Humanoid then
        Humanoid.PlatformStand = false
    end
    
    if self.BodyGyro then
        self.BodyGyro:Destroy()
        self.BodyGyro = nil
    end
    
    if self.BodyVelocity then
        self.BodyVelocity:Destroy()
        self.BodyVelocity = nil
    end
end

function FlySystem:Update()
    if not self.BodyGyro or not self.BodyVelocity then return end
    
    self.BodyGyro.CFrame = Camera.CFrame
    
    local Direction = Vector3.new(0, 0, 0)
    
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        Direction = Direction + Camera.CFrame.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        Direction = Direction - Camera.CFrame.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        Direction = Direction - Camera.CFrame.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        Direction = Direction + Camera.CFrame.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        Direction = Direction + Vector3.new(0, 1, 0)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        Direction = Direction - Vector3.new(0, 1, 0)
    end
    
    if Direction.Magnitude > 0 then
        Direction = Direction.Unit
    end
    
    local TargetVelocity = Direction * State.Fly.Speed
    
    if State.Fly.Legit then
        self.CurrentVelocity = self.CurrentVelocity:Lerp(TargetVelocity, 0.1)
        self.BodyVelocity.Velocity = self.CurrentVelocity
    else
        self.BodyVelocity.Velocity = TargetVelocity
    end
end

-- ===========================================================================
-- ESP SYSTEM (Improved Performance)
-- ===========================================================================
local ESP = {
    Drawings = {},
    TextCache = {},
    BoxCache = {}
}

function ESP:Initialize()
    -- Check if Drawing API exists
    local Success = pcall(function()
        local Test = Drawing.new("Text")
        Test:Remove()
    end)
    
    if not Success then
        warn("Drawing API not available - ESP disabled")
        return false
    end
    
    return true
end

function ESP:CreateDrawing(Type, Properties)
    local Drawing = Drawing.new(Type)
    if Properties then
        for Property, Value in pairs(Properties) do
            Drawing[Property] = Value
        end
    end
    return Drawing
end

function ESP:GetTextDrawing(Name)
    if not self.TextCache[Name] then
        self.TextCache[Name] = self:CreateDrawing("Text", {
            Size = 14,
            Outline = true,
            Center = true,
            Visible = false
        })
    end
    return self.TextCache[Name]
end

function ESP:GetBoxDrawing(Name)
    if not self.BoxCache[Name] then
        self.BoxCache[Name] = self:CreateDrawing("Square", {
            Thickness = 1,
            Filled = false,
            Visible = false
        })
    end
    return self.BoxCache[Name]
end

function ESP:Update()
    if not State.ESP.Enabled then
        for _, Drawing in pairs(self.TextCache) do
            Drawing.Visible = false
        end
        for _, Drawing in pairs(self.BoxCache) do
            Drawing.Visible = false
        end
        return
    end
    
    local LocalTeam = LocalPlayer.Team
    local LocalRoot = GetRootPart()
    
    for PlayerName, Data in pairs(EntityCache.Players) do
        if Data.RootPart and Data.Humanoid and Data.Humanoid.Health > 0 then
            if State.ESP.TeamCheck and Data.Team and LocalTeam and Data.Team == LocalTeam then
                goto Continue
            end
            
            local Distance = LocalRoot and (LocalRoot.Position - Data.RootPart.Position).Magnitude or 0
            if Distance > State.ESP.MaxDistance then
                goto Continue
            end
            
            local ScreenPosition, OnScreen, Depth = WorldToScreen(Data.RootPart.Position)
            
            if OnScreen then
                -- Calculate box size based on distance
                local Scale = 100 / Depth
                local BoxWidth = 80 * Scale
                local BoxHeight = 120 * Scale
                
                -- Box ESP
                if State.ESP.Boxes then
                    local Box = self:GetBoxDrawing(PlayerName .. "_box")
                    Box.Size = Vector2.new(BoxWidth, BoxHeight)
                    Box.Position = ScreenPosition - Vector2.new(BoxWidth / 2, BoxHeight / 2)
                    Box.Color = Color3.fromRGB(255, 50, 50)
                    Box.Visible = true
                end
                
                -- Name ESP
                if State.ESP.Names then
                    local NameText = self:GetTextDrawing(PlayerName .. "_name")
                    NameText.Text = PlayerName
                    NameText.Position = ScreenPosition - Vector2.new(0, BoxHeight / 2 + 15)
                    NameText.Color = Color3.fromRGB(255, 255, 255)
                    NameText.Visible = true
                end
                
                -- Health ESP
                if State.ESP.Health then
                    local HealthPercent = Data.Humanoid.Health / Data.Humanoid.MaxHealth
                    local HealthText = self:GetTextDrawing(PlayerName .. "_health")
                    HealthText.Text = math.floor(Data.Humanoid.Health) .. " HP"
                    HealthText.Position = ScreenPosition - Vector2.new(0, BoxHeight / 2 + 30)
                    HealthText.Color = Color3.fromRGB(
                        255 - 255 * HealthPercent,
                        255 * HealthPercent,
                        0
                    )
                    HealthText.Visible = true
                end
                
                -- Distance ESP
                if State.ESP.Distance then
                    local DistanceText = self:GetTextDrawing(PlayerName .. "_distance")
                    DistanceText.Text = math.floor(Distance) .. " studs"
                    DistanceText.Position = ScreenPosition + Vector2.new(0, BoxHeight / 2 + 10)
                    DistanceText.Color = Color3.fromRGB(200, 200, 200)
                    DistanceText.Visible = true
                end
            else
                -- Hide off-screen drawings
                local Drawings = {
                    PlayerName .. "_box",
                    PlayerName .. "_name",
                    PlayerName .. "_health",
                    PlayerName .. "_distance"
                }
                
                for _, Name in ipairs(Drawings) do
                    local Text = self.TextCache[Name]
                    if Text then Text.Visible = false end
                    
                    local Box = self.BoxCache[Name]
                    if Box then Box.Visible = false end
                end
            end
            
            ::Continue::
        else
            -- Hide drawings for invalid/dead players
            local Drawings = {
                PlayerName .. "_box",
                PlayerName .. "_name",
                PlayerName .. "_health",
                PlayerName .. "_distance"
            }
            
            for _, Name in ipairs(Drawings) do
                local Text = self.TextCache[Name]
                if Text then Text.Visible = false end
                
                local Box = self.BoxCache[Name]
                if Box then Box.Visible = false end
            end
        end
    end
end

-- ===========================================================================
-- SILENT AIM SYSTEM
-- ===========================================================================
local SilentAim = {
    Hooked = false,
    LastTarget = nil
}

function SilentAim:GetBestTarget()
    if not State.SilentAim.Enabled then return nil end
    
    local LocalRoot = GetRootPart()
    if not LocalRoot then return nil end
    
    local LocalTeam = LocalPlayer.Team
    local ScreenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local BestTarget = nil
    local BestAngle = math.huge
    
    for PlayerName, Data in pairs(EntityCache.Players) do
        if Data.RootPart and Data.Humanoid and Data.Humanoid.Health > 0 then
            if State.ESP.TeamCheck and Data.Team and LocalTeam and Data.Team == LocalTeam then
                continue
            end
            
            local ScreenPosition, OnScreen = WorldToScreen(Data.RootPart.Position)
            if OnScreen then
                local Angle = (ScreenPosition - ScreenCenter).Magnitude
                
                if Angle <= State.SilentAim.FOV and Angle < BestAngle then
                    BestTarget = Data
                    BestAngle = Angle
                end
            end
        end
    end
    
    return BestTarget
end

function SilentAim:EnableHooks()
    if self.Hooked then return end
    
    -- Check for required exploit functions
    local hookmetamethod
    local getnamecallmethod
    
    pcall(function()
        hookmetamethod = hookmetamethod or get_hidden_property(game, "__namecall")
    end)
    
    pcall(function()
        getnamecallmethod = getnamecallmethod or get_namecall_method
    end)
    
    if not hookmetamethod or not getnamecallmethod then
        warn("Silent Aim requires exploit functions")
        return
    end
    
    local OriginalNamecall
    OriginalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local Method = getnamecallmethod()
        local Args = {...}
        
        if State.SilentAim.Enabled and math.random(1, 100) <= State.SilentAim.HitChance then
            if Method == "FireServer" or Method == "InvokeServer" then
                local RemoteName = tostring(self):lower()
                
                -- Check for combat-related remotes
                if RemoteName:find("hit") or RemoteName:find("damage") or RemoteName:find("attack") then
                    local Target = self:GetBestTarget()
                    
                    if Target and Target.Head then
                        local TargetPosition = Target.Head.Position
                        
                        if State.SilentAim.Prediction and Target.RootPart then
                            TargetPosition = TargetPosition + (Target.RootPart.Velocity * State.SilentAim.PredictionAmount)
                        end
                        
                        -- Modify position arguments
                        for i, Arg in ipairs(Args) do
                            if typeof(Arg) == "Vector3" then
                                Args[i] = TargetPosition
                            elseif typeof(Arg) == "CFrame" then
                                Args[i] = CFrame.new(TargetPosition)
                            elseif typeof(Arg) == "table" then
                                if Arg.Position then
                                    Arg.Position = TargetPosition
                                elseif Arg.Origin then
                                    Arg.Origin = TargetPosition
                                end
                            end
                        end
                        
                        SilentAim.LastTarget = Target
                    end
                end
            elseif self == Workspace and (Method == "Raycast" or Method == "FindPartOnRay") then
                local Target = self:GetBestTarget()
                
                if Target and Target.Head and math.random(1, 100) <= State.SilentAim.HitChance then
                    local TargetPosition = Target.Head.Position
                    
                    if State.SilentAim.Prediction and Target.RootPart then
                        TargetPosition = TargetPosition + (Target.RootPart.Velocity * State.SilentAim.PredictionAmount)
                    end
                    
                    -- Modify ray arguments
                    if Args[1] and typeof(Args[1]) == "Ray" then
                        Args[1] = Ray.new(Args[1].Origin, (TargetPosition - Args[1].Origin).Unit * 1000)
                    elseif Args[1] and Args[2] then
                        Args[2] = (TargetPosition - Args[1]).Unit * 1000
                    end
                    
                    SilentAim.LastTarget = Target
                end
            end
        end
        
        return OriginalNamecall(self, unpack(Args))
    end)
    
    self.Hooked = true
end

-- ===========================================================================
-- AIM ASSIST
-- ===========================================================================
function UpdateAimAssist()
    if not State.AimAssist.Enabled or not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        return
    end
    
    local LocalRoot = GetRootPart()
    if not LocalRoot then return end
    
    local ScreenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local BestTarget = nil
    local BestAngle = math.huge
    local LocalTeam = LocalPlayer.Team
    
    for PlayerName, Data in pairs(EntityCache.Players) do
        if Data.RootPart and Data.Humanoid and Data.Humanoid.Health > 0 then
            if State.ESP.TeamCheck and Data.Team and LocalTeam and Data.Team == LocalTeam then
                continue
            end
            
            local ScreenPosition, OnScreen = WorldToScreen(Data.RootPart.Position)
            if OnScreen then
                local Angle = (ScreenPosition - ScreenCenter).Magnitude
                
                if Angle <= State.AimAssist.FOV and Angle < BestAngle then
                    BestTarget = Data
                    BestAngle = Angle
                end
            end
        end
    end
    
    if BestTarget and BestTarget.RootPart then
        local TargetPosition = BestTarget.RootPart.Position
        Camera.CFrame = Camera.CFrame:Lerp(
            CFrame.new(Camera.CFrame.Position, TargetPosition),
            State.AimAssist.Smoothness
        )
    end
end

-- ===========================================================================
-- MAIN UPDATE LOOP
-- ===========================================================================
RunService.RenderStepped:Connect(function(DeltaTime)
    -- Update entity cache periodically
    UpdateEntityCache()
    
    -- Update movement features
    if State.Fly.Enabled then
        FlySystem:Update()
    end
    
    -- Update ESP
    ESP:Update()
    
    -- Update Aim Assist
    UpdateAimAssist()
    
    -- Update WalkSpeed
    if State.WalkSpeed.Enabled then
        local Humanoid = GetHumanoid()
        if Humanoid then
            Humanoid.WalkSpeed = State.WalkSpeed.Value
        end
    end
    
    -- Apply noclip
    if State.Noclip then
        local Character = GetCharacter()
        if Character then
            for _, Part in pairs(Character:GetDescendants()) do
                if Part:IsA("BasePart") then
                    Part.CanCollide = false
                end
            end
        end
    end
end)

-- ===========================================================================
-- SLIDE BOOST SYSTEM
-- ===========================================================================
local LastSlideTime = 0

UserInputService.InputBegan:Connect(function(Input, Processed)
    if Processed then return end
    
    if Input.KeyCode == Enum.KeyCode.LeftControl and State.SlideBoost.Enabled then
        local Now = tick()
        if Now - LastSlideTime < State.SlideBoost.Cooldown then return end
        
        LastSlideTime = Now
        
        local Root = GetRootPart()
        if not Root then return end
        
        -- Apply velocity boost in look direction
        local Velocity = Instance.new("BodyVelocity")
        Velocity.Velocity = Camera.CFrame.LookVector * State.SlideBoost.Value
        Velocity.MaxForce = Vector3.new(10000, 0, 10000)
        Velocity.P = 10000
        Velocity.Parent = Root
        
        game:GetService("Debris"):AddItem(Velocity, 0.2)
    end
    
    -- Infinite Jump
    if Input.KeyCode == Enum.KeyCode.Space and State.InfiniteJump then
        local Humanoid = GetHumanoid()
        if Humanoid then
            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- ===========================================================================
-- VERTICAL UI CREATION
-- ===========================================================================
local VertexUI = {}
local ToggleStates = {}

-- Color Scheme
local Colors = {
    Background = Color3.fromRGB(20, 20, 30),
    Panel = Color3.fromRGB(25, 25, 40),
    Surface = Color3.fromRGB(30, 30, 50),
    Accent = Color3.fromRGB(100, 150, 255),
    Text = Color3.fromRGB(240, 240, 255),
    SubText = Color3.fromRGB(180, 180, 200),
    Border = Color3.fromRGB(50, 60, 80)
}

-- Create UI Elements
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VertexHub"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 1, -40)
MainFrame.Position = UDim2.new(0, 10, 0, 20)
MainFrame.BackgroundColor3 = Colors.Background
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = MainFrame

local Stroke = Instance.new("UIStroke")
Stroke.Color = Colors.Border
Stroke.Thickness = 1
Stroke.Parent = MainFrame

-- Header
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Colors.Panel
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 8)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "VERTEX HUB"
Title.TextColor3 = Colors.Accent
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Subtitle = Instance.new("TextLabel")
Subtitle.Name = "Subtitle"
Subtitle.Size = UDim2.new(1, -20, 0, 16)
Subtitle.Position = UDim2.new(0, 10, 1, -20)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Vertical Redesign"
Subtitle.TextColor3 = Colors.SubText
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextSize = 11
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = Header

-- Content Scrolling
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Name = "ScrollFrame"
ScrollFrame.Size = UDim2.new(1, 0, 1, -50)
ScrollFrame.Position = UDim2.new(0, 0, 0, 50)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.ScrollBarImageColor3 = Colors.Accent
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollFrame.Parent = MainFrame

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Padding = UDim.new(0, 8)
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Parent = ScrollFrame

local ContentPadding = Instance.new("UIPadding")
ContentPadding.PaddingLeft = UDim.new(0, 10)
ContentPadding.PaddingRight = UDim.new(0, 10)
ContentPadding.PaddingTop = UDim.new(0, 10)
ContentPadding.PaddingBottom = UDim.new(0, 10)
ContentPadding.Parent = ScrollFrame

-- UI Component Functions
function VertexUI:CreateSection(TitleText)
    local Section = Instance.new("Frame")
    Section.Name = "Section_" .. TitleText
    Section.Size = UDim2.new(1, 0, 0, 32)
    Section.BackgroundTransparency = 1
    Section.LayoutOrder = #ScrollFrame:GetChildren()
    Section.Parent = ScrollFrame
    
    local SectionTitle = Instance.new("TextLabel")
    SectionTitle.Name = "Title"
    SectionTitle.Size = UDim2.new(1, 0, 1, 0)
    SectionTitle.BackgroundTransparency = 1
    SectionTitle.Text = TitleText:upper()
    SectionTitle.TextColor3 = Colors.Accent
    SectionTitle.Font = Enum.Font.GothamBold
    SectionTitle.TextSize = 12
    SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    SectionTitle.Parent = Section
    
    local Divider = Instance.new("Frame")
    Divider.Name = "Divider"
    Divider.Size = UDim2.new(1, 0, 0, 1)
    Divider.Position = UDim2.new(0, 0, 1, -1)
    Divider.BackgroundColor3 = Colors.Border
    Divider.BorderSizePixel = 0
    Divider.Parent = Section
    
    return Section
end

function VertexUI:CreateToggle(Text, Callback, Default)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Name = "Toggle_" .. Text
    ToggleFrame.Size = UDim2.new(1, 0, 0, 36)
    ToggleFrame.BackgroundColor3 = Colors.Surface
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.LayoutOrder = #ScrollFrame:GetChildren()
    ToggleFrame.Parent = ScrollFrame
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 6)
    ToggleCorner.Parent = ToggleFrame
    
    local Label = Instance.new("TextLabel")
    Label.Name = "Label"
    Label.Size = UDim2.new(1, -50, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = Text
    Label.TextColor3 = Colors.Text
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "Button"
    ToggleButton.Size = UDim2.new(0, 40, 0, 20)
    ToggleButton.Position = UDim2.new(1, -50, 0.5, 0)
    ToggleButton.AnchorPoint = Vector2.new(0, 0.5)
    ToggleButton.BackgroundColor3 = Colors.Border
    ToggleButton.BorderSizePixel = 0
    ToggleButton.AutoButtonColor = false
    ToggleButton.Text = ""
    ToggleButton.Parent = ToggleFrame
    
    local ToggleInner = Instance.new("Frame")
    ToggleInner.Name = "Inner"
    ToggleInner.Size = UDim2.new(0, 16, 0, 16)
    ToggleInner.Position = UDim2.new(0, 2, 0.5, 0)
    ToggleInner.AnchorPoint = Vector2.new(0, 0.5)
    ToggleInner.BackgroundColor3 = Colors.SubText
    ToggleInner.BorderSizePixel = 0
    ToggleInner.Parent = ToggleButton
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(1, 0)
    ButtonCorner.Parent = ToggleButton
    
    local InnerCorner = Instance.new("UICorner")
    InnerCorner.CornerRadius = UDim.new(1, 0)
    InnerCorner.Parent = ToggleInner
    
    local State = Default or false
    ToggleStates[Text] = State
    
    local function UpdateVisual()
        if State then
            Tween(ToggleButton, {BackgroundColor3 = Colors.Accent})
            Tween(ToggleInner, {
                Position = UDim2.new(1, -18, 0.5, 0),
                BackgroundColor3 = Colors.Text
            })
            Tween(Label, {TextColor3 = Colors.Accent})
        else
            Tween(ToggleButton, {BackgroundColor3 = Colors.Border})
            Tween(ToggleInner, {
                Position = UDim2.new(0, 2, 0.5, 0),
                BackgroundColor3 = Colors.SubText
            })
            Tween(Label, {TextColor3 = Colors.Text})
        end
    end
    
    ToggleButton.MouseButton1Click:Connect(function()
        State = not State
        ToggleStates[Text] = State
        UpdateVisual()
        if Callback then
            Callback(State)
        end
    end)
    
    UpdateVisual()
    
    return {
        SetState = function(NewState)
            State = NewState
            ToggleStates[Text] = State
            UpdateVisual()
        end,
        GetState = function()
            return State
        end
    }
end

function VertexUI:CreateSlider(Text, Min, Max, Default, Callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Name = "Slider_" .. Text
    SliderFrame.Size = UDim2.new(1, 0, 0, 60)
    SliderFrame.BackgroundColor3 = Colors.Surface
    SliderFrame.BorderSizePixel = 0
    SliderFrame.LayoutOrder = #ScrollFrame:GetChildren()
    SliderFrame.Parent = ScrollFrame
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 6)
    SliderCorner.Parent = SliderFrame
    
    local Label = Instance.new("TextLabel")
    Label.Name = "Label"
    Label.Size = UDim2.new(1, -20, 0, 20)
    Label.Position = UDim2.new(0, 10, 0, 5)
    Label.BackgroundTransparency = 1
    Label.Text = Text
    Label.TextColor3 = Colors.Text
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = SliderFrame
    
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Name = "Value"
    ValueLabel.Size = UDim2.new(0, 60, 0, 20)
    ValueLabel.Position = UDim2.new(1, -70, 0, 5)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(Default)
    ValueLabel.TextColor3 = Colors.Accent
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextSize = 13
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = SliderFrame
    
    local Track = Instance.new("Frame")
    Track.Name = "Track"
    Track.Size = UDim2.new(1, -20, 0, 4)
    Track.Position = UDim2.new(0, 10, 1, -20)
    Track.BackgroundColor3 = Colors.Border
    Track.BorderSizePixel = 0
    Track.Parent = SliderFrame
    
    local TrackCorner = Instance.new("UICorner")
    TrackCorner.CornerRadius = UDim.new(1, 0)
    TrackCorner.Parent = Track
    
    local Fill = Instance.new("Frame")
    Fill.Name = "Fill"
    Fill.Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0)
    Fill.BackgroundColor3 = Colors.Accent
    Fill.BorderSizePixel = 0
    Fill.Parent = Track
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = Fill
    
    local Handle = Instance.new("Frame")
    Handle.Name = "Handle"
    Handle.Size = UDim2.new(0, 12, 0, 12)
    Handle.Position = UDim2.new((Default - Min) / (Max - Min), 0, 0.5, 0)
    Handle.AnchorPoint = Vector2.new(0.5, 0.5)
    Handle.BackgroundColor3 = Colors.Text
    Handle.BorderSizePixel = 0
    Handle.ZIndex = 2
    Handle.Parent = Track
    
    local HandleCorner = Instance.new("UICorner")
    HandleCorner.CornerRadius = UDim.new(1, 0)
    HandleCorner.Parent = Handle
    
    local Value = Default
    local Dragging = false
    
    local function UpdateVisual(Ratio)
        Value = math.floor(Min + (Max - Min) * Ratio)
        ValueLabel.Text = tostring(Value)
        
        Tween(Fill, {Size = UDim2.new(Ratio, 0, 1, 0)})
        Tween(Handle, {Position = UDim2.new(Ratio, 0, 0.5, 0)})
        
        if Callback then
            Callback(Value)
        end
    end
    
    Track.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            local RelativeX = (Input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X
            UpdateVisual(math.clamp(RelativeX, 0, 1))
        end
    end)
    
    Handle.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
        end
    end)
    
    UserInputService.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(Input)
        if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
            local RelativeX = (Input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X
            UpdateVisual(math.clamp(RelativeX, 0, 1))
        end
    end)
    
    return {
        SetValue = function(NewValue)
            local Ratio = (NewValue - Min) / (Max - Min)
            UpdateVisual(math.clamp(Ratio, 0, 1))
        end
    }
end

-- ===========================================================================
-- BUILD VERTICAL UI
-- ===========================================================================
-- Movement Section
VertexUI:CreateSection("Movement")

local WalkSpeedToggle = VertexUI:CreateToggle("WalkSpeed", function(Enabled)
    State.WalkSpeed.Enabled = Enabled
    if not Enabled then
        local Humanoid = GetHumanoid()
        if Humanoid then
            Humanoid.WalkSpeed = 16
        end
    end
end)

local WalkSpeedSlider = VertexUI:CreateSlider("Speed", 16, 100, 16, function(Value)
    State.WalkSpeed.Value = Value
    if State.WalkSpeed.Enabled then
        local Humanoid = GetHumanoid()
        if Humanoid then
            Humanoid.WalkSpeed = Value
        end
    end
end)

local SlideBoostToggle = VertexUI:CreateToggle("Slide Boost", function(Enabled)
    State.SlideBoost.Enabled = Enabled
end)

local SlideBoostSlider = VertexUI:CreateSlider("Boost Power", 20, 200, 50, function(Value)
    State.SlideBoost.Value = Value
end)

local FlyToggle = VertexUI:CreateToggle("Fly", function(Enabled)
    State.Fly.Enabled = Enabled
    if Enabled then
        FlySystem:Enable()
    else
        FlySystem:Disable()
    end
end)

local FlySpeedSlider = VertexUI:CreateSlider("Fly Speed", 10, 200, 50, function(Value)
    State.Fly.Speed = Value
end)

local FlyLegitToggle = VertexUI:CreateToggle("Fly Legit Mode", function(Enabled)
    State.Fly.Legit = Enabled
end)

local NoclipToggle = VertexUI:CreateToggle("Noclip", function(Enabled)
    State.Noclip = Enabled
end)

local InfiniteJumpToggle = VertexUI:CreateToggle("Infinite Jump", function(Enabled)
    State.InfiniteJump = Enabled
end)

-- Combat Section
VertexUI:CreateSection("Combat")

local AimAssistToggle = VertexUI:CreateToggle("Aim Assist", function(Enabled)
    State.AimAssist.Enabled = Enabled
end)

local AimAssistSmoothSlider = VertexUI:CreateSlider("Aim Smoothness", 1, 100, 10, function(Value)
    State.AimAssist.Smoothness = Value / 100
end)

local AimAssistFOVSlider = VertexUI:CreateSlider("Aim FOV", 50, 300, 100, function(Value)
    State.AimAssist.FOV = Value
end)

local SilentAimToggle = VertexUI:CreateToggle("Silent Aim", function(Enabled)
    State.SilentAim.Enabled = Enabled
    if Enabled then
        SilentAim:EnableHooks()
    end
end)

local SilentAimChanceSlider = VertexUI:CreateSlider("Hit Chance %", 1, 100, 100, function(Value)
    State.SilentAim.HitChance = Value
end)

local SilentAimFOVSlider = VertexUI:CreateSlider("Silent FOV", 50, 300, 100, function(Value)
    State.SilentAim.FOV = Value
end)

local SilentAimPredictionToggle = VertexUI:CreateToggle("Prediction", function(Enabled)
    State.SilentAim.Prediction = Enabled
end)

local SilentAimPredictionSlider = VertexUI:CreateSlider("Prediction Amount", 1, 50, 10, function(Value)
    State.SilentAim.PredictionAmount = Value / 100
end)

-- ESP Section
VertexUI:CreateSection("Visual ESP")

local ESPToggle = VertexUI:CreateToggle("Enable ESP", function(Enabled)
    State.ESP.Enabled = Enabled
    if not Enabled then
        ESP:Update() -- Clear drawings
    end
end)

local ESPBoxToggle = VertexUI:CreateToggle("Box ESP", function(Enabled)
    State.ESP.Boxes = Enabled
end)

local ESPNameToggle = VertexUI:CreateToggle("Name ESP", function(Enabled)
    State.ESP.Names = Enabled
end)

local ESPHealthToggle = VertexUI:CreateToggle("Health ESP", function(Enabled)
    State.ESP.Health = Enabled
end)

local ESPDistanceToggle = VertexUI:CreateToggle("Distance ESP", function(Enabled)
    State.ESP.Distance = Enabled
end)

local ESPDistanceSlider = VertexUI:CreateSlider("Max Distance", 100, 5000, 1000, function(Value)
    State.ESP.MaxDistance = Value
end)

local ESPTeamToggle = VertexUI:CreateToggle("Team Check", function(Enabled)
    State.ESP.TeamCheck = Enabled
end)

-- ===========================================================================
-- UI TOGGLE & DRAGGING
-- ===========================================================================
local UIVisible = true
local Dragging = false
local DragStart, StartPosition

-- Toggle UI with Insert key
UserInputService.InputBegan:Connect(function(Input, Processed)
    if Processed then return end
    
    if Input.KeyCode == Enum.KeyCode.Insert then
        UIVisible = not UIVisible
        MainFrame.Visible = UIVisible
    end
end)

-- Dragging functionality
Header.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging = true
        DragStart = Input.Position
        StartPosition = MainFrame.Position
        
        Input.Changed:Connect(function()
            if Input.UserInputState == Enum.UserInputState.End then
                Dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(Input)
    if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
        local Delta = Input.Position - DragStart
        MainFrame.Position = UDim2.new(
            StartPosition.X.Scale,
            StartPosition.X.Offset + Delta.X,
            StartPosition.Y.Scale,
            StartPosition.Y.Offset + Delta.Y
        )
    end
end)

-- ===========================================================================
-- INITIALIZATION
-- ===========================================================================
-- Initialize ESP
if not ESP:Initialize() then
    ESPToggle:SetState(false)
    warn("ESP requires Drawing API")
end

-- Initialize Silent Aim hooks
task.spawn(function()
    SilentAim:EnableHooks()
end)

print("Vertex Hub - Vertical Redesign")
print("Loaded successfully!")
print("Press Insert to toggle UI")
print("Features:")
print("- WalkSpeed Control")
print("- Slide Boost (Left Ctrl)")
print("- Fly + Noclip System")
print("- Infinite Jump")
print("- Aim Assist")
print("- Improved ESP System")
print("- Silent Aim")
