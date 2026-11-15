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
        Instance.Parent = Library.LocalPlayer:WaitForChild("PlayerGui", math.huge)
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
local themeName = "Default"
local themeNeutralValues = {0, 20, 25, 30, 32, 35, 45, 50, 60, 72, 80, 85, 90, 95, 100, 140, 200, 220, 255}
local function paletteColor(name, r, g, b)
    local def = ThemeDefinitions[name] or ThemeDefinitions.Default
    if r == 60 and g == 200 and b == 100 then return Color3.fromRGB(table.unpack(def.accent)) end
    if r ~= g or g ~= b then return Color3.fromRGB(r, g, b) end
    if name == "Default" then return Color3.fromRGB(r, g, b) end
    if def.paper and def.surface and def.ink and def.muted then
        if r <= 100 then
            return Color3.fromRGB(table.unpack(def.paper)):Lerp(Color3.fromRGB(table.unpack(def.surface)), math.clamp(r / 100, 0, 1))
        end
        return Color3.fromRGB(table.unpack(def.muted)):Lerp(Color3.fromRGB(table.unpack(def.ink)), math.clamp((r - 100) / 155, 0, 1))
    end
    if def.base and def.surface then
        local base = Color3.fromRGB(table.unpack(def.base))
        local surface = Color3.fromRGB(table.unpack(def.surface))
        if r <= 100 then return base:Lerp(surface, math.clamp((r - 15) / 85, 0, 1)) end
        local t = math.clamp((r - 100) / 155, 0, 1)
        return surface:Lerp(Color3.fromRGB(242, 240, 245), 0.48 + 0.52 * t)
    end
    if def.light then
        local shade
        if r <= 35 then shade = 255 - r * 0.65
        elseif r <= 100 then shade = math.clamp(232.25 - (r - 35) * 1.55, 130, 232.25)
        else shade = math.clamp(82 - (r - 100) * 0.37, 24, 82) end
        return Color3.fromRGB(shade, shade, math.clamp(shade + (r <= 100 and 2 or 0), 0, 255))
    end
    local amount = math.max(0, 1 - r / 255)
    local tone = def.darken and r <= 100 and r * def.darken or r
    return Color3.fromRGB(math.clamp(tone + def.low[1] * amount, 0, 255), math.clamp(tone + def.low[2] * amount, 0, 255), math.clamp(tone + def.low[3] * amount, 0, 255))
end
local function ThemeColor(r, g, b) return paletteColor(themeName, r, g, b) end
local function ThemeTextAlpha(value)
    if IsLightTheme(themeName) and value > 0 and value < 1 then return value * 0.48 end
    if value > 0 and value < 1 then return value * 0.22 end
    return value
end

local defaultToggleColor = ThemeColor(60, 60, 60)
local hoveringToggleColor = ThemeColor(100, 100, 100)
local enabledToggleColor = ThemeColor(60, 200, 100)

local semiBoldFont = Font.fromEnum(Enum.Font.GothamBold)
local mediumFont = Font.fromEnum(Enum.Font.GothamMedium)
local regularFont = Font.fromEnum(Enum.Font.Gotham)

local keyCodesName = {
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

local hueSequenceTable = {}
for hue = 0, 1, 0.1 do
    table.insert(hueSequenceTable, ColorSequenceKeypoint.new(hue, Color3.fromHSV(hue, 1, 1)))
end

local function HasProperty(instance: Instance, property: string)
    local _ = instance[property]
end

local function Create(class: string, properties: table): Instance
    local instance = Instance.new(class)

    local borderSuccess = pcall(HasProperty, instance, "BorderSizePixel")
    if borderSuccess then
        instance["BorderSizePixel"] = 0
    end

    for property, value in pairs(properties) do
        instance[property] = value
    end

    return instance
end

local function Round(number, factor)
    local result = math.floor(number / factor + (math.sign(number) * 0.5)) * factor
    if result < 0 then result += factor end
    return result
end

local textBoundsCache = {}
local function GetTextBounds(text: string, font, size: number, width: number)
    local key = text .. "|" .. tostring(size) .. "|" .. tostring(width) .. "|" .. tostring(font)
    local cached = textBoundsCache[key]
    if cached then return cached end

    local params = Instance.new("GetTextBoundsParams")
    params.Text = text
    params.Font = font
    params.Size = size
    params.Width = width

    local ok, bounds = pcall(function() return TextService:GetTextBoundsAsync(params) end)
    if not ok or not bounds then return nil end

    textBoundsCache[key] = bounds
    return bounds
end

local activeTweens = {}
local function Tween(target, info, props)
    local key = target
    if activeTweens[key] then
        activeTweens[key]:Cancel()
        activeTweens[key] = nil
    end
    local tween = TweenService:Create(target, info, props)
    activeTweens[key] = tween
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
                    local viewport = camera and camera.ViewportSize or Vector2.new(800, 600)
                    local inset = game:GetService("GuiService"):GetGuiInset()
                    local size = main.AbsoluteSize
                    local minX, minY = 6, 0
                    local maxX = math.max(minX, viewport.X - size.X - 6)
                    local maxY = math.max(minY, viewport.Y - size.Y - 1)
                    local x = math.clamp(startAbsolute.X + delta.X, minX, maxX)
                    local y = math.clamp(startAbsolute.Y + delta.Y, minY, maxY)
                    local uiScale = main.Parent and main.Parent:FindFirstChildOfClass("UIScale")
                    local scale = uiScale and uiScale.Scale or 1
                    main.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + (x - startAbsolute.X) / scale, framePos.Y.Scale, framePos.Y.Offset + (y - startAbsolute.Y) / scale)
                end
            end)
            table.insert(Library.Connections, dragConnection)

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if dragConnection then
                        dragConnection:Disconnect()
                        dragConnection = nil
                    end
                end
            end)
        end
    end)
end


Library.Icons = nil
Library.IconCache = {}

