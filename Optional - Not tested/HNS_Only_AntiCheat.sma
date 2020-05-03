#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <colorchat>

#define MIN_PERFECT get_pcvar_num(g_pCvar[0])
#define MIN_LASTJUMP 40
#define MIN_SCROLL 20
#define BAN_TIME get_pcvar_num(g_pCvar[1])

new g_iPerfectJumps[33];
static g_szAuthid[33][33];

static szLogFile[64];
static sz_Data[256];

new g_pCvar[3];

const TASKID_CHECK = 1337;

new const ScriptListName[] = "Script_Prefixes.ini";
new const CheatListName[] = "Cheat_Prefixes.ini";

/*#define m_afButtonPressed 246
#define m_afButtonReleased 247*/

new g_CheckCvar[][] =
{
"gl_vsync","fps_modem","fps_override","cl_sidespeed","sv_cheats","cl_pitchspeed",
"cl_forwardspeed","cl_backspeed","cl_yawspeed","developer","cl_filterstuffcmd"
};
new g_DefaultCvar[][] =
{
"gl_vsync 0","fps_modem 0","fps_override 0","cl_sidespeed 400",
"cl_forwardspeed 400","cl_backspeed 400","cl_yawspeed 210","developer 0","cl_pitchspeed 225"
};
new g_DefaultCmd[][] =
{
"fullupdate","lastinv","menuselect","vban","specmode","VModEnable","specmode","spec_set_ad",
"vmodenable","cl_setautobuy","cl_setrebuy","byu","buyequip","weapon_knife","weapon_flashbang",
"weapon_smokegrenade","buyammo1","buyammo2","showbriefing"
};

new TotalCvars;

new bool:isBanned[33];
new bool:isCommandsEnabled[33]

new Trie:BadCommands;
new Array:CheatCommands;

new Float:OldAngles[33][3];
new Float:FLastCmd[33],Float:fForwardMove[33],Float:fSideMove[33];

new WarMove[33],WarHLGuard[33],WarAngles[33],WarFps[33];
new UserFPS[33],Steps[33],NamesChangesNum[33],BadCommandsFile[1024],CheatCommandsFile[1024];

new g_Ban_Type, g_Max_Fps, g_Check_Cheat, g_Check_Helper, g_Check_HLGuard, g_Check_Fps, g_Check_Bhop, g_Check_Space, g_Check_Gstrafe, g_Check_Cvars, g_Check_Bad_Cmd, g_Check_ID_LAN, g_Fix_Bug_Nick, g_Min_Name_Length, g_Fast_Name_Change, g_Show_Console_Info;

