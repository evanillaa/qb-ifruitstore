-- Variables

local QBCore = exports['qb-core']:GetCoreObject()
local CurrentCops = 0
local copsCalled = false
local requiredItemsShowed = false
local requiredItemsShowed2 = false
local requiredItems = {}
local currentSpot = 0
local usingSafe = false

-- Functions

function lockpickDone(success)
    local pos = GetEntityCoords(PlayerPedId())
    if math.random(1, 100) <= 80 and not QBCore.Functions.IsWearingGloves() then
        TriggerServerEvent("evidence:server:CreateFingerDrop", pos)
    end
    if success then
        GrabItem(currentSpot)
    else
        if math.random(1, 100) <= 40 and QBCore.Functions.IsWearingGloves() then
            TriggerServerEvent("evidence:server:CreateFingerDrop", pos)
            QBCore.Functions.Notify(Lang:t('info.glove_ripped'))
        end
        if math.random(1, 100) <= 10 then
            -- TODO: make server side event to remove item
            TriggerServerEvent("QBCore:Server:RemoveItem", "advancedlockpick", 1)
            TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items["advancedlockpick"], "remove")
        end
    end
end

function GrabItem(spot)
    if requiredItemsShowed2 then
        requiredItemsShowed2 = false
        TriggerEvent('inventory:client:requiredItems', requiredItems, false)
    end
    QBCore.Functions.Progressbar("grab_ifruititem", Lang:t('info.grab_item'), 10000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "anim@gangops@facility@servers@",
        anim = "hotwire",
        flags = 16,
    }, {}, {}, function() -- Done
        if not copsCalled then
            TriggerServerEvent('police:server:policeAlert', Lang:t('info.robbery_attempt'))
            copsCalled = true
        end

        StopAnimTask(PlayerPedId(), "anim@gangops@facility@servers@", "hotwire", 1.0)
        TriggerServerEvent('qb-ifruitstore:server:setSpotState', "isDone", true, spot)
        TriggerServerEvent('qb-ifruitstore:server:setSpotState', "isBusy", false, spot)
        TriggerServerEvent('qb-ifruitstore:server:itemReward', spot)
        TriggerServerEvent('police:server:policeAlert', Lang:t('info.robbery_attempt2'))
    end, function() -- Cancel
        StopAnimTask(PlayerPedId(), "anim@gangops@facility@servers@", "hotwire", 1.0)
        TriggerServerEvent('qb-ifruitstore:server:setSpotState', "isBusy", false, spot)
        QBCore.Functions.Notify(Lang:t('error.canceled'), "error")
    end)
end

function DrawText3Ds(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

function takeAnim()
    local ped = PlayerPedId()
    while (not HasAnimDictLoaded("amb@prop_human_bum_bin@idle_b")) do
        RequestAnimDict("amb@prop_human_bum_bin@idle_b")
        Wait(100)
    end
    TaskPlayAnim(ped, "amb@prop_human_bum_bin@idle_b", "idle_d", 8.0, 8.0, -1, 50, 0, false, false, false)
    Wait(2500)
    TaskPlayAnim(ped, "amb@prop_human_bum_bin@idle_b", "exit", 8.0, 8.0, -1, 50, 0, false, false, false)
end

function CreateFire(coords, time)
    for i = 1, math.random(1, 7), 1 do
        TriggerServerEvent("thermite:StartServerFire", coords, 24, false)
    end
    Wait(time)
    TriggerServerEvent("thermite:StopFires")
end

-- NUI

RegisterNUICallback('thermiteclick', function()
    PlaySound(-1, "CLICK_BACK", "WEB_NAVIGATION_SOUNDS_PHONE", 0, 0, 1)
end)

RegisterNUICallback('thermitefailed', function()
    PlaySound(-1, "Place_Prop_Fail", "DLC_Dmod_Prop_Editor_Sounds", 0, 0, 1)
    TriggerServerEvent("qb-ifruitstore:server:SetThermiteStatus", "isBusy", false)
    -- TODO: make server side event to remove item
    TriggerServerEvent("QBCore:Server:RemoveItem", "thermite", 1)
    TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items["thermite"], "remove")
    local coords = GetEntityCoords(PlayerPedId())
    local randTime = math.random(10000, 15000)
    CreateFire(coords, randTime)

    TriggerServerEvent('police:server:policeAlert', Lang:t('info.robbery_attempt2'))
end)

