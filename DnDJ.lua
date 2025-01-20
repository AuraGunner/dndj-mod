--- STEAMODDED HEADER
--- MOD_NAME: D & DJ
--- MOD_ID: dndj
--- MOD_AUTHOR: [Auraa_]
--- MOD_DESCRIPTION: This mod aims to re-imagine cards from Dungeons & Degenerate Gamblers as jokers
--- PREFIX: dndj
--- LOADER_VERSION_GEQ: 1.0.0
--- VERSION: 0.1.1
--- BADGE_COLOR: 32751a

-- A T L A S E S --
dndj = {}
SMODS.Atlas {
    key = 'jokers_atlas',
    path = "Jokers.png",
    px = 71,
    py = 95
}

-- C O M P A T I B I L I T Y --
dndj.compat = {
    talisman = (SMODS.Mods['Talisman'] or {}).can_load,
}

-- J O K E R S --

-- Birthday Card --
SMODS.Joker {
    key = "birthdaycard",
    name = "Birthday Card",
    atlas = 'jokers_atlas',
    pos = {
        x = 0,
        y = 0,
    },
    rarity = 2,
    cost = 7,
    unlocked = true,
    discovered = false,
    eternal_compat = false,
    perishable_compat = false,
    blueprint_compat = false,
    config = {
        extra = {
            cards_scored = 0,
            cards_required = 21
        }
    },
    loc_txt = {
        name = "Birthday Card",
        text = {
          "After {C:attention}#2#{} cards score,",
          "destroy this Joker and",
          "earn {C:attention}5 Standard Tags",
          "{C:inactive}(Currently {C:attention}#1#{C:inactive}/#2#)"
        },
      },
      loc_vars = function(self, info_queue, center)
        return {vars = { center.ability.extra.cards_scored, center.ability.extra.cards_required } }
      end,
      calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint and not context.other_card.debuff then
            card.ability.extra.cards_scored = card.ability.extra.cards_scored + 1
        end
        if context.after then
            if card.ability.extra.cards_scored >= card.ability.extra.cards_required then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        add_tag(Tag('tag_standard'))
                        add_tag(Tag('tag_standard'))
                        add_tag(Tag('tag_standard'))
                        add_tag(Tag('tag_standard'))
                        add_tag(Tag('tag_standard'))
                        play_sound('generic1', 0.9 + math.random()*0.1, 0.8)
                        play_sound('holo1', 1.2 + math.random()*0.1, 0.4)
                        G.jokers:remove_card(self)
                        card:remove()
                        card = nil
                        return true
                    end
                })) 
                return {
                    message = "Happy birthday!",
                    colour = G.C.RED
                }
            end
        end
    end         
}

-- Jack of All Trades --
SMODS.Joker{
    key = 'jackoff_lmao',
    rarity = 3,
    cost = 9,
    atlas = 'jokers_atlas',
    blueprint_compat = true,
    pos = { x = 1, y = 0 },
    config = {extra = {chips = 50, mult = 7, x_mult = 1.25, dollars = 1} },
    loc_txt = {
        name = "Jack of all Trades",
        text = {
            "Played {C:attention}Jacks{} give {C:chips}+#1#{} Chips,",
            "{C:mult}+#2#{} Mult, {X:mult,C:white}x#3#{} Mult, and {C:money}$#4#{}",
            "when scored"
        },
      },
    loc_vars = function(self, info_queue, center)
        return { vars = {center.ability.extra.chips, center.ability.extra.mult, center.ability.extra.x_mult, center.ability.extra.dollars} }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:get_id() == 11 then
                return {
                  chips = card.ability.extra.chips,
                  mult = card.ability.extra.mult,
                  x_mult = card.ability.extra.x_mult,
                  dollars = card.ability.extra.dollars,
                  card = card
              }
          end
      end
    end
}

