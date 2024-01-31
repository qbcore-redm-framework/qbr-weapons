Config.WeaponRepairPoints = GlobalState.WeaponRepairPoints or Config.WeaponRepairPoints
local sharedWeapons = exports['qbr-core']:GetWeapons()
local sharedItems = exports['qbr-core']:GetItems()
local sid = GetPlayerServerId(PlayerId())
local Weapons = {}

----------------------------------------------------------------------------
---- FUNCTIONS
----------------------------------------------------------------------------

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
        local WeaponClass = WeaponData.ammotype and string.match(WeaponData.ammotype, "_(.+)"):lower()
        if not WeaponClass then return end
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

local function ResetWeapons()
    local ped = PlayerPedId()
    RemoveAllPedWeapons(ped, true, true)
    Weapons = {}
    local pistols = 1
    Wait(250)
    local slots = exports['qbr-inventory']:GetSlotData(1, 5)
    for i=1, 5 do
        local weapon = slots[i]
        if weapon and string.find(weapon.name, 'weapon') then
            if weapon.info and weapon.info ~= "" then
                local hash = joaat(weapon.name)
                weapon.info.ammo = weapon.info.ammo or 0
                Weapons[hash] = weapon
                local group = GetWeapontypeGroup(hash)
                if group == `group_revolver` or group == `group_pistol` then
                    pistols += 1
                    GiveWeaponToPed_2(ped, hash, 0, false, true, pistols)
                else
                    GiveWeaponToPed_2(ped, hash, 0, false, true)
                end
            end
        end
    end
end

----------------------------------------------------------------------------
---- EVENTS & HANDLERS
----------------------------------------------------------------------------

AddStateBagChangeHandler('WeaponRepairPoints', 'global', function(_, _, value)
    Config.WeaponRepairPoints = value
end)

AddStateBagChangeHandler('isLoggedIn', ('player:%s'):format(sid), function(_, _, value)
    if not value then return end
    local ped = PlayerPedId()
    SetPedConfigFlag(ped, 334, true) -- Quick Aim Disable
    SetPedConfigFlag(ped, 20, true) -- Quick Aim Disable
    SetPedConfigFlag(ped, 263, true) -- Disable Critical Damage
    SetPedConfigFlag(ped, 445, true) -- Disable Door Ramming
    SetPedConfigFlag(ped, 40, true) -- Allow Attacking
    SetPedConfigFlag(ped, 305, true) -- Disable Head Gore
    Citizen.InvokeNative(0x1B83C0DEEBCBB214, ped) -- RemoveAllPedAmmo
    ResetWeapons()
end)

RegisterNetEvent('qbr-weapons:client:CheckWeapon', ResetWeapons)

RegisterNetEvent('qbr-weapons:client:UseWeapon', function(weaponData, Inspect)
    local ped = PlayerPedId()
    local hash = joaat(weaponData.name)
    local weaponName = tostring(weaponData.name)
    local weapon = Citizen.InvokeNative(0x8425C5F057012DAB, ped) -- GetPedCurrentHeldWeapon
    local current = weapon ~= `WEAPON_UNARMED` and weapon
    local group = GetWeapontypeGroup(hash)
    if current and current == hash then
        if Inspect then return end
        SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
    elseif current and current ~= hash then
        Citizen.InvokeNative(0x1B83C0DEEBCBB214, ped)
        SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
        if string.find(weaponName, 'thrown') then
			Citizen.InvokeNative(0x106A811C6D3035F3, ped, Citizen.InvokeNative(0x5C2EA6C44F515F34, hash), 1, 752097756) -- AddAmmoToPedByType
            TriggerServerEvent('qbr-weapons:server:UsedThrowable', weaponName, weaponData.slot)
        end
        Wait(500)
        if group == `GROUP_REVOLVER` or group == `GROUP_PISTOL` then
            SetCurrentPedWeapon(ped, hash, true)
            SetAmmoInClip(ped, hash, weaponData.info.ammo or 0)
        else
            SetPedAmmo(ped, hash, weaponData.info.ammo or 0)
            Citizen.InvokeNative(0xB282DC6EBD803C75, ped, hash)  --GiveDelayedWeaponToPed
            SetCurrentPedWeapon(ped, hash, true)
        end
    else
        Citizen.InvokeNative(0x1B83C0DEEBCBB214, ped)
        if string.find(weaponName, 'thrown') then
			Citizen.InvokeNative(0x106A811C6D3035F3, ped, Citizen.InvokeNative(0x5C2EA6C44F515F34, hash), 1, 752097756) -- AddAmmoToPedByType
            TriggerServerEvent('qbr-weapons:server:UsedThrowable', weaponName, weaponData.slot)
        end
        Wait(100)
        if group == `GROUP_REVOLVER` or group == `GROUP_PISTOL` then
            SetCurrentPedWeapon(ped, hash, true)
            SetAmmoInClip(ped, hash, weaponData.info.ammo or 0)
        else
            SetPedAmmo(ped, hash, weaponData.info.ammo or 0)
            Citizen.InvokeNative(0xB282DC6EBD803C75, ped, hash)  --GiveDelayedWeaponToPed
            SetCurrentPedWeapon(ped, hash, true)
        end
    end
end)