RegisterNUICallback('thermitesuccess', function()
    QBCore.Functions.Notify("The fuses are broken", "success")
    -- TODO: make server side event to remove item
    TriggerServerEvent("QBCore:Server:RemoveItem", "thermite", 1)
    local pos = GetEntityCoords(PlayerPedId())
    if #(pos - vector3(Config.Locations["thermite"].x, Config.Locations["thermite"].y,Config.Locations["thermite"].z)) < 1.0 then
        TriggerServerEvent("qb-ifruitstore:server:SetThermiteStatus", "isDone", true)
        TriggerServerEvent("qb-ifruitstore:server:SetThermiteStatus", "isBusy", false)
    end
end)

RegisterNUICallback('closethermite', function()
    SetNuiFocus(false, false)
end)

-- Events

RegisterNetEvent('SafeCracker:EndMinigame', function(won)
    if usingSafe then
        if won then
            if not Config.Locations["safe"].isDone then
                SetNuiFocus(false, false)
                TriggerServerEvent("qb-ifruitstore:server:SafeReward")
                TriggerServerEvent("qb-ifruitstore:server:SetSafeStatus", "isBusy", false)
                TriggerServerEvent("qb-ifruitstore:server:SetSafeStatus", "isDone", false)
                takeAnim()
            end
        end
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    TriggerServerEvent("qb-ifruitstore:server:LoadLocationList")
end)

RegisterNetEvent('police:SetCopCount', function(amount)
    CurrentCops = amount
end)

RegisterNetEvent('qb-ifruitstore:client:LoadList', function(list)
    Config.Locations = list
end)

RegisterNetEvent('thermite:UseThermite', function()
    local pos = GetEntityCoords(PlayerPedId())
    if #(pos - vector3(Config.Locations["thermite"].x, Config.Locations["thermite"].y,Config.Locations["thermite"].z)) < 1.0 then
        if CurrentCops >= Config.MinimumThermitePolice then
            local pos = GetEntityCoords(PlayerPedId())
            if math.random(1, 100) <= 80 and not QBCore.Functions.IsWearingGloves() then
                TriggerServerEvent("evidence:server:CreateFingerDrop", pos)
            end
            if requiredItemsShowed then
                requiredItems = {
                    [1] = {name = QBCore.Shared.Items["thermite"]["name"], image = QBCore.Shared.Items["thermite"]["image"]},
                }
                requiredItemsShowed = false
                TriggerEvent('inventory:client:requiredItems', requiredItems, false)
                TriggerServerEvent("qb-ifruitstore:server:SetThermiteStatus", "isBusy", true)
                SetNuiFocus(true, true)
                SendNUIMessage({
                    action = "openThermite",
                    amount = math.random(5, 6),
                })
            end
        else
            QBCore.Functions.Notify(Lang:t('error.minimum_police', {value = Config.MinimumThermitePolice}), "error")
        end
    end
end)

RegisterNetEvent('qb-ifruitstore:client:setSpotState', function(stateType, state, spot)
    if stateType == "isBusy" then
        Config.Locations["takeables"][spot].isBusy = state
    elseif stateType == "isDone" then
        Config.Locations["takeables"][spot].isDone = state
    end
end)

RegisterNetEvent('qb-ifruitstore:client:SetSafeStatus', function(stateType, state)
    if stateType == "isBusy" then
        Config.Locations["safe"].isBusy = state
    elseif stateType == "isDone" then
        Config.Locations["safe"].isDone = state
    end
end)

RegisterNetEvent('qb-ifruitstore:client:SetThermiteStatus', function(stateType, state)
    if stateType == "isBusy" then
        Config.Locations["thermite"].isBusy = state
    elseif stateType == "isDone" then
        Config.Locations["thermite"].isDone = state
    end
end)

-- Thread

