/obj/screen/ability/topBar/cruiser
	cast_ability(params)
		var/datum/targetable/cruiser/spell = owner
		if (!istype(spell))
			return
		..()
		return

/datum/abilityHolder/cruiser
	topBarRendered = 1
	usesPoints = 0
	regenRate = 0
	tabName = "Cruiser Controls"

// ----------------------------------------
// Controls for the cruiser ships.
// ----------------------------------------

/datum/targetable/cruiser
	icon = 'icons/mob/cruiser_ui.dmi'
	icon_state = ""
	cooldown = 0
	last_cast = 0
	check_range = 0
	var/disabled = 0
	var/toggled = 0
	var/is_on = 0   // used if a toggle ability
	preferred_holder_type = /datum/abilityHolder/cruiser
	ignore_sticky_cooldown = 1

	New()
		var/obj/screen/ability/topBar/cruiser/B = new /obj/screen/ability/topBar/cruiser(null)
		B.icon = src.icon
		B.icon_state = src.icon_state
		B.owner = src
		B.name = src.name
		B.desc = src.desc
		src.object = B

	updateObject()
		..()
		if (!src.object)
			src.object = new /obj/screen/ability/topBar/cruiser()
			object.icon = src.icon
			object.owner = src
		if (disabled)
			object.name = "[src.name] (unavailable)"
			object.icon_state = src.icon_state + "_cd"
		else if (src.last_cast > TIME)
			object.name = "[src.name] ([round((src.last_cast - TIME)/10)])"
			object.icon_state = src.icon_state + "_cd"
		else if (toggled)
			if (is_on)
				object.name = "[src.name] (on)"
				object.icon_state = src.icon_state
			else
				object.name = "[src.name] (off)"
				object.icon_state = src.icon_state + "_cd"
		else
			object.name = src.name
			object.icon_state = src.icon_state

	proc/incapacitationCheck()
		var/mob/living/M = holder.owner
		return M.restrained() || M.stat || M.getStatusDuration("paralysis") || M.getStatusDuration("stunned") || M.getStatusDuration("weakened")

	castcheck()
		if (incapacitationCheck())
			boutput(holder.owner, __red("Not while incapacitated."))
			return 0
		if (disabled)
			boutput(holder.owner, __red("You cannot use that ability at this time."))
			return 0
		return 1

	doCooldown()
		if (!holder)
			return
		last_cast = TIME + cooldown
		holder.updateButtons()
		SPAWN_DBG(cooldown + 5)
			holder.updateButtons()

	cast(atom/target)
		. = ..()
		actions.interrupt(holder.owner, INTERRUPT_ACT)
