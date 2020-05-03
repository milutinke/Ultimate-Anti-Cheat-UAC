// Based on the original: Sakura's AntiCheat (https://forums.alliedmods.net/showthread.php?t=78765)

// Enabled: Very Optimized
#define USE_BYM_API		1

#if defined  USE_BYM_API
#include < bym_api >
#else
#include < amxmodx >
#include < hamsandwich >
#endif

#include < amxmisc >
#include < fakemeta_util >
#include < dhudmessage >
#include < cstrike >
#include < engine >
#include < nvault >

#define PLUGIN 			"Ultimate Anti-Cheat"
#define VERSION 		"1.6"
#define AUTHOR 			"Milutinke (ByM) and Ilham Sakura"

#define MAX_FLASHBUG_ZONES 	20
#define ADVERTISING_TIME 	240.0

#define FM_HITGROUP_HEAD 	( 1 << 1 )
#define FM_TEAM_OFFSET 		114

#define TASK_RECAPTCHA		7624543
#define TASK_MILF		7624544
#define TASK_PLAYER_AD		7624545

#define ADMIN_IGNORE_FLAG 	ADMIN_BAN

// Disabled: Very Optimized
//#define USE_TASKS		1
//#define USE_FAKEMETA		1

enum _:iStructSettings {
	PLUGIN_STATUS = 0,
	PLUGIN_ADVERSTRIMENT,
	PLUGIN_LOG_ACTIONS,
	
	PUNISH_TYPE,
	BAN_TYPE,
	BAN_TIME,
	IGNORE_ADMINS,
	
	SPEEDHACK_SECURE,
	
	BAN_COMMAND,
	KICK_COMMAND,
	
	CHECK_RAPIDFIRE,
	CHECK_SPINHACK,
	CHECK_SPEEDHACK,
	CHECK_SHAKE,
	CHECK_LOWRECOIL,
	CHECK_AIMBOT,
	CHECK_BHOP,
	
	CHECK_MOVEKEYS,
	CHECK_DOUBLEATTACK,
	
	CHECK_FLASHBUG,

	BLOCK_NOFLASH,
	
	CHECK_FASTNAME,
	CHECK_NAME,
	CHECK_NAME_SYMBOLS,
	CNS_SHOW_REASON,
	CHECK_IPS,
	ANTIBOT_ENABLED,
	BYM_RECAPTCHA,
	BYM_RECAPTCHA_TIME,
	BYM_RECAPTCHA_TRYS,
	BYM_RECAPTCHA_REMEMBER,
	MILF_ANTICHEAT_BINDS,
	MILF_ANTICHEAT_KEYS,
	MILF_ANTICHEAT_PUNISHMENT,
	MILF_ANTICHEAT_TIME,
	MILF_ANTICHEAT_REASON,
	
	RAPID_FIRE_PUNISH_NUMBER,
	SPINHACK_WARNING_NUMBER,
	SPINHACK_PUNISH_NUMBER,
	SPEEDHACK_WARNING_NUMBER,
	SPEEDHACK_PUNISH_NUMBER,
	SHAKE_WARNING_NUMBER,
	SHAKE_PUNISH_NUMBER,
	LOWRECOILL_WARNING_NUMBER,
	LOWRECOILL_PUNISH_NUMBER,
	AIMBOT_WARNING_NUMBER,
	AIMBOT_PUNISH_NUMBER,
	FAST_NAME_CHANING_NUMBER
};

enum _:Cheats {
	RAPIDFIRE = 0,
	SPINHACK,
	SPEEDHACK,
	SHAKE,
	RECOIL,
	AIMBOT
};

new const g_szSettingsName[ ][ ] = {
	"Plugin_Status",
	"Plugin_Adverstriment",
	"Plugin_Log_Actions",
	"Punish_Type",
	"Punish_Ban_Type",
	"Punish_Bantime",
	"Ignore_Admins",
	"Speedhack_Secure",
	"Ban_Command",
	"Kick_Command",
	"Check_Rapidfire",
	"Check_Spinhack",
	"Check_Speedhack",
	"Check_Shake",
	"Check_Lowrecoil",
	"Check_Aimbot",
	"Check_Bhop",
	"Check_Movekeys",
	"Check_Doubleattack",
	"Check_Flashbug",
	"Block_NoFlash",
	"Check_Name_Fastchange",
	"Check_Name",
	"Check_Name_Symbols",
	"CNS_Show_Reason",
	"Check_IPs",
	"AntiBot_Enabled",
	"ByM_ReCaptcha_Enabled",
	"ByM_ReCaptcha_Secounds",
	"ByM_ReCaptcha_NumberOfTrys",
	"ByM_ReCaptcha_Remeber_Time",
	"Milf_AntiCheat",
	"Milf_AntiCheat_Keys",
	"Milf_AntiCheat_Punishment",
	"Milf_AntiCheat_BanTime",
	"Milf_AntiCheat_Reason",
	
	"Rapid_Punish_Number",
	"SpinHack_Warning_Number",
	"SpinHack_Punish_Number",
	"SpeedHack_Warning_Number",
	"SpeedHack_Punish_Number",
	"Shake_Warning_Number",
	"Shake_Punish_Number",
	"LowRecoill_Warning_Number",
	"LowRecoill_Punish_Number",
	"AimBot_Warning_Number",
	"AimBot_Punish_Number",
	"Fast_Name_Changing_Number"
};

new const g_szOldCheats[ ][ ] = {
	"EcstaticCheat",
	"TeKilla",
	"MicCheat",
	"AlphaCheat",
	"PimP",
	"LCD",
	"Chapman",
	"_PRJVDC"
};

new const g_szGunsEvents[ ][ ] = {
	"events/awp.sc",
	"events/g3sg1.sc",
	"events/ak47.sc",
	"events/scout.sc",
	"events/m249.sc",
	"events/m4a1.sc",
	"events/sg552.sc",
	"events/aug.sc",
	"events/sg550.sc",
	"events/m3.sc",
	"events/xm1014.sc",
	"events/usp.sc",
	"events/mac10.sc",
	"events/ump45.sc",
	"events/fiveseven.sc",
	"events/p90.sc",
	"events/deagle.sc",
	"events/p228.sc",
	"events/glock18.sc",
	"events/mp5n.sc",
	"events/tmp.sc",
	"events/elite_left.sc",
	"events/elite_right.sc",
	"events/galil.sc",
	"events/famas.sc"
};

new g_szGunsEventsId[ sizeof g_szGunsEvents ];
new g_iSettings[ iStructSettings ] = { 0, ... };
new g_szMapName[ 32 ];
new g_szBanCommand[ 512 ];
new g_szKickCommand[ 512 ];
new g_iFlashVectors[ MAX_FLASHBUG_ZONES ][ 4 ];
new g_iFlashZones;
new bool: g_iIsDetected[ 33 ];
new g_iDetections[ 33 ][ Cheats ];
new g_iBhopScript[ 32 ];
new g_iNamesChangesNumber[ 33 ];
new g_szRestrictedSymbols[ 32 ];
new g_szReCaptchaText[ 33 ][ 5 ];
new g_iReCaptcaTrys[ 33 ];
new g_iPassedReCaptcha[ 33 ];
new g_iHasSecounds[ 33 ];
new g_iCheckedCaptchaExipration[ 33 ];
new g_szMilfReason[ 128 ];
new g_iIgnoreAim[ 33 ];
new g_iIgnoreRapid[ 33 ];
new g_iIgnoreNoRecoil[ 33 ];
new g_iIgnoreSpeedHack[ 33 ];
new g_iIgnoreShake[ 33 ];
new g_szMilfKeys[ 128 ];

new Float: g_fOldAimAngles[ 33 ][ 3 ];
new Float: g_fLastAngles[ 33 ][ 3 ];
new Float: g_fTotalAngle[ 33 ];
new Float: g_fRecoilLastAngles[ 33 ][ 3 ];
new Float: g_fLastOrigin[ 33 ][ 3 ];
new Float: g_fAimOrigin[ 33 ][ 3 ];
new Float: g_fNextAimCheck[ 33 ];
new Float: g_fFlashedUntil[ 33 ];

new Trie: g_tMaliciousIPs;
new Trie: g_tExcludedIPs;
new g_iMessageScreenFade;
new g_iMessageChat;

new g_iCaptchaVault;

const Float: g_fReverse = -1.0;
const Float: g_fFraction = 9999.0;


public plugin_init( ) {
	// Register plugin
	#if defined USE_BYM_API
		// Initialise ByM API and Register Plugin
		ByM::Initialise( register_plugin( PLUGIN, VERSION, AUTHOR ) );
	#else
		register_plugin( PLUGIN, VERSION, AUTHOR )
	#endif

	// Tracking cvar
	register_cvar( "ByM_UltimateAntiCheat", "1.6", FCVAR_SERVER );
	
	// Load lang phrases
	register_dictionary( "UltimateAntiCheat.txt" );
	
	// Fake Meta module forwards
	register_forward( FM_Think, "fw_FmThink" );
	register_forward( FM_PlayerPostThink, "fw_FmPlayerPostThink" );
	register_forward( FM_PlayerPreThink, "fw_PlayerPreThink" );
	register_forward( FM_PlaybackEvent, "g_fwPlayBackEvent" );
	register_forward( FM_TraceLine, "fw_FmTraceLine" );
	register_forward( FM_AddToFullPack, "fw_FmAddFullToPack", 0 );
	
	// Engine events
	register_event( "ScreenFade", "fw_EventPlayerFlashed", "b", "7=255" );
	register_event( "HLTV", "fw_EventNewRound", "a", "1=0", "2=0" );
	
	// Register Commands
	formatex( g_iBhopScript, charsmax( g_iBhopScript ), "plop%d%d%d", random( 100 ), random( 100 ), random( 100 ) );
	register_clcmd( g_iBhopScript, "fw_CommandCheckBHop" );
	register_clcmd( "say /uaca", "ShowAuthors" );
	register_clcmd( "say_team /uaca", "ShowAuthors" );
	register_clcmd( "say", "fw_ChatCommand" );
	register_clcmd( "say_team", "fw_ChatCommand" );

	// Register messages
	g_iMessageScreenFade = get_user_msgid( "ScreenFade" );
	g_iMessageChat = get_user_msgid( "SayText" );
}

public plugin_precache( ) {
	for( new iIterator2 = 0 ; iIterator2 < sizeof g_szGunsEvents ; iIterator2 ++ )
		g_szGunsEventsId[ iIterator2 ] = engfunc( EngFunc_PrecacheEvent, 1, g_szGunsEvents[ iIterator2 ] );
}

