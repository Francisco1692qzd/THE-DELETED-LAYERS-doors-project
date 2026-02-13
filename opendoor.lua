-- [[ OpenDoor.lua - Seamless Auto-Progress ]]
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer

local function SeamlessBreach()
    local char = Player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- [1. THE HIDING WATCHER]
    -- If the player is currently hiding, we wait for them to exit.
    if char:GetAttribute("Hiding") == true then
        -- This 'repeat' yields the script until they are no longer hiding
        repeat task.wait(0.1) until char:GetAttribute("Hiding") ~= true
    end

    -- [2. TARGETING]
    local roomNum = RS.GameData.LatestRoom.Value
    local room = workspace.CurrentRooms:FindFirstChild(tostring(roomNum))

    if room and room:FindFirstChild("Door") then
        local door = room.Door
        local main = door:FindFirstChild("Door") or door:FindFirstChild("Panel")

        if main and main.CanCollide == true then
            local oldPos = root.CFrame
            
            -- [3. THE SEAMLESS SNAP]
            -- Snap to door underground to remain unnoticed
            root.CFrame = main.CFrame * CFrame.new(0, -15, 0)
            
            -- Single frame trigger
            local remote = door:FindFirstChild("ClientOpen")
            if remote then remote:FireServer() end

            for _, v in pairs(door:GetDescendants()) do
                if v:IsA("ProximityPrompt") then
                    fireproximityprompt(v)
                elseif v:IsA("TouchTransmitter") then
                    firetouchinterest(root, v.Parent, 0)
                    firetouchinterest(root, v.Parent, 1)
                end
            end

            -- [4. THE INSTANT RETURN]
            task.wait() -- Minimal sync
            root.CFrame = oldPos
            root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        end
    end
end

-- Execute in a new thread so it doesn't block other scripts while waiting
task.spawn(function()
    pcall(SeamlessBreach)
end)
