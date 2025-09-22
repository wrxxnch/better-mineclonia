local S = core.get_translator(core.get_current_modname())

-- Taken from https://minecraft.gamepedia.com/Enchanting

local function increase_damage(damage_group, factor)
	return function(itemstack, level)
		local tool_capabilities = itemstack:get_tool_capabilities()
		tool_capabilities.damage_groups[damage_group] = (tool_capabilities.damage_groups[damage_group] or 0) + level * factor
		itemstack:get_meta():set_tool_capabilities(tool_capabilities)
	end
end

-- implemented via on_enchant and additions in mobs_mc; Slowness IV part unimplemented
mcl_enchanting.enchantments.bane_of_arthropods = {
	name = S("Bane of Arthropods"),
	max_level = 5,
	primary = {sword = true},
	secondary = {axe = true},
	disallow = {},
	incompatible = {smite = true, sharpness = true, density = true, breach = true},
	weight = 5,
	description = S("Increases damage and applies Slowness IV to arthropod mobs (spiders, cave spiders, silverfish and endermites)."),
	curse = false,
	on_enchant = increase_damage("arthropod", 2.5),
	requires_tool = false,
	treasure = false,
	power_range_table = {{5, 25}, {13, 33}, {21, 41}, {29, 49}, {37, 57}},
	inv_combat_tab = true,
	inv_tool_tab = false,
	anvil_item_factor = 2,
	anvil_book_factor = 1,
}

-- requires missing MineClone2 feature
--[[mcl_enchanting.enchantments.channeling = {
	name = S("Channeling"),
	max_level = 1,
	primary = {trident = true},
	secondary = {},
	disallow = {},
	incompatible = {riptide = true},
	weight = 1,
	description = S("Channels a bolt of lightning toward a target. Works only during thunderstorms and if target is unobstructed with opaque blocks."),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = false,
	power_range_table = {{25, 50}},
	inv_combat_tab = true,
	inv_tool_tab = false,
	anvil_item_factor = 8,
	anvil_book_factor = 4,
}]]--

-- implemented in mcl_death_drop
mcl_enchanting.enchantments.curse_of_vanishing = {
	name = S("Curse of Vanishing"),
	max_level = 1,
	primary = {},
	secondary = {armor_head = true, armor_torso = true, armor_legs = true, armor_feet = true, tool = true, weapon = true},
	disallow = {},
	incompatible = {},
	weight = 1,
	description = S("Item destroyed on death."),
	curse = true,
	on_enchant = function() end,
	requires_tool = false,
	treasure = true,
	power_range_table = {{25, 50}},
	inv_combat_tab = true,
	inv_tool_tab = true,
	anvil_item_factor = 8,
	anvil_book_factor = 4,
}

-- implemented below
mcl_enchanting.enchantments.depth_strider = {
	name = S("Depth Strider"),
	max_level = 3,
	primary = {},
	secondary = {armor_feet = true},
	disallow = {non_combat_armor = true},
	incompatible = {frost_walker = true},
	weight = 2,
	description = S("Increases underwater movement speed."),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = false,
	power_range_table = {{10, 25}, {20, 35}, {30, 45}},
	inv_combat_tab = true,
	inv_tool_tab = false,
	anvil_item_factor = 4,
	anvil_book_factor = 2,
}

mcl_player.register_globalstep_slow(function(player)
	if core.get_item_group(mcl_player.players[player].nodes.feet, "liquid") ~= 0 and mcl_enchanting.get_enchantment(player:get_inventory():get_stack("armor", 5), "depth_strider") then
		local boots = player:get_inventory():get_stack("armor", 5)
		local depth_strider = mcl_enchanting.get_enchantment(boots, "depth_strider")

		if depth_strider > 0 then
			playerphysics.add_physics_factor(player, "speed", "mcl_playerplus:depth_strider", (depth_strider / 3) + 0.75)
		end
	else
		playerphysics.remove_physics_factor(player, "speed", "mcl_playerplus:depth_strider")
	end
end)

function mcl_enchanting.depth_strider_level (mob)
	if not mob.armor_list or mob.armor_list.feet == "" then
		return 0
	end

	local stack = ItemStack (mob.armor_list.feet)
	return stack:is_empty () and 0
		or mcl_enchanting.get_enchantment (stack, "depth_strider")
end

