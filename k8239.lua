-- ═══════════════════════════════════════════════════════════════════════════
--  REZE HUB - SECURE KEY SYSTEM WITH ANTI-BYPASS
--  Part 1: Core Protection & Anti-Tampering
-- ═══════════════════════════════════════════════════════════════════════════

-- ══════════════════════════════════════════
--  Config - DO NOT MODIFY
-- ══════════════════════════════════════════
local ENLACE_DISCORD = "https://discord.gg/23ZdKDc4nn"
local INVITE_CODE    = "23ZdKDc4nn"
local API_KEY        = "e3486680-8816-4d88-9338-bfa2394697d1"
local SCRIPT_ID      = "7734"

-- ══════════════════════════════════════════
--  ANTI-BYPASS: Integrity Check
--  Detects common bypass methods
-- ══════════════════════════════════════════
local function InitAntiBypass()
    local players = game:GetService("Players")
    local localPlayer = players.LocalPlayer
    
    -- Check for common bypass attempts
    local function CheckTampering()
        -- Check if getgenv was manipulated before script loads
        if getgenv().SCRIPT_KEY and type(getgenv().SCRIPT_KEY) == "string" then
            if #getgenv().SCRIPT_KEY > 0 and not getgenv()._REZE_SECURE_LOADED then
                return true, "Tampering detected: SCRIPT_KEY pre-set"
            end
        end
        
        -- Check for hookfunction (common bypass tool)
        if getgenv().hookfunction then
            local original = getgenv().game.HttpGet
            local test = getgenv().hookfunction(original, function() end)
            if original == test then
                return true, "Tampering detected: hookfunction active"
            end
        end
        
        -- Check for getrawmetatable manipulation
        if getgenv().getrawmetatable then
            local mt = getgenv().getrawmetatable(game)
            if mt and mt.__namecall and debug.info(mt.__namecall, "s") ~= "[C]" then
                return true, "Tampering detected: metatable hooked"
            end
        end
        
        -- Check for fake Junkie
        if getgenv().Junkie and type(getgenv().Junkie) == "table" then
            if not getgenv().Junkie._REZE_VERIFIED then
                return true, "Tampering detected: Fake SDK injection"
            end
        end
        
        return false, nil
    end
    
    local isTampered, reason = CheckTampering()
    if isTampered then
        -- Log attempt (silent)
        pcall(function()
            local http = game:GetService("HttpService")
            local req = (syn and syn.request) or http_request or request
            if req then
                req({
                    Url = "https://api.jnkie.com/api/v2/security/log",
                    Method = "POST",
                    Headers = {
                        ["Authorization"] = "Bearer " .. API_KEY,
                        ["Content-Type"] = "application/json"
                    },
                    Body = http:JSONEncode({
                        event = "bypass_attempt",
                        reason = reason,
                        user_id = localPlayer and localPlayer.UserId or 0,
                        timestamp = os.time()
                    })
                })
            end
        end)
        
        -- Kick player
        localPlayer:Kick("Security violation detected: " .. reason .. ". If this is an error, contact support.")
        task.wait(5)
        while true do end -- Hang if kick fails
    end
    
    -- Mark secure environment
    getgenv()._REZE_SECURE_LOADED = true
end

-- Run immediately
InitAntiBypass()

-- ══════════════════════════════════════════
--  ANTI-SPY: Environment Protection
-- ══════════════════════════════════════════
local function InitAntiSpy()
    -- Hide sensitive functions from external inspection
    local protected = {}
    local originalGet = getgenv().getgenv
    
    -- Protect critical globals
    getgenv()._REZE_INTERNAL = {
        API_KEY = API_KEY,
        SCRIPT_ID = SCRIPT_ID,
        protected = true
    }
    
    -- Detect debuggers (basic)
    local function IsDebuggerPresent()
        local info = debug.info(InitAntiSpy, "s")
        return info and info:match("Debugger")
    end
    
    if IsDebuggerPresent() then
        game:GetService("Players").LocalPlayer:Kick("Debugger detected.")
        while true do end
    end
end

InitAntiSpy()

-- ══════════════════════════════════════════
--  SDK Loading with Verification
-- ══════════════════════════════════════════
local Junkie = loadstring(game:HttpGet("https://jnkie.com/sdk/library.lua"))()
Junkie.service    = "Key games"
Junkie.identifier = SCRIPT_ID
Junkie.provider   = "Key system 2"
Junkie._REZE_VERIFIED = true -- Mark as verified

-- ══════════════════════════════════════════
--  USER REGISTRATION SYSTEM
--  Registers user to dashboard on successful auth
-- ══════════════════════════════════════════
local function RegisterUserToDashboard(key, hwid)
    local http = game:GetService("HttpService")
    local req = (syn and syn.request) or http_request or request
    
    if not req then return false end
    
    local player = game:GetService("Players").LocalPlayer
    local success, response = pcall(function()
        return req({
            Url = "https://api.jnkie.com/api/v2/users/register",
            Method = "POST",
            Headers = {
                ["Authorization"] = "Bearer " .. API_KEY,
                ["Content-Type"] = "application/json"
            },
            Body = http:JSONEncode({
                key = key,
                hwid = hwid,
                user_id = player and player.UserId or 0,
                username = player and player.Name or "Unknown",
                script_id = SCRIPT_ID,
                timestamp = os.time(),
                client_info = {
                    place_id = game.PlaceId,
                    job_id = game.JobId,
                    universe_id = game.GameId
                }
            })
        })
    end)
    
    if success and response and response.StatusCode == 200 then
        local data = http:JSONDecode(response.Body)
        return data and data.success or false
    end
    
    return false
end

-- ══════════════════════════════════════════
--  PAYLOAD CONTAINER
--  Your script goes here after verification
-- ══════════════════════════════════════════
local RezePayload = {
    Loaded = false,
    Code = nil,
    
    Execute = function()
        if RezePayload.Loaded and RezePayload.Code then
            -- Execute in protected mode
            local success, err = pcall(function()
                loadstring(RezePayload.Code)()
            end)
            
            if not success then
                warn("Payload execution error: " .. tostring(err))
            end
        else
            warn("No payload loaded")
        end
    end,
    
    -- Method to set payload (called after auth)
    Set = function(code)
        RezePayload.Code = code
        RezePayload.Loaded = true
    end
}

