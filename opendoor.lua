-- [[ OpenDoor.lua - Hide-Friendly Bunker ]]
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer

local function UniversalBunkerBreach()
    if _G.DoorBreaching then return end
    _G.DoorBreaching = true

    local char = Player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then _G.DoorBreaching = false return end

    -- [1. TARGETING]
    local roomNum = RS.GameData.LatestRoom.Value
    local room = workspace.CurrentRooms:FindFirstChild(tostring(roomNum))
    if not room or not room:FindFirstChild("Door") then 
        _G.DoorBreaching = false 
        return 
    end

    local door = room.Door
    local main = door:FindFirstChild("Door") or door:FindFirstChild("Panel")

    if main and main.CanCollide == true then
        -- [2. STATE PRESERVATION]
        local oldPos = root.CFrame
        -- We keep the "Hiding" attribute exactly as it is. 
        -- No waiting, no toggling.

        -- [3. THE UNDERWORLD BUNKER]
        -- -15 is DOWN (Under floor), 4 is BACK (Behind door)
        local bunkerCF = main.CFrame * CFrame.new(0, -15, 4) 

        root.CFrame = bunkerCF
        
        -- Fire Remote
        local remote = door:FindFirstChild("ClientOpen")
        if remote then remote:FireServer() end

        -- 2-frame stay for server registration (Invisible to eyes)
        RunService.Heartbeat:Wait()
        RunService.Heartbeat:Wait()

        -- Trigger all events
        for _, v in pairs(door:GetDescendants()) do
            if v:IsA("ProximityPrompt") then
                fireproximityprompt(v)
            elseif v:IsA("TouchTransmitter") then
                firetouchinterest(root, v.Parent, 0)
                firetouchinterest(root, v.Parent, 1)
            end
        end

        -- [4. THE SECURE RETURN]
        root.CFrame = oldPos
        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end

    _G.DoorBreaching = false
end

-- This will now trigger regardless of whether the player is hiding or walking
task.spawn(function()
    pcall(UniversalBunkerBreach)
end)