public plugin_cfg( ) {
	static szBaseDir[ 128 ], szUltimateAntiCheatDir[ 128 ], szFile[ 128 ];
	get_basedir( szBaseDir, charsmax( szBaseDir ) );
	
	formatex( szUltimateAntiCheatDir, charsmax( szUltimateAntiCheatDir ), "%s/configs/UltimateAntiCheat", szBaseDir );
	formatex( szFile, charsmax( szFile ), "%s/Settings.cfg", szUltimateAntiCheatDir );
	
	if( !dir_exists( szUltimateAntiCheatDir ) )
		mkdir( szUltimateAntiCheatDir );
	
	if( !file_exists( szFile ) ) {
		server_print( "%L", LANG_SERVER, "PRINT_SRV_ERROR" );
		return;
	} else server_print( "%L", LANG_PLAYER, "SUCC_LOADED" );
	
	static iFile, szBuffer[ 512 ], szKey[ 128 ], szStatus[ 128 ];
	iFile = fopen( szFile, "rt" );
	
	while( !feof( iFile ) ) {
		fgets( iFile, szBuffer, charsmax( szBuffer ) );
		
		if( szBuffer[ 0 ] == EOS || ( szBuffer[ 0 ] == ';' ) || ( szBuffer[ 0 ] == '/' && szBuffer[ 1 ] == '/' ) )
			continue;
		
		strtok( szBuffer, szKey, charsmax( szKey ), szStatus, charsmax( szStatus ), '=', 1 );
		
		for( new iIterator = PLUGIN_STATUS; iIterator <= FAST_NAME_CHANING_NUMBER; iIterator ++ ) {
			if( equali( g_szSettingsName[ iIterator ], szKey ) ) {
				if( equali( szKey, "Ban_Command" ) ) {
					trim( szStatus );
					formatex( g_szBanCommand, charsmax( g_szBanCommand ), "%s", szStatus );
					
					server_print( "%L", LANG_SERVER, "SETTINGS_STR", g_szSettingsName[ iIterator ], szStatus );
					continue;
				}
				else if( equali( szKey, "Kick_Command" ) ) {
					trim( szStatus );
					formatex( g_szKickCommand, charsmax( g_szKickCommand ), "%s", szStatus );
					
					server_print( "%L", LANG_SERVER, "SETTINGS_STR", g_szSettingsName[ iIterator ], szStatus );
					continue;
				}
				else if( equali( szKey, "Check_Name_Symbols" ) ) {
					trim( szStatus );
					formatex( g_szRestrictedSymbols, charsmax( g_szRestrictedSymbols ), "%s", szStatus );
					
					server_print( "%L", LANG_SERVER, "SETTINGS_STR", g_szSettingsName[ iIterator ], szStatus );
					continue;
				} else if( equali( szKey, "Milf_AntiCheat_Keys" ) ) {
					trim( szStatus );
					formatex( g_szMilfKeys, charsmax( g_szMilfKeys ), "%s", szStatus );
					
					server_print( "%L", LANG_SERVER, "SETTINGS_STR", g_szSettingsName[ iIterator ], szStatus );
					continue;
				} else if( equali( szKey, "Milf_AntiCheat_Reason" ) ) {
					trim( szStatus );
					formatex( g_szMilfReason, charsmax( g_szMilfReason ), "%s", szStatus );
					
					server_print( "%L", LANG_SERVER, "SETTINGS_STR", g_szSettingsName[ iIterator ], szStatus );
					continue;
				} 

				replace_all( szStatus, charsmax( szStatus ), "=", "" );
				trim( szStatus );
				g_iSettings[ iIterator ] = str_to_num( szStatus );
				
				if( iIterator >= RAPID_FIRE_PUNISH_NUMBER && iIterator <= FAST_NAME_CHANING_NUMBER )
					server_print( "%L", LANG_SERVER, "SET_V_2", g_szSettingsName[ iIterator ], szStatus );
				else server_print( "%L", LANG_SERVER, "SET_V_2", g_szSettingsName[ iIterator ], g_iSettings[ iIterator ] ? "Enabled" : "Disabled" );
			}
		}
	}

	fclose( iFile );
	
	if( g_iSettings[ BYM_RECAPTCHA ] ) {
		if( !g_iSettings[ BYM_RECAPTCHA_TIME ] )
			g_iSettings[ BYM_RECAPTCHA_TIME ] = 20;
	}
	
	LoadFlashBugVectors( );

	formatex( szFile, charsmax( szFile ), "%s/Blocked_IPs.ini", szUltimateAntiCheatDir );
	LoadMaliciousIPs( szFile );
	
	szFile[ 0 ] = EOS;
	formatex( szFile, charsmax( szFile ), "%s/ByM_AntiBot_Excluded_IPs.ini", szUltimateAntiCheatDir );
	LoadExcludedIPs( szFile );
	
	if( !g_iSettings[ PLUGIN_STATUS ] ) {
		pause( "a" );
		return;
	}
	
	if( g_iSettings[ BYM_RECAPTCHA_REMEMBER ] )
		g_iCaptchaVault = nvault_open(  "ByM_ReCaptcha" );

	set_task( ADVERTISING_TIME, "Adverstiment", random( 1337 ), "", 0, "b", 0 );

	#if defined USE_TASKS
	if( g_iSettings[ CHECK_RAPIDFIRE ] )
		set_task( 1.0, "CheckRapidFire", random( 1337 ), "", 0, "b", 0 );

	if( g_iSettings[ CHECK_SPINHACK ] )
		set_task( 1.0, "CheckSpinTotal", random( 1337 ), "", 0, "b", 0 );

	if( g_iSettings[ CHECK_SPEEDHACK ] )
		set_task( 0.5, "CheckSpeedHack", random( 1337 ), "", 0, "b", 0 );

	if( g_iSettings[ CHECK_LOWRECOIL ] )
		set_task( 1.0, "ClearRecoil", random( 1337 ), "", 0, "b", 0 );
	#else
	CreateGlobalThinker( );
	CreateSpeedHackThinker( );
	#endif
}

#if !defined USE_TASKS
CreateGlobalThinker( ) {
	new iEntity = create_entity( "info_target" );

	if( !iEntity ) {
		server_print( "There is not enoguh entities spaces to cheate Ultimate Anti Cheat Thinker!" );
		g_iSettings[ PLUGIN_STATUS ] = 0;
		pause( "a" );
		return;
	}

	entity_set_string( iEntity, EV_SZ_classname, "UAC_GlobalThinker" );
	entity_set_float( iEntity, EV_FL_nextthink, get_gametime( ) + 1.0 );

	register_think( "UAC_GlobalThinker", "fw_GlobalThink" );
}

public fw_GlobalThink( iEntity ) {
	if( !is_valid_ent( iEntity ) )
		return;

	entity_set_float( iEntity, EV_FL_nextthink, get_gametime( ) + 1.0 );

	static iPlayer;
	for( iPlayer = 1; iPlayer <= GetMaxPlayers(); iPlayer ++ ) {
		#if defined USE_BYM_API
		if( !IsPlayer->Connected( iPlayer ) )
			continue;
		#else
		if( !is_user_connected( iPlayer ) )
			continue;
		#endif

		if( g_iSettings[ CHECK_RAPIDFIRE ] && !g_iIgnoreRapid[ iPlayer ] )
			CheckRapidFire( iPlayer );

		if( g_iSettings[ CHECK_SPINHACK ] )
			CheckSpinTotal( iPlayer );

		if( g_iSettings[ CHECK_LOWRECOIL ] )
			ClearRecoil( iPlayer );
	}
}

CreateSpeedHackThinker( ) {
	if( !g_iSettings[ CHECK_SPEEDHACK ] )
		return;

	new iEntity = create_entity( "info_target" );

	if( !iEntity ) {
		server_print( "There is not enoguh entities spaces to cheate Ultimate Anti Cheat Thinker!" );
		g_iSettings[ PLUGIN_STATUS ] = 0;
		pause( "a" );
		return;
	}

	entity_set_string( iEntity, EV_SZ_classname, "UAC_SpeedHackThinker" );
	entity_set_float( iEntity, EV_FL_nextthink, get_gametime( ) + 0.5 );

	register_think( "UAC_SpeedHackThinker", "fw_SpeedHackThink" );
}

public fw_SpeedHackThink( iEntity ) {
	if( !is_valid_ent( iEntity ) )
		return;

	entity_set_float( iEntity, EV_FL_nextthink, get_gametime( ) + 0.5 );

	static iPlayer;
	for( iPlayer = 1; iPlayer <= GetMaxPlayers( ); iPlayer ++ ) {
		if( !g_iIgnoreSpeedHack[ iPlayer ] )
			CheckSpeedHack( iPlayer );
	}
}
#endif

public Adverstiment( ) {
	if( !g_iSettings[ PLUGIN_ADVERSTRIMENT ] )
		return;
	
	if( !( random_num( 1, 300 ) == 1 ) )
		return;
	
	set_dhudmessage( 0, 255, 255, -1.0, 0.45, 0, 6.0, 10.0 );
	show_dhudmessage( 0, "This Server is Protected by Ultimate Anti Cheat [v%s]!^nAuthors:^n%s", VERSION, AUTHOR );

	PrintToChat( 0, "!gThis Server is Protected by Ultimate Anti Cheat! - Say !t/uaca !gto see the autors." );
}

public PlayerConnectedAdv( iTask )
	PrintToChat( iTask - TASK_PLAYER_AD, "!gThis Server is Protected by Ultimate Anti Cheat [v%s]! By: %s", VERSION, AUTHOR );

public ShowAuthors( iPlayer )
	PrintToChat( iPlayer, "!rAuthors Are: !g%s", AUTHOR );

public fw_ChatCommand( iPlayer ) {
	if( !g_iSettings[ BYM_RECAPTCHA ] )
		return 0;

	if( g_iPassedReCaptcha[ iPlayer ] )
		return 0;

	#if defined USE_BYM_API
	if( !IsPlayer->Connected( iPlayer ) || !IsValidPlayer( iPlayer ) )
		return 2;
	#else
	if( !is_user_connected( iPlayer ) || !IsValidPlayer( iPlayer ) )
		return 2;
	#endif

	static szSaid[ 32 ];
	read_args( szSaid, charsmax( szSaid ) );
	remove_quotes( szSaid );
	
	if( !szSaid[ 0 ] )
		return 2;

	if( !g_iPassedReCaptcha[ iPlayer ] ) {
		if( equali( szSaid, g_szReCaptchaText[ iPlayer ] ) ) {
			PrintToChat( iPlayer, "%L", iPlayer, "CORRECT_CAPTCHA" );
			g_iPassedReCaptcha[ iPlayer ] = 1;
			
			if( g_iSettings[ BYM_RECAPTCHA_REMEMBER ] ) {
				new szSteamID[ 64 ];
				get_user_authid( iPlayer, szSteamID, charsmax( szSteamID ) );
			
				new szData[ 12 ];
				num_to_str( get_systime( ) + g_iSettings[ BYM_RECAPTCHA_REMEMBER ], szData, charsmax( szData ) );
			
				nvault_set( g_iCaptchaVault, szSteamID, szData );
				g_iCheckedCaptchaExipration[ iPlayer ] = 1;
			}
		} else {
			PrintToChat( iPlayer, "%L", iPlayer, "WRONG_CAPTCHA", g_iSettings[ BYM_RECAPTCHA_TRYS ] - g_iReCaptcaTrys[ iPlayer ] );
			g_iReCaptcaTrys[ iPlayer ] ++;
			
			if( g_iReCaptcaTrys[ iPlayer ] >= g_iSettings[ BYM_RECAPTCHA_TRYS ] )
				PunishUser( iPlayer, "Fake Player" );
		}
	}

	return 2;
}

