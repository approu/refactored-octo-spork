
setfflag('DebugRunParallelLuaOnMainThread', 'True')
local type_custom = typeof
if not LPH_OBFUSCATED then
    LPH_JIT = function(...)
        return ...;
    end;
    LPH_JIT_MAX = function(...)
        return ...;
    end;
    LPH_NO_VIRTUALIZE = function(...)
        return ...;
    end;
    LPH_NO_UPVALUES = function(f)
        return (function(...)
            return f(...);
        end);
    end;
    LPH_ENCSTR = function(...)
        return ...;
    end;
    LPH_ENCNUM = function(...)
        return ...;
    end;
    LPH_ENCFUNC = function(func, key1, key2)
        if key1 ~= key2 then return print("LPH_ENCFUNC mismatch") end
        return func
    end
    LPH_CRASH = function()
        return print(debug.traceback());
    end;
    SWG_DiscordUser = "swim"
    SWG_DiscordID = 1337
    SWG_Private = true
    SWG_Dev = false
    SWG_Version = "dev"
    SWG_Title = 'Limonad.xyz'
    SWG_ShortName = 'dev'
    SWG_FullName = 'indev build'
    SWG_FFA = false
end;
local workspace = cloneref(game:GetService("Workspace"))
local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local Lighting = cloneref(game:GetService("Lighting"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local HttpService = cloneref(game:GetService("HttpService"))
local GuiInset = cloneref(game:GetService("GuiService")):GetGuiInset()
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

local function getfile(name)
    local repo = "https://raw.githubusercontent.com/SWIMHUBISWIMMING/swimhub/main/"
    local success, content = pcall(request, {Url = repo..name, Method = "GET"})
    if success and content.StatusCode == 200 then
        return content.Body
    else
        return print("getfile returned error \""..content.."\"")
    end
end
local function isswimhubfile(file)
    return isfile("swimhub/new/files/"..file)
end
local function readswimhubfile(file)
    if not isswimhubfile(file) then return false end
    local success, returns = pcall(readfile, "swimhub/new/files/"..file)
    if success then return returns else return print(returns) end
end
local function loadswimhubfile(file)
    if not isswimhubfile(file) then return false end
    local success, returns = pcall(loadstring, readswimhubfile(file))
    if success then return returns else return print(returns) end
end
local function getswimhubasset(file)
    if isswimhubfile(file) then return false end
    local success, returns = pcall(getcustomasset, "swimhub/new/files/"..file)
    if success then return returns else return print(returns) end
end
do
    if not isfolder("swimhub") then makefolder("swimhub") end
    if not isfolder("swimhub/new") then makefolder("swimhub/new") end
    if not isfolder("swimhub/new/files") then makefolder("swimhub/new/files") end
    local function getfiles(force, list)
        for _, file in list do
            if (force or not force and not isswimhubfile(file)) then
                writefile("swimhub/new/files/"..file, getfile(file))
            end
        end
    end
    local gotassets = getfile("assets.json")
    local assets = HttpService:JSONDecode(gotassets)
    local localassets = readswimhubfile("assets.json")
    if localassets then
        localassets = HttpService:JSONDecode(localassets)
        if localassets then
            writefile("swimhub/new/files/assets.json", gotassets)
            getfiles(true, assets.list)
        end
    else
        writefile("swimhub/new/files/assets.json", gotassets)
    end
    getfiles(false, assets.list)
end



local cheat = {
    Library = nil,
    Toggles = nil,
    Options = nil,
    ThemeManager = nil,
    SaveManager = nil,
    connections = {
        heartbeats = {},
        renderstepped = {}
    },
    drawings = {},
    hooks = {}
}
cheat.utility = {} do
    cheat.utility.new_heartbeat = function(func)
        local obj = {}
        cheat.connections.heartbeats[func] = func
        function obj:Disconnect()
            if func then
                cheat.connections.heartbeats[func] = nil
                func = nil
            end
        end
        return obj
    end
    cheat.utility.new_renderstepped = function(func)
        local obj = {}
        cheat.connections.renderstepped[func] = func
        function obj:Disconnect()
            if func then
                cheat.connections.renderstepped[func] = nil
                func = nil
            end
        end
        return obj
    end
    cheat.utility.new_drawing = function(drawobj, args)
        local obj = Drawing.new(drawobj)
        for i, v in pairs(args) do
            obj[i] = v
        end
        cheat.drawings[obj] = obj
        return obj
    end
    cheat.utility.new_hook = function(f, newf, usecclosure) LPH_NO_VIRTUALIZE(function()
        if usecclosure then
            local old; old = hookfunction(f, newcclosure(function(...)
                return newf(old, ...)
            end))
            cheat.hooks[f] = old
            return old
        else
            local old; old = hookfunction(f, function(...)
                return newf(old, ...)
            end)
            cheat.hooks[f] = old
            return old
        end
    end)() end
    local connection; connection = RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function(delta)
        for _, func in pairs(cheat.connections.heartbeats) do
            func(delta)
        end
    end))
    local connection1; connection1 = RunService.RenderStepped:Connect(LPH_NO_VIRTUALIZE(function(delta)
        for _, func in pairs(cheat.connections.renderstepped) do
            func(delta)
        end
    end))
    cheat.utility.unload = function()
        connection:Disconnect()
        connection1:Disconnect()
        for key, _ in pairs(cheat.connections.heartbeats) do
            cheat.connections.heartbeats[key] = nil
        end
        for key, _ in pairs(cheat.connections.renderstepped) do
            cheat.connections.heartbeats[key] = nil
        end
        for _, drawing in pairs(cheat.drawings) do
            drawing:Remove()
            cheat.drawings[_] = nil
        end
        for hooked, original in pairs(cheat.hooks) do
            if type(original) == "function" then
                hookfunction(hooked, clonefunction(original))
            else
                hookmetamethod(original["instance"], original["metamethod"], clonefunction(original["func"]))
            end
        end
    end
end
local _CFramenew = CFrame.new
local _Vector2new = Vector2.new
local _Vector3new = Vector3.new
local _IsDescendantOf = game.IsDescendantOf
local _FindFirstChild = game.FindFirstChild
local _FindFirstChildOfClass = game.FindFirstChildOfClass
local _Raycast = workspace.Raycast
local _IsKeyDown = UserInputService.IsKeyDown
local _WorldToViewportPoint = Camera.WorldToViewportPoint
local _Vector3zeromin = Vector3.zero.Min
local _Vector2zeromin = Vector2.zero.Min
local _Vector3zeromax = Vector3.zero.Max
local _Vector2zeromax = Vector2.zero.Max
local _IsA = game.IsA
local tablecreate = table.create
local mathfloor = math.floor
local mathround = math.round
local mathclamp = math.clamp
local tostring = tostring
local unpack = unpack
local getupvalues = debug.getupvalues
local getupvalue = debug.getupvalue
local setupvalue = debug.setupvalue
local getconstants = debug.getconstants
local getconstant = debug.getconstant
local setconstant = debug.setconstant
local getstack = debug.getstack
local setstack = debug.setstack
local getinfo = debug.getinfo
local rawget = rawget

local trident = {
    loaded = false,
    lastpos = nil,
    middlepart = nil,
    tcp = nil,
    original_model = nil
}
local garbage = {}
local classes = nil;
local runonactorused = false

if not (hookfunction and hookmetamethod and getgc and getupvalues and getupvalue) then return print('wtf dude...') end
LPH_JIT_MAX(function()
    for i,v in pairs(getgc(true)) do
        if type(v) == "table" then
            if type(rawget(v, "Camera")) == "table" and rawget(rawget(v, "Camera"), "type") == "Camera" then
                classes = v
            end
            if type(rawget(v, "updateCharacter")) == "function" then
                garbage.character = v
            end
            if rawget(v, "SetMaxRelativeLookExtentsY") then
                garbage.maxlooky = rawget(v, "SetMaxRelativeLookExtentsY")
            end
            if rawget(v, "GetEquippedItem") then
                --print('------------------------')
                --table.foreach(getinfo(v.GetEquippedItem), print)
                --table.foreach(v, print)
                --for _, v1 in v do if type(v) == "function" and getinfo(v1).short_src:find("FPS") then print(v1) end end
                --print(swimdump(getupvalues(v[5])[1]))
                garbage.equippeditem = rawget(v, "GetEquippedItem")
            end
            if rawget(v, "GetEntityFromPart") then
                --print(swimdump(getupvalues(v[5])[1]))
                garbage.entitylist = rawget(v, "GetEntityFromPart")
            end
            if rawget(v, "Recoil") and getinfo(rawget(v, "Recoil")).short_src:find("Camera") then
                --print(swimdump(getupvalues(v[5])[1]))
                --print('obayudno')
                garbage.recoil = rawget(v, "Recoil")
            end
        end
    end
    --[[for i,v in pairs(getgc(true)) do
        if type(v) == "table" then
            if type(rawget(v, "Camera")) == "table" and rawget(rawget(v, "Camera"), "type") == "Camera" then
                classes = v
            end
            if type(rawget(v, "updateCharacter")) == "function" then
                garbage.character = v
            end
            if table.find(v, "SetMaxRelativeLookExtentsY") then
                garbage.maxlooky = rawget(v, 5)
            end
            if table.find(v, "GetEquippedItem") then
                --print('------------------------')
                --table.foreach(getinfo(v.GetEquippedItem), print)
                --table.foreach(v, print)
                --for _, v1 in v do if type(v) == "function" and getinfo(v1).short_src:find("FPS") then print(v1) end end
                --print(swimdump(getupvalues(v[5])[1]))
                garbage.equippeditem = rawget(v, 5)
            end
            if table.find(v, "GetEntityFromPart") then
                --print(swimdump(getupvalues(v[5])[1]))
                garbage.entitylist = rawget(v, 5)
            end
            if table.find(v, "Recoil") and getinfo(rawget(v, 5)).short_src:find("Camera") then
                --print(swimdump(getupvalues(v[5])[1]))
                --print('obayudno')
                garbage.recoil = rawget(v, 5)
            end
        end
    end]]
end)()
if not (classes and garbage.character and garbage.maxlooky and garbage.equippeditem and garbage.entitylist and garbage.recoil) then
    return print("Join A server.")
end
cheat.utility.new_heartbeat(function()
    local localChar = workspace:FindFirstChild("Const")
    if localChar then
        local ignore = localChar:FindFirstChild("Ignore")
        if ignore then
            local ignoreLocal = ignore:FindFirstChild("LocalCharacter")
            if ignoreLocal then
                local top = ignoreLocal:FindFirstChild("Top")
                local middle = ignoreLocal:FindFirstChild("Middle")

                if top then
                    top.CanCollide = false
                end

                if middle then
                    middle.CanCollide = false
                end
            end
        end
    end
end)
repeat if not pcall(function()
    trident.middlepart = workspace.Const.Ignore.LocalCharacter.Middle
    trident.original_model = game:GetService("ReplicatedStorage").Shared.entities.Player.Model
    trident.tcp = LocalPlayer.TCP
    trident.udp = LocalPlayer.UDP
    trident.valid_types = {}
    trident.valid_types["Player"] = true
    for _, v in game:GetService("ReplicatedStorage").Shared.entities.NPC:GetChildren() do
        trident.valid_types[v.Name] = true
    end
end) then task.wait(0.5) end until trident.middlepart and trident.original_model and trident.tcp
cheat.Library, cheat.Toggles, cheat.Options = loadswimhubfile("library_main.lua")()
cheat.ThemeManager = loadswimhubfile("library_theme.lua")()
cheat.SaveManager = loadswimhubfile("library_save.lua")()
local ui = {
    window = cheat.Library:CreateWindow({
        Title=string.format(
            SWG_Title,
            SWG_Version,
            SWG_FullName
        ),
    Center=true,AutoShow=true,TabPadding=8})
}

ui.tabs = {
    combat = ui.window:AddTab('combat'),
    visuals = ui.window:AddTab('visuals'),
    misc = ui.window:AddTab('misc'),
    tab = ui.window:AddTab('local'),
    config = ui.window:AddTab('config'),
}
ui.box = {
    aimbot = ui.tabs.combat:AddLeftTabbox(),
    mods = ui.tabs.combat:AddRightTabbox(),
    antiaim = ui.tabs.combat:AddRightTabbox(),
    esp = ui.tabs.visuals:AddLeftTabbox(),
    cheatvis = ui.tabs.visuals:AddRightTabbox(),
    world = ui.tabs.visuals:AddRightTabbox(),
    move = ui.tabs.misc:AddLeftTabbox(),
    atvfly = ui.tabs.misc:AddLeftTabbox(),
    misc = ui.tabs.misc:AddRightTabbox(),
    themeconfig = ui.tabs.config:AddLeftGroupbox('theme config'),
}
local vectors = {
    Vector3.zero, 
    _Vector3new(0, 0, 0), 
    _Vector3new(1, 0, 0),
    _Vector3new(-1, 0, 0), 
    _Vector3new(0, 0, 1), 
    _Vector3new(0, 0, -1), 
    _Vector3new(0, 1, 0), 
    _Vector3new(0, -1, 0), 
    
    _Vector3new(1 / 2, 0, 0), 
    _Vector3new(-1 / 2, 0, 0), 
    _Vector3new(0, 0, 1 / 2), 
    _Vector3new(0, 0, -1 / 2), 
    _Vector3new(0, 1 / 2, 0), 
    _Vector3new(0, -1 / 2, 0), 

    _Vector3new(1 / 2, 1 / 2, 0), 
    _Vector3new(1 / 2, -1 / 2, 0), 
    _Vector3new(-1 / 2, 1 / 2, 0), 
    _Vector3new(-1 / 2, -1 / 2, 0), 
    _Vector3new(0, 1 / 2, 1 / 2), 
    _Vector3new(0, -1 / 2, 1 / 2), 
    _Vector3new(0, 1 / 2, -1 / 2), 
    _Vector3new(0, -1 / 2, -1 / 2), 

    _Vector3new(1 / 3, 1 / 3, 1 / 3), 
    _Vector3new(1 / 3, 1 / 3, -1 / 3), 
    _Vector3new(1 / 3, -1 / 3, 1 / 3), 
    _Vector3new(1 / 3, -1 / 3, -1 / 3), 
    _Vector3new(-1 / 3, 1 / 3, 1 / 3), 
    _Vector3new(-1 / 3, 1 / 3, -1 / 3), 
    _Vector3new(-1 / 3, -1 / 3, 1 / 3), 
    _Vector3new(-1 / 3, -1 / 3, -1 / 3), 
    
    _Vector3new(1 / 4, 1 / 4, 1 / 4), 
    _Vector3new(1 / 4, 1 / 4, -1 / 4), 
    _Vector3new(1 / 4, -1 / 4, 1 / 4), 
    _Vector3new(1 / 4, -1 / 4, -1 / 4), 
    _Vector3new(-1 / 4, 1 / 4, 1 / 4), 
    _Vector3new(-1 / 4, 1 / 4, -1 / 4), 
    _Vector3new(-1 / 4, -1 / 4, 1 / 4), 
    _Vector3new(-1 / 4, -1 / 4, -1 / 4), 
    
    _Vector3new(1 / 5, 1 / 5, 1 / 5), 
    _Vector3new(1 / 5, 1 / 5, -1 / 5), 
    _Vector3new(1 / 5, -1 / 5, 1 / 5), 
    _Vector3new(1 / 5, -1 / 5, -1 / 5), 
    _Vector3new(-1 / 5, 1 / 5, 1 / 5), 
    _Vector3new(-1 / 5, 1 / 5, -1 / 5), 
    _Vector3new(-1 / 5, -1 / 5, 1 / 5), 
    _Vector3new(-1 / 5, -1 / 5, -1 / 5), 
    
    _Vector3new(1 / 6, 1 / 6, 1 / 6), 
    _Vector3new(1 / 6, 1 / 6, -1 / 6), 
    _Vector3new(1 / 6, -1 / 6, 1 / 6), 
    _Vector3new(1 / 6, -1 / 6, -1 / 6), 
    _Vector3new(-1 / 6, 1 / 6, 1 / 6), 
    _Vector3new(-1 / 6, 1 / 6, -1 / 6), 
    _Vector3new(-1 / 6, -1 / 6, 1 / 6), 
    _Vector3new(-1 / 6, -1 / 6, -1 / 6), 
}

