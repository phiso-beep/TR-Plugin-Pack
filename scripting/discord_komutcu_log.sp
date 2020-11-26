#include <sourcemod>
#include <warden>
#include <steamworks>

#pragma semicolon 1
#pragma newdecls required

Handle sure_timer = null;
ConVar webhook = null;
int Komutcu = -1, sure = -1;

public Plugin myinfo = 
{
	name = "Discord Komutçu Bildirme", 
	author = "ByDexter", 
	description = "Komuta geçen oyuncuları discorda aktarır!", 
	version = "1.0", 
	url = "https://steamcommunity.com/id/ByDexterTR - ByDexter#5494"
};

public void OnPluginStart()
{
	AddCommandListener(Control_ExitWarden, "sm_uw");
	AddCommandListener(Control_ExitWarden, "sm_unwarden");
	AddCommandListener(Control_ExitWarden, "sm_uc");
	AddCommandListener(Control_ExitWarden, "sm_uncommander");
	
	webhook = CreateConVar("sm_dc_bildirim_webhook", "https://discord.com/api/webhooks/767689878854041640/LjPFjHhW6xLa8s08-tLf3VDTSpvV0CVKhTXeuVe8EclYPaLi1FIZZTTwQZqfPk2ymDUx", "Discord Kanal Entregrasyon Webhook");
	AutoExecConfig(true, "Discord-Komutcu", "ByDexter");
}

public void OnMapEnd()
{
	int pic[4];
	SteamWorks_GetPublicIP(pic);
	char name[MAX_NAME_LENGTH], authid[128], discordbildirim[512], sIP[32];
	GetClientName(Komutcu, name, sizeof(name));
	GetClientAuthId(Komutcu, AuthId_Steam2, authid, sizeof(authid));
	Format(sIP, sizeof(sIP), "%d.%d.%d.%d", pic[0], pic[1], pic[2], pic[3]);
	Format(discordbildirim, sizeof(discordbildirim), "▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬\n> :sob:  Komutçu Komuttan Ayrıldı :sob:\n> \n> :man_police_officer: `%s` - `%s` : ( %d Dakika komut verdi )\nTıkla Bağlan : steam://connect/%s", name, authid, sure, sIP);
	SendToDiscord(discordbildirim);
	Komutcu = -1;
	if (sure_timer != null)
	{
		delete sure_timer;
		sure_timer = null;
	}
}

public Action Control_ExitWarden(int client, const char[] command, int argc)
{
	if (warden_iswarden(client))
	{
		int pic[4];
		SteamWorks_GetPublicIP(pic);
		char name[MAX_NAME_LENGTH], authid[128], discordbildirim[512], sIP[32];
		GetClientName(Komutcu, name, sizeof(name));
		GetClientAuthId(Komutcu, AuthId_Steam2, authid, sizeof(authid));
		Format(sIP, sizeof(sIP), "%d.%d.%d.%d", pic[0], pic[1], pic[2], pic[3]);
		Format(discordbildirim, sizeof(discordbildirim), "▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬\n> :sob:  Komutçu Komuttan Ayrıldı :sob:\n> \n> :man_police_officer: `%s` - `%s` : ( %d Dakika komut verdi )\nTıkla Bağlan : steam://connect/%s", name, authid, sure, sIP);
		SendToDiscord(discordbildirim);
		Komutcu = -1;
		if (sure_timer != null)
		{
			delete sure_timer;
			sure_timer = null;
		}
	}
}

public void warden_OnWardenCreated(int client)
{
	Komutcu = client;
	int pic[4];
	SteamWorks_GetPublicIP(pic);
	char name[MAX_NAME_LENGTH], authid[128], discordbildirim[512], sIP[32];
	GetClientName(Komutcu, name, sizeof(name));
	GetClientAuthId(Komutcu, AuthId_Steam2, authid, sizeof(authid));
	Format(sIP, sizeof(sIP), "%d.%d.%d.%d", pic[0], pic[1], pic[2], pic[3]);
	Format(discordbildirim, sizeof(discordbildirim), "▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬\n> :star:  Yeni Birisi Komuta Geçti :star:\n> \n> :man_police_officer: `%s` - `%s`\nTıkla Bağlan : steam://connect/%s", name, authid, sIP);
	SendToDiscord(discordbildirim);
	if (sure != 0)
		sure = 0;
	if (sure_timer != null)
		delete sure_timer;
	sure_timer = CreateTimer(60.0, Surearttir, _, TIMER_REPEAT);
}

public void warden_OnWardenRemoved(int client)
{
	int pic[4];
	SteamWorks_GetPublicIP(pic);
	char name[MAX_NAME_LENGTH], authid[128], discordbildirim[512], sIP[32];
	GetClientName(Komutcu, name, sizeof(name));
	GetClientAuthId(Komutcu, AuthId_Steam2, authid, sizeof(authid));
	Format(sIP, sizeof(sIP), "%d.%d.%d.%d", pic[0], pic[1], pic[2], pic[3]);
	Format(discordbildirim, sizeof(discordbildirim), "▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬\n> :sob:  Komutçu Komuttan Ayrıldı :sob:\n> \n> :man_police_officer: `%s` - `%s` : ( %d Dakika komut verdi )\nTıkla Bağlan : steam://connect/%s", name, authid, sure, sIP);
	SendToDiscord(discordbildirim);
	Komutcu = -1;
	if (sure_timer != null)
	{
		delete sure_timer;
		sure_timer = null;
	}
}

public Action Surearttir(Handle timer, any data)
{
	sure++;
}

public void SendToDiscord(const char[] message)
{
	char Api[256];
	GetConVarString(webhook, Api, sizeof(Api));
	
	Handle request = SteamWorks_CreateHTTPRequest(k_EHTTPMethodPOST, Api);
	
	SteamWorks_SetHTTPRequestGetOrPostParameter(request, "content", message);
	SteamWorks_SetHTTPRequestHeaderValue(request, "Content-Type", "application/x-www-form-urlencoded");
	
	if (request == null || !SteamWorks_SetHTTPCallbacks(request, Callback_SendToDiscord) || !SteamWorks_SendHTTPRequest(request))
	{
		PrintToServer("[Komutcu_Log] ! HATA !");
		delete request;
	}
	else
		PrintToServer("[Komutcu_Log] Komutcu bilgisi discorda aktarma basarili!");
}

public int Callback_SendToDiscord(Handle hRequest, bool bFailure, bool bRequestSuccessful, EHTTPStatusCode eStatusCode)
{
	if (!bFailure && bRequestSuccessful)
	{
		if (eStatusCode != k_EHTTPStatusCode200OK && eStatusCode != k_EHTTPStatusCode204NoContent)
		{
			LogError("[Komutcu_Log] HATA BULUNDU - Kod: [%i]", eStatusCode);
			SteamWorks_GetHTTPResponseBodyCallback(hRequest, Callback_Response);
		}
	}
	delete hRequest;
}

public int Callback_Response(const char[] sData)
{
	PrintToServer("[Komutcu_Log] %s", sData);
} 