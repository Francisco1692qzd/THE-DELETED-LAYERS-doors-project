local SoundService = game:GetService("SoundService")

-- 1. Create the SoundNoises Folder (only if it doesn't exist)
local soundFolder = workspace:FindFirstChild("SoundNoises") or Instance.new("Folder", workspace)
soundFolder.Name = "SoundNoises"

-- 2. Define the Sound Data
local soundData = {
    {Name = "Creaking", ID = "9126263705", Vol = 0.5},
    {Name = "Creaking2", ID = "9126264414", Vol = 0.5},
    {Name = "ElevadorDoorSlamAndSqueak", ID = "139834138189648", Vol = 0.2},
    {Name = "DoorCloseSlam", ID = "105010771396686", Vol = 0.4},
    {Name = "WindowKnock", ID = "9194119888", Vol = 0.6},
    {Name = "WindowKnockUrgent", ID = "9116200285", Vol = 0.7},
    {Name = "Hammerdrop", ID = "9126271711", Vol = 0.5},
    {Name = "Hammerdrop2", ID = "9114751814", Vol = 0.5}
}

-- 3. Create the Ghost Emitter Part
local emitter = Instance.new("Part")
emitter.Name = "AmbientOneShot"
emitter.Transparency = 1
emitter.CanCollide = false
emitter.Anchored = true
emitter.Parent = workspace

-- 4. THE EXECUTION
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()

if char and char:FindFirstChild("HumanoidRootPart") then
    -- Pick a random sound from the table
    local pickedData = soundData[math.random(1, #soundData)]
    
    -- Create the sound object
    local sound = Instance.new("Sound")
    sound.Name = pickedData.Name
    sound.SoundId = "rbxassetid://" .. pickedData.ID
    sound.Volume = pickedData.Vol
    sound.RollOffMaxDistance = 50
    sound.RollOffMinDistance = 5
    sound.Parent = emitter
    
    -- Randomize position around the player (15-25 studs away)
    local angle = math.rad(math.random(0, 360))
    local distance = math.random(15, 25)
    local offset = Vector3.new(math.cos(angle) * distance, math.random(-2, 5), math.sin(angle) * distance)
    
    emitter.Position = char.HumanoidRootPart.Position + offset
    
    -- Play and Cleanup
    sound:Play()
    sound.Ended:Connect(function()
        emitter:Destroy() -- Removes the part and the sound once finished
    end)
end