cheat.EspLibrary = {};
LPH_NO_VIRTUALIZE(function()
    local esp_table = {}
    local workspace = cloneref(game:GetService("Workspace"))
    local rservice = cloneref(game:GetService("RunService"))
    local plrs = cloneref(game:GetService("Players"))
    local lplr = plrs.LocalPlayer
    local container = Instance.new("Folder", game:GetService("CoreGui").RobloxGui)
    esp_table = {
        __loaded = false,
        main_settings = {
            textSize = 15,
            textFont = Drawing.Fonts.System,
            distancelimit = false,
            maxdistance = 200,
            useteamcolor = false,
            teamcheck = false,
            sleepcheck = false,
            simplecalc = false
        },
        main_object_settings = {
            textSize = 15,
            textFont = Drawing.Fonts.System,
            distancelimit = false,
            maxdistance = 200,
            useteamcolor = false,
            teamcheck = false,
            sleepcheck = false,
            allowed = {}
        },
        settings = {
            enemy = {
                enabled = false,
    
                box = false,
                box_fill = false,
                realname = false,
                dist = false,
                weapon = false,
                skeleton = false,
    
                box_outline = false,
                realname_outline = false,
                dist_outline = false,
                weapon_outline = false,
    
                box_color = { Color3.new(1, 1, 1), 1 },
                box_fill_color = { Color3.new(1, 0, 0), 0.3 },
                realname_color = { Color3.new(1, 1, 1), 1 },
                dist_color = { Color3.new(1, 1, 1), 1 },
                weapon_color = { Color3.new(1, 1, 1), 1 },
                skeleton_color = { Color3.new(1, 1, 1), 1 },
    
                box_outline_color = { Color3.new(), 1 },
                realname_outline_color = Color3.new(),
                dist_outline_color = Color3.new(),
                weapon_outline_color = Color3.new(),
    
                chams = false,
                chams_visible_only = false,
                chams_fill_color = { Color3.new(1, 1, 1), 0.5 },
                chamsoutline_color = { Color3.new(1, 1, 1), 0 }
            },
            object = {
                enabled = false,
                allenabled = false,

                realname = false,
                realname_outline = false,

                realname_color = { Color3.new(1, 1, 1), 1 },
                realname_outline_color = Color3.new(),

                chams = false,
                chams_visible_only = false,
                chams_fill_color = { Color3.new(1, 1, 1), 0.5 },
                chamsoutline_color = { Color3.new(1, 1, 1), 0 }
            }
        }
    }
    local loaded_plrs = {}
    
    local camera = workspace.CurrentCamera

    
    local VERTICES = {
        _Vector3new(-1, -1, -1),
        _Vector3new(-1, 1, -1),
        _Vector3new(-1, 1, 1),
        _Vector3new(-1, -1, 1),
        _Vector3new(1, -1, -1),
        _Vector3new(1, 1, -1),
        _Vector3new(1, 1, 1),
        _Vector3new(1, -1, 1)
    }
    local skeleton_order = {
        ["LeftFoot"] = "LeftLowerLeg",
        ["LeftLowerLeg"] = "LeftUpperLeg",
        ["LeftUpperLeg"] = "LowerTorso",
    
        ["RightFoot"] = "RightLowerLeg",
        ["RightLowerLeg"] = "RightUpperLeg",
        ["RightUpperLeg"] = "LowerTorso",
    
        ["LeftHand"] = "LeftLowerArm",
        ["LeftLowerArm"] = "LeftUpperArm",
        ["LeftUpperArm"] = "Torso",
    
        ["RightHand"] = "RightLowerArm",
        ["RightLowerArm"] = "RightUpperArm",
        ["RightUpperArm"] = "Torso",
    
        ["LowerTorso"] = "Torso",
        ["Torso"] = "Head"
    }
    
    local player_memory = {}
    
    local function getcurrentweapon(entity)
        
        local gun = "None"
        if type(entity) == "table" and type(rawget(entity, "equippedItem")) == "table" then
            return rawget(rawget(entity, "equippedItem"), "type")
        end
        return gun
    end
    
    local esp = {}
    esp.create_obj = function(type, args)
        local obj = Drawing.new(type)
        for i, v in args do
            obj[i] = v
        end
        return obj
    end
    local function isBodyPart(name)
        return name == "Head" or name:find("Torso") or name:find("Leg") or name:find("Arm")
    end
    local function getBoundingBox(parts)
        local min, max
        for i = 1, #parts do
            local part = parts[i]
            local cframe, size = part.CFrame, part.Size
    
            min = _Vector3zeromin(min or cframe.Position, (cframe - size * 0.5).Position)
            max = _Vector3zeromax(max or cframe.Position, (cframe + size * 0.5).Position)
        end
    
        local center = (min + max) * 0.5
        local front = _Vector3new(center.X, center.Y, max.Z)
        return _CFramenew(center, front), max - min
    end
    local function worldToScreen(world)
        local screen, inBounds = _WorldToViewportPoint(camera, world)
        return _Vector2new(screen.X, screen.Y), inBounds, screen.Z
    end
    
    local function calculateCorners(cframe, size)
        local corners = tablecreate(#VERTICES)
        for i = 1, #VERTICES do
            corners[i] = worldToScreen((cframe + size * 0.5 * VERTICES[i]).Position)
        end
    
        local min = _Vector2zeromin(camera.ViewportSize, unpack(corners))
        local max = _Vector2zeromax(Vector2.zero, unpack(corners))
        return {
            corners = corners,
            topLeft = _Vector2new(mathfloor(min.X), mathfloor(min.Y)),
            topRight = _Vector2new(mathfloor(max.X), mathfloor(min.Y)),
            bottomLeft = _Vector2new(mathfloor(min.X), mathfloor(max.Y)),
            bottomRight = _Vector2new(mathfloor(max.X), mathfloor(max.Y))
        }
    end

    local function calculateCornersSimple(head, hrp)
        
        local head_position = worldToScreen(head.Position - Vector3.yAxis * 0.5)
        local leg_position = worldToScreen(hrp.Position - Vector3.yAxis * 3.5)
        local headx, heady = head_position.X, head_position.Y
        local legx, legy = leg_position.X, leg_position.Y
        local height = legy - heady;
        local width = height / 3.6
        return {
            topLeft = _Vector2new(headx - width, heady),
            topRight = _Vector2new(headx - width, legy),
            bottomLeft = _Vector2new(headx + width, heady),
            bottomRight =_Vector2new(headx + width, legy)
        }
    end

    local enttiyidentification = {}
    for i, v in game:GetService("ReplicatedStorage").Shared.entities:GetChildren() do
        local model = _FindFirstChild(v, "Model")
        if model and model.PrimaryPart then
            enttiyidentification[v.Name] = {
                CollisionGroup = model.PrimaryPart.CollisionGroup,
                Material = model.PrimaryPart.Material,
                Color = model.PrimaryPart.Color
            }
        end
    end
    local function identify_model(model)
        if model.ClassName ~= "Model" then return false, false end
        if _FindFirstChildOfClass(model, "MeshPart") and _FindFirstChildOfClass(model, "MeshPart").MeshId == "rbxassetid://12939036056" then
            if #model:GetChildren() == 1 then
                return "Stone", model:GetChildren()[1]
            else
                for _, part in model:GetChildren() do
                    if part.Color == Color3.fromRGB(248, 248, 248) then
                        return "Nitrate", part
                    elseif part.Color == Color3.fromRGB(199, 172, 120) then
                        return "Iron", part
                    end
                end
            end
        end
        if not model.PrimaryPart then return end
        local primpart = model.PrimaryPart
        for name, entity in enttiyidentification do
            if entity.Color == primpart.Color and entity.Material == primpart.Material and entity.CollisionGroup == primpart.CollisionGroup then
                return name, primpart
            end
        end
        return false, false
    end

    
    local function create_esp(model)
        if model and _FindFirstChild(model, "Head") and _FindFirstChild(model, "LowerTorso") then
            local entity;
            repeat
                for _, ent in getupvalue(garbage.entitylist, 1) do
                    if rawget(ent, "model") == model then
                        entity = ent
                        break
                    end
                end
                if not entity then task.wait(.1) end
            until entity
            
            local entity_type = rawget(entity, "type")
            local entity_id = rawget(entity, "id")

            local settings = esp_table.settings.enemy
            loaded_plrs[model] = {
                obj = {
                    box_fill = esp.create_obj("Square", { Filled = true, Visible = false }),
                    box_outline = esp.create_obj("Square", { Filled = false, Thickness = 3, Visible = false, ZIndex = -1}),
                    box = esp.create_obj("Square", { Filled = false, Thickness = 1, Visible = false }),
                    realname = esp.create_obj("Text", { Center = true, Visible = false }),
                    dist = esp.create_obj("Text", { Center = true, Visible = false }),
                    weapon = esp.create_obj("Text", { Center = true, Visible = false }),
                },
                esp = {
                    current_gun = "",
                    corners = nil,
                    head = nil,
                    character = nil
                },
                chams_object = Instance.new("Highlight", container),
            }
            for required, _ in next, skeleton_order do
                loaded_plrs[model].obj["skeleton_" .. required] = esp.create_obj("Line", { Visible = false })
            end

            local character = model
            local head = _FindFirstChild(character, "Head")
            local lowertorso = _FindFirstChild(character, "LowerTorso")


            local plr = loaded_plrs[model]
            local obj = plr.obj

            local cham = plr.chams_object
            local box = obj.box
            local box_outline = obj.box_outline
            local box_fill = obj.box_fill
            local realname = obj.realname
            local dist = obj.dist
            local weapon = obj.weapon

            local main_settings = esp_table.main_settings
            local settings = esp_table.settings.enemy

            local setvis_cache = false

            function plr:forceupdate()
                cham.DepthMode = settings.chams_visible_only and Enum.HighlightDepthMode.Occluded or not settings.chams_visible_only and Enum.HighlightDepthMode.AlwaysOnTop 
                cham.FillColor = settings.chams_fill_color[1]
                cham.FillTransparency = settings.chams_fill_color[2]
                cham.OutlineColor = settings.chamsoutline_color[1]
                cham.OutlineTransparency = settings.chamsoutline_color[2]

                box.Transparency = settings.box_color[2]
                box.Color = settings.box_color[1]
                box_outline.Transparency = settings.box_outline_color[2]
                box_outline.Color = settings.box_outline_color[1]
                box_fill.Color = settings.box_fill_color[1]
                box_fill.Transparency = settings.box_fill_color[2]

                realname.Size = main_settings.textSize
                realname.Font = main_settings.textFont
                realname.Color = settings.realname_color[1]
                realname.Outline = settings.realname_outline
                realname.OutlineColor = settings.realname_outline_color
                realname.Transparency = settings.realname_color[2]

                dist.Size = main_settings.textSize
                dist.Font = main_settings.textFont
                dist.Color = settings.dist_color[1]
                dist.Outline = settings.dist_outline
                dist.OutlineColor = settings.dist_outline_color
                dist.Transparency = settings.dist_color[2]

                weapon.Size = main_settings.textSize
                weapon.Font = main_settings.textFont
                weapon.Color = settings.weapon_color[1]
                weapon.Outline = settings.weapon_outline
                weapon.OutlineColor = settings.weapon_outline_color
                weapon.Transparency = settings.weapon_color[2]

                for required, _ in next, skeleton_order do
                    local skeletonobj = obj["skeleton_" .. required]
                    if (skeletonobj) then
                        skeletonobj.Color = settings.skeleton_color[1]
                        skeletonobj.Transparency = settings.skeleton_color[2]
                    end
                end

                if setvis_cache then
                    cham.Enabled = settings.chams
                    box.Visible = settings.box
                    box_outline.Visible = settings.box_outline
                    box_fill.Visible = settings.box_fill
                    realname.Visible = settings.realname
                    dist.Visible = settings.dist
                    weapon.Visible = settings.weapon
                    for required, _ in next, skeleton_order do
                        local skeletonobj = obj["skeleton_" .. required]
                        if (skeletonobj) then
                            skeletonobj.Visible = settings.skeleton
                        end
                    end
                end
            end

            function plr:togglevis(bool)
                if setvis_cache ~= bool then
                    setvis_cache = bool
                    if not bool then
                        for _, v in obj do v.Visible = false end
                        cham.Enabled = false
                    else
                        cham.Enabled = settings.chams
                        box.Visible = settings.box
                        box_outline.Visible = settings.box_outline
                        box_fill.Visible = settings.box_fill
                        realname.Visible = settings.realname
                        dist.Visible = settings.dist
                        weapon.Visible = settings.weapon
                        for required, _ in next, skeleton_order do
                            local skeletonobj = obj["skeleton_" .. required]
                            if (skeletonobj) then
                                skeletonobj.Visible = settings.skeleton
                            end
                        end
                    end
                end
            end

            plr.connection = cheat.utility.new_renderstepped(function(delta)
                if not (
                    settings.enabled and
                    head and
                    character and
                    (
                        main_settings.sleepcheck and
                        not rawget(entity, "sleeping") or
                        not main_settings.sleepcheck
                    )
                ) then
                    return plr:togglevis(false)
                end
                local _, onScreen = worldToScreen(head.Position)
                if not onScreen then
                    return plr:togglevis(false)
                end

                local distance = (camera.CFrame.p - head.Position).Magnitude

                local corners if main_settings.simplecalc then
                    corners = calculateCornersSimple(head, lowertorso)
                else
                    local cache = {}
                    local children = character:GetChildren()
                    for i = 1, #children do
                        local part = children[i]
                        if _IsA(part, "BasePart") and isBodyPart(part.Name) then
                            cache[#cache + 1] = part
                        end
                    end
                    corners = calculateCorners(getBoundingBox(cache))
                end

                if not corners then
                    return plr:togglevis(false)
                end

                plr:togglevis(true)

                cham.Adornee = character
                do
                    local pos = corners.topLeft
                    local size = corners.bottomRight - corners.topLeft
                    box.Position = pos
                    box.Size = size
                    if getgenv().DrawingFix then
                        box_outline.Position = pos - _Vector2new(1, 1)
                        box_outline.Size = size + _Vector2new(2, 2)
                    else
                        box_outline.Position = pos
                        box_outline.Size = size
                    end
                    box_fill.Position = pos
                    box_fill.Size = size
                end

                do
                    local entity_name = rawget(entity, "Name")
                    realname.Text = player_memory[entity_id] or entity_name or entity_type
                    if entity_type == "Player" and entity_name then
                        player_memory[entity_id] = entity_name
                    end
                    realname.Position = (corners.topLeft + corners.topRight) * 0.5 -
                        Vector2.yAxis * realname.TextBounds.Y - _Vector2new(0, 2)
                end

                do
                    local bottom = (corners.bottomLeft + corners.bottomRight) * 0.5
                    dist.Text = tostring(mathround(distance)) .. " studs"
                    dist.Position = bottom
                    weapon.Text = getcurrentweapon(entity)
                    weapon.Position = bottom + (dist.Visible and Vector2.yAxis * dist.TextBounds.Y - _Vector2new(0, 2) or Vector2.zero)
                end

                if settings.skeleton then
                    for _, part in next, character:GetChildren() do
                        local part_name = part.Name
                        local skeletonobj = obj["skeleton_" .. part_name]
                        local parent_part = skeleton_order[part_name] and _FindFirstChild(character, skeleton_order[part_name])
                        if skeletonobj and parent_part then
                            local part_position, _ = _WorldToViewportPoint(camera, part.Position)
                            local parent_part_position, _ = _WorldToViewportPoint(
                                camera, parent_part.CFrame.p
                            )
                            skeletonobj.From = _Vector2new(part_position.X, part_position.Y)
                            skeletonobj.To = _Vector2new(parent_part_position.X, parent_part_position.Y)
                        end
                    end
                end
            end)

            plr:forceupdate()
        else
            local espname, mainpart = identify_model(model)
            if not (espname and mainpart) then return end
            loaded_plrs[model] = {
                obj = {
                    name = esp.create_obj("Text", { Center = true, Visible = false, Text = espname }),
                }
            }
            local plr = loaded_plrs[model]
            local obj = plr.obj

            local realname = obj.name

            local main_settings = esp_table.main_object_settings
            local settings = esp_table.settings.object
            local allowedobjs = main_settings.allowed

            local setvis_cache = false

            function plr:forceupdate()
                realname.Size = main_settings.textSize
                realname.Font = main_settings.textFont
                realname.Color = settings.realname_color[1]
                realname.Outline = settings.realname_outline
                realname.OutlineColor = settings.realname_outline_color
                realname.Transparency = settings.realname_color[2]
            end

            function plr:togglevis(bool)
                if setvis_cache ~= bool then
                    for _, v in obj do v.Visible = bool end
                    setvis_cache = bool
                end
            end

            plr.connection = cheat.utility.new_heartbeat(function(delta)
                local plr = loaded_plrs[model]
                if not (settings.enabled and mainpart and (settings.allenabled or allowedobjs[espname])) then
                    return plr:togglevis(false)
                end
                local position, onscreen = worldToScreen(mainpart.Position)
                if not onscreen then
                    return plr:togglevis(false)
                end
                plr:togglevis(true)
                realname.Position = position
            end)

            plr:forceupdate()
        end
    end
    local function destroy_esp(model)
        local plr_object = loaded_plrs[model]
        if not plr_object then return end
        plr_object.connection:Disconnect()
        for i, v in plr_object.obj do
            v:Remove()
        end
        if plr_object.chams_object then
            plr_object.chams_object:Destroy()
        end
        loaded_plrs[model] = nil
    end
    
    function esp_table.load()
        assert(not esp_table.__loaded, "[ESP] already loaded");
    
        for i, v in next, workspace:GetChildren() do
           create_esp(v)
        end
    
        esp_table.playerAdded = workspace.ChildAdded:Connect(create_esp);
        esp_table.playerRemoving = workspace.ChildRemoved:Connect(destroy_esp);
        esp_table.__loaded = true;
    end
    
    function esp_table.unload()
        assert(esp_table.__loaded, "[ESP] not loaded yet");
    
        for i, v in next, workspace:GetChildren() do
            destroy_esp(v)
        end
    
        esp_table.playerAdded:Disconnect();
        esp_table.playerRemoving:Disconnect();
        esp_table.__loaded = false;
    end
    
    function esp_table.icaca()
        for _, v in loaded_plrs do
            task.spawn(function() v:forceupdate() end)
        end
    end

    cheat.EspLibrary = esp_table
end)();

local vischeck_params = RaycastParams.new()
vischeck_params.FilterDescendantsInstances = { workspace.Const.Ignore }
vischeck_params.FilterType = Enum.RaycastFilterType.Exclude
vischeck_params.CollisionGroup = "WeaponRaycast"
vischeck_params.IgnoreWater = true

local function is_visible(position, target, target_part)
    if not (target and target_part and position) then return false end
    local castresults = _Raycast(workspace, position, target_part.CFrame.p - position, vischeck_params)
    return castresults and castresults.Instance and castresults.Instance.Parent == target
end

local function is_position_visible(pos_from, pos_to)
    if not (pos_to and pos_from) then return false end
    local castresults = _Raycast(workspace, pos_from, pos_to - pos_from, vischeck_params)
    return not castresults
end


local function predict_entity(part, entity, projectile_speed, projectile_drop, origin)
    local part_cframe = part.CFrame
    local velocity = (rawget(entity, "goalPosition") - rawget(entity, "startPosition")) / 0.15 * _Vector3new(1, 0, 1)
    local distance = (origin - part_cframe.Position).Magnitude
    local time_to_hit = (distance / projectile_speed)
    local predicted_position = part_cframe.Position + (velocity * time_to_hit)
    local delta = (predicted_position - part_cframe.Position).Magnitude
    time_to_hit = time_to_hit + (delta / projectile_speed)
    return predicted_position + Vector3.yAxis * (projectile_drop ^ (time_to_hit * projectile_drop) - 1)
end
local function get_actual_hitpos(projectile_speed, projectile_drop, origin, position)
    local distance = (origin - position).Magnitude
    local time_to_hit = (distance / projectile_speed)
    local drop_distance = projectile_drop ^ (time_to_hit * projectile_drop) - 1
    local look_vector = CFrame.lookAt(origin, position + Vector3.yAxis * drop_distance)
    return look_vector, (look_vector * _CFramenew(0, -projectile_drop ^ (time_to_hit * projectile_drop) + 1, -time_to_hit * projectile_speed)).Position
end
local function predict_drop_position(position, projectile_speed, projectile_drop, origin)
    local origin = origin or Camera.CFrame.p
    local distance = (origin - position).Magnitude
    local time_to_hit = (distance / projectile_speed)
    local drop_timing = projectile_drop ^ (time_to_hit * projectile_drop) - 1
    if not (drop_timing ~= drop_timing) then
        return drop_timing, time_to_hit
    end
    return 0
end
local function get_manipulation_pos(origin_pos, target, target_part, range, enabled)
    if not origin_pos then origin_pos = Camera.CFrame.p end
    if not enabled then
        local visible = is_visible(origin_pos, target, target_part)
        if visible then
            return origin_pos
        end
    end
    local final, maxmag = nil, math.huge;
    for _, vector in vectors do
        local curvector = (vector * range)
        local modified = origin_pos + curvector
        local posvisible, visible = is_position_visible(origin_pos, modified), is_visible(modified, target, target_part)
        if curvector.Magnitude <= maxmag and posvisible and visible then
            final = modified
            maxmag = curvector.Magnitude
        end
    end
    return final
end
local function get_simulation_pos(origin_pos, target, target_part, simtable, projectile_speed, projectile_drop) -- сделать по дуге 
    local final, maxmag = nil, math.huge
    task.spawn(function()
        for i = 1, #simtable do
            local vector = simtable[i]
            local modified = targetpos + vector
            local distance = (origin_pos - modified).Magnitude
            local visible = is_visible(modified, target, target_part)

            if visible then
                local posvisible = is_position_visible(origin_pos, modified)
                if posvisible and distance < maxmag then
                    final = modified
                    maxmag = distance
                end
            end
        end
    end)

    return final
end
local function get_closest_target(usefov, fov_size, aimpart, sleep, team)
    local part, entity = nil, nil
    local maximum_distance = usefov and fov_size or math.huge
    local mousepos = _Vector2new(Mouse.X, Mouse.Y)
    local valid_types = trident.valid_types
    LPH_JIT_MAX(function()
        for _, tbl in getupvalue(garbage.entitylist, 1) do
            local model = rawget(tbl, "model")
            local enttype = rawget(tbl, "type")
            local sleeping = rawget(tbl, "sleeping")
            local hitpart = model and _FindFirstChild(model, aimpart)
            if (hitpart and valid_types[enttype]) and (sleep and not sleeping or not sleep) then
                local position, onscreen = _WorldToViewportPoint(Camera, hitpart.Position)
                local distance = (_Vector2new(position.X, position.Y - GuiInset.Y) - mousepos).Magnitude
                if (usefov and onscreen or not usefov) and distance < maximum_distance then
                    part = hitpart
                    entity = tbl
                    maximum_distance = distance
                end
            end
        end
    end)()
    return part, entity
end
local function make_beam(Origin, Position, Color)
    local part1, part2 = Instance.new("Part", workspace.Const.Ignore), Instance.new("Part", workspace.Const.Ignore)
    part1.Position = Origin; part2.Position = Position;
    part1.Transparency = 1; part2.Transparency = 1;
    part1.CanCollide = false; part2.CanCollide = false;
    part1.Size = Vector3.zero; part2.Size = Vector3.zero;
    part1.Anchored = true; part2.Anchored = true;
    local OriginAttachment = Instance.new("Attachment", part1)
    local PositionAttachment = Instance.new("Attachment", part2)
    local Beam = Instance.new("Beam", workspace.Const.Ignore)
    Beam.Name = "Beam"
    Beam.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0,Color),
        ColorSequenceKeypoint.new(1,Color)
    };
    Beam.LightEmission = 1
    Beam.LightInfluence = 1
    Beam.TextureMode = Enum.TextureMode.Static
    Beam.TextureSpeed = 0
    Beam.Transparency = NumberSequence.new(0)
    Beam.Attachment0 = OriginAttachment
    Beam.Attachment1 = PositionAttachment
    Beam.FaceCamera = true
    Beam.Segments = 1
    Beam.Width0 = 0.1
    Beam.Width1 = 0.1
    return Beam, part1, part2
end
local function make_beam_drawing(Origin, Position, Color)
    local part1, part2 = Instance.new("Part", workspace.Const.Ignore), Instance.new("Part", workspace.Const.Ignore)
    part1.Position = Origin; part2.Position = Position;
    part1.Transparency = 1; part2.Transparency = 1;
    part1.CanCollide = false; part2.CanCollide = false;
    part1.Size = Vector3.zero; part2.Size = Vector3.zero;
    part1.Anchored = true; part2.Anchored = true;
    local OriginAttachment = Instance.new("Attachment", part1)
    local PositionAttachment = Instance.new("Attachment", part2)
    local Beam = Instance.new("Beam", workspace.Const.Ignore)
    Beam.Name = "Beam"
    Beam.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0,Color),
        ColorSequenceKeypoint.new(1,Color)
    };
    Beam.LightEmission = 1
    Beam.LightInfluence = 1
    Beam.TextureMode = Enum.TextureMode.Static
    Beam.TextureSpeed = 0
    Beam.Transparency = NumberSequence.new(0)
    Beam.Attachment0 = OriginAttachment
    Beam.Attachment1 = PositionAttachment
    Beam.FaceCamera = true
    Beam.Segments = 1
    Beam.Width0 = 0.1
    Beam.Width1 = 0.1
    return Beam, part1, part2
end
local function create_cool_beam(pos1, pos2, color, rainbow)
    LPH_JIT_MAX(function()
        local drawing, deleteme, deleteme1;
        local real_sigma, fakeerror = pcall(function()
            drawing, deleteme, deleteme1 = make_beam(pos1, pos2, color)
        end)
        if not real_sigma then
            return print(fakeerror)
        end
        local wtf = -1
        local conn; conn = cheat.utility.new_renderstepped(function(delta)
            wtf = wtf + delta
            drawing.Transparency = NumberSequence.new(math.clamp(wtf, 0, 1))
            if rainbow then
                drawing.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromHSV(wtf % 1, 1, 1)),
                    ColorSequenceKeypoint.new(1, Color3.fromHSV(wtf % 1, 1, 1))
                }
            end
            if wtf >= 1 then
                drawing:Destroy()
                deleteme:Destroy()
                deleteme1:Destroy()
                conn:Disconnect()
            end
        end)
    end)()
end
local function visualize_bullet_path(cframedir, position, projectile_speed, projectile_drop, color, rainbow)
    local distance = (cframedir.p - position).Magnitude
    local time_to_hit = (distance / projectile_speed)
    LPH_JIT_MAX(function()
        local newpos = cframedir.p
        local predictions = math.ceil(distance/10)
        if predictions == 0 then return end
        for i=1,predictions do
            local new_time = (i/predictions)*time_to_hit
            local oldpos = newpos
            local newpos1 = (cframedir * _CFramenew(0, -projectile_drop ^ (new_time * projectile_drop) + 1, -new_time * projectile_speed)).Position
            newpos = newpos1
            
            local drawing, deleteme, deleteme1;
            local real_sigma, fakeerror = pcall(function()
                drawing, deleteme, deleteme1 = make_beam(oldpos, newpos1, color)
            end)
            if not real_sigma then
                return print(fakeerror)
            end
            local wtf = -1
            local conn; conn = cheat.utility.new_renderstepped(function(delta)
                wtf = wtf + delta
                new_time = new_time + delta
                drawing.Transparency = NumberSequence.new(math.clamp(wtf, 0, 1))
                if rainbow then
                    drawing.Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, Color3.fromHSV(new_time / 2 % 1, 1, 1)),
                        ColorSequenceKeypoint.new(1, Color3.fromHSV(new_time / 2 % 1, 1, 1))
                    }
                end
                if wtf >= 1 then
                    drawing:Destroy()
                    deleteme:Destroy()
                    deleteme1:Destroy()
                    conn:Disconnect()
                end
            end)
        end
    end)()
end


