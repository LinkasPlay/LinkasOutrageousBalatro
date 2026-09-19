SMODS.Atlas {
	key = "jokers_common",
	path = "jokerseleve.png",
	px = 71,
	py = 95
}


SMODS.Sound({key = "lob_snd_explosion", path = "snd_explosion.ogg",})

SMODS.Joker {
    key = 'fonction_derivee',
    loc_txt = {
        name = 'Fonction Dérivée',
        text = {
            "Gagne {C:mult}+#1#{} Mult pour chaque",
            "main jouée ce round.",
            "{C:inactive}(Actuellement {C:mult}+#2#{C:inactive} Mult)"
        }
    },
    config = { extra = { mult_per_hand = 5 } },
    blueprint_compat = true,
    pools = { ["LOB"] = true, ["EXERCISE"] = true, ["MATH"] = true },
    rarity = 1,
    atlas = 'jokers_common',
    pos = { x = 0, y = 10 },
    cost = 4,

    loc_vars = function(self, info_queue, card)
        local hands_played = (G.GAME and G.GAME.current_round and G.GAME.current_round.hands_played) or 0
        local current_mult = (hands_played + 1) * card.ability.extra.mult_per_hand
        return { vars = { card.ability.extra.mult_per_hand, current_mult } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local hands_played = (G.GAME and G.GAME.current_round and G.GAME.current_round.hands_played) or 0
            local total_mult = (hands_played + 1) * card.ability.extra.mult_per_hand
            
            return {
                mult_mod = total_mult,
                message = "+" .. total_mult,
                colour = G.C.MULT
            }
        end
    end
}

SMODS.Joker {
    key = 'lipschitzienne',
    loc_txt = {
        name = 'Application Lipschitzienne',
        text = {
            "Gagne {C:mult}+#1#{} Mult si",
            "la main jouée est",
            "de {C:attention}Niveau 1{}."
        }
    },
    config = { extra = { mult = 20 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult } }
    end,
    blueprint_compat = true,
    pools = { ["LOB"] = true, ["EXERCISE"] = true },
    rarity = 1,
    atlas = 'jokers_common',
    pos = { x = 1, y = 10 },
    cost = 3,
    calculate = function(self, card, context)
        if context.joker_main then
            if G.GAME.hands[context.scoring_name].level == 1 then
                return {
                    mult_mod = card.ability.extra.mult,
                    message = "+" .. card.ability.extra.mult,
                    colour = G.C.MULT
                }
            end
        end
    end
}

SMODS.Joker {
    key = 'pivot_de_gauss',
    loc_txt = {
        name = 'Pivot de Gauss',
        text = {
            "Inverse vos {C:blue}Jetons{} et",
            "votre {C:red}Mult{} lors du",
            "calcul du score final."
        }
    },
    blueprint_compat = true,
    pools = { ["LOB"] = true, ["EXERCISE"] = true, ["MATH"] = true },
    rarity = 2,
    atlas = 'jokers_common',
    pos = { x = 2, y = 10 },
    cost = 6,

    calculate = function(self, card, context)
        if context.joker_main then
            local temp_chips = hand_chips or 0
            local temp_mult = mult or 0
            
            hand_chips = temp_mult
            mult = temp_chips

            update_hand_text({delay = 0}, {mult = mult, chips = hand_chips})

            return {
                message = "Pivot !",
                colour = G.C.ORANGE
            }
        end
    end
}

SMODS.Joker {
    key = 'cauchy',
    loc_txt = {
        name = 'Cauchy',
        text = {
            "Gagne {C:mult}+#1#{} Mult si la main",
            "jouée est la même que la précédente.",
            "{C:inactive}(Actuellement {C:mult}+#2#{C:inactive} Mult, précédente : #3#)"
        }
    },
    config = { extra = { gain = 2, mult = 0, previous_hand = nil } },
    blueprint_compat = true,
    pools = { ["LOB"] = true, ["EXERCISE"] = true, ["MATH"] = true },
    rarity = 1,
    atlas = 'jokers_common',
    pos = { x = 3, y = 10 },
    cost = 4,

    loc_vars = function(self, info_queue, card)
        local prev_name = card.ability.extra.previous_hand and localize(card.ability.extra.previous_hand, 'poker_hands') or "Aucune"
        return { vars = { card.ability.extra.gain, card.ability.extra.mult, prev_name } }
    end,

    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            if card.ability.extra.previous_hand and card.ability.extra.previous_hand == context.scoring_name then
                card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.gain
                return {
                    message = "Convergence !",
                    colour = G.C.MULT
                }
            end
        end

        if context.joker_main and card.ability.extra.mult > 0 then
            return {
                mult_mod = card.ability.extra.mult,
                message = "+" .. card.ability.extra.mult
            }
        end

        if context.after and not context.blueprint then
            card.ability.extra.previous_hand = context.scoring_name
        end
    end
}

SMODS.Joker {
    key = 'pythagore',
    loc_txt = {
        name = 'Pythagore',
        text = {
            "Si la main jouée contient un {C:attention}Brelan{},",
            "gagne {C:chips}+#1#{} Jetons et {C:mult}+#2#{} Mult.",
            "{C:inactive}(Actuellement {C:chips}+#3#{C:inactive} Jetons et {C:mult}+#4#{C:inactive} Mult)"
        }
    },
    config = { extra = { chip_gain = 2, mult_gain = 2, chips = 0, mult = 0 } },
    blueprint_compat = true,
    pools = { ["LOB"] = true, ["EXERCISE"] = true, ["MATH"] = true },
    rarity = 1,
    atlas = 'jokers_common',
    pos = { x = 4, y = 10 },
    cost = 4,

    loc_vars = function(self, info_queue, card)
        return { vars = {
            card.ability.extra.chip_gain, card.ability.extra.mult_gain,
            card.ability.extra.chips, card.ability.extra.mult
        }}
    end,

    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            if context.poker_hands and context.poker_hands['Three of a Kind'] and next(context.poker_hands['Three of a Kind']) then
                card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_gain
                card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_gain
                return {
                    message = "a²+b²=c² !",
                    colour = G.C.GREEN
                }
            end
        end

        if context.joker_main then
            if card.ability.extra.chips > 0 or card.ability.extra.mult > 0 then
                return {
                    chip_mod = card.ability.extra.chips,
                    mult_mod = card.ability.extra.mult,
                    message = "Pythagore"
                }
            end
        end
    end
}

SMODS.Joker {
    key = 'nature',
    loc_txt = {
        name = 'Nature des Séries',
        text = {
            "Les cartes de valeur {C:attention}Première{}",
            "(2, 3, 5, 7) donnent {C:chips}+#1#{} Jetons",
            "et {C:mult}+#2#{} Mult lorsqu'elles sont jouées."
        }
    },
    config = { extra = { chips = 10, mult = 4 } },
    blueprint_compat = true,
    pools = { ["LOB"] = true, ["EXERCISE"] = true, ["MATH"] = true },
    rarity = 1,
    atlas = 'jokers_common',
    pos = { x = 5, y = 10 },
    cost = 4,

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips, card.ability.extra.mult } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local id = context.other_card.base.id
            if id == 2 or id == 3 or id == 5 or id == 7 then
                return {
                    chips = card.ability.extra.chips,
                    mult = card.ability.extra.mult,
                    card = card
                }
            end
        end
    end
}