do
    local Lucide = {}

    local icons = {{"align-vertical-distribute-center","chevron-down","list-restart","table-cells-split","gavel","dna-off","refresh-ccw-dot","venus","bean","circle-question-mark","folder-code","bolt","heater","feather","align-horizontal-distribute-center","grip-vertical","pill-bottle","person-standing","badge-swiss-franc","between-horizontal-end","file-braces-corner","rotate-cw","house-plus","bus-front","shield-ellipsis","between-vertical-end","globe-lock","tags","concierge-bell","bookmark-minus","plant-pot","file-down","picture-in-picture","messages-square","scissors","file-check-corner","phone-call","anchor","hand-helping","text-wrap","birdhouse","wifi-off","cloud-alert","message-square","cloud-download","folder-plus","cctv-off","notebook-dot","mirror-round","user-round","pointer","between-horizontal-start","chevrons-up-down","brush","message-circle-more","parentheses","book-up-2","flame","chevrons-up","square-dashed","square-mouse-pointer","superscript","signal","wifi-cog","hexagon","navigation-2-off","eye-off","arrows-up-from-line","file-code-corner","square-centerline-dashed-horizontal","panels-right-bottom","scaling","hash","arrow-left-from-line","ship","ticket-percent","calendar-clock","x","non-binary","voicemail","presentation","tree-palm","badge","captions-off","align-vertical-justify-center","download","mouse-right","lens-convex","shrimp-off","focus","diamond-percent","arrow-big-up","volume-x","mouse-pointer-click","face-slightly-smiling-plus","hard-drive","grid-2x2-x","package-minus","cloud","pipette","corner-left-down","badge-cent","cloud-lightning","user-round-pen","arrow-left-to-line","book-open-text","monitor-cloud","parking-meter","cat","heart-handshake","dam","trees","ham","circle-pause","chess-king","bean-off","clef-alto","separator-horizontal","ambulance","globe-code","citrus","phone-missed","calendar-off","chart-column","battery-medium","square-minus","star-check","decimals-arrow-left","folder-output","menu","bangladeshi-taka","image-down","terminal","building-complex-plus","circle-dot-dashed","medal","cake-slice","git-graph","armchair","tickets","qr-code","copy","goal","book-bookmark","trending-down","creative-commons","layers-arrow-down","ev-charger","user-star","road","nfc","align-center-horizontal","car","notebook-tabs","ear","videotape","sun-moon","chart-scatter","podium","toolbox","calendar","calendar-cog","gallery-horizontal","clipboard-x","list-sort-ascending","book-open","circle-pile","rectangle-ellipsis","badge-plus","badge-info","file-headphone","bow-arrow","clipboard-pen-line","user-round-key","folder-search","utensils-crossed","arrow-up","arrow-up-from-dot","align-vertical-justify-start","layers-minus","pause","shrub","flag","biceps-flexed","align-horizontal-distribute-end","donut","calendar-plus-2","move-vertical","file-pen-line","badge-russian-ruble","radius","pilcrow","corner-left-up","georgian-lari","cable","book-user","square-arrow-down","circle-plus","view","cctv","circle-arrow-left","square-off","octagon-alert","panel-bottom-dashed","book-a","align-end-vertical","thumbs-up","globe","rabbit","layers-plus","door-stairwell","banknote-arrow-down","message-square-off","dice-4","message-circle-x","folder-x","message-circle-warning","map","move","arrow-up-left","award","arrow-down-wide-narrow","unfold-horizontal","lens-concave","zoom-out","motorbike","music-4","zoom-in","shield-x","file-volume","disc-3","file-signal","columns-4","archive-x","zodiac-virgo","square-dashed-kanban","mouse-pointer-2","clock-arrow-up","clock-fading","pencil-sparkles","library-big","vegan","star-plus","file-check","clef-bass","message-circle-plus","user-key","credit-card-plus","zodiac-pisces","fast-forward","user-pen","chess-knight","wifi-pen","files","send-to-back","alarm-clock","microscope","zodiac-libra","zodiac-leo","zodiac-gemini","shopping-basket","send","smartphone","square-dashed-bottom","zodiac-aries","zodiac-aquarius","land-plot","wind-arrow-down","germ-off","brush-cleaning","skip-back","x-line-top","book-audio","octagon-minus","file-scan","cupcake","midi-port","message-square-dashed","shield-check","worm","chevrons-left","workflow","umbrella","skip-forward","clipboard-copy","map-pin-off","arrow-up-from-line","circle-chevron-up","wine-off","wine","circle-small","align-vertical-space-between","lamp-desk","circle-arrow-up","zap","beaker","timeline","panel-left-right-dashed","wifi-sync","paintbrush","sliders-vertical","broccoli","wifi-high","wifi","chevron-up","triangles-centerline-dashed-horizontal","whistle","pen-tool","database-check","wheat-off","form","pencil-ruler","dna","arrow-big-down-dash","chart-area","bug-off","wheat","weight-tilde","card-sim","weight","server-crash","map-pin-search","flask-round","eye-dashed","webcam-off","ellipse","spell-check","webcam","waypoints","popcorn","blocks","waves-vertical","layer-arrow-up","microchip","waves-ladder","badge-minus","cloud-sun","circle","shield-alert","waves-horizontal","phone-incoming","map-minus","waves-arrow-down","watch","separator-vertical","washing-machine","heart-minus","scan-square","ampersands","wand-sparkles","user-search","magnet","fence","wallpaper","square-user-round","wallet-minimal","wallet-cards","sunrise","strikethrough","calendar-days","folder-bookmark","wallet","banknote-arrow-up","layout-arrow-right","vote","dollar-sign","message-square-quote","volume-off","ruler-dimension-line","volume-1","list-minus","cloud-hail","volume","eye-closed","app-window-mac","volleyball","ellipsis","copy-check","clock-arrow-right","satellite","bookmark-plus","virus","folder-key","coffee","circle-power","ligature","hourglass","tickets-plane","folder-git","video","bomb","layers-2","battery-full","sparkle","line-dot-bottom-vertical","chart-gantt","folder-tree","command","badge-dollar-sign","align-start-vertical","briefcase-conveyor-belt","message-circle-question-mark","vibrate","bluetooth-off","venus-and-mars","square-square","cannabis","equal-approximately-not","book","grip-horizontal","circle-minus","audio-waveform","moon-star","arrow-down-narrow-wide","ghost","database-backup","wand","receipt-turkish-lira","vector-polygon","calendar-minus-2","copy-minus","vault","folder-input","book-image","badge-x","mouse-left","tag-plus","shirt","van","server-off","move-up","message-circle-dashed","utensils","plug-2","users-round","chess-rook","brackets","calendar-heart","list-ordered","users","star-x","mic-off","user-x","arrow-big-left","square-split-horizontal","triangle-alert","user-round-x","clover","sun-snow","sofa","user-round-search","handbag","funnel-x","map-pin","clock-2","calendar-fold","fish-off","baby","database-x","fold-vertical","user-round-group","hop","face-angry","user-round-cog","cigarette","calendar-chevrons-right","user-round-check","user-round-arrow-left","diamond-plus","refrigerator","file-chart-column","triangle-dashed","git-pull-request-closed","badge-check","user-minus","user-lock","layers-arrow-up","plug-zap","heading-4","chess-queen","graduation-cap","grid-3x2","zodiac-sagittarius","square-dashed-x-corner","square-dashed-bottom-code","clock-7","ethernet-port","scan-text","user-group","shower-head","equal-not","user-cog","move-down","clock-arrow-down","ticket-slash","ruler","settings-2","user","circle-user-round","usb-c-port","layers","list-filter","map-pin-check","egg-off","upload","cog","dog","unplug","swords","spotlight","panel-right-dashed","signal-zero","paper-bag","truck-electric","unlink","check-line","university","bubbles","bot","chart-bar-increasing","ungroup","playing-card","air-vent","unfold-vertical","dot","ice-cream-cone","mouth","file-symlink","clipboard-paste","chevron-last","book-heart","undo-2","circle-parking","globe-check","cloud-check","panel-left","circle-chevron-right","undo","underline","squares-unite","arrow-down-up","git-fork","forward","brain-circuit","between-vertical-start","database","panel-right","umbrella-off","type-outline","flower","log-out","git-branch-plus","clipboard-minus","file-text","trending-up","fire-extinguisher","fan","table-rows-split","milk-off","tv-minimal","cloud-upload","banknote","turntable","message-circle-dashed-check","drumstick","turkish-lira","calendar-search","tube-lotion","line-dot-top-vertical","bell-ring","circle-chevron-left","truck","arrow-down","arrow-up-down","folder-dot","trophy","case-lower","whole-word","monitor","disc-2","trending-up-down","folder-cog","user-shield","triangle","tv-minimal-play","circle-stop","align-vertical-space-around","switch-camera","tree-deciduous","square-chart-gantt","arrow-big-down","circle-parking-off","calendar-x-2","user-plus","move-diagonal-2","bandage","gallery-horizontal-end","panel-top-dashed","transgender","chess-bishop","tram-front","train-front-tunnel","train-front","refresh-cw-off","audio-lines","traffic-cone","tractor","toothbrush","tower-control","rocket","fish","ear-off","touchpad-off","save-check","touchpad","torus","printer","megaphone-off","tornado","arrow-big-right","section","file-clock","toothbrush-sparkles","toy-brick","square-chevron-down","dice-1","drill","app-window","robot-vacuum","hand-metal","tool-case","spell-check-2","toilet","squirrel","list-plus","toggle-left","rotate-ccw-key","timer-reset","chart-pie","paw-print","timer","copy-slash","wind","ticket-x","layout-panel-left","moon","circle-percent","ticket-minus","circle-arrow-out-down-right","square-x","italic","chart-column-increasing","layout-freeform","step-forward","message-square-diff","a-arrow-down","broom-sparkles","sticker","tic-tac-toe","move-left","thermometer-sun","thermometer-snowflake","thermometer","theater","import","badge-turkish-lira","square-terminal","file-music","logs","beef","faucet","file-user","text-quote","square-radical","lightbulb","image-upscale","book-type","text-cursor-input","signpost-big","text-cursor","cloudy","helicopter","square-percent","text-align-justify","navigation-off","arrow-left","car-taxi-front","text-align-end","mouth-off","chevrons-right-left","text-align-center","test-tubes","test-tube-diagonal","brick-wall-fire","square-stack","tent","square-dimensions","face-slightly-smiling","align-end-horizontal","layer-arrow-down","equal","megaphone","calendar-x","telescope","ice-cream-bowl","egg","tangent","save-off","ship-cargo","circle-pound-sterling","video-off","japanese-yen","tally-3","tag","tally-1","library","file-terminal","circle-chevron-down","accessibility","route","square-library","amphora","hourglass-cog","tally-2","tablets","tablet-smartphone","building-complex","remove-formatting","sheet","circle-check-big","table-properties","table-of-contents","map-pinned","corner-down-left","circuit-board","table-columns-split","table-cells-merge","table-2","table","folder-open-dot","book-dashed","syringe","lasso","bluetooth","tree-pine","receipt-indian-rupee","swiss-franc","shield-plus","sunset","sun-medium","sun-dim","can-soda","flask-conical","power","funnel","square-star","folder-sync","monitor-pc","zodiac-ophiuchus","subscript","stretch-vertical","arrow-up-narrow-wide","fishing-hook","stretch-horizontal","maximize-2","stone","frame","calendar-arrow-down","clock-12","star-minus","heart","sticky-note-x","images","lollipop","book-text","chart-no-axes-column-increasing","lamp-floor","file-plus-corner","image","equal-approximately","badge-euro","bike","angle","gap-vertical","sticky-note-check","sticky-note","stethoscope","step-back","star-off","option","banknote-check","scroll-text","server-plus","repeat","star","stamp","toggle-right","file-x","ferris-wheel","camera-off","squircle","search-slash","repeat-off","squares-exclude","square-user","group","square-text","battery","mic-audio-lines","tent-tree","square-split-vertical","rectangle-horizontal","spade","square-slash","screen-share-off","bitcoin","square-scissors","battery-plus","database-search","square-round-corner","file-diff","joystick","square-plus","square-play","spline-pointer","square-pilcrow","axis-3d","square-pi","message-square-share","binoculars","square-pause","calendar-range","square-parking","rose","euro","mail-minus","square-m","square-kanban","square-function","pyramid","clipboard-pen","bottle-wine","alarm-clock-off","square-equal","list","square-dot","square-arrow-right","dome","badge-pound-sterling","bookmark-check","square-divide","wrench-off","shopping-bag","a-arrow-up","clock-check","shrink","chevrons-down","vibrate-off","face-grinning","zodiac-cancer","square-code","file-code","square-chevron-up","carton-off","credit-card-reader","paintbrush-vertical","cassette-tape","battery-low","square-chevron-left","receipt-japanese-yen","signpost","snail","calendar-arrow-up","landmark","fish-symbol","trash-off","loader","bold","dice-2","file-type","clipboard-clock","beer","lectern","square-centerline-dashed-vertical","square-bottom-dashed-scissors","square-bookmark","binary","move-diagonal","square-asterisk","door-closed","square-arrow-up-right","layout-template","rows-4","piano","square-arrow-right-exit","bookmark-off","hand-heart","square-arrow-right-enter","scan-qr-code","message-square-check","square-arrow-out-up-right","square-arrow-out-up-left","monitor-play","brain","square-arrow-out-down-left","server-cog","square-arrow-down-right","key","clock-11","gap-horizontal","ticket-plus","arrow-up-0-1","bell-electric","square","heading","book-open-check","panel-top-close","lasso-select","sprout","spray-can","sport-shoe","shield-off","bus","search-alert","audio-lines-x","chart-no-axes-gantt","file-spreadsheet","percent","clipboard-list","speech","contact-round","speaker","keyboard-off","sparkles","file-badge","battery-warning","mail-question-mark","arrow-down-from-line","briefcase","biohazard","rectangle-circle","braces","scale-3d","panel-top-bottom-dashed","mail-x","square-dashed-mouse-pointer","square-sparkles","lock-open","file-play","pizza","list-indent-decrease","arrow-up-wide-narrow","soup","clock-5","solar-panel","rotate-ccw","align-horizontal-justify-center","soap-dispenser-droplet","antenna","memory-stick","scan-eye","snowflake","square-check","heart-plus","smartphone-nfc","map-pin-minus-inside","git-merge","gallery-vertical-end","square-dashed-plus","hand-coins","zodiac-capricorn","wifi-low","sliders-horizontal","clock","file-pen","git-compare-arrows","cloud-sun-rain","align-horizontal-justify-start","power-off","mail-badge","skull","calendar-plus","siren","arrow-down-z-a","bath","signature","unlink-2","signal-medium","shopping-cart-minus","folder-check","signal-low","book-key","ribbon","microwave","calculator","gallery-vertical","sigma","shuffle","square-dashed-text","map-pin-pen","move-up-left","shrimp","folder-heart","hard-drive-upload","monitor-speaker","shopping-cart-plus","arrow-up-a-z","package","square-dashed-top-solid","ship-wheel","shield-user","shield-question-mark","swatch-book","receipt-cent","spool","folder-archive","folder-symlink","can","ban","message-square-x","paint-roller","git-pull-request-draft","archive","shield-lock","shield-keyhole","shield-half","circle-slash-2","shield-cog-corner","cake","cloud-rain","chart-bar","shield-cog","wrench","shield-ban","shield","shelving-unit","flag-triangle-right","shell","gamepad-directional","bell","share","shapes","music-3","chart-bar-big","user-check","proportions","settings","plane","webhook-off","carrot","square-arrow-left","file-cog","circle-dashed","server","send-horizontal","search-x","germ","squares-subtract","search-code","dices","split","list-sort-descending","search","forklift","scroll","alarm-clock-minus","heart-x","eraser","square-sigma","screen-share","bluetooth-connected","rotate-ccw-square","chart-no-axes-column","cannabis-off","folder-kanban","lighthouse","mars-stroke","roller-coaster","school","scan-search","file-box","pickaxe","paint-bucket","glass-water","mic","glasses","piggy-bank","scan-face","cuboid","cloud-off","check-check","activity","axe","plane-takeoff","scan-box","cloud-rain-wind","scan-barcode","scan","copy-x","file-axis-3d","radical","chart-column-decreasing","play-off","bug-play","align-vertical-distribute-start","save-plus","waves-arrow-up","tally-5","headset","save","saudi-riyal","circle-divide","satellite-dish","sandwich","salad","life-buoy","sailboat","external-link","volume-2","battery-charging","russian-ruble","square-arrow-up-left","brick-wall-shield","footprints","rows-3","building","rows-2","router","route-off","tag-x","book-alert","link-2","astroid","bell-minus","image-up","closed-caption","drum","arrow-up-z-a","sun","rotate-cw-fading-clock","rotate-cw-clock","file-key","rotate-ccw-clock","rotate-3d","scissors-line-dashed","house-wifi","robot-arm","rewind","ticket-check","combine","reply","replace-all","mountain","mars","picture-in-picture-2","radio-off","flower-2","replace","squares-intersect","repeat-2","repeat-1","keyboard-music","star-half","playing-cards-fan","code-xml","pencil-line","mails","brain-cog","tablet","regex","pi","trash","book-down","hdmi-port","trailer","case-upper","circle-fading-arrow-up","refresh-cw","croissant","phone","computer","barcode","pin","redo","bed","circle-arrow-right","divide","grape","rectangle-vertical","party-popper","file-chart-pie","rectangle-goggles","file-x-corner","dice-6","receipt-swiss-franc","blender","receipt-russian-ruble","zap-off","square-check-big","receipt-euro","receipt","ratio","laptop-minimal","rat","rainbow","map-pin-minus","omega","chart-spline","message-square-more","radio-receiver","chart-candlestick","radio","arrow-down-a-z","radiation","radar","move-horizontal","file-sliders","quote","square-exclamation-point","cup-soda","puzzle","projector","sword","printer-check","map-pin-x","earth","slice","dice-3","milk","mouse-pointer-ban","crown","circle-slash","circle-star","rotate-cw-square","atom","package-x","bed-double","pound-sterling","circle-dot","file-exclamation-point","hand-fist","message-circle-code","folder-git-2","message-square-code","popsicle","towel-rack","layout-grid","arrow-big-left-dash","plus","dumbbell","plug","playing-cards","houses","scale","play","flashlight","panel-top-open","plane-landing","pin-off","notebook","redo-2","pill","square-menu","pilcrow-left","monitor-smartphone","laptop","scan-line","clock-4","square-arrow-up","book-minus","file-question-mark","chevrons-left-right","phone-off","save-pen","arrow-down-to-line","phone-forwarded","refresh-ccw","venetian-mask","calendar-check-2","phi","spline","banknote-x","git-pull-request-create-arrow","pentagon","circle-check","pencil-off","caravan","pen-off","pen-line","hand-platter","pc-case","timer-off","arrow-big-right-dash","bed-single","parasol","paperclip","backpack","calendar-minus","panels-left-bottom","panel-top","panel-right-open","mic-signal","arrow-down-right","panel-right-close","letters","wifi-zero","panel-left-open","panel-left-dashed","map-pin-plus","hard-drive-download","image-off","panel-bottom-close","panel-bottom","panda","engine","square-chevron-right","mail-search","package-search","bone-fracture","package-plus","package-open","crop","package-2","lambda","ampersand","ad","shopping-cart","align-vertical-justify-end","origami","alarm-smoke","orbit","file-input","clock-8","hand-grab","cloud-cog","blend","hd","radio-tower","list-tree","droplet","line-squiggle","eye","octagon-pause","square-dashed-x","banana","gpu","message-square-heart","nut-off","circle-equal","face-slightly-frowning","nut","notepad-text-dashed","notepad-text","text-initial","arrow-up-right","maximize","leafy-green","message-square-dot","file-chart-line","columns-3-cog","newspaper","network","minimize-2","nepali-rupee","navigation-2","cone","navigation","file-image","music-2","palette","barrel","gallery-thumbnails","move-up-right","cpu","move-right","thumbs-down","merge","hamburger","move-down-right","hat-glasses","code","move-down-left","move-3d","mail-check","mouse-pointer","carton","mouse-off","kanban","bone","apple","rocking-chair","bot-off","circle-arrow-out-down-left","database-arrow-down","folder","circle-arrow-out-up-left","mop","cable-car","arrow-down-left","square-activity","message-square-text","cigarette-off","monitor-up","message-circle","circle-arrow-out-up-right","car-battery","monitor-stop","fold-horizontal","shovel","calendar-1","cloud-moon","square-arrow-out-down-right","monitor-pause","clock-plus","circle-euro","cloud-snow","anvil","arrow-big-up-dash","monitor-off","log-in","monitor-dot","monitor-cog","monitor-check","list-checks","chevrons-down-up","clipboard-plus","circle-x","list-end","minus","list-collapse","chevrons-right","audio-lines-off","message-square-reply","corner-down-right","milestone","summary","lamp-wall-down","mic-vocal","layout-arrow-down","ellipsis-vertical","globe-off","square-stop","arrow-up-1-0","align-horizontal-justify-end","scan-heart","align-vertical-distribute-end","heart-crack","airplay","case-sensitive","messages-circle","message-square-warning","monitor-x","bell-check","database-minus","square-pen","message-square-plus","message-square-lock","dice-5","octagon","ticket","folder-lock","message-circle-off","briefcase-plus","bookmark","message-circle-heart","utility-pole","message-circle-check","chart-bar-decreasing","database-plus","calendar-sync","funnel-plus","store","circle-arrow-down","notebook-pen","egg-fried","compass","keyboard","corner-right-up","map-pin-x-inside","printer-3d","user-round-plus","panel-left-close","crosshair","pilcrow-right","user-round-minus","mailbox","indian-rupee","mail-plus","mail-pen","bell-off","mail-clock","mouse-pointer-2-off","drone","slash","credit-card-x","aperture","arrow-right-left","mail","vector-square","circle-gauge","circle-alert","check","text-search","arrow-down-to-dot","monitor-down","lock-keyhole-open","chef-hat","lock-keyhole","lock","file-archive","signal-high","inbox","locate-fixed","locate","image-play","align-horizontal-space-between","loader-pinwheel","calendar-check","database-zap","droplets","loader-circle","broom","corner-right-down","layout-list","file-search","list-video","alarm-clock-plus","circle-dollar-sign","usb","house","receipt-pound-sterling","list-music","list-indent-increase","id-card","mouse","minimize","list-clock","list-chevrons-up-down","galaxy","list-chevrons-down-up","book-x","mirror-rectangular","list-check","link-2-off","link","headphone-off","asterisk","line-style","octagon-x","languages","line-dot-right-horizontal","alarm-clock-check","guitar","dock","beer-off","scooter","square-parking-off","notebook-text","arrow-right-to-line","clef-treble","tally-4","zodiac-taurus","leaf","door-open","flag-triangle-left","grid-3x3","file","layout-panel-top","pocket-knife","book-copy","castle","car-front","clock-alert","reply-all","cloud-moon-rain","clipboard-type","layout-dashboard","list-todo","printer-x","bird","list-start","lamp-wall-up","a-large-small","lamp-ceiling","lamp","map-plus","key-square","file-chart-column-increasing","kayak","database-arrow-up","arrow-right-from-line","flame-kindling","square-power","iv-bag","bring-to-front","iteration-cw","iteration-ccw","bell-plus","inspection-panel","info","infinity","folders","mail-warning","image-plus","image-minus","id-card-lanyard","bridge","chart-line","file-lock","cast","circle-fading-plus","clock-10","undo-dot","target","list-filter-plus","house-plug","drama","house-heart","baseline","martini","contrast","hotel","candy-off","hospital","book-check","heart-off","book-lock","highlighter","briefcase-medical","calendars","text-align-start","heart-pulse","hop-off","warehouse","sticky-notes","drafting-compass","save-all","file-braces","heading-6","heading-5","heading-3","heading-2","fishing-rod","book-headphones","credit-card","heading-1","haze","hard-hat","shredder","panel-bottom-open","door-closed-package","eject","credit-card-check","balloon","map-pin-plus-inside","bookmark-x","badge-question-mark","pen","hand","candy-cane","hammer","grip","gamepad-2","file-type-corner","grid-2x2-check","grid-2x2","globe-x","shield-minus","circle-off","dessert","eclipse","church","git-pull-request-create","cylinder","badge-japanese-yen","columns-3","receipt-text","git-merge-conflict","git-compare","git-commit-vertical","git-commit-horizontal","file-output","disc-album","circle-ellipsis","arrow-down-0-1","captions","git-branch","gift","philippine-peso","badge-alert","gem","folder-pen","cross","gauge","chevron-right","sticky-note-minus","square-arrow-down-left","share-2","gamepad","fullscreen","fuel","folder-up","folder-search-2","folder-root","chess-pawn","folder-open","briefcase-business","folder-minus","message-circle-reply","cloud-sync","triangle-right","folder-clock","folder-closed","mop-sparkles","type","webhook","flask-conical-off","align-horizontal-distribute-start","flashlight-off","flag-off","pointer-off","turtle","camera","fingerprint-pattern","film","git-pull-request","bluetooth-searching","arrow-up-to-line","squircle-dashed","clock-3","badge-percent","face-expressionless","file-video-camera","file-up","grid-2x2-plus","file-stack","box","file-search-corner","clock-1","file-heart","house-cog","space","file-minus-corner","file-minus","file-digit","corner-up-left","clock-6","zodiac-scorpio","key-round","headphones","tv","factory","face-neutral","rss","expand","at-sign","map-pin-check-inside","sticky-note-off","music","handshake","earth-lock","circle-user","copy-plus","droplet-off","virus-off","line-dot-left-horizontal","disc","diff","search-check","clipboard-check","columns-2","diamond-minus","clipboard","align-center-vertical","diameter","delete","club","cloud-fog","mosque","currency","map-pin-house","package-check","chevron-first","pencil","boxes","list-x","copyright","copyleft","corner-up-right","cookie","clock-arrow-left","container","contact","badge-indian-rupee","construction","redo-dot","component","align-start-horizontal","chart-column-stacked","file-plus","git-pull-request-arrow","coins","decimals-arrow-right","bell-dot","folder-down","cloud-drizzle","cloud-backup","align-horizontal-space-around","door-closed-locked","clock-9","diamond","blinds","clapperboard","circle-play","book-search","git-branch-minus","circle-dashed-check","recycle","mountain-snow","luggage","chevrons-left-right-ellipsis","bot-message-square","phone-outgoing","smartphone-charging","chevron-left","train-track","cherry","chart-bar-stacked","sticky-note-plus","chart-no-axes-column-decreasing","chart-network","chart-column-big","chart-no-axes-combined","metronome","triangles-centerline-dashed-vertical","arrow-down-1-0","credit-card-minus","candy","arrow-left-right","lightbulb-off","panels-top-left","beef-off","locate-off","bug","test-tube","brick-wall","cooking-pot","boom-box","book-up","book-plus","laptop-minimal-check","mail-open","park","baggage-claim","variable","arrow-right","archive-restore"},{"rbxassetid://104502745253902","rbxassetid://89421818506275"},{[48]={{1,{24,24},{175,0}},{1,{24,24},{650,0}},{1,{24,24},{850,250}},{2,{24,24},{150,0}},{1,{24,24},{250,700}},{1,{24,24},{600,225}},{1,{24,24},{575,800}},{2,{24,24},{225,225}},{1,{24,24},{50,350}},{1,{24,24},{675,25}},{1,{24,24},{500,425}},{1,{24,24},{50,400}},{1,{24,24},{75,925}},{1,{24,24},{825,50}},{1,{24,24},{50,75}},{1,{24,24},{175,800}},{1,{24,24},{375,925}},{1,{24,24},{850,450}},{1,{24,24},{325,50}},{1,{24,24},{100,325}},{1,{24,24},{650,225}},{1,{24,24},{950,475}},{1,{24,24},{725,300}},{1,{24,24},{425,125}},{1,{24,24},{650,850}},{1,{24,24},{50,375}},{1,{24,24},{550,425}},{2,{24,24},{50,125}},{1,{24,24},{25,725}},{1,{24,24},{300,200}},{1,{24,24},{825,500}},{1,{24,24},{300,575}},{1,{24,24},{500,800}},{1,{24,24},{950,225}},{1,{24,24},{525,925}},{1,{24,24},{500,375}},{1,{24,24},{775,525}},{1,{24,24},{100,100}},{1,{24,24},{900,100}},{2,{24,24},{200,50}},{1,{24,24},{325,125}},{2,{24,24},{100,400}},{1,{24,24},{175,550}},{1,{24,24},{175,975}},{1,{24,24},{75,650}},{1,{24,24},{100,825}},{1,{24,24},{225,375}},{1,{24,24},{525,700}},{1,{24,24},{500,675}},{2,{24,24},{225,200}},{1,{24,24},{500,825}},{1,{24,24},{75,350}},{1,{24,24},{325,325}},{1,{24,24},{50,475}},{1,{24,24},{775,375}},{1,{24,24},{600,675}},{1,{24,24},{450,50}},{1,{24,24},{900,25}},{1,{24,24},{300,350}},{1,{24,24},{775,900}},{1,{24,24},{775,925}},{2,{24,24},{50,50}},{1,{24,24},{750,800}},{2,{24,24},{175,325}},{1,{24,24},{25,975}},{1,{24,24},{750,475}},{1,{24,24},{250,600}},{1,{24,24},{250,75}},{1,{24,24},{425,450}},{1,{24,24},{925,725}},{1,{24,24},{725,550}},{1,{24,24},{875,575}},{1,{24,24},{650,350}},{1,{24,24},{100,175}},{1,{24,24},{800,725}},{2,{24,24},{250,25}},{1,{24,24},{100,450}},{2,{24,24},{225,300}},{1,{24,24},{550,675}},{2,{24,24},{0,450}},{1,{24,24},{350,975}},{2,{24,24},{25,300}},{1,{24,24},{250,125}},{1,{24,24},{50,525}},{1,{24,24},{100,75}},{1,{24,24},{275,550}},{1,{24,24},{525,675}},{1,{24,24},{775,300}},{1,{24,24},{550,975}},{1,{24,24},{700,225}},{1,{24,24},{150,650}},{1,{24,24},{150,100}},{2,{24,24},{375,100}},{1,{24,24},{575,625}},{1,{24,24},{75,775}},{1,{24,24},{700,300}},{1,{24,24},{300,675}},{1,{24,24},{775,475}},{1,{24,24},{475,275}},{1,{24,24},{950,375}},{1,{24,24},{350,425}},{1,{24,24},{250,100}},{1,{24,24},{750,0}},{2,{24,24},{325,100}},{1,{24,24},{50,225}},{1,{24,24},{75,400}},{1,{24,24},{450,725}},{1,{24,24},{550,725}},{1,{24,24},{250,350}},{1,{24,24},{250,750}},{1,{24,24},{575,225}},{2,{24,24},{350,0}},{1,{24,24},{75,900}},{1,{24,24},{125,550}},{1,{24,24},{100,525}},{1,{24,24},{75,325}},{1,{24,24},{350,350}},{1,{24,24},{650,825}},{1,{24,24},{200,0}},{1,{24,24},{575,400}},{1,{24,24},{400,300}},{1,{24,24},{700,600}},{1,{24,24},{525,50}},{1,{24,24},{550,75}},{1,{24,24},{200,200}},{1,{24,24},{800,900}},{1,{24,24},{950,875}},{1,{24,24},{300,500}},{1,{24,24},{150,775}},{1,{24,24},{950,200}},{1,{24,24},{100,275}},{1,{24,24},{525,500}},{2,{24,24},{0,200}},{1,{24,24},{500,50}},{1,{24,24},{425,250}},{1,{24,24},{200,925}},{1,{24,24},{325,225}},{1,{24,24},{875,100}},{1,{24,24},{75,150}},{2,{24,24},{100,175}},{1,{24,24},{775,575}},{1,{24,24},{475,300}},{1,{24,24},{450,525}},{1,{24,24},{375,100}},{2,{24,24},{325,25}},{1,{24,24},{175,600}},{1,{24,24},{300,750}},{1,{24,24},{375,475}},{2,{24,24},{150,275}},{1,{24,24},{750,650}},{1,{24,24},{575,650}},{1,{24,24},{0,100}},{1,{24,24},{550,50}},{1,{24,24},{475,750}},{1,{24,24},{850,0}},{2,{24,24},{100,350}},{2,{24,24},{50,25}},{1,{24,24},{300,325}},{1,{24,24},{550,775}},{2,{24,24},{200,100}},{1,{24,24},{325,250}},{1,{24,24},{75,475}},{1,{24,24},{500,450}},{1,{24,24},{25,675}},{1,{24,24},{825,275}},{1,{24,24},{50,425}},{1,{24,24},{75,600}},{1,{24,24},{775,600}},{1,{24,24},{25,325}},{1,{24,24},{125,225}},{1,{24,24},{250,625}},{1,{24,24},{50,450}},{1,{24,24},{125,575}},{2,{24,24},{375,50}},{1,{24,24},{25,900}},{2,{24,24},{25,400}},{1,{24,24},{275,50}},{1,{24,24},{125,175}},{1,{24,24},{50,125}},{1,{24,24},{250,800}},{1,{24,24},{500,775}},{1,{24,24},{925,625}},{1,{24,24},{0,900}},{1,{24,24},{0,425}},{1,{24,24},{25,100}},{1,{24,24},{450,375}},{1,{24,24},{500,75}},{1,{24,24},{900,325}},{1,{24,24},{0,875}},{1,{24,24},{350,25}},{1,{24,24},{525,825}},{1,{24,24},{400,900}},{1,{24,24},{325,450}},{1,{24,24},{200,750}},{1,{24,24},{350,200}},{1,{24,24},{400,100}},{1,{24,24},{950,675}},{1,{24,24},{25,650}},{2,{24,24},{75,375}},{1,{24,24},{200,400}},{1,{24,24},{150,500}},{1,{24,24},{750,950}},{1,{24,24},{300,925}},{1,{24,24},{450,800}},{1,{24,24},{450,25}},{1,{24,24},{75,50}},{2,{24,24},{50,200}},{1,{24,24},{475,500}},{1,{24,24},{725,625}},{1,{24,24},{225,825}},{1,{24,24},{325,500}},{1,{24,24},{75,300}},{1,{24,24},{375,775}},{1,{24,24},{0,800}},{1,{24,24},{625,525}},{1,{24,24},{875,75}},{1,{24,24},{650,500}},{1,{24,24},{350,775}},{1,{24,24},{875,350}},{1,{24,24},{75,225}},{1,{24,24},{25,300}},{1,{24,24},{175,100}},{2,{24,24},{50,325}},{1,{24,24},{800,275}},{2,{24,24},{250,300}},{1,{24,24},{775,425}},{1,{24,24},{800,425}},{2,{24,24},{275,275}},{1,{24,24},{900,625}},{1,{24,24},{400,500}},{1,{24,24},{700,125}},{1,{24,24},{700,200}},{1,{24,24},{175,575}},{1,{24,24},{125,100}},{2,{24,24},{300,250}},{1,{24,24},{950,725}},{1,{24,24},{625,575}},{1,{24,24},{325,400}},{1,{24,24},{275,450}},{1,{24,24},{950,350}},{1,{24,24},{725,350}},{2,{24,24},{300,150}},{1,{24,24},{850,975}},{1,{24,24},{475,400}},{1,{24,24},{325,375}},{1,{24,24},{725,425}},{2,{24,24},{150,250}},{1,{24,24},{100,675}},{2,{24,24},{400,150}},{1,{24,24},{875,0}},{2,{24,24},{75,325}},{1,{24,24},{75,550}},{2,{24,24},{75,425}},{1,{24,24},{300,600}},{1,{24,24},{700,775}},{1,{24,24},{50,50}},{1,{24,24},{750,425}},{2,{24,24},{450,100}},{2,{24,24},{475,75}},{2,{24,24},{50,475}},{1,{24,24},{725,800}},{1,{24,24},{675,800}},{1,{24,24},{825,750}},{1,{24,24},{975,700}},{2,{24,24},{125,400}},{2,{24,24},{150,375}},{1,{24,24},{575,475}},{2,{24,24},{450,75}},{1,{24,24},{175,775}},{1,{24,24},{75,450}},{1,{24,24},{625,925}},{2,{24,24},{250,275}},{1,{24,24},{400,75}},{1,{24,24},{275,950}},{1,{24,24},{775,125}},{1,{24,24},{650,150}},{1,{24,24},{700,475}},{1,{24,24},{525,625}},{1,{24,24},{725,775}},{2,{24,24},{325,200}},{1,{24,24},{400,250}},{2,{24,24},{350,175}},{2,{24,24},{175,200}},{1,{24,24},{600,950}},{1,{24,24},{225,475}},{1,{24,24},{600,525}},{1,{24,24},{100,200}},{1,{24,24},{550,125}},{2,{24,24},{400,125}},{2,{24,24},{375,150}},{1,{24,24},{600,100}},{1,{24,24},{0,175}},{1,{24,24},{700,350}},{1,{24,24},{0,650}},{2,{24,24},{175,350}},{1,{24,24},{100,300}},{2,{24,24},{75,200}},{1,{24,24},{300,950}},{2,{24,24},{50,450}},{1,{24,24},{550,700}},{1,{24,24},{900,675}},{1,{24,24},{150,375}},{2,{24,24},{150,350}},{2,{24,24},{475,50}},{1,{24,24},{525,125}},{2,{24,24},{150,200}},{2,{24,24},{225,275}},{1,{24,24},{375,900}},{1,{24,24},{475,325}},{2,{24,24},{275,225}},{1,{24,24},{750,200}},{1,{24,24},{975,325}},{1,{24,24},{575,250}},{1,{24,24},{50,175}},{1,{24,24},{175,425}},{1,{24,24},{0,525}},{2,{24,24},{250,250}},{2,{24,24},{325,175}},{1,{24,24},{500,100}},{2,{24,24},{300,200}},{1,{24,24},{575,900}},{1,{24,24},{500,625}},{1,{24,24},{775,150}},{1,{24,24},{275,575}},{2,{24,24},{425,75}},{1,{24,24},{650,200}},{1,{24,24},{875,725}},{2,{24,24},{400,100}},{2,{24,24},{450,50}},{1,{24,24},{475,850}},{1,{24,24},{200,250}},{2,{24,24},{475,25}},{1,{24,24},{350,700}},{1,{24,24},{775,400}},{2,{24,24},{0,475}},{1,{24,24},{75,275}},{1,{24,24},{550,200}},{1,{24,24},{450,250}},{1,{24,24},{775,725}},{2,{24,24},{25,450}},{1,{24,24},{725,575}},{1,{24,24},{750,375}},{2,{24,24},{75,400}},{2,{24,24},{100,375}},{1,{24,24},{625,850}},{2,{24,24},{125,350}},{1,{24,24},{225,775}},{1,{24,24},{650,800}},{1,{24,24},{150,50}},{2,{24,24},{200,275}},{2,{24,24},{200,225}},{1,{24,24},{250,850}},{1,{24,24},{800,75}},{2,{24,24},{225,250}},{1,{24,24},{875,900}},{2,{24,24},{275,200}},{2,{24,24},{300,175}},{2,{24,24},{100,0}},{2,{24,24},{0,25}},{1,{24,24},{50,500}},{1,{24,24},{600,325}},{2,{24,24},{250,225}},{1,{24,24},{50,325}},{1,{24,24},{150,900}},{2,{24,24},{325,150}},{1,{24,24},{500,325}},{1,{24,24},{325,825}},{2,{24,24},{400,75}},{1,{24,24},{750,675}},{2,{24,24},{450,25}},{1,{24,24},{950,150}},{1,{24,24},{0,725}},{2,{24,24},{350,125}},{1,{24,24},{300,550}},{1,{24,24},{225,0}},{2,{24,24},{475,0}},{1,{24,24},{600,250}},{1,{24,24},{600,175}},{1,{24,24},{350,375}},{1,{24,24},{575,850}},{1,{24,24},{250,250}},{2,{24,24},{25,425}},{1,{24,24},{275,650}},{1,{24,24},{325,425}},{1,{24,24},{700,0}},{1,{24,24},{650,425}},{1,{24,24},{825,200}},{2,{24,24},{125,150}},{1,{24,24},{375,550}},{2,{24,24},{125,325}},{1,{24,24},{25,425}},{1,{24,24},{325,725}},{1,{24,24},{250,150}},{1,{24,24},{600,975}},{1,{24,24},{550,525}},{1,{24,24},{525,100}},{1,{24,24},{925,25}},{1,{24,24},{125,625}},{1,{24,24},{200,150}},{1,{24,24},{0,150}},{1,{24,24},{275,250}},{1,{24,24},{700,450}},{2,{24,24},{175,275}},{1,{24,24},{150,300}},{2,{24,24},{250,200}},{1,{24,24},{800,950}},{1,{24,24},{75,500}},{1,{24,24},{550,300}},{1,{24,24},{350,150}},{1,{24,24},{200,775}},{1,{24,24},{225,450}},{1,{24,24},{50,275}},{1,{24,24},{900,300}},{1,{24,24},{0,250}},{1,{24,24},{125,825}},{1,{24,24},{500,300}},{2,{24,24},{175,300}},{1,{24,24},{850,525}},{2,{24,24},{350,100}},{1,{24,24},{575,0}},{1,{24,24},{575,200}},{2,{24,24},{375,75}},{1,{24,24},{325,600}},{1,{24,24},{200,275}},{1,{24,24},{275,100}},{1,{24,24},{700,500}},{2,{24,24},{125,50}},{1,{24,24},{775,750}},{2,{24,24},{425,25}},{1,{24,24},{550,925}},{1,{24,24},{925,300}},{1,{24,24},{825,325}},{2,{24,24},{0,425}},{1,{24,24},{675,650}},{2,{24,24},{75,350}},{1,{24,24},{0,625}},{1,{24,24},{500,25}},{1,{24,24},{0,550}},{1,{24,24},{900,200}},{2,{24,24},{50,375}},{1,{24,24},{975,875}},{1,{24,24},{875,300}},{2,{24,24},{125,300}},{1,{24,24},{250,0}},{1,{24,24},{850,900}},{2,{24,24},{250,100}},{2,{24,24},{250,175}},{1,{24,24},{425,325}},{2,{24,24},{25,50}},{1,{24,24},{725,850}},{2,{24,24},{275,150}},{1,{24,24},{800,200}},{1,{24,24},{600,350}},{1,{24,24},{425,700}},{1,{24,24},{625,100}},{1,{24,24},{25,525}},{1,{24,24},{200,700}},{1,{24,24},{325,25}},{1,{24,24},{375,425}},{1,{24,24},{650,275}},{2,{24,24},{400,25}},{1,{24,24},{925,100}},{1,{24,24},{200,650}},{2,{24,24},{425,0}},{1,{24,24},{225,425}},{1,{24,24},{125,425}},{2,{24,24},{0,400}},{2,{24,24},{25,375}},{1,{24,24},{125,675}},{1,{24,24},{475,900}},{1,{24,24},{575,300}},{2,{24,24},{225,125}},{1,{24,24},{775,200}},{1,{24,24},{225,125}},{2,{24,24},{100,300}},{2,{24,24},{125,275}},{1,{24,24},{275,775}},{1,{24,24},{650,675}},{1,{24,24},{450,550}},{1,{24,24},{25,600}},{1,{24,24},{400,575}},{1,{24,24},{250,725}},{2,{24,24},{375,175}},{1,{24,24},{825,850}},{1,{24,24},{675,975}},{1,{24,24},{500,225}},{1,{24,24},{425,425}},{1,{24,24},{625,825}},{2,{24,24},{175,225}},{1,{24,24},{600,925}},{1,{24,24},{500,350}},{2,{24,24},{200,200}},{1,{24,24},{300,900}},{1,{24,24},{400,325}},{2,{24,24},{200,75}},{1,{24,24},{725,700}},{1,{24,24},{975,525}},{2,{24,24},{100,325}},{1,{24,24},{525,175}},{2,{24,24},{275,125}},{1,{24,24},{200,850}},{1,{24,24},{125,950}},{1,{24,24},{700,425}},{1,{24,24},{725,125}},{2,{24,24},{300,100}},{1,{24,24},{300,450}},{1,{24,24},{525,300}},{2,{24,24},{325,75}},{2,{24,24},{75,50}},{1,{24,24},{725,875}},{1,{24,24},{950,325}},{1,{24,24},{775,775}},{1,{24,24},{675,600}},{2,{24,24},{75,275}},{2,{24,24},{350,50}},{1,{24,24},{225,400}},{2,{24,24},{400,0}},{1,{24,24},{25,500}},{1,{24,24},{100,400}},{1,{24,24},{100,500}},{2,{24,24},{0,375}},{1,{24,24},{750,575}},{1,{24,24},{75,0}},{2,{24,24},{25,350}},{1,{24,24},{300,525}},{1,{24,24},{600,425}},{1,{24,24},{450,750}},{1,{24,24},{600,300}},{1,{24,24},{150,550}},{1,{24,24},{600,50}},{1,{24,24},{225,250}},{2,{24,24},{125,250}},{1,{24,24},{150,525}},{1,{24,24},{600,375}},{1,{24,24},{125,600}},{1,{24,24},{275,975}},{1,{24,24},{575,100}},{2,{24,24},{75,300}},{2,{24,24},{150,225}},{1,{24,24},{900,900}},{1,{24,24},{200,75}},{1,{24,24},{900,75}},{1,{24,24},{725,225}},{1,{24,24},{475,50}},{1,{24,24},{25,400}},{1,{24,24},{325,475}},{1,{24,24},{900,375}},{2,{24,24},{200,175}},{2,{24,24},{250,125}},{1,{24,24},{725,200}},{1,{24,24},{350,750}},{1,{24,24},{50,900}},{1,{24,24},{175,525}},{1,{24,24},{550,350}},{2,{24,24},{275,75}},{1,{24,24},{225,675}},{1,{24,24},{0,850}},{2,{24,24},{50,100}},{1,{24,24},{650,525}},{2,{24,24},{300,75}},{1,{24,24},{500,250}},{1,{24,24},{400,0}},{2,{24,24},{375,0}},{1,{24,24},{850,300}},{1,{24,24},{50,775}},{2,{24,24},{0,350}},{1,{24,24},{425,150}},{2,{24,24},{25,325}},{1,{24,24},{475,600}},{1,{24,24},{150,275}},{1,{24,24},{600,75}},{2,{24,24},{50,300}},{1,{24,24},{125,150}},{1,{24,24},{150,150}},{1,{24,24},{450,475}},{2,{24,24},{100,250}},{1,{24,24},{400,200}},{2,{24,24},{200,300}},{1,{24,24},{925,275}},{1,{24,24},{725,100}},{2,{24,24},{300,50}},{1,{24,24},{475,450}},{2,{24,24},{175,250}},{2,{24,24},{175,175}},{2,{24,24},{325,50}},{1,{24,24},{550,150}},{1,{24,24},{25,150}},{2,{24,24},{125,0}},{2,{24,24},{50,275}},{1,{24,24},{875,775}},{1,{24,24},{25,200}},{1,{24,24},{175,500}},{1,{24,24},{375,200}},{2,{24,24},{50,350}},{1,{24,24},{400,800}},{1,{24,24},{125,250}},{1,{24,24},{525,425}},{1,{24,24},{825,450}},{2,{24,24},{125,200}},{1,{24,24},{125,500}},{2,{24,24},{150,175}},{2,{24,24},{225,100}},{2,{24,24},{200,125}},{1,{24,24},{525,850}},{1,{24,24},{75,250}},{2,{24,24},{275,50}},{2,{24,24},{300,25}},{2,{24,24},{150,150}},{2,{24,24},{0,300}},{1,{24,24},{675,725}},{1,{24,24},{150,750}},{1,{24,24},{0,825}},{2,{24,24},{75,225}},{1,{24,24},{500,925}},{2,{24,24},{50,250}},{2,{24,24},{100,200}},{1,{24,24},{900,450}},{1,{24,24},{175,950}},{2,{24,24},{125,175}},{1,{24,24},{200,50}},{1,{24,24},{750,725}},{1,{24,24},{450,425}},{2,{24,24},{175,125}},{2,{24,24},{325,0}},{1,{24,24},{800,850}},{1,{24,24},{75,725}},{1,{24,24},{200,625}},{1,{24,24},{200,25}},{1,{24,24},{700,700}},{1,{24,24},{875,125}},{2,{24,24},{225,75}},{1,{24,24},{900,700}},{2,{24,24},{250,50}},{1,{24,24},{825,975}},{1,{24,24},{875,225}},{2,{24,24},{300,0}},{1,{24,24},{525,875}},{2,{24,24},{25,250}},{1,{24,24},{325,300}},{1,{24,24},{475,800}},{2,{24,24},{0,275}},{1,{24,24},{525,250}},{2,{24,24},{425,100}},{2,{24,24},{175,100}},{1,{24,24},{950,125}},{1,{24,24},{875,325}},{1,{24,24},{100,575}},{2,{24,24},{275,0}},{1,{24,24},{100,550}},{1,{24,24},{825,950}},{1,{24,24},{150,875}},{1,{24,24},{600,25}},{1,{24,24},{100,950}},{1,{24,24},{900,950}},{1,{24,24},{500,650}},{1,{24,24},{0,0}},{1,{24,24},{125,400}},{1,{24,24},{975,900}},{2,{24,24},{25,225}},{1,{24,24},{250,950}},{2,{24,24},{125,125}},{2,{24,24},{150,100}},{2,{24,24},{100,150}},{2,{24,24},{175,75}},{1,{24,24},{300,725}},{1,{24,24},{300,75}},{1,{24,24},{925,850}},{1,{24,24},{50,825}},{1,{24,24},{325,775}},{1,{24,24},{375,50}},{1,{24,24},{850,25}},{1,{24,24},{450,450}},{2,{24,24},{250,0}},{1,{24,24},{750,975}},{1,{24,24},{600,475}},{1,{24,24},{375,650}},{1,{24,24},{475,25}},{2,{24,24},{50,175}},{1,{24,24},{700,850}},{2,{24,24},{25,200}},{1,{24,24},{450,300}},{1,{24,24},{50,950}},{1,{24,24},{900,825}},{2,{24,24},{100,125}},{1,{24,24},{700,525}},{1,{24,24},{25,250}},{1,{24,24},{575,25}},{2,{24,24},{125,100}},{1,{24,24},{475,725}},{1,{24,24},{375,275}},{2,{24,24},{150,75}},{2,{24,24},{175,50}},{2,{24,24},{225,0}},{1,{24,24},{400,125}},{1,{24,24},{775,975}},{2,{24,24},{25,175}},{1,{24,24},{750,925}},{1,{24,24},{50,800}},{1,{24,24},{100,25}},{1,{24,24},{375,675}},{1,{24,24},{475,375}},{1,{24,24},{150,975}},{1,{24,24},{350,225}},{2,{24,24},{75,125}},{1,{24,24},{625,400}},{1,{24,24},{700,150}},{2,{24,24},{125,75}},{1,{24,24},{475,950}},{1,{24,24},{850,675}},{1,{24,24},{0,675}},{2,{24,24},{150,300}},{1,{24,24},{50,975}},{2,{24,24},{200,0}},{2,{24,24},{75,100}},{2,{24,24},{25,150}},{1,{24,24},{700,375}},{1,{24,24},{575,325}},{1,{24,24},{625,50}},{1,{24,24},{50,0}},{1,{24,24},{900,525}},{1,{24,24},{875,825}},{1,{24,24},{125,75}},{1,{24,24},{850,175}},{2,{24,24},{0,175}},{2,{24,24},{150,25}},{2,{24,24},{0,150}},{1,{24,24},{475,75}},{1,{24,24},{425,950}},{1,{24,24},{850,650}},{1,{24,24},{675,0}},{2,{24,24},{75,75}},{2,{24,24},{100,50}},{1,{24,24},{400,725}},{1,{24,24},{400,375}},{1,{24,24},{425,275}},{2,{24,24},{125,25}},{2,{24,24},{0,125}},{2,{24,24},{25,100}},{2,{24,24},{25,125}},{1,{24,24},{200,725}},{1,{24,24},{300,175}},{2,{24,24},{50,75}},{1,{24,24},{400,650}},{1,{24,24},{100,350}},{2,{24,24},{0,325}},{1,{24,24},{375,975}},{2,{24,24},{0,100}},{1,{24,24},{975,550}},{2,{24,24},{75,25}},{2,{24,24},{75,0}},{2,{24,24},{0,50}},{1,{24,24},{225,350}},{1,{24,24},{800,125}},{1,{24,24},{375,950}},{1,{24,24},{575,375}},{1,{24,24},{975,800}},{1,{24,24},{950,0}},{1,{24,24},{300,875}},{2,{24,24},{425,125}},{2,{24,24},{50,0}},{2,{24,24},{25,0}},{1,{24,24},{50,250}},{1,{24,24},{125,775}},{2,{24,24},{0,0}},{1,{24,24},{250,875}},{1,{24,24},{950,975}},{1,{24,24},{700,250}},{1,{24,24},{225,325}},{1,{24,24},{650,75}},{1,{24,24},{900,925}},{1,{24,24},{100,900}},{1,{24,24},{950,950}},{1,{24,24},{325,700}},{1,{24,24},{300,800}},{1,{24,24},{500,0}},{1,{24,24},{425,200}},{1,{24,24},{675,375}},{1,{24,24},{850,50}},{1,{24,24},{350,675}},{1,{24,24},{525,325}},{1,{24,24},{175,175}},{1,{24,24},{450,0}},{1,{24,24},{75,125}},{1,{24,24},{300,650}},{1,{24,24},{950,925}},{1,{24,24},{925,975}},{1,{24,24},{875,975}},{1,{24,24},{925,925}},{1,{24,24},{875,950}},{1,{24,24},{900,350}},{1,{24,24},{25,350}},{1,{24,24},{950,525}},{1,{24,24},{525,950}},{1,{24,24},{925,475}},{1,{24,24},{950,900}},{1,{24,24},{975,850}},{2,{24,24},{275,25}},{1,{24,24},{350,550}},{1,{24,24},{775,100}},{1,{24,24},{275,300}},{1,{24,24},{850,950}},{1,{24,24},{825,650}},{1,{24,24},{950,450}},{1,{24,24},{975,825}},{1,{24,24},{850,925}},{1,{24,24},{125,850}},{1,{24,24},{900,875}},{1,{24,24},{125,275}},{1,{24,24},{900,275}},{2,{24,24},{50,150}},{1,{24,24},{825,925}},{1,{24,24},{725,650}},{1,{24,24},{625,950}},{1,{24,24},{900,850}},{1,{24,24},{475,975}},{1,{24,24},{300,150}},{1,{24,24},{950,800}},{1,{24,24},{175,225}},{1,{24,24},{400,400}},{1,{24,24},{975,775}},{1,{24,24},{350,525}},{1,{24,24},{975,75}},{1,{24,24},{800,925}},{1,{24,24},{825,900}},{1,{24,24},{850,750}},{1,{24,24},{850,875}},{1,{24,24},{350,0}},{1,{24,24},{875,850}},{1,{24,24},{275,875}},{1,{24,24},{400,50}},{1,{24,24},{950,775}},{1,{24,24},{450,125}},{1,{24,24},{975,750}},{1,{24,24},{600,800}},{1,{24,24},{400,450}},{1,{24,24},{150,950}},{1,{24,24},{850,850}},{1,{24,24},{900,800}},{1,{24,24},{925,775}},{1,{24,24},{800,550}},{1,{24,24},{100,600}},{1,{24,24},{75,425}},{1,{24,24},{100,0}},{1,{24,24},{975,725}},{1,{24,24},{650,450}},{1,{24,24},{700,975}},{1,{24,24},{750,875}},{1,{24,24},{475,350}},{1,{24,24},{0,350}},{1,{24,24},{325,175}},{1,{24,24},{725,950}},{2,{24,24},{300,225}},{1,{24,24},{750,775}},{1,{24,24},{25,0}},{1,{24,24},{300,425}},{1,{24,24},{950,600}},{1,{24,24},{475,175}},{2,{24,24},{200,250}},{1,{24,24},{150,700}},{2,{24,24},{100,425}},{1,{24,24},{700,950}},{1,{24,24},{400,475}},{1,{24,24},{725,925}},{1,{24,24},{450,150}},{1,{24,24},{75,700}},{1,{24,24},{575,675}},{1,{24,24},{325,275}},{1,{24,24},{225,175}},{1,{24,24},{775,875}},{1,{24,24},{975,400}},{1,{24,24},{675,875}},{1,{24,24},{800,775}},{1,{24,24},{200,350}},{1,{24,24},{550,500}},{1,{24,24},{175,725}},{2,{24,24},{100,225}},{1,{24,24},{575,525}},{1,{24,24},{75,375}},{1,{24,24},{50,750}},{1,{24,24},{500,400}},{1,{24,24},{250,450}},{1,{24,24},{325,100}},{1,{24,24},{825,250}},{1,{24,24},{900,750}},{1,{24,24},{950,700}},{1,{24,24},{975,675}},{1,{24,24},{425,25}},{1,{24,24},{375,825}},{1,{24,24},{650,975}},{1,{24,24},{375,450}},{1,{24,24},{700,925}},{1,{24,24},{900,175}},{1,{24,24},{800,625}},{1,{24,24},{575,725}},{1,{24,24},{775,850}},{1,{24,24},{275,225}},{1,{24,24},{925,75}},{1,{24,24},{800,825}},{1,{24,24},{700,750}},{1,{24,24},{575,575}},{1,{24,24},{825,800}},{1,{24,24},{850,775}},{1,{24,24},{275,900}},{1,{24,24},{425,100}},{1,{24,24},{900,725}},{1,{24,24},{600,875}},{1,{24,24},{975,650}},{1,{24,24},{850,200}},{1,{24,24},{675,50}},{1,{24,24},{325,625}},{2,{24,24},{225,50}},{1,{24,24},{225,75}},{1,{24,24},{250,175}},{1,{24,24},{800,975}},{1,{24,24},{375,625}},{1,{24,24},{100,375}},{1,{24,24},{850,425}},{1,{24,24},{425,625}},{1,{24,24},{675,925}},{1,{24,24},{700,900}},{1,{24,24},{750,850}},{1,{24,24},{525,975}},{1,{24,24},{400,150}},{1,{24,24},{900,575}},{1,{24,24},{100,225}},{1,{24,24},{350,275}},{1,{24,24},{650,250}},{1,{24,24},{875,425}},{1,{24,24},{200,500}},{1,{24,24},{925,675}},{1,{24,24},{750,25}},{1,{24,24},{950,650}},{1,{24,24},{800,250}},{1,{24,24},{975,625}},{1,{24,24},{700,175}},{1,{24,24},{150,250}},{1,{24,24},{925,200}},{1,{24,24},{50,200}},{1,{24,24},{200,325}},{1,{24,24},{375,75}},{1,{24,24},{800,575}},{1,{24,24},{525,0}},{1,{24,24},{925,525}},{1,{24,24},{875,400}},{1,{24,24},{850,275}},{1,{24,24},{925,750}},{1,{24,24},{875,875}},{1,{24,24},{425,675}},{1,{24,24},{875,25}},{1,{24,24},{925,400}},{1,{24,24},{100,975}},{1,{24,24},{325,0}},{1,{24,24},{675,900}},{1,{24,24},{550,175}},{1,{24,24},{700,875}},{1,{24,24},{475,925}},{1,{24,24},{150,0}},{1,{24,24},{750,825}},{1,{24,24},{50,150}},{1,{24,24},{975,175}},{1,{24,24},{800,650}},{1,{24,24},{775,800}},{1,{24,24},{825,825}},{1,{24,24},{175,825}},{1,{24,24},{850,725}},{1,{24,24},{650,475}},{1,{24,24},{825,150}},{1,{24,24},{450,500}},{1,{24,24},{900,775}},{1,{24,24},{0,975}},{2,{24,24},{75,450}},{2,{24,24},{125,375}},{1,{24,24},{925,650}},{1,{24,24},{225,500}},{1,{24,24},{900,0}},{1,{24,24},{950,25}},{1,{24,24},{575,175}},{1,{24,24},{100,50}},{1,{24,24},{400,925}},{1,{24,24},{225,875}},{1,{24,24},{575,975}},{1,{24,24},{475,100}},{1,{24,24},{650,900}},{1,{24,24},{150,125}},{1,{24,24},{300,100}},{1,{24,24},{725,825}},{2,{24,24},{375,25}},{1,{24,24},{800,750}},{1,{24,24},{700,825}},{1,{24,24},{575,350}},{1,{24,24},{825,725}},{1,{24,24},{175,300}},{1,{24,24},{775,625}},{1,{24,24},{725,450}},{1,{24,24},{275,275}},{1,{24,24},{425,525}},{1,{24,24},{875,675}},{1,{24,24},{900,650}},{1,{24,24},{875,800}},{1,{24,24},{575,550}},{1,{24,24},{975,250}},{1,{24,24},{975,575}},{1,{24,24},{350,575}},{1,{24,24},{725,275}},{1,{24,24},{225,950}},{1,{24,24},{675,850}},{1,{24,24},{175,125}},{1,{24,24},{650,600}},{1,{24,24},{850,825}},{1,{24,24},{825,700}},{1,{24,24},{925,600}},{1,{24,24},{950,575}},{2,{24,24},{25,75}},{1,{24,24},{425,925}},{1,{24,24},{775,825}},{1,{24,24},{625,300}},{1,{24,24},{0,925}},{1,{24,24},{200,375}},{1,{24,24},{175,200}},{1,{24,24},{200,950}},{1,{24,24},{600,650}},{1,{24,24},{700,275}},{1,{24,24},{100,125}},{1,{24,24},{575,925}},{1,{24,24},{600,900}},{1,{24,24},{625,875}},{1,{24,24},{650,50}},{1,{24,24},{700,800}},{1,{24,24},{300,250}},{1,{24,24},{625,125}},{1,{24,24},{50,550}},{1,{24,24},{675,825}},{2,{24,24},{275,250}},{1,{24,24},{750,750}},{1,{24,24},{875,650}},{1,{24,24},{800,700}},{1,{24,24},{25,875}},{1,{24,24},{825,675}},{1,{24,24},{375,575}},{1,{24,24},{125,300}},{1,{24,24},{875,625}},{1,{24,24},{925,575}},{1,{24,24},{825,400}},{1,{24,24},{150,450}},{2,{24,24},{225,175}},{1,{24,24},{850,500}},{1,{24,24},{950,550}},{1,{24,24},{850,475}},{2,{24,24},{375,125}},{1,{24,24},{475,125}},{1,{24,24},{925,700}},{1,{24,24},{375,500}},{1,{24,24},{500,175}},{1,{24,24},{500,975}},{1,{24,24},{725,750}},{1,{24,24},{800,675}},{1,{24,24},{150,800}},{1,{24,24},{925,875}},{1,{24,24},{850,625}},{1,{24,24},{775,50}},{1,{24,24},{800,800}},{1,{24,24},{800,300}},{1,{24,24},{775,700}},{1,{24,24},{775,175}},{1,{24,24},{925,550}},{1,{24,24},{0,75}},{1,{24,24},{125,875}},{1,{24,24},{450,400}},{1,{24,24},{925,825}},{1,{24,24},{975,500}},{1,{24,24},{175,275}},{1,{24,24},{500,900}},{1,{24,24},{400,225}},{1,{24,24},{100,475}},{1,{24,24},{300,625}},{1,{24,24},{575,500}},{1,{24,24},{325,800}},{1,{24,24},{625,775}},{1,{24,24},{575,875}},{1,{24,24},{675,775}},{1,{24,24},{675,200}},{1,{24,24},{550,750}},{1,{24,24},{625,625}},{1,{24,24},{650,325}},{1,{24,24},{800,375}},{1,{24,24},{625,350}},{1,{24,24},{475,825}},{1,{24,24},{775,675}},{1,{24,24},{700,100}},{1,{24,24},{675,75}},{1,{24,24},{250,375}},{1,{24,24},{25,25}},{1,{24,24},{0,325}},{1,{24,24},{875,450}},{1,{24,24},{825,625}},{1,{24,24},{650,100}},{1,{24,24},{850,600}},{1,{24,24},{600,850}},{1,{24,24},{500,275}},{1,{24,24},{725,150}},{1,{24,24},{650,700}},{1,{24,24},{625,0}},{1,{24,24},{800,525}},{1,{24,24},{550,0}},{1,{24,24},{125,50}},{1,{24,24},{975,475}},{2,{24,24},{50,425}},{2,{24,24},{150,50}},{1,{24,24},{300,700}},{1,{24,24},{950,500}},{1,{24,24},{550,875}},{1,{24,24},{475,200}},{1,{24,24},{600,825}},{1,{24,24},{625,800}},{1,{24,24},{650,775}},{1,{24,24},{675,400}},{1,{24,24},{675,750}},{1,{24,24},{325,525}},{2,{24,24},{425,50}},{1,{24,24},{275,125}},{1,{24,24},{700,725}},{1,{24,24},{725,900}},{1,{24,24},{375,150}},{1,{24,24},{800,150}},{1,{24,24},{825,600}},{1,{24,24},{450,100}},{1,{24,24},{850,575}},{1,{24,24},{875,550}},{1,{24,24},{925,500}},{2,{24,24},{100,75}},{1,{24,24},{425,50}},{1,{24,24},{375,700}},{1,{24,24},{200,125}},{1,{24,24},{225,200}},{1,{24,24},{400,625}},{1,{24,24},{200,525}},{1,{24,24},{75,750}},{1,{24,24},{300,25}},{2,{24,24},{0,75}},{1,{24,24},{425,975}},{1,{24,24},{450,950}},{1,{24,24},{150,725}},{1,{24,24},{550,850}},{1,{24,24},{575,825}},{1,{24,24},{550,900}},{1,{24,24},{700,325}},{1,{24,24},{725,675}},{1,{24,24},{800,600}},{2,{24,24},{0,250}},{1,{24,24},{150,600}},{1,{24,24},{825,575}},{1,{24,24},{900,500}},{1,{24,24},{725,475}},{1,{24,24},{300,825}},{1,{24,24},{525,775}},{1,{24,24},{625,725}},{1,{24,24},{750,175}},{1,{24,24},{875,525}},{1,{24,24},{950,850}},{1,{24,24},{975,425}},{1,{24,24},{400,975}},{1,{24,24},{825,225}},{1,{24,24},{925,900}},{1,{24,24},{725,600}},{1,{24,24},{375,375}},{1,{24,24},{325,950}},{1,{24,24},{775,350}},{1,{24,24},{450,75}},{2,{24,24},{175,0}},{1,{24,24},{450,925}},{1,{24,24},{600,700}},{2,{24,24},{75,250}},{1,{24,24},{275,200}},{1,{24,24},{550,450}},{2,{24,24},{250,75}},{1,{24,24},{350,250}},{1,{24,24},{300,375}},{1,{24,24},{500,875}},{1,{24,24},{0,775}},{1,{24,24},{625,675}},{1,{24,24},{50,700}},{1,{24,24},{375,25}},{1,{24,24},{975,350}},{1,{24,24},{600,775}},{1,{24,24},{425,0}},{1,{24,24},{25,625}},{1,{24,24},{625,200}},{1,{24,24},{375,600}},{1,{24,24},{700,675}},{1,{24,24},{525,750}},{1,{24,24},{525,350}},{1,{24,24},{750,625}},{1,{24,24},{375,525}},{1,{24,24},{800,25}},{1,{24,24},{900,475}},{1,{24,24},{250,200}},{1,{24,24},{925,450}},{2,{24,24},{200,325}},{1,{24,24},{850,800}},{1,{24,24},{400,950}},{1,{24,24},{825,550}},{1,{24,24},{450,900}},{1,{24,24},{475,575}},{1,{24,24},{475,875}},{1,{24,24},{500,850}},{1,{24,24},{625,500}},{1,{24,24},{925,325}},{1,{24,24},{275,350}},{1,{24,24},{400,750}},{1,{24,24},{600,750}},{1,{24,24},{25,575}},{1,{24,24},{550,800}},{1,{24,24},{75,175}},{1,{24,24},{675,675}},{1,{24,24},{700,650}},{1,{24,24},{275,925}},{1,{24,24},{675,225}},{1,{24,24},{750,600}},{1,{24,24},{950,750}},{1,{24,24},{675,125}},{1,{24,24},{825,525}},{1,{24,24},{875,475}},{2,{24,24},{100,25}},{1,{24,24},{950,400}},{1,{24,24},{450,675}},{1,{24,24},{800,50}},{1,{24,24},{950,625}},{1,{24,24},{25,775}},{1,{24,24},{625,550}},{1,{24,24},{600,600}},{1,{24,24},{725,75}},{1,{24,24},{625,75}},{1,{24,24},{575,125}},{1,{24,24},{975,450}},{1,{24,24},{150,175}},{1,{24,24},{675,575}},{1,{24,24},{25,375}},{1,{24,24},{425,900}},{1,{24,24},{400,275}},{1,{24,24},{275,600}},{1,{24,24},{975,25}},{1,{24,24},{875,275}},{1,{24,24},{400,525}},{1,{24,24},{550,600}},{1,{24,24},{450,875}},{2,{24,24},{25,275}},{1,{24,24},{75,975}},{1,{24,24},{0,225}},{1,{24,24},{600,725}},{1,{24,24},{25,800}},{1,{24,24},{625,700}},{1,{24,24},{700,625}},{1,{24,24},{650,375}},{1,{24,24},{900,550}},{1,{24,24},{775,550}},{1,{24,24},{850,75}},{1,{24,24},{800,475}},{1,{24,24},{900,425}},{1,{24,24},{325,975}},{1,{24,24},{425,800}},{1,{24,24},{650,725}},{1,{24,24},{350,950}},{1,{24,24},{825,875}},{1,{24,24},{450,850}},{1,{24,24},{250,925}},{1,{24,24},{450,600}},{1,{24,24},{725,725}},{1,{24,24},{575,150}},{1,{24,24},{675,950}},{1,{24,24},{125,350}},{1,{24,24},{800,100}},{1,{24,24},{425,225}},{1,{24,24},{675,625}},{1,{24,24},{450,975}},{1,{24,24},{225,50}},{1,{24,24},{750,550}},{1,{24,24},{550,825}},{2,{24,24},{275,175}},{1,{24,24},{175,375}},{1,{24,24},{825,475}},{1,{24,24},{825,775}},{1,{24,24},{0,375}},{1,{24,24},{750,225}},{1,{24,24},{900,400}},{1,{24,24},{650,25}},{1,{24,24},{300,975}},{1,{24,24},{525,75}},{1,{24,24},{400,875}},{1,{24,24},{425,850}},{1,{24,24},{850,150}},{1,{24,24},{450,825}},{2,{24,24},{50,225}},{1,{24,24},{225,25}},{1,{24,24},{0,400}},{1,{24,24},{625,650}},{1,{24,24},{650,625}},{1,{24,24},{300,50}},{1,{24,24},{550,25}},{1,{24,24},{750,525}},{1,{24,24},{775,500}},{1,{24,24},{925,350}},{1,{24,24},{850,325}},{1,{24,24},{275,0}},{1,{24,24},{975,300}},{1,{24,24},{750,325}},{2,{24,24},{25,475}},{1,{24,24},{325,925}},{1,{24,24},{350,900}},{1,{24,24},{525,600}},{1,{24,24},{750,250}},{1,{24,24},{475,550}},{1,{24,24},{475,775}},{1,{24,24},{400,850}},{1,{24,24},{500,750}},{1,{24,24},{575,275}},{1,{24,24},{750,900}},{1,{24,24},{900,225}},{1,{24,24},{700,550}},{1,{24,24},{0,450}},{1,{24,24},{725,525}},{1,{24,24},{750,500}},{1,{24,24},{800,0}},{1,{24,24},{825,425}},{1,{24,24},{750,300}},{1,{24,24},{175,25}},{1,{24,24},{0,50}},{1,{24,24},{650,875}},{1,{24,24},{75,100}},{1,{24,24},{850,400}},{1,{24,24},{25,75}},{1,{24,24},{875,375}},{1,{24,24},{175,700}},{1,{24,24},{475,250}},{1,{24,24},{950,50}},{1,{24,24},{100,625}},{1,{24,24},{275,175}},{1,{24,24},{575,425}},{1,{24,24},{575,775}},{1,{24,24},{725,375}},{1,{24,24},{125,700}},{1,{24,24},{450,625}},{1,{24,24},{225,625}},{1,{24,24},{250,975}},{1,{24,24},{800,875}},{1,{24,24},{150,225}},{1,{24,24},{425,550}},{1,{24,24},{450,700}},{1,{24,24},{350,875}},{1,{24,24},{350,325}},{1,{24,24},{100,750}},{1,{24,24},{325,900}},{1,{24,24},{400,825}},{1,{24,24},{375,850}},{2,{24,24},{0,225}},{1,{24,24},{25,275}},{1,{24,24},{225,900}},{1,{24,24},{850,225}},{1,{24,24},{475,675}},{1,{24,24},{550,325}},{1,{24,24},{225,525}},{1,{24,24},{600,625}},{1,{24,24},{625,600}},{1,{24,24},{600,575}},{1,{24,24},{650,575}},{1,{24,24},{725,500}},{1,{24,24},{0,750}},{1,{24,24},{675,550}},{1,{24,24},{200,675}},{1,{24,24},{850,375}},{1,{24,24},{525,725}},{1,{24,24},{350,50}},{1,{24,24},{475,475}},{1,{24,24},{950,275}},{1,{24,24},{200,575}},{1,{24,24},{225,975}},{2,{24,24},{75,175}},{1,{24,24},{925,225}},{1,{24,24},{50,925}},{1,{24,24},{325,875}},{1,{24,24},{625,375}},{1,{24,24},{350,400}},{1,{24,24},{350,850}},{1,{24,24},{425,775}},{1,{24,24},{200,900}},{1,{24,24},{550,650}},{1,{24,24},{425,175}},{1,{24,24},{675,525}},{1,{24,24},{950,100}},{1,{24,24},{475,0}},{1,{24,24},{175,50}},{1,{24,24},{650,750}},{1,{24,24},{125,375}},{1,{24,24},{125,525}},{1,{24,24},{550,250}},{1,{24,24},{850,100}},{1,{24,24},{75,575}},{1,{24,24},{825,375}},{1,{24,24},{375,175}},{1,{24,24},{25,225}},{1,{24,24},{650,950}},{1,{24,24},{250,900}},{1,{24,24},{250,400}},{1,{24,24},{975,225}},{1,{24,24},{600,550}},{1,{24,24},{50,600}},{1,{24,24},{0,575}},{1,{24,24},{200,975}},{1,{24,24},{675,250}},{1,{24,24},{625,900}},{1,{24,24},{250,300}},{1,{24,24},{700,50}},{1,{24,24},{875,750}},{1,{24,24},{325,850}},{1,{24,24},{250,475}},{1,{24,24},{325,350}},{1,{24,24},{600,150}},{1,{24,24},{25,175}},{1,{24,24},{175,75}},{1,{24,24},{350,825}},{1,{24,24},{375,725}},{1,{24,24},{400,775}},{1,{24,24},{425,750}},{1,{24,24},{475,700}},{1,{24,24},{300,775}},{1,{24,24},{500,150}},{1,{24,24},{75,625}},{1,{24,24},{475,225}},{1,{24,24},{175,900}},{1,{24,24},{550,625}},{1,{24,24},{200,875}},{1,{24,24},{350,300}},{1,{24,24},{125,200}},{1,{24,24},{300,850}},{1,{24,24},{375,400}},{1,{24,24},{675,500}},{2,{24,24},{25,25}},{1,{24,24},{650,400}},{1,{24,24},{825,350}},{1,{24,24},{175,875}},{1,{24,24},{625,225}},{1,{24,24},{525,450}},{1,{24,24},{950,825}},{1,{24,24},{200,100}},{1,{24,24},{125,25}},{1,{24,24},{750,700}},{1,{24,24},{150,25}},{1,{24,24},{275,725}},{1,{24,24},{50,25}},{1,{24,24},{375,225}},{1,{24,24},{975,200}},{1,{24,24},{225,925}},{1,{24,24},{950,250}},{1,{24,24},{300,125}},{1,{24,24},{450,350}},{1,{24,24},{925,800}},{1,{24,24},{350,800}},{1,{24,24},{425,725}},{1,{24,24},{825,0}},{1,{24,24},{950,300}},{2,{24,24},{150,125}},{1,{24,24},{250,675}},{1,{24,24},{750,400}},{1,{24,24},{225,300}},{1,{24,24},{200,300}},{1,{24,24},{800,350}},{2,{24,24},{450,0}},{1,{24,24},{900,250}},{1,{24,24},{125,475}},{1,{24,24},{425,375}},{1,{24,24},{400,175}},{1,{24,24},{625,325}},{1,{24,24},{975,975}},{1,{24,24},{175,475}},{1,{24,24},{500,725}},{1,{24,24},{750,100}},{1,{24,24},{100,650}},{1,{24,24},{775,275}},{1,{24,24},{275,500}},{1,{24,24},{475,650}},{1,{24,24},{975,375}},{2,{24,24},{300,125}},{1,{24,24},{375,875}},{1,{24,24},{750,50}},{1,{24,24},{425,875}},{2,{24,24},{350,75}},{1,{24,24},{800,325}},{1,{24,24},{250,775}},{1,{24,24},{950,175}},{1,{24,24},{975,150}},{1,{24,24},{200,225}},{1,{24,24},{175,925}},{1,{24,24},{650,550}},{1,{24,24},{175,650}},{1,{24,24},{975,600}},{1,{24,24},{50,725}},{1,{24,24},{0,200}},{1,{24,24},{300,0}},{1,{24,24},{825,300}},{2,{24,24},{325,125}},{1,{24,24},{250,425}},{1,{24,24},{200,450}},{1,{24,24},{200,425}},{2,{24,24},{225,25}},{1,{24,24},{250,25}},{1,{24,24},{375,800}},{1,{24,24},{475,625}},{1,{24,24},{175,450}},{1,{24,24},{450,650}},{1,{24,24},{400,700}},{1,{24,24},{750,125}},{1,{24,24},{850,700}},{1,{24,24},{275,750}},{1,{24,24},{550,550}},{1,{24,24},{500,600}},{1,{24,24},{450,575}},{1,{24,24},{50,100}},{1,{24,24},{600,500}},{1,{24,24},{150,400}},{1,{24,24},{350,450}},{1,{24,24},{100,725}},{1,{24,24},{625,475}},{1,{24,24},{100,425}},{1,{24,24},{300,475}},{1,{24,24},{975,100}},{1,{24,24},{725,175}},{1,{24,24},{700,400}},{1,{24,24},{75,25}},{1,{24,24},{450,225}},{2,{24,24},{250,150}},{1,{24,24},{675,350}},{1,{24,24},{950,425}},{1,{24,24},{925,175}},{1,{24,24},{975,125}},{1,{24,24},{550,475}},{1,{24,24},{500,700}},{1,{24,24},{575,600}},{1,{24,24},{225,850}},{1,{24,24},{250,825}},{1,{24,24},{550,400}},{1,{24,24},{275,800}},{1,{24,24},{375,125}},{1,{24,24},{525,650}},{1,{24,24},{325,750}},{1,{24,24},{400,675}},{1,{24,24},{350,725}},{1,{24,24},{350,650}},{1,{24,24},{225,100}},{1,{24,24},{425,650}},{1,{24,24},{975,275}},{1,{24,24},{525,525}},{1,{24,24},{500,575}},{1,{24,24},{25,50}},{1,{24,24},{100,875}},{1,{24,24},{550,275}},{1,{24,24},{350,75}},{1,{24,24},{500,950}},{1,{24,24},{725,975}},{1,{24,24},{450,775}},{1,{24,24},{275,25}},{1,{24,24},{300,400}},{2,{24,24},{175,25}},{2,{24,24},{325,225}},{1,{24,24},{875,200}},{1,{24,24},{350,475}},{1,{24,24},{50,850}},{1,{24,24},{225,750}},{1,{24,24},{325,575}},{1,{24,24},{925,150}},{1,{24,24},{575,750}},{1,{24,24},{325,150}},{1,{24,24},{275,325}},{1,{24,24},{600,0}},{1,{24,24},{425,300}},{1,{24,24},{850,550}},{1,{24,24},{725,25}},{1,{24,24},{50,650}},{1,{24,24},{125,925}},{1,{24,24},{750,350}},{1,{24,24},{925,425}},{1,{24,24},{350,100}},{1,{24,24},{775,325}},{1,{24,24},{625,425}},{1,{24,24},{0,25}},{1,{24,24},{725,325}},{1,{24,24},{600,450}},{1,{24,24},{375,750}},{1,{24,24},{875,175}},{1,{24,24},{600,275}},{1,{24,24},{925,125}},{1,{24,24},{525,275}},{1,{24,24},{0,275}},{1,{24,24},{925,0}},{1,{24,24},{775,950}},{1,{24,24},{75,950}},{1,{24,24},{175,350}},{1,{24,24},{100,925}},{1,{24,24},{125,900}},{1,{24,24},{175,250}},{1,{24,24},{175,850}},{1,{24,24},{200,825}},{1,{24,24},{225,800}},{1,{24,24},{825,125}},{1,{24,24},{875,250}},{1,{24,24},{425,600}},{1,{24,24},{500,525}},{1,{24,24},{575,450}},{1,{24,24},{325,200}},{1,{24,24},{500,125}},{1,{24,24},{125,750}},{1,{24,24},{300,300}},{1,{24,24},{275,400}},{1,{24,24},{700,25}},{2,{24,24},{100,275}},{2,{24,24},{100,100}},{1,{24,24},{150,925}},{1,{24,24},{750,275}},{1,{24,24},{225,600}},{1,{24,24},{775,250}},{1,{24,24},{325,75}},{1,{24,24},{275,850}},{1,{24,24},{675,100}},{1,{24,24},{875,150}},{1,{24,24},{150,425}},{1,{24,24},{900,125}},{1,{24,24},{350,125}},{1,{24,24},{200,800}},{1,{24,24},{150,325}},{1,{24,24},{975,50}},{1,{24,24},{250,275}},{1,{24,24},{300,275}},{2,{24,24},{75,150}},{1,{24,24},{150,850}},{1,{24,24},{950,75}},{2,{24,24},{150,325}},{1,{24,24},{975,950}},{1,{24,24},{250,575}},{1,{24,24},{525,900}},{1,{24,24},{625,250}},{1,{24,24},{400,600}},{1,{24,24},{425,575}},{1,{24,24},{475,525}},{1,{24,24},{500,500}},{1,{24,24},{100,800}},{1,{24,24},{250,225}},{1,{24,24},{25,750}},{1,{24,24},{525,475}},{1,{24,24},{600,400}},{1,{24,24},{675,325}},{1,{24,24},{575,950}},{1,{24,24},{425,825}},{1,{24,24},{400,425}},{1,{24,24},{675,175}},{1,{24,24},{150,625}},{1,{24,24},{200,175}},{1,{24,24},{550,575}},{1,{24,24},{225,275}},{1,{24,24},{375,0}},{1,{24,24},{350,925}},{1,{24,24},{825,175}},{1,{24,24},{175,400}},{1,{24,24},{25,950}},{1,{24,24},{150,825}},{1,{24,24},{400,550}},{1,{24,24},{525,375}},{1,{24,24},{350,625}},{1,{24,24},{275,700}},{1,{24,24},{500,475}},{1,{24,24},{550,950}},{1,{24,24},{200,475}},{1,{24,24},{225,575}},{1,{24,24},{775,75}},{1,{24,24},{275,375}},{1,{24,24},{725,250}},{1,{24,24},{600,200}},{1,{24,24},{100,250}},{1,{24,24},{200,550}},{1,{24,24},{875,500}},{1,{24,24},{850,125}},{1,{24,24},{925,50}},{1,{24,24},{975,0}},{1,{24,24},{0,950}},{1,{24,24},{25,850}},{1,{24,24},{675,150}},{1,{24,24},{375,300}},{1,{24,24},{125,125}},{1,{24,24},{25,550}},{1,{24,24},{25,925}},{1,{24,24},{100,850}},{1,{24,24},{800,500}},{1,{24,24},{275,75}},{1,{24,24},{225,725}},{1,{24,24},{125,800}},{1,{24,24},{775,25}},{1,{24,24},{275,675}},{1,{24,24},{550,100}},{1,{24,24},{925,950}},{1,{24,24},{625,975}},{1,{24,24},{900,600}},{1,{24,24},{350,600}},{1,{24,24},{650,300}},{1,{24,24},{675,275}},{1,{24,24},{900,50}},{1,{24,24},{50,875}},{1,{24,24},{75,850}},{1,{24,24},{50,575}},{1,{24,24},{175,750}},{1,{24,24},{300,225}},{1,{24,24},{225,700}},{1,{24,24},{675,475}},{1,{24,24},{525,225}},{2,{24,24},{200,150}},{1,{24,24},{550,375}},{1,{24,24},{525,400}},{1,{24,24},{850,350}},{2,{24,24},{225,150}},{2,{24,24},{350,150}},{1,{24,24},{825,100}},{1,{24,24},{0,125}},{1,{24,24},{875,50}},{1,{24,24},{75,825}},{1,{24,24},{525,800}},{2,{24,24},{350,25}},{1,{24,24},{250,325}},{1,{24,24},{250,650}},{1,{24,24},{275,625}},{1,{24,24},{675,300}},{1,{24,24},{125,325}},{1,{24,24},{0,300}},{1,{24,24},{875,925}},{1,{24,24},{600,125}},{1,{24,24},{50,300}},{1,{24,24},{175,675}},{1,{24,24},{425,475}},{1,{24,24},{475,425}},{1,{24,24},{325,650}},{1,{24,24},{625,275}},{1,{24,24},{25,475}},{1,{24,24},{750,150}},{1,{24,24},{725,0}},{1,{24,24},{225,650}},{1,{24,24},{800,225}},{1,{24,24},{650,925}},{1,{24,24},{100,775}},{1,{24,24},{75,800}},{1,{24,24},{325,550}},{1,{24,24},{250,525}},{1,{24,24},{525,200}},{2,{24,24},{350,200}},{1,{24,24},{900,150}},{1,{24,24},{325,675}},{2,{24,24},{275,100}},{1,{24,24},{25,825}},{1,{24,24},{125,725}},{1,{24,24},{775,650}},{1,{24,24},{350,500}},{1,{24,24},{175,150}},{1,{24,24},{725,400}},{1,{24,24},{900,975}},{1,{24,24},{775,450}},{1,{24,24},{775,225}},{1,{24,24},{825,25}},{1,{24,24},{500,200}},{1,{24,24},{550,225}},{1,{24,24},{150,675}},{2,{24,24},{50,400}},{1,{24,24},{525,550}},{1,{24,24},{650,175}},{1,{24,24},{750,75}},{1,{24,24},{875,600}},{1,{24,24},{275,425}},{1,{24,24},{250,500}},{1,{24,24},{175,625}},{1,{24,24},{0,700}},{1,{24,24},{125,0}},{1,{24,24},{200,600}},{1,{24,24},{250,550}},{1,{24,24},{400,350}},{1,{24,24},{25,700}},{1,{24,24},{800,400}},{1,{24,24},{625,175}},{1,{24,24},{675,450}},{1,{24,24},{800,450}},{1,{24,24},{625,25}},{1,{24,24},{925,375}},{1,{24,24},{0,500}},{1,{24,24},{675,425}},{1,{24,24},{425,350}},{1,{24,24},{450,325}},{1,{24,24},{225,550}},{1,{24,24},{650,125}},{1,{24,24},{375,350}},{1,{24,24},{700,75}},{1,{24,24},{725,50}},{1,{24,24},{150,200}},{1,{24,24},{775,0}},{1,{24,24},{625,750}},{1,{24,24},{75,675}},{1,{24,24},{25,125}},{1,{24,24},{575,50}},{1,{24,24},{825,75}},{1,{24,24},{800,175}},{1,{24,24},{275,475}},{1,{24,24},{275,525}},{1,{24,24},{275,150}},{1,{24,24},{425,500}},{1,{24,24},{50,675}},{1,{24,24},{150,575}},{1,{24,24},{75,75}},{1,{24,24},{425,400}},{1,{24,24},{450,275}},{1,{24,24},{100,700}},{1,{24,24},{225,225}},{1,{24,24},{375,325}},{1,{24,24},{50,625}},{1,{24,24},{0,475}},{1,{24,24},{75,875}},{1,{24,24},{525,150}},{1,{24,24},{675,700}},{1,{24,24},{750,450}},{1,{24,24},{275,825}},{1,{24,24},{450,200}},{1,{24,24},{150,350}},{1,{24,24},{650,650}},{1,{24,24},{875,700}},{1,{24,24},{575,75}},{2,{24,24},{175,150}},{1,{24,24},{150,475}},{1,{24,24},{75,525}},{1,{24,24},{975,925}},{1,{24,24},{450,175}},{1,{24,24},{475,150}},{1,{24,24},{0,600}},{1,{24,24},{375,250}},{1,{24,24},{925,250}},{2,{24,24},{125,225}},{1,{24,24},{100,150}},{1,{24,24},{125,650}},{1,{24,24},{125,450}},{1,{24,24},{75,200}},{1,{24,24},{625,450}},{1,{24,24},{700,575}},{1,{24,24},{400,25}},{1,{24,24},{525,575}},{1,{24,24},{525,25}},{2,{24,24},{200,25}},{1,{24,24},{350,175}},{1,{24,24},{625,150}},{1,{24,24},{175,325}},{1,{24,24},{425,75}},{1,{24,24},{25,450}},{1,{24,24},{500,550}},{1,{24,24},{125,975}},{1,{24,24},{575,700}},{1,{24,24},{225,150}},{2,{24,24},{400,50}},{1,{24,24},{250,50}},{1,{24,24},{150,75}}}}}

    local iconIndices: { string } = icons[1]
    local idIndices: { string } = icons[2]
    local iconRegistry: { [number]: { number | { number } } } = icons[3]

    Lucide.Icons = iconIndices
    function Lucide.GetAsset(name: string)
        local size = 48

        local iconIndex = table.find(iconIndices, name)

        if not iconIndex then
            return nil
        end

        local currentDifference = math.huge
        local currentSize = size

        for registrySize, _ in iconRegistry do
            local diff = math.abs(size - registrySize)

            if diff < currentDifference then
                currentDifference = diff
                currentSize = registrySize
            end
        end

        local icon = iconRegistry[currentSize][iconIndex]
        if icon then
            return {
                IconName = name,
                Url = idIndices[icon[1]],
                ImageRectSize = Vector2.new(icon[2][1], icon[2][2]),
                ImageRectOffset = Vector2.new(icon[3][1], icon[3][2]),
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
        return { Url = "rbxassetid://" .. tostring(Name), ImageRectOffset = Vector2.zero, ImageRectSize = Vector2.zero }
    end

    if IsUrl(Name) then
        return { Url = Name, ImageRectOffset = Vector2.zero, ImageRectSize = Vector2.zero, Custom = true }
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
    if IsLightTheme(themeName) then
        ImageGui.ImageColor3 = ImageGui:GetAttribute("MainTitleIcon") and Color3.fromRGB(15, 17, 20) or Color3.fromRGB(50, 55, 60)
        if ImageGui:GetAttribute("MainTitleIcon") then ImageGui.ImageTransparency = math.min(ImageGui.ImageTransparency, 0.12) end
    end

    if Rotation then
        ImageGui.Rotation = Rotation
    end

    ImageGui.Image = Icon.Url or ImageGui.Image
    ImageGui.ImageRectOffset = Icon.ImageRectOffset or ImageGui.ImageRectOffset
    ImageGui.ImageRectSize = Icon.ImageRectSize or ImageGui.ImageRectSize
end

local UI = Create("ScreenGui", {
    DisplayOrder = 998,
    Name = "Library",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})

ParentUI(UI)

local AddAnimatedBorder

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
        task.delay(0.55, function()
            if token ~= TooltipToken or not Target.Parent or not UI.Parent or Library.Unloaded or Library.Opened == false then return end
            if not TooltipBox or not TooltipBox.Parent then
                TooltipBox = Create("Frame", {Name = "Tooltip", BackgroundColor3 = ThemeColor(30,30,30), Visible = false, ZIndex = 100, Parent = UI})
                Create("UICorner", {CornerRadius = UDim.new(0, 7), Parent = TooltipBox})
                Create("UIStroke", {Color = ThemeColor(80,80,80), Thickness = 1, Parent = TooltipBox})
                TooltipText = Create("TextLabel", {BackgroundTransparency = 1, FontFace = regularFont, TextColor3 = ThemeColor(255,255,255), TextSize = 14, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.fromOffset(10, 6), Size = UDim2.new(1, -20, 1, -12), ZIndex = 101, Parent = TooltipBox})
            end
            TooltipText.Text = Content
            TooltipBox.BackgroundColor3 = ThemeColor(30,30,30)
            local bounds = GetTextBounds(Content, regularFont, 14, 230) or Vector2.new(120, 18)
            local width, height = math.clamp(bounds.X + 20, 100, 250), math.max(30, bounds.Y + 12)
            local camera = workspace.CurrentCamera
            local viewport = camera and camera.ViewportSize or Vector2.new(800, 600)
            local pos = Target.AbsolutePosition
            local x = math.clamp(pos.X, 4, math.max(4, viewport.X - width - 4))
            local y = pos.Y + Target.AbsoluteSize.Y + 6
            if y + height > viewport.Y - 4 then y = math.max(4, pos.Y - height - 6) end
            TooltipBox.Position, TooltipBox.Size = UDim2.fromOffset(x,y), UDim2.fromOffset(width,height)
            TooltipBox.Visible = true
        end)
    end
    Library:AddConnection(Target.MouseEnter:Connect(ShowLater))
    Library:AddConnection(Target.MouseLeave:Connect(Hide))
    Library:AddConnection(Target.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.Touch then ShowLater() end end))
    Library:AddConnection(Target.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.Touch then Hide() end end))
