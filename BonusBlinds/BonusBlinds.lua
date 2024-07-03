--- STEAMODDED HEADER
--- MOD_NAME: Bonus Blinds
--- MOD_ID: BB
--- PREFIX: bb
--- MOD_AUTHOR: [mathguy]
--- MOD_DESCRIPTION: Bonus Blinds
--- VERSION: 1.0.0
----------------------------------------------
------------MOD CODE -------------------------

local bonusType = SMODS.ConsumableType {
    key = 'Bonus',
    primary_colour = G.C.RED,
    secondary_colour = G.C.RED,
    loc_txt = {
        name = 'Bonus Blind',
        collection = 'Bonus Blinds',
        undiscovered = {
            name = 'Undiscovered Bonus',
            text = { 'idk stuff ig' },
        }
    },
    collection_rows = { 6, 6 },
    shop_rate = 2,
    rarities = {
        {key = 'Common', rate = 100},
        {key = 'Uncommon', rate = 25},
        {key = 'Rare', rate = 5},
        {key = 'Legendary', rate = 1},
    },
    default = "c_bb_bonus"
}

SMODS.Bonus = SMODS.Consumable:extend {
    set = 'Bonus',
    set_badges = function(self, card, badges)
        local colours = {
            Common = HEX('FE5F55'),
            Uncommon =  HEX('8867a5'),
            Rare = HEX("fda200"),
            Legendary = {0,0,0,1}
        }
        local len = string.len(self.rarity)
        local size = 1.3 - (len > 5 and 0.02 * (len - 5) or 0)
        badges[#badges + 1] = create_badge(self.rarity, colours[self.rarity], nil, size)
    end
}

SMODS.Atlas({ key = "mystery", atlas_table = "ASSET_ATLAS", path = "mystery.png", px = 71, py = 95})

SMODS.Atlas({ key = "another", atlas_table = "ASSET_ATLAS", path = "bonus.png", px = 71, py = 95})

SMODS.Atlas({ key = "loops", atlas_table = "ASSET_ATLAS", path = "loop.png", px = 71, py = 95})

SMODS.Atlas({ key = "bonus_tags", atlas_table = "ASSET_ATLAS", path = "tags.png", px = 34, py = 34})

local unknown = SMODS.UndiscoveredSprite {
    key = 'Bonus',
    atlas = 'mystery',
    pos = {x = 0, y = 0}
}

SMODS.Bonus {
    key = 'extra',
    loc_txt = {
        name = "Bonus Blind",
        text = {
            "Charges {C:money}$#2#{}",
            "to play {C:blue}#1#{}"
        }
    },
    atlas = "another",
    pos = {x = 0, y = 0},
    rarity = 'Common',
    set_ability = function(self, card, initial, delay_sprites)
        if G.P_BLINDS == nil then
            card.ability.the_blind = 'bl_small'
            card.ability.reward = {dollars = 1}
        else
            local rngpick = {}
            for i, j in pairs(G.P_BLINDS) do
                if j.boss and not j.boss.showdown then
                    table.insert(rngpick, i)
                end
            end
            local blind = pseudorandom_element(rngpick, pseudoseed('bonus'))
            card.ability.the_blind = blind
            card.ability.reward = {dollars = math.floor(1.5*G.P_BLINDS[blind].dollars)}
        end
    end,
    loc_vars = function(self, info_queue, card)
        return {vars = {localize{type ='name_text', key = card.ability.the_blind, set = 'Blind'}, card.ability.reward.dollars}}
    end,
    use = function(self, card, area, copier)
        bonus_selection(card.ability.the_blind, {none = 1})
        ease_dollars(-card.ability.reward.dollars)
    end,
    can_use = function(self, card)
        return ((not not G.blind_select) and (G.GAME.dollars >= card.ability.reward.dollars))
    end
}

SMODS.Bonus {
    key = 'needy',
    loc_txt = {
        name = "Needy Blind",
        text = {
            "Play a {C:attention}Boss Blind{}",
            "with only {C:blue}#1#{} Hand"
        }
    },
    atlas = "another",
    pos = {x = 2, y = 0},
    rarity = 'Common',
    set_ability = function(self, card, initial, delay_sprites)
        card.ability.start_hands = 1
    end,
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.start_hands}}
    end,
    use = function(self, card, area, copier)
        local rngpick = {}
        for i, j in pairs(G.P_BLINDS) do
            if j.boss and not j.boss.showdown and (i ~= 'bl_needle') then
                table.insert(rngpick, i)
            end
        end
        local blind = pseudorandom_element(rngpick, pseudoseed('bonus'))
        bonus_selection(blind, {hands = card.ability.start_hands})
    end,
    can_use = function(self, card)
        return (not not G.blind_select)
    end
}

