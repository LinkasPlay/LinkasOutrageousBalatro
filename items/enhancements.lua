SMODS.Atlas {
	key = "enhancements",
	path = "Enhancers.png",
	px = 71,
	py = 95
}

SMODS.Enhancement {
    key = 'noisy',
    atlas = 'enhancements',
    pos = { x = 0, y = 0 }, 
    loc_txt = {
        name = 'Carte Bruyante',
        text = {
            "{X:mult,C:white}X#1#{} Mult",
            "(1 + 0.1 par carte tenue en main)"
        }
    },
    calculate = function(self, card, context)
        if context.main_scoring and context.cardarea == G.play then
            local hand_size = (G.hand and G.hand.cards) and #G.hand.cards or 0
            local xmult = 1 + 0.1 * hand_size
            return {
                Xmult_mod = xmult,
                message = "X" .. string.format("%.1f", xmult),
                colour = G.C.MULT
            }
        end
    end,
    loc_vars = function(self, info_queue, card)
        local hand_size = (G.hand and G.hand.cards) and #G.hand.cards or 0
        local xmult = 1 + 0.1 * hand_size
        return { vars = { string.format("%.1f", xmult) } }
    end
}

SMODS.Enhancement {
    key = 'silent',
    atlas = 'enhancements',
    pos = { x = 1, y = 0 },
    loc_txt = {
        name = 'Carte Silencieuse',
        text = {
            "{X:mult,C:white}X#1#{} Mult",
            "(3 - 0.3 par carte tenue en main)"
        }
    },
    calculate = function(self, card, context)
        if context.main_scoring and context.cardarea == G.play then
            local hand_size = (G.hand and G.hand.cards) and #G.hand.cards or 0
            local xmult = math.max(0.5, 3 - 0.3 * hand_size)
            return {
                Xmult_mod = xmult,
                message = "X" .. string.format("%.1f", xmult),
                colour = G.C.MULT
            }
        end
    end,
    loc_vars = function(self, info_queue, card)
        local hand_size = (G.hand and G.hand.cards) and #G.hand.cards or 0
        local xmult = math.max(0.5, 3 - 0.3 * hand_size)
        return { vars = { string.format("%.1f", xmult) } }
    end
}

SMODS.Enhancement {
    key = 'echo',
    atlas = 'enhancements',
    pos = { x = 3, y = 0 },
    loc_txt = {
        name = 'Carte Écho',
        text = {
            "Se retrigger {C:attention}trois fois{}",
            "si au moins une {C:attention}Bruyante{} ou {C:attention}Silencieuse{}",
            "est jouée dans la même main"
        }
    },
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            -- On vérifie si une carte bruyante ou silencieuse a été jouée
            local has_trigger_card = false
            for _, played_card in ipairs(context.scoring_hand or {}) do
                if played_card ~= card and 
                   (played_card.config.center.key == 'm_lob_noisy' or 
                    played_card.config.center.key == 'm_lob_silent') then
                    has_trigger_card = true
                    break -- On arrête de chercher dès qu'on en trouve une
                end
            end
            
            if has_trigger_card then
                return {
                    message = 'Écho !',
                    repetitions = 3,
                    card = card
                }
            end
        end
    end
}

SMODS.Seal{
    key = "dark",
    atlas = "enhancements",
    pos = {x = 2, y = 0},
    badge_colour = G.C.WHITE,
    loc_txt = {
        name = "Dark Seal",
        text = {
            "Quand cette carte est",
            "{C:red}détruite{} : crée",
            "un {C:dark_edition}Joker négatif{}"
        }
    },

    calculate = function(self, card, context)
        if context.cards_destroyed then
            for _, v in ipairs(context.cards_destroyed) do
                -- On ajoute le "not card.dark_seal_triggered" pour empêcher la boucle folle
                if v == card and not card.dark_seal_triggered then
                    card.dark_seal_triggered = true
                    
                    local joker = create_card("Joker", G.jokers, nil, nil, nil, nil, nil, 'j_lob_dark_joker')
                    joker:set_edition('e_negative', true)
                    joker:add_to_deck()
                    G.jokers:emplace(joker)
                    
                    return { message = "Négatif !" }
                end
            end
        end
    end
}