end


local Windows = Create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundTransparency = 1,
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.new(1, -12, 1, -12),
    Parent = UI
})

local Notifications = Create("Frame", {
    AnchorPoint = Vector2.new(1, 1),
    BackgroundTransparency = 1,
    Position = UDim2.new(1, -8, 1, -8),
    Size = UDim2.new(0, 480, 1, -12),
    Parent = UI
})

Create("UIListLayout", {
    HorizontalAlignment = Enum.HorizontalAlignment.Right,
    VerticalAlignment = Enum.VerticalAlignment.Bottom,
    Padding = UDim.new(0, 6),
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

local FastTween = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

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
    return string.format("%s/%s.json", dir, name)
end

function Library:GetAutoloadPath()
    local dir = self:GetConfigDirectory()
    if not dir then return nil end
    return dir .. "/autoload.txt"
end

function Library:EnsureConfigFolder()
    local dir = self:GetConfigDirectory()
    if not dir then return false end
    if not isfolder(dir) then
        makefolder(dir)
    end
    return isfolder(dir)
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

ElementSerializers.ElementToggle = {
    Save = function(flag, el)
        return {
            type = "ElementToggle", idx = flag,
            value = el.Value and true or false,
            mode = el.Mode or "Toggle",
            keybind = el.Keybind and tostring(el.Keybind) or "nil",
        }
    end,
    Load = function(flag, data)
        local el = Library.Flags[flag]
        if not el or el.Type ~= "ElementToggle" then return end
        el:Set(data.value and true or false)
        if data.mode then el.Mode = data.mode end
        if data.keybind ~= nil then
            local kb = GetKeybindFromString(data.keybind)
            el:SetKeybind(kb)
        end
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
        local col = Color3.fromHex(data.color or "ffffff")
        el:SetRainbow(false)
        el:SetColor(col)
        if data.transparency ~= nil then el:SetTransparency(data.transparency) end
        if data.rainbow ~= nil then el:SetRainbow(data.rainbow) end
    end,
}

function Library:RefreshConfigList()
    local dir = self:GetConfigDirectory()
    if not dir then return {} end
    if not isfolder(dir) then makefolder(dir) end

    local files = listfiles(dir)
    local names = {}
    for _, full in ipairs(files) do
        local fname = full:match("([^/\\]+)%.json$")
        if fname and fname ~= "autoload" and fname ~= "Favorites" and fname ~= "CommandFavorites" then
            table.insert(names, fname)
        end
    end
    return names
end

function Library:SaveConfigData(name)
    local data = {
        timestamp = os.date("%d.%m.%Y %H:%M:%S"),
        name = name or "",
        objects = {},
    }

    for flag, el in pairs(Library.Flags) do
        if el.Type then
            local serializer = ElementSerializers[el.Type]
            if serializer then
                local entry = serializer.Save(flag, el)
                if entry then
                    table.insert(data.objects, entry)
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
        ElementToggle = true,
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
                table.insert(bucketToggles, opt)
            elseif StartsWithNumber(opt.idx) then
                table.insert(bucketPriority, opt)
            else
                table.insert(bucketToggles, nil)
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
                table.insert(bucketToggles, opt)
            elseif StartsWithNumber(opt.idx) then
                table.insert(bucketPriority, opt)
            else
                table.insert(bucketNormal, opt)
            end
        end
    end

    local function apply(list)
        for _, opt in ipairs(list) do
            local serializer = ElementSerializers[opt.type]
            if serializer then
                task.defer(serializer.Load, opt.idx, opt)
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
    writefile(path, encoded)
    return true
end

function Library:LoadConfig(name)
    if IsStringEmpty(name) then return false, "No config selected" end
    local path = self:GetConfigPath(name)
    if not path or not isfile(path) then return false, "Config does not exist" end

    local content = readfile(path)
    return self:LoadConfigData(content)
end

function Library:DeleteConfig(name)
    if IsStringEmpty(name) then return false, "No config selected" end
    local path = self:GetConfigPath(name)
    if not path or not isfile(path) then return false, "Config does not exist" end

    delfile(path)
    if name == self.AutoloadConfigName then
        self:DeleteAutoloadConfig()
    end
    return true
end

function Library:GetAutoloadConfig()
    self:EnsureConfigFolder()
    local path = self:GetAutoloadPath()
    if not path or not isfile(path) then return "None", false end

    local name = readfile(path)
    if typeof(name) ~= "string" then return "None", false end
    if not self:GetConfigPath(name) or not isfile(self:GetConfigPath(name)) then
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
    if not self:GetConfigPath(name) or not isfile(self:GetConfigPath(name)) then
        return false, "Config does not exist"
    end
    writefile(path, name)
    self.AutoloadConfigName = name
    return true
end

function Library:DeleteAutoloadConfig()
    self:EnsureConfigFolder()
    local path = self:GetAutoloadPath()
    if not path or not isfile(path) then return false, "Not set" end
    delfile(path)
    self.AutoloadConfigName = nil
    return true
end

function Library:LoadAutoloadConfig()
    local name, ok = self:GetAutoloadConfig()
    if not ok then return end
    self:LoadConfig(name)
end


-- Palette feature registry: controls remain the source of truth.
Library._PaletteFeatures = {}
Library._PaletteLocks = {}
local function PaletteValueText(value)
    if typeof(value) == "Color3" then return "#" .. value:ToHex():upper() end
    if typeof(value) == "EnumItem" then return value.Name end
    if type(value) == "table" then
        local names = {}
        for key, active in pairs(value) do if active == true then table.insert(names, tostring(key)) end end
        table.sort(names)
        return #names > 0 and table.concat(names, ", ") or "None"
    end
    if value == nil then return "None" end
    if type(value) == "boolean" then return value and "true" or "false" end
    return tostring(value)
end
local function RefreshPaletteValue()
    local overlay = UI:FindFirstChild("CommandPaletteOverlay")
    if overlay and overlay.Visible and Library.RefreshCommandPalette and not Library._PaletteBatch then Library:RefreshCommandPalette() end
end
local function ResolvePaletteOptions(control, raw)
    local resolved, seen = {}, {}
    local values = control.Values or {}
    for part in (raw .. ","):gmatch("(.-),") do
        local query = part:match("^%s*(.-)%s*$"):lower()
        if query == "" then return nil, "Enter an option between commas." end
        local best, bestDistance, ambiguous = nil, math.huge, false
        for key, item in pairs(values) do
            local option = type(key) == "number" and item or key
            local candidate = tostring(option):lower()
            if #query <= 128 and #candidate <= 128 then
                local matrix = {}
                for i = 0, #query do matrix[i] = {[0] = i} end
                for j = 0, #candidate do matrix[0][j] = j end
                for i = 1, #query do for j = 1, #candidate do
                    local cost = query:sub(i,i) == candidate:sub(j,j) and 0 or 1
                    local d = math.min(matrix[i-1][j] + 1, matrix[i][j-1] + 1, matrix[i-1][j-1] + cost)
                    if i > 1 and j > 1 and query:sub(i,i) == candidate:sub(j-1,j-1) and query:sub(i-1,i-1) == candidate:sub(j,j) then d = math.min(d, matrix[i-2][j-2] + 1) end
                    matrix[i][j] = d
                end end
                local score = matrix[#query][#candidate]
                if score < bestDistance then best, bestDistance, ambiguous = option, score, false
                elseif score == bestDistance then ambiguous = true end
            end
        end
        local limit = #query >= 5 and 2 or 1
        if best == nil or bestDistance > limit or ambiguous then return nil, "Option not found or ambiguous: " .. part end
        if not seen[best] then table.insert(resolved, best); seen[best] = true end
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
            elseif type(entry.DisplayFormat) == "string" then local ok, formatted = pcall(string.format, entry.DisplayFormat, type(value) == "table" and PaletteValueText(value) or value); if ok then return formatted end end
            return PaletteValueText(value)
        end,
        Callback = function(args)
            for category, locked in pairs(Library._PaletteLocks) do
                if locked and (entry.Category == category or entry.Category:sub(1, #category + 3) == category .. " / ") then return end
            end
            if entry.Control and entry.Control.Locked then return end
            if entry.Kind == "Button" then if entry.Activate then entry.Activate() end; return end
            local raw = table.concat(args or {}, " ")
            local current = entry.GetValue and entry.GetValue() or nil
            local value = raw
            if entry.Kind == "Toggle" then
                local lower = raw:lower()
                if lower == "" or lower == "toggle" then value = not current
                elseif lower == "true" or lower == "on" or lower == "1" then value = true
                elseif lower == "false" or lower == "off" or lower == "0" then value = false
                else warn("Use on, off or toggle for " .. entry.Name); return end
            elseif entry.Kind == "Slider" then
                value = tonumber(raw)
                if not value or value ~= value or value == math.huge or value == -math.huge then warn("Enter a number for " .. entry.Name); return end
            elseif entry.Kind == "Keybind" then
                if raw:lower() == "none" then value = nil else value = GetKeybindFromString(raw); if not value then warn("Invalid keybind: " .. raw); return end end
            elseif entry.Kind == "Color" then
                local hex = raw:match("^#?(%x%x%x%x%x%x)$")
                local r, g, b = raw:match("^(%d+)%s*,%s*(%d+)%s*,%s*(%d+)$")
                if hex then value = Color3.fromHex(hex)
                elseif r and tonumber(r) <= 255 and tonumber(g) <= 255 and tonumber(b) <= 255 then value = Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b))
                else warn("Use #RRGGBB or R, G, B for " .. entry.Name); return end
            elseif entry.Kind == "Dropdown" and entry.Control then
                if raw == "" then return end
                local selected, errorMessage = ResolvePaletteOptions(entry.Control, raw)
                if not selected then warn(errorMessage); return end
                if entry.Control.Multi then
                    local nextValues = table.clone(entry.Control.Value or {})
                    for _, option in ipairs(selected) do
                        if #selected == 1 then nextValues[option] = not nextValues[option] or nil else nextValues[option] = true end
                    end
                    value = nextValues
                else value = selected[1] end
            elseif raw == "" then return end
            if entry.SetValue then entry.SetValue(value) end
            RefreshPaletteValue()
        end,
    })
    entry.Published = true
end
function Library:RegisterPaletteFeature(info)
    assert(type(info) == "table" and type(info.Name) == "string" and info.Name:match("%S"), "A feature needs a name")
    local entry = {Name = info.Name, Category = tostring(info.Category or info.Section or "Custom"), Kind = info.Kind or info.Type or "Custom",
        Control = info.Control, GetValue = info.GetValue or info.Get, SetValue = info.SetValue or info.Set,
        Description = info.Description, Activate = info.Activate, Icon = info.Icon, Tag = info.Tag or info.Label, DisplayFormat = info.DisplayFormat, Auto = info.Auto == true}
    table.insert(self._PaletteFeatures, entry)
    PublishPaletteFeature(entry)
    function entry:Refresh() RefreshPaletteValue() end
    function entry:Destroy()
        if self.Published and Library.RemoveCommand then Library:RemoveCommand(self.CommandName) end
        self.Published = false
        local index = table.find(Library._PaletteFeatures, self)
        if index then table.remove(Library._PaletteFeatures, index) end
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
            local values = table.pack(original(self, ...))
            if entry.Published and not (kind == "Color" and control.Rainbow) then RefreshPaletteValue() end
            return table.unpack(values, 1, values.n)
        end
    end
end

local activeOption
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
            Size = UDim2.new(1, 0, 0, 6 + MarginTop + MarginBottom),
            Parent = self.Container,
        })

        Create("UIPadding", {
            PaddingTop = UDim.new(0, MarginTop),
            PaddingBottom = UDim.new(0, MarginBottom),
            Parent = Holder,
        })

        local InnerHolder = Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -Inset * 2, 1, 0),
            Position = UDim2.fromOffset(Inset, 0),
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

            local fade = math.clamp(Fade, 0.01, 0.49)
            Create("UIGradient", {
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, leftFade and 1 or 0),
                    NumberSequenceKeypoint.new(fade, 0),
                    NumberSequenceKeypoint.new(1 - fade, 0),
                    NumberSequenceKeypoint.new(1, rightFade and 1 or 0),
                }),
                Parent = line,
            })
            return line
        end

        if Text then
            local TextLabel = Create("TextLabel", {
                TextYAlignment = Enum.TextYAlignment.Center,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Text = Text,
                FontFace = regularFont,
                TextSize = 14,
                TextColor3 = ThemeColor(255, 255, 255),
                TextTransparency = ThemeTextAlpha(0.5),
                TextXAlignment = Enum.TextXAlignment.Center,
                Parent = InnerHolder,
            })

            local bounds = GetTextBounds(Text, regularFont, 14, Library.UISize - 24)
            local X = bounds and bounds.X or 60
            local SizeX = math.floor(X / 2) + 10

            MakeLine(
                UDim2.new(0.5, -SizeX, 0, 2),
                UDim2.fromScale(0, 0.5),
                Vector2.new(0, 0.5),
                true,
                false
            )

            MakeLine(
                UDim2.new(0.5, -SizeX, 0, 2),
                UDim2.fromScale(1, 0.5),
                Vector2.new(1, 0.5),
                false,
                true
            )
        else
            MakeLine(
                UDim2.new(1, 0, 0, 2),
                UDim2.fromScale(0, 0.5),
                Vector2.new(0, 0.5),
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
            FontFace = regularFont,
            RichText = true,
            Size = UDim2.new(1, 0, 0, 0),
            Text = "",
            TextColor3 = ThemeColor(255, 255, 255),
            TextSize = 15,
            TextTransparency = ThemeTextAlpha(0.5),
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = self.Container
        })

        Create("UIPadding", {
            PaddingLeft = UDim.new(0, 14),
            PaddingRight = UDim.new(0, 14),
            PaddingTop = UDim.new(0, 4),
            PaddingBottom = UDim.new(0, 4),
            Parent = TextLabel
        })

        local Label = { Text = text or "No Text" }

        function Label:Set(newText: string)
            Label.Text = newText
            local size = GetTextBounds(Label.Text, regularFont, 15, Library.UISize - 24)
            if size then
                TextLabel.Size = UDim2.new(1, 0, 0, size.Y + 15)
            end
            TextLabel.Text = Label.Text
        end

        Label:Set(Label.Text)
        return Label
    end

    function Components:AddButton(options: ButtonOptions)
        local ButtonHolder = Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 42),
            Parent = self.Container
        })
        AttachTooltip(ButtonHolder, options, "Button")

        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 5),
            PaddingLeft = UDim.new(0, 13),
            PaddingRight = UDim.new(0, 13),
            PaddingTop = UDim.new(0, 5),
            Parent = ButtonHolder
        })

        local ActualButton: TextButton = Create("TextButton", {
            TextYAlignment = Enum.TextYAlignment.Center,
            AutoButtonColor = false,
            BackgroundColor3 = ThemeColor(25, 25, 25),
            FontFace = regularFont,
            Size = UDim2.fromScale(1, 1),
            Text = options.Name or "Button",
            TextColor3 = ThemeColor(255, 255, 255),
            TextScaled = false, TextSize = 15,
            TextTransparency = ThemeTextAlpha(0.5),
            Parent = ButtonHolder
        })

        Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = ActualButton })
        
        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 6),
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 6),
            PaddingTop = UDim.new(0, 6),
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
            ActualButton:FindFirstChildOfClass("UIPadding").PaddingLeft = UDim.new(0, 18)
            local Icon = Create("ImageLabel", {BackgroundTransparency = 1, Image = "", Size = UDim2.fromOffset(16, 16), ImageColor3 = options.Name == "Save Position" and ThemeColor(60, 200, 100) or ThemeColor(220, 220, 220), Parent = ActualButton})
            if options.Name == "Save Position" then Icon:SetAttribute("ThemeAccentIcon", true) end
            Library:ApplyIcon(Icon, IconDefinition)
            local function PositionIcon()
                local Bounds = GetTextBounds(ActualButton.Text, regularFont, 15, 1000)
                local Width = Bounds and Bounds.X or 60
                local Available = math.max(0, ActualButton.AbsoluteSize.X - 24)
                Tween(Icon, FastTween, {Position = UDim2.new(0, math.max(0, (Available - math.min(Width, Available - 20)) / 2 - 20), 0.5, -8)})
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
        Create("UIGradient", {Color = ColorSequence.new(Color3.fromRGB(255,255,255), Color3.fromRGB(205,205,205)), Rotation = 90, Parent = ActualButton})

        local buttonScale = Create("UIScale", {Scale = 1, Parent = ActualButton})
        local buttonPressTween
        local function AnimateButtonPress()
            if buttonPressTween then buttonPressTween:Cancel() end
            buttonScale.Scale = 0.96
            buttonPressTween = TweenService:Create(buttonScale, TweenInfo.new(0.24, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1})
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
            ButtonStroke.Color = options.Name == "Save Position" and ThemeColor(60, 200, 100) or hoveringToggleColor
            if not Button.Clicking then
                Tween(ActualButton, FastTween, {TextTransparency = ThemeTextAlpha(0.25)})
            end
        end)

        ActualButton.MouseLeave:Connect(function()
            Button.Hovering = false
            ButtonStroke.Color = options.Name == "Save Position" and ThemeColor(60, 200, 100) or defaultToggleColor
            if not Button.Clicking then
                Tween(ActualButton, FastTween, {TextTransparency = ThemeTextAlpha(0.5)})
            end
        end)

        function Button:Activate()
            if Button.Locked then return end
            AnimateButtonPress()

            if Button.DoubleClick then
                if Button.Clicking then
                    Button:SetClicking(false)
                    Button.TimesClicked += 1
                    Library:SafeCallback(options.Callback, Button.TimesClicked)
                else
                    Button:SetClicking(true)
                    task.delay(0.5, function()
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
            Size = UDim2.new(1, 0, 0, 32),
            Parent = self.Container
        })
        AttachTooltip(ToggleHolder, options, "Toggle")

        Create("UIPadding", {
            PaddingLeft = UDim.new(0, 11),
            PaddingRight = UDim.new(0, 13),
            Parent = ToggleHolder
        })

        local ToggleText: TextLabel = Create("TextLabel", {
            TextYAlignment = Enum.TextYAlignment.Center,
            BackgroundTransparency = 1,
            FontFace = regularFont,
            Size = UDim2.fromScale(1, 1),
            Text = options.Name or "Toggle",
            TextColor3 = ThemeColor(255, 255, 255),
            TextScaled = false, TextSize = 15,
            TextTruncate = Enum.TextTruncate.AtEnd,
            TextTransparency = ThemeTextAlpha(0.5),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = ToggleHolder
        })

        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 36),
            PaddingTop = UDim.new(0, 6),
            Parent = ToggleText
        })

        local ToggleButton: TextButton = Create("TextButton", {
            AnchorPoint = Vector2.new(1, 0.5),
            AutoButtonColor = false,
            BackgroundColor3 = ThemeColor(35, 35, 35),
            BackgroundTransparency = 0,
            Position = UDim2.fromScale(1, 0.5),
            Size = IsCheckbox and UDim2.fromOffset(21, 21) or UDim2.fromOffset(32, 16),
            Text = "",
            Parent = ToggleHolder
        })

        Create("UICorner", { CornerRadius = IsCheckbox and UDim.new(0, 4) or UDim.new(1, 0), Parent = ToggleButton })
        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 2),
            PaddingLeft = UDim.new(0, 2),
            PaddingRight = UDim.new(0, 2),
            PaddingTop = UDim.new(0, 2),
            Parent = ToggleButton,
        })

        local ToggleStroke = Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = ThemeColor(60, 60, 60),
            Parent = ToggleButton
        })

        Create("UIGradient", {Color = ColorSequence.new(Color3.fromRGB(255,255,255), Color3.fromRGB(190,190,190)), Rotation = 90, Parent = ToggleButton})

        local ToggleIcon = Create("Frame", {
            BackgroundColor3 = ThemeColor(60, 60, 60),
            Size = UDim2.fromScale(1, 1),
            SizeConstraint = Enum.SizeConstraint.RelativeYY,
            Parent = ToggleButton
        })

        ToggleIcon:SetAttribute("ThemeColorIgnore", true)
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = ToggleIcon })
        local CheckboxMark
        if IsCheckbox then
            ToggleIcon.BackgroundTransparency = 1
            CheckboxMark = Create("ImageLabel", {Name = "CheckboxMark", BackgroundTransparency = 1, Image = "", ImageColor3 = Color3.new(1,1,1), ImageTransparency = 1, Size = UDim2.fromScale(1,1), Parent = ToggleIcon})
            CheckboxMark:SetAttribute("ThemeColorIgnore", true)
            Library:ApplyIcon(CheckboxMark, Library:GetIcon("check"))
        end

        local LockedIcon = Create("Frame", {
            Name = "LockedToggleFrame",
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundColor3 = ThemeColor(25, 25, 25),
            Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.fromOffset(24, 24), Visible = false, Parent = ToggleHolder,
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = LockedIcon})
        Create("UIStroke", {Color = ThemeColor(60, 60, 60), Parent = LockedIcon})
        local LockImage = Create("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Image = "",
            ImageTransparency = 0.3, Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(16, 16), Parent = LockedIcon,
        })
        Library:ApplyIcon(LockImage, LockIcon)

        local LockedBlocker: TextButton = Create("TextButton", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
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

        function Toggle:AddOption(title, iconName)
            if Toggle.Options then return Toggle.Options end
            local icon = Create("ImageButton", {
                AnchorPoint = Vector2.new(1, 0.5), BackgroundTransparency = 1,
                Position = UDim2.new(1, -38, 0.5, 0), Size = UDim2.fromOffset(17, 17),
                Image = "", ImageTransparency = 0.5, Parent = ToggleHolder
            })
            Toggle.OptionsIcon = icon
            if Toggle.KeyPicker then icon.Position = UDim2.new(1, -(Toggle._KeyWidth or 82) - 42, 0.5, 0) end
            Library:ApplyIcon(icon, Library:GetIcon("ellipsis"))
            ToggleText:FindFirstChildOfClass("UIPadding").PaddingRight = UDim.new(0, Toggle.KeyPicker and ((Toggle._KeyWidth or 82) + 64) or 60)
            local popup = Create("CanvasGroup", {
                Name = "ToggleOptions",
                BackgroundColor3 = ThemeColor(25, 25, 25),
                BorderSizePixel = 0,
                Size = UDim2.fromOffset(Library.UISize, 44),
                GroupTransparency = 1,
                Visible = false,
                ZIndex = 20,
                Parent = UI,
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = popup})
            AddAnimatedBorder(popup)
            local header = Create("Frame", {
                BackgroundColor3 = ThemeColor(20, 20, 20),
                Size = UDim2.new(1, 0, 0, 40),
                ZIndex = 21,
                Parent = popup,
            })

            Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = header})
            Create("Frame", {
                BackgroundColor3 = ThemeColor(20, 20, 20),
                Position = UDim2.new(0, 0, 1, -6),
                Size = UDim2.new(1, 0, 0, 6),
                ZIndex = 21,
                Parent = header,
            })
            local hasIcon = iconName and Library:GetIcon(iconName)
            if hasIcon then
                local image = Create("ImageLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(12, 10),
                    Size = UDim2.fromOffset(20, 20),
                    Image = "",
                    ImageTransparency = 0.3,
                    ZIndex = 22,
                    Parent = header,
                })
                Library:ApplyIcon(image, hasIcon)
            end
            local titleLabel = Create("TextLabel", {
                BackgroundTransparency = 1,
                FontFace = mediumFont,
                Position = UDim2.fromOffset(hasIcon and 40 or 12, 0),
                Size = UDim2.new(1, hasIcon and -76 or -48, 1, 0),
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
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -10, 0.5, 0),
                Size = UDim2.fromOffset(18, 18),
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
                Position = UDim2.fromOffset(0, 40),
                Size = UDim2.new(1, 0, 0, 1),
                ZIndex = 22,
                Parent = popup,
            })
            local contentHolder = Create("ScrollingFrame", {
                Active = true,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2.fromOffset(0, 41),
                Size = UDim2.new(1, 0, 1, -41),
                CanvasSize = UDim2.fromOffset(0, 0),
                ScrollBarThickness = 3,
                ScrollBarImageColor3 = ThemeColor(100, 100, 100),
                ZIndex = 21,
                Parent = popup,
            })

            local layout = Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Parent = contentHolder})
            local result = setmetatable({Container = contentHolder, Opened = false, Minimized = false, _PaletteCategory = Toggle._PaletteCategory}, BaseComponents)
            local fadeTween, fadeId = nil, 0
            local sizeTween
            local userMoved = false
            local savedPosition
            Toggle.Options = result
            local function getHeight()
                local camera = workspace.CurrentCamera
                local viewport = camera and camera.ViewportSize or Vector2.new(800, 600)
                return result.Minimized and 40 or math.min(math.max(layout.AbsoluteContentSize.Y + 41, 49), math.max(80, viewport.Y - 24))
            end
            local function refreshSize(animate)
                contentHolder.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y)
                if sizeTween then sizeTween:Cancel() sizeTween = nil end
                local size = UDim2.fromOffset(Library.UISize, getHeight())
                if animate then
                    sizeTween = TweenService:Create(popup, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = size})
                    sizeTween:Play()
                else popup.Size = size end
            end
            local function placeNearToggle()
                local camera = workspace.CurrentCamera
                local viewport = camera and camera.ViewportSize or Vector2.new(800, 600)
                local p, size = icon.AbsolutePosition, icon.AbsoluteSize
                local x = p.X + size.X + 8
                if x + Library.UISize > viewport.X - 6 then x = p.X - Library.UISize - 8 end
                x = math.clamp(x, 6, math.max(6, viewport.X - Library.UISize - 6))
                local y = math.clamp(p.Y, 6, math.max(6, viewport.Y - getHeight() - 6))
                local inset = game:GetService("GuiService"):GetGuiInset()
                popup.Position = UDim2.fromOffset(x - inset.X, y - inset.Y)
            end
            function result:SetMinimized(minimized)
                self.Minimized = minimized == true
                Library:ApplyIcon(resizeButton, Library:GetIcon(self.Minimized and "maximize-2" or "minimize-2"))
                contentHolder.Visible = true
                refreshSize(true)
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
                placeNearToggle()
            end
            function result:DetachToLeft()
                if not self.Opened then return end
                userMoved = true
                self:SetMinimized(false)
                local camera = workspace.CurrentCamera
                local viewport = camera and camera.ViewportSize or Vector2.new(800, 600)
                local inset = game:GetService("GuiService"):GetGuiInset()
                local availableHeight = math.max(1, viewport.Y - inset.Y)
                local maxX = math.max(0, viewport.X - Library.UISize)
                local maxY = math.max(0, availableHeight - getHeight())
                local x = savedPosition and math.clamp(savedPosition.X, 0, maxX) or math.min(12, maxX)
                local y = savedPosition and math.clamp(savedPosition.Y, 0, maxY) or maxY * 0.38
                popup.Position = UDim2.fromOffset(x, y)
            end
            local dragInput, dragStart, dragPosition
            header.Active = true
            header.InputBegan:Connect(function(input)
                if input.UserInputType ~= Enum.UserInputType.Touch and input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
                local p, a, z = input.Position, resizeButton.AbsolutePosition, resizeButton.AbsoluteSize
                if p.X >= a.X and p.X <= a.X + z.X and p.Y >= a.Y and p.Y <= a.Y + z.Y then return end
                dragInput, dragStart, dragPosition = input, input.Position, popup.Position
            end)
            Library:AddConnection(UserInputService.InputChanged:Connect(function(input)
                if not dragInput or not result.Opened then return end
                if input ~= dragInput and not (dragInput.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseMovement) then return end
                local delta = input.Position - dragStart
                if delta.Magnitude < 3 then return end
                userMoved = true
                local camera = workspace.CurrentCamera
                local viewport = camera and camera.ViewportSize or Vector2.new(800, 600)
                local x = math.clamp(dragPosition.X.Offset + delta.X, 0, math.max(0, viewport.X - popup.AbsoluteSize.X))
                local y = math.clamp(dragPosition.Y.Offset + delta.Y, 0, math.max(0, viewport.Y - popup.AbsoluteSize.Y))
                popup.Position = UDim2.fromOffset(x, y)
                savedPosition = Vector2.new(x, y)
            end))
            Library:AddConnection(UserInputService.InputEnded:Connect(function(input) if input == dragInput then dragInput = nil end end))
            local function fade(show)
                fadeId += 1
                local id = fadeId
                if fadeTween then fadeTween:Cancel() end
                if show then popup.Visible = true end
                local tween = TweenService:Create(popup, TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {GroupTransparency = show and 0 or 1})
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
                if activeOption == result then activeOption = nil end
                fade(false)
            end
            function result:Open()
                if Toggle.Locked or not Library.Opened then return end
                if activeOption and activeOption ~= result then activeOption:Close() end
                activeOption = result
                self.Opened = true
                userMoved = false
                refreshSize(false)
                placeNearToggle()
                icon.ImageColor3 = Color3.new(1, 1, 1)
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
                if popup.Visible and not result.Minimized then refreshSize(false) end
            end))
            Library:AddConnection(RunService.Heartbeat:Connect(function()
                if result.Opened and Library.Opened and not userMoved and ToggleHolder:IsDescendantOf(UI) then
                    placeNearToggle()
                end
            end))
            Library:AddConnection(UserInputService.InputBegan:Connect(function(input)
                if not result.Opened or not Library.Opened or (input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch) then return end
                local p = input.Position
                local function inside(obj)
                    if not obj or not obj.Parent or not obj:IsA("GuiObject") or not obj.Visible then return false end
                    local a, z = obj.AbsolutePosition, obj.AbsoluteSize
                    return p.X >= a.X and p.X <= a.X + z.X and p.Y >= a.Y and p.Y <= a.Y + z.Y
                end
                if inside(popup) or (Library.Opened and inside(icon)) or inside(Library.MobileButton) then return end
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
                ToggleIcon.BackgroundColor3 = defaultToggleColor
                ToggleStroke.Color = defaultToggleColor
            else
                ToggleIcon.BackgroundColor3 = Toggle.Value and Color3.fromRGB(255, 255, 255) or ThemeColor(140, 140, 140)
                ToggleButton.BackgroundColor3 = Toggle.Value and enabledToggleColor or ThemeColor(35, 35, 35)
                if CheckboxMark then Tween(CheckboxMark, FastTween, {ImageTransparency = Toggle.Value and 0 or 1}) else Tween(ToggleIcon, FastTween, {Position = Toggle.Value and UDim2.fromOffset(16, 0) or UDim2.fromOffset(0, 0)}) end
                ToggleStroke.Color = Toggle.Value and enabledToggleColor or (Toggle.Hovering and hoveringToggleColor or defaultToggleColor)
            end
        end

        function Toggle:Set(newValue: boolean)
            local oldValue = Toggle.Value
            Toggle.Value = newValue

            ToggleIcon.BackgroundColor3 = Toggle.Value and Color3.fromRGB(255, 255, 255) or ThemeColor(140, 140, 140)
            Tween(ToggleButton, FastTween, {BackgroundColor3 = Toggle.Value and enabledToggleColor or ThemeColor(35, 35, 35)})
            if CheckboxMark then Tween(CheckboxMark, FastTween, {ImageTransparency = Toggle.Value and 0 or 1}) else Tween(ToggleIcon, FastTween, {Position = Toggle.Value and UDim2.fromOffset(16, 0) or UDim2.fromOffset(0, 0)}) end
            ToggleStroke.Color = Toggle.Value and enabledToggleColor or (Toggle.Hovering and hoveringToggleColor or defaultToggleColor)

            if Toggle.Value ~= oldValue then
                Library:SafeCallback(options.Callback, Toggle.Value, oldValue)
            end
            if Toggle.KeyPicker and Toggle.KeyPicker.RefreshList then Toggle.KeyPicker:RefreshList() end
        end

        function Toggle:AddKeybind(keyOptions)
            keyOptions = type(keyOptions) == "table" and table.clone(keyOptions) or {Keybind = keyOptions}
            keyOptions.Name = keyOptions.Name or ((options.Name or "Toggle") .. " Keybind")
            keyOptions._Inline = true
            keyOptions._Toggle = Toggle
            local callback = keyOptions.Callback
            local picker
            keyOptions.Callback = function(state, oldState)
                local mode = picker and picker.Mode or keyOptions.Mode or "Toggle"
                if not Toggle.Locked then
                    if mode == "Hold" then Toggle:Set(state)
                    elseif mode == "Always" then Toggle:Set(true)
                    elseif not (picker and picker.ModeChanging) then Toggle:Set(not Toggle.Value) end
                end
                if callback then Library:SafeCallback(callback, state, oldState) end
            end
            picker = Components.AddKeyPicker(self._PaletteContainer, keyOptions)
            self.KeyPicker = picker
            picker.Holder.Parent = ToggleHolder
            picker.Holder.AnchorPoint = Vector2.new(1, 0.5)
            picker.Holder.Position = UDim2.new(1, 0, 0.5, 0)
            local holderPadding = picker.Holder:FindFirstChildOfClass("UIPadding")
            if holderPadding then holderPadding:Destroy() end
            picker.Label.Visible = false
            local function layoutInlineKey()
                local width = picker.Button.Size.X.Offset + (keyOptions.Clearable == false and 0 or 29)
                self._KeyWidth = width
                picker.Holder.Size = UDim2.fromOffset(width, 32)
                ToggleButton.Position = UDim2.new(1, -width - 4, 0.5, 0)
                LockedIcon.Position = UDim2.new(1, -width - 4, 0.5, 0)
                ToggleText:FindFirstChildOfClass("UIPadding").PaddingRight = UDim.new(0, width + (self.OptionsIcon and 64 or 40))
                if self.OptionsIcon then self.OptionsIcon.Position = UDim2.new(1, -width - 42, 0.5, 0) end
            end
            Library:AddConnection(picker.Button:GetPropertyChangedSignal("Size"):Connect(layoutInlineKey))
            layoutInlineKey()
            return picker
        end
        Toggle._PaletteContainer = self

        if options.Flag then
            Library.Flags[options.Flag] = Toggle
        end

        local function UpdateToggleHover()
            if Toggle.Locked then return end
            local base = Toggle.Value and enabledToggleColor or defaultToggleColor
            local color = Toggle.Hovering and base:Lerp(Color3.new(1, 1, 1), 0.3) or base
            Tween(ToggleButton, FastTween, {BackgroundColor3 = Toggle.Value and color or ThemeColor(35, 35, 35)})
            Tween(ToggleStroke, FastTween, {Color = color})
        end
        ToggleButton.MouseEnter:Connect(function() Toggle.Hovering = true UpdateToggleHover() end)
        ToggleButton.MouseLeave:Connect(function() Toggle.Hovering = false UpdateToggleHover() end)

        ToggleButton.MouseButton1Click:Connect(function()
            if Toggle.Locked then return end
            Toggle:Set(not Toggle.Value)
        end)

        Library.ThemeToggleRefreshers = Library.ThemeToggleRefreshers or {}
        table.insert(Library.ThemeToggleRefreshers, function()
            if not ToggleHolder.Parent then return end
            if Toggle.Locked then
                ToggleStroke.Color = defaultToggleColor
            else
                UpdateToggleHover()
                ToggleIcon.BackgroundColor3 = Toggle.Value and Color3.new(1, 1, 1) or ThemeColor(140, 140, 140)
            end
        end)
        Toggle:Set(Toggle.Value)
    RegisterControlForPalette(self, options, Toggle, "Toggle")
        if options.Keybind then Toggle:AddKeybind({Keybind = options.Keybind, Mode = options.KeybindMode, Clearable = options.Clearable}) end
        return Toggle
    end

    function Components:AddCheckbox(options)
        local settings = table.clone(options or {})
        settings._Checkbox = true
        return Components.AddToggle(self, settings)
    end

function Components:AddSlider(options: SliderOptions)
    local SliderHolder = Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 48),
        Parent = self.Container
    })
        AttachTooltip(SliderHolder, options, "Slider")

    Create("UIPadding", {
        PaddingLeft = UDim.new(0, 11),
        PaddingRight = UDim.new(0, 11),
        Parent = SliderHolder
    })

    local SliderHoverZone: TextButton = Create("TextButton", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Text = "",
        ZIndex = 0,
        Parent = SliderHolder
    })

    local SliderText = Create("TextLabel", {
        TextYAlignment = Enum.TextYAlignment.Center,
        BackgroundTransparency = 1,
        FontFace = regularFont,
        Size = UDim2.new(1, -70, 0, 32),
        Text = options.Name or "No Name",
        TextColor3 = ThemeColor(255, 255, 255),
        TextScaled = false, TextSize = 15,
        TextTransparency = ThemeTextAlpha(0.5),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = SliderHolder
    })

    Create("UIPadding", {
        PaddingBottom = UDim.new(0, 6),
        PaddingTop = UDim.new(0, 6),
        Parent = SliderText
    })

    local SliderValue: TextBox = Create("TextBox", {
        TextYAlignment = Enum.TextYAlignment.Center,
        AnchorPoint = Vector2.new(1, 0),
        BackgroundColor3 = ThemeColor(30, 30, 30),
        BackgroundTransparency = 0,
        FontFace = regularFont,
        Position = UDim2.new(1, 0, 0, 7),
        Size = UDim2.fromOffset(64, 20),
        Text = "100",
        TextColor3 = ThemeColor(255, 255, 255),
        TextScaled = false, TextSize = 14,
        TextTransparency = ThemeTextAlpha(0.5),
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = SliderHolder
    })
    Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SliderValue})
    Create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = ThemeColor(60, 60, 60), Parent = SliderValue})

    local SliderBar: TextButton = Create("TextButton", {
        AnchorPoint = Vector2.new(0, 1),
        AutoButtonColor = false,
        BackgroundColor3 = ThemeColor(60, 60, 60),
        Position = UDim2.new(0, 0, 1, -10),
        Size = UDim2.new(1, 0, 0, 6),
        Text = "",
        Parent = SliderHolder
    })

    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = SliderBar })

    local SliderFillBar = Create("Frame", {
        BackgroundColor3 = ThemeColor(60, 200, 100),
        Size = UDim2.fromScale(0.5, 1),
        Parent = SliderBar
    })

    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = SliderFillBar })
    Create("UIGradient", {Color = ColorSequence.new(Color3.fromRGB(235, 235, 235), Color3.fromRGB(255, 255, 255)), Rotation = 0, Parent = SliderFillBar})

    local SliderKnob = Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.fromRGB(245, 245, 245),
        Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(12, 12), ZIndex = 3, Parent = SliderBar,
    })
    SliderKnob:SetAttribute("ThemeColorIgnore", true)
    Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SliderKnob})
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
            return math.floor(value / inc + 0.5) * inc
        end
        local rounding = Slider.Rounding
        if rounding and rounding > 0 then
            local mult = 10 ^ rounding
            return math.floor(value * mult + 0.5) / mult
        end
        return math.floor(value + 0.5)
    end

    local function ClampRound(value)
        return math.clamp(RoundTo(value), Slider.Min, Slider.Max)
    end

    local function FormatNumber(n)
        if n == math.floor(n) then
            return tostring(math.floor(n))
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
            local ok, value = pcall(string.format, options.DisplayFormat, Slider.Value); if ok then custom = value end
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

        local ratio = (Slider.Max == Slider.Min) and 0 or ((Slider.Value - Slider.Min) / (Slider.Max - Slider.Min))
        SliderFillBar.Size = UDim2.fromScale(math.clamp(ratio, 0, 1), 1)
        SliderKnob.Position = UDim2.fromScale(math.clamp(ratio, 0, 1), 0.5)
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
        Slider:Set(math.clamp(Slider.Value, Slider.Min, Slider.Max), true)
    end

    function Slider:SetMax(newMax)
        if newMax == nil then return end
        if newMax < Slider.Min then Slider.Min = newMax end
        Slider.Max = newMax
        Slider:Set(math.clamp(Slider.Value, Slider.Min, Slider.Max), true)
    end

    function Slider:SetLocked(locked)
        Slider.Locked = locked == true

        LockedHover.Visible = Slider.Locked
        SliderValue.Visible = not Slider.Locked
        LockedIcon.Visible = Slider.Locked

        if Slider.Locked then
            SliderBar.BackgroundColor3 = defaultToggleColor
            SliderFillBar.BackgroundColor3 = defaultToggleColor
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
        task.spawn(function()
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
        Tween(SliderFillBar, FastTween, {BackgroundColor3 = ThemeColor(60, 200, 100):Lerp(Color3.new(1, 1, 1), 0.18)})
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
        local scale = math.clamp((input.Position.X - abs.X) / math.max(size.X, 1), 0, 1)
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
        if not Library.Opened and not (activeOption and activeOption.Opened and SliderHolder:IsDescendantOf(activeOption.Container)) then
            Slider.Dragging = false
            return
        end

        if input.UserInputType ~= Enum.UserInputType.MouseMovement
            and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        local abs = SliderBar.AbsolutePosition
        local size = SliderBar.AbsoluteSize
        local scale = math.clamp((input.Position.X - abs.X) / math.max(size.X, 1), 0, 1)
        Slider:Set(Slider.Min + (Slider.Max - Slider.Min) * scale)
    end))

    Slider:Set(Slider.Value, true)
    RegisterControlForPalette(self, options, Slider, "Slider")
    return Slider