-- implemented via on_enchant
mcl_enchanting.enchantments.efficiency = {
	name = S("Efficiency"),
	max_level = 5,
	primary = {pickaxe = true, shovel = true, axe = true, hoe = true},
	secondary = {shears = true},
	disallow = {},
	incompatible = {},
	weight = 10,
	description = S("Increases mining speed."),
	curse = false,
	on_enchant = function()
		-- Updating digging speed is handled by update_groupcaps which
		-- is called from load_enchantments.
	end,
	requires_tool = false,
	treasure = false,
	power_range_table = {{1, 61}, {11, 71}, {21, 81}, {31, 91}, {41, 101}},
	inv_combat_tab = false,
	inv_tool_tab = true,
	anvil_item_factor = 1,
	anvil_book_factor = 1,
}

-- implemented in mcl_mobs and via register_on_punchplayer callback
mcl_enchanting.enchantments.fire_aspect = {
	name = S("Fire Aspect"),
	max_level = 2,
	primary = {sword = true},
	secondary = {},
	disallow = {},
	incompatible = {},
	weight = 2,
	description = S("Sets target on fire."),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = false,
	power_range_table = {{10, 61}, {30, 71}},
	inv_combat_tab = true,
	inv_tool_tab = false,
	anvil_item_factor = 4,
	anvil_book_factor = 2,
}

core.register_on_punchplayer(function(player, hitter)
	local wielditem = hitter and mcl_util.get_wielditem (hitter)
	if wielditem then
		local fire_aspect_level = mcl_enchanting.get_enchantment(wielditem, "fire_aspect")
		if fire_aspect_level > 0 then
			mcl_burning.set_on_fire(player, fire_aspect_level * 4)
		end
	end
end)

mcl_enchanting.enchantments.flame = {
	name = S("Flame"),
	max_level = 1,
	primary = {bow = true},
	secondary = {},
	disallow = {},
	incompatible = {},
	weight = 2,
	description = S("Arrows set target on fire."),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = false,
	power_range_table = {{20, 50}},
	inv_combat_tab = true,
	inv_tool_tab = false,
	anvil_item_factor = 4,
	anvil_book_factor = 2,
}

-- implemented in mcl_item_entity
mcl_enchanting.enchantments.fortune = {
	name = S("Fortune"),
	max_level = 3,
	primary = {pickaxe = true, shovel = true, axe = true, hoe = true},
	secondary = {},
	disallow = {},
	incompatible = {silk_touch = true},
	weight = 2,
	description = S("Increases certain block drops."),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = false,
	power_range_table = {{15, 61}, {24, 71}, {33, 81}},
	inv_combat_tab = false,
	inv_tool_tab = true,
	anvil_item_factor = 4,
	anvil_book_factor = 2,
}

-- implemented via walkover.register_global
mcl_enchanting.enchantments.frost_walker = {
	name = S("Frost Walker"),
	max_level = 2,
	primary = {},
	secondary = {armor_feet = true},
	disallow = {non_combat_armor = true},
	incompatible = {depth_strider = true},
	weight = 2,
	description = S("Turns water beneath the player into frosted ice and prevents the damage from magma blocks."),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = true,
	power_range_table = {{10, 25}, {20, 35}},
	inv_combat_tab = true,
	inv_tool_tab = false,
	anvil_item_factor = 4,
	anvil_book_factor = 2,
}

walkover.register_global(function(pos, _, player)
	local boots = player:get_inventory():get_stack("armor", 5)
	local frost_walker = mcl_enchanting.get_enchantment(boots, "frost_walker")
	if frost_walker <= 0 then
		return
	end
	local radius = frost_walker + 2
	local minp = {x = pos.x - radius, y = pos.y, z = pos.z - radius}
	local maxp = {x = pos.x + radius, y = pos.y, z = pos.z + radius}
	local positions = core.find_nodes_in_area_under_air(minp, maxp, "mcl_core:water_source")
	for _, p in ipairs(positions) do
		if vector.distance(pos, p) <= radius then
			core.set_node(p, {name = "mcl_core:frosted_ice_0"})
		end
	end
end)

-- requires missing MineClone2 feature
--[[mcl_enchanting.enchantments.impaling = {
	name = S("Impaling"),
	max_level = 5,
	primary = {trident = true},
	secondary = {},
	disallow = {},
	incompatible = {},
	weight = 2,
	description = S("Trident deals additional damage to ocean mobs."),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = false,
	power_range_table = {{1, 21}, {9, 29}, {17, 37}, {25, 45}, {33, 53}},
	inv_combat_tab = true,
	inv_tool_tab = false,
	anvil_item_factor = 4,
	anvil_book_factor = 2,
}]]--