SMODS.Joker {
    key = 'edp_dordr_2',
    loc_txt = {
        name = "EDP d'ordre 2",
        text = {
            "Gagne {C:chips}+#1#{} Jetons lorsqu'une",
            "carte de rang {C:attention}#2#{} est jouée.",
            "{C:inactive}(La cible change à chaque manche){}",
            "{C:inactive}(Actuellement {C:chips}+#3#{C:inactive} Jetons)"
        }
    },
    config = { extra = { chip_gain = 10, chips = 0, target_rank = '2' } },
    blueprint_compat = true,
    pools = { ["LOB"] = true, ["EXERCISE"] = true, ["MATH"] = true },
    rarity = 1,
    atlas = 'jokers_common',
    pos = { x = 6, y = 10 },
    cost = 4,

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chip_gain, card.ability.extra.target_rank, card.ability.extra.chips } }
    end,

    calculate = function(self, card, context)
        if context.first_hand_drawn and not context.blueprint then
            local ranks = {'2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King', 'Ace'}
            card.ability.extra.target_rank = ranks[math.random(#ranks)]
            return { message = "Nouvelle variable !" }
        end

        if context.individual and context.cardarea == G.play and not context.blueprint then
            if context.other_card.base.value == card.ability.extra.target_rank then
                card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_gain
                return { message = "Résolu !", colour = G.C.CHIPS }
            end
        end

        if context.joker_main and card.ability.extra.chips > 0 then
            return {
                chip_mod = card.ability.extra.chips,
                message = "+" .. card.ability.extra.chips
            }
        end
    end
}

SMODS.Joker {
    key = 'sigma',
    loc_txt = {
        name = 'Sigma',
        text = {
            "Fait la somme de la valeur nominale",
            "des cartes jouées.",
            "Donne {C:money}1${} tous les {C:attention}#1#{} points.",
            "{C:inactive}(Actuellement : {C:attention}#2#{C:inactive} points){}"
        }
    },
    config = { extra = { threshold = 6, points = 0 } },
    blueprint_compat = false,
    pools = { ["LOB"] = true, ["EXERCISE"] = true, ["MATH"] = true },
    rarity = 2,
    atlas = 'jokers_common',
    pos = { x = 7, y = 10 },
    cost = 6,

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.threshold, card.ability.extra.points } }
    end,

    calculate = function(self, card, context)
        if context.after and not context.blueprint then
            local sum = 0
            for _, c in ipairs(context.scoring_hand) do
                sum = sum + c.base.nominal
            end
            
            card.ability.extra.points = card.ability.extra.points + sum
            local dollars_earned = math.floor(card.ability.extra.points / card.ability.extra.threshold)
            
            if dollars_earned > 0 then
                card.ability.extra.points = card.ability.extra.points % card.ability.extra.threshold
                
                G.E_MANAGER:add_event(Event({
                    func = function()
                        ease_dollars(dollars_earned)
                        return true
                    end
                }))
                
                return {
                    message = "+$" .. dollars_earned,
                    colour = G.C.MONEY
                }
            end
        end
    end
}

SMODS.Joker {
    key = 'integrale', 
    loc_txt = { 
        name = 'Intégrale', 
        text = { 
            "Donne {X:mult,C:white}X1.05{} Mult pour", 
            "chaque {C:money}5${} que vous possédez.", 
            "{C:inactive}(Actuellement {X:mult,C:white}X#1#{C:inactive})" 
        } 
    },
    blueprint_compat = true, 
    pools = { ["LOB"] = true, ["EXERCISE"] = true, ["MATH"] = true },
    rarity = 2, 
    atlas = 'jokers_common', 
    pos = { x = 8, y = 10 }, 
    cost = 6,
    loc_vars = function(self, info_queue, card) 
        local dollars = LOB_plain_num((G.GAME and G.GAME.dollars) or 0)
        local xmult = 1 + math.floor(dollars / 5) * 0.05
        return { vars = { string.format("%.2f", xmult) } } 
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local dollars = LOB_plain_num((G.GAME and G.GAME.dollars) or 0)
            local xmult = 1 + math.floor(dollars / 5) * 0.05
            if xmult > 1 then 
                return { Xmult_mod = xmult, message = "X"..string.format("%.2f", xmult) } 
            end
        end
    end
}

SMODS.Joker {
    key = 'analyse_rn',
    loc_txt = {
        name = 'Analyse Rn',
        text = {
            "Les cartes {C:dark_edition}Noires{}",
            "donnent {X:mult,C:white}X#1#{} Mult.",
            "Les cartes {C:red}Rouges{}",
            "donnent {X:mult,C:white}X#2#{} Mult."
        }
    },
    config = { extra = { bad_mult = 0.5, good_mult = 1.5 } },
    blueprint_compat = true,
    pools = { ["LOB"] = true, ["EXERCISE"] = true, ["MATH"] = true },
    rarity = 2,
    atlas = 'jokers_common',
    pos = { x = 9, y = 10 },
    cost = 6,

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.bad_mult, card.ability.extra.good_mult } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:is_suit('Spades') or context.other_card:is_suit('Clubs') then
                return {
                    x_mult = card.ability.extra.bad_mult,
                    card = card,
                    colour = G.C.GREY
                }
            elseif context.other_card:is_suit('Hearts') or context.other_card:is_suit('Diamonds') then
                return {
                    x_mult = card.ability.extra.good_mult,
                    card = card,
                    colour = G.C.RED
                }
            end
        end
    end
}

SMODS.Joker {
    key = 'probabilite',
    loc_txt = {
        name = 'Probabilité',
        text = {
            "Divise par deux toutes les",
            "probabilités affichées",
            "{C:green}(Ex: 1 sur 2 devient 1 sur 4){}"
        }
    },
    blueprint_compat = false,
    pools = { ["LOB"] = true, ["EXERCISE"] = true, ["MATH"] = true },
    rarity = 2,
    atlas = 'jokers_common',
    pos = { x = 0, y = 11 },
    cost = 6,

    add_to_deck = function(self, card)
        G.GAME.probabilities.normal = G.GAME.probabilities.normal / 2
    end,

    remove_from_deck = function(self, card)
        G.GAME.probabilities.normal = G.GAME.probabilities.normal * 2
    end
}

SMODS.Joker {
    key = 'condorcet',
    loc_txt = {
        name = 'Condorcet',
        text = {
            "Si toutes les cartes jouées",
            "sont de rang {C:attention}différent{},",
            "gagne {C:mult}+#1#{} Mult.",
            "{C:inactive}(Actuellement {C:mult}+#2#{C:inactive} Mult)"
        }
    },
    config = { extra = { gain = 2, mult = 0 } },
    blueprint_compat = true,
    pools = { ["LOB"] = true, ["EXERCISE"] = true, ["PHYSIQUE"] = true },
    rarity = 2, 
    atlas = 'jokers_common',
    pos = { x = 1, y = 11 },
    cost = 6,

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.gain, card.ability.extra.mult } }
    end,

    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            local ranks = {}
            local all_different = true
            
            for _, c in ipairs(context.scoring_hand) do
                if ranks[c.base.value] then
                    all_different = false
                    break
                end
                ranks[c.base.value] = true
            end

            if all_different then
                card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.gain
                return { message = "Paradoxe !", colour = G.C.MULT }
            end
        end

        if context.joker_main and card.ability.extra.mult > 0 then
            return {
                mult_mod = card.ability.extra.mult,
                message = "+" .. card.ability.extra.mult
            }
        end
    end
}

SMODS.Joker {
    key = 'turing',
    loc_txt = {
        name = 'Turing',
        text = {
            "Si les cartes jouées contiennent",
            "au moins 1 carte {C:attention}Rouge{} et",
            "1 carte {C:attention}Noire{}, {C:mult}+#1#{} Mult."
        }
    },
    config = { extra = { mult = 20 } },
    blueprint_compat = true,
    pools = { ["LOB"] = true, ["EXERCISE"] = true, ["PHYSIQUE"] = true },
    rarity = 1,
    atlas = 'jokers_common',
    pos = { x = 2, y = 11 },
    cost = 4,

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local has_red, has_black = false, false
            for _, c in ipairs(context.scoring_hand) do
                if c:is_suit('Hearts') or c:is_suit('Diamonds') then has_red = true end
                if c:is_suit('Spades') or c:is_suit('Clubs') then has_black = true end
            end
            
            if has_red and has_black then
                return {
                    mult_mod = card.ability.extra.mult,
                    message = "Binaire!"
                }
            end
        end
    end
}

SMODS.Joker {
    key = 'fermat',
    loc_txt = {
        name = 'Fermat',
        text = {
            "Si la main contient au moins",
            "une carte {C:attention}Pierre{}, donne",
            "{C:mult}+#1#{} Mult."
        }
    },
    config = { extra = { mult = 20 } },
    blueprint_compat = true,
    pools = { ["LOB"] = true, ["EXERCISE"] = true, ["PHYSIQUE"] = true },
    rarity = 1,
    atlas = 'jokers_common',
    pos = { x = 3, y = 11 },
    cost = 4,

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local has_stone = false
            for _, c in ipairs(context.scoring_hand) do
                if c.config.center.key == 'm_stone' then
                    has_stone = true
                    break
                end
            end
            
            if has_stone then
                return {
                    mult_mod = card.ability.extra.mult,
                    message = "Dernier théorème !"
                }
            end
        end
    end
}

SMODS.Joker {
    key = 'edoh_complexe',
    loc_txt = {
        name = 'EDOH Complexe',
        text = {
            "Toutes les cartes avec un",
            "Sceau joué donnent",
            "{C:chips}+#1#{} Jetons."
        }
    },
    config = { extra = { chips = 15 } },
    blueprint_compat = true,
    pools = { ["LOB"] = true, ["EXERCISE"] = true, ["PHYSIQUE"] = true },
    rarity = 1,
    atlas = 'jokers_common',
    pos = { x = 4, y = 11 },
    cost = 4,

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card.seal then
                return {
                    chips = card.ability.extra.chips,
                    card = card
                }
            end
        end
    end
}