local modulecomm = {
    enabled = false,
    resolver = false,
    camera = false,
    silent = false,
    sleep_check = false,
    team_check = false,
    part = "Head",
    manipulation = false,
    manipulation_range = 5,
    fov = false,
    fov_show = false,
    fov_color = Color3.new(1, 1, 1),
    fov_outline = false,
    fov_outline_color = Color3.new(0, 0, 0),
    fov_size = 100,
    indicator = false,
    indicator_text = "",
    godmode = false,
    snaplines = false,
    snaplines_color = Color3.new(1, 1, 1),
    snaplines_from = "center",
    jumpshoot = false,
    noslowdown = false,
    nospread = false,
    forcehead = false,
    invis = false,
    mathhuge = false,
    hitboxes = false,
    hbbypass = false,
    instant = false,
    fly = false,
    silentwalk = false,
    downhill = false,
    velobreak = false,
    velobreakstrenght = 6,
    infiniteregister = false,
    simulation = false,
    simulation_time = "simple",
    simulation_table = {},
    target = {},
    antiaim = {
        antiaim = false,
        antiaimyaw = "none", 
        antiaimpitch = "none", 
        spinspeed = 0.1,
        backwards = false,
        yawoffset = 0,
        yawjittersize = 0,
        pitchjittersize = 0,
        pitchcustom = 0,
        yawrandomspeed = 1,
        pitchrandomspeed = 1,

        car = false,
        cartripmode = "side", 
        caryaw = "none", 
        carspinspeed = 0.1,
        cartriprandomspeed = 1,
        caryawrandomspeed = 1,
    },
}
do
    local norecoil = false
    local target_part, target_entity, manipulation_pos;
    local extremeresolver, resolver = false, false
    local salobox = ui.box.aimbot:AddTab('aimbotzz')
    local gunmodbox = ui.box.mods:AddTab('gun mods')
    local aabox = ui.box.antiaim:AddTab('antiaim')
do
    local aaset = modulecomm.antiaim
    aabox:AddToggle('antiaim_enabled', {Text = 'antiaim', Default = false, Callback = function(first)
        aaset.antiaim = first
    end}):AddKeyPicker('antiaimbind', {Default = 'None', SyncToggleState = true, Mode = 'Toggle', Text = 'antiaim', NoUI = false})

    aabox:AddDropdown('antiaim_yaw', {Values = {"none", "spin", "static", "jitter", "invisible", "invisible2", "random", "custom"}, Default = 1, Multi = false, Text = 'yaw modifier', Callback = function(Value)
        aaset.antiaimyaw = Value
    end})

    aabox:AddDropdown('antiaim_pitch', {Values = {"none", "down", "up", "jitter", "random", "custom"}, Default = 1, Multi = false, Text = 'pitch modifier', Callback = function(Value)
        aaset.antiaimpitch = Value
    end})

    
    
    do
        local aadepbox = aabox:AddDependencyBox()
        aadepbox:AddSlider('antiaim_spinspeed', {Text = 'spin speed (rpm)', Default = 60, Min = 60, Max = 360, Rounding = 0, Compact = true, Callback = function(State)
            aaset.spinspeed = State
        end})
        aadepbox:SetupDependencies({
            { cheat.Options.antiaim_yaw, "spin" }
        })
    end

    
    do
        local aadepbox = aabox:AddDependencyBox()
        aadepbox:AddSlider('antiaim_jittersize', {Text = 'yaw jitter (d)', Default = 45, Min = 0, Max = 180, Rounding = 0, Compact = true, Callback = function(State)
            aaset.yawjittersize = State
        end})
        aadepbox:SetupDependencies({
            { cheat.Options.antiaim_yaw, "jitter" }
        })
    end

    
    do
        local aadepbox = aabox:AddDependencyBox()
        aadepbox:AddToggle('antiaim_backwards', {Text = 'backwards', Default = false, Callback = function(Value)
            aaset.backwards = Value
        end})
        aadepbox:AddSlider('antiaim_yawoffset', {Text = 'yaw offset', Default = 0, Min = -90, Max = 90, Rounding = 0, Compact = true, Callback = function(State)
            aaset.yawoffset = State
        end})
        aadepbox:SetupDependencies({
            { cheat.Options.antiaim_yaw, "static" },
            { cheat.Options.antiaim_yaw, "jitter" }
        })
    end

    
    do
        local aadepbox = aabox:AddDependencyBox()
        aadepbox:AddSlider('antiaim_customyaw', {Text = 'custom yaw (-360-360)', Default = 0, Min = -360, Max = 360, Rounding = 0, Compact = true, Callback = function(State)
            aaset.customyaw = State
        end})
        aadepbox:SetupDependencies({
            { cheat.Options.antiaim_yaw, "custom" }
        })
    end

    
    
    do
        local aadepbox = aabox:AddDependencyBox()
        aadepbox:AddSlider('antiaim_pitchjittersize', {Text = 'pitch jitter', Default = 90, Min = 0, Max = 90, Rounding = 0, Compact = true, Callback = function(State)
            aaset.pitchjittersize = State
        end})
        aadepbox:SetupDependencies({
            { cheat.Options.antiaim_pitch, "jitter" }
        })
    end

    
    do
        local aadepbox = aabox:AddDependencyBox()
        aadepbox:AddSlider('antiaim_custompitch', {Text = 'pitch (-90=down, 90=up)', Default = 0, Min = -90, Max = 90, Rounding = 0, Compact = true, Callback = function(State)
            aaset.pitchcustom = State
        end})
        aadepbox:SetupDependencies({
            { cheat.Options.antiaim_pitch, "custom" }
        })
    end

    
    
    do
        local aadepbox = aabox:AddDependencyBox()
        aadepbox:AddSlider('antiaim_yaw_random_speed', {Text = 'yaw random speed', Default = 1, Min = 0.1, Max = 50, Rounding = 1, Compact = true, Callback = function(State)
            aaset.yawrandomspeed = State
        end})
        aadepbox:SetupDependencies({
            { cheat.Options.antiaim_yaw, "random" }
        })
    end

    
    
    do
        local aadepbox = aabox:AddDependencyBox()
        aadepbox:AddSlider('antiaim_pitch_random_speed', {Text = 'pitch random speed', Default = 1, Min = 0.1, Max = 50, Rounding = 1, Compact = true, Callback = function(State)
            aaset.pitchrandomspeed = State
        end})
        aadepbox:SetupDependencies({
            { cheat.Options.antiaim_pitch, "random" }
        })
    end
end
    gunmodbox:AddToggle('gunmods_norecoil',{Text='no recoil',Default=false,Callback=function(state)
    for _,v in ipairs(getgc(true))do
        if typeof(v)=='table'then
            if rawget(v,'recoilOffset')then v.recoilOffset=CFrame.new()v.recoilLerpSpeed=0 v.recoilReturnSpeed=0 end
            if rawget(v,'AimRecoil')then for k in pairs(v.AimRecoil)do v.AimRecoil[k]=0 end end
            if rawget(v,'HipRecoil')then for k in pairs(v.HipRecoil)do v.HipRecoil[k]=0 end end
            if rawget(v,'RecoilData')then for k in pairs(v.RecoilData)do v.RecoilData[k]=0 end end
        end
    end
    end})
    gunmodbox:AddToggle('gunmods_jumpshoot', {Text = 'jump shoot',Default = false,Tooltip = 'Allows shooting while jumping',Callback = function(first)
        modulecomm.jumpshoot = first
    end})

    
    




local originalAutoShootValues = {}
local originalSpreadValues = {}
local originalInfiniteRangeValues = {}
local originalReloadTimeValues = {}
local originalEquipTimeValues = {}

gunmodbox:AddToggle('gunmods_autoshoot', {Text = 'auto shoot', Default = false, Tooltip = 'Enables auto shoot', Callback = function(first)
    for i, v in pairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "Damage") then
            local fireActionKey = nil
            for key, value in pairs(v) do
                if string.find(string.lower(tostring(key)), "fire") and 
                   (string.find(string.lower(tostring(key)), "action") or 
                    string.find(string.lower(tostring(key)), "mode")) then
                    fireActionKey = key
                end
            end
            if fireActionKey then
                if first then
                    
                    if not originalAutoShootValues[v] then
                        originalAutoShootValues[v] = {}
                    end
                    if originalAutoShootValues[v][fireActionKey] == nil then
                        originalAutoShootValues[v][fireActionKey] = rawget(v, fireActionKey)
                    end
                    
                    rawset(v, fireActionKey, "auto")
                else
                    
                    if originalAutoShootValues[v] and originalAutoShootValues[v][fireActionKey] ~= nil then
                        rawset(v, fireActionKey, originalAutoShootValues[v][fireActionKey])
                        originalAutoShootValues[v][fireActionKey] = nil
                    end
                end
            end
        end
    end
end})

gunmodbox:AddToggle('gunmods_nospread', {Text = 'no spread', Default = false, Tooltip = 'Removes spread', Callback = function(first)
    for i, v in pairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "Damage") then
            local accuracyKey = nil
            for key, value in pairs(v) do
                if string.find(string.lower(tostring(key)), "accuracy") then
                    accuracyKey = key
                end
            end
            if accuracyKey then
                if first then
                    
                    if not originalSpreadValues[v] then
                        originalSpreadValues[v] = {}
                    end
                    if originalSpreadValues[v][accuracyKey] == nil then
                        originalSpreadValues[v][accuracyKey] = rawget(v, accuracyKey)
                    end
                    
                    rawset(v, accuracyKey, math.huge)
                else
                    
                    if originalSpreadValues[v] and originalSpreadValues[v][accuracyKey] ~= nil then
                        rawset(v, accuracyKey, originalSpreadValues[v][accuracyKey])
                        originalSpreadValues[v][accuracyKey] = nil
                    end
                end
            end
        end
    end
end})

--[[gunmodbox:AddToggle('gunmods_infrange', {Text = 'inf range', Default = false, Tooltip = 'Enables infinite range', Callback = function(first)
    for i, v in pairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "Damage") then
            local projectLiveDropKey = nil
            for key, value in pairs(v) do
                if string.find(string.lower(tostring(key)), "projectile") and 
                   string.find(string.lower(tostring(key)), "drop") then
                    projectLiveDropKey = key
                end
            end
            if projectLiveDropKey then
                if first then
                    
                    if not originalInfiniteRangeValues[v] then
                        originalInfiniteRangeValues[v] = {}
                    end
                    if originalInfiniteRangeValues[v][projectLiveDropKey] == nil then
                        originalInfiniteRangeValues[v][projectLiveDropKey] = rawget(v, projectLiveDropKey)
                    end
                    
                    rawset(v, projectLiveDropKey, 0)
                else
                    
                    if originalInfiniteRangeValues[v] and originalInfiniteRangeValues[v][projectLiveDropKey] ~= nil then
                        rawset(v, projectLiveDropKey, originalInfiniteRangeValues[v][projectLiveDropKey])
                        originalInfiniteRangeValues[v][projectLiveDropKey] = nil
                    end
                end
            end
        end
    end
end})]]

--[[gunmodbox:AddToggle('gunmods_noreloadanimation', {Text = 'no reload animation', Default = false, Tooltip = 'Removes reload animation', Callback = function(first)
    for i, v in pairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "ReloadTime") then
            if first then
                
                if originalReloadTimeValues[v] == nil then
                    originalReloadTimeValues[v] = rawget(v, "ReloadTime")
                end
                
                rawset(v, "ReloadTime", 0)
            else
                
                if originalReloadTimeValues[v] ~= nil then
                    rawset(v, "ReloadTime", originalReloadTimeValues[v])
                    originalReloadTimeValues[v] = nil
                end
            end
        end
    end
end})]]

    gunmodbox:AddToggle('gunmods_noslowdown', {Text = 'no slowdown', Default = false, Tooltip = 'Removes movement slowdown while shooting or aiming', Callback = function(first)
        modulecomm.noslowdown = first
    end})
    gunmodbox:AddToggle('gunmods_forcehead', {Text = 'force head',Default = false,Callback = function(first)
        modulecomm.forcehead = first
    end})
    salobox:AddDropdown('aim_part', {Text = 'aim part', Values = {"Head","HumanoidRootPart","Torso","Left Arm","Right Arm","Left Leg","Right Leg"}, Default = 1, Multi = false, Tooltip = 'Select the body part to aim at', Callback = function(v)
        modulecomm.aim_part = v
    end})
    salobox:AddToggle('aimbot_enabled', {Text = 'aimbot',Default = false,Tooltip = 'Enables the aimbot',Callback = function(first)
        modulecomm.enabled = first
    end})

    salobox:AddToggle('aimbot_resolver', {Text = 'resolver',Default = false,Tooltip = 'correct enemy antiaim spinbot etc',Callback = function(first)
        resolver = first
    end})
    salobox:AddToggle('aimbot_camera', {Text = 'camera (mb2)',Default = false,Tooltip = 'Aims using camera direction when holding MB2',Callback = function(first)
        modulecomm.camera = first
    end})
    salobox:AddToggle('aimbot_silent', {Text = 'silent',Default = false,Tooltip = 'Silent aim without moving the camera',Callback = function(first)
        modulecomm.silent = first
    end})

    salobox:AddToggle('aimbot_indicator', {Text = 'indicator (crosshair needed)',Default = false,Tooltip = 'Shows an indicator when visible or aimbot is active',Callback = function(first)
        modulecomm.indicator = first
    end})
    salobox:AddToggle('aimbot_snaplines', {Text = 'snaplines a bit broken',Default = false,Tooltip = 'Shows snaplines',Callback = function(first)
        modulecomm.snaplines = first
    end}):AddColorPicker('aimbot_snaplines_color',{Default = Color3.new(1, 1, 1),Title = 'snaplines color',Transparency = 0,Callback = function(Value)
        modulecomm.snaplines_color = Value
    end})
    salobox:AddDropdown('aimbot_snaplines_from', {
        Text = 'snapline origin',
        Default = 1,
        Values = {'center','mouse','bottom'},
        Tooltip = 'Where snapline starts',
        Callback = function(choice)
            modulecomm.snaplines_from = choice
        end
    })
    salobox:AddToggle('aimbot_sleep_check', {Text = 'sleeper check',Default = false,Tooltip = 'Ignores sleeping players',Callback = function(first)
        modulecomm.sleep_check = first
    end})

    salobox:AddToggle('aimbot_team_check', {Text = 'team check',Default = false,Tooltip = 'Ignores teammates',Callback = function(first)
        modulecomm.team_check = first
    end})

    salobox:AddToggle('aimbot_fov', {Text = 'use fov',Default = false,Tooltip = 'Limits aimbot to a specific field of view',Callback = function(Value)
        modulecomm.fov = Value
    end})

    local Depbox1 = salobox:AddDependencyBox();

    Depbox1:AddToggle('aimbot_fov_show', {Text = 'show fov',Default = false,Tooltip = 'Displays the aimbot FOV circle',Callback = function(Value)
        modulecomm.fov_show = Value
    end}):AddColorPicker('aimbot_fov_color',{Default = Color3.new(1, 1, 1),Title = 'fov color',Transparency = 0,Callback = function(Value)
        modulecomm.fov_color = Value
    end})

    Depbox1:AddToggle('aimbot_fov_outline', {Text = 'fov outline',Default = false,Tooltip = 'Adds an outline to the FOV circle',Callback = function(Value)
        modulecomm.fov_outline = Value
    end})

    Depbox1:AddSlider('aimbot_fov_size',{Text = 'target fov',Default = 100,Min = 10,Max = 1000,Rounding = 0,Compact = true,Tooltip = 'Adjusts the size of the aimbot FOV',Callback = function(State)
        modulecomm.fov_size = State
    end})

    Depbox1:SetupDependencies({
        { cheat.Toggles.aimbot_fov, true }
    });
    salobox:AddToggle('silentaim_manipulation', {Text = 'silent manipulation',Default = false,Callback = function(Value)
        modulecomm.manipulation = Value
    end})

    local Depbox2 = salobox:AddDependencyBox();
    
    Depbox2:AddSlider('silentaim_manipulation_range',{Text = 'manipulation range',Default = 5,Min = 1,Max = 5,Rounding = 1,Compact = true,Callback = function(State)
        modulecomm.manipulation_range = State
    end})

    Depbox2:SetupDependencies({
        { cheat.Toggles.silentaim_manipulation, true }
    });
    local simulation_table = {} do
        local enabled, range, yrange, slices, refresh_time = false, 10, 5, 5, 0.1

        local function generate_simulation_table() LPH_JIT_MAX(function()
            simulation_table = {}
            if not modulecomm.simulation then return end
            for x = -range, range, range/slices do
                for z = -range, range, range/slices do
                    if x * x + z * z <= range * range then
                        if yrange > 0 then
                            for y = -yrange, yrange, yrange/slices do
                                simulation_table[#simulation_table + 1] = _Vector3new(x, y, z)
                            end
                        else
                            simulation_table[#simulation_table + 1] = _Vector3new(x, 0, z)
                        end
                    end
                end
            end
        end)() end
        salobox:AddToggle('silentaim_simulation', {Text = 'player simulation',Default = false,Callback = function(Value)
            modulecomm.simulation = Value
            generate_simulation_table()
        end})
        salobox:AddSlider('silentaim_simulation_range',{Text = 'simulation range',Default = 50,Min = 50,Max = 500,Rounding = 0,Compact = true,Callback = function(State)
            range = State
            generate_simulation_table()
        end})
        salobox:AddSlider('silentaim_simulation_yrange',{Text = 'simulation y range',Default = 0,Min = 0,Max = 8,Rounding = 0,Compact = true,Callback = function(State)
            yrange = State
            generate_simulation_table()
        end})
        salobox:AddSlider('silentaim_simulation_slices',{Text = 'simulation slices',Default = 5,Min = 1,Max = 20,Rounding = 0,Compact = true,Callback = function(State)
            slices = State
            generate_simulation_table()
        end})
        salobox:AddSlider('silentaim_simulation_refresh',{Text = 'refresh time',Default = 0.1,Min = 0.1,Max = 1,Rounding = 1,Compact = true,Callback = function(State)
            refresh_time = State
            generate_simulation_table()
        end})
    salobox:AddDropdown('silentaim_simulation_time', {Values = {'simple','complex-simple','complex'},Default = 1,Multi = false,Text = 'simulation time type',Callback = function(Value)
        modulecomm.simulation_time = Value
    end})
    generate_simulation_table()
    
    task.spawn(function()
        while task.wait(refresh_time) do
            if modulecomm.simulation and modulecomm.target[1] then
                modulecomm.simulation_pos = get_simulation_pos(Camera.CFrame.p, modulecomm.target[1].Parent, modulecomm.target[1], simulation_table)
            end
        end
    end)

    -- AutoFire Function
    local autofire_enabled = false
    local autofire_connection = nil
    local last_shoot_time = 0
    local shoot_delay = 0.1 -- Default delay between shots
    local mouse1_down = false
    
    salobox:AddToggle('aimbot_autofire', {Text = 'autofire', Default = false, Tooltip = 'Automatically holds left mouse button when target is visible', Callback = function(first)
        autofire_enabled = first
        if autofire_enabled then
            autofire_connection = cheat.utility.new_heartbeat(function(delta)
                if autofire_enabled and modulecomm.enabled and target_part and target_entity then
                    -- Check if target is visible (using manipulation or simulation)
                    local target_visible = false
                    if modulecomm.manipulation and manipulation_pos then
                        target_visible = true
                    elseif modulecomm.simulation and modulecomm.simulation_pos then
                        target_visible = true
                    end
                    
                    -- Hold left mouse button if target is visible
                    if target_visible and not mouse1_down then
                        mouse1_down = true
                        -- Simulate mouse1 press
                        mouse1press()
                    elseif not target_visible and mouse1_down then
                        mouse1_down = false
                        -- Simulate mouse1 release
                        mouse1release()
                    end
                elseif mouse1_down then
                    -- Release mouse if no target
                    mouse1_down = false
                    mouse1release()
                end
            end)
        else
            if autofire_connection then
                autofire_connection:Disconnect()
                autofire_connection = nil
                -- Release mouse when disabled
                if mouse1_down then
                    mouse1_down = false
                    mouse1release()
                end
            end
        end
    end}):AddKeyPicker('aimbot_autofire_key', {Default = 'None', SyncToggleState = true, Mode = 'Toggle', Text = 'autofire key'})
    
    salobox:AddSlider('aimbot_autofire_delay', {Text = 'autofire delay', Default = 100, Min = 0, Max = 1000, Rounding = 0, Compact = true, Tooltip = 'Delay between autofire shots in milliseconds', Callback = function(State)
        shoot_delay = State / 1000 -- Convert milliseconds to seconds
    end})
end
    local CircleOutline = Drawing.new("Circle")
    local CircleInline = Drawing.new("Circle")
    CircleInline.Transparency = 1
    CircleInline.Thickness = 1
    CircleInline.ZIndex = 2
    CircleOutline.Thickness = 3
    CircleOutline.Color = Color3.new()
    CircleOutline.ZIndex = 1
    

    cheat.utility.new_renderstepped(LPH_JIT_MAX(function()
        CircleOutline.Position = (_Vector2new(Mouse.X, Mouse.Y + GuiInset.Y))
        CircleInline.Position = (_Vector2new(Mouse.X, Mouse.Y + GuiInset.Y))
        CircleInline.Radius = modulecomm.fov_size
        CircleInline.Color = modulecomm.fov_color
        CircleInline.Visible = modulecomm.fov and modulecomm.fov_show
        CircleOutline.Radius = modulecomm.fov_size
        CircleOutline.Visible = (modulecomm.fov and modulecomm.fov_show and modulecomm.fov_outline)
        if modulecomm.noslowdown then
            rawset(garbage.character, "sprintBlocked", false)
        end
    end))
    cheat.utility.new_heartbeat(LPH_JIT_MAX(function()
        local indtxt = ""
        target_part, target_entity = get_closest_target(modulecomm.fov, modulecomm.fov_size, modulecomm.part, modulecomm.sleep_check, modulecomm.team_check);
        modulecomm.target = {target_part, target_entity}
        if target_part and target_entity then
            manipulation_pos = target_part and target_entity and get_manipulation_pos(modulecomm.extended_manipulation and trident.lastpos or Camera.CFrame.p, target_part.Parent, target_part, modulecomm.manipulation_range + (modulecomm.extended_manipulation and 5 or 0), modulecomm.manipulation) or nil;
            modulecomm.manipulation_pos = manipulation_pos
            indtxt = indtxt..(rawget(target_entity, "name") or rawget(target_entity, "type"))
            if modulecomm.manipulation and manipulation_pos then
                indtxt = indtxt.." (visible)"
            end
            if modulecomm.simulation_pos then
                indtxt = indtxt.." (simulated)"
            end
        else
            indtxt = ""
            modulecomm.manipulation_pos = nil
        end
        modulecomm.indicator_text = indtxt
    end))
    local function worldToScreen(world)
        local screen, inBounds = _WorldToViewportPoint(Camera, world)
        return _Vector2new(screen.X, screen.Y), inBounds, screen.Z
    end
    local snapline = nil
    cheat.utility.new_renderstepped(LPH_JIT_MAX(function()
        if not modulecomm.snaplines then
            if snapline then snapline.Visible = false end
            return
        end

        local target = modulecomm.target[1]
        local has_anchor = modulecomm.manipulation_pos and modulecomm.manipulation or modulecomm.simulation_pos

        if not (target and has_anchor) then
            if snapline then snapline.Visible = false end
            return
        end

        local screen_pos, on_screen = worldToScreen(target.Position)
        if modulecomm.fov and on_screen then
            local mouse_pos = _Vector2new(Mouse.X, Mouse.Y + GuiInset.Y)
            if (screen_pos - mouse_pos).Magnitude > modulecomm.fov_size then
                on_screen = false
            end
        end

        if on_screen then
            local origin_mode = modulecomm.snaplines_from
            local from_pos

            if origin_mode == "mouse" then
                from_pos = _Vector2new(Mouse.X, Mouse.Y + GuiInset.Y)
            elseif origin_mode == "bottom" then
                from_pos = _Vector2new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            else
                from_pos = _Vector2new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            end

            if not snapline then
                snapline = Drawing.new("Line")
                snapline.Thickness = 1
                snapline.ZIndex = 2
            end
            snapline.Visible = true
            snapline.Color = modulecomm.snaplines_color
            snapline.From = from_pos
            snapline.To = screen_pos
        elseif snapline then
            snapline.Visible = false
        end
    end))
    for _, v in getgc(true) do
        if type(v) == "table" and rawget(v, "type") == "MiningDrill" then
            v.AttackCooldown = 0
        end
    end
    for _, v in getgc(true) do
        if type(v) == "table" and rawget(v, "type") == "Magnum" then
            v.ChargeUpTime = 0
        end
    end



do
    local function findIsGrounded()
        for _, obj in ipairs(getgc(true)) do
            if type(obj) == "table" then
                local hasIsGrounded = false
                for k, v in pairs(obj) do
                    if k == "IsGrounded" and type(v) == "function" then
                        hasIsGrounded = true
                        break
                    end
                end
                if hasIsGrounded then
                    return obj
                end
            end
        end
        return nil
    end

    local characterTable = findIsGrounded()
    if characterTable then
        local originalIsGrounded = characterTable.IsGrounded
        characterTable.IsGrounded = function(...)
            if modulecomm and modulecomm.jumpshoot then
                return true
            end
            return originalIsGrounded(...)
        end
    end
end
--[[    u = function()
    return function(CharacterModel)
        -- Поиск части тела 'Head'
        local HeadPart = CharacterModel:FindFirstChild('Head')
        
        -- Проверяет, существует ли HeadPart и включен ли у него дочерний объект/свойство 'Teamtag'
        return HeadPart and HeadPart.Teamtag.Enabled
    end
end]]
if modulecomm.team_check then
    local function checkTeamTag(entity)
        local HeadPart = entity:FindFirstChild("Head")
        if HeadPart then
            local teamtag = HeadPart:FindFirstChild("Teamtag")
            if teamtag and teamtag.Enabled then
                return true
            end
        end
        return false
    end
end
    do
        local entlist = getupvalue(garbage.entitylist, 1)
        RunService:BindToRenderStep(tostring(math.random()), 0, LPH_NO_VIRTUALIZE(function()
            if resolver then
                for id, entity in entlist do if rawget(entity, "startAngleY") and rawget(entity, "startAngleX") then
                    rawset(entity, "startAngleY", 0)
                    rawset(entity, "goalAngleY", 0)
                    rawset(entity, "startAngleX", 0)
                    rawset(entity, "goalAngleX", 0)
                    rawset(entity, "rot", Vector3.zero)
                end end
            end
            
            local equippeditem = getupvalue(garbage.equippeditem, 1)
            trident.guninfo = classes and equippeditem and rawget(classes, rawget(equippeditem, "type"))
    
            if modulecomm.enabled and modulecomm.camera and target_part and target_entity and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                local guninfo    = trident.guninfo
                local proj_speed = guninfo and rawget(guninfo, "ProjectileSpeed")
                local proj_drop  = guninfo and rawget(guninfo, "ProjectileDrop") or 0
                local campos     = Camera.CFrame.p
                local pitch, yaw = CFrame.lookAt(campos, 
                    (guninfo and proj_speed and proj_drop)
                and
                    predict_entity(target_part, target_entity, proj_speed, proj_drop, campos)
                or
                    target_part.CFrame.p
                ):ToOrientation()
                setupvalue(garbage.recoil, 13, _Vector3new(pitch, yaw, 0))
            end
        end))
    end

local RWC = (classes and classes.RangedWeaponClient) or RangedWeaponClient
assert(RWC and type(RWC.CreateProjectile) == "function", "[silent] RangedWeaponClient.CreateProjectile not found")


local function compute_silent_cf(defaultOrigin)
    
    if not (modulecomm and modulecomm.enabled and modulecomm.silent and target_entity) then
        return nil
    end
    local guninfo    = trident.guninfo
    local proj_speed = guninfo and rawget(guninfo, "ProjectileSpeed")
    local proj_drop  = guninfo and rawget(guninfo, "ProjectileDrop") or 0
    if not (guninfo and proj_speed and proj_drop) then
        return nil
    end

    
    local chosenPart
    if typeof(target_entity) == "Instance" then
        chosenPart = target_entity:FindFirstChild(modulecomm.aim_part)
    elseif typeof(target_entity) == "table" and target_entity.model and typeof(target_entity.model) == "Instance" then
        chosenPart = target_entity.model:FindFirstChild(modulecomm.aim_part)
    end
    if not (chosenPart and typeof(chosenPart) == "Instance" and chosenPart:IsA("BasePart")) then
        warn("[silent] skipped: invalid chosenPart →", chosenPart)
        return nil
    end

    local origin = manipulation_pos or defaultOrigin or Camera.CFrame.p
    local aimPos

    aimPos = predict_entity(chosenPart, target_entity, proj_speed, proj_drop, origin)

    if not aimPos then return nil end

    return CFrame.lookAt(origin, aimPos)
end


do
    local oldCP = RWC.CreateProjectile
    RWC.CreateProjectile = function(startCFrame, weaponData, isLocal, ignoreModel, dropOverride)
        
        if not isLocal then
            return oldCP(startCFrame, weaponData, isLocal, ignoreModel, dropOverride)
        end

        
        getgenv().lastSilentCF = nil 

        local silentCF = compute_silent_cf(startCFrame and startCFrame.p or Camera.CFrame.p)
        if silentCF then
            startCFrame = silentCF
            getgenv().lastSilentCF = silentCF 
        end

        return oldCP(startCFrame, weaponData, isLocal, ignoreModel, dropOverride)
    end
end


do
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        if method == "FireServer" and (tostring(self) == "TCP" or tostring(self) == "UDP") then
            if args[1] == (classes and classes.SendCodes and classes.SendCodes.INV_USE_ITEM) or args[1] == 10 then
                if args[2] == "Fire" and typeof(args[4]) == "CFrame" then
                    
                    
                    local silentCF = getgenv().lastSilentCF
                    
                    if silentCF then
                        args[4] = silentCF
                        
                        
                        getgenv().lastSilentCF = nil 
                    end
                end
            end
            return oldNamecall(self, unpack(args))
        end
    return oldNamecall(self, ...)
    end))
