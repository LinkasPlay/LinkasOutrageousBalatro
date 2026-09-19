SMODS.Atlas {
	key = "LOB",
	path = "jokersprof.png",
	px = 71,
	py = 95
}

SMODS.Joker {
	key = 'el_amine_khalid',
	loc_txt = {
		name = 'El Amine Khalid',
		text = {
			"Si la main jouée est de type {C:attention}#1#{} :",
			"{X:mult,C:white}^5{} Mult",
			"Sinon : {X:mult,C:white}X0{} Mult"
		}
	},

	config = { extra = { poker_hand = 'High Card' } },

	blueprint_compat = true,
	eternal_compat   = true,
	perishable_compat= true,

    pools = { ["PROF"] = true, ["MATH"] = true, ["LOB"] = true },

	rarity = 3,
	atlas  = 'LOB',
	pos    = { x = 2, y = 0 },
    soul_pos = { x = 3, y = 0 },
	cost   = 10,

	loc_vars = function(self, info_queue, card)
        local hand_name = localize(card.ability.extra.poker_hand, 'poker_hands')
		return { vars = { hand_name } }
	end,

    set_ability = function(self, card, initial, delay_sprites)
        local _poker_hands = {}
        for handname, _ in pairs(G.GAME.hands) do
            if SMODS.is_poker_hand_visible(handname) then
                _poker_hands[#_poker_hands + 1] = handname
            end
        end
        card.ability.extra.poker_hand = pseudorandom_element(_poker_hands, 'el_amine_khalid_init')
    end,

	calculate = function(self, card, context)
        if context.end_of_round and context.game_over == false and not context.blueprint and context.main_eval then
            local _poker_hands = {}
            for handname, _ in pairs(G.GAME.hands) do
                if SMODS.is_poker_hand_visible(handname) then
                    _poker_hands[#_poker_hands + 1] = handname
                end
            end
            card.ability.extra.poker_hand = pseudorandom_element(_poker_hands, 'el_amine_khalid_reset')
            return {
                message = localize('k_reset'),
                colour = G.C.YELLOW,
                card = card
            }
        end

        if context.joker_main then
            if context.scoring_name == card.ability.extra.poker_hand then
                return { 
                    message = "^5", 
                    Xmult_mod = 5 
                }
            else
                return { 
                    message = "X0", 
                    Xmult_mod = 0 
                }
            end
        end
	end
}

SMODS.Joker {
    key = 'fabien_piguet',
    loc_txt = {
        name = 'Fabien Piguet',
        text = {
            "{C:chips}+#1#{} Chips",
            "{C:inactive}(Gagne {C:chips}+1{} chip par seconde en combat)",
            "{C:inactive}Reset à chaque main jouée"
        }
    },
    config = { extra = { chips = 0, last_tick = 0 } },

    blueprint_compat = true,
    eternal_compat   = true,
    perishable_compat= true,

    pools = { ["PROF"] = true, ["PHYSIQUE"] = true, ["LOB"] = true },

    rarity = 3,
    atlas = 'LOB',
    pos = { x = 0, y = 4 },
    soul_pos = { x = 1, y = 4 },
    cost = 10,

    loc_vars = function(self, info_queue, card)
        return { vars = { math.floor(card.ability.extra.chips) } }
    end,

    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            card.ability.extra.chips = 0
            return {
                message = "Reset !",
                colour = G.C.CHIPS
            }
        end

        if context.joker_main then
            return {
                chip_mod = math.floor(card.ability.extra.chips),
                message = localize { type = 'variable', key = 'a_chips', vars = { math.floor(card.ability.extra.chips) } }
            }
        end
        
    end,

    update = function(self, card, dt)
        if G.STATE == G.STATES.SELECTING_HAND or G.STATE == G.STATES.PLAY_TAROT or G.STATE == G.STATES.HAND_PLAYED then
            if not card.ability.extra.last_tick then card.ability.extra.last_tick = lob.ticks end
            
            if lob.ticks >= card.ability.extra.last_tick + 100 then
                card.ability.extra.chips = card.ability.extra.chips + 1
                card.ability.extra.last_tick = lob.ticks
                card_eval_status_text(card, 'extra', nil, nil, nil, {
                    message = "+1",
                    colour = G.C.CHIPS,
                    scale = 0.5
                })
            end
        end
    end
}

SMODS.Joker {
    key = 'akridas_morel_panayotis',
    loc_txt = {
        name = 'Akridas Morel Panayotis',
        text = {
            "Chaque carte {C:attention}Bruyante{} jouée",
            "donne {X:mult,C:white}^1.25{} Mult",
            "et toutes les cartes Bruyante/Silencieuse",
            "sont inversées à la fin de la main"
        }
    },
    config = { extra = {} },
    blueprint_compat = true,
    pools = { ["PROF"] = true, ["PHYSIQUE"] = true, ["LOB"] = true },
    rarity = 3,
    atlas = 'LOB',
    pos = { x = 0, y = 6 },
    soul_pos = { x = 1, y = 6 },
    cost = 10,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card.config.center == G.P_CENTERS.m_lob_noisy then
                return {
                    x_mult = 1.25,
                    colour = G.C.MULT,
                    card = context.other_card
                }
            end
        end

        if context.after and not context.blueprint and not context.repetition then
            local flipped = false
            for _, c in ipairs(context.full_hand or {}) do
                if c.config.center == G.P_CENTERS.m_lob_noisy then
                    c:set_ability(G.P_CENTERS.m_lob_silent, nil, true)
                    flipped = true
                elseif c.config.center == G.P_CENTERS.m_lob_silent then
                    c:set_ability(G.P_CENTERS.m_lob_noisy, nil, true)
                    flipped = true
                end
            end
            
            if flipped then
                return {
                    message = "Changement de ton !",
                    colour = G.C.PURPLE
                }
            end
        end
    end
}

SMODS.Joker {
    key = 'nguyen',
    loc_txt = {
        name = 'Nguyen',
        text = {
            "Si la main jouée est de type {C:attention}#1#{} :",
            "{X:mult,C:white}X0{} Mult",
            "Sinon : {X:mult,C:white}X2.5{} Mult"
        }
    },
    config = { extra = { poker_hand = 'High Card' } },
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    pools = { ["PROF"] = true, ["MATH"] = true, ["LOB"] = true },
    rarity = 3,
    atlas = 'LOB',
    pos = { x = 2, y = 1 },
    soul_pos = { x = 3, y = 1 },
    cost = 10,

    loc_vars = function(self, info_queue, card)
        local hand_key = card.ability.extra.poker_hand or 'High Card'
        local hand_name = localize(hand_key, 'poker_hands')
        return { vars = { hand_name } }
    end,

    set_ability = function(self, card, initial, delay_sprites)
        local _poker_hands = {}
        for handname, _ in pairs(G.GAME.hands) do
            if SMODS.is_poker_hand_visible(handname) then
                _poker_hands[#_poker_hands + 1] = handname
            end
        end
        card.ability.extra.poker_hand = pseudorandom_element(_poker_hands, 'nguyen_init') or 'High Card'
    end,

    calculate = function(self, card, context)
        if context.end_of_round and context.game_over == false and not context.blueprint and context.main_eval then
            local _hands = {}
            for h,_ in pairs(G.GAME.hands) do
                if SMODS.is_poker_hand_visible(h) then _hands[#_hands+1] = h end
            end
            card.ability.extra.poker_hand = pseudorandom_element(_hands, 'nguyen_reset') or card.ability.extra.poker_hand or 'High Card'
            return { message = localize('k_reset'), colour = G.C.YELLOW, card = card }
        end

        if context.joker_main then
            if card.ability.extra.poker_hand and context.scoring_name == card.ability.extra.poker_hand then
                return { message = "X0 Mult !", Xmult_mod = 0, colour = G.C.RED }
            else
                return {
                    message = "X2.5",
                    Xmult_mod = 2.5,
                    colour = G.C.MULT,
                    card = card
                }
            end
        end
    end
}

SMODS.Joker {
    key = 'aranciaba',
    loc_txt = {
        name = 'Aranciaba',
        text = {
            "{X:mult,C:white}X#1#{} Mult",
            "({C:attention}#2#{} cette main)"
        }
    },
    config = { extra = { xmult = 1.0 } },
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    pools = { ["PROF"] = true, ["MATH"] = true, ["LOB"] = true },
    rarity = 3,
    atlas = 'LOB',
    pos = { x = 0, y = 1 },
    soul_pos = { x = 1, y = 1 },
    cost = 10,

    loc_vars = function(self, info_queue, card)
        local x = card.ability.extra.xmult or 1.0
        local status = (x == 1) and "É.B." or (x > 1 and "Mayoré" or "Minoré")
        return { vars = { string.format("%.2f", x), status } }
    end,

    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            local is_high = pseudorandom('aranciaba_chance') > 0.5
            local rand = 1.0
            
            if is_high then
                rand = 1.01 + pseudorandom('aranciaba_high') * 98.99
            else
                rand = 0.01 + pseudorandom('aranciaba_low') * 0.98
            end
            
            card.ability.extra.xmult = rand

            local status = (rand == 1) and "é bé comment cé arrivé ? Cé pas tré statistiquement probable !" or (rand > 1 and "Mayoré !" or "Minoré !")
            return {
                message = status .. " X" .. string.format("%.2f", rand),
                colour = (rand > 1) and G.C.MULT or (rand < 1 and G.C.RED or G.C.GREY),
                card = card
            }
        end

        if context.joker_main then
            local x = card.ability.extra.xmult or 1.0
            return {
                Xmult_mod = x,
                message = "X" .. string.format("%.2f", x)
            }
        end
    end
}

SMODS.Joker {
    key = 'j_lob_batiti',
    loc_txt = {
        name = 'Batiti',
        text = {
            "{C:attention}+#1#{} taille de main",
            "par autre joker {C:attention}Professeur{}",
            "{C:inactive}(Actuellement +#2#){}"
        }
    },
    config = { extra = { current_prof_bonus = 0 } },
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    pools = { ["PROF"] = true, ["MATH"] = true, ["LOB"] = true },
    rarity = 3,
    atlas = 'LOB',
    pos = { x = 2, y = 2 },
    soul_pos = { x = 3, y = 2 },
    cost = 10,

    loc_vars = function(self, info_queue, card)
        return { vars = { 1, card.ability.extra.current_prof_bonus or 0 } }
    end,

    update = function(self, card, dt)
        if G.jokers and G.jokers.cards and G.hand then
            local prof_count = 0
            if not card.debuff then
                for _, j in ipairs(G.jokers.cards) do
                    if j ~= card and j.config.center.pools and j.config.center.pools["PROF"] and not j.debuff then
                        prof_count = prof_count + 1
                    end
                end
            end
            
            local current = card.ability.extra.current_prof_bonus or 0
            if prof_count ~= current then
                G.hand:change_size(prof_count - current)
                card.ability.extra.current_prof_bonus = prof_count
            end
        end
    end,

    remove_from_deck = function(self, card, from_debuff)
        if G.hand and card.ability.extra.current_prof_bonus ~= 0 then
            G.hand:change_size(-(card.ability.extra.current_prof_bonus or 0))
            card.ability.extra.current_prof_bonus = 0
        end
    end
}

SMODS.Joker {
    key = 'zoghlami',
    loc_txt = {
        name = 'Zoghlami',
        text = {
            "{C:green}1/6{} chance de {X:mult,C:white}^10{} Mult",
            "sinon : {X:mult,C:white}X0{} Mult"
        }
    },
    config = { extra = {} },
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    pools = { ["PROF"] = true, ["MATH"] = true, ["LOB"] = true },
    rarity = 3,
    atlas = 'LOB',
    pos = { x = 0, y = 0 },
    soul_pos = { x = 1, y = 0 },
    cost = 10,

    calculate = function(self, card, context)
        if context.joker_main then
            if pseudorandom('zoghlami') < (1/6) then
                return {
                    message = "Comment ???",
                    Xmult_mod = 10,
                    colour = G.C.MULT
                }
            else
                return {
                    message = "0/20",
                    Xmult_mod = 0,
                    colour = G.C.RED
                }
            end
        end
    end
}

SMODS.Joker {
    key = 'ludivic_cesbron',
    loc_txt = {
        name = 'Ludivic Cesbron',
        text = {
            "Si {C:attention}exactement 3{} cartes figures {C:attention}bruyantes{} sont jouées:",
            "elles deviennent {C:attention}silencieuses{}, {C:dark_edition}red seal{} et {C:dark_edition}negative{}"
        }
    },
    pools = { ["PROF"] = true, ["MATH"] = true, ["LOB"] = true },
    rarity = 3,
    atlas = 'LOB',
    pos = { x = 0, y = 2 },
    soul_pos = { x = 1, y = 2 },
    cost = 10,

    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            local candidates = {}
            for _, c in ipairs(context.full_hand or {}) do
                if c:is_face() and c.config.center == G.P_CENTERS.m_lob_noisy then
                    table.insert(candidates, c)
                end
            end

            if #candidates == 3 then
                for _, c in ipairs(candidates) do
                    c:set_ability(G.P_CENTERS.m_lob_silent, nil, true)
                    c:set_seal('Red', true, true)
                    c:set_edition({ negative = true }, true)
                end
                return {
                    message = "Optimisation !",
                    colour = G.C.DARK_EDITION
                }
            end
        end
    end
}

SMODS.Joker {
    key = 'banica_teodore',
    loc_txt = {
        name = 'Banica Teodore',
        text = {
            "Au début de la manche :",
            "Si seul {C:attention}Prof{} : {X:mult,C:white}+1{} Xmult",
            "Sinon : {C:attention}-1{} Xmult",
            "Si {C:attention}Ludivic{} présent : {X:mult,C:white}X0{} Mult",
            "{C:inactive}(Actuellement {X:mult,C:white} X#1# {C:inactive} Mult)"
        }
    },
    config = { extra = { xmult = 1 } },
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    pools = { ["PROF"] = true, ["MATH"] = true, ["LOB"] = true },
    rarity = 3,
    atlas = 'LOB',
    pos = { x = 0, y = 3 },
    soul_pos = { x = 1, y = 3 },
    cost = 10,

    loc_vars = function(self, info_queue, card)
        local has_ludivic = false
        if G.jokers and G.jokers.cards then
            for _, j in ipairs(G.jokers.cards) do
                if j.config.center.key == 'j_lob_ludivic_cesbron' then 
                    has_ludivic = true 
                    break 
                end
            end
        end
        local current_xmult = has_ludivic and 0 or (card.ability.extra.xmult or 1)
        return { vars = { current_xmult } }
    end,

    calculate = function(self, card, context)
        local has_ludivic = false
        if G.jokers and G.jokers.cards then
            for _, j in ipairs(G.jokers.cards) do
                if j.config.center.key == 'j_lob_ludivic_cesbron' then 
                    has_ludivic = true 
                    break 
                end
            end
        end

        if context.setting_blind and not context.blueprint then
            if has_ludivic then
                return { message = "Bloqué !", colour = G.C.RED, card = card }
            end

            local other_prof_count = 0
            for _, j in ipairs(G.jokers.cards) do
                if j ~= card and j.config.center.pools and j.config.center.pools["PROF"] then
                    other_prof_count = other_prof_count + 1
                end
            end

            if other_prof_count == 0 then
                card.ability.extra.xmult = (card.ability.extra.xmult or 1) + 1
                return { message = "+1 Xmult", colour = G.C.MULT, card = card }
            else
                card.ability.extra.xmult = math.max(0, (card.ability.extra.xmult or 1) - 1)
                return { message = "-1 Xmult", colour = G.C.RED, card = card }
            end
        end

        if context.joker_main then
            local xm = has_ludivic and 0 or (card.ability.extra.xmult or 1)
            return { message = "X" .. xm, Xmult_mod = xm, colour = G.C.MULT }
        end
    end
}

SMODS.Joker {
    key = 'romuald',
    loc_txt = {
        name = 'Romuald',
        text = {
            "Si une carte {C:attention}bruyante{} est jouée :",
            "Romuald est détruit",
            "Timer : {C:attention}#1#{} manches restantes",
            "Si le timer atteint 0 le maloc crash ",
            "Allouez de la mémoire en détruisant ds cartes !",
            "{X:mult,C:white}+0.2{} Xmult par carte défaussée cette manche",
            "{C:inactive}(Actuellement {X:mult,C:white}X#2#{C:inactive})"
        }
    },
    config = { extra = { timer = 3, xmult = 1, gain = 0.2 } },
    blueprint_compat = false,
    eternal_compat = false,
    perishable_compat = true,
    pools = { ["PROF"] = true, ["INFO"] = true, ["LOB"] = true },
    rarity = 3,
    atlas = 'LOB',
    pos = { x = 2, y = 5 },
    soul_pos = { x = 3, y = 5 },
    cost = 10,

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.timer, card.ability.extra.xmult } }
    end,
    calculate = function(self, card, context)
        if context.discard and not context.blueprint then
            card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.gain
            return { message = "+" .. card.ability.extra.gain .. " Xmult", colour = G.C.RED }
        end

        if context.lob_card_destroyed and not context.blueprint then
            card.ability.extra.timer = 3
            return { message = "Mémoire allouée !", colour = G.C.GREEN, card = card }
        end

        if context.individual and context.cardarea == G.play then
            if context.other_card.config.center_key == 'm_lob_noisy' then
                G.E_MANAGER:add_event(Event({func = function() 
                    card:start_dissolve(); return true 
                end}))
                return { message = "Ragequit !" }
            end
        end

        if context.end_of_round and not context.blueprint and not (context.individual or context.repetition) then
            card.ability.extra.timer = card.ability.extra.timer - 1
            card.ability.extra.xmult = 1
            if card.ability.extra.timer <= 0 then error("Vous n'avez pas maloc...") end
            return { message = "Timer : "..card.ability.extra.timer }
        end

        if context.joker_main then
            return { message = "X" .. card.ability.extra.xmult, Xmult_mod = card.ability.extra.xmult }
        end
    end
}

SMODS.Joker {
    key = 'mohamed_adache',
    loc_txt = {
        name = 'Mohamed Adache',
        text = {
            "Au début de chaque manche :",
            "génère une carte {C:tarot}Weed{} {C:dark_edition}négative{}"
        }
    },
    config = { extra = {} },
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    pools = { ["PROF"] = true, ["INFO"] = true, ["LOB"] = true },
    rarity = 3,
    atlas = 'LOB',
    pos = { x = 2, y = 6 },
    soul_pos = { x = 3, y = 6 },
    cost = 10,

    calculate = function(self, card, context)
        if context.first_hand_drawn and not context.blueprint then
            
            local card_key = 'c_lob_weed'

            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.4,
                func = function()
                    if G.P_CENTERS[card_key] then
                        local weed_card = create_card('Tarot', G.consumeables, nil, nil, nil, nil, card_key, 'c_lob_weed')
                        
                        weed_card:set_edition({negative = true}, true)
                        weed_card:add_to_deck()
                        G.consumeables:emplace(weed_card)
                        
                        card_eval_status_text(card, 'extra', nil, nil, nil, { message = "Smoking" })
                    else
                        card_eval_status_text(card, 'extra', nil, nil, nil, { message = "No Weed found!" })
                    end
                    return true
                end
            }))
        end
    end
}