SMODS.Joker {
    key = 'coordonee_cylindrique',
    loc_txt = {
        name = 'Coordonnée Cylindrique',
        text = {
            "Divise votre Mult et vos Jetons",
            "par {C:attention}deux{} ({X:mult,C:white}X#1#{}).",
            "Gagne {C:money}#2#${} par main jouée."
        }
    },
    config = { extra = { debuff = 0.5, dollars = 5 } },
    blueprint_compat = false,
    pools = { ["LOB"] = true, ["EXERCISE"] = true, ["PHYSIQUE"] = true },
    rarity = 1,
    atlas = 'jokers_common',
    pos = { x = 5, y = 11 },
    cost = 4,

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.debuff, card.ability.extra.dollars } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            return {
                Xmult_mod = card.ability.extra.debuff,
                message = "Cylindrique !"
            }
        end
        
        if context.after and not context.blueprint then
            ease_dollars(card.ability.extra.dollars)
            return {
                message = "+$" .. card.ability.extra.dollars,
                colour = G.C.MONEY
            }
        end
    end
}

SMODS.Joker {
    key = 'equation_maxwell',
    loc_txt = {
        name = 'Équations de Maxwell',
        text = {
            "Les cartes de la {C:attention}couleur ciblée{}",
            "donnent {C:mult}+#1#{} Mult.",
            "{C:inactive}(La cible change à chaque manche){}",
            "Cible: {C:attention}#2#"
        }
    },
    config = { extra = { mult = 4, suit = 'Spades' } },
    blueprint_compat = true,
    pools = { ["LOB"] = true, ["EXERCISE"] = true, ["PHYSIQUE"] = true },
    rarity = 1,
    atlas = 'jokers_common',
    pos = { x = 6, y = 11 },
    cost = 4,

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult, localize(card.ability.extra.suit, 'suits_plural') } }
    end,

    calculate = function(self, card, context)
        if context.first_hand_drawn and not context.blueprint then
            local suits = {'Spades', 'Hearts', 'Clubs', 'Diamonds'}
            card.ability.extra.suit = suits[math.random(#suits)]
            return { message = "Magnétisé !", colour = G.C.SECONDARY_SET.Tarot }
        end

        if context.individual and context.cardarea == G.play then
            if context.other_card:is_suit(card.ability.extra.suit) then
                return {
                    mult = card.ability.extra.mult,
                    card = card
                }
            end
        end
    end
}

SMODS.Joker {
    key = 'mecanique_du_point', loc_txt = { name = 'Mécanique du Point', text = { "Gagne {X:mult,C:white}X0.2{} Mult", "à chaque main jouée.", "Retombe à X1 si vous défaussez.", "{C:inactive}(Actuellement {X:mult,C:white}X#1#{C:inactive})" } },
    config = { extra = { xmult = 1, gain = 0.2 } }, blueprint_compat = true, pools = { ["LOB"] = true, ["EXERCISE"] = true, ["PHYSIQUE"] = true },
    rarity = 2, atlas = 'jokers_common', pos = { x = 7, y = 11 }, cost = 6,
    loc_vars = function(self, info_queue, card) return { vars = { card.ability.extra.xmult } } end,
    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.gain
        end
        if context.discard and not context.blueprint then
            if card.ability.extra.xmult > 1 then
                card.ability.extra.xmult = 1
                return { message = "Perte d'élan !", colour = G.C.RED }
            end
        end
        if context.joker_main and card.ability.extra.xmult > 1 then
            return { Xmult_mod = card.ability.extra.xmult, message = "X"..string.format("%.1f", card.ability.extra.xmult) }
        end
    end
}

SMODS.Joker {
    key = 'poussee_archimede',
    loc_txt = {
        name = "Poussée d'Archimède",
        text = {
            "Les cartes de rang {C:attention}2, 3, 4 et 5{}",
            "flottent et donnent",
            "{X:mult,C:white}X#1#{} Mult."
        }
    },
    config = { extra = { xmult = 1.1 } },
    blueprint_compat = true,
    pools = { ["LOB"] = true, ["EXERCISE"] = true, ["PHYSIQUE"] = true },
    rarity = 2,
    atlas = 'jokers_common',
    pos = { x = 8, y = 11 },
    cost = 6,

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local id = context.other_card.base.id
            if id >= 2 and id <= 5 then
                return {
                    x_mult = card.ability.extra.xmult,
                    card = card
                }
            end
        end
    end
}

SMODS.Joker {
    key = 'qcm',
    loc_txt = {
        name = 'QCM',
        text = {
            "{C:spades}Piques{} : {C:chips}+#1#{} Jetons",
            "{C:clubs}Trèfles{} : {C:mult}+#2#{} Mult",
            "{C:diamonds}Carreaux{} : {C:money}+#3#${}",
            "{C:hearts}Cœurs{} : {C:green}1 chance sur #4#{} de donner {X:mult,C:white}X#5#{} Mult"
        }
    },
    config = { extra = { 
        spades_chips = 30, 
        clubs_mult = 5, 
        diamonds_money = 1, 
        hearts_odds = 2, 
        hearts_xmult = 1.2 
    }},
    blueprint_compat = true,
    pools = { ["LOB"] = true, ["EXERCISE"] = true, ["PHYSIQUE"] = true },
    rarity = 2,
    atlas = 'jokers_common',
    pos = { x = 9, y = 11 },
    cost = 6,

    loc_vars = function(self, info_queue, card)
        return { vars = { 
            card.ability.extra.spades_chips, 
            card.ability.extra.clubs_mult, 
            card.ability.extra.diamonds_money,
            (G.GAME.probabilities.normal or 1) * card.ability.extra.hearts_odds,
            card.ability.extra.hearts_xmult
        }}
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            
            if context.other_card:is_suit('Spades') then
                return {
                    chips = card.ability.extra.spades_chips,
                    card = card
                }
            
            elseif context.other_card:is_suit('Clubs') then
                return {
                    mult = card.ability.extra.clubs_mult,
                    card = card
                }
            
            elseif context.other_card:is_suit('Diamonds') then
                G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + card.ability.extra.diamonds_money
                G.E_MANAGER:add_event(Event({func = (function() 
                    ease_dollars(card.ability.extra.diamonds_money)
                    return true 
                end)}))
                return {
                    extra = {message = "+$"..card.ability.extra.diamonds_money, colour = G.C.MONEY},
                    card = card
                }
            
            elseif context.other_card:is_suit('Hearts') then
                if pseudorandom('qcm_hearts') < G.GAME.probabilities.normal / card.ability.extra.hearts_odds then
                    return {
                        x_mult = card.ability.extra.hearts_xmult,
                        card = card
                    }
                end
            end
            
        end
    end
}

SMODS.Joker {
    key = 'optique',
    loc_txt = {
        name = 'Optique',
        text = {
            "Chaque carte {C:attention}Verre{} jouée",
            "donne {X:mult,C:white}X#1#{} Mult mais a",
            "{C:green}1 chance sur #2#{} supplémentaire d'exploser."
        }
    },
    config = { extra = { xmult = 1.5, shatter_chance = 4 } },
    blueprint_compat = true,
    pools = { ["LOB"] = true, ["EXERCISE"] = true, ["PHYSIQUE"] = true },
    rarity = 2,
    atlas = 'jokers_common',
    pos = { x = 0, y = 12 },
    cost = 6,

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult, (G.GAME.probabilities.normal or 1) * card.ability.extra.shatter_chance } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card.config.center.key == 'm_glass' then
                return {
                    x_mult = card.ability.extra.xmult,
                    card = card
                }
            end
        end

        if context.destroying_card and not context.blueprint then
            if context.destroying_card.config.center.key == 'm_glass' then
                if pseudorandom('optique') < G.GAME.probabilities.normal / card.ability.extra.shatter_chance then
                    return true
                end
            end
        end
    end
}

SMODS.Joker {
    key = 'c',
    loc_txt = {
        name = 'C',
        text = {
            "La {C:attention}première main{} de",
            "chaque manche donne",
            "{C:chips}+#1#{} Jetons."
        }
    },
    config = { extra = { chips = 100 } },
    blueprint_compat = true,
    pools = { ["LOB"] = true, ["EXERCISE"] = true, ["INFO"] = true },
    rarity = 1,
    atlas = 'jokers_common',
    pos = { x = 1, y = 12 },
    cost = 4,

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips } }
    end,

    calculate = function(self, card, context)
        if context.joker_main and G.GAME.current_round.hands_played == 0 then
            return {
                chip_mod = card.ability.extra.chips,
                message = "Vitesse C !"
            }
        end
    end
}

