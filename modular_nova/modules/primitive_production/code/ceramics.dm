#define DEFAULT_SPIN (4 SECONDS)

/*
 * Clay Bricks
 */

/obj/item/stack/sheet/mineral/clay
	name = "clay brick"
	desc = "A heavy clay brick."
	singular_name = "clay brick"
	icon = 'modular_nova/modules/primitive_production/icons/prim_fun.dmi'
	icon_state = "sheet-clay"
	inhand_icon_state = null
	throw_speed = 3
	throw_range = 5
	merge_type = /obj/item/stack/sheet/mineral/clay
	drop_sound = SFX_BRICK_DROP
	pickup_sound = SFX_BRICK_PICKUP

GLOBAL_LIST_INIT(clay_recipes, list ( \
	new/datum/stack_recipe("clay range", /obj/machinery/primitive_stove, 10, time = 5 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_MISC), \
	new/datum/stack_recipe("clay oven", /obj/machinery/oven/stone, 10, time = 5 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_MISC) \
	))

/obj/item/stack/sheet/mineral/clay/get_main_recipes()
	. = ..()
	. += GLOB.clay_recipes

/obj/structure/water_source/puddle/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	if(istype(attacking_item, /obj/item/stack/ore/glass))
		var/obj/item/stack/ore/glass/glass_item = attacking_item
		if(!glass_item.use(1))
			return

		new /obj/item/stack/clay(get_turf(src))
		user.mind.adjust_experience(/datum/skill/production, 1)
		return

	return ..()

/turf/open/water/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	if(istype(attacking_item, /obj/item/stack/ore/glass))
		var/obj/item/stack/ore/glass/glass_item = attacking_item
		if(!glass_item.use(1))
			return

		new /obj/item/stack/clay(src)
		user.mind.adjust_experience(/datum/skill/production, 1)
		return

	return ..()

/obj/structure/sink/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	if(istype(attacking_item, /obj/item/stack/ore/glass))
		if(dispensedreagent != /datum/reagent/water)
			return

		if(reagents.total_volume <= 0)
			return

		var/obj/item/stack/ore/glass/glass_item = attacking_item
		if(!glass_item.use(1))
			return

		new /obj/item/stack/clay(get_turf(src))
		user.mind.adjust_experience(/datum/skill/production, 1)
		return

	return ..()

/obj/item/ceramic
	icon = 'modular_nova/modules/primitive_production/icons/prim_fun.dmi'
	var/forge_item

/obj/item/ceramic/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	if(istype(attacking_item, /obj/item/toy/crayon))
		var/obj/item/toy/crayon/crayon_item = attacking_item
		if(!forge_item || !crayon_item.paint_color)
			return

		color = crayon_item.paint_color
		to_chat(user, span_notice("You color [src] with [crayon_item]..."))
		return

	return ..()

/obj/item/stack/clay
	name = "clay"
	desc = "A pile of clay that can be used to create ceramic artwork."
	icon = 'modular_nova/modules/primitive_production/icons/prim_fun.dmi'
	icon_state = "clay"
	merge_type = /obj/item/stack/clay
	singular_name = "glob of clay"

/datum/export/ceramics
	cost = CARGO_CRATE_VALUE * 2
	unit_name = "ceramic product"
	export_types = list(
		/obj/item/plate/ceramic,
		/obj/item/plate/oven_tray/material/ceramic,
		/obj/item/reagent_containers/cup/bowl/ceramic,
		/obj/item/clay_pot,
		/obj/item/reagent_containers/cup/beaker/large/ceramic,
	)

/datum/export/ceramics/sell_object(obj/O, datum/export_report/report, dry_run, apply_elastic = FALSE) //I really dont want them to feel gimped
	. = ..()

/datum/export/ceramics_unfinished
	cost = CARGO_CRATE_VALUE * 0.5
	unit_name = "unfinished ceramic product"
	export_types = list(/obj/item/ceramic/plate,
						/obj/item/ceramic/bowl,
						/obj/item/ceramic/pot,
						/obj/item/ceramic/tray,
						/obj/item/ceramic/cup)

/datum/export/ceramics_unfinished/sell_object(obj/O, datum/export_report/report, dry_run, apply_elastic = FALSE) //I really dont want them to feel gimped
	. = ..()

