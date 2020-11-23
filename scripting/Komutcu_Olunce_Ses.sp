#include <sourcemod>
#include <emitsoundany>
#include <sdktools>
#include <warden>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = 
{
	name = "Komutçu Ölünce Ses - Efekt", 
	author = "ByDexter", 
	description = "", 
	version = "1.0", 
	url = "https://steamcommunity.com/id/ByDexterTR - ByDexter#5494"
};

public void OnPluginStart()
{
	HookEvent("player_death", OnClientDead);
}

public void OnMapStart()
{
	PreCacheSoundAndDownload("ByDexter/Adam_oldu_amk.mp3");
}

public Action OnClientDead(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (warden_iswarden(client))
	{
		EmitSoundToAllAny("ByDexter/Adam_oldu_amk.mp3", SOUND_FROM_PLAYER, 1, 100);
		Give_Effect(client, { 255, 0, 0, 120 } );
	}
}

stock void PreCacheSoundAndDownload(const char[] sSound)
{
	char sBuffer[256];
	PrecacheSound(sSound);
	Format(sBuffer, sizeof(sBuffer), "sound/%s", sSound);
	AddFileToDownloadsTable(sBuffer);
}

stock void Give_Effect(int client, int Renk[4])
{
	int clients[1];
	clients[0] = client;
	Handle message = StartMessageEx(GetUserMessageId("Fade"), clients, 1, 0);
	Protobuf pb = UserMessageToProtobuf(message);
	pb.SetInt("duration", 200);
	pb.SetInt("hold_time", 40);
	pb.SetInt("flags", 17);
	pb.SetColor("clr", Renk);
	EndMessage();
} 