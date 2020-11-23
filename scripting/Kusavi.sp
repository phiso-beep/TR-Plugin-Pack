#include <sourcemod>
#include <warden>
#include <sdktools>
#include <cstrike>

#pragma semicolon 1
#pragma newdecls required

bool Oyun = false;
ConVar yetkiflag = null;

public Plugin myinfo = 
{
	name = "Kuş Avı", 
	author = "ByDexter", 
	description = "", 
	version = "1.0", 
	url = "https://steamcommunity.com/id/ByDexterTR - ByDexter#5494"
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_kusavi", Command_Kusavi);
	yetkiflag = CreateConVar("sm_kusavi_flag", "b", "Komutçu harici kuş avı başlatabilecek yetki harfi");
	AutoExecConfig(true, "Kus-Avi", "ByDexter");
	
	HookEvent("round_start", RoundStartEnd);
	HookEvent("round_end", RoundStartEnd);
	HookEvent("player_death", OnClientDead);
}

public Action OnClientDead(Event event, const char[] name, bool dontBroadcast)
{
	if (Oyun)
	{
		int T_Sayisi = 0;
		for (int i = 1; i < MaxClients; i++)
		{
			if (IsValidClient(i, false, false) && GetClientTeam(i) == CS_TEAM_T)
				T_Sayisi++;
		}
		if (T_Sayisi == 1)
		{
			SetCvar("sv_gravity", 800);
			Oyun = false;
			PrintToChatAll("[SM] \x0EKuş Avı \x01oynu iptal edildi!");
		}
	}
}

public Action RoundStartEnd(Event event, const char[] name, bool dontBroadcast)
{
	if (Oyun)
	{
		SetCvar("sv_gravity", 800);
		Oyun = false;
		PrintToChatAll("[SM] \x0EKuş Avı \x01oynu iptal edildi!");
	}
}

public Action Command_Kusavi(int client, int args)
{
	char flag[8];
	yetkiflag.GetString(flag, sizeof(flag));
	if (warden_iswarden(client) || CheckAdminFlag(client, flag))
	{
		if (!Oyun)
		{
			int T_Sayisi = 0;
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i, false, false) && GetClientTeam(i) == CS_TEAM_T)
					T_Sayisi++;
			}
			if (T_Sayisi > 0)
			{
				float zemin[3];
				GetAimCoords(client, zemin);
				zemin[2] += 32;
				for (int i = 1; i <= MaxClients; i++)
				{
					if (IsValidClient(i, false, false))
					{
						ClearWeapon(i);
						if (GetClientTeam(i) == CS_TEAM_T)
						{
							SetEntityHealth(i, 1);
							GivePlayerItem(i, "weapon_knife");
							TeleportEntity(i, zemin, NULL_VECTOR, NULL_VECTOR);
						}
						if (GetClientTeam(i) == CS_TEAM_CT)
						{
							SetEntProp(i, Prop_Data, "m_takedamage", 0, 1);
							GivePlayerItem(i, "wepaon_knife");
							GivePlayerItem(i, "weapon_ssg08");
						}
					}
				}
				SetCvar("sv_gravity", 350);
				Oyun = true;
				PrintToChatAll("[SM] \x10%N \x01tarafından \x0EKuş Avı \x01oynu başlatıldı!", client);
				return Plugin_Handled;
			}
			else
			{
				ReplyToCommand(client, "[SM] Yeterli Terörist bulunamadı!");
				return Plugin_Handled;
			}
		}
		else
		{
			SetCvar("sv_gravity", 800);
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i, false, false))
				{
					if (GetClientTeam(i) == CS_TEAM_T)
					{
						SetEntityHealth(i, 100);
					}
				}
			}
			Oyun = false;
			PrintToChatAll("[SM] \x10%N \x01tarafından \x0EKuş Avı \x01oynu durduruldu!", client);
			return Plugin_Handled;
		}
	}
	else
	{
		ReplyToCommand(client, "[SM] Bu komuta erişiminiz yok!");
		return Plugin_Handled;
	}
}

public Action OnPlayerRunCmd(int client, int &buttons)
{
	if (Oyun && IsValidClient(client))
	{
		buttons &= ~IN_ATTACK2;
	}
	return Plugin_Continue;
}

public void GetAimCoords(int client, float vector[3])
{
	float vAngles[3];
	float vOrigin[3];
	GetClientEyePosition(client, vOrigin);
	GetClientEyeAngles(client, vAngles);
	
	Handle trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);
	if (TR_DidHit(trace))
		TR_GetEndPosition(vector, trace);
	trace.Close();
}

public bool TraceEntityFilterPlayer(int entity, int contentsMask)
{
	return entity > MaxClients;
}

stock bool CheckAdminFlag(int client, const char[] flags) // Z harfi otomatik erişim verir
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

stock bool IsValidClient(int client, bool AllowBots = false, bool AllowDead = false)
{
	if (!(1 <= client <= MaxClients) || !IsClientInGame(client) || (IsFakeClient(client) && !AllowBots) || IsClientSourceTV(client) || IsClientReplay(client) || (!AllowDead && !IsPlayerAlive(client)))
	{
		return false;
	}
	return true;
}

stock void ClearWeapon(int client)
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