end

do
    local validcharacters = {}
    local hbc, original_size, hbsize = nil, trident.original_model.Torso.Size, _Vector3new(0.5, 1, 0.5)
    local dynamic, alwayshead = false, false
    local hitboxheadsizex, hitboxheadsizey, hitboxheadtransparency, cancollide = 10, 10, 0.5, false
    local function addtovc(obj)
        if not obj then return end
        if not obj:FindFirstChild("Head") and not obj:FindFirstChild("LowerTorso") then return end
        validcharacters[obj] = obj
    end

    local function removefromvc(obj)
        if not validcharacters[obj] then return end
        validcharacters[obj] = nil
    end

    for i, v in next, workspace:GetChildren() do addtovc(v) end
    workspace.ChildAdded:Connect(addtovc);
    workspace.ChildRemoved:Connect(removefromvc);
local hbb = ui.box.aimbot:AddTab("Hitbox")
hbb:AddToggle('hitbox_enabled', { Text = 'hitbox', Default = false, Callback = function(value)
    modulecomm.hitboxes = value
    if hbc then hbc:Disconnect() end
    if value then
        hbc = cheat.utility.new_heartbeat(function()
            local trans = hitboxheadtransparency
            for _, model in pairs(validcharacters) do
                local primpart = model and _FindFirstChild(model, 'Torso')
                local sleeping = false
                for _, entity in pairs(getupvalue(garbage.entitylist, 1)) do
                    if rawget(entity, "model") == model and rawget(entity, "sleeping") then
                        sleeping = true
                        break
                    end
                end
                if primpart and not sleeping then
                    primpart.Size = hbsize
                    primpart.Transparency = trans
                    primpart.CanCollide = cancollide
                end
            end
        end)
    else
        if hbc then hbc:Disconnect() end
        for _, model in pairs(validcharacters) do
            local primpart = model and _FindFirstChild(model, 'Torso')
            if primpart then
                primpart.Size = original_size
                primpart.Transparency = 0
                primpart.CanCollide = true
            end
        end
    end
end 
})

    hbb:AddToggle('hitbox_cancollide',{Text = 'can collide',Default = false,Callback = function(v)
        cancollide = v
    end})
    hbb:AddSlider('hitbox_head_transparency', { Text = 'transparency', Default = 0.5, Min = 0, Max = 1, Rounding = 1, Compact = false }):OnChanged(function(State)
        hitboxheadtransparency = State
    end)
    hbb:AddSlider('hitbox_head_size_x', { Text = 'size x', Default = 10, Min = 1, Max = 1000, Rounding = 1, Compact = false }):OnChanged(function(State)
        hitboxheadsizex = State
        hbsize = _Vector3new(hitboxheadsizex, hitboxheadsizey, hitboxheadsizex)
    end)
    hbb:AddSlider('hitbox_head_size_y', { Text = 'size y', Default = 10, Min = 1, Max = 25, Rounding = 1, Compact = false }):OnChanged(function(State)
        hitboxheadsizey = State
        hbsize = _Vector3new(hitboxheadsizex, hitboxheadsizey, hitboxheadsizex)
    end)
end
do
    local espb = ui.box.esp:AddTab("player esp")
    local es = cheat.EspLibrary.settings.enemy
    espb:AddDropdown('espfont', {Values = { 'UI', 'System', 'Plex', 'Monospace' },Default = 2,Multi = false,Text = 'esp font',Tooltip = 'select font',Callback = function(Value)
        cheat.EspLibrary.main_settings.textFont = Drawing.Fonts[Value]
        cheat.EspLibrary.icaca()
    end})
    espb:AddSlider('espfontsize', { Text = 'esp font size', Default = 13, Min = 1, Max = 30, Rounding = 0, Compact = true }):OnChanged(function(State)
        cheat.EspLibrary.main_settings.textSize = State
        cheat.EspLibrary.icaca()
    end)
    espb:AddToggle('espsimplecalc', {
        Text = 'simpler corner calc (fps)',
        Default = false,
        Callback = function(first)
            cheat.EspLibrary.main_settings.simplecalc = first
            cheat.EspLibrary.icaca()
        end
    })
    espb:AddToggle('espswitch', {
        Text = 'enable esp',
        Default = false,
        Callback = function(first)
            es.enabled = first
            cheat.EspLibrary.icaca()
        end
    })
    espb:AddToggle('espteamswitch', {
        Text = 'team/ai check',
        Default = false,
        Callback = function(first)
            cheat.EspLibrary.main_settings.teamcheck = first
            cheat.EspLibrary.icaca()
        end
    })
    espb:AddToggle('espsleeperswitch', {
        Text = 'sleeper check',
        Default = false,
        Callback = function(first)
            cheat.EspLibrary.main_settings.sleepcheck = first
            cheat.EspLibrary.icaca()
        end
    })
    
    espb:AddToggle('espbox', {
        Text = 'box esp',
        Default = false,
        Callback = function(first)
            es.box = first
            cheat.EspLibrary.icaca()
        end
    }):AddColorPicker('espboxcolor', {
        Default = Color3.new(1, 1, 1),
        Title = 'box color',
        Transparency = 0,
        Callback = function(Value)
            es.box_color[1] = Value
            cheat.EspLibrary.icaca()
        end
    })
    
    espb:AddToggle('espboxfill', {
        Text = 'box fill',
        Default = false,
        Callback = function(first)
            es.box_fill = first
            cheat.EspLibrary.icaca()
        end
    }):AddColorPicker('espboxfillcolor',
        {
            Default = Color3.new(1, 1, 1),
            Title = 'box fill color',
            Transparency = 0,
            Callback = function(Value)
                es.box_fill_color[1] = Value
                cheat.EspLibrary.icaca()
            end
        })
    
    espb:AddToggle('espoutlinebox', {
        Text = 'box outline',
        Default = false,
        Callback = function(first)
            es.box_outline = first
            cheat.EspLibrary.icaca()
        end
    }):AddColorPicker('espboxoutlinecolor',
        {
            Default = Color3.new(),
            Title = 'box outline color',
            Transparency = 0,
            Callback = function(Value)
                es.box_outline_color[1] = Value
                cheat.EspLibrary.icaca()
            end
        })
    
    espb:AddSlider('espboxtransparency',
        { Text = 'box transparency', Default = 0, Min = 0, Max = 1, Rounding = 1, Compact = false }):OnChanged(function(
        State)
        es.box_color[2] = 1-State
        cheat.EspLibrary.icaca()
    end)
    espb:AddSlider('espoutlineboxtransparency',
        { Text = 'box outline transparency', Default = 0, Min = 0, Max = 1, Rounding = 1, Compact = false }):OnChanged(function(
        State)
        es.box_outline_color[2] = State
        cheat.EspLibrary.icaca()
    end)
    espb:AddSlider('espboxfilltransparency',
        { Text = 'box fill transparency', Default = 0.5, Min = 0, Max = 1, Rounding = 1, Compact = false }):OnChanged(function(
        State)
        es.box_fill_color[2] = 1-State
        cheat.EspLibrary.icaca()
    end)
    
    espb:AddToggle('esprealname', {
        Text = 'name esp',
        Default = false,
        Callback = function(first)
            es.realname = first
            cheat.EspLibrary.icaca()
        end
    }):AddColorPicker('esprealnamecolor',
        {
            Default = Color3.new(1, 1, 1),
            Title = 'name color',
            Transparency = 0,
            Callback = function(Value)
                es.realname_color[1] = Value
                cheat.EspLibrary.icaca()
            end
        })
    espb:AddSlider('esprealnametransparency',
        { Text = 'name transparency', Default = 0, Min = 0, Max = 1, Rounding = 1, Compact = false }):OnChanged(function(
        State)
        es.realname_color[2] = 1-State
        cheat.EspLibrary.icaca()
    end)
    
    espb:AddToggle('esprealnameoutline', {
        Text = 'name outline',
        Default = false,
        Callback = function(first)
            es.realname_outline = first
            cheat.EspLibrary.icaca()
        end
    }):AddColorPicker('esprealnameoutlinecolor',
        {
            Default = Color3.new(),
            Title = 'name outline color',
            Transparency = 0,
            Callback = function(Value)
                es.realname_outline_color = Value
                cheat.EspLibrary.icaca()
            end
        })

    
    espb:AddToggle('espdistance', {
        Text = 'distance esp',
        Default = false,
        Callback = function(first)
            es.dist = first
            cheat.EspLibrary.icaca()
        end
    }):AddColorPicker('espdistancecolor',
        {
            Default = Color3.new(1, 1, 1),
            Title = 'distance color',
            Transparency = 0,
            Callback = function(Value)
                es.dist_color[1] = Value
                cheat.EspLibrary.icaca()
            end
        })
    espb:AddSlider('espdistancetransparency',
        { Text = 'distance transparency', Default = 0, Min = 0, Max = 1, Rounding = 1, Compact = false }):OnChanged(function(
        State)
        es.dist_color[2] = 1-State
        cheat.EspLibrary.icaca()
    end)
    
    espb:AddToggle('espdistanceoutline', {
        Text = 'distance outline',
        Default = false,
        Callback = function(first)
            es.dist_outline = first
            cheat.EspLibrary.icaca()
        end
    }):AddColorPicker('espdistanceoutlinecolor',
        {
            Default = Color3.new(),
            Title = 'distance outline color',
            Transparency = 0,
            Callback = function(Value)
                es.dist_outline_color = Value
                cheat.EspLibrary.icaca()
            end
        })
    
    espb:AddToggle('espweapon', {
        Text = 'weapon esp',
        Default = false,
        Callback = function(first)
            es.weapon = first
            cheat.EspLibrary.icaca()
        end
    }):AddColorPicker('espweaponcolor',
        {
            Default = Color3.new(1, 1, 1),
            Title = 'weapon color',
            Transparency = 0,
            Callback = function(Value)
                es.weapon_color[1] = Value
                cheat.EspLibrary.icaca()
            end
        })
    espb:AddSlider('espweapontransparency',
        { Text = 'weapon transparency', Default = 0, Min = 0, Max = 1, Rounding = 1, Compact = false }):OnChanged(function(
        State)
        es.weapon_color[2] = 1-State
        cheat.EspLibrary.icaca()
    end)
    
    espb:AddToggle('espweaponoutline', {
        Text = 'weapon outline',
        Default = false,
        Callback = function(first)
            es.weapon_outline = first
            cheat.EspLibrary.icaca()
        end
    }):AddColorPicker('espweaponoutlinecolor',
        {
            Default = Color3.new(),
            Title = 'weapon outline color',
            Transparency = 0,
            Callback = function(Value)
                es.weapon_outline_color = Value
                cheat.EspLibrary.icaca()
            end
        })
    
    espb:AddToggle('espskeleton', {Text = 'skeleton esp',Default = false,Callback = function(first)
        es.skeleton = first
        cheat.EspLibrary.icaca()
    end}):AddColorPicker('espskeletoncolor', {Default = Color3.new(1, 1, 1),Title = 'skeleton color',Transparency = 0,Callback = function(Value)
        es.skeleton_color[1] = Value
        cheat.EspLibrary.icaca()
    end})
    espb:AddSlider('espskeletontransparency', { Text = 'skeleton transparency', Default = 0, Min = 0, Max = 1, Rounding = 1, Compact = false }):OnChanged(function(State)
        es.skeleton_color[2] = 1-State
        cheat.EspLibrary.icaca()
    end)
    
    espb:AddToggle('espchams', {
        Text = 'chams',
        Default = false,
        Callback = function(first)
            es.chams = first
            cheat.EspLibrary.icaca()
        end
    })
    espb:AddToggle('espchamsvisibleonly', {
        Text = 'chams visible only',
        Default = false,
        Callback = function(first)
            es.chams_visible_only = first
            cheat.EspLibrary.icaca()
        end
    })
    
    espb:AddLabel("chams fill color"):AddColorPicker('espchamsfillcolor',
        {
            Default = Color3.new(),
            Title = 'chams fill color',
            Transparency = 0,
            Callback = function(Value)
                es.chams_fill_color[1] = Value
                cheat.EspLibrary.icaca()
            end
        })
    espb:AddLabel("chams outline color"):AddColorPicker('espchamsoutlinecolor',
        {
            Default = Color3.new(),
            Title = 'chams outline color',
            Transparency = 0,
            Callback = function(Value)
                es.chamsoutline_color[1] = Value
                cheat.EspLibrary.icaca()
            end
        })
    
    espb:AddSlider('espchamsfilltransparency',
        { Text = 'fill transparency', Default = 0.5, Min = 0, Max = 1, Rounding = 1, Compact = false }):OnChanged(function(
        State)
        es.chams_fill_color[2] = State
        cheat.EspLibrary.icaca()
    end)
    espb:AddSlider('espchamsoutlinetransparency',
        { Text = 'outline transparency', Default = 0, Min = 0, Max = 1, Rounding = 1, Compact = false }):OnChanged(function(
        State)
        es.chamsoutline_color[2] = State
        cheat.EspLibrary.icaca()
    end)
    
end
do
    local espb = ui.box.esp:AddTab("object esp")
    local es = cheat.EspLibrary.settings.object
    espb:AddDropdown('objectespfont', {Values = { 'UI', 'System', 'Plex', 'Monospace' },Default = 2,Multi = false,Text = 'esp font',Tooltip = 'select font',Callback = function(Value)
        cheat.EspLibrary.main_object_settings.textFont = Drawing.Fonts[Value]
        cheat.EspLibrary.icaca()
    end})
    espb:AddSlider('objectespfontsize', { Text = 'esp font size', Default = 13, Min = 1, Max = 30, Rounding = 0, Compact = true }):OnChanged(function(State)
        cheat.EspLibrary.main_object_settings.textSize = State
        cheat.EspLibrary.icaca()
    end)
    espb:AddDropdown('objectespallowed', {Values = {
        'ATV', 'Stone', 'Nitrate', 'Iron', 'Backpack',
        'Tree1', 'Tree2', 'Tree3', 'Tree4',
        'TeslaPylon', 'GasTrap', 'ClaimTotem'
    },Default = 0,Multi = true,Text = 'objects',Tooltip = 'select objects thats gonna show up',Callback = function(Value)
        cheat.EspLibrary.main_object_settings.allowed = Value
        cheat.EspLibrary.icaca()
    end})
    espb:AddToggle('objectespswitch', {
        Text = 'enable esp',
        Default = false,
        Callback = function(first)
            es.enabled = first
            cheat.EspLibrary.icaca()
        end
    })
    espb:AddToggle('objectespallswitch', {
        Text = 'esp on fucking everything apparently????',
        Default = false,
        Callback = function(first)
            es.allenabled = first
            cheat.EspLibrary.icaca()
        end
    })
    espb:AddToggle('objectesprealname', {
        Text = 'name esp',
        Default = false,
        Callback = function(first)
            es.realname = first
            cheat.EspLibrary.icaca()
        end
    }):AddColorPicker('objectesprealnamecolor',
        {
            Default = Color3.new(1, 1, 1),
            Title = 'name color',
            Transparency = 0,
            Callback = function(Value)
                es.realname_color[1] = Value
                cheat.EspLibrary.icaca()
            end
        })
    espb:AddSlider('objectesprealnametransparency',
        { Text = 'name transparency', Default = 0, Min = 0, Max = 1, Rounding = 1, Compact = false }):OnChanged(function(
        State)
        es.realname_color[2] = 1-State
        cheat.EspLibrary.icaca()
    end)
    espb:AddToggle('objectesprealnameoutline', {
        Text = 'name outline',
        Default = false,
        Callback = function(first)
            es.realname_outline = first
            cheat.EspLibrary.icaca()
        end
    }):AddColorPicker('objectesprealnameoutlinecolor',
        {
            Default = Color3.new(),
            Title = 'name outline color',
            Transparency = 0,
            Callback = function(Value)
                es.realname_outline_color = Value
                cheat.EspLibrary.icaca()
            end
        })
