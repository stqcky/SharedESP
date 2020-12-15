local GUI = {
    General = {},
    Team = {},
    Enemy = {}
}

local ESP = {
    Font = draw.CreateFont("Tahoma", 16, 0),
    Team = {
        Box = 0,
        BoxColor = {0, 0, 0, 0},
        Name = false,
        HealthBar = false,
        HealthNumber = false,
        Weapon = false,
        Ammo = false
    },
    Enemy = {
        Box = 0,
        BoxColor = {0, 0, 0, 0},
        Name = false,
        HealthBar = false,
        HealthNumber = false,
        Weapon = false,
        Ammo = false
    },
    Types = {"Team", "Enemy"},
    ESPSettings = {"Box", "Name", "HealthBar", "HealthNumber", "Weapon", "Ammo"},
    LocalPlayers = {}
}

local Network = {
    Socket = network.Socket("UDP"),
    ServerList = {},
    ServerAddress = "",
    ServerPort = 57020,
    ClientPort = 57021,
    PacketType = {
        HEARTBEAT = 0,
        PLAYERINFO = 1,
        SERVERINFO = 2,
        REQUESTSERVERINFO = 3
    },
    ServerIP = "",
    SharedPlayers = {},
    PacketSize = 4096,
    PlayerLastUpdate = {}
}

local Utils = {
    WeaponTable = {[1] = "DEAGLE", [2] = "ELITE", [3] = "FIVESEVEN", [4] = "GLOCK", [7] = "AK47", [8] = "AUG", [9] = "AWP", [10] = "FAMAS", [11] = "G3SG1", [13] = "GALILAR", [14] = "M249", [16] = "M4A1", [17] = "MAC10", [19] = "P90", [23] = "MP5SD", [24] = "UMP45", [25] = "XM1014", [26] = "BIZON", [27] = "MAG7", [28] = "NEGEV", [29] = "SAWEDOFF", [30] = "TEC9", [31] = "TASER", [32] = "HKP2000", [33] = "MP7", [34] = "MP9", [35] = "NOVA", [36] = "P250", [37] = "SHIELD", [38] = "SCAR20", [39] = "SG556", [40] = "SSG08", [41] = "KNIFE", [42] = "KNIFE", [43] = "FLASHBANG", [44] = "HEGRENADE", [45] = "SMOKEGRENADE", [46] = "MOLOTOV", [47] = "DECOY", [48] = "INCGRENADE", [49] = "C4", [57] = "HEALTHSHOT", [59] = "KNIFE", [60] = "M4A1 SILENCER", [61] = "USP SILENCER", [63] = "CZ75A", [64] = "REVOLVER", [68] = "TAGRENADE", [69] = "FISTS", [70] = "BREACH CHARGE", [72] = "TABLET", [74] = "MELEE", [75] = "AXE", [76] = "HAMMER", [78] = "SPANNER", [80] = "KNIFE", [81] = "FIREBOMB", [82] = "DIVERSION", [83] = "FRAG GRENADE", [84] = "SNOWBALL", [85] = "BUMP MINE", [500] = "KNIFE", [503] = "KNIFE", [505] = "KNIFE", [506] = "KNIFE", [507] = "KNIFE", [508] = "KNIFE", [509] = "KNIFE", [512] = "KNIFE", [514] = "KNIFE", [515] = "KNIFE", [516] = "KNIFE", [517] = "KNIFE", [518] = "KNIFE", [519] = "KNIFE", [520] = "KNIFE", [521] = "KNIFE", [522] = "KNIFE", [523] = "KNIFE", [525] = "KNIFE"},
    WeaponMaxAmmo = {7, 30, 20, 20, 0, 0, 30, 30, 10, 25, 20, 0, 35, 100, 0, 30, 30, 18, 50, 0, 0, 0, 30, 25, 7, 64, 5, 150, 7, 18, 0, 13, 30, 30, 8, 13, 0, 20, 30, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 25, 12, 0, 12, 8}
}

GUI.Tab = gui.Tab( gui.Reference("Visuals"), "sharedesp", "Shared ESP" )

