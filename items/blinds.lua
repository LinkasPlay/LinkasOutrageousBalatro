SMODS.Atlas {
    key = "lob_blinds",
    path = "blinds.png",
    px = 34,
    py = 34,
    frames = 21,
    atlas_table = 'ANIMATION_ATLAS'
}

SMODS.Atlas {
    key = "lob_anne_geante",
    path = "anne_geante.png",
    px = 546,
    py = 633
}

local function is_in_battle_state()
    return G.STATE == G.STATES.SELECTING_HAND 
        or G.STATE == G.STATES.PLAY_TAROT 
        or G.STATE == G.STATES.HAND_PLAYED 
        or G.STATE == G.STATES.DRAW_TO_HAND
end

SMODS.Sound {
    key = "music_irl_boss",
    path = "irl_boss.ogg",
    pitch = 1,
    select_music_track = function()
        if G.GAME and G.GAME.blind and is_in_battle_state() then
            local n = G.GAME.blind.config.blind.key
            local is_boss = (n == "bl_lob_boss_ds_maths" or n == "bl_lob_boss_ds_physique" or n == "bl_lob_boss_ds_info" or 
                             n == "bl_lob_boss_job" or n == "bl_lob_boss_rera" or n == "bl_lob_boss_gemini" or n == "bl_lob_boss_anne_christine")
            if is_boss then return 100 end 
        end
    end
}

SMODS.Sound {
    key = "music_mc_boss",
    path = "mc_boss.ogg",
    pitch = 1,
    select_music_track = function()
        if G.GAME and G.GAME.blind and is_in_battle_state() then
            local n = G.GAME.blind.config.blind.key
            local is_boss = (n == "bl_lob_boss_tentacule" or n == "bl_lob_boss_phantom" or n == "bl_lob_boss_speedrun")
            if is_boss then return 100 end
        end
    end
}

SMODS.Sound {
    key = "music_renoir_boss",
    path = "Renoir.ogg",
    pitch = 1,
    select_music_track = function()
        if G.GAME and G.GAME.blind and is_in_battle_state() then
            if G.GAME.blind.config.blind.key == "bl_lob_boss_renoir" then
                return 100
            end
        end
    end
}

SMODS.Blind {
    name = "boss_renoir",
    key = "boss_renoir",
    atlas = "lob_blinds",
    pos = { y = 0 },
    dollars = 5,
    mult = 2,
    loc_txt = { name = 'Renoir', text = { 'Toutes les 3 secondes,', 'désactive la carte de', 'plus haute valeur en main' } },
    boss = { min = 1 },
    boss_colour = HEX('e74c3c'),

    debuff_card = function(self, card, from_blind)
        if card.lob_renoir_debuff and not G.GAME.blind.disabled then
            return true
        end
        return false
    end,
    disable = function(self)
        for _, c in ipairs(G.hand.cards) do c.lob_renoir_debuff = false; c:set_debuff(false) end
    end,
    defeat = function(self)
        for _, c in ipairs(G.hand.cards) do c.lob_renoir_debuff = false; c:set_debuff(false) end
    end
}

SMODS.Blind {
    name = "boss_tentacule",
    key = "boss_tentacule",
    atlas = "lob_blinds",
    pos = { y = 1 },
    dollars = 5,
    mult = 2,
    loc_txt = {
        name = 'Tentacule',
        text = {
            '-1 taille de main après',
            'chaque main jouée'
        }
    },
    boss = { min = 1 },
    boss_colour = HEX('8e44ad'),

    set_blind = function(self)
        G.GAME.lob_tentacule_reductions = 0
    end,

    press_play = function(self)
        if not G.GAME.blind.disabled then
            G.hand:change_size(-1)
            G.GAME.lob_tentacule_reductions = (G.GAME.lob_tentacule_reductions or 0) + 1
            play_sound('timpani')
        end
    end,

    disable = function(self)
        if G.GAME.lob_tentacule_reductions and G.GAME.lob_tentacule_reductions > 0 then
            G.hand:change_size(G.GAME.lob_tentacule_reductions)
            G.GAME.lob_tentacule_reductions = 0
        end
    end,

    defeat = function(self)
        if G.GAME.lob_tentacule_reductions and G.GAME.lob_tentacule_reductions > 0 then
            G.hand:change_size(G.GAME.lob_tentacule_reductions)
            G.GAME.lob_tentacule_reductions = 0
        end
    end,
}

