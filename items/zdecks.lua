SMODS.Atlas{
    key = 'Decks',
    path = 'enhancers.png',
    px = 71,
    py = 95,
}

SMODS.Back({
    key = "rsg_deck",
    loc_txt = {
        name = "Resetting For A Beach Seed",
        text={
        "{C:green}1 in 6{} chance",
        "to start with an",
        "{C:attention}Open To Lan{}",
        },
    },

	config = { hands = 0, discards = 0, consumeables = 'c_opentolan'},
	pos = { x = 0, y = 2 },
	order = 1,
	atlas = "Decks",
    unlocked = true,

	apply = function(self)
        G.E_MANAGER:add_event(Event({
			func = function()
				if G.consumeables then
                    if math.random(1,1) == 1 then
                        print("Lucky! Open To Lan!")
                        local card = create_card("Spectral", G.consumeables, nil, nil, nil, nil, "c_lob_opentolan", "lob_deck")
                        card:add_to_deck()
                        G.consumeables:emplace(card)
                    else
                        print("Unlucky!")
                        local card = create_card("Tarot", G.consumeables, nil, nil, nil, nil, "c_fool", "lob_deck")
                        card:add_to_deck()
                        G.consumeables:emplace(card)
                    end
                    return true
                  end
			end,
		}))
	end,

	check_for_unlock = function(self, args)
		if args.type == "win_deck" then
            unlock_card(self)
        else
			unlock_card(self)
		end
	end,
})

SMODS.Back {
    key = "boumiz_deck",
    pos = { x = 1, y = 2 },
    atlas = "Decks",
    unlocked = true,
    loc_txt = {
        name = "Deck Boumiz",
        text = {
            "Commence avec {C:legendary}Seigneur Boumiz{}",
            "{C:red}-2{} emplacements de Joker",
            "Après chaque {C:attention}Boss Blind{} :",
            "crée un {C:dark_edition}Joker Physique négatif{}"
        },
    },
    config = {
        joker = { "j_lob_seigneur_boumiz" },
        joker_slots = -2
    },

    apply = function(self)
        G.E_MANAGER:add_event(Event({
            trigger = 'immediate',
            func = function()
                local key = self.config.joker[1]
                if G.P_CENTERS[key] then
                    local card = create_card('Joker', G.jokers, true, nil, nil, nil, key, "lob_deck")
                    card:add_to_deck()
                    G.jokers:emplace(card)
                else
                    print("[LOB] ERREUR : Seigneur Boumiz ("..key..") non trouvé")
                end
                return true
            end
        }))
    end,

    calculate = function(self, context)
        if context.end_of_round and context.game_over ~= true and not context.individual and not context.repetition and G.GAME.blind and G.GAME.blind.boss then
            local phys_jokers = {}
            for _, center in pairs(G.P_CENTERS) do
                if center.pools and center.pools["PHYSIQUE"] then
                    table.insert(phys_jokers, center.key)
                end
            end
            if #phys_jokers > 0 then
                local key = pseudorandom_element(phys_jokers, "boumiz_phys")
                if G.P_CENTERS[key] then
                    local card = create_card('Joker', G.jokers, true, nil, nil, nil, key)
                    card:set_edition({ negative = true }, true)
                    card:add_to_deck()
                    G.jokers:emplace(card)
                    return { message = "Pouvoir du cane !", colour = G.C.PURPLE }
                end
            end
        end
    end
}

SMODS.Back {
    key = "lukas_deck",
    pos = { x = 2, y = 2 },
    atlas = "Decks",
    unlocked = true,

    loc_txt = {
        name = "Deck Lukas",
        text = {
            "Commence avec",
            "{C:spectral}Rituel de Lukas{}",
            "Cette carte peut apparaître",
            "dans les {C:attention}shops et paquets arcana{}"
        }
    },

    config = {
        consumables = { "c_lob_rituel_lukas" }
    },
}

SMODS.Back({
    key = "cytech_deck",
    loc_txt = {
        name = "Deck Cy-Tech",
        text = {
            "Seuls les paquets",
            "{C:attention}du mod{}",
            "peuvent apparaître"
        },
    },
    pos = { x = 4, y = 2 },
    atlas = "Decks",
    unlocked = true,

    apply = function(self)
        G.GAME.modifiers = G.GAME.modifiers or {}
        G.GAME.modifiers.cytech_only = true
    end
})

SMODS.Back({
    key = "dark_deck",
    loc_txt = {
        name = "Deck Ténébreux",
        text = {
            "Toutes les cartes ont",
            "{C:attention}Dark Seal{}",
            "Si une carte est {C:red}détruite{} :",
            "crée un {C:dark_edition}Joker négatif{}"
        },
    },
    pos = { x = 3, y = 2 },
    atlas = "Decks",
    unlocked = true,

    apply = function(self)
        G.E_MANAGER:add_event(Event({
            trigger = 'immediate',
            func = function()
                for _, c in pairs(G.playing_cards) do
                    c:set_seal("lob_dark", true, true)
                end
                return true
            end
        }))
    end
})

