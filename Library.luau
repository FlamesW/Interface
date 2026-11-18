-- // Interface.luau
local math_huge, Color3_fromRGB, table_unpack, math_clamp, math_max, table_insert = math.huge, Color3.fromRGB, table.unpack, math.clamp, math.max, table.insert
local ColorSequenceKeypoint_new, Color3_fromHSV, Instance_new, math_floor, math_sign, Vector2_new = ColorSequenceKeypoint.new, Color3.fromHSV, Instance.new, math.floor, math.sign, Vector2.new
local UDim2_new, UDim2_fromOffset, UDim2_fromScale, UDim_new, TweenInfo_new, Color3_new = UDim2.new, UDim2.fromOffset, UDim2.fromScale, UDim.new, TweenInfo.new, Color3.new
local table_find, math_abs, Vector2_zero, math_min, task_delay, string_format = table.find, math.abs, Vector2.zero, math.min, task.delay, string.format
local Color3_fromHex, os_date, task_defer, table_sort, table_concat, table_clone = Color3.fromHex, os.date, task.defer, table.sort, table.concat, table.clone
local table_remove, table_pack, NumberSequence_new, NumberSequenceKeypoint_new, ColorSequence_new, math_ceil = table.remove, table.pack, NumberSequence.new, NumberSequenceKeypoint.new, ColorSequence.new, math.ceil
local task_spawn, utf8_len, utf8_offset, table_clear, string_sub, Random_new = task.spawn, utf8.len, utf8.offset, table.clear, string.sub, Random.new
local math_sin, os_clock, string_match, math_noise, task_wait, typeof = math.sin, os.clock, string.match, math.noise, task.wait, typeof
local type, pcall, tonumber, tostring, warn, print = type, pcall, tonumber, tostring, warn, print
local next, setmetatable, pairs, ipairs, assert, write_file = next, setmetatable, pairs, ipairs, assert, writefile
local read_file, is_file, is_folder, make_folder, delete_file, setclipboard = readfile, isfile, isfolder, makefolder, delfile, setclipboard

local Library = (function()
local cloneref = (cloneref or clonereference or function(instance: any)
    return instance
end)

local CoreGui: CoreGui = cloneref(game:GetService("CoreGui"))
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local Players: Players = cloneref(game:GetService("Players"))
local RunService: RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local TweenService: TweenService = cloneref(game:GetService("TweenService"))
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")

local getgenv = getgenv or function()
    return shared
end

local protectgui = protectgui or (syn and syn.protect_gui) or function() end
local gethui = gethui or function()
    return CoreGui
end

local Library = {
    Debug = false, Connections = {}, Flags = {}, Tabs = {},
    LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait(),

    UISize = 245, ToggleKeybind = Enum.KeyCode.V, ShowLibrarysFeatures = true,
    Opened = nil, SaveFolder = nil, Mobile = UserInputService:GetPlatform() == Enum.Platform.Android or UserInputService:GetPlatform() == Enum.Platform.IOS,
}

function Library:AddConnection(connection)
    table_insert(Library.Connections, connection)
end

local function SafeParentUI(Instance: Instance, Parent: Instance | () -> Instance)
    local success, _error = pcall(function()
        if not Parent then
            Parent = CoreGui
        end

        local DestinationParent
        if typeof(Parent) == "function" then
            DestinationParent = Parent()
        else
            DestinationParent = Parent
        end

        Instance.Parent = DestinationParent
    end)

    if not (success and Instance.Parent) then
        Instance.Parent = Library.LocalPlayer:WaitForChild("PlayerGui", math_huge)
    end
end

local function ParentUI(UI: Instance, SkipHiddenUI: boolean?)
    if SkipHiddenUI then
        SafeParentUI(UI, CoreGui)
        return
    end

    pcall(protectgui, UI)
    SafeParentUI(UI, gethui)
end

local ThemeDefinitions = {
    Default = { low = {0, 0, 0}, accent = {60, 200, 100} },
    Nature = { low = {13, 22, 16}, accent = {91, 190, 105} },
    Rose = {base = {24, 21, 30}, surface = {59, 53, 68}, accent = {230, 153, 171}},
    Obsidian = { low = {7, 3, 15}, accent = {160, 86, 230}, darken = 0.72 },
    Discord = { low = {14, 15, 23}, accent = {114, 137, 255} },
    Midnight = { low = {6, 11, 26}, accent = {98, 155, 245} },
    SynthWave = { low = {22, 8, 29}, accent = {255, 84, 181} },
    Monokai = { low = {3, 3, 3}, accent = {171, 237, 31} },
    Solarized = { low = {2, 25, 28}, accent = {42, 161, 152} },
    Red = { low = {25, 8, 8}, accent = {240, 70, 70} },
    Pink = { low = {24, 9, 17}, accent = {244, 122, 181} },
    Aurora = { low = {8, 19, 21}, accent = {100, 222, 189} },
    Sunset = { low = {23, 11, 15}, accent = {255, 145, 91} },
    Sandstorm = {base = {34, 26, 17}, surface = {93, 73, 45}, accent = {238, 194, 116}},
    Cyberpunk = {base = {25, 19, 35}, surface = {69, 53, 74}, accent = {243, 220, 70}},
    Glacier = {base = {15, 28, 39}, surface = {47, 79, 96}, accent = {162, 224, 245}},
    Espresso = {base = {29, 16, 11}, surface = {90, 56, 35}, accent = {241, 196, 146}},
    Volcano = {base = {34, 9, 6}, surface = {95, 31, 19}, accent = {255, 153, 49}},
    Energized = {base = {7, 26, 27}, surface = {31, 72, 69}, accent = {241, 150, 87}},
    Gum = {base = {6, 28, 22}, surface = {27, 79, 63}, accent = {249, 165, 189}},
    Arctic = {base = {22, 35, 45}, surface = {61, 91, 110}, accent = {197, 239, 255}},
    Orchid = {base = {34, 12, 34}, surface = {98, 42, 91}, accent = {127, 235, 206}},
    Slate = {base = {22, 27, 34}, surface = {65, 73, 84}, accent = {161, 202, 226}},
    Eucalyptus = {base = {22, 38, 31}, surface = {57, 94, 79}, accent = {154, 211, 184}},
    Lagoon = {base = {7, 35, 35}, surface = {24, 91, 88}, accent = {91, 222, 201}},
    Cocoa = {base = {32, 21, 19}, surface = {87, 61, 55}, accent = {221, 176, 161}},
    Charcoal = {base = {20, 21, 23}, surface = {66, 68, 72}, accent = {212, 215, 219}},
    Steel = {base = {22, 29, 34}, surface = {65, 83, 93}, accent = {173, 198, 211}},
    Firefly = {base = {13, 20, 30}, surface = {35, 48, 67}, accent = {241, 199, 91}},
    Gold = {base = {22, 22, 20}, surface = {61, 60, 54}, accent = {224, 191, 111}},
}
local function ResolveThemeName(name)
    if type(name) ~= "string" then return nil end
    return ThemeDefinitions[name] and name or nil
end
local function IsLightTheme(name)
    local definition = ThemeDefinitions[name]
    return definition ~= nil and definition.light == true
end
local ThemeName = "Default"
local ThemeNeutralValues = {0, 20, 25, 30, 32, 35, 38, 40, 42, 45, 50, 60, 72, 80, 85, 90, 95, 100, 140, 150, 160, 170, 180, 200, 220, 255}
local function ComputePaletteColor(name, r, g, b)
    local def = ThemeDefinitions[name] or ThemeDefinitions.Default
    if r == 60 and g == 200 and b == 100 then return Color3_fromRGB(table_unpack(def.accent)) end
    if r ~= g or g ~= b then return Color3_fromRGB(r, g, b) end
    if name == "Default" then return Color3_fromRGB(r, g, b) end
    if def.paper and def.surface and def.ink and def.muted then
        if r <= 100 then
            return Color3_fromRGB(table_unpack(def.paper)):Lerp(Color3_fromRGB(table_unpack(def.surface)), math_clamp(r / 100, 0, 1))
        end
        return Color3_fromRGB(table_unpack(def.muted)):Lerp(Color3_fromRGB(table_unpack(def.ink)), math_clamp((r - 100) / 155, 0, 1))
    end
    if def.base and def.surface then
        local base = Color3_fromRGB(table_unpack(def.base))
        local surface = Color3_fromRGB(table_unpack(def.surface))
        if r <= 100 then return base:Lerp(surface, math_clamp((r - 15) / 85, 0, 1)) end
        local t = math_clamp((r - 100) / 155, 0, 1)
        return surface:Lerp(Color3_fromRGB(242, 240, 245), 0.48 + 0.52 * t)
    end
    if def.light then
        local shade
        if r <= 35 then shade = 255 - r * 0.65
        elseif r <= 100 then shade = math_clamp(232.25 - (r - 35) * 1.55, 130, 232.25)
        else shade = math_clamp(82 - (r - 100) * 0.37, 24, 82) end
        return Color3_fromRGB(shade, shade, math_clamp(shade + (r <= 100 and 2 or 0), 0, 255))
    end
    local amount = math_max(0, 1 - r / 255)
    local tone = def.darken and r <= 100 and r * def.darken or r
    return Color3_fromRGB(math_clamp(tone + def.low[1] * amount, 0, 255), math_clamp(tone + def.low[2] * amount, 0, 255), math_clamp(tone + def.low[3] * amount, 0, 255))
end
local PaletteColorCache = {}
local function PaletteColor(name, r, g, b)
    name = name or "Default"
    if r >= 0 and r <= 255 and g >= 0 and g <= 255 and b >= 0 and b <= 255
        and r == math_floor(r) and g == math_floor(g) and b == math_floor(b) then
        local Cache = PaletteColorCache[name]
        if not Cache then Cache = {}; PaletteColorCache[name] = Cache end
        local Key = r * 65536 + g * 256 + b
        local Color = Cache[Key]
        if Color then return Color end
        Color = ComputePaletteColor(name, r, g, b)
        Cache[Key] = Color
        return Color
    end
    return ComputePaletteColor(name, r, g, b)
end
local function ThemeColor(r, g, b) return PaletteColor(ThemeName, r, g, b) end
local function ThemeTextAlpha(value)
    if IsLightTheme(ThemeName) and value > 0 and value < 1 then return value * 0.48 end
    if value > 0 and value < 1 then return value * 0.22 end
    return value
end

local DefaultToggleColor = ThemeColor(60, 60, 60)
local HoveringToggleColor = ThemeColor(100, 100, 100)
local EnabledToggleColor = ThemeColor(60, 200, 100)

local SemiBoldFont = Font.fromEnum(Enum.Font.GothamBold)
local MediumFont = Font.fromEnum(Enum.Font.GothamMedium)
local RegularFont = Font.fromEnum(Enum.Font.Gotham)

local KeyCodesName = {
    [Enum.KeyCode.Insert] = "Ins",
    [Enum.KeyCode.Delete] = "Del",
    [Enum.KeyCode.PageDown] = "PgDn",
    [Enum.KeyCode.PageUp] = "PgUp",

    [Enum.KeyCode.LeftAlt] = "LAlt",
    [Enum.KeyCode.RightAlt] = "RAlt",
    [Enum.KeyCode.LeftControl] = "LCtrl",
    [Enum.KeyCode.RightControl] = "RCtrl",
    [Enum.KeyCode.LeftShift] = "LShift",
    [Enum.KeyCode.RightShift] = "RShift",

    [Enum.UserInputType.MouseButton1] = "LMB",
    [Enum.UserInputType.MouseButton2] = "RMB",
    [Enum.UserInputType.MouseButton3] = "MMB",
}

function GetKeybindFromString(value)
    if value == nil or value == false then return nil end
    if typeof(value) == "EnumItem" then
        if value.EnumType == Enum.KeyCode and value ~= Enum.KeyCode.Unknown then return value end
        if value.EnumType == Enum.UserInputType then return value end
        return nil
    end
    if type(value) ~= "string" then return nil end
    if value == "" or value:lower() == "none" or value:lower() == "nil" then return nil end
    local enumType, name = value:match("^Enum%.(%w+)%.(%w+)$")
    local ok, result = pcall(function()
        local lower = (name or value):lower()
        if not enumType or enumType == "KeyCode" then
            for _, item in ipairs(Enum.KeyCode:GetEnumItems()) do if item.Name:lower() == lower then return item end end
        end
        if not enumType or enumType == "UserInputType" then
            for _, item in ipairs(Enum.UserInputType:GetEnumItems()) do if item.Name:lower() == lower then return item end end
        end
    end)
    if ok and typeof(result) == "EnumItem" and result ~= Enum.KeyCode.Unknown then return result end
    return nil
end

local HueSequenceTable = {}
for hue = 0, 1, 0.1 do
    table_insert(HueSequenceTable, ColorSequenceKeypoint_new(hue, Color3_fromHSV(hue, 1, 1)))
end

local function Create(class: string, properties: table): Instance
    local instance = Instance_new(class)
    if instance:IsA("GuiObject") then instance.BorderSizePixel = 0 end
    for property, value in pairs(properties) do
        if property ~= "Parent" then instance[property] = value end
    end
    if properties.Parent then instance.Parent = properties.Parent end
    return instance
end

local function Round(number, factor)
    local result = math_floor(number / factor + (math_sign(number) * 0.5)) * factor
    if result < 0 then result += factor end
    return result
end

local TextBoundsCache = {}
local TextBoundsCount = 0
local TextBoundsKeys = {}
local TextBoundsCursor = 1
local function GetTextBounds(text: string, font, size: number, width: number)
    local key = text .. "|" .. tostring(size) .. "|" .. tostring(width) .. "|" .. tostring(font)
    local cached = TextBoundsCache[key]
    if cached then return cached end

    local params = Instance_new("GetTextBoundsParams")
    params.Text = text
    params.Font = font
    params.Size = size
    params.Width = width

    local ok, bounds = pcall(function() return TextService:GetTextBoundsAsync(params) end)
    params:Destroy()
    if not ok or not bounds then return nil end

    if TextBoundsCount >= 768 then
        TextBoundsCache[TextBoundsKeys[TextBoundsCursor]] = nil
    else
        TextBoundsCount += 1
    end
    TextBoundsKeys[TextBoundsCursor] = key
    TextBoundsCursor = TextBoundsCursor % 768 + 1
    TextBoundsCache[key] = bounds
    return bounds
end

local ActiveTweens = {}
local ActiveTweenGoals = {}
local function Tween(target, info, props)
    local previous = ActiveTweens[target]
    local Goal = ActiveTweenGoals[target]
    if previous and Goal then
        local LastInfo = Goal.Info
        local SameInfo = LastInfo == info or (
            LastInfo.Time == info.Time and LastInfo.EasingStyle == info.EasingStyle
            and LastInfo.EasingDirection == info.EasingDirection
            and LastInfo.RepeatCount == info.RepeatCount
            and LastInfo.Reverses == info.Reverses and LastInfo.DelayTime == info.DelayTime
        )
        if SameInfo then
            local SameGoal = true
            for Property, Value in pairs(props) do
                if Goal.Props[Property] ~= Value then SameGoal = false; break end
            end
            if SameGoal then
                for Property in pairs(Goal.Props) do
                    if props[Property] == nil then SameGoal = false; break end
                end
            end
            if SameGoal then return previous end
        end
    end
    local unchanged = true
    for property, goal in pairs(props) do
        if target[property] ~= goal then unchanged = false; break end
    end
    if unchanged then
        if previous then previous:Cancel() end
        ActiveTweens[target], ActiveTweenGoals[target] = nil, nil
        return
    end
    if previous then previous:Cancel() end
    local tween = TweenService:Create(target, info, props)
    ActiveTweens[target] = tween
    ActiveTweenGoals[target] = {Info = info, Props = table_clone(props)}
    tween.Completed:Once(function()
        if ActiveTweens[target] == tween then
            ActiveTweens[target], ActiveTweenGoals[target] = nil, nil
        end
    end)
    tween:Play()
    return tween
end

local function MakeDraggable(instance: Instance, main: Instance)
    local dragging = false
    local mousePos
    local framePos
    local startAbsolute
    local dragConnection

    instance.InputBegan:Connect(function(input: InputObject)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            mousePos = input.Position
            framePos = main.Position
            startAbsolute = main.AbsolutePosition

            if dragConnection then dragConnection:Disconnect() end
            dragConnection = UserInputService.InputChanged:Connect(function(i: InputObject)
                if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                    if input.UserInputType == Enum.UserInputType.Touch and i ~= input then return end
                    local delta = i.Position - mousePos
                    local camera = workspace.CurrentCamera
                    local viewport = camera and camera.ViewportSize or Vector2_new(800, 600)
                    local inset = game:GetService("GuiService"):GetGuiInset()
                    local size = main.AbsoluteSize
                    local minX, minY = 6, 0
                    local maxX = math_max(minX, viewport.X - size.X - 6)
                    local maxY = math_max(minY, viewport.Y - size.Y - 1)
                    local x = math_clamp(startAbsolute.X + delta.X, minX, maxX)
                    local y = math_clamp(startAbsolute.Y + delta.Y, minY, maxY)
                    local uiScale = main.Parent and main.Parent:FindFirstChildOfClass("UIScale")
                    local scale = uiScale and uiScale.Scale or 1
                    main.Position = UDim2_new(framePos.X.Scale, framePos.X.Offset + (x - startAbsolute.X) / scale, framePos.Y.Scale, framePos.Y.Offset + (y - startAbsolute.Y) / scale)
                end
            end)
            table_insert(Library.Connections, dragConnection)

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if dragConnection then
                        dragConnection:Disconnect()
                        local index = table_find(Library.Connections, dragConnection)
                        if index then table_remove(Library.Connections, index) end
                        dragConnection = nil
                    end
                end
            end)
        end
    end)
end

local function CreateDragGrip(parent, target)
    local grip = Create("TextButton", {
        Name = "DragGrip", AutoButtonColor = false, Active = true,
        BackgroundTransparency = 1, AnchorPoint = Vector2_new(0,0),
        Size = UDim2_fromOffset(26,26), Visible = false,
        Text = "", ZIndex = 80, Parent = parent,
    })
    grip:SetAttribute("GripAllowed", true)
    local clip = Create("Frame", {
        Name = "GripClip", BackgroundTransparency = 1, ClipsDescendants = true,
        Size = UDim2_fromScale(1,1), ZIndex = 81, Parent = grip,
    })
    local arc = Create("Frame", {
        Name = "FloatingGrip", BackgroundTransparency = 1, BorderSizePixel = 0,
        Position = UDim2_fromScale(-0.55,-0.55), Size = UDim2_fromScale(1.35,1.35),
        ZIndex = 82, Parent = clip,
    })
    Create("UICorner", {CornerRadius = UDim_new(1,0), Parent = arc})
    local stroke = Create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3_fromRGB(175,175,175), Transparency = 0.72, Thickness = 2, Parent = arc})
    stroke:SetAttribute("ThemeColorIgnore", true)
    local hovering = false
    local info = TweenInfo_new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local function update()
        if not target.Parent or not grip.Parent then return end
        local dpi = Library.MobileScale and Library.MobileScale.Scale or 1
        local p, size = target.AbsolutePosition, target.AbsoluteSize
        grip.Position = UDim2_fromOffset(p.X + size.X - 16*dpi, p.Y + size.Y - 16*dpi)
        grip.Size = UDim2_fromOffset(26*dpi,26*dpi)
        local visible = target.Visible and grip:GetAttribute("GripAllowed") ~= false
        local ancestor = target.Parent
        while ancestor and ancestor ~= parent do
            if ancestor:IsA("GuiObject") and not ancestor.Visible then visible = false break end
            ancestor = ancestor.Parent
        end
        local alpha = target:IsA("CanvasGroup") and target.GroupTransparency or 0
        grip.Visible = visible and alpha < .999
        stroke.Transparency = (hovering and .05 or .72) + (hovering and .95 or .28) * alpha
    end
    local connections = {}
    local function watch(signal) table_insert(connections, signal:Connect(update)) end
    watch(target:GetPropertyChangedSignal("AbsolutePosition"))
    watch(target:GetPropertyChangedSignal("AbsoluteSize"))
    watch(target:GetPropertyChangedSignal("Visible"))
    if target:IsA("CanvasGroup") then watch(target:GetPropertyChangedSignal("GroupTransparency")) end
    if target.Parent and target.Parent:IsA("GuiObject") then watch(target.Parent:GetPropertyChangedSignal("Visible")) end
    watch(grip:GetAttributeChangedSignal("GripAllowed"))
    grip.MouseEnter:Connect(function() hovering = true; Tween(stroke, info, {Color = Color3_new(1,1,1), Transparency = .05}) end)
    grip.MouseLeave:Connect(function() hovering = false; Tween(stroke, info, {Color = Color3_fromRGB(175,175,175), Transparency = .72}) end)
    target.Destroying:Connect(function()
        for _, connection in ipairs(connections) do connection:Disconnect() end
        grip:Destroy()
    end)
    update()
    return grip
end

Library.Icons = nil
Library.IconCache = {}

do
    local Lucide = {}

    local icons = {{"align-vertical-distribute-center","chevron-down","list-restart","table-cells-split","gavel","dna-off","refresh-ccw-dot","venus","bean","circle-question-mark","folder-code","bolt","heater","feather","align-horizontal-distribute-center","grip-vertical","pill-bottle","person-standing","badge-swiss-franc","between-horizontal-end","file-braces-corner","rotate-cw","house-plus","bus-front","shield-ellipsis","between-vertical-end","globe-lock","tags","concierge-bell","bookmark-minus","plant-pot","file-down","picture-in-picture","messages-square","scissors","file-check-corner","phone-call","anchor","hand-helping","text-wrap","birdhouse","wifi-off","cloud-alert","message-square","cloud-download","folder-plus","cctv-off","notebook-dot","mirror-round","user-round","pointer","between-horizontal-start","chevrons-up-down","brush","message-circle-more","parentheses","book-up-2","flame","chevrons-up","square-dashed","square-mouse-pointer","superscript","signal","wifi-cog","hexagon","navigation-2-off","eye-off","arrows-up-from-line","file-code-corner","square-centerline-dashed-horizontal","panels-right-bottom","scaling","hash","arrow-left-from-line","ship","ticket-percent","calendar-clock","x","non-binary","voicemail","presentation","tree-palm","badge","captions-off","align-vertical-justify-center","download","mouse-right","lens-convex","shrimp-off","focus","diamond-percent","arrow-big-up","volume-x","mouse-pointer-click","face-slightly-smiling-plus","hard-drive","grid-2x2-x","package-minus","cloud","pipette","corner-left-down","badge-cent","cloud-lightning","user-round-pen","arrow-left-to-line","book-open-text","monitor-cloud","parking-meter","cat","heart-handshake","dam","trees","ham","circle-pause","chess-king","bean-off","clef-alto","separator-horizontal","ambulance","globe-code","citrus","phone-missed","calendar-off","chart-column","battery-medium","square-minus","star-check","decimals-arrow-left","folder-output","menu","bangladeshi-taka","image-down","terminal","building-complex-plus","circle-dot-dashed","medal","cake-slice","git-graph","armchair","tickets","qr-code","copy","goal","book-bookmark","trending-down","creative-commons","layers-arrow-down","ev-charger","user-star","road","nfc","align-center-horizontal","car","notebook-tabs","ear","videotape","sun-moon","chart-scatter","podium","toolbox","calendar","calendar-cog","gallery-horizontal","clipboard-x","list-sort-ascending","book-open","circle-pile","rectangle-ellipsis","badge-plus","badge-info","file-headphone","bow-arrow","clipboard-pen-line","user-round-key","folder-search","utensils-crossed","arrow-up","arrow-up-from-dot","align-vertical-justify-start","layers-minus","pause","shrub","flag","biceps-flexed","align-horizontal-distribute-end","donut","calendar-plus-2","move-vertical","file-pen-line","badge-russian-ruble","radius","pilcrow","corner-left-up","georgian-lari","cable","book-user","square-arrow-down","circle-plus","view","cctv","circle-arrow-left","square-off","octagon-alert","panel-bottom-dashed","book-a","align-end-vertical","thumbs-up","globe","rabbit","layers-plus","door-stairwell","banknote-arrow-down","message-square-off","dice-4","message-circle-x","folder-x","message-circle-warning","map","move","arrow-up-left","award","arrow-down-wide-narrow","unfold-horizontal","lens-concave","zoom-out","motorbike","music-4","zoom-in","shield-x","file-volume","disc-3","file-signal","columns-4","archive-x","zodiac-virgo","square-dashed-kanban","mouse-pointer-2","clock-arrow-up","clock-fading","pencil-sparkles","library-big","vegan","star-plus","file-check","clef-bass","message-circle-plus","user-key","credit-card-plus","zodiac-pisces","fast-forward","user-pen","chess-knight","wifi-pen","files","send-to-back","alarm-clock","microscope","zodiac-libra","zodiac-leo","zodiac-gemini","shopping-basket","send","smartphone","square-dashed-bottom","zodiac-aries","zodiac-aquarius","land-plot","wind-arrow-down","germ-off","brush-cleaning","skip-back","x-line-top","book-audio","octagon-minus","file-scan","cupcake","midi-port","message-square-dashed","shield-check","worm","chevrons-left","workflow","umbrella","skip-forward","clipboard-copy","map-pin-off","arrow-up-from-line","circle-chevron-up","wine-off","wine","circle-small","align-vertical-space-between","lamp-desk","circle-arrow-up","zap","beaker","timeline","panel-left-right-dashed","wifi-sync","paintbrush","sliders-vertical","broccoli","wifi-high","wifi","chevron-up","triangles-centerline-dashed-horizontal","whistle","pen-tool","database-check","wheat-off","form","pencil-ruler","dna","arrow-big-down-dash","chart-area","bug-off","wheat","weight-tilde","card-sim","weight","server-crash","map-pin-search","flask-round","eye-dashed","webcam-off","ellipse","spell-check","webcam","waypoints","popcorn","blocks","waves-vertical","layer-arrow-up","microchip","waves-ladder","badge-minus","cloud-sun","circle","shield-alert","waves-horizontal","phone-incoming","map-minus","waves-arrow-down","watch","separator-vertical","washing-machine","heart-minus","scan-square","ampersands","wand-sparkles","user-search","magnet","fence","wallpaper","square-user-round","wallet-minimal","wallet-cards","sunrise","strikethrough","calendar-days","folder-bookmark","wallet","banknote-arrow-up","layout-arrow-right","vote","dollar-sign","message-square-quote","volume-off","ruler-dimension-line","volume-1","list-minus","cloud-hail","volume","eye-closed","app-window-mac","volleyball","ellipsis","copy-check","clock-arrow-right","satellite","bookmark-plus","virus","folder-key","coffee","circle-power","ligature","hourglass","tickets-plane","folder-git","video","bomb","layers-2","battery-full","sparkle","line-dot-bottom-vertical","chart-gantt","folder-tree","command","badge-dollar-sign","align-start-vertical","briefcase-conveyor-belt","message-circle-question-mark","vibrate","bluetooth-off","venus-and-mars","square-square","cannabis","equal-approximately-not","book","grip-horizontal","circle-minus","audio-waveform","moon-star","arrow-down-narrow-wide","ghost","database-backup","wand","receipt-turkish-lira","vector-polygon","calendar-minus-2","copy-minus","vault","folder-input","book-image","badge-x","mouse-left","tag-plus","shirt","van","server-off","move-up","message-circle-dashed","utensils","plug-2","users-round","chess-rook","brackets","calendar-heart","list-ordered","users","star-x","mic-off","user-x","arrow-big-left","square-split-horizontal","triangle-alert","user-round-x","clover","sun-snow","sofa","user-round-search","handbag","funnel-x","map-pin","clock-2","calendar-fold","fish-off","baby","database-x","fold-vertical","user-round-group","hop","face-angry","user-round-cog","cigarette","calendar-chevrons-right","user-round-check","user-round-arrow-left","diamond-plus","refrigerator","file-chart-column","triangle-dashed","git-pull-request-closed","badge-check","user-minus","user-lock","layers-arrow-up","plug-zap","heading-4","chess-queen","graduation-cap","grid-3x2","zodiac-sagittarius","square-dashed-x-corner","square-dashed-bottom-code","clock-7","ethernet-port","scan-text","user-group","shower-head","equal-not","user-cog","move-down","clock-arrow-down","ticket-slash","ruler","settings-2","user","circle-user-round","usb-c-port","layers","list-filter","map-pin-check","egg-off","upload","cog","dog","unplug","swords","spotlight","panel-right-dashed","signal-zero","paper-bag","truck-electric","unlink","check-line","university","bubbles","bot","chart-bar-increasing","ungroup","playing-card","air-vent","unfold-vertical","dot","ice-cream-cone","mouth","file-symlink","clipboard-paste","chevron-last","book-heart","undo-2","circle-parking","globe-check","cloud-check","panel-left","circle-chevron-right","undo","underline","squares-unite","arrow-down-up","git-fork","forward","brain-circuit","between-vertical-start","database","panel-right","umbrella-off","type-outline","flower","log-out","git-branch-plus","clipboard-minus","file-text","trending-up","fire-extinguisher","fan","table-rows-split","milk-off","tv-minimal","cloud-upload","banknote","turntable","message-circle-dashed-check","drumstick","turkish-lira","calendar-search","tube-lotion","line-dot-top-vertical","bell-ring","circle-chevron-left","truck","arrow-down","arrow-up-down","folder-dot","trophy","case-lower","whole-word","monitor","disc-2","trending-up-down","folder-cog","user-shield","triangle","tv-minimal-play","circle-stop","align-vertical-space-around","switch-camera","tree-deciduous","square-chart-gantt","arrow-big-down","circle-parking-off","calendar-x-2","user-plus","move-diagonal-2","bandage","gallery-horizontal-end","panel-top-dashed","transgender","chess-bishop","tram-front","train-front-tunnel","train-front","refresh-cw-off","audio-lines","traffic-cone","tractor","toothbrush","tower-control","rocket","fish","ear-off","touchpad-off","save-check","touchpad","torus","printer","megaphone-off","tornado","arrow-big-right","section","file-clock","toothbrush-sparkles","toy-brick","square-chevron-down","dice-1","drill","app-window","robot-vacuum","hand-metal","tool-case","spell-check-2","toilet","squirrel","list-plus","toggle-left","rotate-ccw-key","timer-reset","chart-pie","paw-print","timer","copy-slash","wind","ticket-x","layout-panel-left","moon","circle-percent","ticket-minus","circle-arrow-out-down-right","square-x","italic","chart-column-increasing","layout-freeform","step-forward","message-square-diff","a-arrow-down","broom-sparkles","sticker","tic-tac-toe","move-left","thermometer-sun","thermometer-snowflake","thermometer","theater","import","badge-turkish-lira","square-terminal","file-music","logs","beef","faucet","file-user","text-quote","square-radical","lightbulb","image-upscale","book-type","text-cursor-input","signpost-big","text-cursor","cloudy","helicopter","square-percent","text-align-justify","navigation-off","arrow-left","car-taxi-front","text-align-end","mouth-off","chevrons-right-left","text-align-center","test-tubes","test-tube-diagonal","brick-wall-fire","square-stack","tent","square-dimensions","face-slightly-smiling","align-end-horizontal","layer-arrow-down","equal","megaphone","calendar-x","telescope","ice-cream-bowl","egg","tangent","save-off","ship-cargo","circle-pound-sterling","video-off","japanese-yen","tally-3","tag","tally-1","library","file-terminal","circle-chevron-down","accessibility","route","square-library","amphora","hourglass-cog","tally-2","tablets","tablet-smartphone","building-complex","remove-formatting","sheet","circle-check-big","table-properties","table-of-contents","map-pinned","corner-down-left","circuit-board","table-columns-split","table-cells-merge","table-2","table","folder-open-dot","book-dashed","syringe","lasso","bluetooth","tree-pine","receipt-indian-rupee","swiss-franc","shield-plus","sunset","sun-medium","sun-dim","can-soda","flask-conical","power","funnel","square-star","folder-sync","monitor-pc","zodiac-ophiuchus","subscript","stretch-vertical","arrow-up-narrow-wide","fishing-hook","stretch-horizontal","maximize-2","stone","frame","calendar-arrow-down","clock-12","star-minus","heart","sticky-note-x","images","lollipop","book-text","chart-no-axes-column-increasing","lamp-floor","file-plus-corner","image","equal-approximately","badge-euro","bike","angle","gap-vertical","sticky-note-check","sticky-note","stethoscope","step-back","star-off","option","banknote-check","scroll-text","server-plus","repeat","star","stamp","toggle-right","file-x","ferris-wheel","camera-off","squircle","search-slash","repeat-off","squares-exclude","square-user","group","square-text","battery","mic-audio-lines","tent-tree","square-split-vertical","rectangle-horizontal","spade","square-slash","screen-share-off","bitcoin","square-scissors","battery-plus","database-search","square-round-corner","file-diff","joystick","square-plus","square-play","spline-pointer","square-pilcrow","axis-3d","square-pi","message-square-share","binoculars","square-pause","calendar-range","square-parking","rose","euro","mail-minus","square-m","square-kanban","square-function","pyramid","clipboard-pen","bottle-wine","alarm-clock-off","square-equal","list","square-dot","square-arrow-right","dome","badge-pound-sterling","bookmark-check","square-divide","wrench-off","shopping-bag","a-arrow-up","clock-check","shrink","chevrons-down","vibrate-off","face-grinning","zodiac-cancer","square-code","file-code","square-chevron-up","carton-off","credit-card-reader","paintbrush-vertical","cassette-tape","battery-low","square-chevron-left","receipt-japanese-yen","signpost","snail","calendar-arrow-up","landmark","fish-symbol","trash-off","loader","bold","dice-2","file-type","clipboard-clock","beer","lectern","square-centerline-dashed-vertical","square-bottom-dashed-scissors","square-bookmark","binary","move-diagonal","square-asterisk","door-closed","square-arrow-up-right","layout-template","rows-4","piano","square-arrow-right-exit","bookmark-off","hand-heart","square-arrow-right-enter","scan-qr-code","message-square-check","square-arrow-out-up-right","square-arrow-out-up-left","monitor-play","brain","square-arrow-out-down-left","server-cog","square-arrow-down-right","key","clock-11","gap-horizontal","ticket-plus","arrow-up-0-1","bell-electric","square","heading","book-open-check","panel-top-close","lasso-select","sprout","spray-can","sport-shoe","shield-off","bus","search-alert","audio-lines-x","chart-no-axes-gantt","file-spreadsheet","percent","clipboard-list","speech","contact-round","speaker","keyboard-off","sparkles","file-badge","battery-warning","mail-question-mark","arrow-down-from-line","briefcase","biohazard","rectangle-circle","braces","scale-3d","panel-top-bottom-dashed","mail-x","square-dashed-mouse-pointer","square-sparkles","lock-open","file-play","pizza","list-indent-decrease","arrow-up-wide-narrow","soup","clock-5","solar-panel","rotate-ccw","align-horizontal-justify-center","soap-dispenser-droplet","antenna","memory-stick","scan-eye","snowflake","square-check","heart-plus","smartphone-nfc","map-pin-minus-inside","git-merge","gallery-vertical-end","square-dashed-plus","hand-coins","zodiac-capricorn","wifi-low","sliders-horizontal","clock","file-pen","git-compare-arrows","cloud-sun-rain","align-horizontal-justify-start","power-off","mail-badge","skull","calendar-plus","siren","arrow-down-z-a","bath","signature","unlink-2","signal-medium","shopping-cart-minus","folder-check","signal-low","book-key","ribbon","microwave","calculator","gallery-vertical","sigma","shuffle","square-dashed-text","map-pin-pen","move-up-left","shrimp","folder-heart","hard-drive-upload","monitor-speaker","shopping-cart-plus","arrow-up-a-z","package","square-dashed-top-solid","ship-wheel","shield-user","shield-question-mark","swatch-book","receipt-cent","spool","folder-archive","folder-symlink","can","ban","message-square-x","paint-roller","git-pull-request-draft","archive","shield-lock","shield-keyhole","shield-half","circle-slash-2","shield-cog-corner","cake","cloud-rain","chart-bar","shield-cog","wrench","shield-ban","shield","shelving-unit","flag-triangle-right","shell","gamepad-directional","bell","share","shapes","music-3","chart-bar-big","user-check","proportions","settings","plane","webhook-off","carrot","square-arrow-left","file-cog","circle-dashed","server","send-horizontal","search-x","germ","squares-subtract","search-code","dices","split","list-sort-descending","search","forklift","scroll","alarm-clock-minus","heart-x","eraser","square-sigma","screen-share","bluetooth-connected","rotate-ccw-square","chart-no-axes-column","cannabis-off","folder-kanban","lighthouse","mars-stroke","roller-coaster","school","scan-search","file-box","pickaxe","paint-bucket","glass-water","mic","glasses","piggy-bank","scan-face","cuboid","cloud-off","check-check","activity","axe","plane-takeoff","scan-box","cloud-rain-wind","scan-barcode","scan","copy-x","file-axis-3d","radical","chart-column-decreasing","play-off","bug-play","align-vertical-distribute-start","save-plus","waves-arrow-up","tally-5","headset","save","saudi-riyal","circle-divide","satellite-dish","sandwich","salad","life-buoy","sailboat","external-link","volume-2","battery-charging","russian-ruble","square-arrow-up-left","brick-wall-shield","footprints","rows-3","building","rows-2","router","route-off","tag-x","book-alert","link-2","astroid","bell-minus","image-up","closed-caption","drum","arrow-up-z-a","sun","rotate-cw-fading-clock","rotate-cw-clock","file-key","rotate-ccw-clock","rotate-3d","scissors-line-dashed","house-wifi","robot-arm","rewind","ticket-check","combine","reply","replace-all","mountain","mars","picture-in-picture-2","radio-off","flower-2","replace","squares-intersect","repeat-2","repeat-1","keyboard-music","star-half","playing-cards-fan","code-xml","pencil-line","mails","brain-cog","tablet","regex","pi","trash","book-down","hdmi-port","trailer","case-upper","circle-fading-arrow-up","refresh-cw","croissant","phone","computer","barcode","pin","redo","bed","circle-arrow-right","divide","grape","rectangle-vertical","party-popper","file-chart-pie","rectangle-goggles","file-x-corner","dice-6","receipt-swiss-franc","blender","receipt-russian-ruble","zap-off","square-check-big","receipt-euro","receipt","ratio","laptop-minimal","rat","rainbow","map-pin-minus","omega","chart-spline","message-square-more","radio-receiver","chart-candlestick","radio","arrow-down-a-z","radiation","radar","move-horizontal","file-sliders","quote","square-exclamation-point","cup-soda","puzzle","projector","sword","printer-check","map-pin-x","earth","slice","dice-3","milk","mouse-pointer-ban","crown","circle-slash","circle-star","rotate-cw-square","atom","package-x","bed-double","pound-sterling","circle-dot","file-exclamation-point","hand-fist","message-circle-code","folder-git-2","message-square-code","popsicle","towel-rack","layout-grid","arrow-big-left-dash","plus","dumbbell","plug","playing-cards","houses","scale","play","flashlight","panel-top-open","plane-landing","pin-off","notebook","redo-2","pill","square-menu","pilcrow-left","monitor-smartphone","laptop","scan-line","clock-4","square-arrow-up","book-minus","file-question-mark","chevrons-left-right","phone-off","save-pen","arrow-down-to-line","phone-forwarded","refresh-ccw","venetian-mask","calendar-check-2","phi","spline","banknote-x","git-pull-request-create-arrow","pentagon","circle-check","pencil-off","caravan","pen-off","pen-line","hand-platter","pc-case","timer-off","arrow-big-right-dash","bed-single","parasol","paperclip","backpack","calendar-minus","panels-left-bottom","panel-top","panel-right-open","mic-signal","arrow-down-right","panel-right-close","letters","wifi-zero","panel-left-open","panel-left-dashed","map-pin-plus","hard-drive-download","image-off","panel-bottom-close","panel-bottom","panda","engine","square-chevron-right","mail-search","package-search","bone-fracture","package-plus","package-open","crop","package-2","lambda","ampersand","ad","shopping-cart","align-vertical-justify-end","origami","alarm-smoke","orbit","file-input","clock-8","hand-grab","cloud-cog","blend","hd","radio-tower","list-tree","droplet","line-squiggle","eye","octagon-pause","square-dashed-x","banana","gpu","message-square-heart","nut-off","circle-equal","face-slightly-frowning","nut","notepad-text-dashed","notepad-text","text-initial","arrow-up-right","maximize","leafy-green","message-square-dot","file-chart-line","columns-3-cog","newspaper","network","minimize-2","nepali-rupee","navigation-2","cone","navigation","file-image","music-2","palette","barrel","gallery-thumbnails","move-up-right","cpu","move-right","thumbs-down","merge","hamburger","move-down-right","hat-glasses","code","move-down-left","move-3d","mail-check","mouse-pointer","carton","mouse-off","kanban","bone","apple","rocking-chair","bot-off","circle-arrow-out-down-left","database-arrow-down","folder","circle-arrow-out-up-left","mop","cable-car","arrow-down-left","square-activity","message-square-text","cigarette-off","monitor-up","message-circle","circle-arrow-out-up-right","car-battery","monitor-stop","fold-horizontal","shovel","calendar-1","cloud-moon","square-arrow-out-down-right","monitor-pause","clock-plus","circle-euro","cloud-snow","anvil","arrow-big-up-dash","monitor-off","log-in","monitor-dot","monitor-cog","monitor-check","list-checks","chevrons-down-up","clipboard-plus","circle-x","list-end","minus","list-collapse","chevrons-right","audio-lines-off","message-square-reply","corner-down-right","milestone","summary","lamp-wall-down","mic-vocal","layout-arrow-down","ellipsis-vertical","globe-off","square-stop","arrow-up-1-0","align-horizontal-justify-end","scan-heart","align-vertical-distribute-end","heart-crack","airplay","case-sensitive","messages-circle","message-square-warning","monitor-x","bell-check","database-minus","square-pen","message-square-plus","message-square-lock","dice-5","octagon","ticket","folder-lock","message-circle-off","briefcase-plus","bookmark","message-circle-heart","utility-pole","message-circle-check","chart-bar-decreasing","database-plus","calendar-sync","funnel-plus","store","circle-arrow-down","notebook-pen","egg-fried","compass","keyboard","corner-right-up","map-pin-x-inside","printer-3d","user-round-plus","panel-left-close","crosshair","pilcrow-right","user-round-minus","mailbox","indian-rupee","mail-plus","mail-pen","bell-off","mail-clock","mouse-pointer-2-off","drone","slash","credit-card-x","aperture","arrow-right-left","mail","vector-square","circle-gauge","circle-alert","check","text-search","arrow-down-to-dot","monitor-down","lock-keyhole-open","chef-hat","lock-keyhole","lock","file-archive","signal-high","inbox","locate-fixed","locate","image-play","align-horizontal-space-between","loader-pinwheel","calendar-check","database-zap","droplets","loader-circle","broom","corner-right-down","layout-list","file-search","list-video","alarm-clock-plus","circle-dollar-sign","usb","house","receipt-pound-sterling","list-music","list-indent-increase","id-card","mouse","minimize","list-clock","list-chevrons-up-down","galaxy","list-chevrons-down-up","book-x","mirror-rectangular","list-check","link-2-off","link","headphone-off","asterisk","line-style","octagon-x","languages","line-dot-right-horizontal","alarm-clock-check","guitar","dock","beer-off","scooter","square-parking-off","notebook-text","arrow-right-to-line","clef-treble","tally-4","zodiac-taurus","leaf","door-open","flag-triangle-left","grid-3x3","file","layout-panel-top","pocket-knife","book-copy","castle","car-front","clock-alert","reply-all","cloud-moon-rain","clipboard-type","layout-dashboard","list-todo","printer-x","bird","list-start","lamp-wall-up","a-large-small","lamp-ceiling","lamp","map-plus","key-square","file-chart-column-increasing","kayak","database-arrow-up","arrow-right-from-line","flame-kindling","square-power","iv-bag","bring-to-front","iteration-cw","iteration-ccw","bell-plus","inspection-panel","info","infinity","folders","mail-warning","image-plus","image-minus","id-card-lanyard","bridge","chart-line","file-lock","cast","circle-fading-plus","clock-10","undo-dot","target","list-filter-plus","house-plug","drama","house-heart","baseline","martini","contrast","hotel","candy-off","hospital","book-check","heart-off","book-lock","highlighter","briefcase-medical","calendars","text-align-start","heart-pulse","hop-off","warehouse","sticky-notes","drafting-compass","save-all","file-braces","heading-6","heading-5","heading-3","heading-2","fishing-rod","book-headphones","credit-card","heading-1","haze","hard-hat","shredder","panel-bottom-open","door-closed-package","eject","credit-card-check","balloon","map-pin-plus-inside","bookmark-x","badge-question-mark","pen","hand","candy-cane","hammer","grip","gamepad-2","file-type-corner","grid-2x2-check","grid-2x2","globe-x","shield-minus","circle-off","dessert","eclipse","church","git-pull-request-create","cylinder","badge-japanese-yen","columns-3","receipt-text","git-merge-conflict","git-compare","git-commit-vertical","git-commit-horizontal","file-output","disc-album","circle-ellipsis","arrow-down-0-1","captions","git-branch","gift","philippine-peso","badge-alert","gem","folder-pen","cross","gauge","chevron-right","sticky-note-minus","square-arrow-down-left","share-2","gamepad","fullscreen","fuel","folder-up","folder-search-2","folder-root","chess-pawn","folder-open","briefcase-business","folder-minus","message-circle-reply","cloud-sync","triangle-right","folder-clock","folder-closed","mop-sparkles","type","webhook","flask-conical-off","align-horizontal-distribute-start","flashlight-off","flag-off","pointer-off","turtle","camera","fingerprint-pattern","film","git-pull-request","bluetooth-searching","arrow-up-to-line","squircle-dashed","clock-3","badge-percent","face-expressionless","file-video-camera","file-up","grid-2x2-plus","file-stack","box","file-search-corner","clock-1","file-heart","house-cog","space","file-minus-corner","file-minus","file-digit","corner-up-left","clock-6","zodiac-scorpio","key-round","headphones","tv","factory","face-neutral","rss","expand","at-sign","map-pin-check-inside","sticky-note-off","music","handshake","earth-lock","circle-user","copy-plus","droplet-off","virus-off","line-dot-left-horizontal","disc","diff","search-check","clipboard-check","columns-2","diamond-minus","clipboard","align-center-vertical","diameter","delete","club","cloud-fog","mosque","currency","map-pin-house","package-check","chevron-first","pencil","boxes","list-x","copyright","copyleft","corner-up-right","cookie","clock-arrow-left","container","contact","badge-indian-rupee","construction","redo-dot","component","align-start-horizontal","chart-column-stacked","file-plus","git-pull-request-arrow","coins","decimals-arrow-right","bell-dot","folder-down","cloud-drizzle","cloud-backup","align-horizontal-space-around","door-closed-locked","clock-9","diamond","blinds","clapperboard","circle-play","book-search","git-branch-minus","circle-dashed-check","recycle","mountain-snow","luggage","chevrons-left-right-ellipsis","bot-message-square","phone-outgoing","smartphone-charging","chevron-left","train-track","cherry","chart-bar-stacked","sticky-note-plus","chart-no-axes-column-decreasing","chart-network","chart-column-big","chart-no-axes-combined","metronome","triangles-centerline-dashed-vertical","arrow-down-1-0","credit-card-minus","candy","arrow-left-right","lightbulb-off","panels-top-left","beef-off","locate-off","bug","test-tube","brick-wall","cooking-pot","boom-box","book-up","book-plus","laptop-minimal-check","mail-open","park","baggage-claim","variable","arrow-right","archive-restore"},{"rbxassetid://104502745253902","rbxassetid://89421818506275"},{[48]={{1,{24,24},{175,0}},{1,{24,24},{650,0}},{1,{24,24},{850,250}},{2,{24,24},{150,0}},{1,{24,24},{250,700}},{1,{24,24},{600,225}},{1,{24,24},{575,800}},{2,{24,24},{225,225}},{1,{24,24},{50,350}},{1,{24,24},{675,25}},{1,{24,24},{500,425}},{1,{24,24},{50,400}},{1,{24,24},{75,925}},{1,{24,24},{825,50}},{1,{24,24},{50,75}},{1,{24,24},{175,800}},{1,{24,24},{375,925}},{1,{24,24},{850,450}},{1,{24,24},{325,50}},{1,{24,24},{100,325}},{1,{24,24},{650,225}},{1,{24,24},{950,475}},{1,{24,24},{725,300}},{1,{24,24},{425,125}},{1,{24,24},{650,850}},{1,{24,24},{50,375}},{1,{24,24},{550,425}},{2,{24,24},{50,125}},{1,{24,24},{25,725}},{1,{24,24},{300,200}},{1,{24,24},{825,500}},{1,{24,24},{300,575}},{1,{24,24},{500,800}},{1,{24,24},{950,225}},{1,{24,24},{525,925}},{1,{24,24},{500,375}},{1,{24,24},{775,525}},{1,{24,24},{100,100}},{1,{24,24},{900,100}},{2,{24,24},{200,50}},{1,{24,24},{325,125}},{2,{24,24},{100,400}},{1,{24,24},{175,550}},{1,{24,24},{175,975}},{1,{24,24},{75,650}},{1,{24,24},{100,825}},{1,{24,24},{225,375}},{1,{24,24},{525,700}},{1,{24,24},{500,675}},{2,{24,24},{225,200}},{1,{24,24},{500,825}},{1,{24,24},{75,350}},{1,{24,24},{325,325}},{1,{24,24},{50,475}},{1,{24,24},{775,375}},{1,{24,24},{600,675}},{1,{24,24},{450,50}},{1,{24,24},{900,25}},{1,{24,24},{300,350}},{1,{24,24},{775,900}},{1,{24,24},{775,925}},{2,{24,24},{50,50}},{1,{24,24},{750,800}},{2,{24,24},{175,325}},{1,{24,24},{25,975}},{1,{24,24},{750,475}},{1,{24,24},{250,600}},{1,{24,24},{250,75}},{1,{24,24},{425,450}},{1,{24,24},{925,725}},{1,{24,24},{725,550}},{1,{24,24},{875,575}},{1,{24,24},{650,350}},{1,{24,24},{100,175}},{1,{24,24},{800,725}},{2,{24,24},{250,25}},{1,{24,24},{100,450}},{2,{24,24},{225,300}},{1,{24,24},{550,675}},{2,{24,24},{0,450}},{1,{24,24},{350,975}},{2,{24,24},{25,300}},{1,{24,24},{250,125}},{1,{24,24},{50,525}},{1,{24,24},{100,75}},{1,{24,24},{275,550}},{1,{24,24},{525,675}},{1,{24,24},{775,300}},{1,{24,24},{550,975}},{1,{24,24},{700,225}},{1,{24,24},{150,650}},{1,{24,24},{150,100}},{2,{24,24},{375,100}},{1,{24,24},{575,625}},{1,{24,24},{75,775}},{1,{24,24},{700,300}},{1,{24,24},{300,675}},{1,{24,24},{775,475}},{1,{24,24},{475,275}},{1,{24,24},{950,375}},{1,{24,24},{350,425}},{1,{24,24},{250,100}},{1,{24,24},{750,0}},{2,{24,24},{325,100}},{1,{24,24},{50,225}},{1,{24,24},{75,400}},{1,{24,24},{450,725}},{1,{24,24},{550,725}},{1,{24,24},{250,350}},{1,{24,24},{250,750}},{1,{24,24},{575,225}},{2,{24,24},{350,0}},{1,{24,24},{75,900}},{1,{24,24},{125,550}},{1,{24,24},{100,525}},{1,{24,24},{75,325}},{1,{24,24},{350,350}},{1,{24,24},{650,825}},{1,{24,24},{200,0}},{1,{24,24},{575,400}},{1,{24,24},{400,300}},{1,{24,24},{700,600}},{1,{24,24},{525,50}},{1,{24,24},{550,75}},{1,{24,24},{200,200}},{1,{24,24},{800,900}},{1,{24,24},{950,875}},{1,{24,24},{300,500}},{1,{24,24},{150,775}},{1,{24,24},{950,200}},{1,{24,24},{100,275}},{1,{24,24},{525,500}},{2,{24,24},{0,200}},{1,{24,24},{500,50}},{1,{24,24},{425,250}},{1,{24,24},{200,925}},{1,{24,24},{325,225}},{1,{24,24},{875,100}},{1,{24,24},{75,150}},{2,{24,24},{100,175}},{1,{24,24},{775,575}},{1,{24,24},{475,300}},{1,{24,24},{450,525}},{1,{24,24},{375,100}},{2,{24,24},{325,25}},{1,{24,24},{175,600}},{1,{24,24},{300,750}},{1,{24,24},{375,475}},{2,{24,24},{150,275}},{1,{24,24},{750,650}},{1,{24,24},{575,650}},{1,{24,24},{0,100}},{1,{24,24},{550,50}},{1,{24,24},{475,750}},{1,{24,24},{850,0}},{2,{24,24},{100,350}},{2,{24,24},{50,25}},{1,{24,24},{300,325}},{1,{24,24},{550,775}},{2,{24,24},{200,100}},{1,{24,24},{325,250}},{1,{24,24},{75,475}},{1,{24,24},{500,450}},{1,{24,24},{25,675}},{1,{24,24},{825,275}},{1,{24,24},{50,425}},{1,{24,24},{75,600}},{1,{24,24},{775,600}},{1,{24,24},{25,325}},{1,{24,24},{125,225}},{1,{24,24},{250,625}},{1,{24,24},{50,450}},{1,{24,24},{125,575}},{2,{24,24},{375,50}},{1,{24,24},{25,900}},{2,{24,24},{25,400}},{1,{24,24},{275,50}},{1,{24,24},{125,175}},{1,{24,24},{50,125}},{1,{24,24},{250,800}},{1,{24,24},{500,775}},{1,{24,24},{925,625}},{1,{24,24},{0,900}},{1,{24,24},{0,425}},{1,{24,24},{25,100}},{1,{24,24},{450,375}},{1,{24,24},{500,75}},{1,{24,24},{900,325}},{1,{24,24},{0,875}},{1,{24,24},{350,25}},{1,{24,24},{525,825}},{1,{24,24},{400,900}},{1,{24,24},{325,450}},{1,{24,24},{200,750}},{1,{24,24},{350,200}},{1,{24,24},{400,100}},{1,{24,24},{950,675}},{1,{24,24},{25,650}},{2,{24,24},{75,375}},{1,{24,24},{200,400}},{1,{24,24},{150,500}},{1,{24,24},{750,950}},{1,{24,24},{300,925}},{1,{24,24},{450,800}},{1,{24,24},{450,25}},{1,{24,24},{75,50}},{2,{24,24},{50,200}},{1,{24,24},{475,500}},{1,{24,24},{725,625}},{1,{24,24},{225,825}},{1,{24,24},{325,500}},{1,{24,24},{75,300}},{1,{24,24},{375,775}},{1,{24,24},{0,800}},{1,{24,24},{625,525}},{1,{24,24},{875,75}},{1,{24,24},{650,500}},{1,{24,24},{350,775}},{1,{24,24},{875,350}},{1,{24,24},{75,225}},{1,{24,24},{25,300}},{1,{24,24},{175,100}},{2,{24,24},{50,325}},{1,{24,24},{800,275}},{2,{24,24},{250,300}},{1,{24,24},{775,425}},{1,{24,24},{800,425}},{2,{24,24},{275,275}},{1,{24,24},{900,625}},{1,{24,24},{400,500}},{1,{24,24},{700,125}},{1,{24,24},{700,200}},{1,{24,24},{175,575}},{1,{24,24},{125,100}},{2,{24,24},{300,250}},{1,{24,24},{950,725}},{1,{24,24},{625,575}},{1,{24,24},{325,400}},{1,{24,24},{275,450}},{1,{24,24},{950,350}},{1,{24,24},{725,350}},{2,{24,24},{300,150}},{1,{24,24},{850,975}},{1,{24,24},{475,400}},{1,{24,24},{325,375}},{1,{24,24},{725,425}},{2,{24,24},{150,250}},{1,{24,24},{100,675}},{2,{24,24},{400,150}},{1,{24,24},{875,0}},{2,{24,24},{75,325}},{1,{24,24},{75,550}},{2,{24,24},{75,425}},{1,{24,24},{300,600}},{1,{24,24},{700,775}},{1,{24,24},{50,50}},{1,{24,24},{750,425}},{2,{24,24},{450,100}},{2,{24,24},{475,75}},{2,{24,24},{50,475}},{1,{24,24},{725,800}},{1,{24,24},{675,800}},{1,{24,24},{825,750}},{1,{24,24},{975,700}},{2,{24,24},{125,400}},{2,{24,24},{150,375}},{1,{24,24},{575,475}},{2,{24,24},{450,75}},{1,{24,24},{175,775}},{1,{24,24},{75,450}},{1,{24,24},{625,925}},{2,{24,24},{250,275}},{1,{24,24},{400,75}},{1,{24,24},{275,950}},{1,{24,24},{775,125}},{1,{24,24},{650,150}},{1,{24,24},{700,475}},{1,{24,24},{525,625}},{1,{24,24},{725,775}},{2,{24,24},{325,200}},{1,{24,24},{400,250}},{2,{24,24},{350,175}},{2,{24,24},{175,200}},{1,{24,24},{600,950}},{1,{24,24},{225,475}},{1,{24,24},{600,525}},{1,{24,24},{100,200}},{1,{24,24},{550,125}},{2,{24,24},{400,125}},{2,{24,24},{375,150}},{1,{24,24},{600,100}},{1,{24,24},{0,175}},{1,{24,24},{700,350}},{1,{24,24},{0,650}},{2,{24,24},{175,350}},{1,{24,24},{100,300}},{2,{24,24},{75,200}},{1,{24,24},{300,950}},{2,{24,24},{50,450}},{1,{24,24},{550,700}},{1,{24,24},{900,675}},{1,{24,24},{150,375}},{2,{24,24},{150,350}},{2,{24,24},{475,50}},{1,{24,24},{525,125}},{2,{24,24},{150,200}},{2,{24,24},{225,275}},{1,{24,24},{375,900}},{1,{24,24},{475,325}},{2,{24,24},{275,225}},{1,{24,24},{750,200}},{1,{24,24},{975,325}},{1,{24,24},{575,250}},{1,{24,24},{50,175}},{1,{24,24},{175,425}},{1,{24,24},{0,525}},{2,{24,24},{250,250}},{2,{24,24},{325,175}},{1,{24,24},{500,100}},{2,{24,24},{300,200}},{1,{24,24},{575,900}},{1,{24,24},{500,625}},{1,{24,24},{775,150}},{1,{24,24},{275,575}},{2,{24,24},{425,75}},{1,{24,24},{650,200}},{1,{24,24},{875,725}},{2,{24,24},{400,100}},{2,{24,24},{450,50}},{1,{24,24},{475,850}},{1,{24,24},{200,250}},{2,{24,24},{475,25}},{1,{24,24},{350,700}},{1,{24,24},{775,400}},{2,{24,24},{0,475}},{1,{24,24},{75,275}},{1,{24,24},{550,200}},{1,{24,24},{450,250}},{1,{24,24},{775,725}},{2,{24,24},{25,450}},{1,{24,24},{725,575}},{1,{24,24},{750,375}},{2,{24,24},{75,400}},{2,{24,24},{100,375}},{1,{24,24},{625,850}},{2,{24,24},{125,350}},{1,{24,24},{225,775}},{1,{24,24},{650,800}},{1,{24,24},{150,50}},{2,{24,24},{200,275}},{2,{24,24},{200,225}},{1,{24,24},{250,850}},{1,{24,24},{800,75}},{2,{24,24},{225,250}},{1,{24,24},{875,900}},{2,{24,24},{275,200}},{2,{24,24},{300,175}},{2,{24,24},{100,0}},{2,{24,24},{0,25}},{1,{24,24},{50,500}},{1,{24,24},{600,325}},{2,{24,24},{250,225}},{1,{24,24},{50,325}},{1,{24,24},{150,900}},{2,{24,24},{325,150}},{1,{24,24},{500,325}},{1,{24,24},{325,825}},{2,{24,24},{400,75}},{1,{24,24},{750,675}},{2,{24,24},{450,25}},{1,{24,24},{950,150}},{1,{24,24},{0,725}},{2,{24,24},{350,125}},{1,{24,24},{300,550}},{1,{24,24},{225,0}},{2,{24,24},{475,0}},{1,{24,24},{600,250}},{1,{24,24},{600,175}},{1,{24,24},{350,375}},{1,{24,24},{575,850}},{1,{24,24},{250,250}},{2,{24,24},{25,425}},{1,{24,24},{275,650}},{1,{24,24},{325,425}},{1,{24,24},{700,0}},{1,{24,24},{650,425}},{1,{24,24},{825,200}},{2,{24,24},{125,150}},{1,{24,24},{375,550}},{2,{24,24},{125,325}},{1,{24,24},{25,425}},{1,{24,24},{325,725}},{1,{24,24},{250,150}},{1,{24,24},{600,975}},{1,{24,24},{550,525}},{1,{24,24},{525,100}},{1,{24,24},{925,25}},{1,{24,24},{125,625}},{1,{24,24},{200,150}},{1,{24,24},{0,150}},{1,{24,24},{275,250}},{1,{24,24},{700,450}},{2,{24,24},{175,275}},{1,{24,24},{150,300}},{2,{24,24},{250,200}},{1,{24,24},{800,950}},{1,{24,24},{75,500}},{1,{24,24},{550,300}},{1,{24,24},{350,150}},{1,{24,24},{200,775}},{1,{24,24},{225,450}},{1,{24,24},{50,275}},{1,{24,24},{900,300}},{1,{24,24},{0,250}},{1,{24,24},{125,825}},{1,{24,24},{500,300}},{2,{24,24},{175,300}},{1,{24,24},{850,525}},{2,{24,24},{350,100}},{1,{24,24},{575,0}},{1,{24,24},{575,200}},{2,{24,24},{375,75}},{1,{24,24},{325,600}},{1,{24,24},{200,275}},{1,{24,24},{275,100}},{1,{24,24},{700,500}},{2,{24,24},{125,50}},{1,{24,24},{775,750}},{2,{24,24},{425,25}},{1,{24,24},{550,925}},{1,{24,24},{925,300}},{1,{24,24},{825,325}},{2,{24,24},{0,425}},{1,{24,24},{675,650}},{2,{24,24},{75,350}},{1,{24,24},{0,625}},{1,{24,24},{500,25}},{1,{24,24},{0,550}},{1,{24,24},{900,200}},{2,{24,24},{50,375}},{1,{24,24},{975,875}},{1,{24,24},{875,300}},{2,{24,24},{125,300}},{1,{24,24},{250,0}},{1,{24,24},{850,900}},{2,{24,24},{250,100}},{2,{24,24},{250,175}},{1,{24,24},{425,325}},{2,{24,24},{25,50}},{1,{24,24},{725,850}},{2,{24,24},{275,150}},{1,{24,24},{800,200}},{1,{24,24},{600,350}},{1,{24,24},{425,700}},{1,{24,24},{625,100}},{1,{24,24},{25,525}},{1,{24,24},{200,700}},{1,{24,24},{325,25}},{1,{24,24},{375,425}},{1,{24,24},{650,275}},{2,{24,24},{400,25}},{1,{24,24},{925,100}},{1,{24,24},{200,650}},{2,{24,24},{425,0}},{1,{24,24},{225,425}},{1,{24,24},{125,425}},{2,{24,24},{0,400}},{2,{24,24},{25,375}},{1,{24,24},{125,675}},{1,{24,24},{475,900}},{1,{24,24},{575,300}},{2,{24,24},{225,125}},{1,{24,24},{775,200}},{1,{24,24},{225,125}},{2,{24,24},{100,300}},{2,{24,24},{125,275}},{1,{24,24},{275,775}},{1,{24,24},{650,675}},{1,{24,24},{450,550}},{1,{24,24},{25,600}},{1,{24,24},{400,575}},{1,{24,24},{250,725}},{2,{24,24},{375,175}},{1,{24,24},{825,850}},{1,{24,24},{675,975}},{1,{24,24},{500,225}},{1,{24,24},{425,425}},{1,{24,24},{625,825}},{2,{24,24},{175,225}},{1,{24,24},{600,925}},{1,{24,24},{500,350}},{2,{24,24},{200,200}},{1,{24,24},{300,900}},{1,{24,24},{400,325}},{2,{24,24},{200,75}},{1,{24,24},{725,700}},{1,{24,24},{975,525}},{2,{24,24},{100,325}},{1,{24,24},{525,175}},{2,{24,24},{275,125}},{1,{24,24},{200,850}},{1,{24,24},{125,950}},{1,{24,24},{700,425}},{1,{24,24},{725,125}},{2,{24,24},{300,100}},{1,{24,24},{300,450}},{1,{24,24},{525,300}},{2,{24,24},{325,75}},{2,{24,24},{75,50}},{1,{24,24},{725,875}},{1,{24,24},{950,325}},{1,{24,24},{775,775}},{1,{24,24},{675,600}},{2,{24,24},{75,275}},{2,{24,24},{350,50}},{1,{24,24},{225,400}},{2,{24,24},{400,0}},{1,{24,24},{25,500}},{1,{24,24},{100,400}},{1,{24,24},{100,500}},{2,{24,24},{0,375}},{1,{24,24},{750,575}},{1,{24,24},{75,0}},{2,{24,24},{25,350}},{1,{24,24},{300,525}},{1,{24,24},{600,425}},{1,{24,24},{450,750}},{1,{24,24},{600,300}},{1,{24,24},{150,550}},{1,{24,24},{600,50}},{1,{24,24},{225,250}},{2,{24,24},{125,250}},{1,{24,24},{150,525}},{1,{24,24},{600,375}},{1,{24,24},{125,600}},{1,{24,24},{275,975}},{1,{24,24},{575,100}},{2,{24,24},{75,300}},{2,{24,24},{150,225}},{1,{24,24},{900,900}},{1,{24,24},{200,75}},{1,{24,24},{900,75}},{1,{24,24},{725,225}},{1,{24,24},{475,50}},{1,{24,24},{25,400}},{1,{24,24},{325,475}},{1,{24,24},{900,375}},{2,{24,24},{200,175}},{2,{24,24},{250,125}},{1,{24,24},{725,200}},{1,{24,24},{350,750}},{1,{24,24},{50,900}},{1,{24,24},{175,525}},{1,{24,24},{550,350}},{2,{24,24},{275,75}},{1,{24,24},{225,675}},{1,{24,24},{0,850}},{2,{24,24},{50,100}},{1,{24,24},{650,525}},{2,{24,24},{300,75}},{1,{24,24},{500,250}},{1,{24,24},{400,0}},{2,{24,24},{375,0}},{1,{24,24},{850,300}},{1,{24,24},{50,775}},{2,{24,24},{0,350}},{1,{24,24},{425,150}},{2,{24,24},{25,325}},{1,{24,24},{475,600}},{1,{24,24},{150,275}},{1,{24,24},{600,75}},{2,{24,24},{50,300}},{1,{24,24},{125,150}},{1,{24,24},{150,150}},{1,{24,24},{450,475}},{2,{24,24},{100,250}},{1,{24,24},{400,200}},{2,{24,24},{200,300}},{1,{24,24},{925,275}},{1,{24,24},{725,100}},{2,{24,24},{300,50}},{1,{24,24},{475,450}},{2,{24,24},{175,250}},{2,{24,24},{175,175}},{2,{24,24},{325,50}},{1,{24,24},{550,150}},{1,{24,24},{25,150}},{2,{24,24},{125,0}},{2,{24,24},{50,275}},{1,{24,24},{875,775}},{1,{24,24},{25,200}},{1,{24,24},{175,500}},{1,{24,24},{375,200}},{2,{24,24},{50,350}},{1,{24,24},{400,800}},{1,{24,24},{125,250}},{1,{24,24},{525,425}},{1,{24,24},{825,450}},{2,{24,24},{125,200}},{1,{24,24},{125,500}},{2,{24,24},{150,175}},{2,{24,24},{225,100}},{2,{24,24},{200,125}},{1,{24,24},{525,850}},{1,{24,24},{75,250}},{2,{24,24},{275,50}},{2,{24,24},{300,25}},{2,{24,24},{150,150}},{2,{24,24},{0,300}},{1,{24,24},{675,725}},{1,{24,24},{150,750}},{1,{24,24},{0,825}},{2,{24,24},{75,225}},{1,{24,24},{500,925}},{2,{24,24},{50,250}},{2,{24,24},{100,200}},{1,{24,24},{900,450}},{1,{24,24},{175,950}},{2,{24,24},{125,175}},{1,{24,24},{200,50}},{1,{24,24},{750,725}},{1,{24,24},{450,425}},{2,{24,24},{175,125}},{2,{24,24},{325,0}},{1,{24,24},{800,850}},{1,{24,24},{75,725}},{1,{24,24},{200,625}},{1,{24,24},{200,25}},{1,{24,24},{700,700}},{1,{24,24},{875,125}},{2,{24,24},{225,75}},{1,{24,24},{900,700}},{2,{24,24},{250,50}},{1,{24,24},{825,975}},{1,{24,24},{875,225}},{2,{24,24},{300,0}},{1,{24,24},{525,875}},{2,{24,24},{25,250}},{1,{24,24},{325,300}},{1,{24,24},{475,800}},{2,{24,24},{0,275}},{1,{24,24},{525,250}},{2,{24,24},{425,100}},{2,{24,24},{175,100}},{1,{24,24},{950,125}},{1,{24,24},{875,325}},{1,{24,24},{100,575}},{2,{24,24},{275,0}},{1,{24,24},{100,550}},{1,{24,24},{825,950}},{1,{24,24},{150,875}},{1,{24,24},{600,25}},{1,{24,24},{100,950}},{1,{24,24},{900,950}},{1,{24,24},{500,650}},{1,{24,24},{0,0}},{1,{24,24},{125,400}},{1,{24,24},{975,900}},{2,{24,24},{25,225}},{1,{24,24},{250,950}},{2,{24,24},{125,125}},{2,{24,24},{150,100}},{2,{24,24},{100,150}},{2,{24,24},{175,75}},{1,{24,24},{300,725}},{1,{24,24},{300,75}},{1,{24,24},{925,850}},{1,{24,24},{50,825}},{1,{24,24},{325,775}},{1,{24,24},{375,50}},{1,{24,24},{850,25}},{1,{24,24},{450,450}},{2,{24,24},{250,0}},{1,{24,24},{750,975}},{1,{24,24},{600,475}},{1,{24,24},{375,650}},{1,{24,24},{475,25}},{2,{24,24},{50,175}},{1,{24,24},{700,850}},{2,{24,24},{25,200}},{1,{24,24},{450,300}},{1,{24,24},{50,950}},{1,{24,24},{900,825}},{2,{24,24},{100,125}},{1,{24,24},{700,525}},{1,{24,24},{25,250}},{1,{24,24},{575,25}},{2,{24,24},{125,100}},{1,{24,24},{475,725}},{1,{24,24},{375,275}},{2,{24,24},{150,75}},{2,{24,24},{175,50}},{2,{24,24},{225,0}},{1,{24,24},{400,125}},{1,{24,24},{775,975}},{2,{24,24},{25,175}},{1,{24,24},{750,925}},{1,{24,24},{50,800}},{1,{24,24},{100,25}},{1,{24,24},{375,675}},{1,{24,24},{475,375}},{1,{24,24},{150,975}},{1,{24,24},{350,225}},{2,{24,24},{75,125}},{1,{24,24},{625,400}},{1,{24,24},{700,150}},{2,{24,24},{125,75}},{1,{24,24},{475,950}},{1,{24,24},{850,675}},{1,{24,24},{0,675}},{2,{24,24},{150,300}},{1,{24,24},{50,975}},{2,{24,24},{200,0}},{2,{24,24},{75,100}},{2,{24,24},{25,150}},{1,{24,24},{700,375}},{1,{24,24},{575,325}},{1,{24,24},{625,50}},{1,{24,24},{50,0}},{1,{24,24},{900,525}},{1,{24,24},{875,825}},{1,{24,24},{125,75}},{1,{24,24},{850,175}},{2,{24,24},{0,175}},{2,{24,24},{150,25}},{2,{24,24},{0,150}},{1,{24,24},{475,75}},{1,{24,24},{425,950}},{1,{24,24},{850,650}},{1,{24,24},{675,0}},{2,{24,24},{75,75}},{2,{24,24},{100,50}},{1,{24,24},{400,725}},{1,{24,24},{400,375}},{1,{24,24},{425,275}},{2,{24,24},{125,25}},{2,{24,24},{0,125}},{2,{24,24},{25,100}},{2,{24,24},{25,125}},{1,{24,24},{200,725}},{1,{24,24},{300,175}},{2,{24,24},{50,75}},{1,{24,24},{400,650}},{1,{24,24},{100,350}},{2,{24,24},{0,325}},{1,{24,24},{375,975}},{2,{24,24},{0,100}},{1,{24,24},{975,550}},{2,{24,24},{75,25}},{2,{24,24},{75,0}},{2,{24,24},{0,50}},{1,{24,24},{225,350}},{1,{24,24},{800,125}},{1,{24,24},{375,950}},{1,{24,24},{575,375}},{1,{24,24},{975,800}},{1,{24,24},{950,0}},{1,{24,24},{300,875}},{2,{24,24},{425,125}},{2,{24,24},{50,0}},{2,{24,24},{25,0}},{1,{24,24},{50,250}},{1,{24,24},{125,775}},{2,{24,24},{0,0}},{1,{24,24},{250,875}},{1,{24,24},{950,975}},{1,{24,24},{700,250}},{1,{24,24},{225,325}},{1,{24,24},{650,75}},{1,{24,24},{900,925}},{1,{24,24},{100,900}},{1,{24,24},{950,950}},{1,{24,24},{325,700}},{1,{24,24},{300,800}},{1,{24,24},{500,0}},{1,{24,24},{425,200}},{1,{24,24},{675,375}},{1,{24,24},{850,50}},{1,{24,24},{350,675}},{1,{24,24},{525,325}},{1,{24,24},{175,175}},{1,{24,24},{450,0}},{1,{24,24},{75,125}},{1,{24,24},{300,650}},{1,{24,24},{950,925}},{1,{24,24},{925,975}},{1,{24,24},{875,975}},{1,{24,24},{925,925}},{1,{24,24},{875,950}},{1,{24,24},{900,350}},{1,{24,24},{25,350}},{1,{24,24},{950,525}},{1,{24,24},{525,950}},{1,{24,24},{925,475}},{1,{24,24},{950,900}},{1,{24,24},{975,850}},{2,{24,24},{275,25}},{1,{24,24},{350,550}},{1,{24,24},{775,100}},{1,{24,24},{275,300}},{1,{24,24},{850,950}},{1,{24,24},{825,650}},{1,{24,24},{950,450}},{1,{24,24},{975,825}},{1,{24,24},{850,925}},{1,{24,24},{125,850}},{1,{24,24},{900,875}},{1,{24,24},{125,275}},{1,{24,24},{900,275}},{2,{24,24},{50,150}},{1,{24,24},{825,925}},{1,{24,24},{725,650}},{1,{24,24},{625,950}},{1,{24,24},{900,850}},{1,{24,24},{475,975}},{1,{24,24},{300,150}},{1,{24,24},{950,800}},{1,{24,24},{175,225}},{1,{24,24},{400,400}},{1,{24,24},{975,775}},{1,{24,24},{350,525}},{1,{24,24},{975,75}},{1,{24,24},{800,925}},{1,{24,24},{825,900}},{1,{24,24},{850,750}},{1,{24,24},{850,875}},{1,{24,24},{350,0}},{1,{24,24},{875,850}},{1,{24,24},{275,875}},{1,{24,24},{400,50}},{1,{24,24},{950,775}},{1,{24,24},{450,125}},{1,{24,24},{975,750}},{1,{24,24},{600,800}},{1,{24,24},{400,450}},{1,{24,24},{150,950}},{1,{24,24},{850,850}},{1,{24,24},{900,800}},{1,{24,24},{925,775}},{1,{24,24},{800,550}},{1,{24,24},{100,600}},{1,{24,24},{75,425}},{1,{24,24},{100,0}},{1,{24,24},{975,725}},{1,{24,24},{650,450}},{1,{24,24},{700,975}},{1,{24,24},{750,875}},{1,{24,24},{475,350}},{1,{24,24},{0,350}},{1,{24,24},{325,175}},{1,{24,24},{725,950}},{2,{24,24},{300,225}},{1,{24,24},{750,775}},{1,{24,24},{25,0}},{1,{24,24},{300,425}},{1,{24,24},{950,600}},{1,{24,24},{475,175}},{2,{24,24},{200,250}},{1,{24,24},{150,700}},{2,{24,24},{100,425}},{1,{24,24},{700,950}},{1,{24,24},{400,475}},{1,{24,24},{725,925}},{1,{24,24},{450,150}},{1,{24,24},{75,700}},{1,{24,24},{575,675}},{1,{24,24},{325,275}},{1,{24,24},{225,175}},{1,{24,24},{775,875}},{1,{24,24},{975,400}},{1,{24,24},{675,875}},{1,{24,24},{800,775}},{1,{24,24},{200,350}},{1,{24,24},{550,500}},{1,{24,24},{175,725}},{2,{24,24},{100,225}},{1,{24,24},{575,525}},{1,{24,24},{75,375}},{1,{24,24},{50,750}},{1,{24,24},{500,400}},{1,{24,24},{250,450}},{1,{24,24},{325,100}},{1,{24,24},{825,250}},{1,{24,24},{900,750}},{1,{24,24},{950,700}},{1,{24,24},{975,675}},{1,{24,24},{425,25}},{1,{24,24},{375,825}},{1,{24,24},{650,975}},{1,{24,24},{375,450}},{1,{24,24},{700,925}},{1,{24,24},{900,175}},{1,{24,24},{800,625}},{1,{24,24},{575,725}},{1,{24,24},{775,850}},{1,{24,24},{275,225}},{1,{24,24},{925,75}},{1,{24,24},{800,825}},{1,{24,24},{700,750}},{1,{24,24},{575,575}},{1,{24,24},{825,800}},{1,{24,24},{850,775}},{1,{24,24},{275,900}},{1,{24,24},{425,100}},{1,{24,24},{900,725}},{1,{24,24},{600,875}},{1,{24,24},{975,650}},{1,{24,24},{850,200}},{1,{24,24},{675,50}},{1,{24,24},{325,625}},{2,{24,24},{225,50}},{1,{24,24},{225,75}},{1,{24,24},{250,175}},{1,{24,24},{800,975}},{1,{24,24},{375,625}},{1,{24,24},{100,375}},{1,{24,24},{850,425}},{1,{24,24},{425,625}},{1,{24,24},{675,925}},{1,{24,24},{700,900}},{1,{24,24},{750,850}},{1,{24,24},{525,975}},{1,{24,24},{400,150}},{1,{24,24},{900,575}},{1,{24,24},{100,225}},{1,{24,24},{350,275}},{1,{24,24},{650,250}},{1,{24,24},{875,425}},{1,{24,24},{200,500}},{1,{24,24},{925,675}},{1,{24,24},{750,25}},{1,{24,24},{950,650}},{1,{24,24},{800,250}},{1,{24,24},{975,625}},{1,{24,24},{700,175}},{1,{24,24},{150,250}},{1,{24,24},{925,200}},{1,{24,24},{50,200}},{1,{24,24},{200,325}},{1,{24,24},{375,75}},{1,{24,24},{800,575}},{1,{24,24},{525,0}},{1,{24,24},{925,525}},{1,{24,24},{875,400}},{1,{24,24},{850,275}},{1,{24,24},{925,750}},{1,{24,24},{875,875}},{1,{24,24},{425,675}},{1,{24,24},{875,25}},{1,{24,24},{925,400}},{1,{24,24},{100,975}},{1,{24,24},{325,0}},{1,{24,24},{675,900}},{1,{24,24},{550,175}},{1,{24,24},{700,875}},{1,{24,24},{475,925}},{1,{24,24},{150,0}},{1,{24,24},{750,825}},{1,{24,24},{50,150}},{1,{24,24},{975,175}},{1,{24,24},{800,650}},{1,{24,24},{775,800}},{1,{24,24},{825,825}},{1,{24,24},{175,825}},{1,{24,24},{850,725}},{1,{24,24},{650,475}},{1,{24,24},{825,150}},{1,{24,24},{450,500}},{1,{24,24},{900,775}},{1,{24,24},{0,975}},{2,{24,24},{75,450}},{2,{24,24},{125,375}},{1,{24,24},{925,650}},{1,{24,24},{225,500}},{1,{24,24},{900,0}},{1,{24,24},{950,25}},{1,{24,24},{575,175}},{1,{24,24},{100,50}},{1,{24,24},{400,925}},{1,{24,24},{225,875}},{1,{24,24},{575,975}},{1,{24,24},{475,100}},{1,{24,24},{650,900}},{1,{24,24},{150,125}},{1,{24,24},{300,100}},{1,{24,24},{725,825}},{2,{24,24},{375,25}},{1,{24,24},{800,750}},{1,{24,24},{700,825}},{1,{24,24},{575,350}},{1,{24,24},{825,725}},{1,{24,24},{175,300}},{1,{24,24},{775,625}},{1,{24,24},{725,450}},{1,{24,24},{275,275}},{1,{24,24},{425,525}},{1,{24,24},{875,675}},{1,{24,24},{900,650}},{1,{24,24},{875,800}},{1,{24,24},{575,550}},{1,{24,24},{975,250}},{1,{24,24},{975,575}},{1,{24,24},{350,575}},{1,{24,24},{725,275}},{1,{24,24},{225,950}},{1,{24,24},{675,850}},{1,{24,24},{175,125}},{1,{24,24},{650,600}},{1,{24,24},{850,825}},{1,{24,24},{825,700}},{1,{24,24},{925,600}},{1,{24,24},{950,575}},{2,{24,24},{25,75}},{1,{24,24},{425,925}},{1,{24,24},{775,825}},{1,{24,24},{625,300}},{1,{24,24},{0,925}},{1,{24,24},{200,375}},{1,{24,24},{175,200}},{1,{24,24},{200,950}},{1,{24,24},{600,650}},{1,{24,24},{700,275}},{1,{24,24},{100,125}},{1,{24,24},{575,925}},{1,{24,24},{600,900}},{1,{24,24},{625,875}},{1,{24,24},{650,50}},{1,{24,24},{700,800}},{1,{24,24},{300,250}},{1,{24,24},{625,125}},{1,{24,24},{50,550}},{1,{24,24},{675,825}},{2,{24,24},{275,250}},{1,{24,24},{750,750}},{1,{24,24},{875,650}},{1,{24,24},{800,700}},{1,{24,24},{25,875}},{1,{24,24},{825,675}},{1,{24,24},{375,575}},{1,{24,24},{125,300}},{1,{24,24},{875,625}},{1,{24,24},{925,575}},{1,{24,24},{825,400}},{1,{24,24},{150,450}},{2,{24,24},{225,175}},{1,{24,24},{850,500}},{1,{24,24},{950,550}},{1,{24,24},{850,475}},{2,{24,24},{375,125}},{1,{24,24},{475,125}},{1,{24,24},{925,700}},{1,{24,24},{375,500}},{1,{24,24},{500,175}},{1,{24,24},{500,975}},{1,{24,24},{725,750}},{1,{24,24},{800,675}},{1,{24,24},{150,800}},{1,{24,24},{925,875}},{1,{24,24},{850,625}},{1,{24,24},{775,50}},{1,{24,24},{800,800}},{1,{24,24},{800,300}},{1,{24,24},{775,700}},{1,{24,24},{775,175}},{1,{24,24},{925,550}},{1,{24,24},{0,75}},{1,{24,24},{125,875}},{1,{24,24},{450,400}},{1,{24,24},{925,825}},{1,{24,24},{975,500}},{1,{24,24},{175,275}},{1,{24,24},{500,900}},{1,{24,24},{400,225}},{1,{24,24},{100,475}},{1,{24,24},{300,625}},{1,{24,24},{575,500}},{1,{24,24},{325,800}},{1,{24,24},{625,775}},{1,{24,24},{575,875}},{1,{24,24},{675,775}},{1,{24,24},{675,200}},{1,{24,24},{550,750}},{1,{24,24},{625,625}},{1,{24,24},{650,325}},{1,{24,24},{800,375}},{1,{24,24},{625,350}},{1,{24,24},{475,825}},{1,{24,24},{775,675}},{1,{24,24},{700,100}},{1,{24,24},{675,75}},{1,{24,24},{250,375}},{1,{24,24},{25,25}},{1,{24,24},{0,325}},{1,{24,24},{875,450}},{1,{24,24},{825,625}},{1,{24,24},{650,100}},{1,{24,24},{850,600}},{1,{24,24},{600,850}},{1,{24,24},{500,275}},{1,{24,24},{725,150}},{1,{24,24},{650,700}},{1,{24,24},{625,0}},{1,{24,24},{800,525}},{1,{24,24},{550,0}},{1,{24,24},{125,50}},{1,{24,24},{975,475}},{2,{24,24},{50,425}},{2,{24,24},{150,50}},{1,{24,24},{300,700}},{1,{24,24},{950,500}},{1,{24,24},{550,875}},{1,{24,24},{475,200}},{1,{24,24},{600,825}},{1,{24,24},{625,800}},{1,{24,24},{650,775}},{1,{24,24},{675,400}},{1,{24,24},{675,750}},{1,{24,24},{325,525}},{2,{24,24},{425,50}},{1,{24,24},{275,125}},{1,{24,24},{700,725}},{1,{24,24},{725,900}},{1,{24,24},{375,150}},{1,{24,24},{800,150}},{1,{24,24},{825,600}},{1,{24,24},{450,100}},{1,{24,24},{850,575}},{1,{24,24},{875,550}},{1,{24,24},{925,500}},{2,{24,24},{100,75}},{1,{24,24},{425,50}},{1,{24,24},{375,700}},{1,{24,24},{200,125}},{1,{24,24},{225,200}},{1,{24,24},{400,625}},{1,{24,24},{200,525}},{1,{24,24},{75,750}},{1,{24,24},{300,25}},{2,{24,24},{0,75}},{1,{24,24},{425,975}},{1,{24,24},{450,950}},{1,{24,24},{150,725}},{1,{24,24},{550,850}},{1,{24,24},{575,825}},{1,{24,24},{550,900}},{1,{24,24},{700,325}},{1,{24,24},{725,675}},{1,{24,24},{800,600}},{2,{24,24},{0,250}},{1,{24,24},{150,600}},{1,{24,24},{825,575}},{1,{24,24},{900,500}},{1,{24,24},{725,475}},{1,{24,24},{300,825}},{1,{24,24},{525,775}},{1,{24,24},{625,725}},{1,{24,24},{750,175}},{1,{24,24},{875,525}},{1,{24,24},{950,850}},{1,{24,24},{975,425}},{1,{24,24},{400,975}},{1,{24,24},{825,225}},{1,{24,24},{925,900}},{1,{24,24},{725,600}},{1,{24,24},{375,375}},{1,{24,24},{325,950}},{1,{24,24},{775,350}},{1,{24,24},{450,75}},{2,{24,24},{175,0}},{1,{24,24},{450,925}},{1,{24,24},{600,700}},{2,{24,24},{75,250}},{1,{24,24},{275,200}},{1,{24,24},{550,450}},{2,{24,24},{250,75}},{1,{24,24},{350,250}},{1,{24,24},{300,375}},{1,{24,24},{500,875}},{1,{24,24},{0,775}},{1,{24,24},{625,675}},{1,{24,24},{50,700}},{1,{24,24},{375,25}},{1,{24,24},{975,350}},{1,{24,24},{600,775}},{1,{24,24},{425,0}},{1,{24,24},{25,625}},{1,{24,24},{625,200}},{1,{24,24},{375,600}},{1,{24,24},{700,675}},{1,{24,24},{525,750}},{1,{24,24},{525,350}},{1,{24,24},{750,625}},{1,{24,24},{375,525}},{1,{24,24},{800,25}},{1,{24,24},{900,475}},{1,{24,24},{250,200}},{1,{24,24},{925,450}},{2,{24,24},{200,325}},{1,{24,24},{850,800}},{1,{24,24},{400,950}},{1,{24,24},{825,550}},{1,{24,24},{450,900}},{1,{24,24},{475,575}},{1,{24,24},{475,875}},{1,{24,24},{500,850}},{1,{24,24},{625,500}},{1,{24,24},{925,325}},{1,{24,24},{275,350}},{1,{24,24},{400,750}},{1,{24,24},{600,750}},{1,{24,24},{25,575}},{1,{24,24},{550,800}},{1,{24,24},{75,175}},{1,{24,24},{675,675}},{1,{24,24},{700,650}},{1,{24,24},{275,925}},{1,{24,24},{675,225}},{1,{24,24},{750,600}},{1,{24,24},{950,750}},{1,{24,24},{675,125}},{1,{24,24},{825,525}},{1,{24,24},{875,475}},{2,{24,24},{100,25}},{1,{24,24},{950,400}},{1,{24,24},{450,675}},{1,{24,24},{800,50}},{1,{24,24},{950,625}},{1,{24,24},{25,775}},{1,{24,24},{625,550}},{1,{24,24},{600,600}},{1,{24,24},{725,75}},{1,{24,24},{625,75}},{1,{24,24},{575,125}},{1,{24,24},{975,450}},{1,{24,24},{150,175}},{1,{24,24},{675,575}},{1,{24,24},{25,375}},{1,{24,24},{425,900}},{1,{24,24},{400,275}},{1,{24,24},{275,600}},{1,{24,24},{975,25}},{1,{24,24},{875,275}},{1,{24,24},{400,525}},{1,{24,24},{550,600}},{1,{24,24},{450,875}},{2,{24,24},{25,275}},{1,{24,24},{75,975}},{1,{24,24},{0,225}},{1,{24,24},{600,725}},{1,{24,24},{25,800}},{1,{24,24},{625,700}},{1,{24,24},{700,625}},{1,{24,24},{650,375}},{1,{24,24},{900,550}},{1,{24,24},{775,550}},{1,{24,24},{850,75}},{1,{24,24},{800,475}},{1,{24,24},{900,425}},{1,{24,24},{325,975}},{1,{24,24},{425,800}},{1,{24,24},{650,725}},{1,{24,24},{350,950}},{1,{24,24},{825,875}},{1,{24,24},{450,850}},{1,{24,24},{250,925}},{1,{24,24},{450,600}},{1,{24,24},{725,725}},{1,{24,24},{575,150}},{1,{24,24},{675,950}},{1,{24,24},{125,350}},{1,{24,24},{800,100}},{1,{24,24},{425,225}},{1,{24,24},{675,625}},{1,{24,24},{450,975}},{1,{24,24},{225,50}},{1,{24,24},{750,550}},{1,{24,24},{550,825}},{2,{24,24},{275,175}},{1,{24,24},{175,375}},{1,{24,24},{825,475}},{1,{24,24},{825,775}},{1,{24,24},{0,375}},{1,{24,24},{750,225}},{1,{24,24},{900,400}},{1,{24,24},{650,25}},{1,{24,24},{300,975}},{1,{24,24},{525,75}},{1,{24,24},{400,875}},{1,{24,24},{425,850}},{1,{24,24},{850,150}},{1,{24,24},{450,825}},{2,{24,24},{50,225}},{1,{24,24},{225,25}},{1,{24,24},{0,400}},{1,{24,24},{625,650}},{1,{24,24},{650,625}},{1,{24,24},{300,50}},{1,{24,24},{550,25}},{1,{24,24},{750,525}},{1,{24,24},{775,500}},{1,{24,24},{925,350}},{1,{24,24},{850,325}},{1,{24,24},{275,0}},{1,{24,24},{975,300}},{1,{24,24},{750,325}},{2,{24,24},{25,475}},{1,{24,24},{325,925}},{1,{24,24},{350,900}},{1,{24,24},{525,600}},{1,{24,24},{750,250}},{1,{24,24},{475,550}},{1,{24,24},{475,775}},{1,{24,24},{400,850}},{1,{24,24},{500,750}},{1,{24,24},{575,275}},{1,{24,24},{750,900}},{1,{24,24},{900,225}},{1,{24,24},{700,550}},{1,{24,24},{0,450}},{1,{24,24},{725,525}},{1,{24,24},{750,500}},{1,{24,24},{800,0}},{1,{24,24},{825,425}},{1,{24,24},{750,300}},{1,{24,24},{175,25}},{1,{24,24},{0,50}},{1,{24,24},{650,875}},{1,{24,24},{75,100}},{1,{24,24},{850,400}},{1,{24,24},{25,75}},{1,{24,24},{875,375}},{1,{24,24},{175,700}},{1,{24,24},{475,250}},{1,{24,24},{950,50}},{1,{24,24},{100,625}},{1,{24,24},{275,175}},{1,{24,24},{575,425}},{1,{24,24},{575,775}},{1,{24,24},{725,375}},{1,{24,24},{125,700}},{1,{24,24},{450,625}},{1,{24,24},{225,625}},{1,{24,24},{250,975}},{1,{24,24},{800,875}},{1,{24,24},{150,225}},{1,{24,24},{425,550}},{1,{24,24},{450,700}},{1,{24,24},{350,875}},{1,{24,24},{350,325}},{1,{24,24},{100,750}},{1,{24,24},{325,900}},{1,{24,24},{400,825}},{1,{24,24},{375,850}},{2,{24,24},{0,225}},{1,{24,24},{25,275}},{1,{24,24},{225,900}},{1,{24,24},{850,225}},{1,{24,24},{475,675}},{1,{24,24},{550,325}},{1,{24,24},{225,525}},{1,{24,24},{600,625}},{1,{24,24},{625,600}},{1,{24,24},{600,575}},{1,{24,24},{650,575}},{1,{24,24},{725,500}},{1,{24,24},{0,750}},{1,{24,24},{675,550}},{1,{24,24},{200,675}},{1,{24,24},{850,375}},{1,{24,24},{525,725}},{1,{24,24},{350,50}},{1,{24,24},{475,475}},{1,{24,24},{950,275}},{1,{24,24},{200,575}},{1,{24,24},{225,975}},{2,{24,24},{75,175}},{1,{24,24},{925,225}},{1,{24,24},{50,925}},{1,{24,24},{325,875}},{1,{24,24},{625,375}},{1,{24,24},{350,400}},{1,{24,24},{350,850}},{1,{24,24},{425,775}},{1,{24,24},{200,900}},{1,{24,24},{550,650}},{1,{24,24},{425,175}},{1,{24,24},{675,525}},{1,{24,24},{950,100}},{1,{24,24},{475,0}},{1,{24,24},{175,50}},{1,{24,24},{650,750}},{1,{24,24},{125,375}},{1,{24,24},{125,525}},{1,{24,24},{550,250}},{1,{24,24},{850,100}},{1,{24,24},{75,575}},{1,{24,24},{825,375}},{1,{24,24},{375,175}},{1,{24,24},{25,225}},{1,{24,24},{650,950}},{1,{24,24},{250,900}},{1,{24,24},{250,400}},{1,{24,24},{975,225}},{1,{24,24},{600,550}},{1,{24,24},{50,600}},{1,{24,24},{0,575}},{1,{24,24},{200,975}},{1,{24,24},{675,250}},{1,{24,24},{625,900}},{1,{24,24},{250,300}},{1,{24,24},{700,50}},{1,{24,24},{875,750}},{1,{24,24},{325,850}},{1,{24,24},{250,475}},{1,{24,24},{325,350}},{1,{24,24},{600,150}},{1,{24,24},{25,175}},{1,{24,24},{175,75}},{1,{24,24},{350,825}},{1,{24,24},{375,725}},{1,{24,24},{400,775}},{1,{24,24},{425,750}},{1,{24,24},{475,700}},{1,{24,24},{300,775}},{1,{24,24},{500,150}},{1,{24,24},{75,625}},{1,{24,24},{475,225}},{1,{24,24},{175,900}},{1,{24,24},{550,625}},{1,{24,24},{200,875}},{1,{24,24},{350,300}},{1,{24,24},{125,200}},{1,{24,24},{300,850}},{1,{24,24},{375,400}},{1,{24,24},{675,500}},{2,{24,24},{25,25}},{1,{24,24},{650,400}},{1,{24,24},{825,350}},{1,{24,24},{175,875}},{1,{24,24},{625,225}},{1,{24,24},{525,450}},{1,{24,24},{950,825}},{1,{24,24},{200,100}},{1,{24,24},{125,25}},{1,{24,24},{750,700}},{1,{24,24},{150,25}},{1,{24,24},{275,725}},{1,{24,24},{50,25}},{1,{24,24},{375,225}},{1,{24,24},{975,200}},{1,{24,24},{225,925}},{1,{24,24},{950,250}},{1,{24,24},{300,125}},{1,{24,24},{450,350}},{1,{24,24},{925,800}},{1,{24,24},{350,800}},{1,{24,24},{425,725}},{1,{24,24},{825,0}},{1,{24,24},{950,300}},{2,{24,24},{150,125}},{1,{24,24},{250,675}},{1,{24,24},{750,400}},{1,{24,24},{225,300}},{1,{24,24},{200,300}},{1,{24,24},{800,350}},{2,{24,24},{450,0}},{1,{24,24},{900,250}},{1,{24,24},{125,475}},{1,{24,24},{425,375}},{1,{24,24},{400,175}},{1,{24,24},{625,325}},{1,{24,24},{975,975}},{1,{24,24},{175,475}},{1,{24,24},{500,725}},{1,{24,24},{750,100}},{1,{24,24},{100,650}},{1,{24,24},{775,275}},{1,{24,24},{275,500}},{1,{24,24},{475,650}},{1,{24,24},{975,375}},{2,{24,24},{300,125}},{1,{24,24},{375,875}},{1,{24,24},{750,50}},{1,{24,24},{425,875}},{2,{24,24},{350,75}},{1,{24,24},{800,325}},{1,{24,24},{250,775}},{1,{24,24},{950,175}},{1,{24,24},{975,150}},{1,{24,24},{200,225}},{1,{24,24},{175,925}},{1,{24,24},{650,550}},{1,{24,24},{175,650}},{1,{24,24},{975,600}},{1,{24,24},{50,725}},{1,{24,24},{0,200}},{1,{24,24},{300,0}},{1,{24,24},{825,300}},{2,{24,24},{325,125}},{1,{24,24},{250,425}},{1,{24,24},{200,450}},{1,{24,24},{200,425}},{2,{24,24},{225,25}},{1,{24,24},{250,25}},{1,{24,24},{375,800}},{1,{24,24},{475,625}},{1,{24,24},{175,450}},{1,{24,24},{450,650}},{1,{24,24},{400,700}},{1,{24,24},{750,125}},{1,{24,24},{850,700}},{1,{24,24},{275,750}},{1,{24,24},{550,550}},{1,{24,24},{500,600}},{1,{24,24},{450,575}},{1,{24,24},{50,100}},{1,{24,24},{600,500}},{1,{24,24},{150,400}},{1,{24,24},{350,450}},{1,{24,24},{100,725}},{1,{24,24},{625,475}},{1,{24,24},{100,425}},{1,{24,24},{300,475}},{1,{24,24},{975,100}},{1,{24,24},{725,175}},{1,{24,24},{700,400}},{1,{24,24},{75,25}},{1,{24,24},{450,225}},{2,{24,24},{250,150}},{1,{24,24},{675,350}},{1,{24,24},{950,425}},{1,{24,24},{925,175}},{1,{24,24},{975,125}},{1,{24,24},{550,475}},{1,{24,24},{500,700}},{1,{24,24},{575,600}},{1,{24,24},{225,850}},{1,{24,24},{250,825}},{1,{24,24},{550,400}},{1,{24,24},{275,800}},{1,{24,24},{375,125}},{1,{24,24},{525,650}},{1,{24,24},{325,750}},{1,{24,24},{400,675}},{1,{24,24},{350,725}},{1,{24,24},{350,650}},{1,{24,24},{225,100}},{1,{24,24},{425,650}},{1,{24,24},{975,275}},{1,{24,24},{525,525}},{1,{24,24},{500,575}},{1,{24,24},{25,50}},{1,{24,24},{100,875}},{1,{24,24},{550,275}},{1,{24,24},{350,75}},{1,{24,24},{500,950}},{1,{24,24},{725,975}},{1,{24,24},{450,775}},{1,{24,24},{275,25}},{1,{24,24},{300,400}},{2,{24,24},{175,25}},{2,{24,24},{325,225}},{1,{24,24},{875,200}},{1,{24,24},{350,475}},{1,{24,24},{50,850}},{1,{24,24},{225,750}},{1,{24,24},{325,575}},{1,{24,24},{925,150}},{1,{24,24},{575,750}},{1,{24,24},{325,150}},{1,{24,24},{275,325}},{1,{24,24},{600,0}},{1,{24,24},{425,300}},{1,{24,24},{850,550}},{1,{24,24},{725,25}},{1,{24,24},{50,650}},{1,{24,24},{125,925}},{1,{24,24},{750,350}},{1,{24,24},{925,425}},{1,{24,24},{350,100}},{1,{24,24},{775,325}},{1,{24,24},{625,425}},{1,{24,24},{0,25}},{1,{24,24},{725,325}},{1,{24,24},{600,450}},{1,{24,24},{375,750}},{1,{24,24},{875,175}},{1,{24,24},{600,275}},{1,{24,24},{925,125}},{1,{24,24},{525,275}},{1,{24,24},{0,275}},{1,{24,24},{925,0}},{1,{24,24},{775,950}},{1,{24,24},{75,950}},{1,{24,24},{175,350}},{1,{24,24},{100,925}},{1,{24,24},{125,900}},{1,{24,24},{175,250}},{1,{24,24},{175,850}},{1,{24,24},{200,825}},{1,{24,24},{225,800}},{1,{24,24},{825,125}},{1,{24,24},{875,250}},{1,{24,24},{425,600}},{1,{24,24},{500,525}},{1,{24,24},{575,450}},{1,{24,24},{325,200}},{1,{24,24},{500,125}},{1,{24,24},{125,750}},{1,{24,24},{300,300}},{1,{24,24},{275,400}},{1,{24,24},{700,25}},{2,{24,24},{100,275}},{2,{24,24},{100,100}},{1,{24,24},{150,925}},{1,{24,24},{750,275}},{1,{24,24},{225,600}},{1,{24,24},{775,250}},{1,{24,24},{325,75}},{1,{24,24},{275,850}},{1,{24,24},{675,100}},{1,{24,24},{875,150}},{1,{24,24},{150,425}},{1,{24,24},{900,125}},{1,{24,24},{350,125}},{1,{24,24},{200,800}},{1,{24,24},{150,325}},{1,{24,24},{975,50}},{1,{24,24},{250,275}},{1,{24,24},{300,275}},{2,{24,24},{75,150}},{1,{24,24},{150,850}},{1,{24,24},{950,75}},{2,{24,24},{150,325}},{1,{24,24},{975,950}},{1,{24,24},{250,575}},{1,{24,24},{525,900}},{1,{24,24},{625,250}},{1,{24,24},{400,600}},{1,{24,24},{425,575}},{1,{24,24},{475,525}},{1,{24,24},{500,500}},{1,{24,24},{100,800}},{1,{24,24},{250,225}},{1,{24,24},{25,750}},{1,{24,24},{525,475}},{1,{24,24},{600,400}},{1,{24,24},{675,325}},{1,{24,24},{575,950}},{1,{24,24},{425,825}},{1,{24,24},{400,425}},{1,{24,24},{675,175}},{1,{24,24},{150,625}},{1,{24,24},{200,175}},{1,{24,24},{550,575}},{1,{24,24},{225,275}},{1,{24,24},{375,0}},{1,{24,24},{350,925}},{1,{24,24},{825,175}},{1,{24,24},{175,400}},{1,{24,24},{25,950}},{1,{24,24},{150,825}},{1,{24,24},{400,550}},{1,{24,24},{525,375}},{1,{24,24},{350,625}},{1,{24,24},{275,700}},{1,{24,24},{500,475}},{1,{24,24},{550,950}},{1,{24,24},{200,475}},{1,{24,24},{225,575}},{1,{24,24},{775,75}},{1,{24,24},{275,375}},{1,{24,24},{725,250}},{1,{24,24},{600,200}},{1,{24,24},{100,250}},{1,{24,24},{200,550}},{1,{24,24},{875,500}},{1,{24,24},{850,125}},{1,{24,24},{925,50}},{1,{24,24},{975,0}},{1,{24,24},{0,950}},{1,{24,24},{25,850}},{1,{24,24},{675,150}},{1,{24,24},{375,300}},{1,{24,24},{125,125}},{1,{24,24},{25,550}},{1,{24,24},{25,925}},{1,{24,24},{100,850}},{1,{24,24},{800,500}},{1,{24,24},{275,75}},{1,{24,24},{225,725}},{1,{24,24},{125,800}},{1,{24,24},{775,25}},{1,{24,24},{275,675}},{1,{24,24},{550,100}},{1,{24,24},{925,950}},{1,{24,24},{625,975}},{1,{24,24},{900,600}},{1,{24,24},{350,600}},{1,{24,24},{650,300}},{1,{24,24},{675,275}},{1,{24,24},{900,50}},{1,{24,24},{50,875}},{1,{24,24},{75,850}},{1,{24,24},{50,575}},{1,{24,24},{175,750}},{1,{24,24},{300,225}},{1,{24,24},{225,700}},{1,{24,24},{675,475}},{1,{24,24},{525,225}},{2,{24,24},{200,150}},{1,{24,24},{550,375}},{1,{24,24},{525,400}},{1,{24,24},{850,350}},{2,{24,24},{225,150}},{2,{24,24},{350,150}},{1,{24,24},{825,100}},{1,{24,24},{0,125}},{1,{24,24},{875,50}},{1,{24,24},{75,825}},{1,{24,24},{525,800}},{2,{24,24},{350,25}},{1,{24,24},{250,325}},{1,{24,24},{250,650}},{1,{24,24},{275,625}},{1,{24,24},{675,300}},{1,{24,24},{125,325}},{1,{24,24},{0,300}},{1,{24,24},{875,925}},{1,{24,24},{600,125}},{1,{24,24},{50,300}},{1,{24,24},{175,675}},{1,{24,24},{425,475}},{1,{24,24},{475,425}},{1,{24,24},{325,650}},{1,{24,24},{625,275}},{1,{24,24},{25,475}},{1,{24,24},{750,150}},{1,{24,24},{725,0}},{1,{24,24},{225,650}},{1,{24,24},{800,225}},{1,{24,24},{650,925}},{1,{24,24},{100,775}},{1,{24,24},{75,800}},{1,{24,24},{325,550}},{1,{24,24},{250,525}},{1,{24,24},{525,200}},{2,{24,24},{350,200}},{1,{24,24},{900,150}},{1,{24,24},{325,675}},{2,{24,24},{275,100}},{1,{24,24},{25,825}},{1,{24,24},{125,725}},{1,{24,24},{775,650}},{1,{24,24},{350,500}},{1,{24,24},{175,150}},{1,{24,24},{725,400}},{1,{24,24},{900,975}},{1,{24,24},{775,450}},{1,{24,24},{775,225}},{1,{24,24},{825,25}},{1,{24,24},{500,200}},{1,{24,24},{550,225}},{1,{24,24},{150,675}},{2,{24,24},{50,400}},{1,{24,24},{525,550}},{1,{24,24},{650,175}},{1,{24,24},{750,75}},{1,{24,24},{875,600}},{1,{24,24},{275,425}},{1,{24,24},{250,500}},{1,{24,24},{175,625}},{1,{24,24},{0,700}},{1,{24,24},{125,0}},{1,{24,24},{200,600}},{1,{24,24},{250,550}},{1,{24,24},{400,350}},{1,{24,24},{25,700}},{1,{24,24},{800,400}},{1,{24,24},{625,175}},{1,{24,24},{675,450}},{1,{24,24},{800,450}},{1,{24,24},{625,25}},{1,{24,24},{925,375}},{1,{24,24},{0,500}},{1,{24,24},{675,425}},{1,{24,24},{425,350}},{1,{24,24},{450,325}},{1,{24,24},{225,550}},{1,{24,24},{650,125}},{1,{24,24},{375,350}},{1,{24,24},{700,75}},{1,{24,24},{725,50}},{1,{24,24},{150,200}},{1,{24,24},{775,0}},{1,{24,24},{625,750}},{1,{24,24},{75,675}},{1,{24,24},{25,125}},{1,{24,24},{575,50}},{1,{24,24},{825,75}},{1,{24,24},{800,175}},{1,{24,24},{275,475}},{1,{24,24},{275,525}},{1,{24,24},{275,150}},{1,{24,24},{425,500}},{1,{24,24},{50,675}},{1,{24,24},{150,575}},{1,{24,24},{75,75}},{1,{24,24},{425,400}},{1,{24,24},{450,275}},{1,{24,24},{100,700}},{1,{24,24},{225,225}},{1,{24,24},{375,325}},{1,{24,24},{50,625}},{1,{24,24},{0,475}},{1,{24,24},{75,875}},{1,{24,24},{525,150}},{1,{24,24},{675,700}},{1,{24,24},{750,450}},{1,{24,24},{275,825}},{1,{24,24},{450,200}},{1,{24,24},{150,350}},{1,{24,24},{650,650}},{1,{24,24},{875,700}},{1,{24,24},{575,75}},{2,{24,24},{175,150}},{1,{24,24},{150,475}},{1,{24,24},{75,525}},{1,{24,24},{975,925}},{1,{24,24},{450,175}},{1,{24,24},{475,150}},{1,{24,24},{0,600}},{1,{24,24},{375,250}},{1,{24,24},{925,250}},{2,{24,24},{125,225}},{1,{24,24},{100,150}},{1,{24,24},{125,650}},{1,{24,24},{125,450}},{1,{24,24},{75,200}},{1,{24,24},{625,450}},{1,{24,24},{700,575}},{1,{24,24},{400,25}},{1,{24,24},{525,575}},{1,{24,24},{525,25}},{2,{24,24},{200,25}},{1,{24,24},{350,175}},{1,{24,24},{625,150}},{1,{24,24},{175,325}},{1,{24,24},{425,75}},{1,{24,24},{25,450}},{1,{24,24},{500,550}},{1,{24,24},{125,975}},{1,{24,24},{575,700}},{1,{24,24},{225,150}},{2,{24,24},{400,50}},{1,{24,24},{250,50}},{1,{24,24},{150,75}}}}}

    local iconIndices: { string } = icons[1]
    local idIndices: { string } = icons[2]
    local iconRegistry: { [number]: { number | { number } } } = icons[3]
    local IconLookup = {}
    for Index, Name in ipairs(iconIndices) do IconLookup[Name] = Index end
    local IconSize, Difference = 48, math_huge
    for Size in pairs(iconRegistry) do
        local Current = math_abs(Size - 48)
        if Current < Difference then Difference, IconSize = Current, Size end
    end
    local Atlas = iconRegistry[IconSize]

    Lucide.Icons = iconIndices
    function Lucide.GetAsset(name: string)
        local iconIndex = IconLookup[name]
        if not iconIndex then return nil end
        local icon = Atlas and Atlas[iconIndex]
        if icon then
            return {
                IconName = name,
                Url = idIndices[icon[1]],
                ImageRectSize = Vector2_new(icon[2][1], icon[2][2]),
                ImageRectOffset = Vector2_new(icon[3][1], icon[3][2]),
            }
        end

        return nil
    end

    Library.Icons = Lucide
end

local function IsNumeric(Value)
    return typeof(Value) == "number"
        or (typeof(Value) == "string" and #Value > 0 and Value:match("^%d+$") ~= nil)
end

local function IsUrl(Value)
    if typeof(Value) ~= "string" or Value == "" then return false end
    return Value:match("^rbxasset://") ~= nil
        or Value:match("^rbxassetid://") ~= nil
        or Value:match("^rbxthumb://") ~= nil
        or Value:match("^https?://") ~= nil
        or Value:match("^content://") ~= nil
end

function Library:GetIcon(Name)
    if not Name then return nil end

    if IsNumeric(Name) then
        return { Url = "rbxassetid://" .. tostring(Name), ImageRectOffset = Vector2_zero, ImageRectSize = Vector2_zero }
    end

    if IsUrl(Name) then
        return { Url = Name, ImageRectOffset = Vector2_zero, ImageRectSize = Vector2_zero, Custom = true }
    end

    if typeof(Name) == "string" then
        local Cached = Library.IconCache[Name]
        if Cached ~= nil then return Cached or nil end

        if not Library.Icons then
            Library.IconCache[Name] = false
            return nil
        end

        local Ok, Asset = pcall(Library.Icons.GetAsset, Name)
        if Ok and Asset then
            Library.IconCache[Name] = Asset
            return Asset
        end

        Library.IconCache[Name] = false
        return nil
    end

    return nil
end

function Library:ApplyIcon(ImageGui, Icon, Rotation)
    if not ImageGui or not Icon then return end
    if not (ImageGui:IsA("ImageLabel") or ImageGui:IsA("ImageButton")) then return end
    if not ImageGui:GetAttribute("ThemeIcon") then
        ImageGui:SetAttribute("ThemeIcon", true)
        ImageGui:SetAttribute("ThemeIconOriginalColor", ImageGui.ImageColor3)
    end
    if IsLightTheme(ThemeName) then
        ImageGui.ImageColor3 = ImageGui:GetAttribute("MainTitleIcon") and Color3_fromRGB(15, 17, 20) or Color3_fromRGB(50, 55, 60)
        if ImageGui:GetAttribute("MainTitleIcon") then ImageGui.ImageTransparency = math_min(ImageGui.ImageTransparency, 0.12) end
    end

    if Rotation then
        ImageGui.Rotation = Rotation
    end

    ImageGui.Image = Icon.Url or ImageGui.Image
    ImageGui.ImageRectOffset = Icon.ImageRectOffset or ImageGui.ImageRectOffset
    ImageGui.ImageRectSize = Icon.ImageRectSize or ImageGui.ImageRectSize
end

local function ResolveValueImage(images, value, rawValue)
    if typeof(images) ~= "table" then return nil end
    local ref = images[value]
    if ref == nil and rawValue ~= nil then ref = images[rawValue] end
    if typeof(ref) == "table" then
        if typeof(ref.Url) == "string" then return ref end
        return nil
    end
    return Library:GetIcon(ref)
end

local UI = Create("ScreenGui", {
    DisplayOrder = 998,
    Name = "Library",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})

ParentUI(UI)

local AddAnimatedBorder
local animateThemeColor

local TooltipBox, TooltipText, TooltipToken = nil, nil, 0
local function AttachTooltip(Target, Options, Kind)
    local Content = Options.Tooltip
    if Content == nil then Content = Options.Description end
    if type(Content) ~= "string" or Content == "" then return end
    local function Hide()
        TooltipToken += 1
        if TooltipBox then TooltipBox.Visible = false end
    end
    local function ShowLater()
        TooltipToken += 1
        local token = TooltipToken
        task_delay(0.55, function()
            if token ~= TooltipToken or not Target.Parent or not UI.Parent or Library.Unloaded or Library.Opened == false then return end
            if not TooltipBox or not TooltipBox.Parent then
                TooltipBox = Create("Frame", {Name = "Tooltip", BackgroundColor3 = ThemeColor(30,30,30), Visible = false, ZIndex = 100, Parent = UI})
                Create("UICorner", {CornerRadius = UDim_new(0, 7), Parent = TooltipBox})
                Create("UIStroke", {Color = ThemeColor(80,80,80), Thickness = 1, Parent = TooltipBox})
                TooltipText = Create("TextLabel", {BackgroundTransparency = 1, FontFace = RegularFont, TextColor3 = ThemeColor(255,255,255), TextSize = 14, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2_fromOffset(10, 6), Size = UDim2_new(1, -20, 1, -12), ZIndex = 101, Parent = TooltipBox})
            end
            TooltipText.Text = Content
            TooltipBox.BackgroundColor3 = ThemeColor(30,30,30)
            local bounds = GetTextBounds(Content, RegularFont, 14, 230) or Vector2_new(120, 18)
            local width, height = math_clamp(bounds.X + 20, 100, 250), math_max(30, bounds.Y + 12)
            local camera = workspace.CurrentCamera
            local viewport = camera and camera.ViewportSize or Vector2_new(800, 600)
            local pos = Target.AbsolutePosition
            local x = math_clamp(pos.X, 4, math_max(4, viewport.X - width - 4))
            local y = pos.Y + Target.AbsoluteSize.Y + 6
            if y + height > viewport.Y - 4 then y = math_max(4, pos.Y - height - 6) end
            TooltipBox.Position, TooltipBox.Size = UDim2_fromOffset(x,y), UDim2_fromOffset(width,height)
            TooltipBox.Visible = true
        end)
    end
    Library:AddConnection(Target.MouseEnter:Connect(ShowLater))
    Library:AddConnection(Target.MouseLeave:Connect(Hide))
    Library:AddConnection(Target.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.Touch then ShowLater() end end))
    Library:AddConnection(Target.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.Touch then Hide() end end))
end

local Windows = Create("Frame", {
    AnchorPoint = Vector2_new(0, 0),
    BackgroundTransparency = 1,
    Position = UDim2_fromOffset(6, 6),
    Size = UDim2_new(1, -12, 1, -12),
    Parent = UI
})

local Notifications = Create("Frame", {
    AnchorPoint = Vector2_new(1, 1),
    BackgroundTransparency = 1,
    Position = UDim2_new(1, -8, 1, -8),
    Size = UDim2_new(0, 480, 1, -12),
    Parent = UI
})

Create("UIListLayout", {
    HorizontalAlignment = Enum.HorizontalAlignment.Right,
    VerticalAlignment = Enum.VerticalAlignment.Bottom,
    Padding = UDim_new(0, 6),
    Parent = Notifications
})

local CheckIcon    = Library:GetIcon("check")
local ArrowIcon    = Library:GetIcon("chevron-up")
local ResizeIcon   = Library:GetIcon("move-diagonal-2")
local KeyIcon      = Library:GetIcon("key")
local MoveIcon     = Library:GetIcon("move")
local PopOutIcon   = Library:GetIcon("square-arrow-out-up-right")
local PopInIcon    = Library:GetIcon("square-arrow-out-down-right")
local CloseIcon    = Library:GetIcon("x")
local SettingsIcon = Library:GetIcon("settings")
local LockIcon     = Library:GetIcon("lock")

local FastTween = TweenInfo_new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function TrimString(s)
    return typeof(s) == "string" and s:match("^%s*(.-)%s*$") or ""
end

local function IsStringEmpty(s)
    return typeof(s) ~= "string" or TrimString(s) == ""
end

function Library:GetConfigDirectory()
    if IsStringEmpty(self.SaveFolder) then return nil end
    return self.SaveFolder
end

function Library:GetConfigPath(name)
    local dir = self:GetConfigDirectory()
    if not dir then return nil end
    return string_format("%s/%s.json", dir, name)
end

function Library:GetAutoloadPath()
    local dir = self:GetConfigDirectory()
    if not dir then return nil end
    return dir .. "/autoload.txt"
end

function Library:EnsureConfigFolder()
    local dir = self:GetConfigDirectory()
    if not dir then return false end
    if not is_folder(dir) then
        make_folder(dir)
    end
    return is_folder(dir)
end

local ElementSerializers = {}

ElementSerializers.Toggle = {
    Save = function(flag, el)
        return { type = "Toggle", idx = flag, value = el.Value and true or false }
    end,
    Load = function(flag, data)
        local el = Library.Flags[flag]
        if not el or el.Type ~= "Toggle" then return end
        el:Set(data.value and true or false)
    end,
}

ElementSerializers.Slider = {
    Save = function(flag, el)
        return { type = "Slider", idx = flag, value = tonumber(el.Value) or 0 }
    end,
    Load = function(flag, data)
        local el = Library.Flags[flag]
        if not el or el.Type ~= "Slider" then return end
        el:Set(tonumber(data.value) or 0)
    end,
}

ElementSerializers.Stepper = {
    Save = function(Flag, Element)
        return {type = "Stepper", idx = Flag, value = tonumber(Element.Value) or 0}
    end,
    Load = function(Flag, Data)
        local Element = Library.Flags[Flag]
        if not Element or Element.Type ~= "Stepper" then return end
        Element:Set(tonumber(Data.value) or Element.Min)
    end,
}

ElementSerializers.Textbox = {
    Save = function(flag, el)
        return { type = "Textbox", idx = flag, text = tostring(el.Text or "") }
    end,
    Load = function(flag, data)
        local el = Library.Flags[flag]
        if not el or el.Type ~= "Textbox" then return end
        if typeof(data.text) ~= "string" then return end
        el:Set(data.text)
    end,
}

ElementSerializers.Dropdown = {
    Save = function(flag, el)
        local v = el.Value
        if typeof(v) == "table" then
            local copy = {}
            for k, on in pairs(v) do if on then copy[k] = true end end
            v = copy
        end
        return { type = "Dropdown", idx = flag, value = v, multi = el.Multi }
    end,
    Load = function(flag, data)
        local el = Library.Flags[flag]
        if not el or el.Type ~= "Dropdown" then return end
        el:SetValue(data.value)
    end,
}

ElementSerializers.KeyPicker = {
    Save = function(flag, el)
        return {
            type = "KeyPicker", idx = flag,
            mode = el.Mode or "Toggle",
            keybind = el.Keybind and tostring(el.Keybind) or "nil",
            state = el.State and true or false,
        }
    end,
    Load = function(flag, data)
        local el = Library.Flags[flag]
        if not el or el.Type ~= "KeyPicker" then return end
        local kb = nil
        if data.keybind and data.keybind ~= "nil" then
            kb = GetKeybindFromString(data.keybind)
        end
        el:SetKeybind(kb)
        if data.mode and el.SetMode then el:SetMode(data.mode) elseif data.mode then el.Mode = data.mode end
        if data.mode == "Toggle" and data.state ~= nil and el.SetState then
            el:SetState(data.state and true or false)
        end
    end,
}

ElementSerializers.ColorPicker = {
    Save = function(flag, el)
        return {
            type = "ColorPicker", idx = flag,
            color = el.Color and el.Color:ToHex() or "ffffff",
            transparency = el.Transparency, rainbow = el.Rainbow,
        }
    end,
    Load = function(flag, data)
        local el = Library.Flags[flag]
        if not el or el.Type ~= "ColorPicker" then return end
        local col = Color3_fromHex(data.color or "ffffff")
        el:SetRainbow(false)
        el:SetColor(col)
        if data.transparency ~= nil then el:SetTransparency(data.transparency) end
        if data.rainbow ~= nil then el:SetRainbow(data.rainbow) end
    end,
}

function Library:RefreshConfigList()
    local dir = self:GetConfigDirectory()
    if not dir then return {} end
    if not is_folder(dir) then make_folder(dir) end

    local files = listfiles(dir)
    local names = {}
    for _, full in ipairs(files) do
        local fname = full:match("([^/\\]+)%.json$")
        if fname and fname ~= "autoload" and fname ~= "Favorites" then
            table_insert(names, fname)
        end
    end
    return names
end

function Library:SaveConfigData(name)
    local data = {
        timestamp = os_date("%d.%m.%Y %H:%M:%S"),
        name = name or "",
        objects = {},
    }

    for flag, el in pairs(Library.Flags) do
        if el.Type then
            local serializer = ElementSerializers[el.Type]
            if serializer then
                local entry = serializer.Save(flag, el)
                if entry then
                    table_insert(data.objects, entry)
                end
            end
        end
    end

    return HttpService:JSONEncode(data)
end

function Library:LoadConfigData(content)
    if IsStringEmpty(content) then return false, "No data" end

    local decoded = HttpService:JSONDecode(content)
    if typeof(decoded) ~= "table" or typeof(decoded.objects) ~= "table" then
        return false, "Invalid data"
    end

    local TOGGLE_TYPES = {
        Toggle = true,
    }

    local function StartsWithNumber(str)
        if typeof(str) ~= "string" or #str == 0 then return false end
        return str:match("^%d") ~= nil
    end

    local bucketPriority = {}
    local bucketToggles = {}

    for _, opt in ipairs(decoded.objects) do
        if opt.type and ElementSerializers[opt.type] then
            local isToggle = TOGGLE_TYPES[opt.type] == true
            if isToggle then
                table_insert(bucketToggles, opt)
            elseif StartsWithNumber(opt.idx) then
                table_insert(bucketPriority, opt)
            else
                table_insert(bucketToggles, nil)
            end
        end
    end

    bucketPriority = {}
    local bucketNormal = {}
    bucketToggles = {}

    for _, opt in ipairs(decoded.objects) do
        if opt.type and ElementSerializers[opt.type] then
            local isToggle = TOGGLE_TYPES[opt.type] == true
            if isToggle then
                table_insert(bucketToggles, opt)
            elseif StartsWithNumber(opt.idx) then
                table_insert(bucketPriority, opt)
            else
                table_insert(bucketNormal, opt)
            end
        end
    end

    local function apply(list)
        for _, opt in ipairs(list) do
            local serializer = ElementSerializers[opt.type]
            if serializer then
                task_defer(serializer.Load, opt.idx, opt)
            end
        end
    end

    apply(bucketPriority)
    apply(bucketNormal)
    apply(bucketToggles)

    return true
end

function Library:SaveConfig(name)
    if IsStringEmpty(name) then return false, "Invalid name" end
    if name:lower() == "autoload" then return false, "Reserved name" end
    if not self:EnsureConfigFolder() then return false, "Folder unavailable" end

    local path = self:GetConfigPath(name)
    if not path then return false, "Invalid path" end

    local encoded = self:SaveConfigData(name)
    write_file(path, encoded)
    return true
end

function Library:LoadConfig(name)
    if IsStringEmpty(name) then return false, "No config selected" end
    local path = self:GetConfigPath(name)
    if not path or not is_file(path) then return false, "Config does not exist" end

    local content = read_file(path)
    return self:LoadConfigData(content)
end

function Library:DeleteConfig(name)
    if IsStringEmpty(name) then return false, "No config selected" end
    local path = self:GetConfigPath(name)
    if not path or not is_file(path) then return false, "Config does not exist" end

    delete_file(path)
    if name == self.AutoloadConfigName then
        self:DeleteAutoloadConfig()
    end
    return true
end

function Library:GetAutoloadConfig()
    self:EnsureConfigFolder()
    local path = self:GetAutoloadPath()
    if not path or not is_file(path) then return "None", false end

    local name = read_file(path)
    if typeof(name) ~= "string" then return "None", false end
    if not self:GetConfigPath(name) or not is_file(self:GetConfigPath(name)) then
        return "None", false
    end

    self.AutoloadConfigName = name
    return name, true
end

function Library:SaveAutoloadConfig(name)
    if IsStringEmpty(name) then return false, "No config selected" end
    self:EnsureConfigFolder()
    local path = self:GetAutoloadPath()
    if not path then return false, "Invalid path" end
    if not self:GetConfigPath(name) or not is_file(self:GetConfigPath(name)) then
        return false, "Config does not exist"
    end
    write_file(path, name)
    self.AutoloadConfigName = name
    return true
end

function Library:DeleteAutoloadConfig()
    self:EnsureConfigFolder()
    local path = self:GetAutoloadPath()
    if not path or not is_file(path) then return false, "Not set" end
    delete_file(path)
    self.AutoloadConfigName = nil
    return true
end

function Library:LoadAutoloadConfig()
    local name, ok = self:GetAutoloadConfig()
    if not ok then return end
    self:LoadConfig(name)
end

Library._PaletteFeatures = {}
Library._PaletteLocks = {}
local function PaletteValueText(value)
    if typeof(value) == "Color3" then return "#" .. value:ToHex():upper() end
    if typeof(value) == "EnumItem" then return value.Name end
    if type(value) == "table" then
        local names = {}
        for key, active in pairs(value) do if active == true then table_insert(names, tostring(key)) end end
        table_sort(names)
        return #names > 0 and table_concat(names, ", ") or "None"
    end
    if value == nil then return "None" end
    if type(value) == "boolean" then return value and "true" or "false" end
    return tostring(value)
end
local function RefreshPaletteValue(entry)
    if not Library._PaletteBatch and entry and Library.UpdatePaletteValue and Library:UpdatePaletteValue(entry) then return end
    Library._PaletteDirty = true
    if Library._PaletteBatch then return end
    local overlay = UI:FindFirstChild("CommandPaletteOverlay")
    if not overlay or not overlay.Visible or overlay:GetAttribute("Closing") then return end
    if Library.RefreshCommandPalette then Library:RefreshCommandPalette() end
end
local function ResolvePaletteOptions(control, raw)
    local resolved, seen = {}, {}
    local values = control.Values or {}
    for part in (raw .. ","):gmatch("(.-),") do
        local query = part:match("^%s*(.-)%s*$"):lower()
        if query == "" then return nil, "Enter an option between commas." end
        local best, bestDistance, ambiguous = nil, math_huge, false
        for key, item in pairs(values) do
            local option = type(key) == "number" and item or key
            local candidate = tostring(option):lower()
            if #query <= 128 and #candidate <= 128 then
                local matrix = {}
                for i = 0, #query do matrix[i] = {[0] = i} end
                for j = 0, #candidate do matrix[0][j] = j end
                for i = 1, #query do for j = 1, #candidate do
                    local cost = query:sub(i,i) == candidate:sub(j,j) and 0 or 1
                    local d = math_min(matrix[i-1][j] + 1, matrix[i][j-1] + 1, matrix[i-1][j-1] + cost)
                    if i > 1 and j > 1 and query:sub(i,i) == candidate:sub(j-1,j-1) and query:sub(i-1,i-1) == candidate:sub(j,j) then d = math_min(d, matrix[i-2][j-2] + 1) end
                    matrix[i][j] = d
                end end
                local score = matrix[#query][#candidate]
                if score < bestDistance then best, bestDistance, ambiguous = option, score, false
                elseif score == bestDistance then ambiguous = true end
            end
        end
        local limit = #query >= 5 and 2 or 1
        if best == nil or bestDistance > limit or ambiguous then return nil, "Option not found or ambiguous: " .. part end
        if not seen[best] then table_insert(resolved, best); seen[best] = true end
    end
    if not control.Multi and #resolved ~= 1 then return nil, "Choose one option." end
    return resolved
end
local function PublishPaletteFeature(entry)
    if entry.Published or not Library.AddCommand then return end
    if entry.Auto and not Library.ShowLibrarysFeatures then return end
    local commandName = entry.Category .. " / " .. entry.Name
    for _, existing in ipairs(Library:GetCommands()) do
        if existing.Name:lower() == commandName:lower() then return end
    end
    entry.CommandName = commandName
    local arguments = entry.Kind == "Button" and {} or {"value"}
    Library:AddCommand({Name = commandName, Category = entry.Category, Kind = "Feature", FeatureKind = entry.Kind, FeatureEntry = entry, Icon = entry.Icon, Tag = entry.Tag, Arguments = arguments,
        OptionalArguments = true, Description = entry.Description or "", ValueText = function()
            if not entry.GetValue then return "" end
            local value = entry.GetValue()
            if type(entry.DisplayFormat) == "function" then local ok, formatted = pcall(entry.DisplayFormat, value, entry.Control); if ok and formatted ~= nil then return tostring(formatted) end
            elseif type(entry.DisplayFormat) == "string" then local ok, formatted = pcall(string_format, entry.DisplayFormat, type(value) == "table" and PaletteValueText(value) or value); if ok then return formatted end end
            return PaletteValueText(value)
        end,
        Callback = function(args)
            for category, locked in pairs(Library._PaletteLocks) do
                if locked and (entry.Category == category or entry.Category:sub(1, #category + 3) == category .. " / ") then return end
            end
            if entry.Control and entry.Control.Locked then return end
            if entry.Kind == "Button" then if entry.Activate then entry.Activate() end; return end
            local raw = table_concat(args or {}, " ")
            local current = entry.GetValue and entry.GetValue() or nil
            local value = raw
            if entry.Kind == "Toggle" then
                local lower = raw:lower()
                if lower == "" or lower == "toggle" then value = not current
                elseif lower == "true" or lower == "on" or lower == "1" then value = true
                elseif lower == "false" or lower == "off" or lower == "0" then value = false
                else warn("Use on, off or toggle for " .. entry.Name); return end
            elseif entry.Kind == "Slider" or entry.Kind == "Stepper" then
                value = tonumber(raw)
                if not value or value ~= value or value == math_huge or value == -math_huge then warn("Enter a number for " .. entry.Name); return end
            elseif entry.Kind == "Keybind" then
                if raw:lower() == "none" then value = nil else value = GetKeybindFromString(raw); if not value then warn("Invalid keybind: " .. raw); return end end
            elseif entry.Kind == "Color" then
                local hex = raw:match("^#?(%x%x%x%x%x%x)$")
                local r, g, b = raw:match("^(%d+)%s*,%s*(%d+)%s*,%s*(%d+)$")
                if hex then value = Color3_fromHex(hex)
                elseif r and tonumber(r) <= 255 and tonumber(g) <= 255 and tonumber(b) <= 255 then value = Color3_fromRGB(tonumber(r), tonumber(g), tonumber(b))
                else warn("Use #RRGGBB or R, G, B for " .. entry.Name); return end
            elseif entry.Kind == "Dropdown" and entry.Control then
                if raw == "" then return end
                local selected, errorMessage = ResolvePaletteOptions(entry.Control, raw)
                if not selected then warn(errorMessage); return end
                if entry.Control.Multi then
                    local nextValues = table_clone(entry.Control.Value or {})
                    for _, option in ipairs(selected) do
                        if #selected == 1 then nextValues[option] = not nextValues[option] or nil else nextValues[option] = true end
                    end
                    value = nextValues
                else value = selected[1] end
            elseif raw == "" then return end
            if entry.SetValue then entry.SetValue(value) end
            RefreshPaletteValue(entry)
        end,
    })
    entry.Published = true
end
function Library:RegisterPaletteFeature(info)
    assert(type(info) == "table" and type(info.Name) == "string" and info.Name:match("%S"), "A feature needs a name")
    local entry = {Name = info.Name, Category = tostring(info.Category or info.Section or "Custom"), Kind = info.Kind or info.Type or "Custom",
        Control = info.Control, GetValue = info.GetValue or info.Get, SetValue = info.SetValue or info.Set,
        Description = info.Description, Activate = info.Activate, Icon = info.Icon, Tag = info.Tag or info.Label, DisplayFormat = info.DisplayFormat, Auto = info.Auto == true}
    table_insert(self._PaletteFeatures, entry)
    PublishPaletteFeature(entry)
    function entry:Refresh() RefreshPaletteValue(self) end
    function entry:Destroy()
        if self.Published and Library.RemoveCommand then Library:RemoveCommand(self.CommandName) end
        self.Published = false
        local index = table_find(Library._PaletteFeatures, self)
        if index then table_remove(Library._PaletteFeatures, index) end
    end
    return entry
end
function Library:SetShowLibrarysFeatures(enabled)
    self.ShowLibrarysFeatures = enabled == true
    self._PaletteBatch = true
    for _, entry in ipairs(self._PaletteFeatures) do
        if entry.Auto then
            if self.ShowLibrarysFeatures then PublishPaletteFeature(entry)
            elseif entry.Published then self:RemoveCommand(entry.CommandName); entry.Published = false end
        end
    end
    self._PaletteBatch = false
    RefreshPaletteValue()
end
Library.SetShowLibraryFeatures = Library.SetShowLibrarysFeatures
local function RegisterControlForPalette(container, info, control, kind)
    if type(info.Name) ~= "string" or info.Name == "" then return end
    local category = container._PaletteCategory or "Features"
    local setter = kind == "Dropdown" and "SetValue" or kind == "Keybind" and "SetKeybind" or kind == "Color" and "SetColor" or "Set"
    local entry = Library:RegisterPaletteFeature({Name = info.Name, Category = category, Kind = kind, Control = control, DisplayFormat = info.DisplayFormat, Auto = true,
        GetValue = function()
            if kind == "Textbox" then return control.Text end
            if kind == "Color" then return control.Color end
            if kind == "Keybind" then return control.Keybind end
            return control.Value
        end,
        SetValue = function(value) control[setter](control, value) end,
    })
    local refreshMethod = kind == "Color" and "Update" or setter
    local original = control[refreshMethod]
    if type(original) == "function" then
        control[refreshMethod] = function(self, ...)
            local values = table_pack(original(self, ...))
            if entry.Published and kind == "Color" and control.Rainbow then Library._PaletteDirty = true end
            if entry.Published and not (kind == "Color" and control.Rainbow) then RefreshPaletteValue(entry) end
            return table_unpack(values, 1, values.n)
        end
    end
end

local AttachDPIScale
local activeOption
local openOptions = {}
local function IsOpenOptionAncestor(object)
    for option in pairs(openOptions) do
        if option.Opened and object:IsDescendantOf(option.Container) then return true end
    end
    return false
end
local activeDialogue
local BaseComponents = {}  do
    local Components = {}

    function Components:AddDivider(...)
        local Params = select(1, ...)
        local Text
        local MarginTop = 5
        local MarginBottom = 5
        local Fade = 0.5
        local Inset = 6 

        if typeof(Params) == "table" then
            Text = Params.Text
            MarginTop = Params.MarginTop or Params.Margin or MarginTop
            MarginBottom = Params.MarginBottom or Params.Margin or MarginBottom
            Fade = Params.Fade or Fade
            Inset = Params.Inset or Inset
        elseif typeof(Params) == "string" then
            Text = Params
        end

        local Holder = Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2_new(1, 0, 0, 6 + MarginTop + MarginBottom),
            Parent = self.Container,
        })

        Create("UIPadding", {
            PaddingTop = UDim_new(0, MarginTop),
            PaddingBottom = UDim_new(0, MarginBottom),
            Parent = Holder,
        })

        local InnerHolder = Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2_new(1, -Inset * 2, 1, 0),
            Position = UDim2_fromOffset(Inset, 0),
            Parent = Holder,
        })

        local function MakeLine(size, position, anchor, leftFade, rightFade)
            local line = Create("Frame", {
                AnchorPoint = anchor,
                BackgroundColor3 = ThemeColor(60, 60, 60),
                BorderSizePixel = 0,
                Position = position,
                Size = size,
                Parent = InnerHolder,
            })

            local fade = math_clamp(Fade, 0.01, 0.49)
            Create("UIGradient", {
                Transparency = NumberSequence_new({
                    NumberSequenceKeypoint_new(0, leftFade and 1 or 0),
                    NumberSequenceKeypoint_new(fade, 0),
                    NumberSequenceKeypoint_new(1 - fade, 0),
                    NumberSequenceKeypoint_new(1, rightFade and 1 or 0),
                }),
                Parent = line,
            })
            return line
        end

        if Text then
            local TextLabel = Create("TextLabel", {
                TextYAlignment = Enum.TextYAlignment.Center,
                BackgroundTransparency = 1,
                Size = UDim2_fromScale(1, 1),
                Text = Text,
                FontFace = RegularFont,
                TextSize = 14,
                TextColor3 = ThemeColor(255, 255, 255),
                TextTransparency = ThemeTextAlpha(0.5),
                TextXAlignment = Enum.TextXAlignment.Center,
                Parent = InnerHolder,
            })

            local bounds = GetTextBounds(Text, RegularFont, 14, Library.UISize - 24)
            local X = bounds and bounds.X or 60
            local SizeX = math_floor(X / 2) + 10

            MakeLine(
                UDim2_new(0.5, -SizeX, 0, 2),
                UDim2_fromScale(0, 0.5),
                Vector2_new(0, 0.5),
                true,
                false
            )

            MakeLine(
                UDim2_new(0.5, -SizeX, 0, 2),
                UDim2_fromScale(1, 0.5),
                Vector2_new(1, 0.5),
                false,
                true
            )
        else
            MakeLine(
                UDim2_new(1, 0, 0, 2),
                UDim2_fromScale(0, 0.5),
                Vector2_new(0, 0.5),
                true,
                true
            )
        end

        local Divider = {
            Holder = Holder,
            Text = Text,
            MarginTop = MarginTop,
            MarginBottom = MarginBottom,
            Type = "Divider",
        }

        function Divider:SetVisible(Value)
            Holder.Visible = Value == true
        end

        function Divider:Destroy()
            if Holder then Holder:Destroy() end
        end

        return Divider
    end

    function Components:AddLabel(text: string)
        local TextLabel = Create("TextLabel", {
            BackgroundTransparency = 1,
            FontFace = RegularFont,
            RichText = true,
            Size = UDim2_new(1, 0, 0, 0),
            Text = "",
            TextColor3 = ThemeColor(255, 255, 255),
            TextSize = 15,
            TextTransparency = ThemeTextAlpha(0.5),
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = self.Container
        })

        Create("UIPadding", {
            PaddingLeft = UDim_new(0, 14),
            PaddingRight = UDim_new(0, 14),
            PaddingTop = UDim_new(0, 4),
            PaddingBottom = UDim_new(0, 4),
            Parent = TextLabel
        })

        local Label = { Text = text or "No Text" }

        function Label:Set(newText: string)
            Label.Text = newText
            local size = GetTextBounds(Label.Text, RegularFont, 15, Library.UISize - 24)
            if size then
                TextLabel.Size = UDim2_new(1, 0, 0, size.Y + 15)
            end
            TextLabel.Text = Label.Text
        end

        Label:Set(Label.Text)
        return Label
    end

    function Components:AddButton(options: ButtonOptions)
        local ButtonHolder = Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2_new(1, 0, 0, 42),
            Parent = self.Container
        })
        AttachTooltip(ButtonHolder, options, "Button")

        Create("UIPadding", {
            PaddingBottom = UDim_new(0, 5),
            PaddingLeft = UDim_new(0, 13),
            PaddingRight = UDim_new(0, 13),
            PaddingTop = UDim_new(0, 5),
            Parent = ButtonHolder
        })

        local ActualButton: TextButton = Create("TextButton", {
            TextYAlignment = Enum.TextYAlignment.Center,
            AutoButtonColor = false,
            BackgroundColor3 = ThemeColor(25, 25, 25),
            FontFace = RegularFont,
            Size = UDim2_fromScale(1, 1),
            Text = options.Name or "Button",
            TextColor3 = ThemeColor(255, 255, 255),
            TextScaled = false, TextSize = 15,
            TextTransparency = ThemeTextAlpha(0.5),
            Parent = ButtonHolder
        })

        Create("UICorner", { CornerRadius = UDim_new(0, 6), Parent = ActualButton })
        
        Create("UIPadding", {
            PaddingBottom = UDim_new(0, 6),
            PaddingLeft = UDim_new(0, 6),
            PaddingRight = UDim_new(0, 6),
            PaddingTop = UDim_new(0, 6),
            Parent = ActualButton,
        })

        local ButtonStroke = Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = ThemeColor(60, 60, 60),
            Parent = ActualButton
        })

        local ButtonIcons = {["Save Position"] = "map-pin", ["Reset Position"] = "rotate-ccw", ["Unload"] = "power", ["Create Config"] = "plus", ["Load config"] = "download", ["Delete config"] = "trash", ["Overwrite config"] = "pencil-line", ["Set autoload"] = "cloud", ["Reset autoload"] = "rotate-ccw", ["Refresh list"] = "brush-cleaning"}
        local IconName = options.Icon or ButtonIcons[options.Name]
        local IconDefinition = IconName and Library:GetIcon(IconName)
        if IconDefinition then
            ActualButton:FindFirstChildOfClass("UIPadding").PaddingLeft = UDim_new(0, 18)
            local Icon = Create("ImageLabel", {BackgroundTransparency = 1, Image = "", Size = UDim2_fromOffset(16, 16), ImageColor3 = options.Name == "Save Position" and ThemeColor(60, 200, 100) or ThemeColor(220, 220, 220), Parent = ActualButton})
            if options.Name == "Save Position" then Icon:SetAttribute("ThemeAccentIcon", true) end
            Library:ApplyIcon(Icon, IconDefinition)
            local function PositionIcon()
                local Bounds = GetTextBounds(ActualButton.Text, RegularFont, 15, 1000)
                local Width = Bounds and Bounds.X or 60
                local ownScale = ActualButton:FindFirstChildOfClass("UIScale")
                local scale = (Library.MobileScale and Library.MobileScale.Scale or 1) * (ownScale and ownScale.Scale or 1)
                local Available = math_max(0, ActualButton.AbsoluteSize.X / math_max(scale, 0.001) - 24)
                Tween(Icon, TweenInfo_new(0.10, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2_new(0, math_max(0, (Available - math_min(Width, math_max(0, Available - 20))) / 2 - 20), 0.5, -8)})
            end
            Library:AddConnection(ActualButton:GetPropertyChangedSignal("AbsoluteSize"):Connect(PositionIcon))
            Library:AddConnection(ActualButton:GetPropertyChangedSignal("Text"):Connect(PositionIcon))
            PositionIcon()
        end
        if options.Name == "Save Position" then
            ButtonStroke.Color = ThemeColor(60, 200, 100)
            ActualButton:SetAttribute("ThemeAccentButton", true)
            ActualButton.BackgroundColor3 = ThemeColor(25, 25, 25):Lerp(ThemeColor(60, 200, 100), 0.09)
        end
        Create("UIGradient", {Color = ColorSequence_new(Color3_fromRGB(255,255,255), Color3_fromRGB(205,205,205)), Rotation = 90, Parent = ActualButton})

        local buttonScale = Create("UIScale", {Scale = 1, Parent = ActualButton})
        local buttonPressTween
        local function AnimateButtonPress()
            if buttonPressTween then buttonPressTween:Cancel() end
            buttonScale.Scale = 0.96
            buttonPressTween = TweenService:Create(buttonScale, TweenInfo_new(0.24, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1})
            buttonPressTween:Play()
        end
        local Button = {
            Hovering = false,
            Locked = false,
            TimesClicked = 0,
            Clicking = false,
            Name = options.Name or "Button",
            DoubleClick = options.DoubleClick or false,
            Type = "Button"
        }

        function Button:SetClicking(clicking)
            Button.Clicking = clicking
            ActualButton.Text = Button.Clicking and "Are you sure?" or options.Name
            ActualButton.TextTransparency = ThemeTextAlpha(Button.Clicking and 0 or (Button.Hovering and 0.25 or 0.5))
        end

        ActualButton.MouseEnter:Connect(function()
            Button.Hovering = true
            ButtonStroke.Color = options.Name == "Save Position" and ThemeColor(60, 200, 100) or HoveringToggleColor
            if not Button.Clicking then
                Tween(ActualButton, FastTween, {TextTransparency = ThemeTextAlpha(0.25)})
            end
        end)

        ActualButton.MouseLeave:Connect(function()
            Button.Hovering = false
            ButtonStroke.Color = options.Name == "Save Position" and ThemeColor(60, 200, 100) or DefaultToggleColor
            if not Button.Clicking then
                Tween(ActualButton, FastTween, {TextTransparency = ThemeTextAlpha(0.5)})
            end
        end)

        function Button:Confirm()
            if Button.Locked or Library.Unloaded then return false end
            Button:SetClicking(false)
            Button.TimesClicked += 1
            Library:SafeCallback(options.Callback, Button.TimesClicked)
            return true
        end

        function Button:Activate()
            if Button.Locked or Library.Unloaded then return end
            AnimateButtonPress()

            if Button.DoubleClick then
                if Button.Clicking then
                    Button:Confirm()
                else
                    Button:SetClicking(true)
                    task_delay(0.5, function()
                        if Button.Clicking then Button:SetClicking(false) end
                    end)
                end
                return
            end

            Button.TimesClicked += 1
            Library:SafeCallback(options.Callback, Button.TimesClicked)
        end
        ActualButton.MouseButton1Click:Connect(function() Button:Activate() end)
        Library:RegisterPaletteFeature({Name = options.Name or "Button", Category = self._PaletteCategory or "Features", Kind = "Button", Control = Button, Auto = true, Activate = function() Button:Activate() end})

        return Button
    end

    function Components:AddToggle(options: ToggleOptions)
        local IsCheckbox = options._Checkbox == true
        local ToggleHolder = Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2_new(1, 0, 0, 32),
            Parent = self.Container
        })
        AttachTooltip(ToggleHolder, options, "Toggle")

        Create("UIPadding", {
            PaddingLeft = UDim_new(0, 11),
            PaddingRight = UDim_new(0, 13),
            Parent = ToggleHolder
        })

        local ToggleText: TextLabel = Create("TextLabel", {
            TextYAlignment = Enum.TextYAlignment.Center,
            BackgroundTransparency = 1,
            FontFace = RegularFont,
            Size = UDim2_fromScale(1, 1),
            Text = options.Name or "Toggle",
            TextColor3 = ThemeColor(255, 255, 255),
            TextScaled = false, TextSize = 15,
            TextTruncate = Enum.TextTruncate.AtEnd,
            TextTransparency = ThemeTextAlpha(0.5),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = ToggleHolder
        })

        Create("UIPadding", {
            PaddingBottom = UDim_new(0, 6),
            PaddingRight = UDim_new(0, 36),
            PaddingTop = UDim_new(0, 6),
            Parent = ToggleText
        })

        local ToggleButton: TextButton = Create("TextButton", {
            AnchorPoint = Vector2_new(1, 0.5),
            AutoButtonColor = false,
            BackgroundColor3 = ThemeColor(35, 35, 35),
            BackgroundTransparency = 0,
            Position = UDim2_fromScale(1, 0.5),
            Size = IsCheckbox and UDim2_fromOffset(21, 21) or UDim2_fromOffset(32, 16),
            Text = "",
            Parent = ToggleHolder
        })

        Create("UICorner", { CornerRadius = IsCheckbox and UDim_new(0, 4) or UDim_new(1, 0), Parent = ToggleButton })
        Create("UIPadding", {
            PaddingBottom = UDim_new(0, 2),
            PaddingLeft = UDim_new(0, 2),
            PaddingRight = UDim_new(0, 2),
            PaddingTop = UDim_new(0, 2),
            Parent = ToggleButton,
        })

        local ToggleStroke = Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = ThemeColor(60, 60, 60),
            Parent = ToggleButton
        })

        Create("UIGradient", {Color = ColorSequence_new(Color3_fromRGB(255,255,255), Color3_fromRGB(190,190,190)), Rotation = 90, Parent = ToggleButton})

        local ToggleIcon = Create("Frame", {
            BackgroundColor3 = ThemeColor(60, 60, 60),
            Size = UDim2_fromScale(1, 1),
            SizeConstraint = Enum.SizeConstraint.RelativeYY,
            Parent = ToggleButton
        })

        ToggleIcon:SetAttribute("ThemeColorIgnore", true)
        Create("UICorner", { CornerRadius = UDim_new(1, 0), Parent = ToggleIcon })
        local CheckboxMark
        if IsCheckbox then
            ToggleIcon.BackgroundTransparency = 1
            CheckboxMark = Create("ImageLabel", {Name = "CheckboxMark", BackgroundTransparency = 1, Image = "", ImageColor3 = Color3_new(1,1,1), ImageTransparency = 1, Size = UDim2_fromScale(1,1), Parent = ToggleIcon})
            CheckboxMark:SetAttribute("ThemeColorIgnore", true)
            Library:ApplyIcon(CheckboxMark, Library:GetIcon("check"))
        end

        local LockedIcon = Create("Frame", {
            Name = "LockedToggleFrame",
            AnchorPoint = Vector2_new(1, 0.5),
            BackgroundColor3 = ThemeColor(25, 25, 25),
            Position = UDim2_new(1, 0, 0.5, 0),
            Size = UDim2_fromOffset(24, 24), Visible = false, Parent = ToggleHolder,
        })
        Create("UICorner", {CornerRadius = UDim_new(0, 6), Parent = LockedIcon})
        Create("UIStroke", {Color = ThemeColor(60, 60, 60), Parent = LockedIcon})
        local LockImage = Create("ImageLabel", {
            AnchorPoint = Vector2_new(0.5, 0.5), BackgroundTransparency = 1, Image = "",
            ImageTransparency = 0.3, Position = UDim2_fromScale(0.5, 0.5),
            Size = UDim2_fromOffset(16, 16), Parent = LockedIcon,
        })
        Library:ApplyIcon(LockImage, LockIcon)

        local LockedBlocker: TextButton = Create("TextButton", {
            BackgroundTransparency = 1,
            Size = UDim2_fromScale(1, 1),
            Text = "",
            Visible = false,
            ZIndex = 5,
            Parent = ToggleHolder,
        })

        local Toggle = {
            Hovering = false,
            Locked = false,
            Value = options.Default == true or (options.Default == nil and options.Value == true),
            Type = "Toggle"
        }

        Toggle._PaletteCategory = (self._PaletteCategory or "Features") .. " / " .. tostring(options.Name or "Toggle")

        function Toggle:AddOption(title, iconName, settings)
            
            settings = type(settings) == "table" and settings or {}
            if Toggle.Options then return Toggle.Options end
            local icon = Create("ImageButton", {
                AnchorPoint = Vector2_new(1, 0.5), BackgroundTransparency = 1,
                Position = UDim2_new(1, -38, 0.5, 0), Size = UDim2_fromOffset(17, 17),
                Image = "", ImageTransparency = 0.5, Parent = ToggleHolder
            })
            Toggle.OptionsIcon = icon
            if Toggle.KeyPicker then icon.Position = UDim2_new(1, -(Toggle._KeyWidth or 82) - 42, 0.5, 0) end
            Library:ApplyIcon(icon, Library:GetIcon("ellipsis"))
            ToggleText:FindFirstChildOfClass("UIPadding").PaddingRight = UDim_new(0, Toggle.KeyPicker and ((Toggle._KeyWidth or 82) + 64) or 60)
            local popup = Create("CanvasGroup", {
                Name = "ToggleOptions",
                BackgroundColor3 = ThemeColor(25, 25, 25),
                BorderSizePixel = 0,
                Size = UDim2_fromOffset(Library.UISize, 44),
                GroupTransparency = 1,
                Visible = false,
                ZIndex = 20,
                Parent = UI,
            })
            AttachDPIScale(popup)
            Create("UICorner", {CornerRadius = UDim_new(0, 6), Parent = popup})
            AddAnimatedBorder(popup)
            local header = Create("Frame", {
                BackgroundColor3 = ThemeColor(20, 20, 20),
                Size = UDim2_new(1, 0, 0, 40),
                ZIndex = 21,
                Parent = popup,
            })

            Create("UICorner", {CornerRadius = UDim_new(0, 6), Parent = header})
            Create("Frame", {
                BackgroundColor3 = ThemeColor(20, 20, 20),
                Position = UDim2_new(0, 0, 1, -6),
                Size = UDim2_new(1, 0, 0, 6),
                ZIndex = 21,
                Parent = header,
            })
            local hasIcon = iconName and Library:GetIcon(iconName)
            if hasIcon then
                local image = Create("ImageLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2_fromOffset(12, 10),
                    Size = UDim2_fromOffset(20, 20),
                    Image = "",
                    ImageTransparency = 0.3,
                    ZIndex = 22,
                    Parent = header,
                })
                Library:ApplyIcon(image, hasIcon)
            end
            local titleLabel = Create("TextLabel", {
                BackgroundTransparency = 1,
                FontFace = MediumFont,
                Position = UDim2_fromOffset(hasIcon and 40 or 12, 0),
                Size = UDim2_new(1, hasIcon and -76 or -48, 1, 0),
                Text = title or options.Name or "Options",
                TextColor3 = ThemeColor(255, 255, 255),
                TextSize = 16,
                TextTruncate = Enum.TextTruncate.AtEnd,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 22,
                Parent = header,
            })
            local resizeButton = Create("ImageButton", {
                BackgroundTransparency = 1,
                AutoButtonColor = false,
                AnchorPoint = Vector2_new(1, 0.5),
                Position = UDim2_new(1, -10, 0.5, 0),
                Size = UDim2_fromOffset(18, 18),
                Image = "",
                ImageTransparency = 0.5,
                ZIndex = 23,
                Parent = header,
            })
            Library:ApplyIcon(resizeButton, Library:GetIcon("minimize-2"))
            resizeButton.MouseEnter:Connect(function() Tween(resizeButton, FastTween, {ImageTransparency = 0.15}) end)
            resizeButton.MouseLeave:Connect(function() Tween(resizeButton, FastTween, {ImageTransparency = 0.5}) end)
            Create("Frame", {
                BackgroundColor3 = ThemeColor(60, 60, 60),
                Position = UDim2_fromOffset(0, 40),
                Size = UDim2_new(1, 0, 0, 1),
                ZIndex = 22,
                Parent = popup,
            })
            local contentHolder = Create("ScrollingFrame", {
                Active = true,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2_fromOffset(0, 41),
                Size = UDim2_new(1, 0, 1, -41),
                CanvasSize = UDim2_fromOffset(0, 0),
                ScrollBarThickness = 3,
                ScrollBarImageColor3 = ThemeColor(100, 100, 100),
                ZIndex = 21,
                Parent = popup,
            })

            local layout = Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Parent = contentHolder})
            local popupGrip = CreateDragGrip(UI, popup)
            local result = setmetatable({Container = contentHolder, Frame = popup, Grip = popupGrip, Opened = false, Minimized = false, Exclusive = settings.Exclusive ~= false, _PaletteCategory = Toggle._PaletteCategory}, BaseComponents)
            local fadeTween, fadeId = nil, 0
            local sizeTween
            local userMoved = false
            local savedPosition
            Toggle.Options = result
            local function GetHeight()
                local camera = workspace.CurrentCamera
                local viewport = camera and camera.ViewportSize or Vector2_new(800, 600)
                local dpi = Library.MobileScale.Scale
                return result.Minimized and 40 or math_min(math_max(layout.AbsoluteContentSize.Y / dpi + 41, 49), math_max(80, (viewport.Y - 24) / dpi))
            end
            local function RefreshSize(animate)
                contentHolder.CanvasSize = UDim2_fromOffset(0, layout.AbsoluteContentSize.Y / Library.MobileScale.Scale)
                if sizeTween then sizeTween:Cancel() sizeTween = nil end
                local size = UDim2_fromOffset(Library.UISize, GetHeight())
                if animate then
                    sizeTween = TweenService:Create(popup, TweenInfo_new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = size})
                    sizeTween:Play()
                else popup.Size = size end
            end
            local function PlaceNearToggle()
                local camera = workspace.CurrentCamera
                local viewport = camera and camera.ViewportSize or Vector2_new(800, 600)
                local p, size = icon.AbsolutePosition, icon.AbsoluteSize
                local width, height = Library.UISize * Library.MobileScale.Scale, GetHeight() * Library.MobileScale.Scale
                local x = p.X + size.X + 8
                if x + width > viewport.X - 6 then x = p.X - width - 8 end
                x = math_clamp(x, 6, math_max(6, viewport.X - width - 6))
                local y = math_clamp(p.Y, 6, math_max(6, viewport.Y - height - 6))
                local inset = game:GetService("GuiService"):GetGuiInset()
                local TargetPosition = UDim2_fromOffset(x - inset.X, y - inset.Y)
                if popup.Position ~= TargetPosition then popup.Position = TargetPosition end
            end
            function result:SetMinimized(minimized)
                self.Minimized = minimized == true
                popupGrip:SetAttribute("GripAllowed", not self.Minimized)
                Library:ApplyIcon(resizeButton, Library:GetIcon(self.Minimized and "maximize-2" or "minimize-2"))
                contentHolder.Visible = true
                RefreshSize(true)
            end
            resizeButton.MouseButton1Click:Connect(function() result:SetMinimized(not result.Minimized) end)
            function result:ReturnToToggle()
                if not self.Opened then return end
                local parent = ToggleHolder
                while parent and parent ~= Windows do
                    if parent:IsA("GuiObject") and (not parent.Visible or parent:GetAttribute("TabOpened") == false) then
                        userMoved = true
                        return
                    end
                    parent = parent.Parent
                end
                if parent ~= Windows then userMoved = true return end
                userMoved = false
                PlaceNearToggle()
            end
            function result:DetachToLeft()
                if not self.Opened then return end
                userMoved = true
                local camera = workspace.CurrentCamera
                local viewport = camera and camera.ViewportSize or Vector2_new(800, 600)
                local inset = game:GetService("GuiService"):GetGuiInset()
                local availableHeight = math_max(1, viewport.Y - inset.Y)
                local maxX = math_max(0, viewport.X - Library.UISize * Library.MobileScale.Scale)
                local maxY = math_max(0, availableHeight - GetHeight() * Library.MobileScale.Scale)
                local x = savedPosition and math_clamp(savedPosition.X, 0, maxX) or math_min(12, maxX)
                local y = savedPosition and math_clamp(savedPosition.Y, 0, maxY) or maxY * 0.38
                popup.Position = UDim2_fromOffset(x, y)
            end
            local dragInput, dragStart, dragPosition
            header.Active = true
            header.InputBegan:Connect(function(input)
                if input.UserInputType ~= Enum.UserInputType.Touch and input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
                local p, a, z = input.Position, resizeButton.AbsolutePosition, resizeButton.AbsoluteSize
                if p.X >= a.X and p.X <= a.X + z.X and p.Y >= a.Y and p.Y <= a.Y + z.Y then return end
                dragInput, dragStart, dragPosition = input, input.Position, popup.Position
            end)
            popupGrip.InputBegan:Connect(function(input)
                if input.UserInputType ~= Enum.UserInputType.Touch and input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
                dragInput, dragStart, dragPosition = input, input.Position, popup.Position
            end)
            Library:AddConnection(UserInputService.InputChanged:Connect(function(input)
                if not dragInput or not result.Opened then return end
                if input ~= dragInput and not (dragInput.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseMovement) then return end
                local delta = input.Position - dragStart
                if delta.Magnitude < 3 then return end
                userMoved = true
                local camera = workspace.CurrentCamera
                local viewport = camera and camera.ViewportSize or Vector2_new(800, 600)
                local x = math_clamp(dragPosition.X.Offset + delta.X, 0, math_max(0, viewport.X - popup.AbsoluteSize.X))
                local y = math_clamp(dragPosition.Y.Offset + delta.Y, 0, math_max(0, viewport.Y - popup.AbsoluteSize.Y))
                popup.Position = UDim2_fromOffset(x, y)
                savedPosition = Vector2_new(x, y)
            end))
            Library:AddConnection(UserInputService.InputEnded:Connect(function(input) if input == dragInput then dragInput = nil end end))
            local function fade(show)
                fadeId += 1
                local id = fadeId
                if fadeTween then fadeTween:Cancel() end
                if show then popup.Visible = true end
                local tween = TweenService:Create(popup, TweenInfo_new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {GroupTransparency = show and 0 or 1})
                fadeTween = tween
                tween.Completed:Connect(function(state)
                    if id ~= fadeId or state ~= Enum.PlaybackState.Completed then return end
                    fadeTween = nil
                    if not result.Opened then popup.Visible = false end
                end)
                tween:Play()
            end
            function result:Close()
                if not self.Opened then return end
                self.Opened = false
                icon.ImageTransparency = 0.5
                openOptions[result] = nil
                if activeOption == result then activeOption = next(openOptions) end
                fade(false)
            end
            function result:Open()
                if Toggle.Locked or not Library.Opened then return end
                for other in pairs(openOptions) do
                    if other ~= result and (result.Exclusive or other.Exclusive) then other:Close() end
                end
                openOptions[result] = true
                activeOption = result
                self.Opened = true
                userMoved = false
                RefreshSize(false)
                PlaceNearToggle()
                icon.ImageColor3 = Color3_new(1, 1, 1)
                icon.ImageTransparency = 0
                fade(true)
            end
            function result:Toggle()
                if self.Opened then self:Close() else self:Open() end
            end
            icon.MouseButton1Click:Connect(function() result:Toggle() end)
            icon.MouseEnter:Connect(function() if not result.Opened then Tween(icon, FastTween, {ImageTransparency = 0.2}) end end)
            icon.MouseLeave:Connect(function() if not result.Opened then Tween(icon, FastTween, {ImageTransparency = 0.5}) end end)
            Library:AddConnection(layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if popup.Visible and not result.Minimized then RefreshSize(false) end
            end))
            local LastOptionPositionUpdate = 0
            Library:AddConnection(RunService.Heartbeat:Connect(function()
                if not result.Opened or not Library.Opened or userMoved or not ToggleHolder:IsDescendantOf(UI) then return end
                local Now = os_clock()
                if Now - LastOptionPositionUpdate < 1 / 30 then return end
                LastOptionPositionUpdate = Now
                PlaceNearToggle()
            end))
            Library:AddConnection(UserInputService.InputBegan:Connect(function(input)
                if not result.Opened or not Library.Opened or (input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch) then return end
                local p = input.Position
                local function inside(obj)
                    if not obj or not obj.Parent or not obj:IsA("GuiObject") or not obj.Visible then return false end
                    local a, z = obj.AbsolutePosition, obj.AbsoluteSize
                    return p.X >= a.X and p.X <= a.X + z.X and p.Y >= a.Y and p.Y <= a.Y + z.Y
                end
                if inside(popup) or inside(popupGrip) or (Library.Opened and inside(icon)) or inside(Library.MobileButton) then return end
                for option in pairs(openOptions) do
                    if inside(option.Frame) or inside(option.Grip) then return end
                end
                if Library.Opened then
                    if inside(Library.MainWindow) then return end
                    for _, tab in ipairs(Library.TabHolders or {}) do
                        if inside(tab) then return end
                    end
                end
                result:Close()
            end))
            return result
        end

        function Toggle:SetLocked(locked: boolean)
            Toggle.Locked = locked == true
            if Toggle.Locked and Toggle.Options then Toggle.Options:Close() end

            LockedBlocker.Visible = Toggle.Locked
            ToggleButton.Visible = not Toggle.Locked
            LockedIcon.Visible = Toggle.Locked

            if Toggle.Locked then
                ToggleIcon.BackgroundColor3 = DefaultToggleColor
                ToggleStroke.Color = DefaultToggleColor
            else
                ToggleIcon.BackgroundColor3 = Toggle.Value and Color3_fromRGB(255, 255, 255) or ThemeColor(140, 140, 140)
                ToggleButton.BackgroundColor3 = Toggle.Value and EnabledToggleColor or ThemeColor(35, 35, 35)
                if CheckboxMark then Tween(CheckboxMark, FastTween, {ImageTransparency = Toggle.Value and 0 or 1}) else Tween(ToggleIcon, FastTween, {Position = Toggle.Value and UDim2_fromOffset(16, 0) or UDim2_fromOffset(0, 0)}) end
                ToggleStroke.Color = Toggle.Value and EnabledToggleColor or (Toggle.Hovering and HoveringToggleColor or DefaultToggleColor)
            end
        end

        function Toggle:Set(newValue: boolean)
            local oldValue = Toggle.Value
            Toggle.Value = newValue

            ToggleIcon.BackgroundColor3 = Toggle.Value and Color3_fromRGB(255, 255, 255) or ThemeColor(140, 140, 140)
            Tween(ToggleButton, FastTween, {BackgroundColor3 = Toggle.Value and EnabledToggleColor or ThemeColor(35, 35, 35)})
            if CheckboxMark then Tween(CheckboxMark, FastTween, {ImageTransparency = Toggle.Value and 0 or 1}) else Tween(ToggleIcon, FastTween, {Position = Toggle.Value and UDim2_fromOffset(16, 0) or UDim2_fromOffset(0, 0)}) end
            ToggleStroke.Color = Toggle.Value and EnabledToggleColor or (Toggle.Hovering and HoveringToggleColor or DefaultToggleColor)

            if Toggle.Value ~= oldValue then
                Library:SafeCallback(options.Callback, Toggle.Value, oldValue)
            end
            if Toggle.KeyPicker and Toggle.KeyPicker.RefreshList then Toggle.KeyPicker:RefreshList() end
        end

        function Toggle:AddKeybind(keyOptions)
            keyOptions = type(keyOptions) == "table" and table_clone(keyOptions) or {Keybind = keyOptions}
            keyOptions.Name = keyOptions.Name or ((options.Name or "Toggle") .. " Keybind")
            keyOptions._Inline = true
            keyOptions._Toggle = Toggle
            local callback = keyOptions.Callback
            local picker
            keyOptions.Callback = function(state, oldState)
                local mode = picker and picker.Mode or keyOptions.Mode or "Toggle"
                if not Toggle.Locked then
                    if picker and picker.Clearing then Toggle:Set(false)
                    elseif mode == "Hold" then Toggle:Set(state)
                    elseif mode == "Always" then Toggle:Set(true)
                    elseif not (picker and picker.ModeChanging) then Toggle:Set(not Toggle.Value) end
                end
                if callback then Library:SafeCallback(callback, state, oldState) end
            end
            picker = Components.AddKeyPicker(self._PaletteContainer, keyOptions)
            self.KeyPicker = picker
            picker.Holder.Parent = ToggleHolder
            picker.Holder.AnchorPoint = Vector2_new(1, 0.5)
            picker.Holder.Position = UDim2_new(1, 0, 0.5, 0)
            local holderPadding = picker.Holder:FindFirstChildOfClass("UIPadding")
            if holderPadding then holderPadding:Destroy() end
            picker.Label.Visible = false
            local function LayoutInlineKey()
                local width = picker.Button.Size.X.Offset + (keyOptions.Clearable == false and 0 or 29)
                self._KeyWidth = width
                picker.Holder.Size = UDim2_fromOffset(width, 32)
                ToggleButton.Position = UDim2_new(1, -width - 4, 0.5, 0)
                LockedIcon.Position = UDim2_new(1, -width - 4, 0.5, 0)
                ToggleText:FindFirstChildOfClass("UIPadding").PaddingRight = UDim_new(0, width + (self.OptionsIcon and 64 or 40))
                if self.OptionsIcon then self.OptionsIcon.Position = UDim2_new(1, -width - 42, 0.5, 0) end
            end
            Library:AddConnection(picker.Button:GetPropertyChangedSignal("Size"):Connect(LayoutInlineKey))
            LayoutInlineKey()
            return picker
        end
        Toggle._PaletteContainer = self

        if options.Flag then
            Library.Flags[options.Flag] = Toggle
        end

        local function UpdateToggleHover(themeChange)
            if Toggle.Locked then return end
            local base = Toggle.Value and EnabledToggleColor or DefaultToggleColor
            local color = Toggle.Hovering and base:Lerp(Color3_new(1, 1, 1), 0.3) or base
            if themeChange and animateThemeColor then
                animateThemeColor(ToggleButton, "BackgroundColor3", Toggle.Value and color or ThemeColor(35, 35, 35))
                animateThemeColor(ToggleStroke, "Color", color)
            else
                Tween(ToggleButton, FastTween, {BackgroundColor3 = Toggle.Value and color or ThemeColor(35, 35, 35)})
                Tween(ToggleStroke, FastTween, {Color = color})
            end
        end
        ToggleButton.MouseEnter:Connect(function() Toggle.Hovering = true UpdateToggleHover() end)
        ToggleButton.MouseLeave:Connect(function() Toggle.Hovering = false UpdateToggleHover() end)

        ToggleButton.MouseButton1Click:Connect(function()
            if Toggle.Locked then return end
            Toggle:Set(not Toggle.Value)
        end)

        Library.ThemeToggleRefreshers = Library.ThemeToggleRefreshers or {}
        table_insert(Library.ThemeToggleRefreshers, function()
            if not ToggleHolder.Parent then return end
            if Toggle.Locked then
                animateThemeColor(ToggleStroke, "Color", DefaultToggleColor)
            else
                UpdateToggleHover(true)
                animateThemeColor(ToggleIcon, "BackgroundColor3", Toggle.Value and Color3_new(1, 1, 1) or ThemeColor(140, 140, 140))
            end
        end)
        Toggle:Set(Toggle.Value)
    RegisterControlForPalette(self, options, Toggle, "Toggle")
        if options.Keybind then Toggle:AddKeybind({Keybind = options.Keybind, Mode = options.KeybindMode, Clearable = options.Clearable}) end
        return Toggle
    end

    function Components:AddCheckbox(options)
        local settings = table_clone(options or {})
        settings._Checkbox = true
        return Components.AddToggle(self, settings)
    end

function Components:AddSlider(options: SliderOptions)
    local SliderHolder = Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2_new(1, 0, 0, 48),
        Parent = self.Container
    })
        AttachTooltip(SliderHolder, options, "Slider")

    Create("UIPadding", {
        PaddingLeft = UDim_new(0, 11),
        PaddingRight = UDim_new(0, 11),
        Parent = SliderHolder
    })

    local SliderHoverZone: TextButton = Create("TextButton", {
        BackgroundTransparency = 1,
        Size = UDim2_fromScale(1, 1),
        Text = "",
        ZIndex = 0,
        Parent = SliderHolder
    })

    local SliderText = Create("TextLabel", {
        TextYAlignment = Enum.TextYAlignment.Center,
        BackgroundTransparency = 1,
        FontFace = RegularFont,
        Size = UDim2_new(1, -72, 0, 32),
        TextTruncate = Enum.TextTruncate.AtEnd,
        Text = options.Name or "No Name",
        TextColor3 = ThemeColor(255, 255, 255),
        TextScaled = false, TextSize = 15,
        TextTransparency = ThemeTextAlpha(0.5),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = SliderHolder
    })

    Create("UIPadding", {
        PaddingBottom = UDim_new(0, 6),
        PaddingTop = UDim_new(0, 6),
        Parent = SliderText
    })

    local SliderValue: TextBox = Create("TextBox", {
        TextYAlignment = Enum.TextYAlignment.Center,
        AnchorPoint = Vector2_new(1, 0),
        BackgroundColor3 = ThemeColor(35, 35, 35),
        BackgroundTransparency = 0,
        FontFace = RegularFont,
        Position = UDim2_new(1, 0, 0, 7),
        Size = UDim2_fromOffset(64, 20),
        Text = "100",
        TextColor3 = ThemeColor(255, 255, 255),
        TextScaled = false, TextSize = 14,
        TextTransparency = ThemeTextAlpha(0.5),
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = SliderHolder
    })
    Create("UICorner", {CornerRadius = UDim_new(0, 5), Parent = SliderValue})
    Create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = ThemeColor(60, 60, 60), Parent = SliderValue})
    SliderValue.TextTruncate = Enum.TextTruncate.AtEnd
    local function ResizeSliderValue()
        local scale = Library.MobileScale and Library.MobileScale.Scale or 1
        local available = SliderHolder.AbsoluteSize.X / math_max(scale, 0.001)
        local maxWidth = available > 1 and math_max(64, available - 48) or 200
        local measured = TextService:GetTextSize(SliderValue.Text, SliderValue.TextSize, Enum.Font.Gotham, Vector2_new(100000,100)).X
        local width = math_clamp(math_ceil(measured + 18), 64, maxWidth)
        SliderValue.Size = UDim2_fromOffset(width, 20)
        SliderText.Size = UDim2_new(1, -width - 8, 0, 32)
    end
    SliderValue:GetPropertyChangedSignal("Text"):Connect(ResizeSliderValue)
    Library:AddConnection(SliderHolder:GetPropertyChangedSignal("AbsoluteSize"):Connect(ResizeSliderValue))

    local SliderBar: TextButton = Create("TextButton", {
        AnchorPoint = Vector2_new(0, 1),
        AutoButtonColor = false,
        BackgroundColor3 = ThemeColor(60, 60, 60),
        Position = UDim2_new(0, 0, 1, -10),
        Size = UDim2_new(1, 0, 0, 6),
        Text = "",
        Parent = SliderHolder
    })

    Create("UICorner", { CornerRadius = UDim_new(1, 0), Parent = SliderBar })

    local SliderFillBar = Create("Frame", {
        BackgroundColor3 = ThemeColor(60, 200, 100),
        Size = UDim2_fromScale(0.5, 1),
        Parent = SliderBar
    })

    Create("UICorner", { CornerRadius = UDim_new(1, 0), Parent = SliderFillBar })
    Create("UIGradient", {Color = ColorSequence_new(Color3_fromRGB(235, 235, 235), Color3_fromRGB(255, 255, 255)), Rotation = 0, Parent = SliderFillBar})

    local SliderKnob = Create("Frame", {
        AnchorPoint = Vector2_new(0.5, 0.5), BackgroundColor3 = Color3_fromRGB(245, 245, 245),
        Position = UDim2_fromScale(0.5, 0.5), Size = UDim2_fromOffset(12, 12), ZIndex = 3, Parent = SliderBar,
    })
    SliderKnob:SetAttribute("ThemeColorIgnore", true)
    Create("UICorner", {CornerRadius = UDim_new(1, 0), Parent = SliderKnob})
    Create("UIStroke", {Color = ThemeColor(60, 200, 100), Thickness = 1.5, Parent = SliderKnob})

    local Slider = {
        Dragging = false,
        Hovering = false,
        Locked = false,

        Min = options.Min or 0,
        Max = options.Max or 100,
        Rounding = options.Rounding or 0,
        Increment = options.Increment or nil,
        Value = options.Value ~= nil and options.Value or (options.Default ~= nil and options.Default or (options.Min or 0)),

        Prefix = options.Prefix or "",
        Suffix = options.Suffix or "",
        HideMax = options.HideMax or false,
        AllowRightClickInput = options.AllowRightClickInput ~= false,

        Type = "Slider"
    }

    local function RoundTo(value)
        if Slider.Increment and Slider.Increment > 0 then
            local inc = Slider.Increment
            return math_floor(value / inc + 0.5) * inc
        end
        local rounding = Slider.Rounding
        if rounding and rounding > 0 then
            local mult = 10 ^ rounding
            return math_floor(value * mult + 0.5) / mult
        end
        return math_floor(value + 0.5)
    end

    local function ClampRound(value)
        return math_clamp(RoundTo(value), Slider.Min, Slider.Max)
    end

    local function FormatNumber(n)
        if n == math_floor(n) then
            return tostring(math_floor(n))
        end
        return tostring(n)
    end

    function Slider:Display()
        local custom = nil
        if options.FormatDisplayValue then
            custom = options.FormatDisplayValue(Slider, Slider.Value)
        elseif type(options.DisplayFormat) == "function" then
            local ok, value = pcall(options.DisplayFormat, Slider.Value, Slider); if ok then custom = value end
        elseif type(options.DisplayFormat) == "string" then
            local ok, value = pcall(string_format, options.DisplayFormat, Slider.Value); if ok then custom = value end
        end

        if custom then
            SliderValue.Text = tostring(custom)
        elseif Slider.HideMax then
            SliderValue.Text = ("%s%s%s"):format(Slider.Prefix, FormatNumber(Slider.Value), Slider.Suffix)
        else
            SliderValue.Text = ("%s%s%s/%s%s%s"):format(
                Slider.Prefix, FormatNumber(Slider.Value), Slider.Suffix,
                Slider.Prefix, FormatNumber(Slider.Max),   Slider.Suffix
            )
        end

        ResizeSliderValue()
        local ratio = (Slider.Max == Slider.Min) and 0 or ((Slider.Value - Slider.Min) / (Slider.Max - Slider.Min))
        SliderFillBar.Size = UDim2_fromScale(math_clamp(ratio, 0, 1), 1)
        SliderKnob.Position = UDim2_fromScale(math_clamp(ratio, 0, 1), 0.5)
    end

    function Slider:Set(newValue, silent)
        newValue = ClampRound(tonumber(newValue) or Slider.Value)
        local oldValue = Slider.Value

        Slider.Value = newValue
        Slider:Display()

        if not silent and newValue ~= oldValue then
            Library:SafeCallback(options.Callback, newValue, oldValue)
        end
    end

    function Slider:SetMin(newMin)
        if newMin == nil then return end
        if newMin > Slider.Max then Slider.Max = newMin end
        Slider.Min = newMin
        Slider:Set(math_clamp(Slider.Value, Slider.Min, Slider.Max), true)
    end

    function Slider:SetMax(newMax)
        if newMax == nil then return end
        if newMax < Slider.Min then Slider.Min = newMax end
        Slider.Max = newMax
        Slider:Set(math_clamp(Slider.Value, Slider.Min, Slider.Max), true)
    end

    function Slider:SetLocked(locked)
        Slider.Locked = locked == true

        LockedHover.Visible = Slider.Locked
        SliderValue.Visible = not Slider.Locked
        LockedIcon.Visible = Slider.Locked

        if Slider.Locked then
            SliderBar.BackgroundColor3 = DefaultToggleColor
            SliderFillBar.BackgroundColor3 = DefaultToggleColor
        else
            SliderBar.BackgroundColor3 = ThemeColor(60, 60, 60)
            SliderFillBar.BackgroundColor3 = ThemeColor(60, 200, 100)
        end
    end

    function Slider:SetText(text)
        Slider.Name = text
        SliderText.Text = text
        Slider:Display()
    end

    if options.Flag then
        Library.Flags[options.Flag] = Slider
    end

    local typing = false
    local tapAt = 0

    local function OpenTypeIn()
        if Slider.Locked or not Slider.AllowRightClickInput then return end
        typing = true
        SliderValue.Text = tostring(Slider.Value)
        task_spawn(function()
            SliderValue:CaptureFocus()
        end)
    end

    local function CloseTypeIn(enterPressed)
        if not typing then return end
        typing = false
        local raw = SliderValue.Text
        local newValue = tonumber(raw)
        if newValue and enterPressed ~= false then
            Slider:Set(newValue)
        else
            Slider:Display()
        end
    end

    SliderValue.FocusLost:Connect(function(enterPressed)
        if typing then
            CloseTypeIn(enterPressed or true)
        else
            local newValue = tonumber(SliderValue.Text)
            if newValue and enterPressed then
                Slider:Set(newValue)
            else
                Slider:Display()
            end
        end
    end)

    SliderHoverZone.MouseEnter:Connect(function()
        Slider.Hovering = true
        if Slider.Locked then return end
        Tween(SliderText, FastTween, {TextTransparency = 0})
        Tween(SliderFillBar, FastTween, {BackgroundColor3 = ThemeColor(60, 200, 100):Lerp(Color3_new(1, 1, 1), 0.18)})
    end)

    SliderHoverZone.MouseLeave:Connect(function()
        Slider.Hovering = false
        if Slider.Locked then return end
        Tween(SliderText, FastTween, {TextTransparency = ThemeTextAlpha(0.5)})
        Tween(SliderFillBar, FastTween, {BackgroundColor3 = ThemeColor(60, 200, 100)})
    end)

    SliderBar.InputBegan:Connect(function(input)
        if Slider.Locked then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1
            and input.UserInputType ~= Enum.UserInputType.MouseButton2
            and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        if Slider.AllowRightClickInput then
            local isRightClick = input.UserInputType == Enum.UserInputType.MouseButton2
            local isDoubleTap = false
            if input.UserInputType == Enum.UserInputType.Touch then
                local now = tick()
                if now - tapAt < 0.3 then isDoubleTap = true end
                tapAt = now
            end
            if isRightClick or isDoubleTap then
                OpenTypeIn()
                return
            end
        end

        if input.UserInputType == Enum.UserInputType.MouseButton2 then return end

        Slider.Dragging = true

        local abs = SliderBar.AbsolutePosition
        local size = SliderBar.AbsoluteSize
        local scale = math_clamp((input.Position.X - abs.X) / math_max(size.X, 1), 0, 1)
        Slider:Set(Slider.Min + (Slider.Max - Slider.Min) * scale)

        local endConn
        endConn = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                Slider.Dragging = false
                if endConn then endConn:Disconnect() end
            end
        end)
    end)

    Library:AddConnection(UserInputService.InputChanged:Connect(function(input)
        if not Slider.Dragging then return end
        if not Library.Opened and not IsOpenOptionAncestor(SliderHolder) then
            Slider.Dragging = false
            return
        end

        if input.UserInputType ~= Enum.UserInputType.MouseMovement
            and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        local abs = SliderBar.AbsolutePosition
        local size = SliderBar.AbsoluteSize
        local scale = math_clamp((input.Position.X - abs.X) / math_max(size.X, 1), 0, 1)
        Slider:Set(Slider.Min + (Slider.Max - Slider.Min) * scale)
    end))

    Slider:Set(Slider.Value, true)
    RegisterControlForPalette(self, options, Slider, "Slider")
    return Slider
end

local function StepperHoldMultiplier(Control, Elapsed)
    local Step = Control.Step or Control.Increment or 1
    if Step <= 0 then Step = Control.Rounding and 10 ^ -Control.Rounding or 1 end
    local Time = math_max(0, Elapsed or 0)
    local Range = math_abs(Control.Max - Control.Min)
    local Progress = math_min(1, Time / 2.5)
    local Target = math_max(1, Range * 0.012 / Step)
    return math_max(1, math_floor(1 + (Target - 1) * Progress * Progress + Time * 2))
end
Library._HoldMultiplier = StepperHoldMultiplier

local function BindStepperHold(Button, Stepper, Direction, CanHold)
    local Token = 0
    local InputConnection
    local PressInput
    local function Stop()
        Token += 1
        PressInput = nil
        if InputConnection then InputConnection:Disconnect(); InputConnection = nil end
    end
    local function Available()
        return not Library.Unloaded and Button.Parent ~= nil and Button.Active and not Stepper.Locked and (not CanHold or CanHold())
    end
    Button.InputBegan:Connect(function(Input)
        local Kind = Input.UserInputType
        if Kind ~= Enum.UserInputType.MouseButton1 and Kind ~= Enum.UserInputType.Touch then return end
        if not Available() then return end
        Stop()
        local Current = Token
        PressInput = Input
        Stepper:StepBy(Direction)
        if not Available() then Stop(); return end
        InputConnection = UserInputService.InputEnded:Connect(function(Ended)
            if Ended == PressInput or (Kind == Enum.UserInputType.MouseButton1 and Ended.UserInputType == Kind) then Stop() end
        end)
        task_spawn(function()
            task_wait(0.25)
            local Started = os_clock()
            while Current == Token and PressInput == Input and Available() do
                Stepper:StepBy(Direction, StepperHoldMultiplier(Stepper, os_clock() - Started))
                task_wait(math_max(0.03, 0.10 - (os_clock() - Started) * 0.035))
            end
            if Current == Token then Stop() end
        end)
    end)
    Button.InputEnded:Connect(function(Input)
        if Input == PressInput then Stop() end
    end)
    Button.MouseLeave:Connect(Stop)
    Button.Destroying:Connect(Stop)
    Button.Activated:Connect(function(Input)
        if Input and (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) then return end
        if Available() then Stepper:StepBy(Direction) end
    end)
end

Library._BindStepperHold = BindStepperHold

function Components:AddStepper(options)
    options = options or {}
    local StepperHolder = Create("Frame", {BackgroundTransparency = 1, Size = UDim2_new(1, 0, 0, 40), Parent = self.Container})
    AttachTooltip(StepperHolder, options, "Stepper")
    Create("UIPadding", {PaddingLeft = UDim_new(0, 11), PaddingRight = UDim_new(0, 11), Parent = StepperHolder})

    local StepperText = Create("TextLabel", {
        BackgroundTransparency = 1, FontFace = RegularFont, Text = options.Name or "Stepper",
        TextColor3 = ThemeColor(255, 255, 255), TextTransparency = ThemeTextAlpha(0.5), TextSize = 15,
        TextTruncate = Enum.TextTruncate.AtEnd, TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2_new(1, -126, 1, 0), Parent = StepperHolder,
    })
    local StepperFrame = Create("Frame", {
        AnchorPoint = Vector2_new(1, 0.5), Position = UDim2_new(1, 0, 0.5, 0), Size = UDim2_fromOffset(118, 24),
        BackgroundColor3 = ThemeColor(30, 30, 30), Parent = StepperHolder,
    })
    Create("UICorner", {CornerRadius = UDim_new(0, 6), Parent = StepperFrame})
    Create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = ThemeColor(60, 60, 60), Parent = StepperFrame})

    local StepperValue = Create("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2_fromOffset(26, 0), Size = UDim2_fromOffset(66, 24),
        Text = "", TextColor3 = ThemeColor(220, 220, 220), TextSize = 13, FontFace = MediumFont,
        TextTruncate = Enum.TextTruncate.AtEnd, Parent = StepperFrame,
    })
    local Stepper = {
        Type = "Stepper", Name = options.Name or "Stepper", Locked = false,
        Min = tonumber(options.Min) or 0, Max = tonumber(options.Max) or 100,
        Step = tonumber(options.Step or options.Increment) or 1,
        Value = tonumber(options.Value ~= nil and options.Value or options.Default),
        Prefix = options.Prefix or "", Suffix = options.Suffix or "", HideMax = options.HideMax == true,
        Rounding = options.Rounding,
    }
    if Stepper.Max < Stepper.Min then Stepper.Max = Stepper.Min end
    if Stepper.Step <= 0 then Stepper.Step = 1 end
    if Stepper.Value == nil then Stepper.Value = Stepper.Min end

    local function FormatNumber(Value)
        return string_format("%g", Value)
    end
    local function Snap(Value)
        local Rounded = Stepper.Min + math_floor((Value - Stepper.Min) / Stepper.Step + 0.5) * Stepper.Step
        local Digits = Stepper.Rounding
        if Digits == nil then
            local Fraction = tostring(Stepper.Step):match("%.(%d+)")
            Digits = Fraction and #Fraction or 0
        end
        if Digits > 0 then
            local Factor = 10 ^ math_min(Digits, 8)
            Rounded = math_floor(Rounded * Factor + 0.5) / Factor
        end
        return math_clamp(Rounded, Stepper.Min, Stepper.Max)
    end
    function Stepper:DisplayValue()
        if options.FormatDisplayValue then
            local Ok, Formatted = pcall(options.FormatDisplayValue, self, self.Value)
            if Ok and Formatted ~= nil then return tostring(Formatted) end
        elseif type(options.DisplayFormat) == "function" then
            local Ok, Formatted = pcall(options.DisplayFormat, self.Value, self)
            if Ok and Formatted ~= nil then return tostring(Formatted) end
        elseif type(options.DisplayFormat) == "string" then
            local Ok, Formatted = pcall(string_format, options.DisplayFormat, self.Value)
            if Ok and Formatted ~= nil then return tostring(Formatted) end
        end
        local Current = self.Prefix .. FormatNumber(self.Value) .. self.Suffix
        if self.HideMax then return Current end
        return Current .. "/" .. self.Prefix .. FormatNumber(self.Max) .. self.Suffix
    end

    local MinusButton, PlusButton, MinusIcon, PlusIcon
    local function UpdateVisuals()
        StepperValue.Text = Stepper:DisplayValue()
        local CanDecrease = not Stepper.Locked and Stepper.Value > Stepper.Min
        local CanIncrease = not Stepper.Locked and Stepper.Value < Stepper.Max
        MinusButton.Active = CanDecrease
        PlusButton.Active = CanIncrease
        MinusIcon.ImageColor3 = CanDecrease and ThemeColor(200, 200, 200) or ThemeColor(90, 90, 90)
        PlusIcon.ImageColor3 = CanIncrease and ThemeColor(200, 200, 200) or ThemeColor(90, 90, 90)
        StepperValue.TextTransparency = Stepper.Locked and 0.5 or 0
        StepperText.TextTransparency = ThemeTextAlpha(Stepper.Locked and 0.75 or 0.5)
    end
    function Stepper:Set(Value, Silent)
        local Number = tonumber(Value)
        if not Number or Number ~= Number or Number == math_huge or Number == -math_huge then return end
        local Previous = self.Value
        self.Value = Snap(math_clamp(Number, self.Min, self.Max))
        UpdateVisuals()
        if not Silent and self.Value ~= Previous then Library:SafeCallback(options.Callback, self.Value, Previous) end
    end
    function Stepper:StepBy(Direction, Multiplier)
        if self.Locked or Library.Unloaded then return end
        local Count = tonumber(Multiplier) or StepperHoldMultiplier(self, 0)
        self:Set(self.Value + (Direction >= 0 and 1 or -1) * self.Step * math_max(1, Count))
    end
    function Stepper:SetMin(Value)
        Value = tonumber(Value)
        if not Value then return end
        self.Min = Value
        if self.Max < Value then self.Max = Value end
        self:Set(self.Value, true)
    end
    function Stepper:SetMax(Value)
        Value = tonumber(Value)
        if not Value then return end
        self.Max = Value
        if self.Min > Value then self.Min = Value end
        self:Set(self.Value, true)
    end
    function Stepper:SetLocked(Locked)
        self.Locked = Locked == true
        UpdateVisuals()
    end
    function Stepper:SetText(Text)
        self.Name = tostring(Text)
        StepperText.Text = self.Name
    end

    local function StepButton(Direction, IconName, X)
        local Button = Create("TextButton", {
            BackgroundTransparency = 1, AutoButtonColor = false, Text = "",
            Position = UDim2_fromOffset(X, 0), Size = UDim2_fromOffset(26, 24), Parent = StepperFrame,
        })
        local Icon = Create("ImageLabel", {
            BackgroundTransparency = 1, Image = "", ImageColor3 = ThemeColor(200, 200, 200),
            AnchorPoint = Vector2_new(0.5, 0.5), Position = UDim2_fromScale(0.5, 0.5),
            Size = UDim2_fromOffset(15, 15), Parent = Button,
        })
        Library:ApplyIcon(Icon, Library:GetIcon(IconName))
        BindStepperHold(Button, Stepper, Direction)
        Button.MouseEnter:Connect(function()
            if not Stepper.Locked then Tween(Button, FastTween, {BackgroundTransparency = 0.84, BackgroundColor3 = ThemeColor(60, 60, 60)}) end
        end)
        Button.MouseLeave:Connect(function() Tween(Button, FastTween, {BackgroundTransparency = 1}) end)
        return Button, Icon
    end
    MinusButton, MinusIcon = StepButton(-1, "circle-minus", 0)
    PlusButton, PlusIcon = StepButton(1, "circle-plus", 92)
    Stepper:Set(Stepper.Value, true)
    if options.Flag then Library.Flags[options.Flag] = Stepper end
    RegisterControlForPalette(self, options, Stepper, "Stepper")
    return Stepper
end

function Components:AddTextbox(options: TextboxOptions)
    local TextboxHolder = Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2_new(1, 0, 0, 66),
        Parent = self.Container
    })
        AttachTooltip(TextboxHolder, options, "Input")

    Create("UIPadding", {
        PaddingBottom = UDim_new(0, 5),
        PaddingLeft = UDim_new(0, 13),
        PaddingRight = UDim_new(0, 13),
        PaddingTop = UDim_new(0, 5),
        Parent = TextboxHolder
    })

    local Caption = Create("TextLabel", {BackgroundTransparency = 1, FontFace = RegularFont, Text = options.Name or "Input", TextColor3 = ThemeColor(255, 255, 255), TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Size = UDim2_new(1, 0, 0, 22), Parent = TextboxHolder})
    local UpdateVisuals
    local Box: TextBox = Create("TextBox", {
        TextYAlignment = Enum.TextYAlignment.Center,
        BackgroundColor3 = ThemeColor(38, 38, 38),
        BackgroundTransparency = 0,
        ClearTextOnFocus = options.ClearTextOnFocus ~= false and (options.ResetOnFocus ~= false),
        FontFace = RegularFont,
        PlaceholderColor3 = ThemeColor(150, 150, 150),
        PlaceholderText = options.Placeholder or "",
        Position = UDim2_fromOffset(0, 27),
        Size = UDim2_new(1, 0, 1, -27),
        Text = options.Text or "",
        TextColor3 = ThemeColor(140, 140, 140),
        TextScaled = false, TextSize = 15,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TextboxHolder
    })

    Create("UICorner", { CornerRadius = UDim_new(0, 6), Parent = Box })
    Create("UIPadding", {
        PaddingBottom = UDim_new(0, 6),
        PaddingLeft = UDim_new(0, 6),
        PaddingRight = UDim_new(0, 6),
        PaddingTop = UDim_new(0, 6),
        Parent = Box
    })
    Box:SetAttribute("ThemeInputSurface", 38)
    local BoxStroke = Create("UIStroke", {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = ThemeColor(60, 60, 60),
        Parent = Box
    })

    local Textbox = {
        Hovering = false,
        Focused = false,
        Locked = false,

        Text = options.Text or "",

        Numeric = options.Numeric == true,
        Finished = options.Finished == true,
        AllowEmpty = options.AllowEmpty ~= false,
        EmptyReset = options.EmptyReset or "",
        MaxLength = options.MaxLength,
        VerifyValue = options.VerifyValue,
        ClearTextOnBlur = options.ClearTextOnBlur == true,
        ClearTextOnFocus = options.ClearTextOnFocus ~= false and (options.ResetOnFocus ~= false),

        Type = "Textbox"
    }

    local function IsValidValue(text)
        if typeof(Textbox.VerifyValue) == "function" then
            return Textbox.VerifyValue(text) == true
        end
        return true
    end

    local function Sanitize(text)
        if typeof(text) ~= "string" then text = tostring(text) end

        if Textbox.MaxLength and #text > Textbox.MaxLength then
            text = text:sub(1, Textbox.MaxLength)
        end

        if Textbox.Numeric and #text > 0 and not tonumber(text) then
            text = Textbox.Text
        end

        if not Textbox.AllowEmpty and text == "" then
            text = Textbox.EmptyReset
        end

        if text ~= Textbox.EmptyReset and not IsValidValue(text) then
            text = Textbox.EmptyReset
        end

        return text
    end

    function Textbox:Set(newText, silent)
        local oldText = Textbox.Text
        newText = Sanitize(newText)

        Textbox.Text = newText
        if Box.Text ~= newText then
            Box.Text = newText
        end

        if not silent and newText ~= oldText then
            Library:SafeCallback(options.Callback, newText, oldText)
        end
    end

    function Textbox:SetLocked(locked: boolean)
        Textbox.Locked = locked == true

        Box.TextEditable = not Textbox.Locked
        UpdateVisuals()
    end

    function Textbox:SetVisible(visible)
        TextboxHolder.Visible = visible
    end

    function Textbox:SetText(text)
        Caption.Text = tostring(text)
    end

    if options.Flag then
        Library.Flags[options.Flag] = Textbox
    end

    UpdateVisuals = function()
        if Textbox.Focused then
            Tween(Box, FastTween, {
                BackgroundColor3 = ThemeColor(38, 38, 38),
                TextColor3 = ThemeColor(255, 255, 255),
                PlaceholderColor3 = ThemeColor(170, 170, 170),
            })
            Tween(BoxStroke, FastTween, {Color = ThemeColor(90, 90, 90)})
        elseif Textbox.Hovering and not Textbox.Locked then
            Tween(Box, FastTween, {
                BackgroundColor3 = ThemeColor(38, 38, 38),
                TextColor3 = ThemeColor(200, 200, 200),
                PlaceholderColor3 = ThemeColor(160, 160, 160),
            })
            Tween(BoxStroke, FastTween, {Color = ThemeColor(80, 80, 80)})
        else
            Tween(Box, FastTween, {
                BackgroundColor3 = ThemeColor(38, 38, 38),
                TextColor3 = ThemeColor(140, 140, 140),
                PlaceholderColor3 = ThemeColor(150, 150, 150),
            })
            Tween(BoxStroke, FastTween, {Color = ThemeColor(60, 60, 60)})
        end
    end

    Box.MouseEnter:Connect(function()
        Textbox.Hovering = true
        UpdateVisuals()
    end)

    Box.MouseLeave:Connect(function()
        Textbox.Hovering = false
        UpdateVisuals()
    end)

    Box.Focused:Connect(function()
        Textbox.Focused = true
        UpdateVisuals()
    end)

    Box.FocusLost:Connect(function()
        Textbox.Focused = false
        UpdateVisuals()
    end)

    if Textbox.Finished then
        Box.FocusLost:Connect(function(enterPressed)
            Textbox.Focused = false
            if enterPressed then
                Textbox:Set(Box.Text)
            elseif Textbox.ClearTextOnBlur then
                Box.Text = Textbox.Text
            end
        end)
    else
        Box:GetPropertyChangedSignal("Text"):Connect(function()
            if Box.Text == Textbox.Text then return end
            local cursor = Box.CursorPosition
            local old = #Box.Text
            Textbox:Set(Box.Text)
            if Box.Text ~= Textbox.Text then
                Box.Text = Textbox.Text
            end
            if cursor <= old then
                Box.CursorPosition = math_min(cursor, #Box.Text + 1)
            end
        end)
    end

    Box.FocusLost:Connect(function()
        Textbox.Focused = false
        if Box.Text == "" and not Textbox.AllowEmpty then
            Box.Text = Textbox.EmptyReset
        end
        if Textbox.ClearTextOnBlur then
            Box.Text = Textbox.Text
        end
    end)

    Textbox:Set(Textbox.Text, true)
    RegisterControlForPalette(self, options, Textbox, "Textbox")
    return Textbox
end

function Components:AddDropdown(options: DropdownOptions)
    local DropdownHolder = Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2_new(1, 0, 0, 42),
        Parent = self.Container
    })
        AttachTooltip(DropdownHolder, options, "Dropdown")

    Create("UIPadding", {
        PaddingBottom = UDim_new(0, 5),
        PaddingLeft = UDim_new(0, 13),
        PaddingRight = UDim_new(0, 13),
        PaddingTop = UDim_new(0, 5),
        Parent = DropdownHolder
    })

    local function GetPlayerValues()
        local list = Players:GetPlayers()
        if options.ExcludeLocalPlayer then
            local i = table_find(list, Library.LocalPlayer)
            if i then table_remove(list, i) end
        end
        table_sort(list, function(a, b) return a.Name:lower() < b.Name:lower() end)
        return list
    end

    if options.SpecialType == "Player" then
        options.Values = GetPlayerValues()
        options.AllowNull = true
    end

    local ButtonsHolder = Create("Frame", {
        BackgroundColor3 = ThemeColor(25, 25, 25),
        Size = UDim2_new(1, 0, 0, 32),
        ClipsDescendants = true,
        Parent = DropdownHolder
    })

    Create("UICorner", { CornerRadius = UDim_new(0, 6), Parent = ButtonsHolder })
    Create("UIStroke", {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = ThemeColor(60, 60, 60),
        Parent = ButtonsHolder
    })

    local CurrentButton = Create("TextButton", {
        TextYAlignment = Enum.TextYAlignment.Center,
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        FontFace = RegularFont,
        Size = UDim2_new(1, 0, 0, 32),
        TextColor3 = ThemeColor(220, 220, 220),
        TextScaled = false, TextSize = 15,
        TextTruncate = Enum.TextTruncate.None,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = ButtonsHolder
    })

    local CurrentPadding = Create("UIPadding", {
        PaddingBottom = UDim_new(0, 6),
        PaddingLeft = UDim_new(0, 6),
        PaddingRight = UDim_new(0, 20),
        PaddingTop = UDim_new(0, 6),
        Parent = CurrentButton
    })

    local OverflowIndicator = Create("TextLabel", {
        Name = "DropdownOverflow", BackgroundTransparency = 1,
        AnchorPoint = Vector2_new(1, 0), Position = UDim2_new(1, -25, 0, 0),
        Size = UDim2_fromOffset(1, 32), FontFace = RegularFont, TextSize = 15,
        Text = "...", TextColor3 = ThemeColor(220,220,220), Visible = false,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = ButtonsHolder,
    })
    local fullDropdownText = ""
    local function UpdateDropdownText()
        local scale = Library.MobileScale and Library.MobileScale.Scale or 1
        local width = CurrentButton.AbsoluteSize.X / math_max(scale, 0.001)
        if width <= 1 then CurrentButton.Text = fullDropdownText; OverflowIndicator.Visible = false; return end
        local function TextWidth(text)
            local bounds = GetTextBounds(text, CurrentButton.FontFace, CurrentButton.TextSize, 100000)
            return bounds and bounds.X or TextService:GetTextSize(text, CurrentButton.TextSize, Enum.Font.Gotham, Vector2_new(100000,100)).X
        end
        local function Fits(text, maxWidth) return TextWidth(text) <= maxWidth end
        local dotWidth = math_ceil(TextWidth("..."))
        local maxWidth = math_max(0, width - 26)
        if Fits(fullDropdownText, maxWidth) then
            CurrentPadding.PaddingRight = UDim_new(0, 20)
            CurrentButton.Text = fullDropdownText
            OverflowIndicator.Visible = false
            return
        end
        OverflowIndicator.Size = UDim2_fromOffset(dotWidth, 32)
        local ellipsisGap = 1
        CurrentPadding.PaddingRight = UDim_new(0, 20)
        local utf8Length = utf8_len(fullDropdownText)
        local count = utf8Length or #fullDropdownText
        local function PrefixForCount(length)
            if length <= 0 then return "" end
            if not utf8Length then return fullDropdownText:sub(1, length) end
            local nextByte = utf8_offset(fullDropdownText, length + 1)
            return nextByte and fullDropdownText:sub(1, nextByte - 1) or fullDropdownText
        end
        local low, high = 0, count
        local available = math_max(0, maxWidth - dotWidth - ellipsisGap)
        while low < high do
            local middle = math_floor((low + high + 1) / 2)
            local prefixText = PrefixForCount(middle)
            if Fits(prefixText .. "...", maxWidth) then low = middle else high = middle - 1 end
        end
        local prefix = PrefixForCount(low):gsub("%s+$", "")
        CurrentButton.Text = prefix .. "..."
        OverflowIndicator.AnchorPoint = Vector2_new(0, 0)
        OverflowIndicator.Position = UDim2_fromOffset(6 + math_ceil(TextWidth(prefix)), 0)
        OverflowIndicator.Visible = false
    end
    Library:AddConnection(CurrentButton:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateDropdownText))

    local SearchBox, SearchIcon
    if options.Searchable then
        SearchBox = Create("TextBox", {
            BackgroundColor3 = ThemeColor(30, 30, 30),
            ClearTextOnFocus = false,
            FontFace = RegularFont,
            PlaceholderColor3 = ThemeColor(150, 150, 150),
            PlaceholderText = "Search...",
            Position = UDim2_fromOffset(6, 36),
            Size = UDim2_new(1, -12, 0, 28),
            Text = "",
            TextColor3 = ThemeColor(255, 255, 255),
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Visible = false,
            Parent = ButtonsHolder
        })

        Create("UIPadding", {
            PaddingLeft = UDim_new(0, 28),
            PaddingRight = UDim_new(0, 8),
            Parent = SearchBox
        })

        Create("UICorner", {CornerRadius = UDim_new(0, 5), Parent = SearchBox})
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = ThemeColor(60, 60, 60), Transparency = 0.2,
            Parent = SearchBox
        })
        SearchIcon = Create("ImageLabel", {BackgroundTransparency = 1, Image = "", ImageTransparency = 0.35, Position = UDim2_fromOffset(13, 42), Size = UDim2_fromOffset(16, 16), ZIndex = 2, Visible = false, Parent = ButtonsHolder})
        Library:ApplyIcon(SearchIcon, Library:GetIcon("search"))
    end

    local OptionsHolder = Create("ScrollingFrame", {
        Active = true,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2_fromOffset(0, 0),
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = ThemeColor(100, 100, 100),
        Position = UDim2_fromOffset(0, 32),
        Size = UDim2_fromScale(1, 0),
        Visible = false,
        Parent = ButtonsHolder,
    })

    local EmptyMessage = Create("TextLabel", {BackgroundTransparency = 1, FontFace = RegularFont, Size = UDim2_new(1, 0, 0, 32), Text = "No results found", TextColor3 = ThemeColor(140, 140, 140), TextSize = 14, Visible = false, Parent = OptionsHolder})

    local Icon = Create("ImageLabel", {
        AnchorPoint = Vector2_new(1, 0),
        BackgroundTransparency = 1,
        Image = "",
        ImageTransparency = 0.5,
        Position = UDim2_new(1, -3, 0, 8),
        Size = UDim2_fromOffset(16, 16),
        Parent = DropdownHolder
    })
    Library:ApplyIcon(Icon, ArrowIcon)

    local LockedIcon = Create("ImageLabel", {
        AnchorPoint = Vector2_new(1, 0),
        BackgroundTransparency = 1,
        Image = "",
        ImageTransparency = 0.5,
        Position = UDim2_new(1, -3, 0, 8),
        Size = UDim2_fromOffset(16, 16),
        Visible = false,
        Parent = DropdownHolder
    })
    Library:ApplyIcon(LockedIcon, LockIcon)

    local LockedHover = Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2_fromScale(1, 1),
        Visible = false,
        Parent = DropdownHolder,
    })

    local Dropdown = {
        Buttons = {},
        FinalText = "",
        Locked = false,
        Hovering = false,
        Opened = false,
        Animating = false,

        AllowNull = true,
        Multi = options.Multi or false,
        Selectable = options.Multi == true and options.Selectable == true,
        Searchable = options.Searchable == true,
        SearchText = "",
        Name = options.Name or "Dropdown",
        Value = options.Multi and {} or nil,
        Values = options.Values or {},
        ValueImages = typeof(options.ValueImages) == "table" and table_clone(options.ValueImages) or {},

        DisabledValues = options.DisabledValues or {},
        KeepDisabledValuePosition = options.KeepDisabledValuePosition == true,

        SpecialType = options.SpecialType,
        ExcludeLocalPlayer = options.ExcludeLocalPlayer == true,
        MaxVisibleDropdownItems = math_max(1, options.MaxVisibleDropdownItems or 8),

        Type = "Dropdown"
    }

    if options.AllowNull == false then Dropdown.AllowNull = false end

    local SEARCH_HEIGHT = 28
    local SEARCH_GAP = 4
    local BASE_HEIGHT = 32
    local HOLDER_PAD = 10
    local ITEM_HEIGHT = 32
    local selectionBar, selectAllButton, deselectAllButton
    if Dropdown.Selectable then
        selectionBar = Create("Frame", {Name = "SelectionButtons", BackgroundTransparency = 1, Size = UDim2_new(1,-12,0,30), Visible = false, Parent = ButtonsHolder})
        local function SelectionButton(text, x)
            local button = Create("TextButton", {Name = text, AutoButtonColor = false, BackgroundColor3 = ThemeColor(35,35,35), Position = UDim2_new(x,0,0,1), Size = UDim2_new(0.5,-3,0,26), Text = text, TextColor3 = ThemeColor(220,220,220), TextSize = 12, FontFace = RegularFont, Parent = selectionBar})
            Create("UICorner", {CornerRadius = UDim_new(0,5), Parent = button})
            local outline = Create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = ThemeColor(60,60,60), Parent = button})
            button.MouseEnter:Connect(function() Tween(button, FastTween, {BackgroundColor3 = ThemeColor(50,50,50)}); Tween(outline, FastTween, {Color = ThemeColor(100,100,100)}) end)
            button.MouseLeave:Connect(function() Tween(button, FastTween, {BackgroundColor3 = ThemeColor(35,35,35)}); Tween(outline, FastTween, {Color = ThemeColor(60,60,60)}) end)
            return button
        end
        selectAllButton = SelectionButton("Select All", 0)
        deselectAllButton = SelectionButton("Deselect All", 0.5)
    end

    local OpenTweenInfo = TweenInfo_new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local CloseTweenInfo = TweenInfo_new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    local progress = 0
    local listHeight = 0

    local function IsSequentialArray(Table)
        for Key in Table do
            if typeof(Key) ~= "number" or Key < 1 or Key % 1 ~= 0 then
                return false
            end
        end
        return true
    end

    local function GetTableSize(Table)
        local n = 0
        for _ in Table do n += 1 end
        return n
    end

    local function ValueExists(Val)
        if IsSequentialArray(Dropdown.Values) then
            for _, Existing in Dropdown.Values do
                if Existing == Val then return true end
            end
            return false
        end
        return Dropdown.Values[Val] ~= nil
    end

    local function IsValueDisabled(Val, RawValue)
        for _, DisabledVal in Dropdown.DisabledValues do
            if DisabledVal == Val then return true end
            if RawValue ~= nil and DisabledVal == RawValue then return true end
        end
        return false
    end

    function Dropdown:GetActiveValues(ReturnCount)
        local Table = {}
        if Dropdown.Multi then
            for Value in Dropdown.Value do table_insert(Table, Value) end
        else
            if Dropdown.Value then table_insert(Table, Dropdown.Value) end
        end
        return ReturnCount == true and GetTableSize(Table) or Table
    end

    local function FormatListValue(RawValue)
        if Dropdown.SpecialType == "Player" and typeof(RawValue) == "Instance" then
            return RawValue.Name
        end
        return tostring(options.FormatListValue and options.FormatListValue(RawValue) or RawValue)
    end

    local function FormatDisplayValue(RawValue)
        if Dropdown.SpecialType == "Player" and typeof(RawValue) == "Instance" then
            return RawValue.Name
        end
        if options.FormatDisplayValue then
            return tostring(options.FormatDisplayValue(RawValue))
        end
        return tostring(RawValue)
    end

    local function MaxListHeight()
        return Dropdown.MaxVisibleDropdownItems * ITEM_HEIGHT
    end

    local filteredCache = {}

    local function BuildFiltered()
        table_clear(filteredCache)
        local IsDictionary = not IsSequentialArray(Dropdown.Values)
        local Query = Dropdown.Searchable and Dropdown.SearchText or ""

        for Key, RawValue in Dropdown.Values do
            local Value = IsDictionary and Key or RawValue
            local formatted = FormatListValue(RawValue)
            if Query ~= "" and not formatted:lower():find(Query, 1, true) then
                continue
            end
            table_insert(filteredCache, {
                Key = Key,
                Value = Value,
                RawValue = RawValue,
                Formatted = formatted,
                IsDisabled = IsValueDisabled(Value, RawValue),
            })
        end
    end

    local function ApplyProgress(p)
        progress = p
        local searchSlot = SearchBox and (SEARCH_GAP + SEARCH_HEIGHT) or 0
        local selectSlot = selectionBar and 38 or 0

        local openButtonsH = BASE_HEIGHT + searchSlot + selectSlot + math_min(listHeight, MaxListHeight())
        local closedButtonsH = BASE_HEIGHT

        local buttonsH = closedButtonsH + (openButtonsH - closedButtonsH) * p
        local holderH = buttonsH + HOLDER_PAD

        DropdownHolder.Size = UDim2_new(1, 0, 0, holderH)
        ButtonsHolder.Size = UDim2_new(1, 0, 0, buttonsH)

        OptionsHolder.Position = UDim2_fromOffset(0, BASE_HEIGHT + (searchSlot + selectSlot) * p)
        if selectionBar then selectionBar.Position = UDim2_fromOffset(6, BASE_HEIGHT + searchSlot * p + 3); selectionBar.Visible = p > 0.001 end

        if SearchBox then
            local searchY = BASE_HEIGHT + SEARCH_GAP * p
            SearchBox.Position = UDim2_fromOffset(6, searchY)
            SearchBox.BackgroundTransparency = 1 - p
            SearchBox.TextTransparency = 1 - p
            SearchIcon.Position = UDim2_fromOffset(13, searchY + 6)
            SearchIcon.ImageTransparency = 1 - 0.65 * p
            if p > 0.001 then SearchBox.Visible = true; SearchIcon.Visible = true end
        end

        Icon.Rotation = 180 * p
    end

    function Dropdown:RefreshSize()
        listHeight = math_max(#filteredCache, 1) * ITEM_HEIGHT
        ApplyProgress(progress)
    end

    local dropdownTween, dropdownProgressValue, dropdownProgressConnection
    local dropdownTweenId = 0
    function Dropdown:AnimateSize(opening)
        dropdownTweenId += 1
        local animationId = dropdownTweenId
        if dropdownTween then dropdownTween:Cancel() end
        if dropdownProgressConnection then dropdownProgressConnection:Disconnect() dropdownProgressConnection = nil end
        if dropdownProgressValue then dropdownProgressValue:Destroy() dropdownProgressValue = nil end
        Dropdown.Animating = true
        if opening then
            OptionsHolder.Visible = true
            if SearchBox then SearchBox.Visible = true end
            listHeight = math_max(#filteredCache, 1) * ITEM_HEIGHT
        end
        local target = opening and 1 or 0
        local value = Instance_new("NumberValue")
        value.Value = progress
        dropdownProgressValue = value
        dropdownProgressConnection = value.Changed:Connect(function(v) ApplyProgress(v) end)
        local tween = TweenService:Create(value, opening and OpenTweenInfo or CloseTweenInfo, {Value = target})
        dropdownTween = tween
        tween.Completed:Connect(function(state)
            if animationId ~= dropdownTweenId or state ~= Enum.PlaybackState.Completed then return end
            if dropdownProgressConnection then dropdownProgressConnection:Disconnect() dropdownProgressConnection = nil end
            value:Destroy()
            dropdownProgressValue, dropdownTween = nil, nil
            Dropdown.Animating = false
            if not Dropdown.Opened then
                OptionsHolder.Visible = false
                if SearchBox then
                    SearchBox.Visible = false
                    SearchIcon.Visible = false
                    SearchBox.Text = ""
                    Dropdown.SearchText = ""
                    Dropdown:BuildList()
                end
            end
            ApplyProgress(target)
        end)
        tween:Play()
    end

    local function GetOrCreateRow(Value)
        local row = Dropdown.Buttons[Value]
        if row then return row end

        local Btn = Create("TextButton", {
            TextYAlignment = Enum.TextYAlignment.Center,
            AutoButtonColor = false,
            BackgroundTransparency = 1,
            FontFace = RegularFont,
            Size = UDim2_new(1, 0, 0, ITEM_HEIGHT),
            Text = "",
            TextColor3 = ThemeColor(140, 140, 140),
            TextScaled = false, TextSize = 15,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = OptionsHolder
        })
        local RowPadding = Create("UIPadding", {
            PaddingBottom = UDim_new(0, 6),
            PaddingLeft = UDim_new(0, 6),
            PaddingRight = UDim_new(0, 6),
            PaddingTop = UDim_new(0, 6),
            Parent = Btn
        })

        local Check = Create("ImageLabel", {BackgroundTransparency = 1, Position = UDim2_new(0, -20, 0.5, -8), Size = UDim2_fromOffset(16, 16), Image = "", ImageColor3 = Color3_new(1, 1, 1), Visible = false, Parent = Btn})
        Check:SetAttribute("ThemeColorIgnore", true)
        Library:ApplyIcon(Check, Library:GetIcon("check"))
        Check.Name = "SelectionCheck"
        local ValueImage = Create("ImageLabel", {Name = "ValueImage", BackgroundTransparency = 1, Image = "", ImageColor3 = Color3_new(1,1,1), Size = UDim2_fromOffset(16,16), Visible = false, Parent = Btn})
        ValueImage:SetAttribute("ThemeColorIgnore", true)
        local ImageSeparator = Create("Frame", {Name = "ImageSeparator", BackgroundColor3 = Color3_new(1,1,1), BackgroundTransparency = 0.35, BorderSizePixel = 0, Size = UDim2_fromOffset(1,16), Visible = false, Parent = Btn})
        ImageSeparator:SetAttribute("ThemeColorIgnore", true)

        local Divider = Create("Frame", {
            AnchorPoint = Vector2_new(0, 0.5),
            BackgroundColor3 = ThemeColor(50, 50, 50),
            BorderSizePixel = 0,
            Size = UDim2_new(1, 6, 0, 1),
            Visible = false,
            ZIndex = 2,
            Parent = OptionsHolder,
        })

        row = {
            Button = Btn,
            Divider = Divider,
            Hovering = false,
            Selected = false,
            Value = Value,
        }

        function row:UpdateButton()
            if Dropdown.Multi then
                row.Selected = Dropdown.Value[row.Value]
            else
                row.Selected = Dropdown.Value == row.Value
            end
            local selected = row.Selected == true
            local image = ResolveValueImage(Dropdown.ValueImages, row.Value, row.RawValue)
            local hasImage = image ~= nil
            local left = 6 + (selected and 20 or 0) + (hasImage and 24 or 0)
            Check.Visible = selected
            Check.Position = UDim2_new(0, 6 - left, 0.5, -8)
            ValueImage.Visible = hasImage
            ImageSeparator.Visible = selected and hasImage
            ValueImage.Position = UDim2_new(0, (selected and 28 or 6) - left, 0.5, -8)
            ImageSeparator.Position = UDim2_new(0, 24 - left, 0.5, -8)
            if image then
                Library:ApplyIcon(ValueImage, image)
                ValueImage.ImageColor3 = Color3_new(1,1,1)
            end
            Tween(RowPadding, FastTween, {PaddingLeft = UDim_new(0, left)})
            if row.IsDisabled then
                Btn.TextColor3 = row.Selected and ThemeColor(200, 200, 200) or ThemeColor(100, 100, 100)
                Btn.TextTransparency = ThemeTextAlpha(0.65)
            else
                Btn.TextColor3 = row.Selected and ThemeColor(255, 255, 255) or ThemeColor(140, 140, 140)
                Btn.TextTransparency = 0
            end
        end

        Btn.MouseButton1Click:Connect(function()
            if Dropdown.Locked or row.IsDisabled then return end
            if row.Selected and Dropdown:GetActiveValues(true) == 1 and not Dropdown.AllowNull then return end
            local oldValue = Dropdown.Multi and table_clone(Dropdown.Value) or Dropdown.Value
            row.Selected = not row.Selected
            if Dropdown.Multi then
                Dropdown.Value[row.Value] = row.Selected and true or nil
            else
                Dropdown.Value = row.Selected and row.Value or nil
                for _, o in Dropdown.Buttons do o:UpdateButton() end
            end
            row:UpdateButton()
            Dropdown:Update()
            Library:SafeCallback(options.Callback, Dropdown.Value, oldValue)
        end)

        Btn.MouseEnter:Connect(function()
            if Dropdown.Locked or row.IsDisabled then return end
            row.Hovering = true
            local baseColor = row.Selected and ThemeColor(255, 255, 255) or ThemeColor(140, 140, 140)
            local target = baseColor:Lerp(Color3_new(1, 1, 1), 0.6)
            Tween(Btn, FastTween, {TextColor3 = target})
        end)

        Btn.MouseLeave:Connect(function()
            if row.IsDisabled then return end
            row.Hovering = false
            local baseColor = row.Selected and ThemeColor(255, 255, 255) or ThemeColor(140, 140, 140)
            Tween(Btn, FastTween, {TextColor3 = baseColor})
        end)

        Dropdown.Buttons[Value] = row
        return row
    end

    function Dropdown:BuildList()
        local IsDictionary = not IsSequentialArray(Dropdown.Values)
        if Dropdown.Multi then
            for valueName in Dropdown.Value do
                if not ValueExists(valueName) then Dropdown.Value[valueName] = nil end
            end
        else
            if Dropdown.Value ~= nil and not ValueExists(Dropdown.Value) then Dropdown.Value = nil end
        end

        BuildFiltered()

        local total = #filteredCache
        local contentRows = math_max(total, 1)
        listHeight = contentRows * ITEM_HEIGHT
        EmptyMessage.Visible = total == 0
        local visibleHeight = math_min(contentRows * ITEM_HEIGHT, MaxListHeight())
        OptionsHolder.Size = UDim2_new(1, 0, 0, visibleHeight)

        OptionsHolder.CanvasSize = UDim2_fromOffset(0, contentRows * ITEM_HEIGHT)
        local maxScroll = math_max(0, contentRows * ITEM_HEIGHT - visibleHeight)
        if OptionsHolder.CanvasPosition.Y > maxScroll then
            OptionsHolder.CanvasPosition = Vector2_new(0, maxScroll)
        end

        for _, row in Dropdown.Buttons do
            row.Button.Visible = false
            row.Divider.Visible = false
        end

        for i = 1, total do
            local Entry = filteredCache[i]
            if not Entry then break end
            local row = GetOrCreateRow(Entry.Value)
            row.Value = Entry.Value
            row.RawValue = Entry.RawValue
            row.IsDisabled = Entry.IsDisabled
            row.Button.Text = Entry.Formatted
            row.Button.Visible = true
            row.Button.LayoutOrder = (i * 2) - 2
            row.Button.Position = UDim2_fromOffset(0, (i - 1) * ITEM_HEIGHT)

            local absoluteIndex = i
            local showDivider = (absoluteIndex > 1) or (absoluteIndex == 1 and not SearchBox)
            row.Divider.Visible = showDivider
            if showDivider then
                row.Divider.LayoutOrder = (i * 2) - 3
                row.Divider.Position = UDim2_fromOffset(0, (i - 1) * ITEM_HEIGHT)
            end

            row:UpdateButton()
        end

        Dropdown:Update()
        if Dropdown.Opened then ApplyProgress(progress) end
    end

    function Dropdown:SetValue(Value)
        if Dropdown.Multi then
            if typeof(Value) == "string" then
                Value = if Value == "" then {} else { [Value] = true }
            end
            local Table = {}
            for Val, Active in Value or {} do
                if typeof(Active) ~= "boolean" then
                    if ValueExists(Active) and not IsValueDisabled(Active) then Table[Active] = true end
                elseif Active and ValueExists(Val) and not IsValueDisabled(Val) then
                    Table[Val] = true
                end
            end
            if not Dropdown.AllowNull and not next(Table) then
                local default = options.Default or options.Value
                if type(default) == "table" then for key, active in pairs(default) do local candidate = type(key) == "number" and active or key; if ValueExists(candidate) and not IsValueDisabled(candidate) then Table[candidate] = true; break end end
                elseif default ~= nil and ValueExists(default) and not IsValueDisabled(default) then Table[default] = true end
                if not next(Table) then for key, item in pairs(Dropdown.Values) do local candidate = IsSequentialArray(Dropdown.Values) and item or key; if not IsValueDisabled(candidate, item) then Table[candidate] = true; break end end end
            end
            Dropdown.Value = Table
        else
            if ValueExists(Value) and not IsValueDisabled(Value) then
                Dropdown.Value = Value
            elseif not Value then
                Dropdown.Value = nil
            end
        end
        Dropdown:Update()
        Dropdown:UpdateButtons()
        Library:SafeCallback(options.Callback, Dropdown.Value)
    end

    function Dropdown:SelectAll()
        if not self.Selectable or self.Locked then return end
        local selected = {}
        for key, value in pairs(self.Values) do local option = IsSequentialArray(self.Values) and value or key; if not IsValueDisabled(option, value) then selected[option] = true end end
        self:SetValue(selected)
    end
    function Dropdown:DeselectAll()
        if not self.Selectable or self.Locked then return end
        local selected = {}
        if not self.AllowNull then
            local defaults = options.Default or options.Value
            if type(defaults) == "table" then for key, value in pairs(defaults) do local option = type(key) == "number" and value or key; if ValueExists(option) and not IsValueDisabled(option) then selected[option] = true; break end end
            elseif defaults ~= nil and ValueExists(defaults) and not IsValueDisabled(defaults) then selected[defaults] = true end
            if not next(selected) then for key, value in pairs(self.Values) do local option = IsSequentialArray(self.Values) and value or key; if not IsValueDisabled(option, value) then selected[option] = true; break end end end
        end
        self:SetValue(selected)
    end
    if selectionBar then selectAllButton.Activated:Connect(function() Dropdown:SelectAll() end); deselectAllButton.Activated:Connect(function() Dropdown:DeselectAll() end) end

    function Dropdown:SetValueImages(images)
        if typeof(images) ~= "table" then return false end
        self.ValueImages = table_clone(images)
        self:BuildList()
        RefreshPaletteValue()
        return true
    end
    function Dropdown:AddValueImages(images)
        if typeof(images) ~= "table" then return false end
        for value, image in pairs(images) do self.ValueImages[value] = image end
        self:BuildList()
        RefreshPaletteValue()
        return true
    end

    function Dropdown:SetValues(Values)
        Dropdown.Values = Values
        local Changed = false
        if Dropdown.Multi then
            for Val in Dropdown.Value do
                if not ValueExists(Val) or IsValueDisabled(Val) then
                    Dropdown.Value[Val] = nil
                    Changed = true
                end
            end
        elseif Dropdown.Value ~= nil and (not ValueExists(Dropdown.Value) or IsValueDisabled(Dropdown.Value)) then
            Dropdown.Value = nil
            Changed = true
        end
        Dropdown:BuildList()
        Dropdown:Update()
        if Changed then Library:SafeCallback(options.Callback, Dropdown.Value) end
    end

    function Dropdown:AddValues(Values)
        if typeof(Values) ~= "table" and typeof(Values) ~= "string" then return end
        local IsDictionary = not IsSequentialArray(Dropdown.Values)
        if IsDictionary then
            if typeof(Values) == "string" then
                Dropdown.Values[Values] = Values
            elseif IsSequentialArray(Values) then
                for _, Val in Values do Dropdown.Values[Val] = Val end
            else
                for Key, Val in Values do Dropdown.Values[Key] = Val end
            end
        else
            if typeof(Values) == "table" then
                for _, Val in Values do table_insert(Dropdown.Values, Val) end
            else
                table_insert(Dropdown.Values, Values)
            end
        end
        Dropdown:BuildList()
    end

    function Dropdown:SetDisabledValues(DisabledValues)
        Dropdown.DisabledValues = DisabledValues or {}
        local Changed = false
        if Dropdown.Multi then
            for Val in Dropdown.Value do
                if IsValueDisabled(Val) then
                    Dropdown.Value[Val] = nil
                    Changed = true
                end
            end
        elseif Dropdown.Value ~= nil and IsValueDisabled(Dropdown.Value) then
            Dropdown.Value = nil
            Changed = true
        end
        Dropdown:BuildList()
        if Changed then Library:SafeCallback(options.Callback, Dropdown.Value) end
    end

    function Dropdown:AddDisabledValues(DisabledValues)
        if typeof(DisabledValues) == "table" then
            for _, val in DisabledValues do table_insert(Dropdown.DisabledValues, val) end
        elseif typeof(DisabledValues) == "string" or typeof(DisabledValues) == "number" then
            table_insert(Dropdown.DisabledValues, DisabledValues)
        else
            return
        end
        Dropdown:SetDisabledValues(Dropdown.DisabledValues)
    end

    function Dropdown:SetLocked(locked)
        Dropdown.Locked = locked == true

        LockedHover.Visible = Dropdown.Locked
        Icon.Visible = not Dropdown.Locked
        LockedIcon.Visible = Dropdown.Locked

        if Dropdown.Locked and Dropdown.Opened then
            Dropdown:Toggle()
        end
    end

    function Dropdown:Update()
        local Str = ""
        local IsDictionary = not IsSequentialArray(Dropdown.Values)
        if Dropdown.Multi then
            for Key, RawValue in Dropdown.Values do
                local Value = IsDictionary and Key or RawValue
                if Dropdown.Value[Value] then
                    Str = Str .. FormatDisplayValue(RawValue) .. ", "
                end
            end
            Str = Str:sub(1, #Str - 2)
        else
            local DisplayValue = Dropdown.Value
            if IsDictionary and Dropdown.Value ~= nil then
                DisplayValue = Dropdown.Values[Dropdown.Value]
            end
            Str = DisplayValue and FormatDisplayValue(DisplayValue) or ""
        end
        fullDropdownText = Dropdown.Name .. (Str == "" and "" or ": ") .. Str
        UpdateDropdownText()
    end

    function Dropdown:UpdateButtons()
        for _, button in Dropdown.Buttons do button:UpdateButton() end
    end

    function Dropdown:Toggle()
        Dropdown.Opened = not Dropdown.Opened
        Dropdown:AnimateSize(Dropdown.Opened)
    end

    do
        if options.Flag then
            Library.Flags[options.Flag] = Dropdown
        end

        if SearchBox then
            local token = 0
            SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
                Dropdown.SearchText = SearchBox.Text:lower()
                token += 1
                local t = token
                task_defer(function()
                    if t ~= token then return end
                    OptionsHolder.CanvasPosition = Vector2_new(0, 0)
                    Dropdown:BuildList()
                end)
            end)
        end

        LockedHover.MouseEnter:Connect(function()
            Icon.Visible = false
            LockedIcon.Visible = true
        end)

        LockedHover.MouseLeave:Connect(function()
            LockedIcon.Visible = false
            Icon.Visible = true
        end)

        CurrentButton.MouseEnter:Connect(function()
            Dropdown.Hovering = true
            if Dropdown.Locked then return end
            Tween(CurrentButton, FastTween, { TextColor3 = ThemeColor(220, 220, 220) })
        end)

        CurrentButton.MouseLeave:Connect(function()
            Dropdown.Hovering = false
            if Dropdown.Locked then return end
            Tween(CurrentButton, FastTween, { TextColor3 = ThemeColor(220, 220, 220) })
        end)

        CurrentButton.MouseButton1Click:Connect(function() Dropdown:Toggle() end)

        local Defaults = (function()
            local Resolved = {}
            local Default = options.Default
            if Default == nil then Default = options.Value end
            if Default == nil then return Resolved end
            local IsDictionary = not IsSequentialArray(Dropdown.Values)
            local function ResolveOne(Candidate)
                if IsDictionary then return Dropdown.Values[Candidate] ~= nil and Candidate or nil end
                for _, Existing in Dropdown.Values do
                    if Existing == Candidate then return Existing end
                end
                return nil
            end
            local T = typeof(Default)
            if T == "string" then
                local V = ResolveOne(Default)
                if V ~= nil and not IsValueDisabled(V) then table_insert(Resolved, V) end
            elseif T == "table" then
                for _, C in Default do
                    local V = ResolveOne(C)
                    if V ~= nil and not IsValueDisabled(V) then table_insert(Resolved, V) end
                end
            elseif Dropdown.Values[Default] ~= nil then
                local V = IsDictionary and Default or Dropdown.Values[Default]
                if not IsValueDisabled(V) then table_insert(Resolved, V) end
            end
            return Resolved
        end)()

        for _, SelectValue in Defaults do
            if Dropdown.Multi then
                Dropdown.Value[SelectValue] = true
            else
                Dropdown.Value = SelectValue
                break
            end
        end
        if Dropdown.Selectable and not Dropdown.AllowNull and not next(Dropdown.Value) then Dropdown:DeselectAll() end

        Dropdown:BuildList()
        Dropdown:Update()
        ApplyProgress(0)

        if Dropdown.SpecialType == "Player" then
            local function RefreshPlayers()
                if Dropdown.Locked then return end
                Dropdown:SetValues(GetPlayerValues())
            end
            Library:AddConnection(Players.PlayerAdded:Connect(RefreshPlayers))
            Library:AddConnection(Players.PlayerRemoving:Connect(RefreshPlayers))
        end
    end

    RegisterControlForPalette(self, options, Dropdown, "Dropdown")
    return Dropdown
end

    local function EnsureKeybindFrame()
        if Library.KeybindFrame and Library.KeybindFrame.Parent then return Library.KeybindFrame end
        local frame = Create("CanvasGroup", {Name = "KeybindList", AnchorPoint = Vector2_new(1,0.5), Position = UDim2_new(1,-10,0.5,0), Size = UDim2_fromOffset(270,36), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = ThemeColor(25,25,25), GroupTransparency = 1, Visible = false, ZIndex = 30, Parent = UI})
        AttachDPIScale(frame)
        Create("UICorner", {CornerRadius = UDim_new(0,8), Parent = frame})
        AddAnimatedBorder(frame)
        Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Parent = frame})
        local header = Create("TextButton", {Name = "Header", LayoutOrder = -1, AutoButtonColor = false, Active = true, BackgroundColor3 = ThemeColor(35,35,35), Size = UDim2_new(1,0,0,36), Text = "", ZIndex = 31, Parent = frame})
        Create("UIGradient", {Color = ColorSequence_new(Color3_new(1,1,1), Color3_fromRGB(215,215,215)), Rotation = 90, Parent = header})
        local icon = Create("ImageLabel", {BackgroundTransparency = 1, Image = "", ImageColor3 = ThemeColor(220,220,220), AnchorPoint = Vector2_new(0,0.5), Position = UDim2_new(0,12,0.5,0), Size = UDim2_fromOffset(16,16), ZIndex = 32, Parent = header})
        Library:ApplyIcon(icon, Library:GetIcon("keyboard"))
        Create("TextLabel", {BackgroundTransparency = 1, Position = UDim2_fromOffset(38,0), Size = UDim2_new(1,-70,1,0), Text = "Keybinds", TextColor3 = ThemeColor(220,220,220), TextSize = 15, FontFace = SemiBoldFont, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 32, Parent = header})
        Create("Frame", {BackgroundColor3 = ThemeColor(80,80,80), BackgroundTransparency = 0.5, BorderSizePixel = 0, Position = UDim2_new(0,1,1,-1), Size = UDim2_new(1,-2,0,1), ZIndex = 32, Parent = header})
        local minimize = Create("ImageButton", {Name = "Minimize", AutoButtonColor = false, BackgroundTransparency = 1, AnchorPoint = Vector2_new(1,0.5), Position = UDim2_new(1,-7,0.5,0), Size = UDim2_fromOffset(18,18), Image = "", ImageColor3 = ThemeColor(220,220,220), ZIndex = 32, Parent = header})
        Library:ApplyIcon(minimize, Library:GetIcon("chevron-up"))
        MakeDraggable(header, frame)
        local minimizeGeneration = 0
        minimize.Activated:Connect(function()
            Library.KeybindFrameMinimized = not Library.KeybindFrameMinimized
            minimizeGeneration += 1
            local generation = minimizeGeneration
            Tween(minimize, TweenInfo_new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Rotation = Library.KeybindFrameMinimized and 180 or 0})
            for _, child in ipairs(frame:GetChildren()) do if child.Name == "KeybindEntry" then
                child.ClipsDescendants = true
                if not Library.KeybindFrameMinimized then child.Visible = child:GetAttribute("Eligible") == true end
                Tween(child, TweenInfo_new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2_new(1,0,0,Library.KeybindFrameMinimized and 0 or 28)})
                for _, part in ipairs(child:GetChildren()) do
                    if part:IsA("TextLabel") or part:IsA("TextButton") then
                        local properties = {TextTransparency = Library.KeybindFrameMinimized and 1 or 0}
                        if part.Name == "ModeBadge" or part.Name == "FrameKeybind" then properties.BackgroundTransparency = Library.KeybindFrameMinimized and 1 or 0 end
                        Tween(part, TweenInfo_new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), properties)
                        local outline = part:FindFirstChildOfClass("UIStroke")
                        if outline then Tween(outline, TweenInfo_new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Transparency = Library.KeybindFrameMinimized and 1 or 0.25}) end
                    end
                end
                if Library.KeybindFrameMinimized then task_delay(0.2, function() if generation == minimizeGeneration and child.Parent then child.Visible = false end end) end
            end end
        end)
        Library.KeybindFrame = frame
        if Library.KeybindFrameEnabled == nil then Library.KeybindFrameEnabled = false end
        return frame
    end

    local keybindFrameTween, keybindFrameGeneration = nil, 0
    function Library:SetKeybindFrameVisible(visible)
        if self.Unloaded then return end
        local frame = EnsureKeybindFrame()
        self.KeybindFrameEnabled = visible == true
        keybindFrameGeneration += 1
        local generation = keybindFrameGeneration
        if keybindFrameTween then keybindFrameTween:Cancel() end
        if self.KeybindFrameEnabled then frame.Visible = true end
        keybindFrameTween = TweenService:Create(frame, TweenInfo_new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {GroupTransparency = self.KeybindFrameEnabled and 0 or 1})
        keybindFrameTween.Completed:Connect(function(state)
            if generation ~= keybindFrameGeneration or state ~= Enum.PlaybackState.Completed then return end
            keybindFrameTween = nil
            if frame.Parent and not self.KeybindFrameEnabled then frame.Visible = false end
        end)
        keybindFrameTween:Play()
    end
    function Library:OpenKeybindFrame() self:SetKeybindFrameVisible(true) end
    function Library:CloseKeybindFrame() self:SetKeybindFrameVisible(false) end
    function Library:ToggleKeybindFrame() self:SetKeybindFrameVisible(not self.KeybindFrameEnabled) end

    function Components:AddKeyPicker(options: KeyPickerOptions)
        local KeyPickerHolder = Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2_new(1, 0, 0, 32),
            Parent = self.Container,
        })
        AttachTooltip(KeyPickerHolder, options, "Keybind")

        Create("UIPadding", {
            PaddingLeft = UDim_new(0, 11),
            PaddingRight = UDim_new(0, 11),
            Parent = KeyPickerHolder
        })

        local KeyPickerText = Create("TextLabel", {
            TextYAlignment = Enum.TextYAlignment.Center,
            BackgroundTransparency = 1,
            FontFace = RegularFont,
            Size = UDim2_new(1, -72, 1, 0),
            TextTruncate = Enum.TextTruncate.AtEnd,
            Text = options.Name or "Key Picker",
            TextColor3 = ThemeColor(255, 255, 255),
            TextScaled = false, TextSize = 15,
            TextTransparency = ThemeTextAlpha(0.5),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = KeyPickerHolder,
        })

        Create("UIPadding", {
            PaddingBottom = UDim_new(0, 6),
            PaddingRight = UDim_new(0, 4),
            PaddingTop = UDim_new(0, 6),
            Parent = KeyPickerText
        })

        local KeyPickerButton: TextButton = Create("TextButton", {
            TextYAlignment = Enum.TextYAlignment.Center,
            AutoButtonColor = false,
            AnchorPoint = Vector2_new(1, 0.5),
            BackgroundColor3 = ThemeColor(35, 35, 35),
            FontFace = MediumFont,
            Position = UDim2_new(1, -29, 0.5, 0),
            Size = UDim2_fromOffset(40, 24),
            Text = "...",
            TextColor3 = ThemeColor(255, 255, 255),
            TextSize = 14,
            TextTransparency = ThemeTextAlpha(0.5),
            Parent = KeyPickerHolder
        })

        Create("UICorner", { CornerRadius = UDim_new(0, 6), Parent = KeyPickerButton })
        Create("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = ThemeColor(60, 60, 60), Parent = KeyPickerButton })

        local editKey = Create("TextButton", {
            Name = "KeybindClearButton",
            AutoButtonColor = false,
            BackgroundColor3 = ThemeColor(35, 35, 35),
            AnchorPoint = Vector2_new(1, 0.5),
            Position = UDim2_new(1, 0, 0.5, 0),
            Size = UDim2_fromOffset(24, 24),
            Text = "",
            Parent = KeyPickerHolder,
        })
        editKey.Visible = options.Clearable ~= false
        if options.Clearable == false then KeyPickerButton.Position = UDim2_new(1, 0, 0.5, 0) end
        Create("UICorner", { CornerRadius = UDim_new(0, 6), Parent = editKey })
        Create("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = ThemeColor(60, 60, 60), Parent = editKey })
        local editIcon = Create("ImageLabel", {
            AnchorPoint = Vector2_new(0.5, 0.5), BackgroundTransparency = 1,
            Position = UDim2_fromScale(0.5, 0.5), Size = UDim2_fromOffset(16, 16),
            Image = "", ImageTransparency = 0.2, Parent = editKey,
        })
        Library:ApplyIcon(editIcon, Library:GetIcon("pencil"))

        local KeyPicker = {
            Hovering = false,
            KeyPressed = nil,
            State = false,
            Picking = false,
            Keybind = options.Keybind or nil,
            Mode = options.Mode or "Toggle",
            Type = "KeyPicker",
            Holder = KeyPickerHolder,
            Label = KeyPickerText,
            Button = KeyPickerButton,
        }

        local frame = EnsureKeybindFrame()
        local listRow = Create("TextButton", {Name = "KeybindEntry", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2_new(1,0,0,28), Text = "", ClipsDescendants = true, ZIndex = 31, Parent = frame})
        local rowTitle = Create("TextLabel", {BackgroundTransparency = 1, Position = UDim2_fromOffset(10,0), Size = UDim2_new(1,-115,1,0), Text = "", TextTruncate = Enum.TextTruncate.AtEnd, TextColor3 = ThemeColor(220,220,220), TextSize = 13, FontFace = RegularFont, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 32, Parent = listRow})
        local keyText = Create("TextButton", {Name = "FrameKeybind", AutoButtonColor = false, BackgroundColor3 = ThemeColor(30,30,30), AnchorPoint = Vector2_new(1,0.5), Position = UDim2_new(1,-62,0.5,0), Size = UDim2_fromOffset(40,20), Text = "", TextTruncate = Enum.TextTruncate.AtEnd, TextColor3 = ThemeColor(200,200,200), TextSize = 12, FontFace = RegularFont, ZIndex = 32, Parent = listRow})
        Create("UICorner", {CornerRadius = UDim_new(0,4), Parent = keyText}); Create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = ThemeColor(60,60,60), Transparency = 0.3, Parent = keyText})
        local modeBadge = Create("TextLabel", {Name = "ModeBadge", AnchorPoint = Vector2_new(1,0.5), Position = UDim2_new(1,-8,0.5,0), Size = UDim2_fromOffset(50,20), Text = "", TextColor3 = ThemeColor(200,200,200), BackgroundColor3 = ThemeColor(35,35,35), TextSize = 11, FontFace = RegularFont, ZIndex = 32, Parent = listRow})
        Create("UICorner", {CornerRadius = UDim_new(0,4), Parent = modeBadge}); Create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = ThemeColor(80,80,80), Transparency = 0.25, Parent = modeBadge})
        Create("Frame", {Name = "Divider", BackgroundColor3 = ThemeColor(80,80,80), BackgroundTransparency = 0.65, BorderSizePixel = 0, Position = UDim2_new(0,1,1,-1), Size = UDim2_new(1,-2,0,1), ZIndex = 32, Parent = listRow})
        local function RefreshList()
            local eligible = options.NoUI ~= true and (KeyPicker.Keybind ~= nil or KeyPicker.Mode == "Always")
            listRow:SetAttribute("Eligible", eligible)
            listRow.Visible = eligible and not Library.KeybindFrameMinimized
            rowTitle.Text = options.Name or "Keybind"
            keyText.Text = KeyPicker.Keybind and (KeyCodesName[KeyPicker.Keybind] or KeyPicker.Keybind.Name) or "None"
            modeBadge.Text = KeyPicker.Mode
            local active = options._Toggle and options._Toggle.Value or (not options._Toggle and KeyPicker.State)
            rowTitle.TextColor3 = active and ThemeColor(60,200,100) or ThemeColor(200,200,200)
        end
        KeyPicker.RefreshList = RefreshList
        listRow.Activated:Connect(function()
            if KeyPicker.Locked or KeyPicker.Mode == "Always" or KeyPicker.Mode == "Hold" then return end
            if options._Toggle then if not options._Toggle.Locked then options._Toggle:Set(not options._Toggle.Value) end else KeyPicker:SetState(not KeyPicker.State) end
        end)
        local holdingRow
        local function ReleaseHeldRow()
            if not holdingRow then return end
            holdingRow = nil
            if options._Toggle then options._Toggle:Set(false) else KeyPicker:SetState(false) end
        end
        listRow.InputBegan:Connect(function(input)
            if KeyPicker.Mode ~= "Hold" or KeyPicker.Locked or (input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch) then return end
            holdingRow = input
            if options._Toggle then if not options._Toggle.Locked then options._Toggle:Set(true) end else KeyPicker:SetState(true) end
        end)
        Library:AddConnection(UserInputService.InputEnded:Connect(function(input)
            if holdingRow and (input == holdingRow or (holdingRow.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseButton1)) then ReleaseHeldRow() end
        end))
        Library:AddConnection(UserInputService.WindowFocusReleased:Connect(ReleaseHeldRow))
        local modeMenu = Create("CanvasGroup", {Name = "KeybindModeMenu", BackgroundColor3 = ThemeColor(25,25,25), Size = UDim2_fromOffset(116,96), Visible = false, GroupTransparency = 1, ZIndex = 70, Parent = UI})
        AttachDPIScale(modeMenu)
        KeyPicker.ModeMenu = modeMenu
        Create("UICorner", {CornerRadius = UDim_new(0,6), Parent = modeMenu})
        AddAnimatedBorder(modeMenu)
        Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim_new(0,2), Parent = modeMenu})
        Create("UIPadding", {PaddingLeft = UDim_new(0,4), PaddingRight = UDim_new(0,4), PaddingTop = UDim_new(0,4), PaddingBottom = UDim_new(0,4), Parent = modeMenu})
        local modeButtons = {}
        local modeGeneration, modeIsOpen, modeTween = 0, false, nil
        local setModeMenuVisible
        setModeMenuVisible = function(show)
            if show then
                if Library._CloseModeMenu and Library._CloseModeMenu ~= setModeMenuVisible then Library._CloseModeMenu(false) end
                Library._CloseModeMenu = setModeMenuVisible
            elseif Library._CloseModeMenu == setModeMenuVisible then
                Library._CloseModeMenu = nil
            end
            modeGeneration += 1
            local generation = modeGeneration
            modeIsOpen = show
            if modeTween then modeTween:Cancel() end
            if show then modeMenu.Visible = true end
            local tween = TweenService:Create(modeMenu, TweenInfo_new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {GroupTransparency = show and 0 or 1})
            modeTween = tween
            tween:Play()
            tween.Completed:Connect(function(state)
                if generation ~= modeGeneration or state ~= Enum.PlaybackState.Completed then return end
                modeTween = nil
                if not show and modeMenu.Parent then modeMenu.Visible = false end
            end)
        end
        function KeyPicker:SetMode(mode)
            if mode ~= "Always" and mode ~= "Hold" and mode ~= "Toggle" then return false end
            if options.FixedMode and mode ~= "Toggle" then return false end
            ReleaseHeldRow()
            self.Mode = mode
            self.ModeChanging = true
            self:SetState(mode == "Always")
            self.ModeChanging = false
            if mode == "Always" and options._Toggle and not options._Toggle.Locked then options._Toggle:Set(true) end
            for name, button in pairs(modeButtons) do button.TextColor3 = name == mode and ThemeColor(255,255,255) or ThemeColor(200,200,200); button.BackgroundTransparency = name == mode and 0 or 1; local stroke = button:FindFirstChildOfClass("UIStroke"); if stroke then stroke.Color = name == mode and ThemeColor(60,200,100) or ThemeColor(60,60,60) end end
            RefreshList()
            return true
        end
        for order, mode in ipairs({"Always", "Hold", "Toggle"}) do
            local button = Create("TextButton", {Name = mode, AutoButtonColor = false, BackgroundColor3 = ThemeColor(25,25,25):Lerp(ThemeColor(60,200,100),0.25), BackgroundTransparency = 1, Size = UDim2_new(1,0,0,28), LayoutOrder = order, Text = mode, TextColor3 = ThemeColor(200,200,200), FontFace = RegularFont, TextSize = 12, ZIndex = 71, Parent = modeMenu})
            Create("UICorner", {CornerRadius = UDim_new(0,4), Parent = button})
            Create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = ThemeColor(60,60,60), Transparency = 0.25, Parent = button})
            modeButtons[mode] = button
            button.Activated:Connect(function() KeyPicker:SetMode(mode); setModeMenuVisible(false) end)
        end
        local function RefreshModeTheme()
            if not modeMenu.Parent then return end
            for Mode, Button in pairs(modeButtons) do
                if Button.Parent then
                    local Selected = Mode == KeyPicker.Mode
                    Button.BackgroundColor3 = ThemeColor(25,25,25):Lerp(ThemeColor(60,200,100),0.25)
                    Button.TextColor3 = Selected and ThemeColor(255,255,255) or ThemeColor(200,200,200)
                    Button.BackgroundTransparency = Selected and 0 or 1
                    local Stroke = Button:FindFirstChildOfClass("UIStroke")
                    if Stroke then Stroke.Color = Selected and ThemeColor(60,200,100) or ThemeColor(60,60,60) end
                end
            end
        end
        Library.ThemeToggleRefreshers = Library.ThemeToggleRefreshers or {}
        table_insert(Library.ThemeToggleRefreshers, RefreshModeTheme)
        local function ToggleModeMenu(anchor)
            if KeyPicker.Locked or KeyPicker.Picking or options.FixedMode then return end
            local inset = game:GetService("GuiService"):GetGuiInset()
            local camera = workspace.CurrentCamera
            local view = camera and camera.ViewportSize or Vector2_new(800,600)
            local target = anchor == listRow and frame or anchor
            local right = target.AbsolutePosition.X + target.AbsoluteSize.X + 7
            local width, height = 116 * Library.MobileScale.Scale, 96 * Library.MobileScale.Scale
            local x = math_clamp(right + width <= view.X and right or target.AbsolutePosition.X - width - 7, 0, math_max(0, view.X - width))
            local y = math_clamp(anchor.AbsolutePosition.Y - inset.Y + anchor.AbsoluteSize.Y / 2 - height / 2, 0, math_max(0, view.Y - inset.Y - height))
            modeMenu.Position = UDim2_fromOffset(x,y)
            setModeMenuVisible(not modeIsOpen)
        end
        KeyPickerButton.MouseButton2Click:Connect(function() ToggleModeMenu(KeyPickerButton) end)
        listRow.MouseButton2Click:Connect(function() ToggleModeMenu(listRow) end)
        Library:AddConnection(UserInputService.InputBegan:Connect(function(input)
            if not modeIsOpen or (input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch) then return end
            local p, a, size = input.Position, modeMenu.AbsolutePosition, modeMenu.AbsoluteSize
            if p.X < a.X or p.X > a.X + size.X or p.Y < a.Y or p.Y > a.Y + size.Y then setModeMenuVisible(false) end
        end))

        function KeyPicker:SetKeybind(keybind, picking)
            if picking then KeyPicker:Update(KeyPicker.Keybind, true) return end
            local previousKeybind = KeyPicker.Keybind
            KeyPicker.Keybind = GetKeybindFromString(keybind)
            KeyPicker.KeyPressed = nil
            KeyPicker.Picking = false
            if previousKeybind and not KeyPicker.Keybind then
                KeyPicker.Clearing = true
                if KeyPicker.State then KeyPicker:SetState(false) end
                if options._Toggle and options._Toggle.Value and not options._Toggle.Locked then options._Toggle:Set(false) end
                KeyPicker.Clearing = false
            end
            KeyPicker:Update(KeyPicker.Keybind, false)
            RefreshList()
        end

        function KeyPicker:SetValue(value) self:SetKeybind(value) end
        function KeyPicker:Set(value) self:SetKeybind(value) end
        function KeyPicker:Clear() self:SetKeybind(nil) end

        function KeyPicker:SetState(state: boolean)
            local oldState = KeyPicker.State
            KeyPicker.State = state
            if KeyPicker.State ~= oldState then
                Library:SafeCallback(options.Callback, KeyPicker.State, oldState)
            end
            RefreshList()
        end

        function KeyPicker:SetLocked(locked)
            KeyPicker.Locked = locked == true
            KeyPickerButton.Visible = not KeyPicker.Locked
            editKey.Visible = not KeyPicker.Locked and options.Clearable ~= false
            KeyPickerText.TextTransparency = ThemeTextAlpha(KeyPicker.Locked and 0.75 or 0.5)
        end

        function KeyPicker:Update(keybind, picking)
            local keyText = picking and "..." or (keybind and (KeyCodesName[keybind] or string_sub(keybind.Name, 1, 6)) or "None")
            local size = GetTextBounds(keyText, MediumFont, 14, Library.UISize - 24)
            local width = math_clamp((size and size.X or 26) + 16, options._Inline and 28 or 40, options._Inline and 52 or 100)
            KeyPickerButton.Size = UDim2_fromOffset(width, 24)
            KeyPickerText.Size = UDim2_new(1, -(width + (options.Clearable == false and 6 or 35)), 1, 0)
            KeyPickerButton.Text = keyText
            local frameKey = listRow:FindFirstChild("FrameKeybind")
            if frameKey then
                frameKey.Text = keyText
                frameKey.Size = UDim2_fromOffset(picking and 48 or 40, 20)
                frameKey.TextSize = picking and 15 or 12
                rowTitle.Size = UDim2_new(1, picking and -123 or -115, 1, 0)
            end
        end

        if options.Flag then
            Library.Flags[options.Flag] = KeyPicker
        end

        KeyPickerButton.MouseEnter:Connect(function()
            KeyPicker.Hovering = true
            Tween(KeyPickerButton, FastTween, {TextTransparency = ThemeTextAlpha(0.25)})
        end)

        KeyPickerButton.MouseLeave:Connect(function()
            KeyPicker.Hovering = false
            Tween(KeyPickerButton, FastTween, {TextTransparency = ThemeTextAlpha(0.5)})
        end)

        local function PickKey()
            if KeyPicker.Picking or KeyPicker.Locked then return end
            KeyPicker.Picking = true
            Library.ActiveKeyPicker = KeyPicker
            KeyPicker:SetKeybind(nil, true)

            local inputObject = UserInputService.InputBegan:Wait()
            local isKeyCode = inputObject.KeyCode ~= Enum.KeyCode.Unknown
            
            task_defer(function()
                if Library.ActiveKeyPicker == KeyPicker then Library.ActiveKeyPicker = nil end
            end)

            if isKeyCode and (inputObject.KeyCode == Enum.KeyCode.Escape or inputObject.KeyCode == Enum.KeyCode.Backspace or inputObject.KeyCode == Enum.KeyCode.Delete) then
                if options.Clearable ~= false then KeyPicker:SetKeybind(nil) else KeyPicker:SetKeybind(KeyPicker.Keybind) end
                KeyPicker.Picking = false
                return
            end

            local selected = isKeyCode and inputObject.KeyCode or inputObject.UserInputType
            KeyPicker:SetKeybind(selected)
            KeyPicker.KeyPressed = selected
            KeyPicker.Picking = true
        end
        KeyPickerButton.MouseButton1Click:Connect(PickKey)
        keyText.Activated:Connect(PickKey)
        editKey.MouseButton1Click:Connect(function()
            if not KeyPicker.Locked and not KeyPicker.Picking then KeyPicker:Clear() end
        end)
        editKey.MouseEnter:Connect(function() Tween(editIcon, FastTween, {ImageTransparency = 0}) end)
        editKey.MouseLeave:Connect(function() Tween(editIcon, FastTween, {ImageTransparency = 0.2}) end)

        Library:AddConnection(UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
            if Library.ActiveKeyPicker then return end
            if KeyPicker.Mode ~= "Always" and KeyPicker.Keybind and (input.KeyCode == KeyPicker.Keybind or input.UserInputType == KeyPicker.Keybind) and not KeyPicker.Picking and not gameProcessedEvent and not UserInputService:GetFocusedTextBox() then
                if KeyPicker.Mode == "Hold" then
                    KeyPicker:SetState(true)
                else
                    KeyPicker:SetState(not KeyPicker.State)
                end
            end
        end))

        Library:AddConnection(UserInputService.InputEnded:Connect(function(input)
            if KeyPicker.Keybind and (input.KeyCode == KeyPicker.Keybind or input.UserInputType == KeyPicker.Keybind) and not KeyPicker.Picking then
                if KeyPicker.Mode == "Hold" then KeyPicker:SetState(false) end
            elseif (input.KeyCode == KeyPicker.KeyPressed or input.UserInputType == KeyPicker.KeyPressed) and KeyPicker.Picking then
                KeyPicker.KeyPressed = nil
                KeyPicker.Picking = false
            end
        end))

        KeyPicker:SetKeybind(KeyPicker.Keybind)
        KeyPicker:SetMode(KeyPicker.Mode)
    RegisterControlForPalette(self, options, KeyPicker, "Keybind")
        return KeyPicker
    end

    local copiedPickerColor
    local ActiveRainbowPickers = setmetatable({}, {__mode = "k"})
    Library:AddConnection(RunService.Heartbeat:Connect(function(dt)
        for Picker in pairs(ActiveRainbowPickers) do
            if Picker.Rainbow and not Library.Unloaded then
                Picker.Hue = (Picker.Hue + dt * 0.12) % 1
                Picker.Sat, Picker.Vib = 1, 1
                Picker:Update()
            else
                ActiveRainbowPickers[Picker] = nil
            end
        end
    end))

    function Components:AddColorPicker(options: ColorPickerOptions)
        local ColorPickerHolder = Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2_new(1, 0, 0, 42),
            Parent = self.Container
        })
        AttachTooltip(ColorPickerHolder, options, "Color picker")

        Create("UIPadding", {
            PaddingBottom = UDim_new(0, 5),
            PaddingLeft = UDim_new(0, 13),
            PaddingRight = UDim_new(0, 13),
            PaddingTop = UDim_new(0, 5),
            Parent = ColorPickerHolder
        })

        local ButtonsHolder = Create("Frame", {
            BackgroundColor3 = ThemeColor(25, 25, 25),
            Size = UDim2_fromScale(1, 1),
            ClipsDescendants = true,
            Parent = ColorPickerHolder
        })

        Create("UICorner", { CornerRadius = UDim_new(0, 6), Parent = ButtonsHolder })
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = ThemeColor(60, 60, 60),
            Parent = ButtonsHolder
        })
        Create("UIGradient", {Color = ColorSequence_new(Color3_new(1,1,1), Color3_fromRGB(230,230,230)), Rotation = 90, Parent = ButtonsHolder})

        local OpenButton: TextButton = Create("TextButton", {
            TextYAlignment = Enum.TextYAlignment.Center,
            BackgroundTransparency = 1,
            FontFace = RegularFont,
            Size = UDim2_new(1, 0, 0, 32),
            Text = options.Name or "No Name",
            TextColor3 = ThemeColor(140, 140, 140),
            TextScaled = false, TextSize = 15,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = ButtonsHolder
        })

        Create("UIPadding", {
            PaddingBottom = UDim_new(0, 6),
            PaddingLeft = UDim_new(0, 29),
            PaddingRight = UDim_new(0, 30),
            PaddingTop = UDim_new(0, 6),
            Parent = OpenButton
        })
        local colorIcon = Create("ImageLabel", {
            Name = "ColorPickerIcon", BackgroundTransparency = 1, Image = "",
            ImageColor3 = ThemeColor(200,200,200), ImageTransparency = 0.2,
            Position = UDim2_fromOffset(7,8), Size = UDim2_fromOffset(16,16), Parent = ButtonsHolder,
        })
        Library:ApplyIcon(colorIcon, Library:GetIcon("palette"))
        local colorHeaderDivider = Create("Frame", {Name = "ColorHeaderDivider", BorderSizePixel = 0, BackgroundColor3 = ThemeColor(80,80,80), BackgroundTransparency = 0.55, Position = UDim2_fromOffset(6,31), Size = UDim2_new(1,-12,0,1), Visible = false, Parent = ButtonsHolder})

        local pickerScroll = Create("Frame", {Name = "PickerContents", BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2_fromOffset(0,32), Size = UDim2_new(1,0,1,-32), Parent = ButtonsHolder})
        local ColorHolder = Create("Frame", {
            BackgroundTransparency = 1,
            Position = UDim2_fromOffset(0, 0),
            Size = UDim2_new(1, 0, 0, Library.UISize - 50),
            Visible = false,
            Parent = pickerScroll
        })

        Create("UIPadding", {
            PaddingBottom = UDim_new(0, 6),
            PaddingLeft = UDim_new(0, 6),
            PaddingRight = UDim_new(0, 6),
            PaddingTop = UDim_new(0, 6),
            Parent = ColorHolder
        })

        local ColorImage = Create("ImageLabel", {
            BackgroundColor3 = options.Color or Color3_new(1, 1, 1),
            Image = "rbxassetid://4155801252",
            Size = UDim2_new(1, -22, 1, 0),
            Parent = ColorHolder
        })

        Create("UICorner", {CornerRadius = UDim_new(0, 5), Parent = ColorImage})
        ColorImage:SetAttribute("ThemeColorIgnore", true)

        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = ThemeColor(60, 60, 60),
            Thickness = 1,
            Parent = ColorImage,
        })

        local ColorImageIndicator = Create("Frame", {
            AnchorPoint = Vector2_new(0.5, 0.5),
            BackgroundColor3 = Color3_new(1, 1, 1),
            Size = UDim2_fromOffset(6, 6),
            Parent = ColorImage
        })

        Create("UICorner", { CornerRadius = UDim_new(0, 6), Parent = ColorImageIndicator })
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = Color3_new(0, 0, 0),
            Parent = ColorImageIndicator
        })

        local ColorHue: TextButton = Create("TextButton", {
            AutoButtonColor = false,
            AnchorPoint = Vector2_new(1, 0),
            BackgroundColor3 = Color3_new(1, 1, 1),
            Position = UDim2_fromScale(1, 0),
            Size = UDim2_new(0, 16, 1, 0),
            Text = "",
            Parent = ColorHolder
        })

        Create("UICorner", {CornerRadius = UDim_new(0, 5), Parent = ColorHue})
        ColorHue:SetAttribute("ThemeColorIgnore", true)
        Create("UIGradient", {
            Color = ColorSequence_new(HueSequenceTable),
            Rotation = 90,
            Parent = ColorHue
        })

        local ColorHueIndicator = Create("Frame", {
            AnchorPoint = Vector2_new(0.5, 0.5),
            BackgroundColor3 = Color3_new(1, 1, 1),
            BorderColor3 = Color3_new(0, 0, 0),
            BorderSizePixel = 1,
            Position = UDim2_fromScale(0.5, 0.5),
            Size = UDim2_new(1, 2, 0, 2),
            Parent = ColorHue
        })

        ColorHueIndicator:SetAttribute("ThemeColorIgnore", true)
        ColorImageIndicator:SetAttribute("ThemeColorIgnore", true)
        for _, child in ipairs(ColorImageIndicator:GetChildren()) do
            if child:IsA("UIStroke") then child:SetAttribute("ThemeColorIgnore", true) end
        end

        local ColorIndicator = Create("Frame", {
            AnchorPoint = Vector2_new(1, 0),
            BackgroundColor3 = options.Color or Color3_new(1, 1, 1),
            Position = UDim2_new(1, -6, 0, 6),
            Size = UDim2_fromOffset(20, 20),
            Parent = ColorPickerHolder
        })

        local colorGlows = {}
        for index = 5, 1, -1 do
            local spread = index * 3
            local layer = Create("Frame", {
                Name = "ColorSwatchGlow", BackgroundColor3 = options.Color or Color3_new(1,1,1),
                BackgroundTransparency = 0.78 + index * 0.04, BorderSizePixel = 0,
                AnchorPoint = Vector2_new(0.5,0.5), Position = UDim2_new(1,-16,0,16),
                Size = UDim2_fromOffset(20 + spread * 2, 20 + spread * 2), ZIndex = 1, Parent = ColorPickerHolder,
            })
            layer:SetAttribute("ThemeColorIgnore", true)
            Create("UICorner", {CornerRadius = UDim_new(0, 6 + spread), Parent = layer})
            table_insert(colorGlows, layer)
        end
        ColorIndicator.ZIndex = 2
        ColorIndicator:SetAttribute("ThemeColorIgnore", true)
        Create("UICorner", { CornerRadius = UDim_new(0, 6), Parent = ColorIndicator })
        Create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = ThemeColor(80,80,80), Transparency = 0.35, Parent = ColorIndicator})

        local ColorPicker = {
            DraggingColor = false,
            DraggingHue = false,
            Locked = false,
            Hovering = false,
            Opened = false,
            Hue = 0, Sat = 0, Vib = 0,
            Color = options.Color or Color3_new(1, 1, 1),
            Type = "ColorPicker",
            AllowTrans = options.AllowTrans == true, AllowRainbow = options.AllowRainbow == true,
            Transparency = options.AllowTrans and math_clamp(tonumber(options.Transparency) or 0, 0, 1) or 0,
            Rainbow = false,
        }

        local openTweenInfo = TweenInfo_new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        local closeTweenInfo = TweenInfo_new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local CLOSED_HEIGHT = 42
        local controlsHeight = 36 + (ColorPicker.AllowTrans and 42 or 0) + (ColorPicker.AllowRainbow and 32 or 0)
        local bodyHeight = Library.UISize - 50 + controlsHeight
        local OPEN_HEIGHT = CLOSED_HEIGHT + bodyHeight
        local activeTween

        local controls = Create("Frame", {
            BackgroundTransparency = 1,
            Position = UDim2_fromOffset(0, Library.UISize - 50),
            Size = UDim2_new(1, 0, 0, controlsHeight),
            Visible = false,
            Parent = pickerScroll,
        })
        local hexInput = Create("TextBox", {
            BackgroundColor3 = ThemeColor(38, 38, 38),
            ClearTextOnFocus = false,
            FontFace = RegularFont,
            TextSize = 14,
            TextColor3 = ThemeColor(140, 140, 140),
            Position = UDim2_fromOffset(6, 3),
            Size = UDim2_new(1, -112, 0, 26),
            Text = "",
            Parent = controls,
        })
        Create("UICorner", {CornerRadius = UDim_new(0, 6), Parent = hexInput})
        hexInput:SetAttribute("ThemeInputSurface", 38)
        local hexStroke = Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = ThemeColor(60, 60, 60),
            Parent = hexInput,
        })
        local hexHover = false
        local function UpdateHexHover()
            local focused = hexInput:IsFocused()
            Tween(hexInput, FastTween, {
                BackgroundColor3 = focused and ThemeColor(38,38,38) or (hexHover and ThemeColor(42,42,42) or ThemeColor(38,38,38)),
                TextColor3 = focused and ThemeColor(255,255,255) or (hexHover and ThemeColor(200,200,200) or ThemeColor(140,140,140)),
            })
            Tween(hexStroke, FastTween, {Color = focused and ThemeColor(90,90,90) or (hexHover and ThemeColor(80,80,80) or ThemeColor(60,60,60))})
        end
        hexInput.MouseEnter:Connect(function() hexHover = true UpdateHexHover() end)
        hexInput.MouseLeave:Connect(function() hexHover = false UpdateHexHover() end)
        hexInput.Focused:Connect(UpdateHexHover)
        hexInput.FocusLost:Connect(function() task_defer(UpdateHexHover) end)
        local function MakeButton(label, x)
            local b = Create("TextButton", {
                AutoButtonColor = false,
                BackgroundColor3 = ThemeColor(35, 35, 35),
                FontFace = RegularFont,
                TextSize = 13,
                TextColor3 = ThemeColor(220, 220, 220),
                Position = UDim2_new(1, x, 0, 3),
                Size = UDim2_fromOffset(46, 26),
                Text = label,
                Parent = controls,
            })
            Create("UICorner", {CornerRadius = UDim_new(0, 6), Parent = b})
            local stroke = Create("UIStroke", {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                Color = ThemeColor(60, 60, 60),
                Parent = b,
            })
            b.MouseEnter:Connect(function() Tween(b, FastTween, {BackgroundColor3 = ThemeColor(50, 50, 50)}) Tween(stroke, FastTween, {Color = ThemeColor(100, 100, 100)}) end)
            b.MouseLeave:Connect(function() Tween(b, FastTween, {BackgroundColor3 = ThemeColor(35, 35, 35)}) Tween(stroke, FastTween, {Color = ThemeColor(60, 60, 60)}) end)
            return b
        end
        local copyButton, pasteButton = MakeButton("Copy", -100), MakeButton("Paste", -50)
        local y = 36
        local transLabel, transValue, transBar, transFill, rainbowButton, rainbowKnob, rainbowStroke
        if ColorPicker.AllowTrans then
            transLabel = Create("TextLabel", {
                BackgroundTransparency = 1,
                FontFace = RegularFont,
                TextSize = 14,
                TextColor3 = ThemeColor(255, 255, 255),
                TextTransparency = ThemeTextAlpha(0.5),
                TextXAlignment = Enum.TextXAlignment.Left,
                Position = UDim2_fromOffset(6, y),
                Size = UDim2_new(1, -60, 0, 22),
                Text = "Transparency",
                Parent = controls,
            })
            transValue = Create("TextLabel", {
                BackgroundColor3 = ThemeColor(35,35,35),
                FontFace = RegularFont,
                TextSize = 12,
                TextColor3 = ThemeColor(255, 255, 255),
                TextTransparency = ThemeTextAlpha(0.5),
                TextXAlignment = Enum.TextXAlignment.Center,
                Position = UDim2_new(1, -54, 0, y),
                Size = UDim2_fromOffset(48, 22),
                Text = "0%",
                Parent = controls,
            })
            Create("UICorner", {CornerRadius = UDim_new(0, 6), Parent = transValue})
            Create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = ThemeColor(60,60,60), Transparency = 0.3, Parent = transValue})
            transBar = Create("TextButton", {
                BackgroundColor3 = ThemeColor(60, 60, 60),
                Position = UDim2_fromOffset(6, y + 25),
                Size = UDim2_new(1, -12, 0, 6),
                Text = "",
                AutoButtonColor = false,
                Parent = controls,
            })
            Create("UICorner", {CornerRadius = UDim_new(1, 0), Parent = transBar})
            transFill = Create("Frame", {
                BackgroundColor3 = ThemeColor(60, 200, 100),
                Size = UDim2_fromScale(0, 1),
                BorderSizePixel = 0,
                Parent = transBar,
            })
            Create("UICorner", {CornerRadius = UDim_new(1, 0), Parent = transFill})
            Create("UIGradient", {Color = ColorSequence_new(Color3_new(1,1,1), Color3_fromRGB(205,205,205)), Rotation = 90, Parent = transFill})
            local transKnob = Create("Frame", {Name = "TransparencyKnob", AnchorPoint = Vector2_new(0.5,0.5), Position = UDim2_new(1,0,0.5,0), Size = UDim2_fromOffset(12,12), BackgroundColor3 = Color3_new(1,1,1), Parent = transFill})
            Create("UICorner", {CornerRadius = UDim_new(1,0), Parent = transKnob})
            Create("UIStroke", {Color = ThemeColor(60,200,100), Parent = transKnob})
            transBar.MouseEnter:Connect(function()
                if ColorPicker.Locked then return end
                Tween(transFill, FastTween, {BackgroundColor3 = ThemeColor(60, 200, 100):Lerp(Color3_new(1,1,1),0.15)})
                Tween(transBar, FastTween, {BackgroundColor3 = ThemeColor(85, 85, 85)})
                Tween(transLabel, FastTween, {TextTransparency = ThemeTextAlpha(0.25)})
            end)
            transBar.MouseLeave:Connect(function()
                Tween(transFill, FastTween, {BackgroundColor3 = ThemeColor(60, 200, 100)})
                Tween(transBar, FastTween, {BackgroundColor3 = ThemeColor(60, 60, 60)})
                Tween(transLabel, FastTween, {TextTransparency = ThemeTextAlpha(0.5)})
            end)
            y += 42
        end
        if ColorPicker.AllowRainbow then
            Create("TextLabel", {
                BackgroundTransparency = 1,
                FontFace = RegularFont,
                TextSize = 14,
                TextColor3 = ThemeColor(255, 255, 255),
                TextTransparency = ThemeTextAlpha(0.5),
                TextXAlignment = Enum.TextXAlignment.Left,
                Position = UDim2_fromOffset(6, y),
                Size = UDim2_new(1, -48, 0, 24),
                Text = "Rainbow",
                Parent = controls,
            })
            rainbowButton = Create("TextButton", {
                AutoButtonColor = false,
                BackgroundColor3 = ThemeColor(35,35,35),
                AnchorPoint = Vector2_new(1, 0.5),
                Position = UDim2_new(1, -6, 0, y + 12),
                Size = UDim2_fromOffset(32, 16),
                Text = "",
                Parent = controls,
            })
            Create("UIGradient", {Color = ColorSequence_new(Color3_new(1,1,1), Color3_fromRGB(190,190,190)), Rotation = 90, Parent = rainbowButton})
            Create("UICorner", {CornerRadius = UDim_new(1, 0), Parent = rainbowButton})
            Create("UIPadding", {
                PaddingBottom = UDim_new(0, 2),
                PaddingLeft = UDim_new(0, 2),
                PaddingRight = UDim_new(0, 2),
                PaddingTop = UDim_new(0, 2),
                Parent = rainbowButton,
            })
            rainbowStroke = Create("UIStroke", {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                Color = ThemeColor(60, 60, 60),
                Parent = rainbowButton,
            })
            rainbowKnob = Create("Frame", {
                BackgroundColor3 = ThemeColor(140, 140, 140),
                Size = UDim2_fromScale(1, 1),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Parent = rainbowButton,
            })
            Create("UICorner", {CornerRadius = UDim_new(1, 0), Parent = rainbowKnob})
            local function UpdateRainbowHover(hovering)
                if ColorPicker.Locked then return end
                local base = ColorPicker.Rainbow and EnabledToggleColor or DefaultToggleColor
                local color = hovering and base:Lerp(Color3_new(1, 1, 1), 0.3) or base
                Tween(rainbowButton, FastTween, {BackgroundColor3 = ColorPicker.Rainbow and color or ThemeColor(35,35,35)})
                Tween(rainbowStroke, FastTween, {Color = color})
            end
            rainbowButton.MouseEnter:Connect(function() UpdateRainbowHover(true) end)
            rainbowButton.MouseLeave:Connect(function() UpdateRainbowHover(false) end)
        end
        local function ParseColor(value)
            local text = tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", "")
            local hex = text:match("^#?(%x%x%x%x%x%x)$")
            if hex then return Color3_fromHex(hex) end
            local r, g, b = text:match("^%s*%(?%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*%)?%s*$")
            if r and tonumber(r) <= 255 and tonumber(g) <= 255 and tonumber(b) <= 255 then return Color3_fromRGB(tonumber(r), tonumber(g), tonumber(b)) end
        end
        local function applyText(value)
            local color = ParseColor(value)
            if color then ColorPicker:SetRainbow(false) ColorPicker:SetColor(color) return true end
            return false
        end
        copyButton.MouseButton1Click:Connect(function()
            local color = ColorPicker.Color
            copiedPickerColor = ("%d, %d, %d"):format(math_floor(color.R * 255 + .5), math_floor(color.G * 255 + .5), math_floor(color.B * 255 + .5))
            if type(setclipboard) == "function" then pcall(setclipboard, copiedPickerColor) end
        end)
        pasteButton.MouseButton1Click:Connect(function()
            if not applyText(copiedPickerColor or "") then hexInput:CaptureFocus() end
        end)
        hexInput.FocusLost:Connect(function() if not applyText(hexInput.Text) then hexInput.Text = "#" .. ColorPicker.Color:ToHex():upper() end end)
        function ColorPicker:SetTransparency(value)
            if not ColorPicker.AllowTrans then return end
            local old = ColorPicker.Transparency
            ColorPicker.Transparency = math_clamp(tonumber(value) or 0, 0, 1)
            transFill.Size = UDim2_fromScale(ColorPicker.Transparency, 1)
            transValue.Text = ("%d%%"):format(math_floor(ColorPicker.Transparency * 100 + 0.5))
            if old ~= ColorPicker.Transparency then Library:SafeCallback(options.Callback, ColorPicker.Color, ColorPicker.Color, ColorPicker.Transparency) end
        end
        function ColorPicker:SetRainbow(enabled)
            ColorPicker.Rainbow = ColorPicker.AllowRainbow and enabled == true
            ActiveRainbowPickers[ColorPicker] = ColorPicker.Rainbow or nil
            if ColorPicker.Rainbow then
                ColorPicker.DraggingColor = false
                ColorPicker.DraggingHue = false
            end
            if rainbowButton then
                local color = ColorPicker.Rainbow and EnabledToggleColor or DefaultToggleColor
                rainbowStroke.Color = color
                rainbowButton.BackgroundColor3 = ColorPicker.Rainbow and EnabledToggleColor or ThemeColor(35,35,35)
                rainbowKnob.BackgroundColor3 = ColorPicker.Rainbow and Color3_new(1,1,1) or ThemeColor(140,140,140)
                Tween(rainbowKnob, FastTween, {Position = ColorPicker.Rainbow and UDim2_fromOffset(16, 0) or UDim2_fromOffset(0, 0)})
            end
        end
        if rainbowButton then rainbowButton.MouseButton1Click:Connect(function() if not ColorPicker.Locked then ColorPicker:SetRainbow(not ColorPicker.Rainbow) end end) end
        if transBar then
            local drag
            local function UpdateTrans(input) ColorPicker:SetTransparency((input.Position.X - transBar.AbsolutePosition.X) / math_max(transBar.AbsoluteSize.X, 1)) end
            transBar.InputBegan:Connect(function(input)
                if ColorPicker.Locked or (input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch) then return end
                drag = input UpdateTrans(input)
            end)
            Library:AddConnection(UserInputService.InputChanged:Connect(function(input)
                if drag and (input == drag or (drag.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseMovement)) then UpdateTrans(input) end
            end))
            Library:AddConnection(UserInputService.InputEnded:Connect(function(input) if input == drag then drag = nil end end))
            ColorPicker:SetTransparency(ColorPicker.Transparency)
        end
        ColorPickerHolder.Destroying:Connect(function()
            ActiveRainbowPickers[ColorPicker] = nil
        end)

        function ColorPicker:SetColor(newColor: Color3)
            local h, s, v = newColor:ToHSV()
            ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = h, s, v
            ColorPicker:Update()
        end

        function ColorPicker:SetColorHSV(hsv)
            ColorPicker:SetColor(Color3_fromHSV(hsv[1], hsv[2], hsv[3]))
        end

        function ColorPicker:SetLocked(locked)
            ColorPicker.Locked = locked == true

            if ColorPicker.Locked and ColorPicker.Opened then
                ColorPicker:Toggle()
            end
        end

        function ColorPicker:Toggle()
            if ColorPicker.Locked and not ColorPicker.Opened then return end
            ColorPicker.Opened = not ColorPicker.Opened
            colorHeaderDivider.Visible = ColorPicker.Opened
            if activeTween then activeTween:Cancel() end
            ColorHolder.Visible = true
            controls.Visible = true
            if not ColorPicker.Opened then
                ColorPicker.DraggingColor = false
                ColorPicker.DraggingHue = false
            end
            local tween = TweenService:Create(ColorPickerHolder, ColorPicker.Opened and openTweenInfo or closeTweenInfo, {
                Size = ColorPicker.Opened and UDim2_new(1, 0, 0, OPEN_HEIGHT) or UDim2_new(1, 0, 0, CLOSED_HEIGHT)
            })
            activeTween = tween
            tween.Completed:Connect(function(state)
                if activeTween ~= tween then return end
                activeTween = nil
                if state == Enum.PlaybackState.Completed and not ColorPicker.Opened then
                    ColorHolder.Visible = false
                    controls.Visible = false
                end
            end)
            tween:Play()
        end

        function ColorPicker:Update()
            local oldColor = ColorPicker.Color
            ColorPicker.Color = Color3_fromHSV(ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib)
            ColorImage.BackgroundColor3 = Color3_fromHSV(ColorPicker.Hue, 1, 1)
            ColorIndicator.BackgroundColor3 = ColorPicker.Color
            for _, glow in ipairs(colorGlows) do glow.BackgroundColor3 = ColorPicker.Color end
            ColorImageIndicator.Position = UDim2_new(ColorPicker.Sat, 0, 1 - ColorPicker.Vib, 0)
            ColorHueIndicator.Position = UDim2_fromScale(0.5, ColorPicker.Hue)
            if not hexInput:IsFocused() then hexInput.Text = "#" .. ColorPicker.Color:ToHex():upper() end
            if ColorPicker.Color ~= oldColor then
                Library:SafeCallback(options.Callback, ColorPicker.Color, oldColor, ColorPicker.Transparency)
            end
        end

        if options.Flag then
            Library.Flags[options.Flag] = ColorPicker
        end

        OpenButton.TextColor3 = ThemeColor(220, 220, 220)

        OpenButton.MouseButton1Click:Connect(function() ColorPicker:Toggle() end)

        ColorImage.InputBegan:Connect(function(input)
            if not ColorPicker.Locked and not ColorPicker.Rainbow and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                ColorPicker.DraggingColor = true
                local minX = ColorImage.AbsolutePosition.X
                local maxX = minX + ColorImage.AbsoluteSize.X
                local mouseX = math_clamp(input.Position.X, minX, maxX)
                local minY = ColorImage.AbsolutePosition.Y
                local maxY = minY + ColorImage.AbsoluteSize.Y
                local mouseY = math_clamp(input.Position.Y, minY, maxY)
                ColorPicker.Sat = (mouseX - minX) / (maxX - minX)
                ColorPicker.Vib = 1 - (mouseY - minY) / (maxY - minY)
                ColorPicker:Update()
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then ColorPicker.DraggingColor = false end
                end)
            end
        end)

        ColorHue.InputBegan:Connect(function(input)
            if not ColorPicker.Locked and not ColorPicker.Rainbow and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                ColorPicker.DraggingHue = true
                local minY = ColorHue.AbsolutePosition.Y
                local maxY = minY + ColorHue.AbsoluteSize.Y
                local mouseY = math_clamp(input.Position.Y, minY, maxY)
                ColorPicker.Hue = (mouseY - minY) / (maxY - minY)
                ColorPicker:Update()
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then ColorPicker.DraggingHue = false end
                end)
            end
        end)

        Library:AddConnection(UserInputService.InputChanged:Connect(function(input)
            if ColorPicker.Rainbow then
                ColorPicker.DraggingColor = false
                ColorPicker.DraggingHue = false
                return
            end
            if not Library.Opened and not IsOpenOptionAncestor(ColorPickerHolder) then
                ColorPicker.DraggingColor = false
                ColorPicker.DraggingHue = false
                return
            end
            if ColorPicker.DraggingColor then
                local minX = ColorImage.AbsolutePosition.X
                local maxX = minX + ColorImage.AbsoluteSize.X
                local mouseX = math_clamp(input.Position.X, minX, maxX)
                local minY = ColorImage.AbsolutePosition.Y
                local maxY = minY + ColorImage.AbsoluteSize.Y
                local mouseY = math_clamp(input.Position.Y, minY, maxY)
                ColorPicker.Sat = (mouseX - minX) / (maxX - minX)
                ColorPicker.Vib = 1 - (mouseY - minY) / (maxY - minY)
                ColorPicker:Update()
            elseif ColorPicker.DraggingHue then
                local minY = ColorHue.AbsolutePosition.Y
                local maxY = minY + ColorHue.AbsoluteSize.Y
                local mouseY = math_clamp(input.Position.Y, minY, maxY)
                ColorPicker.Hue = (mouseY - minY) / (maxY - minY)
                ColorPicker:Update()
            end
        end))

        ColorPicker:SetColor(options.Color or Color3_new(1, 1, 1))
        ColorPicker:SetRainbow(options.Rainbow == true)
    RegisterControlForPalette(self, options, ColorPicker, "Color")
        return ColorPicker
    end

    BaseComponents.__index = Components
    BaseComponents.__namecall = function(Table, Key, ...)
        return Components[Key](...)
    end
end

local SnowLayer, SnowConnection
local Snowflakes = {}
local SnowEnabled = false
local function SetSnow(enabled)
    SnowEnabled = enabled == true
    if enabled and not SnowLayer then
        SnowLayer = Create("Frame", {
            Name = "ThemeSnow",
            BackgroundTransparency = 1,
            Size = UDim2_fromScale(1, 1),
            ClipsDescendants = true,
            Active = false,
            ZIndex = 30,
            Parent = UI,
        })
        SnowLayer:SetAttribute("ThemeColorIgnore", true)
        local rng = Random_new()
        task_spawn(function()
        for Index = 1, 42 do
            if Library.Unloaded or not SnowLayer or not SnowLayer.Parent then return end
            local size = rng:NextInteger(2, 5)
            local opacity = rng:NextNumber(0.18, 0.50)
            local dot = Create("Frame", {
                BackgroundColor3 = Color3_fromRGB(245, 250, 255),
                BackgroundTransparency = opacity,
                BorderSizePixel = 0,
                Size = UDim2_fromOffset(size, size),
                ZIndex = 30,
                Active = false,
                Parent = SnowLayer,
            })
            dot:SetAttribute("ThemeColorIgnore", true)
            Create("UICorner", {CornerRadius = UDim_new(1, 0), Parent = dot})
            local particle = {dot = dot, x = rng:NextNumber(), y = rng:NextNumber(), speed = rng:NextNumber(0.025, 0.065), drift = rng:NextNumber(0.005, 0.018), phase = rng:NextNumber(0, 6.28), sway = rng:NextNumber(0.6, 1.4), opacity = opacity}
            dot.Position = UDim2_fromScale(particle.x, particle.y)
            table_insert(Snowflakes, particle)
            if Index % 7 == 0 then task_wait() end
        end
        end)
        local time, AccumulatedSnow = 0, 0
        SnowConnection = RunService.Heartbeat:Connect(function(dt)
            if not SnowLayer or not SnowLayer.Parent then return end
            local show = SnowEnabled and (Library.Opened ~= false or Library._PaletteSnowActive == true)
            if SnowLayer.Visible ~= show then SnowLayer.Visible = show end
            local snowZ = Library._PaletteSnowActive and 106 or 30
            if SnowLayer.ZIndex ~= snowZ then SnowLayer.ZIndex = snowZ; for _, particle in ipairs(Snowflakes) do particle.dot.ZIndex = snowZ end end
            if not show then AccumulatedSnow = 0; return end
            AccumulatedSnow += dt
            if AccumulatedSnow < 1 / 30 then return end
            local Elapsed = AccumulatedSnow
            time += Elapsed
            AccumulatedSnow = 0
            for _, particle in ipairs(Snowflakes) do
                particle.y = (particle.y + Elapsed * particle.speed) % 1.04
                local sway = math_sin(time * particle.sway + particle.phase) * particle.drift
                particle.dot.Position = UDim2_fromScale(particle.x + sway, particle.y - 0.02)
                particle.dot.BackgroundTransparency = math_clamp(particle.opacity + math_sin(time * 1.1 + particle.phase) * 0.08, 0, 1)
            end
        end)
        Library:AddConnection(SnowConnection)
    end
    if SnowLayer then
        SnowLayer.Visible = enabled and Library.Opened ~= false
        local snowColor = Color3_fromRGB(245, 250, 255)
        for index, particle in ipairs(Snowflakes) do
            particle.dot.BackgroundColor3 = snowColor
        end
    end
end

local ThemeTweens = setmetatable({}, {__mode = "k"})
local ThemeTransitions = {}
local ThemeConnection
local function ThemeObjectVisible(object)
    local parent = object
    while parent and parent ~= UI do
        if parent:IsA("GuiObject") and not parent.Visible then return false end
        parent = parent.Parent
    end
    return parent == UI
end
animateThemeColor = function(object, property, color)
    local byProperty = ThemeTweens[object]
    if not byProperty then byProperty = {}; ThemeTweens[object] = byProperty end
    local previous = byProperty[property]
    if previous then previous.cancelled = true end
    local start = object[property]
    if start == color or not ThemeObjectVisible(object) then
        byProperty[property] = nil
        object[property] = color
        return
    end
    local entry = {object = object, property = property, from = start, target = color, start = os_clock()}
    byProperty[property] = entry
    table_insert(ThemeTransitions, entry)
    if not ThemeConnection then
        ThemeConnection = RunService.Heartbeat:Connect(function()
            if #ThemeTransitions == 0 then
                ThemeConnection:Disconnect()
                ThemeConnection = nil
                return
            end
            local now = os_clock()
            for i = #ThemeTransitions, 1, -1 do
                local transition = ThemeTransitions[i]
                local target = transition.object
                if transition.cancelled or not target.Parent then
                    table_remove(ThemeTransitions, i)
                else
                    local progress = math_clamp((now - transition.start) / .32, 0, 1)
                    local eased = 1 - (1 - progress) * (1 - progress)
                    target[transition.property] = transition.from:Lerp(transition.target, eased)
                    if progress >= 1 then
                        local properties = ThemeTweens[target]
                        if properties and properties[transition.property] == transition then properties[transition.property] = nil end
                        table_remove(ThemeTransitions, i)
                    end
                end
            end
            if #ThemeTransitions == 0 and ThemeConnection then
                ThemeConnection:Disconnect()
                ThemeConnection = nil
            end
        end)
    end
end

local function ThemeDescendants()
    local all, pending = {}, {UI}
    while #pending > 0 do
        local parent = table_remove(pending)
        for _, child in ipairs(parent:GetChildren()) do
            if child.Name ~= "PaletteViewCache" and child.Name ~= "ThemeSnow" then
                table_insert(all, child)
                table_insert(pending, child)
            end
        end
    end
    return all
end

function Library:SetTheme(name)
    name = ResolveThemeName(name)
    if not name or name == ThemeName then return end
    local previous = ThemeName
    ThemeName = name
    local reverse = {}
    for _, shade in ipairs(ThemeNeutralValues) do
        reverse[PaletteColor(previous, shade, shade, shade):ToHex()] = {shade, shade, shade}
    end
    reverse[PaletteColor(previous, 60, 200, 100):ToHex()] = {60, 200, 100}
    local function Recolor(object, property)
        local ok, color = pcall(function() return object[property] end)
        if not ok or typeof(color) ~= "Color3" then return end
        local ongoing = ThemeTweens[object] and ThemeTweens[object][property]
        local original = reverse[(ongoing and ongoing.target or color):ToHex()]
        if original then animateThemeColor(object, property, PaletteColor(name, table_unpack(original))) end
    end
    for _, object in ipairs(ThemeDescendants()) do
        if not object:GetAttribute("ThemeColorIgnore") then
            if object:IsA("GuiObject") then
                local InputShade = object:GetAttribute("ThemeInputSurface")
                if InputShade then
                    animateThemeColor(object, "BackgroundColor3", ThemeColor(InputShade, InputShade, InputShade))
                elseif object:GetAttribute("ThemeAccentButton") then
                    animateThemeColor(object, "BackgroundColor3", ThemeColor(25, 25, 25):Lerp(ThemeColor(60, 200, 100), 0.09))
                else
                    Recolor(object, "BackgroundColor3")
                end
            end
            if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
                Recolor(object, "TextColor3")
                local alpha = object.TextTransparency
                if IsLightTheme(previous) and alpha > 0 and alpha < 1 then alpha = math_clamp(alpha / 0.48, 0, 1) end
                if IsLightTheme(name) and alpha > 0 and alpha < 1 then alpha *= 0.48 end
                object.TextTransparency = alpha
            end
            if object:IsA("TextBox") then Recolor(object, "PlaceholderColor3") end
            if (object:IsA("ImageLabel") or object:IsA("ImageButton")) and object:GetAttribute("ThemeIcon") then
                if IsLightTheme(name) then
                    if not IsLightTheme(previous) then
                        object:SetAttribute("ThemeIconOriginalColor", object.ImageColor3)
                        object:SetAttribute("ThemeIconOriginalTransparency", object.ImageTransparency)
                    end
                    if object:GetAttribute("MainTitleIcon") then
                        animateThemeColor(object, "ImageColor3", Color3_fromRGB(15, 17, 20))
                        object.ImageTransparency = math_min(object.ImageTransparency, 0.12)
                    else
                        animateThemeColor(object, "ImageColor3", Color3_fromRGB(50, 55, 60))
                    end
                elseif IsLightTheme(previous) then
                    animateThemeColor(object, "ImageColor3", object:GetAttribute("ThemeIconOriginalColor") or Color3_new(1, 1, 1))
                    local originalAlpha = object:GetAttribute("ThemeIconOriginalTransparency")
                    if originalAlpha ~= nil then object.ImageTransparency = originalAlpha end
                end
            end
            if object:GetAttribute("ThemeAccentIcon") and (object:IsA("ImageLabel") or object:IsA("ImageButton")) then
                animateThemeColor(object, "ImageColor3", ThemeColor(60, 200, 100))
            end
            if object:IsA("ScrollingFrame") then Recolor(object, "ScrollBarImageColor3") end
            if object:IsA("UIStroke") then Recolor(object, "Color") end
        end
    end
    DefaultToggleColor = ThemeColor(60, 60, 60)
    HoveringToggleColor = ThemeColor(100, 100, 100)
    EnabledToggleColor = ThemeColor(60, 200, 100)
    for _, refresh in ipairs(self.ThemeToggleRefreshers or {}) do refresh() end
    self.Theme = name
    self._PaletteDirty = true
    local paletteOverlay = UI:FindFirstChild("CommandPaletteOverlay")
    if paletteOverlay and paletteOverlay.Visible and self.RefreshCommandPalette then self:RefreshCommandPalette() end
    for _, tab in ipairs(self.TabAnimations or {}) do
        if tab.RefreshTheme then tab:RefreshTheme() end
    end
    if self.MobileRouterIcon and self.MobileRouterIcon.Parent then
        self.MobileRouterIcon.ImageColor3 = ThemeColor(60, 200, 100)
    end
    SetSnow(Library.SnowEnabled ~= false)
end

function Library:SafeCallback(Func, ...)
    if not Func then return end
    if not Library.Debug then return Func(...) end
    local Result = table_pack(xpcall(Func, function(Error)
        warn("[Library]: | " .. debug.traceback(tostring(Error), 2))
        return Error
    end, ...))
    if not Result[1] then return nil end
    return table_unpack(Result, 2, Result.n)
end

local BorderGradients = {}
AddAnimatedBorder = function(Parent)
    local Stroke = Create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = ThemeColor(60, 200, 100), Thickness = 1, Parent = Parent})
    local Gradient = Create("UIGradient", {
        Transparency = NumberSequence_new({
            NumberSequenceKeypoint_new(0, 0.58),
            NumberSequenceKeypoint_new(0.23, 0.56),
            NumberSequenceKeypoint_new(0.32, 0.49),
            NumberSequenceKeypoint_new(0.40, 0.24),
            NumberSequenceKeypoint_new(0.46, 0.02),
            NumberSequenceKeypoint_new(0.50, 0.00),
            NumberSequenceKeypoint_new(0.54, 0.02),
            NumberSequenceKeypoint_new(0.60, 0.24),
            NumberSequenceKeypoint_new(0.68, 0.49),
            NumberSequenceKeypoint_new(0.77, 0.56),
            NumberSequenceKeypoint_new(1, 0.58),
        }),
        Parent = Stroke,
    })
    Stroke.Transparency = Parent.GroupTransparency
    Library:AddConnection(Parent:GetPropertyChangedSignal("GroupTransparency"):Connect(function()
        Stroke.Transparency = Parent.GroupTransparency
    end))
    table_insert(BorderGradients, Gradient)
end
local BorderUpdateTime = 0
Library:AddConnection(RunService.Heartbeat:Connect(function()
    if #BorderGradients == 0 then return end
    local Now = os_clock()
    if Now - BorderUpdateTime < 1 / 30 then return end
    BorderUpdateTime = Now
    local Rotation = (Now * 32) % 360
    for i = #BorderGradients, 1, -1 do
        local Gradient = BorderGradients[i]
        local Stroke = Gradient.Parent
        if Stroke and Stroke.Parent then
            if Stroke.Parent.Visible and Gradient.Rotation ~= Rotation then Gradient.Rotation = Rotation end
        else
            table_remove(BorderGradients, i)
        end
    end
end))

do
    local scale = Create("UIScale", {Name = "DPIScale", Parent = Windows})
    local cameraConnection
    Library.MobileScale = scale
    Library.DPIPercent = 100
    local function UpdateScale()
        local fit = 1
        local camera = workspace.CurrentCamera
        if Library.Mobile and camera then
            local vp = camera.ViewportSize
            if vp.X > 0 and vp.Y > 0 then
                fit = math_min(1, math_max(1,vp.X-24)/(Library.UISize*2+6), math_max(1,vp.Y-24)/260)
            end
        end
        scale.Scale = fit * Library.DPIPercent / 100
    end
    function Library:SetDPIScale(percent)
        percent = tonumber(percent)
        if not percent or percent ~= percent or percent == math_huge or percent == -math_huge then return false end
        self.DPIPercent = math_clamp(math_floor(percent + 0.5),50,150)
        UpdateScale()
        if self.DPISlider and self.DPISlider.Value ~= self.DPIPercent then self.DPISlider:Set(self.DPIPercent,true) end
        return true
    end
    local function BindCamera()
        if cameraConnection then cameraConnection:Disconnect() end
        local camera = workspace.CurrentCamera
        if camera then cameraConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateScale); Library:AddConnection(cameraConnection) end
        UpdateScale()
    end
    Library:AddConnection(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(BindCamera))
    BindCamera()
end

AttachDPIScale = function(target)
    local scale = Create("UIScale", {Name = "DPIScale", Scale = Library.MobileScale.Scale, Parent = target})
    local connection = Library.MobileScale:GetPropertyChangedSignal("Scale"):Connect(function()
        if scale.Parent then scale.Scale = Library.MobileScale.Scale end
    end)
    target.Destroying:Connect(function() connection:Disconnect() end)
    return scale
end

local function GetStorageFolder()
    if Library.SaveFolder == nil then return nil end
    local root = string_match(Library.SaveFolder, "^([^/]+)")
    if not root or root == "" then return nil end
    return root .. "/Storage"
end

local function EnsureSaveFolder()
    if Library.SaveFolder == nil then return false end
    if not is_folder(Library.SaveFolder) then make_folder(Library.SaveFolder) end

    local storage = GetStorageFolder()
    if storage and not is_folder(storage) then
        make_folder(storage)
    end

    return true
end

local function GetPositionFile()
    local storage = GetStorageFolder()
    if not storage then return nil end
    return storage .. "/Interface.json"
end

local function GetToggleStateFile()
    local storage = GetStorageFolder()
    if not storage then return nil end
    return storage .. "/Flag.json"
end

local function GetKeybindFile()
    local storage = GetStorageFolder()
    if not storage then return nil end
    return storage .. "/Keybind.json"
end

local function GetThemeFile()
    local storage = GetStorageFolder()
    if not storage then return nil end
    return storage .. "/Theme.json"
end

local function SaveTheme(name)
    if not ThemeDefinitions[name] then return false end
    local ok = pcall(function()
        if not EnsureSaveFolder() then return end
        local path = GetThemeFile()
        if path then write_file(path, HttpService:JSONEncode({ Theme = name })) end
    end)
    return ok
end

local function LoadTheme()
    local path = GetThemeFile()
    if not path then return nil end
    local ok, data = pcall(function()
        if not is_file(path) then return nil end
        return HttpService:JSONDecode(read_file(path))
    end)
    if not ok or type(data) ~= "table" or type(data.Theme) ~= "string" then return nil end
    return ResolveThemeName(data.Theme)
end

local function SavePositions()
    if not EnsureSaveFolder() then return false end
    local path = GetPositionFile()
    if not path then return false end

    local data = {}

    if Library.MainWindow then
        data.MainWindow = {
            XScale = Library.MainWindow.Position.X.Scale,
            XOffset = Library.MainWindow.Position.X.Offset,
            YScale = Library.MainWindow.Position.Y.Scale,
            YOffset = Library.MainWindow.Position.Y.Offset
        }
    end

    data.Tabs = {}
    if Library.TabHolders then
        for index, holder in ipairs(Library.TabHolders) do
            if holder and holder.Parent then
                data.Tabs[index] = {
                    XScale = holder.Position.X.Scale,
                    XOffset = holder.Position.X.Offset,
                    YScale = holder.Position.Y.Scale,
                    YOffset = holder.Position.Y.Offset
                }
            end
        end
    end

    write_file(path, tostring(HttpService:JSONEncode(data)))
    return true
end

local function LoadPositions()
    local path = GetPositionFile()
    if not path or not is_file(path) then return false end

    local ok, data = pcall(function()
        return HttpService:JSONDecode(read_file(path))
    end)
    if not ok or type(data) ~= "table" then return false end

    if data.MainWindow and Library.MainWindow then
        local m = data.MainWindow
        Library.MainWindow.Position = UDim2_new(m.XScale, m.XOffset, m.YScale, m.YOffset)
    end

    if data.Tabs and Library.TabHolders then
        for index, pos in pairs(data.Tabs) do
            local holder = Library.TabHolders[tonumber(index) or index]
            if holder and holder.Parent then
                holder.Position = UDim2_new(pos.XScale, pos.XOffset, pos.YScale, pos.YOffset)
            end
        end
    end

    return true
end

local function HasSavedPositions()
    local path = GetPositionFile()
    return path ~= nil and is_file(path)
end

local function ApplyDefaultPositions()
    if not Library.DefaultPositions then return end

    if Library.DefaultPositions.MainWindow and Library.MainWindow then
        local m = Library.DefaultPositions.MainWindow
        Library.MainWindow.Position = UDim2_new(m.XScale, m.XOffset, m.YScale, m.YOffset)
    end

    if Library.DefaultPositions.Tabs and Library.TabHolders then
        for index, pos in pairs(Library.DefaultPositions.Tabs) do
            local holder = Library.TabHolders[tonumber(index) or index]
            if holder and holder.Parent then
                holder.Position = UDim2_new(pos.XScale, pos.XOffset, pos.YScale, pos.YOffset)
            end
        end
    end
end

local function ResetPositions()
    local path = GetPositionFile()
    if path and is_file(path) then
        delete_file(path)
    end
    ApplyDefaultPositions()
end

local function SaveToggleState(state)
    if not EnsureSaveFolder() then return end
    local path = GetToggleStateFile()
    if not path then return end

    write_file(path, tostring(HttpService:JSONEncode({
        Enabled = state and true or false
    })))
end

local function LoadToggleState()
    local path = GetToggleStateFile()
    if not path or not is_file(path) then return false end

    local ok, data = pcall(function()
        return HttpService:JSONDecode(read_file(path))
    end)
    if not ok or type(data) ~= "table" then return false end

    return data.Enabled == true
end

local function ResetToggleStateFile()
    local path = GetToggleStateFile()
    if path and is_file(path) then
        delete_file(path)
    end
end

local function SaveKeybind(keybind)
    if not EnsureSaveFolder() then return end
    local path = GetKeybindFile()
    if not path then return end
    write_file(path, tostring(HttpService:JSONEncode({
        Keybind = keybind and tostring(keybind) or "None"
    })))
end

local function LoadKeybind()
    local path = GetKeybindFile()
    if not path or not is_file(path) then return nil end

    local ok, data = pcall(function()
        return HttpService:JSONDecode(read_file(path))
    end)
    if not ok or type(data) ~= "table" or not data.Keybind then return nil end

    if data.Keybind == "None" then return false end
    return GetKeybindFromString(data.Keybind)
end

function Library:CreateWindow(options: WindowOptions)
    self:SetShowLibrarysFeatures(options.ShowLibrarysFeatures ~= false)
    Library.SnowEnabled = options.Snow ~= false
    SetSnow(Library.SnowEnabled)
    Library.SaveFolder = options.SaveFolder or "Library"
    local dpiFile = GetStorageFolder() and (GetStorageFolder() .. "/DPI.json")
    local loadedDPI
    if dpiFile and type(is_file) == "function" and type(read_file) == "function" then
        local ok, data = pcall(function() if is_file(dpiFile) then return HttpService:JSONDecode(read_file(dpiFile)) end end)
        if ok and type(data) == "table" then loadedDPI = tonumber(data.Percent) end
    end
    self:SetDPIScale(loadedDPI or options.DPI or 100)
    Library.ToggleKeybind = options.ToggleKeybind or Enum.KeyCode.RightShift
    local defaultTheme = ResolveThemeName(options.Theme) or "Default"
    local storedTheme = LoadTheme()
    Library.InitialTheme = storedTheme or defaultTheme
    Library:SetTheme(Library.InitialTheme)
    if not storedTheme then SaveTheme(Library.InitialTheme) end

    if options.Blur ~= false then
        Library.Blur = Create("BlurEffect", { Size = 12, Enabled = false, Parent = Lighting })
    end

    local MainWindow = Create("CanvasGroup", {
        GroupTransparency = 0,
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = ThemeColor(25, 25, 25),
        Size = UDim2_fromOffset(Library.UISize, 0),
        Parent = Windows
    })

    table_insert(Library.Tabs, MainWindow)
    Library.MainWindow = MainWindow
    Library.TabHolders = {}
    Library.TabAnimations = {}
    Library.DefaultPositions = { MainWindow = { XScale = MainWindow.Position.X.Scale, XOffset = MainWindow.Position.X.Offset, YScale = MainWindow.Position.Y.Scale, YOffset = MainWindow.Position.Y.Offset }, Tabs = {} }

    Create("UICorner", { CornerRadius = UDim_new(0, 10), Parent = MainWindow })

    AddAnimatedBorder(MainWindow)
    Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = MainWindow })

    local Top = Create("Frame", {
        BackgroundColor3 = ThemeColor(20, 20, 20),
        Size = UDim2_new(1, 0, 0, 40),
        Parent = MainWindow
    })

    Create("UICorner", { CornerRadius = UDim_new(0, 10), Parent = Top })
    Create("Frame", {
        AnchorPoint = Vector2_new(0.5, 1),
        BackgroundColor3 = ThemeColor(20, 20, 20),
        Position = UDim2_fromScale(0.5, 1),
        Size = UDim2_fromScale(1, 0.25),
        Parent = Top
    })

    local TitleIconDef = options.Icon and Library:GetIcon(options.Icon)
    if TitleIconDef then
        local TitleIcon = Create("ImageLabel", {
            BackgroundTransparency = 1,
            Image = "",
            ImageColor3 = ThemeColor(60, 200, 100),
            Position = UDim2_fromOffset(9, 5),
            Size = UDim2_fromOffset(30, 30),
            ZIndex = 2,
            Parent = Top
        })
        TitleIcon:SetAttribute("MainTitleIcon", true)
        TitleIcon:SetAttribute("ThemeColorIgnore", true)
        Library:ApplyIcon(TitleIcon, TitleIconDef)
        TitleIcon.ImageColor3 = Color3_new(1, 1, 1)
    end

    local Title = Create("TextLabel", {
        BackgroundTransparency = 1,
        FontFace = SemiBoldFont,
        Position = UDim2_fromOffset(TitleIconDef and 36 or 0, 0),
        Size = UDim2_new(1, TitleIconDef and -32 or 0, 1, 0),
        Text = options.Title or "No Title",
        TextColor3 = ThemeColor(255, 255, 255),
        TextScaled = false, TextSize = 15,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Left,
        RichText = true,
        Parent = Top
    })
    Create("UIPadding", {
        PaddingBottom = UDim_new(0, 6),
        PaddingLeft = UDim_new(0, 12),
        PaddingRight = UDim_new(0, 12),
        PaddingTop = UDim_new(0, 6),
        Parent = Title
    })

    Create("Frame", { BackgroundColor3 = ThemeColor(60, 60, 60), Size = UDim2_new(1, 0, 0, 1), Parent = MainWindow })

    local TabButtons = Create("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2_fromScale(1, 0),
        Parent = MainWindow
    })
    Create("UIPadding", {PaddingLeft = UDim_new(0, 7), PaddingRight = UDim_new(0, 7), PaddingTop = UDim_new(0, 4), Parent = TabButtons})
    Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim_new(0, 3), Parent = TabButtons })

    Create("Frame", {BackgroundTransparency = 1, LayoutOrder = 999, Size = UDim2_new(1, 0, 0, 6), Parent = MainWindow})

    task_defer(Library.Toggle)

    local Window = { CommandCategory = "Commands" }
    Library.Window = Window
    function Window:NewSection(name)
        self.CommandCategory = tostring(name or "Commands")
        return self
    end
    function Window:AddCommand(info, ...)
        if type(info) == "table" then
            info = table_clone(info)
            info.Category = info.Category or info.Section or self.CommandCategory
        end
        local command = Library:AddCommand(info, ...)
        if command and type(info) == "string" then command.Category = self.CommandCategory end
        if Library.RefreshCommandPalette then Library:RefreshCommandPalette() end
        return command
    end
    local MobileTabs = {}

    function Window:AddTab(tabName, IconName, Collapsed)
        local TabHolder: CanvasGroup = Create("CanvasGroup", {
            GroupTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = ThemeColor(25, 25, 25),
            Position = UDim2_fromOffset((Library.UISize + 6) * (Library.Mobile and 1 or #Library.Tabs), 0),
            Size = UDim2_fromOffset(Library.UISize, 0),
            Visible = false,
            Parent = Windows,
        })

        table_insert(Library.Tabs, TabHolder)

        if Library.TabHolders then
            table_insert(Library.TabHolders, TabHolder)
            local p = TabHolder.Position
            Library.DefaultPositions.Tabs[#Library.TabHolders] = { XScale = p.X.Scale, XOffset = p.X.Offset, YScale = p.Y.Scale, YOffset = p.Y.Offset }
        end

        Create("UICorner", { CornerRadius = UDim_new(0, 10), Parent = TabHolder })
    Create("UIGradient", {Color = ColorSequence_new(Color3_fromRGB(255, 255, 255), Color3_fromRGB(210, 210, 210)), Rotation = 90, Parent = TabHolder})
        AddAnimatedBorder(TabHolder)
        Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = TabHolder })

        local Top2 = Create("TextButton", {
            AutoButtonColor = false,
            BackgroundColor3 = ThemeColor(20, 20, 20),
            Size = UDim2_new(1, 0, 0, 40),
            Text = "",
            Parent = TabHolder
        })

        Create("UICorner", { CornerRadius = UDim_new(0, 10), Parent = Top2 })
        Create("Frame", {
            AnchorPoint = Vector2_new(0.5, 1),
            BackgroundColor3 = ThemeColor(20, 20, 20),
            Position = UDim2_fromScale(0.5, 1),
            Size = UDim2_fromScale(1, 0.25),
            Parent = Top2
        })

        local DragDots = Create("Frame", {BackgroundTransparency = 1, AnchorPoint = Vector2_new(1, 0.5), Position = UDim2_new(1, -10, 0.5, 0), Size = UDim2_fromOffset(9, 16), Parent = Top2})
        for row = 0, 2 do
            for column = 0, 1 do
                local Dot = Create("Frame", {BackgroundColor3 = ThemeColor(200, 200, 200), BackgroundTransparency = 0.18, Position = UDim2_fromOffset(column * 5, row * 5 + 1), Size = UDim2_fromOffset(2, 2), Parent = DragDots})
                Create("UICorner", {CornerRadius = UDim_new(1, 0), Parent = Dot})
            end
        end

        local HeaderIconDef = IconName and Library:GetIcon(IconName)
        if HeaderIconDef then
            local HeaderIcon = Create("ImageLabel", {
                BackgroundTransparency = 1, Image = "", ImageTransparency = 0.3,
                Position = UDim2_fromOffset(12, 10), Size = UDim2_fromOffset(20, 20), ZIndex = 2, Parent = Top2
            })
            Library:ApplyIcon(HeaderIcon, HeaderIconDef)
        end

        local Title2 = Create("TextLabel", {
            BackgroundTransparency = 1, FontFace = MediumFont,
            Position = UDim2_fromOffset(HeaderIconDef and 28 or 0, 0),
            Size = UDim2_new(1, HeaderIconDef and -60 or 0, 1, 0),
            Text = tabName or "No Name", TextColor3 = ThemeColor(255, 255, 255),
            TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left, Parent = Top2
        })
        Create("UIPadding", {
            PaddingBottom = UDim_new(0, 6), PaddingLeft = UDim_new(0, 12),
            PaddingRight = UDim_new(0, 12), PaddingTop = UDim_new(0, 6), Parent = Title2
        })

        Create("Frame", {BackgroundColor3 = ThemeColor(80, 80, 80), BackgroundTransparency = 0.25, Size = UDim2_new(1, 0, 0, 1), Parent = TabHolder})
        local Elements = Create("ScrollingFrame", {
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
            CanvasSize = UDim2_fromScale(0, 0),
            ScrollBarImageColor3 = ThemeColor(95, 95, 95),
            ScrollBarThickness = 4,
            Size = UDim2_fromScale(1, 0),
            TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
            Parent = TabHolder
        })

        local ElementsListLayout = Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            Padding = UDim_new(0, 5),
            Parent = Elements,
        })

        Create("Frame", {Name = "DragFooter", BackgroundTransparency = 1, LayoutOrder = 999, Size = UDim2_new(1, 0, 0, 2), Parent = TabHolder})
        local tabGrip = CreateDragGrip(UI, TabHolder)
        MakeDraggable(tabGrip, TabHolder)

        Create("Frame", {BackgroundTransparency = 1, LayoutOrder = -1000, Size = UDim2_new(1, 0, 0, 2), Parent = Elements})
        Create("Frame", {Name = "CanvasBottomSpacer", BackgroundTransparency = 1, LayoutOrder = 2147483647, Size = UDim2_new(1, 0, 0, 1), Parent = Elements})

        local TabButton: TextButton = Create("TextButton", {
            AutoButtonColor = false,
            BackgroundColor3 = ThemeColor(25, 25, 25),
            LayoutOrder = (#Library.TabHolders * 2) - 2,
            Size = UDim2_new(1, 0, 0, 36),
            Text = "",
            Parent = TabButtons
        })

        Create("UICorner", { CornerRadius = UDim_new(0, 7), Parent = TabButton })
        local NavStroke = Create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = ThemeColor(60, 200, 100), Transparency = 1, Thickness = 1, Parent = TabButton})

        local SelectedIndicator = Create("Frame", {
            Name = "SelectedIndicator", BorderSizePixel = 0,
            BackgroundColor3 = ThemeColor(60, 200, 100),
            Position = UDim2_fromOffset(0, 2), Size = UDim2_new(0, 4, 1, -4),
            Visible = false, ZIndex = 2, Parent = TabButton,
        })
        Create("UICorner", { CornerRadius = UDim_new(1, 0), Parent = SelectedIndicator })

        local TabButtonText = Create("TextLabel", {
            TextYAlignment = Enum.TextYAlignment.Center,
            BackgroundTransparency = 1, FontFace = MediumFont,
            Position = UDim2_fromOffset(HeaderIconDef and 18 or 0, 0),
            Size = UDim2_new(1, HeaderIconDef and -24 or 0, 1, 0),
            Text = tabName or "No Name", TextColor3 = ThemeColor(255, 255, 255),
            TextScaled = false, TextSize = 16, TextTransparency = ThemeTextAlpha(0.5),
            TextXAlignment = Enum.TextXAlignment.Left, Parent = TabButton
        })

        local TabButtonIcon
        if HeaderIconDef then
            TabButtonIcon = Create("ImageLabel", {
                BackgroundTransparency = 1, Image = "", ImageTransparency = 0.18,
                Position = UDim2_fromOffset(4, 8), Size = UDim2_fromOffset(20, 20), ZIndex = 2, Parent = TabButton
            })
            Library:ApplyIcon(TabButtonIcon, HeaderIconDef)
        end

        Create("UIPadding", {
            PaddingBottom = UDim_new(0, 8), PaddingLeft = UDim_new(0, 11),
            PaddingRight = UDim_new(0, 11), PaddingTop = UDim_new(0, 8), Parent = TabButtonText
        })

        local Tab = { Hovering = false, Opened = false, Locked = false, _LastWasSection = false }
        local tabLock = Create("TextButton", {Name = "TabLock", BackgroundTransparency = 0.75, BackgroundColor3 = Color3_new(0,0,0), Size = UDim2_fromScale(1,1), Text = "", AutoButtonColor = false, Visible = false, ZIndex = 50, Parent = TabHolder})
        function Tab:SetLocked(locked)
            self.Locked = locked == true
            tabLock.Visible = self.Locked
            Library._PaletteLocks[tostring(tabName or "Main")] = self.Locked or nil
        end
        local panelTween
        local panelTweenId = 0

        function Tab:RefreshTheme()
            animateThemeColor(TabButton, "BackgroundColor3", Tab.Opened and ThemeColor(25, 25, 25):Lerp(ThemeColor(60, 200, 100), 0.13) or ThemeColor(25, 25, 25))
        end

        function Tab:AnimatePanel(show)
            panelTweenId += 1
            local animationId = panelTweenId
            if panelTween then panelTween:Cancel() end
            if show then TabHolder.Visible = true end
            if not TabHolder.Visible then return end
            local tween = TweenService:Create(TabHolder, TweenInfo_new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {GroupTransparency = show and 0 or 1})
            panelTween = tween
            tween.Completed:Connect(function(state)
                if animationId ~= panelTweenId or state ~= Enum.PlaybackState.Completed then return end
                panelTween = nil
                if not Tab.Opened then TabHolder.Visible = false end
            end)
            tween:Play()
        end
        table_insert(Library.TabAnimations, Tab)

        function Tab:Toggle()
            if self.Locked then return end
            if Library.Mobile and not Tab.Opened then
                for _, otherTab in MobileTabs do
                    if otherTab ~= Tab and otherTab.Opened then otherTab:Toggle() end
                end
            end
            Tab.Opened = not Tab.Opened
            TabHolder:SetAttribute("TabOpened", Tab.Opened)
            SelectedIndicator.Visible = Tab.Opened
            Tween(NavStroke, FastTween, {Transparency = Tab.Opened and 0.72 or 1})
            if TabButtonIcon then Tween(TabButtonIcon, FastTween, {Position = UDim2_fromOffset(Tab.Opened and 7 or 4, 8)}) end
            Tab:AnimatePanel(Tab.Opened and Library.Opened ~= false)
            Tween(TabButton, TweenInfo_new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Tab.Opened and ThemeColor(25, 25, 25):Lerp(ThemeColor(60, 200, 100), 0.13) or (Tab.Hovering and ThemeColor(30, 30, 30) or ThemeColor(25, 25, 25))})
            Tween(TabButtonText, TweenInfo_new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2_fromOffset((HeaderIconDef and 18 or 0) + (Tab.Opened and 3 or 0), 0), TextTransparency = ThemeTextAlpha(Tab.Opened and 0 or (Tab.Hovering and 0.25 or 0.5))})
        end

        if Library.Mobile then table_insert(MobileTabs, Tab) end

        function Tab:AddElementSection(name, Collapsed, IconName, Minimizable)
            local Options = type(name) == "table" and name or nil
            local SectionName = Options and (Options.Name or Options.Title) or name
            local CanMinimize = Options and Options.Collapsible ~= false or (not Options and Minimizable ~= false)
            local InitiallyOpen = Options and Options.DefaultOpen ~= false or (not Options and Collapsed ~= false)
            if not CanMinimize then InitiallyOpen = true end
            local DisplayName = tostring(SectionName or "Section"):gsub("^%s*•%s*", "")
            local SuggestedIcons = {
                combat = "swords", farming = "sprout", movement = "person-standing",
                visuals = "eye", ["ui manager"] = "settings", ["config manager"] = "folder",
                ["boss farm"] = "skull", ["stand farm"] = "layers",
            }
            local SectionIconName = (Options and Options.Icon) or IconName or SuggestedIcons[DisplayName:lower()]
            Tab._LastWasSection = true

            local ElementHolder = Create("Frame", {
                BackgroundColor3 = ThemeColor(25, 25, 25),
                Size = UDim2_new(1, -12, 0, 36),
                ClipsDescendants = true,
                Parent = Elements,
            })
            Create("UICorner", {CornerRadius = UDim_new(0, 11), Parent = ElementHolder})
            local BorderOverlay = Create("Frame", {Name = "SectionBorder", BackgroundTransparency = 1, Position = UDim2_fromOffset(1, 1), Size = UDim2_new(1, -2, 1, -2), ZIndex = 4, Parent = ElementHolder})
            Create("UICorner", {CornerRadius = UDim_new(0, 10), Parent = BorderOverlay})
            Create("UIStroke", {Color = ThemeColor(80, 80, 80), Transparency = 0.18, Thickness = 1, Parent = BorderOverlay})
            local ButtonFrame = Create("TextButton", {
                AutoButtonColor = false, BackgroundColor3 = ThemeColor(45, 45, 45),
                Size = UDim2_new(1, 0, 0, 36), Text = "", Parent = ElementHolder,
            })
            Create("UICorner", {CornerRadius = UDim_new(0, 11), Parent = ButtonFrame})
            Create("UIGradient", {Color = ColorSequence_new(Color3_fromRGB(255, 255, 255), Color3_fromRGB(220, 220, 220)), Rotation = 90, Parent = ButtonFrame})
            
            local HeaderBottom = Create("Frame", {
                BackgroundColor3 = ThemeColor(45, 45, 45), BorderSizePixel = 0,
                AnchorPoint = Vector2_new(0, 1), Position = UDim2_fromScale(0, 1),
                Size = UDim2_new(1, 0, 0, 10), Visible = false, Parent = ButtonFrame,
            })
            Create("UIGradient", {Color = ColorSequence_new(Color3_fromRGB(230, 230, 230), Color3_fromRGB(220, 220, 220)), Rotation = 90, Parent = HeaderBottom})

            local HeaderDivider = Create("Frame", {BackgroundColor3 = ThemeColor(80, 80, 80), BackgroundTransparency = 0.28, BorderSizePixel = 0, AnchorPoint = Vector2_new(0, 1), Position = UDim2_fromScale(0, 1), Size = UDim2_new(1, 0, 0, 1), Visible = false, ZIndex = 2, Parent = ButtonFrame})

            local SectionIcon
            local IconDef = SectionIconName and Library:GetIcon(SectionIconName)
            if IconDef then
                SectionIcon = Create("ImageLabel", {BackgroundTransparency = 1, Image = "",
                    ImageColor3 = ThemeColor(220, 220, 220), ImageTransparency = 0.2,
                    Position = UDim2_fromOffset(10, 9), Size = UDim2_fromOffset(18, 18), Parent = ButtonFrame})
                Library:ApplyIcon(SectionIcon, IconDef)
            end
            Create("TextLabel", {
                BackgroundTransparency = 1, FontFace = MediumFont,
                Position = UDim2_fromOffset(IconDef and 36 or 11, 0),
                Size = UDim2_new(1, -(IconDef and 72 or 47), 1, 0),
                Text = DisplayName, TextColor3 = ThemeColor(220, 220, 220),
                TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd, Parent = ButtonFrame,
            })
            local Chevron = Create("ImageLabel", {
                AnchorPoint = Vector2_new(1, 0.5), BackgroundTransparency = 1, Image = "",
                ImageColor3 = ThemeColor(255, 255, 255), ImageTransparency = 0.1,
                Position = UDim2_new(1, -10, 0.5, 0), Size = UDim2_fromOffset(18, 18),
                Visible = CanMinimize, Parent = ButtonFrame,
            })
            Library:ApplyIcon(Chevron, Library:GetIcon("chevron-down"))
            local lastChevronRotation
            local Components = Create("Frame", {
                AnchorPoint = Vector2_new(0.5, 1), BackgroundTransparency = 1,
                Position = UDim2_fromScale(0.5, 1), Size = UDim2_new(1, 0, 1, -36), Parent = ElementHolder,
            })
            local ComponentsListLayout = Create("UIListLayout", {
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                SortOrder = Enum.SortOrder.LayoutOrder, Parent = Components,
            })
            local ElementSection = {Container = Components, Opened = false, Collapsible = CanMinimize, _PaletteCategory = tostring(tabName or "Main") .. " / " .. DisplayName}
            local sectionLock = Create("TextButton", {Name = "SectionLock", BackgroundTransparency = 0.75, BackgroundColor3 = Color3_new(0,0,0), Size = UDim2_fromScale(1,1), Text = "", AutoButtonColor = false, Visible = false, ZIndex = 50, Parent = ElementHolder})
            function ElementSection:SetLocked(locked) self.Locked = locked == true; sectionLock.Visible = self.Locked; Library._PaletteLocks[self._PaletteCategory] = self.Locked or nil end
            local function UpdateSectionHeight()
                local Scale = Library.MobileScale and Library.MobileScale.Scale or 1
                HeaderBottom.Visible = ElementSection.Opened
                HeaderDivider.Visible = ElementSection.Opened
                local Height = ElementSection.Opened and ComponentsListLayout.AbsoluteContentSize.Y / Scale + 36 or 36
                Tween(ElementHolder, TweenInfo_new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    Size = UDim2_new(1, -12, 0, Height),
                })
                local rotation = ElementSection.Opened and 180 or 0
                if lastChevronRotation == nil then Chevron.Rotation = rotation
                elseif lastChevronRotation ~= rotation then Tween(Chevron, TweenInfo_new(.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Rotation = rotation}) end
                lastChevronRotation = rotation
            end
            function ElementSection:SetOpen(Open)
                if self.Locked then return end
                if not self.Collapsible and not Open then return end
                self.Opened = Open == true
                UpdateSectionHeight()
            end
            function ElementSection:Toggle()
                if self.Collapsible then self:SetOpen(not self.Opened) end
            end
            function ElementSection:SetCollapsible(Enabled)
                self.Collapsible = Enabled == true
                Chevron.Visible = self.Collapsible
                if not self.Collapsible then self.Opened = true end
                UpdateSectionHeight()
            end
            local SectionSizeQueued = false
            Library:AddConnection(ComponentsListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if SectionSizeQueued then return end
                SectionSizeQueued = true
                task_defer(function()
                    SectionSizeQueued = false
                    if not Library.Unloaded and ElementHolder.Parent then UpdateSectionHeight() end
                end)
            end))
            Library:AddConnection(Library.MobileScale:GetPropertyChangedSignal("Scale"):Connect(UpdateSectionHeight))
            ButtonFrame.MouseButton1Click:Connect(function() ElementSection:Toggle() end)
            setmetatable(ElementSection, BaseComponents)
            ElementSection:SetOpen(InitiallyOpen)
            return ElementSection
        end

        MakeDraggable(Top2, TabHolder)

        local function UpdateElementsSize()
            local camera = workspace.CurrentCamera
            if not camera then return end
            local scale = math_max(Library.MobileScale and Library.MobileScale.Scale or 1, 0.001)
            local contentHeight = ElementsListLayout.AbsoluteContentSize.Y / scale
            local topInset, bottomInset = game:GetService("GuiService"):GetGuiInset()
            local inset = UI.IgnoreGuiInset and 0 or topInset.Y + bottomInset.Y
            local safeBottom = camera.ViewportSize.Y - inset - 8
            local remaining = math_max(0, safeBottom - TabHolder.AbsolutePosition.Y) / scale
            local footer = TabHolder:FindFirstChild("DragFooter")
            local footerHeight = footer and footer.Size.Y.Offset or 0
            local maxHeight = math_max(0, remaining - 41 - footerHeight)
            Elements.Size = UDim2_new(1, 0, 0, math_clamp(contentHeight, 0, maxHeight))
        end
        local viewportConnection
        local function BindViewport()
            if viewportConnection then viewportConnection:Disconnect() end
            local camera = workspace.CurrentCamera
            if camera then
                viewportConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateElementsSize)
                Library:AddConnection(viewportConnection)
            end
            UpdateElementsSize()
        end
        BindViewport()
        local ElementsSizeQueued = false
        local function ScheduleElementsSize()
            if ElementsSizeQueued then return end
            ElementsSizeQueued = true
            task_defer(function()
                ElementsSizeQueued = false
                if not Library.Unloaded and TabHolder.Parent then UpdateElementsSize() end
            end)
        end
        Library:AddConnection(ElementsListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(ScheduleElementsSize))
        Library:AddConnection(Library.MobileScale:GetPropertyChangedSignal("Scale"):Connect(ScheduleElementsSize))
        Library:AddConnection(TabHolder:GetPropertyChangedSignal("AbsolutePosition"):Connect(ScheduleElementsSize))
        Library:AddConnection(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(BindViewport))

        TabButton.MouseEnter:Connect(function()
            Tab.Hovering = true
            if not Tab.Opened then
                Tween(TabButton, FastTween, {BackgroundColor3 = ThemeColor(30, 30, 30)})
                Tween(TabButtonText, FastTween, {TextTransparency = ThemeTextAlpha(0.25)})
            end
        end)

        TabButton.MouseLeave:Connect(function()
            Tab.Hovering = false
            if not Tab.Opened then
                Tween(TabButton, FastTween, {BackgroundColor3 = ThemeColor(25, 25, 25)})
                Tween(TabButtonText, FastTween, {TextTransparency = ThemeTextAlpha(0.5)})
            end
        end)

        TabButton.MouseButton1Click:Connect(function() Tab:Toggle() end)
        if Collapsed ~= false then Tab:Toggle() end

        return Tab
    end

    function Window:AddDialouge(options)
        options = options or {}
        if activeDialogue then return activeDialogue end
        local overlay = Create("TextButton", {
            Name = "DialogueOverlay", AutoButtonColor = false, BackgroundColor3 = Color3_new(0, 0, 0),
            BackgroundTransparency = 1, Size = UDim2_fromScale(1, 1), Text = "", Visible = false, ZIndex = 120, Parent = UI,
        })
        local panel = Create("CanvasGroup", {
            AnchorPoint = Vector2_new(0.5, 0.5), Position = UDim2_fromScale(0.5, 0.5),
            Size = UDim2_new(0.9, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = ThemeColor(25, 25, 25), GroupTransparency = 1, ZIndex = 121, Parent = overlay,
        })
        AttachDPIScale(panel)

        Create("UISizeConstraint", {MaxSize = Vector2_new(360, 10000), Parent = panel})
        Create("UICorner", {CornerRadius = UDim_new(0, 10), Parent = panel})
        Create("UIGradient", {Color = ColorSequence_new(Color3_new(1,1,1), Color3_fromRGB(220,220,220)), Rotation = 90, Parent = panel})
        AddAnimatedBorder(panel)
        Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Parent = panel})
        local header = Create("Frame", {
            BackgroundColor3 = ThemeColor(20, 20, 20),
            Size = UDim2_new(1, 0, 0, 40),
            LayoutOrder = 1,
            ZIndex = 122,
            Parent = panel,
        })

        Create("UICorner", {CornerRadius = UDim_new(0, 10), Parent = header})
        Create("Frame", {
            BackgroundColor3 = ThemeColor(20, 20, 20),
            Position = UDim2_new(0, 0, 1, -6),
            Size = UDim2_new(1, 0, 0, 6),
            ZIndex = 122,
            Parent = header,
        })
        local dialogueIcon = options.Icon and Library:GetIcon(options.Icon)
        if dialogueIcon then
            local image = Create("ImageLabel", {
                BackgroundTransparency = 1,
                Image = "",
                ImageTransparency = 0.3,
                Position = UDim2_fromOffset(12, 10),
                Size = UDim2_fromOffset(20, 20),
                ZIndex = 123,
                Parent = header,
            })
            Library:ApplyIcon(image, dialogueIcon)
        end
        Create("TextLabel", {
            BackgroundTransparency = 1,
            FontFace = MediumFont,
            TextColor3 = ThemeColor(255, 255, 255),
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Position = UDim2_fromOffset(dialogueIcon and 40 or 12, 0),
            Size = UDim2_new(1, dialogueIcon and -52 or -24, 1, 0),
            Text = options.Title or "Dialogue",
            ZIndex = 123,
            Parent = header,
        })
        Create("Frame", {
            BackgroundColor3 = ThemeColor(60, 60, 60),
            Size = UDim2_new(1, 0, 0, 1),
            LayoutOrder = 2,
            ZIndex = 122,
            Parent = panel,
        })
        local body = Create("Frame", {
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y,
            Size = UDim2_new(1, 0, 0, 0),
            LayoutOrder = 3,
            ZIndex = 122,
            Parent = panel,
        })
        Create("UIPadding", {
            PaddingTop = UDim_new(0, 10),
            PaddingBottom = UDim_new(0, 5),
            PaddingLeft = UDim_new(0, 13),
            PaddingRight = UDim_new(0, 13),
            Parent = body,
        })
        Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim_new(0, 15), Parent = body})
        local message = options.Content or options.Description or ""
        Create("TextLabel", {
            BackgroundTransparency = 1,
            FontFace = RegularFont,
            TextColor3 = ThemeColor(255, 255, 255),
            TextTransparency = ThemeTextAlpha(0.3),
            TextSize = 14,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            Text = message,
            Visible = message ~= "",
            AutomaticSize = Enum.AutomaticSize.Y,
            Size = UDim2_new(1, 0, 0, 0),
            LayoutOrder = 1,
            ZIndex = 123,
            Parent = body,
        })
        local buttons = Create("ScrollingFrame", {
            BackgroundTransparency = 1,
            Active = true,
            CanvasSize = UDim2_fromOffset(0, 0),
            ScrollingDirection = Enum.ScrollingDirection.X,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = ThemeColor(100, 100, 100),
            Size = UDim2_new(1, 0, 0, 38),
            LayoutOrder = 2,
            ZIndex = 123,
            Parent = body,
        })
        Create("UIPadding", {
            PaddingTop = UDim_new(0, 2),
            PaddingBottom = UDim_new(0, 4),
            PaddingLeft = UDim_new(0, 2),
            PaddingRight = UDim_new(0, 2),
            Parent = buttons,
        })
        local buttonLayout = Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim_new(0, 6),
            Parent = buttons,
        })
        buttonLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            buttons.CanvasSize = UDim2_fromOffset(buttonLayout.AbsoluteContentSize.X + 4, 0)
        end)
        local dialogue = {Opened = false}
        local entries, hovered, openedAt = {}, nil, 0
        local inputConnection
        local fadeId, panelTween, OverlayTween = 0, nil, nil
        local function animate(show)
            fadeId += 1
            local id = fadeId
            if panelTween then panelTween:Cancel() end
            if OverlayTween then OverlayTween:Cancel() end
            if show then overlay.Visible = true end
            local info = TweenInfo_new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
            local tween = TweenService:Create(panel, info, {GroupTransparency = show and 0 or 1})
            panelTween = tween
            OverlayTween = TweenService:Create(overlay, info, {BackgroundTransparency = show and 0.45 or 1})
            tween.Completed:Connect(function(state)
                if id ~= fadeId or state ~= Enum.PlaybackState.Completed then return end
                panelTween = nil
                if not dialogue.Opened then
                    overlay.Visible = false
                    if activeDialogue == dialogue then activeDialogue = nil end
                end
            end)
            tween:Play()
            OverlayTween:Play()
        end
        function dialogue:Open()
            if self.Opened or (activeDialogue and activeDialogue ~= self) then return false end
            activeDialogue = self
            self.Opened = true
            openedAt = os_clock()
            animate(true)
            return true
        end
        function dialogue:Close()
            if not self.Opened then return end
            self.Opened = false
            hovered = nil
            animate(false)
        end
        function dialogue:Destroy()
            fadeId += 1
            if panelTween then panelTween:Cancel() end
            if OverlayTween then OverlayTween:Cancel() end
            if activeDialogue == self then activeDialogue = nil end
            if inputConnection then inputConnection:Disconnect(); inputConnection = nil end
            hovered = nil
            overlay:Destroy()
        end
        function dialogue:AddButton(buttonOptions, callback)
            if type(buttonOptions) == "string" then buttonOptions = {Name = buttonOptions, Callback = callback} end
            buttonOptions = buttonOptions or {}
            local buttonName = tostring(buttonOptions.Name or buttonOptions.Title or "Button")
            local bounds = GetTextBounds(buttonName, RegularFont, 14, 1000)
            local width = math_clamp((bounds and bounds.X or 60) + 28, 82, 220)
            local primary = buttonOptions.Primary == true
            local base = primary and ThemeColor(25,25,25):Lerp(ThemeColor(60,200,100),0.15) or ThemeColor(35,35,35)
            local button = Create("TextButton", {
                AutoButtonColor = false,
                BackgroundColor3 = base,
                FontFace = RegularFont,
                TextSize = 14,
                TextColor3 = ThemeColor(220, 220, 220),
                TextTransparency = ThemeTextAlpha(0.12),
                Text = buttonName,
                Size = UDim2_fromOffset(width, 28),
                ZIndex = 124,
                Parent = buttons,
            })
            Create("UICorner", {CornerRadius = UDim_new(0, 6), Parent = button})
            local stroke = Create("UIStroke", {
                Color = primary and ThemeColor(60,200,100) or ThemeColor(70,70,70),
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                Parent = button,
            })
            Create("UIGradient", {Color = ColorSequence_new(Color3_new(1,1,1),Color3_fromRGB(225,225,225)), Rotation = 90, Parent = button})
            local entry = {Button = button, Default = buttonOptions.Default == true, Cancel = buttonOptions.Cancel == true}
            local lastActivation = -math_huge
            function entry:Activate()
                if not dialogue.Opened or activeDialogue ~= dialogue or Library.Unloaded or not button.Parent or not button.Visible then return end
                local now = os_clock()
                if now - lastActivation < .15 then return end
                lastActivation = now
                Library:SafeCallback(buttonOptions.Callback, dialogue)
            end
            table_insert(entries, entry)
            button.MouseEnter:Connect(function() hovered = entry; Tween(button, FastTween, {BackgroundColor3 = base:Lerp(ThemeColor(60,200,100),0.12), TextTransparency = 0}); Tween(stroke, FastTween, {Color = ThemeColor(60,200,100)}) end)
            button.MouseLeave:Connect(function() if hovered == entry then hovered = nil end; Tween(button, FastTween, {BackgroundColor3 = base, TextTransparency = ThemeTextAlpha(0.12)}); Tween(stroke, FastTween, {Color = primary and ThemeColor(60,200,100) or ThemeColor(70,70,70)}) end)
            button.MouseButton1Click:Connect(function() entry:Activate() end)
            return button
        end
        for _, button in ipairs(options.Buttons or {}) do dialogue:AddButton(button) end
        inputConnection = UserInputService.InputBegan:Connect(function(input)
            if not dialogue.Opened or activeDialogue ~= dialogue or Library.Unloaded or UserInputService:GetFocusedTextBox() then return end
            if os_clock() - openedAt < .12 then return end
            if input.KeyCode == Enum.KeyCode.Backspace then
                for _, entry in ipairs(entries) do if entry.Cancel then entry:Activate(); return end end
                return
            end
            if input.KeyCode ~= Enum.KeyCode.Return and input.KeyCode ~= Enum.KeyCode.KeypadEnter then return end
            
            if options.ConfirmOnEnter then
                for _, entry in ipairs(entries) do if entry.Default then entry:Activate(); return end end
            end
            local chosen = hovered
            if not chosen then
                local selectedObject = game:GetService("GuiService").SelectedObject
                for _, entry in ipairs(entries) do if entry.Button == selectedObject then chosen = entry; break end end
            end
            if not chosen then
                for _, entry in ipairs(entries) do if entry.Default then chosen = entry; break end end
            end
            
            chosen = chosen or entries[1]
            if chosen then chosen:Activate() end
        end)
        Library:AddConnection(inputConnection)
        if options.AutoOpen ~= false then dialogue:Open() end
        return dialogue
    end
    Window.AddDialogue = Window.AddDialouge

    function Window:BuildSettingsElement(tab)
        local UISection = tab:AddElementSection("UI Manager")
        local ConfigSection = tab:AddElementSection("Config Manager")

        UISection:AddDropdown({
            Name = "Theme",
            Searchable = true,
            Values = {"Default", "Nature", "Rose", "Obsidian", "Discord", "Midnight", "SynthWave", "Monokai", "Solarized", "Red", "Pink", "Aurora", "Sunset", "Sandstorm", "Cyberpunk", "Glacier", "Espresso", "Volcano", "Energized", "Gum", "Arctic", "Orchid", "Slate", "Eucalyptus", "Lagoon", "Cocoa", "Charcoal", "Steel", "Firefly", "Gold"},
            Default = Library.InitialTheme or "Aurora", AllowNull = false,
            Callback = function(value)
                if value and ThemeDefinitions[value] then
                    Library:SetTheme(value)
                    SaveTheme(value)
                end
            end,
        })

        local dpiSaveToken = 0
        Library.DPISlider = UISection:AddSlider({
            Name = "DPI", Min = 50, Max = 150, Increment = 5, Value = Library.DPIPercent,
            DisplayFormat = "%d%%",
            Callback = function(value)
                Library:SetDPIScale(value)
                dpiSaveToken += 1
                local token = dpiSaveToken
                task_delay(0.4, function()
                    if token ~= dpiSaveToken or Library.Unloaded then return end
                    pcall(function()
                        if EnsureSaveFolder() then
                            local storage = GetStorageFolder()
                            if storage then write_file(storage .. "/DPI.json", HttpService:JSONEncode({Percent = value})) end
                        end
                    end)
                end)
            end,
        })

        local savedKeybind = LoadKeybind()
        local initialKeybind = savedKeybind == nil and Library.ToggleKeybind or savedKeybind
        Library.ToggleKeybind = UISection:AddKeyPicker({
            Name = "Keybind",
            NoUI = true,
            FixedMode = true,
            Keybind = initialKeybind
        })

        do
            local picker = Library.ToggleKeybind
            local originalSetKeybind = picker.SetKeybind
            function picker:SetKeybind(keybind, picking)
                local nextKey = not picking and GetKeybindFromString(keybind)
                if nextKey and type(Library.CommandPaletteKeybind) == "table" and Library.CommandPaletteKeybind.Keybind == nextKey then self:Update(self.Keybind, false); return false end
                originalSetKeybind(self, keybind, picking)
                if not picking then
                    SaveKeybind(self.Keybind)
                end
            end
        end

        local paletteFile = GetStorageFolder() and (GetStorageFolder() .. "/PaletteKeybind.json")
        local savedPaletteKey
        if paletteFile and is_file(paletteFile) then
            local ok, data = pcall(function() return HttpService:JSONDecode(read_file(paletteFile)) end)
            if ok and type(data) == "table" and type(data.Keybind) == "string" then
                if data.Keybind == "None" then savedPaletteKey = false
                else savedPaletteKey = GetKeybindFromString(data.Keybind) end
            end
        end
        local initialPaletteKey = savedPaletteKey == nil and Enum.KeyCode.Semicolon or savedPaletteKey
        if initialPaletteKey and Library.ToggleKeybind.Keybind == initialPaletteKey then initialPaletteKey = Library.ToggleKeybind.Keybind ~= Enum.KeyCode.F4 and Enum.KeyCode.F4 or nil end
        local paletteKeyPicker = UISection:AddKeyPicker({Name = "Palette Keybind", NoUI = true, FixedMode = true, Keybind = initialPaletteKey})
        Library.CommandPaletteKeybind = paletteKeyPicker
        do
            local originalSetKeybind = paletteKeyPicker.SetKeybind
            function paletteKeyPicker:SetKeybind(keybind, picking)
                local nextKey = not picking and GetKeybindFromString(keybind)
                if nextKey and type(Library.ToggleKeybind) == "table" and Library.ToggleKeybind.Keybind == nextKey then self:Update(self.Keybind, false); return false end
                originalSetKeybind(self, keybind, picking)
                if picking or not paletteFile then return end
                pcall(function()
                    if EnsureSaveFolder() then
                        write_file(paletteFile, HttpService:JSONEncode({Keybind = self.Keybind and tostring(self.Keybind) or "None"}))
                    end
                end)
            end
        end
        UISection:AddToggle({
            Name = "Show Library Features",
            Value = Library.ShowLibrarysFeatures == true,
            Callback = function(value) Library:SetShowLibrarysFeatures(value) end,
        })
        UISection:AddButton({
            Name = "Command Palette", Icon = "command",
            Callback = function() Library:OpenCommandPalette() end,
        })

        UISection:AddButton({
            Name = "Save Position",
            Callback = function()
                local ok = SavePositions()
                if ok then
                    Library:Notify("Position saved!")
                    if Library.AutoLoadPositionToggle then
                        Library.AutoLoadPositionToggle:SetLocked(false)
                    end
                else
                    Library:Notify("Failed to save position")
                end
            end,
        })

        local hasFile = HasSavedPositions()
        local savedState = LoadToggleState()
        local initialValue = hasFile and savedState or false

        local autoLoadToggle
        local isInitializing = true

        autoLoadToggle = UISection:AddToggle({
            Name = "Auto Load Position",
            Value = initialValue,
            Callback = function(state)
                if isInitializing then return end

                SaveToggleState(state)

                if state then
                    if HasSavedPositions() then
                        LoadPositions()
                        Library:Notify("Position loaded")
                    else
                        autoLoadToggle:Set(false)
                    end
                end
            end
        })

        autoLoadToggle:SetLocked(not hasFile)
        Library.AutoLoadPositionToggle = autoLoadToggle

        if initialValue then
            task_defer(function()
                LoadPositions()
            end)
        end

        isInitializing = false

        UISection:AddButton({
            Name = "Reset Position",
            DoubleClick = true,
            Callback = function()
                isInitializing = true
                ResetPositions()
                ResetToggleStateFile()
                autoLoadToggle:Set(false)
                autoLoadToggle:SetLocked(true)
                isInitializing = false
                SaveToggleState(false)
                Library:Notify("Position reset")
            end,
        })

        UISection:AddButton({
            Name = "Unload", DoubleClick = true,
            Callback = function() Library:Unload() end,
        })

        local configNameBox = ConfigSection:AddTextbox({ Name = "Config Name", Placeholder = "Default..." })
        local configList = ConfigSection:AddDropdown({ Name = "Config List", Values = Library:RefreshConfigList(), AllowNull = true })

        local autoloadLabel
        local function RefreshAutoloadLabel()
            local name = Library:GetAutoloadConfig()
            if autoloadLabel then
                autoloadLabel:Set(("Autoload: %s"):format(name))
            end
        end

        ConfigSection:AddButton({
            Name = "Create Config",
            Callback = function()
                local n = configNameBox.Text
                if IsStringEmpty(n) then return Library:Notify("Config name empty") end
                if n:lower() == "autoload" then return Library:Notify("Reserved name") end
                local ok, err = Library:SaveConfig(n)
                if not ok then return Library:Notify("Save failed: " .. tostring(err)) end
                Library:Notify(("Created %q"):format(n))
                configList:SetValues(Library:RefreshConfigList())
                RefreshAutoloadLabel()
            end,
        })
        ConfigSection:AddDivider()

        ConfigSection:AddButton({
            Name = "Load config",
            Callback = function()
                local n = configList.Value
                if not n then return Library:Notify("Select a config") end
                local ok, err = Library:LoadConfig(n)
                if not ok then return Library:Notify("Load failed: " .. tostring(err)) end
                Library:Notify(("Loaded %q"):format(n))
            end,
        })

        ConfigSection:AddButton({
            Name = "Delete config",
            DoubleClick = true,
            Callback = function()
                local n = configList.Value
                if not n then return Library:Notify("Select a config") end
                local ok, err = Library:DeleteConfig(n)
                if not ok then return Library:Notify("Delete failed: " .. tostring(err)) end
                Library:Notify(("Deleted %q"):format(n))
                configList:SetValues(Library:RefreshConfigList())
                RefreshAutoloadLabel()
            end,
        })

        ConfigSection:AddButton({
            Name = "Overwrite config",
            Callback = function()
                local n = configList.Value
                if not n then return Library:Notify("Select a config") end
                local ok, err = Library:SaveConfig(n)
                if not ok then return Library:Notify("Save failed: " .. tostring(err)) end
                Library:Notify(("Overwrote %q"):format(n))
                RefreshAutoloadLabel()
            end,
        })

        ConfigSection:AddButton({
            Name = "Set autoload",
            Callback = function()
                local n = configList.Value
                if not n then return Library:Notify("Select a config") end
                local ok, err = Library:SaveAutoloadConfig(n)
                if not ok then return Library:Notify("Autoload failed: " .. tostring(err)) end
                Library:Notify(("Autoload set to %q"):format(n))
                RefreshAutoloadLabel()
            end,
        })

        ConfigSection:AddButton({
            Name = "Reset autoload",
            DoubleClick = true,
            Callback = function()
                local ok, err = Library:DeleteAutoloadConfig()
                if not ok then return Library:Notify("Reset failed: " .. tostring(err)) end
                Library:Notify("Autoload cleared")
                RefreshAutoloadLabel()
            end,
        })

        ConfigSection:AddButton({
            Name = "Refresh list",
            Callback = function()
                configList:SetValues(Library:RefreshConfigList())
                RefreshAutoloadLabel()
            end,
        })

        autoloadLabel = ConfigSection:AddLabel("Autoload: None")
        RefreshAutoloadLabel()
    end

    if Library.Mobile then
        local MobileButtonHolder = Create("Frame", {
            AnchorPoint = Vector2_new(1, 0),
            BackgroundColor3 = ThemeColor(20, 20, 20),
            Position = UDim2_new(1, -12, 0, 12),
            Size = UDim2_fromOffset(194, 52),
            Parent = UI,
        })

        Library.MobileButton = MobileButtonHolder
        Create("UICorner", { CornerRadius = UDim_new(0, 10), Parent = MobileButtonHolder })
        Create("UIGradient", {Color = ColorSequence_new(Color3_fromRGB(255, 255, 255), Color3_fromRGB(210, 210, 210)), Rotation = 90, Parent = MobileButtonHolder})
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = ThemeColor(60, 200, 100),
            Thickness = 1,
            Transparency = 0.45,
            Parent = MobileButtonHolder,
        })

        local IconHolder = Create("Frame", {
            BackgroundColor3 = ThemeColor(30, 30, 30),
            Position = UDim2_fromOffset(10, 10),
            Size = UDim2_fromOffset(32, 32),
            Parent = MobileButtonHolder,
        })
        Create("UICorner", { CornerRadius = UDim_new(0, 8), Parent = IconHolder })
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = ThemeColor(72, 72, 72),
            Thickness = 1,
            Transparency = 0.2,
            Parent = IconHolder,
        })

        local UIIcon = Create("ImageLabel", {
            AnchorPoint = Vector2_new(0.5, 0.5),
            BackgroundTransparency = 1,
            Image = "",
            ImageTransparency = 0,
            Position = UDim2_fromScale(0.5, 0.5),
            Size = UDim2_fromOffset(18, 18),
            Parent = IconHolder,
        })
        Library:ApplyIcon(UIIcon, Library:GetIcon("layout-grid") or SettingsIcon)
        UIIcon.ImageColor3 = ThemeColor(60, 200, 100)
        Library.MobileRouterIcon = UIIcon

        local TitleLabel = Create("TextLabel", {
            BackgroundTransparency = 1,
            FontFace = SemiBoldFont,
            Position = UDim2_fromOffset(52, 8),
            Size = UDim2_new(1, -75, 0, 20),
            Text = "Menu",
            TextColor3 = ThemeColor(255, 255, 255),
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTransparency = 0.05,
            Parent = MobileButtonHolder,
        })

        local SubtitleLabel = Create("TextLabel", {
            BackgroundTransparency = 1,
            FontFace = RegularFont,
            Position = UDim2_fromOffset(52, 27),
            Size = UDim2_new(1, -75, 0, 16),
            Text = "Tap to toggle",
            TextColor3 = ThemeColor(200, 200, 200),
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTransparency = 0.05,
            Parent = MobileButtonHolder,
        })

        local Grip = Create("ImageLabel", {
            AnchorPoint = Vector2_new(1, 0.5),
            BackgroundTransparency = 1,
            Image = "",
            ImageTransparency = 0.5,
            Position = UDim2_new(1, -46, 0.5, 0),
            Size = UDim2_fromOffset(16, 16),
            Parent = MobileButtonHolder,
        })
        Library:ApplyIcon(Grip, MoveIcon or Library:GetIcon("move"))

        local Accent = Create("Frame", {
            AnchorPoint = Vector2_new(0.5, 1),
            BackgroundColor3 = ThemeColor(60, 200, 100),
            BackgroundTransparency = 0.35,
            BorderSizePixel = 0,
            Position = UDim2_fromScale(0.5, 1),
            Size = UDim2_new(1, -20, 0, 2),
            Parent = MobileButtonHolder,
        })
        Create("UICorner", { CornerRadius = UDim_new(1, 0), Parent = Accent })

        local Interaction = Create("TextButton", {
            Name = "MobileToggleInteraction",
            AutoButtonColor = false,
            BackgroundTransparency = 1,
            Size = UDim2_new(1, -40, 1, 0),
            Text = "",
            Parent = MobileButtonHolder,
        })

        local PaletteButton = Create("TextButton", {
            Name = "MobilePaletteButton", AutoButtonColor = false,
            AnchorPoint = Vector2_new(1, 0.5), Position = UDim2_new(1, -7, 0.5, 0),
            Size = UDim2_fromOffset(32, 30), BackgroundColor3 = ThemeColor(25, 25, 25):Lerp(ThemeColor(60, 200, 100), 0.16),
            Text = "", ZIndex = 3, Parent = MobileButtonHolder,
        })
        PaletteButton:SetAttribute("ThemeAccentButton", true)
        Create("UIGradient", {Color = ColorSequence_new(Color3_fromRGB(255,255,255), Color3_fromRGB(205,205,205)), Rotation = 90, Parent = PaletteButton})
        Create("UICorner", {CornerRadius = UDim_new(1, 0), Parent = PaletteButton})
        Create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = ThemeColor(60, 200, 100), Transparency = 0.55, Parent = PaletteButton})
        local PaletteIcon = Create("ImageLabel", {Name = "PaletteIcon", BackgroundTransparency = 1, AnchorPoint = Vector2_new(0.5, 0.5), Position = UDim2_fromScale(0.5, 0.5), Size = UDim2_fromOffset(16, 16), Image = "", ImageColor3 = ThemeColor(60, 200, 100), ZIndex = 4, Parent = PaletteButton})
        PaletteIcon:SetAttribute("ThemeAccentIcon", true)
        Library:ApplyIcon(PaletteIcon, Library:GetIcon("command"))
        PaletteButton.Activated:Connect(function() Library:OpenCommandPalette() end)

        local DRAG_THRESHOLD = 6
        local dragging = false
        local moved = false
        local dragStartPos
        local startFramePos
        local startButtonAbsolute
        local dragConn
        local activeInput

        local function EndDrag()
            dragging = false
            activeInput = nil
            if dragConn then
                dragConn:Disconnect()
                local Index = table_find(Library.Connections, dragConn)
                if Index then table_remove(Library.Connections, Index) end
                dragConn = nil
            end
            Tween(MobileButtonHolder, FastTween, { Size = UDim2_fromOffset(194, 52) })
        end

        Interaction.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.Touch
                and input.UserInputType ~= Enum.UserInputType.MouseButton1 then
                return
            end

            if dragging then return end
            if input.UserInputType == Enum.UserInputType.Touch and #UserInputService:GetTouches() > 1 then return end
            dragging = true
            activeInput = input
            moved = false
            dragStartPos = input.Position
            startFramePos = MobileButtonHolder.Position
            startButtonAbsolute = MobileButtonHolder.AbsolutePosition

            Tween(MobileButtonHolder, FastTween, { Size = UDim2_fromOffset(190, 50) })

            if dragConn then dragConn:Disconnect() end
            dragConn = UserInputService.InputChanged:Connect(function(i)
                if not dragging or not activeInput then return end
                if activeInput.UserInputType == Enum.UserInputType.Touch then
                    if i ~= activeInput then return end
                    if #UserInputService:GetTouches() > 1 then moved = true EndDrag() return end
                elseif i.UserInputType ~= Enum.UserInputType.MouseMovement then return end

                local delta = i.Position - dragStartPos
                if not moved then
                    if math_abs(delta.X) >= DRAG_THRESHOLD or math_abs(delta.Y) >= DRAG_THRESHOLD then
                        moved = true
                    end
                end

                if moved then
                    local camera = workspace.CurrentCamera
                    local viewport = camera and camera.ViewportSize or Vector2_new(800, 600)
                    local inset = game:GetService("GuiService"):GetGuiInset()
                    local size = MobileButtonHolder.AbsoluteSize
                    local x = math_clamp(startButtonAbsolute.X + delta.X, 6, math_max(6, viewport.X - size.X - 6))
                    local y = math_clamp(startButtonAbsolute.Y + delta.Y, 0, math_max(0, viewport.Y - size.Y - 1))
                    MobileButtonHolder.Position = UDim2_new(
                        startFramePos.X.Scale, startFramePos.X.Offset + x - startButtonAbsolute.X,
                        startFramePos.Y.Scale, startFramePos.Y.Offset + y - startButtonAbsolute.Y
                    )
                end
            end)
            table_insert(Library.Connections, dragConn)

            local endedConn
            endedConn = input.Changed:Connect(function()
                if input.UserInputState ~= Enum.UserInputState.End then return end
                if endedConn then endedConn:Disconnect() end
                if activeInput ~= input then return end
                local wasMoved = moved
                EndDrag()

                if not wasMoved then
                    task_spawn(Library.Toggle)
                end
            end)
        end)

        Library:AddConnection(UserInputService.TouchStarted:Connect(function(input)
            if dragging and activeInput and activeInput.UserInputType == Enum.UserInputType.Touch and input ~= activeInput then
                moved = true
                EndDrag()
            end
        end))

    end

    Library:AddConnection(UserInputService.InputBegan:Connect(function(input)
        if Library.ActiveKeyPicker then return end
        if typeof(Library.ToggleKeybind) == "table" and Library.ToggleKeybind.Type == "KeyPicker" and input.KeyCode == Library.ToggleKeybind.Keybind and not Library.ToggleKeybind.Picking then
            task_spawn(Library.Toggle)
        elseif input.KeyCode == Library.ToggleKeybind then
            task_spawn(Library.Toggle)
        end
    end))

    MakeDraggable(Top, MainWindow)
    return Window
end

function Library:Notify(text: string, duration: number)
    text = tostring(text or "")
    duration = math_max(0, tonumber(duration) or 5)
    local camera = workspace.CurrentCamera
    local maxWidth = camera and math_clamp(camera.ViewportSize.X - 32, 120, 340) or 300
    local bounds = GetTextBounds(text, RegularFont, 15, math_max(40, maxWidth - 60)) or Vector2_new(120, 18)
    local width = math_min(maxWidth, math_max(180, bounds.X + 60))
    local height = math_max(46, bounds.Y + 22)
    local Holder = Create("Frame", {BackgroundTransparency = 1, Size = UDim2_fromOffset(width, height), Parent = Notifications})
    local Card = Create("CanvasGroup", {BackgroundColor3 = ThemeColor(25, 25, 25), GroupTransparency = 1, Position = UDim2_new(1, 12, 0, 0), Size = UDim2_fromScale(1, 1), Parent = Holder})
    Create("UICorner", {CornerRadius = UDim_new(0, 9), Parent = Card})
    Create("UIGradient", {Color = ColorSequence_new(Color3_fromRGB(255,255,255), Color3_fromRGB(210,210,210)), Rotation = 90, Parent = Card})
    AddAnimatedBorder(Card)
    local Accent = Create("Frame", {BackgroundColor3 = ThemeColor(60, 200, 100), Position = UDim2_fromOffset(0, 8), Size = UDim2_new(0, 3, 1, -16), Parent = Card})
    Create("UICorner", {CornerRadius = UDim_new(1, 0), Parent = Accent})
    local Icon = Create("ImageLabel", {BackgroundTransparency = 1, Image = "", ImageColor3 = ThemeColor(60, 200, 100), Position = UDim2_new(0, 13, 0.5, -9), Size = UDim2_fromOffset(18, 18), Parent = Card})
    Icon:SetAttribute("ThemeAccentIcon", true)
    Library:ApplyIcon(Icon, Library:GetIcon("info"))
    Create("TextLabel", {BackgroundTransparency = 1, FontFace = RegularFont, Position = UDim2_fromOffset(39, 6), Size = UDim2_new(1, -49, 1, -12), Text = text, TextColor3 = ThemeColor(255, 255, 255), TextSize = 15, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Parent = Card})
    local Show = TweenService:Create(Card, TweenInfo_new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2_fromScale(0, 0), GroupTransparency = 0})
    Show:Play()
    task_delay(duration, function()
        if not Holder.Parent or not Card.Parent then return end
        local Hide = TweenService:Create(Card, TweenInfo_new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Position = UDim2_new(1, 12, 0, 0), GroupTransparency = 1})
        Hide:Play()
        Hide.Completed:Once(function() if Holder.Parent then Holder:Destroy() end end)
    end)
end

local ModalElement = Create("TextButton", {
    BackgroundTransparency = 1, Modal = true,
    Size = UDim2_fromScale(1, 1), Text = "", Visible = false, ZIndex = 0, Parent = UI
})

local windowTween
local windowTweenId = 0

function Library:Toggle()
    if Library.Opened == nil then
        Library.Opened = getgenv().Auto_Show ~= false
        Windows.Visible = Library.Opened
        if Library.MainWindow then Library.MainWindow.GroupTransparency = Library.Opened and 0 or 1 end
        ModalElement.Visible = Library.Opened or Library._PaletteModalActive == true
        if Library.Blur then Library.Blur.Enabled = Library.Opened end
        return
    end

    Library.Opened = not Library.Opened
    if not Library.Opened then TooltipToken += 1; if TooltipBox then TooltipBox.Visible = false end end
    for option in pairs(openOptions) do
        if Library.Opened then option:ReturnToToggle() else option:DetachToLeft() end
    end
    windowTweenId += 1
    local animationId = windowTweenId
    if windowTween then windowTween:Cancel() end
    Windows.Visible = true
    ModalElement.Visible = Library.Opened or Library._PaletteModalActive == true
    if Library.Blur then Library.Blur.Enabled = Library.Opened end

    for _, tab in Library.TabAnimations or {} do
        tab:AnimatePanel(Library.Opened and tab.Opened)
    end
    local main = Library.MainWindow
    if not main then Windows.Visible = Library.Opened return end
    local tween = TweenService:Create(main, TweenInfo_new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        GroupTransparency = Library.Opened and 0 or 1
    })
    windowTween = tween
    tween.Completed:Connect(function(state)
        if animationId ~= windowTweenId or state ~= Enum.PlaybackState.Completed then return end
        windowTween = nil
        if not Library.Opened then Windows.Visible = false end
    end)
    tween:Play()
end

do
    local PaletteState = {
        Commands = {},
        PaletteGeneration = 0,
        ExpandedDropdowns = {},
        ExpandedColors = {},
        ExpandedSliders = {},
        ExpandedSteppers = {},
        NumericShortcutName = "PaletteNumber" .. HttpService:GenerateGUID(false),
        PaletteViews = {},
        PaletteRevision = 0,
        ViewSerial = 0,
        SearchGeneration = 0,
        PendingSearch = false,
        FavoriteCommands = {},
        FavoritesLoaded = false,
        FavoriteSavePending = false,
        FavoriteSaveVersion = 0,
    }
    local Selected = 1
    local MAX_PALETTE_VIEWS = 8
    local MAX_CACHED_PALETTE_ROWS = 1200
    local function PaletteInput()
        local text = PaletteState.Search and PaletteState.Search.Text or ""
        if PaletteState.IgnoredOpeningPrefix and text:sub(1,1) == PaletteState.IgnoredOpeningPrefix then return text:sub(2) end
        return text
    end

    local function FavoritePath()
        return (Library.SaveFolder or "Library") .. "/Favorites.json"
    end
    local function LoadFavorites()
        if PaletteState.FavoritesLoaded then return end
        PaletteState.FavoritesLoaded = true
        if type(is_file) ~= "function" or type(read_file) ~= "function" then return end
        local ok, data = pcall(function()
            local path = FavoritePath()
            if is_file(path) then return HttpService:JSONDecode(read_file(path)) end
        end)
        if ok and type(data) == "table" then PaletteState.FavoriteCommands = data end
    end
    local function SaveFavorites()
        if type(write_file) ~= "function" then return end
        pcall(function() if EnsureSaveFolder() then write_file(FavoritePath(), HttpService:JSONEncode(PaletteState.FavoriteCommands)) end end)
    end
    local function QueueFavoriteSave()
        PaletteState.FavoriteSavePending = true
        PaletteState.FavoriteSaveVersion += 1
        local version = PaletteState.FavoriteSaveVersion
        task_delay(.25, function()
            if PaletteState.FavoriteSavePending and version == PaletteState.FavoriteSaveVersion then
                PaletteState.FavoriteSavePending = false
                SaveFavorites()
            end
        end)
    end
    local Matches = {}
    local PaletteConnections = {}
    local ActiveMenu
    local OwnedHandles = {}
    local Foreground = Color3_fromRGB(235, 235, 235)
    local Muted = Color3_fromRGB(160, 160, 160)
    local background = Color3_fromRGB(25, 25, 25)
    local RowColor = Color3_fromRGB(38, 38, 38)

    local function Make(class, properties)
        return Create(class, properties)
    end

    local function Corner(parent, radius)
        Make("UICorner", { CornerRadius = UDim_new(0, radius or 6), Parent = parent })
    end

    local function Track(connection)
        Library:AddConnection(connection)
        return connection
    end

    local function CleanConnections(connections)
        for _, connection in ipairs(connections) do
            if connection.Connected then connection:Disconnect() end
        end
        table_clear(connections)
    end

    local function ScreenPoint(position)
        local inset = game:GetService("GuiService"):GetGuiInset()
        return Vector2_new(position.X - inset.X, position.Y - inset.Y)
    end

    local function viewport()
        local camera = workspace.CurrentCamera
        local size = camera and camera.ViewportSize or Vector2_new(800, 600)
        local inset = game:GetService("GuiService"):GetGuiInset()
        return Vector2_new(size.X, math_max(1, size.Y - inset.Y))
    end

    local function button(parent, text, z)
        return Make("TextButton", {
            AutoButtonColor = true, BackgroundColor3 = RowColor,
            BorderSizePixel = 0, Text = text, TextColor3 = Foreground,
            TextSize = 14, Font = Enum.Font.Gotham, ZIndex = z, Parent = parent,
        })
    end

    function Library:AddCommand(info, arguments, description, callback, options)
        if type(info) == "string" then
            if type(arguments) == "function" then info = {Name = info, Callback = arguments}
            else
                options = type(options) == "table" and options or {}
                info = {Name = info, Arguments = arguments or {}, Description = description or "", Callback = callback, Aliases = options.Alias or options.Support or options.Aliases, _LegacyArguments = true}
            end
        end
        assert(type(info) == "table" and type(info.Name) == "string" and info.Name:match("%S"), "A command needs a name")
        assert(type(info.Callback) == "function", "A command needs a callback")
        local command = table_clone(info)
        command.Description = tostring(info.Description or "")
        command.Arguments = type(info.Arguments) == "table" and table_clone(info.Arguments) or nil
        command.Aliases = info.Aliases or info.Alias or info.Support or {}
        if type(command.Aliases) == "string" then command.Aliases = {command.Aliases} end
        if type(command.Aliases) ~= "table" then command.Aliases = {} end
        command.Category = tostring(info.Category or info.Section or "Commands")
        if command.Type == "Dropdown" and command.Kind ~= "Feature" then
            command.Values = type(info.Values) == "table" and table_clone(info.Values) or {}
            command.Multi = info.Multi == true
            command.AllowNull = info.AllowNull ~= false
            command.Searchable = info.Searchable ~= false
            command.Selectable = info.Selectable == true
            command._CustomDropdown = true
            local first = command.Values[1]
            if first == nil then
                local keys = {}
                for key in pairs(command.Values) do table_insert(keys, key) end
                table_sort(keys, function(a, b) return tostring(a) < tostring(b) end)
                first = keys[1]
            end
            if command.Multi then
                local Selected = {}
                if type(info.Default) == "table" then
                    for key, value in pairs(info.Default) do
                        if type(key) == "number" then Selected[value] = true
                        elseif value == true then Selected[key] = true end
                    end
                elseif info.Default ~= nil then Selected[info.Default] = true end
                local available = {}
                for key, option in pairs(command.Values) do available[type(key) == "number" and option or key] = true end
                for option in pairs(Selected) do if not available[option] then Selected[option] = nil end end
                if not command.AllowNull and next(Selected) == nil and first ~= nil then Selected[first] = true end
                command.DefaultValue = next(Selected) or first
                command.Value = Selected
            else
                local default = info.Default
                local valid = false
                for key, option in pairs(command.Values) do
                    if (type(key) == "number" and option or key) == default then valid = true; break end
                end
                command.Value = valid and default or first
            end
            function command:GetValue()
                return self.Multi and table_clone(self.Value) or self.Value
            end
            function command:SetValue(value)
                local available = {}
                for key, option in pairs(self.Values) do
                    if type(key) == "number" then available[option] = true
                    else available[key] = true end
                end
                if self.Multi then
                    local nextValue = {}
                    if type(value) == "table" then
                        for key, enabled in pairs(value) do
                            local option = type(key) == "number" and enabled or key
                            if (type(key) == "number" or enabled == true) and available[option] then nextValue[option] = true end
                        end
                    elseif available[value] then nextValue[value] = true end
                    if not self.AllowNull and next(nextValue) == nil then
                        local fallback = self.DefaultValue or first
                        if fallback and available[fallback] then nextValue[fallback] = true end
                    end
                    self.Value = nextValue
                elseif available[value] then self.Value = value
                elseif value == nil and self.AllowNull then self.Value = nil
                else return false end
                task_spawn(self.Callback, self:GetValue())
                Library._PaletteDirty = true
                if PaletteState.Palette and PaletteState.Palette.Visible and not Library._PaletteBatch then Library:RefreshCommandPalette() end
                return true
            end
            command.ValueText = function()
                if command.Multi then
                    local labels = {}
                    for option, enabled in pairs(command.Value) do if enabled then table_insert(labels, tostring(option)) end end
                    table_sort(labels)
                    return #labels > 0 and table_concat(labels, " • ") or "None"
                end
                return command.Value ~= nil and tostring(command.Value) or "None"
            end
        end
        PaletteState.Commands[info.Name:lower()] = command
        PaletteState.SortedCommandList = nil
        self._PaletteDirty = true
        if PaletteState.Palette and PaletteState.Palette.Visible and not self._PaletteBatch then self:RefreshCommandPalette() end
        return command
    end

    local function FindCommand(name)
        if type(name) ~= "string" then return nil end
        local needle = name:lower()
        if PaletteState.Commands[needle] then return PaletteState.Commands[needle] end
        for _, command in pairs(PaletteState.Commands) do
            for _, alias in ipairs(command.Aliases) do
                if type(alias) == "string" and alias:lower() == needle then return command end
            end
        end
    end

    function Library:RemoveCommand(name)
        local command = FindCommand(name)
        if not command then return false end
        PaletteState.Commands[command.Name:lower()] = nil
        PaletteState.SortedCommandList = nil
        self._PaletteDirty = true
        if PaletteState.Palette and PaletteState.Palette.Visible and not self._PaletteBatch then self:RefreshCommandPalette() end
        return true
    end

    local function GetSortedCommandList()
        if not PaletteState.SortedCommandList then
            PaletteState.SortedCommandList = {}
            for _, command in pairs(PaletteState.Commands) do table_insert(PaletteState.SortedCommandList, command) end
            table_sort(PaletteState.SortedCommandList, function(a, b) return a.Name:lower() < b.Name:lower() end)
        end
        return PaletteState.SortedCommandList
    end
    function Library:GetCommands()
        return table_clone(GetSortedCommandList())
    end

    function Library:RunCommand(name, ...)
        local command = FindCommand(name)
        if not command then return false end
        local args = table_pack(...)
        if command._CustomDropdown then
            local value = args[1]
            if type(value) == "table" and not command.Multi then value = value[1] end
            if type(value) == "table" and command.Multi and #value == 1 then value = value[1] end
            if value == nil then return false end
            if type(value) == "string" then
                local needle = value:lower()
                for key, option in pairs(command.Values) do
                    local candidate = type(key) == "number" and option or key
                    if tostring(candidate):lower() == needle then value = candidate; break end
                end
            end
            if command.Multi and type(value) ~= "table" then
                local Selected = command:GetValue()
                if Selected[value] then
                    Selected[value] = nil
                else Selected[value] = true end
                return command:SetValue(Selected)
            end
            return command:SetValue(value)
        end
        task_spawn(function()
            local ok, err
            if command._LegacyArguments or command.Kind == "Feature" or command.Arguments ~= nil then
                local values = args.n == 1 and type(args[1]) == "table" and args[1] or args
                ok, err = pcall(command.Callback, values, Library.LocalPlayer)
            else
                ok, err = pcall(command.Callback, table_unpack(args, 1, args.n))
            end
            if not ok then warn("[Library] Command '" .. command.Name .. "' failed: " .. tostring(err)) end
        end)
        return true
    end

    local function SplitArguments(text)
        local values, current, quote, escaped = {}, "", nil, false
        local started = false
        for i = 1, #text do
            local c = text:sub(i, i)
            if escaped then current ..= c; escaped = false; started = true
            elseif c == "\\" then escaped = true; started = true
            elseif quote then
                if c == quote then quote = nil else current ..= c end
                started = true
            elseif c == '"' or c == "'" then quote = c; started = true
            elseif c:match("%s") then
                if started then table_insert(values, current); current = ""; started = false end
            else current ..= c; started = true end
        end
        if escaped then current ..= "\\" end
        if started then table_insert(values, current) end
        return values
    end

    local function ArgumentsFor(command, input)
        local trimmed = input:match("^%s*(.-)%s*$") or ""
        local lower = trimmed:lower()
        local names = {command.Name}
        if command.Kind == "Feature" then
            local leaf = command.Name:match("([^/]+)$")
            if leaf then table_insert(names, (leaf:match("^%s*(.-)%s*$"))) end
        end
        for _, alias in ipairs(command.Aliases) do if type(alias) == "string" then table_insert(names, alias) end end
        table_sort(names, function(a, b) return #a > #b end)
        for _, name in ipairs(names) do
            if lower:sub(1, #name) == name:lower() and (#lower == #name or lower:sub(#name + 1, #name + 1):match("%s")) then
                return SplitArguments(trimmed:sub(#name + 1))
            end
        end
        for _, name in ipairs(names) do
            local candidate = name:lower()
            if #lower < #candidate and candidate:sub(1,#lower) == lower then return {} end
        end
        local trailing = trimmed:match("^%S+%s+(.+)$")
        return trailing and SplitArguments(trailing) or {}
    end

    local function IsEditorQuery(command, input)
        local text = (input:match("^%s*(.-)%s*$") or ""):lower()
        local full = command.Name:lower()
        local leaf = (command.Name:match("([^/]+)$") or ""):match("^%s*(.-)%s*$"):lower()
        return text ~= "" and (text == full or (command.Kind == "Feature" and text == leaf))
    end

    local function CommandDescription(command)
        local desc = command.Description
        if type(command.GetDescription) == "function" then
            local ok, value = pcall(command.GetDescription)
            if ok and value ~= nil then desc = tostring(value) end
        end
        if type(command.ValueText) == "function" then
            local ok, value = pcall(command.ValueText)
            if ok and value ~= nil and tostring(value) ~= "" then desc = (desc ~= "" and desc .. " • " or "") .. (command.Kind == "Feature" and "Current: " or "") .. tostring(value) end
        elseif command.ValueText ~= nil then desc = (desc ~= "" and desc .. " • " or "") .. tostring(command.ValueText) end
        return desc
    end

    local function ColorCommandDescription(command)
        local description = CommandDescription(command)
        local prefix, hex = description:match("^(.-)(#%x%x%x%x%x%x)$")
        if not hex then return description end
        prefix = prefix:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
        return prefix .. '<font color="' .. hex .. '">' .. hex .. '</font>'
    end

    local RhythmRandom = Random_new()
    local RhythmRows = {}
    local RhythmCache = {}
    local RhythmDepot
    local LastRhythmUpdate = 0
    Library:AddConnection(RunService.Heartbeat:Connect(function()
        if not PaletteState.Palette or not PaletteState.Palette.Visible or not PaletteState.Results or Library.Unloaded or #RhythmRows == 0 then return end
        local now = os_clock()
        if now - LastRhythmUpdate < 1 / 30 then return end
        LastRhythmUpdate = now
        local top = PaletteState.Results.AbsolutePosition.Y
        local bottom = top + PaletteState.Results.AbsoluteWindowSize.Y
        for _, rhythm in ipairs(RhythmRows) do
            local y = rhythm.Container.AbsolutePosition.Y
            if rhythm.Active and rhythm.Container.Parent and y + rhythm.Container.AbsoluteSize.Y >= top and y <= bottom then
                for i, bar in ipairs(rhythm.Bars) do
                    local height = 3 + (math_noise(rhythm.Seed, i * .37, now * 2.3) + .5) * 12
                    bar.Size = UDim2_fromOffset(2, math_clamp(height, 3, 16))
                end
            end
        end
    end))
    local function VisualCommandDescription(command)
        if command.Kind == "Feature" and command.FeatureKind == "Toggle" and command.FeatureEntry and command.FeatureEntry.GetValue then
            local ok, state = pcall(command.FeatureEntry.GetValue)
            if ok and type(state) == "boolean" then return " ", state end
        end
        return command.FeatureKind == "Color" and ColorCommandDescription(command) or CommandDescription(command), nil
    end

    local function Distance(a, b, Limit)
        local LengthA, LengthB = #a, #b
        if math_abs(LengthA - LengthB) > Limit then return Limit + 1 end
        local Previous, Current = {}, {}
        for j = 0, LengthB do Previous[j] = j end
        for i = 1, LengthA do
            Current[0] = i
            local Minimum = Current[0]
            for j = 1, LengthB do
                local Different = a:byte(i) ~= b:byte(j) and 1 or 0
                local Value = math_min(Current[j - 1] + 1, Previous[j] + 1, Previous[j - 1] + Different)
                Current[j] = Value
                if Value < Minimum then Minimum = Value end
            end
            if Minimum > Limit then return Limit + 1 end
            Previous, Current = Current, Previous
        end
        return Previous[LengthB]
    end

    local function MatchScore(Command, Query, AllowFallback)
        local Lower = tostring(Query or ""):lower():match("^%s*(.-)%s*$"):gsub("%s+", " ")
        if Lower == "" then return 0 end
        local Best
        local function Consider(Value)
            if type(Value) ~= "string" then return end
            local Name = Value:lower():match("^%s*(.-)%s*$"):gsub("%s+", " ")
            local Score
            if Name == Lower then
                Score = 0
            elseif Name:sub(1, #Lower) == Lower then
                Score = 1
            elseif Lower:sub(1, #Name) == Name and Lower:sub(#Name + 1, #Name + 1) == " " then
                Score = 2 - math_min(#Name, 500) / 10000
            elseif Name:find(Lower, 1, true) then
                Score = 4
            elseif AllowFallback and #Lower >= 4 and #Name <= 64 then
                local Limit = #Lower >= 6 and 2 or 1
                if math_abs(#Name - #Lower) <= Limit then
                    local Difference = Distance(Lower, Name, Limit)
                    if Difference <= Limit then Score = 12 + Difference end
                end
            end
            if Score and (not Best or Score < Best) then Best = Score end
        end
        Consider(Command.Name)
        if Command.Kind == "Feature" then
            local Leaf = Command.Name:match("([^/]+)$")
            if Leaf then Consider(Leaf) end
        end
        for _, Alias in ipairs(Command.Aliases) do Consider(Alias) end
        if not Best and AllowFallback and CommandDescription(Command):lower():find(Lower, 1, true) then
            Best = 16
        end
        return Best
    end

    function Library:SearchCommands(Query)
        local Lower = tostring(Query or ""):lower():match("^%s*(.-)%s*$"):gsub("%s+", " ")
        local Ranked = {}
        local Sorted = GetSortedCommandList()
        for _, Command in ipairs(Sorted) do
            local Score = MatchScore(Command, Lower)
            if Score then table_insert(Ranked, {command = Command, score = Score}) end
        end
        if #Ranked == 0 and Lower ~= "" then
            for _, Command in ipairs(Sorted) do
                local Score = MatchScore(Command, Lower, true)
                if Score then table_insert(Ranked, {command = Command, score = Score}) end
            end
        end
        table_sort(Ranked, function(A, B)
            if A.score ~= B.score then return A.score < B.score end
            return A.command.Name:lower() < B.command.Name:lower()
        end)
        local Out = {}
        local Best = Ranked[1] and Ranked[1].score
        for _, Item in ipairs(Ranked) do
            if Best and Best < 16 and Item.score >= 16 then break end
            table_insert(Out, Item.command)
        end
        return Out
    end

    function Library:ExecuteCommand(text)
        local query = tostring(text or ""):match("^%s*(.-)%s*$") or ""
        if query == "" then return false, "Command is empty" end
        local choices = self:SearchCommands(query)
        if #choices == 0 then return false, "Command not found" end
        local command = choices[1]
        if #choices > 1 and MatchScore(choices[1], query, true) == MatchScore(choices[2], query, true) then return false, "Ambiguous command" end
        local args = ArgumentsFor(command, query)
        if command.Arguments and not command.OptionalArguments and #args < #command.Arguments then
            local missing = {}; for i = #args + 1, #command.Arguments do table_insert(missing, tostring(command.Arguments[i])) end
            return false, "Missing arguments: " .. table_concat(missing, ", ")
        end
        if command.Arguments or command.Kind == "Feature" or command._LegacyArguments then
            self:RunCommand(command.Name, args)
        else
            self:RunCommand(command.Name, table_unpack(args))
        end
        return true
    end

    local function RunSelected(keepPalette)
        local command = Matches[Selected]
        if not command then return end
        local args = ArgumentsFor(command, PaletteInput())
        if (command.Kind == "Feature" and command.FeatureKind ~= "Toggle" and command.FeatureKind ~= "Button" or command._CustomDropdown) and #args == 0 then
            PaletteState.Search.Text = command.Name .. " "
            if not Library.Mobile then PaletteState.Search:CaptureFocus() end
            Library:Notify("Enter a value, then select this item.")
            return
        end
        if command.FeatureKind == "Dropdown" and command.FeatureEntry and command.FeatureEntry.Control and #args > 0 then
            local control = command.FeatureEntry.Control
            local found, reason = ResolvePaletteOptions(control, table_concat(args, " "))
            if not found then Library:Notify(reason); return end
        end
        if command.Arguments and not command.OptionalArguments and #args < #command.Arguments then
            PaletteState.Search.Text = command.Name .. " "
            if not Library.Mobile then PaletteState.Search:CaptureFocus() end
            Library:Notify("Enter: " .. table_concat(command.Arguments, ", "))
            return
        end
        local entry = command.FeatureEntry
        if command.FeatureKind == "Button" and entry and entry.Control and entry.Control.DoubleClick then
            if entry.Control.Locked or not Library.Window or activeDialogue then return end
            for category, locked in pairs(Library._PaletteLocks) do
                if locked and (entry.Category == category or entry.Category:sub(1,#category + 3) == category .. " / ") then return end
            end
            Library:CloseCommandPalette()
            local decided = false
            Library.Window:AddDialogue({
                Title = "Are you sure?", Content = "Confirm " .. entry.Name .. "?", Icon = "triangle-alert", ConfirmOnEnter = true,
                Buttons = {
                    {Name = "Cancel", Cancel = true, Callback = function(dialogue)
                        if decided then return end
                        decided = true
                        dialogue:Close()
                        task_delay(.25,function() dialogue:Destroy() end)
                    end},
                    {Name = "Confirm", Primary = true, Default = true, Callback = function(dialogue)
                        if decided then return end
                        decided = true
                        dialogue:Close()
                        task_delay(.25,function() dialogue:Destroy() end)
                        task_spawn(function()
                            if Library.Unloaded or entry.Control.Locked then return end
                            for category, locked in pairs(Library._PaletteLocks) do
                                if locked and (entry.Category == category or entry.Category:sub(1,#category + 3) == category .. " / ") then return end
                            end
                            entry.Control:Confirm()
                        end)
                    end},
                },
            })
            return
        end
        local keepOpen = command._CustomDropdown or command.FeatureKind == "Dropdown"
        if not keepOpen then Library:CloseCommandPalette() end
        if command.Arguments or command.Kind == "Feature" or command._LegacyArguments then
            Library:RunCommand(command.Name, args)
        else
            Library:RunCommand(command.Name, table_unpack(args))
        end
        if keepOpen then PaletteState.Search.Text = command.Name .. " " end
    end

    local function ActiveKeybindPath(command)
        if command.Kind ~= "Feature" or (command.FeatureKind ~= "Keybind" and command.FeatureKind ~= "Textbox") then return false end
        local query = PaletteInput():lower():match("^%s*(.-)%s*$") or ""
        local name = command.Name:lower()
        return query == name or query:sub(1, #name + 1) == name .. " "
    end

    local function PaletteViewKey(query)
        local parts = {tostring(PaletteState.PaletteRevision), query, tostring(Library.Theme)}
        for _, map in ipairs({PaletteState.ExpandedDropdowns, PaletteState.ExpandedColors, PaletteState.ExpandedSliders, PaletteState.ExpandedSteppers, PaletteState.FavoriteCommands}) do
            local keys = {}
            for key, value in pairs(map) do table_insert(keys, tostring(key) .. "=" .. tostring(value)) end
            table_sort(keys)
            table_insert(parts, table_concat(keys, "\1"))
        end
        return table_concat(parts, "\2")
    end
    local function StashPaletteView()
        if not PaletteState.CurrentPaletteView then return end
        PaletteState.CurrentPaletteView.matches = table_clone(Matches)
        PaletteState.CurrentPaletteView.rhythms = table_clone(RhythmRows)
        PaletteState.CurrentPaletteView.select = PaletteState.SelectPaletteRow
        for _, rhythm in ipairs(RhythmRows) do
            if rhythm.Container.Parent and RhythmDepot then rhythm.Container.Parent = RhythmDepot end
        end
        for _, child in ipairs(PaletteState.Results:GetChildren()) do
            if child:IsA("GuiObject") then child.Parent = PaletteState.CurrentPaletteView.folder end
        end
        PaletteState.CurrentPaletteView = nil
    end
    local function PrunePaletteViews()
        local CachedRows = 0
        for _, View in ipairs(PaletteState.PaletteViews) do
            CachedRows += View == PaletteState.CurrentPaletteView and #Matches or #(View.matches or {})
        end
        while #PaletteState.PaletteViews > MAX_PALETTE_VIEWS or CachedRows > MAX_CACHED_PALETTE_ROWS and #PaletteState.PaletteViews > 1 do
            local oldest
            for i, View in ipairs(PaletteState.PaletteViews) do
                if View ~= PaletteState.CurrentPaletteView then
                    local Previous = oldest and PaletteState.PaletteViews[oldest]
                    if not Previous or (Previous.query == "" and View.query ~= "") or (Previous.query == View.query and View.serial < Previous.serial) then oldest = i end
                end
            end
            if not oldest then break end
            local removed = table_remove(PaletteState.PaletteViews, oldest)
            CachedRows -= #(removed.matches or {})
            removed.folder:Destroy()
            table_clear(removed.updaters or {})
            table_clear(removed.editorRefreshers or {})
        end
    end
    local function SyncSingleResultScroll()
        if not PaletteState.Results or not PaletteState.Results.Parent or PaletteState.CurrentPaletteView ~= PaletteState.PendingSingleScrollView or #Matches ~= 1 or PaletteState.PendingSearch then return end
        local command = Matches[1]
        if command.FeatureKind == "Dropdown" or command.FeatureKind == "Color" or command.FeatureKind == "Stepper" or command._CustomDropdown then
            PaletteState.Results.CanvasPosition = Vector2_zero
            PaletteState.PendingSingleScrollView = nil
            return
        end
        if PaletteState.Results:FindFirstChild("DropdownOptions") or PaletteState.Results:FindFirstChild("PaletteColorPicker") or PaletteState.Results:FindFirstChild("PaletteSlider") or PaletteState.Results:FindFirstChild("PaletteStepper") then
            PaletteState.PendingSingleScrollView = nil
            return
        end
        local bottom = math_max(0, PaletteState.Results.AbsoluteCanvasSize.Y - PaletteState.Results.AbsoluteWindowSize.Y)
        if math_abs(bottom - PaletteState.Results.CanvasPosition.Y) > .5 then
            PaletteState.Results.CanvasPosition = Vector2_new(PaletteState.Results.CanvasPosition.X, bottom)
        end
    end
    local function FinishPaletteResults(previousScroll, previousSingleName)
        local renderedView = PaletteState.CurrentPaletteView
        task_defer(function()
            if Library.Unloaded or not PaletteState.Results or not PaletteState.Results.Parent or PaletteState.CurrentPaletteView ~= renderedView then return end
            local single = #Matches == 1 and Matches[1] or nil
            local singleName = single and single.Name or nil
            PaletteState.PendingSingleScrollView = single and renderedView or nil
            if previousSingleName == singleName then
                PaletteState.Results.CanvasPosition = previousScroll
            else
                PaletteState.Results.CanvasPosition = Vector2_zero
            end
            SyncSingleResultScroll()
            if PaletteState.ResizePalette then PaletteState.ResizePalette() end
        end)
    end
    function Library:UpdatePaletteValue(entry)
        if not entry then return false end
        
        if entry.Kind == "Toggle" then
            for _, view in ipairs(PaletteState.PaletteViews) do
                local update = view.updaters and view.updaters[entry]
                if update then update() end
            end
            local query = PaletteInput():lower():match("^%s*(.-)%s*$") or ""
            if query == "true" or query == "false" then return false end
            return true
        end
        
        self._PaletteDirty = true
        if not PaletteState.Palette or not PaletteState.Palette.Visible or not PaletteState.CurrentPaletteView then return true end
        local update = PaletteState.CurrentPaletteView.updaters and PaletteState.CurrentPaletteView.updaters[entry]
        if update then update() end
        return true
    end
    function Library:RefreshPaletteToggle(commandName)
        local command = PaletteState.Commands[type(commandName) == "string" and commandName:lower() or ""]
        if command and command.FeatureKind == "Toggle" and command.FeatureEntry then
            return self:UpdatePaletteValue(command.FeatureEntry)
        end
        return false
    end
    function Library:RefreshCommandPalette()
        if not PaletteState.Results then return end
        if self._PaletteDirty then PaletteState.PaletteRevision += 1 end
        self._PaletteDirty = false
        local queryText = PaletteInput()
        local key = PaletteViewKey(queryText)
        PaletteState.PaletteRenderedQuery = queryText
        local previousScroll = PaletteState.Results.CanvasPosition
        local previousSingleName = #Matches == 1 and Matches[1].Name or nil
        StashPaletteView()
        table_clear(RhythmRows)
        table_clear(Matches)
        for _, view in ipairs(PaletteState.PaletteViews) do
            if view.key == key then
                PaletteState.ViewSerial += 1; view.serial = PaletteState.ViewSerial
                PaletteState.CurrentPaletteView = view
                for _, child in ipairs(view.folder:GetChildren()) do child.Parent = PaletteState.Results end
                for _, command in ipairs(view.matches) do table_insert(Matches, command) end
                for _, rhythm in ipairs(view.rhythms) do
                    local target = view.rhythmTargets and view.rhythmTargets[rhythm.CommandName]
                    if target and target.Parent then rhythm.Container.Parent = target end
                    table_insert(RhythmRows, rhythm)
                end
                PaletteState.SelectPaletteRow = view.select
                Selected = math_clamp(Selected, 1, math_max(1, #Matches))
                PaletteState.EmptyLabel.Visible = #Matches == 0
                if PaletteState.SelectPaletteRow then PaletteState.SelectPaletteRow() end
                FinishPaletteResults(previousScroll, previousSingleName)
                return
            end
        end
        PaletteState.ViewSerial += 1
        PaletteState.CurrentPaletteView = {key = key, query = queryText, serial = PaletteState.ViewSerial, updaters = {}, editorRefreshers = {}, rhythmTargets = {}, folder = Make("Folder", {Name = "CachedPaletteView", Parent = PaletteState.PaletteViewStore})}
        table_insert(PaletteState.PaletteViews, PaletteState.CurrentPaletteView)
        PrunePaletteViews()
        local query = PaletteInput():match("^%s*(.-)%s*$") or ""
        local Groups, GroupOrder = {}, {}
        for _, command in ipairs(self:SearchCommands(query)) do
            local category = PaletteState.FavoriteCommands[command.Name] and "Favorites" or (command.Category or "Commands")
            if not Groups[category] then Groups[category] = {}; table_insert(GroupOrder, category) end
            table_insert(Groups[category], command)
        end
        if Groups.Favorites then for i, category in ipairs(GroupOrder) do if category == "Favorites" then table_remove(GroupOrder, i); break end end; table_insert(GroupOrder, 1, "Favorites") end
        local displayCategories = {}
        for _, category in ipairs(GroupOrder) do
            for _, command in ipairs(Groups[category]) do table_insert(Matches, command); table_insert(displayCategories, category) end
        end
        Selected = math_clamp(Selected, 1, math_max(1, #Matches))
        PaletteState.EmptyLabel.Visible = #Matches == 0
        local rows, visualStates, records, headers = {}, {}, {}, {}
        local UpdateFavoriteLayout
        local function RefreshSelection()
            for index, item in ipairs(rows) do
                local cmd = Matches[index]
                local prefix = cmd.Name .. " "
                local opened = ((cmd.FeatureKind == "Dropdown" or cmd._CustomDropdown) and PaletteState.ExpandedDropdowns[cmd.Name] ~= false or cmd.FeatureKind == "Color" and PaletteState.ExpandedColors[cmd.Name] ~= false or cmd.FeatureKind == "Slider" and PaletteState.ExpandedSliders[cmd.Name] ~= false or cmd.FeatureKind == "Stepper" and PaletteState.ExpandedSteppers[cmd.Name] ~= false) and (IsEditorQuery(cmd, PaletteInput()) or PaletteState.Search.Text:lower():sub(1, #prefix) == prefix:lower() or #Matches == 1 and (cmd.FeatureKind == "Slider" or cmd.FeatureKind == "Stepper"))
                local active = index == Selected or PaletteState.FavoriteCommands[cmd.Name] == true or opened or ActiveKeybindPath(cmd)
                if visualStates[item] == active then continue end
                visualStates[item] = active
                Tween(item, FastTween, {BackgroundColor3 = active and ThemeColor(25,25,25):Lerp(ThemeColor(60,200,100), 0.13) or ThemeColor(25,25,25)})
                local outline = item:FindFirstChild("RowOutline")
                if outline then Tween(outline, FastTween, {Color = active and ThemeColor(60,200,100) or ThemeColor(60,60,60), Transparency = active and 0.3 or 0.55}) end
                local marker = item:FindFirstChild("SelectionAccent")
                if marker then marker.Visible = active end
                local icon = item:FindFirstChild("CommandIcon")
                if icon then Tween(icon, FastTween, {ImageColor3 = active and ThemeColor(60,200,100) or ThemeColor(200,200,200)}) end
                local hintRow = item:FindFirstChild("ArgumentHints")
                if hintRow then
                    for _, hint in ipairs(hintRow:GetChildren()) do
                        if hint.Name == "ArgumentHint" then
                            Tween(hint, FastTween, {BackgroundColor3 = active and ThemeColor(45,45,45):Lerp(ThemeColor(60,200,100), 0.10) or ThemeColor(45,45,45)})
                        end
                    end
                end
            end
        end
        local function SectionHeader(category)
            if not headers[category] then
                headers[category] = Make("TextLabel", {Name = "CommandSection", BackgroundTransparency = 1, Size = UDim2_new(1, -4, 0, 24), Text = category, TextColor3 = ThemeColor(200,200,200), TextSize = 13, FontFace = SemiBoldFont, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 103, Parent = PaletteState.Results})
            end
            return headers[category]
        end
        local lastCategory, layoutOrder = nil, 0
        for index, command in ipairs(Matches) do
            if displayCategories[index] ~= lastCategory then
                lastCategory = displayCategories[index]
                layoutOrder += 1
                SectionHeader(lastCategory or "Commands").LayoutOrder = layoutOrder
            end
            layoutOrder += 1
            local displayDescription, RhythmState = VisualCommandDescription(command)
            local title = command.Kind == "Feature" and (command.Name:match("([^/]+)$") or command.Name):match("^%s*(.-)%s*$") or command.Name
            local hints = {}
            local customTag = command.Tag or command.Label
            if type(customTag) == "string" and customTag ~= "" then
                table_insert(hints, customTag)
            elseif command.Kind ~= "Feature" and type(command.Type) == "string" and command.Type ~= "Button" then
                local typeTags = {Toggle = "Toggle", Slider = "Value", Stepper = "Value", Dropdown = "Option", Textbox = "Input", Input = "Input", Keybind = "Key", Color = "Color"}
                table_insert(hints, typeTags[command.Type] or command.Type)
            elseif command.Arguments and #command.Arguments > 0 then
                if command.Kind == "Feature" and command.FeatureKind == "Toggle" then
                    table_insert(hints, "Toggle")
                elseif command.Kind == "Feature" then
                    local examples = {Slider = "Value", Stepper = "Value", Dropdown = command.FeatureEntry and command.FeatureEntry.Control and command.FeatureEntry.Control.Multi and "Options" or "Option", Textbox = "Input", Keybind = "Key", Color = "Color"}
                    table_insert(hints, examples[command.FeatureKind] or "Value")
                else
                    for _, argument in ipairs(command.Arguments) do table_insert(hints, tostring(argument)) end
                end
            end
            local hasHints = #hints > 0
            local titleBounds = GetTextBounds(title, MediumFont, 15, 220)
            local availableTitle = math_max(40, math_min(220, (PaletteState.PaletteBox.AbsoluteSize.X > 0 and PaletteState.PaletteBox.AbsoluteSize.X or 300) - 210))
            local titleWidth = math_clamp((titleBounds and titleBounds.X or 90) + 2, 40, availableTitle)
            local prefixForRow = command.Name .. " "
            local rowOpen = ((command.FeatureKind == "Dropdown" or command._CustomDropdown) and PaletteState.ExpandedDropdowns[command.Name] ~= false or command.FeatureKind == "Color" and PaletteState.ExpandedColors[command.Name] ~= false or command.FeatureKind == "Slider" and PaletteState.ExpandedSliders[command.Name] ~= false or command.FeatureKind == "Stepper" and PaletteState.ExpandedSteppers[command.Name] ~= false) and (IsEditorQuery(command, PaletteInput()) or PaletteState.Search.Text:lower():sub(1,#prefixForRow) == prefixForRow:lower() or #Matches == 1 and (command.FeatureKind == "Slider" or command.FeatureKind == "Stepper"))
            local rowActive = index == Selected or PaletteState.FavoriteCommands[command.Name] == true or rowOpen or ActiveKeybindPath(command)
            local rowHeight = displayDescription ~= "" and 56 or 42
            local item = Make("TextButton", {
                Name = "Command", AutoButtonColor = false,
                Size = UDim2_new(1, -4, 0, rowHeight), LayoutOrder = layoutOrder,
                BackgroundColor3 = rowActive and ThemeColor(25,25,25):Lerp(ThemeColor(60,200,100), 0.13) or ThemeColor(25,25,25),
                Text = "", ZIndex = 103, Parent = PaletteState.Results,
            })
            Corner(item, 8)
            Make("UIStroke", {Name = "RowOutline", ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = rowActive and ThemeColor(60,200,100) or ThemeColor(60,60,60), Transparency = rowActive and 0.3 or 0.55, Parent = item})
            rows[index] = item
            visualStates[item] = rowActive
            local record = {command = command, item = item, editors = {}}
            table_insert(records, record)
            local marker = Make("Frame", {Name = "SelectionAccent", BorderSizePixel = 0,
                BackgroundColor3 = ThemeColor(60,200,100), Position = UDim2_fromOffset(0, 7),
                Size = UDim2_new(0, 3, 1, -14), Visible = rowActive, ZIndex = 104, Parent = item})
            Corner(marker, 2)
            local commandIcon = Make("ImageLabel", {Name = "CommandIcon", BackgroundTransparency = 1, Image = "", ImageColor3 = rowActive and ThemeColor(60,200,100) or ThemeColor(200,200,200), Position = UDim2_fromOffset(14, 9), Size = UDim2_fromOffset(18, 18), ScaleType = Enum.ScaleType.Fit, ZIndex = 104, Parent = item})
            local featureIcons = {Toggle = "toggle-left", Slider = "settings-2", Stepper = "trending-up", Dropdown = "list", Button = "mouse-pointer-click", Textbox = "pencil", Input = "pencil", Keybind = "keyboard", Color = "palette"}
            local visualType = command.FeatureKind or command.Type
            local iconName = command.Icon or featureIcons[visualType] or (command.Kind == "Feature" and "sliders-horizontal" or (command.Builtin and "file-terminal" or "terminal"))
            if not command.Icon and visualType == "Toggle" and type(command.ValueText) == "function" then
                local getter = command.FeatureEntry and command.FeatureEntry.GetValue or command.ValueText
                local ok, value = pcall(getter)
                if ok and (value == true or value == "true" or value == "On") then iconName = "toggle-right" end
            end
            Library:ApplyIcon(commandIcon, Library:GetIcon(iconName) or Library:GetIcon("terminal"))
            Make("TextLabel", {
                Name = "CommandTitle", BackgroundTransparency = 1, Position = UDim2_fromOffset(43, 5),
                Size = UDim2_fromOffset(titleWidth, 24), Text = title, TextColor3 = ThemeColor(255,255,255), TextSize = 15,
                TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
                FontFace = MediumFont, ZIndex = 104, Parent = item,
            })
            local arrow = Make("ImageLabel", {BackgroundTransparency = 1, Image = "", ImageColor3 = ThemeColor(200,200,200), ImageTransparency = 0.25, AnchorPoint = Vector2_new(1,0), Position = UDim2_new(1,-10,0,12), Size = UDim2_fromOffset(16,16), ZIndex = 104, Parent = item})
            Library:ApplyIcon(arrow, Library:GetIcon((command.FeatureKind == "Dropdown" or command._CustomDropdown or command.FeatureKind == "Color" or command.FeatureKind == "Slider" or command.FeatureKind == "Stepper") and (rowOpen and "chevron-up" or "chevron-down") or "chevron-right"))
            local star = Make("ImageButton", {Name = "Favorite", BackgroundTransparency = 1, AutoButtonColor = false, AnchorPoint = Vector2_new(1,0), Position = UDim2_new(1,-31,0,11), Size = UDim2_fromOffset(17,17), Image = "", ImageColor3 = PaletteState.FavoriteCommands[command.Name] and ThemeColor(60,200,100) or ThemeColor(140,140,140), ZIndex = 106, Parent = item})
            Library:ApplyIcon(star, Library:GetIcon(PaletteState.FavoriteCommands[command.Name] and "star" or "star"))
            star.Activated:Connect(function()
                PaletteState.FavoriteCommands[command.Name] = not PaletteState.FavoriteCommands[command.Name] or nil
                star.ImageColor3 = PaletteState.FavoriteCommands[command.Name] and ThemeColor(60,200,100) or ThemeColor(140,140,140)
                QueueFavoriteSave()
                if UpdateFavoriteLayout then UpdateFavoriteLayout() end
            end)
            if RhythmState ~= nil then
                local rhythm = RhythmCache[command.Name]
                if not rhythm then
                    local meter = Make("Frame", {Name = "ToggleRhythm", BackgroundTransparency = 1, Position = UDim2_fromOffset(43, 30), Size = UDim2_fromOffset(66, 17), ZIndex = 104, Parent = item})
                    Make("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim_new(0, 3), Parent = meter})
                    rhythm = {CommandName = command.Name, Container = meter, Active = RhythmState, Seed = RhythmRandom:NextNumber(0, 1000), Bars = {}, Glows = {}}
                    RhythmCache[command.Name] = rhythm
                    local color = RhythmState and Color3_fromRGB(53, 254, 106) or Color3_fromRGB(150, 150, 150)
                    for i = 1, 13 do
                        local bar = Make("Frame", {Name = "Bar", BorderSizePixel = 0, BackgroundColor3 = color, Size = UDim2_fromOffset(2, RhythmState and RhythmRandom:NextInteger(4, 15) or 4), LayoutOrder = i, ZIndex = 106, Parent = meter})
                        bar:SetAttribute("ThemeColorIgnore", true)
                        Corner(bar, 1)
                        local glow = Make("ImageLabel", {
                            Name = "RhythmGlow", BackgroundTransparency = 1,
                            Image = "rbxasset://textures/ui/InGameMenu/BackgroundGlow.png", ImageColor3 = color,
                            ImageTransparency = .28, Visible = RhythmState, AnchorPoint = Vector2_new(.5, .5), Position = UDim2_fromScale(.5, .5),
                            Size = UDim2_new(1, 18, 1, 16), ZIndex = 105, Parent = bar,
                        })
                        glow:SetAttribute("ThemeColorIgnore", true)
                        table_insert(rhythm.Bars, bar)
                        table_insert(rhythm.Glows, glow)
                    end
                else
                    rhythm.Container.Parent = item
                end
                PaletteState.CurrentPaletteView.rhythmTargets[command.Name] = item
                local entry = command.FeatureEntry
                if entry then
                    local iconState = RhythmState
                    PaletteState.CurrentPaletteView.updaters[entry] = function()
                        if Library.Unloaded then return end
                        local ok, state = pcall(entry.GetValue)
                        if not ok or type(state) ~= "boolean" then return end
                        if iconState ~= state then
                            if not command.Icon then Library:ApplyIcon(commandIcon, Library:GetIcon(state and "toggle-right" or "toggle-left")) end
                            iconState = state
                        end
                        if rhythm.Active == state then return end
                        rhythm.Active = state
                        local nextColor = state and Color3_fromRGB(53, 254, 106) or Color3_fromRGB(150, 150, 150)
                        for i, bar in ipairs(rhythm.Bars) do
                            bar.BackgroundColor3 = nextColor
                            if not state then bar.Size = UDim2_fromOffset(2, 4) end
                            local glow = rhythm.Glows[i]
                            glow.Visible = state
                            glow.ImageColor3 = nextColor
                        end
                    end
                    PaletteState.CurrentPaletteView.updaters[entry]()
                end
                table_insert(RhythmRows, rhythm)
            elseif displayDescription ~= "" then
                Make("TextLabel", {
                    Name = "CommandDescription", BackgroundTransparency = 1, Position = UDim2_fromOffset(43, 29), RichText = command.FeatureKind == "Color",
                    Size = UDim2_new(1, -56, 0, 18), Text = displayDescription,
                    TextColor3 = ThemeColor(220,220,220), TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd, FontFace = RegularFont, ZIndex = 104, Parent = item,
                })
            end
            if command.FeatureEntry and RhythmState == nil then
                local entry, view = command.FeatureEntry, PaletteState.CurrentPaletteView
                view.updaters[entry] = function()
                    local description = item:FindFirstChild("CommandDescription")
                    if description then description.Text = command.FeatureKind == "Color" and ColorCommandDescription(command) or CommandDescription(command) end
                    local refreshEditor = view.editorRefreshers[entry]
                    if refreshEditor then refreshEditor() end
                end
            end
            if hasHints then
                local hintStart = 43 + titleWidth + 7
                local hintRow = Make("Frame", {Name = "ArgumentHints", BackgroundTransparency = 1, Position = UDim2_fromOffset(hintStart, 6), Size = UDim2_new(1,-hintStart-60,0,24), ClipsDescendants = true, ZIndex = 104, Parent = item})
                Make("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim_new(0, 5), Parent = hintRow})
                Make("UIPadding", {PaddingLeft = UDim_new(0, 2), PaddingTop = UDim_new(0, 2), Parent = hintRow})
                if command.Kind ~= "Feature" and not command._CustomDropdown then Make("TextLabel", {Name = "ArgumentCaption", LayoutOrder = 0, BackgroundTransparency = 1, Size = UDim2_fromOffset(58, 22), Text = command.OptionalArguments and "Optional:" or "Required:", TextColor3 = ThemeColor(200,200,200), TextSize = 11, FontFace = MediumFont, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 105, Parent = hintRow}) end
                for hintIndex, hintText in ipairs(hints) do
                    local hintBounds = GetTextBounds(hintText, RegularFont, 12, 220)
                    local width = math_clamp((hintBounds and hintBounds.X or 48) + 18, 42, 220)
                    local hint = Make("TextLabel", {Name = "ArgumentHint", LayoutOrder = hintIndex, Size = UDim2_fromOffset(width, 20), BackgroundColor3 = rowActive and ThemeColor(45,45,45):Lerp(ThemeColor(60,200,100), 0.10) or ThemeColor(45,45,45), Text = hintText, TextColor3 = ThemeColor(200,200,200), TextSize = 11, TextTruncate = Enum.TextTruncate.AtEnd, FontFace = RegularFont, ZIndex = 105, Parent = hintRow})
                    Corner(hint, 4)
                    Make("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = ThemeColor(80,80,80), Transparency = 0.25, Parent = hint})
                end
            end
            item.MouseEnter:Connect(function() Selected = table_find(Matches, command) or Selected; RefreshSelection() end)
            item.Activated:Connect(function()
                Selected = table_find(Matches, command) or Selected
                if (command.FeatureKind == "Dropdown" or command._CustomDropdown or command.FeatureKind == "Color" or command.FeatureKind == "Slider" or command.FeatureKind == "Stepper") and #ArgumentsFor(command, PaletteState.Search.Text) == 0 then
                    local prefix = command.Name .. " "
                    local expanded = command.FeatureKind == "Color" and PaletteState.ExpandedColors or command.FeatureKind == "Slider" and PaletteState.ExpandedSliders or command.FeatureKind == "Stepper" and PaletteState.ExpandedSteppers or PaletteState.ExpandedDropdowns
                    if not IsEditorQuery(command, PaletteInput()) and PaletteState.Search.Text:lower():sub(1,#prefix) ~= prefix:lower() then
                        expanded[command.Name] = true; PaletteState.Search.Text = prefix
                    else expanded[command.Name] = expanded[command.Name] == false; Library:RefreshCommandPalette() end
                else RunSelected() end
            end)
            local entry = command.FeatureEntry
            local control = command._CustomDropdown and command or (entry and entry.Control)
            local prefix = command.Name .. " "
            if (command.FeatureKind == "Dropdown" or command._CustomDropdown) and control and PaletteState.ExpandedDropdowns[command.Name] ~= false and (IsEditorQuery(command, PaletteInput()) or PaletteState.Search.Text:lower():sub(1, #prefix) == prefix:lower()) then
                local filter = IsEditorQuery(command, PaletteInput()) and "" or (PaletteState.Search.Text:sub(#prefix + 1):lower():match("^%s*(.-)%s*$") or "")
                local options = {}
                for key, value in ipairs(control.Values or {}) do table_insert(options, value) end
                if #options == 0 then for key in pairs(control.Values or {}) do table_insert(options, key) end; table_sort(options, function(a,b) return tostring(a):lower() < tostring(b):lower() end) end
                local choiceRows = {}
                local function UpdateChoices()
                    for _, row in ipairs(choiceRows) do
                        local chosen = control.Multi and type(control.Value) == "table" and control.Value[row.Value] == true or (not control.Multi and control.Value == row.Value)
                        row.Button.TextColor3 = chosen and ThemeColor(255,255,255) or ThemeColor(140,140,140)
                        row.Check.Visible = chosen
                        local left = 6 + (chosen and 20 or 0) + (row.HasImage and 24 or 0)
                        row.Padding.PaddingLeft = UDim_new(0,left)
                        row.Check.Position = UDim2_new(0,6-left,0.5,-8)
                        row.ValueImage.Position = UDim2_new(0,(chosen and 28 or 6)-left,0.5,-8)
                        row.ImageSeparator.Position = UDim2_new(0,24-left,0.5,-8)
                        row.ImageSeparator.Visible = chosen and row.HasImage
                        row.Divider.Position = UDim2_new(0,-left,1,-1)
                        row.Divider.Size = UDim2_new(1,left,0,1)
                    end
                    local description = item:FindFirstChild("CommandDescription")
                    if description then description.Text = CommandDescription(command) end
                end
                local function MutateChoice(fn)
                    if control.Locked then return end
                    local previous = Library._PaletteBatch
                    Library._PaletteBatch = true
                    local ok, err = pcall(fn)
                    Library._PaletteBatch = previous
                    if not ok then warn("[Library] Dropdown: " .. tostring(err)) end
                    UpdateChoices()
                end
                layoutOrder += 1
                local optionList = Make("Frame", {Name = "DropdownOptions", LayoutOrder = layoutOrder, Size = UDim2_new(1,-4,0,30), BackgroundColor3 = ThemeColor(25,25,25), ZIndex = 103, Parent = PaletteState.Results})
                table_insert(record.editors, optionList)
                Corner(optionList, 6)
                Make("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = ThemeColor(60,60,60), Transparency = 0.3, Parent = optionList})
                Make("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Center, Padding = UDim_new(), Parent = optionList})
                Make("UIPadding", {PaddingTop = UDim_new(0, 3), PaddingBottom = UDim_new(0, 2), Parent = optionList})
                local optionSearch = Make("TextBox", {Name = "DropdownSearch", LayoutOrder = 0, Size = UDim2_new(1,-12,0,30), BackgroundColor3 = ThemeColor(30,30,30), Text = "", PlaceholderText = "Search...", PlaceholderColor3 = ThemeColor(150, 150, 150), TextColor3 = ThemeColor(255,255,255), ClearTextOnFocus = false, TextSize = 12, FontFace = RegularFont, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 104, Parent = optionList})
                optionSearch.Visible = not command._CustomDropdown or command.Searchable
                Corner(optionSearch, 5)
                Make("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = ThemeColor(60,60,60), Parent = optionSearch})
                Make("UIPadding", {PaddingLeft = UDim_new(0, 28), Parent = optionSearch})
                local optionSearchIcon = Make("ImageLabel", {BackgroundTransparency = 1, Image = "", ImageColor3 = ThemeColor(140,140,140), Position = UDim2_fromOffset(-21, 7), Size = UDim2_fromOffset(16,16), ZIndex = 105, Parent = optionSearch})
                Library:ApplyIcon(optionSearchIcon, Library:GetIcon("search"))
                local hasSelectButtons = control.Multi and control.Selectable
                if hasSelectButtons then
                    local bar = Make("Frame", {Name = "SelectionButtons", LayoutOrder = 1, Size = UDim2_new(1,-12,0,36), BackgroundTransparency = 1, ZIndex = 104, Parent = optionList})
                    local function AddSelectionButton(label, x, selecting)
                        local button = Make("TextButton", {Name = label, BackgroundColor3 = ThemeColor(35,35,35), Position = UDim2_new(x,0,0,4), Size = UDim2_new(0.5,-3,0,26), Text = label, TextSize = 12, TextColor3 = ThemeColor(220,220,220), FontFace = RegularFont, ZIndex = 105, Parent = bar})
                        Corner(button, 5); local outline = Make("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = ThemeColor(60,60,60), Parent = button})
                        button.AutoButtonColor = false
                        button.MouseEnter:Connect(function() Tween(button, FastTween, {BackgroundColor3 = ThemeColor(50,50,50)}); Tween(outline, FastTween, {Color = ThemeColor(100,100,100)}) end)
                        button.MouseLeave:Connect(function() Tween(button, FastTween, {BackgroundColor3 = ThemeColor(35,35,35)}); Tween(outline, FastTween, {Color = ThemeColor(60,60,60)}) end)
                        button.Activated:Connect(function() MutateChoice(function()
                            if selecting and control.SelectAll then control:SelectAll()
                            elseif not selecting and control.DeselectAll then control:DeselectAll()
                            else
                                local Selected = {}
                                if selecting then for key,value in pairs(control.Values) do Selected[type(key) == "number" and value or key] = true end end
                                control:SetValue(Selected)
                            end
                        end) end)
                    end
                    AddSelectionButton("Select All", 0, true)
                    AddSelectionButton("Deselect All", 0.5, false)
                end
                local optionOrder = 0
                for _, option in ipairs(options) do
                    local name = tostring(option)
                    if filter == "" or name:lower():find(filter, 1, true) then
                        optionOrder += 1
                        local chosen = control.Multi and type(control.Value) == "table" and control.Value[option] == true or (not control.Multi and control.Value == option)
                        local choice = Make("TextButton", {Name = "DropdownChoice", AutoButtonColor = false, LayoutOrder = optionOrder + (hasSelectButtons and 1 or 0), Size = UDim2_new(1,0,0,30), BackgroundTransparency = 1, Text = name, TextColor3 = chosen and ThemeColor(255,255,255) or ThemeColor(140,140,140), TextSize = 12, FontFace = RegularFont, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 104, Parent = optionList})
                        local rawValue = control.Values and control.Values[option] or nil
                        local icon = ResolveValueImage(control.ValueImages, option, rawValue)
                        local leftPadding = 6 + (chosen and 20 or 0) + (icon and 24 or 0)
                        local padding = Make("UIPadding", {PaddingLeft = UDim_new(0, leftPadding), Parent = choice})
                        local check = Make("ImageLabel", {Name = "SelectionCheck", BackgroundTransparency = 1, Image = "", ImageColor3 = Color3_new(1,1,1), Position = UDim2_new(0,6-leftPadding,0.5,-8), Size = UDim2_fromOffset(16,16), Visible = chosen, ZIndex = 105, Parent = choice})
                        Library:ApplyIcon(check, Library:GetIcon("check"))
                        local valueImage = Make("ImageLabel", {Name = "ValueImage", BackgroundTransparency = 1, Image = "", ImageColor3 = Color3_new(1,1,1), Position = UDim2_new(0,(chosen and 28 or 6)-leftPadding,0.5,-8), Size = UDim2_fromOffset(16,16), Visible = icon ~= nil, ZIndex = 105, Parent = choice})
                        valueImage:SetAttribute("ThemeColorIgnore", true)
                        if icon then Library:ApplyIcon(valueImage, icon); valueImage.ImageColor3 = Color3_new(1,1,1) end
                        local imageSeparator = Make("Frame", {Name = "ImageSeparator", BackgroundColor3 = Color3_new(1,1,1), BackgroundTransparency = 0.35, BorderSizePixel = 0, Position = UDim2_new(0,24-leftPadding,0.5,-8), Size = UDim2_fromOffset(1,16), Visible = chosen and icon ~= nil, ZIndex = 105, Parent = choice})
                        imageSeparator:SetAttribute("ThemeColorIgnore", true)
                        local divider = Make("Frame", {Name = "Divider", BackgroundColor3 = ThemeColor(50,50,50), BackgroundTransparency = 0.4, Position = UDim2_new(0,-leftPadding,1,-1), Size = UDim2_new(1,leftPadding,0,1), ZIndex = 105, Parent = choice})
                        table_insert(choiceRows, {Button = choice, Name = name:lower(), Value = option, Check = check, Padding = padding, Divider = divider, ValueImage = valueImage, ImageSeparator = imageSeparator, HasImage = icon ~= nil})
                        choice.MouseEnter:Connect(function() Tween(choice, FastTween, {TextColor3 = choice.TextColor3:Lerp(Color3_new(1,1,1), 0.6)}) end)
                        choice.MouseLeave:Connect(UpdateChoices)
                        choice.Activated:Connect(function() MutateChoice(function()
                            if control.Multi then
                                local Selected = table_clone(control.Value or {})
                                Selected[option] = not Selected[option] or nil
                                control:SetValue(Selected)
                            else
                                control:SetValue(option)
                            end
                        end) end)
                    end
                end
                local noOptions = Make("TextLabel", {Name = "NoResults", LayoutOrder = 100000, Size = UDim2_new(1,0,0,30), BackgroundTransparency = 1, Text = "No results found", TextColor3 = ThemeColor(140,140,140), TextSize = 12, FontFace = RegularFont, Visible = false, ZIndex = 104, Parent = optionList})
                local function UpdateOptionFilter()
                    local term = optionSearch.Text:lower()
                    local count = 0
                    for _, row in ipairs(choiceRows) do row.Button.Visible = term == "" or row.Name:find(term, 1, true) ~= nil; if row.Button.Visible then count += 1 end end
                    noOptions.Visible = count == 0
                    optionList.Size = UDim2_new(1,-4,0,(optionSearch.Visible and 35 or 5) + (hasSelectButtons and 36 or 0) + math_max(1, count) * 30)
                end
                optionSearch:GetPropertyChangedSignal("Text"):Connect(UpdateOptionFilter)
                if entry then PaletteState.CurrentPaletteView.editorRefreshers[entry] = UpdateChoices end
                UpdateOptionFilter()
            end
            if command.FeatureKind == "Slider" and control and PaletteState.ExpandedSliders[command.Name] ~= false and (IsEditorQuery(command, PaletteInput()) or #Matches == 1) then
                layoutOrder += 1
                local editor = Make("TextButton", {Name="PaletteSlider", AutoButtonColor=false, Text="", LayoutOrder=layoutOrder, Size=UDim2_new(1,-4,0,44), BackgroundColor3=ThemeColor(25,25,25), ZIndex=103, Parent=PaletteState.Results})
                table_insert(record.editors, editor)
                Corner(editor,6)
                Make("UIStroke", {ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Color=ThemeColor(60,60,60),Parent=editor})
                local value = Make("TextLabel", {Name="SliderValue", AnchorPoint=Vector2_new(1,.5), Position=UDim2_new(1,-10,.5,0), Size=UDim2_fromOffset(76,20), BackgroundColor3=ThemeColor(35,35,35), Text="", TextColor3=ThemeColor(220,220,220), TextSize=12, FontFace=RegularFont, ZIndex=104, Parent=editor})
                Corner(value,8); Make("UIStroke", {ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Color=ThemeColor(60,60,60),Parent=value})
                local hitbox=Make("TextButton", {Name="SliderHitbox",AutoButtonColor=false,BackgroundTransparency=1,Position=UDim2_new(0,10,.5,-16),Size=UDim2_new(1,-104,0,32),Text="",ZIndex=104,Parent=editor})
                local bar=Make("TextButton", {Name="SliderBar",AutoButtonColor=false,BackgroundColor3=ThemeColor(60,60,60),Position=UDim2_new(0,10,.5,-3),Size=UDim2_new(1,-104,0,6),Text="",ZIndex=105,Parent=editor})
                Corner(bar,3)
                local fill=Make("Frame", {BackgroundColor3=ThemeColor(60,200,100),Size=UDim2_fromScale(0,1),ZIndex=105,Parent=bar})
                Corner(fill,3); Make("UIGradient", {Color=ColorSequence_new(Color3_fromRGB(235,235,235),Color3_new(1,1,1)),Rotation=0,Parent=fill})
                local knob=Make("Frame", {AnchorPoint=Vector2_new(.5,.5),Position=UDim2_fromScale(0,.5),Size=UDim2_fromOffset(12,12),BackgroundColor3=Color3_fromRGB(245,245,245),ZIndex=106,Parent=bar})
                knob:SetAttribute("ThemeColorIgnore",true); Corner(knob,6); Make("UIStroke", {Color=ThemeColor(60,200,100),Thickness=1.5,Parent=knob})
                local function UpdateSlider()
                    local ratio=control.Max==control.Min and 0 or math_clamp((control.Value-control.Min)/(control.Max-control.Min),0,1)
                    fill.Size=UDim2_fromScale(ratio,1); knob.Position=UDim2_fromScale(ratio,.5)
                    value.Text=tostring(control.Value)..(control.HideMax and "" or "/"..tostring(control.Max))
                    local description=item:FindFirstChild("CommandDescription")
                    if description then description.Text=CommandDescription(command) end
                end
                local drag
                local function SetFromInput(input)
                    if control.Locked then return end
                    local ratio=math_clamp((input.Position.X-bar.AbsolutePosition.X)/math_max(bar.AbsoluteSize.X,1),0,1)
                    local previous=Library._PaletteBatch; Library._PaletteBatch=true
                    local ok,err=pcall(control.Set,control,control.Min+(control.Max-control.Min)*ratio)
                    Library._PaletteBatch=previous
                    if not ok then warn("[Library] Palette slider: "..tostring(err)) end
                    UpdateSlider()
                end
                local function BeginDrag(input)
                    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then drag=input; SetFromInput(input) end
                end
                bar.InputBegan:Connect(BeginDrag)
                hitbox.InputBegan:Connect(BeginDrag)
                local changed=UserInputService.InputChanged:Connect(function(input)
                    if drag and (input==drag or drag.UserInputType==Enum.UserInputType.MouseButton1 and input.UserInputType==Enum.UserInputType.MouseMovement) then SetFromInput(input) end
                end)
                local ended=UserInputService.InputEnded:Connect(function(input) if drag and (input==drag or drag.UserInputType==Enum.UserInputType.MouseButton1 and input.UserInputType==Enum.UserInputType.MouseButton1) then drag=nil end end)
                editor.Destroying:Connect(function() changed:Disconnect(); ended:Disconnect() end)
                if entry then PaletteState.CurrentPaletteView.editorRefreshers[entry] = UpdateSlider end
                UpdateSlider()
            end
            if command.FeatureKind == "Stepper" and control and PaletteState.ExpandedSteppers[command.Name] ~= false and (IsEditorQuery(command, PaletteInput()) or #Matches == 1) then
                layoutOrder += 1
                local Editor = Make("Frame", {Name = "PaletteStepper", LayoutOrder = layoutOrder, Size = UDim2_new(1, -4, 0, 44), BackgroundColor3 = ThemeColor(25, 25, 25), ZIndex = 103, Parent = PaletteState.Results})
                table_insert(record.editors, Editor)
                Corner(Editor, 6)
                Make("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = ThemeColor(60, 60, 60), Parent = Editor})
                local Controls = Make("Frame", {Name = "StepperControls", BackgroundTransparency = 1, Position = UDim2_fromOffset(9, 7), Size = UDim2_new(1, -18, 0, 30), ZIndex = 104, Parent = Editor})
                Make("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim_new(0, 7), Parent = Controls})
                local Minus, Plus, MinusIcon, PlusIcon
                local function AddStepButton(Direction, IconName, Order)
                    local Button = Make("TextButton", {Name = Direction < 0 and "Decrease" or "Increase", AutoButtonColor = false, BackgroundColor3 = ThemeColor(35, 35, 35), Size = UDim2_fromOffset(30, 28), LayoutOrder = Order, Text = "", ZIndex = 105, Parent = Controls})
                    Corner(Button, 6)
                    Make("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = ThemeColor(75, 75, 75), Transparency = 0.18, Thickness = 1, Parent = Button})
                    local Icon = Make("ImageLabel", {BackgroundTransparency = 1, Image = "", ImageColor3 = ThemeColor(200, 200, 200), AnchorPoint = Vector2_new(0.5, 0.5), Position = UDim2_fromScale(0.5, 0.5), Size = UDim2_fromOffset(19, 19), ZIndex = 106, Parent = Button})
                    Library:ApplyIcon(Icon, Library:GetIcon(IconName))
                    Library._BindStepperHold(Button, control, Direction, function()
                        return PaletteState.Palette and PaletteState.Palette.Visible and not PaletteState.Palette:GetAttribute("Closing") and Button:IsDescendantOf(PaletteState.Results)
                    end)
                    Button.MouseEnter:Connect(function() if not control.Locked then Tween(Button, FastTween, {BackgroundColor3 = ThemeColor(50, 50, 50)}) end end)
                    Button.MouseLeave:Connect(function() Tween(Button, FastTween, {BackgroundColor3 = ThemeColor(35, 35, 35)}) end)
                    return Button, Icon
                end
                Minus, MinusIcon = AddStepButton(-1, "circle-minus", 1)
                local Value = Make("TextLabel", {Name = "StepperValue", Size = UDim2_new(1, -74, 0, 28), LayoutOrder = 2, BackgroundColor3 = ThemeColor(30, 30, 30), Text = control:DisplayValue(), TextColor3 = ThemeColor(220, 220, 220), TextSize = 13, FontFace = MediumFont, TextXAlignment = Enum.TextXAlignment.Center, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 105, Parent = Controls})
                Corner(Value, 5)
                Make("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = ThemeColor(60, 60, 60), Parent = Value})
                Plus, PlusIcon = AddStepButton(1, "circle-plus", 3)
                local function UpdateStepper()
                    Value.Text = control:DisplayValue()
                    local CanMinus = not control.Locked and control.Value > control.Min
                    local CanPlus = not control.Locked and control.Value < control.Max
                    Minus.Active = CanMinus
                    Plus.Active = CanPlus
                    MinusIcon.ImageColor3 = CanMinus and ThemeColor(200, 200, 200) or ThemeColor(90, 90, 90)
                    PlusIcon.ImageColor3 = CanPlus and ThemeColor(200, 200, 200) or ThemeColor(90, 90, 90)
                    local Description = item:FindFirstChild("CommandDescription")
                    if Description then Description.Text = CommandDescription(command) end
                end
                if entry then PaletteState.CurrentPaletteView.editorRefreshers[entry] = UpdateStepper end
                UpdateStepper()
            end
            if command.FeatureKind == "Color" and control and PaletteState.ExpandedColors[command.Name] ~= false and IsEditorQuery(command, PaletteInput()) then
                layoutOrder += 1
                local mapHeight = 160
                local bodyTop = mapHeight + 20
                local rainbowY = bodyTop + 68
                local transparencyY = rainbowY + (control.AllowRainbow and 32 or 0)
                local editorHeight = control.AllowTrans and transparencyY + 47 or rainbowY + (control.AllowRainbow and 32 or 8)
                local editor = Make("TextButton", {Name="PaletteColorPicker", AutoButtonColor=false, Text="", LayoutOrder=layoutOrder, Size=UDim2_new(1,-4,0,editorHeight), BackgroundColor3=ThemeColor(25,25,25), ZIndex=103, Parent=PaletteState.Results})
                table_insert(record.editors, editor)
                Corner(editor, 7)
                local glow = Make("UIStroke", {Name="ColorFrameGlow", ApplyStrokeMode=Enum.ApplyStrokeMode.Border, Color=ThemeColor(60,200,100), Transparency=0.48, Thickness=1.2, Parent=editor})
                Make("UIGradient", {Color=ColorSequence_new(Color3_new(1,1,1),Color3_fromRGB(115,115,115)), Rotation=45, Parent=glow})
                local h,s,v = control.Color:ToHSV()
                local shade = Make("ImageButton", {Name="ColorMap", AutoButtonColor=false, BackgroundColor3=Color3_fromHSV(h,1,1), Image="rbxassetid://4155801252", Position=UDim2_fromOffset(10,10), Size=UDim2_new(1,-42,0,mapHeight), ZIndex=104, Parent=editor})
                Corner(shade, 5)
                Make("UIStroke", {ApplyStrokeMode=Enum.ApplyStrokeMode.Border, Color=ThemeColor(60,60,60), Thickness=1, Parent=shade})
                local cursor = Make("Frame", {AnchorPoint=Vector2_new(.5,.5), BackgroundColor3=Color3_new(1,1,1), Size=UDim2_fromOffset(9,9), ZIndex=106, Parent=shade})
                Corner(cursor, 5); Make("UIStroke", {Color=Color3_new(0,0,0), Parent=cursor})
                local hue = Make("TextButton", {Name="Hue", AutoButtonColor=false, BackgroundColor3=Color3_new(1,1,1), AnchorPoint=Vector2_new(1,0), Position=UDim2_new(1,-10,0,10), Size=UDim2_fromOffset(15,mapHeight), Text="", ZIndex=104, Parent=editor})
                Corner(hue, 5); Make("UIGradient", {Color=ColorSequence_new(HueSequenceTable), Rotation=90, Parent=hue})
                local hueCursor = Make("Frame", {AnchorPoint=Vector2_new(.5,.5), Position=UDim2_new(.5,0,0,0), Size=UDim2_new(1,2,0,3), BackgroundColor3=Color3_new(1,1,1), ZIndex=106, Parent=hue})
                local hex = Make("TextBox", {Name="Hex", BackgroundColor3=ThemeColor(35,35,35), ClearTextOnFocus=false, Position=UDim2_fromOffset(10,bodyTop), Size=UDim2_new(1,-20,0,28), Text="", TextColor3=ThemeColor(220,220,220), TextSize=13, FontFace=RegularFont, ZIndex=104, Parent=editor})
                Corner(hex,5); Make("UIStroke", {ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Color=ThemeColor(60,60,60),Parent=hex})
                local function button(label, y, callback)
                    local index = label == "Copy" and 0 or 1
                    local x = UDim2_new(index / 2, 10 - index * 5, 0, bodyTop + 34)
                    local size = UDim2_new(.5,-15,0,27)
                    local b=Make("TextButton", {Name=label, AutoButtonColor=false, BackgroundColor3=ThemeColor(35,35,35), Position=x, Size=size, Text=label, TextSize=12, TextTruncate=Enum.TextTruncate.AtEnd, TextColor3=ThemeColor(220,220,220), FontFace=RegularFont, ZIndex=104, Parent=editor})
                    Corner(b,5); local outline=Make("UIStroke", {ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Color=ThemeColor(60,60,60),Parent=b})
                    b.MouseEnter:Connect(function() Tween(b,FastTween,{BackgroundColor3=ThemeColor(50,50,50)}); Tween(outline,FastTween,{Color=ThemeColor(100,100,100)}) end)
                    b.MouseLeave:Connect(function() Tween(b,FastTween,{BackgroundColor3=ThemeColor(35,35,35)}); Tween(outline,FastTween,{Color=ThemeColor(60,60,60)}) end)
                    b.Activated:Connect(callback); return b
                end
                local rainbowButton, rainbowSwitch, rainbowKnob, bar, fill, transparencyValue
                local function update()
                    if not editor.Parent then return end
                    h,s,v = control.Color:ToHSV()
                    local description = item:FindFirstChild("CommandDescription")
                    if description then description.Text = ColorCommandDescription(command) end
                    shade.BackgroundColor3=Color3_fromHSV(h,1,1); cursor.Position=UDim2_fromScale(s,1-v); hueCursor.Position=UDim2_fromScale(.5,h)
                    if not hex:IsFocused() then hex.Text="#"..control.Color:ToHex():upper() end
                    if rainbowSwitch then
                        rainbowSwitch.BackgroundColor3=control.Rainbow and ThemeColor(60,200,100) or ThemeColor(35,35,35)
                        rainbowKnob.BackgroundColor3=control.Rainbow and Color3_new(1,1,1) or ThemeColor(140,140,140)
                        rainbowKnob.Position=control.Rainbow and UDim2_new(1,-2,.5,0) or UDim2_new(0,2,.5,0)
                        rainbowKnob.AnchorPoint=control.Rainbow and Vector2_new(1,.5) or Vector2_new(0,.5)
                    end
                    if fill then fill.Size=UDim2_fromScale(control.Transparency,1) end
                    if transparencyValue then transparencyValue.Text=("%d%%"):format(math_floor(control.Transparency*100+.5)) end
                end
                local function batch(fn)
                    if control.Locked then return end
                    local old=Library._PaletteBatch
                    Library._PaletteBatch=true
                    local ok, err=pcall(fn)
                    Library._PaletteBatch=old
                    if not ok then warn("[Library] Palette color picker: " .. tostring(err)) end
                    update()
                end
                button("Copy", 77, function() local c=control.Color; PaletteState.PaletteClipboard=("%d, %d, %d"):format(math_floor(c.R*255+.5),math_floor(c.G*255+.5),math_floor(c.B*255+.5)); if type(setclipboard)=="function" then pcall(setclipboard,PaletteState.PaletteClipboard) end end)
                if control.AllowRainbow then
                    rainbowButton=Make("TextButton", {Name="Rainbow", AutoButtonColor=false, BackgroundTransparency=1, Position=UDim2_fromOffset(10,rainbowY), Size=UDim2_new(1,-20,0,27), Text="Rainbow", TextSize=12, TextColor3=ThemeColor(220,220,220), FontFace=RegularFont, TextXAlignment=Enum.TextXAlignment.Left, TextTruncate=Enum.TextTruncate.AtEnd, ZIndex=104, Parent=editor})
                    rainbowSwitch=Make("Frame", {AnchorPoint=Vector2_new(1,.5), Position=UDim2_fromScale(1,.5), Size=UDim2_fromOffset(32,16), BackgroundColor3=ThemeColor(35,35,35), ZIndex=105, Parent=rainbowButton})
                    Make("UIGradient", {Color=ColorSequence_new(Color3_new(1,1,1),Color3_fromRGB(190,190,190)),Rotation=90,Parent=rainbowSwitch})
                    Corner(rainbowSwitch,8); Make("UIStroke", {ApplyStrokeMode=Enum.ApplyStrokeMode.Border, Color=ThemeColor(60,60,60), Parent=rainbowSwitch})
                    rainbowKnob=Make("Frame", {AnchorPoint=Vector2_new(0,.5), Position=UDim2_new(0,2,.5,0), Size=UDim2_fromOffset(12,12), BackgroundColor3=ThemeColor(140,140,140), ZIndex=106, Parent=rainbowSwitch}); Corner(rainbowKnob,6)
                    rainbowButton.Activated:Connect(function() batch(function() control:SetRainbow(not control.Rainbow) end) end)
                end
                local function applyText(text)
                    local code=tostring(text):match("^%s*#?(%x%x%x%x%x%x)%s*$")
                    local r,g,b=tostring(text):match("^%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*$")
                    local color=code and Color3_fromHex(code) or (r and tonumber(r)<=255 and tonumber(g)<=255 and tonumber(b)<=255 and Color3_fromRGB(tonumber(r),tonumber(g),tonumber(b)))
                    if color then batch(function() control:SetRainbow(false); control:SetColor(color) end) end
                    update()
                end
                button("Paste", 109, function() applyText(PaletteState.PaletteClipboard or "") end)
                hex.FocusLost:Connect(function() applyText(hex.Text) end)
                if control.AllowTrans then
                    Make("TextLabel", {BackgroundTransparency=1, Position=UDim2_fromOffset(10,transparencyY), Size=UDim2_new(1,-20,0,20), Text="Transparency", TextColor3=ThemeColor(200,200,200), TextSize=12, FontFace=RegularFont, TextXAlignment=Enum.TextXAlignment.Left,ZIndex=104,Parent=editor})
                    transparencyValue=Make("TextLabel", {Name="TransparencyValue", AnchorPoint=Vector2_new(1,0), Position=UDim2_new(1,-10,0,transparencyY), Size=UDim2_fromOffset(42,20), BackgroundColor3=ThemeColor(35,35,35), Text="0%", TextColor3=ThemeColor(220,220,220), TextSize=11, FontFace=RegularFont, ZIndex=105, Parent=editor})
                    Corner(transparencyValue,5); Make("UIStroke", {ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Color=ThemeColor(60,60,60),Parent=transparencyValue})
                    bar=Make("TextButton", {Name="Transparency", AutoButtonColor=false, BackgroundColor3=ThemeColor(60,60,60), Position=UDim2_fromOffset(10,transparencyY+26), Size=UDim2_new(1,-20,0,6), Text="",ZIndex=104,Parent=editor})
                    Corner(bar,4); fill=Make("Frame",{BackgroundColor3=ThemeColor(60,200,100),Size=UDim2_fromScale(control.Transparency,1),ZIndex=105,Parent=bar});Corner(fill,4)
                    Make("UIGradient", {Color=ColorSequence_new(Color3_new(1,1,1),Color3_fromRGB(205,205,205)),Rotation=90,Parent=fill})
                    local knob=Make("Frame",{AnchorPoint=Vector2_new(.5,.5),Position=UDim2_fromScale(1,.5),Size=UDim2_fromOffset(12,12),BackgroundColor3=Color3_new(1,1,1),ZIndex=106,Parent=fill});Corner(knob,6); Make("UIStroke", {Color=ThemeColor(60,200,100),Parent=knob})
                end
                local dragging
                local function change(input)
                    if not dragging or control.Locked then return end
                    if control.Rainbow and (dragging == shade or dragging == hue) then dragging = nil; return end
                    if dragging == shade then s=math_clamp((input.Position.X-shade.AbsolutePosition.X)/math_max(shade.AbsoluteSize.X,1),0,1); v=1-math_clamp((input.Position.Y-shade.AbsolutePosition.Y)/math_max(shade.AbsoluteSize.Y,1),0,1)
                    elseif dragging == hue then h=math_clamp((input.Position.Y-hue.AbsolutePosition.Y)/math_max(hue.AbsoluteSize.Y,1),0,1)
                    else batch(function() control:SetTransparency(math_clamp((input.Position.X-bar.AbsolutePosition.X)/math_max(bar.AbsoluteSize.X,1),0,1)) end); fill.Size=UDim2_fromScale(control.Transparency,1); return end
                    batch(function() control:SetColor(Color3_fromHSV(h,s,v)) end)
                end
                for _, target in ipairs(bar and {shade,hue,bar} or {shade,hue}) do target.InputBegan:Connect(function(input) if control.Rainbow and (target == shade or target == hue) then return end; if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=target; change(input) end end) end
                local move=UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then change(input) end end)
                local ended=UserInputService.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=nil end end)
                local rain=RunService.Heartbeat:Connect(function() if PaletteState.Palette and PaletteState.Palette.Visible and editor:IsDescendantOf(PaletteState.Results) and control.Rainbow then update() end end)
                editor.Destroying:Connect(function() move:Disconnect(); ended:Disconnect(); rain:Disconnect() end)
                if entry then PaletteState.CurrentPaletteView.editorRefreshers[entry] = update end
                update()
            end
        end
        UpdateFavoriteLayout = function()
            local selectedCommand = Matches[Selected]
            local groups, order = {}, {}
            for _, record in ipairs(records) do
                local category = PaletteState.FavoriteCommands[record.command.Name] and "Favorites" or (record.command.Category or "Commands")
                if not groups[category] then groups[category] = {}; table_insert(order, category) end
                table_insert(groups[category], record)
            end
            if groups.Favorites then
                for i, category in ipairs(order) do if category == "Favorites" then table_remove(order, i); break end end
                table_insert(order, 1, "Favorites")
            end
            for _, header in pairs(headers) do header.Visible = false end
            table_clear(Matches); table_clear(rows)
            local orderIndex = 0
            for _, category in ipairs(order) do
                orderIndex += 1
                local header = SectionHeader(category)
                header.LayoutOrder = orderIndex; header.Visible = true
                for _, record in ipairs(groups[category]) do
                    orderIndex += 1; record.item.LayoutOrder = orderIndex
                    table_insert(Matches, record.command); table_insert(rows, record.item)
                    for _, editor in ipairs(record.editors) do orderIndex += 1; editor.LayoutOrder = orderIndex end
                end
            end
            Selected = table_find(Matches, selectedCommand) or 1
            if PaletteState.CurrentPaletteView then PaletteState.CurrentPaletteView.key = PaletteViewKey(PaletteInput()) end
            RefreshSelection()
        end
        PaletteState.SelectPaletteRow = RefreshSelection
        if PaletteState.CurrentPaletteView then PaletteState.CurrentPaletteView.matches = table_clone(Matches) end
        PrunePaletteViews()
        FinishPaletteResults(previousScroll, previousSingleName)
    end

    local function NumericPaletteControl()
        if not PaletteState.Palette or not PaletteState.Palette.Visible or PaletteState.Palette:GetAttribute("Closing") or not PaletteState.Results or PaletteState.PendingSearch then return end
        local Command = Matches[Selected]
        if not Command or (Command.FeatureKind ~= "Slider" and Command.FeatureKind ~= "Stepper") then return end
        local Entry = Command.FeatureEntry
        local Control = Entry and Entry.Control
        if not Control or Control.Locked then return end
        if Command.FeatureKind == "Slider" then
            if PaletteState.ExpandedSliders[Command.Name] == false or not PaletteState.Results:FindFirstChild("PaletteSlider") then return end
        elseif PaletteState.ExpandedSteppers[Command.Name] == false or not PaletteState.Results:FindFirstChild("PaletteStepper") then return end
        return Control, Command.FeatureKind
    end
    local NumericHoldToken = 0
    local NumericHeldCode
    local function ShiftHeld()
        return UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
    end
    local function StopNumericHold()
        NumericHoldToken += 1
        NumericHeldCode = nil
    end
    local function NumericPaletteShortcut(_, State, Input)
        local Code = Input.KeyCode
        if State == Enum.UserInputState.End or State == Enum.UserInputState.Cancel then
            if NumericHeldCode == Code then StopNumericHold() end
            return Enum.ContextActionResult.Pass
        end
        if State ~= Enum.UserInputState.Begin or not ShiftHeld() then return Enum.ContextActionResult.Pass end
        if NumericHeldCode == Code then return Enum.ContextActionResult.Sink end
        if PaletteState.PendingSearch and PaletteState.Palette and PaletteState.Palette.Visible then
            PaletteState.SearchGeneration += 1
            PaletteState.PendingSearch = false
            Library:RefreshCommandPalette()
        end
        local Control, Kind = NumericPaletteControl()
        if not Control then return Enum.ContextActionResult.Pass end
        StopNumericHold()
        NumericHeldCode = Code
        local Current = NumericHoldToken
        local Direction = (Code == Enum.KeyCode.Equals or Code == Enum.KeyCode.KeypadPlus) and 1 or -1
        local Increment = Kind == "Slider" and (Control.Increment and Control.Increment > 0 and Control.Increment or (Control.Rounding and Control.Rounding > 0 and 10 ^ -Control.Rounding or 1)) or nil
        local function Apply(Elapsed)
            if Kind == "Stepper" then
                Control:StepBy(Direction, Elapsed and Library._HoldMultiplier(Control, Elapsed) or 1)
            else
                Control:Set(Control.Value + Direction * Increment * (Elapsed and Library._HoldMultiplier(Control, Elapsed) or 1))
            end
        end
        Apply()
        task_spawn(function()
            task_wait(0.25)
            local Started = os_clock()
            while Current == NumericHoldToken and NumericHeldCode == Code and ShiftHeld() and not Library.Unloaded do
                local Active = NumericPaletteControl()
                if Active ~= Control then break end
                if (Kind == "Stepper" and (Direction > 0 and Control.Value >= Control.Max or Direction < 0 and Control.Value <= Control.Min)) or (Kind == "Slider" and (Direction > 0 and Control.Value >= Control.Max or Direction < 0 and Control.Value <= Control.Min)) then break end
                Apply(os_clock() - Started)
                task_wait(math_max(0.03, 0.10 - (os_clock() - Started) * 0.035))
            end
            if Current == NumericHoldToken then StopNumericHold() end
        end)
        return Enum.ContextActionResult.Sink
    end

    local function CreatePalette()
        PaletteState.Palette = Make("Frame", { Name = "CommandPaletteOverlay", BackgroundColor3 = Color3_new(0, 0, 0), BackgroundTransparency = 1,
            Size = UDim2_fromScale(1, 1), Visible = false, ZIndex = 100, Parent = UI })
        PaletteState.PaletteViewStore = Make("Frame", {Name = "PaletteViewCache", Visible = false, BackgroundTransparency = 1, Size = UDim2_fromOffset(0, 0), Parent = PaletteState.Palette})
        RhythmDepot = Make("Folder", {Name = "RhythmDepot", Parent = PaletteState.PaletteViewStore})
        local dismiss = Make("TextButton", { BackgroundTransparency = 1, Size = UDim2_fromScale(1, 1), Text = "", ZIndex = 100, Parent = PaletteState.Palette })
        dismiss.Activated:Connect(function()
            if not Library.Mobile then Library:CloseCommandPalette() end
        end)
        PaletteState.PaletteBox = Make("CanvasGroup", {Name = "CommandPalette", AnchorPoint = Vector2_new(0.5, 0), Position = UDim2_new(0.5, 0, 0.12, -10),
            Size = UDim2_new(1, -24, 0.7, 0), BackgroundColor3 = ThemeColor(25,25,25), GroupTransparency = 1, ZIndex = 101, Parent = PaletteState.Palette })
        AttachDPIScale(PaletteState.PaletteBox)
        Make("UISizeConstraint", { MaxSize = Vector2_new(500, 420), MinSize = Vector2_new(160, 120), Parent = PaletteState.PaletteBox })
        Corner(PaletteState.PaletteBox, 10)
        Make("UIGradient", {Color = ColorSequence_new(Color3_fromRGB(255,255,255), Color3_fromRGB(210,210,210)), Rotation = 90, Parent = PaletteState.PaletteBox})
        AddAnimatedBorder(PaletteState.PaletteBox)
        local header = Make("Frame", {BackgroundColor3 = ThemeColor(20,20,20), Size = UDim2_new(1, 0, 0, 42), ZIndex = 102, Parent = PaletteState.PaletteBox})
        Corner(header, 10)
        Make("Frame", {BackgroundColor3 = ThemeColor(20,20,20), Position = UDim2_new(0,0,1,-8), Size = UDim2_new(1,0,0,8), ZIndex = 102, Parent = header})
        local headerIcon = Make("ImageLabel", {BackgroundTransparency = 1, Image = "", ImageColor3 = ThemeColor(60,200,100), Position = UDim2_fromOffset(13, 12), Size = UDim2_fromOffset(18,18), ZIndex = 103, Parent = header})
        headerIcon:SetAttribute("ThemeAccentIcon", true)
        Library:ApplyIcon(headerIcon, Library:GetIcon("command"))
        Make("TextLabel", {BackgroundTransparency = 1, Position = UDim2_fromOffset(40,0), Size = UDim2_new(1,-82,1,0), Text = "Command Palette", TextColor3 = ThemeColor(255,255,255), TextSize = 16, FontFace = SemiBoldFont, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 103, Parent = header})
        local close = Make("ImageButton", {Name = "Close", AutoButtonColor = false, BackgroundTransparency = 1, AnchorPoint = Vector2_new(1,0.5), Position = UDim2_new(1,-12,0.5,0), Size = UDim2_fromOffset(18,18), Image = "", ImageTransparency = 0.25, ZIndex = 103, Parent = header})
        Library:ApplyIcon(close, Library:GetIcon("x"))
        close.Activated:Connect(function() Library:CloseCommandPalette() end)
        Make("Frame", {BackgroundColor3 = ThemeColor(80,80,80), BackgroundTransparency = 0.35, Position = UDim2_fromOffset(0,42), Size = UDim2_new(1,0,0,1), ZIndex = 102, Parent = PaletteState.PaletteBox})
        PaletteState.Search = Make("TextBox", { Name = "CommandSearch", BackgroundColor3 = ThemeColor(35,35,35), Position = UDim2_fromOffset(12, 53),
            Size = UDim2_new(1, -24, 0, 36), Text = "", PlaceholderText = "Search commands...",
            PlaceholderColor3 = ThemeColor(150, 150, 150), TextColor3 = ThemeColor(255,255,255), ClearTextOnFocus = false,
            TextSize = 15, FontFace = RegularFont, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 103, Parent = PaletteState.PaletteBox })
        Corner(PaletteState.Search, 7)
        Make("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = ThemeColor(60,60,60), Parent = PaletteState.Search})
        Make("UIPadding", { PaddingLeft = UDim_new(0, 34), PaddingRight = UDim_new(0, 10), Parent = PaletteState.Search })
        local searchIcon = Make("ImageLabel", {BackgroundTransparency = 1, Image = "", ImageColor3 = ThemeColor(200,200,200), Position = UDim2_fromOffset(21, 62), Size = UDim2_fromOffset(18,18), ZIndex = 104, Parent = PaletteState.PaletteBox})
        Library:ApplyIcon(searchIcon, Library:GetIcon("search"))
        PaletteState.Results = Make("ScrollingFrame", { BackgroundTransparency = 1, BorderSizePixel = 0,
            Position = UDim2_fromOffset(12, 99), Size = UDim2_new(1, -24, 1, -111),
            ScrollBarThickness = 3, ScrollBarImageColor3 = ThemeColor(80,80,80), CanvasSize = UDim2_new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollingDirection = Enum.ScrollingDirection.Y, ZIndex = 102, Parent = PaletteState.PaletteBox })
        local resultLayout = Make("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim_new(0, 5), Parent = PaletteState.Results })
        Make("UIPadding", {PaddingLeft = UDim_new(0, 3), PaddingRight = UDim_new(0, 3), PaddingTop = UDim_new(0, 2), PaddingBottom = UDim_new(0, 2), Parent = PaletteState.Results})
        local PreviousPaletteHeight
        PaletteState.ResizePalette = function()
            if Library.Unloaded or not PaletteState.PaletteBox or not PaletteState.PaletteBox.Parent or not PaletteState.Results or not PaletteState.Results.Parent then return end
            local camera = workspace.CurrentCamera
            local viewportHeight = camera and camera.ViewportSize.Y or 600
            local dpi = Library.MobileScale.Scale
            local maximum = math_max(140, math_min(420, viewportHeight * 0.72 / dpi))
            local contentHeight = #Matches == 0 and 40 or resultLayout.AbsoluteContentSize.Y / dpi
            local desired = math_clamp(contentHeight + (#Matches == 1 and 116 or 112), 150, maximum)
            if PreviousPaletteHeight == desired then
                SyncSingleResultScroll()
                PaletteState.PendingSingleScrollView = nil
                return
            end
            PreviousPaletteHeight = desired
            if PaletteState.PaletteResizeTween then PaletteState.PaletteResizeTween:Cancel() end
            PaletteState.PaletteResizeTween = TweenService:Create(PaletteState.PaletteBox, TweenInfo_new(0.035, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2_new(1, -24, 0, desired)})
            PaletteState.PaletteResizeTween.Completed:Once(function(state)
                if state ~= Enum.PlaybackState.Completed or Library.Unloaded then return end
                SyncSingleResultScroll()
                PaletteState.PendingSingleScrollView = nil
            end)
            PaletteState.PaletteResizeTween:Play()
        end
        resultLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(PaletteState.ResizePalette)
        ContextActionService:BindActionAtPriority(PaletteState.NumericShortcutName, NumericPaletteShortcut, false, 3000, Enum.KeyCode.Equals, Enum.KeyCode.Minus, Enum.KeyCode.KeypadPlus, Enum.KeyCode.KeypadMinus)
        PaletteState.EmptyLabel = Make("TextLabel", { BackgroundTransparency = 1, Position = UDim2_fromOffset(12, 108),
            Size = UDim2_new(1, -24, 0, 40), Text = "No matching commands", TextColor3 = ThemeColor(140,140,140),
            TextSize = 14, FontFace = RegularFont, Visible = false, ZIndex = 103, Parent = PaletteState.PaletteBox })
        local AcceptedSearch = PaletteState.Search.Text
        local RestoringSearch = false
        PaletteState.Search:GetPropertyChangedSignal("Text"):Connect(function()
            if RestoringSearch then return end
            if PaletteState.Search:IsFocused() and ShiftHeld() and PaletteState.Palette and PaletteState.Palette.Visible and not PaletteState.Palette:GetAttribute("Closing") then
                local Command = Matches[Selected]
                if Command and (Command.FeatureKind == "Stepper" or Command.FeatureKind == "Slider") then
                    if PaletteState.Search.Text ~= AcceptedSearch then
                        RestoringSearch = true
                        PaletteState.Search.Text = AcceptedSearch
                        RestoringSearch = false
                    end
                    return
                end
            end
            AcceptedSearch = PaletteState.Search.Text
            if PaletteState.OpeningCharacter and os_clock() <= PaletteState.OpeningCharacterDeadline and PaletteState.Search.Text:sub(1,1):lower() == PaletteState.OpeningCharacter:lower() then
                PaletteState.OpeningCharacter = nil
                PaletteState.Search.Text = PaletteState.Search.Text:sub(2)
                return
            end
            if PaletteState.IgnoredOpeningPrefix and PaletteState.Search.Text:sub(1,1) ~= PaletteState.IgnoredOpeningPrefix then PaletteState.IgnoredOpeningPrefix = nil end
            if PaletteState.Search.Text ~= "" then PaletteState.OpeningCharacter = nil end
            Selected = 1
            PaletteState.SearchGeneration += 1
            local generation = PaletteState.SearchGeneration
            PaletteState.PendingSearch = true
            task_delay(0.06, function()
                if generation ~= PaletteState.SearchGeneration or not PaletteState.PendingSearch or not PaletteState.Results or not PaletteState.Results.Parent then return end
                PaletteState.PendingSearch = false
                Library:RefreshCommandPalette()
            end)
        end)
        PaletteState.Search.FocusLost:Connect(function(enterPressed)
            if not enterPressed or not PaletteState.Palette.Visible or PaletteState.Palette:GetAttribute("Closing") or (activeDialogue and activeDialogue.Opened) then return end
            if PaletteState.PendingSearch then
                PaletteState.SearchGeneration += 1
                PaletteState.PendingSearch = false
                Library:RefreshCommandPalette()
            end
            if PaletteInput():match("%S") then
                local command = Matches[Selected]
                if command then
                    local args = ArgumentsFor(command, PaletteInput())
                    if #args > 0 then RunSelected()
                    elseif command.Kind == "Feature" and command.FeatureKind ~= "Toggle" and command.FeatureKind ~= "Button" then
                        if command.FeatureKind == "Color" then PaletteState.ExpandedColors[command.Name] = true elseif command.FeatureKind == "Slider" then PaletteState.ExpandedSliders[command.Name] = true elseif command.FeatureKind == "Stepper" then PaletteState.ExpandedSteppers[command.Name] = true else PaletteState.ExpandedDropdowns[command.Name] = true end
                        PaletteState.IgnoredOpeningPrefix = nil
                        PaletteState.Search.Text = command.Name .. " "
                        Library:RefreshCommandPalette()
                    else RunSelected() end
                else Library:CloseCommandPalette() end
                if PaletteState.Palette.Visible and not PaletteState.Palette:GetAttribute("Closing") and not Library.Mobile then task_defer(function() if PaletteState.Palette.Visible and PaletteState.Search.Parent then PaletteState.Search:CaptureFocus() end end) end
            else Library:CloseCommandPalette() end
        end)
    end

    function Library:OpenCommandPalette(openingInput)
        if self.Unloaded then return end
        if ActiveMenu then ActiveMenu:Close() end
        if not PaletteState.Palette then CreatePalette() end
        LoadFavorites()
        PaletteState.PaletteGeneration += 1
        if PaletteState.PaletteTween then PaletteState.PaletteTween:Cancel() end
        if PaletteState.OverlayTween then PaletteState.OverlayTween:Cancel() end
        PaletteState.Palette:SetAttribute("Closing", false)
        PaletteState.Palette.Visible = true
        Library._PaletteModalActive = true
        ModalElement.Visible = true
        Library._PaletteSnowActive = true
        if not PaletteState.PaletteBlur then PaletteState.PaletteBlur = Make("BlurEffect", {Name = "PaletteBlur", Size = 12, Parent = Lighting}) end
        PaletteState.PaletteBlur.Enabled = true
        PaletteState.OpeningCharacter = nil
        PaletteState.IgnoredOpeningPrefix = nil
        local hadSearch = PaletteState.Search.Text ~= ""
        if hadSearch then PaletteState.Search.Text = "" end
        if PaletteState.PendingSearch then
            PaletteState.SearchGeneration += 1
            PaletteState.PendingSearch = false
            self:RefreshCommandPalette()
        end
        if openingInput and openingInput.KeyCode and openingInput.KeyCode ~= Enum.KeyCode.Unknown then
            local ok, character = pcall(function() return UserInputService:GetStringForKeyCode(openingInput.KeyCode) end)
            if ok and type(character) == "string" and #character == 1 then
                PaletteState.OpeningCharacter = character
                PaletteState.OpeningCharacterDeadline = os_clock() + 0.35
            end
        end
        Selected = 1
        if not hadSearch and (PaletteState.PaletteRenderedQuery ~= "" or self._PaletteDirty) then self:RefreshCommandPalette()
        elseif PaletteState.SelectPaletteRow then PaletteState.SelectPaletteRow() end
        PaletteState.PaletteBox.GroupTransparency = 1
        PaletteState.PaletteBox.Position = UDim2_new(0.5,0,0.12,-6)
        PaletteState.PaletteTween = TweenService:Create(PaletteState.PaletteBox, TweenInfo_new(0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2_new(0.5,0,0.12,0), GroupTransparency = 0})
        PaletteState.OverlayTween = TweenService:Create(PaletteState.Palette, TweenInfo_new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
        PaletteState.PaletteTween:Play(); PaletteState.OverlayTween:Play()
        if not Library.Mobile then
            task_defer(function() if PaletteState.Palette and PaletteState.Palette.Visible and not PaletteState.Palette:GetAttribute("Closing") and PaletteState.Search.Parent then PaletteState.Search:CaptureFocus() end end)
        end
    end

    function Library:CloseCommandPalette()
        StopNumericHold()
        if not PaletteState.Palette or not PaletteState.Palette.Visible or PaletteState.Palette:GetAttribute("Closing") then return end
        PaletteState.PaletteGeneration += 1
        local generation = PaletteState.PaletteGeneration
        if PaletteState.PaletteTween then PaletteState.PaletteTween:Cancel() end
        if PaletteState.OverlayTween then PaletteState.OverlayTween:Cancel() end
        PaletteState.Palette:SetAttribute("Closing", true)
        Library._PaletteModalActive = false
        ModalElement.Visible = Library.Opened == true
        Library._PaletteSnowActive = false
        if PaletteState.PaletteBlur then PaletteState.PaletteBlur.Enabled = false end
        PaletteState.Search:ReleaseFocus(false)
        PaletteState.PaletteTween = TweenService:Create(PaletteState.PaletteBox, TweenInfo_new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2_new(0.5,0,0.12,-10), GroupTransparency = 1})
        PaletteState.OverlayTween = TweenService:Create(PaletteState.Palette, TweenInfo_new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1})
        PaletteState.PaletteTween.Completed:Connect(function(state)
            if generation ~= PaletteState.PaletteGeneration or state ~= Enum.PlaybackState.Completed then return end
            if PaletteState.Palette and PaletteState.Palette.Parent then PaletteState.Palette.Visible = false; PaletteState.Palette:SetAttribute("Closing", false) end
        end)
        PaletteState.PaletteTween:Play(); PaletteState.OverlayTween:Play()
    end

    Track(UserInputService.InputEnded:Connect(function(Input)
        if Input.KeyCode == NumericHeldCode or Input.KeyCode == Enum.KeyCode.LeftShift or Input.KeyCode == Enum.KeyCode.RightShift then
            StopNumericHold()
        end
    end))
    Track(UserInputService.InputBegan:Connect(function(input, processed)
        if Library.Unloaded or (activeDialogue and activeDialogue.Opened) then return end
        if PaletteState.Palette and PaletteState.Palette.Visible then
            local Code = input.KeyCode
            if (Code == Enum.KeyCode.Equals or Code == Enum.KeyCode.Minus or Code == Enum.KeyCode.KeypadPlus or Code == Enum.KeyCode.KeypadMinus) and ShiftHeld() then
                NumericPaletteShortcut(nil, Enum.UserInputState.Begin, input)
            end
            if input.KeyCode == Enum.KeyCode.Escape then Library:CloseCommandPalette()
            elseif (input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.KeypadEnter) and not UserInputService:GetFocusedTextBox() and not PaletteState.Palette:GetAttribute("Closing") then
                if not PaletteState.Search.Text:match("%S") then Library:CloseCommandPalette() end
            elseif input.KeyCode == Enum.KeyCode.Down or input.KeyCode == Enum.KeyCode.Up then
                Selected = math_clamp(Selected + (input.KeyCode == Enum.KeyCode.Down and 1 or -1), 1, math_max(1, #Matches))
                if PaletteState.SelectPaletteRow then PaletteState.SelectPaletteRow() end
            end
        elseif not processed and not UserInputService:GetFocusedTextBox() and not Library.ActiveKeyPicker then
            local picker = Library.CommandPaletteKeybind
            local key = type(picker) == "table" and picker.Keybind or (picker or Enum.KeyCode.Semicolon)
            if type(picker) == "table" and picker.Keybind == nil then key = nil end
            local uiPicker = Library.ToggleKeybind
            local picking = (type(picker) == "table" and picker.Picking)
                or (type(uiPicker) == "table" and uiPicker.Picking)
            if key and not picking and (input.KeyCode == key or input.UserInputType == key) then
                Library:OpenCommandPalette(input)
            end
        end
    end))

    function Library:AddTooltip(target, text)
        assert(typeof(target) == "Instance" and target:IsA("GuiObject"), "Tooltip target must be a GuiObject")
        local handle = { Text = tostring(text or ""), Connections = {}, Destroyed = false }
        OwnedHandles[handle] = true
        local label = Make("TextLabel", { Name = "Tooltip", BackgroundColor3 = background, TextColor3 = Foreground,
            TextSize = 13, TextWrapped = true, Font = Enum.Font.Gotham, Visible = false,
            Size = UDim2_fromOffset(200, 36), ZIndex = 150, Parent = UI })
        Corner(label, 5)
        local token = 0
        local function hide() token += 1; if label.Parent then label.Visible = false end end
        local function show(position)
            if handle.Destroyed or handle.Text == "" then return end
            local size = viewport()
            local point = ScreenPoint(position)
            label.Text = handle.Text
            local bounds = TextService:GetTextSize(handle.Text, 13, Enum.Font.Gotham, Vector2_new(220, 1000))
            local width = math_min(240, math_max(70, bounds.X + 20, math_min(size.X - 12, 70)))
            width = math_min(width, math_max(1, size.X - 12))
            local height = math_max(30, bounds.Y + 14)
            label.Size = UDim2_fromOffset(width, height)
            label.Position = UDim2_fromOffset(math_clamp(point.X + 12, 0, math_max(0, size.X - width)), math_clamp(point.Y + 18, 0, math_max(0, size.Y - height)))
            label.Visible = true
        end
        local function connect(signal, fn) table_insert(handle.Connections, signal:Connect(fn)) end
        connect(target.MouseEnter, function() show(UserInputService:GetMouseLocation()) end)
        connect(target.MouseLeave, hide)
        connect(target.InputBegan, function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                token += 1; local current = token
                task_delay(0.6, function() if token == current and not handle.Destroyed then show(input.Position) end end)
            end
        end)
        connect(target.InputChanged, function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement and label.Visible then show(UserInputService:GetMouseLocation()) end
        end)
        connect(target.InputEnded, function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then hide() end
        end)
        connect(target.Destroying, function() handle:Destroy() end)
        function handle:SetText(value) self.Text = tostring(value or ""); if label.Visible then label.Text = self.Text end end
        function handle:Destroy()
            if self.Destroyed then return end
            self.Destroyed = true; OwnedHandles[self] = nil; hide(); CleanConnections(self.Connections); label:Destroy()
        end
        return handle
    end

    function Library:CreateContextMenu(items)
        assert(type(items) == "table", "Context menu items must be a table")
        local menu = { Items = items, Connections = {}, Destroyed = false }
        OwnedHandles[menu] = true
        local layer = Make("Frame", { Name = "ContextMenuLayer", Size = UDim2_fromScale(1, 1),
            BackgroundTransparency = 1, Visible = false, ZIndex = 110, Parent = UI })
        local dismiss = Make("TextButton", { BackgroundTransparency = 1, Text = "", Size = UDim2_fromScale(1, 1), ZIndex = 110, Parent = layer })
        local frame = Make("ScrollingFrame", { BackgroundColor3 = background, BorderSizePixel = 0,
            Size = UDim2_fromOffset(190, 0), ScrollBarThickness = 3, AutomaticCanvasSize = Enum.AutomaticSize.Y,
            CanvasSize = UDim2_new(), ScrollingDirection = Enum.ScrollingDirection.Y, ZIndex = 111, Parent = layer })
        Corner(frame, 6)
        Make("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim_new(0, 2), Parent = frame })
        Make("UIPadding", { PaddingTop = UDim_new(0, 5), PaddingBottom = UDim_new(0, 5), PaddingLeft = UDim_new(0, 5), PaddingRight = UDim_new(0, 5), Parent = frame })
        function menu:Close() if not self.Destroyed then layer.Visible = false; if ActiveMenu == self then ActiveMenu = nil end end end
        function menu:Open(position)
            if self.Destroyed or Library.Unloaded then return end
            if ActiveMenu and ActiveMenu ~= self then ActiveMenu:Close() end
            if PaletteState.Palette and PaletteState.Palette.Visible then Library:CloseCommandPalette() end
            for _, child in ipairs(frame:GetChildren()) do if child:IsA("GuiObject") then child:Destroy() end end
            for index, item in ipairs(self.Items) do
                local entry = button(frame, tostring(item.Text or item.Name or "Action"), 112)
                entry.Size = UDim2_new(1, -3, 0, 32); entry.LayoutOrder = index
                entry.TextXAlignment = Enum.TextXAlignment.Left
                entry.TextColor3 = item.Disabled and Muted or Foreground
                Make("UIPadding", { PaddingLeft = UDim_new(0, 8), Parent = entry }); Corner(entry, 4)
                entry.Activated:Connect(function()
                    if item.Disabled then return end
                    self:Close()
                    if type(item.Callback) == "function" then
                        task_spawn(function() local ok, err = pcall(item.Callback); if not ok then warn("[Library] Context menu: " .. tostring(err)) end end)
                    end
                end)
            end
            local size = viewport()
            local width, height = math_min(190, math_max(1, size.X - 12)), math_min(#self.Items * 34 + 10, math_max(1, size.Y - 12))
            local point = ScreenPoint(position or UserInputService:GetMouseLocation())
            frame.Size = UDim2_fromOffset(width, height)
            frame.Position = UDim2_fromOffset(math_clamp(point.X, 0, math_max(0, size.X - width)), math_clamp(point.Y, 0, math_max(0, size.Y - height)))
            layer.Visible = true; ActiveMenu = self
        end
        dismiss.Activated:Connect(function() menu:Close() end)
        function menu:Attach(target)
            assert(typeof(target) == "Instance" and target:IsA("GuiObject"), "Context menu target must be a GuiObject")
            local token = 0
            table_insert(self.Connections, target.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton2 then self:Open(input.Position)
                elseif input.UserInputType == Enum.UserInputType.Touch then
                    token += 1; local current = token; local start = input.Position
                    task_delay(0.6, function() if token == current and not self.Destroyed then self:Open(start) end end)
                end
            end))
            table_insert(self.Connections, target.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.Touch then token += 1 end end))
            table_insert(self.Connections, target.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.Touch then token += 1 end end))
            return self
        end
        function menu:Destroy()
            if self.Destroyed then return end
            self:Close(); self.Destroyed = true; OwnedHandles[self] = nil; CleanConnections(self.Connections); layer:Destroy()
        end
        return menu
    end

    function Library:CleanupAdvancedUI()
        StopNumericHold()
        ContextActionService:UnbindAction(PaletteState.NumericShortcutName)
        PaletteState.SearchGeneration += 1
        PaletteState.PaletteGeneration += 1
        PaletteState.PendingSearch = false
        PaletteState.PendingSingleScrollView = nil
        PaletteState.FavoriteSaveVersion += 1
        if PaletteState.FavoriteSavePending then PaletteState.FavoriteSavePending = false; SaveFavorites() end
        Library._PaletteModalActive = false
        Library._PaletteSnowActive = false
        if PaletteState.PaletteTween then PaletteState.PaletteTween:Cancel(); PaletteState.PaletteTween = nil end
        if PaletteState.OverlayTween then PaletteState.OverlayTween:Cancel(); PaletteState.OverlayTween = nil end
        if PaletteState.PaletteResizeTween then PaletteState.PaletteResizeTween:Cancel(); PaletteState.PaletteResizeTween = nil end
        if PaletteState.PaletteBlur then PaletteState.PaletteBlur:Destroy(); PaletteState.PaletteBlur = nil end
        for handle in pairs(OwnedHandles) do handle:Destroy() end
        if PaletteState.Palette then PaletteState.Palette:Destroy(); PaletteState.Palette = nil end
        for _, rhythm in pairs(RhythmCache) do
            if rhythm.Container.Parent then rhythm.Container:Destroy() end
        end
        table_clear(RhythmCache)
        table_clear(RhythmRows)
        table_clear(PaletteState.PaletteViews)
        table_clear(PaletteState.Commands)
        PaletteState.SortedCommandList = nil
        CleanConnections(PaletteConnections)
    end

    Library:AddCommand({ Name = "Toggle UI", Builtin = true, Description = "Show or hide the main window", Callback = function() Library:Toggle() end })
end

function Library:AddDraggableLabel(options, icon, iconPosition)
    if type(options) ~= "table" then options = {Text = options, Icon = icon, IconPosition = iconPosition} end
    local holder = Create("Frame", {Name = "DraggableLabel", BackgroundColor3 = ThemeColor(25,25,25), Active = true,
        AutomaticSize = Enum.AutomaticSize.X, Size = UDim2_fromOffset(0, 32), Position = options.Position or UDim2_fromOffset(12,100), Parent = UI})
    Create("UICorner", {CornerRadius = UDim_new(0,7), Parent = holder})
    Create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = ThemeColor(80,80,80), Transparency = 0.3, Parent = holder})
    Create("UIPadding", {PaddingLeft = UDim_new(0,10), PaddingRight = UDim_new(0,10), Parent = holder})
    Create("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim_new(0,6), Parent = holder})
    local image = Create("ImageLabel", {Name = "Icon", BackgroundTransparency = 1, Image = "", Size = UDim2_fromOffset(16,16), ImageColor3 = ThemeColor(200,200,200), Parent = holder})
    local text = Create("TextLabel", {Name = "Text", BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2_fromOffset(0,24), FontFace = RegularFont, TextSize = 14, TextColor3 = ThemeColor(255,255,255), Text = tostring(options.Text or ""), Parent = holder})
    local label = {Label = holder, Destroyed = false}
    function label:SetText(value) if not self.Destroyed then text.Text = tostring(value or "") end end
    function label:SetIcon(value)
        if self.Destroyed then return end
        local definition = value and Library:GetIcon(value)
        image.Visible = definition ~= nil
        if definition then Library:ApplyIcon(image, definition) end
    end
    function label:SetIconPosition(value)
        if self.Destroyed then return end
        local right = type(value) == "string" and value:lower() == "right"
        image.LayoutOrder, text.LayoutOrder = right and 2 or 1, right and 1 or 2
    end
    function label:SetVisible(value) if not self.Destroyed then holder.Visible = value == true end end
    function label:SetPosition(value) if not self.Destroyed and typeof(value) == "UDim2" then holder.Position = value end end
    function label:Destroy() if not self.Destroyed then self.Destroyed = true; holder:Destroy() end end
    label:SetIcon(options.Icon)
    label:SetIconPosition(options.IconPosition or "left")
    if options.Visible == false then holder.Visible = false end
    MakeDraggable(holder, holder)
    return label
end

function Library:Unload()
    if Library.Unloaded then return end
    Library.Unloaded = true

    for i = #Library.Connections, 1, -1 do
        local connection = Library.Connections[i]
        if connection and connection.Connected then
            pcall(function() connection:Disconnect() end)
        end
        Library.Connections[i] = nil
    end

    if SnowConnection then SnowConnection:Disconnect(); SnowConnection = nil end
    if ThemeConnection then ThemeConnection:Disconnect(); ThemeConnection = nil end
    if windowTween then windowTween:Cancel(); windowTween = nil end

    if UI and UI.Parent then
        local FadeInfo = TweenInfo_new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        Create("TextButton", {Name = "UnloadBlocker", BackgroundTransparency = 1, Text = "", AutoButtonColor = false, Modal = true, Active = true, Size = UDim2_fromScale(1, 1), ZIndex = 1000, Parent = UI})
        local HasFaded = false
        for _, Object in ipairs(UI:GetDescendants()) do
            if Object:IsA("CanvasGroup") and Object.Visible and Object.GroupTransparency < .999 then
                TweenService:Create(Object, FadeInfo, {GroupTransparency = 1}):Play()
                HasFaded = true
            end
        end
        if Library.Blur and Library.Blur.Parent then TweenService:Create(Library.Blur, FadeInfo, {Size = 0}):Play() end
        if HasFaded then task_wait(0.19) end
    end

    if Library.CleanupAdvancedUI then Library:CleanupAdvancedUI() end

    for target, tween in pairs(ActiveTweens) do
        pcall(function() tween:Cancel() end)
        ActiveTweens[target], ActiveTweenGoals[target] = nil, nil
    end
    for i = #ThemeTransitions, 1, -1 do
        ThemeTransitions[i] = nil
    end
    table_clear(ThemeTweens)
    table_clear(TextBoundsCache)
    table_clear(TextBoundsKeys)
    table_clear(PaletteColorCache)
    TextBoundsCount = 0
    TextBoundsCursor = 1
    table_clear(Snowflakes)
    table_clear(BorderGradients)

    pcall(function()
        UserInputService.OverrideMouseIconBehavior = Enum.OverrideMouseIconBehavior.None
    end)

    if Library.Blur then
        pcall(function() Library.Blur:Destroy() end)
        Library.Blur = nil
    end
    if UI then
        pcall(function() UI:Destroy() end)
    end

    if Library.OnUnload then pcall(Library.OnUnload) end
    if getgenv and getgenv().Library == Library then getgenv().Library = nil end
    if getgenv().Multi_Support then getgenv().Multi_Support = nil end
    if getgenv().Auto_Show ~= nil then getgenv().Auto_Show = nil end

    if type(Library.Icons) == "table" then table_clear(Library.Icons) end
    table_clear(Library.Connections)
    table_clear(Library.Flags)
    table_clear(Library.Tabs)
    table_clear(Library.IconCache)
    table_clear(Library)
end

return Library
end)()

return Library, Library.Flags