SMODS.Joker {
    key = 'radjesvarane',
    loc_txt = {
        name = 'Radjesvarane',
        text = {
            "{C:attention}+#1#{} emplacement Joker par",
            "joker {C:attention}Professeur{} possédé",
            "{C:inactive}(Bonus actuel: {C:attention}+#2# {C:inactive}emplacements)"
        }
    },
    config = { extra = { slot_bonus = 1, current_bonus = 0 } },
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    pools = { ["PROF"] = true, ["INFO"] = true, ["LOB"] = true },
    rarity = 3,
    atlas = 'LOB',
    pos = { x = 2, y = 4 },
    soul_pos = { x = 3, y = 4 },
    cost = 10,

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.slot_bonus, card.ability.extra.current_bonus or 0 } }
    end,

    update = function(self, card, dt)
        if G.jokers and G.jokers.cards then
            local count = 0
            for _, j in ipairs(G.jokers.cards) do
                if j.config.center.pools and j.config.center.pools["PROF"] then
                    count = count + card.ability.extra.slot_bonus
                end
            end
            
            local current = card.ability.extra.current_bonus or 0
            if current ~= count then
                local diff = count - current
                G.jokers.config.card_limit = G.jokers.config.card_limit + diff
                card.ability.extra.current_bonus = count
            end
        end
    end,

    remove_from_deck = function(self, card, from_debuff)
        if card.ability.extra.current_bonus then
            G.jokers.config.card_limit = G.jokers.config.card_limit - card.ability.extra.current_bonus
            card.ability.extra.current_bonus = 0
        end
    end
}

