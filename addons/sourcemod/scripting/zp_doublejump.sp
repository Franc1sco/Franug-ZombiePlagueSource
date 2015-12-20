#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <franug_zp>

// configuration part
#define AWARDNAME "doublejump" // Name of award
#define PRICE 9 // Award price
#define AWARDTEAM ZP_BOTH // Set team that can buy this award (use ZP_BOTH ZP_HUMANS ZP_ZOMBIES)
#define TRANSLATIONS "plague_doublejump.phrases" // Set translations file for this subplugin
// end configuration

new bool:g_Saltador[MAXPLAYERS+1];

// Int, Float, String
new Float:g_flBoost = 250.0;
new g_fLastButtons[MAXPLAYERS+1];
new g_fLastFlags[MAXPLAYERS+1];
new g_iJumps[MAXPLAYERS+1];
new g_iJumpMax;

new Handle:g_cvJumpBoost = INVALID_HANDLE;
new Handle:g_cvJumpMax = INVALID_HANDLE;

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
	
	g_cvJumpBoost = CreateConVar("sm_doublejump_boost", "350.0","The amount of vertical boost to apply to double jumps (double jump award).");
	g_cvJumpMax = CreateConVar("sm_doublejump_max", "1","The maximum number of re-jumps allowed while already jumping (double jump award).");
	g_flBoost = GetConVarFloat(g_cvJumpBoost);
	g_iJumpMax = GetConVarInt(g_cvJumpMax);	
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
		PrintToChat(client, " \x04[SM_Franug-ZombiePlague] \x05%t", "Ahora tienes DOBLE SALTO y puedes saltar en el aire!");
		g_Saltador[client] = true;
	}
}

public OnGameFrame() 
{
	for (new i = 1; i <= MaxClients; i++) 
	{
		if(IsClientInGame(i) && IsPlayerAlive(i)) 
		{
			if (g_Saltador[i])
			{
				DoubleJump(i);
			}
		}
	}
}
stock DoubleJump(const any:client) {
	new fCurFlags	= GetEntityFlags(client);		// current flags
	new fCurButtons	= GetClientButtons(client);		// current buttons
	
	if (g_fLastFlags[client] & FL_ONGROUND) {		// was grounded last frame
		if (
				!(fCurFlags & FL_ONGROUND) &&			// becomes airbirne this frame
				!(g_fLastButtons[client] & IN_JUMP) &&	// was not jumping last frame
				fCurButtons & IN_JUMP					// started jumping this frame
				) {
			OriginalJump(client);					// process jump from the ground
		}
	} else if (										// was airborne last frame
			fCurFlags & FL_ONGROUND						// becomes grounded this frame
			) {
		Landed(client);								// process landing on the ground
	} else if (										// remains airborne this frame
			!(g_fLastButtons[client] & IN_JUMP) &&		// was not jumping last frame
			fCurButtons & IN_JUMP						// started jumping this frame
			) {
		ReJump(client);								// process attempt to double-jump
	}
	
	g_fLastFlags[client]	= fCurFlags;				// update flag state for next frame
	g_fLastButtons[client]	= fCurButtons;			// update button state for next frame
}
stock OriginalJump(const any:client) {
	g_iJumps[client]++;	// increment jump count
}
stock Landed(const any:client) {
	g_iJumps[client] = 0;	// reset jumps count
}
stock ReJump(const any:client) {
	if ( 1 <= g_iJumps[client] <= g_iJumpMax) {						// has jumped at least once but hasn't exceeded max re-jumps
		g_iJumps[client]++;											// increment jump count
		decl Float:vVel[3];
		GetEntPropVector(client, Prop_Data, "m_vecVelocity", vVel);	// get current speeds
		
		vVel[2] = g_flBoost;
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vVel);		// boost player
	}
}

public Action:EventPlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	g_Saltador[client] = false;
}

public OnClientPostAdminCheck(client)
{
	g_Saltador[client] = false;
}