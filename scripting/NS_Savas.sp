#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <warden>

#pragma semicolon 1
#pragma newdecls required

ConVar Test = null;
int Verileceksilah = -1;
int GeriSay = -1;
Handle g_gerisaytimer = null;
bool Block_scope = false;

public Plugin myinfo = 
{
	name = "NoScope Savaşı", 
	author = "ByDexter", 
	description = "", 
	version = "1.0", 
	url = "https://steamcommunity.com/id/ByDexterTR - ByDexter#5494"
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_nsmenu", Command_NSMenu);
	Test = CreateConVar("sm_nsmenu_flag", "f", "Komutçu harici kullanabilecek kişilerin yetki harfi");
	AutoExecConfig(true, "NSMenu", "ByDexter");
	
	HookEvent("round_end", RoundStartEnd);
	HookEvent("round_start", RoundStartEnd);
	HookEvent("player_death", OnClientDead);
}

public Action Command_NSMenu(int client, int args)
{
	char Flag[8];
	Test.GetString(Flag, sizeof(Flag));
	if (warden_iswarden(client) || CheckAdminFlag(client, Flag))
	{
		Menu menu = new Menu(Menu_CallBack);
		menu.SetTitle("[SM] NoScope Menü - Hangi Silahla Kapışılsın?\n ");
		menu.AddItem("0", "→ Awp");
		menu.AddItem("1", "→ Ssg");
		menu.AddItem("2", "→ Scar20");
		menu.AddItem("3", "→ G3SG1\n ");
		menu.AddItem("4", "→ Kapat");
		menu.ExitBackButton = false;
		menu.ExitButton = false;
		menu.Display(client, 20);
		return Plugin_Handled;
	}
	else
	{
		ReplyToCommand(client, "[SM] Bu komuta erişiminiz yok!");
		return Plugin_Handled;
	}
}

public int Menu_CallBack(Menu menu, MenuAction action, int client, int param2)
{
	if (action == MenuAction_Select)
	{
		char Item[32];
		menu.GetItem(param2, Item, sizeof(Item));
		if (StrEqual(Item, "0", true))
		{
			SaniyeSor(client);
			Verileceksilah = 1;
		}
		else if (StrEqual(Item, "1", true))
		{
			SaniyeSor(client);
			Verileceksilah = 2;
		}
		else if (StrEqual(Item, "2", true))
		{
			SaniyeSor(client);
			Verileceksilah = 3;
		}
		else if (StrEqual(Item, "3", true))
		{
			SaniyeSor(client);
			Verileceksilah = 4;
		}
		else if (StrEqual(Item, "4", true))
		{
			PrintToChat(client, "[SM] \x01Bu eklenti \x04ByDexter \x01tarafından yapıldı!");
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
}

public void SaniyeSor(int client)
{
	Menu menu = new Menu(MenuCallBack);
	menu.SetTitle("[SM] NoScope Menü - Kaç saniye sonra başlasın?\n ");
	menu.AddItem("60sn", "60 Saniye Sonra");
	menu.AddItem("50sn", "50 Saniye Sonra");
	menu.AddItem("40sn", "40 Saniye Sonra");
	menu.AddItem("30sn", "30 Saniye Sonra");
	menu.AddItem("20sn", "20 Saniye Sonra");
	menu.AddItem("10sn", "10 Saniye Sonra");
	menu.ExitBackButton = true;
	menu.ExitButton = false;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuCallBack(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char Item[32];
		menu.GetItem(param2, Item, sizeof(Item));
		if (StrEqual(Item, "60sn", true))
		{
			GeriSay = 60;
		}
		else if (StrEqual(Item, "50sn", true))
		{
			GeriSay = 50;
		}
		else if (StrEqual(Item, "40sn", true))
		{
			GeriSay = 40;
		}
		else if (StrEqual(Item, "30sn", true))
		{
			GeriSay = 30;
		}
		else if (StrEqual(Item, "20sn", true))
		{
			GeriSay = 20;
		}
		else if (StrEqual(Item, "10sn", true))
		{
			GeriSay = 10;
		}
		Block_scope = true;
		if (g_gerisaytimer != null)
		{
			delete g_gerisaytimer;
			g_gerisaytimer = null;
		}
		g_gerisaytimer = CreateTimer(1.0, GeriSayTimer, _, TIMER_REPEAT);
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && !IsFakeClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == CS_TEAM_T)
			{
				Client_ClearWeapon(i);
				if (Verileceksilah == 1)
					GivePlayerItem(i, "weapon_awp");
				else if (Verileceksilah == 2)
					GivePlayerItem(i, "weapon_ssg08");
				else if (Verileceksilah == 3)
					GivePlayerItem(i, "weapon_scar20");
				else if (Verileceksilah == 4)
					GivePlayerItem(i, "weapon_g3sg1");
			}
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack)
			Command_NSMenu(param1, 0);
	}
}

