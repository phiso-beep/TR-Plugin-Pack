#include <sdktools>
#include <sdkhooks>

public Plugin myinfo = 
{
	name = "Kar Yağdırma", 
	author = "ByDexter", 
	description = "", 
	version = "1.0", 
	url = "https://steamcommunity.com/id/ByDexterTR - ByDexter#5494"
};

int g_iSnow = -1;

float g_fMinBounds[3];
float g_fMaxBounds[3];
float g_fOrigin[3];

char g_szMapPath[128];

public void OnPluginStart() 
{
	HookEventEx("round_start", Event_RoundStart, EventHookMode_Post);
	HookEventEx("teamplay_round_start", Event_RoundStart, EventHookMode_Post);
}

public void OnMapEnd()
{
	if (IsValidEntity(g_iSnow) && g_iSnow > 0)
	{
		RemoveEntity(g_iSnow);
	}
	g_iSnow = -1;
}

public void OnMapStart()
{
	g_iSnow = -1;
	char szMapName[64]; GetCurrentMap(szMapName, 64);
	Format(g_szMapPath, sizeof(g_szMapPath), "maps/%s.bsp", szMapName);
	PrecacheModel(g_szMapPath, true);
	GetEntPropVector(0, Prop_Data, "m_WorldMins", g_fMinBounds);
	GetEntPropVector(0, Prop_Data, "m_WorldMaxs", g_fMaxBounds);
	bool bIgnoreBoundaryAdjustments = false;
	if (!bIgnoreBoundaryAdjustments) {
		while (TR_PointOutsideWorld(g_fMinBounds)) {
			g_fMinBounds[0]++;
			g_fMinBounds[1]++;
			g_fMinBounds[2]++;
		}
		while (TR_PointOutsideWorld(g_fMaxBounds)) {
			g_fMaxBounds[0]--;
			g_fMaxBounds[1]--;
			g_fMaxBounds[2]--;
		}
	}
	g_fOrigin[0] = (g_fMinBounds[0] + g_fMaxBounds[0]) / 2;
	g_fOrigin[1] = (g_fMinBounds[1] + g_fMaxBounds[1]) / 2;
	g_fOrigin[2] = (g_fMinBounds[2] + g_fMaxBounds[2]) / 2;
	CreateSnow();
}

public void Event_RoundStart(Event eEvent, const char[] szName, bool bDontBroadcast)
{
	CreateSnow();
}

public void CreateSnow()
{
	bool bSnowValid = false;
	if (!IsValidEntity(g_iSnow) || g_iSnow <= 0)
	{
		g_iSnow = CreateEntityByName("func_precipitation");
	}
	else
	{
		bSnowValid = true;
	}
	DispatchKeyValue(g_iSnow, "model", g_szMapPath);
	DispatchKeyValue(g_iSnow, "preciptype", "7");
	DispatchKeyValue(g_iSnow, "renderamt", "75");
	DispatchKeyValue(g_iSnow, "density", "75");
	DispatchKeyValue(g_iSnow, "rendercolor", "230 251 255");
	DispatchKeyValue(g_iSnow, "minSpeed", "35");
	DispatchKeyValue(g_iSnow, "maxSpeed", "45");
	SetEntPropVector(g_iSnow, Prop_Send, "m_vecMins", g_fMinBounds);
	SetEntPropVector(g_iSnow, Prop_Send, "m_vecMaxs", g_fMaxBounds);
	TeleportEntity(g_iSnow, g_fOrigin, NULL_VECTOR, NULL_VECTOR);
	if (!bSnowValid)
	{
		DispatchSpawn(g_iSnow);
	}
	ActivateEntity(g_iSnow);
}

public void OnEntityCreated(int iEntity, const char[] szClassName)
{
	if (!StrEqual(szClassName, "func_precipitation", false))
	{
		return;
	}
	SDKHook(iEntity, SDKHook_SpawnPost, SnowSpawned);
}

public void SnowSpawned(int iSnow)
{
	g_iSnow = iSnow;
	CreateSnow();
} 