public plugin_init()
{

register_plugin("HNS Anti-Cheat","15","Proffi");
register_clcmd("say /showconsole", "ClCmdShowKeys");
g_Ban_Type=register_cvar("Ban_Type", "1");
g_Max_Fps=register_cvar("Max_Fps", "111");
g_Check_Cheat=register_cvar("Check_Cheat", "1");
g_Check_Helper=register_cvar("Check_Helper", "1");
g_Check_HLGuard=register_cvar("Check_HLGuard", "1");
g_Check_Fps=register_cvar("Check_Fps", "1");
g_Check_Bhop=register_cvar("Check_Bhop", "1");
g_Check_Space=register_cvar("Check_Space", "1");
g_Check_Gstrafe=register_cvar("Check_Gstrafe", "1");
g_Check_Cvars=register_cvar("Check_Cvars", "1");
g_Check_Bad_Cmd=register_cvar("Check_Bad_Cmd", "1");
g_Check_ID_LAN=register_cvar("Check_ID_LAN", "1");
g_Fix_Bug_Nick=register_cvar("Fix_Bug_Nick", "1");
g_Min_Name_Length=register_cvar("Min_Name_Length", "3");
g_Fast_Name_Change=register_cvar("Fast_Name_Change", "1");
g_Show_Console_Info=register_cvar("Show_Console_Info", "1");

BadCommands = TrieCreate();
CheatCommands = ArrayCreate(32, 1);

g_pCvar[0] = register_cvar("ah_bhop_perfectcount", "6");
g_pCvar[1] = register_cvar("ah_bantime", "10080");
g_pCvar[2] = register_cvar("ah_testmode", "0");

register_forward(FM_CmdStart, "Player_CmdStart");
register_forward(FM_PlayerPreThink, "Player_PreThink");
register_forward(FM_PlayerPostThink, "Player_PostThink");
//register_forward(FM_CmdStart, "fwdCmdStart", 0);

RegisterHam(Ham_Spawn, "player", "Player_Spawn",1);
RegisterHam(Ham_Killed, "player", "Player_Spawn",1);

set_task(5.0, "Check_Cvar",0,"",0,"b");


}
public plugin_cfg()
{
if(get_pcvar_num(g_Check_Bhop))
{
get_localinfo("amxx_datadir", szLogFile, 63);
format(szLogFile, 63, "/%s/Hackers.txt", szLogFile);
if (!file_exists(szLogFile))
{
write_file(szLogFile, sz_Data);
}
}


static File[64];
get_configsdir(File, 63);
format(File, 63, "%s/Anti_Cheat.cfg", File);

if (!file_exists(File))
{
write_file(File, "Ban_Type ^"1^" //0-кик 1-amxban6^r")
write_file(File, "Max_Fps ^"111^" //максимально допустимое^r")
write_file(File, "Check_Cheat ^"1^" //проверка различных читов 1-да 0-нет^r")
write_file(File, "Check_Helper ^"1^" //проверка инвиз стрейфов 1-да 0-нет^r")
write_file(File, "Check_HLGuard ^"1^" //проверка на HL Protector/CSXGuard 1-да 0-нет^r")
write_file(File, "Check_Fps ^"1^" //проверка фпс 1-да 0-нет^r")
write_file(File, "Check_Bhop ^"1^" //проверка на бхоп хак 1-да 0-нет^r")
write_file(File, "Check_Space ^"1^" //проверка на нажатый пробел 1-да 0-нет^r")
write_file(File, "Check_Gstrafe ^"1^" //проверка на sgs/ddrun hack 1-да 0-нет^r")
write_file(File, "Check_Cvars ^"1^" //проверка на кансольные каманды 1-да 0-нет^r")
write_file(File, "Check_Bad_Cmd ^"1^" //проверка на скрипты 1-да 0-нет^r")
write_file(File, "Check_ID_LAN ^"1^" //кик STEAM_ID_LAN/VALVE_ID_LAN/HLTV 1-да 0-нет^r")
write_file(File, "Fix_Bug_Nick ^"1^" //запрещёные ники + или #^r")
write_file(File, "Min_Name_Length ^"3^" //проверка на короткий ник тоесть меньше 3 букв кик^r")
write_file(File, "Fast_Name_Change ^"1^" //проверка на быстрою смену ника 1-да 0-нет^r")
write_file(File, "Show_Console_Info ^"1^" //палит все что пишут в консоль^r^n")

write_file(File, "//если возникли вопросы пишите в skype/steam dangerous_proffi")

server_cmd("exec %s", File); server_exec();
}
else
{
server_cmd("exec %s", File); server_exec();
}

get_configsdir(BadCommandsFile, 1023);
formatex(BadCommandsFile, 1023, "%s/%s", BadCommandsFile, ScriptListName);

if(file_exists(BadCommandsFile))
{
new iFilePointer = fopen( BadCommandsFile, "r");
if(iFilePointer != 0)
{
new szData[128];
while(fgets(iFilePointer, szData, 127))
{
replace(szData, 127, "^n", "");
replace(szData, 127, "^t", "");
remove_quotes(szData);
trim(szData);
strtolower(szData);

TrieSetCell(BadCommands, szData, 1);
}
fclose(iFilePointer);
}
}

get_configsdir(CheatCommandsFile, 1023);
formatex(CheatCommandsFile, 1023, "%s/%s", CheatCommandsFile, CheatListName);

if(file_exists(CheatCommandsFile))
{
new iFilePointer = fopen(CheatCommandsFile, "r");
if(iFilePointer != 0)
{
new szData[128];
while(fgets(iFilePointer, szData, 127))
{
replace(szData, 127, "^n", "");
replace(szData, 127, "^t", "");
replace(szData, 127, "^r", "");
remove_quotes(szData);
trim(szData);

ArrayPushString(CheatCommands, szData);
}
fclose(iFilePointer);
TotalCvars = ArraySize(CheatCommands);
}
}
return PLUGIN_CONTINUE;
}
public client_connect(id) {for(new i = 0; i < sizeof(g_DefaultCvar); i++) console_cmd(id,"%s",g_DefaultCvar[i]);}
public client_putinserver(id)
{
if(get_pcvar_num(g_Check_Bhop) && is_user_alive(id) && !isBanned[id])
{
g_iPerfectJumps[id] = 0;
get_user_authid(id,g_szAuthid[id],32);
/*
new szAuthid[33];
get_user_authid(id, szAuthid, 32);
if( szAuthid[ 6 ] == 'I' )
{
server_cmd( "kick #%d ^"Bad SteamID^"", get_user_userid( id ) );
}
g_szAuthid[id] = szAuthid;*/
}


static NewName[32],szAuthid[32];
get_user_authid(id,szAuthid,charsmax(szAuthid));
get_user_info(id,"name",NewName,charsmax(NewName));

if(get_pcvar_num(g_Fix_Bug_Nick) && (NewName[0] == '+' || NewName[0] == '#'))
set_user_info(id,"name",NewName[1]);

else if(strlen(NewName) < get_pcvar_num(g_Min_Name_Length))
server_cmd("kick #%d ^"Your nickname is too short!^"",get_user_userid(id));

if(get_pcvar_num(g_Check_ID_LAN) && equali(szAuthid,"STEAM_ID_LAN")
|| equali(szAuthid,"VALVE_ID_LAN") || equali(szAuthid,"HLTV"))
server_cmd("kick #%d ^"%s Prohibited!^"",get_user_userid(id),szAuthid);

isBanned[id] = false;

isCommandsEnabled[id] = true;
Steps[id] = 0;
WarMove[id] = 0;
WarAngles[id] = 0;
WarHLGuard[id] = 0;
NamesChangesNum[id] = 0;

if(get_pcvar_num(g_Check_HLGuard)) set_task(3.0, "Check_Protector", id);
if(get_pcvar_num(g_Check_Cheat)) set_task(5.0, "Check_Cheat",id,"",0,"b");


set_task(1.0, "query_client", id)
}