GUI.General.GBOX = gui.Groupbox( GUI.Tab, "General", 16, 16, 192, 0 )
GUI.General.Enable = gui.Checkbox( GUI.General.GBOX, "enable", "Enable", false ); GUI.General.Enable:SetDescription("Enable Shared ESP.")
GUI.General.Server = gui.Combobox( GUI.General.GBOX, "general.server", "Server", "Loading server list..." ); GUI.General.Server:SetDescription("Configure the server.")
GUI.General.ShareMulti = gui.Multibox( GUI.General.GBOX, "Share" ); GUI.General.ShareMulti:SetDescription("Configure what you want to share.")
GUI.General.ShareEnemy = gui.Checkbox( GUI.General.ShareMulti, "general.share.enemies", "Enemies", false )
GUI.General.ShareTeam = gui.Checkbox( GUI.General.ShareMulti, "general.share.team", "Teammates", false )
GUI.General.OnlyDormant = gui.Checkbox( GUI.General.GBOX, "general.onlydormant", "Only draw Dormant", false ); GUI.General.OnlyDormant:SetDescription("Will only draw Dormant players.")
GUI.General.InterpolationStrength = gui.Slider( GUI.General.GBOX, "general.interpstrength", "Interpolation Strength", 20, 1, 100 ); GUI.General.InterpolationStrength:SetDescription("Configure the position smoothing.")

GUI.Team.GBOX = gui.Groupbox( GUI.Tab, "Teammates", 16 + 16 + 192, 16, 192, 0 )
GUI.Team.Box = gui.Combobox( GUI.Team.GBOX, "team.box", "Box", "Off", "Outlined", "Normal" ); GUI.Team.Box:SetDescription("Draw 2D box around entity.")
GUI.Team.BoxColor = gui.ColorPicker( GUI.Team.Box, "team.box.color", "", 30, 154, 247, 255 )
GUI.Team.Name = gui.Checkbox( GUI.Team.GBOX, "team.name", "Name", false ); GUI.Team.Name:SetDescription("Draw entity name.")
GUI.Team.HealthMulti = gui.Multibox( GUI.Team.GBOX, "Health" ); GUI.Team.HealthMulti:SetDescription("Configure health options.")
GUI.Team.HealthBar = gui.Checkbox( GUI.Team.HealthMulti, "team.health.bar", "Bar", false )
GUI.Team.HealthNumber = gui.Checkbox( GUI.Team.HealthMulti, "team.health.number", "Number", false )
GUI.Team.Weapon = gui.Checkbox( GUI.Team.GBOX, "team.weapon", "Weapon", false ); GUI.Team.Weapon:SetDescription("Draw weapon of player.")
GUI.Team.Ammo = gui.Checkbox( GUI.Team.GBOX, "team.ammo", "Ammo", false ); GUI.Team.Ammo:SetDescription("Amount of ammo left in weapon.")

GUI.Enemy.GBOX = gui.Groupbox( GUI.Tab, "Enemies", 16 + 16 + 192 + 16 + 192, 16, 192, 0 )
GUI.Enemy.Box = gui.Combobox( GUI.Enemy.GBOX, "enemy.box", "Box", "Off", "Outlined", "Normal" ); GUI.Enemy.Box:SetDescription("Draw 2D box around entity.")
GUI.Enemy.BoxColor = gui.ColorPicker( GUI.Enemy.Box, "enemy.box.color", "", 240, 60, 30, 255 )
GUI.Enemy.Name = gui.Checkbox( GUI.Enemy.GBOX, "enemy.name", "Name", false ); GUI.Enemy.Name:SetDescription("Draw entity name.")
GUI.Enemy.HealthMulti = gui.Multibox( GUI.Enemy.GBOX, "Health" ); GUI.Enemy.HealthMulti:SetDescription("Configure health options.")
GUI.Enemy.HealthBar = gui.Checkbox( GUI.Enemy.HealthMulti, "enemy.health.bar", "Bar", false )
GUI.Enemy.HealthNumber = gui.Checkbox( GUI.Enemy.HealthMulti, "enemy.health.number", "Number", false )
GUI.Enemy.Weapon = gui.Checkbox( GUI.Enemy.GBOX, "enemy.weapon", "Weapon", false ); GUI.Enemy.Weapon:SetDescription("Draw weapon of player.")
GUI.Enemy.Ammo = gui.Checkbox( GUI.Enemy.GBOX, "enemy.ammo", "Ammo", false ); GUI.Enemy.Ammo:SetDescription("Amount of ammo left in weapon.")


function Utils:ResolveWeaponID(WeaponID)
    return Utils.WeaponTable[WeaponID] or "UNKNOWN"
end

function Utils:GetWeaponMaxAmmo(WeaponID)
    return Utils.WeaponMaxAmmo[WeaponID] or 1
end

