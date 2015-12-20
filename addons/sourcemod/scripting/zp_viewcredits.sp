#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <franug_zp>

public OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("plague_viewcredits.phrases");
	RegConsoleCmd("sm_viewcredits", VerCreditosClient);
}

public Action:VerCreditosClient(client, args)
{
	if(args < 1) // Not enough parameters
	{
		ReplyToCommand(client, "%t", "[SM] Utiliza: sm_vercreditos <#userid|nombre>");
		return Plugin_Handled;
	}
	decl String:strTarget[32]; GetCmdArg(1, strTarget, sizeof(strTarget)); 
	// Process the targets 
	decl String:strTargetName[MAX_TARGET_LENGTH]; 
	decl TargetList[MAXPLAYERS], TargetCount; 
	decl bool:TargetTranslate; 
	if ((TargetCount = ProcessTargetString(strTarget, 0, TargetList, MAXPLAYERS, COMMAND_FILTER_CONNECTED, 
					strTargetName, sizeof(strTargetName), TargetTranslate)) <= 0) 
	{ 
		ReplyToTargetError(client, TargetCount); 
		return Plugin_Handled; 
	} 
	// Apply to all targets 
	for (new i = 0; i < TargetCount; i++) 
	{ 
		new iClient = TargetList[i]; 
		if (IsClientInGame(iClient)) 
		{ 
			//g_iCredits[iClient] = amount;
			decl String:nombre[64];
			GetClientName(client, nombre, 64);
			PrintToChat(client, " \x04[SM_Franug-ZombiePlague] \x05%t","Ver creditos", nombre, ZP_GetCredits(iClient));
			//PrintToChat(client, "\x04[SM_Franug-ZombiePlague] \x05Puesto %i creditos en el jugador %N", amount, iClient);
		} 
	}   
	return Plugin_Handled;
}