end
local canuseimages = pcall(function()
    cheat.utility.new_drawing("Image", {}):Remove()
end) and pcall(function()
    local a = cheat.utility.new_drawing("Image", {})
    rawget(a, "_frame").Image = ""
    a:Remove()
end)
do
    local enabled, dynamic = false, false;
    local color1, color2 = Color3.new(1,1,1), Color3.new();
    local watermarktab = ui.box.cheatvis:AddTab("watermark")
    local watermarktoggle = watermarktab:AddToggle('watermark_enabled', {Text = 'enabled',Default = false,Callback = function(first)
        enabled = first
    end})
    watermarktoggle:AddColorPicker('watermark_color1',{Default = Color3.new(),Title = canuseimages and 'color left' or 'color',Transparency = 0,Callback = function(Value)
        color1 = Value
        if not canuseimages then color2 = Value end
    end})
    if canuseimages then watermarktoggle:AddColorPicker('watermark_color2',{Default = Color3.new(),Title = 'color right',Transparency = 0,Callback = function(Value)
        color2 = Value
    end}); end
    watermarktab:AddToggle('watermark_rainbowcolor', {Text = 'rainbow',Default = false,Callback = function(first)
        dynamic = first
    end})
    local leftcolor, rightcolor, watertext = 
    Color3.new(0.000000, 0.666667, 0.333333), 
    Color3.new(0.349020, 0.000000, 1.000000),
    "swimhub.xyz canary | Jul 28 2024 | fps: 63 ";
    local waterpos = Vector2.new(10, 10);
    local text = cheat.utility.new_drawing("Text", {
        ZIndex = 4,
        Visible = true,
        Transparency = 1,
        Position = waterpos + Vector2.new(6, 5),
        Color = Color3.new(1, 1, 1),
        Outline = true,
        OutlineColor = Color3.new(),
        Font = 1,
        Size = 14,
        Text = watertext
    });
    local gradr, gradl = cheat.utility.new_drawing(canuseimages and "Image" or "Square", {
        ZIndex = 2,
        Visible = true,
        Transparency = 1,
        Position = waterpos,
        Size = Vector2.new(text.TextBounds.X + 10, text.TextBounds.Y + 10),
        Color = rightcolor
    }), cheat.utility.new_drawing(canuseimages and "Image" or "Square", {
        ZIndex = 2,
        Visible = true,
        Transparency = 1,
        Position = waterpos,
        Size = Vector2.new(text.TextBounds.X + 10, text.TextBounds.Y + 10),
        Color = leftcolor
    });
    local gradbackground = cheat.utility.new_drawing("Square", {
        ZIndex = 1,
        Visible = true,
        Transparency = 1,
        Position = waterpos,
        Size = Vector2.new(text.TextBounds.X + 10, text.TextBounds.Y + 10),
        Color = leftcolor:Lerp(rightcolor, 0.5),
        Filled = true
    });
    local textbackground = cheat.utility.new_drawing("Square", {
        ZIndex = 3,
        Visible = true,
        Transparency = 0.337,
        Position = waterpos + Vector2.new(2, 2),
        Size = Vector2.new(text.TextBounds.X + 6, text.TextBounds.Y + 6),
        Color = Color3.new(0,0,0),
        Filled = true,
        Thickness = 0.00000000000000000000001,
    });
    if canuseimages then rawget(gradr, "_frame").Image = getcustomasset("swimhub/new/files/grad90r.png"); end
    if canuseimages then rawget(gradl, "_frame").Image = getcustomasset("swimhub/new/files/grad90l.png"); end
    local hue1, hue2, fpstimer, fps, finalfps = 0, 0.15, tick(), 0, 60;
    cheat.utility.new_renderstepped(LPH_JIT_MAX(function(delta)
        fps = fps + 1;
        if fpstimer + 1 <= tick() then
            fpstimer = tick();
            finalfps = fps;
            fps = 0;
        end;
        hue1, hue2 = tick() % 1, tick() % 1 + 0.15;
        if hue1 >= 1 then hue1 = 0 end if hue2 >= 1 then hue2 = 0 end
        rightcolor = dynamic and Color3.fromHSV(hue1, 1, 1) or color2;
        leftcolor = dynamic and Color3.fromHSV(hue2, 1, 1) or color1;
        watertext = ("swimhub %s | %s | %s | %s fps"):format(SWG_Version, SWG_ShortName, os.date("%b %d %Y"), tostring(finalfps));
        gradr.Color = rightcolor;
        gradl.Color = leftcolor;
        gradbackground.Color = gradr.Color:Lerp(gradl.Color, 0.5);
        textbackground.Size = Vector2.new(text.TextBounds.X + 7, text.TextBounds.Y + 6);
        textbackground.Position = waterpos + Vector2.new(2, 2);
        gradbackground.Size = Vector2.new(text.TextBounds.X + 11, text.TextBounds.Y + 10);
        gradbackground.Position = waterpos;
        gradl.Position = waterpos;
        gradl.Size = Vector2.new(text.TextBounds.X + 11, text.TextBounds.Y + 10);
        gradr.Position = waterpos;
        gradr.Size = Vector2.new(text.TextBounds.X + 11, text.TextBounds.Y + 10);
        text.Position = waterpos + Vector2.new(6, 5);
        text.Text = watertext;

        text.Visible = enabled;
        gradl.Visible = enabled;
        gradr.Visible = enabled;
        gradbackground.Visible = enabled;
        textbackground.Visible = enabled;
    end))
end
do

    local WorldTab = ui.box.world:AddTab("world visuals")
    local gradientenabled = false
    local gradientcolor1 = Color3.fromRGB(90, 90, 90)
    local gradientcolor2 = Color3.fromRGB(150, 150, 150)
    local time = 12
    local timechanger = false
    local nofog = false
    local noshadows = false
    WorldTab:AddToggle('enabletimechanger', {Text = 'enable time changer',Default = false,Callback = function(first)
        timechanger = first
    end})
    WorldTab:AddSlider('timechanger',{ Text = 'time changer', Default = mathround(Lighting.ClockTime), Min = 0, Max = 24, Rounding = 1, Compact = false }):OnChanged(function(State)
        time = State
    end)
    WorldTab:AddToggle('ambientswitch', {Text = 'enable ambient',Default = false,Callback = function(first)
        gradientenabled = first
    end}):AddColorPicker('ambientcolor', {Default = Color3.new(1, 1, 1),Title = 'ambient color1',Transparency = 0,Callback = function(Value)
        gradientcolor1 = Value
    end}):AddColorPicker('ambientcolor1',{Default = Color3.new(1, 1, 1),Title = 'ambient color2',Transparency = 0,Callback = function(Value)
        gradientcolor2 = Value
    end})
    WorldTab:AddToggle('grassswitch', {
        Text = 'no grass',
        Default = false,
        Callback = function(first)
            sethiddenproperty(_FindFirstChildOfClass(workspace, "Terrain"), "Decoration", not first)
        end
    })
    WorldTab:AddToggle('fogswitch', {
        Text = 'no fog',
        Default = false,
        Callback = function(first)
            nofog = first
        end
    })
    WorldTab:AddToggle('shadowswitch', {
        Text = 'no shadows',
        Default = false,
        Callback = function(first)
            noshadows = first
        end
    })
    cheat.utility.new_heartbeat(function()
        Lighting.GlobalShadows = not noshadows
        if gradientenabled then
            Lighting.Ambient = gradientcolor1
            Lighting.OutdoorAmbient = gradientcolor2
        end
        if timechanger then
            Lighting.ClockTime = time
        end
        Lighting.FogEnd = nofog and math.huge or 900
        Lighting.FogStart = nofog and math.huge or 0
    end)
end

do
    local cursor = {
        Enabled = false,
        CustomPos = false,
        Position = _Vector2new(0, 0),
        Speed = 5,
        Radius = 25,
        Color = Color3.fromRGB(180, 50, 255),
        Thickness = 1.7,
        Outline = false,
        Resize = false,
        Dot = false,
        Gap = 10,
        TheGap = false,
        Font = Drawing.Fonts.System,
        Text = {
            Logo = false,
            LogoColor = Color3.new(1, 1, 1),
            Name = false,
            NameColor = Color3.new(1, 1, 1),
            LogoFadingOffset = 0,
        }
    }
    local CrosshairTab = ui.box.world:AddTab("crosshair")
    cursor.rainbow = false
    cursor.sussy = false
    CrosshairTab:AddDropdown('espfont', {Values = { 'UI', 'System', 'Plex', 'Monospace' },Default = 2,Multi = false,Text = 'esp font',Tooltip = 'select font',Callback = function(Value)
        cursor.Font = Drawing.Fonts[Value]
    end})
    CrosshairTab:AddToggle('crosshairenable', {Text = 'enable crosshair',Default = false,Callback = function(first)
        cursor.Enabled = first
    end}):AddColorPicker('crosshaircolor', {Default = Color3.new(1, 1, 1),Title = 'crosshair color',Transparency = 0,Callback = function(Value)
        cursor.Color = Value
    end})
    CrosshairTab:AddSlider('crosshairspeed', {Text = 'speed',Default = 0,Min = 0,Max = 15,Rounding = 1,Compact = true}):OnChanged(function(State)
        cursor.Speed = State / 10
    end)
    CrosshairTab:AddSlider('crosshairradius', {Text = 'radius',Default = 25,Min = 0.1,Max = 100,Rounding = 1,Compact = true,}):OnChanged(function(State)
        cursor.Radius = State
    end)
    CrosshairTab:AddSlider('crosshairthickness', {Text = 'thickness',Default = 1.5,Min = 0.1,Max = 10,Rounding = 1,Compact = true,}):OnChanged(function(State)
        cursor.Thickness = State
    end)
    CrosshairTab:AddSlider('crosshairgapsize', {Text = 'gap',Default = 5,Min = 0,Max = 50,Rounding = 1,Compact = true,}):OnChanged(function(State)
        cursor.Gap = State
    end)
    CrosshairTab:AddToggle('crosshairenablegap', {Text = 'math divide gap',Default = false,Callback = function(first)
        cursor.TheGap = first
    end})
    CrosshairTab:AddToggle('crosshairenableoutline', {Text = 'outline',Default = false,Callback = function(first)
        cursor.Outline = first
    end})
    CrosshairTab:AddToggle('crosshairenableresize', {Text = 'resize animation',Default = false,Callback = function(first)
        cursor.Resize = first
    end})
    CrosshairTab:AddToggle('crosshairenabledot', {Text = 'dot',Default = false,Callback = function(first)
        cursor.Dot = first
    end})
    CrosshairTab:AddToggle('crosshairenablenazi', {Text = 'sussy',Default = false,Callback = function(first)
        cursor.sussy = first
        end})
        CrosshairTab:AddToggle('crosshairenablefaggot', {Text = 'rainbow',Default = false,Callback = function(first)
        cursor.rainbow = first
    end})
    CrosshairTab:AddToggle('crosshairtextLogo', {Text = 'text logo',Default = false,Callback = function(first)
        cursor.Text.Logo = first
    end}):AddColorPicker('crosshairlogocolor', {Default = Color3.new(1, 1, 1),Title = 'logo color',Transparency = 0,Callback = function(Value)
        cursor.Text.LogoColor = Value
    end})
    CrosshairTab:AddToggle('crosshairtextName', {Text = 'text name',Default = false,Callback = function(first)
        cursor.Text.Name = first
    end}):AddColorPicker('crosshairtextcolor', {Default = Color3.new(1, 1, 1),Title = 'text color',Transparency = 0,Callback = function(Value)
        cursor.Text.NameColor = Value
    end})
    CrosshairTab:AddSlider('crosshairlogooffset', {Text = 'logo fade offset',Default = 0,Min = 0,Max = 5,Rounding = 1,Compact = true}):OnChanged(function(State)
        cursor.Text.LogoFadingOffset = State
    end)

    
    local lines = {}
    
    local outline = cheat.utility.new_drawing("Square", {
        Visible = true,
        Size = _Vector2new(4, 4),
        Color = Color3.fromRGB(0, 0, 0),
        Filled = true,
        ZIndex = 1,
        Transparency = 1
    })
    
    local dot = cheat.utility.new_drawing("Square", {
        Visible = true,
        Size = _Vector2new(2, 2),
        Color = cursor.Color,
        Filled = true,
        ZIndex = 2,
        Transparency = 1
    })
    
    local logotext = cheat.utility.new_drawing("Text", {
        Visible = false,
        Font = cursor.Font,
        Size = 13,
        Color = Color3.fromRGB(138, 128, 255),
        ZIndex = 3,
        Transparency = 1,
        Text = "swimhub.xyz",
        Center = true,
        Outline = true,
    })
    local indicatortext = cheat.utility.new_drawing("Text", {
        Visible = false,
        Font = cursor.Font,
        Size = 13,
        Color = Color3.new(1, 1, 1),
        ZIndex = 3,
        Transparency = 1,
        Text = "",
        Center = true,
        Outline = true,
    })
    
    for i = 1, 4 do
        local line_outline = cheat.utility.new_drawing("Line", {
            Visible = true,
            From = _Vector2new(200, 500),
            To = _Vector2new(200, 500),
            Color = Color3.fromRGB(0, 0, 0),
            Thickness = cursor.Thickness + 2.5,
            ZIndex = 1,
            Transparency = 1
        })
        local line = cheat.utility.new_drawing("Line", {
            Visible = true,
            From = _Vector2new(200, 500),
            To = _Vector2new(200, 500),
            Color = cursor.Color,
            Thickness = cursor.Thickness,
            ZIndex = 2,
            Transparency = 1
        })
        local naziline = cheat.utility.new_drawing("Line", {
            Visible = true,
            From = _Vector2new(200, 500),
            To = _Vector2new(200, 500),
            Color = cursor.Color,
            Thickness = cursor.Thickness,
            ZIndex = 2,
            Transparency = 1
        })
        lines[i] = { line, line_outline, naziline }
    end
    local angle = 0
    local transp = 0
    local reverse = false
    local function setreverse(value)
        if reverse ~= value then
            reverse = value
        end
    end
    
    local pos, rainbow, rotationdegree, color = Vector2.zero, 0, 0, Color3.new()
    local math_cos, math_atan, math_pi, math_sin = math.cos, math.atan, math.pi, math.sin
    local function DEG2RAD(x) return x * math_pi / 180 end
    local function RAD2DEG(x) return x * 180 / math_pi end
    cheat.utility.new_renderstepped(LPH_NO_VIRTUALIZE(function(delta)
        if cursor.Enabled then
            rainbow = rainbow + (delta * 0.5)
            if rainbow > 1.0 then rainbow = 0.0 end
            color = Color3.fromHSV(rainbow, 1, 1)
            if cursor.CustomPos then pos = cursor.Position else pos = _Vector2new(
                Mouse.X,
                Mouse.Y + GuiInset.Y) end
            if cursor.rainbow then color = Color3.fromHSV(rainbow, 1, 1) else color = cursor.Color end
            if transp <= 1.5 + cursor.Text.LogoFadingOffset and not reverse then
                transp = transp + (((cursor.Speed == 0 and 1 or cursor.Speed) * 10) * delta)
                if transp >= 1.5 + cursor.Text.LogoFadingOffset then setreverse(true) end
            elseif reverse then
                transp = transp - (((cursor.Speed == 0 and 1 or cursor.Speed) * 10) * delta)
                if transp <= 0 - cursor.Text.LogoFadingOffset then setreverse(false) end
            end
            logotext.Position = _Vector2new(pos.X, (pos + _Vector2new(0, cursor.Radius + 5)).Y)
            logotext.Transparency = transp
            logotext.Visible = cursor.Text.Logo
            logotext.Color = cursor.Text.LogoColor
            logotext.Font = cursor.Font
            
            indicatortext.Position = _Vector2new(pos.X, (pos + _Vector2new(0, cursor.Radius + (cursor.Text.Logo and 19 or 5))).Y)
            indicatortext.Visible = modulecomm.indicator
            indicatortext.Color = cursor.Text.NameColor
            indicatortext.Font = cursor.Font
            indicatortext.Text = modulecomm.indicator_text

            if cursor.sussy then
                local frametime = delta
                local a = cursor.Radius - 10
                local gamma = math_atan(a / a)

                if rotationdegree >= 90 then rotationdegree = 0 end

                for i = 1, 4 do
                    local p_0 = (a * math_sin(DEG2RAD(rotationdegree + (i * 90))))
                    local p_1 = (a * math_cos(DEG2RAD(rotationdegree + (i * 90))))
                    local p_2 = ((a / math_cos(gamma)) * math_sin(DEG2RAD(rotationdegree + (i * 90) + RAD2DEG(gamma))))
                    local p_3 = ((a / math_cos(gamma)) * math_cos(DEG2RAD(rotationdegree + (i * 90) + RAD2DEG(gamma))))


                    lines[i][1].From = _Vector2new(pos.X, pos.Y)
                    lines[i][1].To = _Vector2new(pos.X + p_0, pos.Y - p_1)
                    lines[i][1].Color = color
                    lines[i][1].Thickness = cursor.Thickness
                    lines[i][1].Visible = true
                    lines[i][3].From = _Vector2new(pos.X + p_0, pos.Y - p_1)
                    lines[i][3].To = _Vector2new(pos.X + p_2, pos.Y - p_3)
                    lines[i][3].Color = color
                    lines[i][3].Thickness = cursor.Thickness
                    lines[i][3].Visible = true
                end
                rotationdegree = rotationdegree + ((cursor.Speed * frametime) * 1000)
            else
                angle = (cursor.Speed == 0 and 0 or angle + ((cursor.Speed * 10) * delta))

                if angle >= 90 then
                    angle = 0
                end

                
                dot.Visible = cursor.Dot
                dot.Color = color
                dot.Position = _Vector2new(pos.X - 1, pos.Y - 1)
                
                outline.Visible = cursor.Outline and cursor.Dot
                outline.Position = _Vector2new(pos.X - 2, pos.Y - 2)
                

                
                for index, line in pairs(lines) do
                    index = index
                    local x, y = {}, {}
                    local x1, y1 = {}, {}
                    if cursor.Resize then
                        x = { pos.X +
                        (math.cos(angle + (index * (math.pi / 2))) * (cursor.Radius + ((cursor.Radius * math.sin(angle)) / 9))),
                            pos.X +
                            (math.cos(angle + (index * (math.pi / 2))) * ((cursor.Radius - 20) - (cursor.TheGap and (((cursor.Radius - 20) * math.cos(angle)) / 4) or (((cursor.Radius - 20) * math.cos(angle)) - 4)))) }
                        y = { pos.Y +
                        (math.sin(angle + (index * (math.pi / 2))) * (cursor.Radius + ((cursor.Radius * math.sin(angle)) / 9))),
                            pos.Y +
                            (math.sin(angle + (index * (math.pi / 2))) * ((cursor.Radius - 20) - (cursor.TheGap and (((cursor.Radius - 20) * math.cos(angle)) / 4) or (((cursor.Radius - 20) * math.cos(angle)) - 4)))) }
                        x1 = { pos.X + (math.cos(angle + (index * (math.pi / 2))) * (cursor.Radius + 1)), pos
                        .X +
                        (math.cos(angle + (index * (math.pi / 2))) * ((cursor.Radius - 20 + 1) - (cursor.TheGap and ((cursor.Radius - 20 + 1) / cursor.Gap) or ((cursor.Radius - 20 + 1) - cursor.Gap)))) }
                        y1 = { pos.Y + (math.sin(angle + (index * (math.pi / 2))) * (cursor.Radius + 1)), pos
                        .Y +
                        (math.sin(angle + (index * (math.pi / 2))) * ((cursor.Radius - 20 + 1) - (cursor.TheGap and ((cursor.Radius - 20 + 1) / cursor.Gap) or ((cursor.Radius - 20 + 1) - cursor.Gap)))) }
                    else
                        x = { pos.X + (math.cos(angle + (index * (math.pi / 2))) * (cursor.Radius)), pos.X +
                        (math.cos(angle + (index * (math.pi / 2))) * ((cursor.Radius - 20) - (cursor.TheGap and ((cursor.Radius - 20) / cursor.Gap) or ((cursor.Radius - 20) - cursor.Gap)))) }
                        y = { pos.Y + (math.sin(angle + (index * (math.pi / 2))) * (cursor.Radius)), pos.Y +
                        (math.sin(angle + (index * (math.pi / 2))) * ((cursor.Radius - 20) - (cursor.TheGap and ((cursor.Radius - 20) / cursor.Gap) or ((cursor.Radius - 20) - cursor.Gap)))) }
                        x1 = { pos.X + (math.cos(angle + (index * (math.pi / 2))) * (cursor.Radius + 1)), pos
                        .X +
                        (math.cos(angle + (index * (math.pi / 2))) * ((cursor.Radius - 20 + 1) - (cursor.TheGap and ((cursor.Radius - 20 + 1) / cursor.Gap) or ((cursor.Radius - 20 + 1) - cursor.Gap)))) }
                        y1 = { pos.Y + (math.sin(angle + (index * (math.pi / 2))) * (cursor.Radius + 1)), pos
                        .Y +
                        (math.sin(angle + (index * (math.pi / 2))) * ((cursor.Radius - 20 + 1) - (cursor.TheGap and ((cursor.Radius - 20 + 1) / cursor.Gap) or ((cursor.Radius - 20 + 1) - cursor.Gap)))) }
                    end
                    
                    line[1].Visible = true
                    line[1].Color = color
                    line[1].From = _Vector2new(x[2], y[2])
                    line[1].To = _Vector2new(x[1], y[1])
                    line[1].Thickness = cursor.Thickness
                    
                    line[2].Visible = cursor.Outline
                    line[2].From = _Vector2new(x1[2], y1[2])
                    line[2].To = _Vector2new(x1[1], y1[1])
                    line[2].Thickness = cursor.Thickness + 2.5

                    line[3].Visible = false
                end
            end
        else
            dot.Visible = false
            outline.Visible = false
            logotext.Visible = false
            indicatortext.Visible = false
            
            for index, line in pairs(lines) do
                line[1].Visible = false
                line[2].Visible = false
                line[3].Visible = false
            end
        end
    end))
