SUBSYSTEM_DEF(dungeon_retriever)
	name = "Matthios Reclamation"
	flags = SS_NO_FIRE
	runlevels = RUNLEVEL_GAME

	var/record_deaths = FALSE
	var/list/dungeon_deaths = list() // The unfortunate fallen to the dungeon.

/datum/controller/subsystem/dungeon_retriever/Initialize(start_timeofday)
	if(SSdungeon_generator.initialized || length(dungeon_deaths))
		record_deaths = TRUE
		RegisterSignal(SSdcs, COMSIG_GLOB_MOB_DEATH, PROC_REF(record_dungeon_death))

	return ..()

/datum/controller/subsystem/dungeon_retriever/Recover()
	UnregisterSignal(SSdcs, COMSIG_GLOB_MOB_DEATH)
	if(length(SSdungeon_retriever.dungeon_deaths))
		dungeon_deaths = SSdungeon_retriever.dungeon_deaths

/datum/controller/subsystem/dungeon_retriever/proc/record_dungeon_death(source, mob, gibbed)
	SIGNAL_HANDLER
	if(isnull(dungeon_deaths))
		dungeon_deaths = list()
	if(!gibbed && ishuman(mob) && istype(get_area(mob), /area/under/tomb))
		dungeon_deaths += mob

/datum/controller/subsystem/dungeon_retriever/proc/retrieve_record()
	var/list/sent_record = list()
	for(var/mob/living/carbon/human/corpse in dungeon_deaths.Copy())
		if(QDELETED(corpse) && (corpse in dungeon_deaths))
			dungeon_deaths -= corpse
			continue
		if((corpse.stat != DEAD) && (corpse in dungeon_deaths))
			dungeon_deaths -= corpse
			continue
		if(!is_valid_target(corpse))
			continue
		sent_record += corpse

	return sent_record

/datum/controller/subsystem/dungeon_retriever/proc/is_valid_target(mob/living/carbon/human/target)
	if(QDELETED(target))
		return FALSE
	if(!(target in dungeon_deaths))
		return FALSE
	if(target.stat != DEAD)
		return FALSE
	if(!istype(get_area(target), /area/under/tomb))
		return FALSE
	if(target.grabbedby)
		return FALSE
	return TRUE

/datum/controller/subsystem/dungeon_retriever/proc/attempt_retrieval(mob/living/carbon/human/corpse, turf/destination)
	//TODO ADD CHECKS FOR VALID CORPSES
	if(!istype(destination))
		return FALSE
	if(is_valid_target(corpse))
		return FALSE

	return retrieve_body(corpse, destination)

/datum/controller/subsystem/dungeon_retriever/proc/retrieve_body(mob/living/carbon/human/corpse, turf/destination)
	dungeon_deaths -= corpse
	corpse.forceMove(destination)
