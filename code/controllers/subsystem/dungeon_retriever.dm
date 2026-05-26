SUBSYSTEM_DEF(dungeon_retriever)
	name = "Matthios Reclamation"
	flags = SS_NO_FIRE
	runlevels = RUNLEVEL_GAME

	var/record_deaths = FALSE
	var/list/dungeon_deaths = list() // The unfortunate fallen to the dungeon.

/datum/controller/subsystem/dungeon_retriever/Initialize(start_timeofday)
	if(SSdungeon_generator.initialized)
		record_deaths = TRUE
		RegisterSignal(SSdcs, COMSIG_GLOB_MOB_DEATH, PROC_REF(record_dungeon_death))

	return ..()

/datum/controller/subsystem/dungeon_retriever/proc/record_dungeon_death(source, mob, gibbed)
	SIGNAL_HANDLER
	if(!gibbed && ishuman(mob) && istype(get_area(mob), /area/under/tomb))
		dungeon_deaths += mob