public client_connect( iPlayer ) {
	for( new iIterator = 0 ; iIterator < sizeof( g_iDetections[ ] ); iIterator ++ )
		g_iDetections[ iPlayer ][ iIterator ] = 0;
	
	g_iIsDetected[ iPlayer ] = false;
	g_iNamesChangesNumber[ iPlayer ] = 0;
	g_iReCaptcaTrys[ iPlayer ] = 0;
	g_szReCaptchaText[ iPlayer ][ 0 ] = EOS;
	g_iPassedReCaptcha[ iPlayer ] = 0;
	g_iHasSecounds[ iPlayer ] = 0;
	g_iCheckedCaptchaExipration[ iPlayer ] = 0;
	g_iIgnoreAim[ iPlayer ] = 0;
	g_iIgnoreRapid[ iPlayer ] = 0;
	g_iIgnoreNoRecoil[ iPlayer ] = 0;
	g_iIgnoreSpeedHack[ iPlayer ] = 0;
	
	if( g_iSettings[ MILF_ANTICHEAT_BINDS ] ) {
		ExecuteCommand( iPlayer, "bind del ^"amx_chat [MILF AntiCheat] Delete pressed!^"" );
		ExecuteCommand( iPlayer, "bind ins ^"amx_chat [MILF AntiCheat] Insert pressed!^"" );
		ExecuteCommand( iPlayer, "bind pgup ^"amx_chat [MILF AntiCheat] PageUP pressed!^"" );
		ExecuteCommand( iPlayer, "bind pgdn ^"amx_chat [MILF AntiCheat] PageDown pressed!^"" );
		ExecuteCommand( iPlayer, "bind end ^"amx_chat [MILF AntiCheat] End pressed!^"" );
		ExecuteCommand( iPlayer, "bind f12 ^"amx_chat [MILF AntiCheat] f12 pressed!^"" );
		ExecuteCommand( iPlayer, "bind f11 ^"amx_chat [MILF AntiCheat] f11 pressed!^"" );
		ExecuteCommand( iPlayer, "bind f10 ^"amx_chat [MILF AntiCheat] f10 pressed!^"" );
		ExecuteCommand( iPlayer, "bind f9 ^"amx_chat [MILF AntiCheat] f9 pressed!^"" );
		ExecuteCommand( iPlayer, "bind f8 ^"amx_chat [MILF AntiCheat] f8 pressed!^"" );
		ExecuteCommand( iPlayer, "bind f7 ^"amx_chat [MILF AntiCheat] f7 pressed!^"" );
		ExecuteCommand( iPlayer, "bind f6 ^"amx_chat [MILF AntiCheat] f6 pressed!^"" );
		ExecuteCommand( iPlayer, "bind f4 ^"amx_chat [MILF AntiCheat] f4 pressed!^"" );
		ExecuteCommand( iPlayer, "bind f3 ^"amx_chat [MILF AntiCheat] f3 pressed!^"" );
		ExecuteCommand( iPlayer, "rebuy;wait:wait:bind f2 ^"amx_chat [MILF AntiCheat] f2 pressed!^"" );
		ExecuteCommand( iPlayer, "autobuy;wait;wait;bind f1 ^"amx_chat [MILF AntiCheat] f1 pressed!^"" );
	}
	

	if( task_exists( iPlayer + TASK_RECAPTCHA ) )
		remove_task( iPlayer + TASK_RECAPTCHA );
		
	if( task_exists( iPlayer + TASK_PLAYER_AD ) )
		remove_task( iPlayer + TASK_PLAYER_AD );
	
	if( g_iSettings[ CHECK_NAME ] ) {
		static szName[ 32 ];
		get_user_name( iPlayer, szName, charsmax( szName ) );
		
		for( new iSymbols = 0 ; iSymbols < strlen( g_szRestrictedSymbols ); iSymbols ++ ) {
			for( new iNameCharacters = 0 ; iNameCharacters < strlen( szName ); iNameCharacters ++ ) {
				if( szName[ iNameCharacters ] == g_szRestrictedSymbols[ iSymbols ] ) {
					server_cmd( "kick #%d ^"%L^"", get_user_userid( iPlayer ), LANG_PLAYER, "WRONG_CH" );
					
					if( g_iSettings[ CNS_SHOW_REASON ] )
						PrintToChat( 0, "%L", LANG_PLAYER, "KICK_WR_CH", szName );
	
					break;
				}
			}
		}
	}

	if( g_iSettings[ CHECK_IPS ] ) {
		if( IsMaliciousIP( iPlayer ) )
			server_cmd( "kick #%d ^"%L^"", get_user_userid( iPlayer ), LANG_PLAYER, "WRONG_IP" );
	}

	return 0;
}

public client_putinserver( iPlayer ) {
	static szInfo[ 3 ];
	for( new iIterator = 0; iIterator < sizeof( g_szOldCheats ); iIterator ++ ) {
		get_user_info( iPlayer, g_szOldCheats[ iIterator ], szInfo, charsmax( szInfo ) );
		
		if( strlen( szInfo ) > 0 ) {
			PunishUser( iPlayer, "Illegal Symbols in Name" );
			return 1;
		}
	}

	#if defined USE_BYM_API
	ByM::PlayerConnected( iPlayer );
	#endif

	if( g_iSettings[ BYM_RECAPTCHA ] ) {
		GenerateReCaptcha( g_szReCaptchaText[ iPlayer ], charsmax( g_szReCaptchaText[ ] ) );
		g_iHasSecounds[ iPlayer ] = g_iSettings[ BYM_RECAPTCHA_TIME ];
		set_task( 3.0, "DisplayReCaptcha", iPlayer + TASK_RECAPTCHA );
	}
	
	if( task_exists( iPlayer +  TASK_MILF ) )
		remove_task( iPlayer +  TASK_MILF );
		
	set_task( 20.0, "PlayerConnectedAdv", iPlayer + TASK_PLAYER_AD );
	return 0;
}

public DisplayReCaptcha( iTask ) {
	new iPlayer = iTask - TASK_RECAPTCHA;
	
	if( g_iSettings[ BYM_RECAPTCHA_REMEMBER ] && !g_iCheckedCaptchaExipration[ iPlayer ] ) {
		g_iCheckedCaptchaExipration[ iPlayer ] = 1;
		
		new szSteamID[ 64 ];
		get_user_authid( iPlayer, szSteamID, charsmax( szSteamID ) );
		
		new szData[ 12 ];
		nvault_get( g_iCaptchaVault, szSteamID, szData, charsmax( szData ) );
		
		if( get_systime( ) < str_to_num( szData ) )
			return;
	}

	g_iHasSecounds[ iPlayer ] --;

	#if defined USE_BYM_API
	if( !IsPlayer->Connected( iPlayer ) || IsPlayer->Bot( iPlayer ) || g_iPassedReCaptcha[ iPlayer ] )
		return;
	#else
	if( !is_user_connected( iPlayer ) || is_user_bot( iPlayer ) || g_iPassedReCaptcha[ iPlayer ] )
		return;
	#endif

	if( g_iHasSecounds[ iPlayer ] <= 0 ) {
		PunishUser( iPlayer, "Fake Player" );
		return;
	}

	set_dhudmessage( 0, 255, 255, -1.0, 0.2, 0, 6.0, 0.7 );
	show_dhudmessage( iPlayer, "%L", iPlayer, "BYM_RECAPTCHA_TEXT", g_iHasSecounds[ iPlayer ], g_szReCaptchaText[ iPlayer ] );

	set_task( 1.0, "DisplayReCaptcha", iPlayer + TASK_RECAPTCHA );
}

stock GenerateReCaptcha( szOutput[ ], const iLen ) {
	new szChar;
	for( new iIterator = 0; iIterator < iLen; iIterator ++ ) {
		switch( random( 3 ) ) {
			case 0: szChar = random_num( 'a', 'z' );
			case 1: szChar = random_num( 'A', 'Z' );
			case 2: szChar = random_num( '0', '9' );
		}

		formatex( szOutput[ iIterator ], iLen, "%c", szChar );
	}
}