/obj/item/ceramic/plate
	name = "ceramic plate"
	desc = "A piece of clay that is flat, in the shape of a plate. Requires heat treatment in a forge."
	icon_state = "clay_plate"
	forge_item = /obj/item/plate/ceramic

/obj/item/plate/ceramic
	name = "ceramic plate"
	icon = 'modular_nova/modules/primitive_production/icons/prim_fun.dmi'
	icon_state = "clay_plate"

/obj/item/ceramic/pot
	name = "ceramic pot"
	desc = "A piece of clay that is curved upwards, in the shape of a pot. Requires heat treatment in a forge."
	icon_state = "clay_pot"
	forge_item = /obj/item/clay_pot

/obj/item/clay_pot
	name = "clay pot"
	desc = "A very empty clay pot. Put some sand and a seed in and call it a day."
	icon = 'modular_nova/modules/primitive_production/icons/prim_fun.dmi'
	icon_state = "clay_pot"

	///whether there is sand, which is required to add turn into a kirby plant from a seed
	var/has_sand = FALSE

/obj/item/clay_pot/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/stack/ore/glass))
		var/obj/item/stack/use_stack = tool
		if(has_sand)
			to_chat(user, span_warning("There is already sand in the pot!"))
			return ITEM_INTERACT_BLOCKING

		to_chat(user, span_notice("You begin to fill [src] with some sand..."))
		if(!do_after(user, 3 SECONDS, target = src))
			to_chat(user, span_notice("You decide against filling the pot with sand."))
			return ITEM_INTERACT_BLOCKING

		if(!use_stack.use(1))
			to_chat(user, span_warning("You find yourself unable to part with [use_stack]!"))
			return ITEM_INTERACT_BLOCKING

		to_chat(user, span_notice("You fill [src] with some sand."))
		has_sand = TRUE
		return ITEM_INTERACT_SUCCESS

	if(istype(tool, /obj/item/seeds))
		if(!has_sand)
			to_chat(user, span_warning("Sand is absolutely required to start planting!"))
			return ITEM_INTERACT_BLOCKING

		to_chat(user, span_notice("You begin to plant a seed inside [src]..."))
		if(!do_after(user, 3 SECONDS, target = src))
			to_chat(user, span_notice("You decide against planting the seed."))
			return ITEM_INTERACT_BLOCKING

		to_chat(user, span_notice("You plant [tool] into the pot."))
		qdel(tool)
		new /obj/item/kirbyplants(drop_location(src))
		qdel(src)
		return ITEM_INTERACT_SUCCESS

	return NONE

/obj/item/ceramic/tray
	name = "ceramic tray"
	desc = "A piece of clay that is flat, in the shape of a tray. Requires heat treatment in a forge."
	icon_state = "clay_tray"
	forge_item = /obj/item/plate/oven_tray/material/ceramic

/obj/item/plate/oven_tray/material/ceramic
	name = "ceramic oven tray"
	icon = 'modular_nova/modules/primitive_production/icons/prim_fun.dmi'
	icon_state = "clay_tray"

/obj/item/ceramic/bowl
	name =  "ceramic bowl"
	desc = "A piece of clay with a raised lip, in the shape of a bowl. Requires heat treatment in a forge."
	icon_state = "clay_bowl"
	forge_item = /obj/item/reagent_containers/cup/bowl/ceramic

/obj/item/reagent_containers/cup/bowl/ceramic
	name = "ceramic bowl"
	icon = 'modular_nova/modules/primitive_production/icons/prim_fun.dmi'
	icon_state = "clay_bowl"
	custom_materials = null

/obj/item/ceramic/cup
	name = "ceramic cup"
	desc = "A piece of clay with high walls, in the shape of a cup. It can hold 120 units. Requires heat treatment in a forge."
	icon_state = "clay_cup"
	forge_item = /obj/item/reagent_containers/cup/beaker/large/ceramic

/obj/item/reagent_containers/cup/beaker/large/ceramic
	name = "ceramic cup"
	desc = "A cup that is made from ceramic."
	icon = 'modular_nova/modules/primitive_production/icons/prim_fun.dmi'
	icon_state = "clay_cup"
	custom_materials = null