-- Jack in a Box --
SMODS.Joker{
    key = 'jack_in_a_box',
    rarity = 1,
    atlas = 'jokers_atlas',
    cost = 4,
    blueprint_compat = true,
    eternal_compat = false,
    pos = { x = 2, y = 0 },
    config = { extra = {mult = 0, mult_mod = 3} },
    loc_txt = {
        name = "Jack in a Box",
        text = {
            "This Joker gains {C:mult}+#2#{} Mult for every ",
            "hand played, but has a {C:green}1 in 10{} chance ",
            "to destroy itself at the end of the round",
            "{C:inactive}(Currently {}{C:mult}+#1#{}{C:inactive} Mult){}"
        },
      },
    loc_vars = function(self, info_queue, center)
        return { vars = {center.ability.extra.mult, center.ability.extra.mult_mod} }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                message = localize { type = 'variable', key = 'a_mult', vars = { card.ability.extra.mult } },
                mult_mod = card.ability.extra.mult
            }
        end
    if context.before and not context.blueprint then
        card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_mod
        return {
            message = localize('k_upgrade_ex'),
            colour = G.C.MULT,
            card = card
        }
    end
    if context.end_of_round and not context.blueprint and not (context.individual or context.repetition) then
        if pseudorandom("jack_in_a_box") < G.GAME.probabilities.normal/10 then
            G.E_MANAGER:add_event(Event({
                func = function()
                    play_sound('tarot1')
                    card.T.r = -0.2
                    card:juice_up(0.3,0.4)
                    card.states.drag.is = true
                    card.children.center.pinch.x = true
                    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false,
                                                func = function()
                                                    G.jokers:remove_card(card)
                                                    card:remove()
                                                    card = nil
                                                    return true; end }))
                    return true
                end
            }))
            return {
                message = "Pop goes the weasel!",
                colour = G.C.RED,
                card = card
            }
        else
            return {
                message = localize("k_safe_ex"),
                colour = G.C.GREEN,
                card = card
            }
        end
    end
end
}

-- Jackhammer --

SMODS.Joker{
    key = 'jackhammer',
    rarity = 2,
    atlas = 'jokers_atlas',
    cost = 5,
    blueprint_compat = true,
    eternal_compat = false,
    pos = { x = 3, y = 0 },

    config = { extra = {mult = 50} },
    loc_txt = {
        name = "Jackhammer",
        text = {
            "{C:mult}+50{} Mult",
            "Destroys itself at end of round",
        },
      },

    loc_vars = function(self, info_queue, center)
        return { vars = {center.ability.extra.mult} }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                message = localize { type = 'variable', key = 'a_mult', vars = { card.ability.extra.mult } },
                mult_mod = card.ability.extra.mult
            }
        end
        if context.end_of_round and not context.blueprint and not (context.individual or context.repetition) then
            G.E_MANAGER:add_event(Event({
                func = function()
                    play_sound('tarot1')
                    card.T.r = -0.2
                    card:juice_up(0.3,0.4)
                    card.states.drag.is = true
                    card.children.center.pinch.x = true
                    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false,
                                                func = function()
                                                    G.jokers:remove_card(card)
                                                    card:remove()
                                                    card = nil
                                                    return true; end }))
                    return true
                end
            }))
            return {
                message = "Overheated!",
                colour = G.C.RED,
                card = card
            }
        end
    end
}

-- Jumping Jacks --

SMODS.Joker{
    key = 'jumpnjacks',
    rarity = 1,
    atlas = 'jokers_atlas',
    cost = 5,
    blueprint_compat = true,
    pos = { x = 4, y = 0 },
    config = { extra = {mult = 10} },
    loc_txt = {
        name = "Jumping Jacks",
        text = {
            "This Joker alternates between giving ",
            "{C:mult}+0{} and {C:mult}+10{} Mult for each",
            "scored {C:attention}Jack{} after every hand.",
            "{C:inactive}(Currently{}{C:mult} +#1#{}{C:inactive} Mult){}"
        },
      },

    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.extra.mult} }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:get_id() == 11 then
                return {
                  mult = card.ability.extra.mult,
                  card = card
              }
            end
        end
        if context.after then
            if card.ability.extra.mult == 10 then
                card.ability.extra.mult = 0
                return {
                    message = "+0 Mult",
                    colour = G.C.RED,
                    card = card
                }
            end
            if card.ability.extra.mult == 0 then
                card.ability.extra.mult = 10
                return {
                    message = "+10 Mult",
                    colour = G.C.GREEN,
                    card = card
                }
            end
        end
    end
}

