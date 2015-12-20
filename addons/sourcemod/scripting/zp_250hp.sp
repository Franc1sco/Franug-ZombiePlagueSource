#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <franug_zp>

// configuration part
#define AWARDNAME "250HP" // Name of award
#define PRICE 8 // Award price
#define AWARDTEAM ZP_HUMANS // Set team that can buy this award (use ZP_BOTH ZP_HUMANS ZP_ZOMBIES)
#define TRANSLATIONS "plague_250hp.phrases" // Set translations file for this subplugin
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
		PrintToChat(client, " \x04[SM_Franug-ZombiePlague] \x05%t", "you bought 250 HP");
		SetEntityHealth(client, 250);
	}
}