public query_client(id)
{
query_client_cvar(id, "cl_filterstuffcmd", "cvar_result_pitch")
query_client_cvar(id, "fps_override", "cvar_result_pitch")
}

public cvar_result_pitch(id, const cvar[ ], const value[ ])
{
if( value[0] != 'B' ) {
console_cmd(id,"fps_max 99.5")
}
else
{
console_cmd(id,"fps_max 101")
}
}


public client_disconnect(id)
{
isBanned[id] = false;

WarMove[id] = 0;
WarAngles[id] = 0;
WarHLGuard[id] = 0;
NamesChangesNum[id] = 0;

if(task_exists(id)) remove_task(id);

if(get_pcvar_num(g_Check_Bhop) && is_user_alive(id) && !isBanned[id])
{
g_iPerfectJumps[id] = 0;
g_szAuthid[id] = "";
}
}

public fwdCmdStart(id, uc_handle, seed)
{
if(get_pcvar_num(g_Check_Bhop) && is_user_alive(id) && is_user_connected(id))
{
static iButtons, s_iOldButtons[33], s_iFrameCounter[33], s_iScrollCounter[33];
iButtons = get_uc(uc_handle, UC_Buttons);

if(s_iOldButtons[id] & IN_JUMP && !(iButtons & IN_JUMP))
s_iFrameCounter[id] = 0;
else if(iButtons & IN_JUMP && !(s_iOldButtons[id] & IN_JUMP) && 1 <= s_iFrameCounter[id] && s_iFrameCounter[id] <= 5)
s_iScrollCounter[id]++;

set_uc(uc_handle, UC_ForwardMove, 0);
if(s_iScrollCounter[id] >= MIN_SCROLL)
{
s_iScrollCounter[id] = 0;

new szName[33];
get_user_name(id, szName, 32);
get_user_authid(id,g_szAuthid[id],32);

ColorChat(0, GREEN, "^x03^x01 Bhop hack detected on^x03 %s^x01!", szName);
ColorChat(0, GREEN, "^x03 Reason: +jump loop (possible kzh_loopx command)." );
loghacker(id, szName, "+jump loop");

if(!get_pcvar_num(g_pCvar[2]))
{
//server_cmd( "kick #%d ^"+jump loop^"; wait; banid %d %s; wait; writeid", get_user_userid( id ), BAN_TIME, g_szAuthid );
server_cmd("amx_ban %i ^"%s^" ^"Bhop Hack Detected^"", BAN_TIME, g_szAuthid[id] );
//client_cmd( id, "disconnect" );
}
}

if(s_iFrameCounter[id] >= 6) s_iScrollCounter[id] = 0;

s_iOldButtons[id] = iButtons;
s_iFrameCounter[id]++;
}
}