SMODS.Joker {
    key = 'python',
    loc_txt = {
        name = 'Python',
        text = {
            "La {C:attention}dernière main{} de",
            "chaque manche donne",
            "{C:mult}+#1#{} Mult."
        }
    },
    config = { extra = { mult = 50 } },
    blueprint_compat = true,
    pools = { ["LOB"] = true, ["EXERCISE"] = true, ["INFO"] = true },
    rarity = 1,
    atlas = 'jokers_common',
    pos = { x = 2, y = 12 },
    cost = 4,

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult } }
    end,

    calculate = function(self, card, context)
        if context.joker_main and G.GAME.current_round.hands_left == 0 then
            return {
                mult_mod = card.ability.extra.mult,
                message = "Lent mais sûr !"
            }
        end
    end
}

SMODS.Joker {
    key = 'html',
    loc_txt = {
        name = 'HTML',
        text = {
            "Les cartes sans amélioration",
            "donnent {C:mult}+#1#{} Mult."
        }
    },
    config = { extra = { mult = 4 } },
    blueprint_compat = true,
    pools = { ["LOB"] = true, ["EXERCISE"] = true, ["INFO"] = true },
    rarity = 1,
    atlas = 'jokers_common',
    pos = { x = 3, y = 12 },
    cost = 4,

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card.config.center == G.P_CENTERS.c_base then
                return {
                    mult = card.ability.extra.mult,
                    card = card
                }
            end
        end
    end
}

SMODS.Joker {
    key = 'java',
    loc_txt = {
        name = 'Java',
        text = {
            "Donne {C:chips}+#1#{} Jetons pour",
            "chaque {C:money}1${} de valeur de vente",
            "de vos Jokers cumulés.",
            "{C:inactive}(Actuellement +#2# Jetons)"
        }
    },
    config = { extra = { chips_per_dollar = 5 } },
    blueprint_compat = true,
    pools = { ["LOB"] = true, ["EXERCISE"] = true, ["INFO"] = true },
    rarity = 1,
    atlas = 'jokers_common',
    pos = { x = 4, y = 12 },
    cost = 4,

    loc_vars = function(self, info_queue, card)
        local total_sell = 0
        for _, j in ipairs(G.jokers.cards) do
            total_sell = total_sell + (j.sell_cost or 0)
        end
        return { vars = { card.ability.extra.chips_per_dollar, total_sell * card.ability.extra.chips_per_dollar } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local total_sell = 0
            for _, j in ipairs(G.jokers.cards) do
                total_sell = total_sell + (j.sell_cost or 0)
            end

            local total_chips = total_sell * card.ability.extra.chips_per_dollar
            if total_chips > 0 then
                return {
                    chip_mod = total_chips,
                    message = "Héritage !"
                }
            end
        end
    end
}

SMODS.Joker {
    key = 'php',
    loc_txt = {
        name = 'PHP',
        text = {
            "Si vous défaussez un(e)",
            "{C:attention}#1#{}, gagnez {C:money}#2#${}.",
            "{C:inactive}(Change à chaque manche){}"
        }
    },
    config = { extra = { target_hand = 'High Card', dollars = 5 } },
    blueprint_compat = false,
    pools = { ["LOB"] = true, ["EXERCISE"] = true, ["INFO"] = true },
    rarity = 1,
    atlas = 'jokers_common',
    pos = { x = 5, y = 12 },
    cost = 4,

    loc_vars = function(self, info_queue, card)
        return { vars = { localize(card.ability.extra.target_hand, 'poker_hands'), card.ability.extra.dollars } }
    end,

    calculate = function(self, card, context)
        if context.first_hand_drawn and not context.blueprint then
            local _hands = {}
            for h, _ in pairs(G.GAME.hands) do
                if SMODS.is_poker_hand_visible(h) then _hands[#_hands+1] = h end
            end
            card.ability.extra.target_hand = pseudorandom_element(_hands, 'php_target')
            return { message = "Nouvelle cible!" }
        end

        if context.pre_discard and not context.blueprint then
            local text, _, _ = G.FUNCS.get_poker_hand_info(G.hand.highlighted)
            if text == card.ability.extra.target_hand then
                ease_dollars(card.ability.extra.dollars)
                return { message = "+$" .. card.ability.extra.dollars, colour = G.C.MONEY }
            end
        end
    end
}

SMODS.Joker {
    key = 'sql',
    loc_txt = {
        name = 'SQL',
        text = {
            "Si la main jouée est la",
            "même que la {C:attention}main la plus jouée{}",
            "de la partie, donne {C:chips}+#1#{} Jetons."
        }
    },
    config = { extra = { chips = 30 } },
    blueprint_compat = true,
    pools = { ["LOB"] = true, ["EXERCISE"] = true, ["INFO"] = true },
    rarity = 1,
    atlas = 'jokers_common',
    pos = { x = 6, y = 12 },
    cost = 6,

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local most_played = "High Card"
            local max_plays = -1
            for k, v in pairs(G.GAME.hands) do
                if v.played > max_plays then
                    max_plays = v.played
                    most_played = k
                end
            end
            
            if context.scoring_name == most_played then
                return {
                    chip_mod = card.ability.extra.chips,
                    message = "Requête OK!"
                }
            end
        end
    end
}

SMODS.Joker {
    key = 'bash',
    loc_txt = {
        name = 'Bash',
        text = {
            "Si vous n'avez {C:red}plus de défausses{}",
            "avant de jouer votre première main,",
            "gagnez {X:mult,C:white}X#1#{} Mult pour la manche."
        }
    },
    config = { extra = { xmult = 2, active = false } },
    blueprint_compat = true,
    pools = { ["LOB"] = true, ["EXERCISE"] = true, ["INFO"] = true },
    rarity = 1,
    atlas = 'jokers_common',
    pos = { x = 7, y = 12 },
    cost = 4,

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult } }
    end,

    calculate = function(self, card, context)
        if context.first_hand_drawn then
            card.ability.extra.active = false
        end

        if context.before and not context.blueprint then
            if G.GAME.current_round.hands_played == 0 and G.GAME.current_round.discards_left == 0 then
                card.ability.extra.active = true
                return { message = "Script lancé !", colour = G.C.MULT }
            end
        end

        if context.joker_main and card.ability.extra.active then
            return {
                Xmult_mod = card.ability.extra.xmult,
                message = "X" .. card.ability.extra.xmult
            }
        end
    end
}

SMODS.Joker {
    key = 'chatgpt', loc_txt = { name = 'ChatGPT', text = { "Génère 1 carte {C:planet}Planète{} aléatoire", "si la main jouée ne contient", "aucune {C:attention}Figure{}." } },
    blueprint_compat = true, pools = { ["LOB"] = true, ["EXERCISE"] = true, ["INFO"] = true },
    rarity = 2, atlas = 'jokers_common', pos = { x = 8, y = 12 }, cost = 6,
    calculate = function(self, card, context)
        if context.after and not context.blueprint then
            local has_face = false
            for _, c in ipairs(context.full_hand) do if c:is_face() then has_face = true break end end
            if not has_face and #G.consumeables.cards < G.consumeables.config.card_limit then
                local planet = create_card('Planet', G.consumeables, nil, nil, nil, nil, nil, 'chatgpt')
                planet:add_to_deck()
                G.consumeables:emplace(planet)
                return { message = "Généré !", colour = G.C.SECONDARY_SET.Planet }
            end
        end
    end
}

SMODS.Joker {
    key = 'vscode', loc_txt = { name = 'VSCode', text = { "{C:attention}+1{} Emplacement", "de Consommable." } },
    blueprint_compat = false, pools = { ["LOB"] = true, ["EXERCISE"] = true, ["INFO"] = true },
    rarity = 2, atlas = 'jokers_common', pos = { x = 9, y = 12 }, cost = 6,
    add_to_deck = function(self, card) G.consumeables.config.card_limit = G.consumeables.config.card_limit + 1 end,
    remove_from_deck = function(self, card) G.consumeables.config.card_limit = G.consumeables.config.card_limit - 1 end
}

SMODS.Joker {
    key = 'le_pc_de_mansour',
    loc_txt = {
        name = 'Le PC de Mansour',
        text = {
            "Gagne {X:mult,C:white}X#1#{} Mult par main jouée.",
            "{C:green}1 chance sur #2#{} de réinitialiser",
            "ce bonus à la fin de la main.",
            "{C:inactive}(Actuellement {X:mult,C:white}X#3#{C:inactive} Mult)"
        }
    },
    config = { extra = { gain = 0.2, reset_chance = 5, current = 1.0 } },
    blueprint_compat = true,
    pools = { ["LOB"] = true, ["EXERCISE"] = true, ["INFO"] = true },
    rarity = 2,
    atlas = 'jokers_common',
    pos = { x = 0, y = 13 },
    cost = 6,

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.gain, (G.GAME.probabilities.normal or 1) * card.ability.extra.reset_chance, string.format("%.1f", card.ability.extra.current) } }
    end,

    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            card.ability.extra.current = card.ability.extra.current + card.ability.extra.gain
        end

        if context.joker_main and card.ability.extra.current > 1 then
            return {
                Xmult_mod = card.ability.extra.current,
                message = "X" .. string.format("%.1f", card.ability.extra.current)
            }
        end

        if context.after and not context.blueprint then
            if pseudorandom('pc_mansour') < G.GAME.probabilities.normal / card.ability.extra.reset_chance then
                card.ability.extra.current = 1.0
                return {
                    message = "Surchauffe !",
                    colour = G.C.RED
                }
            end
        end
    end
}