SMODS.Joker {
    key = 'haktar',
    loc_txt = {
        name = 'Aktar',
        text = {
            "{C:inactive}Actuellement{} {X:mult,C:white}X#1#{}",
            "{X:mult,C:white}X+#2#{} pour chaque {C:tarot}Taco{} utilisé",
            "{X:mult,C:white}X+#3#{} pour chaque {C:tarot}Taco{} détenu"
        }
    },

    config = { extra = { taco_used = 0, mult_used = 1, mult_held = 3 } },

    rarity = 3,
    atlas = 'LOB',
    pos = { x = 2, y = 3 },
    soul_pos = { x = 3, y = 3 },
    cost = 10,
    blueprint_compat = true,

    loc_vars = function(self, info_queue, card)
        local tacos_held = 0
        if G.consumeables then
            for k, v in ipairs(G.consumeables.cards) do
                if v.config.center.key == 'c_lob_taco' then tacos_held = tacos_held + 1 end
            end
        end
        
        local current_mult = 1 + (card.ability.extra.taco_used * card.ability.extra.mult_used) + (tacos_held * card.ability.extra.mult_held)
        
        return { vars = { current_mult, card.ability.extra.mult_used, card.ability.extra.mult_held } }
    end,

    calculate = function(self, card, context)
        if context.using_consumeable and not context.blueprint then
            if context.consumeable.config.center.key == 'c_lob_taco' then
                card.ability.extra.taco_used = card.ability.extra.taco_used + 1
                return {
                    card = card,
                    message = "Upgrade!"
                }
            end
        end

        if context.joker_main then
            local tacos_held = 0
            if G.consumeables then
                for k, v in ipairs(G.consumeables.cards) do
                    if v.config.center.key == 'c_lob_taco' then
                        tacos_held = tacos_held + 1
                    end
                end
            end

            local mult = 1 + (card.ability.extra.taco_used * card.ability.extra.mult_used) + (tacos_held * card.ability.extra.mult_held)

            if mult > 1 then
                return {
                    message = 'X' .. mult,
                    x_mult = mult
                }
            end
        end
    end
}

