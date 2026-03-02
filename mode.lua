-- [[ THE DELETED LAYERS: MASTER DIRECTOR ]]
-- Start: Door 10 | Cooldown Enabled | Adjustable Chances

if workspace:FindFirstChild("InitiatedDELETEDLAYERS") then return end
local lock = Instance.new("BoolValue", workspace)
lock.Name = "InitiatedDELETEDLAYERS"

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer
local BASE_URL = "https://raw.githubusercontent.com/Francisco1692qzd/THE-DELETED-LAYERS-doors-project/refs/heads/main/"

-- [[ ⚙️ ADJUSTABLE CHANCES (Total must be 100 or less) ]]
local CHANCES = {
    ["Xeno"] = 24,             -- 32% chance
    ["Hollow"] = 10,          -- 10% chance
    ["MissingTexture"] = 12,  -- 12% chance
    ["Window"] = 4,           -- 4% chance
    ["Lookman"] = 19,         -- 65% chance
    ["Watt"] = 4,             -- 4% chance
    ["StaticFace"] = 43       -- 43% chance
}
-- Total Entity Chance: 51% | Empty Room Chance: 49%

local lastEntityRoom = 0 -- Keeps track for the cooldown

local WelcomeMessages = {
    "Be happy, because it exists, smile, because it will never be deleted.",
    "Aww man, i suck at coding.",
    "I use Gemini to help me.",
    "New custom noises added, look at ur shoulder.",
    "I'm happy that Gemini exists. -- Francisco",
    "Hey Gemini Devs, please note me."
}

local function ShowCaption(text, duration)
    local pGui = Player:WaitForChild("PlayerGui")
    if pGui:FindFirstChild("OldHardcoreCaption") then pGui.OldHardcoreCaption:Destroy() end
    local screenGui = Instance.new("ScreenGui", pGui)
    screenGui.Name = "OldHardcoreCaption"
    screenGui.IgnoreGuiInset = true
    
    local captionLabel = Instance.new("TextLabel", screenGui)
    captionLabel.Size = UDim2.new(0.6, 0, 0.05, 10)
    captionLabel.Position = UDim2.new(0.5, 0, 0.92, -60)
    captionLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    captionLabel.BackgroundTransparency = 1
    captionLabel.Text = text
    captionLabel.TextColor3 = Color3.fromRGB(255, 222, 189)
    captionLabel.TextSize = 24
    captionLabel.Font = Enum.Font.Oswald
    captionLabel.TextStrokeTransparency = 0
    
    local alertSound = Instance.new("Sound", game.SoundService)
    alertSound.SoundId = "rbxassetid://3848738542"
    alertSound.Volume = 0.5
    alertSound:Play()
    game.Debris:AddItem(alertSound, 2)
    
    task.delay(duration or 4, function()
        if screenGui and screenGui.Parent then
            game:GetService("TweenService"):Create(captionLabel, TweenInfo.new(0.5), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
            task.wait(0.5) screenGui:Destroy()
        end
    end)
end

local function RunEntity(scriptName)
    local url = BASE_URL .. scriptName
    local success, content = pcall(function() return game:HttpGet(url) end)
    if success then
        local func = loadstring(content)
        if func then task.spawn(func) end
    end
end

-- SYNC SEED
local baseSeed = 0
for i = 1, #game.JobId do baseSeed = baseSeed + string.byte(game.JobId, i) end

-- ANTI-LATE JOIN
if RS.GameData.LatestRoom.Value > 0 then
    local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.Health = 0 end
    return
end

-- MAIN LOOP
RS.GameData.LatestRoom:GetPropertyChangedSignal("Value"):Connect(function()
    local roomNum = RS.GameData.LatestRoom.Value
    
    -- 1. INTRO MESSAGES (Room 1)
    local quoteRNG = Random.new(os.clock() + tick())
    if roomNum == 1 then
        ShowCaption("Thank you for Playing, THE DELETED LAYERS Mode has Initiated", 5)
        task.delay(5.5, function()
            ShowCaption(WelcomeMessages[quoteRNG:NextInteger(1, #WelcomeMessages)], 5)
        end)
    end

    -- 2. AMBIENT NOISES (Runs every room)
    RunEntity("soundnoises.lua")

    -- 3. ENTITY LOGIC (Starts at Door 10)
    if roomNum >= 10 then
        -- Check Cooldown: If an entity spawned in the previous room, skip this one.
        if roomNum > lastEntityRoom + 1 then
            local entityRNG = Random.new(baseSeed + roomNum)
            local roll = entityRNG:NextInteger(1, 100)
            
            -- Weighted Spawn Logic
            if roll <= CHANCES["Xeno"] then
                RunEntity("xenoentity.lua")
                lastEntityRoom = roomNum
            elseif roll <= (CHANCES["Xeno"] + CHANCES["Hollow"]) then
                RunEntity("hollow.lua")
                lastEntityRoom = roomNum
            elseif roll <= (CHANCES["Xeno"] + CHANCES["Hollow"] + CHANCES["MissingTexture"]) then
                RunEntity("missingtexture.lua")
                lastEntityRoom = roomNum
            elseif roll <= (CHANCES["Xeno"] + CHANCES["Hollow"] + CHANCES["MissingTexture"] + CHANCES["Window"]) then
                RunEntity("window.lua")
                lastEntityRoom = roomNum
            elseif roll <= (CHANCES["Xeno"] + CHANCES["Hollow"] + CHANCES["MissingTexture"] + CHANCES["Window"] + CHANCES["Lookman"]) then
                RunEntity("lookman.lua")
                lastEntityRoom = roomNum
            elseif roll <= (CHANCES["Xeno"] + CHANCES["Hollow"] + CHANCES["MissingTexture"] + CHANCES["Window"] + CHANCES["Lookman"] + CHANCES["Watt"]) then
                RunEntity("watt.lua")
                lastEntityRoom = roomNum
            elseif roll == 100 then
                RunEntity("staticface.lua")
                lastEntityRoom = roomNum
            end
        end
    end
end)

print("THE DELETED LAYERS: Mode Active. Entities start at Room 10.")
