-- [[ OpenDoor.lua - The Ultimate Smart Breach ]]
-- Features: Ghost Snap, Anti-Hiding Logic, Universal Trigger, and Momentum Kill.

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer

-- [1. SMART BREACHER SELECTION]
-- This ensures only one person teleports, but skips anyone currently hiding.
local function IsDesignatedBreacher()
    local allPlayers = Players:GetPlayers()
    local eligible = {}

    for _, p in pairs(allPlayers) do
        local char = p.Character
        -- Check if player exists and is NOT hiding in a closet/under bed
        if char and char:GetAttribute("Hiding") ~= true then
            table.insert(eligible, p)
        end
    end

    -- Sort by UserId for consistency across all clients
    table.sort(eligible, function(a, b) return a.UserId < b.UserId end)

    -- If everyone is hiding, the first player in the server list takes the risk
    if #eligible == 0 then
        local backupList = Players:GetPlayers()
        table.sort(backupList, function(a, b) return a.UserId < b.UserId end)
        return backupList[1] == Player
    end

    return eligible[1] == Player
end

-- [2. THE BREACH EXECUTION]
local function Breach()
    -- Only run if this specific client is the chosen breacher
    if not IsDesignatedBreacher() then return end

    local Character = Player.Character
    local Root = Character and Character:FindFirstChild("HumanoidRootPart")
    if not Root then return end

    local latestRoomNum = RS.GameData.LatestRoom.Value
    local roomFolder = workspace.CurrentRooms:FindFirstChild(tostring(latestRoomNum))

    if roomFolder and roomFolder:FindFirstChild("Door") then
        local doorModel = roomFolder.Door
        
        -- Target the main physical part of the door
        local mainPart = doorModel:FindFirstChild("Door") 
            or doorModel:FindFirstChild("Panel") 
            or doorModel:FindFirstChildOfClass("BasePart")

        if mainPart and mainPart.CanCollide == true then
            local originalPos = Root.CFrame

            -- A. SNAP TO DOOR (Bypasses Magnitude/Distance checks)
            Root.CFrame = mainPart.CFrame
            task.wait() -- Allow physics engine to update position

            -- B. MULTI-TRIGGER (Hit all possible opening methods)
            
            -- Method 1: Remote Events
            local remote = doorModel:FindFirstChild("ClientOpen")
            if remote then remote:FireServer() end

            -- Method 2 & 3: Interactive Objects
            for _, v in pairs(doorModel:GetDescendants()) do
                if v:IsA("ProximityPrompt") then
                    fireproximityprompt(v)
                elseif v:IsA("TouchTransmitter") then
                    -- Force the server to see a physical hit
                    firetouchinterest(Root, v.Parent, 0) -- Touch Start
                    firetouchinterest(Root, v.Parent, 1) -- Touch End
                end
            end

            -- C. SECURE RETURN
            task.wait() -- Small delay to ensure server registered the 'Open'
            Root.CFrame = originalPos
            Root.AssemblyLinearVelocity = Vector3.new(0, 0, 0) -- Stops the player from sliding
        end
    end
end

-- Run with error protection
local success, err = pcall(Breach)
if not success then
    warn("OpenDoor Error: " .. tostring(err))
end