end

function Components:AddTextbox(options: TextboxOptions)
    local TextboxHolder = Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 66),
        Parent = self.Container
    })
        AttachTooltip(TextboxHolder, options, "Input")

    Create("UIPadding", {
        PaddingBottom = UDim.new(0, 5),
        PaddingLeft = UDim.new(0, 13),
        PaddingRight = UDim.new(0, 13),
        PaddingTop = UDim.new(0, 5),
        Parent = TextboxHolder
    })

    local Caption = Create("TextLabel", {BackgroundTransparency = 1, FontFace = regularFont, Text = options.Name or "Input", TextColor3 = ThemeColor(255, 255, 255), TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Size = UDim2.new(1, 0, 0, 22), Parent = TextboxHolder})
    local UpdateVisuals
    local Box: TextBox = Create("TextBox", {
        TextYAlignment = Enum.TextYAlignment.Center,
        BackgroundColor3 = ThemeColor(35, 35, 35),
        BackgroundTransparency = 0,
        ClearTextOnFocus = options.ClearTextOnFocus ~= false and (options.ResetOnFocus ~= false),
        FontFace = regularFont,
        PlaceholderColor3 = ThemeColor(100, 100, 100),
        PlaceholderText = options.Placeholder or "",
        Position = UDim2.fromOffset(0, 27),
        Size = UDim2.new(1, 0, 1, -27),
        Text = options.Text or "",
        TextColor3 = ThemeColor(220, 220, 220),
        TextScaled = false, TextSize = 15,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TextboxHolder
    })

    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Box })
    Create("UIPadding", {
        PaddingBottom = UDim.new(0, 6),
        PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6),
        PaddingTop = UDim.new(0, 6),
        Parent = Box
    })
    local BoxStroke = Create("UIStroke", {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = ThemeColor(80, 80, 80),
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
                BackgroundColor3 = ThemeColor(35, 35, 35),
                TextColor3 = ThemeColor(255, 255, 255),
                PlaceholderColor3 = ThemeColor(90, 90, 90),
            })
            Tween(BoxStroke, FastTween, {Color = ThemeColor(90, 90, 90)})
        elseif Textbox.Hovering and not Textbox.Locked then
            Tween(Box, FastTween, {
                BackgroundColor3 = ThemeColor(30, 30, 30),
                TextColor3 = ThemeColor(200, 200, 200),
                PlaceholderColor3 = ThemeColor(80, 80, 80),
            })
            Tween(BoxStroke, FastTween, {Color = ThemeColor(80, 80, 80)})
        else
            Tween(Box, FastTween, {
                BackgroundColor3 = ThemeColor(25, 25, 25),
                TextColor3 = ThemeColor(140, 140, 140),
                PlaceholderColor3 = ThemeColor(60, 60, 60),
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
                Box.CursorPosition = math.min(cursor, #Box.Text + 1)
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
        Size = UDim2.new(1, 0, 0, 42),
        Parent = self.Container
    })
        AttachTooltip(DropdownHolder, options, "Dropdown")

    Create("UIPadding", {
        PaddingBottom = UDim.new(0, 5),
        PaddingLeft = UDim.new(0, 13),
        PaddingRight = UDim.new(0, 13),
        PaddingTop = UDim.new(0, 5),
        Parent = DropdownHolder
    })

    local function GetPlayerValues()
        local list = Players:GetPlayers()
        if options.ExcludeLocalPlayer then
            local i = table.find(list, Library.LocalPlayer)
            if i then table.remove(list, i) end
        end
        table.sort(list, function(a, b) return a.Name:lower() < b.Name:lower() end)
        return list
    end

    if options.SpecialType == "Player" then
        options.Values = GetPlayerValues()
        options.AllowNull = true
    end

    local ButtonsHolder = Create("Frame", {
        BackgroundColor3 = ThemeColor(25, 25, 25),
        Size = UDim2.new(1, 0, 0, 32),
        ClipsDescendants = true,
        Parent = DropdownHolder
    })

    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = ButtonsHolder })
    Create("UIStroke", {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = ThemeColor(60, 60, 60),
        Parent = ButtonsHolder
    })

    local CurrentButton = Create("TextButton", {
        TextYAlignment = Enum.TextYAlignment.Center,
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        FontFace = regularFont,
        Size = UDim2.new(1, 0, 0, 32),
        TextColor3 = ThemeColor(220, 220, 220),
        TextScaled = false, TextSize = 15,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = ButtonsHolder
    })

    Create("UIPadding", {
        PaddingBottom = UDim.new(0, 6),
        PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 26),
        PaddingTop = UDim.new(0, 6),
        Parent = CurrentButton
    })

    local SearchBox, SearchIcon
    if options.Searchable then
        SearchBox = Create("TextBox", {
            BackgroundColor3 = ThemeColor(30, 30, 30),
            ClearTextOnFocus = false,
            FontFace = regularFont,
            PlaceholderColor3 = ThemeColor(100, 100, 100),
            PlaceholderText = "Search...",
            Position = UDim2.fromOffset(6, 36),
            Size = UDim2.new(1, -12, 0, 28),
            Text = "",
            TextColor3 = ThemeColor(255, 255, 255),
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Visible = false,
            Parent = ButtonsHolder
        })

        Create("UIPadding", {
            PaddingLeft = UDim.new(0, 28),
            PaddingRight = UDim.new(0, 8),
            Parent = SearchBox
        })

        Create("UICorner", {CornerRadius = UDim.new(0, 5), Parent = SearchBox})
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = ThemeColor(60, 60, 60), Transparency = 0.2,
            Parent = SearchBox
        })
        SearchIcon = Create("ImageLabel", {BackgroundTransparency = 1, Image = "", ImageTransparency = 0.35, Position = UDim2.fromOffset(13, 42), Size = UDim2.fromOffset(16, 16), ZIndex = 2, Visible = false, Parent = ButtonsHolder})
        Library:ApplyIcon(SearchIcon, Library:GetIcon("search"))
    end

    local OptionsHolder = Create("ScrollingFrame", {
        Active = true,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.fromOffset(0, 0),
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = ThemeColor(100, 100, 100),
        Position = UDim2.fromOffset(0, 32),
        Size = UDim2.fromScale(1, 0),
        Visible = false,
        Parent = ButtonsHolder,
    })

    local EmptyMessage = Create("TextLabel", {BackgroundTransparency = 1, FontFace = regularFont, Size = UDim2.new(1, 0, 0, 32), Text = "No results found", TextColor3 = ThemeColor(140, 140, 140), TextSize = 14, Visible = false, Parent = OptionsHolder})

    local Icon = Create("ImageLabel", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Image = "",
        ImageTransparency = 0.5,
        Position = UDim2.new(1, -5, 0, 6),
        Size = UDim2.fromOffset(20, 20),
        Parent = DropdownHolder
    })
    Library:ApplyIcon(Icon, ArrowIcon)

    local LockedIcon = Create("ImageLabel", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Image = "",
        ImageTransparency = 0.5,
        Position = UDim2.new(1, -5, 0, 6),
        Size = UDim2.fromOffset(20, 20),
        Visible = false,
        Parent = DropdownHolder
    })
    Library:ApplyIcon(LockedIcon, LockIcon)

    local LockedHover = Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
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

        DisabledValues = options.DisabledValues or {},
        KeepDisabledValuePosition = options.KeepDisabledValuePosition == true,

        SpecialType = options.SpecialType,
        ExcludeLocalPlayer = options.ExcludeLocalPlayer == true,
        MaxVisibleDropdownItems = math.max(1, options.MaxVisibleDropdownItems or 8),

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
        selectionBar = Create("Frame", {Name = "SelectionButtons", BackgroundTransparency = 1, Size = UDim2.new(1,-12,0,30), Visible = false, Parent = ButtonsHolder})
        local function selectionButton(text, x)
            local button = Create("TextButton", {Name = text, AutoButtonColor = false, BackgroundColor3 = ThemeColor(35,35,35), Position = UDim2.new(x,0,0,1), Size = UDim2.new(0.5,-3,0,26), Text = text, TextColor3 = ThemeColor(220,220,220), TextSize = 12, FontFace = regularFont, Parent = selectionBar})
            Create("UICorner", {CornerRadius = UDim.new(0,5), Parent = button})
            Create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = ThemeColor(60,60,60), Transparency = 0.2, Parent = button})
            return button
        end
        selectAllButton = selectionButton("Select All", 0)
        deselectAllButton = selectionButton("Deselect All", 0.5)
    end

    local OpenTweenInfo = TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local CloseTweenInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

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
            for Value in Dropdown.Value do table.insert(Table, Value) end
        else
            if Dropdown.Value then table.insert(Table, Dropdown.Value) end
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
        table.clear(filteredCache)
        local IsDictionary = not IsSequentialArray(Dropdown.Values)
        local Query = Dropdown.Searchable and Dropdown.SearchText or ""

        for Key, RawValue in Dropdown.Values do
            local Value = IsDictionary and Key or RawValue
            local formatted = FormatListValue(RawValue)
            if Query ~= "" and not formatted:lower():find(Query, 1, true) then
                continue
            end
            table.insert(filteredCache, {
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

        local openButtonsH = BASE_HEIGHT + searchSlot + selectSlot + math.min(listHeight, MaxListHeight())
        local closedButtonsH = BASE_HEIGHT

        local buttonsH = closedButtonsH + (openButtonsH - closedButtonsH) * p
        local holderH = buttonsH + HOLDER_PAD

        DropdownHolder.Size = UDim2.new(1, 0, 0, holderH)
        ButtonsHolder.Size = UDim2.new(1, 0, 0, buttonsH)

        OptionsHolder.Position = UDim2.fromOffset(0, BASE_HEIGHT + (searchSlot + selectSlot) * p)
        if selectionBar then selectionBar.Position = UDim2.fromOffset(6, BASE_HEIGHT + searchSlot * p + 3); selectionBar.Visible = p > 0.001 end

        if SearchBox then
            local searchY = BASE_HEIGHT + SEARCH_GAP * p
            SearchBox.Position = UDim2.fromOffset(6, searchY)
            SearchBox.BackgroundTransparency = 1 - p
            SearchBox.TextTransparency = 1 - p
            SearchIcon.Position = UDim2.fromOffset(13, searchY + 6)
            SearchIcon.ImageTransparency = 1 - 0.65 * p
            if p > 0.001 then SearchBox.Visible = true; SearchIcon.Visible = true end
        end

        Icon.Rotation = 180 * p
    end

    function Dropdown:RefreshSize()
        listHeight = math.max(#filteredCache, 1) * ITEM_HEIGHT
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
            listHeight = math.max(#filteredCache, 1) * ITEM_HEIGHT
        end
        local target = opening and 1 or 0
        local value = Instance.new("NumberValue")
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
            FontFace = regularFont,
            Size = UDim2.new(1, 0, 0, ITEM_HEIGHT),
            Text = "",
            TextColor3 = ThemeColor(140, 140, 140),
            TextScaled = false, TextSize = 15,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = OptionsHolder
        })
        local RowPadding = Create("UIPadding", {
            PaddingBottom = UDim.new(0, 6),
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 6),
            PaddingTop = UDim.new(0, 6),
            Parent = Btn
        })

        local Check = Create("ImageLabel", {BackgroundTransparency = 1, Position = UDim2.new(0, -20, 0.5, -8), Size = UDim2.fromOffset(16, 16), Image = "", ImageColor3 = Color3.new(1, 1, 1), Visible = false, Parent = Btn})
        Check:SetAttribute("ThemeColorIgnore", true)
        Library:ApplyIcon(Check, Library:GetIcon("check"))

        local Divider = Create("Frame", {
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = ThemeColor(50, 50, 50),
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 1),
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
            Check.Visible = row.Selected == true
            Tween(RowPadding, FastTween, {PaddingLeft = UDim.new(0, row.Selected and 26 or 6)})
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
            local oldValue = Dropdown.Multi and table.clone(Dropdown.Value) or Dropdown.Value
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
            local target = baseColor:Lerp(Color3.new(1, 1, 1), 0.6)
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
        local contentRows = math.max(total, 1)
        listHeight = contentRows * ITEM_HEIGHT
        EmptyMessage.Visible = total == 0
        local visibleHeight = math.min(contentRows * ITEM_HEIGHT, MaxListHeight())
        OptionsHolder.Size = UDim2.new(1, 0, 0, visibleHeight)

        OptionsHolder.CanvasSize = UDim2.fromOffset(0, contentRows * ITEM_HEIGHT)
        local maxScroll = math.max(0, contentRows * ITEM_HEIGHT - visibleHeight)
        if OptionsHolder.CanvasPosition.Y > maxScroll then
            OptionsHolder.CanvasPosition = Vector2.new(0, maxScroll)
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
            row.Button.Position = UDim2.fromOffset(0, (i - 1) * ITEM_HEIGHT)

            local absoluteIndex = i
            local showDivider = (absoluteIndex > 1) or (absoluteIndex == 1 and not SearchBox)
            row.Divider.Visible = showDivider
            if showDivider then
                row.Divider.LayoutOrder = (i * 2) - 3
                row.Divider.Position = UDim2.fromOffset(0, (i - 1) * ITEM_HEIGHT)
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
                for _, Val in Values do table.insert(Dropdown.Values, Val) end
            else
                table.insert(Dropdown.Values, Values)
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
            for _, val in DisabledValues do table.insert(Dropdown.DisabledValues, val) end
        elseif typeof(DisabledValues) == "string" or typeof(DisabledValues) == "number" then
            table.insert(Dropdown.DisabledValues, DisabledValues)
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
        CurrentButton.Text = Dropdown.Name .. (Str == "" and "" or ": ") .. Str
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
                task.defer(function()
                    if t ~= token then return end
                    OptionsHolder.CanvasPosition = Vector2.new(0, 0)
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
                if V ~= nil and not IsValueDisabled(V) then table.insert(Resolved, V) end
            elseif T == "table" then
                for _, C in Default do
                    local V = ResolveOne(C)
                    if V ~= nil and not IsValueDisabled(V) then table.insert(Resolved, V) end
                end
            elseif Dropdown.Values[Default] ~= nil then
                local V = IsDictionary and Default or Dropdown.Values[Default]
                if not IsValueDisabled(V) then table.insert(Resolved, V) end
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
        local frame = Create("CanvasGroup", {Name = "KeybindList", AnchorPoint = Vector2.new(1,0.5), Position = UDim2.new(1,-10,0.5,0), Size = UDim2.fromOffset(270,36), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = ThemeColor(25,25,25), GroupTransparency = 1, Visible = false, ZIndex = 30, Parent = UI})
        Create("UICorner", {CornerRadius = UDim.new(0,8), Parent = frame})
        AddAnimatedBorder(frame)
        Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Parent = frame})
        local header = Create("TextButton", {Name = "Header", LayoutOrder = -1, AutoButtonColor = false, Active = true, BackgroundColor3 = ThemeColor(35,35,35), Size = UDim2.new(1,0,0,36), Text = "", ZIndex = 31, Parent = frame})
        Create("UIGradient", {Color = ColorSequence.new(Color3.new(1,1,1), Color3.fromRGB(215,215,215)), Rotation = 90, Parent = header})
        local icon = Create("ImageLabel", {BackgroundTransparency = 1, Image = "", ImageColor3 = ThemeColor(220,220,220), AnchorPoint = Vector2.new(0,0.5), Position = UDim2.new(0,12,0.5,0), Size = UDim2.fromOffset(16,16), ZIndex = 32, Parent = header})
        Library:ApplyIcon(icon, Library:GetIcon("keyboard"))
        Create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.fromOffset(38,0), Size = UDim2.new(1,-70,1,0), Text = "Keybinds", TextColor3 = ThemeColor(220,220,220), TextSize = 15, FontFace = semiBoldFont, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 32, Parent = header})
        Create("Frame", {BackgroundColor3 = ThemeColor(80,80,80), BackgroundTransparency = 0.5, BorderSizePixel = 0, Position = UDim2.new(0,1,1,-1), Size = UDim2.new(1,-2,0,1), ZIndex = 32, Parent = header})
        local minimize = Create("ImageButton", {Name = "Minimize", AutoButtonColor = false, BackgroundTransparency = 1, AnchorPoint = Vector2.new(1,0.5), Position = UDim2.new(1,-7,0.5,0), Size = UDim2.fromOffset(18,18), Image = "", ImageColor3 = ThemeColor(220,220,220), ZIndex = 32, Parent = header})
        Library:ApplyIcon(minimize, Library:GetIcon("chevron-up"))
        MakeDraggable(header, frame)
        local minimizeGeneration = 0
        minimize.Activated:Connect(function()
            Library.KeybindFrameMinimized = not Library.KeybindFrameMinimized
            minimizeGeneration += 1
            local generation = minimizeGeneration
            Tween(minimize, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Rotation = Library.KeybindFrameMinimized and 180 or 0})
            for _, child in ipairs(frame:GetChildren()) do if child.Name == "KeybindEntry" then
                child.ClipsDescendants = true
                if not Library.KeybindFrameMinimized then child.Visible = child:GetAttribute("Eligible") == true end
                Tween(child, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(1,0,0,Library.KeybindFrameMinimized and 0 or 28)})
                for _, part in ipairs(child:GetChildren()) do
                    if part:IsA("TextLabel") or part:IsA("TextButton") then
                        local properties = {TextTransparency = Library.KeybindFrameMinimized and 1 or 0}
                        if part.Name == "ModeBadge" or part.Name == "FrameKeybind" then properties.BackgroundTransparency = Library.KeybindFrameMinimized and 1 or 0 end
                        Tween(part, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), properties)
                        local outline = part:FindFirstChildOfClass("UIStroke")
                        if outline then Tween(outline, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Transparency = Library.KeybindFrameMinimized and 1 or 0.25}) end
                    end
                end
                if Library.KeybindFrameMinimized then task.delay(0.2, function() if generation == minimizeGeneration and child.Parent then child.Visible = false end end) end
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
        keybindFrameTween = TweenService:Create(frame, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {GroupTransparency = self.KeybindFrameEnabled and 0 or 1})
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
            Size = UDim2.new(1, 0, 0, 32),
            Parent = self.Container,
        })
        AttachTooltip(KeyPickerHolder, options, "Keybind")

        Create("UIPadding", {
            PaddingLeft = UDim.new(0, 11),
            PaddingRight = UDim.new(0, 11),
            Parent = KeyPickerHolder
        })

        local KeyPickerText = Create("TextLabel", {
            TextYAlignment = Enum.TextYAlignment.Center,
            BackgroundTransparency = 1,
            FontFace = regularFont,
            Size = UDim2.new(1, -72, 1, 0),
            TextTruncate = Enum.TextTruncate.AtEnd,
            Text = options.Name or "Key Picker",
            TextColor3 = ThemeColor(255, 255, 255),
            TextScaled = false, TextSize = 15,
            TextTransparency = ThemeTextAlpha(0.5),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = KeyPickerHolder,
        })

        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 4),
            PaddingTop = UDim.new(0, 6),
            Parent = KeyPickerText
        })

        local KeyPickerButton: TextButton = Create("TextButton", {
            TextYAlignment = Enum.TextYAlignment.Center,
            AutoButtonColor = false,
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundColor3 = ThemeColor(25, 25, 25),
            FontFace = mediumFont,
            Position = UDim2.new(1, -29, 0.5, 0),
            Size = UDim2.fromOffset(40, 24),
            Text = "...",
            TextColor3 = ThemeColor(255, 255, 255),
            TextSize = 14,
            TextTransparency = ThemeTextAlpha(0.5),
            Parent = KeyPickerHolder
        })

        Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = KeyPickerButton })
        Create("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = ThemeColor(60, 60, 60), Parent = KeyPickerButton })

        local editKey = Create("TextButton", {
            Name = "KeybindClearButton",
            AutoButtonColor = false,
            BackgroundColor3 = ThemeColor(25, 25, 25),
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.fromOffset(24, 24),
            Text = "",
            Parent = KeyPickerHolder,
        })
        editKey.Visible = options.Clearable ~= false
        if options.Clearable == false then KeyPickerButton.Position = UDim2.new(1, 0, 0.5, 0) end
        Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = editKey })
        Create("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = ThemeColor(60, 60, 60), Parent = editKey })
        local editIcon = Create("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(16, 16),
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
        local listRow = Create("TextButton", {Name = "KeybindEntry", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,28), Text = "", ClipsDescendants = true, ZIndex = 31, Parent = frame})
        local rowTitle = Create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.fromOffset(10,0), Size = UDim2.new(1,-115,1,0), Text = "", TextTruncate = Enum.TextTruncate.AtEnd, TextColor3 = ThemeColor(220,220,220), TextSize = 13, FontFace = regularFont, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 32, Parent = listRow})
        local keyText = Create("TextButton", {Name = "FrameKeybind", AutoButtonColor = false, BackgroundColor3 = ThemeColor(30,30,30), AnchorPoint = Vector2.new(1,0.5), Position = UDim2.new(1,-62,0.5,0), Size = UDim2.fromOffset(40,20), Text = "", TextTruncate = Enum.TextTruncate.AtEnd, TextColor3 = ThemeColor(200,200,200), TextSize = 12, FontFace = regularFont, ZIndex = 32, Parent = listRow})
        Create("UICorner", {CornerRadius = UDim.new(0,4), Parent = keyText}); Create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = ThemeColor(60,60,60), Transparency = 0.3, Parent = keyText})
        local modeBadge = Create("TextLabel", {Name = "ModeBadge", AnchorPoint = Vector2.new(1,0.5), Position = UDim2.new(1,-8,0.5,0), Size = UDim2.fromOffset(50,20), Text = "", TextColor3 = ThemeColor(200,200,200), BackgroundColor3 = ThemeColor(35,35,35), TextSize = 11, FontFace = regularFont, ZIndex = 32, Parent = listRow})
        Create("UICorner", {CornerRadius = UDim.new(0,4), Parent = modeBadge}); Create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = ThemeColor(80,80,80), Transparency = 0.25, Parent = modeBadge})
        Create("Frame", {Name = "Divider", BackgroundColor3 = ThemeColor(80,80,80), BackgroundTransparency = 0.65, BorderSizePixel = 0, Position = UDim2.new(0,1,1,-1), Size = UDim2.new(1,-2,0,1), ZIndex = 32, Parent = listRow})
        local function refreshList()
            local eligible = options.NoUI ~= true and (KeyPicker.Keybind ~= nil or KeyPicker.Mode == "Always")
            listRow:SetAttribute("Eligible", eligible)
            listRow.Visible = eligible and not Library.KeybindFrameMinimized
            rowTitle.Text = options.Name or "Keybind"
            keyText.Text = KeyPicker.Keybind and (keyCodesName[KeyPicker.Keybind] or KeyPicker.Keybind.Name) or "None"
            modeBadge.Text = KeyPicker.Mode
            local active = options._Toggle and options._Toggle.Value or (not options._Toggle and KeyPicker.State)
            rowTitle.TextColor3 = active and ThemeColor(60,200,100) or ThemeColor(200,200,200)
        end
        KeyPicker.RefreshList = refreshList
        listRow.Activated:Connect(function()
            if KeyPicker.Locked or KeyPicker.Mode == "Always" or KeyPicker.Mode == "Hold" then return end
            if options._Toggle then if not options._Toggle.Locked then options._Toggle:Set(not options._Toggle.Value) end else KeyPicker:SetState(not KeyPicker.State) end
        end)
        local holdingRow
        local function releaseHeldRow()
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
            if holdingRow and (input == holdingRow or (holdingRow.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseButton1)) then releaseHeldRow() end
        end))
        Library:AddConnection(UserInputService.WindowFocusReleased:Connect(releaseHeldRow))
        local modeMenu = Create("CanvasGroup", {Name = "KeybindModeMenu", BackgroundColor3 = ThemeColor(25,25,25), Size = UDim2.fromOffset(116,96), Visible = false, GroupTransparency = 1, ZIndex = 70, Parent = UI})
        KeyPicker.ModeMenu = modeMenu
        Create("UICorner", {CornerRadius = UDim.new(0,6), Parent = modeMenu})
        AddAnimatedBorder(modeMenu)
        Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,2), Parent = modeMenu})
        Create("UIPadding", {PaddingLeft = UDim.new(0,4), PaddingRight = UDim.new(0,4), PaddingTop = UDim.new(0,4), PaddingBottom = UDim.new(0,4), Parent = modeMenu})
        local modeButtons = {}
        local modeGeneration, modeIsOpen, modeTween = 0, false, nil
        local function setModeMenuVisible(show)
            modeGeneration += 1
            local generation = modeGeneration
            modeIsOpen = show
            if modeTween then modeTween:Cancel() end
            if show then modeMenu.Visible = true end
            local tween = TweenService:Create(modeMenu, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {GroupTransparency = show and 0 or 1})
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
            releaseHeldRow()
            self.Mode = mode
            self.ModeChanging = true
            self:SetState(mode == "Always")
            self.ModeChanging = false
            if mode == "Always" and options._Toggle and not options._Toggle.Locked then options._Toggle:Set(true) end
            for name, button in pairs(modeButtons) do button.TextColor3 = name == mode and ThemeColor(255,255,255) or ThemeColor(200,200,200); button.BackgroundTransparency = name == mode and 0 or 1; local stroke = button:FindFirstChildOfClass("UIStroke"); if stroke then stroke.Color = name == mode and ThemeColor(60,200,100) or ThemeColor(60,60,60) end end
            refreshList()
            return true
        end
        for order, mode in ipairs({"Always", "Hold", "Toggle"}) do
            local button = Create("TextButton", {Name = mode, AutoButtonColor = false, BackgroundColor3 = ThemeColor(25,25,25):Lerp(ThemeColor(60,200,100),0.25), BackgroundTransparency = 1, Size = UDim2.new(1,0,0,28), LayoutOrder = order, Text = mode, TextColor3 = ThemeColor(200,200,200), FontFace = regularFont, TextSize = 12, ZIndex = 71, Parent = modeMenu})
            Create("UICorner", {CornerRadius = UDim.new(0,4), Parent = button})
            Create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = ThemeColor(60,60,60), Transparency = 0.25, Parent = button})
            modeButtons[mode] = button
            button.Activated:Connect(function() KeyPicker:SetMode(mode); setModeMenuVisible(false) end)
        end
        local function toggleModeMenu(anchor)
            if KeyPicker.Locked or KeyPicker.Picking or options.FixedMode then return end
            local inset = game:GetService("GuiService"):GetGuiInset()
            local camera = workspace.CurrentCamera
            local view = camera and camera.ViewportSize or Vector2.new(800,600)
            local target = anchor == listRow and frame or anchor
            local right = target.AbsolutePosition.X + target.AbsoluteSize.X + 7
            local x = math.clamp(right + 116 <= view.X and right or target.AbsolutePosition.X - 123, 0, math.max(0, view.X - 116))
            local y = math.clamp(anchor.AbsolutePosition.Y - inset.Y + anchor.AbsoluteSize.Y / 2 - 48, 0, math.max(0, view.Y - inset.Y - 96))
            modeMenu.Position = UDim2.fromOffset(x,y)
            setModeMenuVisible(not modeIsOpen)
        end
        KeyPickerButton.MouseButton2Click:Connect(function() toggleModeMenu(KeyPickerButton) end)
        listRow.MouseButton2Click:Connect(function() toggleModeMenu(listRow) end)
        Library:AddConnection(UserInputService.InputBegan:Connect(function(input)
            if not modeIsOpen or (input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch) then return end
            local p, a, size = input.Position, modeMenu.AbsolutePosition, modeMenu.AbsoluteSize
            if p.X < a.X or p.X > a.X + size.X or p.Y < a.Y or p.Y > a.Y + size.Y then setModeMenuVisible(false) end
        end))

        function KeyPicker:SetKeybind(keybind, picking)
            if picking then KeyPicker:Update(KeyPicker.Keybind, true) return end
            KeyPicker.Keybind = GetKeybindFromString(keybind)
            KeyPicker.KeyPressed = nil
            KeyPicker.Picking = false
            if not KeyPicker.Keybind and KeyPicker.State and KeyPicker.Mode ~= "Always" then KeyPicker:SetState(false) end
            KeyPicker:Update(KeyPicker.Keybind, false)
            refreshList()
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
            refreshList()
        end

        function KeyPicker:SetLocked(locked)
            KeyPicker.Locked = locked == true
            KeyPickerButton.Visible = not KeyPicker.Locked
            editKey.Visible = not KeyPicker.Locked and options.Clearable ~= false
            KeyPickerText.TextTransparency = ThemeTextAlpha(KeyPicker.Locked and 0.75 or 0.5)
        end

        function KeyPicker:Update(keybind, picking)
            local keyText = picking and "..." or (keybind and (keyCodesName[keybind] or string.sub(keybind.Name, 1, 6)) or "None")
            local size = GetTextBounds(keyText, mediumFont, 14, Library.UISize - 24)
            local width = math.clamp((size and size.X or 26) + 16, options._Inline and 28 or 40, options._Inline and 52 or 100)
            KeyPickerButton.Size = UDim2.fromOffset(width, 24)
            KeyPickerText.Size = UDim2.new(1, -(width + (options.Clearable == false and 6 or 35)), 1, 0)
            KeyPickerButton.Text = keyText
            local frameKey = listRow:FindFirstChild("FrameKeybind")
            if frameKey then
                frameKey.Text = keyText
                frameKey.Size = UDim2.fromOffset(picking and 48 or 40, 20)
                frameKey.TextSize = picking and 15 or 12
                rowTitle.Size = UDim2.new(1, picking and -123 or -115, 1, 0)
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
            -- Keep the guard active for the entire InputBegan dispatch.
            task.defer(function()
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

    function Components:AddColorPicker(options: ColorPickerOptions)
        local ColorPickerHolder = Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 42),
            Parent = self.Container
        })
        AttachTooltip(ColorPickerHolder, options, "Color picker")

        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 5),
            PaddingLeft = UDim.new(0, 13),
            PaddingRight = UDim.new(0, 13),
            PaddingTop = UDim.new(0, 5),
            Parent = ColorPickerHolder
        })

        local ButtonsHolder = Create("Frame", {
            BackgroundColor3 = ThemeColor(25, 25, 25),
            Size = UDim2.fromScale(1, 1),
            ClipsDescendants = true,
            Parent = ColorPickerHolder
        })

        Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = ButtonsHolder })
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = ThemeColor(60, 60, 60),
            Parent = ButtonsHolder
        })
        Create("UIGradient", {Color = ColorSequence.new(Color3.new(1,1,1), Color3.fromRGB(230,230,230)), Rotation = 90, Parent = ButtonsHolder})

        local OpenButton: TextButton = Create("TextButton", {
            TextYAlignment = Enum.TextYAlignment.Center,
            BackgroundTransparency = 1,
            FontFace = regularFont,
            Size = UDim2.new(1, 0, 0, 32),
            Text = options.Name or "No Name",
            TextColor3 = ThemeColor(140, 140, 140),
            TextScaled = false, TextSize = 15,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = ButtonsHolder
        })

        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 6),
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 30),
            PaddingTop = UDim.new(0, 6),
            Parent = OpenButton
        })
        Create("Frame", {Name = "ColorHeaderDivider", BorderSizePixel = 0, BackgroundColor3 = ThemeColor(80,80,80), BackgroundTransparency = 0.55, Position = UDim2.fromOffset(6,31), Size = UDim2.new(1,-12,0,1), Parent = ButtonsHolder})

        local pickerScroll = Create("Frame", {Name = "PickerContents", BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.fromOffset(0,32), Size = UDim2.new(1,0,1,-32), Parent = ButtonsHolder})
        local ColorHolder = Create("Frame", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(0, 0),
            Size = UDim2.new(1, 0, 0, Library.UISize - 50),
            Visible = false,
            Parent = pickerScroll
        })

        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 6),
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 6),
            PaddingTop = UDim.new(0, 6),
            Parent = ColorHolder
        })

        local ColorImage = Create("ImageLabel", {
            BackgroundColor3 = options.Color or Color3.new(1, 1, 1),
            Image = "rbxassetid://4155801252",
            Size = UDim2.new(1, -22, 1, 0),
            Parent = ColorHolder
        })

        Create("UICorner", {CornerRadius = UDim.new(0, 5), Parent = ColorImage})
        ColorImage:SetAttribute("ThemeColorIgnore", true)

        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = ThemeColor(60, 60, 60),
            Thickness = 1,
            Parent = ColorImage,
        })

        local ColorImageIndicator = Create("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.new(1, 1, 1),
            Size = UDim2.fromOffset(6, 6),
            Parent = ColorImage
        })

        Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = ColorImageIndicator })
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = Color3.new(0, 0, 0),
            Parent = ColorImageIndicator
        })

        local ColorHue: TextButton = Create("TextButton", {
            AutoButtonColor = false,
            AnchorPoint = Vector2.new(1, 0),
            BackgroundColor3 = Color3.new(1, 1, 1),
            Position = UDim2.fromScale(1, 0),
            Size = UDim2.new(0, 16, 1, 0),
            Text = "",
            Parent = ColorHolder
        })

        Create("UICorner", {CornerRadius = UDim.new(0, 5), Parent = ColorHue})
        ColorHue:SetAttribute("ThemeColorIgnore", true)
        Create("UIGradient", {
            Color = ColorSequence.new(hueSequenceTable),
            Rotation = 90,
            Parent = ColorHue
        })

        local ColorHueIndicator = Create("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderColor3 = Color3.new(0, 0, 0),
            BorderSizePixel = 1,
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.new(1, 2, 0, 2),
            Parent = ColorHue
        })

        ColorHueIndicator:SetAttribute("ThemeColorIgnore", true)
        ColorImageIndicator:SetAttribute("ThemeColorIgnore", true)
        for _, child in ipairs(ColorImageIndicator:GetChildren()) do
            if child:IsA("UIStroke") then child:SetAttribute("ThemeColorIgnore", true) end
        end

        local ColorIndicator = Create("Frame", {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundColor3 = options.Color or Color3.new(1, 1, 1),
            Position = UDim2.new(1, -6, 0, 6),
            Size = UDim2.fromOffset(20, 20),
            Parent = ColorPickerHolder
        })

        ColorIndicator:SetAttribute("ThemeColorIgnore", true)
        Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = ColorIndicator })
        Create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = ThemeColor(80,80,80), Transparency = 0.35, Parent = ColorIndicator})

        local ColorPicker = {
            DraggingColor = false,
            DraggingHue = false,
            Locked = false,
            Hovering = false,
            Opened = false,
            Hue = 0, Sat = 0, Vib = 0,
            Color = options.Color or Color3.new(1, 1, 1),
            Type = "ColorPicker",
            AllowTrans = options.AllowTrans == true, AllowRainbow = options.AllowRainbow == true,
            Transparency = options.AllowTrans and math.clamp(tonumber(options.Transparency) or 0, 0, 1) or 0,
            Rainbow = false,
        }

        local openTweenInfo = TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        local closeTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local CLOSED_HEIGHT = 42
        local controlsHeight = 36 + (ColorPicker.AllowTrans and 42 or 0) + (ColorPicker.AllowRainbow and 32 or 0)
        local bodyHeight = Library.UISize - 50 + controlsHeight
        local OPEN_HEIGHT = CLOSED_HEIGHT + bodyHeight
        local activeTween

        local controls = Create("Frame", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(0, Library.UISize - 50),
            Size = UDim2.new(1, 0, 0, controlsHeight),
            Visible = false,
            Parent = pickerScroll,
        })
        local hexInput = Create("TextBox", {
            BackgroundColor3 = ThemeColor(25, 25, 25),
            ClearTextOnFocus = false,
            FontFace = regularFont,
            TextSize = 14,
            TextColor3 = ThemeColor(140, 140, 140),
            Position = UDim2.fromOffset(6, 3),
            Size = UDim2.new(1, -112, 0, 26),
            Text = "",
            Parent = controls,
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = hexInput})
        local hexStroke = Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = ThemeColor(60, 60, 60),
            Parent = hexInput,
        })
        local hexHover = false
        local function updateHexHover()
            local active = hexHover or hexInput:IsFocused()
            Tween(hexInput, FastTween, {BackgroundColor3 = active and ThemeColor(32, 32, 32) or ThemeColor(25, 25, 25), TextColor3 = active and ThemeColor(220, 220, 220) or ThemeColor(140, 140, 140)})
            Tween(hexStroke, FastTween, {Color = active and ThemeColor(100, 100, 100) or ThemeColor(60, 60, 60)})
        end
        hexInput.MouseEnter:Connect(function() hexHover = true updateHexHover() end)
        hexInput.MouseLeave:Connect(function() hexHover = false updateHexHover() end)
        hexInput.Focused:Connect(updateHexHover)
        hexInput.FocusLost:Connect(function() task.defer(updateHexHover) end)
        local function makeButton(label, x)
            local b = Create("TextButton", {
                AutoButtonColor = false,
                BackgroundColor3 = ThemeColor(25, 25, 25),
                FontFace = regularFont,
                TextSize = 13,
                TextColor3 = ThemeColor(140, 140, 140),
                Position = UDim2.new(1, x, 0, 3),
                Size = UDim2.fromOffset(46, 26),
                Text = label,
                Parent = controls,
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = b})
            local stroke = Create("UIStroke", {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                Color = ThemeColor(60, 60, 60),
                Parent = b,
            })
            b.MouseEnter:Connect(function() Tween(b, FastTween, {TextColor3 = ThemeColor(220, 220, 220), BackgroundColor3 = ThemeColor(32, 32, 32)}) Tween(stroke, FastTween, {Color = ThemeColor(100, 100, 100)}) end)
            b.MouseLeave:Connect(function() Tween(b, FastTween, {TextColor3 = ThemeColor(140, 140, 140), BackgroundColor3 = ThemeColor(25, 25, 25)}) Tween(stroke, FastTween, {Color = ThemeColor(60, 60, 60)}) end)
            return b
        end
        local copyButton, pasteButton = makeButton("Copy", -100), makeButton("Paste", -50)
        local y = 36
        local transLabel, transValue, transBar, transFill, rainbowButton, rainbowKnob, rainbowStroke
        if ColorPicker.AllowTrans then
            transLabel = Create("TextLabel", {
                BackgroundTransparency = 1,
                FontFace = regularFont,
                TextSize = 14,
                TextColor3 = ThemeColor(255, 255, 255),
                TextTransparency = ThemeTextAlpha(0.5),
                TextXAlignment = Enum.TextXAlignment.Left,
                Position = UDim2.fromOffset(6, y),
                Size = UDim2.new(1, -60, 0, 22),
                Text = "Transparency",
                Parent = controls,
            })
            transValue = Create("TextLabel", {
                BackgroundColor3 = ThemeColor(35,35,35),
                FontFace = regularFont,
                TextSize = 12,
                TextColor3 = ThemeColor(255, 255, 255),
                TextTransparency = ThemeTextAlpha(0.5),
                TextXAlignment = Enum.TextXAlignment.Center,
                Position = UDim2.new(1, -54, 0, y),
                Size = UDim2.fromOffset(48, 22),
                Text = "0%",
                Parent = controls,
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = transValue})
            Create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = ThemeColor(60,60,60), Transparency = 0.3, Parent = transValue})
            transBar = Create("TextButton", {
                BackgroundColor3 = ThemeColor(60, 60, 60),
                Position = UDim2.fromOffset(6, y + 25),
                Size = UDim2.new(1, -12, 0, 6),
                Text = "",
                AutoButtonColor = false,
                Parent = controls,
            })
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = transBar})
            transFill = Create("Frame", {
                BackgroundColor3 = ThemeColor(60, 200, 100),
                Size = UDim2.fromScale(0, 1),
                BorderSizePixel = 0,
                Parent = transBar,
            })
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = transFill})
            Create("UIGradient", {Color = ColorSequence.new(Color3.new(1,1,1), Color3.fromRGB(205,205,205)), Rotation = 90, Parent = transFill})
            local transKnob = Create("Frame", {Name = "TransparencyKnob", AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.new(1,0,0.5,0), Size = UDim2.fromOffset(12,12), BackgroundColor3 = Color3.new(1,1,1), Parent = transFill})
            Create("UICorner", {CornerRadius = UDim.new(1,0), Parent = transKnob})
            Create("UIStroke", {Color = ThemeColor(60,200,100), Parent = transKnob})
            transBar.MouseEnter:Connect(function()
                if ColorPicker.Locked then return end
                Tween(transFill, FastTween, {BackgroundColor3 = ThemeColor(60, 200, 100):Lerp(Color3.new(1,1,1),0.15)})
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
                FontFace = regularFont,
                TextSize = 14,
                TextColor3 = ThemeColor(255, 255, 255),
                TextTransparency = ThemeTextAlpha(0.5),
                TextXAlignment = Enum.TextXAlignment.Left,
                Position = UDim2.fromOffset(6, y),
                Size = UDim2.new(1, -48, 0, 24),
                Text = "Rainbow",
                Parent = controls,
            })
            rainbowButton = Create("TextButton", {
                AutoButtonColor = false,
                BackgroundColor3 = ThemeColor(35,35,35),
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -6, 0, y + 12),
                Size = UDim2.fromOffset(32, 16),
                Text = "",
                Parent = controls,
            })
            Create("UIGradient", {Color = ColorSequence.new(Color3.new(1,1,1), Color3.fromRGB(190,190,190)), Rotation = 90, Parent = rainbowButton})
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = rainbowButton})
            Create("UIPadding", {
                PaddingBottom = UDim.new(0, 2),
                PaddingLeft = UDim.new(0, 2),
                PaddingRight = UDim.new(0, 2),
                PaddingTop = UDim.new(0, 2),
                Parent = rainbowButton,
            })
            rainbowStroke = Create("UIStroke", {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                Color = ThemeColor(60, 60, 60),
                Parent = rainbowButton,
            })
            rainbowKnob = Create("Frame", {
                BackgroundColor3 = ThemeColor(140, 140, 140),
                Size = UDim2.fromScale(1, 1),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Parent = rainbowButton,
            })
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = rainbowKnob})
            local function updateRainbowHover(hovering)
                if ColorPicker.Locked then return end
                local base = ColorPicker.Rainbow and enabledToggleColor or defaultToggleColor
                local color = hovering and base:Lerp(Color3.new(1, 1, 1), 0.3) or base
                Tween(rainbowButton, FastTween, {BackgroundColor3 = ColorPicker.Rainbow and color or ThemeColor(35,35,35)})
                Tween(rainbowStroke, FastTween, {Color = color})
            end
            rainbowButton.MouseEnter:Connect(function() updateRainbowHover(true) end)
            rainbowButton.MouseLeave:Connect(function() updateRainbowHover(false) end)
        end
        local function parseColor(value)
            local text = tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", "")
            local hex = text:match("^#?(%x%x%x%x%x%x)$")
            if hex then return Color3.fromHex(hex) end
            local r, g, b = text:match("^%s*%(?%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*%)?%s*$")
            if r and tonumber(r) <= 255 and tonumber(g) <= 255 and tonumber(b) <= 255 then return Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b)) end
        end
        local function applyText(value)
            local color = parseColor(value)
            if color then ColorPicker:SetRainbow(false) ColorPicker:SetColor(color) return true end
            return false
        end
        copyButton.MouseButton1Click:Connect(function()
            copiedPickerColor = "#" .. ColorPicker.Color:ToHex():upper()
            if type(setclipboard) == "function" then pcall(setclipboard, copiedPickerColor) end
        end)
        pasteButton.MouseButton1Click:Connect(function()
            local value
            if type(getclipboard) == "function" then local ok, result = pcall(getclipboard) if ok then value = result end end
            if not applyText(value or "") and not applyText(copiedPickerColor or "") then hexInput:CaptureFocus() end
        end)
        hexInput.FocusLost:Connect(function() if not applyText(hexInput.Text) then hexInput.Text = "#" .. ColorPicker.Color:ToHex():upper() end end)
        function ColorPicker:SetTransparency(value)
            if not ColorPicker.AllowTrans then return end
            local old = ColorPicker.Transparency
            ColorPicker.Transparency = math.clamp(tonumber(value) or 0, 0, 1)
            transFill.Size = UDim2.fromScale(ColorPicker.Transparency, 1)
            transValue.Text = ("%d%%"):format(math.floor(ColorPicker.Transparency * 100 + 0.5))
            if old ~= ColorPicker.Transparency then Library:SafeCallback(options.Callback, ColorPicker.Color, ColorPicker.Color, ColorPicker.Transparency) end
        end
        function ColorPicker:SetRainbow(enabled)
            ColorPicker.Rainbow = ColorPicker.AllowRainbow and enabled == true
            if ColorPicker.Rainbow then
                ColorPicker.DraggingColor = false
                ColorPicker.DraggingHue = false
            end
            if rainbowButton then
                local color = ColorPicker.Rainbow and enabledToggleColor or defaultToggleColor
                rainbowStroke.Color = color
                rainbowButton.BackgroundColor3 = ColorPicker.Rainbow and enabledToggleColor or ThemeColor(35,35,35)
                rainbowKnob.BackgroundColor3 = ColorPicker.Rainbow and Color3.new(1,1,1) or ThemeColor(140,140,140)
                Tween(rainbowKnob, FastTween, {Position = ColorPicker.Rainbow and UDim2.fromOffset(16, 0) or UDim2.fromOffset(0, 0)})
            end
        end
        if rainbowButton then rainbowButton.MouseButton1Click:Connect(function() if not ColorPicker.Locked then ColorPicker:SetRainbow(not ColorPicker.Rainbow) end end) end
        if transBar then
            local drag
            local function updateTrans(input) ColorPicker:SetTransparency((input.Position.X - transBar.AbsolutePosition.X) / math.max(transBar.AbsoluteSize.X, 1)) end
            transBar.InputBegan:Connect(function(input)
                if ColorPicker.Locked or (input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch) then return end
                drag = input updateTrans(input)
            end)
            Library:AddConnection(UserInputService.InputChanged:Connect(function(input)
                if drag and (input == drag or (drag.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseMovement)) then updateTrans(input) end
            end))
            Library:AddConnection(UserInputService.InputEnded:Connect(function(input) if input == drag then drag = nil end end))
            ColorPicker:SetTransparency(ColorPicker.Transparency)
        end
        Library:AddConnection(RunService.Heartbeat:Connect(function(dt)
            if ColorPicker.Rainbow then ColorPicker.Hue = (ColorPicker.Hue + dt * 0.12) % 1 ColorPicker.Sat = 1 ColorPicker.Vib = 1 ColorPicker:Update() end
        end))

        function ColorPicker:SetColor(newColor: Color3)
            local h, s, v = newColor:ToHSV()
            ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = h, s, v
            ColorPicker:Update()
        end

        function ColorPicker:SetColorHSV(hsv)
            ColorPicker:SetColor(Color3.fromHSV(hsv[1], hsv[2], hsv[3]))
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
            if activeTween then activeTween:Cancel() end
            ColorHolder.Visible = true
            controls.Visible = true
            if not ColorPicker.Opened then
                ColorPicker.DraggingColor = false
                ColorPicker.DraggingHue = false
            end
            local tween = TweenService:Create(ColorPickerHolder, ColorPicker.Opened and openTweenInfo or closeTweenInfo, {
                Size = ColorPicker.Opened and UDim2.new(1, 0, 0, OPEN_HEIGHT) or UDim2.new(1, 0, 0, CLOSED_HEIGHT)
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
            ColorPicker.Color = Color3.fromHSV(ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib)
            ColorImage.BackgroundColor3 = Color3.fromHSV(ColorPicker.Hue, 1, 1)
            ColorIndicator.BackgroundColor3 = ColorPicker.Color
            ColorImageIndicator.Position = UDim2.new(ColorPicker.Sat, 0, 1 - ColorPicker.Vib, 0)
            ColorHueIndicator.Position = UDim2.fromScale(0.5, ColorPicker.Hue)
            if not hexInput:IsFocused() then hexInput.Text = "#" .. ColorPicker.Color:ToHex():upper() end
            if ColorPicker.Color ~= oldColor then
                Library:SafeCallback(options.Callback, ColorPicker.Color, oldColor, ColorPicker.Transparency)
            end
        end

        if options.Flag then
            Library.Flags[options.Flag] = ColorPicker
        end

        OpenButton.MouseEnter:Connect(function()
            ColorPicker.Hovering = true
            if ColorPicker.Locked then return end
            Tween(OpenButton, FastTween, {TextColor3 = ThemeColor(220, 220, 220)})
        end)

        OpenButton.MouseLeave:Connect(function()
            ColorPicker.Hovering = false
            if ColorPicker.Locked then return end
            Tween(OpenButton, FastTween, {TextColor3 = ThemeColor(140, 140, 140)})
        end)

        OpenButton.MouseButton1Click:Connect(function() ColorPicker:Toggle() end)

        ColorImage.InputBegan:Connect(function(input)
            if not ColorPicker.Locked and not ColorPicker.Rainbow and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                ColorPicker.DraggingColor = true
                local minX = ColorImage.AbsolutePosition.X
                local maxX = minX + ColorImage.AbsoluteSize.X
                local mouseX = math.clamp(input.Position.X, minX, maxX)
                local minY = ColorImage.AbsolutePosition.Y
                local maxY = minY + ColorImage.AbsoluteSize.Y
                local mouseY = math.clamp(input.Position.Y, minY, maxY)
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
                local mouseY = math.clamp(input.Position.Y, minY, maxY)
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
            if not Library.Opened and not (activeOption and activeOption.Opened and ColorPickerHolder:IsDescendantOf(activeOption.Container)) then
                ColorPicker.DraggingColor = false
                ColorPicker.DraggingHue = false
                return
            end
            if ColorPicker.DraggingColor then
                local minX = ColorImage.AbsolutePosition.X
                local maxX = minX + ColorImage.AbsoluteSize.X
                local mouseX = math.clamp(input.Position.X, minX, maxX)
                local minY = ColorImage.AbsolutePosition.Y
                local maxY = minY + ColorImage.AbsoluteSize.Y
                local mouseY = math.clamp(input.Position.Y, minY, maxY)
                ColorPicker.Sat = (mouseX - minX) / (maxX - minX)
                ColorPicker.Vib = 1 - (mouseY - minY) / (maxY - minY)
                ColorPicker:Update()
            elseif ColorPicker.DraggingHue then
                local minY = ColorHue.AbsolutePosition.Y
                local maxY = minY + ColorHue.AbsoluteSize.Y
                local mouseY = math.clamp(input.Position.Y, minY, maxY)
                ColorPicker.Hue = (mouseY - minY) / (maxY - minY)
                ColorPicker:Update()
            end
        end))

        ColorPicker:SetColor(options.Color or Color3.new(1, 1, 1))
        ColorPicker:SetRainbow(options.Rainbow == true)
    RegisterControlForPalette(self, options, ColorPicker, "Color")
        return ColorPicker
    end

    BaseComponents.__index = Components
    BaseComponents.__namecall = function(Table, Key, ...)
        return Components[Key](...)
    end
end

local snowLayer, snowConnection
local snowflakes = {}
local snowEnabled = false
local function SetSnow(enabled)
    snowEnabled = enabled == true
    if enabled and not snowLayer then
        snowLayer = Create("Frame", {
            Name = "ThemeSnow",
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            ClipsDescendants = true,
            Active = false,
            ZIndex = 30,
            Parent = UI,
        })
        snowLayer:SetAttribute("ThemeColorIgnore", true)
        local rng = Random.new()
        for _ = 1, 42 do
            local size = rng:NextInteger(2, 5)
            local opacity = rng:NextNumber(0.18, 0.50)
            local dot = Create("Frame", {
                BackgroundColor3 = Color3.fromRGB(245, 250, 255),
                BackgroundTransparency = opacity,
                BorderSizePixel = 0,
                Size = UDim2.fromOffset(size, size),
                ZIndex = 30,
                Active = false,
                Parent = snowLayer,
            })
            dot:SetAttribute("ThemeColorIgnore", true)
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = dot})
            local particle = {dot = dot, x = rng:NextNumber(), y = rng:NextNumber(), speed = rng:NextNumber(0.025, 0.065), drift = rng:NextNumber(0.005, 0.018), phase = rng:NextNumber(0, 6.28), sway = rng:NextNumber(0.6, 1.4), opacity = opacity}
            dot.Position = UDim2.fromScale(particle.x, particle.y)
            table.insert(snowflakes, particle)
        end
        local time = 0
        snowConnection = RunService.Heartbeat:Connect(function(dt)
            if not snowLayer or not snowLayer.Parent then return end
            local show = snowEnabled and (Library.Opened ~= false or Library._PaletteSnowActive == true)
            snowLayer.Visible = show
            local snowZ = Library._PaletteSnowActive and 106 or 30
            if snowLayer.ZIndex ~= snowZ then snowLayer.ZIndex = snowZ; for _, particle in ipairs(snowflakes) do particle.dot.ZIndex = snowZ end end
            if not show then return end
            time += dt
            for _, particle in ipairs(snowflakes) do
                particle.y = (particle.y + dt * particle.speed) % 1.04
                local sway = math.sin(time * particle.sway + particle.phase) * particle.drift
                particle.dot.Position = UDim2.fromScale(particle.x + sway, particle.y - 0.02)
                particle.dot.BackgroundTransparency = math.clamp(particle.opacity + math.sin(time * 1.1 + particle.phase) * 0.08, 0, 1)
            end
        end)
        Library:AddConnection(snowConnection)
    end
    if snowLayer then
        snowLayer.Visible = enabled and Library.Opened ~= false
        local snowColor = Color3.fromRGB(245, 250, 255)
        for index, particle in ipairs(snowflakes) do
            particle.dot.BackgroundColor3 = snowColor
        end
    end