public client_authorized( iPlayer ) {
	if( !g_iSettings[ ANTIBOT_ENABLED ] || is_user_bot( iPlayer ) )
		return;

	new szIP[ 32 ];
	new szSteamID[ 64 ];
	get_user_ip( iPlayer, szIP, charsmax( szIP ), 1 );
	get_user_authid( iPlayer, szSteamID, charsmax( szSteamID ) );
	
	if( !strlen( szIP ) )
		return;
		
	if( !IsExcludedIP( iPlayer ) ) {
		new iNumberOfIPs = 0;
		new szIP2[ 32 ];
		ForEachPlayer( iPlayers ) {
			get_user_ip( iPlayers, szIP2, charsmax( szIP2 ), 1 );
			
			if( equal( szIP, szIP2 ) )
				iNumberOfIPs ++;
		}
		
		if( iNumberOfIPs > 1 ) {
			server_cmd( "kick ^"#%d^" ^"There is someone with the same IP on this is server already playing!^"", get_user_userid( iPlayer ) );
			return;
		}
	}

	if( !strlen( szSteamID ) || containi( szSteamID, "BOT" ) != -1 )
		return;
		
	new iNumberSteamID = 0;
	new szSteamID2[ 32 ];
	ForEachPlayer( iPlayers ) {
		get_user_authid( iPlayers, szSteamID2, charsmax( szSteamID2 ) );
		
		if( equal( szSteamID, szSteamID2 ) )
			iNumberSteamID ++;
	}
	
	if( iNumberSteamID > 1 ) {
		server_cmd( "kick ^"#%d^" ^"There is someone with the same Steam ID on this server is already playing!^"", get_user_userid( iPlayer ) );
		return;
	}
}

public client_disconnected( iPlayer ) {
	#if defined USE_BYM_API
	ByM::PlayerDisconnected( iPlayer );
	#endif
	
	if( task_exists( iPlayer + TASK_PLAYER_AD ) )
		remove_task( iPlayer + TASK_PLAYER_AD );
	
	if( task_exists( iPlayer + TASK_RECAPTCHA ) )
		remove_task( iPlayer + TASK_RECAPTCHA );

	if( task_exists( iPlayer +  TASK_MILF ) )
		remove_task( iPlayer +  TASK_MILF );
		
	for( new iIterator = 0 ; iIterator < sizeof( g_iDetections[ ] ); iIterator ++ )
		g_iDetections[ iPlayer ][ iIterator ] = 0;
	
	g_iIsDetected[ iPlayer ] = false;
	g_iNamesChangesNumber[ iPlayer ] = 0;
	g_iReCaptcaTrys[ iPlayer ] = 0;
	g_szReCaptchaText[ iPlayer ][ 0 ] = EOS;
	g_iPassedReCaptcha[ iPlayer ] = 0;
	g_iHasSecounds[ iPlayer ] = 0;
	g_iCheckedCaptchaExipration[ iPlayer ] = 0;
	g_iIgnoreAim[ iPlayer ] = 0;
	g_iIgnoreRapid[ iPlayer ] = 0;
	g_iIgnoreNoRecoil[ iPlayer ] = 0;
	g_iIgnoreSpeedHack[ iPlayer ] = 0;
}

public client_command( iPlayer ) {
	if( !g_iSettings[ MILF_ANTICHEAT_BINDS ] )
		return PLUGIN_CONTINUE;
	
	new szCommand[ 20 ];
	read_argv( 0, szCommand, charsmax( szCommand ) );
	
	new szParams[ 96 ]
	read_args( szParams, charsmax( szParams ) );
	
	if( equali( szCommand, "amx_chat" ) ) {
		if( containi( szParams, "MILF AntiCheat" ) != -1 ) {
			replace_all( szParams, charsmax( szParams ), "[MILF AntiCheat]", "" );
			replace_all( szParams, charsmax( szParams ), "pressed!", "" );
			replace_all( szParams, charsmax( szParams ), " ", "" );
			trim( szParams );
			
			new const g_szButtons[ ][ ] = { "Delete", "Insert", "PageUP", "PageDown", "End", "F12", "F11", "F10", "F9", "F8", "F7", "F6", "F4", "F3", "F2", "F1" };
			new szButtonPressed[ 32 ];
			szButtonPressed[ 0 ] = EOS;
			
			for( new iButtons = 0; iButtons < sizeof( g_szButtons ); iButtons ++ ) {
				if( containi( szParams, g_szButtons[ iButtons ] ) != -1 ) {
					copy( szButtonPressed, charsmax( szButtonPressed ), g_szButtons[ iButtons ] );
					break;
				}
			}
			
			if( szButtonPressed[ 0 ] == EOS )
				return PLUGIN_CONTINUE;
		
			// Screenshot on Steam, skip steam players
			if( IsSteamPlayer( iPlayer ) && containi( szButtonPressed, "F12" ) != -1 )
				return PLUGIN_CONTINUE;
				
			if( !( containi( g_szMilfKeys, szButtonPressed ) != -1 ) )
				return PLUGIN_CONTINUE;
			
			new szTime[ 32 ];
			get_time( "%d.%m.%Y %H:%M:%S", szTime, charsmax( szTime ) );
			
			PrintToChat( iPlayer, "!g--------------------------" );
			PrintToChat( iPlayer, "!gTime of button %s press: !t%s",szButtonPressed, szTime );
			PrintToChat( iPlayer, "!g--------------------------" );
			client_cmd( iPlayer, "snapshot" );
			
			new szReason[ 96 ];
			formatex( szReason, charsmax( szReason ), "Forbidden button %s pressed!", szButtonPressed );
			
			WriteToLog( iPlayer, g_iSettings[ PUNISH_TYPE ], "", szReason );
			
			if( task_exists( iPlayer +  TASK_MILF ) )
				remove_task( iPlayer +  TASK_MILF );
				
			set_task( 2.0, "MilfPunishment", iPlayer +  TASK_MILF );
		}
	}
	
	return PLUGIN_CONTINUE;
}	

public MilfPunishment( iTask ) {
	new iPlayer = iTask - TASK_MILF;
	
	if( !is_user_connected( iPlayer ) )
		return;
	
	client_cmd( iPlayer, "snapshot" );
	
	new szTime[ 32 ];
	get_time( "%d.%m.%Y %H:%M:%S", szTime, charsmax( szTime ) );
	
	new szSteamID[ 64 ];
	get_user_authid( iPlayer, szSteamID, charsmax( szSteamID ) );
			
	PrintToChat( iPlayer, "!g--------------------------" );
	PrintToChat( iPlayer, "!gTime of ban: !t%s", szTime );
	PrintToChat( iPlayer, "!g--------------------------" );
	
	if( !g_iSettings[ MILF_ANTICHEAT_PUNISHMENT ] ) {
		new szCommand[ 512 ];
		copy( szCommand, charsmax( szCommand ), g_szKickCommand );
		replace_all( szCommand, charsmax( szCommand ), "[player]", szSteamID );
		replace_all( szCommand, charsmax( szCommand ), "[reason]", g_szMilfReason );
		
		server_print( "%s", szCommand );
		server_cmd( "%s", szCommand );
	} else {
		new szCommand[ 512 ];
		copy( szCommand, charsmax( szCommand ), g_szBanCommand );
		
		new szTime[ 32 ];
		num_to_str( g_iSettings[ MILF_ANTICHEAT_TIME ], szTime, charsmax( szTime ) );
		
		replace_all( szCommand, charsmax( szCommand ), "[player]", szSteamID );
		replace_all( szCommand, charsmax( szCommand ), "[time]", szTime );
		replace_all( szCommand, charsmax( szCommand ), "[reason]", g_szMilfReason );
		
		server_print( "%s", szCommand );
		server_cmd( "%s", szCommand );
	}
}

public LoadFlashBugVectors( ) {
	static szBaseDir[ 64 ], szUltimateAntiCheatDir[ 64 ], szFile[ 64 ];
	get_basedir( szBaseDir, charsmax( szBaseDir ) );
	
	get_mapname( g_szMapName, charsmax( g_szMapName ) );
	
	formatex( szUltimateAntiCheatDir, charsmax( szUltimateAntiCheatDir ), "%s/UltimateAntiCheat", szBaseDir );
	formatex( szFile, charsmax( szFile ), "%s/FlashBug/%s.ini", szUltimateAntiCheatDir, g_szMapName );
	
	if( !file_exists( szFile ) ) {
		server_print( "%L", LANG_SERVER, "LD_VECTORS", g_szMapName );
		return;
	}
	
	static iFile, szBuffer[ 128 ], szTemp[ 4 ][ 32 ], iIterator;
	iFile = fopen( szFile, "rt" );
	
	while( !feof( iFile ) ) {
		fgets( iFile, szBuffer, charsmax( szBuffer ) );
		
		if( ( szBuffer[ 0 ] == ';' ) || ( szBuffer[ 0 ] == '/' && szBuffer[ 1 ] == '/' ) || strlen( szBuffer ) < 2 )
			continue;
		
		if( parse( szBuffer, szTemp[ 0 ], charsmax( szTemp[ ] ), szTemp[ 1 ], charsmax( szTemp[ ] ), szTemp[ 2 ], charsmax( szTemp[ ] ), szTemp[ 3 ], charsmax( szTemp[ ] ) ) != 4 ) {
			server_print( "%L", LANG_SERVER, "SV_PRINT_VEC", g_szMapName );
			continue;
		}
		
		g_iFlashVectors[ iIterator ][ 0 ] = str_to_num( szTemp[ 0 ] );
		g_iFlashVectors[ iIterator ][ 1 ] = str_to_num( szTemp[ 1 ] );
		g_iFlashVectors[ iIterator ][ 2 ] = str_to_num( szTemp[ 2 ] );
		g_iFlashVectors[ iIterator ][ 3 ] = str_to_num( szTemp[ 3 ] );
		
		iIterator ++;
	}

	fclose( iFile );
	
	g_iFlashZones = iIterator;
	
	server_print( "%L", LANG_SERVER, "SUC_VEC_LOAD", g_iFlashZones, g_szMapName );
}

public fw_EventPlayerFlashed( iPlayer ) {
	if( !g_iSettings[ BLOCK_NOFLASH ] )
		return PLUGIN_CONTINUE; 

	#if defined USE_BYM_API
	if( !IsPlayer->Connected( iPlayer ) )
		return PLUGIN_CONTINUE; 
	#else
	if( !is_user_connected( iPlayer ) )
		return PLUGIN_CONTINUE; 
	#endif

	g_fFlashedUntil[ iPlayer ] = read_data( 2 ) / 4096.0 + get_gametime( );

	message_begin( MSG_ONE_UNRELIABLE, g_iMessageScreenFade, { 0, 0, 0 }, iPlayer );
	write_short( 0 );
	write_short( 0 );
	write_short( 0 );
	write_byte( 0 );
	write_byte( 0 );
	write_byte( 0 );
	write_byte( 0 );
	message_end( );	
	
	return PLUGIN_CONTINUE; 

}

public fw_EventNewRound( ) {
	static iPlayers[ 32 ], iNumber, iPlayer;
	get_players( iPlayers, iNumber, "ach" );

	for( new iIterator = 0; iIterator < iNumber ; iIterator ++ ) {
		iPlayer = iPlayers[ iIterator ];

		#if defined USE_BYM_API
		if( g_iSettings[ CHECK_SPEEDHACK ] && IsPlayer->Alive( iPlayer ) ) {
		#else
		if( g_iSettings[ CHECK_SPEEDHACK ] && is_user_alive( iPlayer ) ) {
		#endif
			static Float: fOrigin[ 3 ];
			#if defined USE_FAKEMETA
			pev( iPlayer, pev_origin, fOrigin );
			#else
			entity_get_vector( iPlayer, EV_VEC_origin, fOrigin );
			#endif
			
			CopyVector( fOrigin, g_fLastOrigin[ iPlayer ] );
		}
	}
}

public fw_FmThink( iEntity ) {
	#if defined USE_FAKEMETA
	if( !pev_valid( iEntity ) )
		return FMRES_IGNORED;
	#else
	if( !is_valid_ent( iEntity ) )
		return FMRES_IGNORED;
	#endif
	
	if( !g_iSettings[ CHECK_FLASHBUG ] )
		return FMRES_IGNORED;
	
	static Float: fOrigin[ 3 ], iOrigin[ 3 ], iBugZone[ 3 ];
	static szModel[ 32 ];
	
	#if defined USE_FAKEMETA
	pev( iEntity, pev_model, szModel, charsmax( szModel ) ); 
	#else
	entity_get_string( iEntity, EV_SZ_model, szModel, charsmax( szModel ) );
	#endif
	
	if( !equali( szModel, "models/w_flashbang.mdl" ) )
		return FMRES_IGNORED;
	
	static iPlayer;
	#if defined USE_FAKEMETA
	iPlayer = pev( iEntity, pev_owner );
	#else
	iPlayer = entity_get_edict( iEntity, EV_ENT_owner );
	#endif
	
	#if defined USE_FAKEMETA
	pev( iEntity, pev_origin, fOrigin );
	#else
	entity_get_vector( iEntity, EV_VEC_origin, fOrigin );
	#endif

	iOrigin[ 0 ] = floatround( fOrigin[ 0 ] );
	iOrigin[ 1 ] = floatround( fOrigin[ 1 ] );
	iOrigin[ 2 ] = floatround( fOrigin[ 2 ] );
	
	for( new iIterator = 0; iIterator < g_iFlashZones; iIterator ++ ) {
		iBugZone[ 0 ] = g_iFlashVectors[ iIterator ][ 0 ];
		iBugZone[ 1 ] = g_iFlashVectors[ iIterator ][ 1 ];
		iBugZone[ 2 ] = g_iFlashVectors[ iIterator ][ 2 ];
		
		if( get_distance( iOrigin, iBugZone ) <=  g_iFlashVectors[ iIterator ][ 3 ] ) {
			PrintToChat( 0, "%L", LANG_PLAYER, "SUCC_RMV_FLB", iOrigin[ 0 ], iOrigin[ 1 ], iOrigin[ 2 ] );
			engfunc( EngFunc_RemoveEntity, iEntity );
			
			set_dhudmessage( 255, 0, 0, -1.0, 0.3, 0, 6.0, 3.0 );
			show_dhudmessage( iPlayer, "%L", LANG_PLAYER, "ILG_MAP_EXPLOIT" );
			
			SlapUser( iPlayer, 10.0 );
			return FMRES_SUPERCEDE;
		}
	}

	return FMRES_IGNORED;
}

public fw_PlayerPreThink( iPlayer ) {
	#if defined USE_BYM_API
	if( !IsPlayer->Alive( iPlayer ) || IsPlayer->Bot( iPlayer ) )
		return FMRES_IGNORED;
	#else
	if( !is_user_alive( iPlayer ) || is_user_bot( iPlayer ) )
		return FMRES_IGNORED;
	#endif
	
	if( g_iSettings[ CHECK_MOVEKEYS ] )
		CheckScriptBlock( iPlayer );
	
	if( g_iSettings[ CHECK_BHOP ] ) {
		#if defined USE_FAKEMETA
		if( !( pev( iPlayer, pev_flags ) & FL_ONGROUND ) && ( !( pev( iPlayer,pev_button ) & IN_JUMP ) || pev( iPlayer, pev_oldbuttons ) & IN_JUMP ) )
		#else
		if( !( entity_get_int( iPlayer, EV_INT_flags ) & FL_ONGROUND ) && ( !( entity_get_int( iPlayer, EV_INT_button ) & IN_JUMP ) || entity_get_int( iPlayer, EV_INT_oldbuttons ) & IN_JUMP ) )
		#endif
		
		client_cmd( iPlayer, ";alias _special %s", g_iBhopScript );
	}
	
	return FMRES_IGNORED;
}

public fw_FmPlayerPostThink( iPlayer ) {
	#if defined USE_BYM_API
	if( !IsPlayer->Alive( iPlayer ) || IsPlayer->Bot( iPlayer ) )
		return FMRES_IGNORED;
	#else
	if( !is_user_alive( iPlayer ) || is_user_bot( iPlayer ) )
		return FMRES_IGNORED;
	#endif
	
	if( g_iSettings[ CHECK_SPINHACK ] )
		CheckSpinHack_Post( iPlayer );

	if( g_iSettings[ CHECK_SHAKE ] )
		CheckShake( iPlayer );
	
	return FMRES_IGNORED;
}

public fw_FmAddFullToPack( iES, iE, iEntity, iHost, iFlags, iPlayer, iSet ) {
	if( !g_iSettings[ BLOCK_NOFLASH ] )
		return FMRES_IGNORED;

	#if defined USE_BYM_API
	if( !IsPlayer->Alive( iHost ) || IsPlayer->Bot( iHost ) )
		return FMRES_IGNORED;
	#else
	if( !is_user_alive( iHost ) || is_user_bot( iHost ) )
		return FMRES_IGNORED;
	#endif
		
	if( iPlayer ) {
		#if defined USE_BYM_API
		if( !IsPlayer->Alive( iEntity ) || iEntity == iHost )
			return FMRES_IGNORED;
		#else
		if( !is_user_alive( iEntity ) || iEntity == iHost )
			return FMRES_IGNORED;
		#endif
	} else {
		#if defined USE_FAKEMETA
		if( pev_valid( iEntity ) ) {
			static szClassName[ 33 ];
			pev( iEntity, pev_classname, szClassName, charsmax( szClassName ) );
			
			if( !( strcmp( szClassName, "grenade" ) == 0 ) || pev( iEntity, pev_owner ) == iHost )
				return FMRES_IGNORED;
		}
		#else
		if( is_valid_ent( iEntity ) ) {
			static szClassName[ 33 ];
			entity_get_string( iEntity, EV_SZ_classname, szClassName, charsmax( szClassName ) );
			
			if( !( strcmp( szClassName, "grenade" ) == 0 ) || entity_get_edict( iEntity, EV_ENT_owner ) == iHost )
				return FMRES_IGNORED;
		}
		#endif

		return FMRES_IGNORED;
	}
	
	if( get_gametime( ) < g_fFlashedUntil[ iHost ] ) {
		forward_return( FMV_CELL, 0 );
		return FMRES_SUPERCEDE;
	}
	
	return FMRES_IGNORED;

}

public fw_CommandCheckBHop( iPlayer ) {
	if( !g_iSettings[ CHECK_BHOP ] )
		return 1;

	#if defined USE_FAKEMETA
	if( !( pev( iPlayer, pev_flags ) & FL_ONGROUND ) && ( !( pev( iPlayer, pev_button ) & IN_JUMP ) || pev( iPlayer, pev_oldbuttons ) & IN_JUMP ) )
	#else
	if( !( entity_get_int( iPlayer, EV_INT_flags ) & FL_ONGROUND ) && ( !( entity_get_int( iPlayer, EV_INT_button ) & IN_JUMP ) || entity_get_int( iPlayer, EV_INT_oldbuttons ) & IN_JUMP ) )
	#endif
		return 1;
	
	return 0;
}

public CheckShake( iPlayer ) {
	if( g_iIgnoreShake[ iPlayer ] )
		return FMRES_IGNORED;

	static Float: fAimAngles[ 3 ];
	#if defined USE_FAKEMETA
	pev( iPlayer, pev_angles, fAimAngles );
	#else
	entity_get_vector( iPlayer, EV_VEC_angles, fAimAngles );
	#endif
	
	static iWeapon, iTrash;
	iWeapon = get_user_weapon( iPlayer, iTrash, iTrash );
	
	if( iWeapon == CSW_M249 )
		return FMRES_IGNORED;
	
	#if defined USE_FAKEMETA
	if( ( ( fAimAngles[ 0 ] ==  g_fOldAimAngles[ iPlayer ][ 0 ] ) && ( fAimAngles[ 1 ] ==  g_fOldAimAngles[ iPlayer ][ 1 ] ) ) || ( pev( iPlayer, pev_button ) & IN_JUMP ) ) {
	#else
	if( ( ( fAimAngles[ 0 ] ==  g_fOldAimAngles[ iPlayer ][ 0 ] ) && ( fAimAngles[ 1 ] ==  g_fOldAimAngles[ iPlayer ][ 1 ] ) ) || ( entity_get_int( iPlayer, EV_INT_button ) & IN_JUMP ) ) {
	#endif
		g_iDetections[ iPlayer ][ SHAKE ] -= 10;
		
		if( g_iDetections[ iPlayer ][ SHAKE ] < 0 )
			g_iDetections[ iPlayer ][ SHAKE ] = 0;
	} else g_iDetections[ iPlayer ][ SHAKE ]++;
	
	if( g_iDetections[ iPlayer ][ SHAKE ] > g_iSettings[ SHAKE_WARNING_NUMBER ] ) {
		set_hudmessage( 255, 0, 0, -1.0, 0.3, 0, 6.0, 3.0 );
		show_dhudmessage( iPlayer, "%L", LANG_PLAYER, "SHAKE_WARN" );
	}

	if( g_iDetections[ iPlayer ][ SHAKE ] > g_iSettings[ SHAKE_PUNISH_NUMBER ] )
		PunishUser( iPlayer, "Shake" );
	
	CopyVector( fAimAngles, g_fOldAimAngles[ iPlayer ] );
	return FMRES_IGNORED;
}

public CheckSpinHack_Post( iPlayer ) {
	static Float: fAngles[ 3 ];
	#if defined USE_FAKEMETA
	pev( iPlayer, pev_angles, fAngles );
	#else
	entity_get_vector( iPlayer, EV_VEC_angles, fAngles );
	#endif
	
	g_fTotalAngle[ iPlayer ] += vector_distance( g_fLastAngles[ iPlayer ], fAngles );
	
	CopyVector( fAngles, g_fLastAngles[ iPlayer ] );
	
	static iButton;
	#if defined USE_FAKEMETA
	iButton = pev( iPlayer, pev_button );
	#else
	iButton = entity_get_int( iPlayer, EV_INT_button );
	#endif
	
	if( ( iButton & IN_LEFT ) || ( iButton & IN_RIGHT ) )
		g_iDetections[ iPlayer ][ SPINHACK ] = 0;
}

public g_fwPlayBackEvent( iFlags, iPlayer, iEventIndex ) {
	if( !g_iSettings[ CHECK_RAPIDFIRE ] )
		return FMRES_IGNORED;

	#if defined USE_BYM_API
	if( !IsPlayer->Alive( iPlayer ) )
		return FMRES_IGNORED;
	#else
	if( !is_user_alive( iPlayer ) )
		return FMRES_IGNORED;
	#endif
	
	if( g_iIgnoreNoRecoil[ iPlayer ] )
		return FMRES_IGNORED;
	
	for( new iEvents = 0; iEvents < sizeof( g_szGunsEvents ); iEvents ++ ) {
		if( iEventIndex == g_szGunsEventsId[ iEvents ] ) {
			static iWeapon, iTrash;
			iWeapon = get_user_weapon( iPlayer, iTrash, iTrash );
			
			static Float: fAimAngles[ 3 ];
			#if defined USE_FAKEMETA
			pev( iPlayer, pev_angles, fAimAngles );
			#else
			entity_get_vector( iPlayer, EV_VEC_angles, fAimAngles );
			#endif
			
			if( iWeapon == CSW_GLOCK18 || iWeapon == CSW_P90 )
				return FMRES_IGNORED;
			
			if( g_iSettings[ CHECK_RAPIDFIRE ] && !g_iIgnoreRapid[ iPlayer ] )
				g_iDetections[ iPlayer ][ RAPIDFIRE ] ++;
			
			if( g_iSettings[ CHECK_LOWRECOIL ] ) {
				if( ( fAimAngles[ 0 ] == g_fRecoilLastAngles[ iPlayer ][ 0 ] ) && g_fRecoilLastAngles[ iPlayer ][ 0 ] != 0.0 )
					g_iDetections[ iPlayer ][ RECOIL ] ++;
				else g_iDetections[ iPlayer ][ RECOIL ] --;
				
				g_fRecoilLastAngles[ iPlayer ][ 0 ] = fAimAngles[ 0 ];
				
				if( g_iDetections[ iPlayer ][ RECOIL ] > g_iSettings[ LOWRECOILL_WARNING_NUMBER ] ) {
					set_dhudmessage( 255, 0, 0, -1.0, 0.3, 0, 6.0, 3.0 );
					show_dhudmessage( iPlayer, "%L", LANG_PLAYER, "LOW_RECOIL" );
				}

				if( g_iDetections[ iPlayer ][ RECOIL ] > g_iSettings[ LOWRECOILL_PUNISH_NUMBER ] )
					PunishUser( iPlayer, "No Recoil" );
			}
		}
	}

	return FMRES_IGNORED;
}

#if defined USE_TASKS
public ClearRecoil( ) {
#else
public ClearRecoil( iPlayer ) {
#endif
	#if defined USE_TASKS
	static iPlayers[ 32 ], iNumber, iPlayer;
	get_players( iPlayers, iNumber, "ach" );

	for( new iIterator = 0; iIterator < iNumber ; iIterator ++ ) {
		iPlayer = iPlayers[ iIterator ];
		
		if( g_iIgnoreNoRecoil[ iPlayer ] )
			continue;

		g_iDetections[ iPlayer ][ RECOIL ] -= 10;
		
		if( g_iDetections[ iPlayer ][ RECOIL ] < 0 )
			g_iDetections[ iPlayer ][ RECOIL ] = 0;
	}
	#else
	g_iDetections[ iPlayer ][ RECOIL ] -= 10;
		
	if( g_iDetections[ iPlayer ][ RECOIL ] < 0 )
		g_iDetections[ iPlayer ][ RECOIL ] = 0;
	#endif
}

#if defined USE_TASKS
public CheckSpeedHack( ) {
#else
public CheckSpeedHack( iPlayer ) {
#endif
	#if defined USE_TASKS
	static iPlayers[ 32 ], iNumber, iPlayer;
	get_players( iPlayers, iNumber, "ach" );

	for( new iIterator = 0; iIterator < iNumber ; iIterator ++ ) {
		iPlayer = iPlayers[ iIterator ];
		
		if( g_iIgnoreSpeedHack[ iPlayer ] )
			continue;

		#if defined USE_BYM_API
		if( !IsPlayer->Alive( iPlayer ) )
			continue;
		#else
		if( !is_user_alive( iPlayer ) )
			continue;
		#endif
		
		static Float: fOrigin[ 3 ], Float: fOldOrigin[ 3 ], Float: fDistance;
		#if defined USE_FAKEMETA
		pev( iPlayer, pev_origin, fOrigin );
		#else
		entity_get_vector( iPlayer, EV_VEC_origin, fOrigin );
		#endif
		
		CopyVector( g_fLastOrigin[ iPlayer ], fOldOrigin );
		
		if( g_iSettings[ SPEEDHACK_SECURE ] ) {
			fOrigin[ 2 ] = 0.0;
			fOldOrigin[ 2 ] = 0.0;
		}
		
		fDistance = get_distance_f( fOrigin, fOldOrigin );
		
		if( g_iDetections[ iPlayer ][ SPEEDHACK ] >= 3 )
			g_iDetections[ iPlayer ][ SPEEDHACK ]--;
		
		if( g_iDetections[ iPlayer ][ SPEEDHACK ] < 0 )
			g_iDetections[ iPlayer ][ SPEEDHACK ] = 0;
		
		if( fDistance >= 240.0 )
			g_iDetections[ iPlayer ][ SPEEDHACK ] += 3;
		
		if( g_iDetections[ iPlayer ][ SPEEDHACK ] > g_iSettings[ SPEEDHACK_WARNING_NUMBER ] ) {
			set_dhudmessage( 255, 0, 0, -1.0, 0.3, 0, 6.0, 3.0 );
			show_dhudmessage( iPlayer, "%L", LANG_PLAYER, "SPEED_HACK" );
			
			client_cmd( iPlayer, "spk %s", g_szWarningSounds[ 1 ] );
		}
		if( g_iDetections[ iPlayer ][ SPEEDHACK ] > g_iSettings[ SPEEDHACK_PUNISH_NUMBER ] )
			PunishUser( iPlayer, "Speed Hack" );
		
		CopyVector( fOrigin, g_fLastOrigin[ iPlayer ] );
	}
	#else
	
	#if defined USE_BYM_API
	if( !IsPlayer->Alive( iPlayer ) || !IsPlayer->Connected( iPlayer ) )
		return;
	#else
	if( !is_user_alive( iPlayer ) )
		return;
	#endif
		
	static Float: fOrigin[ 3 ], Float: fOldOrigin[ 3 ], Float: fDistance;
	#if defined USE_FAKEMETA
	pev( iPlayer, pev_origin, fOrigin );
	#else
	entity_get_vector( iPlayer, EV_VEC_origin, fOrigin );
	#endif
		
	CopyVector( g_fLastOrigin[ iPlayer ], fOldOrigin );
		
	if( g_iSettings[ SPEEDHACK_SECURE ] ) {
		fOrigin[ 2 ] = 0.0;
		fOldOrigin[ 2 ] = 0.0;
	}
		
	fDistance = get_distance_f( fOrigin, fOldOrigin );
		
	if( g_iDetections[ iPlayer ][ SPEEDHACK ] >= 3 )
		g_iDetections[ iPlayer ][ SPEEDHACK ] --;
		
	if( g_iDetections[ iPlayer ][ SPEEDHACK ] < 0 )
		g_iDetections[ iPlayer ][ SPEEDHACK ] = 0;
		
	if( fDistance >= 350.0 )
		g_iDetections[ iPlayer ][ SPEEDHACK ] += 3;
		
	if( g_iDetections[ iPlayer ][ SPEEDHACK ] > g_iSettings[ SPEEDHACK_WARNING_NUMBER ] ) {
		set_dhudmessage( 255, 0, 0, -1.0, 0.3, 0, 6.0, 3.0 );
		show_dhudmessage( iPlayer, "%L", LANG_PLAYER, "SPEED_HACK" );
	}
	
	if( g_iDetections[ iPlayer ][ SPEEDHACK ] > g_iSettings[ SPEEDHACK_PUNISH_NUMBER ] )
		PunishUser( iPlayer, "Speed Hack" );
		
	CopyVector( fOrigin, g_fLastOrigin[ iPlayer ] );
	#endif
}

#if defined USE_TASKS
public CheckSpinTotal( ) {
#else
public CheckSpinTotal( iPlayer ) {
#endif
	#if defined USE_TASKS
	static iPlayers[ 32 ], iNumber, iPlayer;
	get_players( iPlayers, iNumber, "ach" );
	
	for( new iIterator = 0; iIterator < iNumber ; iIterator ++ ) {
		iPlayer = iPlayers[ iIterator ];
		
		if( g_fTotalAngle[ iPlayer ] >= 1500.0 ) {		
			if( g_iDetections[ iPlayer ][ SPINHACK ] > g_iSettings[ SPINHACK_WARNING_NUMBER ] ) {
				set_dhudmessage( 255, 0, 0, -1.0, 0.3, 0, 6.0, 3.0 );
				show_dhudmessage( iPlayer, "%L", LANG_PLAYER, "SPIN_HACK" );
				
				client_cmd( iPlayer, "spk %s", g_szWarningSounds[ 1 ] );
			}
			if( g_iDetections[ iPlayer ][ SPINHACK ] > g_iSettings[ SPINHACK_PUNISH_NUMBER ] )
				PunishUser( iPlayer, "Spin Bot" );
			
			g_iDetections[ iPlayer ][ SPINHACK ] ++;
		}
		else g_iDetections[ iPlayer ][ SPINHACK ] = 0;
		
		g_fTotalAngle[ iPlayer ] = 0.0;
	}
	#else
	if( g_fTotalAngle[ iPlayer ] >= 1500.0 ) {		
		if( g_iDetections[ iPlayer ][ SPINHACK ] >= g_iSettings[ SPINHACK_WARNING_NUMBER ] ) {
			set_dhudmessage( 255, 0, 0, -1.0, 0.3, 0, 6.0, 3.0 );
			show_dhudmessage( iPlayer, "%L", LANG_PLAYER, "SPIN_HACK" );
				
			//client_cmd( iPlayer, "spk %s", g_szWarningSounds[ 1 ] );
		}
		
		if( g_iDetections[ iPlayer ][ SPINHACK ] > g_iSettings[ SPINHACK_PUNISH_NUMBER ] )
			PunishUser( iPlayer, "Spin Bot" );
			
		g_iDetections[ iPlayer ][ SPINHACK ] ++;
	}
	else g_iDetections[ iPlayer ][ SPINHACK ] = 0;
	
	g_fTotalAngle[ iPlayer ] = 0.0;
	#endif
}

#if defined USE_TASKS
public CheckRapidFire( ) {
#else
public CheckRapidFire( iPlayer ) {
#endif
	#if defined USE_TASKS
	static iPlayers[ 32 ], iNumber, iPlayer;
	get_players( iPlayers, iNumber, "ach" );
	
	for( new iIterator = 0; iIterator < iNumber; iIterator ++ ) {
		iPlayer = iPlayers[ iIterator ];
		
		if( g_iIgnoreRapid[ iPlayer ] )
			continue;
		
		if( g_iDetections[ iPlayer ][ RAPIDFIRE ] >= g_iSettings[ RAPID_FIRE_PUNISH_NUMBER ] )
			PunishUser( iPlayer, "Rapid" );
		
		g_iDetections[ iPlayer ][ RAPIDFIRE ] = 0;
	}
	#else
	if( g_iDetections[ iPlayer ][ RAPIDFIRE ] >= g_iSettings[ RAPID_FIRE_PUNISH_NUMBER ] )
		PunishUser( iPlayer, "Rapid" );
		
	g_iDetections[ iPlayer ][ RAPIDFIRE ] = 0;
	#endif
}

public CheckScriptBlock( iPlayer ) {
	#if defined USE_BYM_API
	if( !IsPlayer->Alive( iPlayer ) )
		return FMRES_IGNORED;
	#else
	if( !is_user_alive( iPlayer ) )
		return FMRES_IGNORED;
	#endif

	static Float: fAimAngles[ 3 ];
	#if defined USE_FAKEMETA
	pev( iPlayer, pev_angles, fAimAngles );
	#else
	entity_get_vector( iPlayer, EV_VEC_angles, fAimAngles );
	#endif
	
	CopyVector( fAimAngles, g_fAimOrigin[ iPlayer ] );
	
	static iButton;
	#if defined USE_FAKEMETA
	iButton = pev( iPlayer, pev_button );
	#else
	iButton = entity_get_int( iPlayer, EV_INT_button );
	#endif
	
	if( iButton & IN_LEFT ) {
		client_cmd( iPlayer, "-left" );
		
		CopyVector( g_fAimOrigin[ iPlayer ], fAimAngles );
		
		#if defined USE_FAKEMETA
		pev( iPlayer, pev_angles, fAimAngles );
		#else
		entity_set_vector( iPlayer, EV_VEC_angles, fAimAngles );
		#endif

		set_pev( iPlayer, pev_fixangle, 1 );
		
		set_dhudmessage( 255, 0, 0, -1.0, 0.3, 0, 6.0, 3.0 );
		show_dhudmessage( iPlayer, "%L", LANG_PLAYER, "LF_R_L_KEYS" );
	}
	else if( iButton & IN_RIGHT ) {
		client_cmd( iPlayer, "-right" );
		
		CopyVector( g_fAimOrigin[ iPlayer ], fAimAngles );
		
		#if defined USE_FAKEMETA
		set_pev( iPlayer, pev_angles, fAimAngles );
		#else
		entity_set_vector( iPlayer, EV_VEC_angles, fAimAngles );
		#endif

		set_pev( iPlayer, pev_fixangle, 1 );
		
		set_dhudmessage( 255, 0, 0, -1.0, 0.3, 0, 6.0, 3.0 );
		show_dhudmessage( iPlayer, "%L", LANG_PLAYER, "LF_R_L_KEYS" );
	}
	
	if( g_iSettings[ CHECK_DOUBLEATTACK ] ) {
		if( ( iButton & IN_ATTACK ) && ( iButton & IN_ATTACK2 ) ) {
			iButton = iButton & ~IN_ATTACK2;

			#if defined USE_FAKEMETA
			set_pev( iPlayer, pev_button, iButton );
			#else
			entity_set_int( iPlayer, EV_INT_button, iButton );
			#endif
			
			set_dhudmessage( 255, 0, 0, -1.0, 0.3, 0, 6.0, 3.0 );
			show_dhudmessage( iPlayer, "%L", LANG_PLAYER, "DUAL_ATTACK" );
			
			return FMRES_SUPERCEDE;
		}
	}

	return FMRES_IGNORED;
}

public client_infochanged( iPlayer ) {
	static szNewName[ 32 ], szOldName[ 32 ];
	
	get_user_name( iPlayer, szOldName, charsmax( szOldName ) );
	get_user_info( iPlayer, "name", szNewName, charsmax( szNewName ) );
	
	if( !equali( szNewName, szOldName ) ) {
		if( !g_iSettings[ CHECK_FASTNAME ] )
			return 1;
		
		g_iNamesChangesNumber[ iPlayer ] ++;
		
		if( g_iNamesChangesNumber[ iPlayer ] >= g_iSettings[ FAST_NAME_CHANING_NUMBER ] )
			PunishUser( iPlayer, "Fast Name Changing" );
		
		if( !task_exists( iPlayer ) )
			set_task( 4.0, "ClearChangesNum", iPlayer );
	}

	return 0;
}

public ClearChangesNum( iPlayer )
	g_iNamesChangesNumber[ iPlayer ] = 0;

public fw_FmTraceLine( Float: fStartPos[ 3 ], Float: fEndPos[ 3 ], iSkipMonsters, iPlayer, iTrace ) {
	if( !g_iSettings[ CHECK_AIMBOT ] )
		return FMRES_IGNORED;

	#if defined USE_BYM_API
	if( !IsPlayer->Alive( iPlayer ) )
		return FMRES_IGNORED;
	#else
	if( !is_user_alive( iPlayer ) )
		return FMRES_IGNORED;
	#endif
	
	if( g_iIgnoreAim[ iPlayer ] )
		return FMRES_IGNORED;
	
	static Float: fGameTime;
	fGameTime = get_gametime( );
	
	if( g_fNextAimCheck[ iPlayer ] < fGameTime ) {
		static iTarget, iHitGroup, iButton;

		iTarget = get_tr2( iTrace, TR_pHit );
		iHitGroup = ( 1 << get_tr2( iTrace, TR_iHitgroup ) );

		#if defined USE_FAKEMETA
		iButton = pev( iPlayer, pev_button );
		#else
		iButton = entity_get_int( iPlayer, EV_INT_button );
		#endif
		
		
		#if defined USE_BYM_API
		if( !IsPlayer->Alive( iTarget ) )
			return FMRES_IGNORED;
		#else
		if( !is_user_alive( iTarget ) )
			return FMRES_IGNORED;
		#endif
		
		if( get_pdata_int( iPlayer, FM_TEAM_OFFSET ) != get_pdata_int( iTarget, FM_TEAM_OFFSET ) ) {
			if( ( iHitGroup & FM_HITGROUP_HEAD ) && ( iButton != 0 ) )
				g_iDetections[ iPlayer ][ AIMBOT ] ++;

			else if( !( iHitGroup & FM_HITGROUP_HEAD ) || ( iButton <= 0 ) )
				g_iDetections[ iPlayer ][ AIMBOT ] = 0;
			
			if( g_iDetections[ iPlayer ][ AIMBOT ] > g_iSettings[ AIMBOT_WARNING_NUMBER ] ) {
				set_dhudmessage( 255, 0, 0, -1.0, 0.3, 0, 6.0, 3.0 );
				show_dhudmessage( iPlayer, "%L", LANG_PLAYER, "AIM_BOT" );			}

			if( g_iDetections[ iPlayer ][ AIMBOT ] > g_iSettings[ AIMBOT_PUNISH_NUMBER ] )
				PunishUser( iPlayer, "AIM BOT" );
			
			g_fNextAimCheck[ iPlayer ] = fGameTime + 0.5;
		}
	}

	return FMRES_IGNORED;
}

stock CountCheaters( ) {
	static szBaseDir[ 128 ], szFile[ 128 ];
	get_basedir( szBaseDir, charsmax( szBaseDir ) );
	
	formatex( szFile, charsmax( szFile ), "%s/configs/UltimateAntiCheat/NumberOfDetects.txt", szBaseDir );
	
	if( !file_exists( szFile ) )
		write_file( szFile, "; Ultimate Anticheat number of players detected.", -1 );
		
	static iLine, iLength, szBuffer[ 16 ];
	iLine = read_file( szFile, iLine, szBuffer, charsmax( szBuffer ), iLength );
	
	static iNumber;
	iNumber = str_to_num( szBuffer );
	
	iNumber ++;
	
	num_to_str( iNumber, szBuffer, charsmax( szBuffer ) );
	
	write_file( szFile, szBuffer, 0 );
}

stock SlapUser( iPlayer, Float: fDamage = 0.0 ) {
	#if defined USE_FAKEMETA
	static Float: fPunchangle[ 3 ];
	pev( iPlayer, pev_punchangle, fPunchangle );
	
	fPunchangle[ 0 ] += random_float( -8.0, 8.0 );
	fPunchangle[ 1 ] += random_float( -8.0, 8.0 );
	
	set_pev( iPlayer, pev_punchangle, fPunchangle );
	
	static Float: fVelocity[ 3 ];
	pev( iPlayer, pev_velocity, fVelocity );
	
	fVelocity[ 0 ] += random_num( 0, 1 ) ? 264.0 : -264.0;
	fVelocity[ 1 ] += random_num( 0, 1 ) ? 264.0 : -264.0;
	
	set_pev( iPlayer, pev_basevelocity, fVelocity );
	#else
	static Float: fPunchangle[ 3 ];
	entity_get_vector( iPlayer, EV_VEC_punchangle, fPunchangle );
	
	fPunchangle[ 0 ] += random_float( -8.0, 8.0 );
	fPunchangle[ 1 ] += random_float( -8.0, 8.0 );
	
	entity_set_vector( iPlayer, EV_VEC_punchangle, fPunchangle );
	
	static Float: fVelocity[ 3 ];
	entity_get_vector( iPlayer, EV_VEC_velocity, fVelocity );
	
	fVelocity[ 0 ] += random_num( 0, 1 ) ? 264.0 : -264.0;
	fVelocity[ 1 ] += random_num( 0, 1 ) ? 264.0 : -264.0;
	
	entity_set_vector( iPlayer, EV_VEC_basevelocity, fVelocity );
	#endif
	
	fm_fakedamage( iPlayer, "worldspawn", fDamage, 1 );
	
	return 1;
}

stock PunishUser( iPlayer, const szCheat[ ] ) {
	#if defined USE_BYM_API
	if( !IsPlayer->Connected( iPlayer ) )
		return;
	#else
	if( !is_user_connected( iPlayer ) )
		return;
	#endif
	
	if( g_iSettings[ IGNORE_ADMINS ] ) {
		if( access( iPlayer, ADMIN_IGNORE_FLAG ) ) {
			WriteToLog( iPlayer, 0, "", "" );
			return;
		}
	}
	
	if( !g_iIsDetected[ iPlayer ] ) {
		static szName[ 32 ], szSteamID[ 32 ], iUid;
		get_user_name( iPlayer, szName, charsmax( szName ) );
		get_user_authid( iPlayer, szSteamID, charsmax( szSteamID ) );
		iUid = get_user_userid( iPlayer );
		
		switch( g_iSettings[ PUNISH_TYPE ] ) {
			case 0: {	
				set_dhudmessage( 255, 0, 0, -1.0, 0.3, 0, 6.0, 3.0 );
				show_dhudmessage( iPlayer, "%L", LANG_PLAYER, "HACK_DETECT", szCheat );
				
				PrintToChat( 0, "%L", LANG_PLAYER, "ID_WITH_HACK", szName, szCheat );
			}
			case 1: {
				server_cmd( "kick #%d ^"%L^"", iUid, LANG_PLAYER, "HACK_DETECT", szCheat );
				
				PrintToChat( 0, "%L", LANG_PLAYER, "KICK_HAVE_CHEAT", szName, szCheat );
			} 
			case 2: {	    
				switch( g_iSettings[ BAN_TYPE ] ) {
					// STEAM ID
					case 0: {
						server_cmd( "kick #%d;wait;wait;wait;banid %d ^"%s^";wait;wait;wait;writeid", iUid, g_iSettings[ BAN_TIME ], szSteamID, szCheat );
						PrintToChat( 0, "%L", LANG_PLAYER, "BAN_MIN_CHEAT", szName, g_iSettings[ BAN_TIME ], szCheat );
					}
					
					// IP
					case 1: {
						static szIp[ 32 ];
						get_user_ip( iPlayer, szIp, charsmax( szIp ), 1 );
						
						server_cmd( "kick #%d;wait;wait;wait;addip %d ^"%s^";wait;wait;writeip", iUid, g_iSettings[ BAN_TIME ], szIp, szCheat );
						PrintToChat( 0, "%L", LANG_PLAYER, "BAN_MIN_CHEAT", szName, g_iSettings[ BAN_TIME ], szCheat );
					}
					
					// Ban Command
					case 2: {
						new szCommand[ 512 ];
						copy( szCommand, charsmax( szCommand ), g_szBanCommand );
		
						new szTime[ 32 ];
						num_to_str( g_iSettings[ BAN_TIME ], szTime, charsmax( szTime ) );
		
						replace_all( szCommand, charsmax( szCommand ), "[player]", szSteamID );
						replace_all( szCommand, charsmax( szCommand ), "[time]", szTime );
						
						new szReason[ 64 ];
						formatex( szReason, charsmax( szReason ), "Cheat Detected: %s", szCheat );
						replace_all( szCommand, charsmax( szCommand ), "[reason]", szReason );
		
						server_cmd( "%s", szCommand );
						PrintToChat( 0, "%L", LANG_PLAYER, "BAN_MIN_CHEAT", szName, g_iSettings[ BAN_TIME ], szCheat );
					}
				}
			}
		}
		
		CountCheaters( );
		WriteToLog( iPlayer, g_iSettings[ PUNISH_TYPE ], "", szCheat );
		
		g_iIsDetected[ iPlayer ] = true;
	}
}

stock CopyVector( Float: fVector1[ 3 ], Float: fVector2[ 3 ] ) {
	fVector2[ 0 ] = fVector1[ 0 ];
	fVector2[ 1 ] = fVector1[ 1 ];
	fVector2[ 2 ] = fVector1[ 2 ];
}

stock WriteToLog( iPlayer, _:iType, const szString[ ], const szCheat[ ] ) {
	if( !g_iSettings[ PLUGIN_LOG_ACTIONS ] )
		return;
	
	static szBaseDir[ 128 ], szLogsDir[ 128 ], szFile[ 128 ];
	get_basedir( szBaseDir, charsmax( szBaseDir ) );
	
	formatex( szLogsDir, charsmax( szLogsDir ), "%s/configs/UltimateAntiCheat/Logs", szBaseDir );
	formatex( szFile, charsmax( szFile ), "%s/UltimateAntiCheat.log", szLogsDir );
	
	if( !dir_exists( szLogsDir ) )
		mkdir( szLogsDir );
	
	if( !file_exists( szFile ) )
		write_file( szFile, "; Ultimate Anti Cheat Logs file.", -1 );
	
	static szName[ 32 ], szIp[ 32 ];
	
	if( iType != -1 ) {
		get_user_name( iPlayer, szName, charsmax( szName ) );
		get_user_ip( iPlayer, szIp, charsmax( szIp ), 1 );
	}
	
	switch( iType ) {
		case -1 : { log_to_file( szFile, "%s", szString ); }
		case 0 : { log_to_file( szFile, "%L", LANG_PLAYER, "LOG_F_1", szIp, szName, szCheat ); }
		case 1 : { log_to_file( szFile, "%L", LANG_PLAYER, "LOG_F_2", szIp, szName, szCheat ); }
		case 2 : { log_to_file( szFile, "%L", LANG_PLAYER, "LOG_F_3", szIp, szName, szCheat ); }
	}
}

stock bool: IsMaliciousIP( iPlayer ) {
	new szIP[ 32 ];
	get_user_ip( iPlayer, szIP, charsmax( szIP ), 1 );
	
	return bool: TrieKeyExists( g_tMaliciousIPs, szIP );
}

stock LoadMaliciousIPs( const szFile[ ] ) {
	if( g_tMaliciousIPs )
		TrieDestroy( g_tMaliciousIPs );

	g_tMaliciousIPs = TrieCreate( );

	new iFile = fopen( szFile, "rt" );
	
	if( !iFile )
		write_file( szFile, "", -1 );
	
	while( !feof( iFile ) ) {
		static szBuffer[ 64 ];
		fgets( iFile, szBuffer, charsmax( szBuffer ) );
		
		if( szBuffer[ 0 ] == EOS || szBuffer[ 0 ] == ';' || szBuffer[ 0 ] == '#' || ( szBuffer[ 0 ] == '/' && szBuffer[ 1 ] == '/' ) )
			continue;
		
		if( !TrieKeyExists( g_tMaliciousIPs, szBuffer ) )
			TrieSetString( g_tMaliciousIPs, szBuffer, szBuffer );
	}

	fclose( iFile );
}

stock bool: IsExcludedIP( iPlayer ) {
	new szIP[ 32 ];
	get_user_ip( iPlayer, szIP, charsmax( szIP ), 1 );
	
	return bool: TrieKeyExists( g_tExcludedIPs, szIP );
}

stock LoadExcludedIPs( const szFile[ ] ) {
	if( g_tExcludedIPs )
		TrieDestroy( g_tExcludedIPs );

	g_tExcludedIPs = TrieCreate( );

	new iFile = fopen( szFile, "rt" );
	
	if( !iFile )
		write_file( szFile, "", -1 );
	
	while( !feof( iFile ) ) {
		static szBuffer[ 64 ];
		fgets( iFile, szBuffer, charsmax( szBuffer ) );
		
		if( szBuffer[ 0 ] == EOS || szBuffer[ 0 ] == ';' || szBuffer[ 0 ] == '#' || ( szBuffer[ 0 ] == '/' && szBuffer[ 1 ] == '/' ) )
			continue;
		
		if( !TrieKeyExists( g_tExcludedIPs, szBuffer ) )
			TrieSetString( g_tExcludedIPs, szBuffer, szBuffer );
	}

	fclose( iFile );
}

stock PrintToChat( iPlayer, const szInput[ ], any:... ) {
	static szMessage[ 191 ];
	vformat( szMessage, charsmax( szMessage ), szInput, 3 );
	replace_all( szMessage, charsmax( szMessage ), "!g", "^4" );
	replace_all( szMessage, charsmax( szMessage ), "!t", "^3" );
	replace_all( szMessage, charsmax( szMessage ), "!r", "^2" );
	replace_all( szMessage, charsmax( szMessage ), "!n", "^1" );
     
	if( iPlayer == 0 ) {
		ForEachPlayer( iTarget ) {
			#if defined USE_BYM_API
			if( !IsPlayer->Connected( iTarget ) || IsPlayer->Bot( iTarget ) )
				return;
			#else
			if( !is_user_connected( iTarget ) || is_user_bot( iTarget ) )
				return;
			#endif
			
			message_begin( MSG_ONE_UNRELIABLE, g_iMessageChat, _, iTarget );
			write_byte( iTarget );
			write_string( szMessage );
			message_end( );
		}
	} else {
		#if defined USE_BYM_API
			if( !IsPlayer->Connected( iPlayer ) || IsPlayer->Bot( iPlayer ) )
				return;
			#else
			if( !is_user_connected( iPlayer ) || is_user_bot( iPlayer ) )
				return;
			#endif
		
		message_begin( MSG_ONE_UNRELIABLE, g_iMessageChat, _, iPlayer );
		write_byte( iPlayer );
		write_string( szMessage );
		message_end( );
	}
}

ExecuteCommand( iPlayer, const szCommand[ ], any:... ) {
	new szText[ 256 ];
	vformat( szText, charsmax( szText ), szCommand, 3 );
	
	message_begin( MSG_ONE, SVC_DIRECTOR, _, iPlayer );
	write_byte( strlen( szText ) + 2 );
	write_byte( 10 );
	write_string( szText );
	message_end( );
}

stock bool: IsSteamPlayer( iPlayer ) {
	new iDpPointer;
	
	if( iDpPointer || ( iDpPointer = get_cvar_pointer( "dp_r_id_provider" ) ) ) {
		server_cmd( "dp_clientinfo %d", iPlayer );
		server_exec( );
		return ( get_pcvar_num( iDpPointer ) == 2 ) ? true : false
	}
	
	return false
}

public plugin_natives( ) {
	register_native( "uac_set_ignore_aim", "NativeSetIgnoreAim", 1 );
	register_native( "uac_set_ignore_rapid", "NativeSetIgnoreRapid", 1 );
	register_native( "uac_set_ignore_norecoil", "NativeSetIgnoreNoRecoil", 1 );
	register_native( "uac_set_ignore_speedhack", "NativeSetIgnoreSpeed", 1 );
	register_native( "uac_set_ignore_shake", "NativeSetIgnoreShake", 1 );
}

public NativeSetIgnoreAim( iPlayer, iValue )
	g_iIgnoreAim[ iPlayer ] = iValue;
	
public NativeSetIgnoreRapid( iPlayer, iValue )
	g_iIgnoreRapid[ iPlayer ] = iValue;
	
public NativeSetIgnoreNoRecoil( iPlayer, iValue )
	g_iIgnoreNoRecoil[ iPlayer ] = iValue;
	
public NativeSetIgnoreSpeed( iPlayer, iValue )
	g_iIgnoreSpeedHack[ iPlayer ] = iValue;

public NativeSetIgnoreShake( iPlayer, iValue )
	g_iIgnoreShake[ iPlayer ] = iValue;

public plugin_end( ) {
	if( g_tMaliciousIPs )
		TrieDestroy( g_tMaliciousIPs );
		
	if( g_iCaptchaVault )
		nvault_close( g_iCaptchaVault );
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang10266\\ f0\\ fs16 \n\\ par }
*/
