Config = Config or {}

Config.Debug = true

Config.WeaponRepairPoints = {
    [1] = {coords = vector3(1417.818, 268.0298, 89.61942)},
}

Config.WeaponRepairCosts = {
    ["pistol"] = 100,
    ["revolver"] = 200,
    ["repeater"] = 300,
    ["rifle"] = 300,
    ["shotgun"] = 400
}

Config.MaxAmmo = {
    [`GROUP_PISTOL`] = 6,
    [`GROUP_RIFLE`] = 12,
    [`GROUP_REVOLVER`] = 6,
    [`GROUP_SHOTGUN`] = 6,
    [`GROUP_BOW`] = 6,
}

Config.DurabilityMultiplier = {
    -- Handguns
    [`weapon_revolver_cattleman`] = 0.15,
	[`weapon_revolver_cattleman_mexican`] = 0.15,
	[`weapon_revolver_doubleaction_gambler`] = 0.15,
	[`weapon_revolver_schofield`] = 0.15,
	[`weapon_revolver_lemat`] = 0.15,
	[`weapon_revolver_navy`] = 0.15,
	[`weapon_pistol_volcanic`] = 0.15,
	[`weapon_pistol_m1899`] = 0.15,
	[`weapon_pistol_mauser`] = 0.15,
	[`weapon_pistol_semiauto`] = 0.15,
	[`weapon_repeater_carbine`]  = 0.15,
	[`weapon_repeater_winchester`] = 0.15,
	[`weapon_repeater_henry`] = 0.15,
	[`weapon_repeater_evans`] = 0.15,

    --Rifles
	[`weapon_rifle_varmint`] = 0.15,
	[`weapon_rifle_springfield`] = 0.15,
	[`weapon_rifle_boltaction`] = 0.15,
	[`weapon_rifle_elephant`] = 0.15,
	[`weapon_sniperrifle_rollingblock`] = 0.15,
	[`weapon_sniperrifle_rollingblock_exotic`] = 0.15,
	[`weapon_sniperrifle_carcano`] = 0.15,

    -- Shotguns
    [`weapon_shotgun_doublebarrel`] = 0.15,
	[`weapon_shotgun_doublebarrel_exotic`] = 0.15,
	[`weapon_shotgun_sawedoff`] = 0.15,
	[`weapon_shotgun_semiauto`] = 0.15,

    -- Bows
    [`weapon_bow_improved`] = 0.15,
	[`weapon_bow`] = 0.15,
}