function Utils:Split(Text, Separator)
    local Table = {}
    for String in string.gmatch(Text, "([^" .. Separator .. "]+)") do
        Table[#Table + 1] = String
    end
    return Table
end


function ESP:UpdateSettings()
    for i = 1, 2 do
        for i2 = 1, #ESP.ESPSettings do
            ESP[ESP.Types[i]][ESP.ESPSettings[i2]] = GUI[ESP.Types[i]][ESP.ESPSettings[i2]]:GetValue()
        end
        ESP[ESP.Types[i]].BoxColor = {GUI[ESP.Types[i]].BoxColor:GetValue()}
    end
end

function ESP:HealthToColor(Health)
    return Health > 50 and 255 * ((100 - Health * 2) / 100) or 255, Health < 50 and 255 * (Health * 2 / 100) or 255, 0, 255
end

function ESP:DrawFilledRect(x1, y1, x2, y2, Color)
    draw.Color(unpack(Color))
    for i = x1, x2 do
        draw.Line( i, y1, i, y2 )
    end
end

function ESP:DrawESP(PlayerIndex)
    local NetworkedPlayer = Network.SharedPlayers[PlayerIndex]
    local Entity = entities.GetByIndex(PlayerIndex)

    local ESPSettings = Entity:GetTeamNumber() == entities.GetLocalPlayer():GetTeamNumber() and ESP.Team or ESP.Enemy
    local vecOrigin = ESP.LocalPlayers[PlayerIndex]
    
    local ScreenHeadX, ScreenHeadY = client.WorldToScreen( vecOrigin + Vector3(0, 0, 82) )
    local ScreenLegsX, ScreenLegsY = client.WorldToScreen( vecOrigin - Vector3(0, 0, 10) )
    if not ScreenHeadX or not ScreenHeadY or not ScreenLegsX or not ScreenLegsY then return end
    
    local BoxHeight = ScreenLegsY - ScreenHeadY
    local BoxWidth = BoxHeight / 2.2
    local BoxLeft = ScreenLegsX - BoxWidth / 2
    local BoxRight = ScreenLegsX + BoxWidth / 2
    local BoxTop = ScreenHeadY + BoxWidth / 5
    local BoxBottom = ScreenHeadY + BoxHeight

    if ESPSettings.Box ~= 0 then
        draw.Color(unpack(ESPSettings.BoxColor))
        draw.OutlinedRect( BoxLeft, BoxTop, BoxRight, BoxBottom )

        if ESPSettings.Box == 1 then
            draw.Color(0, 0, 0, 255)
            draw.OutlinedRect(BoxLeft - 1, BoxTop - 1, BoxRight + 1, BoxBottom + 1)
            draw.OutlinedRect(BoxLeft + 1, BoxTop + 1, BoxRight - 1, BoxBottom - 1)

            BoxLeft = BoxLeft - 1
            BoxTop = BoxTop - 1
            BoxRight = BoxRight + 1
            BoxBottom = BoxBottom + 1
        end
    end

    if ESPSettings.Name then
        local EntityName = Entity:GetName()
        local NameWidth, NameHeight = draw.GetTextSize(EntityName)
        draw.Color(255, 255, 255, 255)
        draw.TextShadow( ScreenLegsX - NameWidth / 2, BoxTop - 15, EntityName )
    end

    if ESPSettings.HealthBar then
        local EntityHealth = NetworkedPlayer.Health
        ESP:DrawFilledRect( BoxLeft - 6, BoxTop, BoxLeft - 2, BoxBottom, {0, 0, 0, 150} )
        ESP:DrawFilledRect(BoxLeft - 5, BoxTop + 1 + ((100 - EntityHealth) / 100 * (BoxBottom - BoxTop)), BoxLeft - 4, BoxBottom - 1, {ESP:HealthToColor(EntityHealth)})
    end

    if ESPSettings.HealthNumber then
        local EntityHealth = tostring(NetworkedPlayer.Health)
        local HealthNumberWidth, HealthNumberHeight = draw.GetTextSize(EntityHealth)
        draw.Color(255, 255, 255, 255)
        draw.TextShadow(BoxLeft - HealthNumberWidth - 2 - 6 * (ESPSettings.HealthBar and 1 or 0), BoxTop, EntityHealth)
    end

    local WeaponNameWidth, WeaponNameHeight = nil, nil
    if ESPSettings.Weapon then
        local WeaponName = Utils:ResolveWeaponID(NetworkedPlayer.WeaponID)
        WeaponNameWidth, WeaponNameHeight = draw.GetTextSize(WeaponName)
        draw.Color(255, 255, 255, 255)
        draw.TextShadow(ScreenLegsX - WeaponNameWidth / 2, BoxBottom + WeaponNameHeight / 2, WeaponName)
    end

    if ESPSettings.Ammo then
        if NetworkedPlayer.WeaponAmmo ~= -1 then
            local Ammo = tostring(NetworkedPlayer.WeaponAmmo)
            local MaxAmmo = tostring(Utils:GetWeaponMaxAmmo(NetworkedPlayer.WeaponID))
            local FullAmmo = Ammo .. "/" .. MaxAmmo
            local FullAmmoWidth, FullAmmoHeight = draw.GetTextSize(FullAmmo)
            draw.Color(255, 255, 255, 255)
            draw.TextShadow(ScreenLegsX - FullAmmoWidth / 2, BoxBottom + FullAmmoHeight / 2 + (ESPSettings.Weapon and WeaponNameHeight * 1.5 or 0), FullAmmo)
        end
    end
end

function ESP:Interpolate()
    for PlayerIndex, PlayerPosition in pairs(ESP.LocalPlayers) do
        local NetworkedPlayer = Network.SharedPlayers[PlayerIndex]
        if NetworkedPlayer then
            local NetworkedPos = Vector3(NetworkedPlayer.OriginX, NetworkedPlayer.OriginY, NetworkedPlayer.OriginZ)

            ESP.LocalPlayers[PlayerIndex] = PlayerPosition + ((NetworkedPos - PlayerPosition) * globals.AbsoluteFrameTime() * GUI.General.InterpolationStrength:GetValue())
        else
            ESP.LocalPlayers[PlayerIndex] = nil
        end
    end
end


function Network:StringifyPlayer(Entity)
    local vecOrigin = Entity:GetAbsOrigin()
    local OriginX = tostring(math.modf(vecOrigin.x / 2))
    local OriginY = tostring(math.modf(vecOrigin.y / 2))
    local OriginZ = tostring(math.modf(vecOrigin.z / 2))

    local PlayerIndex = string.format("%x", Entity:GetIndex())
    local PlayerHealth = string.format("%x", Entity:GetHealth())
    local PlayerWeaponID = string.format("%x", Entity:GetWeaponID())
    local PlayerWeaponAmmo = tostring(Entity:GetPropEntity("m_hActiveWeapon"):GetPropInt("m_iClip1"))

    return table.concat({PlayerIndex, OriginX, OriginY, OriginZ, PlayerHealth, PlayerWeaponID, PlayerWeaponAmmo}, ",")
end

function Network:UnstringifyPlayer(PlayerString)
    local InfoTable = Utils:Split(PlayerString, ",")
    local Player = {
        Index = tonumber(InfoTable[1], 16),
        OriginX = tonumber(InfoTable[2]) * 2,
        OriginY = tonumber(InfoTable[3]) * 2,
        OriginZ = tonumber(InfoTable[4]) * 2,
        Health = tonumber(InfoTable[5], 16),
        WeaponID = tonumber(InfoTable[6], 16),
        WeaponAmmo = tonumber(InfoTable[7])
    }
    return Player
end

function Network:MakePacket(Packet, PacketType)
    return tostring(PacketType) .. tostring(Packet)
end

function Network:SendPacket(Packet, PacketType)
    Network.Socket:SendTo(Network.ServerAddress, Network.ServerPort, Network:MakePacket(Packet, PacketType))
end

function Network:SendPlayerStrings()
    if not Network.ServerIP or Network.ServerIP == "loopback" then return end

    local EntityList = entities.FindByClass("CCSPlayer")
    local LocalPlayer = entities.GetLocalPlayer()
    local PlayerStrings = {}

    for i = 1, #EntityList do
        local Entity = EntityList[i]
        local Team = Entity:GetTeamNumber() == LocalPlayer:GetTeamNumber()

        if ((not Team and GUI.General.ShareEnemy:GetValue()) or (Team and GUI.General.ShareTeam:GetValue())) and not Entity:IsDormant() and Entity:IsAlive() then
            PlayerStrings[#PlayerStrings + 1] = Network:StringifyPlayer(Entity)
        end
    end

    if PlayerStrings[1] then
        Network:SendPacket(table.concat(PlayerStrings, "|"), Network.PacketType.PLAYERINFO)
    end
end

function Network:SendServerIP(ServerIP)
    Network:SendPacket(ServerIP, Network.PacketType.SERVERINFO)
end

function Network:SendHeartbeat()
    Network:SendPacket("", Network.PacketType.HEARTBEAT)
end

function Network:HandlePlayerInfo(PlayerInfo)
    local PlayerInfo = Utils:Split(PlayerInfo, "|")
    local SharedPlayers = {}
    local TickCount = globals.TickCount()

    for i = 1, #PlayerInfo do
        local Player = Network:UnstringifyPlayer(PlayerInfo[i])
        local NetworkedPlayer = Network.SharedPlayers[Player.Index]
        Network.PlayerLastUpdate[Player.Index] = TickCount
        
        if NetworkedPlayer then
            Player.OriginX = (NetworkedPlayer.OriginX + Player.OriginX) / 2
            Player.OriginY = (NetworkedPlayer.OriginY + Player.OriginY) / 2
            Player.OriginZ = (NetworkedPlayer.OriginZ + Player.OriginZ) / 2
        end

        SharedPlayers[Player.Index] = Player
    end

    for PlayerIndex, Player in pairs(Network.SharedPlayers) do
        if not SharedPlayers[PlayerIndex] then
            SharedPlayers[PlayerIndex] = Player
        end
    end

    for PlayerIndex, Player in pairs(SharedPlayers) do
        if not ESP.LocalPlayers[PlayerIndex] then
            ESP.LocalPlayers[PlayerIndex] = Vector3(Player.OriginX, Player.OriginY, Player.OriginX)
        end
    end

    Network.SharedPlayers = SharedPlayers
end

function Network:HandlePacket(Packet)
    local PacketType = tonumber(string.sub(Packet, 1, 1))
    Packet = string.sub(Packet, 2)
    if PacketType == Network.PacketType.PLAYERINFO then
        Network:HandlePlayerInfo(Packet)
    elseif PacketType == Network.PacketType.REQUESTSERVERINFO then
        Network:SendServerIP(engine.GetServerIP())
    end
end

function Network:ReceivePackets()
    local Packet = Network.Socket:RecvFrom("0.0.0.0", Network.ServerPort, Network.PacketSize)
    while Packet do
        Network:HandlePacket(Packet)
        Packet = Network.Socket:RecvFrom("0.0.0.0", Network.ServerPort, Network.PacketSize)
    end
end


local function main()
    Network.Socket:Bind("0.0.0.0", Network.ClientPort)

    local VisualsMaster = gui.Reference("Visuals", "Master Switch")
    local TickRateMultiplier = globals.TickInterval() == 1 / 64 and 1 or 2
    local LastTick = globals.TickCount()

    http.Get("https://raw.githubusercontent.com/stqcky/SharedESP/main/ServerList.lua", function(Result)
        Network.ServerList = loadstring(Result)()
        local ServerNames = {}

        for i = 1, #Network.ServerList do
            ServerNames[#ServerNames + 1] = Network.ServerList[i].Name
        end
        GUI.General.Server:SetOptions(unpack(ServerNames))
    end)

    callbacks.Register( "Draw", function()
        local CurTick = globals.TickCount()
        if CurTick == LastTick then return end
        LastTick = CurTick
        
        if CurTick % 16 * TickRateMultiplier == 0 then
            ESP:UpdateSettings()
        end

        if CurTick % 128 * TickRateMultiplier == 0 then
            local ServerIP = engine.GetServerIP()
            if Network.ServerIP ~= ServerIP then
                Network.ServerIP = ServerIP
                Network:SendServerIP(ServerIP)
            end

            local CurServer = Network.ServerList[GUI.General.Server:GetValue() + 1]
            if CurServer then
                Network.ServerAddress = CurServer.Address
            end
        end

        if CurTick % 960 * TickRateMultiplier == 0 then
            Network:SendHeartbeat()
        end

        if CurTick % 96 * TickRateMultiplier == 0 then
            for PlayerIndex, Player in pairs(Network.SharedPlayers) do
                if Network.PlayerLastUpdate[Player.Index] + 96 * TickRateMultiplier < globals.TickCount() then
                    Network.SharedPlayers[Player.Index] = nil
                end
            end
        end

        Network:SendPlayerStrings()
        Network:ReceivePackets()
    end )

    callbacks.Register( "Draw", function()
        if not VisualsMaster:GetValue() or not GUI.General.Enable:GetValue() then return end

        draw.SetFont(ESP.Font)
        ESP:Interpolate()

        for PlayerIndex, PlayerPosition in pairs(ESP.LocalPlayers) do
            if PlayerIndex ~= client.GetLocalPlayerIndex() and (not GUI.General.OnlyDormant:GetValue() or entities.GetByIndex(PlayerIndex):IsDormant()) then
                ESP:DrawESP(PlayerIndex)
            end
        end
    end )

    callbacks.Register( "Unload", function()
        Network.Socket:Close()
    end )
end

main()