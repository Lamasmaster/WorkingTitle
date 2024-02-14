/obj/item/device/techno_tribalism
	name = "Techno-Tribalism Enforcer"
	desc = "Feeds on rare tools, tool mods and other tech items. After being fed enough, will produce a strange technological part, that will be useful to train your skills overtime."
	icon = 'icons/obj/faction_item.dmi'
	description_info = "Has an internal radio that informs technomancers of its delay, it can be re-enabled with a screwdriver if it is not functioning. Deconstructing other departmental oddities reduces its cooldown. Deconstructing combat-oriented oddities buffs its capability to make better combat oddities."
	description_antag = "You can disable its internal radio with a EMP."
	icon_state = "techno_tribalism"
	item_state = "techno_tribalism"
	origin_tech = list(TECH_MATERIAL = 8, TECH_ENGINEERING = 7, TECH_POWER = 2)
	price_tag = 20000
	spawn_frequency = 0
	spawn_blacklisted = TRUE
	var/list/oddity_stats = list(STAT_INT = 0, STAT_LCK = 0, STAT_INT = 0, STAT_STR = 0, STAT_END = 0, STAT_AGI = 0)
	/// double  for taking out combat-oddities (skydriver , sword of truth)
	// summ of all combat stats points thats permitted
	// 5 power shovels = 30 points
	// deconstructing both gives you a cap of 40
	var/combat_cap = 10
	var/last_produce = -20 MINUTES
	var/items_count = 0
	var/max_count = 5
	var/cooldown = 20 MINUTES
	var/obj/item/device/radio/internal_radio
	var/radio_broadcasting = TRUE

/obj/item/device/techno_tribalism/New()
	..()
	GLOB.all_faction_items[src] = GLOB.department_engineering

/obj/item/device/techno_tribalism/Initialize()
	..()
	internal_radio = new /obj/item/device/radio{channels=list("Engineering")}(src)
	radio_broadcasting = TRUE

/obj/item/device/techno_tribalism/Destroy()
	for(var/mob/living/carbon/human/H in viewers(get_turf(src)))
		SEND_SIGNAL_OLD(H, COMSIG_OBJ_FACTION_ITEM_DESTROY, src)
	GLOB.all_faction_items -= src
	GLOB.technomancer_faction_item_loss++
	..()

