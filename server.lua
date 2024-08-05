local callSigns = {}
QBCore = exports['qb-core']:GetCoreObject()

function findIndexForUnits(x)
    for index, unitsValue in pairs(callSigns) do
        if unitsValue == x then
            return index
        end
    end
    return nil  -- Return nil if not found
end

RegisterServerEvent("CheckAndUpdateTable")
AddEventHandler("CheckAndUpdateTable",function()
    local player = QBCore.Functions.GetPlayer(source)
    if player then
        if player.job.type == "leo" then
            local query = "SELECT unit FROM cad_callsigns WHERE identifier = @identifier"
            local params = {["@identifier"] = source}
            local units = MySQL.Async.fetchScalar(query, params, function(unit) end)
            callSigns[source] = units
            local query = "INSERT INTO cad_units (Unit, Status, Job) VALUES (@unit, @status, @Job)"
            local params = {
            ["@unit"] = units, 
            ["@status"] = Available,
            ["@Job"] = player.job.name
            }
            MySQL.Async.execute(query, params, function(rowsChanged) end)
        end
    end
end)

RegisterServerEvent("RunUQuery")
AddEventHandler("RunUQuery",function(data)
    local resul = json.encode(data)
    local result = json.decode(resul)
    local query = "Update cad_units SET Status = @s Where Unit = @c"
    local params = {
        ["@s"] = result.data,
        -- ["@c"] = callSigns[source]
        ["@c"] = "011"
    }
    MySQL.Async.execute(query, params, function(rowsChanged) end)
    TriggerClientEvent("RefreshUI",-1)
end)
RegisterServerEvent("RunAQuery")
AddEventHandler("RunAQuery",function(data)
    local result = json.decode(data)
    local query = "UPDATE cad_units SET Event = @e, Status @s"
end)
RegisterCommand("cad", function(source, args, rawCommand)
    local playerId = source
    TriggerClientEvent("openCadUI", playerId)
end, false)

RegisterCommand("911", function(source, args, rawCommand)
    local playerId = source
    TriggerClientEvent("GetPlayerData", playerId, args)
end, false)

RegisterServerEvent("CreateEvent")
AddEventHandler("CreateEvent", function(data)
    local source = player
    local result = json.encode(data)
    print(result)
    local query = "INSERT INTO cad_events (Event, Status, Pri, Call_Type, Location, TimeOfCall) VALUES (@e, @s, @p, @c, @l, @t)"
    local params = {
    ["@e"] = result["event"], 
    ["@s"] = result["Status"],
    ["@p"] = result["Priority"],
    ["@c"] = result["call_type"],
    ["@l"] = json.encode(result["Location"]), 
    -- ["@t"] = (result.Time.hour .. ":" .. result.Time.hour) or "N/A", 
}

MySQL.Async.execute(query, params, function(rowsChanged) end)

end)

RegisterServerEvent("AcceptEvent")
AddEventHandler("AcceptEvent", function(data)
    local x = callSigns[source] 
    local result = json.decode(data)
    
    local query = "UPDATE cad_units SET STATUS = 'Active', `Comment` = @c, `Event` = @e, `Location` = @l WHERE `Unit` = @unit"
    local params = {
        ["@c"] = result.Comment,
        ["@e"] = result.EventID,
        ["@l"] = result.Location,
        ["@unit"] = x
    }

    local query2 = "UPDATE cad_events SET STATUS = 'Active' WHERE `EVENT` = @e"
    local param = {
        ["@e"] = result.EventID
    }

    MySQL.Async.execute(query2, param, function(rowsChanged) end)
    MySQL.Async.execute(query, params, function(rowsChanged) end)
end)

RegisterServerEvent("EventResolved")
AddEventHandler("EventResolved", function(EventID)
    local x = callSigns(source)
    local query = "DELETE FROM cad_events WHERE Event = @e"
    local param = {["@e"] = EventID}
    local query2 = "UPDATE cad_units SET STATUS = 'Available', Comment = @c, Event = @e, Location = @l WHERE UNIT = @unit"
    local params = {
        ["@c"] = nil,
        ["@e"] = nil,
        ["@l"] = nil,
        ["@unit"] = x
    }
    MySQL.Async.execute(query, param, function(rowsChanged) end)
    MySQL.Async.execute(query2, params, function(rowsChanged) end)
end)

