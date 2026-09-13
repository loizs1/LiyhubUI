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

function Utility.CreateLiyhubMark(parent: Instance, size: number, posX: number, posY: number?): Frame
    local root = Utility.Create("Frame", {
        Name = "LiyhubMark",
        Size = UDim2.fromOffset(size, size),
        Position = UDim2.new(0, posX, 0.5, posY or -math.floor(size / 2)),
        BackgroundColor3 = Color3.fromRGB(15, 15, 20),
        BorderSizePixel = 0,
        Parent = parent,
    }) :: Frame
    Utility.AddCorner(root, size / 2)
    Utility.AddStroke(root, Color3.fromRGB(0, 162, 255), 1, 0.4)

    local scale = size / 22

    -- Vertical stem of L
    local stemW = math.floor(4 * scale + 0.5)
    local stemH = math.floor(13 * scale + 0.5)
    local stemX = math.floor(5 * scale + 0.5)
    local stemY = math.floor(4 * scale + 0.5)

    local stem = Utility.Create("Frame", {
        Name = "Stem",
        Size = UDim2.fromOffset(stemW, stemH),
        Position = UDim2.fromOffset(stemX, stemY),
        BackgroundColor3 = Color3.fromRGB(255, 150, 30),
        BorderSizePixel = 0,
        Parent = root,
    })
    Utility.AddCorner(stem, 2)
    Utility.Create("UIGradient", {
        Rotation = 90,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 155, 35)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 175, 255)),
        }),
        Parent = stem,
    })

    -- Horizontal foot of L
    local footW = math.floor(11 * scale + 0.5)
    local footH = math.floor(4 * scale + 0.5)
    local footX = math.floor(5 * scale + 0.5)
    local footY = math.floor((4 + 13 - 4) * scale + 0.5)

    local foot = Utility.Create("Frame", {
        Name = "Foot",
        Size = UDim2.fromOffset(footW, footH),
        Position = UDim2.fromOffset(footX, footY),
        BackgroundColor3 = Color3.fromRGB(0, 170, 255),
        BorderSizePixel = 0,
        Parent = root,
    })
    Utility.AddCorner(foot, 2)
    Utility.Create("UIGradient", {
        Rotation = 0,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 145, 60)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 175, 255)),
        }),
        Parent = foot,
    })

    -- Celestial Orb (Sun/Moon accent inside L angle)
    local orbSize = math.floor(4 * scale + 0.5)
    local orbX = math.floor(12 * scale + 0.5)
    local orbY = math.floor(6 * scale + 0.5)

    local orb = Utility.Create("Frame", {
        Name = "CelestialOrb",
        Size = UDim2.fromOffset(orbSize, orbSize),
        Position = UDim2.fromOffset(orbX, orbY),
        BackgroundColor3 = Color3.fromRGB(255, 215, 65),
        BorderSizePixel = 0,
        Parent = root,
    })
    Utility.AddCorner(orb, orbSize / 2)

    return root
end

return Utility