SMODS.Joker {
    key = 'force_push',
    loc_txt = {
        name = 'Force Push',
        text = {
            "Jouer un(e) {C:attention}#1#{} bat instantanément",
            "la Blinde sans récompense monétaire,",
            "mais {C:red}détruit{} un Joker au hasard.",
            "{C:inactive}(La cible change à chaque manche){}"
        }
    },
    config = { extra = { target_hand = 'High Card' } },
    blueprint_compat = false,
    pools = { ["LOB"] = true, ["EXERCISE"] = true, ["INFO"] = true },
    rarity = 2,
    atlas = 'jokers_common',
    pos = { x = 1, y = 13 },
    cost = 6,

    loc_vars = function(self, info_queue, card)
        return { vars = { localize(card.ability.extra.target_hand, 'poker_hands') } }
    end,

    calculate = function(self, card, context)
        if context.first_hand_drawn and not context.blueprint then
            local _hands = {}
            for h, _ in pairs(G.GAME.hands) do
                if SMODS.is_poker_hand_visible(h) then _hands[#_hands+1] = h end
            end
            card.ability.extra.target_hand = pseudorandom_element(_hands, 'force_push_target')
        end

        if context.joker_main and not context.blueprint and context.scoring_name == card.ability.extra.target_hand then
            if #G.jokers.cards > 1 then
                local destroyable_jokers = {}
                for _, j in ipairs(G.jokers.cards) do
                    if j ~= card and not j.ability.eternal then
                        table.insert(destroyable_jokers, j)
                    end
                end
                
                if #destroyable_jokers > 0 then
                    local target = destroyable_jokers[math.random(#destroyable_jokers)]
                    
                    play_sound('lob_snd_explosion')
                    local x_pos = target.T.x * (love.graphics.getWidth()/G.ROOM.T.w) + (target.T.w/2)
                    local y_pos = target.T.y * (love.graphics.getHeight()/G.ROOM.T.h) + (target.T.h/2)
                    add_lob_effect("explosion", x_pos, y_pos)
                    
                    target:start_dissolve()
                    
                    G.GAME.blind.chips = 0
                    G.GAME.blind.chip_text = "0"
                    
                    return { message = "Git Push -f !", colour = G.C.RED }
                end
            end
        end
    end
}


SMODS.Joker {
    key = 'create',
    loc_txt = {
        name = 'Create',
        text = {
            "Gagne {C:blue}+#1#{} Jetons à chaque fois",
            "qu'une carte est {C:attention}re-déclenchée{}",
            "(pas la 1ère fois qu'elle score).",
            "{C:inactive}(Actuellement {C:blue}+#2#{C:inactive} Jetons)"
        }
    },
    config = { extra = { gain = 5, chips = 0 } },
    blueprint_compat = true,
    pools = { ["LOB"] = true, ["MINECRAFT"] = true },
    rarity = 1,
    atlas = 'jokers_common',
    pos = { x = 0, y = 4 },
    cost = 3,

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.gain, card.ability.extra.chips } }
    end,

    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            G.GAME.lob_create_seen = {}
        end

        if context.individual and context.cardarea == G.play and not context.blueprint and context.other_card then
            G.GAME.lob_create_seen = G.GAME.lob_create_seen or {}
            local count = (G.GAME.lob_create_seen[context.other_card] or 0) + 1
            G.GAME.lob_create_seen[context.other_card] = count

            if count > 1 then
                card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.gain
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = 'Upgrade!', colour = G.C.BLUE})
            end
        end

        if context.joker_main and card.ability.extra.chips > 0 then
            return {
                chip_mod = card.ability.extra.chips,
                message = "+" .. card.ability.extra.chips
            }
        end
    end
}

SMODS.Joker {
    key = 'project_e',
    loc_txt = {
        name = 'Project E',
        text = {
            "À la fin de la manche, transforme",
            "le {C:attention}Joker{} le plus à gauche en un",
            "autre Joker aléatoire de {C:attention}même rareté{}."
        }
    },
    blueprint_compat = false,
    pools = { ["LOB"] = true, ["MINECRAFT"] = true },
    rarity = 1,
    atlas = 'jokers_common',
    pos = { x = 1, y = 4 },
    cost = 4,

    calculate = function(self, card, context)
        if context.end_of_round and not context.individual and not context.repetition and not context.blueprint then
            local target = nil
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] ~= card then
                    target = G.jokers.cards[i]
                    break 
                end
            end

            if target then
                local target_rarity = target.config.center.rarity
                target:start_dissolve() 

                local pool = {}
                for k, v in pairs(G.P_CENTERS) do
                    if v.set == 'Joker' and not v.no_pool and v.rarity == target_rarity and k ~= target.config.center.key then
                        table.insert(pool, k)
                    end
                end
                
                if #pool > 0 then
                    local new_key = pool[math.random(#pool)]
                    local new_joker = create_card('Joker', G.jokers, nil, nil, nil, nil, new_key, 'prj')
                    
                    new_joker:add_to_deck()
                    G.jokers:emplace(new_joker)
                    new_joker:juice_up(0.5, 0.5)
                    play_sound('tarot1')

                    return { message = "Transmutation !", colour = G.C.PURPLE, card = card }
                end
            end
        end
    end
}

SMODS.Joker {
    key = 'botania',
    loc_txt = {
        name = 'Botania',
        text = {
            "Gagne {X:chips,C:white}X#1#{} Jetons pour chaque",
            "carte {C:tarot}Weed{} utilisée cette partie",
            "{C:inactive}(Actuellement {X:chips,C:white}X#2#{C:inactive} Jetons)"
        }
    },
    config = { extra = { gain = 0.25, xchips = 1 } },
    blueprint_compat = true,
    pools = { ["LOB"] = true, ["MINECRAFT"] = true },
    rarity = 1,
    atlas = 'jokers_common',
    pos = { x = 2, y = 4 },
    cost = 4,

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.gain, card.ability.extra.xchips } }
    end,

    calculate = function(self, card, context)
        if context.using_consumeable and not context.blueprint then
            if context.consumeable.config.center.key == 'c_lob_weed' then
                card.ability.extra.xchips = card.ability.extra.xchips + card.ability.extra.gain
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = 'Mana!', colour = G.C.GREEN})
            end
        end

        if context.joker_main and card.ability.extra.xchips > 1 then
            return {
                x_chips = card.ability.extra.xchips,
                message = "X" .. card.ability.extra.xchips
            }
        end
    end
}

SMODS.Joker {
    key = 'cataclysm',
    loc_txt = {
        name = 'Cataclysm',
        text = {
            "Quand {C:attention}vendu{}, diminue de {C:attention}50%{}",
            "les jetons nécessaires pour",
            "battre la {C:attention}Blinde{} actuelle"
        }
    },
    blueprint_compat = false,
    pools = { ["LOB"] = true, ["MINECRAFT"] = true },
    rarity = 1,
    atlas = 'jokers_common',
    pos = { x = 3, y = 4 },
    cost = 5,
    calculate = function(self, card, context)
        if context.selling_self and not context.blueprint then
            G.GAME.blind.chips = G.GAME.blind.chips * 0.5
            G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
        end
    end
}

SMODS.Joker {
    key = 'ice_and_fire',
    loc_txt = {
        name = 'Ice and Fire',
        text = {
            "Quand {C:attention}vendu{}, génère",
            "un {C:attention}Tag Dragon{}"
        }
    },
    blueprint_compat = false,
    pools = { ["LOB"] = true, ["MINECRAFT"] = true },
    rarity = 1,
    atlas = 'jokers_common',
    pos = { x = 4, y = 4 },
    cost = 4,
    calculate = function(self, card, context)
        if context.selling_self and not context.blueprint then
            add_tag(Tag('tag_lob_dragon'))
            play_sound('generic1', 0.9 + math.random() * 0.1, 0.8)
            play_sound('holo1', 1.2 + math.random() * 0.1, 0.4)
        end
    end
}

