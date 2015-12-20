#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <franug_zp>

// configuration part
#define AWARDNAME "fury" // Name of award
#define PRICE 50 // Award price
#define AWARDTEAM ZP_BOTH // Set team that can buy this award (use ZP_BOTH ZP_HUMANS ZP_ZOMBIES)
#define TRANSLATIONS "plague_fury.phrases" // Set translations file for this subplugin
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
		PrintToChat(client, " \x04[SM_Franug-ZombiePlague] \x05%t", "you bought fury");
		SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
		SetEntityRenderColor(client, 255, 0, 0, 255);
		CreateTimer(5.0, OpcionNumero16c, client);
	}
}

public Action:OpcionNumero16c(Handle:timer, any:client)
{
	if ( (IsClientInGame(client)) && (IsPlayerAlive(client)) )
	{
		PrintToChat(client, " \x04[SM_Franug-ZombiePlague] \x05%t","Ya no eres INVULNERABLE!");
		SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
		SetEntityRenderColor(client, 255, 255, 255, 255);
	}
}