end

local LocalTab = ui.tabs and ui.tabs.tab
assert(LocalTab, "[ui] ui.tabs.tab is nil")
do
    local GravityEnabled = false
    local GravityValue = 1
    local OriginalGravity = workspace.Gravity  

    ui.box.Gravity = LocalTab:AddLeftTabbox()
    local GravityTab = ui.box.Gravity:AddTab('gravity')

    GravityTab:AddToggle('gravity_enabled', {
        Text = 'enabled',
        Default = GravityEnabled
    }):AddKeyPicker('gravityabuse_bind', {Default = 'None',SyncToggleState = true,Mode = 'Toggle',Text = 'gravity abuse',NoUI = false}):OnChanged(function(state)
        GravityEnabled = state

        if GravityEnabled then
            
            OriginalGravity = workspace.Gravity
            
            if not (modulecomm and modulecomm.speedhack) then
                workspace.Gravity = GravityValue * 196.2
            end
        else
            
            workspace.Gravity = OriginalGravity
        end
    end)

    GravityTab:AddSlider('gravity_value', {
        Text = 'gravity:',
        Suffix = '%',
        Default = GravityValue * 100,
        Min = 0, Max = 200, Rounding = 0
    }):OnChanged(function(val)
        GravityValue = val / 100
        if GravityEnabled and not (modulecomm and modulecomm.speedhack) then
            workspace.Gravity = GravityValue * 196.2
        end
    end)
end



do
    local sounds = {
        ["Defualt Headshot"] = "rbxassetid://9119561046",
        ["Defualt Body"]    = "rbxassetid://9114487369",
        Neverlose = "rbxassetid://8726881116",
        Gamesense = "rbxassetid://4817809188",
        One = "rbxassetid://7380502345",
        Bell = "rbxassetid://6534947240",
        Rust = "rbxassetid://1255040462",
        TF2 = "rbxassetid://2868331684",
        Slime = "rbxassetid://6916371803",
        ["Among Us"] = "rbxassetid://5700183626",
        Minecraft = "rbxassetid://4018616850",
        ["CS:GO"] = "rbxassetid://6937353691",
        Saber = "rbxassetid://8415678813",
        Baimware = "rbxassetid://3124331820",
        Osu = "rbxassetid://7149255551",
        ["TF2 Critical"] = "rbxassetid://296102734",
        Bat = "rbxassetid://3333907347",
        ["Call of Duty"] = "rbxassetid://5952120301",
        Bubble = "rbxassetid://6534947588",
        Pick = "rbxassetid://1347140027",
        Pop = "rbxassetid://198598793",
        Bruh = "rbxassetid://4275842574",
        Bamboo = "rbxassetid://3769434519",
        Crowbar = "rbxassetid://546410481",
        Weeb = "rbxassetid://6442965016",
        Beep = "rbxassetid://8177256015",
        Bambi = "rbxassetid://8437203821",
        Stone = "rbxassetid://3581383408",
        ["Old Fatality"] = "rbxassetid://6607142036",
        Click = "rbxassetid://8053704437",
        Ding = "rbxassetid://7149516994",
        Snow = "rbxassetid://6455527632",
        Laser = "rbxassetid://7837461331",
        Mario = "rbxassetid://2815207981",
        Steve = "rbxassetid://4965083997"
    }

    
    local soundKeys = {}
    for name in pairs(sounds) do
        table.insert(soundKeys, name)
    end
    table.sort(soundKeys) 

    local function ensureSound(name)
        local s = game:GetService("SoundService"):FindFirstChild(name)
        if not s then
            s = Instance.new("Sound")
            s.Name = name
            s.Parent = game:GetService("SoundService")
        end
        return s
    end

    local sHead = ensureSound("PlayerHitHeadshot")
    local sBody = ensureSound("PlayerHit2")

    ui.box.Hitsounds = ui.tabs.tab:AddLeftTabbox()
    local HitsoundsTab = ui.box.Hitsounds:AddTab('hitsounds')

    
    HitsoundsTab:AddToggle('hitsound_head_enabled', { Text = 'headshot enabled', Default = false })
        :OnChanged(function(state) sHead.Playing = state and sHead.SoundId ~= "" end)

    HitsoundsTab:AddDropdown('hitsound_head_dropdown', {
        Values = soundKeys,
        Default = 1, Multi = false, Text = 'Head Hitsound:'
    }):OnChanged(function(val)
        sHead.SoundId = sounds[val] or sHead.SoundId
        sHead.Playing = true
    end)

    HitsoundsTab:AddSlider('hitsound_head_volume', { Text = 'volume', Default = 5, Min = 0, Max = 10, Rounding = 0 })
        :OnChanged(function(vol) sHead.Volume = vol end)

    HitsoundsTab:AddSlider('hitsound_head_pitch', { Text = 'pitch', Default = 1, Min = 0, Max = 2, Rounding = 2 })
        :OnChanged(function(p) sHead.Pitch = p end)

    HitsoundsTab:AddInput('hitsound_head_custom', {
        Default = "rbxassetid://9119561046", Numeric = false, Finished = true,
        Text = 'custom sound:', Placeholder = "rbxassetid://9119561046"
    }):OnChanged(function(id) sHead.SoundId = id end)

    
    HitsoundsTab:AddToggle('hitsound_body_enabled', { Text = 'body enabled', Default = false })
        :OnChanged(function(state) sBody.Playing = state and sBody.SoundId ~= "" end)

    HitsoundsTab:AddDropdown('hitsound_body_dropdown', {
        Values = soundKeys,
        Default = 1, Multi = false, Text = 'Body Hitsound:'
    }):OnChanged(function(val)
        sBody.SoundId = sounds[val] or sBody.SoundId
        sBody.Playing = true
    end)

    HitsoundsTab:AddSlider('hitsound_body_volume', { Text = 'volume', Default = 5, Min = 0, Max = 10, Rounding = 0 })
        :OnChanged(function(vol) sBody.Volume = vol end)

    HitsoundsTab:AddSlider('hitsound_body_pitch', { Text = 'pitch', Default = 1, Min = 0, Max = 2, Rounding = 2 })
        :OnChanged(function(p) sBody.Pitch = p end)

    HitsoundsTab:AddInput('hitsound_body_custom', {
        Default = "rbxassetid://9114487369", Numeric = false, Finished = true,
        Text = 'custom sound:', Placeholder = "rbxassetid://9114487369"
    }):OnChanged(function(id) sBody.SoundId = id end)
end



do
    local AspectRatioEnabled = false
    local StretchValue = 100
    local Cam = workspace.CurrentCamera
    local OldNewIndex

    OldNewIndex = hookmetamethod(game, "__newindex", function(self, Key, Value)
        if self == Cam and Key == "CFrame" and AspectRatioEnabled then
            local X, Y, Z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = Value:GetComponents()
            Value = CFrame.new(
                X, Y, Z,
                R00, R01 * StretchValue/100, R02,
                R10, R11 * StretchValue/100, R12,
                R20, R21 * StretchValue/100, R22
            )
        end
        return OldNewIndex(self, Key, Value)
    end)

    ui.box.AspectRatio = LocalTab:AddLeftTabbox()
    local AspectTab = ui.box.AspectRatio:AddTab('aspect ratio')

    AspectTab:AddToggle('aspectratio_enabled', {
        Text = 'aspect ratio',
        Default = false
    }):OnChanged(function(state)
        AspectRatioEnabled = state
    end)

    AspectTab:AddSlider('aspectratio_value', {
        Text = 'ratio',
        Suffix = '%',
        Default = 100, Min = 1, Max = 200, Rounding = 0
    }):OnChanged(function(val)
        StretchValue = val
    end)
end


do
    local mvb = ui.box.move:AddTab('speedhack')
    local bhop_enabled, bhop_silent, bhop_silent_enabled, speed = false, false, false, 55
    local downcliff_mode, downcliff_start, downcliff_speed, downcliff_accel, downcliff_fall, downcliff_up = false, 50, 150, 50, 50, 50
    local jetpackabuse, abuseupspeed, abusedownspeed = false, 55, 0
    local forcesprint = false
    local slidin = false
    local tp_up_studs = 6
    mvb:AddToggle('speedhack_forcesprint', {Text = 'forcesprint',Default = false,Callback = function(first)
        forcesprint = first
    end})
    if SWG_Private then
        mvb:AddToggle('jetpackabuse', {Text = 'jetpack abuse',Default = false,Callback = function(first)
            jetpackabuse = first
        end}):AddKeyPicker('jetpackabuse_bind', {Default = 'None',SyncToggleState = true,Mode = 'Toggle',Text = 'jetpack abuse',NoUI = false})
        mvb:AddSlider('jetpackabuse_upspeed',{ Text = 'up speed', Default = 55, Min = 10, Max = 500, Rounding = 0, Suffix = "sps", Compact = false }):OnChanged(function(State)
            abuseupspeed = State
        end)
        mvb:AddSlider('jetpackabuse_downspeed',{ Text = 'down speed', Default = 55, Min = 10, Max = 500, Rounding = 0, Suffix = "sps", Compact = false }):OnChanged(function(State)
            abusedownspeed = State
        end)
        mvb:AddLabel("hold space to go up")
        mvb:AddLabel("hold shift to go down")
    else
        mvb:AddLabel("jetpack abuse: private only")
    end
    mvb:AddToggle('speedhack_enabled', {Text = 'speedhack enabled',Default = false,Callback = function(first)
        bhop_enabled = first
    end})
    mvb:AddSlider('speedhack_speed',{ Text = 'speed', Default = 55, Min = 55, Max = 70, Rounding = 0, Suffix = "sps", Compact = false }):OnChanged(function(State)
        speed = State
    end)
    mvb:AddSlider('speedhack_tp_up',{ Text = 'tp up studs', Default = 6, Min = 0, Max = 6, Rounding = 0, Compact = false }):OnChanged(function(State)
        tp_up_studs = State
    end)
    mvb:AddLabel("hold shift and C to speed")
    mvb:AddToggle('downcliff_mode',{ Text = 'downcliff mode',Default = false,Callback = function(first)
        downcliff_mode = first
    end})
    mvb:AddSlider('downcliff_accel',{ Text = 'acceleration', Default = 55, Min = 1, Max = 300, Rounding = 0, Suffix = "sps", Compact = false }):OnChanged(function(State)
        downcliff_accel = State
    end)
    mvb:AddSlider('downcliff_fall',{ Text = 'fall speed', Default = 55, Min = 10, Max = 200, Rounding = 0, Suffix = "sps", Compact = false }):OnChanged(function(State)
        downcliff_fall = State
    end)
    mvb:AddSlider('downcliff_up',{ Text = 'up speed', Default = 55, Min = 10, Max = 200, Rounding = 0, Suffix = "sps", Compact = false }):OnChanged(function(State)
        downcliff_up = State
    end)
    mvb:AddLabel("hold space to go up")
    
    local middle = workspace.Const.Ignore.LocalCharacter.Middle
    local bottom = workspace.Const.Ignore.LocalCharacter.Bottom
    local top = workspace.Const.Ignore.LocalCharacter.Top
    local characterparams = RaycastParams.new()
    characterparams.IgnoreWater = true
    characterparams.FilterDescendantsInstances = { workspace.Const.Ignore }
    characterparams.FilterType = Enum.RaycastFilterType.Exclude
    characterparams.RespectCanCollide = true

    local niga, wtf = speed, 0
    local dc_buildup, dc_oldpos = downcliff_speed, middle.Position

    cheat.utility.new_renderstepped(LPH_JIT_MAX(function(delta)
        local shiftpressed = _IsKeyDown(UserInputService, Enum.KeyCode.LeftShift)
        local cpressed = _IsKeyDown(UserInputService, Enum.KeyCode.C)
        local spacedown = _IsKeyDown(UserInputService, Enum.KeyCode.Space)
        local cameralook = Camera.CFrame.LookVector
        local direction if middle and (cpressed or spacedown or shiftpressed or forcesprint or jetpackabuse) then
            local neutralized_look = _Vector3new(cameralook.X, 0, cameralook.Z).Unit
            direction = Vector3.zero
            direction = _IsKeyDown(UserInputService, Enum.KeyCode.W) and direction + neutralized_look or direction;
            direction = _IsKeyDown(UserInputService, Enum.KeyCode.S) and direction - neutralized_look or direction;
            direction = _IsKeyDown(UserInputService, Enum.KeyCode.D) and direction + _Vector3new(- neutralized_look.Z, 0, neutralized_look.X) or direction;
            direction = _IsKeyDown(UserInputService, Enum.KeyCode.A) and direction + _Vector3new(neutralized_look.Z, 0, - neutralized_look.X) or direction;
        end
        if bhop_silent then return end
        wait()
        if bhop_enabled and not downcliff_mode and middle and cpressed and shiftpressed then
            if not (direction == Vector3.zero) then
                direction = direction.Unit
            end
            niga = math.clamp(niga-delta*20, 17, speed)
            if wtf == 0 then
                local tpcf, mdcf, bmcf = top.CFrame, middle.CFrame, bottom.CFrame
                middle.CFrame = mdcf + _Vector3new(0, tp_up_studs, 0)
                bottom.CFrame = bmcf + _Vector3new(0, tp_up_studs, 0)
                top.CFrame = tpcf + _Vector3new(0, tp_up_studs, 0)
            end
            middle.AssemblyLinearVelocity = (direction * niga) + (Vector3.yAxis * (wtf < 0.85 and 0 or -7))
            bottom.AssemblyLinearVelocity = (direction * niga) + (Vector3.yAxis * (wtf < 0.85 and 0 or -7))
            top.AssemblyLinearVelocity = (direction * niga) + (Vector3.yAxis * (wtf < 0.85 and 0 or -7))
            wtf = wtf + delta
        elseif bhop_enabled and downcliff_mode and middle and cpressed and shiftpressed then
            if not (direction == Vector3.zero) then
                direction = direction.Unit
            end

            

            local wattasigma = middle.Position
            local speed_dir = direction * dc_buildup * delta
            local verticalrc = _Raycast(workspace, wattasigma, -Vector3.yAxis * 20, characterparams)
            local horizontalrc = _Raycast(workspace, verticalrc and verticalrc.Position or wattasigma, speed_dir, characterparams)

            print(horizontalrc, vecrticalrc)
            print(horizontalrc and horizontalrc.Position, vecrticalrc and vecrticalrc.Position)

            dc_buildup = math.clamp(vecrticalrc and dc_buildup + downcliff_accel * math.abs(wattasigma.Y - verticalrc.Position.Y) or dc_buildup - delta * 30 , 17, 250)
            
            if horizontalrc or verticalrc then
                local middle_pos = (horizontalrc or verticalrc).Position + Vector3.yAxis * 1.5
                local bottom_offset = bottom.Position - middle_pos
                local top_offset = top.Position  - middle_pos
                middle.CFrame = _CFramenew(middle_pos)
                bottom.CFrame = _CFramenew(middle_pos + bottom_offset)
                top.CFrame = _CFramenew(middle_pos + top_offset)
                middle.AssemblyLinearVelocity = Vector3.zero 
                bottom.AssemblyLinearVelocity = Vector3.zero 
                top.AssemblyLinearVelocity = Vector3.zero 
            else
                middle.AssemblyLinearVelocity = (direction * dc_buildup) + (Vector3.yAxis * -7)
                bottom.AssemblyLinearVelocity = (direction * dc_buildup) + (Vector3.yAxis * -7)
                top.AssemblyLinearVelocity = (direction * dc_buildup) + (Vector3.yAxis * -7)
            end

            
        elseif jetpackabuse and middle then
            if not (direction == Vector3.zero) then
                direction = direction.Unit
            end
            local yvelo = spacedown and abuseupspeed or shiftpressed and -abusedownspeed or (not shiftpressed and not spacedown) and 0
            middle.AssemblyLinearVelocity = _Vector3new(
                direction.X * 18,
                yvelo,
                direction.Z * 18
            )
            top.AssemblyLinearVelocity = _Vector3new(
                direction.X * 18,
                yvelo,
                direction.Z * 18
            )
            bottom.AssemblyLinearVelocity = _Vector3new(
                direction.X * 18,
                yvelo,
                direction.Z * 18
            )
        else
            if forcesprint and middle then
                if not (direction == Vector3.zero) then
                    direction = direction.Unit
                end
                middle.AssemblyLinearVelocity = _Vector3new(
                    direction.X * 18,
                    middle.AssemblyLinearVelocity.Y,
                    direction.Z * 18
                )
            end
            niga = speed
            dc_buildup = 55
            dc_oldpos = middle.Position
            wtf = 0
        end
    end))
end

do
    local mvb = ui.box.move:AddTab('exploits')
    local enabled, speed, part = false, 55, "bottom"
    mvb:AddToggle('desync_enabled', {Text = 'desync enabled', Default = false, Tooltip = 'Desync works best in jump — breaks prediction. If you turn it on while walking or in jump, it will break prediction in every script', Callback = function(first)
    modulecomm.invis = first
    end}):AddKeyPicker('desyncbind', {Default = 'None', SyncToggleState = true, Mode = 'Toggle', Text = 'desync', NoUI = false, Tooltip = 'Keybind to toggle desync'})
    mvb:AddToggle('seminoclip_enabled', {Text = 'seminoclip enabled', Default = false, Tooltip = 'semi noclip?', Callback = function(first)
    modulecomm.seminoclip = first
    end}):AddKeyPicker('seminoclipbind', {Default = 'None', SyncToggleState = true, Mode = 'Toggle', Text = 'seminoclip', NoUI = false, Tooltip = 'Keybind to toggle Noclip'})
    mvb:AddToggle('godmode', {Text = 'untrusted angle',Default = false,Callback = function(first)
        modulecomm.godmode = first
    end}):AddKeyPicker('godmodebind', {Default = 'None',SyncToggleState = true,Mode = 'Toggle',Text = 'untrusted angle',NoUI = false})
    mvb:AddSlider('godmode_strenght',{ Text = 'strenght', Default = 6, Min = 0, Max = 20, Rounding = 1, Suffix = "s", Compact = false }):OnChanged(function(State)
        modulecomm.godmode_strenght = State
    end)
    mvb:AddToggle('spider', {Text = 'spider',Default = false,Callback = function(first)
        modulecomm.spider = first
    end}):AddKeyPicker('spiderbind', {Default = 'None',SyncToggleState = true,Mode = 'Toggle',Text = 'spider',NoUI = false})
    mvb:AddToggle('velocitybreaker', {Text = 'velocity breaker',Default = false,Callback = function(first)
        modulecomm.velobreak = first
    end}):AddKeyPicker('velocitybreakerbind', {Default = 'None',SyncToggleState = true,Mode = 'Toggle',Text = 'velocity breaker',NoUI = false})
    mvb:AddSlider('velocitybreaker_strenght',{ Text = 'strenght', Default = 6, Min = 0, Max = 20, Rounding = 1, Suffix = "s", Compact = false }):OnChanged(function(State)
        modulecomm.velobreakstrenght = State
    end)
    mvb:AddToggle('silentwalk_enabled', {Text = 'silent walking',Default = false,Callback = function(first)
        modulecomm.silentwalk = first
        if first then trident.tcp:FireServer(2, true) end
    end}):AddKeyPicker('silentwalk_bind', {Default = 'None',SyncToggleState = true,Mode = 'Toggle',Text = 'silent walk',NoUI = false})
    local freecamoffset = Vector3.zero
    local middle = workspace.Const.Ignore.LocalCharacter.Middle
    local bottom = workspace.Const.Ignore.LocalCharacter.Bottom
    local top = workspace.Const.Ignore.LocalCharacter.Top
    local mdpos, bmpos, tppos = middle.CFrame, bottom.CFrame, top.CFrame
    mvb:AddToggle('freecam_enabled', {Text = 'freecam enabled',Default = false,Callback = function(first)
        enabled = first
        modulecomm.invis2 = first
        middle.CanCollide = not first
        bottom.CanCollide = not first
        top.CanCollide = not first
    end}):AddKeyPicker('freecam_bind', {Default = 'None',SyncToggleState = true,Mode = 'Toggle',Text = 'freecam',NoUI = false})
    mvb:AddSlider('freecam_speed',{ Text = 'speed', Default = 10, Min = 1, Max = 150, Rounding = 0, Suffix = "sps", Compact = false }):OnChanged(function(State)
        speed = State
    end)
    mvb:AddDropdown('freecam_part', {Values={"middle", "bottom", "top"},Default = 1,Multi = false,Text = 'freecam part',Callback=function(Value)
        part = Value
    end})
    mvb:AddToggle('silentaim_extended', {Text = 'Extended manipulation',Default = false,Callback = function(Value)
        modulecomm.extended_manipulation = Value
    end}):AddKeyPicker('Extended manipulation', {Default = 'None',SyncToggleState = true,Mode = 'Toggle',Text = 'Extended manipulation',NoUI = false})
    mvb:AddToggle('infiniteunregtechnique', {Text = 'infinite register technique',Default = false,Callback = function(first)
        modulecomm.infiniteregister = first
    end})
    --mvb:AddToggle('0_ping', {Text = '0 ping',Default = false,Callback = function(first)
    --    modulecomm.zero_ping = first
    --end})
    cheat.utility.new_heartbeat(LPH_JIT_MAX(function(delta)
        if enabled and middle then
            if part == "middle" then middle.CFrame = mdpos end
            if part == "bottom" then bottom.CFrame = bmpos end
            if part == "top" then top.CFrame = tppos end
            RunService.RenderStepped:Wait()
            if middle then
                local cameralook = Camera.CFrame.LookVector
                local direction = Vector3.zero
                direction = _IsKeyDown(UserInputService, Enum.KeyCode.W) and direction + cameralook or direction;
                direction = _IsKeyDown(UserInputService, Enum.KeyCode.S) and direction - cameralook or direction;
                direction = _IsKeyDown(UserInputService, Enum.KeyCode.D) and direction + _Vector3new(- cameralook.Z, 0, cameralook.X) or direction;
                direction = _IsKeyDown(UserInputService, Enum.KeyCode.A) and direction + _Vector3new(cameralook.Z, 0, - cameralook.X) or direction;
                if not direction == Vector3.zero then
                    direction = direction.Unit
                end
                freecamoffset = freecamoffset + (direction * delta * speed)
                if part == "middle" then middle.CFrame = mdpos + freecamoffset end
                if part == "bottom" then bottom.CFrame = bmpos + freecamoffset end
                if part == "top" then top.CFrame = tppos + freecamoffset end
                middle.AssemblyLinearVelocity = Vector3.zero
                bottom.AssemblyLinearVelocity = Vector3.zero
                top.AssemblyLinearVelocity = Vector3.zero
            end
        elseif middle then
            freecamoffset = Vector3.zero
            mdpos, bmpos, tppos = middle.CFrame, bottom.CFrame, top.CFrame
        end
    end))
