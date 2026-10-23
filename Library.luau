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
    Connections = {},
    Flags = {},
    Tabs = {},

    NotifySound = 4590657391,
    NotifyVolume = 2,

    UISize = 220,
    ToggleKeybind = Enum.KeyCode.RightShift,
    Opened = nil,
    SaveFolder = nil,

    LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait(),
    Debug = false,

    Platform = Enum.Platform.None,
    Mobile = false,
}

pcall(function() Library.Platform = UserInputService:GetPlatform() end)
Library.Mobile = UserInputService:GetPlatform() == Enum.Platform.Android or UserInputService:GetPlatform() == Enum.Platform.IOS

if Library.Mobile then
    Library.UISize = 180
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

local defaultToggleColor = Color3.fromRGB(60, 60, 60)
local hoveringToggleColor = Color3.fromRGB(100, 100, 100)
local enabledToggleColor = Color3.fromRGB(140, 140, 140)

local semiBoldFont = Font.fromId(12187365364, Enum.FontWeight.SemiBold)
local mediumFont = Font.fromId(12187365364, Enum.FontWeight.Medium)
local regularFont = Font.fromId(12187365364)

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

function GetKeybindFromString(str)
    if str == "nil" or str == nil then return nil end
    local keybindSplit = string.split(tostring(str), ".")
    table.remove(keybindSplit, 1)
    local keybind = Enum
    for _, v in ipairs(keybindSplit) do
        keybind = keybind[v]
    end
    return keybind
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
    local dragConnection

    instance.InputBegan:Connect(function(input: InputObject)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            mousePos = input.Position
            framePos = main.Position

            if dragConnection then dragConnection:Disconnect() end
            dragConnection = UserInputService.InputChanged:Connect(function(i: InputObject)
                if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                    local delta = i.Position - mousePos
                    main.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
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
-- Library.ScreenGui = UI

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

local NotifySoundInstance = Create("Sound", {
    SoundId = "rbxassetid://" .. tostring(Library.NotifySound),
    Volume = Library.NotifyVolume,
    Parent = UI
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
        if data.mode then el.Mode = data.mode end
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
        }
    end,
    Load = function(flag, data)
        local el = Library.Flags[flag]
        if not el or el.Type ~= "ColorPicker" then return end
        local col = Color3.fromHex(data.color or "ffffff")
        el:SetColor(col)
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
        if fname and fname ~= "autoload" then
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

        local function MakeLine(size, position, anchor, LeftFade, RightFade)
            local Line = Create("Frame", {
                AnchorPoint = anchor,
                BackgroundColor3 = Color3.fromRGB(25, 25, 25),
                BorderSizePixel = 0,
                Position = position,
                Size = size,
                Parent = InnerHolder,
            })

            Create("UIGradient", {
                Rotation = 0,
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0,         LeftFade  and 1 or 0),
                    NumberSequenceKeypoint.new(Fade,      LeftFade  and 0 or 0),
                    NumberSequenceKeypoint.new(1 - Fade,  RightFade and 0 or 0),
                    NumberSequenceKeypoint.new(1,         RightFade and 1 or 0),
                }),
                Parent = Line,
            })

            local Overlay = Create("Frame", {
                Size = UDim2.fromScale(1, 1),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 0.1,
                BorderSizePixel = 0,
                Parent = Line,
            })

            Create("UIGradient", {
                Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0,   Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(0.3, Color3.fromRGB(200, 200, 255)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(0.7, Color3.fromRGB(200, 200, 255)),
                    ColorSequenceKeypoint.new(1,   Color3.fromRGB(255, 255, 255)),
                },
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0,         LeftFade  and 1 or 0),
                    NumberSequenceKeypoint.new(Fade,      0.35),
                    NumberSequenceKeypoint.new(0.5,       0),
                    NumberSequenceKeypoint.new(1 - Fade,  0.35),
                    NumberSequenceKeypoint.new(1,         RightFade and 1 or 0),
                }),
                Rotation = 0,
                Parent = Overlay,
            })

            return Line
        end

        if Text then
            local TextLabel = Create("TextLabel", {
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0),
                Text = Text,
                FontFace = regularFont,
                TextSize = 14,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextTransparency = 0.5,
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
            TextColor3 = Color3.new(1, 1, 1),
            TextSize = 20,
            TextTransparency = 0.5,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = self.Container
        })

        Create("UIPadding", {
            PaddingLeft = UDim.new(0, 11),
            PaddingRight = UDim.new(0, 11),
            Parent = TextLabel
        })

        local Label = { Text = text or "No Text" }

        function Label:Set(newText: string)
            Label.Text = newText
            local size = GetTextBounds(Label.Text, regularFont, 20, Library.UISize - 24)
            if size then
                TextLabel.Size = UDim2.new(1, 0, 0, size.Y + 7)
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

        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 5),
            PaddingLeft = UDim.new(0, 13),
            PaddingRight = UDim.new(0, 13),
            PaddingTop = UDim.new(0, 5),
            Parent = ButtonHolder
        })

        local ActualButton: TextButton = Create("TextButton", {
            AutoButtonColor = false,
            BackgroundColor3 = Color3.fromRGB(25, 25, 25),
            FontFace = regularFont,
            Size = UDim2.fromScale(1, 1),
            Text = options.Name or "Button",
            TextColor3 = Color3.new(1, 1, 1),
            TextScaled = true,
            TextTransparency = 0.5,
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
            Color = Color3.fromRGB(60, 60, 60),
            Parent = ActualButton
        })

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
            ActualButton.TextTransparency = Button.Clicking and 0 or (Button.Hovering and 0.25 or 0.5)
        end

        ActualButton.MouseEnter:Connect(function()
            Button.Hovering = true
            ButtonStroke.Color = hoveringToggleColor
            if not Button.Clicking then
                Tween(ActualButton, FastTween, {TextTransparency = 0.25})
            end
        end)

        ActualButton.MouseLeave:Connect(function()
            Button.Hovering = false
            ButtonStroke.Color = defaultToggleColor
            if not Button.Clicking then
                Tween(ActualButton, FastTween, {TextTransparency = 0.5})
            end
        end)

        ActualButton.MouseButton1Click:Connect(function()
            if Button.Locked then return end

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
        end)

        return Button
    end

    function Components:AddToggle(options: ToggleOptions)
        local ToggleHolder = Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 32),
            Parent = self.Container
        })

        Create("UIPadding", {
            PaddingLeft = UDim.new(0, 11),
            PaddingRight = UDim.new(0, 13),
            Parent = ToggleHolder
        })

        local ToggleText: TextLabel = Create("TextLabel", {
            BackgroundTransparency = 1,
            FontFace = regularFont,
            Size = UDim2.fromScale(1, 1),
            Text = options.Name or "Toggle",
            TextColor3 = Color3.new(1, 1, 1),
            TextScaled = true,
            TextTransparency = 0.5,
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
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(1, 0.5),
            Size = UDim2.fromOffset(32, 16),
            Text = "",
            Parent = ToggleHolder
        })

        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = ToggleButton })
        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 2),
            PaddingLeft = UDim.new(0, 2),
            PaddingRight = UDim.new(0, 2),
            PaddingTop = UDim.new(0, 2),
            Parent = ToggleButton,
        })

        local ToggleStroke = Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = Color3.fromRGB(60, 60, 60),
            Parent = ToggleButton
        })

        local ToggleIcon = Create("Frame", {
            BackgroundColor3 = Color3.fromRGB(60, 60, 60),
            Size = UDim2.fromScale(1, 1),
            SizeConstraint = Enum.SizeConstraint.RelativeYY,
            Parent = ToggleButton
        })

        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = ToggleIcon })

        local LockedIcon = Create("ImageLabel", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundTransparency = 1,
            Image = "",
            ImageTransparency = 0.5,
            Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.fromOffset(16, 16),
            Visible = false,
            Parent = ToggleHolder
        })
        Library:ApplyIcon(LockedIcon, LockIcon)

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
            Value = options.Value or false,
            Type = "Toggle"
        }

        function Toggle:SetLocked(locked: boolean)
            Toggle.Locked = locked == true

            LockedBlocker.Visible = Toggle.Locked
            ToggleButton.Visible = not Toggle.Locked
            LockedIcon.Visible = Toggle.Locked

            if Toggle.Locked then
                ToggleIcon.BackgroundColor3 = defaultToggleColor
                ToggleStroke.Color = defaultToggleColor
            else
                ToggleIcon.BackgroundColor3 = Toggle.Value and enabledToggleColor or (Toggle.Hovering and hoveringToggleColor or defaultToggleColor)
                Tween(ToggleIcon, FastTween, {Position = Toggle.Value and UDim2.fromOffset(16, 0) or UDim2.fromOffset(0, 0)})
                ToggleStroke.Color = Toggle.Value and enabledToggleColor or (Toggle.Hovering and hoveringToggleColor or defaultToggleColor)
            end
        end

        function Toggle:Set(newValue: boolean)
            local oldValue = Toggle.Value
            Toggle.Value = newValue

            ToggleIcon.BackgroundColor3 = Toggle.Value and enabledToggleColor or (Toggle.Hovering and hoveringToggleColor or defaultToggleColor)
            Tween(ToggleIcon, FastTween, {Position = Toggle.Value and UDim2.fromOffset(16, 0) or UDim2.fromOffset(0, 0)})
            ToggleStroke.Color = Toggle.Value and enabledToggleColor or (Toggle.Hovering and hoveringToggleColor or defaultToggleColor)

            if Toggle.Value ~= oldValue then
                Library:SafeCallback(options.Callback, Toggle.Value, oldValue)
            end
        end

        if options.Flag then
            Library.Flags[options.Flag] = Toggle
        end

        ToggleButton.MouseEnter:Connect(function()
            Toggle.Hovering = true
            if not Toggle.Value and not Toggle.Locked then
                ToggleIcon.BackgroundColor3 = hoveringToggleColor
                ToggleStroke.Color = hoveringToggleColor
            end
        end)

        ToggleButton.MouseLeave:Connect(function()
            Toggle.Hovering = false
            if not Toggle.Value and not Toggle.Locked then
                ToggleIcon.BackgroundColor3 = defaultToggleColor
                ToggleStroke.Color = defaultToggleColor
            end
        end)

        ToggleButton.MouseButton1Click:Connect(function()
            if Toggle.Locked then return end
            Toggle:Set(not Toggle.Value)
        end)

        Toggle:Set(Toggle.Value)
        return Toggle
    end

