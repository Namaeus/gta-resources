ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj)
            ESX = obj
        end)
        Citizen.Wait(0)
    end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end

    ESX.PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)

local isShowing = false

RegisterCommand('mdt', function()
    if Config.cmd then
    if not isShowing then
        ESX.TriggerServerCallback('disc-mdt:getUser', function(user)
            SendNUIMessage({
                type = 'SET_USER',
                data = {
                    user = user
                }
            })
        end)
    end

        SendNUIMessage({
            type = "APP_SHOW"
        })
        SetNuiFocus(true, true)
        isShowing = true
    else
        SendNUIMessage({
            type = "APP_HIDE"
        })
        SetNuiFocus(false, false)
        isShowing = false
    end
end)

function enableTablet(enable)
    SetNuiFocus(true, true)
    isShowing = true
    SendNUIMessage({
            type = "APP_SHOW"
        })
end

RegisterNetEvent("disc-mdt:openTablet")
AddEventHandler("disc-mdt:openTablet", function()
enableTablet(true)
end)

RegisterNUICallback('escape', function(data, cb)
    enableTablet(false)
    SetNuiFocus(false, false)
    cb('ok')
end)

local tabletObjNetID = 0
function tabletAnim()
    Citizen.CreateThread(function()
        if tabEnabled == false then
            
            ClearPedSecondaryTask(PlayerPedId())
            DetachEntity(NetToObj(tabletObjNetID), 1, 1)
            DeleteEntity(NetToObj(tabletObjNetID))
            tabletObjNetID = nil
            currentAction = "none"
            return
        end
       
        RequestModel(GetHashKey("prop_cs_tablet"))
        while not HasModelLoaded(GetHashKey("prop_cs_tablet")) do
            Citizen.Wait(100)
        end
 
        RequestAnimDict("amb@world_human_seat_wall_tablet@female@base")
        while not HasAnimDictLoaded("amb@world_human_seat_wall_tablet@female@base") do
            Citizen.Wait(100)
        end
 
        local plyCoords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 0.0, -5.0)
        local objSpawned = CreateObject(GetHashKey("prop_cs_tablet"), plyCoords.x, plyCoords.y, plyCoords.z, 1, 1, 1)
        Citizen.Wait(1000)
        local netid = ObjToNet(objSpawned)
        AttachEntityToEntity(objSpawned, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 28422), boneCoords.xoff, boneCoords.yoff, boneCoords.zoff, boneCoords.xrot, boneCoords.yrot, boneCoords.zrot, 1, 1, 0, 1, 0, 1)
        TaskPlayAnim(PlayerPedId(), 1.0, -1, -1, 50, 0, 0, 0, 0) -- 50 = 32 + 16 + 2
        TaskPlayAnim(PlayerPedId(), "amb@world_human_seat_wall_tablet@female@base", "base", 1.0, -1, -1, 50, 0, 0, 0, 0)
        tabletObjNetID = netid
    end)
end

RegisterNUICallback("CloseUI", function(data, cb)
    isShowing = false
    SetNuiFocus(false, false)
end)

RegisterNUICallback('SetDarkMode', function(data, cb)
    TriggerServerEvent('disc-mdt:setDarkMode', data)
    cb('OK')
end)

RegisterNUICallback('GetLocation', function(data, cb)
    local player = PlayerPedId()
    local x, y, z = table.unpack(GetEntityCoords(player))
    local coords = { x = x, y = y, z = z }
    local var1, var2 = GetStreetNameAtCoord(x, y, z, Citizen.ResultAsInteger(), Citizen.ResultAsInteger())
    street1 = GetStreetNameFromHashKey(var1)
    street2 = GetStreetNameFromHashKey(var2)
    streetName = street1
    if street2 ~= nil and street2 ~= '' then
        streetName = streetName .. ' + ' .. street2
    end
    area = GetLabelText(GetNameOfZone(x, y, z))
    SendNUIMessage({
        type = 'SET_LOCATION',
        data = {
            location = {
                street = streetName,
                area = area,
                coords = coords
            }
        }
    })
    cb('OK')
end)

RegisterNetEvent('disc-mdt:addNotification')
AddEventHandler('disc-mdt:addNotification', function(data)
    SendNUIMessage({
        type = 'ADD_NOTIFICATION',
        data = data
    })
end)