/obj/item/device/techno_tribalism/attackby(obj/item/W, mob/user, params)
	if(nt_sword_attack(W, user))
		return FALSE
	if(user.a_intent == I_HELP && W.get_tool_quality(QUALITY_SCREW_DRIVING))
		if(radio_broadcasting == FALSE)
			to_chat(user, "You reenable the [src]'s internal radio broadcaster")
			radio_broadcasting = TRUE
	if(user.a_intent != I_DISARM)
		to_chat(user, "You need to be in a disarming stance to insert items into the [src]")
		return FALSE
	var/starting_sum = list(
		STAT_END = oddity_stats[STAT_END],
		STAT_STR = oddity_stats[STAT_STR],
		STAT_AGI = oddity_stats[STAT_AGI],
		STAT_INT = oddity_stats[STAT_INT],
		STAT_INT = oddity_stats[STAT_INT],
		STAT_LCK = oddity_stats[STAT_LCK]
	)
	if(items_count < max_count)
		if(W in GLOB.all_faction_items)
			to_chat(user, "Inserting the departmental relic decreases the [src]'s delay by 2 minutes!")
			cooldown -= 2 MINUTES
			if(GLOB.all_faction_items[W] == GLOB.department_moebius)
				oddity_stats[STAT_LCK] += 3
				oddity_stats[STAT_INT] += 3
				oddity_stats[STAT_INT] += 3
			else if(GLOB.all_faction_items[W] == GLOB.department_security)
				oddity_stats[STAT_AGI] += 3
				oddity_stats[STAT_END] += 3
				oddity_stats[STAT_STR] += 3
				if(istype(W, /obj/item/gun/projectile/revolver/sky_driver))
					to_chat(user, "This departmental relic is used for combat, it has boosted the [src]'s capability of creating combat oddities.")
					combat_cap *= 2
			else if(GLOB.all_faction_items[W] == GLOB.department_church)
				oddity_stats[STAT_INT] += 3
				oddity_stats[STAT_LCK] += 2
				oddity_stats[STAT_AGI] += 2
				oddity_stats[STAT_END] += 2
				if(istype(W, /obj/item/tool/sword/nt_sword))
					to_chat(user, "This departmental relic is used for combat, it has boosted the [src]'s capability of creating combat oddities.")
					combat_cap *= 2
			else if(GLOB.all_faction_items[W] == GLOB.department_guild)
				oddity_stats[STAT_LCK] += 3
				oddity_stats[STAT_INT] += 3
				oddity_stats[STAT_STR] += 1
				oddity_stats[STAT_AGI] += 2
			else if(GLOB.all_faction_items[W] == GLOB.department_engineering)
				oddity_stats[STAT_INT] += 5
				oddity_stats[STAT_LCK] += 2
				oddity_stats[STAT_END] += 1
				oddity_stats[STAT_AGI] += 1
			else if(GLOB.all_faction_items[W] == GLOB.department_command)
				oddity_stats[STAT_STR] += 2
				oddity_stats[STAT_END] += 1
				oddity_stats[STAT_INT] += 1
				oddity_stats[STAT_INT] += 1
				oddity_stats[STAT_AGI] += 3
				oddity_stats[STAT_LCK] += 1
			else if(GLOB.all_faction_items[W] == GLOB.department_civilian)
				oddity_stats[STAT_INT] += 3
				oddity_stats[STAT_AGI] += 2
				oddity_stats[STAT_LCK] += 2
			else
				CRASH("[W], incompatible department")

		else if(istool(W))
			var/useful = FALSE
			if(W.tool_qualities)

				for(var/quality in W.tool_qualities)

					if(W.tool_qualities[quality] >= 35)
						var/stat_cost = round(W.tool_qualities[quality] / 15)
						if(quality == QUALITY_BOLT_TURNING || quality == QUALITY_SCREW_DRIVING || quality == QUALITY_CUTTING)
							oddity_stats[STAT_LCK] += stat_cost
							useful = TRUE

						else if (quality == QUALITY_PULSING || quality == QUALITY_ADHESIVE || quality == QUALITY_SEALING)
							oddity_stats[STAT_INT] += stat_cost
							useful = TRUE

						else if (quality == QUALITY_PRYING || quality == QUALITY_HAMMERING || quality == QUALITY_DIGGING)
							oddity_stats[STAT_STR] += stat_cost
							useful = TRUE

						else if (quality == QUALITY_WELDING || quality == QUALITY_WIRE_CUTTING || quality == QUALITY_SAWING || quality == QUALITY_LASER_CUTTING)
							oddity_stats[STAT_AGI] += stat_cost
							useful = TRUE

						else if (quality == QUALITY_CLAMPING || quality == QUALITY_CAUTERIZING || quality == QUALITY_RETRACTING || quality == QUALITY_BONE_SETTING)
							oddity_stats[STAT_INT] += stat_cost
							useful = TRUE

						else if (quality == QUALITY_DRILLING || quality == QUALITY_SHOVELING || quality == QUALITY_EXCAVATION)
							oddity_stats[STAT_END] += stat_cost
							useful = TRUE

				if(!useful)
					to_chat(user, SPAN_WARNING("The [W] is not suitable for [src]!"))
					return
			else
				to_chat(user, SPAN_WARNING("The [W] is not suitable for [src]!"))
				return


		else if(istype(W, /obj/item/tool_upgrade))

			var/obj/item/tool_upgrade/T = W

			if(istype(T, /obj/item/tool_upgrade/reinforcement))
				oddity_stats[STAT_END] += 3

			else if(istype(T, /obj/item/tool_upgrade/productivity))
				oddity_stats[STAT_LCK] += 3

			else if(istype(T, /obj/item/tool_upgrade/refinement))
				oddity_stats[STAT_AGI] += 3

			else if(istype(T, /obj/item/tool_upgrade/augment))
				oddity_stats[STAT_INT] += 3


		else if(istype(W, /obj/item/cell))
			if(istype(W, /obj/item/cell/small/moebius/nuclear))
				oddity_stats[STAT_STR] += 2

			else if(istype(W, /obj/item/cell/medium/moebius/nuclear))
				oddity_stats[STAT_STR] += 3

			else if(istype(W, /obj/item/cell/large/moebius/nuclear))
				oddity_stats[STAT_STR] += 4

			else
				oddity_stats[STAT_STR] += 1

		else if(isgun(W))
			oddity_stats[STAT_STR] += 2
			oddity_stats[STAT_AGI] += 2

		else
			to_chat(user, SPAN_WARNING("The [W] is not suitable for [src]!"))
			return

		if(oddity_stats[STAT_STR] + oddity_stats[STAT_AGI] + oddity_stats[STAT_END] > combat_cap)
			to_chat(user, SPAN_WARNING("The [W] goes beyond the Tribalism's capability for combat, perhaps it could be upgraded with combat relics from other factions."))
			for(var/stat in starting_sum)
				oddity_stats[stat] = starting_sum[stat]
			return
		to_chat(user, SPAN_NOTICE("You feed [W] to [src]."))
		SEND_SIGNAL_OLD(user, COMSIG_OBJ_TECHNO_TRIBALISM, W)
		items_count += 1
		qdel(W)

	else
		to_chat(user, SPAN_WARNING("The [src] is full!"))
		return