function Components:AddSlider(options: SliderOptions)
    local SliderHolder = Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 48),
        Parent = self.Container
    })

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
        BackgroundTransparency = 1,
        FontFace = regularFont,
        Size = UDim2.new(1, -48, 0, 32),
        Text = options.Name or "No Name",
        TextColor3 = Color3.new(1, 1, 1),
        TextScaled = true,
        TextTransparency = 0.5,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = SliderHolder
    })

    Create("UIPadding", {
        PaddingBottom = UDim.new(0, 6),
        PaddingTop = UDim.new(0, 6),
        Parent = SliderText
    })

    local SliderValue: TextBox = Create("TextBox", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        FontFace = regularFont,
        Position = UDim2.new(1, 0, 0, 8),
        Size = UDim2.fromOffset(48, 18),
        Text = "100",
        TextColor3 = Color3.new(1, 1, 1),
        TextScaled = true,
        TextTransparency = 0.5,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = SliderHolder
    })

    local SliderBar: TextButton = Create("TextButton", {
        AnchorPoint = Vector2.new(0, 1),
        AutoButtonColor = false,
        BackgroundColor3 = Color3.fromRGB(60, 60, 60),
        Position = UDim2.new(0, 0, 1, -10),
        Size = UDim2.new(1, 0, 0, 6),
        Text = "",
        Parent = SliderHolder
    })

    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = SliderBar })

    local SliderFillBar = Create("Frame", {
        BackgroundColor3 = Color3.fromRGB(140, 140, 140),
        Size = UDim2.fromScale(0.5, 1),
        Parent = SliderBar
    })

    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = SliderFillBar })

    local Slider = {
        Dragging = false,
        Hovering = false,
        Locked = false,

        Min = options.Min or 0,
        Max = options.Max or 100,
        Rounding = options.Rounding or 0,
        Increment = options.Increment or nil,
        Value = options.Value or (options.Min or 0),

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
            SliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            SliderFillBar.BackgroundColor3 = Slider.Hovering
                and Color3.fromRGB(220, 220, 220)
                or  Color3.fromRGB(140, 140, 140)
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
        Tween(SliderFillBar, FastTween, {BackgroundColor3 = Color3.fromRGB(220, 220, 220)})
    end)

    SliderHoverZone.MouseLeave:Connect(function()
        Slider.Hovering = false
        if Slider.Locked then return end
        Tween(SliderText, FastTween, {TextTransparency = 0.5})
        Tween(SliderFillBar, FastTween, {BackgroundColor3 = Color3.fromRGB(140, 140, 140)})
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
        if not Library.Opened then
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
    return Slider
end

function Components:AddTextbox(options: TextboxOptions)
    local TextboxHolder = Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 42),
        Parent = self.Container
    })

    Create("UIPadding", {
        PaddingBottom = UDim.new(0, 5),
        PaddingLeft = UDim.new(0, 13),
        PaddingRight = UDim.new(0, 13),
        PaddingTop = UDim.new(0, 5),
        Parent = TextboxHolder
    })

    local Box: TextBox = Create("TextBox", {
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        BackgroundTransparency = 0,
        ClearTextOnFocus = options.ClearTextOnFocus ~= false and (options.ResetOnFocus ~= false),
        FontFace = regularFont,
        PlaceholderColor3 = Color3.fromRGB(60, 60, 60),
        PlaceholderText = options.Placeholder or options.Name or "No Name",
        Size = UDim2.fromScale(1, 1),
        Text = options.Text or "",
        TextColor3 = Color3.fromRGB(140, 140, 140),
        TextScaled = true,
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
        Color = Color3.fromRGB(60, 60, 60),
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
        LockedIcon.Visible = Textbox.Locked
        UpdateVisuals()
    end

    function Textbox:SetVisible(visible)
        TextboxHolder.Visible = visible
    end

    function Textbox:SetText(text)
        Textbox.Name = text
    end

    if options.Flag then
        Library.Flags[options.Flag] = Textbox
    end

    local function UpdateVisuals()
        if Textbox.Focused then
            Tween(Box, FastTween, {
                BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                TextColor3 = Color3.new(1, 1, 1),
                PlaceholderColor3 = Color3.fromRGB(90, 90, 90),
            })
            Tween(BoxStroke, FastTween, {Color = Color3.fromRGB(90, 90, 90)})
        elseif Textbox.Hovering and not Textbox.Locked then
            Tween(Box, FastTween, {
                BackgroundColor3 = Color3.fromRGB(30, 30, 30),
                TextColor3 = Color3.fromRGB(200, 200, 200),
                PlaceholderColor3 = Color3.fromRGB(80, 80, 80),
            })
            Tween(BoxStroke, FastTween, {Color = Color3.fromRGB(80, 80, 80)})
        else
            Tween(Box, FastTween, {
                BackgroundColor3 = Color3.fromRGB(25, 25, 25),
                TextColor3 = Color3.fromRGB(140, 140, 140),
                PlaceholderColor3 = Color3.fromRGB(60, 60, 60),
            })
            Tween(BoxStroke, FastTween, {Color = Color3.fromRGB(60, 60, 60)})
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
    return Textbox
end

function Components:AddDropdown(options: DropdownOptions)
    local DropdownHolder = Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 42),
        Parent = self.Container
    })

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
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        Size = UDim2.new(1, 0, 0, 32),
        ClipsDescendants = true,
        Parent = DropdownHolder
    })

    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = ButtonsHolder })
    Create("UIStroke", {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = Color3.fromRGB(60, 60, 60),
        Parent = ButtonsHolder
    })

    local CurrentButton = Create("TextButton", {
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        FontFace = regularFont,
        Size = UDim2.new(1, 0, 0, 32),
        TextColor3 = Color3.fromRGB(140, 140, 140),
        TextScaled = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = ButtonsHolder
    })

    Create("UIPadding", {
        PaddingBottom = UDim.new(0, 6),
        PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 30),
        PaddingTop = UDim.new(0, 6),
        Parent = CurrentButton
    })

    local SearchBox
    if options.Searchable then
        SearchBox = Create("TextBox", {
            BackgroundColor3 = Color3.fromRGB(30, 30, 30),
            ClearTextOnFocus = false,
            FontFace = regularFont,
            PlaceholderColor3 = Color3.fromRGB(100, 100, 100),
            PlaceholderText = "Search...",
            Position = UDim2.fromOffset(0, 32),
            Size = UDim2.new(1, 0, 0, 28),
            Text = "",
            TextColor3 = Color3.new(1, 1, 1),
            TextSize = 20,
            TextXAlignment = Enum.TextXAlignment.Left,
            Visible = false,
            Parent = ButtonsHolder
        })

        Create("UIPadding", {
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            Parent = SearchBox
        })

        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = Color3.fromRGB(60, 60, 60),
            Parent = SearchBox
        })
    end

    local OptionsHolder = Create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 32),
        Size = UDim2.fromScale(1, 0),
        Visible = false,
        Parent = ButtonsHolder,
    })

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

    local OpenTweenInfo = TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local CloseTweenInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    local progress = 0
    local listHeight = 0
    local scrollOffset = 0

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

        local openButtonsH = BASE_HEIGHT + searchSlot + math.min(listHeight, MaxListHeight())
        local closedButtonsH = BASE_HEIGHT

        local buttonsH = closedButtonsH + (openButtonsH - closedButtonsH) * p
        local holderH = buttonsH + HOLDER_PAD

        DropdownHolder.Size = UDim2.new(1, 0, 0, holderH)
        ButtonsHolder.Size = UDim2.new(1, 0, 0, buttonsH)

        OptionsHolder.Position = UDim2.fromOffset(0, BASE_HEIGHT + searchSlot * p)

        if SearchBox then
            local searchY = BASE_HEIGHT + SEARCH_GAP * p
            SearchBox.Position = UDim2.fromOffset(0, searchY)
            SearchBox.BackgroundTransparency = 1 - p
            SearchBox.TextTransparency = 1 - p
            if p > 0.001 then SearchBox.Visible = true end
        end

        Icon.Rotation = 180 * p
    end

    function Dropdown:RefreshSize()
        listHeight = #filteredCache * ITEM_HEIGHT
        ApplyProgress(progress)
    end

    function Dropdown:AnimateSize(opening)
        Dropdown.Animating = true
        if opening then
            OptionsHolder.Visible = true
            if SearchBox then SearchBox.Visible = true end
            listHeight = #filteredCache * ITEM_HEIGHT
        end

        local from = progress
        local to = opening and 1 or 0
        local progressValue = Instance.new("NumberValue")
        progressValue.Value = from
        local conn = progressValue.Changed:Connect(function(v) ApplyProgress(v) end)
        local tween = TweenService:Create(progressValue, opening and OpenTweenInfo or CloseTweenInfo, { Value = to })
        tween.Completed:Connect(function()
            conn:Disconnect()
            Dropdown.Animating = false
            if not opening then
                OptionsHolder.Visible = false
                if SearchBox then
                    SearchBox.Visible = false
                    SearchBox.Text = ""
                    Dropdown.SearchText = ""
                    Dropdown:BuildList()
                end
            end
            ApplyProgress(to)
        end)
        tween:Play()
    end

    local function GetOrCreateRow(Value)
        local row = Dropdown.Buttons[Value]
        if row then return row end

        local Btn = Create("TextButton", {
            AutoButtonColor = false,
            BackgroundTransparency = 1,
            FontFace = regularFont,
            Size = UDim2.new(1, 0, 0, ITEM_HEIGHT),
            Text = "",
            TextColor3 = Color3.fromRGB(140, 140, 140),
            TextScaled = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = OptionsHolder
        })
        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 6),
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 6),
            PaddingTop = UDim.new(0, 6),
            Parent = Btn
        })

        local Divider = Create("Frame", {
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = Color3.fromRGB(50, 50, 50),
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
            if row.IsDisabled then
                Btn.TextColor3 = row.Selected and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(100, 100, 100)
                Btn.TextTransparency = 0.65
            else
                Btn.TextColor3 = row.Selected and Color3.new(1, 1, 1) or Color3.fromRGB(140, 140, 140)
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
            local baseColor = row.Selected and Color3.new(1, 1, 1) or Color3.fromRGB(140, 140, 140)
            local target = baseColor:Lerp(Color3.new(1, 1, 1), 0.6)
            Tween(Btn, FastTween, { TextColor3 = target })
        end)

        Btn.MouseLeave:Connect(function()
            if row.IsDisabled then return end
            row.Hovering = false
            local baseColor = row.Selected and Color3.new(1, 1, 1) or Color3.fromRGB(140, 140, 140)
            Tween(Btn, FastTween, { TextColor3 = baseColor })
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
        local visibleHeight = math.min(total * ITEM_HEIGHT, MaxListHeight())
        OptionsHolder.Size = UDim2.new(1, 0, 0, visibleHeight)

        local visibleCount = math.min(Dropdown.MaxVisibleDropdownItems + 1, total)
        local first = math.floor(scrollOffset / ITEM_HEIGHT) + 1
        local maxFirst = math.max(1, total - visibleCount + 1)
        first = math.clamp(first, 1, maxFirst)

        local firstVisibleValue = filteredCache[first] and filteredCache[first].Value
        if firstVisibleValue and Dropdown.Buttons[firstVisibleValue] then
            scrollOffset = (first - 1) * ITEM_HEIGHT
        end

        for _, row in Dropdown.Buttons do
            row.Button.Visible = false
            row.Divider.Visible = false
        end

        for i = 1, visibleCount do
            local Entry = filteredCache[first + i - 1]
            if not Entry then break end
            local row = GetOrCreateRow(Entry.Value)
            row.Value = Entry.Value
            row.RawValue = Entry.RawValue
            row.IsDisabled = Entry.IsDisabled
            row.Button.Text = Entry.Formatted
            row.Button.Visible = true
            row.Button.LayoutOrder = (i * 2) - 2
            row.Button.Position = UDim2.fromOffset(0, (i - 1) * ITEM_HEIGHT)

            local absoluteIndex = first + i - 1
            local showDivider = (absoluteIndex > 1) or (absoluteIndex == 1 and not SearchBox)
            row.Divider.Visible = showDivider
            if showDivider then
                row.Divider.LayoutOrder = (i * 2) - 3
                row.Divider.Position = UDim2.fromOffset(0, (i - 1) * ITEM_HEIGHT)
            end

            row:UpdateButton()
        end

        Dropdown:Update()
        if Dropdown.Opened and not Dropdown.Animating then Dropdown:RefreshSize() end
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
                    scrollOffset = 0
                    Dropdown:BuildList()
                end)
            end)
        end

        UserInputService.InputChanged:Connect(function(input)
            if not Dropdown.Opened or Dropdown.Animating then return end
            if input.UserInputType ~= Enum.UserInputType.MouseWheel then return end
            if not OptionsHolder.Visible then return end
            local mx, my = input.Position.X, input.Position.Y
            local ap = OptionsHolder.AbsolutePosition
            local as = OptionsHolder.AbsoluteSize
            if mx < ap.X or mx > ap.X + as.X or my < ap.Y or my > ap.Y + as.Y then return end
            local total = #filteredCache * ITEM_HEIGHT
            local maxScroll = math.max(0, total - MaxListHeight())
            scrollOffset = math.clamp(scrollOffset - input.Position.Z * ITEM_HEIGHT, 0, maxScroll)
            Dropdown:BuildList()
        end)

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
            Tween(CurrentButton, FastTween, { TextColor3 = Color3.fromRGB(220, 220, 220) })
        end)

        CurrentButton.MouseLeave:Connect(function()
            Dropdown.Hovering = false
            if Dropdown.Locked then return end
            Tween(CurrentButton, FastTween, { TextColor3 = Color3.fromRGB(140, 140, 140) })
        end)

        CurrentButton.MouseButton1Click:Connect(function() Dropdown:Toggle() end)

        local Defaults = (function()
            local Resolved = {}
            local Default = options.Value
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

    return Dropdown
end

    function Components:AddKeyPicker(options: KeyPickerOptions)
        local KeyPickerHolder = Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 32),
            Parent = self.Container,
        })

        Create("UIPadding", {
            PaddingLeft = UDim.new(0, 11),
            PaddingRight = UDim.new(0, 11),
            Parent = KeyPickerHolder
        })

        local KeyPickerText = Create("TextLabel", {
            BackgroundTransparency = 1,
            FontFace = regularFont,
            Size = UDim2.fromScale(1, 1),
            Text = options.Name or "Key Picker",
            TextColor3 = Color3.new(1, 1, 1),
            TextScaled = true,
            TextTransparency = 0.5,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = KeyPickerHolder,
        })

        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 6),
            PaddingTop = UDim.new(0, 6),
            Parent = KeyPickerText
        })

        local KeyPickerButton: TextButton = Create("TextButton", {
            AutoButtonColor = false,
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundTransparency = 0.95,
            FontFace = semiBoldFont,
            Position = UDim2.fromScale(1, 0.5),
            Size = UDim2.fromOffset(20, 20),
            Text = "...",
            TextColor3 = Color3.new(1, 1, 1),
            TextSize = 14,
            TextTransparency = 0.5,
            Parent = KeyPickerHolder
        })

        Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = KeyPickerButton })

        local KeyPicker = {
            Hovering = false,
            KeyPressed = nil,
            State = false,
            Picking = false,
            Keybind = options.Keybind or nil,
            Mode = options.Mode or "Toggle",
            Type = "KeyPicker",
        }

        function KeyPicker:SetKeybind(keybind, picking)
            KeyPicker.Keybind = keybind
            KeyPicker:Update(KeyPicker.Keybind, picking)
        end

        function KeyPicker:SetState(state: boolean)
            local oldState = KeyPicker.State
            KeyPicker.State = state
            if KeyPicker.State ~= oldState then
                Library:SafeCallback(options.Callback, KeyPicker.State, oldState)
            end
        end

        function KeyPicker:SetLocked(locked)
            KeyPicker.Locked = locked == true
            KeyPickerButton.Visible = not KeyPicker.Locked
            KeyPickerText.TextTransparency = KeyPicker.Locked and 0.75 or 0.5
        end

        function KeyPicker:Update(keybind, picking)
            local keyText = picking and "..." or (keybind and (keyCodesName[keybind] or string.sub(keybind.Name, 1, 6)) or "None")
            local size = GetTextBounds(keyText, semiBoldFont, 14, Library.UISize - 24)
            if size then KeyPickerButton.Size = UDim2.fromOffset(size.X + 12, 20) end
            KeyPickerButton.Text = keyText
        end

        if options.Flag then
            Library.Flags[options.Flag] = KeyPicker
        end

        KeyPickerButton.MouseEnter:Connect(function()
            KeyPicker.Hovering = true
            Tween(KeyPickerButton, FastTween, {TextTransparency = 0.25})
        end)

        KeyPickerButton.MouseLeave:Connect(function()
            KeyPicker.Hovering = false
            Tween(KeyPickerButton, FastTween, {TextTransparency = 0.5})
        end)

        KeyPickerButton.MouseButton1Click:Connect(function()
            if KeyPicker.Picking or KeyPicker.Locked then return end
            KeyPicker.Picking = true
            KeyPicker:SetKeybind(nil, true)

            local inputObject = UserInputService.InputBegan:Wait()
            local isKeyCode = inputObject.KeyCode ~= Enum.KeyCode.Unknown

            if isKeyCode and inputObject.KeyCode == Enum.KeyCode.Escape then
                KeyPicker:SetKeybind(nil)
                KeyPicker.Picking = false
                return
            end

            KeyPicker.KeyPressed = isKeyCode and inputObject.KeyCode or inputObject.UserInputType
            KeyPicker:SetKeybind(KeyPicker.KeyPressed)
        end)

        Library:AddConnection(UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
            if (input.KeyCode == KeyPicker.Keybind or input.UserInputType == KeyPicker.Keybind) and not KeyPicker.Picking and not gameProcessedEvent then
                if KeyPicker.Mode == "Hold" then
                    KeyPicker:SetState(true)
                else
                    KeyPicker:SetState(not KeyPicker.State)
                end
            end
        end))

        Library:AddConnection(UserInputService.InputEnded:Connect(function(input)
            if (input.KeyCode == KeyPicker.Keybind or input.UserInputType == KeyPicker.Keybind) and not KeyPicker.Picking then
                if KeyPicker.Mode == "Hold" then KeyPicker:SetState(false) end
            elseif (input.KeyCode == KeyPicker.KeyPressed or input.UserInputType == KeyPicker.KeyPressed) and KeyPicker.Picking then
                KeyPicker.KeyPressed = nil
                KeyPicker.Picking = false
            end
        end))

        KeyPicker:SetKeybind(KeyPicker.Keybind)
        return KeyPicker
    end

    function Components:AddColorPicker(options: ColorPickerOptions)
        local ColorPickerHolder = Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 42),
            Parent = self.Container
        })

        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 5),
            PaddingLeft = UDim.new(0, 13),
            PaddingRight = UDim.new(0, 13),
            PaddingTop = UDim.new(0, 5),
            Parent = ColorPickerHolder
        })

        local ButtonsHolder = Create("Frame", {
            BackgroundColor3 = Color3.fromRGB(25, 25, 25),
            Size = UDim2.fromScale(1, 1),
            ClipsDescendants = true,
            Parent = ColorPickerHolder
        })

        Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = ButtonsHolder })
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = Color3.fromRGB(60, 60, 60),
            Parent = ButtonsHolder
        })

        local OpenButton: TextButton = Create("TextButton", {
            BackgroundTransparency = 1,
            FontFace = regularFont,
            Size = UDim2.new(1, 0, 0, 32),
            Text = options.Name or "No Name",
            TextColor3 = Color3.fromRGB(140, 140, 140),
            TextScaled = true,
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

        local ColorHolder = Create("Frame", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(0, 32),
            Size = UDim2.new(1, 0, 1, -32),
            Visible = false,
            Parent = ButtonsHolder
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
            Size = UDim2.fromScale(1, 1),
            SizeConstraint = Enum.SizeConstraint.RelativeYY,
            Parent = ColorHolder
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

        local ColorIndicator = Create("Frame", {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundColor3 = options.Color or Color3.new(1, 1, 1),
            Position = UDim2.new(1, -6, 0, 6),
            Size = UDim2.fromOffset(20, 20),
            Parent = ColorPickerHolder
        })

        Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = ColorIndicator })

        local ColorPicker = {
            DraggingColor = false,
            DraggingHue = false,
            Locked = false,
            Hovering = false,
            Opened = false,
            Hue = 0, Sat = 0, Vib = 0,
            Color = options.Color or Color3.new(1, 1, 1),
            Type = "ColorPicker"
        }

        local openTweenInfo = TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        local closeTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local CLOSED_HEIGHT = 42
        local OPEN_HEIGHT = Library.UISize - 8

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

            LockedHover.Visible = ColorPicker.Locked
            ColorIndicator.Visible = not ColorPicker.Locked
            LockedIcon.Visible = ColorPicker.Locked

            if ColorPicker.Locked and ColorPicker.Opened then
                ColorPicker.Opened = false
                ColorPicker:Toggle()
            end
        end

        function ColorPicker:Toggle()
            ColorPicker.Opened = not ColorPicker.Opened
            ColorHolder.Visible = true
            local hTween = TweenService:Create(ColorPickerHolder, ColorPicker.Opened and openTweenInfo or closeTweenInfo, {
                Size = ColorPicker.Opened and UDim2.new(1, 0, 0, OPEN_HEIGHT) or UDim2.new(1, 0, 0, CLOSED_HEIGHT)
            })
            hTween:Play()
            if not ColorPicker.Opened then
                hTween.Completed:Connect(function() ColorHolder.Visible = false end)
            end
        end

        function ColorPicker:Update()
            local oldColor = ColorPicker.Color
            ColorPicker.Color = Color3.fromHSV(ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib)
            ColorImage.BackgroundColor3 = Color3.fromHSV(ColorPicker.Hue, 1, 1)
            ColorIndicator.BackgroundColor3 = ColorPicker.Color
            ColorImageIndicator.Position = UDim2.new(ColorPicker.Sat, 0, 1 - ColorPicker.Vib, 0)
            ColorHueIndicator.Position = UDim2.fromScale(0.5, ColorPicker.Hue)
            if ColorPicker.Color ~= oldColor then
                Library:SafeCallback(options.Callback, ColorPicker.Color, oldColor)
            end
        end

        if options.Flag then
            Library.Flags[options.Flag] = ColorPicker
        end

        OpenButton.MouseEnter:Connect(function()
            ColorPicker.Hovering = true
            if ColorPicker.Locked then return end
            Tween(OpenButton, FastTween, {TextColor3 = Color3.fromRGB(220, 220, 220)})
        end)

        OpenButton.MouseLeave:Connect(function()
            ColorPicker.Hovering = false
            if ColorPicker.Locked then return end
            Tween(OpenButton, FastTween, {TextColor3 = Color3.fromRGB(140, 140, 140)})
        end)

        OpenButton.MouseButton1Click:Connect(function() ColorPicker:Toggle() end)

        ColorImage.InputBegan:Connect(function(input)
            if not ColorPicker.Locked and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
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
            if not ColorPicker.Locked and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
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
            if not Library.Opened then
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

        ColorPicker:SetColor(options.Color)
        return ColorPicker
    end

    BaseComponents.__index = Components
    BaseComponents.__namecall = function(Table, Key, ...)
        return Components[Key](...)
    end
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
    if not keybind then return end

    writefile(path, tostring(HttpService:JSONEncode({
        Keybind = tostring(keybind)
    })))
end

local function LoadKeybind()
    local path = GetKeybindFile()
    if not path or not isfile(path) then return nil end

    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(path))
    end)
    if not ok or type(data) ~= "table" or not data.Keybind then return nil end

    local split = string.split(data.Keybind, ".")
    table.remove(split, 1)
    local keybind = Enum
    for _, v in ipairs(split) do
        keybind = keybind[v]
    end

    return keybind
