#include <sourcemod>
#include <cstrike>
#include <sdktools>

#pragma semicolon 1
#pragma newdecls required

int LRAtan = -1;

public Plugin myinfo = 
{
	name = "LR - Hakkı Salma ( Ported 1.6 )", 
	author = "Port: ByDexter ( Orginial Author: Necati_DGN )", 
	description = "", 
	version = "1.0", 
	url = "https://steamcommunity.com/id/ByDexterTR - ByDexter#5494"
};

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	HookEvent("round_start", RoundStartEnd, EventHookMode_PostNoCopy);
	HookEvent("round_end", RoundStartEnd, EventHookMode_PostNoCopy);
	HookEvent("player_death", OnClientDead);
	RegConsoleCmd("sm_lrsal", Command_LRSal);
}

public Action Command_LRSal(int client, int args)
{
	if (args != 1)
	{
		ReplyToCommand(client, "[SM] Kullanım: sm_lrsal <Hedef>");
		return Plugin_Handled;
	}
	{
		if (client == LRAtan)
		{
			char arg1[MAX_TARGET_LENGTH];
			GetCmdArg(1, arg1, sizeof(arg1));
			int target = FindTarget(client, arg1, true, false);
			if (GetClientTeam(target) != 2)
			{
				ReplyToCommand(client, "[SM] Hedeflediğiniz kişi Terörist değil.");
				return Plugin_Handled;
			}
			else
			{
				if (target == COMMAND_TARGET_NONE || target == COMMAND_TARGET_AMBIGUOUS)
				{
					ReplyToTargetError(client, target);
					return Plugin_Handled;
				}
				else
				{
					if (target == LRAtan) // Cahil bunlar amQ
					{
						ReplyToCommand(client, "[SM] Kendini hedefliyemezsin.");
						return Plugin_Handled;
					}
					else
					{
						CS_RespawnPlayer(target);
						ForcePlayerSuicide(LRAtan);
						FakeClientCommand(target, "sm_lr");
						return Plugin_Handled;
					}
				}
			}
		}
		else
		{
			ReplyToCommand(client, "[SM] Bu komuta erişiminiz yok");
			return Plugin_Handled;
		}
	}
}

public Action RoundStartEnd(Event event, const char[] name, bool dontBroadcast)
{
	if (LRAtan != -1)
		LRAtan = -1;
}

public Action OnClientDead(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (IsClientInGame(client))
	{
		if (GetClientTeam(client) == CS_TEAM_T)
		{
			int iCount_terrorist = 0;
			for (int i = 1; i < MaxClients; i++)
			{
				if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == 2)
				{
					iCount_terrorist++;
				}
			}
			if (iCount_terrorist == 1)
			{
				for (int i = 1; i < MaxClients; i++)
				{
					if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == 2)
						LRAtan = i;
				}
			}
		}
		else if (client == LRAtan)
			LRAtan = -1;
	}
} 