-- Jack and the Beanstalk --
SMODS.Joker{
    key = 'beanstalk',
    rarity = 2,
    atlas = 'jokers_atlas',
    cost = 8,
    blueprint_compat = true,
    pos = { x = 5, y = 0 },
    config = { extra = {repetitions = 2} },
    loc_txt = {
        name = "Jack and the Beanstalk",
        text = {"Retrigger each played {C:attention}Jack{} twice"},
    },
    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.extra.repetitions} }
    end,
    calculate = function(self, card, context)
    if context.repetition
	and context.other_card:get_id() == 11
	and context.cardarea == G.play then
		return {
			message = localize('k_again_ex'),
			repetitions = card.ability.extra.repetitions,
			card = card
			}
		end
    end
}

-- Monterey Jack --
SMODS.Joker{
    key = 'throw_the_cheese',
    rarity = 2,
    atlas = 'jokers_atlas',
    cost = 6,
    eternal_compat = false,
    pos = { x = 6, y = 0 },
    config = { extra = {hands = 3, hands_mod = 1} },
    loc_txt = {
        name = "Monterey Jack",
        text = {
            "{C:blue}+#1#{} Hands every round,",
            "Reduces by {C:red}#2#{} each round"
        },
      },
    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.extra.hands, card.ability.extra.hands_mod} }
    end,
    calculate = function(self, card, context)
    if context.setting_blind and context.blind == G.GAME.round_resets.blind then
        G.E_MANAGER:add_event(Event({func = function()
            ease_hands_played(card.ability.extra.hands)
            --card_eval_status_text(context.blueprint_card, 'extra', nil, nil, nil, {message = localize{type = 'variable', key = 'a_hands', vars = {card.ability.extra.hands}}})--
        return true end }))
    end
    if context.end_of_round and not context.blueprint and not (context.individual or context.repetition) then
        if card.ability.extra.hands - card.ability.extra.hands_mod <= 0 then 
            G.E_MANAGER:add_event(Event({
                func = function()
                    play_sound('tarot1')
                    card.T.r = -0.2
                    card:juice_up(0.3, 0.4)
                    card.states.drag.is = true
                    card.children.center.pinch.x = true
                    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false,
                        func = function()
                                G.jokers:remove_card(card)
                                card:remove()
                                card = nil
                            return true; end})) 
                    return true
                end
            })) 
            return {
                message = localize('k_eaten_ex'),
                colour = G.C.FILTER
            }
        else
            card.ability.extra.hands = card.ability.extra.hands - card.ability.extra.hands_mod
            ease_hands_played(-1)
            return {
                message = "-1 Hand",
                colour = G.C.FILTER
            }
        end
    end
end
}

-- Jackpot --
SMODS.Joker{
    key = 'jackpot',
    rarity = 2,
    atlas = 'jokers_atlas',
    cost = 6,
    eternal_compat = false,
    pos = { x = 8, y = 0 },
    --config = { extra = {} },
    loc_txt = {
        name = "Jackpot",
        text = {
            "At the beginning of the round, this Joker",
            "adds {C:attention}3 Jacks{} with a random seal,",
            "enhancement, and edition to your hand,",
            "then becomes a Pot"
        },
      },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.j_dndj_pot_like_weed_get_it_hah_ha
        return { vars = {} }
    end,
    calculate = function(self, card, context)
        if context.first_hand_drawn then
            for i = 0, 2, 1 do
            G.E_MANAGER:add_event(Event({
                func = function()
                    local eligible_suits = {}
                    for _,k in ipairs(SMODS.Suit.obj_buffer) do
                    if not SMODS.Suits[k].in_pool or SMODS.Suits[k]:in_pool({ rank = 'Jack' }) then eligible_suits[#eligible_suits+1] = SMODS.Suits[k].card_key end
                    end
                    local _suit = pseudorandom_element(eligible_suits, pseudoseed('jacks'))
                    local _card = create_playing_card({
                        front = G.P_CARDS[_suit..'_J'], 
                        center = G.P_CENTERS.c_base}, G.hand, nil, nil, nil)
                    _card:set_ability(G.P_CENTERS[SMODS.poll_enhancement({guaranteed = true, options = {"m_bonus", "m_mult", "m_gold", "m_steel", "m_lucky"}, type_key = 'randomseed'})], true, false)
                    _card:set_seal(SMODS.poll_seal({guaranteed = true, type_key = 'randomseed'}), true, false)
                    _card:set_edition(poll_edition("randomseed", nil, false, true, {"e_foil", "e_holo","e_polychrome","e_negative"}))
                    G.GAME.blind:debuff_card(_card)
                    G.hand:sort()
                    if context.blueprint_card then context.blueprint_card:juice_up() else card:juice_up() end
                    return true
                end}))
            end
            playing_card_joker_effects({true})
            G.E_MANAGER:add_event(Event({
                func = function()
                    play_sound('tarot1')
                    card.T.r = -0.2
                    card:juice_up(0.3, 0.4)
                    card.states.drag.is = true
                    card.children.center.pinch.x = true
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.3,
                        blockable = false,
                        func = function()
                            G.jokers:remove_card(card)
                            card:remove()
 
                            if #G.jokers.cards + G.GAME.joker_buffer < G.jokers.config.card_limit then
                                local jokers_to_create = math.min(1,
                                    G.jokers.config.card_limit - (#G.jokers.cards + G.GAME.joker_buffer))
                                G.GAME.joker_buffer = G.GAME.joker_buffer + jokers_to_create
                                
                                G.E_MANAGER:add_event(Event({
                                    func = function()
                                        --local card = create_card('Joker', G.jokers, nil, 0, nil, nil, 'j_pot_like_weed_get_it_hah_ha', 'random')--
                                        local _card = SMODS.create_card({
                                            set = 'Joker',
                                            area = G.jokers,
                                            key = 'j_dndj_pot_like_weed_get_it_hah_ha',
                                        })
                                        _card:add_to_deck()
                                        G.jokers:emplace(_card)
                                        _card:start_materialize()
                                        G.GAME.joker_buffer = 0
                                        return true
                                    end
                                }))
                            end
                            return true;
                        end
                    }))
                    return true
                end
            }))

            return {
                message = "A WINNER IS YOU",
                colour = G.C.MULT,
                card = card
            }
        end
        
    end
}

