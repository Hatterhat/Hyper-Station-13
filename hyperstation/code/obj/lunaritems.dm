/obj/structure/lunaraltar
	name = "lunar altar"
	desc = "Judging by the symbols, millenia ago, it seems that the creatures of this world used something precious to the icy moon that orbits this hellish planet. You... Wouldn't do that, would you?"
	icon = 'icons/obj/hand_of_god_structures.dmi' //Placeholder.
	icon_state = "sacrificealtar" //Placeholder.
	anchored = TRUE
	density = FALSE
	var/used = FALSE

/obj/structure/lunaraltar/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(used)
		to_chat(user, "<span class='notice'>The altar seems shattered.</span>")
		return
	if(istype(user, /mob/living/carbon/human/))
		var/part = pick("1","2","3","4")
		var/mob/living/carbon/human/H = user
		var/obj/item/bodypart/bodypart
		switch(part)
			if("1")
				bodypart = H.get_bodypart(BODY_ZONE_L_LEG)
			if("2")
				bodypart = H.get_bodypart(BODY_ZONE_R_LEG)
			if("3")
				bodypart = H.get_bodypart(BODY_ZONE_L_ARM)
			if("4")
				bodypart = H.get_bodypart(BODY_ZONE_R_ARM)
		if(!bodypart)
			to_chat(user, "<span class='notice'>The altar does nothing.</span>")
			return
		to_chat(user,"<span class='warning'>You begin placing your hand on the altar.</span>")
		playsound(src, 'sound/weapons/slice.ogg', 50, 1, 5)
		if(do_after(user, 100, target=src))
			if(used)
				return
			visible_message("<span class='danger'>[user]'s [bodypart] is momentarily enveloped by shadows before they are gruesomely twisted and dismembered!</span>", \
									"<span class='userdanger'>Your [bodypart] is momentarily enveloped by shadows before it's gruesomely twisted and dismembered!</span>")
			bodypart.dismember()
			bodypart.Destroy()
			H.bleed_rate += 5
			H.emote("scream")
			new /obj/item/helfiretincture(src.loc) //Eventually a pick, with different items.
			visible_message("<span class='warning'>As you blink, cracks appear on the altar and a flash of lunar light reaches its surface. A gift?</span>")
			message_admins("[ADMIN_LOOKUPFLW(user)] has sacrificed their [bodypart] on the lunar altar at [AREACOORD(src)].")
			used = TRUE

/obj/item/helfiretincture
	name = "helfire tincture" //"Hel" not Hell. Intended.
	icon = 'hyperstation/icons/obj/lunar.dmi'
	icon_state = "helfire_tincture"
	desc = "Burn everyone nearby... including you. You wouldn't do that on the shuttle now, would you?"
	var/cooldowntime = 45 SECONDS
	var/used = FALSE

/obj/item/helfiretincture/attack_self(mob/user)
	if(!used)
		used = TRUE
		visible_message("<span class='danger'>[user] draws from the power of a Hellfire Tincture!</span>", \
								"<span class='userdanger'>You draw the power of the Hellfire Tincture!</span>")
		for(var/mob/living/H in spiral_range(8, user))
			H.adjustFireLoss(10)
			H.adjust_fire_stacks(5)
			H.IgniteMob()
		playsound(src.loc, 'hyperstation/sound/misc/helfire_use.ogg', 100, 1, extrarange = 8)
		icon_state = "helfire_tincture_used"
		update_icon()
		addtimer(CALLBACK(src, .proc/restore, user), cooldowntime)
	else
		to_chat(user, "<span class='warning'>It's too soon to use this again!</span>")

/obj/item/helfiretincture/proc/restore(mob/user)
	used = FALSE
	icon_state = "helfire_tincture"
	update_icon()
	to_chat(user, "<span class='warning'>The tincture vibrates with power once again.</span>")
