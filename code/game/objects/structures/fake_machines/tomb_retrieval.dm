/obj/structure/fake_machine/tomb_retrieval
	name = "\improper KHARON"
	desc = "Ferries bodies from the Tomb of Mathios. It answers only to marked obols."
	icon = 'icons/roguetown/misc/machines.dmi'
	icon_state = "stockpile_vendor"

	var/budget = 0
	var/obol_budget = 0

/obj/structure/fake_machine/tomb_retrieval/Destroy()
	ejectobols()
	budget2change(budget)
	return ..()

/obj/structure/fake_machine/tomb_retrieval/proc/ejectobols()
	for(var/i in 1 to obol_budget)
		new /obj/item/underworld/kharon_coin(loc)
	obol_budget = 0

/obj/structure/fake_machine/tomb_retrieval/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return

	user.changeNext_move(CLICK_CD_MELEE)
	playsound(src, 'sound/misc/keyboard_enter.ogg', 100, FALSE, -1)

	var/contents = get_retrieval_subjects(user)
	var/datum/browser/popup = new(user, "KHARONLIST", "", 370, 400)

	popup.set_content(contents)
	popup.open()

/obj/structure/fake_machine/tomb_retrieval/attackby(obj/item/attacking_item, mob/user, list/modifiers)
	if(ishuman(user))
		if(istype(attacking_item, /obj/item/underworld/kharon_coin))
			var/amt = 1
			obol_budget += amt
			qdel(attacking_item)
			to_chat(user, span_info("I put [amt] obol in \the [src]."))
			playsound(src, 'sound/misc/coininsert.ogg', 100, FALSE, -1)
			return attack_hand(user)
		if(istype(attacking_item, /obj/item/coin))
			var/money = attacking_item.get_real_price()
			budget += money
			qdel(attacking_item)
			to_chat(user, span_info("I put [money] mammon in \the [src]."))
			playsound(src, 'sound/misc/coininsert.ogg', 100, TRUE, -1)
			return attack_hand(user)

/obj/structure/fake_machine/tomb_retrieval/proc/get_retrieval_subjects(mob/living/user)
	var/contents = "<center>Currency<BR>"
	contents += "--------------<BR>"
	contents += "Mammon: [budget]<BR>"
	contents += "Obols: [obol_budget]<BR><BR>"
	contents += "<a href='byond://?src=[REF(src)];eject_mammon=1'>Eject Mammon</a><BR>"
	contents += "<a href='byond://?src=[REF(src)];eject_obols=1'>Eject Obols</a><BR>"
	var/datum/job/mob_job = user.job ? SSjob.GetJob(user.job) : null
	if(istype(mob_job, /datum/job/tomb_warden))
		contents += "<a href='byond://?src=[REF(src)];buy_obol=1'>Buy Obol 50 Mammon</a><BR><BR>"

	contents += "TOMB'S VICTIMS<BR>"
	contents += "--------------<BR>"
	var/list/recorded_deaths = (SSdungeon_retriever?.initialized && SSdungeon_retriever.record_deaths) ? SSdungeon_retriever.retrieve_record() : list()

	if(length(recorded_deaths))
		contents += "The following unfortunate souls have perished in the dungeon. Whom to ferry back?</center><BR>"
		for(var/mob/living/carbon/human/corpse in recorded_deaths)
			contents += "<a href='byond://?src=[REF(src)];retrieve=[REF(corpse)]'>[corpse.real_name]</a><BR>"
	else
		contents += "No deaths have been recorded.</center><BR>"

	return contents

/obj/structure/fake_machine/tomb_retrieval/Topic(href, href_list)
	. = ..()
	if(!usr.can_perform_action(src, NEED_DEXTERITY|FORBID_TELEKINESIS_REACH))
		return
	if(href_list["retrieve"])
		var/datum/controller/subsystem/dungeon_retriever/retriever = SSdungeon_retriever
		if(!retriever)
			return
		//TODO CHECK IF THERE IS ENOUGH COINS
		var/mob/living/carbon/human/corpse = locate(href_list["retrieve"])
		if(!istype(corpse))
			return attack_hand(usr)
		retriever.attempt_retrieval(corpse, get_turf(usr))
		return attack_hand(usr)

	if(href_list["buy_obol"])
		if(budget >= 50)
			obol_budget += 1
			budget -= 50
			to_chat(usr, span_info("I exchange 50 mammon for an obol in \the [src]."))
			playsound(src, 'sound/misc/coininsert.ogg', 100, FALSE, -1)
		else
			to_chat(usr, span_info("I don't have enough mammon to buy an obol."))
		return attack_hand(usr)

	if(href_list["eject_mammon"])
		budget2change(budget, usr)
		budget = 0
		return attack_hand(usr)

	if(href_list["eject_obols"])
		ejectobols()
		return attack_hand(usr)
