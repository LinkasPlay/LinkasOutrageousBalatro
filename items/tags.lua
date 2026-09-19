-- tag dragon : désactive l'effet du prochain boss blind
-- tag invisible : duplique la prochaine chose achetée (joker, tarot, packs, etc sauf vouchers)
-- tag lukas : donne un joker lukas (simple) négatif mais -1 hands
-- tag révision : donne un paquet math, physique et informatique
-- tag maléfique : créé un joker professeur aléatoire
-- tag undermine : retire tout l'argent mais tout coûte 1 $ en moins
-- tag clair obscur : donne un joker aléatoire entre maelle, lune, sock and buskin + le prochain boss devient renoir
-- tag boumiz : 1 chance sur 3 de créer Seigneur Boumiz, sinon Boumiz normal
-- tag triforce : créé soit Open To Lan, soit une Soul, soit un Rituel du Lukas, -1 défausse

local base_set_cost = Card.set_cost
function Card:set_cost()
    base_set_cost(self)
    if self.cost and self.cost > 0 and G.GAME and G.GAME.lob_flat_discount and G.GAME.lob_flat_discount > 0 then
        self.cost = math.max(1, self.cost - G.GAME.lob_flat_discount)
    end
end

SMODS.Atlas {
    key = "LOB_Tags",
    path = "tags.png",
    px = 34,
    py = 34
}

-- TAG DRAGON : Désactive le prochain Boss
SMODS.Tag {
    key = "lob_dragon",
    atlas = "LOB_Tags", pos = { x = 0, y = 0 },
    loc_txt = { name = "Tag Dragon", text = { "Désactive l'effet de", "la prochaine {C:attention}Blinde de Boss{}" } },
    apply = function(self, tag, context)
        if context.type == 'immediate' then
            G.GAME.lob_dragon_pending = true
            tag.triggered = true
            return true
        end
    end
}

-- TAG INVISIBLE : Duplique le prochain achat
SMODS.Tag {
    key = "lob_invisible",
    atlas = "LOB_Tags", pos = { x = 1, y = 0 },
    loc_txt = { name = "Tag Invisible", text = { "Le prochain objet acheté", "est {C:attention}dupliqué{}" } },

    init = function(self)
        local buy_ref = G.FUNCS.buy_from_shop
        G.FUNCS.buy_from_shop = function(e)
            local res = buy_ref(e)
            if res ~= false then
                for i = 1, #G.GAME.tags do
                    if G.GAME.tags[i].key == 'tag_lob_lob_invisible' then
                        G.GAME.tags[i]:apply_to_run({ type = 'item_bought', card = e.config.ref_table })
                    end
                end
            end
            return res
        end
    end,

    apply = function(self, tag, context)
        if context.type == 'item_bought' and context.card then
            local lock = tag.ID
            G.CONTROLLER.locks[lock] = true
            tag:yep('+', G.C.WHITE, function()
                local copy = copy_card(context.card)
                copy:add_to_deck()

                if context.card.area then
                    context.card.area:emplace(copy)
                else
                    if copy.ability.set == 'Joker' then G.jokers:emplace(copy)
                    else G.consumeables:emplace(copy) end
                end

                G.CONTROLLER.locks[lock] = nil
                return true
            end)
            tag.triggered = true
            return true
        end
    end
}

-- TAG LUKAS : Lukas Négatif mais -1 main
SMODS.Tag {
    key = "lob_lukas",
    atlas = "LOB_Tags", pos = { x = 2, y = 0 },
    loc_txt = { name = "Tag Lukas", text = { "Donne un {C:dark_edition}Lukas Négatif{}", "mais {C:red}-1{} main par manche" } },
    apply = function(self, tag, context)
        if context.type == 'immediate' then
            tag:yep('+', G.C.DARK_EDITION, function()
                local card = create_card('Joker', G.jokers, nil, nil, nil, nil, 'j_lob_lukas')
                card:set_edition('e_negative', true)
                card:add_to_deck()
                G.jokers:emplace(card)
                G.GAME.round_resets.hands = G.GAME.round_resets.hands - 1
                return true
            end)
            tag.triggered = true
            return true
        end
    end
}

-- TAG RÉVISION : Ouvre Math, Physique et Info à la suite
SMODS.Tag {
    key = "lob_revision",
    atlas = "LOB_Tags", pos = { x = 3, y = 0 },
    loc_txt = { name = "Tag Révision", text = { "Ouvre un paquet {C:attention}Math{},", "{C:attention}Physique{} et {C:attention}Info{} à la suite" } },

    apply = function(self, tag, context)
        if context.type == 'immediate' then
            tag:yep('+', G.C.FILTER, function()
                local packs = {'p_lob_booster_math', 'p_lob_booster_physique', 'p_lob_booster_info'}
                G.GAME.lob_revision_queue = packs
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.2,
                    func = function() return lob_open_next_revision_pack() end
                }))
                return true
            end)
            tag.triggered = true
            return true
        end
    end
}

