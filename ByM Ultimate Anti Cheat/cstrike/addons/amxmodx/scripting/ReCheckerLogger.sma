#include <amxmisc>

new rcString[192];
new rcTime[16];
new rcFile[64];

public plugin_init()
{
	register_plugin("ReChecker Logging", "freesrv", "custom")

	register_srvcmd("rc_log", "cmd_rcLog");
	register_srvcmd("ms_log", "cmd_msLog");
	register_srvcmd("fk_log", "cmd_fkLog");

	if( !dir_exists( "addons/amxmodx/logs/ReChecker_Logs/" ) )
		mkdir( "addons/amxmodx/logs/ReChecker_Logs/" );
}

public cmd_rcLog(id)
{
	read_args(rcString, charsmax(rcString));
	get_time("%Y%m%d", rcTime, charsmax(rcTime));
	format(rcFile, charsmax(rcFile), "addons/amxmodx/logs/ReChecker_Logs/rc_%s.log", rcTime);
	
	log_to_file(rcFile, "%s", rcString);
}

public cmd_msLog(id)
{
	read_args(rcString, charsmax(rcString));
	get_time("%Y%m%d", rcTime, charsmax(rcTime));
	format(rcFile, charsmax(rcFile), "addons/amxmodx/logs/ReChecker_Logs/ms_%s.log", rcTime);
	
	log_to_file(rcFile, "%s", rcString)
}

public cmd_fkLog(id)
{
	read_args(rcString, charsmax(rcString));
	get_time("%Y%m%d", rcTime, charsmax(rcTime));
	format(rcFile, charsmax(rcFile), "addons/amxmodx/logs/ReChecker_Logs/fk_%s.log", rcTime);
	
	log_to_file(rcFile, "%s", rcString);
}
