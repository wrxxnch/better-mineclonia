local S = core.get_translator("mcl_copper")

core.register_craftitem("mcl_copper:copper_ingot", {
	description = S("Copper Ingot"),
	_doc_items_longdesc = S("Molten Raw Copper. It is used to craft blocks."),
	inventory_image = "mcl_copper_ingot.png",
	groups = { craftitem = 1 },
	_mcl_armor_trim_color = "#c36447",
	_mcl_armor_trim_desc = S("Copper Material"),
	_mcl_crafting_output = {
		line_tall3 = {output = "mcl_lightning_rods:rod"},
		square3 = {output = "mcl_copper:block"}
	}
})

core.register_craftitem("mcl_copper:raw_copper", {
	description = S("Raw Copper"),
	_doc_items_longdesc = S("Raw Copper. Mine a Copper Ore to get it."),
	inventory_image = "mcl_copper_raw.png",
	groups = { craftitem = 1, blast_furnace_smeltable = 1 },
	_mcl_cooking_output = "mcl_copper:copper_ingot",
	_mcl_crafting_output = {square3 = {output = "mcl_copper:block_raw"}}
})