SMODS.Joker {
    key = 'boumiz',
    loc_txt = {
        name = 'Boumiz',
        text = {
            "{X:mult,C:white}X#1#{} Mult pour",
            "chaque Joker",
            "de type {C:attention}Physique{}"
        }
    },
    config = { extra = { xmult = 1.5 } },
    blueprint_compat = true,
    rarity = 3,
    atlas = 'LOB',
    pos = { x = 0, y = 5 },
    soul_pos = { x = 1, y = 5 },
    cost = 10,

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult } }
    end,

    calculate = function(self, card, context)
        if context.other_joker and context.other_joker.config.center.pools and context.other_joker.config.center.pools["PHYSIQUE"] then
            return {
                xmult = card.ability.extra.xmult,
                card = card
            }
        end
    end
}

SMODS.Joker {
    key = 'seigneur_boumiz',
    loc_txt = {
        name = 'Seigneur Boumiz',
        text = {
            "{X:mult,C:white}^#1#{} Mult pour chaque",
            "Joker de type {C:attention}Physique{}",
            "Les Jokers {C:attention}Physique{}",
            "se déclenchent {C:attention}une fois{} de plus"
        }
    },
    config = { extra = { xmult = 2.25 } },
    blueprint_compat = true,
    rarity = 4,
    atlas = 'LOB',
    pos = { x = 4, y = 0 },
    soul_pos = { x = 5, y = 0, extra = { x = 6, y = 0 } },
    cost = 20,

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult } }
    end,

    calculate = function(self, card, context)
        if context.other_joker and context.other_joker.config.center.pools and context.other_joker.config.center.pools["PHYSIQUE"] then
            return {
                xmult = card.ability.extra.xmult,
                card = card
            }
        end
    end
}

SMODS.Atlas {
	key = "jokerseleve",
	path = "jokerseleve.png",
	px = 71,
	py = 95
}

