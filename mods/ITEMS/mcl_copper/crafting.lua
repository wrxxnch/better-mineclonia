local block_type = { "", "_cut", "_chiseled", "_grate" }
local block_exposure_level = { "", "_exposed", "_weathered", "_oxidized" }
local waxed = { "", "_preserved" }

for _, x in ipairs(block_exposure_level) do
	for _, w in ipairs(waxed) do
		core.register_craft({
			output = "mcl_copper:block"..x.."_cut"..w.." 4",
			recipe = {
				{ "mcl_copper:block"..x..w, "mcl_copper:block"..x..w },
				{ "mcl_copper:block"..x..w, "mcl_copper:block"..x..w }
			}
		})
	end
end

for _, x in ipairs(block_exposure_level) do
	for _, w in ipairs(waxed) do
		core.register_craft({
			output = "mcl_copper:block"..x.."_grate"..w.." 4",
			recipe = {
				{ "", "mcl_copper:block"..x..w, "" },
				{ "mcl_copper:block"..x..w, "", "mcl_copper:block"..x..w },
				{ "", "mcl_copper:block"..x..w, "" }
			}
		})
	end
end

for _, x in ipairs(block_exposure_level) do
	for _, w in ipairs(waxed) do
		core.register_craft({
			output = "mcl_copper:block"..x.."_chiseled"..w.." 4",
			recipe = {
				{ "mcl_stairs:slab_copper"..x.."_cut"..w },
				{ "mcl_stairs:slab_copper"..x.."_cut"..w }
			}
		})
	end
end

for _, x in ipairs(block_exposure_level) do
	core.register_craft({
		output = "mcl_stairs:slab_copper"..x.."_cut_preserved 6",
		recipe = {
			{ "mcl_copper:block"..x.."_cut_preserved", "mcl_copper:block"..x.."_cut_preserved", "mcl_copper:block"..x.."_cut_preserved" }
		}
	})
end

for _, x in ipairs(block_exposure_level) do
	core.register_craft({
		output = "mcl_stairs:stair_copper"..x.."_cut_preserved 4",
		recipe = {
			{ "", "", "mcl_copper:block"..x.."_cut_preserved" },
			{"", "mcl_copper:block"..x.."_cut_preserved", "mcl_copper:block"..x.."_cut_preserved"},
			{"mcl_copper:block"..x.."_cut_preserved", "mcl_copper:block"..x.."_cut_preserved", "mcl_copper:block"..x.."_cut_preserved" }
		}
	})
end

for _, x in ipairs(block_exposure_level) do
	core.register_craft({
		output = "mcl_stairs:stair_copper"..x.."_cut_preserved 4",
		recipe = {
			{ "mcl_copper:block"..x.."_cut_preserved", "", "" },
			{ "mcl_copper:block"..x.."_cut_preserved", "mcl_copper:block"..x.."_cut_preserved", "" },
			{ "mcl_copper:block"..x.."_cut_preserved", "mcl_copper:block"..x.."_cut_preserved", "mcl_copper:block"..x.."_cut_preserved" }
		}
	})
end

for _, x in ipairs(block_exposure_level) do
	for _, w in ipairs(waxed) do
		core.register_craft({
			output = "mcl_copper:bulb"..x.."_off"..w.." 4",
			recipe = {
				{ "", "mcl_copper:block"..x..w, "" },
				{ "mcl_copper:block"..x..w, "mcl_mobitems:blaze_rod", "mcl_copper:block"..x..w },
				{ "", "mesecons:redstone", "" }
			}
		})
	end
end

core.register_craft({
	output = "mcl_copper:door 3",
	recipe = {
		{ "mcl_copper:copper_ingot", "mcl_copper:copper_ingot" },
		{ "mcl_copper:copper_ingot", "mcl_copper:copper_ingot" },
		{ "mcl_copper:copper_ingot", "mcl_copper:copper_ingot" }
	}
})

core.register_craft({
	output = "mcl_copper:trapdoor 2",
	recipe = {
		{ "mcl_copper:copper_ingot", "mcl_copper:copper_ingot", "mcl_copper:copper_ingot" },
		{ "mcl_copper:copper_ingot", "mcl_copper:copper_ingot", "mcl_copper:copper_ingot" }
	}
})

for _, t in ipairs(block_type) do
	for _, x in ipairs(block_exposure_level) do
		core.register_craft({
			output = "mcl_copper:block"..x..t.."_preserved",
			recipe = {
				{ "mcl_copper:block"..x..t, "mcl_honey:honeycomb" }
			}
		})
	end
end

-- for _, x in ipairs(block_exposure_level) do
-- 	core.register_craft({
-- 		output = "mcl_copper:door"..x.."_preserved",
-- 		recipe = {
-- 			{ "mcl_copper:door"..x, "mcl_honey:honeycomb" }
-- 		}
-- 	})
-- end

for _, x in ipairs(block_exposure_level) do
	core.register_craft({
		output = "mcl_copper:trapdoor"..x.."_preserved",
		recipe = {
			{ "mcl_copper:trapdoor"..x, "mcl_honey:honeycomb" }
		}
	})
end

for _, x in ipairs(block_exposure_level) do
	core.register_craft({
		output = "mcl_copper:bulb"..x.."_off_preserved",
		recipe = {
			{ "mcl_copper:bulb"..x.."_off", "mcl_honey:honeycomb" }
		}
	})
end

for _, x in ipairs(block_exposure_level) do
	core.register_craft({
		output = "mcl_stairs:slab_copper"..x.."_cut_preserved",
		recipe = {
			{ "mcl_stairs:slab_copper"..x.."_cut", "mcl_honey:honeycomb" }
		}
	})
end

for _, x in ipairs(block_exposure_level) do
	core.register_craft({
		output = "mcl_stairs:stair_copper"..x.."_cut_preserved",
		recipe = {
			{ "mcl_stairs:stair_copper"..x.."_cut", "mcl_honey:honeycomb" }
		}
	})
end
