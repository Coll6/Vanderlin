SUBSYSTEM_DEF(dungeon_retriever)
	name = "Matthios Reclamation"
	flags = SS_NO_FIRE
	runlevels = RUNLEVEL_GAME

	var/record_deaths = FALSE

/datum/controller/subsystem/dungeon_retriever/Initialize(start_timeofday)
	if(SSdungeon_generator.initialized)
		record_deaths = TRUE
	return ..()