public Action GeriSayTimer(Handle timer, any data)
{
	if (GeriSay > -1)
	{
		YerdekiSilahlariSil();
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && !IsFakeClient(i))
			{
				PrintHintText(i, "<font color='#00FF00'>%d Saniye</font> sonra noscope savaşı başlayacak", GeriSay);
			}
		}
		GeriSay--;
		return Plugin_Continue;
	}
	if (GeriSay <= -1)
	{
		if (GetConVarInt(FindConVar("mp_teammates_are_enemies")) != 1)SetCvar("mp_teammates_are_enemies", 1);
		if (GetConVarInt(FindConVar("mp_friendlyfire")) != 1)SetCvar("mp_friendlyfire", 1);
		if (GetConVarInt(FindConVar("mp_respawn_on_death_t")) != 0)SetCvar("mp_respawn_on_death_t", 0);
		PrintToChatAll("[SM] \x01No Scope Savaşı \x04başladı!");
		if (g_gerisaytimer != null)g_gerisaytimer = null;
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public Action OnClientDead(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (IsClientInGame(client) && !IsFakeClient(client) && GetClientTeam(client) == CS_TEAM_T)
	{
		int Yasayan = 0;
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(client) && !IsFakeClient(client) && GetClientTeam(client) == CS_TEAM_T && IsPlayerAlive(client))
				Yasayan++;
		}
		if (Yasayan == 1)
		{
			Block_scope = false;
			SetCvar("mp_teammates_are_enemies", 0);
			SetCvar("mp_friendlyfire", 0);
			PrintToChatAll("[SM] \x01No Scope savaşı sona erdi!");
		}
	}
}

public Action RoundStartEnd(Event event, const char[] name, bool dontBroadcast)
{
	if (Block_scope)
	{
		Block_scope = false;
		SetCvar("mp_teammates_are_enemies", 0);
		SetCvar("mp_friendlyfire", 0);
		PrintToChatAll("[SM] \x01No Scope savaşı iptal edildi!");
	}
}

public Action OnPlayerRunCmd(int client, int &buttons)
{
	if (Block_scope && IsClientInGame(client) && !IsFakeClient(client) && IsPlayerAlive(client))
	{
		buttons &= ~IN_ATTACK2;
	}
	return Plugin_Continue;
}

stock void YerdekiSilahlariSil()
{
	int g_WeaponParent = FindSendPropInfo("CBaseCombatWeapon", "m_hOwnerEntity");
	int maxent = GetMaxEntities();
	char weapon[64];
	for (int i = MaxClients; i < maxent; i++)
	{
		if (IsValidEdict(i) && IsValidEntity(i))
		{
			GetEdictClassname(i, weapon, sizeof(weapon));
			if ((StrContains(weapon, "weapon_") != -1 || StrContains(weapon, "item_") != -1) && GetEntDataEnt2(i, g_WeaponParent) == -1)
				RemoveEdict(i);
		}
	}
}

stock void Client_ClearWeapon(int client)
{
	for (int j = 0; j < 12; j++)
	{
		int weapon = GetPlayerWeaponSlot(client, j);
		if (weapon != -1)
		{
			RemovePlayerItem(client, weapon);
			RemoveEdict(weapon);
		}
	}
}

stock void SetCvar(char[] cvarName, int value)
{
	ConVar IntCvar = FindConVar(cvarName);
	if (IntCvar == null)return;
	int flags = IntCvar.Flags;
	flags &= ~FCVAR_NOTIFY;
	IntCvar.Flags = flags;
	IntCvar.IntValue = value;
	flags |= FCVAR_NOTIFY;
	IntCvar.Flags = flags;
}

stock bool CheckAdminFlag(int client, const char[] flags)
{
	int iCount = 0;
	char sflagNeed[22][8], sflagFormat[64];
	bool bEntitled = false;
	Format(sflagFormat, sizeof(sflagFormat), flags);
	ReplaceString(sflagFormat, sizeof(sflagFormat), " ", "");
	iCount = ExplodeString(sflagFormat, ",", sflagNeed, sizeof(sflagNeed), sizeof(sflagNeed[]));
	for (int i = 0; i < iCount; i++)
	{
		if ((GetUserFlagBits(client) & ReadFlagString(sflagNeed[i])) || (GetUserFlagBits(client) & ADMFLAG_ROOT))
		{
			bEntitled = true;
			break;
		}
	}
	return bEntitled;
} 