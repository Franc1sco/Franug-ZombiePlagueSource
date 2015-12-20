#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <franug_zp>

// configuration part
#define AWARDNAME "infiniteammo" // Name of award
#define PRICE 16 // Award price
#define AWARDTEAM ZP_HUMANS // Set team that can buy this award (use ZP_BOTH ZP_HUMANS ZP_ZOMBIES)
#define TRANSLATIONS "plague_infiniteammo.phrases" // Set translations file for this subplugin
// end configuration

new bool:g_AmmoInfi[MAXPLAYERS+1];
new activeOffset = -1;
new clip1Offset = -1;
new clip2Offset = -1;
new secAmmoTypeOffset = -1;
new priAmmoTypeOffset = -1;

// dont touch
public OnPluginStart()
{
	CreateTimer(0.1, Lateload);
	HookEvent("player_spawn", EventPlayerSpawn);
	HookEvent("weapon_fire", EventWeaponFire);
	
	activeOffset = FindSendPropOffs("CAI_BaseNPC", "m_hActiveWeapon");
	
	clip1Offset = FindSendPropOffs("CBaseCombatWeapon", "m_iClip1");
	clip2Offset = FindSendPropOffs("CBaseCombatWeapon", "m_iClip2");
	
	priAmmoTypeOffset = FindSendPropOffs("CBaseCombatWeapon", "m_iPrimaryAmmoCount");
	secAmmoTypeOffset = FindSendPropOffs("CBaseCombatWeapon", "m_iSecondaryAmmoCount");
}
public Action:Lateload(Handle:timer)
{
	LoadTranslations(TRANSLATIONS); // translations to the local plugin
	ZP_LoadTranslations(TRANSLATIONS); // sent translations to the main plugin
	
	ZP_AddAward(AWARDNAME, PRICE, AWARDTEAM); // add award to the main plugin
}
public OnPluginEnd()
{
	ZP_RemoveAward(AWARDNAME); // remove award when the plugin is unloaded
}
// END dont touch part


public ZP_OnAwardBought( client, const String:awardbought[])
{
	if(StrEqual(awardbought, AWARDNAME))
	{
		// use your custom code here
		PrintToChat(client, " \x04[SM_Franug-ZombiePlague] \x05%t", "you bought infiniteammo");
		g_AmmoInfi[client] = true;
	}
}

public Action:EventPlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	g_AmmoInfi[client] = false;
}

public Action:EventWeaponFire(Handle:event, const String:name[], bool:dontBroadcast)
{
    // Get all required event info.
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(!g_AmmoInfi[client]) return;
	
	Client_ResetAmmo(client);
}

public Client_ResetAmmo(client)
{
	new zomg = GetEntDataEnt2(client, activeOffset);
	if (clip1Offset != -1 && zomg != -1)
		SetEntData(zomg, clip1Offset, GetEntData(zomg, clip1Offset, 4)+1, 4, true);
	if (clip2Offset != -1 && zomg != -1)
		SetEntData(zomg, clip2Offset, GetEntData(zomg, clip2Offset, 4)+1, 4, true);
	if (priAmmoTypeOffset != -1 && zomg != -1)
		SetEntData(zomg, priAmmoTypeOffset, GetEntData(zomg, priAmmoTypeOffset, 4)+1, 4, true);
	if (secAmmoTypeOffset != -1 && zomg != -1)
		SetEntData(zomg, secAmmoTypeOffset, GetEntData(zomg, secAmmoTypeOffset, 4)+1, 4, true);
		
}