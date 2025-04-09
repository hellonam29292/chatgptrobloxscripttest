local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Settings
local FOVRadius = 200          -- radius (in pixels) for selectable targets
local aimSmoothness = 0.1      -- how quickly the camera adjusts towards the target

-- Helper function: Converts a world position (part.Position) to a 2D screen position
local function getScreenPos(part)
    if not part then
        return nil
    end

    local screenPoint, onScreen = Camera:WorldToViewportPoint(part.Position)
    if onScreen then
        return Vector2.new(screenPoint.X, screenPoint.Y)
    end
    return nil
end

-- Helper function: Computes the distance from the center of the viewport
local function distanceFromCenter(screenPos)
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    return (screenPos - center).Magnitude
end

-- Function to find the nearest player's head inside the FOV circle
local function getNearestTarget()
    local nearestDistance = math.huge
    local bestTarget = nil

    for _, player in ipairs(Players:GetPlayers()) do
        -- Skip the local player
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            local screenPos = getScreenPos(head)
            
            if screenPos then
                local dist = distanceFromCenter(screenPos)
                if dist <= FOVRadius and dist < nearestDistance then
                    nearestDistance = dist
                    bestTarget = head
                end
            end
        end
    end

    return bestTarget
end

-- Heartbeat update that (if a target is found) smoothly points the camera at the target's head.
-- Your mouse cursor is not forced to the center, so you can still move freely.
RunService.Heartbeat:Connect(function(delta)
    local targetHead = getNearestTarget()
    
    if targetHead then
        local currentCamPos = Camera.CFrame.Position
        local targetPos = targetHead.Position

        -- Compute the desired CFrame from our camera to the target (aim at the target's head)
        local desiredCFrame = CFrame.new(currentCamPos, targetPos)
        
        -- Smoothly interpolate between the current CFrame and the desired CFrame
        Camera.CFrame = Camera.CFrame:Lerp(desiredCFrame, aimSmoothness)
    end
end)
