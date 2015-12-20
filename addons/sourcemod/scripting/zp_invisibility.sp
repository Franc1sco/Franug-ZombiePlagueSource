#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <franug_zp>

// configuration part
#define AWARDNAME "invisibility" // Name of award
#define PRICE 20 // Award price
#define AWARDTEAM ZP_BOTH // Set team that can buy this award (use ZP_BOTH ZP_HUMANS ZP_ZOMBIES)
#define TRANSLATIONS "plague_invisibility.phrases" // Set translations file for this subplugin
// end configuration

new bool:g_invisible[MAXPLAYERS+1];


// dont touch
public OnPluginStart()
{
	CreateTimer(0.1, Lateload);
	HookEvent("player_spawn", EventPlayerSpawn);
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
		PrintToChat(client, " \x04[SM_Franug-ZombiePlague] \x05%t", "you bought invisibility");
		if(!g_invisible[client]) SDKHook(client, SDKHook_SetTransmit, Hook_SetTransmit); 
		g_invisible[client] = true;
	}
}

public Action:EventPlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(g_invisible[client])
	{
		g_invisible[client] = false;
		SDKUnhook(client, SDKHook_SetTransmit, Hook_SetTransmit); 
	}
}

public Action:Hook_SetTransmit(entity, client) 
{ 
	if(entity == client) return Plugin_Continue;
	
	return Plugin_Handled;
} 

public OnClientPostAdminCheck(client)
{
	g_invisible[client] = false;
}