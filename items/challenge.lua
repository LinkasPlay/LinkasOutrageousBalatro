G.localization = G.localization or {}
G.localization.misc = G.localization.misc or {}
G.localization.misc.v_text = G.localization.misc.v_text or {}

G.localization.misc.v_text.ch_c_no_profs = { "Aucun Professeur disponible (Jokers, Paquets, Tags)" }
G.localization.misc.v_text.ch_c_lukaspocalypse_rules = { 
    "Un Lukas (Éternel, Négatif) offert après chaque Boss Blind",
    "Aucun Joker en boutique",
    "Seuls les Jokers Élèves peuvent apparaître"
}

SMODS.Challenge {
    key = "terroriste",
    loc_txt = {
        name = "Défi Terroriste"
    },
    jokers = {
        { id = "j_lob_yanis", eternal = true, pinned = true, edition = "negative" },
        { id = "j_lob_terroriste_gentleman", eternal = true, pinned = true }
    }
}

SMODS.Challenge {
    key = "redoublement",
    loc_txt = {
        name = "Objectif Redoublement"
    },
    jokers = {
        { id = "j_lob_zoghlami", eternal = true, edition = "negative" }
    },
    rules = {
        custom = {
            { id = "no_profs" }
        }
    }
}

SMODS.Challenge {
    key = "lukaspocalypse",
    loc_txt = {
        name = "Lukaspocalypse"
    },
    rules = {
        custom = {
            { id = "lukaspocalypse_rules" }
        },
        modifiers = {
            { id = 'joker_slots', value = 0 }
        }
    }
}

local function is_joker_allowed(key)
    if key == "j_lob_entre_suceur" then return true end
    if G.GAME and G.GAME.used_jokers then
        if G.GAME.used_jokers["j_showman"] then return true end
        if G.GAME.used_jokers[key] then return false end
    end
    return true
end

local old_get_current_pool = get_current_pool
function get_current_pool(_type, _rarity, _legendary, _append)
    local pool, pool_key = old_get_current_pool(_type, _rarity, _legendary, _append)
    
    if G.GAME and (G.GAME.modifiers.no_profs or G.GAME.challenge == "c_lob_redoublement") and _type == 'Joker' then
        local filtered_pool = {}
        for _, key in ipairs(pool) do
            local center = G.P_CENTERS[key]
            if not (center and center.pools and center.pools["PROF"]) then
                if is_joker_allowed(key) then
                    table.insert(filtered_pool, key)
                end
            end
        end
        return filtered_pool, pool_key
    end

    if G.GAME and (G.GAME.modifiers.lukaspocalypse_rules or G.GAME.challenge == "c_lob_lukaspocalypse") and _type == 'Joker' then
        local eleve_pool = {}
        for key, center in pairs(G.P_CENTERS) do
            if center.set == 'Joker' and center.pools and center.pools["ELEVE"] then
                if is_joker_allowed(key) then
                    table.insert(eleve_pool, key)
                end
            end
        end
        if #eleve_pool > 0 then
            return eleve_pool, pool_key
        end
    end

    if _type == 'Joker' and pool then
        local clean_pool = {}
        for _, key in ipairs(pool) do
            if is_joker_allowed(key) then
                table.insert(clean_pool, key)
            end
        end
        if #clean_pool > 0 then
            return clean_pool, pool_key
        end
    end

    return pool, pool_key
end

local old_create_card = create_card
function create_card(_type, area, skip_materialize, soulable, forced_key, key_append, custom_deck, skin)
    if G.GAME and G.GAME.challenge == "c_lob_lukaspocalypse" and _type == 'Joker' and area == G.shop_jokers then
        return nil
    end
    return old_create_card(_type, area, skip_materialize, soulable, forced_key, key_append, custom_deck, skin)
end

local old_start_run = Game.start_run
function Game:start_run(args)
    old_start_run(self, args)
    if G.GAME.challenge == "c_lob_lukaspocalypse" then
        local lukas_jokers = {}
        for key, center in pairs(G.P_CENTERS) do
            if center.set == 'Joker' and center.pools and center.pools["LUKAS"] then
                table.insert(lukas_jokers, key)
            end
        end
        if #lukas_jokers > 0 then
            local chosen_key = pseudorandom_element(lukas_jokers, pseudoseed("lukaspocalypse_start"))
            local card = create_card('Joker', G.jokers, true, nil, nil, nil, chosen_key)
            card.eternal = true
            card:set_edition({ negative = true }, true)
            card:add_to_deck()
            G.jokers:emplace(card)
        end
    end
end

local old_blind_defeat = Blind.defeat
function Blind:defeat(silent)
    old_blind_defeat(self, silent)
    if G.GAME and G.GAME.challenge == "c_lob_lukaspocalypse" and self.boss then
        local lukas_jokers = {}
        for key, center in pairs(G.P_CENTERS) do
            if center.set == 'Joker' and center.pools and center.pools["LUKAS"] then
                table.insert(lukas_jokers, key)
            end
        end
        if #lukas_jokers > 0 then
            local chosen_key = pseudorandom_element(lukas_jokers, pseudoseed("lukaspocalypse_boss"))
            local card = create_card('Joker', G.jokers, true, nil, nil, nil, chosen_key)
            card.eternal = true
            card:set_edition({ negative = true }, true)
            card:add_to_deck()
            G.jokers:emplace(card)
        end
    end
end