end

function Library:CreateWindow(options: WindowOptions)
    Library.NotifySound = options.NotifySound or 4590657391
    Library.NotifyVolume = options.NotifyVolume or 2
    Library.SaveFolder = options.SaveFolder or "Library"
    Library.ToggleKeybind = options.ToggleKeybind or Enum.KeyCode.RightShift

    NotifySoundInstance.SoundId = "rbxassetid://" .. tostring(Library.NotifySound)
    NotifySoundInstance.Volume = Library.NotifyVolume

    if options.Blur ~= false then
        Library.Blur = Create("BlurEffect", { Size = 12, Parent = Lighting })
    end

    local MainWindow = Create("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        Size = UDim2.fromOffset(Library.UISize, 0),
        Parent = Windows
    })
    table.insert(Library.Tabs, MainWindow)
    Library.MainWindow = MainWindow
    Library.TabHolders = {}

    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = MainWindow })
    Create("UIListLayout", { Parent = MainWindow })

    local Top = Create("Frame", {
        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        Size = UDim2.new(1, 0, 0, 40),
        Parent = MainWindow
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Top })
    Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 1),
        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        Position = UDim2.fromScale(0.5, 1),
        Size = UDim2.fromScale(1, 0.25),
        Parent = Top
    })

    local TitleIconDef = options.Icon and Library:GetIcon(options.Icon)
    if TitleIconDef then
        local TitleIcon = Create("ImageLabel", {
            BackgroundTransparency = 1,
            Image = "",
            Position = UDim2.fromOffset(9, 5),
            Size = UDim2.fromOffset(30, 30),
            ZIndex = 2,
            Parent = Top
        })
        Library:ApplyIcon(TitleIcon, TitleIconDef)
    end

    local Title = Create("TextLabel", {
        BackgroundTransparency = 1,
        FontFace = semiBoldFont,
        Position = UDim2.fromOffset(TitleIconDef and 32 or 0, 0),
        Size = UDim2.new(1, TitleIconDef and -32 or 0, 1, 0),
        Text = options.Title or "No Title",
        TextColor3 = Color3.new(1, 1, 1),
        TextScaled = true,
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

    Create("Frame", { BackgroundColor3 = Color3.fromRGB(60, 60, 60), Size = UDim2.new(1, 0, 0, 1), Parent = MainWindow })

    local TabButtons = Create("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 0),
        Parent = MainWindow
    })
    Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = TabButtons })

    Create("Frame", { BackgroundColor3 = Color3.fromRGB(60, 60, 60), Size = UDim2.new(1, 0, 0, 1), Parent = MainWindow })
    Create("Frame", { BackgroundTransparency = 1, LayoutOrder = 999, Size = UDim2.new(1, 0, 0, 6), Parent = MainWindow })

    task.spawn(Library.Toggle)

    local Window = {}

    function Window:AddTab(tabName, IconName, Collapsed)
        local TabHolder: Frame = Create("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = Color3.fromRGB(25, 25, 25),
            Position = UDim2.fromOffset((Library.UISize + 6) * #Library.Tabs, 0),
            Size = UDim2.fromOffset(Library.UISize, 0),
            Visible = false,
            Parent = Windows,
        })
        table.insert(Library.Tabs, MainWindow)

        if Library.TabHolders then table.insert(Library.TabHolders, TabHolder) end

        Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = TabHolder })
        Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = TabHolder })

        local Top2 = Create("TextButton", {
            AutoButtonColor = false,
            BackgroundColor3 = Color3.fromRGB(20, 20, 20),
            Size = UDim2.new(1, 0, 0, 40),
            Text = "",
            Parent = TabHolder
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Top2 })
        Create("Frame", {
            AnchorPoint = Vector2.new(0.5, 1),
            BackgroundColor3 = Color3.fromRGB(20, 20, 20),
            Position = UDim2.fromScale(0.5, 1),
            Size = UDim2.fromScale(1, 0.25),
            Parent = Top2
        })

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
            Text = tabName or "No Name", TextColor3 = Color3.new(1, 1, 1),
            TextSize = 20, TextXAlignment = Enum.TextXAlignment.Left, Parent = Top2
        })
        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12), PaddingTop = UDim.new(0, 6), Parent = Title2
        })

        Create("Frame", { BackgroundColor3 = Color3.fromRGB(60, 60, 60), Size = UDim2.new(1, 0, 0, 1), Parent = TabHolder })

        local Elements = Create("ScrollingFrame", {
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
            CanvasSize = UDim2.fromScale(0, 0),
            ScrollBarImageColor3 = Color3.fromRGB(95, 95, 95),
            ScrollBarThickness = 4,
            Size = UDim2.fromScale(1, 0),
            TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
            Parent = TabHolder
        })

        local ElementsListLayout = Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = Elements })

        Create("Frame", { BackgroundColor3 = Color3.fromRGB(60, 60, 60), Size = UDim2.new(1, 0, 0, 1), Parent = TabHolder })
        Create("Frame", { BackgroundTransparency = 1, LayoutOrder = 999, Size = UDim2.new(1, 0, 0, 6), Parent = TabHolder })

        if #Library.TabHolders > 1 then
            Create("Frame", {
                BackgroundColor3 = Color3.fromRGB(60, 60, 60),
                LayoutOrder = (#Library.TabHolders * 2) - 3,
                Size = UDim2.new(1, 0, 0, 1),
                Parent = TabButtons,
            })
        end

        local TabButton: TextButton = Create("TextButton", {
            AutoButtonColor = false,
            BackgroundColor3 = Color3.fromRGB(25, 25, 25),
            LayoutOrder = (#Library.TabHolders * 2) - 2,
            Size = UDim2.new(1, 0, 0, 36),
            Text = "",
            Parent = TabButtons
        })

        local TabButtonText = Create("TextLabel", {
            BackgroundTransparency = 1, FontFace = regularFont,
            Position = UDim2.fromOffset(HeaderIconDef and 18 or 0, 0),
            Size = UDim2.new(1, HeaderIconDef and -24 or 0, 1, 0),
            Text = tabName or "No Name", TextColor3 = Color3.new(1, 1, 1),
            TextScaled = true, TextTransparency = 0.5,
            TextXAlignment = Enum.TextXAlignment.Left, Parent = TabButton
        })

        if HeaderIconDef then
            local TabButtonIcon = Create("ImageLabel", {
                BackgroundTransparency = 1, Image = "", ImageTransparency = 0.5,
                Position = UDim2.fromOffset(4, 8), Size = UDim2.fromOffset(20, 20), ZIndex = 2, Parent = TabButton
            })
            Library:ApplyIcon(TabButtonIcon, HeaderIconDef)
        end

        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 11),
            PaddingRight = UDim.new(0, 11), PaddingTop = UDim.new(0, 8), Parent = TabButtonText
        })

        local Tab = { Hovering = false, Opened = false, _LastWasSection = false }

        function Tab:Toggle()
            Tab.Opened = not Tab.Opened
            TabHolder.Visible = Tab.Opened
            TabButton.BackgroundColor3 = Tab.Opened and Color3.fromRGB(35, 35, 35) or (Tab.Hovering and Color3.fromRGB(30, 30, 30) or Color3.fromRGB(25, 25, 25))
            TabButtonText.TextTransparency = Tab.Opened and 0 or (Tab.Hovering and 0.25 or 0.5)
        end

        function Tab:AddElementSection(name, Collapsed)
            if Tab._LastWasSection then
                Create("Frame", { BackgroundColor3 = Color3.fromRGB(60, 60, 60), Size = UDim2.new(1, 0, 0, 1), Parent = Elements })
            end
            Tab._LastWasSection = true

            local ElementHolder: TextButton = Create("TextButton", {
                AutoButtonColor = false,
                BackgroundColor3 = Color3.fromRGB(25, 25, 25),
                Size = UDim2.new(1, 0, 0, 36),
                Text = "",
                Parent = Elements
            })

            local ButtonFrame: TextButton = Create("TextButton", {
                AutoButtonColor = false,
                BackgroundColor3 = Color3.fromRGB(25, 25, 25),
                FontFace = regularFont,
                Size = UDim2.new(1, 0, 0, 36),
                Text = name or "Section",
                TextColor3 = Color3.new(1, 1, 1),
                TextScaled = true,
                TextTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = ElementHolder
            })

            local Components = Create("Frame", {
                AnchorPoint = Vector2.new(0.5, 1),
                BackgroundColor3 = Color3.fromRGB(20, 20, 20),
                Position = UDim2.fromScale(0.5, 1),
                Size = UDim2.new(1, 0, 1, -36),
                Parent = ElementHolder
            })

            local ComponentsListLayout = Create("UIListLayout", {
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = Components
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

            local ElementSection = { Container = Components, Opened = false }

            function ElementSection:Toggle()
                ElementSection.Opened = not ElementSection.Opened
                ElementHolder.Size = ElementSection.Opened and UDim2.new(1, 0, 0, ComponentsListLayout.AbsoluteContentSize.Y + 36) or UDim2.new(1, 0, 0, 36)
                Library:ApplyIcon(Icon, ElementSection.Opened and PopInIcon or PopOutIcon)
            end

            ComponentsListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                ElementHolder.Size = ElementSection.Opened and UDim2.new(1, 0, 0, ComponentsListLayout.AbsoluteContentSize.Y + 36) or UDim2.new(1, 0, 0, 36)
            end)

            ButtonFrame.MouseEnter:Connect(function()
                ButtonFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                ButtonFrame.TextTransparency = 0.25
            end)

            ButtonFrame.MouseLeave:Connect(function()
                ButtonFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                ButtonFrame.TextTransparency = 0.5
            end)

            ButtonFrame.MouseButton1Click:Connect(function() ElementSection:Toggle() end)

            setmetatable(ElementSection, BaseComponents)

            if Collapsed ~= false then ElementSection:Toggle() end
            return ElementSection
        end

        function Tab:AddElementToggle(options: ElementToggleOptions)
            local ElementHolder: TextButton = Create("TextButton", {
                AutoButtonColor = false, BackgroundColor3 = Color3.fromRGB(25, 25, 25),
                Size = UDim2.new(1, 0, 0, 36), Text = "", Parent = Elements
            })

            local ButtonFrame: TextButton = Create("TextButton", {
                AutoButtonColor = false, BackgroundColor3 = Color3.fromRGB(25, 25, 25),
                FontFace = regularFont, Size = UDim2.new(1, 0, 0, 36),
                Text = options.Name or "Button", TextColor3 = Color3.new(1, 1, 1),
                TextScaled = true, TextTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Left, Parent = ElementHolder
            })

            local KeybindButton: TextButton = Create("TextButton", {
                AutoButtonColor = false, AnchorPoint = Vector2.new(1, 0),
                BackgroundTransparency = 0.95, FontFace = semiBoldFont,
                Position = UDim2.new(1, -28, 0, 8), Size = UDim2.fromOffset(20, 20),
                Text = "...", TextColor3 = Color3.new(1, 1, 1), TextSize = 14,
                TextTransparency = 0.5, Parent = ElementHolder
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = KeybindButton })

            local Components = Create("Frame", {
                AnchorPoint = Vector2.new(0.5, 1), BackgroundColor3 = Color3.fromRGB(20, 20, 20),
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
                ButtonFrame.BackgroundColor3 = ElementToggle.Value and Color3.fromRGB(35, 35, 35) or (ElementToggle.Hovering and Color3.fromRGB(30, 30, 30) or Color3.fromRGB(25, 25, 25))
                ButtonFrame.TextTransparency = ElementToggle.Value and 0 or (ElementToggle.Hovering and 0.25 or 0.5)
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
                ElementToggle.Keybind = keybind
                ElementToggle:UpdateKeybind(ElementToggle.Keybind, picking)
            end

            function ElementToggle:UpdateKeybind(keybind, picking)
                local keyText = picking and "..." or (keybind and (keyCodesName[keybind] or string.sub(keybind.Name, 1, 6)) or "None")
                local size = GetTextBounds(keyText, semiBoldFont, 14, Library.UISize - 24)
                if size then KeybindButton.Size = UDim2.fromOffset(size.X + 12, 20) end
                KeybindButton.Text = keyText
            end

            function ElementToggle:Toggle()
                ElementToggle.Opened = not ElementToggle.Opened
                ElementHolder.Size = ElementToggle.Opened and UDim2.new(1, 0, 0, ComponentsListLayout.AbsoluteContentSize.Y + 36) or UDim2.new(1, 0, 0, 36)
                Library:ApplyIcon(Icon, ElementToggle.Opened and PopInIcon or PopOutIcon)
            end

            if options.Flag then Library.Flags[options.Flag] = ElementToggle end

            ComponentsListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                ElementHolder.Size = ElementToggle.Opened and UDim2.new(1, 0, 0, ComponentsListLayout.AbsoluteContentSize.Y + 36) or UDim2.new(1, 0, 0, 36)
            end)

            ButtonFrame.MouseButton1Click:Connect(function()
                if ElementToggle.Locked then return end
                ElementToggle:Set(not ElementToggle.Value)
            end)
            ButtonFrame.MouseButton2Click:Connect(function() ElementToggle:Toggle() end)

            KeybindButton.MouseEnter:Connect(function()
                Tween(KeybindButton, FastTween, {TextTransparency = 0.25})
            end)

            KeybindButton.MouseLeave:Connect(function()
                Tween(KeybindButton, FastTween, {TextTransparency = 0.5})
            end)

            KeybindButton.MouseButton1Click:Connect(function()
                if ElementToggle.Picking then return end
                ElementToggle.Picking = true
                ElementToggle:SetKeybind(nil, true)
                local inputObject = UserInputService.InputBegan:Wait()
                local isKeyCode = inputObject.KeyCode ~= Enum.KeyCode.Unknown
                if isKeyCode and inputObject.KeyCode == Enum.KeyCode.Escape then
                    ElementToggle:SetKeybind(nil)
                    ElementToggle.Picking = false
                    return
                end
                ElementToggle.KeyPressed = isKeyCode and inputObject.KeyCode or inputObject.UserInputType
                ElementToggle:SetKeybind(ElementToggle.KeyPressed)
            end)

            Library:AddConnection(UserInputService.InputBegan:Connect(function(input, gp)
                if not ElementToggle.Locked and (input.KeyCode == ElementToggle.Keybind or input.UserInputType == ElementToggle.Keybind) and not ElementToggle.Picking and not gp then
                    if ElementToggle.Mode == "Hold" then ElementToggle:Set(true)
                    else ElementToggle:Set(not ElementToggle.Value) end
                end
            end))
            Library:AddConnection(UserInputService.InputEnded:Connect(function(input)
                if not ElementToggle.Locked and (input.KeyCode == ElementToggle.Keybind or input.UserInputType == ElementToggle.Keybind) and not ElementToggle.Picking then
                    if ElementToggle.Mode == "Hold" then ElementToggle:Set(false) end
                elseif (input.KeyCode == ElementToggle.KeyPressed or input.UserInputType == ElementToggle.KeyPressed) and ElementToggle.Picking then
                    ElementToggle.KeyPressed = nil
                    ElementToggle.Picking = false
                end
            end))

            ElementToggle:Set(ElementToggle.Value)
            ElementToggle:SetKeybind(ElementToggle.Keybind)
            setmetatable(ElementToggle, BaseComponents)
            return ElementToggle
        end

        MakeDraggable(Top2, TabHolder)

        Elements.Size = UDim2.new(1, 0, 0, math.clamp(ElementsListLayout.AbsoluteContentSize.Y, 0, workspace.CurrentCamera.ViewportSize.Y / 1.6))
        ElementsListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Elements.Size = UDim2.new(1, 0, 0, math.clamp(ElementsListLayout.AbsoluteContentSize.Y, 0, workspace.CurrentCamera.ViewportSize.Y / 1.6))
        end)

        TabButton.MouseEnter:Connect(function()
            Tab.Hovering = true
            if not Tab.Opened then
                Tween(TabButton, FastTween, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)})
                Tween(TabButtonText, FastTween, {TextTransparency = 0.25})
            end
        end)

        TabButton.MouseLeave:Connect(function()
            Tab.Hovering = false
            if not Tab.Opened then
                Tween(TabButton, FastTween, {BackgroundColor3 = Color3.fromRGB(25, 25, 25)})
                Tween(TabButtonText, FastTween, {TextTransparency = 0.5})
            end
        end)

        TabButton.MouseButton1Click:Connect(function() task.spawn(Tab.Toggle) end)
        if Collapsed ~= false then Tab:Toggle() end

        return Tab
    end

    function Window:BuildSettingsElement(tab)
        local UISection = tab:AddElementSection("UI Manager")
        local ConfigSection = tab:AddElementSection("Config Manager")

        Library.ToggleKeybind = UISection:AddKeyPicker({
            Name = "Keybind", Flag = "Toggle_Keybind",
            Keybind = LoadKeybind() or Library.ToggleKeybind
        })

        do
            local picker = Library.ToggleKeybind
            local originalSetKeybind = picker.SetKeybind
            function picker:SetKeybind(keybind, picking)
                originalSetKeybind(self, keybind, picking)
                if not picking and keybind ~= nil then
                    SaveKeybind(keybind)
                end
            end
        end

        UISection:AddSlider({
            Name = "Notify Volume", Flag = "Notify_Volume",
            Min = 0, Max = 4, Increment = 0.5, Value = Library.NotifyVolume,
            Callback = function(value)
                Library.NotifyVolume = value
                NotifySoundInstance.Volume = value
            end
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

        local configNameBox = ConfigSection:AddTextbox({ Name = "Config Name" })
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
            BackgroundColor3 = Color3.fromRGB(30, 30, 30),
            Position = UDim2.new(1, -12, 0, 12),
            Size = UDim2.fromOffset(160, 52),
            Parent = UI,
        })

        Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = MobileButtonHolder })
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = Color3.fromRGB(72, 72, 72),
            Thickness = 1,
            Transparency = 0.1,
            Parent = MobileButtonHolder,
        })

        local IconHolder = Create("Frame", {
            BackgroundColor3 = Color3.fromRGB(30, 30, 30),
            Position = UDim2.fromOffset(10, 10),
            Size = UDim2.fromOffset(32, 32),
            Parent = MobileButtonHolder,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = IconHolder })
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = Color3.fromRGB(72, 72, 72),
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
        Library:ApplyIcon(UIIcon, Library:GetIcon("router") or SettingsIcon)
        UIIcon.ImageColor3 = Color3.fromRGB(60, 200, 100)

        local TitleLabel = Create("TextLabel", {
            BackgroundTransparency = 1,
            FontFace = semiBoldFont,
            Position = UDim2.fromOffset(52, 8),
            Size = UDim2.new(1, -64, 0, 20),
            Text = "Router",
            TextColor3 = Color3.new(1, 1, 1),
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTransparency = 0.05,
            Parent = MobileButtonHolder,
        })

        local SubtitleLabel = Create("TextLabel", {
            BackgroundTransparency = 1,
            FontFace = regularFont,
            Position = UDim2.fromOffset(52, 27),
            Size = UDim2.new(1, -64, 0, 16),
            Text = "Tap to open",
            TextColor3 = Color3.fromRGB(200, 200, 200),
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
            Position = UDim2.new(1, -10, 0.5, 0),
            Size = UDim2.fromOffset(16, 16),
            Parent = MobileButtonHolder,
        })
        Library:ApplyIcon(Grip, MoveIcon or Library:GetIcon("move"))

        local Accent = Create("Frame", {
            AnchorPoint = Vector2.new(0.5, 1),
            BackgroundColor3 = Color3.fromRGB(30, 30, 30),
            BorderSizePixel = 0,
            Position = UDim2.fromScale(0.5, 1),
            Size = UDim2.new(1, -20, 0, 2),
            Parent = MobileButtonHolder,
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Accent })

        local Interaction = Create("TextButton", {
            AutoButtonColor = false,
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Text = "",
            Parent = MobileButtonHolder,
        })

        local DRAG_THRESHOLD = 6
        local dragging = false
        local moved = false
        local dragStartPos
        local startFramePos
        local dragConn

        local function EndDrag()
            dragging = false
            if dragConn then
                dragConn:Disconnect()
                dragConn = nil
            end
            Tween(MobileButtonHolder, FastTween, { Size = UDim2.fromOffset(160, 52) })
        end

        Interaction.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.Touch
                and input.UserInputType ~= Enum.UserInputType.MouseButton1 then
                return
            end

            dragging = true
            moved = false
            dragStartPos = input.Position
            startFramePos = MobileButtonHolder.Position

            Tween(MobileButtonHolder, FastTween, { Size = UDim2.fromOffset(156, 50) })

            if dragConn then dragConn:Disconnect() end
            dragConn = UserInputService.InputChanged:Connect(function(i)
                if not dragging then return end
                if i.UserInputType ~= Enum.UserInputType.Touch
                    and i.UserInputType ~= Enum.UserInputType.MouseMovement then
                    return
                end

                local delta = i.Position - dragStartPos
                if not moved then
                    if math.abs(delta.X) >= DRAG_THRESHOLD or math.abs(delta.Y) >= DRAG_THRESHOLD then
                        moved = true
                    end
                end

                if moved then
                    MobileButtonHolder.Position = UDim2.new(
                        startFramePos.X.Scale, startFramePos.X.Offset + delta.X,
                        startFramePos.Y.Scale, startFramePos.Y.Offset + delta.Y
                    )
                end
            end)
            table.insert(Library.Connections, dragConn)

            local endedConn
            endedConn = input.Changed:Connect(function()
                if input.UserInputState ~= Enum.UserInputState.End then return end
                if endedConn then endedConn:Disconnect() end

                local wasMoved = moved
                EndDrag()

                if not wasMoved then
                    task.spawn(Library.Toggle)
                end
            end)
        end)

        UserInputService.InputEnded:Connect(function(input)
            if not dragging then return end
            if input.UserInputType ~= Enum.UserInputType.Touch
                and input.UserInputType ~= Enum.UserInputType.MouseButton1 then
                return
            end
            EndDrag()
        end)
    end

    Library:AddConnection(UserInputService.InputBegan:Connect(function(input)
        if typeof(Library.ToggleKeybind) == "table" and Library.ToggleKeybind.Type == "KeyPicker" and input.KeyCode == Library.ToggleKeybind.Keybind and not Library.ToggleKeybind.Picking then
            task.spawn(Library.Toggle)
        elseif input.KeyCode == Library.ToggleKeybind then
            task.spawn(Library.Toggle)
        end
    end))

    MakeDraggable(Top, MainWindow)
    return Window