/obj/item/ceramic/brick
	name = "ceramic brick"
	desc = "A dense block of clay, ready to be fired into a brick!"
	icon = 'modular_nova/modules/primitive_production/icons/prim_fun.dmi'
	icon_state = "sheet-clay"
	forge_item = /obj/item/stack/sheet/mineral/clay

/obj/structure/throwing_wheel
	name = "throwing wheel"
	desc = "A machine that allows you to throw clay."
	icon = 'modular_nova/modules/primitive_production/icons/prim_fun.dmi'
	icon_state = "throw_wheel_empty"
	density = TRUE
	anchored = TRUE

	///if the structure has clay
	var/has_clay = FALSE

	//if the structure is in use or not
	var/in_use = FALSE

	///the list of items that the throwing wheel can make
	var/static/list/production_list = list(
		"Cup" = /obj/item/ceramic/cup,
		"Plate" = /obj/item/ceramic/plate,
		"Bowl" = /obj/item/ceramic/bowl,
		"Pot" = /obj/item/ceramic/pot,
		"Tray" = /obj/item/ceramic/tray,
		"Brick" = /obj/item/ceramic/brick,
	)

	///the list of messages that are sent whilst "working" the clay
	var/static/list/given_message = list(
		"You slowly start spinning the throwing wheel...",
		"You place your hands on the clay, slowly shaping it...",
		"You start becoming satisfied with what you have made...",
		"You stop the throwing wheel, admiring your new creation...",
	)

/obj/structure/throwing_wheel/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	if(istype(attacking_item, /obj/item/stack/clay))
		if(has_clay)
			return

		var/obj/item/stack/stack_item = attacking_item
		if(!stack_item.use(1))
			return

		has_clay = TRUE
		icon_state = "throw_wheel_full"
		return

	return ..()

/obj/structure/throwing_wheel/crowbar_act(mob/living/user, obj/item/tool)
	tool.play_tool_sound(src)
	new /obj/item/stack/sheet/iron/ten(get_turf(src))
	if(has_clay)
		new /obj/item/stack/clay(get_turf(src))

	qdel(src)

/obj/structure/throwing_wheel/wrench_act(mob/living/user, obj/item/tool)
	tool.play_tool_sound(src)
	anchored = !anchored

/obj/structure/throwing_wheel/proc/use_clay(spawn_type, mob/user)
	var/spinning_speed = user.mind.get_skill_modifier(/datum/skill/production, SKILL_SPEED_MODIFIER) * DEFAULT_SPIN
	for(var/loop_try in 1 to length(given_message))
		if(!do_after(user, spinning_speed, target = src))
			in_use = FALSE
			return

		to_chat(user, span_notice(given_message[loop_try]))

	new spawn_type(get_turf(src))
	user.mind.adjust_experience(/datum/skill/production, 50)
	has_clay = FALSE
	icon_state = "throw_wheel_empty"

/obj/structure/throwing_wheel/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(in_use)
		return

	use(user)
	in_use = FALSE

/**
 * Prompts user for how they wish to use the throwing wheel
 *
 * To make sure in_use var always gets set back to FALSE no matter what happens, do the actual 'using' in its own proc and do the setting to FALSE in attack_hand
 *
 * Arguments:
 * * user - the mob who is using the throwing wheel
 */
/obj/structure/throwing_wheel/proc/use(mob/living/user)
	in_use = TRUE
	var/spinning_speed = user.mind.get_skill_modifier(/datum/skill/production, SKILL_SPEED_MODIFIER) * DEFAULT_SPIN
	if(!has_clay)
		balloon_alert(user, "there is no clay!")
		return

	var/user_input = tgui_alert(user, "What would you like to do?", "Choice Selection", list("Create", "Remove"))
	if(!user_input)
		return

	switch(user_input)
		if("Create")
			var/creation_choice = tgui_input_list(user, "What you like to create?", "Creation Choice", production_list)
			if(isnull(creation_choice))
				return

			use_clay(production_list[creation_choice], user)

		if("Remove")
			if(!do_after(user, spinning_speed, target = src))
				return

			var/atom/movable/new_clay = new /obj/item/stack/clay(get_turf(src))
			user.put_in_active_hand(new_clay)
			has_clay = FALSE
			icon_state = "throw_wheel_empty"

#undef DEFAULT_SPIN