SMODS.Joker {
    key = 'lukas_soumi',
    loc_txt = {
        name = 'Lukas Soumi',
        text = {
            "Copie l'effet du Joker à sa {C:attention}gauche{}",
            "{C:red}ET{} l'effet du Joker à sa {C:attention}droite{}"
        }
    },
    blueprint_compat = true,
    pools = { ["LOB"] = true, ["LUKAS"] = true },
    rarity = 4,
    atlas = 'jokerseleve',
    pos = { x = 7, y = 0 },
    soul_pos = { x = 7, y = 1 },
    cost = 20,

    calculate = function(self, card, context)
        local my_pos = nil
        for i=1, #G.jokers.cards do if G.jokers.cards[i] == card then my_pos = i break end end
        
        local left = my_pos and my_pos > 1 and G.jokers.cards[my_pos - 1]
        local right = my_pos and my_pos < #G.jokers.cards and G.jokers.cards[my_pos + 1]

        local left_ret = left and SMODS.blueprint_effect(card, left, context)
        local right_ret = right and SMODS.blueprint_effect(card, right, context)

        if left_ret and right_ret then
            SMODS.calculate_effect(left_ret, left)
            return right_ret
        elseif left_ret then
            return left_ret
        elseif right_ret then
            return right_ret
        end
    end
}

SMODS.Joker {
    key = 'lukas_fou',
    loc_txt = {
        name = 'Lukas Fou',
        text = {
            "Gagne {X:mult,C:white}X0.1{} Mult et {X:chips,C:white}X0.1{} Jetons",
            "pour chaque {C:attention}carte jouée{}",
            "{C:inactive}(Actuellement {X:mult,C:white}X#1#{C:inactive} Mult et {X:chips,C:white}X#2#{C:inactive} Jetons)"
        }
    },
    config = { extra = { xmult = 1, xchips = 1, gain = 0.1 } },
    blueprint_compat = true,
    pools = { ["LOB"] = true, ["LUKAS"] = true },
    rarity = 4,
    atlas = 'jokerseleve',
    pos = { x = 4, y = 0 },
    soul_pos = { x = 4, y = 1 },
    cost = 20,

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult, card.ability.extra.xchips } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.gain
            card.ability.extra.xchips = card.ability.extra.xchips + card.ability.extra.gain
            return { message = "Folie!", colour = G.C.PURPLE }
        end

        if context.joker_main then
            return {
                message = "X" .. string.format("%.1f", card.ability.extra.xmult),
                Xmult_mod = card.ability.extra.xmult,
                x_chips = card.ability.extra.xchips
            }
        end
    end
}

SMODS.Joker {
    key = 'lukas_grenouille',
    loc_txt = {
        name = 'Lukas Grenouille',
        text = {
            "Au début de la manche, détruit",
            "tous vos {C:attention}consommables{} et gagne",
            "un {C:attention}Tag{} aléatoire pour chacun"
        }
    },
    pools = { ["LOB"] = true, ["LUKAS"] = true },
    rarity = 4,
    atlas = 'jokerseleve',
    pos = { x = 9, y = 0 },
    soul_pos = { x = 9, y = 1 },
    cost = 20,

    calculate = function(self, card, context)
        if context.first_hand_drawn and not context.blueprint then
            local count = #G.consumeables.cards
            if count > 0 then
                for i = count, 1, -1 do
                    G.consumeables.cards[i]:start_dissolve()
                end
                
                for i = 1, count do
                    add_tag(Tag(get_next_tag_key('lukas_grenouille')))
                end
                return { message = "+"..count.." Tags !", colour = G.C.GREEN }
            end
        end
    end
}

