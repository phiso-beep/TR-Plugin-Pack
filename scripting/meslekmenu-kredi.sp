 // ----- #include ----- //

#include <sourcemod>
#include <sdktools>
#include <store>

// ----- #pragma ----- //

#pragma semicolon 1
#pragma newdecls required

// ----- bool ----- //

bool Kullandi[MAXPLAYERS] = false;

// ----- Handle ----- //

Handle Flash_Timer[MAXPLAYERS] = null;

// ----- myinfo ----- //

public Plugin myinfo = 
{
	name = "Meslekmenu - Market", 
	author = "ByDexter", 
	description = "", 
	version = "1.0", 
	url = "https://steamcommunity.com/id/ByDexterTR - ByDexter#2947"
};

// ----- OnPluginStart ----- //

public void OnPluginStart()
{
	RegConsoleCmd("sm_meslekmenu", Meslek);
	RegConsoleCmd("sm_meslek", Meslek);
	HookEvent("round_start", RoundStart);
}

public Action Meslek(int client, int args)
{
	Menu menu = new Menu(Menu_CallBack);
	menu.SetTitle("[SM] Meslekmenu - Hangi meslek olmak istiyorsun?\n ");
	if (Store_GetClientCredits(client) >= 500 && !Kullandi[client])
	{
		menu.AddItem("Rambo", "Rambo: 150 Can - 500 Kredi");
		menu.AddItem("Flash", "FLash: 5 Saniye Hızlı Koşma - 500 Kredi");
		menu.AddItem("Bombaci", "Bombaci : 1 El bombasi ve 1 Molotof - 500 Kredi");
		menu.AddItem("Doktor", "Doktor: 2 Sağlık Aşısı - 500 Kredi");
	}
	else if (Store_GetClientCredits(client) < 500 || Kullandi[client])
	{
		menu.AddItem("Rambo", "Rambo: 150 Can - 500 Kredi", ITEMDRAW_DISABLED);
		menu.AddItem("Flash", "FLash: 5 Saniye Hızlı Koşma - 500 Kredi", ITEMDRAW_DISABLED);
		menu.AddItem("Bombaci", "Bombaci : 1 El bombasi ve 1 Molotof - 500 Kredi", ITEMDRAW_DISABLED);
		menu.AddItem("Doktor", "Doktor: 2 Sağlık Aşısı - 500 Kredi", ITEMDRAW_DISABLED);
	}
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Menu_CallBack(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char Item[32];
		menu.GetItem(param2, Item, sizeof(Item));
		if (StrEqual(Item, "Rambo", true))
		{
			PrintToChat(param1, "[SM] \x01Mesleğin değiştirildi: \x04Rambo");
			Store_SetClientCredits(param1, Store_GetClientCredits(param1) - 500);
			SetEntityHealth(param1, 150);
		}
		else if (StrEqual(Item, "Flash", true))
		{
			PrintToChat(param1, "[SM] \x01Mesleğin değiştirildi: \x04Flash");
			Store_SetClientCredits(param1, Store_GetClientCredits(param1) - 500);
			Flash_Timer[param1] = CreateTimer(5.0, FlashKapat, param1, TIMER_FLAG_NO_MAPCHANGE);
			SetEntPropFloat(param1, Prop_Data, "m_flLaggedMovementValue", 1.7);
		}
		else if (StrEqual(Item, "Bombaci", true))
		{
			PrintToChat(param1, "[SM] \x01Mesleğin değiştirildi: \x04Bombaci");
			Store_SetClientCredits(param1, Store_GetClientCredits(param1) - 500);
			GivePlayerItem(param1, "weapon_hegrenade");
			GivePlayerItem(param1, "weapon_molotov");
		}
		else if (StrEqual(Item, "Doktor", true))
		{
			PrintToChat(param1, "[SM] \x01Mesleğin değiştirildi: \x04Doktor");
			Store_SetClientCredits(param1, Store_GetClientCredits(param1) - 500);
			GivePlayerItem(param1, "weapon_healthshot");
			GivePlayerItem(param1, "weapon_healthshot");
		}
		Kullandi[param1] = true;
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
}

public Action FlashKapat(Handle timer, int client)
{
	Flash_Timer[client] = null;
	if (IsPlayerAlive(client))
	{
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
	}
	return Plugin_Stop;
}

public Action RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	for (int i = 1; i < MaxClients; i++)
	{
		if (IsClientInGame(i) && Kullandi[i])
		{
			Kullandi[i] = false;
			if (Flash_Timer[i] != null)
			{
				SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 1.0);
				Flash_Timer[i] = null;
			}
		}
	}
} 