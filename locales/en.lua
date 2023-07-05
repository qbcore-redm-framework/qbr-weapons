local Translations = {
    error = {
        canceled = 'Canceled',
        max_ammo = 'Max Ammo Capacity',
        no_weapon = 'You have no weapon.',
        no_support_attachment = 'This weapon does not support this attachment.',
        no_weapon_in_hand = 'You dont have a weapon in your hand.',
        weapon_broken = 'This weapon is broken and can not be used.',
        no_damage_on_weapon = 'This weapon is not damaged..',
        weapon_broken_need_repair = 'Your weapon is broken, you need to repair it before you can use it again.',
        attachment_already_on_weapon = 'You already have a %{value} on your weapon.'
    },
    success = {
        reloaded = 'Reloaded',
        weapon_ready = 'Your Weapon is Ready'
    },
    info = {
        loading_bullets = 'Loading Bullets',
        repair_button = 'Fix Weapons'
    }
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