function lob_open_next_revision_pack()
    if G.STATE ~= G.STATES.SHOP and G.STATE ~= G.STATES.BLIND_SELECT then
        return false
    end
    if G.pack_cards and G.pack_cards.cards and #G.pack_cards.cards > 0 then
        return false
    end

    local queue = G.GAME.lob_revision_queue
    if not queue or #queue == 0 then
        return true
    end

    local p_key = table.remove(queue, 1)
    local center = G.P_CENTERS[p_key]
    if not center then
        return lob_open_next_revision_pack()
    end

    local booster = Card(G.play.T.x, G.play.T.y, G.CARD_W * 1.27, G.CARD_H * 1.27, G.P_CARDS.empty, center)
    if not booster then
        return lob_open_next_revision_pack()
    end
    booster.cost = 0
    booster.states.visible = false
    G.FUNCS.use_card({ config = { ref_table = booster } })

    if #queue > 0 then
        G.E_MANAGER:add_event(Event({
            trigger = 'condition',
            blocking = true,
            condition = function()
                return G.STATE ~= G.STATES.TAROT_PACK and G.STATE ~= G.STATES.PLANET_PACK
                    and G.STATE ~= G.STATES.SMODS_BOOSTER_OPENED
                    and (G.pack_cards == nil or G.pack_cards.cards == nil or #G.pack_cards.cards == 0)
            end
        }))
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function() return lob_open_next_revision_pack() end
        }))
    end

    return true
end

-- TAG MALÉFIQUE : Joker Professeur aléatoire
SMODS.Tag {
    key = "lob_malefique",
    atlas = "LOB_Tags", pos = { x = 4, y = 0 },
    loc_txt = { name = "Tag Maléfique", text = { "Crée un {C:attention}Joker Professeur{} aléatoire" } },
    apply = function(self, tag, context)
        if context.type == 'immediate' then
            tag:yep('+', G.C.PURPLE, function()
                local card = SMODS.create_card({set = 'PROF', area = G.jokers, legendary = false})
                card:add_to_deck()
                G.jokers:emplace(card)
                return true
            end)
            tag.triggered = true
            return true
        end
    end
}

-- TAG UNDERMINE : Tout à 1$ de moins mais plus d'argent
SMODS.Tag {
    key = "lob_undermine",
    atlas = "LOB_Tags", pos = { x = 5, y = 0 },
    loc_txt = { name = "Undermine", text = { "Retire tout l'argent,", "les objets coûtent {C:money}1${} de moins", "(minimum 1$)" } },
    apply = function(self, tag, context)
        if context.type == 'immediate' then
            tag:yep('+', G.C.MONEY, function()
                ease_dollars(-G.GAME.dollars, true)
                G.GAME.lob_flat_discount = (G.GAME.lob_flat_discount or 0) + 1

                if G.I.CARD then
                    for _, v in pairs(G.I.CARD) do
                        if v.set_cost then v:set_cost() end
                    end
                end
                return true
            end)
            tag.triggered = true
            return true
        end
    end
}

-- TAG CLAIR OBSCUR : Maelle/Lune/Sock + Boss Renoir
SMODS.Tag {
    key = "lob_clairobscur",
    atlas = "LOB_Tags", pos = { x = 0, y = 1 },
    loc_txt = { name = "Tag Clair-Obscur", text = { "Donne {C:attention}Maëlle{}, {C:attention}Lune{} ou {C:attention}Sock and Buskin{}", "Le prochain Boss devient {C:attention}Renoir{}" } },
    apply = function(self, tag, context)
        if context.type == 'immediate' then
            local available_bosses = {}
            for k, v in pairs(G.P_BLINDS) do
                if v.boss and k ~= G.GAME.bosses_used[tostring(G.GAME.round_resets.ante)] then
                    table.insert(available_bosses, k)
                end
            end
            local new_boss = pseudorandom_element(available_bosses, pseudoseed('clair_obscur'))
            G.GAME.bosses_used[tostring(G.GAME.round_resets.ante)] = new_boss

            if G.STATE == G.STATES.BLIND_SELECT then
                G.GAME.round_resets.blind_choices.Boss = new_boss
            end
            return true
        end
    end
}

-- TAG BOUMIZ : Seigneur Boumiz (1/3) ou normal
SMODS.Tag {
    key = "lob_boumiz",
    atlas = "LOB_Tags", pos = { x = 1, y = 1 },
    loc_txt = { name = "Tag Boumiz", text = { "{C:green}1 chance sur 3{} d'obtenir", "{C:legendary}Seigneur Boumiz{}, sinon {C:attention}Boumiz{}" } },
    apply = function(self, tag, context)
        if context.type == 'immediate' then
            tag:yep('+', G.C.RED, function()
                local key = (math.random(3) == 1) and 'j_lob_seigneur_boumiz' or 'j_lob_boumiz'
                local card = create_card('Joker', G.jokers, nil, nil, nil, nil, key)
                card:add_to_deck()
                G.jokers:emplace(card)
                return true
            end)
            tag.triggered = true
            return true
        end
    end
}

-- TAG TRIFORCE : Open To Lan, Soul ou Rituel, -1 défausse
SMODS.Tag {
    key = "lob_triforce",
    atlas = "LOB_Tags", pos = { x = 2, y = 1 },
    loc_txt = { name = "Tag Triforce", text = { "Donne {C:spectral}Open To Lan{}, {C:spectral}Soul{} ou {C:spectral}Rituel{}", "mais {C:red}-1{} défausse par manche" } },
    apply = function(self, tag, context)
        if context.type == 'immediate' then
            tag:yep('+', G.C.SECONDARY_SET.Spectral, function()
                local keys = {'c_lob_opentolan', 'c_soul', 'c_lob_rituel_lukas'}
                local card = create_card('Spectral', G.consumeables, nil, nil, nil, nil, keys[math.random(#keys)])
                card:add_to_deck()
                G.consumeables:emplace(card)
                G.GAME.round_resets.discards = G.GAME.round_resets.discards - 1
                return true
            end)
            tag.triggered = true
            return true
        end
    end
}