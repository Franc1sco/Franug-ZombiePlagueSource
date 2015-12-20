#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <franug_zp>

public OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("plague_setcredits.phrases");
	RegAdminCmd("sm_setcredits", FijarCreditos, ADMFLAG_CUSTOM2);
}

public Action:FijarCreditos(client, args)
{
	if(args < 2) // Not enough parameters
	{
		ReplyToCommand(client, "%t","[SM] Utiliza: sm_setcredits <#userid|nombre> [cantidad]");
		return Plugin_Handled;
	}
	decl String:arg2[10];
	//GetCmdArg(1, arg, sizeof(arg));
	GetCmdArg(2, arg2, sizeof(arg2));
	new amount = StringToInt(arg2);
	//new target;
	//decl String:patt[MAX_NAME]
	//if(args == 1) 
	//{ 
	decl String:strTarget[32]; GetCmdArg(1, strTarget, sizeof(strTarget)); 
	// Process the targets 
	decl String:strTargetName[MAX_TARGET_LENGTH]; 
	decl TargetList[MAXPLAYERS], TargetCount; 
	decl bool:TargetTranslate; 
	if ((TargetCount = ProcessTargetString(strTarget, client, TargetList, MAXPLAYERS, COMMAND_FILTER_CONNECTED, 
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
			//g_creditos[iClient] = amount;
			ZP_SetCredits(client, amount);
			decl String:nombre[64];
			GetClientName(client, nombre, 64);
			PrintToChat(client, " \x04[SM_Franug-ZombiePlague] \x05%t","Puesto creditos", amount, nombre);
		} 
	} 
	//}  
	//    SetEntProp(target, Prop_Data, "m_iDeaths", amount);
	return Plugin_Handled;
}