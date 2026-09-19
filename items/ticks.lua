lob = lob or {}
lob.ticks = 0
lob.dt_counter = 0

local animated_jokers = {
    { key = 'j_lob_among_us_fart',      frames = 143, w = 12 },
    { key = 'j_lob_ganondorf',          frames = 40,  w = 7  },
    { key = 'j_lob_singe_ambulancier',  frames = 134, w = 12 },
    { key = 'j_lob_singe_balatro',      frames = 128, w = 12 },
    { key = 'j_lob_singe_deprime',      frames = 41,  w = 7  },
    { key = 'j_lob_sus_balatro',        frames = 31,  w = 6  },
    { key = 'j_lob_subwaysurfers',      frames = 256, w = 16 },
}

local game_update_ref = Game.update
function Game:update(dt)
    game_update_ref(self, dt)

    lob.dt_counter = (lob.dt_counter or 0) + dt
    while lob.dt_counter >= 0.01 do
        lob.ticks = (lob.ticks or 0) + 1
        lob.dt_counter = lob.dt_counter - 0.01

        if math.fmod(lob.ticks, 8) == 0 then
            for _, j in ipairs(animated_jokers) do
                local center = G.P_CENTERS[j.key]
                if center then
                    center.anim_frame = (center.anim_frame or 0) + 1
                    if center.anim_frame >= j.frames then 
                        center.anim_frame = 0 
                    end

                    center.pos.x = math.fmod(center.anim_frame, j.w)
                    center.pos.y = math.floor(center.anim_frame / j.w)
                end
            end
        end
    end
end

local function lob_merge_joker_effect(base, extra)
    if not extra then return base end
    if not base then return extra end
    for k, v in pairs(extra) do
        if k == 'Xmult_mod' or k == 'x_mult' then
            base[k] = (base[k] or 1) * v
        elseif k == 'chip_mod' or k == 'mult_mod' or k == 'x_chips' or k == 'dollars' then
            base[k] = (base[k] or 0) + v
        elseif base[k] == nil then
            base[k] = v
        end
    end
    return base
end

local lob_joker_retrigger_ref = Card.calculate_joker
function Card:calculate_joker(context)
    local ret = lob_joker_retrigger_ref(self, context)

    if context.joker_main and self.ability and self.ability.lob_booster_xmult and self.ability.lob_booster_xmult > 1 then
        if ret then
            ret.x_mult = (ret.x_mult or 1) * self.ability.lob_booster_xmult
        else
            ret = {
                message = "X" .. self.ability.lob_booster_xmult,
                Xmult_mod = self.ability.lob_booster_xmult,
                colour = G.C.MULT
            }
        end
    end

    if context.joker_main and not context.blueprint and G.jokers and G.jokers.cards and self.config.center.key ~= 'j_lob_seigneur_boumiz' and self.config.center.key ~= 'j_lob_entre_suceur' then
        local extra_triggers = 0

        if self.config.center.pools and self.config.center.pools["PHYSIQUE"] then
            for _, j in ipairs(G.jokers.cards) do
                if j.config.center.key == 'j_lob_seigneur_boumiz' then
                    extra_triggers = extra_triggers + 1
                end
            end
        end

        local suceurs_pos = {}
        for i, c in ipairs(G.jokers.cards) do
            if c.config.center.key == 'j_lob_entre_suceur' then
                table.insert(suceurs_pos, i)
            end
        end
        if #suceurs_pos >= 2 then
            local pos1, pos2 = suceurs_pos[1], suceurs_pos[#suceurs_pos]
            local my_pos = nil
            for i, c in ipairs(G.jokers.cards) do if c == self then my_pos = i break end end
            if my_pos and my_pos > pos1 and my_pos < pos2 then
                extra_triggers = extra_triggers + 1
            end
        end

        for i = 1, extra_triggers do
            local extra_ret = lob_joker_retrigger_ref(self, context)
            if extra_ret then
                card_eval_status_text(self, 'extra', nil, nil, nil, { message = "Suceur !", colour = G.C.PURPLE })
                ret = lob_merge_joker_effect(ret, extra_ret)
            end
        end
    end

    return ret
end

local old_l_cursor_press = Controller.L_cursor_press
function Controller:L_cursor_press(x, y)
    old_l_cursor_press(self, x, y)
    if G.jokers and G.jokers.cards then
        SMODS.calculate_context({ lob_global_click = true })
    end
end

local destroy_ref = Card.start_dissolve
function Card:start_dissolve(delay, ...)
    SMODS.calculate_context({ lob_card_destroyed = true, cards_destroyed = { self } })
    return destroy_ref(self, delay, ...)
end