SMODS.Joker {
    key = 'lukas_sorciere',
    loc_txt = {
        name = 'Lukas Sorcière',
        text = {
            "Les cartes {C:attention}Wild{} jouées reçoivent",
            "un {C:dark_edition}Dark Seal{}. Les cartes avec un",
            "{C:dark_edition}Dark Seal{} jouées reçoivent un Sceau et",
            "une Édition {C:attention}aléatoires{}."
        }
    },
    pools = { ["LOB"] = true, ["LUKAS"] = true },
    rarity = 4,
    atlas = 'jokerseleve',
    pos = { x = 6, y = 0 },
    soul_pos = { x = 6, y = 1 },
    cost = 20,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            local c = context.other_card
            
            if c.config.center.key == 'm_wild' and c.seal ~= 'lob_dark' then
                c:set_seal('lob_dark', true)
                return { message = "Malédiction !", colour = G.C.PURPLE, card = card }
            
            elseif c.seal == 'lob_dark' then
                local seals = {'Red', 'Blue', 'Gold', 'Purple'}
                c:set_seal(seals[math.random(#seals)], true)
                c:set_edition(poll_edition('sorciere', nil, true, true), true)
                return { message = "Chaos !", colour = G.C.DARK_EDITION, card = card }
            end
        end
    end
}

SMODS.Joker {
    key = 'lukas_militaire',
    loc_txt = {
        name = 'Lukas Militaire',
        text = {
            "Gagne {X:chips,C:white}X1{} Jetons",
            "quand une carte {C:attention}non-Figure{}",
            "est {C:red}détruite{}",
            "{C:inactive}(Actuellement {X:chips,C:white}X#1#{C:inactive} Jetons)"
        }
    },
    config = { extra = { xchips = 1, gain = 1 } },
    blueprint_compat = true,
    pools = { ["LOB"] = true, ["LUKAS"] = true },
    rarity = 4,
    atlas = 'jokerseleve',
    pos = { x = 8, y = 0 },
    soul_pos = { x = 8, y = 1 },
    cost = 20,

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xchips } }
    end,

    calculate = function(self, card, context)
        if context.cards_destroyed and not context.blueprint then
            local gained = false
            for _, c in ipairs(context.cards_destroyed) do
                if c.base and not c:is_face() then
                    card.ability.extra.xchips = card.ability.extra.xchips + card.ability.extra.gain
                    gained = true
                end
            end
            if gained then return { message = "X"..card.ability.extra.xchips.." Chips", colour = G.C.CHIPS } end
        end

        if context.joker_main then
            return { x_chips = card.ability.extra.xchips, message = "X"..card.ability.extra.xchips.." Chips" }
        end
    end
}

SMODS.Joker {
    key = 'lukas_fatigue',
    loc_txt = {
        name = 'Lukas Fatigué',
        text = {
            "Toutes les {C:attention}Figures{} jouées",
            "sont {C:red}désactivées{}. Donne {X:mult,C:white}X3{} Mult",
            "pour chaque carte désactivée",
            "{C:inactive}(Bonus prévu : {X:mult,C:white}X#1#{C:inactive} Mult)"
        }
    },
    config = { extra = { disabled_count = 0 } },
    blueprint_compat = true,
    pools = { ["LOB"] = true, ["LUKAS"] = true },
    rarity = 4,
    atlas = 'jokerseleve',
    pos = { x = 3, y = 0 },
    soul_pos = { x = 3, y = 1 },
    cost = 20,

    loc_vars = function(self, info_queue, card)
        local faces_selected = 0
        if G.hand and G.hand.highlighted then
            for _, c in ipairs(G.hand.highlighted) do
                if c:is_face() then faces_selected = faces_selected + 1 end
            end
        end
        local current_mult = faces_selected > 0 and (faces_selected * 3) or 1
        return { vars = { current_mult } }
    end,

    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            local count = 0
            for _, c in ipairs(context.full_hand) do
                if c:is_face() then
                    c.lob_fatigue_debuff = true
                    c:set_debuff(true)
                    c:juice_up()
                    count = count + 1
                end
            end
            card.ability.extra.disabled_count = count
            if count > 0 then return { message = "Zzz...", colour = G.C.RED } end
        end

        if context.joker_main and card.ability.extra.disabled_count > 0 then
            local xmult = card.ability.extra.disabled_count * 3
            return { Xmult_mod = xmult, message = "X"..xmult, colour = G.C.MULT }
        end

        if context.after and not context.blueprint then
            for _, c in ipairs(context.full_hand) do
                if c.lob_fatigue_debuff then
                    c.lob_fatigue_debuff = false
                    c:set_debuff(false)
                end
            end
            card.ability.extra.disabled_count = 0
        end
    end
}

SMODS.Joker {
    key = 'lukas_clown',
    loc_txt = {
        name = 'Lukas Clown',
        text = {
            "Gagne {X:mult,C:white}X0.2{} Mult",
            "pour chaque {C:attention}Joker vendu{}",
            "{C:inactive}(Actuellement {X:mult,C:white}X#1#{C:inactive} Mult)"
        }
    },
    config = { extra = { xmult = 1, gain = 0.2 } },
    blueprint_compat = true,
    pools = { ["LOB"] = true, ["LUKAS"] = true },
    rarity = 4,
    atlas = 'jokerseleve',
    pos = { x = 5, y = 0 },
    soul_pos = { x = 5, y = 1 },
    cost = 20,

    loc_vars = function(self, info_queue, card)
        return { vars = { string.format("%.1f", card.ability.extra.xmult) } }
    end,

    calculate = function(self, card, context)
        if context.selling_card and context.card.ability.set == 'Joker' and not context.blueprint then
            card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.gain
            return { message = "X"..string.format("%.1f", card.ability.extra.xmult), colour = G.C.MULT }
        end

        if context.joker_main then
            return { Xmult_mod = card.ability.extra.xmult, message = "X"..string.format("%.1f", card.ability.extra.xmult) }
        end
    end
}

SMODS.Joker {
    key = 'lukas_scientifique',
    loc_txt = {
        name = 'Lukas Scientifique',
        text = {
            "Choisit une amélioration au hasard.",
            "Les cartes jouées ayant cette",
            "amélioration donnent {X:mult,C:white}X3{} Mult.",
            "{C:inactive}(Cible actuelle : {C:attention}#1#{C:inactive})"
        }
    },
    config = { extra = { target = 'm_mult' } },
    blueprint_compat = true,
    pools = { ["LOB"] = true, ["LUKAS"] = true },
    rarity = 4,
    atlas = 'jokerseleve',
    pos = { x = 2, y = 0 },
    soul_pos = { x = 2, y = 1 },
    cost = 20,

    set_ability = function(self, card, initial, delay_sprites)
        if initial then
            local valid = {}
            for k, v in pairs(G.P_CENTERS) do
                if v.set == 'Enhancement' then table.insert(valid, k) end
            end
            if #valid > 0 then
                card.ability.extra.target = pseudorandom_element(valid, pseudoseed('lukas_sci_init'))
            else
                card.ability.extra.target = 'm_mult'
            end
        end
    end,

    loc_vars = function(self, info_queue, card)
        local t = card.ability.extra.target or 'm_mult'
        
        if G.P_CENTERS[t] then
            table.insert(info_queue, G.P_CENTERS[t])
        end

        local target_name = (G.localization.descriptions.Enhanced[t] and G.localization.descriptions.Enhanced[t].name) 
                            or (G.P_CENTERS[t] and G.P_CENTERS[t].label) 
                            or t
        return { vars = { target_name } }
    end,

    calculate = function(self, card, context)
        if context.end_of_round and not context.repetition and not context.individual and not context.blueprint then
            local valid_enhancements = {}
            for k, v in pairs(G.P_CENTERS) do
                if v.set == 'Enhancement' and k ~= card.ability.extra.target then 
                    table.insert(valid_enhancements, k) 
                end
            end
            if #valid_enhancements > 0 then
                card.ability.extra.target = pseudorandom_element(valid_enhancements, pseudoseed('lukas_sci_round'))
            end
            return { message = "Eurêka !", colour = G.C.GREEN, card = card }
        end

        if context.individual and context.cardarea == G.play then
            if context.other_card.config.center.key == card.ability.extra.target then
                return {
                    x_mult = 3,
                    card = context.other_card,
                    colour = G.C.MULT
                }
            end
        end
    end
}

SMODS.Joker {
    key = 'lukas_plage',
    loc_txt = {
        name = 'Lukas Plage',
        text = {
            "Chaque carte tenue en {C:attention}main{}",
            "donne {X:mult,C:white}X1.5{} Mult"
        }
    },
    blueprint_compat = true,
    pools = { ["LOB"] = true, ["LUKAS"] = true },
    rarity = 4,
    atlas = 'jokerseleve',
    pos = { x = 1, y = 0 },
    soul_pos = { x = 1, y = 1 },
    cost = 20,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.hand and not context.end_of_round and not context.repetition then
            return {
                x_mult = 1.5,
                card = context.other_card,
                colour = G.C.MULT
            }
        end
    end
}

SMODS.Joker {
    key = 'lukas_giga_chad',
    loc_txt = {
        name = 'Lukas Giga Chad',
        text = {
            "{C:legendary}+5{} Taille de main, {C:legendary}+3{} Jokers",
            "{C:legendary}+2{} Consommables",
            "{C:legendary}+1{} case au Shop, {C:legendary}+1{} Booster au Shop"
        }
    },
    blueprint_compat = false,
    pools = { ["LOB"] = true, ["LUKAS"] = true },
    rarity = 4,
    atlas = 'jokerseleve',
    pos = { x = 0, y = 0 },
    soul_pos = { x = 0, y = 1 },
    cost = 20,

    add_to_deck = function(self, card, from_debuff)
        G.hand:change_size(5)
        G.jokers.config.card_limit = (G.jokers.config.card_limit or 5) + 3
        G.consumeables.config.card_limit = (G.consumeables.config.card_limit or 2) + 2
        G.GAME.shop.joker_max = (G.GAME.shop.joker_max or 2) + 1
        G.GAME.modifiers.booster_packs = (G.GAME.modifiers.booster_packs or 2) + 1
    end,

    remove_from_deck = function(self, card, from_debuff)
        G.hand:change_size(-5)
        G.jokers.config.card_limit = math.max(1, (G.jokers.config.card_limit or 8) - 3)
        G.consumeables.config.card_limit = math.max(1, (G.consumeables.config.card_limit or 4) - 2)
        G.GAME.shop.joker_max = math.max(2, (G.GAME.shop.joker_max or 3) - 1)
        G.GAME.modifiers.booster_packs = math.max(1, (G.GAME.modifiers.booster_packs or 3) - 1)
    end
}

SMODS.Joker {
    key = 'lukas',

    loc_txt = {
        name = 'Lukas',
        text = {
            "Crée un {C:spectral}Rituel de Lukas{}",
            "quand ce Joker est {C:red}vendu{}"
        }
    },

    config = { extra = { mult = 5, chips = 10 } },

    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,

    pools = { ["LOB"] = true, ["ELEVE"] = true },

    rarity = 2,
    atlas = 'jokerseleve',
    pos = { x = 0, y = 2 },
    soul_pos = { x = 0, y = 3 },
    cost = 7,

    loc_vars = function(self, info_queue, card)
        return { vars = {} }
    end,

    calculate = function(self, card, context)

        if context.selling_self then
            SMODS.add_card{
                set = "Consumeables",
                key = "c_lob_rituel_lukas"
            }
        end
    end
}

SMODS.Joker {
    key = 'zozan',

    loc_txt = {
        name = 'Zozan',
        text = {
            "Au début de la manche",
            "crée {C:tarot}1 Taco{}",
            "+1 {C:dark_edition}Taco Négatif{}",
            "par {C:attention}Élève{}"
        }
    },

    config = { extra = { } },

    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,

    pools = { ["LOB"] = true, ["ELEVE"] = true },

    rarity = 2,
    atlas = 'jokerseleve',
    pos = { x = 1, y = 2 },
    soul_pos = { x = 1, y = 3 },
    cost = 6,

    loc_vars = function(self, info_queue, card)
        return { vars = {} }
    end,

    calculate = function(self, card, context)

        if context.setting_blind then

            SMODS.add_card{ set = "Consumeables", key = "c_lob_taco" }

            local eleves = 0
            for i,v in ipairs(G.jokers.cards) do
                if v.config.center.pools and v.config.center.pools["ELEVE"] then
                    eleves = eleves + 1
                end
            end

            for i = 1, eleves do
                SMODS.add_card{
                    set = "Consumeables",
                    key = "c_lob_taco",
                    edition = "e_negative"
                }
            end
        end
    end
}

SMODS.Joker {
    key = 'modpack',
    loc_txt = {
        name = 'Modpack',
        text = {
            "Détruit les Jokers {C:attention}Minecraft{}",
            "au début de la manche",
            "Gagne {X:chips,C:white} X#1# {} Jetons",
            "par Joker détruit",
            "{C:inactive}(Actuellement X#2#)"
        }
    },
    config = { extra = { xchips = 1, gain = 1 } },
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    pools = { ["LOB"] = true, ["ELEVE"] = true, ["MINECRAFT"] = true },
    rarity = 2,
    atlas = 'jokerseleve',
    pos = { x = 2, y = 2 },
    soul_pos = { x = 2, y = 3 },
    cost = 7,

    loc_vars = function(self, info_queue, card)
        return { vars = {
            card.ability.extra.gain,
            card.ability.extra.xchips
        }}
    end,

    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            local destroyed = false
            for i = #G.jokers.cards, 1, -1 do
                local j = G.jokers.cards[i]
                if j ~= card and j.config.center.pools and j.config.center.pools["MINECRAFT"] and not j.ability.eternal then
                    j:start_dissolve()
                    card.ability.extra.xchips = card.ability.extra.xchips + card.ability.extra.gain
                    destroyed = true
                end
            end
            
            if destroyed then
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = 'Nettoyage!', colour = G.C.RED})
                card:juice_up(0.5, 0.5)
            end
        end

        if context.joker_main then
            return {
                x_chips = card.ability.extra.xchips,
                message = "X" .. card.ability.extra.xchips,
                colour = G.C.CHIPS
            }
        end
    end
}

