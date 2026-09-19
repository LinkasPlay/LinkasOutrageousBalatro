-- Booster Atlas
SMODS.Atlas{
    key = 'boosteratlas',
    path = 'boosters.png',
    px = 71,
    py = 95,
}

local lob_use_card_ref = G.FUNCS.use_card
G.FUNCS.use_card = function(e)
    local ref = e.config and e.config.ref_table
    local center = ref and ref.config and ref.config.center
    if center and center.set == 'Booster' and center.key and string.find(center.key, "lob") then
        G.GAME.lob_current_pack_key = center.key
    end
    return lob_use_card_ref(e)
end

SMODS.Sound {
    key = "music_shop",
    path = "music_shop.ogg",
    pitch = 1,
    select_music_track = function()
        local pack_states = {
            [G.STATES.TAROT_PACK] = true,
            [G.STATES.PLANET_PACK] = true,
            [G.STATES.SPECTRAL_PACK] = true,
            [G.STATES.STANDARD_PACK] = true,
            [G.STATES.BUFFOON_PACK] = true,
            [G.STATES.SMODS_BOOSTER_OPENED] = true
        }

        if not pack_states[G.STATE] then
            G.GAME.lob_current_pack_key = nil
            return
        end

        if G.GAME.lob_current_pack_key then
            return 100
        end
    end
}

SMODS.Booster{
    key = 'booster_eleve',
    group_key = "k_eleve_booster_group",
    atlas = 'boosteratlas',
    pos = { x = 2, y = 0 },
    discovered = true,
    loc_txt= {
        name = 'Paquet élève',
        text = { "Choissisez {C:attention}#1#{} parmis",
                "{C:attention}#2# cartes{} jokers d'éléves", },
    },

    draw_hand = false,
    config = {
        extra = 2,
        choose = 1,
    },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.choose, card.ability.extra } }
    end,

    weight = 1,
    cost = 5,
    kind = "ELEVE",

    create_card = function(self, card, i)
        ease_background_colour(HEX("ffac00"))
        return SMODS.create_card({
            set = "ELEVE",
            area = G.pack_cards,
            skip_materialize = true,
            soulable = true,
        })
    end,
    select_card = 'jokers',

    in_pool = function() return true end
}

SMODS.Booster{
    key = 'booster_eleve_jumbo',
    group_key = "k_eleve_booster_group",
    atlas = 'boosteratlas',
    pos = { x = 3, y = 0 },

    discovered = true,

    loc_txt = {
        name = 'Paquet Jumbo Élèves',
        text = {
            "Choissisez {C:attention}#1#{} parmi",
            "{C:attention}#2# cartes{} jokers d'élèves"
        }
    },

    draw_hand = false,

    config = {
        extra = 4,
        choose = 1
    },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.choose, card.ability.extra } }
    end,

    weight = 0.6,
    cost = 7,
    kind = "ELEVE",

    create_card = function(self, card, i)
        ease_background_colour(HEX("ffac00"))
        return SMODS.create_card({
            set = "ELEVE",
            area = G.pack_cards,
            skip_materialize = true,
            soulable = true
        })
    end,

    select_card = 'jokers'
}

SMODS.Booster{
    key = 'booster_prof',
    group_key = "k_prof_booster_group",
    atlas = 'boosteratlas',
    pos = { x = 1, y = 0 },

    discovered = true,

    loc_txt = {
        name = 'Paquet Professeurs',
        text = {
            "Choissisez {C:attention}#1#{} parmi",
            "{C:attention}#2# cartes{} jokers de professeurs"
        }
    },

    draw_hand = false,

    config = {
        extra = 2,
        choose = 1
    },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.choose, card.ability.extra } }
    end,

    weight = 1,
    cost = 5,
    kind = "PROF",

    create_card = function(self, card, i)
        ease_background_colour(HEX("7aa6ff"))
        return SMODS.create_card({
            set = "PROF",
            area = G.pack_cards,
            skip_materialize = true,
            soulable = true
        })
    end,

    select_card = 'jokers'
}

