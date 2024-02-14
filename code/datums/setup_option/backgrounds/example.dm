/datum/category_group/setup_option_category/background/example
	name = "Example"
	category_item_type = /datum/category_item/setup_option/background/example

/datum/category_item/setup_option/background/example

/datum/category_item/setup_option/background/example/example
	name = "Example"
	desc = "Example background"
	restricted_depts = MEDICAL | SCIENCE
	restricted_jobs = list(/datum/job/captain)
	stat_modifiers = list(
		STAT_STR = 1,
		STAT_PER = 1,
		STAT_END = 2,
		STAT_CHR = 3,
		STAT_INT = 4,
		STAT_AGI = 5,
		STAT_LCK = 6
	)
	perks = list(/datum/perk)