loghacker(id, const szName[], const szReason[])
{
new szAuthid[33];
get_user_authid(id, szAuthid, 32);
new szTime[17];
get_time("%y/%m/%d/%H:%M",szTime,16);
formatex(sz_Data, 255, "[%s] Name: ^"%s^" STEAMID: ^"%s^" Reason: ^"%s^"", szTime, szName, g_szAuthid[id], szReason);
write_file(szLogFile, sz_Data);
}

public Player_Spawn(id)
{
WarMove[id] = 0;
WarAngles[id] = 0;
WarHLGuard[id] = 0;
//if(get_pcvar_num(g_Check_HLGuard) && is_user_alive(id)) Check_Protector(id);

return HAM_IGNORED;
}
public Check_Protector(id)
{
if(is_user_connected(id) || !is_user_bot(id) || !is_user_hltv(id))
{
set_task(1.0, "CheckButton", id);
console_cmd(id,"+jump;+moveright;+moveleft;+forward;+back");
}
}
public Check_Cvar()
{
if(get_pcvar_num(g_Check_Cvars))
{
static players[32],num,id;
get_players(players, num, "h");
for(new i = 0; i < num; i++)
{
id = players[i];
for(new i = 0; i < sizeof(g_CheckCvar); i++)
query_client_cvar(id,g_CheckCvar[i],"Cvars");
consol_check(id);
}
}
}
public Check_Cheat(id)
{
if(is_user_connected(id))
{
new first = 30 * Steps[id], last = first + 30;
if(last >= TotalCvars)
{
last = TotalCvars;
remove_task(id);
}
new szString[128];
for(new i = first; i < last; i++)
{
ArrayGetString(CheatCommands, i, szString, 127);
formatex(szString, 127, "%s", szString);
query_client_cvar(id, szString, "kzh");
}
Steps[id]++;
}
}
public kzh(id, const Cvar[], const Value[])
{
if(is_user_connected(id) && Value[0] != 'B' && !isBanned[id])
{
new szName[32],szIP[32];
get_user_name(id, szName, charsmax(szName));
get_user_ip(id, szIP, charsmax(szIP));

user_kill(id,1);
isBanned[id] = true;
switch(get_pcvar_num(g_Ban_Type))
{
case 0: server_cmd("kick #%d ^"Cheat Commands [%s] Detected^"",get_user_userid(id),Cvar);
case 1: server_cmd("amx_ban 0 %s ^"Cheat Commands [%s] Detected^"",szIP,Cvar);
}
ColorChat(0,NORMAL,"[^3Anti-Cheat^1]Player ^4%s ^1uses ^4Hack Commands ^1[^4%s^1]",szName,Cvar);
}
return PLUGIN_HANDLED;
}
public Player_CmdStart(id, uc_handle)
{
if(get_pcvar_num(g_Check_Fps) && is_user_alive(id))
UserFPS[id] = floatround(1/(get_uc(uc_handle, UC_Msec) * 0.001));

if(get_pcvar_num(g_Check_Helper) && is_user_alive(id))
{
get_uc(uc_handle, UC_SideMove, fSideMove[id]);
get_uc(uc_handle, UC_ForwardMove, fForwardMove[id]);
}
return FMRES_IGNORED;
}
public Player_PostThink(id)
{
if(get_pcvar_num(g_Check_Fps) && is_user_alive(id) && !isBanned[id])
{
if(UserFPS[id] > get_pcvar_num(g_Max_Fps)
|| UserFPS[id] <= 0 && !(pev(id,pev_flags) & FL_FROZEN))
{
if(++WarFps[id] >= 3)
{
static szName[32],szIP[32];
get_user_name(id, szName, charsmax(szName));
get_user_ip(id, szIP, charsmax(szIP));

WarFps[id] = 0;
user_kill(id,1);
isBanned[id] = true;
switch(get_pcvar_num(g_Ban_Type))
{
case 0: server_cmd("kick #%d ^"%d FPS Detected^"",get_user_userid(id),UserFPS[id])
case 1: server_cmd("amx_ban 10080 %s ^"%d FPS Detected^"",szIP,UserFPS[id]);
}
ColorChat(0,NORMAL,"[^3Anti-Cheat^1]Player ^4%s ^1uses ^1[^4%d FPS^1]",szName,UserFPS[id]);
}
}
else WarFps[id] = 0;
}
if(get_pcvar_num(g_Check_Helper) && is_user_alive(id) && !isBanned[id])
{
new Float:fSpeed[3]; pev(id, pev_velocity, fSpeed); fSpeed[2] = 0.0;
new Float:fValue = floatsqroot(fForwardMove[id] * fForwardMove[id] + fSideMove[id] * fSideMove[id]);
new Float:vAngles[3]; pev(id,pev_angles,vAngles);

new Float:maxspeed; pev(id,pev_maxspeed,maxspeed);
if(vector_length(fSpeed) > 270.0 && (fValue > maxspeed||(0<floatabs(fForwardMove[id]) < 50.0))&&floatabs(vAngles[1] - OldAngles[id][1]) > 0.0 )
{
pev(id, pev_velocity, fSpeed);
fSpeed[0] *= 0.3; fSpeed[1] *= 0.3;
set_pev(id, pev_velocity, fSpeed);

if(++WarMove[id] >= 16)
{
new szName[32],szIP[32];
get_user_name(id, szName, charsmax(szName));
get_user_ip(id, szIP, charsmax(szIP));

user_kill(id,1);
WarMove[id] = 0;
isBanned[id] = true;
switch(get_pcvar_num(g_Ban_Type))
{
case 0: server_cmd("kick #%d ^"Strafe Helper Detected^"",get_user_userid(id));
case 1: server_cmd("amx_ban 0 %s ^"Strafe Helper Detected^"",szIP);
}
ColorChat(0,NORMAL,"[^3Anti-Cheat^1]Player ^4%s ^1uses ^1[^4Strafe Helper^1]",szName);
}
}
}
}
public Player_PreThink(id)
{
if(get_pcvar_num(g_Check_Gstrafe) && is_user_alive(id) && !isBanned[id])
{
static Buttons;Buttons = pev(id, pev_button);
static OldButtons;OldButtons = pev(id, pev_oldbuttons);

static OldDuckCount[33],OldJumpCount[33],OldGroundFrame[33];
static WarDuck[33],DuckCount[33],JumpCount[33],GroundFrame[33];
static Float:Speed[3];pev(id,pev_velocity,Speed); Speed[2] = 0.0;

if(Buttons & IN_JUMP && !(OldButtons & IN_JUMP)) JumpCount[id]++;
if(Buttons & IN_DUCK && !(OldButtons & IN_DUCK)) DuckCount[id]++;

if(pev(id, pev_flags) & FL_ONGROUND) GroundFrame[id]++;

else if(DuckCount[id] && GroundFrame[id]
&& !IsUserSurfing(id) && vector_length(Speed) > 250.0)
{
if(DuckCount[id] && GroundFrame[id] && JumpCount[id] == OldJumpCount[id]
&& DuckCount[id] == OldDuckCount[id] && GroundFrame[id] == OldGroundFrame[id])
{
if(++WarDuck[id] >= 9)
{
new szName[32],szIP[32];
get_user_name(id,szName,charsmax(szName));
get_user_ip(id,szIP,charsmax(szIP));

user_kill(id,1);
WarDuck[id] = 0;
isBanned[id] = true;
switch(get_pcvar_num(g_Ban_Type))
{
case 0: server_cmd("kick #%d ^"Gstrafe Hack Detected^"",get_user_userid(id));
case 1: server_cmd("amx_ban 0 %s ^"Gstrafe Hack Detected^"",szIP);
}
ColorChat(0,NORMAL,"[^3Anti-Cheat^1]Player ^4%s ^1uses ^1[^4Gstrafe Hack^1]",szName);
}
}
else
WarDuck[id] = 0;
OldJumpCount[id] = JumpCount[id];
OldDuckCount[id] = DuckCount[id];
OldGroundFrame[id] = GroundFrame[id];
DuckCount[id] = 0; JumpCount[id] = 0; GroundFrame[id] = 0;
}
if(!DuckCount[id] && !GroundFrame[id] && IsUserSurfing(id) || vector_length(Speed) <= 250.0) WarDuck[id] = 0;
}

if(get_pcvar_num(g_Check_Bhop) && is_user_alive(id) && is_user_connected(id))
{
static s_iOldFlags[33], s_iLastJump[33], bool:s_bCheckNextFrame[33], iButton, iOldButtons, iFlags;

iButton = pev(id, pev_button);
iOldButtons = pev(id, pev_oldbuttons);
iFlags = pev(id, pev_flags);

if(s_bCheckNextFrame[id] && !(iButton & IN_JUMP))
{
g_iPerfectJumps[id]++;
s_bCheckNextFrame[id] = false;
}

if(!(s_iOldFlags[id] & FL_ONGROUND) && iFlags & FL_ONGROUND && iButton & IN_JUMP && !(iOldButtons & IN_JUMP) && s_iLastJump[id] > MIN_LASTJUMP)
s_bCheckNextFrame[id] = true;
else if(s_iOldFlags[id] & FL_ONGROUND && iFlags & FL_ONGROUND && g_iPerfectJumps[id] > 0)
g_iPerfectJumps[id] = 0;

if(g_iPerfectJumps[id] >= MIN_PERFECT)
{
new szName[33];
get_user_name(id, szName, 32);
new g_szAuthid[32];
get_user_authid(id,g_szAuthid[id],31);

//client_print(0, print_chat, "[ID-Game.net] Bhop hack detected on %s! Reason: %i perfect jumps in a row.", szName, g_iPerfectJumps[id]);

ColorChat(0, GREEN, "^x03^x01 Bhop hack detected on^x03 %s^x01! STEAMID: %s", szName, g_szAuthid[id]);
ColorChat(0, GREEN, "^x03 Reason:^x04 %i^x03 perfect jumps in a row.", g_iPerfectJumps[id]);
loghacker(id, szName, "Bhop Hack");

g_iPerfectJumps[id] = 0;
if(!get_pcvar_num(g_pCvar[2]))
{
new szAuthid[33];
get_user_authid(id, szAuthid, 32);
//server_cmd( "kick #%d ^"Bhop Hack^"; wait; banid %d %s; wait; writeid", get_user_userid( id ), BAN_TIME, g_szAuthid[id] );
server_cmd("amx_ban %i ^"%s^" ^"Bhop Hack Detected^"", BAN_TIME, g_szAuthid[id] );
//client_cmd( id, "disconnect" );
}
}

if(iOldButtons & IN_JUMP && !(iButton & IN_JUMP))
s_iLastJump[id] = 1;
else if(!(iOldButtons & IN_JUMP) && !(iButton & IN_JUMP))
s_iLastJump[id]++;

s_iOldFlags[id] = iFlags;
}

if(get_pcvar_num(g_Check_Space) && is_user_alive(id) && !isBanned[id])
{
new szName[32],szIP[32];
get_user_name(id, szName, charsmax(szName));
get_user_ip(id, szIP, charsmax(szIP));

static FrameCounter[33],WarSpace[33],GroundFrame[33];
static Buttons;Buttons = pev(id, pev_button);
static OldButtons;OldButtons = pev(id, pev_oldbuttons);

if(pev(id, pev_flags) & FL_ONGROUND) GroundFrame[id]++;
else if(GroundFrame[id])
{
static Float:LastJump[33];
if(get_gametime() - LastJump[id] <= 0.3) WarSpace[id] = 0;
LastJump[id] = get_gametime();
GroundFrame[id] = 0;
}
if(OldButtons & IN_JUMP && !(Buttons & IN_JUMP)) FrameCounter[id] = 0;
else if(Buttons & IN_JUMP && !(OldButtons & IN_JUMP) && 1 <= FrameCounter[id] && FrameCounter[id] <= 5)
{
if(++WarSpace[id] >= 66)
{
user_kill(id,1);
WarSpace[id] = 0;
isBanned[id] = true;
server_cmd("amx_ban 10080 %s ^"Holding Space Detected^"",szIP);
ColorChat(0,NORMAL,"[^3Anti-Cheat^1]Player ^4%s ^1is ^1[^4Holding Space^1]",szName);
}
}
if(FrameCounter[id] >= 6) WarSpace[id] = 0;
FrameCounter[id]++;
}
return FMRES_IGNORED;
}
public CheckButton(id)
{
if(is_user_connected(id))
{
new button = pev(id, pev_button);

if(~button & IN_FORWARD
|| ~button & IN_JUMP || ~button & IN_BACK
|| ~button & IN_MOVELEFT || ~button & IN_MOVERIGHT)
{
new szName[32];get_user_name(id, szName, charsmax(szName));
server_cmd("kick #%d ^"HL Guard Detected^"",get_user_userid(id));
ColorChat(0,NORMAL,"[^3Anti-Cheat^1]Player ^4%s ^1uses ^1[^4HL Guard^1]",szName);
}
console_cmd(id,"-jump;-moveright;-moveleft;-forward;-back");
}
}
public Cvars(id,const szVar[],const szValue[])
{
if(is_user_connected(id) && !isBanned[id])
{
new szName[32],szIP[32];
get_user_name(id, szName, charsmax(szName));
get_user_ip(id, szIP, charsmax(szIP));

if(equal(szVar, "cl_forwardspeed") && str_to_float(szValue) != 400
|| equal(szVar, "cl_sidespeed") && str_to_float(szValue) != 400
|| equal(szVar, "cl_backspeed") && str_to_float(szValue) != 400
|| equal(szVar, "cl_yawspeed") && str_to_float(szValue) != 210
|| equal(szVar, "cl_pitchspeed") && str_to_float(szValue) != 225
|| equal(szVar, "developer") && str_to_float(szValue) != 0)
{
user_kill(id,1);
isBanned[id] = true;
switch(get_pcvar_num(g_Ban_Type))
{
case 0: server_cmd("kick #%d ^"%s %s Detected^"",get_user_userid(id),szVar,szValue);
case 1: server_cmd("amx_ban 10080 %s ^"%s %s Detected^"",szIP,szVar,szValue);
}
ColorChat(0,NORMAL,"[^3Anti-Cheat^1]Player ^4%s ^1uses ^1[^4%s %s^1]",szName,szVar,szValue);
}
if(equal(szVar, "cl_filterstuffcmd") && str_to_float(szValue) != 0
|| equal(szVar, "fps_override") && str_to_float(szValue) != 0
|| equal(szVar, "fps_modem") && str_to_float(szValue) != 0
|| equal(szVar, "sv_cheats") && str_to_float(szValue) != 0
|| equal(szVar, "gl_vsync") && str_to_float(szValue) != 0)
{
server_cmd("kick #%d ^"Please type in your console%s 0^"", get_user_userid(id),szVar)
ColorChat(0,NORMAL,"[^3Anti-Cheat^1]Player ^4%s ^1uses ^1[^4%s %s^1]",szName,szVar,szValue);
}

}
}


