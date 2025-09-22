local S = core.get_translator(core.get_current_modname())

mcl_bells = {}

function mcl_bells.ring_once(pos)
	local alarm_time = core.get_gametime ()

	core.sound_play( "mcl_bells_bell_stroke", { pos = pos, gain = 1.5, max_hear_distance = 150,})
	for o in core.objects_inside_radius(pos, 32) do
		local entity = o:get_luaentity()
		if entity and entity.name == "mobs_mc:villager" then
			entity._last_alarm_gmt = alarm_time
		end

		if entity and entity.is_mob and entity.raidmob then
			local distance = vector.distance (o:get_pos (), pos)
			if distance <= 48 then
				mcl_potions.give_effect ("glowing", o, o, 1, 3)
			end
		end
	end
end

core.register_node("mcl_bells:bell", {
	description = S("Bell"),
	paramtype = "light",
	inventory_image = "mcl_bells_bell.png",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -8/16, -8/16, -8/16,  8/16, -6/16,  8/16 },
			{ -6/16, -6/16, -6/16,  6/16,  6/16,  6/16 },
			{ -2/16,  6/16, -2/16,  2/16,  8/16,  2/16 },
		}
	},
	--tiles = { "blank.png" },
	tiles = {
		"mcl_bells_bell_top.png",
		"mcl_bells_bell_bottom.png",
		"mcl_bells_bell_side.png",
	},
	is_ground_content = false,
	groups = {pickaxey=2, deco_block=1, dig_by_piston=1, pathfinder_partial = 2,},
	sounds = mcl_sounds.node_sound_metal_defaults(),
	_mcl_hardness = 5,
	on_rightclick = mcl_bells.ring_once,
	use_texture_alpha = "clip",
	_mcl_redstone = {
		update = function(pos, node)
			local oldpowered = node.param2 ~= 0
			local powered = mcl_redstone.get_power(pos) ~= 0
			if powered and not oldpowered then
				mcl_bells.ring_once(pos)
			end

			core.swap_node(pos, {
				name = node.name,
				param2 = powered and 1 or 0,
			})
		end,
	},
})
