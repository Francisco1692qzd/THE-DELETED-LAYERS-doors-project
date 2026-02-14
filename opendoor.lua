-- [[ OpenDoor.lua - The Final Stand ]]
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- [1. CHOOSE THE OPENER]
local function GetOpener()
    local p = Players:GetPlayers()
    -- Sorts by ID so the person with the smallest number is always index 1
    table.sort(p, function(a, b) return a.UserId < b.UserId end)
    return p[1]
end

local function FullBreach()
    -- Only the Chosen One runs the teleport
    if LocalPlayer ~= GetOpener() then return end
    if _G.DoorBreaching then return end
    _G.DoorBreaching = true

    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then _G.DoorBreaching = false return end

    -- [2. TARGETING]
    local latestRoom = RS.GameData.LatestRoom.Value
    local room = workspace.CurrentRooms:FindFirstChild(tostring(latestRoom))

    if room then
        local roomEnd = room:FindFirstChild("RoomEnd")
        local door = room:FindFirstChild("Door")
        local main = door and (door:FindFirstChild("Door") or door:FindFirstChild("Panel"))

        -- Only run if the door is actually closed
        if roomEnd and door and (not main or main.CanCollide == true) then
            local oldPos = root.CFrame
            local wasHiding = char:GetAttribute("Hiding")

            -- [3. THE SNAP]
            -- Your working logic: Use RoomEnd instead of a calculated offset
            if wasHiding then char:SetAttribute("Hiding", false) end
            
            root.Anchored = true 
            root.CFrame = roomEnd.CFrame

            -- [4. THE PULSE]
            -- Fire the remote and wait 0.1s so the server registers your position
            local remote = door:FindFirstChild("ClientOpen")
            if remote then remote:FireServer() end
            
            -- We use 0.1s instead of Heartbeat to account for ping
            task.wait(0.1) 

            -- [5. RETURN]
            root.Anchored = false
            root.CFrame = oldPos
            if wasHiding then char:SetAttribute("Hiding", true) end
            root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        end
    end

    _G.DoorBreaching = false
end

-- Execute safely
task.spawn(function()
    local success, err = pcall(FullBreach)
    if not success then 
        warn("Breach Error: " .. tostring(err)) 
        _G.DoorBreaching = false
    end
end)