SMODS.Booster{
    key = 'booster_prof_jumbo',
    group_key = "k_prof_booster_group",
    atlas = 'boosteratlas',
    pos = { x = 0, y = 0 },

    discovered = true,

    loc_txt = {
        name = 'Paquet Jumbo Professeurs',
        text = {
            "Choissisez {C:attention}#1#{} parmi",
            "{C:attention}#2# cartes{} jokers de professeurs"
        }
    },

    draw_hand = false,

    config = {
        extra = 4,
        choose = 1
    },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.choose, card.ability.extra } }
    end,

    weight = 0.6,
    cost = 7,
    kind = "PROF",

    create_card = function(self, card, i)
        ease_background_colour(HEX("7aa6ff"))
        return SMODS.create_card({
            set = "PROF",
            area = G.pack_cards,
            skip_materialize = true,
            soulable = true
        })
    end,

    select_card = 'jokers'
}

SMODS.Booster{
    key = 'booster_minecraft',
    group_key = "k_minecraft_booster_group",
    atlas = 'boosteratlas',
    pos = { x = 0, y = 1 },

    discovered = true,

    loc_txt = {
        name = 'Paquet Minecraft',
        text = {
            "Choissisez {C:attention}#1#{} parmi",
            "{C:attention}#2# cartes{} jokers Minecraft"
        }
    },

    draw_hand = false,

    config = {
        extra = 2,
        choose = 1
    },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.choose, card.ability.extra } }
    end,

    weight = 1,
    cost = 5,
    kind = "MINECRAFT",

    create_card = function(self, card, i)
        ease_background_colour(HEX("5bbf3a"))
        return SMODS.create_card({
            set = "MINECRAFT",
            area = G.pack_cards,
            skip_materialize = true,
            soulable = true
        })
    end,

    select_card = 'jokers'
}

SMODS.Booster{
    key = 'booster_minecraft_jumbo',
    group_key = "k_minecraft_booster_group",
    atlas = 'boosteratlas',
    pos = { x = 0, y = 2 },

    discovered = true,

    loc_txt = {
        name = 'Paquet Jumbo Minecraft',
        text = {
            "Choissisez {C:attention}#1#{} parmi",
            "{C:attention}#2# cartes{} jokers Minecraft"
        }
    },

    draw_hand = false,

    config = {
        extra = 4,
        choose = 1
    },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.choose, card.ability.extra } }
    end,

    weight = 0.6,
    cost = 7,
    kind = "MINECRAFT",

    create_card = function(self, card, i)
        ease_background_colour(HEX("5bbf3a"))
        return SMODS.create_card({
            set = "MINECRAFT",
            area = G.pack_cards,
            skip_materialize = true,
            soulable = true
        })
    end,

    select_card = 'jokers'
}

SMODS.Booster{
    key = 'booster_info',
    group_key = "k_info_booster_group",
    atlas = 'boosteratlas',
    pos = { x = 1, y = 1 },

    discovered = true,

    loc_txt = {
        name = 'Paquet Informatique',
        text = {
            "Choissisez {C:attention}#1#{} parmi",
            "{C:attention}#2# cartes{} jokers Informatique"
        }
    },

    draw_hand = false,

    config = {
        extra = 2,
        choose = 1
    },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.choose, card.ability.extra } }
    end,

    weight = 1,
    cost = 5,
    kind = "INFO",

    create_card = function(self, card, i)
        ease_background_colour(HEX("4fd6ff"))
        return SMODS.create_card({
            set = "INFO",
            area = G.pack_cards,
            skip_materialize = true,
            soulable = true
        })
    end,

    select_card = 'jokers'
}