end

function Library:SetTheme(name)
    name = ResolveThemeName(name)
    if not name or name == themeName then return end
    local previous = themeName
    themeName = name
    local reverse = {}
    for _, shade in ipairs(themeNeutralValues) do
        reverse[paletteColor(previous, shade, shade, shade):ToHex()] = {shade, shade, shade}
    end
    reverse[paletteColor(previous, 60, 200, 100):ToHex()] = {60, 200, 100}
    local function recolor(object, property)
        local ok, color = pcall(function() return object[property] end)
        if not ok or typeof(color) ~= "Color3" then return end
        local original = reverse[color:ToHex()]
        if original then object[property] = paletteColor(name, table.unpack(original)) end
    end
    for _, object in ipairs(UI:GetDescendants()) do
        if not object:GetAttribute("ThemeColorIgnore") then
            if object:IsA("GuiObject") then
                if object:GetAttribute("ThemeAccentButton") then
                    object.BackgroundColor3 = ThemeColor(25, 25, 25):Lerp(ThemeColor(60, 200, 100), 0.09)
                else
                    recolor(object, "BackgroundColor3")
                end
            end
            if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
                recolor(object, "TextColor3")
                local alpha = object.TextTransparency
                if IsLightTheme(previous) and alpha > 0 and alpha < 1 then alpha = math.clamp(alpha / 0.48, 0, 1) end
                if IsLightTheme(name) and alpha > 0 and alpha < 1 then alpha *= 0.48 end
                object.TextTransparency = alpha
            end
            if object:IsA("TextBox") then recolor(object, "PlaceholderColor3") end
            if (object:IsA("ImageLabel") or object:IsA("ImageButton")) and object:GetAttribute("ThemeIcon") then
                if IsLightTheme(name) then
                    if not IsLightTheme(previous) then
                        object:SetAttribute("ThemeIconOriginalColor", object.ImageColor3)
                        object:SetAttribute("ThemeIconOriginalTransparency", object.ImageTransparency)
                    end
                    if object:GetAttribute("MainTitleIcon") then
                        object.ImageColor3 = Color3.fromRGB(15, 17, 20)
                        object.ImageTransparency = math.min(object.ImageTransparency, 0.12)
                    else
                        object.ImageColor3 = Color3.fromRGB(50, 55, 60)
                    end
                elseif IsLightTheme(previous) then
                    object.ImageColor3 = object:GetAttribute("ThemeIconOriginalColor") or Color3.new(1, 1, 1)
                    local originalAlpha = object:GetAttribute("ThemeIconOriginalTransparency")
                    if originalAlpha ~= nil then object.ImageTransparency = originalAlpha end
                end
            end
            if object:GetAttribute("ThemeAccentIcon") and (object:IsA("ImageLabel") or object:IsA("ImageButton")) then
                object.ImageColor3 = ThemeColor(60, 200, 100)
            end
            if object:IsA("ScrollingFrame") then recolor(object, "ScrollBarImageColor3") end
            if object:IsA("UIStroke") then recolor(object, "Color") end
        end
    end
    defaultToggleColor = ThemeColor(60, 60, 60)
    hoveringToggleColor = ThemeColor(100, 100, 100)
    enabledToggleColor = ThemeColor(60, 200, 100)
    for _, refresh in ipairs(self.ThemeToggleRefreshers or {}) do refresh() end
    self.Theme = name
    if self.RefreshCommandPalette then self:RefreshCommandPalette() end
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
    local Result = table.pack(xpcall(Func, function(Error)
        warn("[Library]: | " .. debug.traceback(tostring(Error), 2))
        return Error
    end, ...))
    if not Result[1] then return nil end
    return table.unpack(Result, 2, Result.n)
