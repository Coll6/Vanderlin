/obj/structure/fake_machine/tomb_retrieval
	name = "\improper KHARON"
	desc = "Ferries bodies from the Tomb of Mathios. It answers only to marked obols."
	icon = 'icons/roguetown/misc/machines.dmi'
	icon_state = "stockpile_vendor"

	var/budget = 0

/obj/structure/fake_machine/tomb_retrieval/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return

	user.changeNext_move(CLICK_CD_MELEE)
	playsound(src, 'sound/misc/keyboard_enter.ogg', 100, FALSE, -1)

	var/contents = get_retrieval_subjects()
	var/datum/browser/popup = new(user, "KHARONLIST", "", 370, 400)

	popup.set_content(contents)
	popup.open()

/obj/structure/fake_machine/tomb_retrieval/attackby(obj/item/attacking_item, mob/user, list/modifiers)
	if(ishuman(user))
		if(istype(attacking_item, /obj/item/underworld/kharon_coin))
			playsound(src, 'sound/misc/coininsert.ogg', 100, FALSE, -1)
			//TODO INSERT COIN
			return attack_hand(user)

/obj/structure/fake_machine/tomb_retrieval/proc/get_retrieval_subjects()
	var/contents = "<center>TOMB'S VICTIMS<BR>"
	contents += "--------------<BR>"
	var/list/recorded_deaths = (SSdungeon_retriever?.initialized && SSdungeon_retriever.record_deaths) ? SSdungeon_retriever.dungeon_deaths : list()

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
			return
		var/result = retriever.attempt_retrieval(corpse, get_turf(usr))
		return
	if(href_list["eject"])
		//TODO EJECT ALL COINS
		return