public consol_check(id)
{
query_client_cvar(id, "cl_filterstuffcmd", "client_fps")
query_client_cvar(id, "fps_override", "client_fps")
}

public client_fps(id, const cvar[ ], const value[ ])
{
if( value[0] != 'B' ) {
query_client_cvar(id, "fps_max", "fps_maxfix_new_cs")
}
else
{
query_client_cvar(id, "fps_max", "fps_maxfix_old_cs")
}

}

public fps_maxfix_new_cs(id, const szVar[],const szValue[])
{
new szName[32]
get_user_name(id, szName, charsmax(szName));
if(equal(szVar, "fps_max") && (str_to_float(szValue) < 61 || str_to_float(szValue) > 99.5))
{
server_cmd("kick #%d ^"Please type to your console: fps_max 99.5^"", get_user_userid(id))
ColorChat(0,NORMAL,"[^3Anti-Cheat^1]Player ^4%s ^1uses ^1[^4%s %s^1]",szName,szVar,szValue);
}
}

public fps_maxfix_old_cs(id, const szVar[], const szValue[])
{
new szName[32]
get_user_name(id, szName, charsmax(szName));
if(equal(szVar, "fps_max") && (str_to_float(szValue) < 61 || str_to_float(szValue) > 101))
{
server_cmd("kick #%d ^"Please type in your console: fps_max 101^"", get_user_userid(id))
ColorChat(0,NORMAL,"[^3Anti-Cheat^1]Player ^4%s ^1uses ^1[^4%s %s^1]",szName,szVar,szValue);
}
}