end

function Library:AddConnection(connection)
    table.insert(Library.Connections, connection)
end

local BorderGradients = {}
AddAnimatedBorder = function(Parent)
    local Stroke = Create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = ThemeColor(60, 200, 100), Thickness = 1, Parent = Parent})
    local Gradient = Create("UIGradient", {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.58),
            NumberSequenceKeypoint.new(0.23, 0.56),
            NumberSequenceKeypoint.new(0.32, 0.49),
            NumberSequenceKeypoint.new(0.40, 0.30),
            NumberSequenceKeypoint.new(0.46, 0.10),
            NumberSequenceKeypoint.new(0.50, 0.03),
            NumberSequenceKeypoint.new(0.54, 0.10),
            NumberSequenceKeypoint.new(0.60, 0.30),
            NumberSequenceKeypoint.new(0.68, 0.49),
            NumberSequenceKeypoint.new(0.77, 0.56),
            NumberSequenceKeypoint.new(1, 0.58),
        }),
        Parent = Stroke,
    })
    Stroke.Transparency = Parent.GroupTransparency
    Library:AddConnection(Parent:GetPropertyChangedSignal("GroupTransparency"):Connect(function()
        Stroke.Transparency = Parent.GroupTransparency
    end))
    table.insert(BorderGradients, Gradient)
end
Library:AddConnection(RunService.Heartbeat:Connect(function()
    local Rotation = (os.clock() * 32) % 360
    for i = #BorderGradients, 1, -1 do
        local Gradient = BorderGradients[i]
        if Gradient.Parent then Gradient.Rotation = Rotation else table.remove(BorderGradients, i) end
    end
end))

if Library.Mobile then
    local scale = Create("UIScale", { Parent = Windows })
    local cameraConnection
    local function UpdateScale()
        local camera = workspace.CurrentCamera
        if not camera then return end
        local vp = camera.ViewportSize
        if vp.X <= 0 or vp.Y <= 0 then return end

        local fitWidth = math.max(1, vp.X - 24) / (Library.UISize * 2 + 6)
        local fitHeight = math.max(1, vp.Y - 24) / 260
        scale.Scale = math.min(1, fitWidth, fitHeight)
    end
    local function BindCamera()
        if cameraConnection then cameraConnection:Disconnect() end
        local camera = workspace.CurrentCamera
        if camera then
            cameraConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateScale)
            Library:AddConnection(cameraConnection)
        end
        UpdateScale()
    end
    Library.MobileScale = scale
    Library:AddConnection(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(BindCamera))
    BindCamera()
end

local function GetStorageFolder()
    if Library.SaveFolder == nil then return nil end
    local root = string.match(Library.SaveFolder, "^([^/]+)")
    if not root or root == "" then return nil end
    return root .. "/Storage"
end

local function EnsureSaveFolder()
    if Library.SaveFolder == nil then return false end
    if not isfolder(Library.SaveFolder) then makefolder(Library.SaveFolder) end

    local storage = GetStorageFolder()
    if storage and not isfolder(storage) then
        makefolder(storage)
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
        if path then writefile(path, HttpService:JSONEncode({ Theme = name })) end
    end)
    return ok
end

local function LoadTheme()
    local path = GetThemeFile()
    if not path then return nil end
    local ok, data = pcall(function()
        if not isfile(path) then return nil end
        return HttpService:JSONDecode(readfile(path))
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

    writefile(path, tostring(HttpService:JSONEncode(data)))
    return true
end

local function LoadPositions()
    local path = GetPositionFile()
    if not path or not isfile(path) then return false end

    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(path))
    end)
    if not ok or type(data) ~= "table" then return false end

    if data.MainWindow and Library.MainWindow then
        local m = data.MainWindow
        Library.MainWindow.Position = UDim2.new(m.XScale, m.XOffset, m.YScale, m.YOffset)
    end

    if data.Tabs and Library.TabHolders then
        for index, pos in pairs(data.Tabs) do
            local holder = Library.TabHolders[tonumber(index) or index]
            if holder and holder.Parent then
                holder.Position = UDim2.new(pos.XScale, pos.XOffset, pos.YScale, pos.YOffset)
            end
        end
    end

    return true
end

local function HasSavedPositions()
    local path = GetPositionFile()
    return path ~= nil and isfile(path)
end

local function ApplyDefaultPositions()
    if not Library.DefaultPositions then return end

    if Library.DefaultPositions.MainWindow and Library.MainWindow then
        local m = Library.DefaultPositions.MainWindow
        Library.MainWindow.Position = UDim2.new(m.XScale, m.XOffset, m.YScale, m.YOffset)
    end

    if Library.DefaultPositions.Tabs and Library.TabHolders then
        for index, pos in pairs(Library.DefaultPositions.Tabs) do
            local holder = Library.TabHolders[tonumber(index) or index]
            if holder and holder.Parent then
                holder.Position = UDim2.new(pos.XScale, pos.XOffset, pos.YScale, pos.YOffset)
            end
        end
    end
end

local function ResetPositions()
    local path = GetPositionFile()
    if path and isfile(path) then
        delfile(path)
    end
    ApplyDefaultPositions()
end

local function SaveToggleState(state)
    if not EnsureSaveFolder() then return end
    local path = GetToggleStateFile()
    if not path then return end

    writefile(path, tostring(HttpService:JSONEncode({
        Enabled = state and true or false
    })))
end

local function LoadToggleState()
    local path = GetToggleStateFile()
    if not path or not isfile(path) then return false end

    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(path))
    end)
    if not ok or type(data) ~= "table" then return false end

    return data.Enabled == true
end

local function ResetToggleStateFile()
    local path = GetToggleStateFile()
    if path and isfile(path) then
        delfile(path)
    end
end

local function SaveKeybind(keybind)
    if not EnsureSaveFolder() then return end
    local path = GetKeybindFile()
    if not path then return end
    writefile(path, tostring(HttpService:JSONEncode({
        Keybind = keybind and tostring(keybind) or "None"
    })))
end

local function LoadKeybind()
    local path = GetKeybindFile()
    if not path or not isfile(path) then return nil end

    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(path))
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
    Library.ToggleKeybind = options.ToggleKeybind or Enum.KeyCode.RightShift
    local defaultTheme = ResolveThemeName(options.Theme) or "Default"
    local storedTheme = LoadTheme()
    Library.InitialTheme = storedTheme or defaultTheme
    Library:SetTheme(Library.InitialTheme)
    if not storedTheme then SaveTheme(Library.InitialTheme) end


    if options.Blur ~= false then
        Library.Blur = Create("BlurEffect", { Size = 12, Parent = Lighting })
    end

    local MainWindow = Create("CanvasGroup", {
        GroupTransparency = 0,
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = ThemeColor(25, 25, 25),
        Size = UDim2.fromOffset(Library.UISize, 0),
        Parent = Windows
    })

    table.insert(Library.Tabs, MainWindow)
    Library.MainWindow = MainWindow
    Library.TabHolders = {}
    Library.TabAnimations = {}
    Library.DefaultPositions = { MainWindow = { XScale = MainWindow.Position.X.Scale, XOffset = MainWindow.Position.X.Offset, YScale = MainWindow.Position.Y.Scale, YOffset = MainWindow.Position.Y.Offset }, Tabs = {} }

    Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = MainWindow })

    AddAnimatedBorder(MainWindow)
    Create("UIListLayout", { Parent = MainWindow })

    local Top = Create("Frame", {
        BackgroundColor3 = ThemeColor(20, 20, 20),
        Size = UDim2.new(1, 0, 0, 40),
        Parent = MainWindow
    })

    Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = Top })
    Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 1),
        BackgroundColor3 = ThemeColor(20, 20, 20),
        Position = UDim2.fromScale(0.5, 1),
        Size = UDim2.fromScale(1, 0.25),
        Parent = Top
    })

    local TitleIconDef = options.Icon and Library:GetIcon(options.Icon)
    if TitleIconDef then
        local TitleIcon = Create("ImageLabel", {
            BackgroundTransparency = 1,
            Image = "",
            ImageColor3 = ThemeColor(60, 200, 100),
            Position = UDim2.fromOffset(9, 5),
            Size = UDim2.fromOffset(30, 30),
            ZIndex = 2,
            Parent = Top
        })
        TitleIcon:SetAttribute("MainTitleIcon", true)
        TitleIcon:SetAttribute("ThemeColorIgnore", true)
        Library:ApplyIcon(TitleIcon, TitleIconDef)
        TitleIcon.ImageColor3 = Color3.new(1, 1, 1)
    end

    local Title = Create("TextLabel", {
        BackgroundTransparency = 1,
        FontFace = semiBoldFont,
        Position = UDim2.fromOffset(TitleIconDef and 36 or 0, 0),
        Size = UDim2.new(1, TitleIconDef and -32 or 0, 1, 0),
        Text = options.Title or "No Title",
        TextColor3 = ThemeColor(255, 255, 255),
        TextScaled = false, TextSize = 15,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Left,
        RichText = true,
        Parent = Top
    })
    Create("UIPadding", {
        PaddingBottom = UDim.new(0, 6),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        PaddingTop = UDim.new(0, 6),
        Parent = Title
    })

    Create("Frame", { BackgroundColor3 = ThemeColor(60, 60, 60), Size = UDim2.new(1, 0, 0, 1), Parent = MainWindow })

    local TabButtons = Create("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 0),
        Parent = MainWindow
    })
    Create("UIPadding", {PaddingLeft = UDim.new(0, 7), PaddingRight = UDim.new(0, 7), PaddingTop = UDim.new(0, 4), Parent = TabButtons})
    Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 3), Parent = TabButtons })

    Create("Frame", { BackgroundTransparency = 1, LayoutOrder = 999, Size = UDim2.new(1, 0, 0, 6), Parent = MainWindow })

    task.spawn(Library.Toggle)

    local Window = { CommandCategory = "Commands" }
    function Window:NewSection(name)
        self.CommandCategory = tostring(name or "Commands")
        return self
    end
    function Window:AddCommand(info, ...)
        if type(info) == "table" then
            info = table.clone(info)
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
            Position = UDim2.fromOffset((Library.UISize + 6) * (Library.Mobile and 1 or #Library.Tabs), 0),
            Size = UDim2.fromOffset(Library.UISize, 0),
            Visible = false,
            Parent = Windows,
        })

        table.insert(Library.Tabs, TabHolder)

        if Library.TabHolders then
            table.insert(Library.TabHolders, TabHolder)
            local p = TabHolder.Position
            Library.DefaultPositions.Tabs[#Library.TabHolders] = { XScale = p.X.Scale, XOffset = p.X.Offset, YScale = p.Y.Scale, YOffset = p.Y.Offset }
        end

        Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = TabHolder })
    Create("UIGradient", {Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(210, 210, 210)), Rotation = 90, Parent = TabHolder})
        AddAnimatedBorder(TabHolder)
        Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = TabHolder })

        local Top2 = Create("TextButton", {
            AutoButtonColor = false,
            BackgroundColor3 = ThemeColor(20, 20, 20),
            Size = UDim2.new(1, 0, 0, 40),
            Text = "",
            Parent = TabHolder
        })

        Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = Top2 })
        Create("Frame", {
            AnchorPoint = Vector2.new(0.5, 1),
            BackgroundColor3 = ThemeColor(20, 20, 20),
            Position = UDim2.fromScale(0.5, 1),
            Size = UDim2.fromScale(1, 0.25),
            Parent = Top2
        })

        local DragDots = Create("Frame", {BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(9, 16), Parent = Top2})
        for row = 0, 2 do
            for column = 0, 1 do
                local Dot = Create("Frame", {BackgroundColor3 = ThemeColor(200, 200, 200), BackgroundTransparency = 0.18, Position = UDim2.fromOffset(column * 5, row * 5 + 1), Size = UDim2.fromOffset(2, 2), Parent = DragDots})
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Dot})
            end
        end

        local HeaderIconDef = IconName and Library:GetIcon(IconName)
        if HeaderIconDef then
            local HeaderIcon = Create("ImageLabel", {
                BackgroundTransparency = 1, Image = "", ImageTransparency = 0.3,
                Position = UDim2.fromOffset(12, 10), Size = UDim2.fromOffset(20, 20), ZIndex = 2, Parent = Top2
            })
            Library:ApplyIcon(HeaderIcon, HeaderIconDef)
        end

        local Title2 = Create("TextLabel", {
            BackgroundTransparency = 1, FontFace = mediumFont,
            Position = UDim2.fromOffset(HeaderIconDef and 28 or 0, 0),
            Size = UDim2.new(1, HeaderIconDef and -60 or 0, 1, 0),
            Text = tabName or "No Name", TextColor3 = ThemeColor(255, 255, 255),
            TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left, Parent = Top2
        })
        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12), PaddingTop = UDim.new(0, 6), Parent = Title2
        })


        Create("Frame", {BackgroundColor3 = ThemeColor(80, 80, 80), BackgroundTransparency = 0.25, Size = UDim2.new(1, 0, 0, 1), Parent = TabHolder})
        local Elements = Create("ScrollingFrame", {
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
            CanvasSize = UDim2.fromScale(0, 0),
            ScrollBarImageColor3 = ThemeColor(95, 95, 95),
            ScrollBarThickness = 4,
            Size = UDim2.fromScale(1, 0),
            TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
            Parent = TabHolder
        })

        local ElementsListLayout = Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            Padding = UDim.new(0, 5),
            Parent = Elements,
        })

        Create("Frame", { BackgroundTransparency = 1, LayoutOrder = 999, Size = UDim2.new(1, 0, 0, 6), Parent = TabHolder })

        Create("Frame", {BackgroundTransparency = 1, LayoutOrder = -1000, Size = UDim2.new(1, 0, 0, 2), Parent = Elements})

        local TabButton: TextButton = Create("TextButton", {
            AutoButtonColor = false,
            BackgroundColor3 = ThemeColor(25, 25, 25),
            LayoutOrder = (#Library.TabHolders * 2) - 2,
            Size = UDim2.new(1, 0, 0, 36),
            Text = "",
            Parent = TabButtons
        })

        Create("UICorner", { CornerRadius = UDim.new(0, 7), Parent = TabButton })
        local NavStroke = Create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = ThemeColor(60, 200, 100), Transparency = 1, Thickness = 1, Parent = TabButton})

        local SelectedIndicator = Create("Frame", {
            Name = "SelectedIndicator", BorderSizePixel = 0,
            BackgroundColor3 = ThemeColor(60, 200, 100),
            Position = UDim2.fromOffset(0, 2), Size = UDim2.new(0, 4, 1, -4),
            Visible = false, ZIndex = 2, Parent = TabButton,
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = SelectedIndicator })

        local TabButtonText = Create("TextLabel", {
            TextYAlignment = Enum.TextYAlignment.Center,
            BackgroundTransparency = 1, FontFace = mediumFont,
            Position = UDim2.fromOffset(HeaderIconDef and 18 or 0, 0),
            Size = UDim2.new(1, HeaderIconDef and -24 or 0, 1, 0),
            Text = tabName or "No Name", TextColor3 = ThemeColor(255, 255, 255),
            TextScaled = false, TextSize = 16, TextTransparency = ThemeTextAlpha(0.5),
            TextXAlignment = Enum.TextXAlignment.Left, Parent = TabButton
        })

        local TabButtonIcon
        if HeaderIconDef then
            TabButtonIcon = Create("ImageLabel", {
                BackgroundTransparency = 1, Image = "", ImageTransparency = 0.18,
                Position = UDim2.fromOffset(4, 8), Size = UDim2.fromOffset(20, 20), ZIndex = 2, Parent = TabButton
            })
            Library:ApplyIcon(TabButtonIcon, HeaderIconDef)
        end

        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 11),
            PaddingRight = UDim.new(0, 11), PaddingTop = UDim.new(0, 8), Parent = TabButtonText
        })

        local Tab = { Hovering = false, Opened = false, Locked = false, _LastWasSection = false }
        local tabLock = Create("TextButton", {Name = "TabLock", BackgroundTransparency = 0.75, BackgroundColor3 = Color3.new(0,0,0), Size = UDim2.fromScale(1,1), Text = "", AutoButtonColor = false, Visible = false, ZIndex = 50, Parent = TabHolder})
        function Tab:SetLocked(locked)
            self.Locked = locked == true
            tabLock.Visible = self.Locked
            Library._PaletteLocks[tostring(tabName or "Main")] = self.Locked or nil
        end
        local panelTween
        local panelTweenId = 0

        function Tab:RefreshTheme()
            Tween(TabButton, FastTween, {BackgroundColor3 = Tab.Opened and ThemeColor(25, 25, 25):Lerp(ThemeColor(60, 200, 100), 0.13) or ThemeColor(25, 25, 25)})
        end

        function Tab:AnimatePanel(show)
            panelTweenId += 1
            local animationId = panelTweenId
            if panelTween then panelTween:Cancel() end
            if show then TabHolder.Visible = true end
            if not TabHolder.Visible then return end
            local tween = TweenService:Create(TabHolder, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {GroupTransparency = show and 0 or 1})
            panelTween = tween
            tween.Completed:Connect(function(state)
                if animationId ~= panelTweenId or state ~= Enum.PlaybackState.Completed then return end
                panelTween = nil
                if not Tab.Opened then TabHolder.Visible = false end
            end)
            tween:Play()
        end
        table.insert(Library.TabAnimations, Tab)

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
            if TabButtonIcon then Tween(TabButtonIcon, FastTween, {Position = UDim2.fromOffset(Tab.Opened and 7 or 4, 8)}) end
            Tab:AnimatePanel(Tab.Opened and Library.Opened ~= false)
            Tween(TabButton, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Tab.Opened and ThemeColor(25, 25, 25):Lerp(ThemeColor(60, 200, 100), 0.13) or (Tab.Hovering and ThemeColor(30, 30, 30) or ThemeColor(25, 25, 25))})
            Tween(TabButtonText, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.fromOffset((HeaderIconDef and 18 or 0) + (Tab.Opened and 3 or 0), 0), TextTransparency = ThemeTextAlpha(Tab.Opened and 0 or (Tab.Hovering and 0.25 or 0.5))})
        end

        if Library.Mobile then table.insert(MobileTabs, Tab) end

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
                Size = UDim2.new(1, -12, 0, 36),
                ClipsDescendants = true,
                Parent = Elements,
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 11), Parent = ElementHolder})
            local BorderOverlay = Create("Frame", {Name = "SectionBorder", BackgroundTransparency = 1, Position = UDim2.fromOffset(1, 1), Size = UDim2.new(1, -2, 1, -2), ZIndex = 4, Parent = ElementHolder})
            Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = BorderOverlay})
            Create("UIStroke", {Color = ThemeColor(80, 80, 80), Transparency = 0.18, Thickness = 1, Parent = BorderOverlay})
            local ButtonFrame = Create("TextButton", {
                AutoButtonColor = false, BackgroundColor3 = ThemeColor(45, 45, 45),
                Size = UDim2.new(1, 0, 0, 36), Text = "", Parent = ElementHolder,
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 11), Parent = ButtonFrame})
            Create("UIGradient", {Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(220, 220, 220)), Rotation = 90, Parent = ButtonFrame})
            -- Continue the header gradient to a flat lower edge when expanded.
            local HeaderBottom = Create("Frame", {
                BackgroundColor3 = ThemeColor(45, 45, 45), BorderSizePixel = 0,
                AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1),
                Size = UDim2.new(1, 0, 0, 10), Visible = false, Parent = ButtonFrame,
            })
            Create("UIGradient", {Color = ColorSequence.new(Color3.fromRGB(230, 230, 230), Color3.fromRGB(220, 220, 220)), Rotation = 90, Parent = HeaderBottom})

            local HeaderDivider = Create("Frame", {BackgroundColor3 = ThemeColor(80, 80, 80), BackgroundTransparency = 0.28, BorderSizePixel = 0, AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 1), Visible = false, ZIndex = 2, Parent = ButtonFrame})

            local SectionIcon
            local IconDef = SectionIconName and Library:GetIcon(SectionIconName)
            if IconDef then
                SectionIcon = Create("ImageLabel", {BackgroundTransparency = 1, Image = "",
                    ImageColor3 = ThemeColor(220, 220, 220), ImageTransparency = 0.2,
                    Position = UDim2.fromOffset(10, 9), Size = UDim2.fromOffset(18, 18), Parent = ButtonFrame})
                Library:ApplyIcon(SectionIcon, IconDef)
            end
            Create("TextLabel", {
                BackgroundTransparency = 1, FontFace = semiBoldFont,
                Position = UDim2.fromOffset(IconDef and 36 or 11, 0),
                Size = UDim2.new(1, -(IconDef and 72 or 47), 1, 0),
                Text = DisplayName, TextColor3 = ThemeColor(220, 220, 220),
                TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd, Parent = ButtonFrame,
            })
            local Chevron = Create("ImageLabel", {
                AnchorPoint = Vector2.new(1, 0.5), BackgroundTransparency = 1, Image = "",
                ImageColor3 = ThemeColor(255, 255, 255), ImageTransparency = 0.1,
                Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(18, 18),
                Visible = CanMinimize, Parent = ButtonFrame,
            })
            local Components = Create("Frame", {
                AnchorPoint = Vector2.new(0.5, 1), BackgroundTransparency = 1,
                Position = UDim2.fromScale(0.5, 1), Size = UDim2.new(1, 0, 1, -36), Parent = ElementHolder,
            })
            local ComponentsListLayout = Create("UIListLayout", {
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                SortOrder = Enum.SortOrder.LayoutOrder, Parent = Components,
            })
            local ElementSection = {Container = Components, Opened = false, Collapsible = CanMinimize, _PaletteCategory = tostring(tabName or "Main") .. " / " .. DisplayName}
            local sectionLock = Create("TextButton", {Name = "SectionLock", BackgroundTransparency = 0.75, BackgroundColor3 = Color3.new(0,0,0), Size = UDim2.fromScale(1,1), Text = "", AutoButtonColor = false, Visible = false, ZIndex = 50, Parent = ElementHolder})
            function ElementSection:SetLocked(locked) self.Locked = locked == true; sectionLock.Visible = self.Locked; Library._PaletteLocks[self._PaletteCategory] = self.Locked or nil end
            local function UpdateSectionHeight()
                local Scale = Library.Mobile and Library.MobileScale.Scale or 1
                HeaderBottom.Visible = ElementSection.Opened
                HeaderDivider.Visible = ElementSection.Opened
                local Height = ElementSection.Opened and ComponentsListLayout.AbsoluteContentSize.Y / Scale + 36 or 36
                Tween(ElementHolder, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    Size = UDim2.new(1, -12, 0, Height),
                })
                if Chevron.Visible then Library:ApplyIcon(Chevron, Library:GetIcon(ElementSection.Opened and "chevron-up" or "chevron-down")) end
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
            Library:AddConnection(ComponentsListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateSectionHeight))
            if Library.Mobile then Library:AddConnection(Library.MobileScale:GetPropertyChangedSignal("Scale"):Connect(UpdateSectionHeight)) end
            ButtonFrame.MouseButton1Click:Connect(function() ElementSection:Toggle() end)
            setmetatable(ElementSection, BaseComponents)
            ElementSection:SetOpen(InitiallyOpen)
            return ElementSection
        end


        function Tab:AddElementToggle(options: ElementToggleOptions)
            local ElementHolder: TextButton = Create("TextButton", {
                AutoButtonColor = false, BackgroundColor3 = ThemeColor(25, 25, 25),
                Size = UDim2.new(1, 0, 0, 36), Text = "", Parent = Elements
            })
            AttachTooltip(ElementHolder, options, "Toggle")

            local ButtonFrame: TextButton = Create("TextButton", {
                AutoButtonColor = false, BackgroundColor3 = ThemeColor(25, 25, 25),
                FontFace = regularFont, Size = UDim2.new(1, 0, 0, 36),
                Text = options.Name or "Button", TextColor3 = ThemeColor(255, 255, 255),
                TextScaled = false, TextSize = 15, TextTransparency = ThemeTextAlpha(0.5),
                TextXAlignment = Enum.TextXAlignment.Left, Parent = ElementHolder
            })

            local KeybindButton: TextButton = Create("TextButton", {
                AutoButtonColor = false, AnchorPoint = Vector2.new(1, 0),
                BackgroundTransparency = 0.95, FontFace = semiBoldFont,
                Position = UDim2.new(1, -28, 0, 8), Size = UDim2.fromOffset(20, 20),
                Text = "...", TextColor3 = ThemeColor(255, 255, 255), TextSize = 14,
                TextTransparency = ThemeTextAlpha(0.5), Parent = ElementHolder
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = KeybindButton })

            local Components = Create("Frame", {
                AnchorPoint = Vector2.new(0.5, 1), BackgroundColor3 = ThemeColor(20, 20, 20),
                Position = UDim2.fromScale(0.5, 1), Size = UDim2.new(1, 0, 1, -36), Parent = ElementHolder
            })

            local ComponentsListLayout = Create("UIListLayout", {
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                SortOrder = Enum.SortOrder.LayoutOrder, Parent = Components
            })
            local Icon = Create("ImageLabel", {
                AnchorPoint = Vector2.new(1, 0), BackgroundTransparency = 1, Image = "",
                ImageTransparency = 0.5, Position = UDim2.new(1, -4, 0, 8),
                Size = UDim2.fromOffset(20, 20), ZIndex = 2, Parent = ElementHolder
            })
            Library:ApplyIcon(Icon, PopOutIcon)
            Create("UIPadding", {
                PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 11),
                PaddingRight = UDim.new(0, 11), PaddingTop = UDim.new(0, 8), Parent = ButtonFrame
            })

            ElementHolder.ClipsDescendants = true
            local ElementToggle = {
                Container = Components, Hovering = false, KeyPressed = nil,
                Locked = false, Opened = false, Picking = false, State = false,
                Name = options.Name or "Toggle", Value = options.Value or false,
                Keybind = options.Keybind or nil, Mode = options.Mode or "Toggle",
                Type = "ElementToggle"
            }

            function ElementToggle:Set(newValue: boolean)
                local oldValue = ElementToggle.Value
                ElementToggle.Value = newValue
                ButtonFrame.BackgroundColor3 = ElementToggle.Value and ThemeColor(35, 35, 35) or (ElementToggle.Hovering and ThemeColor(30, 30, 30) or ThemeColor(25, 25, 25))
                ButtonFrame.TextTransparency = ThemeTextAlpha(ElementToggle.Value and 0 or (ElementToggle.Hovering and 0.25 or 0.5))
                if ElementToggle.Value ~= oldValue then
                    Library:SafeCallback(options.Callback, ElementToggle.Value, oldValue)
                end
            end

            function ElementToggle:SetLocked(locked: boolean)
                ElementToggle.Locked = locked == true

                Icon.Position = ElementToggle.Locked and UDim2.new(1, -7, 0, 8) or UDim2.new(1, -4, 0, 8)
                Library:ApplyIcon(Icon, ElementToggle.Locked and LockIcon or (ElementToggle.Opened and PopInIcon or PopOutIcon))
            end

            function ElementToggle:SetKeybind(keybind, picking)
                if picking then ElementToggle:UpdateKeybind(ElementToggle.Keybind, true) return end
                ElementToggle.Keybind = GetKeybindFromString(keybind)
                ElementToggle.KeyPressed = nil
                ElementToggle.Picking = false
                ElementToggle:UpdateKeybind(ElementToggle.Keybind, false)
            end

            function ElementToggle:SetKey(value) self:SetKeybind(value) end
            function ElementToggle:ClearKeybind() self:SetKeybind(nil) end

            function ElementToggle:UpdateKeybind(keybind, picking)
                local keyText = picking and "..." or (keybind and (keyCodesName[keybind] or string.sub(keybind.Name, 1, 6)) or "None")
                local size = GetTextBounds(keyText, semiBoldFont, 14, Library.UISize - 24)
                if size then KeybindButton.Size = UDim2.fromOffset(size.X + 12, 20) end
                KeybindButton.Text = keyText
            end

            function ElementToggle:Toggle()
                ElementToggle.Opened = not ElementToggle.Opened
                Tween(ElementHolder, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = ElementToggle.Opened and UDim2.new(1, 0, 0, ComponentsListLayout.AbsoluteContentSize.Y / (Library.Mobile and Library.MobileScale.Scale or 1) + 36) or UDim2.new(1, 0, 0, 36)})
                Library:ApplyIcon(Icon, ElementToggle.Opened and PopInIcon or PopOutIcon)
            end

            if options.Flag then Library.Flags[options.Flag] = ElementToggle end

            local function UpdateSectionHeight()
                Tween(ElementHolder, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = ElementToggle.Opened and UDim2.new(1, 0, 0, ComponentsListLayout.AbsoluteContentSize.Y / (Library.Mobile and Library.MobileScale.Scale or 1) + 36) or UDim2.new(1, 0, 0, 36)})
            end
            Library:AddConnection(ComponentsListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateSectionHeight))
            if Library.Mobile then
                Library:AddConnection(Library.MobileScale:GetPropertyChangedSignal("Scale"):Connect(UpdateSectionHeight))
            end

            ButtonFrame.MouseButton1Click:Connect(function()
                if ElementToggle.Locked then return end
                ElementToggle:Set(not ElementToggle.Value)
            end)
            ButtonFrame.MouseButton2Click:Connect(function() ElementToggle:Toggle() end)

            KeybindButton.MouseEnter:Connect(function()
                Tween(KeybindButton, FastTween, {TextTransparency = ThemeTextAlpha(0.25)})
            end)

            KeybindButton.MouseLeave:Connect(function()
                Tween(KeybindButton, FastTween, {TextTransparency = ThemeTextAlpha(0.5)})
            end)

            KeybindButton.MouseButton1Click:Connect(function()
                if ElementToggle.Picking then return end
                ElementToggle.Picking = true
                ElementToggle:SetKeybind(nil, true)
                local inputObject = UserInputService.InputBegan:Wait()
                local isKeyCode = inputObject.KeyCode ~= Enum.KeyCode.Unknown
                if isKeyCode and (inputObject.KeyCode == Enum.KeyCode.Escape or inputObject.KeyCode == Enum.KeyCode.Backspace or inputObject.KeyCode == Enum.KeyCode.Delete) then
                    ElementToggle:SetKeybind(nil)
                    ElementToggle.Picking = false
                    return
                end
                local selected = isKeyCode and inputObject.KeyCode or inputObject.UserInputType
                ElementToggle:SetKeybind(selected)
                ElementToggle.KeyPressed = selected
                ElementToggle.Picking = true
            end)

            Library:AddConnection(UserInputService.InputBegan:Connect(function(input, gp)
                if not ElementToggle.Locked and ElementToggle.Keybind and (input.KeyCode == ElementToggle.Keybind or input.UserInputType == ElementToggle.Keybind) and not ElementToggle.Picking and not gp then
                    if ElementToggle.Mode == "Hold" then ElementToggle:Set(true)
                    else ElementToggle:Set(not ElementToggle.Value) end
                end
            end))
            Library:AddConnection(UserInputService.InputEnded:Connect(function(input)
                if not ElementToggle.Locked and ElementToggle.Keybind and (input.KeyCode == ElementToggle.Keybind or input.UserInputType == ElementToggle.Keybind) and not ElementToggle.Picking then
                    if ElementToggle.Mode == "Hold" then ElementToggle:Set(false) end
                elseif (input.KeyCode == ElementToggle.KeyPressed or input.UserInputType == ElementToggle.KeyPressed) and ElementToggle.Picking then
                    ElementToggle.KeyPressed = nil
                    ElementToggle.Picking = false
                end
            end))

            ElementToggle:Set(ElementToggle.Value)
            ElementToggle:SetKeybind(ElementToggle.Keybind)
            ElementToggle._PaletteCategory = tostring(tabName or "Main") .. " / " .. tostring(options.Name or "Toggle")
            setmetatable(ElementToggle, BaseComponents)
            RegisterControlForPalette(ElementToggle, options, ElementToggle, "Toggle")
            return ElementToggle
        end

        MakeDraggable(Top2, TabHolder)

        local function UpdateElementsSize()
            local camera = workspace.CurrentCamera
            if not camera then return end
            local scale = Library.Mobile and Library.MobileScale.Scale or 1
            local contentHeight = ElementsListLayout.AbsoluteContentSize.Y / scale
            local maxHeight = Library.Mobile and math.max(0, (camera.ViewportSize.Y - 24) / scale - 48)
                or math.max(0, camera.ViewportSize.Y - 100)
            Elements.Size = UDim2.new(1, 0, 0, math.clamp(contentHeight, 0, maxHeight))
        end
        UpdateElementsSize()
        Library:AddConnection(ElementsListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateElementsSize))
        if Library.Mobile then
            Library:AddConnection(Library.MobileScale:GetPropertyChangedSignal("Scale"):Connect(UpdateElementsSize))
        end

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
            Name = "DialogueOverlay", AutoButtonColor = false, BackgroundColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = "", Visible = false, ZIndex = 40, Parent = UI,
        })
        local panel = Create("CanvasGroup", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.new(0.9, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = ThemeColor(25, 25, 25), GroupTransparency = 1, ZIndex = 41, Parent = overlay,
        })

        Create("UISizeConstraint", {MaxSize = Vector2.new(360, 10000), Parent = panel})
        Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = panel})
        local panelStroke = Create("UIStroke", {
            Color = ThemeColor(60, 60, 60),
            Transparency = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Parent = panel,
        })
        panel:GetPropertyChangedSignal("GroupTransparency"):Connect(function() panelStroke.Transparency = panel.GroupTransparency end)
        Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Parent = panel})
        local header = Create("Frame", {
            BackgroundColor3 = ThemeColor(20, 20, 20),
            Size = UDim2.new(1, 0, 0, 40),
            LayoutOrder = 1,
            ZIndex = 42,
            Parent = panel,
        })

        Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = header})
        Create("Frame", {
            BackgroundColor3 = ThemeColor(20, 20, 20),
            Position = UDim2.new(0, 0, 1, -6),
            Size = UDim2.new(1, 0, 0, 6),
            ZIndex = 42,
            Parent = header,
        })
        local dialogueIcon = options.Icon and Library:GetIcon(options.Icon)
        if dialogueIcon then
            local image = Create("ImageLabel", {
                BackgroundTransparency = 1,
                Image = "",
                ImageTransparency = 0.3,
                Position = UDim2.fromOffset(12, 10),
                Size = UDim2.fromOffset(20, 20),
                ZIndex = 43,
                Parent = header,
            })
            Library:ApplyIcon(image, dialogueIcon)
        end
        Create("TextLabel", {
            BackgroundTransparency = 1,
            FontFace = mediumFont,
            TextColor3 = ThemeColor(255, 255, 255),
            TextSize = 20,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Position = UDim2.fromOffset(dialogueIcon and 40 or 12, 0),
            Size = UDim2.new(1, dialogueIcon and -52 or -24, 1, 0),
            Text = options.Title or "Dialogue",
            ZIndex = 43,
            Parent = header,
        })
        Create("Frame", {
            BackgroundColor3 = ThemeColor(60, 60, 60),
            Size = UDim2.new(1, 0, 0, 1),
            LayoutOrder = 2,
            ZIndex = 42,
            Parent = panel,
        })
        local body = Create("Frame", {
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y,
            Size = UDim2.new(1, 0, 0, 0),
            LayoutOrder = 3,
            ZIndex = 42,
            Parent = panel,
        })
        Create("UIPadding", {
            PaddingTop = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 5),
            PaddingLeft = UDim.new(0, 13),
            PaddingRight = UDim.new(0, 13),
            Parent = body,
        })
        Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 15), Parent = body})
        local message = options.Content or options.Description or ""
        Create("TextLabel", {
            BackgroundTransparency = 1,
            FontFace = regularFont,
            TextColor3 = ThemeColor(255, 255, 255),
            TextTransparency = ThemeTextAlpha(0.3),
            TextSize = 17,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            Text = message,
            Visible = message ~= "",
            AutomaticSize = Enum.AutomaticSize.Y,
            Size = UDim2.new(1, 0, 0, 0),
            LayoutOrder = 1,
            ZIndex = 43,
            Parent = body,
        })
        local buttons = Create("ScrollingFrame", {
            BackgroundTransparency = 1,
            Active = true,
            CanvasSize = UDim2.fromOffset(0, 0),
            ScrollingDirection = Enum.ScrollingDirection.X,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = ThemeColor(100, 100, 100),
            Size = UDim2.new(1, 0, 0, 38),
            LayoutOrder = 2,
            ZIndex = 43,
            Parent = body,
        })
        Create("UIPadding", {
            PaddingTop = UDim.new(0, 2),
            PaddingBottom = UDim.new(0, 4),
            PaddingLeft = UDim.new(0, 2),
            PaddingRight = UDim.new(0, 2),
            Parent = buttons,
        })
        local buttonLayout = Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 6),
            Parent = buttons,
        })
        buttonLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            buttons.CanvasSize = UDim2.fromOffset(buttonLayout.AbsoluteContentSize.X + 4, 0)
        end)
        local dialogue = {Opened = false}
        local fadeId, panelTween, overlayTween = 0, nil, nil
        local function animate(show)
            fadeId += 1
            local id = fadeId
            if panelTween then panelTween:Cancel() end
            if overlayTween then overlayTween:Cancel() end
            if show then overlay.Visible = true end
            local info = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
            local tween = TweenService:Create(panel, info, {GroupTransparency = show and 0 or 1})
            panelTween = tween
            overlayTween = TweenService:Create(overlay, info, {BackgroundTransparency = show and 0.45 or 1})
            tween.Completed:Connect(function(state)
                if id ~= fadeId or state ~= Enum.PlaybackState.Completed then return end
                panelTween = nil
                if not dialogue.Opened then
                    overlay.Visible = false
                    if activeDialogue == dialogue then activeDialogue = nil end
                end
            end)
            tween:Play()
            overlayTween:Play()
        end
        function dialogue:Open()
            if self.Opened or (activeDialogue and activeDialogue ~= self) then return false end
            activeDialogue = self
            self.Opened = true
            animate(true)
            return true
        end
        function dialogue:Close()
            if not self.Opened then return end
            self.Opened = false
            animate(false)
        end
        function dialogue:Destroy()
            fadeId += 1
            if panelTween then panelTween:Cancel() end
            if overlayTween then overlayTween:Cancel() end
            if activeDialogue == self then activeDialogue = nil end
            overlay:Destroy()
        end
        function dialogue:AddButton(buttonOptions, callback)
            if type(buttonOptions) == "string" then buttonOptions = {Name = buttonOptions, Callback = callback} end
            buttonOptions = buttonOptions or {}
            local button = Create("TextButton", {
                AutoButtonColor = false,
                BackgroundColor3 = ThemeColor(30, 30, 30),
                FontFace = regularFont,
                TextSize = 15,
                TextColor3 = ThemeColor(255, 255, 255),
                TextTransparency = ThemeTextAlpha(0.35),
                Text = buttonOptions.Name or buttonOptions.Title or "Button",
                Size = UDim2.fromOffset(76, 28),
                ZIndex = 44,
                Parent = buttons,
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = button})
            local stroke = Create("UIStroke", {
                Color = ThemeColor(60, 60, 60),
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                Parent = button,
            })
            button.MouseEnter:Connect(function() Tween(button, FastTween, {TextTransparency = ThemeTextAlpha(0.25)}) Tween(stroke, FastTween, {Color = hoveringToggleColor}) end)
            button.MouseLeave:Connect(function() Tween(button, FastTween, {TextTransparency = ThemeTextAlpha(0.35)}) Tween(stroke, FastTween, {Color = defaultToggleColor}) end)
            button.MouseButton1Click:Connect(function()
                Library:SafeCallback(buttonOptions.Callback, dialogue)
            end)
            return button
        end
        for _, button in ipairs(options.Buttons or {}) do dialogue:AddButton(button) end
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

        -- The palette shortcut uses its own file, separate from the UI toggle key.
        local paletteFile = GetStorageFolder() and (GetStorageFolder() .. "/PaletteKeybind.json")
        local savedPaletteKey
        if paletteFile and isfile(paletteFile) then
            local ok, data = pcall(function() return HttpService:JSONDecode(readfile(paletteFile)) end)
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
                        writefile(paletteFile, HttpService:JSONEncode({Keybind = self.Keybind and tostring(self.Keybind) or "None"}))
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
            task.defer(function()
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
            AnchorPoint = Vector2.new(1, 0),
            BackgroundColor3 = ThemeColor(20, 20, 20),
            Position = UDim2.new(1, -12, 0, 12),
            Size = UDim2.fromOffset(194, 52),
            Parent = UI,
        })

        Library.MobileButton = MobileButtonHolder
        Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = MobileButtonHolder })
        Create("UIGradient", {Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(210, 210, 210)), Rotation = 90, Parent = MobileButtonHolder})
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = ThemeColor(60, 200, 100),
            Thickness = 1,
            Transparency = 0.45,
            Parent = MobileButtonHolder,
        })

        local IconHolder = Create("Frame", {
            BackgroundColor3 = ThemeColor(30, 30, 30),
            Position = UDim2.fromOffset(10, 10),
            Size = UDim2.fromOffset(32, 32),
            Parent = MobileButtonHolder,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = IconHolder })
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = ThemeColor(72, 72, 72),
            Thickness = 1,
            Transparency = 0.2,
            Parent = IconHolder,
        })

        local UIIcon = Create("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Image = "",
            ImageTransparency = 0,
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(18, 18),
            Parent = IconHolder,
        })
        Library:ApplyIcon(UIIcon, Library:GetIcon("layout-grid") or SettingsIcon)
        UIIcon.ImageColor3 = ThemeColor(60, 200, 100)
        Library.MobileRouterIcon = UIIcon

        local TitleLabel = Create("TextLabel", {
            BackgroundTransparency = 1,
            FontFace = semiBoldFont,
            Position = UDim2.fromOffset(52, 8),
            Size = UDim2.new(1, -75, 0, 20),
            Text = "Menu",
            TextColor3 = ThemeColor(255, 255, 255),
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTransparency = 0.05,
            Parent = MobileButtonHolder,
        })

        local SubtitleLabel = Create("TextLabel", {
            BackgroundTransparency = 1,
            FontFace = regularFont,
            Position = UDim2.fromOffset(52, 27),
            Size = UDim2.new(1, -75, 0, 16),
            Text = "Tap to toggle",
            TextColor3 = ThemeColor(200, 200, 200),
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTransparency = 0.05,
            Parent = MobileButtonHolder,
        })

        local Grip = Create("ImageLabel", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundTransparency = 1,
            Image = "",
            ImageTransparency = 0.5,
            Position = UDim2.new(1, -46, 0.5, 0),
            Size = UDim2.fromOffset(16, 16),
            Parent = MobileButtonHolder,
        })
        Library:ApplyIcon(Grip, MoveIcon or Library:GetIcon("move"))

        local Accent = Create("Frame", {
            AnchorPoint = Vector2.new(0.5, 1),
            BackgroundColor3 = ThemeColor(60, 200, 100),
            BackgroundTransparency = 0.35,
            BorderSizePixel = 0,
            Position = UDim2.fromScale(0.5, 1),
            Size = UDim2.new(1, -20, 0, 2),
            Parent = MobileButtonHolder,
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Accent })

        local Interaction = Create("TextButton", {
            Name = "MobileToggleInteraction",
            AutoButtonColor = false,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -40, 1, 0),
            Text = "",
            Parent = MobileButtonHolder,
        })

        local PaletteButton = Create("TextButton", {
            Name = "MobilePaletteButton", AutoButtonColor = false,
            AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -7, 0.5, 0),
            Size = UDim2.fromOffset(32, 30), BackgroundColor3 = ThemeColor(25, 25, 25):Lerp(ThemeColor(60, 200, 100), 0.16),
            Text = "", ZIndex = 3, Parent = MobileButtonHolder,
        })
        PaletteButton:SetAttribute("ThemeAccentButton", true)
        Create("UIGradient", {Color = ColorSequence.new(Color3.fromRGB(255,255,255), Color3.fromRGB(205,205,205)), Rotation = 90, Parent = PaletteButton})
        Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = PaletteButton})
        Create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = ThemeColor(60, 200, 100), Transparency = 0.55, Parent = PaletteButton})
        local PaletteIcon = Create("ImageLabel", {Name = "PaletteIcon", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(16, 16), Image = "", ImageColor3 = ThemeColor(60, 200, 100), ZIndex = 4, Parent = PaletteButton})
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
                dragConn = nil
            end
            Tween(MobileButtonHolder, FastTween, { Size = UDim2.fromOffset(194, 52) })
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

            Tween(MobileButtonHolder, FastTween, { Size = UDim2.fromOffset(190, 50) })

            if dragConn then dragConn:Disconnect() end
            dragConn = UserInputService.InputChanged:Connect(function(i)
                if not dragging or not activeInput then return end
                if activeInput.UserInputType == Enum.UserInputType.Touch then
                    if i ~= activeInput then return end
                    if #UserInputService:GetTouches() > 1 then moved = true EndDrag() return end
                elseif i.UserInputType ~= Enum.UserInputType.MouseMovement then return end

                local delta = i.Position - dragStartPos
                if not moved then
                    if math.abs(delta.X) >= DRAG_THRESHOLD or math.abs(delta.Y) >= DRAG_THRESHOLD then
                        moved = true
                    end
                end

                if moved then
                    local camera = workspace.CurrentCamera
                    local viewport = camera and camera.ViewportSize or Vector2.new(800, 600)
                    local inset = game:GetService("GuiService"):GetGuiInset()
                    local size = MobileButtonHolder.AbsoluteSize
                    local x = math.clamp(startButtonAbsolute.X + delta.X, 6, math.max(6, viewport.X - size.X - 6))
                    local y = math.clamp(startButtonAbsolute.Y + delta.Y, 0, math.max(0, viewport.Y - size.Y - 1))
                    MobileButtonHolder.Position = UDim2.new(
                        startFramePos.X.Scale, startFramePos.X.Offset + x - startButtonAbsolute.X,
                        startFramePos.Y.Scale, startFramePos.Y.Offset + y - startButtonAbsolute.Y
                    )
                end
            end)
            table.insert(Library.Connections, dragConn)

            local endedConn
            endedConn = input.Changed:Connect(function()
                if input.UserInputState ~= Enum.UserInputState.End then return end
                if endedConn then endedConn:Disconnect() end
                if activeInput ~= input then return end
                local wasMoved = moved
                EndDrag()

                if not wasMoved then
                    task.spawn(Library.Toggle)
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
            task.spawn(Library.Toggle)
        elseif input.KeyCode == Library.ToggleKeybind then
            task.spawn(Library.Toggle)
        end
    end))

    MakeDraggable(Top, MainWindow)
    return Window