RegisterServerEvent("CleanTable")
AddEventHandler("CleanTable",function()
    local query = "DELETE FROM cad_units WHERE Unit = @unit"
    local params = {["@unit"] = callSigns[source]}
    callSigns[source] = nil
    MySQL.Async.execute(query, params, function(rowsChanged) end)
end)

RegisterServerEvent("fetchData")
AddEventHandler("fetchData",function()
    local x = source
    -- local player = QBCore.Functions.GetPlayer(x)
    local player = 'police'
    local result = json.encode(MySQL.Sync.fetchAll("select Unit, Status,Event, Location, Comment from cad_units where Job = @jobs", {["@jobs"] = player}))
    local params = {["jobs"] = player} -- job.name
    TriggerClientEvent("sendData",x,result)
end)

RegisterServerEvent("fetchEvent")
AddEventHandler("fetchEvent",function()
    local x = source
    local result = json.encode(MySQL.Sync.fetchAll("select * from cad_events"))
    TriggerClientEvent("sendEvent",x,result)
end)

RegisterServerEvent("cad_Login")
AddEventHandler("cad_Login",function(input)
    local player = source
    local file = LoadResourceFile(GetCurrentResourceName(), "./users.json")
    local users = json.decode(file)
    local username = nil
    local password = nil

    for key, value in pairs(input) do
        username = key
        password = value
    end

    if not username or not password then
        TriggerClientEvent("UpdateLoginStatus", player, "login_failure")
        return
    end
    print(users)
    print(username)
    print(password)
    if users[username] and users[username].password == password then
        print("Success")
        TriggerClientEvent("UpdateLoginStatus", player, "login_success")
    else
        print("Failure")
        TriggerClientEvent("UpdateLoginStatus", player,"login_failure")
    end
end)

RegisterServerEvent("Update_Callsign")
AddEventHandler("Update_Callsign", function(data)
    local player = source
    local query = "INSERT INTO CAD UNITS (id,callsign) VALUES(@i,@c)"
    local params = {
        ["@i"] = source,
        ["@c"] = data
    }
    MySQL.Async.execute(query, params, function(rowsChanged) end)
    callSigns[source] = data
end)
RegisterServerEvent("cad_Register")
AddEventHandler("cad_Register",function(data)
    local player = source
    local file = LoadResourceFile(GetCurrentResourceName(), "./users.json")
    local users = json.decode(file) or {}
    local input = data
    print(users)
    print(input)
    local username = nil
    local password = nil
    local mess1 = "registration_failure"
    local mess2 = "registration_success"
    for key, value in pairs(input) do
        username = key
        password = value
    end
    print(username)
    print(password)
    if not username or not password then
        TriggerClientEvent("UpdateLoginStatus", player, mess1)
        return
    end

    if users[username] then
        TriggerClientEvent("UpdateLoginStatus", player,mess1)
    else
        users[username] = { password = password }
        print(users)
        SaveResourceFile(GetCurrentResourceName(), "users.json", json.encode(users), -1)
        TriggerClientEvent("UpdateLoginStatus", player, mess2)
    end
end)

RegisterServerEvent('pull_messages')
AddEventHandler('pull_messages',function()
    local player = source
    local query = "SELECT * from cad_messages WHERE receiver = @c"
    -- local params = {["@c"] = callSigns[tonumber(player)]}
    local params = {["@c"] = 011}
    local result = json.encode(MySQL.Sync.fetchAll(query, params))
    TriggerClientEvent('update_messages', player, result)
end)

RegisterServerEvent('Update_messages')
AddEventHandler('Update_messages', function(data)
    local result = data
    print(json.encode(data))
    local query = "INSERT INTO cad_messages (sender, receiver, content, flag) VALUES (@s, @t, @c, @f)"
    local params = {
        ['@s'] = result.sender,
        ['@t'] = result.receiver,
        ['@c'] = result.content,
        ['@f'] = result.flag
    }
    MySQL.Async.execute(query, params, function(rowsChanged) end)
    local updated = json.encode(MySQL.Sync.fetchAll(query, params))
    -- receiver = findIndexForUnits(result.receiver)
    -- TriggerClientEvent('update_messages', receiver, updated)
end)