-- ══════════════════════════════════════════
--  SECURE ENVIRONMENT SETUP
-- ══════════════════════════════════════════
local result = (function()
    getgenv().UI_CLOSED = false

    local ScriptIcon  = "rbxassetid://14535038383"
    local DiscordIcon = "rbxassetid://112538196670712"
    local uiTitle     = "Reze"
    local uiSubtitle  = "Key system"

    local mainCorner    = 24
    local discordCorner = 24
    local notifCorner   = 24
    local iconCorner    = 24
    local buttonCorner  = 24
    local inputCorner   = 24

    local players      = game:GetService("Players")
    local tween        = game:GetService("TweenService")
    local inputService = game:GetService("UserInputService")
    local http         = game:GetService("HttpService")
    local lighting     = game:GetService("Lighting")
    local textSize     = game:GetService("TextService")

    local pics = {
        main    = ScriptIcon,
        discord = DiscordIcon,
        key     = "rbxassetid://128426502701541",
        link    = "rbxassetid://73034596791310",
        check   = "rbxassetid://83827110621355",
        close   = "rbxassetid://73070135088117",
        members = "rbxassetid://115398113982385",
    }

    local col = {
        back      = Color3.fromRGB(0, 0, 0),
        main      = Color3.fromRGB(2, 2, 2),
        light     = Color3.fromRGB(6, 6, 6),
        line      = Color3.fromRGB(15, 15, 15),
        lineLight = Color3.fromRGB(30, 30, 30),
        text      = Color3.fromRGB(255, 255, 255),
        textSoft  = Color3.fromRGB(130, 130, 130),
        textFaint = Color3.fromRGB(50, 50, 50),
        glass     = Color3.fromRGB(255, 255, 255),
        good      = Color3.fromRGB(200, 255, 200),
        bad       = Color3.fromRGB(255, 200, 200),
        blue      = Color3.fromRGB(88, 101, 242),
        blueDark  = Color3.fromRGB(64, 78, 237),
    }

    local curFnt = { normal = Enum.Font.Gotham, bold = Enum.Font.GothamBold }

    -- REST API helper
    local API_BASE  = "https://api.jnkie.com/api/v2"
    local httpReqFn = (syn and syn.request) or http_request or request

    local function apiCall(method, path, body)
        if not httpReqFn then return nil end
        local ok, res = pcall(function()
            return httpReqFn({
                Url     = API_BASE .. path,
                Method  = method,
                Headers = {
                    ["Authorization"] = "Bearer " .. API_KEY,
                    ["Content-Type"]  = "application/json",
                },
                Body = body and http:JSONEncode(body) or nil,
            })
        end)
        if not ok or not res then return nil end
        if res.StatusCode >= 200 and res.StatusCode < 300 then
            local ok2, data = pcall(function() return http:JSONDecode(res.Body) end)
            return ok2 and data or nil
        end
        return nil
    end

    -- HWID Collection
    local function getHWID()
        if typeof(get_hwid) == "function" then
            local ok, id = pcall(get_hwid)
            if ok and id and id ~= "" then return tostring(id) end
        end
        if typeof(gethwid) == "function" then
            local ok, id = pcall(gethwid)
            if ok and id and id ~= "" then return tostring(id) end
        end
        local ok, id = pcall(function()
            return game:GetService("RbxAnalyticsService"):GetClientId()
        end)
        if ok and id and id ~= "" then return tostring(id) end
        local pl = players.LocalPlayer
        return tostring(pl and pl.UserId or 0) .. "_" .. tostring(game.PlaceId)
    end

    -- HWID Ban Check
    local function checkHWIDBan(hwid)
        local data = apiCall("GET", "/hwid-bans/check/" .. hwid)
        if not data then return false, nil end
        if data.is_banned then
            local ban    = data.hwid_ban
            local reason = (ban and ban.reason) and (" Reason: " .. ban.reason) or ""
            return true, "Your device is banned." .. reason
        end
        return false, nil
    end

    -- Bind HWID to key
    local function registerUser(key, hwid)
        if not hwid or hwid == "" then return end
        local data = apiCall("GET", "/keys/" .. key)
        if not data or not data.key then return end
        local existing = data.key.keys_hwid or {}
        local found = false
        for _, v in ipairs(existing) do
            if v == hwid then found = true; break end
        end
        if not found then
            table.insert(existing, hwid)
            apiCall("PUT", "/keys/" .. key, { hwids = existing })
        end
        
        -- Register to dashboard
        RegisterUserToDashboard(key, hwid)
    end

    -- Heartbeat
    local heartbeatActive = false
    local function startHeartbeat()
        if heartbeatActive then return end
        heartbeatActive = true
        task.spawn(function()
            while heartbeatActive do
                pcall(function()
                    if Junkie.heartbeat then Junkie.heartbeat()
                    elseif Junkie.beat then Junkie.beat() end
                end)
                task.wait(30)
            end
        end)
    end

    -- Error Messages
    local ERROR_MESSAGES = {
        KEY_INVALID        = "Key not found.",
        KEY_EXPIRED        = "Key has expired.",
        HWID_BANNED        = "Your device is banned.",
        KEY_INVALIDATED    = "Key was disabled.",
        ALREADY_USED       = "One-time key already used.",
        HWID_MISMATCH      = "HWID limit reached for this key.",
        SERVICE_NOT_FOUND  = "Service not found.",
        SERVICE_MISMATCH   = "Key belongs to a different service.",
        PREMIUM_REQUIRED   = "A premium key is required.",
        ERROR              = "Network error, try again.",
    }

    local function friendlyError(errCode)
        if not errCode then return "Invalid key." end
        if ERROR_MESSAGES[errCode] then return ERROR_MESSAGES[errCode] end
        if tostring(errCode):match("^http %d+") then
            return "Server error (" .. errCode .. "), try again."
        end
        return tostring(errCode)
    end

    -- Discord Data
    local function cargarDatosDiscord()
        local codigo = ENLACE_DISCORD:match("discord%.gg/([%w%-]+)")
                    or ENLACE_DISCORD:match("discord%.com/invite/([%w%-]+)")
                    or INVITE_CODE
        local url = "https://discord.com/api/v9/invites/" .. codigo .. "?with_counts=true"

        local req = (syn and syn.request) or http_request or request
        if not req then
            return {
                guild = { name = "HTTP not supported", icon = nil, id = nil },
                approximate_member_count = 0,
                approximate_presence_count = 0,
            }
        end

        local ok, respuesta = pcall(function()
            return req({ Url = url, Method = "GET", Headers = { ["User-Agent"] = "Mozilla/5.0" } })
        end)

        if ok and respuesta and respuesta.StatusCode == 200 then
            local ok2, data = pcall(function() return http:JSONDecode(respuesta.Body) end)
            if ok2 and data and data.guild then return data end
        end

        return {
            guild = { name = "Failed to load", icon = nil, id = nil },
            approximate_member_count = 0,
            approximate_presence_count = 0,
        }
    end

    -- Discord Join
    local isMobile = inputService.TouchEnabled and not inputService.KeyboardEnabled
    local function joinDiscord(popRef)
        if not isMobile then
            local req = (syn and syn.request) or http_request or request
            local opened = false
            if req then
                local ok = pcall(function()
                    req({
                        Url    = "http://127.0.0.1:6463/rpc?v=1",
                        Method = "POST",
                        Headers = {
                            ["Content-Type"] = "application/json",
                            ["Origin"]       = "https://discord.com",
                        },
                        Body = http:JSONEncode({
                            cmd   = "INVITE_BROWSER",
                            args  = { code = INVITE_CODE },
                            nonce = http:GenerateGUID(false),
                        }),
                    })
                end)
                opened = ok
            end

            if not opened then
                if setclipboard then
                    setclipboard("https://discord.gg/" .. INVITE_CODE)
                    if popRef then popRef:show("Discord not detected — link copied", "good", 2.5) end
                end
            else
                if popRef then popRef:show("Opening Discord...", "good", 2) end
            end
        else
            if setclipboard then
                setclipboard("https://discord.gg/" .. INVITE_CODE)
                if popRef then popRef:show("Link copied to clipboard", "good", 2) end
            end
        end
    end

    -- Config
    local config = {}
    function config:load()
        local base = { autoLoad = false }
        if not pcall(function() return type(writefile) == "function" end) then return base end
        local ok, dat = pcall(function() return http:JSONDecode(readfile("key_config.json")) end)
        if ok and dat then return dat end
        return base
    end
    function config:save(dat)
        if not pcall(function() return type(writefile) == "function" end) then return false end
        pcall(function() writefile("key_config.json", http:JSONEncode(dat)) end)
    end

    local usr = config:load()

    local function kpK(k)
        if not pcall(function() return type(writefile) == "function" end) then return false end
        pcall(function() writefile("verified_key.txt", k) end)
    end
    local function gtK()
        if not pcall(function() return type(writefile) == "function" end) then return nil end
        local ok, d = pcall(function() return readfile("verified_key.txt") end)
        if not ok or not d then return nil end
        return d
    end
    local function drK()
        if not pcall(function() return type(writefile) == "function" end) then return false end
        pcall(function() delfile("verified_key.txt") end)
        getgenv().SCRIPT_KEY = nil
    end

    -- Notification System
    local Pop = {}
    Pop.__index = Pop

    function Pop.new(p)
        local self = setmetatable({}, Pop)
        self.p = p
        self.l = {}
        self.b = Instance.new("Frame")
        self.b.Size = UDim2.new(0, 300, 1, -40)
        self.b.Position = UDim2.new(1, -20, 0, 20)
        self.b.AnchorPoint = Vector2.new(1, 0)
        self.b.BackgroundTransparency = 1
        self.b.Parent = p
        return self
    end

    function Pop:show(m, k, t)
        t = t or 2.5
        local y = (#self.l * 45) + 10
        local f   = Instance.new("Frame")
        local cr  = Instance.new("UICorner")
        local st  = Instance.new("UIStroke")
        local ic  = Instance.new("ImageLabel")
        local tx  = Instance.new("TextLabel")
        f.Size = UDim2.new(0, 0, 0, 40)
        f.Position = UDim2.new(1, 0, 0, y)
        f.AnchorPoint = Vector2.new(1, 0)
        f.BackgroundColor3 = col.light
        f.BackgroundTransparency = 0.1
        f.BorderSizePixel = 0
        f.Parent = self.b
        cr.CornerRadius = UDim.new(0, notifCorner)
        cr.Parent = f
        st.Color = k == "good" and col.good or k == "bad" and col.bad or col.lineLight
        st.Thickness = 1
        st.Transparency = 0.5
        st.Parent = f
        ic.Size = UDim2.new(0, 18, 0, 18)
        ic.Position = UDim2.new(0, 10, 0.5, 0)
        ic.AnchorPoint = Vector2.new(0, 0.5)
        ic.BackgroundTransparency = 1
        ic.Image = k == "good" and pics.check or k == "bad" and pics.close or pics.link
        ic.ImageColor3 = k == "good" and col.good or k == "bad" and col.bad or col.textSoft
        ic.ScaleType = Enum.ScaleType.Fit
        ic.Parent = f
        tx.Size = UDim2.new(1, -35, 1, 0)
        tx.Position = UDim2.new(0, 33, 0, 0)
        tx.BackgroundTransparency = 1
        tx.Text = m
        tx.TextColor3 = col.text
        tx.TextSize = 13
        tx.Font = curFnt.normal
        tx.TextXAlignment = Enum.TextXAlignment.Left
        tx.Parent = f
        local sz = textSize:GetTextSize(m, 13, curFnt.normal, Vector2.new(280, 40))
        local w = math.min(sz.X + 60, 280)
        tween:Create(f, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, w, 0, 40)}):Play()
        table.insert(self.l, f)
        task.delay(t, function()
            if f and f.Parent then
                tween:Create(f,  TweenInfo.new(0.3), {Size = UDim2.new(0, 0, 0, 40), BackgroundTransparency = 1}):Play()
                tween:Create(st, TweenInfo.new(0.3), {Transparency = 1}):Play()
                tween:Create(ic, TweenInfo.new(0.3), {ImageTransparency = 1}):Play()
                tween:Create(tx, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
                task.wait(0.3)
                f:Destroy()
                for i, v in ipairs(self.l) do if v == f then table.remove(self.l, i) break end end
                for idx, a in ipairs(self.l) do
                    tween:Create(a, TweenInfo.new(0.3), {Position = UDim2.new(1, 0, 0, (idx-1)*45+10)}):Play()
                end
            end
        end)
    end

	-- ══════════════════════════════════════════
    --  Discord Server UI (popup)
    -- ══════════════════════════════════════════
    local Main = {}
    Main.__index = Main

    function Main.new()
        local self = setmetatable({}, Main)
        self.t  = uiTitle
        self.s  = uiSubtitle
        self.pl = players.LocalPlayer
        self.ls = {}
        self.dc = nil
        self.dg = false
        self.pt = {}
        self.cf = usr
        return self
    end

    function Main:gtD()
        self.dc = cargarDatosDiscord()
        return true
    end

    function Main:shwS()
        if self.dg then return end
        self.dg = true
        if not self.dc then self:gtD() end

        local bl   = Instance.new("BlurEffect")
        local dk   = Instance.new("TextButton")
        local bx   = Instance.new("Frame")
        local bxCr = Instance.new("UICorner")
        local bxLn = Instance.new("UIStroke")
        local bxGl = Instance.new("Frame")
        local glCr = Instance.new("UICorner")
        local svPc = Instance.new("ImageLabel")
        local svCr = Instance.new("UICorner")
        local svLn = Instance.new("UIStroke")
        local svNm = Instance.new("TextLabel")
        local inBx = Instance.new("Frame")
        local inCr = Instance.new("UICorner")
        local inLn = Instance.new("UIStroke")
        local mbPc = Instance.new("ImageLabel")
        local mbCt = Instance.new("TextLabel")
        local mbLb = Instance.new("TextLabel")
        local onPc = Instance.new("ImageLabel")
        local onCt = Instance.new("TextLabel")
        local onLb = Instance.new("TextLabel")
        local jnBt = Instance.new("TextButton")
        local jnCr = Instance.new("UICorner")
        local jnLn = Instance.new("UIStroke")
        local jnPc = Instance.new("ImageLabel")
        local jnTx = Instance.new("TextLabel")
        local clDg = Instance.new("TextButton")
        local clCr = Instance.new("UICorner")
        local clLn = Instance.new("UIStroke")
        local clPc = Instance.new("ImageLabel")

        bl.Size = 16
        bl.Parent = lighting

        dk.Size = UDim2.new(1, 0, 1, 0)
        dk.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        dk.BackgroundTransparency = 0.85
        dk.BorderSizePixel = 0
        dk.Text = ""
        dk.AutoButtonColor = false
        dk.ZIndex = 9
        dk.Parent = self.gui

        bx.Size = UDim2.new(0, 0, 0, 0)
        bx.Position = UDim2.new(0.5, 0, 0.5, 0)
        bx.AnchorPoint = Vector2.new(0.5, 0.5)
        bx.BackgroundColor3 = col.main
        bx.BackgroundTransparency = 0.1
        bx.BorderSizePixel = 0
        bx.ZIndex = 10
        bx.Parent = dk

        bxCr.CornerRadius = UDim.new(0, discordCorner)
        bxCr.Parent = bx
        bxLn.Color = col.lineLight
        bxLn.Thickness = 1.5
        bxLn.Transparency = 0.3
        bxLn.Parent = bx
        bxGl.Size = UDim2.new(1, 0, 1, 0)
        bxGl.BackgroundColor3 = col.glass
        bxGl.BackgroundTransparency = 0.985
        bxGl.BorderSizePixel = 0
        bxGl.Parent = bx
        glCr.CornerRadius = UDim.new(0, discordCorner)
        glCr.Parent = bxGl

        svPc.Size = UDim2.new(0, 70, 0, 70)
        svPc.Position = UDim2.new(0.5, 0, 0, 24)
        svPc.AnchorPoint = Vector2.new(0.5, 0)
        svPc.BackgroundColor3 = col.light
        svPc.BackgroundTransparency = 0.3
        svPc.Image = "rbxassetid://10613271708"
        svPc.ImageColor3 = col.text
        svPc.ScaleType = Enum.ScaleType.Fit
        svPc.ZIndex = 11
        svPc.Parent = bx
        svCr.CornerRadius = UDim.new(0, iconCorner)
        svCr.Parent = svPc
        svLn.Color = col.lineLight
        svLn.Thickness = 1.5
        svLn.Transparency = 0.3
        svLn.Parent = svPc

        if self.dc and self.dc.guild and self.dc.guild.icon and self.dc.guild.id then
            task.spawn(function()
                local req = (syn and syn.request) or http_request or request
                if req and writefile and getcustomasset then
                    local avatarUrl = "https://cdn.discordapp.com/icons/"
                        .. self.dc.guild.id .. "/" .. self.dc.guild.icon .. ".png?size=256"
                    local ok, imgR = pcall(function()
                        return req({ Url = avatarUrl, Method = "GET" })
                    end)
                    if ok and imgR and imgR.StatusCode == 200 then
                        local fname = "discord_icon_" .. tostring(self.dc.guild.id) .. ".png"
                        pcall(function()
                            writefile(fname, imgR.Body)
                            svPc.Image = getcustomasset(fname)
                        end)
                    end
                end
            end)
        end

        svNm.Size = UDim2.new(1, -30, 0, 20)
        svNm.Position = UDim2.new(0.5, 0, 0, 106)
        svNm.AnchorPoint = Vector2.new(0.5, 0)
        svNm.BackgroundTransparency = 1
        svNm.Text = (self.dc and self.dc.guild and self.dc.guild.name) or "Loading..."
        svNm.TextColor3 = col.text
        svNm.TextSize = 18
        svNm.Font = curFnt.bold
        svNm.ZIndex = 11
        svNm.Parent = bx

        inBx.Size = UDim2.new(1, -30, 0, 58)
        inBx.Position = UDim2.new(0.5, 0, 0, 138)
        inBx.AnchorPoint = Vector2.new(0.5, 0)
        inBx.BackgroundColor3 = col.light
        inBx.BackgroundTransparency = 0.5
        inBx.BorderSizePixel = 0
        inBx.ZIndex = 11
        inBx.Parent = bx
        inCr.CornerRadius = UDim.new(0, inputCorner)
        inCr.Parent = inBx
        inLn.Color = col.lineLight
        inLn.Thickness = 1
        inLn.Transparency = 0.5
        inLn.Parent = inBx

        mbPc.Size = UDim2.new(0, 16, 0, 16)
        mbPc.Position = UDim2.new(0, 12, 0.25, 0)
        mbPc.AnchorPoint = Vector2.new(0, 0)
        mbPc.BackgroundTransparency = 1
        mbPc.Image = pics.members
        mbPc.ImageColor3 = col.textSoft
        mbPc.ScaleType = Enum.ScaleType.Fit
        mbPc.ZIndex = 12
        mbPc.Parent = inBx

        mbCt.Size = UDim2.new(0, 60, 0, 16)
        mbCt.Position = UDim2.new(0, 32, 0.25, 0)
        mbCt.BackgroundTransparency = 1
        mbCt.Text = tostring((self.dc and self.dc.approximate_member_count) or "--")
        mbCt.TextColor3 = col.text
        mbCt.TextSize = 14
        mbCt.Font = curFnt.bold
        mbCt.TextXAlignment = Enum.TextXAlignment.Left
        mbCt.ZIndex = 12
        mbCt.Parent = inBx

        mbLb.Size = UDim2.new(0, 60, 0, 14)
        mbLb.Position = UDim2.new(0, 32, 0.55, 0)
        mbLb.BackgroundTransparency = 1
        mbLb.Text = "members"
        mbLb.TextColor3 = col.textSoft
        mbLb.TextSize = 10
        mbLb.Font = curFnt.normal
        mbLb.TextXAlignment = Enum.TextXAlignment.Left
        mbLb.ZIndex = 12
        mbLb.Parent = inBx

        onPc.Size = UDim2.new(0, 16, 0, 16)
        onPc.Position = UDim2.new(0.5, 10, 0.25, 0)
        onPc.AnchorPoint = Vector2.new(0, 0)
        onPc.BackgroundTransparency = 1
        onPc.Image = pics.members
        onPc.ImageColor3 = col.textSoft
        onPc.ScaleType = Enum.ScaleType.Fit
        onPc.ZIndex = 12
        onPc.Parent = inBx

        onCt.Size = UDim2.new(0, 60, 0, 16)
        onCt.Position = UDim2.new(0.5, 30, 0.25, 0)
        onCt.BackgroundTransparency = 1
        onCt.Text = tostring((self.dc and self.dc.approximate_presence_count) or "--")
        onCt.TextColor3 = col.text
        onCt.TextSize = 14
        onCt.Font = curFnt.bold
        onCt.TextXAlignment = Enum.TextXAlignment.Left
        onCt.ZIndex = 12
        onCt.Parent = inBx

        onLb.Size = UDim2.new(0, 60, 0, 14)
        onLb.Position = UDim2.new(0.5, 30, 0.55, 0)
        onLb.BackgroundTransparency = 1
        onLb.Text = "online"
        onLb.TextColor3 = col.textSoft
        onLb.TextSize = 10
        onLb.Font = curFnt.normal
        onLb.TextXAlignment = Enum.TextXAlignment.Left
        onLb.ZIndex = 12
        onLb.Parent = inBx

        jnBt.Size = UDim2.new(0, 175, 0, 42)
        jnBt.Position = UDim2.new(0.5, 0, 1, -22)
        jnBt.AnchorPoint = Vector2.new(0.5, 1)
        jnBt.BackgroundColor3 = col.blue
        jnBt.BackgroundTransparency = 0.2
        jnBt.BorderSizePixel = 0
        jnBt.AutoButtonColor = false
        jnBt.Text = ""
        jnBt.ZIndex = 11
        jnBt.Parent = bx
        jnCr.CornerRadius = UDim.new(0, buttonCorner)
        jnCr.Parent = jnBt
        jnLn.Color = col.blueDark
        jnLn.Thickness = 1
        jnLn.Transparency = 0.5
        jnLn.Parent = jnBt

        jnPc.Size = UDim2.new(0, 16, 0, 16)
        jnPc.Position = UDim2.new(0, 14, 0.5, 0)
        jnPc.AnchorPoint = Vector2.new(0, 0.5)
        jnPc.BackgroundTransparency = 1
        jnPc.Image = pics.link
        jnPc.ImageColor3 = col.text
        jnPc.ScaleType = Enum.ScaleType.Fit
        jnPc.ZIndex = 12
        jnPc.Parent = jnBt

        jnTx.Size = UDim2.new(1, -36, 1, 0)
        jnTx.Position = UDim2.new(0, 34, 0, 0)
        jnTx.BackgroundTransparency = 1
        jnTx.Text = "Join Server"
        jnTx.TextColor3 = col.text
        jnTx.TextSize = 15
        jnTx.Font = curFnt.bold
        jnTx.TextXAlignment = Enum.TextXAlignment.Left
        jnTx.ZIndex = 12
        jnTx.Parent = jnBt

        clDg.Size = UDim2.new(0, 36, 0, 36)
        clDg.Position = UDim2.new(1, -18, 0, 18)
        clDg.AnchorPoint = Vector2.new(1, 0)
        clDg.BackgroundColor3 = col.light
        clDg.BackgroundTransparency = 0.6
        clDg.BorderSizePixel = 0
        clDg.AutoButtonColor = false
        clDg.Text = ""
        clDg.ZIndex = 11
        clDg.Parent = bx
        clCr.CornerRadius = UDim.new(0, buttonCorner)
        clCr.Parent = clDg
        clLn.Color = col.line
        clLn.Thickness = 1
        clLn.Transparency = 0.5
        clLn.Parent = clDg

        clPc.Size = UDim2.new(0, 16, 0, 16)
        clPc.Position = UDim2.new(0.5, 0, 0.5, 0)
        clPc.AnchorPoint = Vector2.new(0.5, 0.5)
        clPc.BackgroundTransparency = 1
        clPc.Image = pics.close
        clPc.ImageColor3 = col.textSoft
        clPc.ScaleType = Enum.ScaleType.Fit
        clPc.ZIndex = 12
        clPc.Parent = clDg

        tween:Create(bx, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 300, 0, 285)}):Play()
        tween:Create(dk, TweenInfo.new(0.3), {BackgroundTransparency = 0.75}):Play()

        jnBt.MouseEnter:Connect(function()
            tween:Create(jnBt, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0, Size = UDim2.new(0, 180, 0, 44), Position = UDim2.new(0.5, 0, 1, -23)}):Play()
            tween:Create(jnLn, TweenInfo.new(0.2), {Transparency = 0.2, Thickness = 2}):Play()
        end)
        jnBt.MouseLeave:Connect(function()
            tween:Create(jnBt, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0.2, Size = UDim2.new(0, 175, 0, 42), Position = UDim2.new(0.5, 0, 1, -22)}):Play()
            tween:Create(jnLn, TweenInfo.new(0.2), {Transparency = 0.5, Thickness = 1}):Play()
        end)

        jnBt.MouseButton1Click:Connect(function()
            joinDiscord(self.pop)
        end)

        local function clAll()
            self.dg = false
            tween:Create(bx, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}):Play()
            tween:Create(dk, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            task.wait(0.2)
            bl:Destroy()
            dk:Destroy()
        end

        dk.MouseButton1Click:Connect(clAll)
        clDg.MouseButton1Click:Connect(clAll)

        clDg.MouseEnter:Connect(function()
            tween:Create(clDg, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0.3, Size = UDim2.new(0, 38, 0, 38), Position = UDim2.new(1, -19, 0, 17)}):Play()
            tween:Create(clLn, TweenInfo.new(0.2), {Color = col.lineLight, Transparency = 0.3}):Play()
            tween:Create(clPc, TweenInfo.new(0.2), {ImageColor3 = col.text, Rotation = 90}):Play()
        end)
        clDg.MouseLeave:Connect(function()
            tween:Create(clDg, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0.6, Size = UDim2.new(0, 36, 0, 36), Position = UDim2.new(1, -18, 0, 18)}):Play()
            tween:Create(clLn, TweenInfo.new(0.2), {Color = col.line, Transparency = 0.5}):Play()
            tween:Create(clPc, TweenInfo.new(0.2), {ImageColor3 = col.textSoft, Rotation = 0}):Play()
        end)
    end

    -- ══════════════════════════════════════════
    --  Main UI Construction
    -- ══════════════════════════════════════════
    function Main:mk()
        if self.gui then self.gui:Destroy() end
        self.gui = Instance.new("ScreenGui")
        self.gui.ResetOnSpawn = false
        self.gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        self.gui.IgnoreGuiInset = true

        local bl   = Instance.new("BlurEffect")
        local dk   = Instance.new("Frame")
        local bx   = Instance.new("Frame")
        local bxCr = Instance.new("UICorner")
        local bxLn = Instance.new("UIStroke")
        local bxGl = Instance.new("Frame")
        local glCr = Instance.new("UICorner")
        local tp   = Instance.new("Frame")
        local icBx = Instance.new("Frame")
        local icCr = Instance.new("UICorner")
        local icLn = Instance.new("UIStroke")
        local mIc  = Instance.new("ImageLabel")
        local tt   = Instance.new("TextLabel")
        local st   = Instance.new("TextLabel")
        local clBt = Instance.new("TextButton")
        local clCr = Instance.new("UICorner")
        local clLn = Instance.new("UIStroke")
        local clIc = Instance.new("ImageLabel")

        local dcBt = Instance.new("TextButton")
        local dcCr = Instance.new("UICorner")
        local dcLn = Instance.new("UIStroke")
        local dcIc = Instance.new("ImageLabel")

        local mnAr = Instance.new("Frame")
        local inBx = Instance.new("Frame")
        local inCr = Instance.new("UICorner")
        local inLn = Instance.new("UIStroke")
        local kIc  = Instance.new("ImageLabel")
        local kF   = Instance.new("TextBox")
        local aBx, aLb, aTg, aCr, aKn, knCr
        local btBx = Instance.new("Frame")
        local lBt  = Instance.new("TextButton")
        local lCr  = Instance.new("UICorner")
        local lLn  = Instance.new("UIStroke")
        local lIc  = Instance.new("ImageLabel")
        local lTx  = Instance.new("TextLabel")
        local vBt  = Instance.new("TextButton")
        local vCr  = Instance.new("UICorner")
        local vLn  = Instance.new("UIStroke")
        local vIc  = Instance.new("ImageLabel")
        local vTx  = Instance.new("TextLabel")

        bl.Size = 20
        bl.Parent = lighting

        dk.Size = UDim2.new(1, 0, 1, 0)
        dk.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        dk.BackgroundTransparency = 0.75
        dk.BorderSizePixel = 0
        dk.Parent = self.gui
        tween:Create(dk, TweenInfo.new(0.6), {BackgroundTransparency = 0.75}):Play()

        bx.Size = UDim2.new(0, 330, 0, 420)
        bx.Position = UDim2.new(0.5, 0, 0.5, 30)
        bx.AnchorPoint = Vector2.new(0.5, 0.5)
        bx.BackgroundColor3 = col.main
        bx.BackgroundTransparency = 0.1
        bx.BorderSizePixel = 0
        bx.Parent = dk
        tween:Create(bx, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundTransparency = 0}):Play()

        bxCr.CornerRadius = UDim.new(0, mainCorner)
        bxCr.Parent = bx
        bxLn.Color = col.line
        bxLn.Thickness = 1
        bxLn.Transparency = 0.4
        bxLn.Parent = bx
        bxGl.Size = UDim2.new(1, 0, 1, 0)
        bxGl.BackgroundColor3 = col.glass
        bxGl.BackgroundTransparency = 0.985
        bxGl.BorderSizePixel = 0
        bxGl.Parent = bx
        glCr.CornerRadius = UDim.new(0, mainCorner)
        glCr.Parent = bxGl

        tp.Size = UDim2.new(1, 0, 0, 60)
        tp.BackgroundTransparency = 1
        tp.Parent = bx

        icBx.Size = UDim2.new(0, 90, 0, 90)
        icBx.Position = UDim2.new(0.5, 0, 0, 16)
        icBx.AnchorPoint = Vector2.new(0.5, 0)
        icBx.BackgroundColor3 = col.light
        icBx.BackgroundTransparency = 0.5
        icBx.BorderSizePixel = 0
        icBx.Parent = tp
        icCr.CornerRadius = UDim.new(0, iconCorner)
        icCr.Parent = icBx
        icLn.Color = col.lineLight
        icLn.Thickness = 1
        icLn.Transparency = 0.6
        icLn.Parent = icBx

        mIc.Size = UDim2.new(1, -10, 1, -10)
        mIc.Position = UDim2.new(0.5, 0, 0.5, 0)
        mIc.AnchorPoint = Vector2.new(0.5, 0.5)
        mIc.BackgroundTransparency = 1
        mIc.Image = pics.main
        mIc.ImageColor3 = col.text
        mIc.ScaleType = Enum.ScaleType.Fit
        mIc.Parent = icBx

        tt.Size = UDim2.new(1, -30, 0, 20)
        tt.Position = UDim2.new(0.5, 0, 0, 114)
        tt.AnchorPoint = Vector2.new(0.5, 0)
        tt.BackgroundTransparency = 1
        tt.Text = self.t
        tt.TextColor3 = col.text
        tt.TextSize = 20
        tt.Font = curFnt.bold
        tt.Parent = tp

        st.Size = UDim2.new(1, -30, 0, 16)
        st.Position = UDim2.new(0.5, 0, 0, 138)
        st.AnchorPoint = Vector2.new(0.5, 0)
        st.BackgroundTransparency = 1
        st.Text = self.s
        st.TextColor3 = col.textSoft
        st.TextSize = 12
        st.Font = curFnt.normal
        st.Parent = tp

        clBt.Size = UDim2.new(0, 36, 0, 36)
        clBt.Position = UDim2.new(1, -18, 0, 18)
        clBt.AnchorPoint = Vector2.new(1, 0)
        clBt.BackgroundColor3 = col.light
        clBt.BackgroundTransparency = 0.6
        clBt.BorderSizePixel = 0
        clBt.AutoButtonColor = false
        clBt.Text = ""
        clBt.Parent = tp
        clCr.CornerRadius = UDim.new(0, buttonCorner)
        clCr.Parent = clBt
        clLn.Color = col.line
        clLn.Thickness = 1
        clLn.Transparency = 0.5
        clLn.Parent = clBt
        clIc.Size = UDim2.new(0, 16, 0, 16)
        clIc.Position = UDim2.new(0.5, 0, 0.5, 0)
        clIc.AnchorPoint = Vector2.new(0.5, 0.5)
        clIc.BackgroundTransparency = 1
        clIc.Image = pics.close
        clIc.ImageColor3 = col.textSoft
        clIc.ScaleType = Enum.ScaleType.Fit
        clIc.Parent = clBt

        dcBt.Size = UDim2.new(0, 36, 0, 36)
        dcBt.Position = UDim2.new(0, 18, 0, 18)
        dcBt.BackgroundColor3 = col.blue
        dcBt.BackgroundTransparency = 0.3
        dcBt.BorderSizePixel = 0
        dcBt.AutoButtonColor = false
        dcBt.Text = ""
        dcBt.Parent = tp
        dcCr.CornerRadius = UDim.new(0, buttonCorner)
        dcCr.Parent = dcBt
        dcLn.Color = col.blueDark
        dcLn.Thickness = 1
        dcLn.Transparency = 0.5
        dcLn.Parent = dcBt
        dcIc.Size = UDim2.new(0, 18, 0, 18)
        dcIc.Position = UDim2.new(0.5, 0, 0.5, 0)
        dcIc.AnchorPoint = Vector2.new(0.5, 0.5)
        dcIc.BackgroundTransparency = 1
        dcIc.Image = pics.discord
        dcIc.ImageColor3 = col.text
        dcIc.ScaleType = Enum.ScaleType.Fit
        dcIc.Parent = dcBt

        mnAr.Size = UDim2.new(1, -30, 1, -135)
        mnAr.Position = UDim2.new(0, 15, 0, 165)
        mnAr.BackgroundTransparency = 1
        mnAr.Parent = bx

        inBx.Size = UDim2.new(1, 0, 0, 50)
        inBx.Position = UDim2.new(0, 0, 0, 22)
        inBx.BackgroundColor3 = col.light
        inBx.BackgroundTransparency = 0.6
        inBx.BorderSizePixel = 0
        inBx.Parent = mnAr
        inCr.CornerRadius = UDim.new(0, inputCorner)
        inCr.Parent = inBx
        inLn.Color = col.line
        inLn.Thickness = 1
        inLn.Transparency = 0.5
        inLn.Parent = inBx

        kIc.Size = UDim2.new(0, 14, 0, 14)
        kIc.Position = UDim2.new(0, 12, 0.5, 0)
        kIc.AnchorPoint = Vector2.new(0, 0.5)
        kIc.BackgroundTransparency = 1
        kIc.Image = pics.key
        kIc.ImageColor3 = col.textFaint
        kIc.ScaleType = Enum.ScaleType.Fit
        kIc.Parent = inBx

        kF.Size = UDim2.new(1, -40, 1, 0)
        kF.Position = UDim2.new(0, 35, 0, 0)
        kF.BackgroundTransparency = 1
        kF.PlaceholderText = "Enter key here..."
        kF.PlaceholderColor3 = col.textFaint
        kF.Text = getgenv().SCRIPT_KEY or ""
        kF.TextColor3 = col.text
        kF.TextSize = 14
        kF.Font = curFnt.normal
        kF.ClearTextOnFocus = false
        kF.TextTruncate = Enum.TextTruncate.AtEnd
        kF.Parent = inBx

        aBx = Instance.new("Frame")
        aLb = Instance.new("TextLabel")
        aTg = Instance.new("TextButton")
        aCr = Instance.new("UICorner")
        aKn = Instance.new("Frame")
        knCr = Instance.new("UICorner")

        aBx.Size = UDim2.new(1, 0, 0, 36)
        aBx.Position = UDim2.new(0, 0, 0, 90)
        aBx.BackgroundTransparency = 1
        aBx.Parent = mnAr

        aLb.Size = UDim2.new(0, 100, 1, 0)
        aLb.BackgroundTransparency = 1
        aLb.Text = "Auto Load"
        aLb.TextColor3 = col.textSoft
        aLb.TextSize = 14
        aLb.Font = curFnt.normal
        aLb.TextXAlignment = Enum.TextXAlignment.Left
        aLb.Parent = aBx

        aTg.Size = UDim2.new(0, 52, 0, 26)
        aTg.Position = UDim2.new(1, 0, 0.5, 0)
        aTg.AnchorPoint = Vector2.new(1, 0.5)
        aTg.BackgroundColor3 = self.cf.autoLoad and col.blue or col.light
        aTg.BackgroundTransparency = self.cf.autoLoad and 0.2 or 0.6
        aTg.BorderSizePixel = 0
        aTg.AutoButtonColor = false
        aTg.Text = ""
        aTg.Parent = aBx
        aCr.CornerRadius = UDim.new(1, 0)
        aCr.Parent = aTg

        aKn.Size = UDim2.new(0, 22, 0, 22)
        aKn.Position = self.cf.autoLoad and UDim2.new(1, -24, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
        aKn.AnchorPoint = Vector2.new(0, 0.5)
        aKn.BackgroundColor3 = col.text
        aKn.BorderSizePixel = 0
        aKn.Parent = aTg
        knCr.CornerRadius = UDim.new(1, 0)
        knCr.Parent = aKn

        btBx.Size = UDim2.new(1, 0, 0, 98)
        btBx.Position = UDim2.new(0, 0, 0, 144)
        btBx.BackgroundTransparency = 1
        btBx.Parent = mnAr

        lBt.Size = UDim2.new(1, 0, 0, 44)
        lBt.BackgroundColor3 = col.light
        lBt.BackgroundTransparency = 0.6
        lBt.BorderSizePixel = 0
        lBt.AutoButtonColor = false
        lBt.Text = ""
        lBt.Parent = btBx
        lCr.CornerRadius = UDim.new(0, buttonCorner)
        lCr.Parent = lBt
        lLn.Color = col.line
        lLn.Thickness = 1
        lLn.Transparency = 0.5
        lLn.Parent = lBt
        lIc.Size = UDim2.new(0, 14, 0, 14)
        lIc.Position = UDim2.new(0, 12, 0.5, 0)
        lIc.AnchorPoint = Vector2.new(0, 0.5)
        lIc.BackgroundTransparency = 1
        lIc.Image = pics.link
        lIc.ImageColor3 = col.textFaint
        lIc.ScaleType = Enum.ScaleType.Fit
        lIc.Parent = lBt
        lTx.Size = UDim2.new(1, -40, 1, 0)
        lTx.Position = UDim2.new(0, 35, 0, 0)
        lTx.BackgroundTransparency = 1
        lTx.Text = "Get Key"
        lTx.TextColor3 = col.textSoft
        lTx.TextSize = 14
        lTx.Font = curFnt.bold
        lTx.TextXAlignment = Enum.TextXAlignment.Left
        lTx.Parent = lBt

        vBt.Size = UDim2.new(1, 0, 0, 44)
        vBt.Position = UDim2.new(0, 0, 0, 54)
        vBt.BackgroundColor3 = col.light
        vBt.BackgroundTransparency = 0.6
        vBt.BorderSizePixel = 0
        vBt.AutoButtonColor = false
        vBt.Text = ""
        vBt.Parent = btBx
        vCr.CornerRadius = UDim.new(0, buttonCorner)
        vCr.Parent = vBt
        vLn.Color = col.line
        vLn.Thickness = 1
        vLn.Transparency = 0.5
        vLn.Parent = vBt
        vIc.Size = UDim2.new(0, 14, 0, 14)
        vIc.Position = UDim2.new(0, 12, 0.5, 0)
        vIc.AnchorPoint = Vector2.new(0, 0.5)
        vIc.BackgroundTransparency = 1
        vIc.Image = pics.check
        vIc.ImageColor3 = col.textFaint
        vIc.ScaleType = Enum.ScaleType.Fit
        vIc.Parent = vBt
        vTx.Size = UDim2.new(1, -40, 1, 0)
        vTx.Position = UDim2.new(0, 35, 0, 0)
        vTx.BackgroundTransparency = 1
        vTx.Text = "Verify"
        vTx.TextColor3 = col.textSoft
        vTx.TextSize = 14
        vTx.Font = curFnt.bold
        vTx.TextXAlignment = Enum.TextXAlignment.Left
        vTx.Parent = vBt

        self.pt = {
            box = bx, closeButton = clBt, discordButton = dcBt, discordIcon = dcIc,
            keyField = kF, linkButton = lBt, verifyButton = vBt, inputBorder = inLn,
            dark = dk, blur = bl,
            autoToggle = aTg, autoKnob = aKn,
            linkWords = lTx, verifyWords = vTx,
            linkIcon = lIc, verifyIcon = vIc,
            keyIcon = kIc, closeIcon = clIc,
            iconBox = icBx, iconBorder = icLn,
            mainIcon = mIc, title = tt, subtitle = st,
        }

        self.pop = Pop.new(self.gui)

        self:gtD()
        self:addActs()
        self:addEvs()

        self.gui.Parent = game:GetService("CoreGui")

        self.gui.AncestryChanged:Connect(function(_, p)
            if p == nil then
                local b = lighting:FindFirstChild("KeySystemBlur")
                if b then b:Destroy() end
            end
        end)

        return self.gui
    end

    function Main:addActs()
        local p = self.pt

        p.discordButton.MouseEnter:Connect(function()
            tween:Create(p.discordButton, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0.1, Size = UDim2.new(0, 38, 0, 38), Position = UDim2.new(0, 17, 0, 17)}):Play()
            tween:Create(p.discordButton:FindFirstChild("UIStroke"), TweenInfo.new(0.2), {Transparency = 0.2, Thickness = 2}):Play()
            if p.discordIcon then tween:Create(p.discordIcon, TweenInfo.new(0.2), {ImageColor3 = col.text, Rotation = 10}):Play() end
        end)
        p.discordButton.MouseLeave:Connect(function()
            tween:Create(p.discordButton, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0.3, Size = UDim2.new(0, 36, 0, 36), Position = UDim2.new(0, 18, 0, 18)}):Play()
            tween:Create(p.discordButton:FindFirstChild("UIStroke"), TweenInfo.new(0.2), {Transparency = 0.5, Thickness = 1}):Play()
            if p.discordIcon then tween:Create(p.discordIcon, TweenInfo.new(0.2), {ImageColor3 = col.text, Rotation = 0}):Play() end
        end)
        p.discordButton.MouseButton1Click:Connect(function() self:shwS() end)

        p.closeButton.MouseEnter:Connect(function()
            tween:Create(p.closeButton, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0.3, Size = UDim2.new(0, 38, 0, 38), Position = UDim2.new(1, -19, 0, 17)}):Play()
            tween:Create(p.closeButton:FindFirstChild("UIStroke"), TweenInfo.new(0.2), {Color = col.lineLight, Transparency = 0.2, Thickness = 2}):Play()
            if p.closeIcon then tween:Create(p.closeIcon, TweenInfo.new(0.2), {ImageColor3 = col.text, Rotation = 90}):Play() end
        end)
        p.closeButton.MouseLeave:Connect(function()
            tween:Create(p.closeButton, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0.6, Size = UDim2.new(0, 36, 0, 36), Position = UDim2.new(1, -18, 0, 18)}):Play()
            tween:Create(p.closeButton:FindFirstChild("UIStroke"), TweenInfo.new(0.2), {Color = col.line, Transparency = 0.5, Thickness = 1}):Play()
            if p.closeIcon then tween:Create(p.closeIcon, TweenInfo.new(0.2), {ImageColor3 = col.textSoft, Rotation = 0}):Play() end
        end)

        p.autoToggle.MouseButton1Click:Connect(function()
            self.cf.autoLoad = not self.cf.autoLoad
            config:save(self.cf)
            local newPos = self.cf.autoLoad and UDim2.new(1, -24, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
            tween:Create(p.autoKnob, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = newPos}):Play()
            tween:Create(p.autoToggle, TweenInfo.new(0.3), {
                BackgroundColor3       = self.cf.autoLoad and col.blue or col.light,
                BackgroundTransparency = self.cf.autoLoad and 0.2 or 0.6,
            }):Play()
            if self.pop then
                self.pop:show(self.cf.autoLoad and "Auto load On" or "Auto load Off", "good", 2)
            end
        end)

        p.linkButton.MouseEnter:Connect(function()
            tween:Create(p.linkButton, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0.3, Size = UDim2.new(1, 2, 0, 46), Position = UDim2.new(0, -1, 0, -1)}):Play()
            tween:Create(p.linkButton:FindFirstChild("UIStroke"), TweenInfo.new(0.2), {Color = col.lineLight, Transparency = 0.1, Thickness = 2}):Play()
            if p.linkIcon then tween:Create(p.linkIcon, TweenInfo.new(0.2), {ImageColor3 = col.text, Rotation = 10}):Play() end
            tween:Create(p.linkWords, TweenInfo.new(0.2), {TextColor3 = col.text}):Play()
        end)
        p.linkButton.MouseLeave:Connect(function()
            tween:Create(p.linkButton, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0.6, Size = UDim2.new(1, 0, 0, 44), Position = UDim2.new(0, 0, 0, 0)}):Play()
            tween:Create(p.linkButton:FindFirstChild("UIStroke"), TweenInfo.new(0.2), {Color = col.line, Transparency = 0.5, Thickness = 1}):Play()
            if p.linkIcon then tween:Create(p.linkIcon, TweenInfo.new(0.2), {ImageColor3 = col.textFaint, Rotation = 0}):Play() end
            tween:Create(p.linkWords, TweenInfo.new(0.2), {TextColor3 = col.textSoft}):Play()
        end)

        p.verifyButton.MouseEnter:Connect(function()
            tween:Create(p.verifyButton, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0.3, Size = UDim2.new(1, 2, 0, 46), Position = UDim2.new(0, -1, 0, 53)}):Play()
            tween:Create(p.verifyButton:FindFirstChild("UIStroke"), TweenInfo.new(0.2), {Color = col.lineLight, Transparency = 0.1, Thickness = 2}):Play()
            if p.verifyIcon then tween:Create(p.verifyIcon, TweenInfo.new(0.2), {ImageColor3 = col.text, Rotation = 10}):Play() end
            tween:Create(p.verifyWords, TweenInfo.new(0.2), {TextColor3 = col.text}):Play()
        end)
        p.verifyButton.MouseLeave:Connect(function()
            tween:Create(p.verifyButton, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0.6, Size = UDim2.new(1, 0, 0, 44), Position = UDim2.new(0, 0, 0, 54)}):Play()
            tween:Create(p.verifyButton:FindFirstChild("UIStroke"), TweenInfo.new(0.2), {Color = col.line, Transparency = 0.5, Thickness = 1}):Play()
            if p.verifyIcon then tween:Create(p.verifyIcon, TweenInfo.new(0.2), {ImageColor3 = col.textFaint, Rotation = 0}):Play() end
            tween:Create(p.verifyWords, TweenInfo.new(0.2), {TextColor3 = col.textSoft}):Play()
        end)

        p.keyField.Focused:Connect(function()
            tween:Create(p.inputBorder, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Color = col.lineLight, Transparency = 0, Thickness = 2}):Play()
            if p.keyIcon then tween:Create(p.keyIcon, TweenInfo.new(0.2), {ImageColor3 = col.text, Rotation = 10}):Play() end
        end)
        p.keyField.FocusLost:Connect(function()
            tween:Create(p.inputBorder, TweenInfo.new(0.2), {Color = col.line, Transparency = 0.5, Thickness = 1}):Play()
            if p.keyIcon then tween:Create(p.keyIcon, TweenInfo.new(0.2), {ImageColor3 = col.textFaint, Rotation = 0}):Play() end
        end)
    end

    function Main:addEvs()
        table.insert(self.ls, self.pt.closeButton.MouseButton1Click:Connect(function() self:cls() end))
        table.insert(self.ls, self.pt.linkButton.MouseButton1Click:Connect(function() self:hnL() end))
        table.insert(self.ls, self.pt.verifyButton.MouseButton1Click:Connect(function() self:hnV() end))
        table.insert(self.ls, self.pt.keyField.FocusLost:Connect(function(e) if e then self:hnV() end end))
    end

    function Main:hnL()
        local l, err = Junkie.get_key_link()
        if not l then
            local msg = (err == "RATE_LIMITTED") and "Rate limited — wait 5 min" or "Failed to get link"
            if self.pop then self.pop:show(msg, "bad", 2) end
            return
        end
        if setclipboard then
            setclipboard(l)
            if self.pop then self.pop:show("Link copied", "good", 1.5) end
        end
    end

    -- ══════════════════════════════════════════
    --  Verify handler with Dashboard Registration
    -- ══════════════════════════════════════════
    function Main:hnV()
        local k = self.pt.keyField.Text:gsub("%s+", "")
        if k == "" then if self.pop then self.pop:show("Enter a key", "bad", 1.5) end return end

        self.pt.verifyWords.Text = ""
        if self.pt.verifyIcon then self.pt.verifyIcon.Visible = false end

        -- Spinner
        local sp   = Instance.new("Frame")
        local spCr = Instance.new("UICorner")
        sp.Size = UDim2.new(0, 14, 0, 14)
        sp.Position = UDim2.new(0, 35, 0.5, -7)
        sp.BackgroundColor3 = col.textSoft
        sp.BackgroundTransparency = 0.5
        sp.BorderSizePixel = 0
        sp.Parent = self.pt.verifyButton
        spCr.CornerRadius = UDim.new(1, 0)
        spCr.Parent = sp
        tween:Create(sp, TweenInfo.new(0.8, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {Rotation = 360}):Play()

        local res = Junkie.check_key(k)

        sp:Destroy()
        if self.pt.verifyIcon then self.pt.verifyIcon.Visible = true end
        self.pt.verifyWords.Text = "Verify"

        -- Success
        if res and res.valid then
            local hwid = getHWID()

            kpK(k)
            getgenv().SCRIPT_KEY = k

            -- Register user to dashboard
            task.spawn(function()
                registerUser(k, hwid)
                -- Additional dashboard logging
                pcall(function()
                    local http = game:GetService("HttpService")
                    local req = (syn and syn.request) or http_request or request
                    if req then
                        req({
                            Url = "https://api.jnkie.com/api/v2/sessions/start",
                            Method = "POST",
                            Headers = {
                                ["Authorization"] = "Bearer " .. API_KEY,
                                ["Content-Type"] = "application/json"
                            },
                            Body = http:JSONEncode({
                                key = k,
                                hwid = hwid,
                                user_id = players.LocalPlayer and players.LocalPlayer.UserId or 0,
                                username = players.LocalPlayer and players.LocalPlayer.Name or "Unknown",
                                timestamp = os.time()
                            })
                        })
                    end
                end)
            end)

            startHeartbeat()

            if self.pop then self.pop:show("Verified", "good", 1.5) end
            task.wait(0.8)
            self:cls()
            
            -- ══════════════════════════════════════════
            --  PAYLOAD EXECUTION AREA
            --  Paste your script below this line
            -- ═════════════════════════════════════════=
            
            --[[
                ==========================================
                YOUR SCRIPT GOES HERE
                This executes after successful verification
                ==========================================
            --]]
            
            -- Example: loadstring(game:HttpGet("your_script_url"))()
            
            -- ═════════════════════════════════════════=
            --  END PAYLOAD
            -- ═════════════════════════════════════════=
            
            return
        end

        -- Failure
        local errCode = res and res.error
        drK()

        if errCode == "HWID_BANNED" then
            if self.pop then self.pop:show("Your device is banned.", "bad", 4) end
            task.wait(4)
            players.LocalPlayer:Kick("Device banned.")
            return
        end

        local msg = friendlyError(errCode)
        if self.pop then self.pop:show(msg, "bad", 2.5) end
    end

    function Main:cls(skp)
        if not skp then getgenv().UI_CLOSED = true end
        for _, i in ipairs(self.ls) do pcall(function() i:Disconnect() end) end
        if self.pt.box  then tween:Create(self.pt.box,  TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 0.5, -30)}):Play() end
        if self.pt.dark then tween:Create(self.pt.dark, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play() end
        task.wait(0.3)
        if self.pt.blur then self.pt.blur:Destroy() end
        if self.gui     then self.gui:Destroy() end
        return getgenv().SCRIPT_KEY
    end

    -- ═════════════════════════════════════════=
    --  Startup with Security Checks
    -- ═════════════════════════════════════════=
    local hwid = getHWID()

    -- Pre-check HWID ban
    local banned, banMsg = checkHWIDBan(hwid)
    if banned then
        local errGui = Instance.new("ScreenGui")
        errGui.ResetOnSpawn = false
        errGui.IgnoreGuiInset = true
        local errLbl = Instance.new("TextLabel")
        errLbl.Size = UDim2.new(1, 0, 0, 50)
        errLbl.Position = UDim2.new(0, 0, 0.5, -25)
        errLbl.BackgroundTransparency = 1
        errLbl.Text = banMsg or "Your device is banned."
        errLbl.TextColor3 = Color3.fromRGB(255, 100, 100)
        errLbl.TextSize = 18
        errLbl.Font = Enum.Font.GothamBold
        errLbl.Parent = errGui
        errGui.Parent = game:GetService("CoreGui")
        task.wait(5)
        errGui:Destroy()
        players.LocalPlayer:Kick(banMsg or "Device banned.")
        return nil
    end

    local svd = gtK()
    local chk = svd or getgenv().SCRIPT_KEY

    if chk and usr.autoLoad then
        local res = Junkie.check_key(chk)

        if res and res.valid then
            if res.message == "KEYLESS" then
                getgenv().SCRIPT_KEY = "KEYLESS"
                startHeartbeat()
                
                -- Execute payload for keyless
                --[[ PAYLOAD AREA FOR KEYLESS MODE --]]
                return getgenv().SCRIPT_KEY
            end
            
            if res.message == "KEY_VALID" then
                if not svd then kpK(chk) end
                getgenv().SCRIPT_KEY = chk
                task.spawn(registerUser, chk, hwid)
                startHeartbeat()
                
                -- Execute payload for validated key
                --[[ PAYLOAD AREA FOR VALIDATED KEY --]]
                return getgenv().SCRIPT_KEY
            end
        end

        if svd then drK() end
        getgenv().SCRIPT_KEY = nil

        if res and res.error == "HWID_BANNED" then
            players.LocalPlayer:Kick("Device banned.")
            return nil
        end
    end

    -- Show UI
    local app = Main.new()
    app:mk()

    while not getgenv().UI_CLOSED do
        task.wait()
    end

    return getgenv().SCRIPT_KEY
end)()

print("Reze hub loaded")
