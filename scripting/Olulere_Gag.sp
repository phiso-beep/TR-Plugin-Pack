#include <sourcemod>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = 
{
	name = "Ölü oyuncuları gaglama", 
	author = "ByDexter", 
	description = "", 
	version = "1.0", 
	url = "https://steamcommunity.com/id/ByDexterTR - ByDexter#5494"
};

bool OluGag = false;

public void OnPluginStart()
{
	RegAdminCmd("sm_otogag", Command_Otogag, ADMFLAG_CHAT);
	AddCommandListener(Command_Say, "sm_say");
	AddCommandListener(Command_Say, "say");
	AddCommandListener(Command_Say, "say2");
	AddCommandListener(Command_Say, "say_team");
}

public Action Command_Say(int client, const char[] command, int argc)
{
	if (OluGag && !IsPlayerAlive(client))
	{
		PrintToChat(client, "[SM] \x01Sohbet ölü oyunculara \x07kapalı!");
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public Action Command_Otogag(int client, int args)
{
	if (!OluGag)
	{
		ReplyToCommand(client, "[SM] Ölü oyunculara sohbet kapatıldı!");
		OluGag = true;
		PrintToChatAll("[SM] \x10%N \x01tarafından ölülerin sohbeti \x07kapatıldı!", client);
	}
	else
	{
		ReplyToCommand(client, "[SM] Ölü oyunculara sohbet açıldı!");
		OluGag = false;
		PrintToChatAll("[SM] \x10%N \x01tarafından ölülerin sohbeti \x04açıldı!", client);
	}
} 