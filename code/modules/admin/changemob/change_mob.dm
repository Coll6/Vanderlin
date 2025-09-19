/datum/cchange_mob_panel
	//var/user_ckey
	var/mob/living/cached_body
	var/client/cached_client

/datum/cchange_mob_panel/New(mob/living/changing_mob, client/mob_client)
	cached_body = changing_mob
	cached_client = mob_client
	return ..()

/datum/cchange_mob_panel/Destroy(force, ...)
	cached_body = null
	cached_client = null
	return ..()

/datum/cchange_mob_panel/proc/show_ui(mob/user)
	if(!cached_body || !cached_client)
		to_chat(user, "<span class='boldwarning'>Error: Missing mob or client data!</span>")
		qdel(src)
		return

	var/list/dat = list()
	dat += "<a href='byond://?src=[REF(src)];task=refresh_window'>Refresh Window</a>"

	var/datum/browser/extra/popup = new(user, "complex_change_mob_panel", "Complex Change Mob Panel", 550, 500, owner = src)
	popup.set_content(dat.Join())
	popup.open()

/datum/cchange_mob_panel/Topic(href, list/href_list)
	..()

	if(href_list["close"])
		qdel(src)

	switch(href_list["task"])
		if("refresh_window")
			to_chat(usr, "<span class='notice'>Refreshing window...</span>")
		//var/alert = alert(user, "Reset the panel and clear all of the values?", "Reset", "Yes", "No")
		//reset_panel(user)

/datum/browser/extra
	//A browser that will close itself when the user disconnects or the owner is deleted.

/datum/browser/extra/New(mob/user, window_id, title = "", width = 0, height = 0, atom/owner = null)
	..()
	RegisterSignal(user, COMSIG_MOB_LOGOUT, PROC_REF(closewindow))

/datum/browser/extra/proc/transferclosewindow()
	SIGNAL_HANDLER
	UnregisterSignal(user, COMSIG_MOB_LOGOUT)
	//UnregisterSignal(user, COMSIG_MOB_MIND_TRANSFERRED_OUT_OF)

/datum/browser/extra/proc/closewindow()
	SIGNAL_HANDLER
	UnregisterSignal(user, COMSIG_MOB_LOGOUT)
	//UnregisterSignal(user, COMSIG_MOB_MIND_TRANSFERRED_OUT_OF)
	//var/datum/mind/user_mind = user.mind
	//if(user)


	//user << browse(null, "window=[window_id]")
