--local S = core.get_translator(core.get_current_modname())

-- wrapper for core.item_eat (this way we make sure other mods can't break this one)
function core.do_item_eat(hp_change, replace_with_item, itemstack, user, pointed_thing)
	if not user or not user.is_player or not user:is_player() or user.is_fake_player then return itemstack end

	local rc = mcl_util.call_on_rightclick(itemstack, user, pointed_thing)
	if rc then return rc end

	-- Also don't eat when pointing object (it could be an animal)
	if pointed_thing.type == "object" then
		return itemstack
	end

	local old_itemstack = itemstack

	local name = user:get_player_name()

	local creative = core.is_creative_enabled(name)

	-- Special foodstuffs like the cake may disable the eating delay
	local no_eat_delay = creative
		or pointed_thing._csm_eating
		or (core.get_item_group(itemstack:get_name(), "no_eat_delay") == 1)

	-- Allow eating only after a delay of 2 seconds. This prevents eating as an excessive speed.
	-- FIXME: time() is not a precise timer, so the actual delay may be +- 1 second, depending on which fraction
	-- of the second the player made the first eat.
	-- FIXME: In singleplayer, there's a cheat to circumvent this, simply by pausing the game between eats.
	-- This is because os.time() obviously does not care about the pause. A fix needs a different timer mechanism.
	if no_eat_delay or (mcl_hunger.last_eat[name] < 0) or (os.difftime(os.time(), mcl_hunger.last_eat[name]) >= 2) then
		local can_eat_when_full = creative or (mcl_hunger.active == false)
		or core.get_item_group(itemstack:get_name(), "can_eat_when_full") == 1
		-- Don't allow eating when player has full hunger bar (some exceptional items apply)
		if can_eat_when_full or (mcl_hunger.get_hunger(user) < 20) then
			itemstack = mcl_hunger.eat(hp_change, replace_with_item, itemstack, user, pointed_thing)
			for _, callback in pairs(core.registered_on_item_eats) do
				local result = callback(hp_change, replace_with_item, itemstack, user, pointed_thing, old_itemstack)
				if result then
					return result
				end
			end
			mcl_hunger.last_eat[name] = os.time()
		end
	end

	return itemstack
end

function mcl_hunger.eat(hp_change, replace_with_item, itemstack, user, _)
	local item = itemstack:get_name()
	local def = mcl_hunger.registered_foods[item]
	if not def then
		def = {}
		if type(hp_change) ~= "number" then
			hp_change = 1
			core.log("error", "Wrong on_use() definition for item '" .. item .. "'")
		end
		def.saturation = hp_change
		def.replace = replace_with_item
	end
	local func = mcl_hunger.item_eat(def.saturation, def.replace, def.poisontime, def.poison, def.exhaust, def.poisonchance)
	return func(itemstack, user)
end

-- Reset HUD bars after food poisoning

function mcl_hunger.reset_bars_poison_hunger(player)
	hb.change_hudbar(player, "hunger", nil, nil, "hbhunger_icon.png", nil, "hbhunger_bar.png")
	if mcl_hunger.debug then
		hb.change_hudbar(player, "exhaustion", nil, nil, nil, nil, "mcl_hunger_bar_exhaustion.png")
	end
end

local poisonrandomizer = PcgRandom(os.time())

function mcl_hunger.item_eat(hunger_change, replace_with_item, poisontime, poison, exhaust, poisonchance)
	return function(itemstack, user)
		if not user or not user.is_player or not user:is_player() or user.is_fake_player then return itemstack end
		local itemname = itemstack:get_name()
		local creative = core.is_creative_enabled(user:get_player_name())
		if itemstack:peek_item() and user then
			if not creative then
				itemstack:take_item()
			end
			local name = user:get_player_name()
			--local hp = mcl_util.get_hp (user)

			local pos = user:get_pos()
			-- player height
			pos.y = pos.y + 1.5
			local foodtype = core.get_item_group(itemname, "food")
			if foodtype == 3 then
				-- Item is a drink, only play drinking sound (no particle)
				core.sound_play("survival_thirst_drink", {
					max_hear_distance = 12,
					gain = 1.0,
					pitch = 1 + math.random(-10, 10)*0.005,
					object = user,
				}, true)
			else
				-- Assume the item is a food
				-- Add eat particle effect and sound
				local def = core.registered_items[itemname]
				local texture = def.inventory_image
				if not texture or texture == "" then
					texture = def.wield_image
				end
				-- Special item definition field: _food_particles
				-- If false, force item to not spawn any food partiles when eaten
				if def._food_particles ~= false and texture and texture ~= "" then
					local v = user:get_velocity() or user:get_player_velocity()
					for i = 0, math.min(math.max(8, hunger_change*2), 25) do
						core.add_particle({
							pos = { x = pos.x, y = pos.y, z = pos.z },
							velocity = vector.add(v, { x = math.random(-1, 1), y = math.random(1, 2), z = math.random(-1, 1) }),
							acceleration = { x = 0, y = math.random(-9, -5), z = 0 },
							expirationtime = 1,
							size = math.random(1, 2),
							collisiondetection = true,
							vertical = false,
							texture = "[combine:3x3:" .. -i .. "," .. -i .. "=" .. texture,
						})
					end
				end
				core.sound_play("mcl_hunger_bite", {
					max_hear_distance = 12,
					gain = 1.0,
					pitch = 1 + math.random(-10, 10)*0.005,
					object = user,
				}, true)
			end

			if mcl_hunger.active and hunger_change then
				-- Add saturation (must be defined in item table)
				local _mcl_saturation = core.registered_items[itemname]._mcl_saturation
				local saturation
				if not _mcl_saturation then
					saturation = 0
				else
					saturation = core.registered_items[itemname]._mcl_saturation
				end
				mcl_hunger.saturate(name, saturation, false)

				-- Add food points
				local h = mcl_hunger.get_hunger(user)
				if h < 20 and hunger_change then
					h = h + hunger_change
					if h > 20 then h = 20 end
					mcl_hunger.set_hunger(user, h, false)
				end

				hb.change_hudbar(user, "hunger", h)
				mcl_hunger.update_saturation_hud(user, mcl_hunger.get_saturation(user), h)
			elseif not mcl_hunger.active and hunger_change then
			   -- Is this code still reachable?
			   mcl_damage.heal_player (user, hunger_change)
			end
			-- Poison
			if mcl_hunger.active and poisontime then
				local do_poison = false
				if poisonchance then
					if poisonrandomizer:next(0,100) < poisonchance then
						do_poison = true
					end
				else
					do_poison = true
				end
				if do_poison then
					local level = mcl_potions.get_effect_level(user, "hunger")
					mcl_potions.give_effect_by_level("hunger", user, level+exhaust, poisontime)
				end
			end

			if not creative then
				local nstack = ItemStack(replace_with_item)
				local inv = user:get_inventory()
				if itemstack:is_empty () then
					itemstack:add_item(replace_with_item)
				elseif inv:room_for_item("main",nstack) then
					inv:add_item("main", nstack)
				else
					core.add_item(user:get_pos(), nstack)
				end
			end
		end
		return itemstack
	end
end

if mcl_hunger.active then
	-- player-action based hunger changes
	core.register_on_dignode(function(_, _, player)
		-- is_fake_player comes from the pipeworks, we are not interested in those
		if not player or not player:is_player() or player.is_fake_player == true then
			return
		end
		local name = player:get_player_name()
		-- dig event
		mcl_hunger.exhaust(name, mcl_hunger.EXHAUST_DIG)
	end)
end