end
cheat.utility.new_heartbeat(function()
if modulecomm.seminoclip then
    workspace.Const.Ignore.LocalCharacter.Bottom.Size = Vector3.new(0.15, 0.15, 0.15)
    modulecomm.forseminoclip = true
end
if not modulecomm.seminoclip then 
    modulecomm.forseminoclip = false
end
end)
cheat.utility.new_heartbeat(function()
if not modulecomm.seminoclip then
workspace.Const.Ignore.LocalCharacter.Bottom.Size = Vector3.new(3, 3, 3)
end
end)
cheat.utility.new_heartbeat(function(delta)
    if modulecomm.spider then
        local function rotateVector(v, axis, angle)
            local cos = math.cos(angle)
            local sin = math.sin(angle)
            local dot = axis:Dot(v)
            local cross = axis:Cross(v)
            return v * cos + cross * sin + axis * dot * (1 - cos)
        end

        local radius = 40
        local length = 2
        local rays_per_3_units = 1
        local num_rays = math.max(1, math.floor(radius / 3))
        local angle_step = num_rays > 1 and (2 * math.pi / num_rays) or 0

        local parts = {
            workspace.Const.Ignore.LocalCharacter.Middle,
            workspace.Const.Ignore.LocalCharacter.Bottom,
            workspace.Const.Ignore.LocalCharacter.Top
        }

        for _, part in ipairs(parts) do
            if part then
                local original_dir = part.CFrame.LookVector * length
                local axis = part.CFrame.UpVector
                local should_apply = false

                for i = 1, num_rays do
                    local angle = i * angle_step
                    local dir = rotateVector(original_dir, axis, angle)
                    local ray = Ray.new(part.Position, dir)
                    local hit, _ = workspace:FindPartOnRay(ray, workspace.Const.Ignore.LocalCharacter.Top)
                    local hit2, _ = workspace:FindPartOnRay(ray, workspace.Const.Ignore.LocalCharacter.Middle)

                    if hit and hit2 then
                        should_apply = true
                        break
                    end
                end

                if should_apply then
                    part.AssemblyLinearVelocity = Vector3.new(
                        part.AssemblyLinearVelocity.X,
                        10,
                        part.AssemblyLinearVelocity.Z
                    )
                end
            end
        end
    end
end)
local activeProjectiles = {}

__gamenamecall = hookmetamethod(game, "__namecall", newcclosure(LPH_NO_VIRTUALIZE(function(self, ...)
    if typeof(self) ~= "Instance" then
        return __gamenamecall(self, ...)
    end

    local method = getnamecallmethod()
    local args = {...}

    if method == "FireServer" and (self == trident.tcp or self == trident.udp) then
        if args[1] == 10 and args[2] == "Fire" and modulecomm.infiniteregister then
            local projId = args[3]
            if projId then
                activeProjectiles[projId] = {
                    time  = tick(),
                    gun   = trident.guninfo,
                    muzzle = typeof(args[4]) == "CFrame" and args[4].p or nil
                }
            end
        end
    end
    return __gamenamecall(self, ...)
end))
)

local WeaponCooldown = {}
local originalValues: {[string]: number} = {}

local weaponTypes = {
    "UZI", "USP9", "PumpShotgun", "PipeSMG", "PipePistol", "LeverActionRifle",
    "GaussRifle", "M4A1", "SCAR", "SVD", "AR15", "C9", "Magnum"
}


local function initDefaults()
    for _, typeName in ipairs(weaponTypes) do
        for _, v in getgc(true) do
            if typeof(v) == "table" and rawget(v, "AttackCooldown") and tostring(rawget(v, "type")) == typeName then
                originalValues[typeName] = v.AttackCooldown
                break 
            end
        end
    end
end


local function applyToType(typeName: string, value: number)
    for _, v in getgc(true) do
        if typeof(v) == "table" and rawget(v, "AttackCooldown") and tostring(rawget(v, "type")) == typeName then
            v.AttackCooldown = (value / 100) * 10
        end
    end
end


local function restoreType(typeName: string)
    for _, v in getgc(true) do
        if typeof(v) == "table" and rawget(v, "AttackCooldown") and tostring(rawget(v, "type")) == typeName then
            if originalValues[typeName] then
                v.AttackCooldown = originalValues[typeName]
            end
        end
    end
end


for _, weapon in ipairs(weaponTypes) do
    WeaponCooldown["Apply_" .. weapon] = function(value: number)
        applyToType(weapon, value)
    end
    WeaponCooldown["Restore_" .. weapon] = function()
        restoreType(weapon)
    end
end


local mvb = ui.box.misc:AddTab("Rapid fire")
for _, weapon in ipairs(weaponTypes) do
    mvb:AddSlider("cooldown_" .. weapon, {
        Text = weapon .. " Cooldown",
        Default = 1,
        Min = 0,
        Max = 10,
        Rounding = 1,
        Compact = false,
        Callback = function(val: number)
            WeaponCooldown["Apply_" .. weapon](val)
        end
    })
end


initDefaults()
do
    local mvb = ui.box.atvfly:AddTab('atv fly')
    local carfly_enabled, speed, accel, upspeed = false, 55, 100, 200
    mvb:AddToggle('carfly_enabled', {Text = 'car fly enabled',Default = false,Callback = function(first)
        carfly_enabled = first
    end}):AddKeyPicker('carfly_bind', {Default = 'None',SyncToggleState = true,Mode = 'Toggle',Text = 'car fly bind',NoUI = false})
    mvb:AddSlider('carfly_speed',{ Text = 'speed', Default = 150, Min = 50, Max = 300, Rounding = 0, Suffix = "sps", Compact = false }):OnChanged(function(State)
        speed = State
    end)
    mvb:AddSlider('carfly_upspeed',{ Text = 'up speed', Default = 15, Min = 5, Max = 30, Rounding = 0, Suffix = "sps", Compact = false }):OnChanged(function(State)
        upspeed = State
    end)
    mvb:AddSlider('carfly_accel',{ Text = 'acceleration', Default = 100, Min = 10, Max = 300, Rounding = 0, Suffix = "sps", Compact = false }):OnChanged(function(State)
        accel = State
    end)
    mvb:AddLabel("hold V to go up")
    mvb:AddLabel("hold B to go down")
    local car, dist = nil, 50
    local findcar = function()
        car, dist = nil, 50
        for i,v in pairs(workspace:GetChildren()) do
            if _FindFirstChild(v, "Seat") and _FindFirstChild(v, "Frame") then
                if (v.Frame.Position - trident.middlepart.Position).Magnitude < dist then
                    car = v
                    dist = (v.Frame.Position - trident.middlepart.Position).Magnitude
                end
            end
        end
    end
    findcar()
    local buildup = 0
    local lastdir = _Vector3new(1,0,0)
    cheat.utility.new_renderstepped(LPH_JIT_MAX(function(delta)
        if carfly_enabled and car and _FindFirstChild(car, "Frame") and (car.Frame.CFrame.p - Camera.CFrame.p).Magnitude <= 50 then
            local cameralook = Camera.CFrame.LookVector
            cameralook = _Vector3new(cameralook.X, 0, cameralook.Z)
            local direction = Vector3.zero
            direction = _IsKeyDown(UserInputService, Enum.KeyCode.W) and direction + cameralook or direction;
            direction = _IsKeyDown(UserInputService, Enum.KeyCode.S) and direction - cameralook or direction;
            direction = _IsKeyDown(UserInputService, Enum.KeyCode.D) and direction + _Vector3new(- cameralook.Z, 0, cameralook.X) or direction;
            direction = _IsKeyDown(UserInputService, Enum.KeyCode.A) and direction + _Vector3new(cameralook.Z, 0, - cameralook.X) or direction;
            direction = _IsKeyDown(UserInputService, Enum.KeyCode.V) and direction + Vector3.yAxis or direction;
            direction = _IsKeyDown(UserInputService, Enum.KeyCode.B) and direction - Vector3.yAxis or direction;
            if direction ~= Vector3.zero then
                direction = direction.Unit
                if direction ~= _Vector3new(0, 1, 0) then
                    buildup = math.clamp(buildup + delta * accel, 0, speed)
                    lastdir = direction
                end
            else
                direction = lastdir
                buildup = math.clamp(buildup - delta * 100, 0, speed)
            end
            for i,v in pairs(car:GetChildren()) do
                v.AssemblyLinearVelocity = _Vector3new(direction.X * buildup, direction.Y * upspeed, direction.Z * buildup)
                
                
            end
        elseif not car or car and car:FindFirstChild("Frame") and (car.Frame.CFrame.p - Camera.CFrame.p).Magnitude > 50 then
            findcar()
            buildup = 0
        else
            buildup = 0
        end
    end))
do
    local noatvrestriction = false
    local charactermod = ui.box.misc:AddTab("atv mods")
    charactermod:AddToggle('noatvrestriction', {Text = 'no atv restriction',Default = false,Callback = function(first)
        noatvrestriction = first
    end})
    do
        
        
        local aaset = modulecomm.antiaim
        charactermod:AddToggle('antiaim_carenabled', {Text = 'car antiaim',Default = false,Callback = function(first)
            aaset.car = first
        end})
        charactermod:AddDropdown('antiaim_cartrip', {Values={"none", "zero", "random", "pizdec"},Default = 1,Multi = false,Text = 'trip mode',Callback=function(Value)
            aaset.cartripmode = Value
        end})
        do
            local depbox = charactermod:AddDependencyBox();
            depbox:AddSlider('antiaim_cartriprandomspeed',{Text = 'trip random speed',Default = 1,Min = 0.1,Max = 50,Rounding = 1,Compact = true,Callback = function(State)
                aaset.cartriprandomspeed = State
            end})
            depbox:SetupDependencies({
                { cheat.Options.antiaim_cartrip, "random" }
            });
        end
        charactermod:AddDropdown('antiaim_caryaw', {Values={"none", "spin", "random", "pizdec"},Default = 1,Multi = false,Text = 'car yaw',Callback=function(Value)
            aaset.caryaw = Value
        end})
        do
            local aadepbox = charactermod:AddDependencyBox();
            aadepbox:AddSlider('antiaim_carspinspeed',{Text = 'spin speed (rpm)',Default = 60,Min = 60,Max = 360,Rounding = 0,Compact = true,Callback = function(State)
                aaset.carspinspeed = State
            end})
            aadepbox:SetupDependencies({
                { cheat.Options.antiaim_caryaw, "spin" }
            });
        end
        do
            local aadepbox = charactermod:AddDependencyBox();
            aadepbox:AddSlider('antiaim_caryawrandomspeed',{Text = 'yaw random speed',Default = 1,Min = 0.1,Max = 50,Rounding = 1,Compact = true,Callback = function(State)
                aaset.caryawrandomspeed = State
            end})
            aadepbox:SetupDependencies({
                { cheat.Options.antiaim_caryaw, "random" }
            });
        end
    end
    task.spawn(function()
        while wait() do if noatvrestriction then
            setupvalue(garbage.maxlooky, 1, 10000)
        end end
    end)
end
do
    local real_extended = 0
    local game_Lighting = game:GetService("Lighting")
    local torso_spoofed_index = {
        ["Transparency"] = trident.original_model["Torso"]["Transparency"],
        ["CanCollide"] = trident.original_model["Torso"]["CanCollide"],
        ["Size"] = trident.original_model["Torso"]["Size"]
    }
    local lighting_oldvalues = {
        ["Ambient"] = game_Lighting.Ambient,
        ["OutdoorAmbient"] = game_Lighting.OutdoorAmbient,
        ["FogStart"] = game_Lighting.FogStart,
        ["FogEnd"] = game_Lighting.FogEnd,
        ["GlobalShadows"] = game_Lighting.GlobalShadows,
        ["ClockTime"] = game_Lighting.ClockTime,
        ["TimeOfDay"] = game_Lighting.TimeOfDay
    }
    local __gameindex; __gameindex = hookmetamethod(game, "__index", newcclosure(LPH_NO_VIRTUALIZE(function(self, idx)
        
        if typeof(self) ~= "Instance" then return __gameindex(self, idx) end
        if (idx == "CanCollide" or idx == "Size" or idx == "Transparency") and self.Name == "Torso" and torso_spoofed_index[idx] then
            return torso_spoofed_index[idx]
        end
        if self == game_Lighting and lighting_oldvalues[idx] then
            return lighting_oldvalues[idx]
        end
        return __gameindex(self, idx)
    end)))
    local __gamenewindex; __gamenewindex = hookmetamethod(game, "__newindex", newcclosure(LPH_NO_VIRTUALIZE(function(self, idx, val)
        
        if typeof(self) ~= "Instance" then return __gamenewindex(self, idx, val) end
        if self == game_Lighting then
            lighting_oldvalues[idx] = val
            
        end
        return __gamenewindex(self, idx, val)
    end)))
    local __gamenamecall; __gamenamecall = hookmetamethod(game, "__namecall", newcclosure(LPH_NO_VIRTUALIZE(function(self, ...)
        
        if typeof(self) ~= "Instance" then return __gamenamecall(self, ...) end

        local method = getnamecallmethod()
        local args = {...}
        if method == "Raycast" and modulecomm.simulation_pos and args[3].CollisionGroup == "WeaponRaycast" then
            local target = modulecomm.target
            if target[1] and target[2] then
                local guninfo = trident.guninfo
                local proj_speed = guninfo and rawget(guninfo, "ProjectileSpeed")
                if guninfo and proj_speed then
                   return {
                        Instance = target[1],
                        Position = target[1].Position,
                        Normal = Vector3.new(0, 0, 0),
                        Material = target[1].Material,
                        Distance = (target[1].Position - args[1]).Magnitude
                    }
                end
                return __gamenamecall(self, unpack(args))
            end
        end
        if method == "FireServer" and (self == trident.tcp or self == trident.udp) then
            if args[1] == 46 then
                if typeof(args[3]) == "Vector3" and modulecomm.antiaim.car then
                    local aaset = modulecomm.antiaim
                    local pitch, roll do 
                        local tripmode = aaset.cartripmode
                        pitch = (
                            tripmode == "none" and args[4].X or
                            
                            
                            tripmode == "zero" and 0 or
                            tripmode == "random" and math.sin(tick() * aaset.cartriprandomspeed) * math.rad(70) or
                            tripmode == "pizdec" and math.sin(tick() * 360) * math.rad(80) or
                            args[4].Y or 0
                        )
                        roll = (
                            tripmode == "none" and args[4].Z or
                            
                            
                            tripmode == "zero" and 0 or
                            tripmode == "random" and math.cos(tick() * aaset.cartriprandomspeed) * math.rad(70) or
                            tripmode == "pizdec" and math.cos(tick() * 360) * math.rad(80) or
                            args[4].Z or 0
                        )
                    end
local yaw do
    -- antiaimyaw = "none", -- none, spin, static, jitter, invisible
    local yawset = aaset.antiaimyaw
    yaw = (
        (yawset == "static" or yawset == "jitter") and 
        (args[3].X + (math.rad(aaset.yawoffset) - (aaset.backwards and math.pi or 0)))
    ) or 0
    yaw = (
        yawset == "none" and args[3].Y or
        yawset == "spin" and (tick() % 1) * ((aaset.spinspeed / 360) * math.pi) or
        yawset == "invisible" and math.huge or
        yawset == "jitter" and math.rad((real_extended % 2 == 0 and 1 or -1) * (aaset.yawjittersize / 2)) or
        yaw or 0 -- womp womp
        -- for every skid out here, im 14 and i did this math all by myself
        -- don't ask me the reasons of whys
        -- except spin
    )
end
                    args[4] = _Vector3new(pitch, yaw, roll)
                end
            end
            if args[1] == 1 then

                real_extended = real_extended + 1

                if real_extended % 2 >= 1 and modulecomm.extended_manipulation then
                    args[5] = nil
                    return __gamenamecall(self, unpack(args))
                end

                if modulecomm.velobreak then
                    if real_extended % 4 == 0 or real_extended % 4 == 2 then
                        args[5] = nil
                    end
                    args[2] = args[2] + (real_extended % 4 == 1 and Vector3.zero or Vector3.yAxis * modulecomm.velobreakstrenght)
                    return __gamenamecall(self, unpack(args))
                end

                if modulecomm.invis then
                    args[5] = nil
                    return __gamenamecall(self, unpack(args))
                end
                    --[[
                        l_NetClient_0.SendTCP(
                            l_SendCodes_0.INV_USE_ITEM,
                            "Fire",
                            projid,
                            cf_origin
                        );
                    ]]
                    --[[
                        l_NetClient_0.SendTCP(
                            l_SendCodes_0.INV_USE_ITEM,
                            "Hit",
                            projid,
                            time,
                            entity.id,
                            raycastres.Instance.Name,
                            raycastres.Position - entity.model.PrimaryPart.Position,
                            raycastres.Position
                        );
                    ]]
                if modulecomm.invis2 then
                    args[5] = nil
                    return __gamenamecall(self, unpack(args))
                end
                trident.lastpos = args[2] + _Vector3new(0, 3, 0)

                if typeof(args[3]) == "Vector3" and modulecomm.antiaim.antiaim then
                    local aaset = modulecomm.antiaim
                    if aaset.antiaimyaw == "invisible" then
                        args[3] = Vector3int16.new(0, math.huge, 0)
                        return __gamenamecall(self, unpack(args))
                    elseif aaset.antiaimyaw == "invisible2" then
                        args[3] = Vector3int16.new(math.huge, 0, 0)
                        return __gamenamecall(self, unpack(args))
                    end
                    local pitch do 
                        local pitchset = aaset.antiaimpitch
                        pitch = (
                            pitchset == "none" and args[3].Y or
                            pitchset == "down" and -1.5 or
                            pitchset == "up" and 1.5 or
                            pitchset == "jitter" and (real_extended % 2 == 0 and -1.5 or 1.5) * (aaset.pitchjittersize / 90) or
                            pitchset == "random" and math.sin(tick() * aaset.pitchrandomspeed) * math.rad(90) or
                            pitchset == "custom" and 1.5 * (aaset.pitchcustom / 90) or
                            args[3].Y or 0
                        )
                    end
local yaw do
    
    local yawset = aaset.antiaimyaw
    yaw = (
        (yawset == "static" or yawset == "jitter") and 
        (args[3].X + math.rad(aaset.yawoffset + (aaset.backwards and 180 or 0)))
    ) or 0
    yaw = (
        yawset == "none" and args[3].Y or
        yawset == "spin" and ((args[3].X - (aaset.backwards and math.pi or 0) + math.rad(aaset.yawoffset)) + ((tick() * ((aaset.spinspeed / 60) * (2 * math.pi))) % (2 * math.pi))) or
        yawset == "invisible" and math.huge or
        yawset == "random" and math.sin(tick() * aaset.yawrandomspeed) * math.pi or
        yawset == "jitter" and math.rad((real_extended % 2 == 0 and 1 or -1) * aaset.yawjittersize) or 
        yawset == "custom" and math.rad(aaset.yawcustom + 360 + args[3].X - (aaset.backwards and 180 or 0)) or
        yaw or 0
        
        
        
        
    )
end
                    args[3] = _Vector3new(pitch, yaw, 0)
                end
            end
        if args[1] == 1 and modulecomm.godmode then
            args[2] = Vector3.new(args[2].X, args[2].Y + modulecomm.godmode_strenght, args[2].Z)
        end
        if args[1] == 1 and modulecomm.forseminoclip then
            args[2] = Vector3.new(args[2].X, args[2].Y + 1.5, args[2].Z)
        end
            if args[1] == 2 and modulecomm.silentwalk then
                return __gamenamecall(self, 2, true)
            end
            if args[1] == 10 then
                if args[2] == "Fire" and typeof(args[4]) == "CFrame" and modulecomm.simulation and modulecomm.simulation_pos then


                    
                    
                    
                    
                        

                    local target = modulecomm.target
                    local guninfo    = trident.guninfo
                    local proj_speed = guninfo and rawget(guninfo, "ProjectileSpeed")
                    local proj_drop  = guninfo and rawget(guninfo, "ProjectileDrop") or 0
                    if target[1] and target[2] and guninfo and proj_speed then
                        
                        create_cool_beam(args[4].p, target[1].Position, Color3.new(0,1,0), true)
                        args[4] = CFrame.lookAt(
                            args[4].p,
                            modulecomm.simulation_pos +
                            _Vector3new(0, predict_drop_position(modulecomm.simulation_pos, proj_speed, proj_drop, args[4].p), 0)
                        )
                        return __gamenamecall(self, unpack(args))
                    end
                end
                if args[2] == "Hit" and type(args[5]) == "number" and type(args[6]) == "string" and typeof(args[7]) == "Vector3" then
                    local entity = rawget(getupvalue(garbage.entitylist, 1), args[5])
                    local entitymodel = entity and rawget(entity, "model")
                    local entityhead = entitymodel and _FindFirstChild(entitymodel, "Head")
                    if entityhead then

                        if modulecomm.forcehead then args[6] = "Head" end

                        local part = _FindFirstChild(entitymodel, args[6])
                        local originalpart = _FindFirstChild(trident.original_model, args[6])
                        if not (part and originalpart) then return __gamenamecall(self, unpack(args)) end
                         local simpos = modulecomm.simulation_pos

                        if modulecomm.hitboxes or simpos then
                            local primarypart = entitymodel.PrimaryPart
                            local partoffset = part.Position - primarypart.Position
                            args[7] = _Vector3new(
                                math.random(-originalpart.Size.X, originalpart.Size.X),
                                math.random(-originalpart.Size.Y, originalpart.Size.Y),
                                math.random(-originalpart.Size.Z, originalpart.Size.Z)
                            ) + partoffset
                        end
                        if simpos then
                            local target = modulecomm.target
                            local guninfo = trident.guninfo
                            local proj_speed = guninfo and rawget(guninfo, "ProjectileSpeed")
                            local proj_drop  = guninfo and rawget(guninfo, "ProjectileDrop") or 0
                            if not (target[1] and target[2]) then return __gamenamecall(self, unpack(args)) end
                            local drop, time = predict_drop_position(simpos, proj_speed, proj_drop, Camera.CFrame.p)
                            args[4] = (simpos - Camera.CFrame.p).Magnitude / proj_speed
                            args[8] = simpos
                            create_cool_beam(Camera.CFrame.p, args[8], Color3.new(1,1,1), true)
                            task.spawn(function()
                                task.wait(args[4])
                                self.FireServer(self, unpack(args))
                            end)
                                return
                            end
                            end
                        end
                        end
                    return __gamenamecall(self, unpack(args))
                end
            return __gamenamecall(self, ...)
        end)))
    end