SMODS.Blind {
    name = "boss_phantom",
    key = "boss_phantom",
    atlas = "lob_blinds",
    pos = { y = 2 },
    dollars = 5,
    mult = 2,
    loc_txt = {
        name = 'Phantom',
        text = {
            'Désactive entre 1 et 3',
            'cartes aléatoires',
            'parmi celles jouées'
        }
    },
    boss = { min = 1 },
    boss_colour = HEX('7f8c8d'),

    press_play = function(self)
        if not G.GAME.blind.disabled then
            local num_to_debuff = math.random(1, 3)
            local valid_cards = {}
            
            for i = 1, #G.play.cards do
                if not G.play.cards[i].debuff then 
                    table.insert(valid_cards, G.play.cards[i]) 
                end
            end

            for i = 1, math.min(num_to_debuff, #valid_cards) do
                local random_card = pseudorandom_element(valid_cards, pseudoseed('phantom'..i))
                
                if random_card then
                    random_card:set_debuff(true)
                    random_card:juice_up()
                    
                    for j = 1, #valid_cards do
                        if valid_cards[j] == random_card then
                            table.remove(valid_cards, j)
                            break
                        end
                    end
                end
            end
        end
    end
}

SMODS.Blind {
    name = "boss_ds_maths",
    key = "boss_ds_maths",
    atlas = "lob_blinds",
    pos = { y = 3 },
    dollars = 5,
    mult = 2,
    loc_txt = { 
        name = 'DS Maths', 
        text = { 
            'Désactive tous les', 
            'Jokers Maths' 
        }
    },
    boss = { min = 2 },
    boss_colour = HEX('2980b9'),

    recalc_debuff = function(self, card)
        for i = 1, #G.jokers.cards do
            if G.jokers.cards[i].config.center.pools and G.jokers.cards[i].config.center.pools["MATH"] and not G.GAME.blind.disabled then
                G.jokers.cards[i]:set_debuff(true)
            end
        end
    end,

    disable = function(self)
        for i = 1, #G.jokers.cards do
            G.jokers.cards[i]:set_debuff(false)
        end
    end,

    defeat = function(self)
        for i = 1, #G.jokers.cards do
            G.jokers.cards[i]:set_debuff(false)
        end
    end,
}

SMODS.Blind {
    name = "boss_ds_physique",
    key = "boss_ds_physique",
    atlas = "lob_blinds",
    pos = { y = 4 },
    dollars = 5,
    mult = 2,
    loc_txt = { 
        name = 'DS Physique', 
        text = { 
            'Désactive tous les', 
            'Jokers Physique' 
        }
    },
    boss = { min = 2 },
    boss_colour = HEX('c0392b'),

    recalc_debuff = function(self, card)
        for i = 1, #G.jokers.cards do
            if G.jokers.cards[i].config.center.pools and G.jokers.cards[i].config.center.pools["PHYSIQUE"] and not G.GAME.blind.disabled then
                G.jokers.cards[i]:set_debuff(true)
            end
        end
    end,

    disable = function(self)
        for i = 1, #G.jokers.cards do
            G.jokers.cards[i]:set_debuff(false)
        end
    end,

    defeat = function(self)
        for i = 1, #G.jokers.cards do
            G.jokers.cards[i]:set_debuff(false)
        end
    end,
}

SMODS.Blind {
    name = "boss_ds_info",
    key = "boss_ds_info",
    atlas = "lob_blinds",
    pos = { y = 5 },
    dollars = 5,
    mult = 2,
    loc_txt = { 
        name = 'DS Info', 
        text = { 
            'Désactive tous les', 
            'Jokers Info' 
        }
    },
    boss = { min = 2 },
    boss_colour = HEX('27ae60'),

    recalc_debuff = function(self, card)
        for i = 1, #G.jokers.cards do
            if G.jokers.cards[i].config.center.pools and G.jokers.cards[i].config.center.pools["INFO"] and not G.GAME.blind.disabled then
                G.jokers.cards[i]:set_debuff(true)
            end
        end
    end,

    disable = function(self)
        for i = 1, #G.jokers.cards do
            G.jokers.cards[i]:set_debuff(false)
        end
    end,

    defeat = function(self)
        for i = 1, #G.jokers.cards do
            G.jokers.cards[i]:set_debuff(false)
        end
    end,
}

SMODS.Blind {
    name = "boss_job",
    key = "boss_job",
    atlas = "lob_blinds",
    pos = { y = 6 },
    dollars = 5,
    mult = 2,
    loc_txt = {
        name = 'Job Application',
        text = {
            'Toutes les cartes',
            'sans amélioration',
            'sont désactivées'
        }
    },
    boss = { min = 1 },
    boss_colour = HEX('e67e22'),

    debuff_card = function(self, card, from_blind)
        if card.area ~= G.jokers and card.config.center == G.P_CENTERS.c_base and not G.GAME.blind.disabled then
            return true
        end
        return false
    end
}

SMODS.Blind {
    name = "boss_speedrun",
    key = "boss_speedrun",
    atlas = "lob_blinds",
    pos = { y = 7 },
    dollars = 5,
    mult = 2,
    loc_txt = {
        name = 'Speedrun',
        text = {
            'Les jetons requis',
            'augmentent continuellement',
            'avec le temps !'
        }
    },
    boss = { min = 1 },
    boss_colour = HEX('2ecc71'),

    set_blind = function(self)
        G.GAME.lob_speedrun_base_chips = G.GAME.blind.chips
    end,
}

SMODS.Blind {
    name = "boss_gemini",
    key = "boss_gemini",
    atlas = "lob_blinds",
    pos = { y = 8 },
    dollars = 5,
    mult = 2,
    loc_txt = {
        name = 'Gemini',
        text = {
            'Les cartes piochées',
            'après une défausse',
            'sont faces cachées'
        }
    },
    boss = { min = 1 },
    boss_colour = HEX('4a90e2'),

    drawn_to_hand = function(self, card)
        if not card then return end
        if G.GAME.lob_is_discarding and not G.GAME.blind.disabled then
            card.facing = 'back'
            card.sprite_facing = 'back'
            card.flip_status = true
        end
    end
}

SMODS.Blind {
    name = "boss_rera",
    key = "boss_rera",
    atlas = "lob_blinds",
    pos = { y = 9 },
    dollars = 5,
    mult = 2,
    loc_txt = {
        name = 'RER A',
        text = {
            "Les jokers sont",
            "lus à l'envers"
        }
    },
    boss = { min = 1 },
    boss_colour = HEX('e74c3c'),

    press_play = function(self)
        if not G.GAME.blind.disabled then
            local n = #G.jokers.cards
            for i = 1, math.floor(n / 2) do
                G.jokers.cards[i], G.jokers.cards[n - i + 1] = G.jokers.cards[n - i + 1], G.jokers.cards[i]
            end
            G.jokers:set_ranks()
            G.jokers:align_cards()
            play_sound('card1', 0.8)
        end
    end
}

SMODS.Blind {
    name = "boss_anne_christine",
    key = "boss_anne_christine",
    atlas = "lob_blinds",
    pos = { y = 10 },
    dollars = 5,
    mult = 2,
    loc_txt = {
        name = 'Anne Christine',
        text = {
            'Désactive tous les',
            'Jokers Élèves'
        }
    },
    boss = { min = 1 },
    boss_colour = HEX('ecf0f1'),

    recalc_debuff = function(self, card)
        for i = 1, #G.jokers.cards do
            if G.jokers.cards[i].config.center.pools and G.jokers.cards[i].config.center.pools["ELEVE"] and not G.GAME.blind.disabled then
                G.jokers.cards[i]:set_debuff(true)
            end
        end
    end,

    disable = function(self)
        for i = 1, #G.jokers.cards do
            G.jokers.cards[i]:set_debuff(false)
        end
    end,

    defeat = function(self)
        for i = 1, #G.jokers.cards do
            G.jokers.cards[i]:set_debuff(false)
        end
    end,
}

local update_ref = Game.update
function Game.update(self, dt)
    update_ref(self, dt)
    
    if G.GAME and G.STATE == G.STATES.SELECTING_HAND and G.GAME.blind then
        local boss_key = G.GAME.blind.config.blind.key

        if boss_key == 'bl_lob_boss_renoir' and not G.GAME.blind.disabled then
            G.GAME.lob_renoir_timer = (G.GAME.lob_renoir_timer or 0) + dt
            if G.GAME.lob_renoir_timer >= 3 then
                G.GAME.lob_renoir_timer = 0
                
                local best_card = nil
                local max_val = -1
                if G.hand and G.hand.cards then
                    for i = 1, #G.hand.cards do
                        local card = G.hand.cards[i]
                        if not card.lob_renoir_debuff and card.base.nominal > max_val then
                            max_val = card.base.nominal
                            best_card = card
                        end
                    end
                end
                
                if best_card then
                    best_card.lob_renoir_debuff = true 
                    best_card:set_debuff(true)
                    best_card:juice_up(0.5, 0.5)
                    play_sound('tarot1')
                end
            end
        end

        if boss_key == 'bl_lob_boss_speedrun' and not G.GAME.blind.disabled then
            G.GAME.lob_speedrun_timer = (G.GAME.lob_speedrun_timer or 0) + dt
            if G.GAME.lob_speedrun_timer >= 1 then 
                G.GAME.lob_speedrun_timer = 0
                if G.GAME.lob_speedrun_base_chips then
                    local linear_increase = math.max(1, math.floor(G.GAME.lob_speedrun_base_chips * 0.01))
                    G.GAME.blind.chips = G.GAME.blind.chips + linear_increase
                    G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
                    
                    local blind_ui = G.HUD_blind and G.HUD_blind:get_UIE_by_ID('blind_chips')
                    if blind_ui and blind_ui.config.text then
                        blind_ui.config.text = G.GAME.blind.chip_text
                        if blind_ui.children and blind_ui.children[1] then
                            blind_ui.children[1].config.text = G.GAME.blind.chip_text
                        end
                    end
                    
                    if G.hand_text_area and G.hand_text_area.blind_chips then
                        G.hand_text_area.blind_chips:juice_up()
                    end
                end
            end
        end
    end
end

local draw_ref = Game.draw
function Game.draw(self)
    draw_ref(self)
    
    if G.GAME and G.GAME.blind and G.GAME.blind.name == 'boss_anne_christine' and not G.GAME.blind.disabled then
        if G.STATE == G.STATES.SELECTING_HAND or G.STATE == G.STATES.PLAY_TAROT then
            if G.ASSET_ATLAS["lob_anne_geante"] then
                local tex = G.ASSET_ATLAS["lob_anne_geante"]
                if tex.image then
                    love.graphics.setColor(1, 1, 1, 0.8)
                    
                    local screen_w = love.graphics.getWidth()
                    local screen_h = love.graphics.getHeight()
                    
                    local scale_x = (screen_w / tex.px) * 2
                    local scale_y = (screen_h / tex.py) * 2
                    
                    love.graphics.draw(tex.image, 0, 0, 0, scale_x, scale_y)
                    
                    love.graphics.setColor(1, 1, 1, 1)
                end
            end
        end
    end
end

local alias_discard = G.FUNCS.discard_cards_from_highlighted
G.FUNCS.discard_cards_from_highlighted = function(e, hook)
    if G.GAME then G.GAME.lob_is_discarding = true end
    alias_discard(e, hook)
end

local alias_play = G.FUNCS.play_cards_from_highlighted
G.FUNCS.play_cards_from_highlighted = function(e, hook)
    if G.GAME then G.GAME.lob_is_discarding = false end
    alias_play(e, hook)
end