-- implemented in mcl_bows
mcl_enchanting.enchantments.infinity = {
	name = S("Infinity"),
	max_level = 1,
	primary = {bow = true},
	secondary = {},
	disallow = {},
	incompatible = {mending = true},
	weight = 1,
	description = S("Shooting consumes no regular arrows."),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = false,
	power_range_table = {{20, 50}},
	inv_combat_tab = true,
	inv_tool_tab = false,
	anvil_item_factor = 8,
	anvil_book_factor = 4,
}

-- implemented via core.calculate_knockback
mcl_enchanting.enchantments.knockback = {
	name = S("Knockback"),
	max_level = 2,
	primary = {sword = true},
	secondary = {},
	disallow = {},
	incompatible = {},
	weight = 5,
	description = S("Increases knockback."),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = false,
	power_range_table = {{5, 61}, {25, 71}},
	inv_combat_tab = true,
	inv_tool_tab = false,
	anvil_item_factor = 2,
	anvil_book_factor = 1,
}

function core.calculate_knockback(player, hitter, time_from_last_punch, tool_capabilities, dir, distance, damage)
	-- Core knockback computation is overridden by mcl_player.
	return 0
end

-- implemented in mcl_mobs and mobs_mc
mcl_enchanting.enchantments.looting = {
	name = S("Looting"),
	max_level = 3,
	primary = {sword = true},
	secondary = {},
	disallow = {},
	incompatible = {},
	weight = 2,
	description = S("Increases mob loot."),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = false,
	power_range_table = {{15, 61}, {24, 71}, {33, 81}},
	inv_combat_tab = true,
	inv_tool_tab = false,
	anvil_item_factor = 4,
	anvil_book_factor = 2,
}

-- requires missing MineClone2 feature
--[[mcl_enchanting.enchantments.loyalty = {
	name = S("Loyalty"),
	max_level = 3,
	primary = {trident = true},
	secondary = {},
	disallow = {},
	incompatible = {riptide = true},
	weight = 5,
	description = S("Trident returns after being thrown. Higher levels reduce return time."),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = false,
	power_range_table = {{12, 50}, {19, 50}, {26, 50}},
	inv_combat_tab = true,
	inv_tool_tab = false,
	anvil_item_factor = 1,
	anvil_book_factor = 1,
}]]--

-- implemented in mcl_fishing
mcl_enchanting.enchantments.luck_of_the_sea = {
	name = S("Luck of the Sea"),
	max_level = 3,
	primary = {fishing_rod = true},
	secondary = {},
	disallow = {},
	incompatible = {},
	weight = 2,
	description = S("Increases rate of good loot (enchanting books, etc.)"),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = false,
	power_range_table = {{15, 61}, {24, 71}, {33, 81}},
	inv_combat_tab = false,
	inv_tool_tab = true,
	anvil_item_factor = 4,
	anvil_book_factor = 2,
}

-- implemented in mcl_fishing
mcl_enchanting.enchantments.lure = {
	name = S("Lure"),
	max_level = 3,
	primary = {fishing_rod = true},
	secondary = {},
	disallow = {},
	incompatible = {},
	weight = 2,
	description = S("Decreases time until rod catches something."),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = false,
	power_range_table = {{15, 61}, {24, 71}, {33, 81}},
	inv_combat_tab = false,
	inv_tool_tab = true,
	anvil_item_factor = 4,
	anvil_book_factor = 2,
}

-- implemented in mcl_experience
mcl_enchanting.enchantments.mending = {
	name = S("Mending"),
	max_level = 1,
	primary = {},
	secondary = {armor_head = true, armor_torso = true, armor_legs = true, armor_feet = true, tool = true, weapon = true},
	disallow = {},
	incompatible = {infinity = true},
	weight = 2,
	description = S("Repair the item while gaining XP orbs."),
	curse = false,
	on_enchant = function() end,
	requires_tool = true,
	treasure = true,
	power_range_table = {{25, 75}},
	inv_combat_tab = true,
	inv_tool_tab = true,
	anvil_item_factor = 4,
	anvil_book_factor = 2,
}

