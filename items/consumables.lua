SMODS.Atlas{
    key = 'LOB_consumeable',
    path = 'consumeable.png',
    px = 71,
    py = 95,
}

SMODS.Consumable({
    key = "opentolan",
    set = "Spectral",
    object_type = "Consumable",
    name = "opentolan",
    soul_set = "Spectral",
    loc_txt = {
        name = "Open To Lan",
        text={
        "Spawns the card",
        "{C:dark_edition}of your choice.{}",
        },
    },
	
	config = {},
	pos = {x=9, y= 0},
    soul_pos = { x = 9, y = 1 },
	order = 99,
	atlas = "LOB_consumeable",
    unlocked = true,
    cost = 10,
    sell_cost = 0,
    hidden = true,

    use = function(self, card, area, copier)
        G.opentolan_canspawn = true
        G.opentolan_phase = lob.ticks
        G.opentolan_phase_ex = 1
        G.opentolan_phase = 600
        print("Can spawn any item! Go to the Collection, hover on what you want and press Enter")
    end,

    can_use = function(self, card)
		return true
	end,

	check_for_unlock = function(self, args)
		if args.type == "win_deck" then
            unlock_card(self)
        else
			unlock_card(self)
		end
	end,
})

SMODS.Consumable {
    set = "Tarot",
    key = "plato",

	config = {
        max_highlighted = 2,
    },

    loc_txt = {
        name = "Plato",
        text = {
            "Transforme jusqu'à",
            "{C:attention}#1# cartes{} en",
            "{C:white,T:lob_noisy}cartes Bruyantes{}"
        }
    },

    loc_vars = function(self, info_queue, card)
        return {vars = {(card.ability or self.config).max_highlighted}}
    end,

    cost = 4,
    atlas = "LOB_consumeable",
    pos = {x=0, y=0},

    use = function(self, card, area, copier)

        for i = 1, math.min(#G.hand.highlighted, card.ability.max_highlighted) do

            G.E_MANAGER:add_event(Event({
                func = function()
                    card:juice_up(0.3,0.5)
                    return true
                end
            }))

            G.E_MANAGER:add_event(Event({
                trigger='after',
                delay=0.1,
                func=function()

                    G.hand.highlighted[i]:set_ability("m_lob_noisy")

                    return true
                end
            }))

            delay(0.5)
        end

        G.E_MANAGER:add_event(Event({
            trigger='after',
            delay=0.2,
            func=function()
                G.hand:unhighlight_all()
                return true
            end
        }))
    end
}

SMODS.Consumable {
    set = "Tarot",
    key = "td",

	config = {
        max_highlighted = 2,
    },

    loc_txt = {
        name = "TD",
        text = {
            "Transforme jusqu'à",
            "{C:attention}#1# cartes{} en",
            "{C:white,T:lob_silent}cartes Silencieuses{}"
        }
    },

    loc_vars = function(self, info_queue, card)
        return {vars = {(card.ability or self.config).max_highlighted}}
    end,

    cost = 4,
    atlas = "LOB_consumeable",
    pos = {x=1, y=0},

    use = function(self, card, area, copier)

        for i = 1, math.min(#G.hand.highlighted, card.ability.max_highlighted) do

            G.E_MANAGER:add_event(Event({
                func=function()
                    card:juice_up(0.3,0.5)
                    return true
                end
            }))

            G.E_MANAGER:add_event(Event({
                trigger='after',
                delay=0.1,
                func=function()

                    G.hand.highlighted[i]:set_ability("m_lob_silent")

                    return true
                end
            }))

            delay(0.5)
        end

        G.E_MANAGER:add_event(Event({
            trigger='after',
            delay=0.2,
            func=function()
                G.hand:unhighlight_all()
                return true
            end
        }))
    end
}

SMODS.Consumable {
    set = "Tarot",
    key = "echo",

	config = {
        max_highlighted = 2,
    },

    loc_txt = {
        name = "Echo",
        text = {
            "Transforme jusqu'à",
            "{C:attention}#1# cartes{} en",
            "{C:white,T:lob_echo}cartes Echo{}"
        }
    },

    loc_vars = function(self, info_queue, card)
        return {vars = {(card.ability or self.config).max_highlighted}}
    end,

    cost = 5,
    atlas = "LOB_consumeable",
    pos = {x=2, y=0},

    use = function(self, card, area, copier)

        for i = 1, math.min(#G.hand.highlighted, card.ability.max_highlighted) do

            G.E_MANAGER:add_event(Event({
                func=function()
                    card:juice_up(0.3,0.5)
                    return true
                end
            }))

            G.E_MANAGER:add_event(Event({
                trigger='after',
                delay=0.1,
                func=function()

                    G.hand.highlighted[i]:set_ability("m_lob_echo")

                    return true
                end
            }))

            delay(0.5)
        end

        G.E_MANAGER:add_event(Event({
            trigger='after',
            delay=0.2,
            func=function()
                G.hand:unhighlight_all()
                return true
            end
        }))
    end
}

SMODS.Consumable {
    set = "Tarot",
    key = "taco",

    loc_txt = {
        name = "Taco",
        text = {
            "+1 taille de main",
            "pendant cette manche"
        }
    },

    cost = 3,
    atlas = "LOB_consumeable",
    pos = {x=3, y=0},
    can_use = function(self, card, area, copier)
        return true
    end,
    use = function(self, card, area, copier)

        G.hand:change_size(1)

        G.GAME.lob_temp_hand = (G.GAME.lob_temp_hand or 0) + 1

        card_eval_status_text(card, 'extra', nil, nil, nil,
        {message = "+1 taille de la main", colour = G.C.GREEN})

    end
}

SMODS.Consumable {
    set = "Tarot",
    key = "weed",
    loc_txt = {
        name = "Weed",
        text = { "Retourne et mélange", "la main.", "Prochaine main :", "{X:mult,C:white}X3{} Mult" }
    },
    cost = 5,
    atlas = "LOB_consumeable",
    pos = {x=4,y=0},
    can_use = function(self, card, area, copier)
        return true
    end,
    use = function(self, card, area, copier)
        -- 1. Retourne toutes les cartes face visible
        for i=1, #G.hand.cards do
            if G.hand.cards[i].facing == 'front' then
                G.hand.cards[i]:flip()
            end
        end

        -- 2. Mélange la main pour que le joueur soit perdu
        G.hand:shuffle()

        G.GAME.lob_next_hand_xmult = 3

        card_eval_status_text(card, 'extra', nil, nil, nil,
        {message = "X3 next hand", colour = G.C.MULT})
    end
}

SMODS.Consumable {

    set = "Spectral",
    key = "malediction",

    loc_txt = {
        name = "Malédiction",
        text = {
            "Applique un",
            "{C:dark_edition}Dark Seal{}"
        }
    },

    config = {max_highlighted = 1},

    cost = 6,
    atlas = "LOB_consumeable",
    pos = {x=0,y=1},

    use = function(self, card, area, copier)

        if #G.hand.highlighted > 0 then
            G.hand.highlighted[1]:set_seal("lob_dark", true, true)
        end

        G.hand:unhighlight_all()

    end
}

SMODS.Consumable {

    set = "Spectral",
    key = "discord",

    loc_txt = {
        name = "Discord",
        text = {
            "Génère un",
            "Joker {C:attention}Élève{} aléatoire"
        }
    },

    cost = 6,
    atlas = "LOB_consumeable",
    pos = {x=1,y=1},

    use = function(self, card, area, copier)

        local new_joker = create_card(
            "Joker",
            G.jokers,
            nil,
            nil,
            nil,
            nil,
            nil,
            "discord"
        )

        new_joker:add_to_deck()
        G.jokers:emplace(new_joker)

    end
}

SMODS.Consumable {

    set = "Spectral",
    key = "cy",

    loc_txt = {
        name = "Cy",
        text = {
            "Génère un",
            "Joker {C:attention}Prof{} aléatoire"
        }
    },

    cost = 6,
    atlas = "LOB_consumeable",
    pos = {x=2,y=1},

    use = function(self, card, area, copier)

        local new_joker = create_card(
            "Joker",
            G.jokers,
            nil,
            nil,
            nil,
            nil,
            nil,
            "cy"
        )

        new_joker:add_to_deck()
        G.jokers:emplace(new_joker)

    end
}

SMODS.Consumable {
    set = "Spectral",
    key = "rituel_lukas",
    config = { max_highlighted = 1 },

    loc_txt = {
        name = "Rituel du Lukas",
        text = {
            "Sacrifie un {C:attention}Joker élève{}",
            "sélectionné pour invoquer",
            "sa forme {C:legendary}Lukas{} correspondante"
        }
    },

    cost = 4,
    atlas = "LOB_consumeable", 
    pos = {x = 3, y = 1},

    -- On autorise l'apparition en boutique et booster
    in_pool = function(self) return true end,

    -- Vérifie si UN SEUL joker est sélectionné
    can_use = function(self, card)
        return G.jokers and #G.jokers.highlighted == 1
    end,

    use = function(self, card, area, copier)
        local target = G.jokers.highlighted[1]
        
        local target_key = target.config.center.key
        
        -- Table de correspondance (Clé du Joker sacrifié -> Clé du Lukas invoqué)
        local lukas_map = {
            j_lob_mansour  = "j_lob_lukas_soumi",
            j_lob_yanis    = "j_lob_lukas_fou",
            j_lob_matteo   = "j_lob_lukas_grenouille",
            j_lob_lucien   = "j_lob_lukas_sorciere",
            j_lob_axel     = "j_lob_lukas_militaire",
            j_lob_github   = "j_lob_lukas_fatigue",
            j_lob_pixel    = "j_lob_lukas_clown",
            j_lob_modpack  = "j_lob_lukas_scientifique",
            j_lob_zozan    = "j_lob_lukas_plage",
            j_lob_lukas    = "j_lob_lukas_giga_chad"
        }

        local spawn_key = lukas_map[target_key] or "j_lob_lukas"

        -- Animation de début
        play_sound('tarot1')
        card:juice_up(0.3, 0.5)

        -- 1. On détruit le Joker sacrifié avec une animation
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                target:start_dissolve()
                return true
            end
        }))

        -- 2. On invoque le nouveau Lukas
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                local new_joker = SMODS.add_card({
                    set = "Joker",
                    key = spawn_key,
                    ins_at = target.states.last_sort_order -- Garde la même position
                })
                new_joker:juice_up(0.3, 0.5)
                return true
            end
        }))
    end
}

-- reset open to lan on run restart (and other variables)
local _startrunhook = Game.start_run
function Game:start_run(args)
    _startrunhook(self, args)
    if G.SETTINGS.GAMESPEED == 0.25 then G.SETTINGS.GAMESPEED = 1 end
    if G.wiwidestroyed and G.wiwidestroyed ~= 0 then G.wiwidestroyed = 0 end

    if G.opentolan_canspawn == true then
        G.opentolan_phase_ex = 2
        G.opentolan_phase = lob.ticks
        G.opentolan_canspawn = false
    end
end

local calc_ref = Card.calculate_joker
function Card:calculate_joker(context)

    local ret = calc_ref(self, context)

    if context.joker_main and G.GAME.lob_next_hand_xmult then

        local mult = G.GAME.lob_next_hand_xmult
        G.GAME.lob_next_hand_xmult = nil

        return {
            Xmult_mod = mult,
            message = "Weed X"..mult
        }

    end

    return ret
end