SMODS.Bonus {
    key = 'sail',
    loc_txt = {
        name = "Sailing Blind",
        text = {
            "Play a {C:attention}Boss Blind{}",
            "with {C:red}#1#{} Discards"
        }
    },
    atlas = "another",
    pos = {x = 3, y = 0},
    rarity = 'Common',
    set_ability = function(self, card, initial, delay_sprites)
        card.ability.start_discards = 0
    end,
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.start_discards}}
    end,
    use = function(self, card, area, copier)
        local rngpick = {}
        for i, j in pairs(G.P_BLINDS) do
            if j.boss and not j.boss.showdown and (i ~= 'bl_water') then
                table.insert(rngpick, i)
            end
        end
        local blind = pseudorandom_element(rngpick, pseudoseed('bonus'))
        bonus_selection(blind, {discards = card.ability.start_discards})
    end,
    can_use = function(self, card)
        return (not not G.blind_select)
    end
}

SMODS.Bonus {
    key = 'redo',
    loc_txt = {
        name = "Redo Blind",
        text = {
            "Defeat {C:purple}#1#{} with ",
            "{C:blue}X3 Blind Size{} to get a {C:attention}#2#{}"
        }
    },
    atlas = "another",
    pos = {x = 1, y = 0},
    rarity = 'Uncommon',
    set_ability = function(self, card, initial, delay_sprites)
        card.ability.the_blind = 'bl_final_vessel'
        card.ability.reward = {tags = {'tag_boss'}, blind_mult = 3}
    end,
    loc_vars = function(self, info_queue, card)
        return {vars = {localize{type ='name_text', key = card.ability.the_blind, set = 'Blind'}, localize{type ='name_text', key = card.ability.reward.tags[1], set = 'Tag'}}}
    end,
    use = function(self, card, area, copier)
        bonus_selection(card.ability.the_blind, card.ability.reward)
    end,
    can_use = function(self, card)
        return (not not G.blind_select)
    end
}

SMODS.Bonus {
    key = 'broken',
    loc_txt = {
        name = "Broken Blind",
        text = {
            "{C:green}#1# in #2#{} chance to",
            "play a {C:blue}#3#{}"
        }
    },
    atlas = "another",
    pos = {x = 5, y = 0},
    rarity = 'Uncommon',
    set_ability = function(self, card, initial, delay_sprites)
        card.ability.the_blind = 'bl_small'
    end,
    loc_vars = function(self, info_queue, card)
        return {vars = {G.GAME.probabilities.normal,2,localize{type ='name_text', key = card.ability.the_blind, set = 'Blind'}}}
    end,
    use = function(self, card, area, copier)
        if pseudorandom("broken") < G.GAME.probabilities.normal/2 then
            bonus_selection(card.ability.the_blind, {none = 1})
        else
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                attention_text({
                    text = localize('k_nope_ex'),
                    scale = 1.3, 
                    hold = 1.4,
                    major = card,
                    backdrop_colour = G.C.SECONDARY_SET.Tarot,
                    align = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK) and 'tm' or 'cm',
                    offset = {x = 0, y = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK) and -0.2 or 0},
                    silent = true
                    })
                    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.06*G.SETTINGS.GAMESPEED, blockable = false, blocking = false, func = function()
                        play_sound('tarot2', 0.76, 0.4);return true end}))
                    play_sound('tarot2', 1, 0.4)
                    card:juice_up(0.3, 0.5)
            return true end }))
            delay(0.6)
        end
    end,
    can_use = function(self, card)
        return (not not G.blind_select)
    end
}

