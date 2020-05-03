#if defined _bym_api_included
  #endinput
#endif
#define _bym_api_included

#include < amxmodx >
#include < amxmisc >
#include < hamsandwich >

#define Struct 				enum
#define ByM::				__ByM__

#define GetBitVar(%1,%2)		( %1 & ( 1 << ( %2 & 31 ) ) )
#define SetBitVar(%1,%2)		( %1 |= ( 1 << ( %2 & 31 ) ) )
#define DelBitVar(%1,%2)		( %1 &= ~( 1 << ( %2 & 31 ) ) )

#define IsPlayer->%1(%2)		bool: ( GetBitVar( ByM::Tags[ ByM::%1 ], %2 ) && IsValidPlayer( %2 ) )
#define IsValidPlayer(%1)		bool: ( 1 <= %1 <= GetMaxPlayers( ) )
#define ForEachPlayer(%1)		for( new %1 = 1; %1 <= GetMaxPlayers( ); %1 ++ )
#define ForEachTag(%1)			for( new %1 = 0; %1 < _:ByM::StructTags; %1 ++ )
#define GetMaxPlayers()			( ByM::MaxPlayers )	

Struct ByM::StructTags {
	ByM::Alive,
	ByM::Connected,
	ByM::Bot,
	ByM::Vip,
	ByM::Admin,
	ByM::Hero
}

new ByM::Tags[ ByM::StructTags ];
new ByM::MaxPlayers;
new ByM::PluginName[ 64 ];
new bool: ByM::Init = false;

#pragma unused __ByM__MaxPlayers

stock ByM::Initialise( iPlugin ) {
	if( ByM::Init == true )
		return;

	get_plugin( iPlugin, _, _, ByM::PluginName, charsmax( ByM::PluginName ) );
		
	ByM::Init = true;
	ByM::MaxPlayers = get_maxplayers( );

	RegisterHam( Ham_Spawn, "player", "fw_BymPlayerSpawnPost", .Post = true );
	RegisterHam( Ham_Killed, "player", "fw_BymPlayerDeath" );

	server_print( "[ByM] API intialised for %s", ByM::PluginName );
}

public fw_BymPlayerSpawnPost( iPlayer ) {
	if( is_user_alive( iPlayer ) ) 
		SetBitVar( ByM::Tags[ ByM::Alive ], iPlayer );
}

public fw_BymPlayerDeath( iVictim, iAttacker, iSH ) {
	DelBitVar( ByM::Tags[ ByM::Alive ], iVictim );
}

stock ByM::PlayerConnected( iPlayer ) {
	if( !ByM::Init ) {
		new szText[ 256 ];
		formatex( szText, charsmax( szText ), "Error, API is not initialised :: Tryed to invoke ByM::PlayerConnected( iPlayer ) without initialisation of API" );
		log_to_file( "ByM_Api.txt", szText );
		return;
	}
	
	ByM::DeleteTags( iPlayer );
	
	if( is_user_connected( iPlayer ) )
		SetBitVar( ByM::Tags[ ByM::Connected ], iPlayer );
		
	if( is_user_bot( iPlayer ) )
		SetBitVar( ByM::Tags[ ByM::Bot ], iPlayer );
		
	if( is_user_admin( iPlayer ) )
		SetBitVar( ByM::Tags[ ByM::Admin ], iPlayer );
}

stock ByM::PlayerDisconnected( iPlayer ) {
	if( !ByM::Init ) {
		log_to_file( "ByM_Api.txt", "Error, API is not initialised :: Tryed to invoke ByM::PlayerDisconnected( iPlayer ) without initialisation of API" );
		return;
	}
	
	ByM::DeleteTags( iPlayer );
}

stock ByM::DeleteTags( iPlayer ) {
	ForEachTag( iTag ) {
		DelBitVar( ByM::Tags[ ByM::StructTags: iTag ], iPlayer );
	}
}

stock ByM::SetVip( iPlayer ) {
	SetBitVar( ByM::Tags[ ByM::Vip ], iPlayer );
}

stock ByM::DelVip( iPlayer ) {
	DelBitVar( ByM::Tags[ ByM::Vip ], iPlayer );
}

stock ByM::SetHero( iPlayer ) {
	SetBitVar( ByM::Tags[ ByM::Hero ], iPlayer );
}

stock ByM::DelHero( iPlayer ) {
	DelBitVar( ByM::Tags[ ByM::Hero ], iPlayer );
}

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang9242\\ f0\\ fs16 \n\\ par }
*/