SMODS.Booster{
    key = 'booster_info_jumbo',
    group_key = "k_info_booster_group",
    atlas = 'boosteratlas',
    pos = { x = 1, y = 2 },

    discovered = true,

    loc_txt = {
        name = 'Paquet Jumbo Informatique',
        text = {
            "Choissisez {C:attention}#1#{} parmi",
            "{C:attention}#2# cartes{} jokers Informatique"
        }
    },

    draw_hand = false,

    config = {
        extra = 4,
        choose = 1
    },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.choose, card.ability.extra } }
    end,

    weight = 0.6,
    cost = 7,
    kind = "INFO",

    create_card = function(self, card, i)
        ease_background_colour(HEX("4fd6ff"))
        return SMODS.create_card({
            set = "INFO",
            area = G.pack_cards,
            skip_materialize = true,
            soulable = true
        })
    end,

    select_card = 'jokers'
}

SMODS.Booster{
    key = 'booster_physique',
    group_key = "k_physique_booster_group",
    atlas = 'boosteratlas',
    pos = { x = 2, y = 1 },

    discovered = true,

    loc_txt = {
        name = 'Paquet Physique',
        text = {
            "Choissisez {C:attention}#1#{} parmi",
            "{C:attention}#2# cartes{} jokers Physique"
        }
    },

    draw_hand = false,

    config = {
        extra = 2,
        choose = 1
    },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.choose, card.ability.extra } }
    end,

    weight = 1,
    cost = 5,
    kind = "PHYSIQUE",

    create_card = function(self, card, i)
        ease_background_colour(HEX("b084ff"))
        return SMODS.create_card({
            set = "PHYSIQUE",
            area = G.pack_cards,
            skip_materialize = true,
            soulable = true
        })
    end,

    select_card = 'jokers'
}

SMODS.Booster{
    key = 'booster_physique_jumbo',
    group_key = "k_physique_booster_group",
    atlas = 'boosteratlas',
    pos = { x = 2, y = 2 },

    discovered = true,

    loc_txt = {
        name = 'Paquet Jumbo Physique',
        text = {
            "Choissisez {C:attention}#1#{} parmi",
            "{C:attention}#2# cartes{} jokers Physique"
        }
    },

    draw_hand = false,

    config = {
        extra = 4,
        choose = 1
    },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.choose, card.ability.extra } }
    end,

    weight = 0.6,
    cost = 7,
    kind = "PHYSIQUE",

    create_card = function(self, card, i)
        ease_background_colour(HEX("b084ff"))
        return SMODS.create_card({
            set = "PHYSIQUE",
            area = G.pack_cards,
            skip_materialize = true,
            soulable = true
        })
    end,

    select_card = 'jokers'
}

SMODS.Booster{
    key = 'booster_math',
    group_key = "k_math_booster_group",
    atlas = 'boosteratlas',
    pos = { x = 3, y = 1 },

    discovered = true,

    loc_txt = {
        name = 'Paquet Mathématiques',
        text = {
            "Choissisez {C:attention}#1#{} parmi",
            "{C:attention}#2# cartes{} jokers Mathématiques"
        }
    },

    draw_hand = false,

    config = {
        extra = 2,
        choose = 1
    },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.choose, card.ability.extra } }
    end,

    weight = 1,
    cost = 5,
    kind = "MATH",

    create_card = function(self, card, i)
        ease_background_colour(HEX("ff5fa2"))
        return SMODS.create_card({
            set = "MATH",
            area = G.pack_cards,
            skip_materialize = true,
            soulable = true
        })
    end,

    select_card = 'jokers'
}

SMODS.Booster{
    key = 'booster_math_jumbo',
    group_key = "k_math_booster_group",
    atlas = 'boosteratlas',
    pos = { x = 3, y = 2 },

    discovered = true,

    loc_txt = {
        name = 'Paquet Jumbo Mathématiques',
        text = {
            "Choissisez {C:attention}#1#{} parmi",
            "{C:attention}#2# cartes{} jokers Mathématiques"
        }
    },

    draw_hand = false,

    config = {
        extra = 4,
        choose = 1
    },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.choose, card.ability.extra } }
    end,

    weight = 0.6,
    cost = 7,
    kind = "MATH",

    create_card = function(self, card, i)
        ease_background_colour(HEX("ff5fa2"))
        return SMODS.create_card({
            set = "MATH",
            area = G.pack_cards,
            skip_materialize = true,
            soulable = true
        })
    end,

    select_card = 'jokers'
}