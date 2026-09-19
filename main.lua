--- STEAMODDED HEADER
--- MOD_NAME: Linkas' Outrageous Ballatro
--- MOD_ID: linkasobalatro
--- MOD_AUTHOR: Linkas
--- MOD_DESCRIPTION: W mod.
--- PREFIX: lob
----------------------------------------------------------
----------- MOD CODE -------------------------------------

LinkasOBAlatro = LinkasOBAlatro or {}
dev_mode = true

assert(SMODS.load_file("ui.lua"))()

LinkasOBAlatro.hastalisman = next(SMODS.find_mod("Talisman")) ~= nil
if LinkasOBAlatro.hastalisman then
    print("[LOB] Talisman détecté → compatibilité activée")
else
    print("[LOB] Pas de Talisman → mode standard")
end

function tNum(number)
    if LinkasOBAlatro.hastalisman then
        return to_big(number)
    end
    return number
end

function LOB_plain_num(value)
    if type(value) == "number" then
        return value
    end
    if type(value) == "table" then
        if value.to_number then
            local ok, n = pcall(function() return value:to_number() end)
            if ok and type(n) == "number" then return n end
        end
        if to_number then
            local ok, n = pcall(to_number, value)
            if ok and type(n) == "number" then return n end
        end
        local ok, n = pcall(function() return tonumber(tostring(value)) end)
        if ok and n then return n end
    end
    return 0
end

G.C.LOB_BLUE   = HEX("4a90e2")
G.C.LOB_RED    = HEX("e74c3c")
G.C.LOB_GREEN  = HEX("27ae60")
G.C.LOB_WHITE  = HEX("a5a5a5")

SMODS.current_mod.description_loc_vars = function()
    return {
        background_colour = G.C.CLEAR,
        text_colour = G.C.WHITE,
        scale = 1.3,
        shadow = true
    }
end

local mod_path = SMODS.current_mod.path
LinkasOBAlatro.path = mod_path
LinkasOBAlatro.config = SMODS.current_mod.config or {}

local files = NFS.getDirectoryItems(mod_path .. "items")
for _, file in ipairs(files) do
	print("[LOB] Loading lua file " .. file)
	local f, err = SMODS.load_file("items/" .. file)
	if err then
		error(err)
	end
	f()
end

local files = NFS.getDirectoryItems(mod_path .. "libs/")
for _, file in ipairs(files) do
	print("[LOB] Loading lib file " .. file)
	local f, err = SMODS.load_file("libs/" .. file)
	if err then
		error(err)
	end
	f()
end

local files = NFS.getDirectoryItems(mod_path .. "localization")
for _, file in ipairs(files) do
	print("[LOB] Loading localization file " .. file)
	local f, err = SMODS.load_file("localization/" .. file)
	if err then
		error(err)
	end
	f()
end

local custom_pools = {
    { key = "LUKAS", default = "j_joker", vanilla = "j_joker" },
    { key = "ELEVE", default = "j_mime", vanilla = "j_mime" },
    { key = "MATH", default = "j_fibonacci", vanilla = "j_fibonacci" },
    { key = "PROF", default = "j_scholar", vanilla = "j_scholar" },
    { key = "INFO", default = "j_blueprint", vanilla = "j_blueprint" },
    { key = "EXERCISE", default = "j_brainstorm", vanilla = "j_brainstorm" },
    { key = "PHYSIQUE", default = "j_hanging_chad", vanilla = "j_hanging_chad" },
    { key = "MINECRAFT", default = "j_dice", vanilla = "j_dice" }
}

for _, pool_data in ipairs(custom_pools) do
    SMODS.ObjectType({
        key = pool_data.key,
        default = pool_data.default,
        cards = {},
        inject = function(self)
            SMODS.ObjectType.inject(self)

            if G.P_CENTERS[pool_data.vanilla] then
                table.insert(self.cards, G.P_CENTERS[pool_data.vanilla])
            end

            for k, v in pairs(G.P_CENTERS) do
                if v.set == "Joker" and v.pools and v.pools[pool_data.key] then
                    table.insert(self.cards, v)
                end
            end
        end
    })
end

-- Deck Cy-Tech : ne filtre plus au niveau "peut-on créer un booster" (ça bloquait TOUS les
-- boosters, y compris les tiens) mais au niveau du pool de boosters lui-même.
local old_get_current_pool = get_current_pool
function get_current_pool(_type, _rarity, _legendary, _key_append, _initial)
    local pool, weight = old_get_current_pool(_type, _rarity, _legendary, _key_append, _initial)
    if _type == 'Booster' and G.GAME and G.GAME.modifiers and G.GAME.modifiers.cytech_only then
        local filtered = {}
        for _, center in ipairs(pool or {}) do
            if center.key and string.find(center.key, "lob") then
                table.insert(filtered, center)
            end
        end
        if #filtered > 0 then
            return filtered, weight
        end
    end
    return pool, weight
end

SMODS.Sound {
    key = "menu_music",
    path = "menu.ogg",
    pitch = 1,
    select_music_track = function()
        if G.STATE == G.STATES.MENU then return 100 end
    end
}

G.E_MANAGER:add_event(Event({
    trigger = 'after',
    delay = 0,
    func = function()
        if G.STATE ~= G.STATES.MENU and G.MUSIC and G.MUSIC.current == "menu_music" then
            play_music('default_menu_music')
        end
        return true
    end
}))

local prof_jokers_keys = {
    'j_lob_el_amine_khalid',
    'j_fabien_piguet',
    'j_lob_akridas_morel_panayotis',
    'j_lob_nguyen',
    'j_lob_aranciaba',
    'j_lob_batiti',
    'j_lob_zoghlami',
    'j_lob_ludivic_cesbron',
    'j_lob_banica_teodore',
    'j_lob_romuald',
    'j_lob_mohamed_adache',
    'j_lob_radjesvarane',
    'j_haktar',
    'j_seigneur_boumiz',
    'j_boumiz'
}

local base_end_round = end_round
function end_round()
    if G.GAME.lob_temp_hand and G.GAME.lob_temp_hand > 0 then
        G.hand:change_size(-G.GAME.lob_temp_hand)
        G.GAME.lob_temp_hand = 0
    end
    base_end_round()
end

G.E_MANAGER:add_event(Event({
    trigger = 'after',
    delay = 0,
    func = function()
        if G.STATE == G.STATES.MENU then
            local selected_key = prof_jokers_keys[math.random(#prof_jokers_keys)]
            local card = create_card("Joker", nil, nil, nil, nil, nil, selected_key)
            G.MENU.center_card = card
            return true
        end
    end
}))

-- Tag Dragon : Tags n'ont pas de contexte "au moment où le boss démarre" ;
-- on pose un drapeau à l'obtention du tag, puis on le consomme au vrai moment
-- où la blinde choisie devient active (clic sur "Select" à l'écran des blindes).
local lob_select_blind_ref = G.FUNCS.select_blind
G.FUNCS.select_blind = function(e)
    lob_select_blind_ref(e)
    if G.GAME.lob_dragon_pending and G.GAME.blind and G.GAME.blind.boss and not G.GAME.blind.disabled then
        G.GAME.lob_dragon_pending = false
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.3,
            func = function()
                G.GAME.blind:disable()
                play_sound('timpani')
                return true
            end
        }))
    end
end

print("[Linkas' Outrageous Ballatro] Mod chargé avec succès !")

----------------------------------------------------------
----------- MOD CODE END ----------------------------------