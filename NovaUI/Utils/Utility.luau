-- language: luau, file: NovaUI/Utils/Utility.luau
local Utility = {}

function Utility.Create(className: string, properties: { [string]: any }, children: { Instance }?): Instance
    local instance = Instance.new(className)
    for prop, val in pairs(properties or {}) do
        (instance :: any)[prop] = val
    end
    if children then
        for _, child in ipairs(children) do
            child.Parent = instance
        end
    end
    return instance
end

function Utility.AddCorner(instance: Instance, radius: number?): UICorner
    return Utility.Create("UICorner", {
        CornerRadius = UDim.new(0, radius or 6),
        Parent = instance,
    }) :: UICorner
end

function Utility.AddStroke(instance: Instance, color: Color3?, thickness: number?, transparency: number?): UIStroke
    return Utility.Create("UIStroke", {
        Color = color or Color3.fromRGB(60, 60, 70),
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = instance,
    }) :: UIStroke
end

function Utility.AddPadding(instance: Instance, top: number?, bottom: number?, left: number?, right: number?): UIPadding
    return Utility.Create("UIPadding", {
        PaddingTop = UDim.new(0, top or 8),
        PaddingBottom = UDim.new(0, bottom or 8),
        PaddingLeft = UDim.new(0, left or 8),
        PaddingRight = UDim.new(0, right or 8),
        Parent = instance,
    }) :: UIPadding
end

return Utility