RegisterNetEvent('qbr-weapons:client:AddAmmo', function(atype, amount, itemData)
    local ped = PlayerPedId()
    local weapon = atype ~= 'AMMO_ARROW' and Citizen.InvokeNative(0x8425C5F057012DAB,ped) or Citizen.InvokeNative(0xDBC4B552B2AE9A83, ped, joaat('slot_bow'))
    if Citizen.InvokeNative(0x5C2EA6C44F515F34, weapon) == joaat(atype) then
        local total = GetAmmoInPedWeapon(ped, weapon)
        if total <= 1 then
            local maxammo = Config.MaxAmmo[GetWeapontypeGroup(weapon)] or 12
            exports['qbr-core']:Progressbar("taking_bullets", Lang:t('info.loading_bullets'), math.random(4000, 6000), false, true, {
                disableCombat = true,
            }, {}, {}, {}, function() -- Done
                local weaponData = Weapons[weapon]
                if weaponData then
                    if weaponData.info?.quality and weaponData.info.quality <= 0 then
                        return  exports['qbr-core']:Notify(9, 'Cannot Reload Broken Weapon', 5000, 0, 'mp_lobby_textures', 'cross', 'COLOR_WHITE')
                    end
                    if atype == 'AMMO_ARROW' then
                        SetPedAmmo(ped, weapon, maxammo)
                        SetCurrentPedWeapon(ped, weapon, true)
                    else
                        if atype == 'AMMO_REVOLVER' or atype == 'AMMO_PISTOL' then
                            SetAmmoInClip(ped, weapon, maxammo)
                        else
                            SetPedAmmo(ped, weapon, maxammo)
                        end
                        TaskReloadWeapon(ped)
                    end
                    TriggerServerEvent('QBCore:Server:RemoveItem', itemData.name, 1, itemData.slot)
                    TriggerEvent('inventory:client:ItemBox', itemData.name, "remove")
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
end)

----------------------------------------------------------------------------
---- THREADS
----------------------------------------------------------------------------

CreateThread(function()
    SetWeaponsNoAutoswap(true)
    while true do
        local ped = PlayerPedId()
        local holdingweap = Citizen.InvokeNative(0x8425C5F057012DAB,ped) -- GetPedCurrentHeldWeapon
        local weapon = Weapons[holdingweap]
        if weapon then
            local IsGun = Citizen.InvokeNative(0x705BE297EEBDB95D, holdingweap) -- IsWeaponAGun
            if IsGun then
                local currentammo = GetAmmoInPedWeapon(ped, holdingweap)
                if currentammo ~= weapon.info.ammo then
                    local diff = weapon.info.ammo - currentammo
                    weapon.info.ammo = currentammo
                    local DecreaseAmount = Config.DurabilityMultiplier[holdingweap] * diff
					if weapon.info?.quality then 
                        Weapons[holdingweap].info.quality = weapon.info.quality - DecreaseAmount 
                    end
                    TriggerServerEvent('qbr-weapons:server:UpdateWeaponData', weapon.slot, currentammo, DecreaseAmount > 0 and DecreaseAmount)
                end
            end
        end
        Wait(1000)
    end
end)

CreateThread(function()
    for k, v in pairs(Config.WeaponRepairPoints) do
        exports['qbr-core']:createPrompt("weapons:repair"..k, v.coords, 0xCEFD9220, Lang:t('info.repair_button'), {
            type = 'callback',
            event = OpenMenu,
            args = {k},
        })
    end
end)
