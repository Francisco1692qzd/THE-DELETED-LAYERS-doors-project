-- [[ OpenDoor.lua - Hiding Bypass Edition ]]
-- Forces the door to open even while you are inside a closet.

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer

-- [1. THE DESIGNATED BREACHER]
-- Standard leader selection so only one player teleports
local function IsDesignatedBreacher()
    local allPlayers = Players:GetPlayers()
    table.sort(allPlayers, function(a, b) return a.UserId < b.UserId end)
    return allPlayers[1] == Player
end

local function Breach()
    if not IsDesignatedBreacher() then return end

    local Character = Player.Character
    local Root = Character and Character:FindFirstChild("HumanoidRootPart")
    if not Root then return end

    local latestRoomNum = RS.GameData.LatestRoom.Value
    local roomFolder = workspace.CurrentRooms:FindFirstChild(tostring(latestRoomNum))

    if roomFolder and roomFolder:FindFirstChild("Door") then
        local doorModel = roomFolder.Door
        local mainPart = doorModel:FindFirstChild("Door") or doorModel:FindFirstChild("Panel") or doorModel:FindFirstChildOfClass("BasePart")

        if mainPart and mainPart.CanCollide == true then
            -- A. SAVE CURRENT STATE
            local originalPos = Root.CFrame
            local wasHiding = Character:GetAttribute("Hiding")

            -- B. THE "UN-HIDE" GLITCH
            -- Temporarily disable hiding so the door/prompts accept our interaction
            if wasHiding then
                Character:SetAttribute("Hiding", false)
            end

            -- C. THE GHOST SNAP
            Root.CFrame = mainPart.CFrame
            task.wait() -- Frame 1: Server sees you at the door and NOT hiding

            -- D. FIRE TRIGGERS
            local remote = doorModel:FindFirstChild("ClientOpen")
            if remote then remote:FireServer() end

            for _, v in pairs(doorModel:GetDescendants()) do
                if v:IsA("ProximityPrompt") then
                    fireproximityprompt(v)
                elseif v:IsA("TouchTransmitter") then
                    firetouchinterest(Root, v.Parent, 0)
                    firetouchinterest(Root, v.Parent, 1)
                end
            end

            -- E. THE RE-HIDE & RETURN
            -- We put you back exactly where you were and restore your invincibility
            task.wait() -- Frame 2: Server processes the open
            
            Root.CFrame = originalPos
            if wasHiding then
                Character:SetAttribute("Hiding", true)
            end
            
            Root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            print("Door " .. latestRoomNum .. " breached from hiding.")
        end
    end
end

pcall(Breach)