public client_infochanged(id)
{
new NewName[32],szName[32],szIP[32];
get_user_ip(id, szIP, charsmax(szIP));
get_user_name(id, szName, charsmax(szName));
get_user_info(id, "name",NewName,charsmax(NewName));

if(get_pcvar_num(g_Fast_Name_Change) && is_user_connected(id) && !isBanned[id])
{
if(!equali(szName, NewName))
{
if(++NamesChangesNum[id] >= 3)
{
user_kill(id,1);
isBanned[id] = true;
NamesChangesNum[id] = 0;
switch(get_pcvar_num(g_Ban_Type))
{
case 0: server_cmd("kick #%d ^"Fast Name Change Detected^"",get_user_userid(id))
case 1: server_cmd("amx_ban 10080 %s ^"Fast Name Change Detected^"",szIP);
}
ColorChat(0,NORMAL,"[^3Anti-Cheat^1]Player ^4%s ^1uses ^1[^4Fast Name Change^1]",szName);
}
static Float:Gametime;Gametime = get_gametime();
if(Gametime > (FLastCmd[id] + 5.0))
{
NamesChangesNum[id] = 0;
FLastCmd[id] = Gametime;
}
}
}
if(get_pcvar_num(g_Fix_Bug_Nick) && (NewName[0] == '+' || NewName[0] == '#'))
set_user_info(id,"name",NewName[1]);

else if(strlen(NewName) < get_pcvar_num(g_Min_Name_Length))
server_cmd("kick #%d ^"Your nickname is too short!^"",get_user_userid(id));
}
public client_command(id)
{
static Float:Last_Cmd[33];
if(Last_Cmd[id] == get_gametime())
{
Last_Cmd[id] = get_gametime();
return PLUGIN_HANDLED;
}
Last_Cmd[id] = get_gametime();

static sArgv[64],sArgv1[64];
read_argv(0, sArgv, 63);
read_args(sArgv1, charsmax(sArgv1));
remove_quotes(sArgv); trim(sArgv);

new szName[32],szIP[32],players[32],pnum;
get_players(players, pnum, "ch");
get_user_ip(id, szIP, charsmax(szIP));
get_user_name(id, szName, charsmax(szName));

if(get_pcvar_num(g_Check_Bad_Cmd) && is_user_connected(id) && !isBanned[id])
{
if(strlen(sArgv) == 0) return PLUGIN_HANDLED;
else if(TrieKeyExists(BadCommands, sArgv))
{
user_kill(id,1);
isBanned[id] = true;
server_cmd("amx_ban 10080 %s ^"Bad Commands [%s] Detected^"",szIP,sArgv);
ColorChat(0,NORMAL,"[^3Anti-Cheat^1]Player ^4%s ^1uses ^4Bad Commands ^1[^4%s^1]",szName,sArgv); return PLUGIN_HANDLED;
}
}
if(get_pcvar_num(g_Show_Console_Info) && is_user_connected(id))
{
for(new i = 0; i < sizeof(g_DefaultCmd); i++)
{
if(equal(g_DefaultCmd[i],sArgv))
{
return PLUGIN_CONTINUE;
}
}
static Float:FLastMsg[33],Float:Gametime;Gametime = get_gametime();
if(Gametime > (FLastMsg[id] + 1.5))
{
for(new i = 0; i < pnum; i++)
{
if(get_user_flags(players[i]) & ADMIN_BAN)
{
if(isCommandsEnabled[players[i]] == true)
{
ColorChat(players[i],NORMAL,"[^3Anti-Cheat^1]Player ^4%s ^1registered in console ^1[^4%s %s^1]",szName,sArgv,sArgv1);
}
}
}
FLastMsg[id] = Gametime;
}
}
return PLUGIN_CONTINUE;
}