/obj/item/device/techno_tribalism/attack_self()
	if(world.time >= (last_produce + cooldown))
		if(items_count >= max_count)
			if(ishuman(src.loc))
				var/mob/living/carbon/human/user = src.loc
				var/obj/item/oddity/techno/T = new /obj/item/oddity/techno(src)
				T.oddity_stats = src.oddity_stats
				T.AddComponent(/datum/component/inspiration, T.oddity_stats, T.perk)
				items_count = 0
				oddity_stats = list(STAT_INT = 0, STAT_LCK = 0, STAT_INT = 0, STAT_STR = 0, STAT_END = 0, STAT_AGI = 0)
				// let technos know
				addtimer(CALLBACK(src, PROC_REF(alert_technomancers)), cooldown)
				last_produce = world.time
				user.put_in_hands(T)
			else
				to_chat(src.loc, SPAN_WARNING("The [src] is too complicated to use!"))
		else
			visible_message("\icon The [src] beeps, \"The [src] is not full enough to produce.\".")
	else
		visible_message("\icon The [src] beeps, \"The [src] needs time to cooldown.\".")

/obj/item/device/techno_tribalism/proc/alert_technomancers()
	if(radio_broadcasting)
		internal_radio.autosay("The [src]'s cooldown has expired. It is ready to produce another oddity", "Techno-Tribalism enforcer", "Engineering", TRUE)

/obj/item/device/techno_tribalism/emp_act(severity)
	..()
	if(severity)
		// lets people emp to prevent broadcasting
		radio_broadcasting = FALSE

/obj/item/device/techno_tribalism/examine(user)
	..()
	to_chat(user, SPAN_NOTICE("The [src] is fed by [items_count]/[max_count]."))
	to_chat(user, SPAN_NOTICE("The remaining delay is [world.time > last_produce + cooldown ? "0" : round(abs(world.time - (last_produce + cooldown)) / 600)] Minutes"))
	to_chat(user, SPAN_NOTICE("Its internal radio is currently [internal_radio.broadcasting ? "working normally" : "not functioning"]"))
	to_chat(user, SPAN_NOTICE("The current limit for all combat-oriented skill points on oddities is [combat_cap]."))