CreateThread(function()
    while true do
        Wait(1000 * 45 * 5)
        if copsCalled then
            copsCalled = false
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(1)
        local inRange = false
        if LocalPlayer.state.isLoggedIn then
            local pos = GetEntityCoords(PlayerPedId())
            if #(pos - vector3(Config.Locations["thermite"].x, Config.Locations["thermite"].y,Config.Locations["thermite"].z)) < 10.0 then
                inRange = true
                if #(pos - vector3(Config.Locations["thermite"].x, Config.Locations["thermite"].y,Config.Locations["thermite"].z)) < 3.0 and not Config.Locations["thermite"].isDone then
                    DrawMarker(2, Config.Locations["thermite"].x, Config.Locations["thermite"].y,Config.Locations["thermite"].z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.25, 0.25, 0.1, 255, 255, 255, 100, 0, 0, 0, 1, 0, 0, 0)
                    if #(pos - vector3(Config.Locations["thermite"].x, Config.Locations["thermite"].y,Config.Locations["thermite"].z)) < 1.0 then
                        if not Config.Locations["thermite"].isDone then
                            if not requiredItemsShowed then
                                requiredItems = {
                                    [1] = {name = QBCore.Shared.Items["thermite"]["name"], image = QBCore.Shared.Items["thermite"]["image"]},
                                }
                                requiredItemsShowed = true
                                TriggerEvent('inventory:client:requiredItems', requiredItems, true)
                            end
                        end
                    end
                else
                    if requiredItemsShowed then
                        requiredItems = {
                            [1] = {name = QBCore.Shared.Items["thermite"]["name"], image = QBCore.Shared.Items["thermite"]["image"]},
                        }
                        requiredItemsShowed = false
                        TriggerEvent('inventory:client:requiredItems', requiredItems, false)
                    end
                end
            elseif not inRange then
                Wait(3000)
            end
        else
            Wait(3000)
        end
    end
end)

CreateThread(function()
    local inRange = false
    while true do
        Wait(1)
        if LocalPlayer.state.isLoggedIn then
            local pos = GetEntityCoords(PlayerPedId())
            for spot, location in pairs(Config.Locations["takeables"]) do
                local dist = #(pos - vector3(Config.Locations["takeables"][spot].x, Config.Locations["takeables"][spot].y,Config.Locations["takeables"][spot].z))
                if dist < 1.0 then
                    inRange = true
                    if dist < 0.6 then
                        if not requiredItemsShowed2 then
                            requiredItems = {
                                [1] = {name = QBCore.Shared.Items["advancedlockpick"]["name"], image = QBCore.Shared.Items["advancedlockpick"]["image"]},
                            }
                            requiredItemsShowed2 = true
                            TriggerEvent('inventory:client:requiredItems', requiredItems, true)
                        end
                        if not Config.Locations["takeables"][spot].isBusy and not Config.Locations["takeables"][spot].isDone then
                            DrawText3Ds(Config.Locations["takeables"][spot].x, Config.Locations["takeables"][spot].y,Config.Locations["takeables"][spot].z, Lang:t('general.grab_item'))
                            if IsControlJustPressed(0, 38) then
                                if CurrentCops >= Config.MinimumiFruitPolice then
                                    if Config.Locations["thermite"].isDone then
                                        QBCore.Functions.TriggerCallback('QBCore:HasItem', function(hasItem)
                                            if hasItem then
                                                currentSpot = spot
                                                GrabItem(currentSpot)
                                            else
                                                QBCore.Functions.Notify(Lang:t('error.missing_lockpick'), "error")
                                            end
                                        end, "advancedlockpick")
                                    else
                                        QBCore.Functions.Notify(Lang:t('error.active_security'), "error")
                                    end
                                else
                                    QBCore.Functions.Notify(Lang:t('error.minimum_police', {value = Config.MinimumiFruitPolice}), "error")
                                end
                            end
                        end
                    else
                        if requiredItemsShowed2 then
                            requiredItems = {
                                [1] = {name = QBCore.Shared.Items["advancedlockpick"]["name"], image = QBCore.Shared.Items["advancedlockpick"]["image"]},
                            }
                            requiredItemsShowed2 = false
                            TriggerEvent('inventory:client:requiredItems', requiredItems, false)
                        end
                    end
                end
            end

            if not inRange then
                if requiredItemsShowed2 then
                    requiredItems = {
                        [1] = {name = QBCore.Shared.Items["advancedlockpick"]["name"], image = QBCore.Shared.Items["advancedlockpick"]["image"]},
                    }
                    requiredItemsShowed2 = false
                    TriggerEvent('inventory:client:requiredItems', requiredItems, false)
                end
                Wait(2000)
            end
        end
    end
end)
