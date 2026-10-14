-- language: luau, file: NovaUI/Services/Input.luau
local UserInputService = game:GetService("UserInputService")
local Utility = require(script.Parent.Parent.Utils.Utility)

local Input = {}

function Input.MakeDraggable(frame: Frame, handle: Frame?)
    local dragHandle = handle or frame
    local moveConn, endConn

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if moveConn then moveConn:Disconnect() moveConn = nil end
            if endConn then endConn:Disconnect() endConn = nil end

            local dragStart = input.Position
            local startPos = frame.Position

            moveConn = UserInputService.InputChanged:Connect(function(moveInput)
                if moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch then
                    local delta = moveInput.Position - dragStart
                    frame.Position = UDim2.new(
                        startPos.X.Scale,
                        startPos.X.Offset + delta.X,
                        startPos.Y.Scale,
                        startPos.Y.Offset + delta.Y
                    )
                end
            end)

            endConn = UserInputService.InputEnded:Connect(function(endInput)
                if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                    if moveConn then moveConn:Disconnect() moveConn = nil end
                    if endConn then endConn:Disconnect() endConn = nil end
                end
            end)
        end
    end)
end

function Input.MakeResizable(frame: Frame, handle: Frame, minSize: Vector2)
    local moveConn, endConn

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if moveConn then moveConn:Disconnect() moveConn = nil end
            if endConn then endConn:Disconnect() endConn = nil end

            local dragStart = input.Position
            local startSize = frame.AbsoluteSize

            moveConn = UserInputService.InputChanged:Connect(function(moveInput)
                if moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch then
                    local delta = moveInput.Position - dragStart
                    local newWidth = math.max(minSize.X, startSize.X + delta.X)
                    local newHeight = math.max(minSize.Y, startSize.Y + delta.Y)
                    frame.Size = UDim2.fromOffset(newWidth, newHeight)
                end
            end)

            endConn = UserInputService.InputEnded:Connect(function(endInput)
                if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                    if moveConn then moveConn:Disconnect() moveConn = nil end
                    if endConn then endConn:Disconnect() endConn = nil end
                end
            end)
        end
    end)
end

return Input
