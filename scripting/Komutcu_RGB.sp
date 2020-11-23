#include <sourcemod>
#include <warden>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = 
{
	name = "Komutçu RGB", 
	author = "ByDexter", 
	description = "", 
	version = "1.0", 
	url = "https://steamcommunity.com/id/ByDexterTR - ByDexter#5494"
};

Handle g_WardenTimer[MAXPLAYERS] = null;

public void OnPluginStart()
{
	HookEvent("player_spawn", OnClientSpawn);
}

public Action OnClientSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (warden_iswarden(client))
	{
		if (g_WardenTimer[client] != null)
		{
			delete g_WardenTimer[client];
			g_WardenTimer[client] = null;
		}
		g_WardenTimer[client] = CreateTimer(0.1, ChangeColor, client, TIMER_REPEAT);
	}
}

public Action ChangeColor(Handle timer, int client)
{
	if (IsPlayerAlive(client))
	{
		SetEntityRenderColor(client, GetRandomInt(1, 255), GetRandomInt(1, 255), GetRandomInt(1, 255), 255);
		return Plugin_Continue;
	}
	else
	{
		g_WardenTimer[client] = null;
		return Plugin_Stop;
	}
} 