SMODS.Joker {
    key = 'broken_bad',
    loc_txt = {
        name = 'Broken Bad',
        text = {
            "Gagne une carte {C:attention}Weed{} si la",
            "main jouée est un {C:attention}#1#{}",
            "{C:inactive}(Change à chaque manche, max 1/manche)",
            "{C:green}Bonus :{} +1 si vous avez {C:attention}Create{}"
        }
    },
    config = { extra = { target_hand = 'High Card', triggered = false } },
    blueprint_compat = true,
    pools = { ["LOB"] = true, ["MINECRAFT"] = true },
    rarity = 1,
    atlas = 'jokers_common',
    pos = { x = 5, y = 4 },
    cost = 5,
    loc_vars = function(self, info_queue, card)
        return { vars = { localize(card.ability.extra.target_hand, 'poker_hands') } }
    end,
    calculate = function(self, card, context)
        if context.first_hand_drawn then card.ability.extra.triggered = false end
        
        if context.before and context.scoring_name == card.ability.extra.target_hand and not card.ability.extra.triggered then
            card.ability.extra.triggered = true
            local count = 1
            if next(SMODS.find_card('j_lob_create')) then count = count + 1 end
            
            for i = 1, count do
                local weed = create_card('Tarot', G.consumeables, nil, nil, nil, nil, 'c_lob_weed', 'broken_bad')
                weed:add_to_deck()
                G.consumeables:emplace(weed)
            end
            return { message = 'Heisenberg!', colour = G.C.BLUE }
        end
    end
}

SMODS.Joker {
    key = 'ae2',
    loc_txt = {
        name = 'Ae2',
        text = {
            "À la fin de la manche, {C:red}détruit{}",
            "le Joker à sa {C:attention}droite{} et gagne",
            "{C:blue}+#1# Jetons{} par {C:money}${} de sa valeur.",
            "{C:inactive}(Actuellement {C:blue}+#2#{C:inactive} Jetons)"
        }
    },
    config = { extra = { mult_val = 4, chips = 0 } },
    blueprint_compat = false,
    pools = { ["LOB"] = true, ["MINECRAFT"] = true },
    rarity = 1,
    atlas = 'jokers_common',
    pos = { x = 6, y = 4 },
    cost = 4,

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult_val, card.ability.extra.chips } }
    end,

    calculate = function(self, card, context)
        if context.end_of_round and not context.blueprint and not context.individual and not context.repetition then
            local my_pos = nil
            for i=1, #G.jokers.cards do if G.jokers.cards[i] == card then my_pos = i break end end
            
            if my_pos and my_pos < #G.jokers.cards then
                local target = G.jokers.cards[my_pos + 1]
                
                if target and not target.config.center.eternal and not target.getting_sliced then
                    target.getting_sliced = true
                    
                    local gain = (target.sell_cost or 0) * card.ability.extra.mult_val
                    card.ability.extra.chips = card.ability.extra.chips + gain
                    
                    target:start_dissolve()
                    return { message = '+'..gain..' Jetons', colour = G.C.BLUE }
                end
            end
        end

        if context.joker_main and card.ability.extra.chips > 0 then
            return {
                chip_mod = card.ability.extra.chips,
                message = "+" .. card.ability.extra.chips
            }
        end
    end
}

SMODS.Joker {
    key = 'terraria',
    loc_txt = {
        name = 'Terraria',
        text = {
            "Si vous deviez {C:red}perdre{}, vous survivez,",
            "perdez tout votre {C:money}argent{}",
            "puis cette carte est {C:red}détruite{}"
        }
    },
	pools = { ["LOB"] = true, ["MINECRAFT"] = true },
    blueprint_compat = false,
    eternal_compat = false,
    rarity = 2,
    atlas = 'jokers_common',
    pos = { x = 7, y = 4 },
    cost = 6,
    calculate = function(self, card, context)
        if context.end_of_round and context.game_over and not context.blueprint then
            G.E_MANAGER:add_event(Event({
                func = function()
                    G.hand_text_area.blind_chips:juice_up()
                    G.hand_text_area.game_chips:juice_up()
                    play_sound('tarot1')
                    ease_dollars(-G.GAME.dollars, true) 
                    card:start_dissolve()
                    return true
                end
            }))
            return {
                message = 'Sauvé par Terraria !',
                saved = true,
                colour = G.C.RED
            }
        end
    end
}

SMODS.Joker {
    key = 'urschleim',
    loc_txt = {
        name = 'Urschleim',
        text = {
            "À la fin de la manche, {C:red}détruit{} le Joker à droite.",
            "Gagne {C:money}double{} sa valeur en {C:attention}Valeur de Vente{}.",
            "Tous les {C:attention}2{} Jokers détruits, gagne un {C:attention}Tag{} aléatoire.",
            "{C:inactive}(Détruits : #1#)"
        }
    },
    config = { extra = { destroyed = 0 } },
    blueprint_compat = false,
    pools = { ["LOB"] = true, ["MINECRAFT"] = true },
    rarity = 1,
    atlas = 'jokers_common',
    pos = { x = 0, y = 5 },
    cost = 3,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.destroyed } }
    end,
    calculate = function(self, card, context)
        if context.end_of_round and not context.blueprint and not context.individual and not context.repetition then
            local my_pos = nil
            for i=1, #G.jokers.cards do if G.jokers.cards[i] == card then my_pos = i break end end
            local target = G.jokers.cards[my_pos + 1]

            if target and not target.config.center.eternal and not target.getting_sliced then
                target.getting_sliced = true 
                
                local sell_val = target.sell_cost or 0
                card.ability.extra_value = card.ability.extra_value + (sell_val * 2)
                card:set_cost()
                
                card.ability.extra.destroyed = card.ability.extra.destroyed + 1
                target:start_dissolve()
                
                if card.ability.extra.destroyed % 2 == 0 then
                    add_tag(Tag(get_next_tag_key('urschleim')))
                end
                return { message = "Ecrasé !", colour = G.C.GREEN }
            end
        end
    end
}

SMODS.Joker {
    key = 'entre_suceur',
    loc_txt = {
        name = 'Entre-Suceur',
        text = {
            "Si vous en possédez {C:attention}deux{},",
            "tous les Jokers {C:attention}entre eux{} sont",
            "re-déclenchés une fois.",
            "{C:inactive}(Peut apparaître même si déjà possédé)"
        }
    },
    blueprint_compat = false,
    pools = { ["LOB"] = true, ["MINECRAFT"] = true },
    rarity = 1,
    atlas = 'jokers_common',
    pos = { x = 1, y = 5 },
    cost = 3,

    in_pool = function(self, args)
        return true, { allow_duplicates = true }
    end,

    calculate = function(self, card, context)
        if context.retrigger_joker_check and not context.retrigger_joker then
            local selfid = 0
            local suceurcount = 0
            local othersuceur = 0

            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == card then selfid = i end
                if G.jokers.cards[i].config.center.key == card.config.center.key and not G.jokers.cards[i].debuff then
                    suceurcount = suceurcount + 1
                end
            end

            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] ~= card and G.jokers.cards[i].config.center.key == card.config.center.key then
                    othersuceur = i
                end
            end

            if suceurcount >= 2 and selfid < othersuceur then
                local target_pos = 0
                for i = 1, #G.jokers.cards do
                    if G.jokers.cards[i] == context.other_card then target_pos = i end
                end

                if target_pos > selfid and target_pos < othersuceur then
                    return {
                        message = 'Suceur !',
                        repetitions = 1,
                        card = card
                    }
                end
            end
        end
    end
}

local function lob_boost_card_values(t, multiplier)
    for k, v in pairs(t) do
        if type(v) == 'number' then
            if (k == 'x_mult' or k == 'x_chips' or k == 'perma_x_mult' or k == 'perma_x_chips') and (v == 0 or v == 1) then
            else
                t[k] = v * multiplier
            end
        elseif type(v) == 'table' and k ~= 'consumeable' then
            lob_boost_card_values(v, multiplier)
        end
    end
end

