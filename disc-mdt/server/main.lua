ESX = nil

TriggerEvent('esx:getSharedObject', function(obj)
    ESX = obj
end)

ESX.RegisterUsableItem('cadtablet', function(source)

    local xPlayer = ESX.GetPlayerFromId(source)
    TriggerClientEvent('disc-mdt:openTablet', source)
end)



RegisterServerEvent('disc-mdt:setDarkMode')
AddEventHandler('disc-mdt:setDarkMode', function(data)
    MySQL.Async.execute('UPDATE users SET darkmode=@state WHERE identifier=@identifier', {
        ['@identifier'] = data.identifier,
        ['@state'] = data.state
    })
end)

ESX.RegisterServerCallback('disc-mdt:getUser', function(source, cb)
    local player = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll('SELECT * FROM users WHERE identifier=@identifier', {
        ['@identifier'] = player.identifier
    }, function(result)
        cb(result[1])
    end)
end)