end
ui.box.themeconfig:AddToggle('keybindshoww', {Text = 'show keybinds',Default = false,Callback = function(first)cheat.Library.KeybindFrame.Visible = first end})
cheat.ThemeManager:SetOptionsTEMP(cheat.Options, cheat.Toggles)
cheat.SaveManager:SetOptionsTEMP(cheat.Options, cheat.Toggles)
cheat.ThemeManager:SetLibrary(cheat.Library)
cheat.SaveManager:SetLibrary(cheat.Library)
cheat.SaveManager:IgnoreThemeSettings()
cheat.ThemeManager:SetFolder('swimhub')
cheat.SaveManager:SetFolder('swimhub')
cheat.SaveManager:BuildConfigSection(ui.tabs.config)
cheat.ThemeManager:ApplyToGroupbox(ui.box.themeconfig)

cheat.EspLibrary.load()
local FIXED_FONT = Enum.Font.Gotham

local function fixFontAnywhere(obj)
    if typeof(obj) ~= "Instance" then return end
    pcall(function()
        obj.Font = FIXED_FONT
    end)

    for _, child in pairs(obj:GetChildren()) do
        fixFontAnywhere(child)
    end
end

local CoreGui = game:GetService("CoreGui")
fixFontAnywhere(CoreGui)
local a = game:GetService("Players")
local b = game:GetService("RunService")
local c = workspace.CurrentCamera
local d = a.LocalPlayer
local e = game:GetService("UserInputService")
local g = {}
local drawingsEnabled = true
local n = {
    {partName = "Body", partSize = Vector3.new(2.5, 6.25, 2.5), espLabel = "TC", espColor = Color3.new(0, 1, 0)},
    {partName = "Crates", partSize = Vector3.new(5.803810119628906, 2.7799904346466064, 5.775084972381592), espLabel = "Airdrop", espColor = Color3.new(1.000000, 0.098039, 0.000000)},
    {partName = "Prim", partSize = Vector3.new(3, 0.25, 3), espLabel = "x", espColor = Color3.new(0.000000, 0.478431, 0.866667)},
    {partName = "Bottom", partSize = Vector3.new(2.9763996601104736, 2.150311231613159, 6.314671516418457), espLabel = "MilitaryCrate", espColor = Color3.new(0.043137, 0.611765, 0.090196)},
    {partName = "Hitbox", partSize = Vector3.new(4.5, 6.75, 2.25), espLabel = "l", espColor = Color3.new(1, 0, 0)},
    {partName = "Plastics2", partSize = Vector3.new(5.546261787414551, 1.9555978775024414, 3.854473352432251), espLabel = "ATV", espColor = Color3.new(1.000000, 0.000000, 0.000000)},
    {partName = "Prim", partSize = Vector3.new(1.8424512147903442, 3.0965967178344727, 0.9474747776985168), espLabel = "Gas", espColor = Color3.new(1.000000, 0.098039, 0.000000)},
    {partName = "Body", partSize = Vector3.new(6.795680046081543, 5.078634262084961, 13.125102996826172), espLabel = "ATV", espColor = Color3.new(1, 0, 0)}
}

local function o(p, q, r)
    r = r or 0.01
    return math.abs(p.X - q.X) <= r and math.abs(p.Y - q.Y) <= r and math.abs(p.Z - q.Z) <= r
end

local function s(t, u, v)
    if not g[t] then
        local w = Drawing.new("Text")
        w.Size = 26
        w.Center = true
        w.Outline = true
        w.OutlineColor = Color3.new(0, 0, 0)
        w.Color = v
        w.Visible = false 
        w.Text = u
        g[t] = w
    end
end

local function x(t)
    if g[t] then
        g[t]:Remove()
        g[t] = nil
    end
end

local function y()
    if not drawingsEnabled then
        for _, w in pairs(g) do
            w.Visible = false
        end
        return
    end

    for t, w in pairs(g) do
        if t and t:IsDescendantOf(workspace) then
            local pos, onScreen = c:WorldToViewportPoint(t.Position)
            if onScreen then
                w.Position = Vector2.new(pos.X, pos.Y)
                w.Visible = true
            else
                w.Visible = false
            end
        else
            x(t)
        end
    end
end

workspace.DescendantAdded:Connect(function(C)
    for _, D in ipairs(n) do
        if C:IsA("BasePart") and C.Name == D.partName and o(C.Size, D.partSize) then
            s(C, D.espLabel, D.espColor)
        end
    end
end)

workspace.DescendantRemoving:Connect(function(C)
    x(C)
end)

for _, C in ipairs(workspace:GetDescendants()) do
    for _, D in ipairs(n) do
        if C:IsA("BasePart") and C.Name == D.partName and o(C.Size, D.partSize) then
            s(C, D.espLabel, D.espColor)
        end
    end
end

e.InputBegan:Connect(function(T, U)
    if not U and T.KeyCode == Enum.KeyCode.O then
        drawingsEnabled = not drawingsEnabled
    end
end)

b.RenderStepped:Connect(y)
local UserInput = game:GetService('UserInputService')
local RunService = game:GetService('RunService')
local Camera = workspace.CurrentCamera
local Players = game:GetService('Players')
local LocalPlayer = Players.LocalPlayer

-- Keys
local KEY_TOGGLE_Z = Enum.KeyCode.Z
local KEY_TOGGLE_F = Enum.KeyCode.F
local KEY_BOOST = Enum.KeyCode.LeftShift
local KEY_NOCLIP = Enum.KeyCode.T
local KEY_ASCEND = Enum.KeyCode.Unknown
local KEY_DESCEND = Enum.KeyCode.Unknown

-- Speeds (tweakable)
local FLY_SPEED_Z = 150 -- Horizontal speed for Z mode (units/sec)
local FLY_SPEED_F = 15 -- Horizontal speed for F mode (units/sec)
local BOOST_MULT = 8 -- Speed multiplier when boosting
local DOWNWARD_SPEED = 0 -- Configurable constant downward speed (units/sec)
local VERTICAL_SPEED = 50 -- Manual vertical speed for ascend/descend (units/sec)

-- Rotation: yaw speed in radians PER SECOND
local YAW_SPEED_RAD_PER_SEC = math.rad(400) -- ~150 deg/sec

-- Smoothing & stabilizer
local LERP_ALPHA = 0.12 -- Interpolation factor for rotation smoothing (0..1)
local STABILIZER_P = 2000
local STABILIZER_D = 100
local STABILIZER_MAXTORQUE = 1e5 -- Large to hold pitch/roll

-- State
local flyingZ = false
local flyingF = false
local boosting = false
local connections = {} -- List of Heartbeat connections
local flyObjects = {} -- Parts we fly
local bodyGyros = {} -- Stabilizers per part (key = part)

-- Criteria list
local criteriaList = {
    { partName = 'BLWheelHub', partSize = Vector3.new(0.25, 0.25, 0.25) },
    {
        partName = 'lights1',
        partSize = Vector3.new(
            3.0251893997192383,
            0.6689038276672363,
            5.577791213989258
        ),
    },
    {
        partName = 'lights3',
        partSize = Vector3.new(
            0.42277026176452637,
            0.6625227928161621,
            0.07328414916992188
        ),
    },
    {
        partName = 'lights2',
        partSize = Vector3.new(
            0.42277026176452637,
            0.6625227928161621,
            0.07328414916992188
        ),
    },
    {
        partName = 'FRWheel',
        partSize = Vector3.new(2.4, 2.4, 0.7129999995231628),
    },
    {
        partName = 'FLWheel',
        partSize = Vector3.new(2.4, 2.4, 0.7129999995231628),
    },
    {
        partName = 'Body',
        partSize = Vector3.new(
            6.795680046081543,
            5.078634262084961,
            13.125102996826172
        ),
    },
    {
        partName = 'BRWheel',
        partSize = Vector3.new(2.4, 2.4, 0.7129999995231628),
    },
    {
        partName = 'BLWheel',
        partSize = Vector3.new(2.4, 2.4, 0.7129999995231628),
    },
    {
        partName = 'Plastics',
        partSize = Vector3.new(
            7.551962852478027,
            2.7462241649627686,
            4.972546577453613
        ),
    },
    {
        partName = 'BackLeftRim',
        partSize = Vector3.new(
            1.067999005317688,
            1.067999005317688,
            0.7230425477027893
        ),
    },
    {
        partName = 'BackLeftW',
        partSize = Vector3.new(
            2.1518802642822266,
            2.1898412704467773,
            0.9632723927497864
        ),
    },
    {
        partName = 'BackRightRim',
        partSize = Vector3.new(
            1.067999005317688,
            1.067999005317688,
            0.7230425477027893
        ),
    },
    {
        partName = 'BackRightW',
        partSize = Vector3.new(
            2.1518802642822266,
            2.1898412704467773,
            0.9632723927497864
        ),
    },
    {
        partName = 'Frame',
        partSize = Vector3.new(
            6.972168922424316,
            2.774535655975342,
            5.0449066162109375
        ),
    },
    {
        partName = 'FrontLeftRim',
        partSize = Vector3.new(
            1.067999005317688,
            1.067999005317688,
            0.7230425477027893
        ),
    },
    {
        partName = 'FrontLeftW',
        partSize = Vector3.new(
            2.1518802642822266,
            2.1898412704467773,
            0.7132723927497864
        ),
    },
    {
        partName = 'FrontRightRim',
        partSize = Vector3.new(
            1.067999005317688,
            1.067999005317688,
            0.7230425477027893
        ),
    },
    {
        partName = 'FrontRightW',
        partSize = Vector3.new(
            2.1518802642822266,
            2.1898412704467773,
            0.7132723927497864
        ),
    },
    {
        partName = 'Grip',
        partSize = Vector3.new(
            0.5733855366706848,
            0.9605950117111206,
            2.1716928482055664
        ),
    },
    {
        partName = 'HandleBars',
        partSize = Vector3.new(
            0.448628693819046,
            1.376966953277588,
            2.0683438777923584
        ),
    },
    {
        partName = 'Plastics2',
        partSize = Vector3.new(
            5.546261787414551,
            1.9555978775024414,
            3.854473352432251
        ),
    },
    {
        partName = 'Seat',
        partSize = Vector3.new(
            4.404223442077637,
            1.439717411994934,
            2.2254559993743896
        ),
    },
    { partName = 'LeftBackWH', partSize = Vector3.new(0.625, 0.625, 0.125) },
    { partName = 'LeftFrontWH', partSize = Vector3.new(0.625, 0.625, 0.125) },
    { partName = 'RightBackWH', partSize = Vector3.new(0.625, 0.625, 0.125) },
    { partName = 'RightFrontWH', partSize = Vector3.new(0.625, 0.625, 0.125) },
}

local function isMatchingSize(partSize, targetSize, tolerance)
    tolerance = tolerance or 0.001
    return math.abs(partSize.X - targetSize.X) <= tolerance
        and math.abs(partSize.Y - targetSize.Y) <= tolerance
        and math.abs(partSize.Z - targetSize.Z) <= tolerance
end

local function matchesCriteria(part)
    for _, criteria in ipairs(criteriaList) do
        if
            part:IsA('BasePart')
            and part.Name == criteria.partName
            and isMatchingSize(part.Size, criteria.partSize)
        then
            return true
        end
    end
    return false
end

local function createStabilizer(part)
    local bg = Instance.new('BodyGyro')
    bg.MaxTorque = Vector3.new(STABILIZER_MAXTORQUE, 0, STABILIZER_MAXTORQUE)
    bg.P = STABILIZER_P
    bg.D = STABILIZER_D
    local _, yaw, _ = part.CFrame:ToOrientation()
    bg.CFrame = CFrame.Angles(0, yaw, 0)
    bg.Parent = part
    return bg
end

local function applyYawSmooth(part, yawDelta, dt)
    if yawDelta == 0 then
        return
    end
    local desiredCFrame = part.CFrame * CFrame.Angles(0, yawDelta, 0)
    part.CFrame = part.CFrame:Lerp(desiredCFrame, math.clamp(LERP_ALPHA, 0, 1))
end

local function controlFlyForPart(part, speed, dt)
    if not part or not part:IsA('BasePart') then
        return
    end
    if UserInput:GetFocusedTextBox() then
        part.Velocity = flyingZ and Vector3.new(0, -DOWNWARD_SPEED, 0)
            or Vector3.zero
        part.RotVelocity = Vector3.zero
        return
    end

    -- Determine if the part is a wheel
    local isWheel = part.Name:match('Wheel')
        or part.Name:match('Rim')
        or part.Name:match('WH')

    -- Movement
    local cam = Camera.CFrame
    local look = cam.LookVector
    local right = cam.RightVector
    local up = cam.UpVector
    local moveDir = flyingZ and Vector3.new(0, -DOWNWARD_SPEED, 0)
        or Vector3.zero

    -- Camera-relative horizontal movement
    if UserInput:IsKeyDown(Enum.KeyCode.W) then
        moveDir = moveDir + look * speed
    end
    if UserInput:IsKeyDown(Enum.KeyCode.S) then
        moveDir = moveDir - look * speed
    end
    if UserInput:IsKeyDown(Enum.KeyCode.D) then
        moveDir = moveDir + right * speed
    end
    if UserInput:IsKeyDown(Enum.KeyCode.A) then
        moveDir = moveDir - right * speed
    end

    -- Camera-relative vertical movement
    if UserInput:IsKeyDown(KEY_ASCEND) then
        moveDir = moveDir + up * VERTICAL_SPEED
    end
    if UserInput:IsKeyDown(KEY_DESCEND) then
        moveDir = moveDir - up * VERTICAL_SPEED
    end

    -- Apply speed with boost
    local appliedSpeed = speed
    if boosting then
        appliedSpeed = appliedSpeed * BOOST_MULT
    end

    -- Set linear velocity
    if moveDir.Magnitude > 0 then
        local horizontal = Vector3.new(moveDir.X, 0, moveDir.Z)
        if horizontal.Magnitude > 0 then
            horizontal = horizontal.Unit * appliedSpeed
            moveDir = Vector3.new(horizontal.X, moveDir.Y, horizontal.Z)
        end
        part.Velocity = moveDir
    else
        part.Velocity = flyingZ and Vector3.new(0, -DOWNWARD_SPEED, 0)
            or Vector3.zero
    end

    -- Lock rotation for wheels
    if isWheel then
        part.RotVelocity = Vector3.zero
    end

    -- Yaw rotation
    local yawDelta = 0
    if UserInput:IsKeyDown(Enum.KeyCode.Q) then
        yawDelta = yawDelta + YAW_SPEED_RAD_PER_SEC * dt
    end
    if UserInput:IsKeyDown(Enum.KeyCode.R) then
        yawDelta = yawDelta - YAW_SPEED_RAD_PER_SEC * dt
    end

    if yawDelta ~= 0 then
        applyYawSmooth(part, yawDelta, dt)
    else
        -- Sync stabilizer yaw
        local bg = bodyGyros[part]
        if bg then
            local _, currentYaw, _ = part.CFrame:ToOrientation()
            bg.CFrame = CFrame.Angles(0, currentYaw, 0)
        end
    end
end

-- Start/stop helpers
local function startForPart(part, speed)
    if not part or not part:IsA('BasePart') then
        return
    end
    part.Anchored = false
    if not bodyGyros[part] then
        bodyGyros[part] = createStabilizer(part)
    end
    local conn = RunService.Heartbeat:Connect(function(dt)
        controlFlyForPart(part, speed, dt)
    end)
    table.insert(connections, conn)
end

local function stopAll()
    for _, conn in ipairs(connections) do
        pcall(function()
            conn:Disconnect()
        end)
    end
    connections = {}
    for p, g in pairs(bodyGyros) do
        if g and g.Parent then
            pcall(function()
                g:Destroy()
            end)
        end
    end
    bodyGyros = {}
end

-- Input handling
UserInput.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end

    if input.KeyCode == KEY_TOGGLE_Z then
        if flyingZ then
            flyingZ = false
            stopAll()
        else
            flyingZ = true
            flyingF = false
            stopAll()
            for _, obj in ipairs(flyObjects) do
                startForPart(obj, FLY_SPEED_Z)
            end
        end
    elseif input.KeyCode == KEY_TOGGLE_F then
        if flyingF then
            flyingF = false
            stopAll()
        else
            flyingF = true
            flyingZ = false
            stopAll()
            for _, obj in ipairs(flyObjects) do
                startForPart(obj, FLY_SPEED_F)
            end
        end
    elseif input.KeyCode == KEY_BOOST then
        boosting = true
    elseif input.KeyCode == KEY_NOCLIP then
        for _, obj in ipairs(flyObjects) do
            if obj:IsA('BasePart') then
                obj.CanCollide = not obj.CanCollide
            end
        end
    end
end)

UserInput.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end
    if input.KeyCode == KEY_BOOST then
        boosting = false
    end
end)

-- Workspace hooks
workspace.DescendantAdded:Connect(function(desc)
    if matchesCriteria(desc) then
        table.insert(flyObjects, desc)
        if flyingZ then
            startForPart(desc, FLY_SPEED_Z)
        end
        if flyingF then
            startForPart(desc, FLY_SPEED_F)
        end
    end
end)

workspace.DescendantRemoving:Connect(function(desc)
    for i, obj in ipairs(flyObjects) do
        if obj == desc then
            table.remove(flyObjects, i)
            if bodyGyros[obj] then
                pcall(function()
                    bodyGyros[obj]:Destroy()
                end)
                bodyGyros[obj] = nil
            end
            break
        end
    end
end)

-- Initial scan
for _, descendant in ipairs(workspace:GetDescendants()) do
    if matchesCriteria(descendant) then
        table.insert(flyObjects, descendant)
    end
end
task.spawn(function()
    while true do
        task.wait() -- every 1 second
        for _, obj in ipairs(flyObjects) do
            if obj:IsA("BasePart") then
                local isWheel = obj.Name:match("Wheel") or obj.Name:match("Rim") or obj.Name:match("WH")
                if isWheel then
                    obj.CanCollide = false
                end
            end
        end
    end
end)
-- gui protect dont want ban :)
--[[task.spawn(function() -- turn on when detected.
    local hui = gethui and gethui() or game:GetService("CoreGui")
    local function forceToHui(obj)
        if typeof(obj) ~= "Instance" then return end
        if obj:IsA("ScreenGui") or obj:IsA("GuiObject") or obj:IsA("Folder") then
            pcall(function()
                obj.Parent = hui
            end)
        end
        for _, child in obj:GetChildren() do
            forceToHui(child)
        end
    end

    for _, v in hui:GetChildren() do
        forceToHui(v)
    end

    hui.ChildAdded:Connect(function(child)
        task.wait()
        forceToHui(child)
    end)
end)
end]]
--[[local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local targetRanks = {
    ["HR Moderators"] = true,
    ["Map Design"] = true,
    ["Co-Owner"] = true,
    ["Owner"] = true,
    ["Holder"] = true
}

local moderatorList = {}

task.spawn(function()
    local success, result = pcall(function()
        return game:HttpGet("https://groups.roblox.com/v1/groups/32075233/roles")
    end)
    if success then
        local roles = HttpService:JSONDecode(result).roles
        for _, role in pairs(roles) do
            if targetRanks[role.name] then
                local userData = game:HttpGet("https://groups.roblox.com/v1/groups/32075233/roles/"..role.id.."/users?limit=100")
                local data = HttpService:JSONDecode(userData).data
                for _, user in pairs(data) do
                    moderatorList[user.username] = role.name
                end
            end
        end
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ScreenGui"
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "ModeratorFrame"
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BackgroundTransparency = 0.25
MainFrame.BorderSizePixel = 0
MainFrame.Size = UDim2.new(0, 180, 0, 48)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local function savePosition(x, y)
    writefile("moderator_ui_pos.txt", x .. "," .. y)
end

local function loadPosition()
    local success, data = pcall(readfile, "moderator_ui_pos.txt")
    if success and data then
        local x, y = data:match("([^,]+),([^,]+)")
        if x and y then
            return tonumber(x), tonumber(y)
        end
    end
    return -90, 15
end

local savedX, savedY = loadPosition()
MainFrame.Position = UDim2.new(0.5, savedX, 0, savedY)

local lastPosition = nil
MainFrame.Changed:Connect(function(property)
    if property == "Position" then
        local currentPos = MainFrame.Position
        if lastPosition ~= currentPos then
            lastPosition = currentPos
            savePosition(currentPos.X.Offset, currentPos.Y.Offset)
        end
    end
end)

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 4)
UICorner.Parent = MainFrame

local Icon = Instance.new("ImageLabel")
Icon.Name = "Icon"
Icon.BackgroundTransparency = 1
Icon.Image = "rbxassetid://3926305904"
Icon.ImageRectOffset = Vector2.new(84, 204)
Icon.ImageRectSize = Vector2.new(36, 36)
Icon.ImageColor3 = Color3.fromRGB(66, 135, 245)
Icon.Position = UDim2.new(0, 8, 0, 6)
Icon.Size = UDim2.new(0, 14, 0, 14)
Icon.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 28, 0, 6)
Title.Size = UDim2.new(0, 140, 0, 14)
Title.Font = Enum.Font.SourceSansBold
Title.Text = "Moderators"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local Status = Instance.new("TextLabel")
Status.Name = "Status"
Status.BackgroundTransparency = 1
Status.Position = UDim2.new(0, 8, 0, 26)
Status.Size = UDim2.new(0, 160, 0, 14)
Status.Font = Enum.Font.SourceSans
Status.TextSize = 14
Status.TextColor3 = Color3.fromRGB(255, 255, 255)
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Parent = MainFrame

local function updateStatus()
    local foundOnServer = {}
    
    for _, plr in pairs(Players:GetPlayers()) do
        if moderatorList[plr.Name] then
            table.insert(foundOnServer, plr.Name)
        end
    end

    if #foundOnServer > 0 then
        Status.Text = table.concat(foundOnServer, ", ")
        Status.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        Status.Text = "No Moderators Found"
        Status.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end

task.spawn(function()
    while task.wait(1) do
        updateStatus()
    end
end)]]
---BETA
end