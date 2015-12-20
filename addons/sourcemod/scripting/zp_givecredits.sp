#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <franug_zp>

public OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("plague_givecredits.phrases");
	RegConsoleCmd("sm_givecredits", Dar);
}

public Action:Dar(client, args)
{
	if(args < 2) // Not enough parameters
	{
		ReplyToCommand(client, "%t", "[SM] Utiliza: sm_dar <#userid|nombre> [cantidad]");
		return Plugin_Handled;
	}
	decl String:arg[30], String:arg2[10];
	GetCmdArg(1, arg, sizeof(arg));
	GetCmdArg(2, arg2, sizeof(arg2));
	new amount = StringToInt(arg2);
	if(amount > ZP_GetCredits(client))
	{
		PrintToChat(client, " \x04[SM_Franug-ZombiePlague] \x05%t","Tu no tienes tantos creditos!");
		return Plugin_Handled; // Target not found...
	}
	if(amount <= 0)
	{
		PrintToChat(client, " \x04[SM_Franug-ZombiePlague] \x05%t","No puedes dar menos de 0 creditos!");
		return Plugin_Handled; // Target not found...
	}
	new target;
	if((target = FindTarget(client, arg, false, false)) == -1)
	{
		PrintToChat(client, " \x04[SM_Franug-ZombiePlague] \x05%t","No matching client");
		return Plugin_Handled; // Target not found...
	}
	//    SetEntProp(target, Prop_Data, "m_iDeaths", amount);
	ZP_SetCredits(target, ZP_GetCredits(target)+amount);
	ZP_SetCredits(client, ZP_GetCredits(client)-amount);
	decl String:nombre[32];
	GetClientName(client, nombre, sizeof(nombre));
	decl String:nombre2[32];
	GetClientName(target, nombre2, sizeof(nombre2));
	PrintToChat(client, " \x04[SM_Franug-ZombiePlague] \x05%t","Entregados", amount, nombre2);
	PrintToChat(target, " \x04[SM_Franug-ZombiePlague] \x05%t","Te ha Entregado", amount, nombre);
	
	return Plugin_Handled;
}