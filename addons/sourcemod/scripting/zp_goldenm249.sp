#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <franug_zp>

// configuration part
#define AWARDNAME "goldenm249" // Name of award
#define PRICE 60 // Award price
#define AWARDTEAM ZP_HUMANS // Set team that can buy this award (use ZP_BOTH ZP_HUMANS ZP_ZOMBIES)
#define TRANSLATIONS "plague_goldenm249.phrases" // Set translations file for this subplugin
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
		PrintToChat(client, " \x04[SM_Franug-ZombiePlague] \x05%t", "you bought goldenm249");
		DarOro(client);
	}
}

DarOro(client)
{
	// Gets the Clients weapon in slot 0 - Primary
	new index = GetPlayerWeaponSlot(client, 0);
	// If the index is not -1 - Client has a Primary weapon 
	if(index != -1)
	{
		CS_DropWeapon(client, index, false, true);
	}
	new ent = GivePlayerItem(client,"weapon_m249");

	ZP_AddGoldenWeapon(client, ent);
}