SMODS.Joker {
    key = 'github',

    loc_txt = {
        name = 'GitHub',
        text = {
            "Donne {C:money}+#1#${}",
            "par Joker {C:attention}INFO{}",
            "possédé (hors lui-même)",
            "{C:inactive}(Actuellement +#2#$)"
        }
    },

    config = { extra = { money = 10 } },

    rarity = 2,
    atlas = 'jokerseleve',
    pos = { x = 3, y = 2 },
    soul_pos = { x = 3, y = 3 },
    cost = 5,

    pools = { ["LOB"] = true, ["ELEVE"] = true, ["INFO"] = true },

    loc_vars = function(self, info_queue, card)
        local infos_count = 0
        for _, v in ipairs(G.jokers.cards) do
            if v ~= card and v.config.center.pools and v.config.center.pools["INFO"] then
                infos_count = infos_count + 1
            end
        end
        return { vars = { card.ability.extra.money, infos_count * card.ability.extra.money } }
    end,

    calculate = function(self, card, context)
        if context.end_of_round and not context.individual and not context.repetition then
            local infos_count = 0

            for i, v in ipairs(G.jokers.cards) do
                if v ~= card and v.config.center.pools and v.config.center.pools["INFO"] then
                    infos_count = infos_count + 1
                end
            end

            if infos_count > 0 then
                local total_money = infos_count * card.ability.extra.money

                return {
                    message = "GitHub: +" .. total_money .. "$",
                    dollars = total_money,
                    colour = G.C.MONEY
                }
            end
        end
    end
}