SMODS.Joker {
    key = 'booster',
    config = { extra = { stored_chips = 0 } },
    loc_txt = {
        name = 'Booster',
        text = {
            "Début de manche : {C:red}détruit{} le Joker à gauche",
            "et stocke sa valeur ({C:blue}+1 Jeton{} par {C:money}${}).",
            "À la {C:attention}vente{}, le Joker à gauche",
            "multiplie ses valeurs par {X:mult,C:white}X0.10{}",
            "pour chaque {C:blue}2 Jetons{} stockés.",
            "{C:inactive}(Actuellement {C:blue}#1#{} Jetons stockés)"
        }
    },

    blueprint_compat = false,
    pools = { ["LOB"] = true, ["MINECRAFT"] = true },
    rarity = 1,
    atlas = 'jokers_common',
    pos = { x = 2, y = 5 },
    cost = 5,

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.stored_chips or 0 } }
    end,

    calculate = function(self, card, context)
        if context.first_hand_drawn and not context.blueprint then
            local my_pos = nil
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == card then my_pos = i break end
            end
            if my_pos and my_pos > 1 then
                local target = G.jokers.cards[my_pos - 1]
                if target and not target.config.center.eternal then
                    card.ability.extra.stored_chips = (card.ability.extra.stored_chips or 0) + (target.sell_cost or 0)
                    target:start_dissolve()
                    return { message = "Scrap!", colour = G.C.ORANGE }
                end
            end
        end

        if context.selling_self and not context.blueprint and (card.ability.extra.stored_chips or 0) > 0 then
            local my_pos = nil
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == card then my_pos = i break end
            end
            if my_pos and my_pos > 1 then
                local target = G.jokers.cards[my_pos - 1]
                local multiplier = 1 + math.floor(card.ability.extra.stored_chips / 2) * 0.10

                if target and multiplier > 1 and not target.config.center.eternal then
                    lob_boost_card_values(target.ability, multiplier)
                    card_eval_status_text(target, 'extra', nil, nil, nil, {
                        message = "BOOSTÉ X" .. string.format("%.2f", multiplier) .. " !",
                        colour = G.C.GREEN
                    })
                end
            end
        end
    end
}

SMODS.Joker {
    key = 'oiseau_de_feu',
    loc_txt = {
        name = 'Oiseau de Feu',
        text = {
            "Si la main jouée est {C:attention}enflamé{} génère",
            "{C:tarot}1 Carte de Tarot{} pour chaque {C:attention}2 défausses{} restantes."
        }
    },
    blueprint_compat = true,
    pools = { ["LOB"] = true, ["MINECRAFT"] = true },
    rarity = 1,
    atlas = 'jokers_common',
    pos = { x = 3, y = 5 },
    cost = 4,
    calculate = function(self, card, context)
        if context.joker_main then
            local score_now = LOB_plain_num(hand_chips or 0) * LOB_plain_num(mult or 0)
            local score_needed = LOB_plain_num(G.GAME.blind.chips or 0)
            if score_now >= score_needed then
                local count = math.floor((G.GAME.current_round.discards_left or 0) / 2)
                if count > 0 then
                    local created = 0
                    for i = 1, count do
                        if #G.consumeables.cards < G.consumeables.config.card_limit then
                            local tarot = create_card('Tarot', G.consumeables, nil, nil, nil, nil, nil, 'fire')
                            tarot:add_to_deck()
                            G.consumeables:emplace(tarot)
                            created = created + 1
                        end
                    end
                    if created > 0 then
                        return { message = "+"..created.." Tarots!", colour = G.C.RED }
                    end
                end
            end
        end
    end
}

SMODS.Atlas {
	key = "singe_balatro",
	path = "singe_balatro.png",
	px = 71,
	py = 95,
	frames = 128
}

SMODS.Atlas {
	key = "singe_ambulancier",
	path = "singe_ambulancier.png",
	px = 71,
	py = 95,
	frames = 162
}

SMODS.Atlas {
	key = "sus_balatro",
	path = "sus_balatro.png",
	px = 71,
	py = 95,
	frames = 33
}

SMODS.Atlas {
	key = "singe_deprime",
	path = "singe_deprime.png",
	px = 71,
	py = 95,
	frames = 56
}

SMODS.Atlas {
	key = "among_us_fart",
	path = "among_us_fart.png",
	px = 71,
	py = 95,
	frames = 143
}

SMODS.Atlas {
	key = "ganondorf",
	path = "ganondorf.png",
	px = 71,
	py = 95,
	frames = 40
}

SMODS.Atlas {
	key = "subwaysurfers",
	path = "subwaysurfers.png",
	px = 71,
	py = 96,
	frames = 256
}

SMODS.Joker {
    key = 'maelle',
    loc_txt = {
        name = 'Maelle',
        text = {
            "{C:green}50%{} de chance : {X:mult,C:white}X2{} Chips & Mult.",
            "{C:red}50%{} de chance : {X:mult,C:white}X0.5{} Chips & Mult."
        }
    },
    blueprint_compat = true,
    pools = { ["LOB"] = true, ["MEME"] = true },
    rarity = 1,
    atlas = 'jokers_common',
	-- art : https://www.instagram.com/p/DKiM9ywRc9r/?utm_source=ig_web_copy_link&igsh=NTc4MTIwNjQ2YQ==
    pos = { x = 0, y = 6 },
    cost = 3,
    calculate = function(self, card, context)
        if context.joker_main then
            if pseudorandom('maelle') < 0.5 then
                return { x_mult = 2, x_chips = 2, message = "Touché !", colour = G.C.GREEN }
            else
                return { x_mult = 0.5, x_chips = 0.5, message = "Raté...", colour = G.C.RED }
            end
        end
    end
}

SMODS.Joker {
    key = 'lune',
    loc_txt = {
        name = 'Lune',
        text = {
            "Gagne {C:blue}+2 Jetons{} et {C:red}+2 Mult{} pour chaque",
            "carte {C:planet}Planète{} utilisée cette partie.",
            "{C:inactive}(Actuellement {C:blue}+#1#{C:inactive} Jetons et {C:red}+#2#{C:inactive} Mult)"
        }
    },
    blueprint_compat = true,
    pools = { ["LOB"] = true, ["MEME"] = true },
    rarity = 1,
    atlas = 'jokers_common',
	-- art : https://www.facebook.com/groups/pixelartplus/posts/1728550914407685/
    pos = { x = 1, y = 6 },
    cost = 3,
    loc_vars = function(self, info_queue, card)
        local count = 0
        if G.GAME and G.GAME.consumeable_usage then
            for k, v in pairs(G.GAME.consumeable_usage) do
                if G.P_CENTERS[k] and G.P_CENTERS[k].set == 'Planet' then count = count + v.count end
            end
        end
        return { vars = { count * 2, count * 2 } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local count = 0
            if G.GAME and G.GAME.consumeable_usage then
                for k, v in pairs(G.GAME.consumeable_usage) do
                    if G.P_CENTERS[k] and G.P_CENTERS[k].set == 'Planet' then count = count + v.count end
                end
            end
            if count > 0 then
                return {
                    chip_mod = count * 2,
                    mult_mod = count * 2,
                    message = "Astral!"
                }
            end
        end
    end
}

SMODS.Joker {
    key = 'singe_balatro',
    loc_txt = {
        name = 'Singe Balatro',
        text = {
            "{X:chips,C:white}X#1#{} Jetons.",
            "{C:green}1 chance sur #2#{} de générer",
            "un {C:attention}Gros Michel Négatif{} à la fin de la",
            "manche et d'être {C:red}détruit{}."
        }
    },
    config = { extra = { x_chips = 2, odds = 10 } },
    blueprint_compat = true,
    pools = { ["LOB"] = true, ["MEME"] = true },
    rarity = 1,
    atlas = 'singe_balatro',
    pos = { x = 0, y = 0 },
    cost = 3,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.x_chips, (G.GAME.probabilities.normal or 1) * card.ability.extra.odds } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return { x_chips = card.ability.extra.x_chips }
        end
        if context.end_of_round and not context.blueprint and not context.individual and not context.repetition then
            if not card.getting_sliced then 
                if pseudorandom('singe_balatro') < G.GAME.probabilities.normal / card.ability.extra.odds then
                    card.getting_sliced = true
                    local target = G.GAME.pool_flags.gros_michel_extinct and 'j_cavendish' or 'j_gros_michel'
                    
                    local new_joker = create_card('Joker', G.jokers, nil, nil, nil, nil, target, 'sbl')
                    new_joker:set_edition({negative = true}, true)
                    new_joker:add_to_deck()
                    G.jokers:emplace(new_joker)
                    
                    card:start_dissolve()
                    return { message = "Banana!", colour = G.C.YELLOW }
                end
            end
        end
    end
}

SMODS.Joker {
    key = 'singe_ambulancier',
    loc_txt = {
        name = 'Singe Ambulancier',
        text = {
            "Génère un {C:attention}Joker Meme{} lorsqu'un",
            "Joker est {C:attention}vendu{}.",
            "Devient {C:dark_edition}Déprimé{} après {C:attention}#1# utilisations{}."
        }
    },
    config = { extra = { uses = 4 } },
    blueprint_compat = false,
    pools = { ["LOB"] = true, ["MEME"] = true },
    rarity = 1,
    atlas = 'singe_ambulancier',
    pos = { x = 0, y = 0 },
    cost = 3,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.uses } }
    end,
    calculate = function(self, card, context)
        if context.selling_card and context.card.ability.set == 'Joker' and not context.blueprint then
            card.ability.extra.uses = card.ability.extra.uses - 1
            
            local eligible_jokers = {}
            for k, v in pairs(G.P_CENTERS) do
                if v.set == 'Joker' and v.pools and v.pools["MEME"] then table.insert(eligible_jokers, k) end
            end
            
            if #eligible_jokers > 0 then
                local target_key = pseudorandom_element(eligible_jokers, pseudoseed('meme_gen'))
                local meme_joker = create_card('Joker', G.jokers, nil, nil, nil, nil, target_key, 'meme_gen')
                meme_joker:add_to_deck()
                G.jokers:emplace(meme_joker)
            end
            
            if card.ability.extra.uses <= 0 then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        card:set_ability(G.P_CENTERS.j_lob_singe_deprime)
                        card:set_eternal(true)
                        card_eval_status_text(card, 'extra', nil, nil, nil, {message = "Déprimé...", colour = G.C.BLUE})
                        return true
                    end
                }))
            end
        end
    end
}

