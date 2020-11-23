#include <sourcemod>
#include <store>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = 
{
	name = "Rastgele Kredi", 
	author = "ByDexter", 
	description = "", 
	version = "1.0", 
	url = "https://steamcommunity.com/id/ByDexterTR - ByDexter#5494"
};

ConVar g_KrediDegeri = null;

public void OnPluginStart()
{
	RegAdminCmd("sm_rastgelekredi", Command_RastgeleKredi, ADMFLAG_ROOT);
	
	g_KrediDegeri = CreateConVar("sm_rastgelekredi_odul", "1500", "Şanslı oyuncu kaç kredi kazansın?", FCVAR_NOTIFY, true, 1.0);
}

public Action Command_RastgeleKredi(int client, int args)
{
	int Kazanan = GetRandomPlayer();
	Store_SetClientCredits(Kazanan, Store_GetClientCredits(Kazanan) + g_KrediDegeri.IntValue);
	PrintToChatAll("[SM] \x10%N \x01adlı şanslı oyuncu \x04%d Kredi \x01kazandı!", Kazanan, g_KrediDegeri.IntValue);
}

stock int GetRandomPlayer()
{
	int[] clients = new int[MaxClients];
	int clientCount;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			clients[clientCount++] = i;
		}
	}
	return (clientCount == 0) ? -1 : clients[GetRandomInt(0, clientCount - 1)];
} 