SMODS.Joker {
    key = 'yanis',
    loc_txt = {
        name = 'Yanis',
        text = {
            "À la fin de la manche,",
            "{C:red}détruit{} toutes les cartes en",
            "{C:attention}main{} et {C:red}s'autodétruit{}"
        }
    },
    rarity = 2,
    atlas = 'jokerseleve',
    pos = { x = 4, y = 2 },
    soul_pos = { x = 4, y = 3 },
    cost = 6,
    pools = { ["LOB"] = true, ["ELEVE"] = true },
    loc_vars = function(self, info_queue, card) return { vars = {} } end,

    calculate = function(self, card, context)
        if context.end_of_round and not context.blueprint then
            for i,v in ipairs(G.hand.cards) do
                v:start_dissolve()
            end

            play_sound('lob_snd_explosion') 
            local x_pos = card.T.x * (love.graphics.getWidth()/G.ROOM.T.w) + (card.T.w/2)
            local y_pos = card.T.y * (love.graphics.getHeight()/G.ROOM.T.h) + (card.T.h/2)
            add_lob_effect("explosion", x_pos, y_pos)

            card:start_dissolve()
        end
    end
}

SMODS.Joker {
    key = 'pixel',

    loc_txt = {
        name = 'Pixel',
        text = {
            "{X:mult,C:white}X#1#{} Mult",
            "contre les {C:red}Boss Blind{}"
        }
    },

    rarity = 2,
    atlas = 'jokerseleve',
    pos = { x = 5, y = 2 },
    soul_pos = { x = 5, y = 3 },
    cost = 6,

    pools = { ["LOB"] = true, ["ELEVE"] = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { 5 } }
    end,

    calculate = function(self, card, context)

        if context.joker_main and G.GAME.blind.boss then
            return {
                x_mult_mod = 5
            }
        end
    end
}

SMODS.Joker {
    key = 'lucien',

    loc_txt = {
        name = 'Lucien',
        text = {
            "Les cartes {C:attention}Wild{} jouées",
            "reçoivent un {C:dark_edition}Dark Seal{}"
        }
    },

    rarity = 2,
    atlas = 'jokerseleve',
    pos = { x = 6, y = 2 },
    soul_pos = { x = 6, y = 3 },
    cost = 7,

    pools = { ["LOB"] = true, ["ELEVE"] = true },

    loc_vars = function(self, info_queue, card)
        return { vars = {} }
    end,

    calculate = function(self, card, context)

        if context.individual and context.cardarea == G.play then

            if context.other_card.config.center.key == "m_wild" then
                context.other_card:set_seal("lob_dark")
            end
        end
    end
}

SMODS.Joker {
    key = 'mansour',
    loc_txt = {
        name = 'Mansour',
        text = {
            "Gagne {X:mult,C:white}X#2#{} Mult lorsqu'un",
            "Joker {C:attention}Exercice{} est vendu",
            "{C:inactive}(Actuellement {}{X:mult,C:white}X#1#{}{C:inactive} Mult{}",
        }
    },
    config = { extra = { xmult = 1, gain = 0.25 } },
    rarity = 2,
    atlas = 'jokerseleve',
    pos = { x = 7, y = 2 },
    soul_pos = { x = 7, y = 3 },
    cost = 4,
    pools = { ["LOB"] = true, ["ELEVE"] = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult, card.ability.extra.gain } }
    end,

    calculate = function(self, card, context)
        if context.selling_card and not context.blueprint then
            if context.card.config.center.pools and context.card.config.center.pools["EXERCISE"] then
                card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.gain
                return { message = "Corrigé !", colour = G.C.MULT }
            end
        end

        if context.joker_main then
            if card.ability.extra.xmult > 1 then
                return { 
                    Xmult_mod = card.ability.extra.xmult, 
                    message = "X"..card.ability.extra.xmult 
                }
            end
        end
    end
}

SMODS.Joker {
    key = 'axel',
    loc_txt = {
        name = 'Axel',
        text = {
            "Les cartes {C:attention}Bruyantes{} ou {C:attention}Silencieuses{} jouées",
            "donnent {C:money}+#1#${}, {C:attention}Figures{} donnent {C:money}+#2#${}"
        }
    },
    config = { extra = { money_normal = 3, money_face = 5 } },
    rarity = 2,
    atlas = 'jokerseleve',
    pos = { x = 8, y = 2 },
    soul_pos = { x = 8, y = 3 },
    cost = 6,

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.money_normal, card.ability.extra.money_face } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local c = context.other_card
            local is_noisy = (c.config.center == G.P_CENTERS.m_lob_noisy)
            local is_silent = (c.config.center == G.P_CENTERS.m_lob_silent)

            if is_noisy or is_silent then
                local payout = c:is_face() and card.ability.extra.money_face or card.ability.extra.money_normal
                return {
                    dollars = payout,
                    card = card
                }
            end
        end
    end
}

SMODS.Joker {
    key = 'matteo',

    loc_txt = {
        name = 'Matteo',
        text = {
            "Gagne {C:mult}+#1#{} Mult",
            "par carte jouée",
            "sans {C:attention}Enhancement{}",
            "{C:inactive}(Actuellement +#2# Mult)"
        }
    },

    config = { extra = { mult = 0, gain = 2 } },

    rarity = 2,
    atlas = 'jokerseleve',
    pos = { x = 9, y = 2 },
    soul_pos = { x = 9, y = 3 },
    cost = 7,

    pools = { ["LOB"] = true, ["ELEVE"] = true },

    loc_vars = function(self, info_queue, card)
        return { vars = {
            card.ability.extra.gain,
            card.ability.extra.mult
        }}
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card.config.center == G.P_CENTERS.c_base then
                card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.gain
                return {
                    extra = { focus = card, message = "@Lucien Foyer @Axel boite à gant ça mange ou ce midi ??" },
                    card = card
                }
            end
        end

        if context.joker_main then
            return { mult_mod = card.ability.extra.mult }
        end
    end
}


for k,v in pairs(G.P_CENTERS) do
    if v.set == "Joker" then
        v.discovered = true
        v.unlocked = true
    end
end