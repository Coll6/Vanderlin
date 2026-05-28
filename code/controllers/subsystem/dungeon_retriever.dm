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
	UnregisterSignal(SSdungeon_retriever, COMSIG_GLOB_MOB_DEATH)
	if(length(SSdungeon_retriever.dungeon_deaths))
		dungeon_deaths = SSdungeon_retriever.dungeon_deaths

/datum/controller/subsystem/dungeon_retriever/proc/record_dungeon_death(source, mob, gibbed)
	SIGNAL_HANDLER
	if(!gibbed && ishuman(mob) && istype(get_area(mob), /area/under/tomb))
		dungeon_deaths += mob

/datum/controller/subsystem/dungeon_retriever/proc/attempt_retrieval()

/datum/controller/subsystem/dungeon_retriever/proc/retrieve_body()

 //TODO handle revives on living revive SEND_SIGNAL(src, COMSIG_LIVING_REVIVE, full_heal_flags)
