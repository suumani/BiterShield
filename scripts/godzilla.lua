data:extend({
	{
		type = "unit",
		name = "ÉSÉWÉâ",
		icon = "__base__/graphics/icons/small-biter.png",
		icon_size = 256, icon_mipmaps = 4,
		flags = {"placeable-player", "placeable-enemy", "placeable-off-grid", "breaths-air"},
		max_health = 15000,
		order = "b-b-a",
		subgroup = "enemies",
		healing_per_tick = 0.01,
		collision_box = {{-0.2, -0.2}, {0.2, 0.2}},
		selection_box = {{-0.4, -0.7}, {0.7, 0.4}},
		attack_parameters = {
			type = "projectile",
			range = 0.5,
			cooldown = 35,
			ammo_category = "melee",
			ammo_type = {
				category = "melee",
				target_type = "entity",
				action = {
					type = "direct",
					action_delivery = {
					type = "instant",
					target_effects = {
						type = "damage",
						damage = { amount = 7, type = "physical"}
					}
				}
			}
		},
		animation = {
			layers = {
				{
					filename = "__base__/graphics/entity/small-biter/small-biter-run.png",
					width = 80,
					height = 80,
					scale = 0.5,
					direction_count = 16
					}
				}
			}
		},
		vision_distance = 30,
		movement_speed = 0.2,
		distance_per_frame = 0.1,
		pollution_to_join_attack = 200,
		distraction_cooldown = 300
	}
})