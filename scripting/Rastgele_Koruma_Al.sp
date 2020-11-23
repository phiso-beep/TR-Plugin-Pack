#include <sourcemod>
#include <cstrike>
#include <warden>

#pragma semicolon 1
#pragma newdecls required

int Koruma = -1;

public Plugin myinfo =
{
	name = "Koruma Çekiliş", 
	author = "ByDexter", 
	description = "", 
	version = "1.0", 
	url = "https://steamcommunity.com/id/ByDexterTR - ByDexter#5494"
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_korumacek", Command_Korumacek);
}

public Action Command_Korumacek(int client, int args)
{
	if (warden_iswarden(client))
	{
		Koruma = GetRandomPlayer(CS_TEAM_T, false);
		char Name[MAX_NAME_LENGTH];
		GetClientName(Koruma, Name, sizeof(Name));
		PrintToChatAll("[SM] \x01Çıkan şanslı isim: \x10%s", Name);
		Menu menu = new Menu(Menu_Callback);
		menu.SetTitle("%s -> Koruma olmasını istiyor musun?\n ", Name);
		menu.AddItem("0", "-> Evet <-");
		menu.AddItem("1", "-> Hayır <-");
		menu.ExitBackButton = false;
		menu.ExitButton = false;
		return Plugin_Handled;
	}
	else
	{
		ReplyToCommand(client, "[SM] Bu komutu sadece komutçu kullanabilir!");
		return Plugin_Handled;
	}
}
public int Menu_Callback(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char Item[32];
		menu.GetItem(param2, Item, sizeof(Item));
		char Name[MAX_NAME_LENGTH];
		GetClientName(Koruma, Name, sizeof(Name));
		if (StrEqual(Item, "0", true))
		{
			ChangeClientTeam(Koruma, CS_TEAM_CT);
			PrintToChatAll("[SM] \x10Komutçu \x01tarafından \x10%N \x01CT kabul edildi!", Koruma);
			Koruma = -1;
		}
		else if (StrEqual(Item, "1", true))
		{
			PrintToChatAll("[SM] \x10Komutçu \x01tarafından \x10%N \x01CT kabul edilmedi!", Koruma);
			Koruma = -1;
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
}
stock int GetRandomPlayer(int team = -1, bool OnlyAlive = true)
{
	int[] clients = new int[MaxClients];
	int clientCount;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && (team == -1 || GetClientTeam(i) == team) && (!OnlyAlive || !IsPlayerAlive(i)))
		{
			clients[clientCount++] = i;
		}
	}
	return (clientCount == 0) ? -1 : clients[GetRandomInt(0, clientCount - 1)];
} 