public ClCmdShowKeys(id)
{
if((get_user_flags(id) & ADMIN_BAN) && isCommandsEnabled[id])
{
isCommandsEnabled[id] = false;
ColorChat(0,GREEN, "^3Message from players are disabled!");
return PLUGIN_HANDLED;
}
else
{
isCommandsEnabled[id] = true;
ColorChat(0,GREEN, "^3Message from players are enabled!");
return PLUGIN_HANDLED
}
return PLUGIN_CONTINUE
}

IsUserSurfing(id)
{
if(is_user_alive(id))
{
new Flags;Flags = pev(id, pev_flags);
if(Flags & FL_ONGROUND) return 0;

new Float:origin[3], Float:dest[3];
pev(id, pev_origin, origin)

dest[0] = origin[0];
dest[1] = origin[1];
dest[2] = origin[2] - 1.0;

new ptr = create_tr2();
engfunc(EngFunc_TraceHull, origin, dest, 0, Flags & FL_DUCKING ? HULL_HEAD : HULL_HUMAN, id, ptr);
new Float:flFraction;
get_tr2(ptr, TR_flFraction, flFraction);
if(flFraction >= 1.0)
{
free_tr2(ptr);
return 0;
}

get_tr2(ptr, TR_vecPlaneNormal, dest);
free_tr2(ptr);

return dest[2] <= 0.7;
}
return 0;
}

stock super_cmd(const id, const szCmd[])
{
message_begin(MSG_ONE, SVC_DIRECTOR, _, id)
write_byte(strlen(szCmd) + 2)// command length in bytes
write_byte(10)
write_string(szCmd) // banner file
message_end()
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang9242\\ f0\\ fs16 \n\\ par }
*/