end

function Library:Notify(text: string, duration: number)
    text = tostring(text or "")
    duration = math.max(0, tonumber(duration) or 5)
    local camera = workspace.CurrentCamera
    local maxWidth = camera and math.clamp(camera.ViewportSize.X - 32, 120, 340) or 300
    local bounds = GetTextBounds(text, regularFont, 15, math.max(40, maxWidth - 60)) or Vector2.new(120, 18)
    local width = math.min(maxWidth, math.max(180, bounds.X + 60))
    local height = math.max(46, bounds.Y + 22)
    local Holder = Create("Frame", {BackgroundTransparency = 1, Size = UDim2.fromOffset(width, height), Parent = Notifications})
    local Card = Create("CanvasGroup", {BackgroundColor3 = ThemeColor(25, 25, 25), GroupTransparency = 1, Position = UDim2.new(1, 12, 0, 0), Size = UDim2.fromScale(1, 1), Parent = Holder})
    Create("UICorner", {CornerRadius = UDim.new(0, 9), Parent = Card})
    Create("UIGradient", {Color = ColorSequence.new(Color3.fromRGB(255,255,255), Color3.fromRGB(210,210,210)), Rotation = 90, Parent = Card})
    local Stroke = Create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = ThemeColor(80, 80, 80), Transparency = 1, Parent = Card})
    Card:GetPropertyChangedSignal("GroupTransparency"):Connect(function() Stroke.Transparency = 0.3 + 0.7 * Card.GroupTransparency end)
    local Accent = Create("Frame", {BackgroundColor3 = ThemeColor(60, 200, 100), Position = UDim2.fromOffset(0, 8), Size = UDim2.new(0, 3, 1, -16), Parent = Card})
    Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Accent})
    local Icon = Create("ImageLabel", {BackgroundTransparency = 1, Image = "", ImageColor3 = ThemeColor(60, 200, 100), Position = UDim2.new(0, 13, 0.5, -9), Size = UDim2.fromOffset(18, 18), Parent = Card})
    Icon:SetAttribute("ThemeAccentIcon", true)
    Library:ApplyIcon(Icon, Library:GetIcon("info"))
    Create("TextLabel", {BackgroundTransparency = 1, FontFace = regularFont, Position = UDim2.fromOffset(39, 6), Size = UDim2.new(1, -49, 1, -12), Text = text, TextColor3 = ThemeColor(255, 255, 255), TextSize = 15, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Parent = Card})
    local Show = TweenService:Create(Card, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.fromScale(0, 0), GroupTransparency = 0})
    Show:Play()
    task.delay(duration, function()
        if not Holder.Parent or not Card.Parent then return end
        local Hide = TweenService:Create(Card, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Position = UDim2.new(1, 12, 0, 0), GroupTransparency = 1})
        Hide:Play()
        Hide.Completed:Once(function() if Holder.Parent then Holder:Destroy() end end)
    end)
end