mcl_experience.register_on_add_xp(function(player, xp)
	local inv = player:get_inventory()

	local candidates = {
		{list = "main", index = player:get_wield_index()},
		{list = "armor", index = 2},
		{list = "armor", index = 3},
		{list = "armor", index = 4},
		{list = "armor", index = 5},
		{list = "offhand", index = 1},
	}

	local final_candidates = {}
	for _, can in ipairs(candidates) do
		local stack = inv:get_stack(can.list, can.index)
		local wear = stack:get_wear()
		if mcl_enchanting.has_enchantment(stack, "mending") and wear > 0 then
			can.stack = stack
			can.wear = wear
			table.insert(final_candidates, can)
		end
	end

	if #final_candidates > 0 then
		local can = final_candidates[math.random(#final_candidates)]
		local stack, list, index, wear = can.stack, can.list, can.index, can.wear
		local unbreaking_level = mcl_enchanting.get_enchantment(stack, "unbreaking") or 0
		local uses = mcl_util.calculate_durability(stack)
		local multiplier = 2 * 65535 / uses * ( unbreaking_level + 1 )
		local repair = xp * multiplier
		local new_wear = wear - repair

		if new_wear < 0 then
			xp = math.floor(-new_wear / multiplier + 0.5)
			new_wear = 0
		else
			xp = 0
		end

		local tooldef = stack:get_definition ()
		if tooldef and tooldef._on_repair then
			tooldef._on_repair (stack)
		end

		stack:set_wear(math.floor(new_wear))
		inv:set_stack(list, index, stack)
	end

	return xp
end, 0)

mcl_enchanting.enchantments.multishot = {
	name = S("Multishot"),
	max_level = 1,
	primary = {crossbow = true},
	secondary = {},
	disallow = {},
	incompatible = {piercing = true},
	weight = 2,
	description = S("Shoot 3 arrows at the cost of one."),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = false,
	power_range_table = {{20, 50}},
	inv_combat_tab = true,
	inv_tool_tab = false,
	anvil_item_factor = 4,
	anvil_book_factor = 2,
}

-- requires missing MineClone2 feature
mcl_enchanting.enchantments.piercing = {
	name = S("Piercing"),
	max_level = 4,
	primary = {crossbow = true},
	secondary = {},
	disallow = {},
	incompatible = {multishot = true},
	weight = 10,
	description = S("Arrows passes through multiple objects."),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = false,
	power_range_table = {{1, 50}, {11, 50}, {21, 50}, {31, 50}},
	inv_combat_tab = true,
	inv_tool_tab = false,
	anvil_item_factor = 1,
	anvil_book_factor = 1,
}

-- implemented in mcl_bows
mcl_enchanting.enchantments.power = {
	name = S("Power"),
	max_level = 5,
	primary = {bow = true},
	secondary = {},
	disallow = {},
	incompatible = {},
	weight = 10,
	description = S("Increases arrow damage."),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = false,
	power_range_table = {{1, 16}, {11, 26}, {21, 36}, {31, 46}, {41, 56}},
	inv_combat_tab = true,
	inv_tool_tab = false,
	anvil_item_factor = 1,
	anvil_book_factor = 1,
}

-- implemented via core.calculate_knockback (together with the Knockback enchantment) and mcl_bows
mcl_enchanting.enchantments.punch = {
	name = S("Punch"),
	max_level = 2,
	primary = {},
	secondary = {bow = true},
	disallow = {},
	incompatible = {},
	weight = 2,
	description = S("Increases arrow knockback."),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = false,
	power_range_table = {{12, 37}, {32, 57}},
	inv_combat_tab = true,
	inv_tool_tab = false,
	anvil_item_factor = 4,
	anvil_book_factor = 2,
}

-- requires missing MineClone2 feature
mcl_enchanting.enchantments.quick_charge = {
	name = S("Quick Charge"),
	max_level = 3,
	primary = {crossbow = true},
	secondary = {},
	disallow = {},
	incompatible = {},
	weight = 5,
	description = S("Decreases crossbow charging time."),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = false,
	power_range_table = {{12, 50}, {32, 50}, {52, 50}},
	inv_combat_tab = true,
	inv_tool_tab = false,
	anvil_item_factor = 2,
	anvil_book_factor = 1,
}

-- implemented below
mcl_enchanting.enchantments.respiration = {
	name = S("Respiration"),
	max_level = 3,
	primary = {armor_head = true},
	secondary = {},
	disallow = {non_combat_armor = true},
	incompatible = {},
	weight = 2,
	description = S("Extends underwater breathing time."),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = false,
	power_range_table = {{10, 40}, {20, 50}, {30, 60}},
	inv_combat_tab = true,
	inv_tool_tab = false,
	anvil_item_factor = 4,
	anvil_book_factor = 2,
}

-- requires missing MineClone2 feature
--[[mcl_enchanting.enchantments.riptide = {
	name = S("Riptide"),
	max_level = 3,
	primary = {trident = true},
	secondary = {},
	disallow = {},
	incompatible = {channeling = true, loyalty = true},
	weight = 2,
	description = S("Trident launches player with itself when thrown. Works only in water or rain."),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = false,
	power_range_table = {{17, 50}, {24, 50}, {31, 50}},
	inv_combat_tab = true,
	inv_tool_tab = false,
	anvil_item_factor = 4,
	anvil_book_factor = 2,
}]]--

-- implemented via on_enchant
mcl_enchanting.enchantments.sharpness = {
	name = S("Sharpness"),
	max_level = 5,
	primary = {sword = true},
	secondary = {axe = true},
	disallow = {},
	incompatible = {bane_of_arthropods = true, smite = true},
	weight = 5,
	description = S("Increases damage."),
	curse = false,
	on_enchant = increase_damage("fleshy", 0.5),
	requires_tool = false,
	treasure = false,
	power_range_table = {{1, 21}, {12, 32}, {23, 43}, {34, 54}, {45, 65}},
	inv_combat_tab = true,
	inv_tool_tab = false,
	anvil_item_factor = 1,
	anvil_book_factor = 1,
}

-- implemented in mcl_item_entity
mcl_enchanting.enchantments.silk_touch = {
	name = S("Silk Touch"),
	max_level = 1,
	primary = {pickaxe = true, shovel = true, axe = true, hoe = true},
	secondary = {shears = true},
	disallow = {},
	incompatible = {fortune = true},
	weight = 1,
	description = S("Mined blocks drop themselves."),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = false,
	power_range_table = {{15, 61}},
	inv_combat_tab = false,
	inv_tool_tab = true,
	anvil_item_factor = 8,
	anvil_book_factor = 4,
}

-- implemented via on_enchant and additions in mobs_mc
mcl_enchanting.enchantments.smite = {
	name = S("Smite"),
	max_level = 5,
	primary = {sword = true},
	secondary = {axe = true},
	disallow = {},
	incompatible = {bane_of_arthropods = true, sharpness = true, density = true, breach = true},
	weight = 5,
	description = S("Increases damage to undead mobs."),
	curse = false,
	on_enchant = increase_damage("undead", 2.5),
	requires_tool = false,
	treasure = false,
	power_range_table = {{5, 25}, {13, 33}, {21, 41}, {29, 49}, {37, 57}},
	inv_combat_tab = true,
	inv_tool_tab = false,
	anvil_item_factor = 2,
	anvil_book_factor = 1,
}

-- implemented in mcl_playerplus
mcl_enchanting.enchantments.soul_speed = {
	name = S("Soul Speed"),
	max_level = 3,
	primary = {},
	secondary = {armor_feet = true},
	disallow = {non_combat_armor = true},
	incompatible = {frost_walker = true},
	weight = 2,
	description = S("Increases walking speed on soul sand."),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = true,
	power_range_table = {{10, 25}, {20, 35}, {30, 45}},
	inv_combat_tab = true,
	inv_tool_tab = false,
	anvil_item_factor = 8,
	anvil_book_factor = 4,
}

-- requires missing MineClone2 feature
--[[mcl_enchanting.enchantments.sweeping_edge = {
	name = S("Sweeping Edge"),
	max_level = 3,
	primary = {sword = true},
	secondary = {},
	disallow = {},
	incompatible = {},
	weight = 2,
	description = S("Increases sweeping attack damage."),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = false,
	power_range_table = {{5, 20}, {14, 29}, {23, 38}},
	inv_combat_tab = true,
	inv_tool_tab = false,
	anvil_item_factor = 4,
	anvil_book_factor = 2,
}]]--

-- for tools & weapons implemented via on_enchant; for bows implemented in mcl_bows; for armor implemented in mcl_armor and mcl_tt; for fishing rods implemented in mcl_fishing
mcl_enchanting.enchantments.unbreaking = {
	name = S("Unbreaking"),
	max_level = 3,
	primary = {armor_head = true, armor_torso = true, armor_legs = true, armor_feet = true, pickaxe = true, shovel = true, axe = true, hoe = true, sword = true, fishing_rod = true, bow = true, crossbow = true, },
	secondary = {tool = true},
	disallow = {non_combat_armor = true},
	incompatible = {},
	weight = 5,
	description = S("Increases item durability."),
	curse = false,
	on_enchant = function(itemstack, level)
		local name = itemstack:get_name()
		if not core.registered_tools[name].tool_capabilities then
			return
		end

		local tool_capabilities = itemstack:get_tool_capabilities()
		tool_capabilities.punch_attack_uses = tool_capabilities.punch_attack_uses * (1 + level)
		itemstack:get_meta():set_tool_capabilities(tool_capabilities)

		-- Updating digging durability is handled by update_groupcaps
		-- which is called from load_enchantments.
	end,
	requires_tool = true,
	treasure = false,
	power_range_table = {{5, 61}, {13, 71}, {21, 81}},
	inv_combat_tab = true,
	inv_tool_tab = true,
	anvil_item_factor = 2,
	anvil_book_factor = 1,
}

-- implemented in mcl_tools
mcl_enchanting.enchantments.density = {
	name = S("Density"),
	max_level = 5,
	primary = { mace = true},
	secondary = { mace = true},
	disallow = {},
	incompatible = { breach = true, bane_of_arthropods = true, smite = true },
	weight = 2,
	description = S("Increases mace damage when falling."),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = true,
	power_range_table = {{10, 25}, {20, 35}, {30, 45}, {40, 55}, {50, 65}},
	inv_combat_tab = true,
	inv_tool_tab = false,
	anvil_item_factor = 8,
	anvil_book_factor = 4,
}

-- implemented in mcl_armor
mcl_enchanting.enchantments.breach = {
	name = S("Breach"),
	max_level = 4,
	primary = { mace = true},
	secondary = { mace = true},
	disallow = {},
	incompatible = { density = true, bane_of_arthropods = true, smite = true },
	weight = 2,
	description = S("Reduces target's armor effectiveness."),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = true,
	power_range_table = {{10, 25}, {20, 35}, {30, 45}, {40, 55}},
	inv_combat_tab = true,
	inv_tool_tab = false,
	anvil_item_factor = 8,
	anvil_book_factor = 4,
}

-- implemented in mcl_tools
mcl_enchanting.enchantments.wind_burst = {
	name = S("Wind Burst"),
	max_level = 3,
	primary = { mace = true},
	secondary = { mace = true},
	disallow = {},
	incompatible = {},
	weight = 2,
	description = S("Emits a burst of wind from a mace smash attack."),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = true,
	power_range_table = {{10, 25}, {20, 35}, {30, 45}},
	inv_combat_tab = true,
	inv_tool_tab = false,
	anvil_item_factor = 8,
	anvil_book_factor = 4,
}

-- Respiration breath_max adjustment.
function mcl_enchanting.update_respiration (player, resp_lv)
	if not player:is_player () then return end

	resp_lv = math.min (math.ceil (tonumber (resp_lv)), 255)
	local meta = player:get_meta ()
	if resp_lv < 0 then return end

	-- Luanti's native breath seems to be not draining by 1 per second.
	-- Also, non-10s breaths result in uneven hud bubble pop.
	-- Default = 10 breath = roughly 19s (MC 15s).
	-- Respiration III = 40 breath = roughly 78s (MC 60s).
	local new_max = 10 + (10 * resp_lv)
	local old_max = player:get_properties ().breath_max
	if new_max == old_max then return end

	meta:set_int ("respiration_level", resp_lv)
	player:set_properties ({breath_max = new_max})
	local old_breath = player:get_breath ()
	if new_max > old_max then
		if old_breath == old_max then
			player:set_breath (new_max)
		end
	else -- new_max < old_max
		if old_breath > new_max then
			player:set_breath (new_max)
		end
	end
end

-- Respiration drown damage reduction.
mcl_damage.register_modifier (function (obj, damage, reason)
	if reason.type == "drown" and obj:is_player () then
		local resp_lv = obj:get_meta ():get_int ("respiration_level") or 0
		resp_lv = math.min (math.ceil (tonumber (resp_lv)), 255)
		if resp_lv <= 0 then return damage end

		-- chance to resist damage = level / ( level + 1 ), thus
		-- chance to take damage = 1 / ( level + 1 )
		local roll = math.random( resp_lv + 1 )
		return roll == 1 and damage or 0
	end
	return damage
end)