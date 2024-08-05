local uiopen = false
local isNuiFocusEnabled = false
-- Config = require("config")
local event_coords = {}
QBCore = exports['qb-core']:GetCoreObject()

-----------------------------------------------------------------FUNCTIONS-------------------------------------------------------------------------
function CategorizeInto10Code(args)
    local lowerArgs = string.lower(json.encode(args))    
    local codeMapping = Config.CodeMapping

    for keyword, code in pairs(codeMapping) do
        if string.find(lowerArgs, keyword) then
            return code
        end
    end

    return "10-99"  
end

function CalculatePriority(code)
    local priorityMapping = Config.PriorityMapping
    local defaultPriority = 4 
    return priorityMapping[code] or defaultPriority
end

function GenerateRandomEventID()
    math.randomseed(GetClockMinutes()) 
    local randomPart = math.random(1000000, 9999999) 
    local timestampPart = GetClockMinutes()

    local eventID = tostring(timestampPart) .. tostring(randomPart)
    return eventID
end

function GetPlayerLocation(player)
    local coords = GetEntityCoords(GetPlayerPed(player))
    return {
        x = coords.x,
        y = coords.y,
        z = coords.z
    }
end

function GetInGameTime()
    local hour = GetClockHours()
    local minute = GetClockMinutes()

    return {
        hour = hour,
        minute = minute
    }
end
------------------------------------------------------------DEFAULT HANDLERS-----------------------------------------------------------------------
AddEventHandler("playerSpawned",function() 
    TriggerServerEvent("CheckAndUpdateTable")
end)
AddEventHandler("playerDropped",function()
    TriggerServerEvent("CleanTable")
end)
---------------------------------------------------------------NUICALLBACK---------------------------------------------------------------------

RegisterNUICallback('cad_AVL', function(data, cb)
    TriggerServerEvent("RunUQuery",data)
    cb('ok')
end)
RegisterNUICallback('cad_enr', function(data, cb)
    TriggerServerEvent("RunUQuery",data)
    cb('ok')
end)
RegisterNUICallback('cad_ARV', function(data, cb)
    TriggerServerEvent("RunUQuery",data)
    cb('ok')
end)
RegisterNUICallback('cad_OOS', function(data, cb)
    TriggerServerEvent("RunUQuery",data)
    cb('ok')
end)
RegisterNUICallback('cad_Busy', function(data, cb)
    TriggerServerEvent("RunUQuery",data)
    cb('ok')
end)
RegisterNUICallback('cad_CLR', function(data, cb)
    TriggerServerEvent("RunUQuery",data)
    cb('ok')
end)
RegisterNUICallback('cad_Register', function(data,cb)
    TriggerServerEvent("cad_Register",data)
end)
RegisterNUICallback('cad_Login', function(data,cb)
    print(data)
    TriggerServerEvent("cad_Login",data)
end)
RegisterNUICallback('Get_GPS_Done',function(data, cb)
    SetNewWaypoint(
        event_coords[tonumber(data)].x, 
        event_coords[tonumber(data)].y
    )
    cb('ok')
end)
RegisterNUICallback('cad_MessRecv', function(data,cb)
    TriggerServerEvent('pull_messages')
    cb('ok')
end)
RegisterNUICallback('cad_MessSend', function(data,cb)
    TriggerServerEvent('Update_messages', data)
    cb('ok')
end)
RegisterNUICallback('Help_Me',function(data, cb)
    TriggerServerEvent("RunUQuery",data)
end)
RegisterNUICallback('Register_Callsign',function(data, cb)
    console.log("CallbackReceived")
    TriggerServerEvent("Update_Callsign",data)
end)
RegisterNUICallback('Accept_Event', function(data, cb)
    print(json.encode(data))
    -- TriggerServerEvent("RunUQuery",data)
    cb('ok')
end)

------------------------------------------------Events---------------------------------------------------------------------------------------------
RegisterNetEvent("GetPlayerData")
AddEventHandler("GetPlayerData", function(args)
    local player = PlayerPedId()
    -- local playerData = QBCore.Functions.GetPlayer(player)

    
        local eventData = {
            event = GenerateRandomEventID(),
            status = "Pending",
            call_type = CategorizeInto10Code(args),
            Priority = CalculatePriority(call_type), 
            Location = GetPlayerLocation(player),
            Time = GetInGameTime()
        }
        event_coords[eventData.event] = GetEntityCoords(player)
        TriggerServerEvent("CreateEvent", eventData)
    end)

------------------------------------------------------NUIMESSAGES----------------------------------------------------------------------------------
RegisterNetEvent("openCadUI")
AddEventHandler("openCadUI", function()
    if not uiopen then
        SendNUIMessage({
            type = "showUi"
        })
        SetNuiFocus(true, true)

        TriggerServerEvent('fetchData')
        TriggerServerEvent('fetchEvent')
        uiopen = true
    end
end)

RegisterNetEvent("RefreshUI")
AddEventHandler("RefreshUI", function(args)
    TriggerServerEvent('fetchData')
    TriggerServerEvent('fetchEvent')
end)
RegisterNUICallback('Nui', function(data, cb)
    SetNuiFocus(false, false)
    uiopen = false
    cb('ok')
end)
RegisterNUICallback('Nuiopen', function(data, cb)
    SetNuiFocus(true, true)
    uiopen = true
    cb('ok')
end)
RegisterNetEvent('sendData')
AddEventHandler('sendData',function(datax)
    SendNUIMessage({
        type = 'updateData',
        data = datax
   })
end)

RegisterNetEvent('sendEvent')
AddEventHandler('sendEvent',function(datax)
    SendNUIMessage({
        type = 'updateEvent',
        data = datax
   })
end)
RegisterNetEvent('update_messages')
AddEventHandler('update_messages',function(datax)
    SendNUIMessage({
        type = 'update_messages',
        data = datax
    })
end)
RegisterNetEvent('UpdateLoginStatus')
AddEventHandler('UpdateLoginStatus',function(datax)
    SendNUIMessage({
        type = datax,
   })
end)