end

function Library:Notify(text: string, duration: number, soundId: number)
    duration = duration or 5
    soundId = soundId or Library.NotifySound

    local textSize = GetTextBounds(text, regularFont, 24, (workspace.CurrentCamera.ViewportSize.X / 4) - 12)
    if not textSize then textSize = Vector2.new(120, 24) end

    local NotificationHolder = Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(textSize.X + 18, textSize.Y + 18),
        Parent = Notifications
    })

    local NotificationText: TextLabel = Create("TextLabel", {
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        BackgroundTransparency = 0.25,
        FontFace = regularFont,
        Position = UDim2.new(1, 6, 0, 0),
        Size = UDim2.fromScale(1, 1),
        Text = text, TextColor3 = Color3.new(1, 1, 1),
        TextSize = 24, TextWrapped = true, Parent = NotificationHolder
    })

    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = NotificationText })
    Create("UIPadding", {
        PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6), PaddingTop = UDim.new(0, 6), Parent = NotificationText
    })
    Create("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.fromRGB(90, 90, 90), Parent = NotificationText })

    if soundId then
        NotifySoundInstance.SoundId = "rbxassetid://" .. soundId
        NotifySoundInstance.Volume = Library.NotifyVolume
        NotifySoundInstance:Play()
    end

    NotificationText:TweenPosition(UDim2.fromScale(0, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Quint, 0.3)

    task.delay(duration, function()
        if not NotificationText or not NotificationText.Parent then return end
        NotificationText:TweenPosition(UDim2.new(1, 6, 0, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Quint, 0.3)
        task.wait(0.3)
        if NotificationHolder and NotificationHolder.Parent then
            NotificationHolder:Destroy()
        end
    end)
end

local ModalElement = Create("TextButton", {
    BackgroundTransparency = 1, Modal = true,
    Size = UDim2.fromScale(1, 1), Text = "", Visible = false, ZIndex = 0, Parent = UI
})

function Library:Toggle()
    if Library.Opened == nil then
        Library.Opened = getgenv().Auto_Show ~= false
        ModalElement.Visible = Library.Opened
        Windows.Visible = Library.Opened
        if Library.Blur then Library.Blur.Enabled = Library.Opened end
        return
    end

    Library.Opened = not Library.Opened
    ModalElement.Visible = Library.Opened
    Windows.Visible = Library.Opened
    if Library.Blur then Library.Blur.Enabled = Library.Opened end

end

function Library:Unload()
    if Library.Unloaded then return end
    Library.Unloaded = true

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

    if NotifySoundInstance then
        pcall(function() NotifySoundInstance:Destroy() end)
    end
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