-- Pot --

SMODS.Joker{
    key = 'pot_like_weed_get_it_hah_ha',
    rarity = 1,
    atlas = 'jokers_atlas',
    cost = 3,
    blueprint_compat = true,
    pos = { x = 9, y = 0 },
    config = { extra = {chips = 77} },
    in_pool = function(self)
        return false
    end,
    loc_txt = {
        name = "Pot",
        text = {
            "{C:chips}+#1#{} Chips"
        },
      },

    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.extra.chips} }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            return {
                message = localize { type = 'variable', key = 'a_chips', vars = { card.ability.extra.chips } },
                chip_mod = card.ability.extra.chips
            }
        end
    end
}

-- Magic Trick --
SMODS.Joker{
    key = 'holy_shit_magic_trick_2',
    rarity = 2,
    atlas = 'jokers_atlas',
    cost = 7,
    blueprint_compat = true,
    pos = { x = 7, y = 0 },
    config = { extra = {chips = 0, chip_mod = 10, mult = 0, mult_mod = 7} },
    loc_txt = {
        name = "Magic Trick",
        text = {
            "This Joker gains {C:chips}+#2#{} Chips and {C:mult}+#4#{} Mult",
            "for every {C:attention}Queen of Diamonds{} or",
            "{C:attention}7 of Spades{} scored",
            "{C:inactive}(Currently {}{C:chips}+#1#{}{C:inactive} Chips | {C:mult}+#3#{}{C:inactive} Mult)"
        },
      },

    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.extra.chips, card.ability.extra.chip_mod, card.ability.extra.mult, card.ability.extra.mult_mod} }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if (context.other_card:get_id() == 7 and context.other_card:is_suit("Spades") or (context.other_card:get_id() == 12 and context.other_card:is_suit("Diamonds"))) then
                card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_mod
                card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_mod
                return {
                --chips = card.ability.extra.chips,
                --mult = card.ability.extra.mult,
                extra = {focus = card, message = localize('k_upgrade_ex')},
                colour = G.C.MULT,
                card = card
                }
            end
        end
        if context.joker_main then
            SMODS.eval_this(context.blueprint_card or card, {
                chip_mod = card.ability.extra.chips,
                message = localize {
                    type = 'variable',
                    key = 'a_chips',
                    vars = {card.ability.extra.chips},
                }
            })

            return {
                mult_mod = card.ability.extra.mult,
                message = localize {
                    type = 'variable',
                    key = 'a_mult',
                    vars = {card.ability.extra.mult},
                },
                card = card
            }
        end
    end

}

-- D E C K S --
-- [TO BE COMPLETED] --