SMODS.Joker {
    
    key = 'singe_deprime',
    loc_txt = {
        name = 'Singe Déprimé',
        text = {
            "{X:mult,C:white}X#1#{} Mult et {X:chips,C:white}X#2#{} Jetons.",
            "Gagne un {C:attention}Tag aléatoire{} à la fin de la manche."
        }
    },
    config = { extra = { x_mult = 0.5, x_chips = 0.5 } },
    blueprint_compat = true,
    pools = { ["LOB"] = true, ["MEME"] = true },
    rarity = 1,
    atlas = 'singe_deprime',
    pos = { x = 0, y = 0 },
    cost = 3,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.x_mult, card.ability.extra.x_chips } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return { x_mult = card.ability.extra.x_mult, x_chips = card.ability.extra.x_chips, message = "Soupir...", colour = G.C.GREY }
        end
        if context.end_of_round and not context.blueprint and not context.individual and not context.repetition then
            add_tag(Tag(get_next_tag_key('singe_deprime')))
            return { message = "+1 Tag", colour = G.C.ORANGE }
        end
    end
}

SMODS.Joker {
    
    key = 'sus_balatro',
    loc_txt = {
        name = 'Sus Balatro',
        text = {
            "{C:blue}+#1#{} Jetons.",
            "Perd {C:attention}#2# Jeton{} à chaque fois",
            "que vous cliquez n'importe où."
        }
    },
    config = { extra = { chips = 200, loss_per_click = 1 } },
    blueprint_compat = true,
    pools = { ["LOB"] = true, ["MEME"] = true },
    rarity = 1,
    atlas = 'sus_balatro',
    pos = { x = 0, y = 0 },
    cost = 3,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips, card.ability.extra.loss_per_click } }
    end,
    set_ability = function(self, card, initial, delay_sprites)
        local orig_click = card.click
        card.click = function()
            if orig_click then orig_click(card) end
            if card.ability.extra.chips > 0 then
                card.ability.extra.chips = card.ability.extra.chips - card.ability.extra.loss_per_click
                card:juice_up(0.2, 0.2)
                play_sound('timpani', 0.8 + math.random()*0.2, 0.5)
            end
        end
    end,
    calculate = function(self, card, context)
        if context.lob_global_click and card.ability.extra.chips > 0 then
            card.ability.extra.chips = math.max(0, card.ability.extra.chips - card.ability.extra.loss_per_click)
            card:juice_up(0.1, 0.1)
        end

        if context.joker_main and card.ability.extra.chips > 0 then
            return { chip_mod = card.ability.extra.chips }
        end
    end
}

SMODS.Joker {
    
    key = 'among_us_fart',
    loc_txt = {
        name = 'Among Us Fart',
        text = {
            "Si {C:attention}vendu{}, vous battez instantanément",
            "la blinde actuelle, sans récompenses.",
            "Perd {C:money}5${} par jokr possédés.",
        }
    },
    blueprint_compat = false,
    pools = { ["LOB"] = true, ["MEME"] = true },
    rarity = 1,
    atlas = 'among_us_fart',
    pos = { x = 0, y = 0 },
    cost = 3,
    sell_cost = 0,
    calculate = function(self, card, context)
        if context.selling_self and not context.blueprint then
            G.GAME.blind.chips = 0
            G.GAME.blind.dollars = 0
            
            local joker_count = #G.jokers.cards
            local penalty = joker_count * 5
            ease_dollars(-penalty)
            
            G.STATE = G.STATES.NEW_ROUND
            G.STATE_COMPLETE = false
            return { message = "-"..penalty.."$", colour = G.C.RED }
        end
    end
}

SMODS.Joker {
    key = 'terroriste_elegant',
    loc_txt = {
        name = 'Terroriste Gentleman',
        text = {
            "Copie l'effet du Joker",
            "à sa {C:attention}gauche{}.",
            "À la fin de la manche, {C:red}détruit{}",
            "le Joker à sa {C:attention}droite{}."
        }
    },
    blueprint_compat = true,
    pools = { ["LOB"] = true, ["MEME"] = true },
    rarity = 2,
    atlas = 'jokers_common',
    pos = { x = 2, y = 6 },
    cost = 6,

    calculate = function(self, card, context)
        local my_pos = nil
        for i=1, #G.jokers.cards do if G.jokers.cards[i] == card then my_pos = i break end end
        
        if my_pos and my_pos > 1 then
            local left_joker = G.jokers.cards[my_pos - 1]
            local blueprint_ret = SMODS.blueprint_effect(card, left_joker, context)
            if blueprint_ret then
                return blueprint_ret
            end
        end

        if context.end_of_round and not context.blueprint and not context.repetition then
            if my_pos and my_pos < #G.jokers.cards then
                local right_joker = G.jokers.cards[my_pos + 1]
                if right_joker and not right_joker.config.center.eternal and not right_joker.getting_sliced then
                    right_joker.getting_sliced = true
                    
                    play_sound('lob_snd_explosion') 
                    local x_pos = right_joker.T.x * (love.graphics.getWidth()/G.ROOM.T.w) + (right_joker.T.w/2)
                    local y_pos = right_joker.T.y * (love.graphics.getHeight()/G.ROOM.T.h) + (right_joker.T.h/2)
                    add_lob_effect("explosion", x_pos, y_pos)

                    right_joker:start_dissolve()
                    return { message = "BOOM!", colour = G.C.RED }
                end
            end
        end
    end
}

SMODS.Joker{
    key = 'subwaysurfers',
    loc_txt= {
        name = 'Subway Surfers',
        text = { "Randomly gains {C:blue}Chips{} ",
                    "and {C:red}Mult{} over time",
                    "Can randomly lose all {C:blue}Chips{} and {C:red}Mult{}",
                    "{C:inactive}(Currently {C:blue}#1#{C:inactive} Chips {C:red}#2#{C:inactive} Mult)",}
    },
    atlas = 'subwaysurfers',
    rarity = 3,
    cost = 10,
    pools = { ["LOB"] = true, ["MEME"] = true },

    pixel_size = { w = 71 , h = 96 },
    frame = 0,

    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = false,
    perishable_compat = false,

    pos = {x=0, y= 0},
    config = { extra = {chips = 1, mult = 1}},

    loc_vars = function(self, info_queue, center)
		return { vars = { center.ability.extra.chips, center.ability.extra.mult }  }
	end,

    calculate = function(self, card, context)
		if context.joker_main then
			return {
				message = "New High Score!",
				chip_mod = card.ability.extra.chips,
                mult_mod = card.ability.extra.mult,
			}
        end
    end,

    check_for_unlock = function(self, args)
        if args.type == 'test' then 
            unlock_card(self)
        end
        unlock_card(self) 
    end,
}

SMODS.Joker {
    key = 'ganondorf',
    loc_txt = {
        name = 'Ganondorf',
        text = {
            "Transforme toutes les cartes de la",
            "{C:attention}première main{} en {C:attention}Cartes Pierre{}.",
            "Leur donne une {C:dark_edition}Édition{} aléatoire."
        }
    },
    blueprint_compat = true,
    pools = { ["LOB"] = true, ["MEME"] = true },
    rarity = 1,
    atlas = 'ganondorf',
    pos = { x = 0, y = 0 },
    cost = 6,
    calculate = function(self, card, context)
    if context.before and G.GAME.current_round.hands_played == 0 then
        G.E_MANAGER:add_event(Event({
            trigger = 'before',
            delay = 0.5,
            func = function()
                for _, v in ipairs(context.scoring_hand) do
                    v:set_ability(G.P_CENTERS.m_stone, nil, true)
                    
                    local possible_editions = {'e_foil', 'e_holo', 'e_polychrome'}
					local edition = possible_editions[math.random(1, #possible_editions)]
					v:set_edition(edition, true)
                    
                    v:juice_up()
                end
                return true
            end
        }))
        
        return { message = "MOUAHAHAHAHA!", colour = G.C.RED }
    end
end
}
