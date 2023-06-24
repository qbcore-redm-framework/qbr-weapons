Config.WeaponRepairPoints = GlobalState.WeaponRepairPoints or Config.WeaponRepairPoints
local sharedWeapons = exports['qbr-core']:GetWeapons()
local sharedItems = exports['qbr-core']:GetItems()
local curWeapData

----------------------------------------------------------------------------
---- FUNCTIONS
----------------------------------------------------------------------------

local function ShootingThread(hash, ped, ammo)
    CreateThread(function()
        local ammo = ammo
        while curWeapData do
            local currentammo = GetAmmoInPedWeapon(ped, hash)
            if currentammo ~= ammo then
                local diff = ammo - currentammo
                ammo = currentammo
                local DecreaseAmount = Config.DurabilityMultiplier[hash] * diff
                TriggerServerEvent('qbr-weapons:server:UpdateWeaponData', curWeapData.slot, ammo, DecreaseAmount > 0 and DecreaseAmount)
            end
            Wait(500)
        end
    end)
end

local function GetRepairCallBack(data)
    exports['qbr-core']:TriggerCallback('qbr-weapons:server:RepairWeapon', function(CanRepair)
        if CanRepair then
            curWeapData = nil
        end
    end, data)
end

local function OpenMenu(index)
    local data = Config.WeaponRepairPoints[index]
    local RepairMenu = {}
    if data.IsRepairing and data.IsRepairing.Ready then
        RepairMenu[#RepairMenu+1] = {
            header = "Pickup Repaired Weapon",
            txt = "Description: "..sharedItems[data.IsRepairing.WeaponData.name]['label'],
            params = {
                isServer = true,
                event = "qbr-weapons:server:TakeBackWeapon",
                args = {index = index}
            }
        }
    elseif not data.IsRepairing and curWeapData and next(curWeapData) then
        local WeaponData = sharedWeapons[joaat(curWeapData.name)]
        local WeaponClass = (exports['qbr-core']:SplitStr(WeaponData.ammotype, "_")[2]):lower()
        RepairMenu[#RepairMenu+1] = {
            header = "Repair Weapon",
            txt = "Weapon: "..sharedItems[curWeapData.name]['label'].." Price: "..Config.WeaponRepairCosts[WeaponClass],
            params = {
                isAction = true,
                event = GetRepairCallBack,
                args = {index = index, slot = curWeapData.slot}
            }
        }
    else
        exports['qbr-core']:Notify(9, Lang:t('error.no_weapon_in_hand'), 5000, 0, 'mp_lobby_textures', 'cross', 'COLOR_WHITE')
    end
    exports['qbr-menu']:openMenu(RepairMenu)
end

----------------------------------------------------------------------------
---- EVENTS & HANDLERS
----------------------------------------------------------------------------

AddStateBagChangeHandler('WeaponRepairPoints', 'global', function(_, _, value)
    Config.WeaponRepairPoints = value
end)

RegisterNetEvent('qbr-weapons:client:CheckWeapon', function(weaponName)
    if not curWeapData or curWeapData.name ~= weaponName then return end
    local ped = PlayerPedId()
    RemoveWeaponFromPed(ped, joaat(curWeapData.name))
    SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
    SetCurrentPedWeapon(ped, true)
    curWeapData = nil
end)

RegisterNetEvent('qbr-weapons:client:UseWeapon', function(weaponData)
    local ped = PlayerPedId()
    local hash = joaat(weaponData.name)
    local weaponName = tostring(weaponData.name)
    if curWeapData and curWeapData.info.serie == weaponData.info.serie then
        RemoveWeaponFromPed(ped, hash)
        curWeapData = nil
    elseif curWeapData and curWeapData.info.serie ~= weaponData.info.serie then
        local curHash = joaat(curWeapData.name)
        RemoveWeaponFromPed(ped, curHash)
        curWeapData = nil
        Wait(500)
        Citizen.InvokeNative(0xB282DC6EBD803C75, ped, hash, 0, false, true) --GiveDelayedWeaponToPed
        SetCurrentPedWeapon(ped, hash, true)
        SetPedAmmo(ped, hash, weaponData.info.ammo or 0)
        curWeapData = weaponData
        if string.find(weaponName, 'lasso') then return end
        ShootingThread(hash, ped, weaponData.info.ammo or 0)
    elseif not curWeapData then
        Citizen.InvokeNative(0xB282DC6EBD803C75, ped, hash, 0, false, true)  --GiveDelayedWeaponToPed
        SetCurrentPedWeapon(ped, hash, true)
        SetPedAmmo(ped, hash, weaponData.info.ammo or 0)
        curWeapData = weaponData
        if string.find(weaponName, 'lasso') then return end
        ShootingThread(hash, ped, weaponData.info.ammo or 0)
    end
end)

RegisterNetEvent('qbr-weapons:client:AddAmmo', function(type, amount, itemData)
    if curWeapData then
        local weapon = joaat(curWeapData.name)
        local data = sharedWeapons[weapon]
        if data["name"] ~= "weapon_unarmed" and data["ammotype"] == type:upper() then
            local ped = PlayerPedId()
            local total = GetAmmoInPedWeapon(ped, weapon)
            if total + (amount/2) < Config.MaxAmmo[GetWeapontypeGroup(weapon)] then
                exports['qbr-core']:Progressbar("taking_bullets", Lang:t('info.loading_bullets'), math.random(4000, 6000), false, true, {
                    disableCombat = true,
                }, {}, {}, {}, function() -- Done
                    if sharedWeapons[weapon] then
                        SetPedAmmo(ped, weapon, total + amount)
                        TaskReloadWeapon(ped)
                        TriggerServerEvent("qbr-weapons:server:UpdateWeaponData", curWeapData.slot, total + amount)
                        TriggerServerEvent('QBCore:Server:RemoveItem', itemData.name, 1, itemData.slot)
                        TriggerEvent('inventory:client:ItemBox', sharedItems[itemData.name], "remove")
                        TriggerEvent('QBCore:Notify', Lang:t('success.reloaded'), 5000, 0, 'hud_textures', 'check', 'COLOR_WHITE')
                    end
                end, function()
                    exports['qbr-core']:Notify(9, Lang:t('error.canceled'), 5000, 0, 'mp_lobby_textures', 'cross', 'COLOR_WHITE')
                end)
            else
                exports['qbr-core']:Notify(9, Lang:t('error.max_ammo'), 5000, 0, 'mp_lobby_textures', 'cross', 'COLOR_WHITE')
            end
        else
            exports['qbr-core']:Notify(9, Lang:t('error.no_weapon'), 5000, 0, 'mp_lobby_textures', 'cross', 'COLOR_WHITE')
        end
    else
        exports['qbr-core']:Notify(9, Lang:t('error.no_weapon'), 5000, 0, 'mp_lobby_textures', 'cross', 'COLOR_WHITE')
    end
end)

----------------------------------------------------------------------------
---- THREADS
----------------------------------------------------------------------------

CreateThread(function()
    for k, v in pairs(Config.WeaponRepairPoints) do
        exports['qbr-core']:createPrompt("weapons:repair"..k, v.coords, 0xCEFD9220, Lang:t('info.repair_button'), {
            type = 'callback',
            event = OpenMenu,
            args = {k},
        })
    end
end)