local ModalElement = Create("TextButton", {
    BackgroundTransparency = 1, Modal = true,
    Size = UDim2.fromScale(1, 1), Text = "", Visible = false, ZIndex = 0, Parent = UI
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
    if activeOption and activeOption.Opened then
        if Library.Opened then
            activeOption:ReturnToToggle()
        else
            activeOption:DetachToLeft()
        end
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
    local tween = TweenService:Create(main, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
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

-- Commands, a searchable command palette, tooltips and reusable context menus.
-- Insert after Library:AddConnection is defined and before Library:Unload.
do
    local commands = {}
    local paletteClipboard
    local palette, search, results, emptyLabel
    local openingCharacter, openingCharacterDeadline, ignoredOpeningPrefix
    local function paletteInput()
        local text = search and search.Text or ""
        if ignoredOpeningPrefix and text:sub(1,1) == ignoredOpeningPrefix then return text:sub(2) end
        return text
    end
    local paletteBox, paletteTween, overlayTween, paletteResizeTween, paletteBlur
    local resizePalette
    local paletteGeneration = 0
    local selected = 1
    local expandedDropdowns = {}
    local favoriteCommands, favoritesLoaded = {}, false
    local function favoritePath()
        return (Library.SaveFolder or "Library") .. "/Favorites.json"
    end
    local function loadFavorites()
        if favoritesLoaded then return end
        favoritesLoaded = true
        if type(isfile) ~= "function" or type(readfile) ~= "function" then return end
        local ok, data = pcall(function()
            local path = favoritePath()
            local legacy = (Library.SaveFolder or "Library") .. "/CommandFavorites.json"
            if isfile(path) then return HttpService:JSONDecode(readfile(path)) end
            if isfile(legacy) then return HttpService:JSONDecode(readfile(legacy)) end
        end)
        if ok and type(data) == "table" then favoriteCommands = data end
    end
    local function saveFavorites()
        if type(writefile) ~= "function" then return end
        pcall(function() if EnsureSaveFolder() then writefile(favoritePath(), HttpService:JSONEncode(favoriteCommands)) end end)
    end
    local matches = {}
    local paletteConnections = {}
    local activeMenu
    local ownedHandles = {}
    local foreground = Color3.fromRGB(235, 235, 235)
    local muted = Color3.fromRGB(160, 160, 160)
    local background = Color3.fromRGB(25, 25, 25)
    local rowColor = Color3.fromRGB(38, 38, 38)

    local function make(class, properties)
        return Create(class, properties)
    end

    local function corner(parent, radius)
        make("UICorner", { CornerRadius = UDim.new(0, radius or 6), Parent = parent })
    end

    local function track(connection)
        Library:AddConnection(connection)
        return connection
    end

    local function cleanConnections(connections)
        for _, connection in ipairs(connections) do
            if connection.Connected then connection:Disconnect() end
        end
        table.clear(connections)
    end

    local function screenPoint(position)
        local inset = game:GetService("GuiService"):GetGuiInset()
        return Vector2.new(position.X - inset.X, position.Y - inset.Y)
    end

    local function viewport()
        local camera = workspace.CurrentCamera
        local size = camera and camera.ViewportSize or Vector2.new(800, 600)
        local inset = game:GetService("GuiService"):GetGuiInset()
        return Vector2.new(size.X, math.max(1, size.Y - inset.Y))
    end

    local function button(parent, text, z)
        return make("TextButton", {
            AutoButtonColor = true, BackgroundColor3 = rowColor,
            BorderSizePixel = 0, Text = text, TextColor3 = foreground,
            TextSize = 14, Font = Enum.Font.Gotham, ZIndex = z, Parent = parent,
        })
    end

    -- Supports both table definitions and the older positional command API.
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
        local command = table.clone(info)
        command.Description = tostring(info.Description or "")
        command.Arguments = type(info.Arguments) == "table" and table.clone(info.Arguments) or nil
        command.Aliases = info.Aliases or info.Alias or info.Support or {}
        if type(command.Aliases) == "string" then command.Aliases = {command.Aliases} end
        if type(command.Aliases) ~= "table" then command.Aliases = {} end
        command.Category = tostring(info.Category or info.Section or "Commands")
        if command.Type == "Dropdown" and command.Kind ~= "Feature" then
            command.Values = type(info.Values) == "table" and table.clone(info.Values) or {}
            command.Multi = info.Multi == true
            command.AllowNull = info.AllowNull ~= false
            command.Searchable = info.Searchable ~= false
            command.Selectable = info.Selectable == true
            command._CustomDropdown = true
            local first = command.Values[1]
            if first == nil then
                local keys = {}
                for key in pairs(command.Values) do table.insert(keys, key) end
                table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)
                first = keys[1]
            end
            if command.Multi then
                local selected = {}
                if type(info.Default) == "table" then
                    for key, value in pairs(info.Default) do
                        if type(key) == "number" then selected[value] = true
                        elseif value == true then selected[key] = true end
                    end
                elseif info.Default ~= nil then selected[info.Default] = true end
                local available = {}
                for key, option in pairs(command.Values) do available[type(key) == "number" and option or key] = true end
                for option in pairs(selected) do if not available[option] then selected[option] = nil end end
                if not command.AllowNull and next(selected) == nil and first ~= nil then selected[first] = true end
                command.DefaultValue = next(selected) or first
                command.Value = selected
            else
                local default = info.Default
                local valid = false
                for key, option in pairs(command.Values) do
                    if (type(key) == "number" and option or key) == default then valid = true; break end
                end
                command.Value = valid and default or first
            end
            function command:GetValue()
                return self.Multi and table.clone(self.Value) or self.Value
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
                task.spawn(self.Callback, self:GetValue())
                if palette and palette.Visible and not Library._PaletteBatch then Library:RefreshCommandPalette() end
                return true
            end
            command.ValueText = function()
                if command.Multi then
                    local labels = {}
                    for option, enabled in pairs(command.Value) do if enabled then table.insert(labels, tostring(option)) end end
                    table.sort(labels)
                    return #labels > 0 and table.concat(labels, " • ") or "None"
                end
                return command.Value ~= nil and tostring(command.Value) or "None"
            end
        end
        commands[info.Name:lower()] = command
        if palette and palette.Visible and not self._PaletteBatch then self:RefreshCommandPalette() end
        return command
    end

    local function findCommand(name)
        if type(name) ~= "string" then return nil end
        local needle = name:lower()
        if commands[needle] then return commands[needle] end
        for _, command in pairs(commands) do
            for _, alias in ipairs(command.Aliases) do
                if type(alias) == "string" and alias:lower() == needle then return command end
            end
        end
    end

    function Library:RemoveCommand(name)
        local command = findCommand(name)
        if not command then return false end
        commands[command.Name:lower()] = nil
        if palette and palette.Visible and not self._PaletteBatch then self:RefreshCommandPalette() end
        return true
    end

    function Library:GetCommands()
        local list = {}
        for _, command in pairs(commands) do table.insert(list, command) end
        table.sort(list, function(a, b) return a.Name:lower() < b.Name:lower() end)
        return list
    end

    function Library:RunCommand(name, ...)
        local command = findCommand(name)
        if not command then return false end
        local args = table.pack(...)
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
                local selected = command:GetValue()
                if selected[value] then
                    selected[value] = nil
                else selected[value] = true end
                return command:SetValue(selected)
            end
            return command:SetValue(value)
        end
        task.spawn(function()
            local ok, err
            if command._LegacyArguments or command.Kind == "Feature" or command.Arguments ~= nil then
                local values = args.n == 1 and type(args[1]) == "table" and args[1] or args
                ok, err = pcall(command.Callback, values, Library.LocalPlayer)
            else
                ok, err = pcall(command.Callback, table.unpack(args, 1, args.n))
            end
            if not ok then warn("[Library] Command '" .. command.Name .. "' failed: " .. tostring(err)) end
        end)
        return true
    end

    local function splitArguments(text)
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
                if started then table.insert(values, current); current = ""; started = false end
            else current ..= c; started = true end
        end
        if escaped then current ..= "\\" end
        if started then table.insert(values, current) end
        return values
    end

    local function argumentsFor(command, input)
        local trimmed = input:match("^%s*(.-)%s*$") or ""
        local lower = trimmed:lower()
        local names = {command.Name}
        if command.Kind == "Feature" then
            local leaf = command.Name:match("([^/]+)$")
            if leaf then table.insert(names, (leaf:match("^%s*(.-)%s*$"))) end
        end
        for _, alias in ipairs(command.Aliases) do if type(alias) == "string" then table.insert(names, alias) end end
        table.sort(names, function(a, b) return #a > #b end)
        for _, name in ipairs(names) do
            if lower:sub(1, #name) == name:lower() and (#lower == #name or lower:sub(#name + 1, #name + 1):match("%s")) then
                return splitArguments(trimmed:sub(#name + 1))
            end
        end
        local trailing = trimmed:match("^%S+%s+(.+)$")
        return trailing and splitArguments(trailing) or {}
    end

    local function commandDescription(command)
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

    local function distance(a, b)
        local previous = {}; for j = 0, #b do previous[j] = j end
        for i = 1, #a do
            local current = {[0] = i}
            for j = 1, #b do
                current[j] = math.min(current[j-1] + 1, previous[j] + 1, previous[j-1] + (a:sub(i,i) == b:sub(j,j) and 0 or 1))
            end
            previous = current
        end
        return previous[#b]
    end

    local function matchScore(command, query)
        if query == "" then return 0 end
        local lower = query:lower():match("^%s*(.-)%s*$") or ""
        local first = lower:match("^(%S+)") or ""
        local best
        local function consider(value)
            if type(value) ~= "string" then return end
            local name = value:lower()
            local score
            if lower == name or (lower:sub(1,#name) == name and lower:sub(#name+1,#name+1):match("%s")) then score = 0
            elseif name:sub(1,#lower) == lower then score = 1
            elseif command.Kind == "Feature" and #first >= 2 and name:sub(1,#first) == first and lower:find("%s") then score = 3
            elseif #first >= 3 and #first <= 64 and #name <= 128 and distance(first, name) <= 2 then score = 2 + distance(first, name)
            elseif name:find(lower,1,true) then score = 10 end
            if score and (not best or score < best) then best = score end
        end
        consider(command.Name)
        if command.Kind == "Feature" then
            local leaf = command.Name:match("([^/]+)$")
            if leaf then consider(leaf:match("^%s*(.-)%s*$")) end
        end
        for _, alias in ipairs(command.Aliases) do consider(alias) end
        if not best and commandDescription(command):lower():find(lower,1,true) then best = 11 end
        return best
    end

    function Library:SearchCommands(query)
        local ranked = {}
        for _, command in ipairs(self:GetCommands()) do
            local score = matchScore(command, tostring(query or ""))
            if score then table.insert(ranked, {command = command, score = score}) end
        end
        table.sort(ranked, function(a,b) if a.score ~= b.score then return a.score < b.score end return a.command.Name:lower() < b.command.Name:lower() end)
        local hasPrimary = ranked[1] and ranked[1].score < 10
        local out = {}; for _, item in ipairs(ranked) do if not hasPrimary or item.score < 10 then table.insert(out, item.command) end end
        return out
    end

    function Library:ExecuteCommand(text)
        local query = tostring(text or ""):match("^%s*(.-)%s*$") or ""
        if query == "" then return false, "Command is empty" end
        local choices = self:SearchCommands(query)
        if #choices == 0 then return false, "Command not found" end
        local command = choices[1]
        if #choices > 1 and matchScore(choices[1], query) == matchScore(choices[2], query) then return false, "Ambiguous command" end
        local args = argumentsFor(command, query)
        if command.Arguments and not command.OptionalArguments and #args < #command.Arguments then
            local missing = {}; for i = #args + 1, #command.Arguments do table.insert(missing, tostring(command.Arguments[i])) end
            return false, "Missing arguments: " .. table.concat(missing, ", ")
        end
        if command.Arguments or command.Kind == "Feature" or command._LegacyArguments then
            self:RunCommand(command.Name, args)
        else
            self:RunCommand(command.Name, table.unpack(args))
        end
        return true
    end

    local function runSelected(keepPalette)
        local command = matches[selected]
        if not command then return end
        local args = argumentsFor(command, paletteInput())
        if (command.Kind == "Feature" and command.FeatureKind ~= "Toggle" and command.FeatureKind ~= "Button" or command._CustomDropdown) and #args == 0 then
            search.Text = command.Name .. " "
            if not Library.Mobile then search:CaptureFocus() end
            Library:Notify("Enter a value, then select this item.")
            return
        end
        if command.FeatureKind == "Dropdown" and command.FeatureEntry and command.FeatureEntry.Control and #args > 0 then
            local control = command.FeatureEntry.Control
            local found, reason = ResolvePaletteOptions(control, table.concat(args, " "))
            if not found then Library:Notify(reason); return end
        end
        if command.Arguments and not command.OptionalArguments and #args < #command.Arguments then
            search.Text = command.Name .. " "
            if not Library.Mobile then search:CaptureFocus() end
            Library:Notify("Enter: " .. table.concat(command.Arguments, ", "))
            return
        end
        local entry = command.FeatureEntry
        if command.FeatureKind == "Button" and entry and entry.Name == "Unload" and entry.Control and entry.Control.DoubleClick then
            Library:CloseCommandPalette()
            task.spawn(function()
                if entry.Control.Clicking then entry.Control:SetClicking(false) end
                entry.Activate(); entry.Activate()
            end)
            return
        end
        local keepOpen = (command._CustomDropdown and command.Multi) or (command.FeatureKind == "Dropdown" and command.FeatureEntry and command.FeatureEntry.Control and command.FeatureEntry.Control.Multi)
        if not keepOpen then Library:CloseCommandPalette() end
        if command.Arguments or command.Kind == "Feature" or command._LegacyArguments then
            Library:RunCommand(command.Name, args)
        else
            Library:RunCommand(command.Name, table.unpack(args))
        end
        if keepOpen then search.Text = command.Name .. " " end
    end

    function Library:RefreshCommandPalette()
        if not results then return end
        local previousScroll = results.CanvasPosition
        for _, child in ipairs(results:GetChildren()) do
            if child:IsA("GuiObject") then child:Destroy() end
        end
        table.clear(matches)
        local query = paletteInput():match("^%s*(.-)%s*$") or ""
        local Groups, GroupOrder = {}, {}
        for _, command in ipairs(self:SearchCommands(query)) do
            local category = favoriteCommands[command.Name] and "Favorites" or (command.Category or "Commands")
            if not Groups[category] then Groups[category] = {}; table.insert(GroupOrder, category) end
            table.insert(Groups[category], command)
        end
        if Groups.Favorites then for i, category in ipairs(GroupOrder) do if category == "Favorites" then table.remove(GroupOrder, i); break end end; table.insert(GroupOrder, 1, "Favorites") end
        local displayCategories = {}
        for _, category in ipairs(GroupOrder) do
            for _, command in ipairs(Groups[category]) do table.insert(matches, command); table.insert(displayCategories, category) end
        end
        selected = math.clamp(selected, 1, math.max(1, #matches))
        emptyLabel.Visible = #matches == 0
        local rows = {}
        local function refreshSelection()
            for index, item in ipairs(rows) do
                local cmd = matches[index]
                local prefix = cmd.Name .. " "
                local opened = (cmd.FeatureKind == "Dropdown" or cmd._CustomDropdown) and expandedDropdowns[cmd.Name] ~= false and (search.Text:lower() == cmd.Name:lower() or search.Text:lower():sub(1, #prefix) == prefix:lower())
                local active = index == selected or favoriteCommands[cmd.Name] == true or opened
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
        local lastCategory, layoutOrder = nil, 0
        for index, command in ipairs(matches) do
            if displayCategories[index] ~= lastCategory then
                lastCategory = displayCategories[index]
                layoutOrder += 1
                make("TextLabel", {Name = "CommandSection", BackgroundTransparency = 1, Size = UDim2.new(1, -4, 0, 24), LayoutOrder = layoutOrder, Text = lastCategory or "Commands", TextColor3 = ThemeColor(200,200,200), TextSize = 13, FontFace = semiBoldFont, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 103, Parent = results})
            end
            layoutOrder += 1
            local displayDescription = commandDescription(command)
            local title = command.Kind == "Feature" and (command.Name:match("([^/]+)$") or command.Name):match("^%s*(.-)%s*$") or command.Name
            local hints = {}
            local customTag = command.Tag or command.Label
            if type(customTag) == "string" and customTag ~= "" then
                table.insert(hints, customTag)
            elseif command.Kind ~= "Feature" and type(command.Type) == "string" and command.Type ~= "Button" then
                local typeTags = {Toggle = "Toggle", Slider = "Value", Dropdown = "Option", Textbox = "Input", Input = "Input", Keybind = "Key", Color = "Color"}
                table.insert(hints, typeTags[command.Type] or command.Type)
            elseif command.Arguments and #command.Arguments > 0 then
                if command.Kind == "Feature" and command.FeatureKind == "Toggle" then
                    table.insert(hints, "Toggle")
                elseif command.Kind == "Feature" then
                    local examples = {Slider = "Value", Dropdown = command.FeatureEntry and command.FeatureEntry.Control and command.FeatureEntry.Control.Multi and "Options" or "Option", Textbox = "Input", Keybind = "Key", Color = "Color"}
                    table.insert(hints, examples[command.FeatureKind] or "Value")
                else
                    for _, argument in ipairs(command.Arguments) do table.insert(hints, tostring(argument)) end
                end
            end
            local hasHints = #hints > 0
            local titleBounds = GetTextBounds(title, mediumFont, 15, 220)
            local availableTitle = math.max(40, math.min(220, (paletteBox.AbsoluteSize.X > 0 and paletteBox.AbsoluteSize.X or 300) - 210))
            local titleWidth = math.clamp((titleBounds and titleBounds.X or 90) + 2, 40, availableTitle)
            local prefixForRow = command.Name .. " "
            local rowOpen = (command.FeatureKind == "Dropdown" or command._CustomDropdown) and expandedDropdowns[command.Name] ~= false and (search.Text:lower() == command.Name:lower() or search.Text:lower():sub(1,#prefixForRow) == prefixForRow:lower())
            local rowActive = index == selected or favoriteCommands[command.Name] == true or rowOpen
            local rowHeight = displayDescription ~= "" and 56 or 42
            local item = make("TextButton", {
                Name = "Command", AutoButtonColor = false,
                Size = UDim2.new(1, -4, 0, rowHeight), LayoutOrder = layoutOrder,
                BackgroundColor3 = rowActive and ThemeColor(25,25,25):Lerp(ThemeColor(60,200,100), 0.13) or ThemeColor(25,25,25),
                Text = "", ZIndex = 103, Parent = results,
            })
            corner(item, 8)
            make("UIStroke", {Name = "RowOutline", ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = rowActive and ThemeColor(60,200,100) or ThemeColor(60,60,60), Transparency = rowActive and 0.3 or 0.55, Parent = item})
            rows[index] = item
            local marker = make("Frame", {Name = "SelectionAccent", BorderSizePixel = 0,
                BackgroundColor3 = ThemeColor(60,200,100), Position = UDim2.fromOffset(0, 7),
                Size = UDim2.new(0, 3, 1, -14), Visible = rowActive, ZIndex = 104, Parent = item})
            corner(marker, 2)
            local commandIcon = make("ImageLabel", {Name = "CommandIcon", BackgroundTransparency = 1, Image = "", ImageColor3 = index == selected and ThemeColor(60,200,100) or ThemeColor(200,200,200), Position = UDim2.fromOffset(14, 9), Size = UDim2.fromOffset(18, 18), ScaleType = Enum.ScaleType.Fit, ZIndex = 104, Parent = item})
            local featureIcons = {Toggle = "toggle-left", Slider = "settings-2", Dropdown = "list", Button = "mouse-pointer-click", Textbox = "pencil", Input = "pencil", Keybind = "keyboard", Color = "palette"}
            local visualType = command.FeatureKind or command.Type
            local iconName = command.Icon or featureIcons[visualType] or (command.Kind == "Feature" and "sliders-horizontal" or (command.Builtin and "file-terminal" or "terminal"))
            if not command.Icon and visualType == "Toggle" and type(command.ValueText) == "function" then
                local getter = command.FeatureEntry and command.FeatureEntry.GetValue or command.ValueText
                local ok, value = pcall(getter)
                if ok and (value == true or value == "true" or value == "On") then iconName = "toggle-right" end
            end
            Library:ApplyIcon(commandIcon, Library:GetIcon(iconName) or Library:GetIcon("terminal"))
            make("TextLabel", {
                Name = "CommandTitle", BackgroundTransparency = 1, Position = UDim2.fromOffset(43, 5),
                Size = UDim2.fromOffset(titleWidth, 24), Text = title, TextColor3 = ThemeColor(255,255,255), TextSize = 15,
                TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
                FontFace = mediumFont, ZIndex = 104, Parent = item,
            })
            local arrow = make("ImageLabel", {BackgroundTransparency = 1, Image = "", ImageColor3 = ThemeColor(200,200,200), ImageTransparency = 0.25, AnchorPoint = Vector2.new(1,0), Position = UDim2.new(1,-10,0,12), Size = UDim2.fromOffset(16,16), ZIndex = 104, Parent = item})
            Library:ApplyIcon(arrow, Library:GetIcon((command.FeatureKind == "Dropdown" or command._CustomDropdown) and (rowOpen and "chevron-up" or "chevron-down") or "chevron-right"))
            local star = make("ImageButton", {Name = "Favorite", BackgroundTransparency = 1, AutoButtonColor = false, AnchorPoint = Vector2.new(1,0), Position = UDim2.new(1,-31,0,11), Size = UDim2.fromOffset(17,17), Image = "", ImageColor3 = favoriteCommands[command.Name] and ThemeColor(60,200,100) or ThemeColor(140,140,140), ZIndex = 106, Parent = item})
            Library:ApplyIcon(star, Library:GetIcon(favoriteCommands[command.Name] and "star" or "star"))
            star.Activated:Connect(function() favoriteCommands[command.Name] = not favoriteCommands[command.Name] or nil; saveFavorites(); Library:RefreshCommandPalette() end)
            if displayDescription ~= "" then
                make("TextLabel", {
                    Name = "CommandDescription", BackgroundTransparency = 1, Position = UDim2.fromOffset(43, 29),
                    Size = UDim2.new(1, -56, 0, 18), Text = displayDescription,
                    TextColor3 = ThemeColor(220,220,220), TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd, FontFace = regularFont, ZIndex = 104, Parent = item,
                })
            end
            if hasHints then
                local hintStart = 43 + titleWidth + 7
                local hintRow = make("Frame", {Name = "ArgumentHints", BackgroundTransparency = 1, Position = UDim2.fromOffset(hintStart, 6), Size = UDim2.new(1,-hintStart-60,0,24), ClipsDescendants = true, ZIndex = 104, Parent = item})
                make("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5), Parent = hintRow})
                make("UIPadding", {PaddingLeft = UDim.new(0, 2), PaddingTop = UDim.new(0, 2), Parent = hintRow})
                if command.Kind ~= "Feature" and not command._CustomDropdown then make("TextLabel", {Name = "ArgumentCaption", LayoutOrder = 0, BackgroundTransparency = 1, Size = UDim2.fromOffset(58, 22), Text = command.OptionalArguments and "Optional:" or "Required:", TextColor3 = ThemeColor(200,200,200), TextSize = 11, FontFace = mediumFont, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 105, Parent = hintRow}) end
                for hintIndex, hintText in ipairs(hints) do
                    local hintBounds = GetTextBounds(hintText, regularFont, 12, 220)
                    local width = math.clamp((hintBounds and hintBounds.X or 48) + 18, 42, 220)
                    local hint = make("TextLabel", {Name = "ArgumentHint", LayoutOrder = hintIndex, Size = UDim2.fromOffset(width, 20), BackgroundColor3 = rowActive and ThemeColor(45,45,45):Lerp(ThemeColor(60,200,100), 0.10) or ThemeColor(45,45,45), Text = hintText, TextColor3 = ThemeColor(200,200,200), TextSize = 11, TextTruncate = Enum.TextTruncate.AtEnd, FontFace = regularFont, ZIndex = 105, Parent = hintRow})
                    corner(hint, 4)
                    make("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = ThemeColor(80,80,80), Transparency = 0.25, Parent = hint})
                end
            end
            item.MouseEnter:Connect(function() selected = index; refreshSelection() end)
            item.Activated:Connect(function()
                selected = index
                if (command.FeatureKind == "Dropdown" or command._CustomDropdown) and #argumentsFor(command, search.Text) == 0 then
                    local prefix = command.Name .. " "
                    if search.Text:lower() ~= command.Name:lower() and search.Text:lower():sub(1,#prefix) ~= prefix:lower() then
                        expandedDropdowns[command.Name] = true; search.Text = prefix
                    else expandedDropdowns[command.Name] = expandedDropdowns[command.Name] == false; Library:RefreshCommandPalette() end
                else runSelected() end
            end)
            local entry = command.FeatureEntry
            local control = command._CustomDropdown and command or (entry and entry.Control)
            local prefix = command.Name .. " "
            if (command.FeatureKind == "Dropdown" or command._CustomDropdown) and control and expandedDropdowns[command.Name] ~= false and (search.Text:lower() == command.Name:lower() or search.Text:lower():sub(1, #prefix) == prefix:lower()) then
                local filter = search.Text:lower() == command.Name:lower() and "" or (search.Text:sub(#prefix + 1):lower():match("^%s*(.-)%s*$") or "")
                local options = {}
                for key, value in ipairs(control.Values or {}) do table.insert(options, value) end
                if #options == 0 then for key in pairs(control.Values or {}) do table.insert(options, key) end; table.sort(options, function(a,b) return tostring(a):lower() < tostring(b):lower() end) end
                local choiceRows = {}
                layoutOrder += 1
                local optionList = make("Frame", {Name = "DropdownOptions", LayoutOrder = layoutOrder, Size = UDim2.new(1,-4,0,30), BackgroundColor3 = ThemeColor(25,25,25), ZIndex = 103, Parent = results})
                corner(optionList, 6)
                make("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = ThemeColor(60,60,60), Transparency = 0.3, Parent = optionList})
                make("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Center, Padding = UDim.new(), Parent = optionList})
                make("UIPadding", {PaddingTop = UDim.new(0, 3), PaddingBottom = UDim.new(0, 2), Parent = optionList})
                local optionSearch = make("TextBox", {Name = "DropdownSearch", LayoutOrder = 0, Size = UDim2.new(1,-12,0,30), BackgroundColor3 = ThemeColor(30,30,30), Text = "", PlaceholderText = "Search...", PlaceholderColor3 = ThemeColor(140,140,140), TextColor3 = ThemeColor(255,255,255), ClearTextOnFocus = false, TextSize = 12, FontFace = regularFont, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 104, Parent = optionList})
                optionSearch.Visible = not command._CustomDropdown or command.Searchable
                corner(optionSearch, 5)
                make("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = ThemeColor(60,60,60), Parent = optionSearch})
                make("UIPadding", {PaddingLeft = UDim.new(0, 28), Parent = optionSearch})
                local optionSearchIcon = make("ImageLabel", {BackgroundTransparency = 1, Image = "", ImageColor3 = ThemeColor(140,140,140), Position = UDim2.fromOffset(-21, 7), Size = UDim2.fromOffset(16,16), ZIndex = 105, Parent = optionSearch})
                Library:ApplyIcon(optionSearchIcon, Library:GetIcon("search"))
                local hasSelectButtons = control.Multi and control.Selectable
                if hasSelectButtons then
                    local bar = make("Frame", {Name = "SelectionButtons", LayoutOrder = 1, Size = UDim2.new(1,-12,0,36), BackgroundTransparency = 1, ZIndex = 104, Parent = optionList})
                    local function addSelectionButton(label, x, selecting)
                        local button = make("TextButton", {Name = label, BackgroundColor3 = ThemeColor(35,35,35), Position = UDim2.new(x,0,0,4), Size = UDim2.new(0.5,-3,0,26), Text = label, TextSize = 12, TextColor3 = ThemeColor(220,220,220), FontFace = regularFont, ZIndex = 105, Parent = bar})
                        corner(button, 5); make("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = ThemeColor(60,60,60), Transparency = 0.2, Parent = button})
                        button.Activated:Connect(function()
                            if selecting and control.SelectAll then control:SelectAll()
                            elseif not selecting and control.DeselectAll then control:DeselectAll()
                            else
                                local selected = {}
                                if selecting then for key,value in pairs(control.Values) do selected[type(key) == "number" and value or key] = true end end
                                control:SetValue(selected)
                            end
                            Library:RefreshCommandPalette()
                        end)
                    end
                    addSelectionButton("Select All", 0, true)
                    addSelectionButton("Deselect All", 0.5, false)
                end
                local optionOrder = 0
                for _, option in ipairs(options) do
                    local name = tostring(option)
                    if filter == "" or name:lower():find(filter, 1, true) then
                        optionOrder += 1
                        local chosen = control.Multi and type(control.Value) == "table" and control.Value[option] == true or (not control.Multi and control.Value == option)
                        local choice = make("TextButton", {Name = "DropdownChoice", AutoButtonColor = false, LayoutOrder = optionOrder + (hasSelectButtons and 1 or 0), Size = UDim2.new(1,0,0,30), BackgroundTransparency = 1, Text = name, TextColor3 = chosen and ThemeColor(255,255,255) or ThemeColor(140,140,140), TextSize = 12, FontFace = regularFont, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 104, Parent = optionList})
                        table.insert(choiceRows, {Button = choice, Name = name:lower()})
                        local leftPadding = chosen and 26 or 6
                        make("UIPadding", {PaddingLeft = UDim.new(0, leftPadding), Parent = choice})
                        local check = make("ImageLabel", {BackgroundTransparency = 1, Image = "", ImageColor3 = Color3.new(1,1,1), Position = UDim2.new(0,-20,0.5,-8), Size = UDim2.fromOffset(16,16), Visible = chosen, ZIndex = 105, Parent = choice})
                        Library:ApplyIcon(check, Library:GetIcon("check"))
                        make("Frame", {Name = "Divider", BackgroundColor3 = ThemeColor(50,50,50), BackgroundTransparency = 0.4, Position = UDim2.new(0,-leftPadding,1,-1), Size = UDim2.new(1,leftPadding,0,1), ZIndex = 105, Parent = choice})
                        local baseColor = chosen and ThemeColor(255,255,255) or ThemeColor(140,140,140)
                        choice.MouseEnter:Connect(function() Tween(choice, FastTween, {TextColor3 = baseColor:Lerp(Color3.new(1,1,1), 0.6)}) end)
                        choice.MouseLeave:Connect(function() Tween(choice, FastTween, {TextColor3 = baseColor}) end)
                        choice.Activated:Connect(function()
                            if not control.Multi then Library:CloseCommandPalette() end
                            Library:RunCommand(command.Name, {name})
                            if control.Multi then search.Text = prefix; Library:RefreshCommandPalette() end
                        end)
                    end
                end
                local noOptions = make("TextLabel", {Name = "NoResults", LayoutOrder = 100000, Size = UDim2.new(1,0,0,30), BackgroundTransparency = 1, Text = "No results found", TextColor3 = ThemeColor(140,140,140), TextSize = 12, FontFace = regularFont, Visible = false, ZIndex = 104, Parent = optionList})
                local function updateOptionFilter()
                    local term = optionSearch.Text:lower()
                    local count = 0
                    for _, row in ipairs(choiceRows) do row.Button.Visible = term == "" or row.Name:find(term, 1, true) ~= nil; if row.Button.Visible then count += 1 end end
                    noOptions.Visible = count == 0
                    optionList.Size = UDim2.new(1,-4,0,(optionSearch.Visible and 35 or 5) + (hasSelectButtons and 36 or 0) + math.max(1, count) * 30)
                end
                optionSearch:GetPropertyChangedSignal("Text"):Connect(updateOptionFilter)
                updateOptionFilter()
            end
            if command.FeatureKind == "Color" and control and (search.Text:lower() == command.Name:lower() or search.Text:lower() == prefix:lower()) then
                layoutOrder += 1
                local mapHeight = 160
                local bodyTop = mapHeight + 20
                local rainbowY = bodyTop + 68
                local transparencyY = rainbowY + (control.AllowRainbow and 32 or 0)
                local editorHeight = control.AllowTrans and transparencyY + 47 or rainbowY + (control.AllowRainbow and 32 or 8)
                local editor = make("Frame", {Name="PaletteColorPicker", LayoutOrder=layoutOrder, Size=UDim2.new(1,-4,0,editorHeight), BackgroundColor3=ThemeColor(25,25,25), ZIndex=103, Parent=results})
                corner(editor, 7)
                make("UIStroke", {ApplyStrokeMode=Enum.ApplyStrokeMode.Border, Color=ThemeColor(60,60,60), Parent=editor})
                local h,s,v = control.Color:ToHSV()
                local shade = make("ImageButton", {Name="ColorMap", AutoButtonColor=false, BackgroundColor3=Color3.fromHSV(h,1,1), Image="rbxassetid://4155801252", Position=UDim2.fromOffset(10,10), Size=UDim2.new(1,-42,0,mapHeight), ZIndex=104, Parent=editor})
                corner(shade, 5)
                make("UIStroke", {ApplyStrokeMode=Enum.ApplyStrokeMode.Border, Color=ThemeColor(60,60,60), Thickness=1, Parent=shade})
                local cursor = make("Frame", {AnchorPoint=Vector2.new(.5,.5), BackgroundColor3=Color3.new(1,1,1), Size=UDim2.fromOffset(9,9), ZIndex=106, Parent=shade})
                corner(cursor, 5); make("UIStroke", {Color=Color3.new(0,0,0), Parent=cursor})
                local hue = make("TextButton", {Name="Hue", AutoButtonColor=false, BackgroundColor3=Color3.new(1,1,1), AnchorPoint=Vector2.new(1,0), Position=UDim2.new(1,-10,0,10), Size=UDim2.fromOffset(15,mapHeight), Text="", ZIndex=104, Parent=editor})
                corner(hue, 5); make("UIGradient", {Color=ColorSequence.new(hueSequenceTable), Rotation=90, Parent=hue})
                local hueCursor = make("Frame", {AnchorPoint=Vector2.new(.5,.5), Position=UDim2.new(.5,0,0,0), Size=UDim2.new(1,2,0,3), BackgroundColor3=Color3.new(1,1,1), ZIndex=106, Parent=hue})
                local hex = make("TextBox", {Name="Hex", BackgroundColor3=ThemeColor(35,35,35), ClearTextOnFocus=false, Position=UDim2.fromOffset(10,bodyTop), Size=UDim2.new(1,-20,0,28), Text="", TextColor3=ThemeColor(220,220,220), TextSize=13, FontFace=regularFont, ZIndex=104, Parent=editor})
                corner(hex,5); make("UIStroke", {ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Color=ThemeColor(60,60,60),Parent=hex})
                local function button(label, y, callback)
                    local index = label == "Copy Hex" and 0 or label == "Copy RGB" and 1 or 2
                    local x = UDim2.new(index / 3, 10 - index * (14/3), 0, bodyTop + 34)
                    local size = UDim2.new(1/3,-32/3,0,27)
                    local b=make("TextButton", {Name=label, AutoButtonColor=false, BackgroundColor3=ThemeColor(35,35,35), Position=x, Size=size, Text=label, TextSize=12, TextTruncate=Enum.TextTruncate.AtEnd, TextColor3=ThemeColor(220,220,220), FontFace=regularFont, ZIndex=104, Parent=editor})
                    corner(b,5); make("UIStroke", {ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Color=ThemeColor(60,60,60),Parent=b}); b.Activated:Connect(callback); return b
                end
                local rainbowButton, rainbowSwitch, rainbowKnob, bar, fill, transparencyValue
                local function update()
                    if not editor.Parent then return end
                    h,s,v = control.Color:ToHSV()
                    shade.BackgroundColor3=Color3.fromHSV(h,1,1); cursor.Position=UDim2.fromScale(s,1-v); hueCursor.Position=UDim2.fromScale(.5,h)
                    if not hex:IsFocused() then hex.Text="#"..control.Color:ToHex():upper() end
                    if rainbowSwitch then
                        rainbowSwitch.BackgroundColor3=control.Rainbow and ThemeColor(60,200,100) or ThemeColor(35,35,35)
                        rainbowKnob.BackgroundColor3=control.Rainbow and Color3.new(1,1,1) or ThemeColor(140,140,140)
                        rainbowKnob.Position=control.Rainbow and UDim2.new(1,-2,.5,0) or UDim2.new(0,2,.5,0)
                        rainbowKnob.AnchorPoint=control.Rainbow and Vector2.new(1,.5) or Vector2.new(0,.5)
                    end
                    if fill then fill.Size=UDim2.fromScale(control.Transparency,1) end
                    if transparencyValue then transparencyValue.Text=("%d%%"):format(math.floor(control.Transparency*100+.5)) end
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
                button("Copy Hex", 45, function() paletteClipboard="#"..control.Color:ToHex():upper(); if type(setclipboard)=="function" then pcall(setclipboard,paletteClipboard) end end)
                button("Copy RGB", 77, function() local c=control.Color; paletteClipboard=("%d, %d, %d"):format(math.floor(c.R*255+.5),math.floor(c.G*255+.5),math.floor(c.B*255+.5)); if type(setclipboard)=="function" then pcall(setclipboard,paletteClipboard) end end)
                if control.AllowRainbow then
                    rainbowButton=make("TextButton", {Name="Rainbow", AutoButtonColor=false, BackgroundTransparency=1, Position=UDim2.fromOffset(10,rainbowY), Size=UDim2.new(1,-20,0,27), Text="Rainbow", TextSize=12, TextColor3=ThemeColor(220,220,220), FontFace=regularFont, TextXAlignment=Enum.TextXAlignment.Left, TextTruncate=Enum.TextTruncate.AtEnd, ZIndex=104, Parent=editor})
                    rainbowSwitch=make("Frame", {AnchorPoint=Vector2.new(1,.5), Position=UDim2.fromScale(1,.5), Size=UDim2.fromOffset(32,16), BackgroundColor3=ThemeColor(35,35,35), ZIndex=105, Parent=rainbowButton})
                    make("UIGradient", {Color=ColorSequence.new(Color3.new(1,1,1),Color3.fromRGB(190,190,190)),Rotation=90,Parent=rainbowSwitch})
                    corner(rainbowSwitch,8); make("UIStroke", {ApplyStrokeMode=Enum.ApplyStrokeMode.Border, Color=ThemeColor(60,60,60), Parent=rainbowSwitch})
                    rainbowKnob=make("Frame", {AnchorPoint=Vector2.new(0,.5), Position=UDim2.new(0,2,.5,0), Size=UDim2.fromOffset(12,12), BackgroundColor3=ThemeColor(140,140,140), ZIndex=106, Parent=rainbowSwitch}); corner(rainbowKnob,6)
                    rainbowButton.Activated:Connect(function() batch(function() control:SetRainbow(not control.Rainbow) end) end)
                end
                local function applyText(text)
                    local code=tostring(text):match("^%s*#?(%x%x%x%x%x%x)%s*$")
                    local r,g,b=tostring(text):match("^%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*$")
                    local color=code and Color3.fromHex(code) or (r and tonumber(r)<=255 and tonumber(g)<=255 and tonumber(b)<=255 and Color3.fromRGB(tonumber(r),tonumber(g),tonumber(b)))
                    if color then batch(function() control:SetRainbow(false); control:SetColor(color) end) end
                    update()
                end
                button("Paste", 109, function() local value; if type(getclipboard)=="function" then local ok,result=pcall(getclipboard); if ok then value=result end end; applyText(value or paletteClipboard or "") end)
                hex.FocusLost:Connect(function() applyText(hex.Text) end)
                if control.AllowTrans then
                    make("TextLabel", {BackgroundTransparency=1, Position=UDim2.fromOffset(10,transparencyY), Size=UDim2.new(1,-20,0,20), Text="Transparency", TextColor3=ThemeColor(200,200,200), TextSize=12, FontFace=regularFont, TextXAlignment=Enum.TextXAlignment.Left,ZIndex=104,Parent=editor})
                    transparencyValue=make("TextLabel", {Name="TransparencyValue", AnchorPoint=Vector2.new(1,0), Position=UDim2.new(1,-10,0,transparencyY), Size=UDim2.fromOffset(42,20), BackgroundColor3=ThemeColor(35,35,35), Text="0%", TextColor3=ThemeColor(220,220,220), TextSize=11, FontFace=regularFont, ZIndex=105, Parent=editor})
                    corner(transparencyValue,5); make("UIStroke", {ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Color=ThemeColor(60,60,60),Parent=transparencyValue})
                    bar=make("TextButton", {Name="Transparency", AutoButtonColor=false, BackgroundColor3=ThemeColor(60,60,60), Position=UDim2.fromOffset(10,transparencyY+26), Size=UDim2.new(1,-20,0,6), Text="",ZIndex=104,Parent=editor})
                    corner(bar,4); fill=make("Frame",{BackgroundColor3=ThemeColor(60,200,100),Size=UDim2.fromScale(control.Transparency,1),ZIndex=105,Parent=bar});corner(fill,4)
                    make("UIGradient", {Color=ColorSequence.new(Color3.new(1,1,1),Color3.fromRGB(205,205,205)),Rotation=90,Parent=fill})
                    local knob=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(1,.5),Size=UDim2.fromOffset(12,12),BackgroundColor3=Color3.new(1,1,1),ZIndex=106,Parent=fill});corner(knob,6); make("UIStroke", {Color=ThemeColor(60,200,100),Parent=knob})
                end
                local dragging
                local function change(input)
                    if not dragging or control.Locked then return end
                    if control.Rainbow and (dragging == shade or dragging == hue) then dragging = nil; return end
                    if dragging == shade then s=math.clamp((input.Position.X-shade.AbsolutePosition.X)/math.max(shade.AbsoluteSize.X,1),0,1); v=1-math.clamp((input.Position.Y-shade.AbsolutePosition.Y)/math.max(shade.AbsoluteSize.Y,1),0,1)
                    elseif dragging == hue then h=math.clamp((input.Position.Y-hue.AbsolutePosition.Y)/math.max(hue.AbsoluteSize.Y,1),0,1)
                    else batch(function() control:SetTransparency(math.clamp((input.Position.X-bar.AbsolutePosition.X)/math.max(bar.AbsoluteSize.X,1),0,1)) end); fill.Size=UDim2.fromScale(control.Transparency,1); return end
                    batch(function() control:SetColor(Color3.fromHSV(h,s,v)) end)
                end
                for _, target in ipairs(bar and {shade,hue,bar} or {shade,hue}) do target.InputBegan:Connect(function(input) if control.Rainbow and (target == shade or target == hue) then return end; if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=target; change(input) end end) end
                local move=UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then change(input) end end)
                local ended=UserInputService.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=nil end end)
                local rain=RunService.Heartbeat:Connect(function() if palette and palette.Visible and control.Rainbow then update() end end)
                editor.Destroying:Connect(function() move:Disconnect(); ended:Disconnect(); rain:Disconnect() end)
                update()
            end
        end
        if resizePalette then task.defer(function() if results and results.Parent then resizePalette(); results.CanvasPosition = previousScroll end end) end
    end

    local function createPalette()
        palette = make("Frame", { Name = "CommandPaletteOverlay", BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1), Visible = false, ZIndex = 100, Parent = UI })
        local dismiss = make("TextButton", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = "", ZIndex = 100, Parent = palette })
        dismiss.Activated:Connect(function()
            if not Library.Mobile then Library:CloseCommandPalette() end
        end)
        paletteBox = make("CanvasGroup", {Name = "CommandPalette", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.12, -10),
            Size = UDim2.new(1, -24, 0.7, 0), BackgroundColor3 = ThemeColor(25,25,25), GroupTransparency = 1, ZIndex = 101, Parent = palette })
        make("UISizeConstraint", { MaxSize = Vector2.new(500, 420), MinSize = Vector2.new(160, 120), Parent = paletteBox })
        corner(paletteBox, 10)
        make("UIGradient", {Color = ColorSequence.new(Color3.fromRGB(255,255,255), Color3.fromRGB(210,210,210)), Rotation = 90, Parent = paletteBox})
        AddAnimatedBorder(paletteBox)
        local header = make("Frame", {BackgroundColor3 = ThemeColor(20,20,20), Size = UDim2.new(1, 0, 0, 42), ZIndex = 102, Parent = paletteBox})
        corner(header, 10)
        make("Frame", {BackgroundColor3 = ThemeColor(20,20,20), Position = UDim2.new(0,0,1,-8), Size = UDim2.new(1,0,0,8), ZIndex = 102, Parent = header})
        local headerIcon = make("ImageLabel", {BackgroundTransparency = 1, Image = "", ImageColor3 = ThemeColor(60,200,100), Position = UDim2.fromOffset(13, 12), Size = UDim2.fromOffset(18,18), ZIndex = 103, Parent = header})
        headerIcon:SetAttribute("ThemeAccentIcon", true)
        Library:ApplyIcon(headerIcon, Library:GetIcon("command"))
        make("TextLabel", {BackgroundTransparency = 1, Position = UDim2.fromOffset(40,0), Size = UDim2.new(1,-82,1,0), Text = "Command Palette", TextColor3 = ThemeColor(255,255,255), TextSize = 16, FontFace = semiBoldFont, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 103, Parent = header})
        local close = make("ImageButton", {Name = "Close", AutoButtonColor = false, BackgroundTransparency = 1, AnchorPoint = Vector2.new(1,0.5), Position = UDim2.new(1,-12,0.5,0), Size = UDim2.fromOffset(18,18), Image = "", ImageTransparency = 0.25, ZIndex = 103, Parent = header})
        Library:ApplyIcon(close, Library:GetIcon("x"))
        close.Activated:Connect(function() Library:CloseCommandPalette() end)
        make("Frame", {BackgroundColor3 = ThemeColor(80,80,80), BackgroundTransparency = 0.35, Position = UDim2.fromOffset(0,42), Size = UDim2.new(1,0,0,1), ZIndex = 102, Parent = paletteBox})
        search = make("TextBox", { Name = "CommandSearch", BackgroundColor3 = ThemeColor(35,35,35), Position = UDim2.fromOffset(12, 53),
            Size = UDim2.new(1, -24, 0, 36), Text = "", PlaceholderText = "Search commands...",
            PlaceholderColor3 = ThemeColor(140,140,140), TextColor3 = ThemeColor(255,255,255), ClearTextOnFocus = false,
            TextSize = 15, FontFace = regularFont, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 103, Parent = paletteBox })
        corner(search, 7)
        make("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = ThemeColor(60,60,60), Parent = search})
        make("UIPadding", { PaddingLeft = UDim.new(0, 34), PaddingRight = UDim.new(0, 10), Parent = search })
        local searchIcon = make("ImageLabel", {BackgroundTransparency = 1, Image = "", ImageColor3 = ThemeColor(200,200,200), Position = UDim2.fromOffset(21, 62), Size = UDim2.fromOffset(18,18), ZIndex = 104, Parent = paletteBox})
        Library:ApplyIcon(searchIcon, Library:GetIcon("search"))
        results = make("ScrollingFrame", { BackgroundTransparency = 1, BorderSizePixel = 0,
            Position = UDim2.fromOffset(12, 99), Size = UDim2.new(1, -24, 1, -111),
            ScrollBarThickness = 3, ScrollBarImageColor3 = ThemeColor(80,80,80), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollingDirection = Enum.ScrollingDirection.Y, ZIndex = 102, Parent = paletteBox })
        local resultLayout = make("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5), Parent = results })
        make("UIPadding", {PaddingLeft = UDim.new(0, 3), PaddingRight = UDim.new(0, 3), PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 2), Parent = results})
        resizePalette = function()
            if not paletteBox or not paletteBox.Parent or not results or not results.Parent then return end
            local camera = workspace.CurrentCamera
            local viewportHeight = camera and camera.ViewportSize.Y or 600
            local maximum = math.max(140, math.min(420, viewportHeight * 0.72))
            local contentHeight = #matches == 0 and 40 or resultLayout.AbsoluteContentSize.Y
            local desired = math.clamp(contentHeight + 112, 150, maximum)
            if paletteResizeTween then paletteResizeTween:Cancel() end
            paletteResizeTween = TweenService:Create(paletteBox, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(1, -24, 0, desired)})
            paletteResizeTween:Play()
        end
        resultLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(resizePalette)
        emptyLabel = make("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 108),
            Size = UDim2.new(1, -24, 0, 40), Text = "No matching commands", TextColor3 = ThemeColor(140,140,140),
            TextSize = 14, FontFace = regularFont, Visible = false, ZIndex = 103, Parent = paletteBox })
        search:GetPropertyChangedSignal("Text"):Connect(function()
            if openingCharacter and os.clock() <= openingCharacterDeadline and search.Text:sub(1,1):lower() == openingCharacter:lower() then
                local first = openingCharacter
                openingCharacter = nil
                if first == ";" or first == "'" then ignoredOpeningPrefix = first
                else search.Text = search.Text:sub(2); return end
            end
            if ignoredOpeningPrefix and search.Text:sub(1,1) ~= ignoredOpeningPrefix then ignoredOpeningPrefix = nil end
            if search.Text ~= "" then openingCharacter = nil end
            selected = 1; results.CanvasPosition = Vector2.new(0,0); Library:RefreshCommandPalette()
        end)
        search.FocusLost:Connect(function(enterPressed)
            if not enterPressed or not palette.Visible or palette:GetAttribute("Closing") then return end
            if paletteInput():match("%S") then
                local command = matches[selected]
                if command then
                    local args = argumentsFor(command, paletteInput())
                    if #args > 0 then runSelected()
                    elseif command.Kind == "Feature" and command.FeatureKind ~= "Toggle" and command.FeatureKind ~= "Button" then
                        expandedDropdowns[command.Name] = true
                        ignoredOpeningPrefix = nil
                        search.Text = command.Name .. " "
                        Library:RefreshCommandPalette()
                    else runSelected() end
                else Library:CloseCommandPalette() end
                if palette.Visible and not palette:GetAttribute("Closing") and not Library.Mobile then task.defer(function() if palette.Visible and search.Parent then search:CaptureFocus() end end) end
            else Library:CloseCommandPalette() end
        end)
    end

    function Library:OpenCommandPalette(openingInput)
        if self.Unloaded then return end
        if activeMenu then activeMenu:Close() end
        if not palette then createPalette() end
        loadFavorites()
        paletteGeneration += 1
        if paletteTween then paletteTween:Cancel() end
        if overlayTween then overlayTween:Cancel() end
        palette:SetAttribute("Closing", false)
        palette.Visible = true
        Library._PaletteModalActive = true
        ModalElement.Visible = true
        Library._PaletteSnowActive = true
        if not paletteBlur then paletteBlur = make("BlurEffect", {Name = "FlamesPaletteBlur", Size = 12, Parent = Lighting}) end
        paletteBlur.Enabled = true
        openingCharacter = nil
        ignoredOpeningPrefix = nil
        search.Text = ""
        if openingInput and openingInput.KeyCode and openingInput.KeyCode ~= Enum.KeyCode.Unknown then
            local ok, character = pcall(function() return UserInputService:GetStringForKeyCode(openingInput.KeyCode) end)
            if ok and type(character) == "string" and #character == 1 then
                openingCharacter = character
                openingCharacterDeadline = os.clock() + 1
            end
        end
        selected = 1
        self:RefreshCommandPalette()
        paletteTween = TweenService:Create(paletteBox, TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(0.5,0,0.12,0), GroupTransparency = 0})
        overlayTween = TweenService:Create(palette, TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
        paletteTween:Play(); overlayTween:Play()
        if not Library.Mobile then
            task.defer(function() if palette and palette.Visible and not palette:GetAttribute("Closing") and search.Parent then search:CaptureFocus() end end)
        end
    end

    function Library:CloseCommandPalette()
        if not palette or not palette.Visible or palette:GetAttribute("Closing") then return end
        paletteGeneration += 1
        local generation = paletteGeneration
        if paletteTween then paletteTween:Cancel() end
        if overlayTween then overlayTween:Cancel() end
        palette:SetAttribute("Closing", true)
        Library._PaletteModalActive = false
        ModalElement.Visible = Library.Opened == true
        Library._PaletteSnowActive = false
        if paletteBlur then paletteBlur:Destroy(); paletteBlur = nil end
        search:ReleaseFocus(false)
        paletteTween = TweenService:Create(paletteBox, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(0.5,0,0.12,-10), GroupTransparency = 1})
        overlayTween = TweenService:Create(palette, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1})
        paletteTween.Completed:Connect(function(state)
            if generation ~= paletteGeneration or state ~= Enum.PlaybackState.Completed then return end
            if palette and palette.Parent then palette.Visible = false; palette:SetAttribute("Closing", false) end
        end)
        paletteTween:Play(); overlayTween:Play()
    end

    track(UserInputService.InputBegan:Connect(function(input, processed)
        if Library.Unloaded then return end
        if palette and palette.Visible then
            if input.KeyCode == Enum.KeyCode.Escape then Library:CloseCommandPalette()
            elseif (input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.KeypadEnter) and not UserInputService:GetFocusedTextBox() and not palette:GetAttribute("Closing") then
                if not search.Text:match("%S") then Library:CloseCommandPalette() end
            elseif input.KeyCode == Enum.KeyCode.Down or input.KeyCode == Enum.KeyCode.Up then
                selected = math.clamp(selected + (input.KeyCode == Enum.KeyCode.Down and 1 or -1), 1, math.max(1, #matches))
                Library:RefreshCommandPalette()
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

    -- AddTooltip(guiObject, text) returns a handle with SetText/Destroy.
    -- Hover with a mouse or touch and hold briefly on a touchscreen.
    function Library:AddTooltip(target, text)
        assert(typeof(target) == "Instance" and target:IsA("GuiObject"), "Tooltip target must be a GuiObject")
        local handle = { Text = tostring(text or ""), Connections = {}, Destroyed = false }
        ownedHandles[handle] = true
        local label = make("TextLabel", { Name = "Tooltip", BackgroundColor3 = background, TextColor3 = foreground,
            TextSize = 13, TextWrapped = true, Font = Enum.Font.Gotham, Visible = false,
            Size = UDim2.fromOffset(200, 36), ZIndex = 150, Parent = UI })
        corner(label, 5)
        local token = 0
        local function hide() token += 1; if label.Parent then label.Visible = false end end
        local function show(position)
            if handle.Destroyed or handle.Text == "" then return end
            local size = viewport()
            local point = screenPoint(position)
            label.Text = handle.Text
            local bounds = TextService:GetTextSize(handle.Text, 13, Enum.Font.Gotham, Vector2.new(220, 1000))
            local width = math.min(240, math.max(70, bounds.X + 20, math.min(size.X - 12, 70)))
            width = math.min(width, math.max(1, size.X - 12))
            local height = math.max(30, bounds.Y + 14)
            label.Size = UDim2.fromOffset(width, height)
            label.Position = UDim2.fromOffset(math.clamp(point.X + 12, 0, math.max(0, size.X - width)), math.clamp(point.Y + 18, 0, math.max(0, size.Y - height)))
            label.Visible = true
        end
        local function connect(signal, fn) table.insert(handle.Connections, signal:Connect(fn)) end
        connect(target.MouseEnter, function() show(UserInputService:GetMouseLocation()) end)
        connect(target.MouseLeave, hide)
        connect(target.InputBegan, function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                token += 1; local current = token
                task.delay(0.6, function() if token == current and not handle.Destroyed then show(input.Position) end end)
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
            self.Destroyed = true; ownedHandles[self] = nil; hide(); cleanConnections(self.Connections); label:Destroy()
        end
        return handle
    end

    -- CreateContextMenu({{Text="Action", Callback=function() end}, ...})
    -- menu:Open(Vector2), menu:Attach(gui), menu:Close(), menu:Destroy().
    -- Attach opens with right click, or touch and hold; position is in screen coordinates.
    function Library:CreateContextMenu(items)
        assert(type(items) == "table", "Context menu items must be a table")
        local menu = { Items = items, Connections = {}, Destroyed = false }
        ownedHandles[menu] = true
        local layer = make("Frame", { Name = "ContextMenuLayer", Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1, Visible = false, ZIndex = 110, Parent = UI })
        local dismiss = make("TextButton", { BackgroundTransparency = 1, Text = "", Size = UDim2.fromScale(1, 1), ZIndex = 110, Parent = layer })
        local frame = make("ScrollingFrame", { BackgroundColor3 = background, BorderSizePixel = 0,
            Size = UDim2.fromOffset(190, 0), ScrollBarThickness = 3, AutomaticCanvasSize = Enum.AutomaticSize.Y,
            CanvasSize = UDim2.new(), ScrollingDirection = Enum.ScrollingDirection.Y, ZIndex = 111, Parent = layer })
        corner(frame, 6)
        make("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2), Parent = frame })
        make("UIPadding", { PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5), PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5), Parent = frame })
        function menu:Close() if not self.Destroyed then layer.Visible = false; if activeMenu == self then activeMenu = nil end end end
        function menu:Open(position)
            if self.Destroyed or Library.Unloaded then return end
            if activeMenu and activeMenu ~= self then activeMenu:Close() end
            if palette and palette.Visible then Library:CloseCommandPalette() end
            for _, child in ipairs(frame:GetChildren()) do if child:IsA("GuiObject") then child:Destroy() end end
            for index, item in ipairs(self.Items) do
                local entry = button(frame, tostring(item.Text or item.Name or "Action"), 112)
                entry.Size = UDim2.new(1, -3, 0, 32); entry.LayoutOrder = index
                entry.TextXAlignment = Enum.TextXAlignment.Left
                entry.TextColor3 = item.Disabled and muted or foreground
                make("UIPadding", { PaddingLeft = UDim.new(0, 8), Parent = entry }); corner(entry, 4)
                entry.Activated:Connect(function()
                    if item.Disabled then return end
                    self:Close()
                    if type(item.Callback) == "function" then
                        task.spawn(function() local ok, err = pcall(item.Callback); if not ok then warn("[Library] Context menu: " .. tostring(err)) end end)
                    end
                end)
            end
            local size = viewport()
            local width, height = math.min(190, math.max(1, size.X - 12)), math.min(#self.Items * 34 + 10, math.max(1, size.Y - 12))
            local point = screenPoint(position or UserInputService:GetMouseLocation())
            frame.Size = UDim2.fromOffset(width, height)
            frame.Position = UDim2.fromOffset(math.clamp(point.X, 0, math.max(0, size.X - width)), math.clamp(point.Y, 0, math.max(0, size.Y - height)))
            layer.Visible = true; activeMenu = self
        end
        dismiss.Activated:Connect(function() menu:Close() end)
        function menu:Attach(target)
            assert(typeof(target) == "Instance" and target:IsA("GuiObject"), "Context menu target must be a GuiObject")
            local token = 0
            table.insert(self.Connections, target.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton2 then self:Open(input.Position)
                elseif input.UserInputType == Enum.UserInputType.Touch then
                    token += 1; local current = token; local start = input.Position
                    task.delay(0.6, function() if token == current and not self.Destroyed then self:Open(start) end end)
                end
            end))
            table.insert(self.Connections, target.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.Touch then token += 1 end end))
            table.insert(self.Connections, target.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.Touch then token += 1 end end))
            return self
        end
        function menu:Destroy()
            if self.Destroyed then return end
            self:Close(); self.Destroyed = true; ownedHandles[self] = nil; cleanConnections(self.Connections); layer:Destroy()
        end
        return menu
    end

    function Library:CleanupAdvancedUI()
        Library._PaletteModalActive = false
        if ModalElement and ModalElement.Parent then ModalElement.Visible = Library.Opened == true end
        Library._PaletteSnowActive = false
        if paletteBlur then paletteBlur:Destroy(); paletteBlur = nil end
        for handle in pairs(ownedHandles) do handle:Destroy() end
        table.clear(commands)
        cleanConnections(paletteConnections)
    end

    Library:AddCommand({ Name = "Toggle UI", Builtin = true, Description = "Show or hide the main window", Callback = function() Library:Toggle() end })
end

-- A floating label can be placed independently of the window and moved by mouse or touch.
function Library:AddDraggableLabel(options, icon, iconPosition)
    if type(options) ~= "table" then options = {Text = options, Icon = icon, IconPosition = iconPosition} end
    local holder = Create("Frame", {Name = "DraggableLabel", BackgroundColor3 = ThemeColor(25,25,25), Active = true,
        AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 32), Position = options.Position or UDim2.fromOffset(12,100), Parent = UI})
    Create("UICorner", {CornerRadius = UDim.new(0,7), Parent = holder})
    Create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = ThemeColor(80,80,80), Transparency = 0.3, Parent = holder})
    Create("UIPadding", {PaddingLeft = UDim.new(0,10), PaddingRight = UDim.new(0,10), Parent = holder})
    Create("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,6), Parent = holder})
    local image = Create("ImageLabel", {Name = "Icon", BackgroundTransparency = 1, Image = "", Size = UDim2.fromOffset(16,16), ImageColor3 = ThemeColor(200,200,200), Parent = holder})
    local text = Create("TextLabel", {Name = "Text", BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0,24), FontFace = regularFont, TextSize = 14, TextColor3 = ThemeColor(255,255,255), Text = tostring(options.Text or ""), Parent = holder})
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
    if Library.CleanupAdvancedUI then Library:CleanupAdvancedUI() end

    pcall(function()
        UserInputService.OverrideMouseIconBehavior = Enum.OverrideMouseIconBehavior.None
    end)

    if Library.Blur then
        pcall(function() Library.Blur:Destroy() end)
        Library.Blur = nil
    end

    if Windows then
        for _, child in ipairs(Windows:GetChildren()) do
            pcall(function() child:Destroy() end)
        end
    end

    if Notifications then
        for _, child in ipairs(Notifications:GetChildren()) do
            if child:IsA("GuiObject") then
                pcall(function() child:Destroy() end)
            end
        end
    end

    for i = #Library.Connections, 1, -1 do
        local conn = table.remove(Library.Connections, i)
        if conn and conn.Connected then
            pcall(function() conn:Disconnect() end)
        end
    end
    table.clear(Library.Icons)
    table.clear(Library.Connections)
    table.clear(Library.Flags)
    table.clear(Library.Tabs)
    table.clear(Library.IconCache)

    if ModalElement then
        pcall(function() ModalElement:Destroy() end)
    end
    if UI then
        pcall(function() UI:Destroy() end)
    end

    if Library.OnUnload then
        pcall(Library.OnUnload)
    end

    if getgenv then
        getgenv().Library = nil
    end

    if getgenv().Multi_Support then
        getgenv().Multi_Support = nil
    end

    if getgenv().Auto_Show ~= nil then
        getgenv().Auto_Show = nil
    end

    Library.Notify = function() end
    Library.Toggle = function() end
    Library.CreateWindow = function() end
    Library.LoadAutoloadConfig = function() end

    table.clear(Library)
end

return Library, Library.Flags