SMODS.Bonus {
    key = 'luck',
    loc_txt = {
        name = "Lucky Blind",
        text = {
            "Defeat a {C:attention}Blind{} with ",
            "{C:blue}#1#{} Hand and {C:red}#2#{} Discard",
            "to get #3# {C:attention}#4#s{}"
        }
    },
    atlas = "another",
    pos = {x = 6, y = 0},
    rarity = 'Rare',
    set_ability = function(self, card, initial, delay_sprites)
        card.ability.start_discards = 1
        card.ability.start_hands = 1
        card.ability.reward = {tags = {'tag_voucher', 'tag_voucher'}}
    end,
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.start_hands, card.ability.start_discards, 2, localize{type ='name_text', key = card.ability.reward.tags[1], set = 'Tag'}}}
    end,
    use = function(self, card, area, copier)
        local rngpick = {}
        for i, j in pairs(G.P_BLINDS) do
            if not j.boss or not j.boss.showdown then
                table.insert(rngpick, i)
            end
        end
        local blind = pseudorandom_element(rngpick, pseudoseed('bonus'))
        bonus_selection(blind, {hands = card.ability.start_hands, discards = card.ability.start_discards, tags = card.ability.reward.tags })
    end,
    can_use = function(self, card)
        return (not not G.blind_select)
    end
}

SMODS.Bonus {
    key = 'magma',
    loc_txt = {
        name = "Magma Blind",
        text = {
            "Defeat {C:blue}#1#{} to",
            "{C:attention}destroy{} cards {C:attention}held in hand{}"
        }
    },
    atlas = "another",
    pos = {x = 7, y = 0},
    rarity = 'Rare',
    set_ability = function(self, card, initial, delay_sprites)
        card.ability.the_blind = 'bl_hook'
        card.ability.reward = {burn_hand = true}
    end,
    loc_vars = function(self, info_queue, card)
        return {vars = {localize{type ='name_text', key = card.ability.the_blind, set = 'Blind'}}}
    end,
    use = function(self, card, area, copier)
        bonus_selection(card.ability.the_blind, card.ability.reward)
    end,
    can_use = function(self, card)
        return (not not G.blind_select)
    end
}

SMODS.Bonus {
    key = 'spoiler',
    loc_txt = {
        name = "Spoiler Blind",
        text = {
            "Play {C:attention}Ante #1#s{} {C:attention}Showdown Blind{}",
            "on this {C:attention}Ante{}"
        }
    },
    atlas = "another",
    pos = {x = 8, y = 0},
    rarity = 'Uncommon',
    set_ability = function(self, card, initial, delay_sprites)
    end,
    loc_vars = function(self, info_queue, card)
        local showdown = (G.GAME.round_resets.ante and (G.GAME.win_ante + math.max(0, math.floor(G.GAME.round_resets.ante / G.GAME.win_ante) * G.GAME.win_ante))) or 8 
        return {vars = {showdown}}
    end,
    use = function(self, card, area, copier)
        local showdown = G.GAME.win_ante + math.max(0, math.floor(G.GAME.round_resets.ante / G.GAME.win_ante) * G.GAME.win_ante)
        local blind = ""
        if not G.GAME.forced_blinds or G.GAME.forced_blinds[showdown] == nil then
            local rngpick = {}
            for i, j in pairs(G.P_BLINDS) do
                if j.boss and j.boss.showdown and not G.GAME.banned_keys[i] then
                    table.insert(rngpick, i)
                end
            end
            blind = pseudorandom_element(rngpick, pseudoseed('bonus'))
            if G.GAME.forced_blinds == nil then
                G.GAME.forced_blinds = {}
            end
            G.GAME.forced_blinds[showdown] = blind
        else
            blind = G.GAME.forced_blinds[showdown]
        end
        bonus_selection(blind, {none = true})
    end,
    can_use = function(self, card)
        return (not not G.blind_select)
    end
}

SMODS.Bonus {
    key = 'champion',
    loc_txt = {
        name = "Champion Blind",
        text = {
            "{C:attention}-#1#{} Ante then play",
            "a {C:blue}Showdown Blind{}"
        }
    },
    atlas = "another",
    pos = {x = 4, y = 0},
    rarity = 'Legendary',
    set_ability = function(self, card, initial, delay_sprites)
        card.ability.remove_ante = 1
    end,
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.remove_ante}}
    end,
    use = function(self, card, area, copier)
        local rngpick = {}
        for i, j in pairs(G.P_BLINDS) do
            if j.boss and j.boss.showdown then
                table.insert(rngpick, i)
            end
        end
        local blind = pseudorandom_element(rngpick, pseudoseed('bonus'))
        bonus_selection(blind, {ante_mod = -card.ability.remove_ante})
    end,
    can_use = function(self, card)
        return (not not G.blind_select)
    end
}

