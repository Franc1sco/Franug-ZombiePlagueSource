#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <emitsoundany>
#include <zombiereloaded>
#include <franug_zp>

// configuration part
#define AWARDNAME "antidote" // Name of award
#define PRICE 18 // Award price
#define AWARDTEAM ZP_ZOMBIES // Set team that can buy this award (use ZP_BOTH ZP_HUMANS ZP_ZOMBIES)
#define TRANSLATIONS "plague_antidote.phrases" // Set translations file for this subplugin
// end configuration


// dont touch
public OnPluginStart()
{
	CreateTimer(0.1, Lateload);
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
		PrintToChat(client, " \x04[SM_Franug-ZombiePlague] \x05%t", "you bought antidote");
		ZR_HumanClient(client, false, false);
						
		GivePlayerItem(client, "weapon_glock");
		GivePlayerItem(client, "weapon_m249");
		new Float:iVec[ 3 ];
		GetClientAbsOrigin( client, Float:iVec );
		EmitAmbientSoundAny("franug/items/smallmedkit1.mp3", iVec, client, SNDLEVEL_NORMAL );
		decl String:nombre[32];
		GetClientName(client, nombre, sizeof(nombre));
		PrintToChatAll("%t","a vuelto a ser humano con un antidoto", nombre);
	}
}

public OnMapStart()
{
	PrecacheSound("franug/items/smallmedkit1.mp3");
	AddFileToDownloadsTable("sound/franug/items/smallmedkit1.mp3");
}