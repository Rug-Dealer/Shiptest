
/obj/vehicle/ridden/atv
	name = "all-terrain vehicle"
	desc = "An all-terrain vehicle built for traversing rough terrain with ease. One of the few old-Earth technologies that are still relevant on most planet-bound outposts."
	icon_state = "atv"
	max_integrity = 150
	armor = list("melee" = 50, "bullet" = 25, "laser" = 20, "energy" = 0, "bomb" = 50, "bio" = 0, "rad" = 0, "fire" = 60, "acid" = 60)
	key_type = /obj/item/key
	integrity_failure = 0.5
	var/static/mutable_appearance/atvcover

/obj/vehicle/ridden/atv/Initialize()
	. = ..()
	var/datum/component/riding/D = LoadComponent(/datum/component/riding)
	D.vehicle_move_delay = 1.5
	D.set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 4), TEXT_SOUTH = list(0, 4), TEXT_EAST = list(0, 4), TEXT_WEST = list(0, 4)))
	D.set_vehicle_dir_layer(SOUTH, ABOVE_MOB_LAYER)
	D.set_vehicle_dir_layer(NORTH, OBJ_LAYER)
	D.set_vehicle_dir_layer(EAST, OBJ_LAYER)
	D.set_vehicle_dir_layer(WEST, OBJ_LAYER)

/obj/vehicle/ridden/atv/post_buckle_mob(mob/living/M)
	add_overlay(atvcover)
	return ..()

/obj/vehicle/ridden/atv/post_unbuckle_mob(mob/living/M)
	if(!has_buckled_mobs())
		cut_overlay(atvcover)
	return ..()

/obj/vehicle/ridden/atv/attackby(obj/item/W as obj, mob/user as mob, params)
	if(W.tool_behaviour == TOOL_WELDER && user.a_intent != INTENT_HARM)
		if(obj_integrity < max_integrity)
			if(W.use_tool(src, user, 0, volume=50, amount=1))
				user.visible_message(span_notice("[user] repairs some damage to [name]."), span_notice("You repair some damage to \the [src]."))
				obj_integrity += min(10, max_integrity-obj_integrity)
				if(obj_integrity == max_integrity)
					to_chat(user, span_notice("It looks to be fully repaired now."))
		return TRUE
	return ..()

/obj/vehicle/ridden/secway/obj_break()
	START_PROCESSING(SSobj, src)
	return ..()

/obj/vehicle/ridden/atv/process(seconds_per_tick)
	if(obj_integrity >= integrity_failure * max_integrity)
		return PROCESS_KILL
	if(SPT_PROB(10, seconds_per_tick))
		return
	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(0, src)
	smoke.start()

/obj/vehicle/ridden/atv/bullet_act(obj/projectile/P)
	if(prob(50) && buckled_mobs)
		for(var/mob/M in buckled_mobs)
			M.bullet_act(P)
		return TRUE
	return ..()

/obj/vehicle/ridden/atv/obj_destruction()
	explosion(src, -1, 0, 2, 4, flame_range = 3)
	return ..()

/obj/vehicle/ridden/atv/Destroy()
	STOP_PROCESSING(SSobj,src)
	return ..()