SMODS.Spectral {
    key = 'loop',
    loc_txt = {
        name = "Loop",
        text = {
            "Create a random",
            "{C:red}Bonus Blind{}"
        }
    },
    atlas = "loops",
    pos = {x = 0, y = 0},
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
            play_sound('timpani')
            local card = create_card("Bonus", G.consumeables)
            card:add_to_deck()
            G.consumeables:emplace(card)
            card:juice_up(0.3, 0.5)
            return true
        end}))
        delay(0.6)
    end,
    can_use = function(self, card)
        return (#G.consumeables.cards < G.consumeables.config.card_limit) or (card.area == G.consumeables)
    end
}

SMODS.Tag {
    key = 'ironic',
    atlas = 'bonus_tags',
    loc_txt = {
        name = "Ironic Tag",
        text = {
            "Create a {C:red}Common{}",
            "{C:red}Bonus Blind{}"
        }
    },
    pos = {x = 0, y = 0},
    apply = function(tag, context)
        if context.type == 'immediate' then
            local lock = tag.ID
            G.CONTROLLER.locks[lock] = true
            tag:yep('+', G.C.BLUE,function() 
                if (#G.consumeables.cards < G.consumeables.config.card_limit) then
                    local card = create_card("Bonus", G.consumeables, nil, 0, nil, nil, nil, 'top')
                    card:add_to_deck()
                    G.consumeables:emplace(card)
                end
                G.CONTROLLER.locks[lock] = nil
                return true
            end)
        end
    end,
    config = {type = 'immediate'}
}

function bonus_new_round(theBlind, bonusData)
    G.RESET_JIGGLES = nil
    delay(0.4)
    G.E_MANAGER:add_event(Event({
      trigger = 'immediate',
      func = function()
            G.GAME.current_round.discards_left = math.max(0, G.GAME.round_resets.discards + G.GAME.round_bonus.discards)
            G.GAME.current_round.hands_left = (math.max(1, G.GAME.round_resets.hands + G.GAME.round_bonus.next_hands))
            G.GAME.current_round.hands_played = 0
            G.GAME.current_round.discards_used = 0
            G.GAME.current_round.reroll_cost_increase = 0
            G.GAME.current_round.used_packs = {}

            for k, v in pairs(G.GAME.hands) do 
                v.played_this_round = 0
            end

            for k, v in pairs(G.playing_cards) do
                v.ability.wheel_flipped = nil
            end

            local chaos = find_joker('Chaos the Clown')
            G.GAME.current_round.free_rerolls = #chaos
            calculate_reroll_cost(true)

            G.GAME.round_bonus.next_hands = 0
            G.GAME.round_bonus.discards = 0

            local blhash = 'S'
            -- if G.GAME.round_resets.blind == G.P_BLINDS.bl_small then
            --     G.GAME.round_resets.blind_states.Small = 'Current'
            --     G.GAME.current_boss_streak = 0
            --     blhash = 'S'
            -- elseif G.GAME.round_resets.blind == G.P_BLINDS.bl_big then
            --     G.GAME.round_resets.blind_states.Big = 'Current'
            --     G.GAME.current_boss_streak = 0
            --     blhash = 'B'
            -- else
            --     G.GAME.round_resets.blind_states.Boss = 'Current'
            --     blhash = 'L'
            -- end
            G.GAME.subhash = (G.GAME.round_resets.ante)..(blhash)

            -- local customBlind = {name = 'The Ox', defeated = false, order = 4, dollars = 5, mult = 2,  vars = {localize('ph_most_played')}, debuff = {}, pos = {x=0, y=2}, boss = {min = 6, max = 10, bonus = true}, boss_colour = HEX('b95b08')}
            G.GAME.blind:set_blind(G.P_BLINDS[theBlind])
            G.GAME.blind.config.bonus = bonusData
            G.GAME.last_blind.boss = nil
            G.GAME.blind.dollars = 0
            G.GAME.current_round.dollars_to_be_earned = ''
            G.HUD_blind.alignment.offset.y = -10
            G.HUD_blind:recalculate(false)
            bonus_start_effect(bonusData)
            
            for i = 1, #G.jokers.cards do
                G.jokers.cards[i]:calculate_joker({setting_blind = true, blind = G.GAME.round_resets.blind})
            end
            delay(0.4)

            G.E_MANAGER:add_event(Event({
                trigger = 'immediate',
                func = function()
                    G.STATE = G.STATES.DRAW_TO_HAND
                    G.deck:shuffle('nr'..G.GAME.round_resets.ante)
                    G.deck:hard_set_T()
                    G.STATE_COMPLETE = false
                    return true
                end
            }))
            return true
            end
        }))
end

function bonus_selection(theBlind, bonusData)
    stop_use()
    if G.blind_select then 
        G.GAME.facing_blind = true
        G.blind_prompt_box:get_UIE_by_ID('prompt_dynatext1').config.object.pop_delay = 0
        G.blind_prompt_box:get_UIE_by_ID('prompt_dynatext1').config.object:pop_out(5)
        G.blind_prompt_box:get_UIE_by_ID('prompt_dynatext2').config.object.pop_delay = 0
        G.blind_prompt_box:get_UIE_by_ID('prompt_dynatext2').config.object:pop_out(5) 

        G.E_MANAGER:add_event(Event({
        trigger = 'before', delay = 0.2,
        func = function()
            G.blind_prompt_box.alignment.offset.y = -10
            G.blind_select.alignment.offset.y = 40
            G.blind_select.alignment.offset.x = 0
            return true
        end}))
        G.E_MANAGER:add_event(Event({
        trigger = 'immediate',
        func = function()
            ease_round(1)
            inc_career_stat('c_rounds', 1)
            if _DEMO then
            G.SETTINGS.DEMO_ROUNDS = (G.SETTINGS.DEMO_ROUNDS or 0) + 1
            inc_steam_stat('demo_rounds')
            G:save_settings()
            end
            -- G.GAME.round_resets.blind = e.config.ref_table
            -- G.GAME.round_resets.blind_states[G.GAME.blind_on_deck] = 'Current'
            G.blind_select:remove()
            G.blind_prompt_box:remove()
            G.blind_select = nil
            delay(0.2)
            return true
        end}))
        G.E_MANAGER:add_event(Event({
        trigger = 'immediate',
        func = function()
            bonus_new_round(theBlind, bonusData)
            return true
        end
        }))
    end
end

function bonus_start_effect(bonusData)
    if bonusData.blind_mult then
        G.GAME.blind.mult = G.GAME.blind.mult * bonusData.blind_mult
        G.GAME.blind.chips = G.GAME.blind.chips * bonusData.blind_mult
        G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
    end
    if bonusData.hands then
        ease_hands_played(bonusData.hands-G.GAME.current_round.hands_left)
    end
    if bonusData.discards then
        ease_discard(bonusData.discards-G.GAME.current_round.discards_left)
    end
    if bonusData.ante_mod then
        ease_ante(bonusData.ante_mod)
        G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante or G.GAME.round_resets.ante
        G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante + bonusData.ante_mod
        G.GAME.blind.chips = math.floor((G.GAME.blind.chips * get_blind_amount(G.GAME.round_resets.blind_ante)) / get_blind_amount(G.GAME.round_resets.blind_ante+1))
        G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
    end
end

function bonus_reward(bonusData)
    if bonusData.tags then
        for i, j in ipairs(bonusData.tags) do
            add_tag(Tag(j))
        end
    end
end

function bonus_end_of_round(bonusData)
    if bonusData.burn_hand then
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function() 
                local i = #G.hand.cards
                while (i >= 1) do
                    local card = G.hand.cards[i]
                    if card.ability.name == 'Glass Card' then 
                        card:shatter()
                    else
                        card:start_dissolve(nil, i == #G.hand.cards)
                    end
                    i = i - 1
                end
                return true 
            end 
        }))
        delay(0.5)
    end
end

----------------------------------------------
------------MOD CODE END----------------------
