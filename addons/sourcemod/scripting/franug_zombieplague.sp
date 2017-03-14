/*  SM Zombie Plague
 *
 *  Copyright (C) 2017 Francisco 'Franc1sco' García
 * 
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) 
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT 
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with 
 * this program. If not, see http://www.gnu.org/licenses/.
 */


#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <zombiereloaded>
#include <franug_zp>
//#include <smlib>

#define RADIO 10

new Handle:array_premios;
new Handle:array_rondas;
new Handle:EnPremioComprado;
new Handle:EnRondaElegida;

new Handle:oros;
new Handle:dorada;

new g_creditos[MAXPLAYERS+1];
new bool:special[MAXPLAYERS+1];

new Handle:menus[MAXPLAYERS+1];

new bool:primero;
new bool:nomadrezombi;

enum Rondas
{
	String:Nombre[64],
	probabilidad
}

enum Premios
{
	String:Nombre[64],
	precio,
	quien
}
#define VERSION "v3.0 by Franc1sco steam: franug (Made in Spain)"

public Plugin:myinfo =
{
	name = "SM Zombie Plague by Franug",
	author = "Franc1sco steam: franug",
	description = "Zombie Plague of cs 1.6 now in sourcemod",
	version = VERSION,
	url = "http://steamcommunity.com/id/franug"
};


public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	CreateNative("ZP_AddAward", Native_AgregarPremio);
	CreateNative("ZP_AddRound", Native_AgregarRonda);
	CreateNative("ZP_RemoveAward", Native_BorrarPremio);
	CreateNative("ZP_RemoveRound", Native_BorrarRonda);
	CreateNative("ZP_ChooseRound", Native_ElegirRonda);
	CreateNative("ZP_SetSpecial", Native_FijarEspecial);
	CreateNative("ZP_GetSpecial", Native_ObtenerEspecial);
	CreateNative("ZP_SetCredits", Native_FijarCreditos);
	CreateNative("ZP_GetCredits", Native_ObtenerCreditos);
	CreateNative("ZP_LoadTranslations", Native_Lengua);
	CreateNative("ZP_AddGoldenWeapon", Native_AgregarDorada);
	EnPremioComprado = CreateGlobalForward("ZP_OnAwardBought", ET_Ignore, Param_Cell, Param_String);
	EnRondaElegida = CreateGlobalForward("ZP_OnRoundSelected", ET_Ignore, Param_String);
    
	return APLRes_Success;
}

public Native_AgregarRonda(Handle:plugin, argc)
{  
	new Items[Rondas];
	GetNativeString(1, Items[Nombre], 64);
	Items[probabilidad] = GetNativeCell(2);
	
	PushArrayArray(array_rondas, Items[0]);
}

public Native_AgregarPremio(Handle:plugin, argc)
{  
	new Items[Premios];
	GetNativeString(1, Items[Nombre], 64);
	Items[precio] = GetNativeCell(2);
	Items[quien] = GetNativeCell(3);
	
	PushArrayArray(array_premios, Items[0]);
	
	RenewMenus();
}

public Native_BorrarPremio(Handle:plugin, argc)
{  
	decl String:buscado[64];
	GetNativeString(1, buscado, 64);
	
	new Items[Premios];
	for(new i=0;i<GetArraySize(array_premios);++i)
	{
		GetArrayArray(array_premios, i, Items[0]);
		if(StrEqual(Items[Nombre], buscado))
		{
			RemoveFromArray(array_premios, i);
			break;
		}
	}
	RenewMenus();
}

public Native_BorrarRonda(Handle:plugin, argc)
{  
	decl String:buscado[64];
	GetNativeString(1, buscado, 64);
	
	new Items[Rondas];
	for(new i=0;i<GetArraySize(array_rondas);++i)
	{
		GetArrayArray(array_rondas, i, Items[0]);
		if(StrEqual(Items[Nombre], buscado))
		{
			RemoveFromArray(array_rondas, i);
			break;
		}
	}
}

public Native_ElegirRonda(Handle:plugin, argc)
{  
	decl String:buscado[64];
	GetNativeString(1, buscado, 64);
	
	new Items[Rondas];
	for(new i=0;i<GetArraySize(array_rondas);++i)
	{
		GetArrayArray(array_rondas, i, Items[0]);
		if(StrEqual(Items[Nombre], buscado))
		{
			Call_StartForward(EnRondaElegida);
			Call_PushString(Items[Nombre]);
			Call_Finish();
			
			nomadrezombi = true;
			break;
		}
	}
}

public Native_FijarEspecial(Handle:plugin, argc)
{  
	special[GetNativeCell(1)] = GetNativeCell(2);
}

public Native_ObtenerEspecial(Handle:plugin, argc)
{  
	return special[GetNativeCell(1)];
}

public Native_ObtenerCreditos(Handle:plugin, argc)
{  
	return g_creditos[GetNativeCell(1)];
}

public Native_FijarCreditos(Handle:plugin, argc)
{  
	g_creditos[GetNativeCell(1)] = GetNativeCell(2);
}

public Native_Lengua(Handle:plugin, argc)
{  
	decl String:buscado[64];
	GetNativeString(1, buscado, 64);
	
	LoadTranslations(buscado);
}

public Native_AgregarDorada(Handle:plugin, argc)
{  
	new elarma = GetNativeCell(2);
	PushArrayCell(oros, elarma);
	DarEfecto(elarma, GetNativeCell(1));
}

public OnPluginStart()
{
	LoadTranslations ("plague.phrases");
	array_premios = CreateArray(66);
	array_rondas = CreateArray(65);
	oros = CreateArray();
	
	RegConsoleCmd("sm_awards", DOMenu);
	RegConsoleCmd("sm_zp", DOMenu);
	HookEvent("round_start", InicioRonda);
	CreateConVar("sm_ZombiePlague", VERSION, "plugin info", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	
	dorada = CreateConVar("zombieplague_dorada", "15.0", "Multipliear of damage for golden weapons");
}

public OnPluginEnd()
{
	CloseHandle(array_premios);
	CloseHandle(array_rondas);
}

RenewMenus()
{
	for (new i = 1; i < GetMaxClients(); i++)
		if(IsClientInGame(i))
		{
			if(menus[i] != INVALID_HANDLE) CloseHandle(menus[i]);
			menus[i] = INVALID_HANDLE;
			CreateMenuClient(i);
		}
}

public OnClientDisconnect(client)
{
	if(menus[client] != INVALID_HANDLE) CloseHandle(menus[client]);
	
	menus[client] = INVALID_HANDLE;
}

public Action:DOMenu(client,args)
{
	CreateMenuClient(client);
	DisplayMenu(menus[client], client, MENU_TIME_FOREVER);
	PrintToChat(client, "\x04[SM_Franug-ZombiePlague] \x05%t" ,"Tus creditos", g_creditos[client]);
	return Plugin_Handled;
}

CreateMenuClient(clientId) 
{
	if(menus[clientId] == INVALID_HANDLE)
	{
		menus[clientId] = CreateMenu(DIDMenuHandler);
		SetMenuTitle(menus[clientId], "ZombiePlague by Franug");
		decl String:MenuItem[128];
		decl String:tnombre[32];
		decl String:tparaquien[32];
		decl String:creditos[32];
	
		new Handle:array_premios_clon = CloneArray(array_premios);
	
		while(GetArraySize(array_premios_clon)>0)
		{
			new menor;
			new Items[GetArraySize(array_premios_clon)][Premios];
			for(new i2=0;i2<GetArraySize(array_premios_clon);++i2)
			{
				GetArrayArray(array_premios_clon, i2, Items[i2][0]);
			
				if(Items[i2][precio] <= Items[menor][precio])
				{
					menor = i2;
				}
			}

			Format(tnombre, sizeof(tnombre),"%T", Items[menor][Nombre], clientId);
			switch(Items[menor][quien])
			{
				case ZP_HUMANS:Format(tparaquien, 32, "%T", "Humanos", clientId);
				case ZP_ZOMBIES:Format(tparaquien, 32, "%T", "Zombies", clientId);
				case ZP_BOTH:Format(tparaquien, 32, "%T", "Ambos", clientId);
			}
			Format(creditos, sizeof(creditos),"%T", "Creditos", clientId);
		
			Format(MenuItem, sizeof(MenuItem),"%s (%s) - %i %s",tnombre, tparaquien, Items[menor][precio], creditos);
			AddMenuItem(menus[clientId], Items[menor][Nombre], MenuItem);
		
			RemoveFromArray(array_premios_clon, menor);
		
		}
		CloseHandle(array_premios_clon);
	
	
		SetMenuExitButton(menus[clientId], true);
	}
}

public DIDMenuHandler(Handle:menu, MenuAction:action, client, itemNum) 
{
	if ( action == MenuAction_Select ) 
	{
		decl String:info[64];
		new Items[Premios];
		
		GetMenuItem(menu, itemNum, info, sizeof(info));
		
		for(new i=0;i<GetArraySize(array_premios);++i)
		{
			GetArrayArray(array_premios, i, Items[0]);
			if(StrEqual(Items[Nombre], info))
			{
				break;
			}
		}
		
		
		if (g_creditos[client] >= Items[precio])
		{
			if (IsPlayerAlive(client))
			{
				if (Items[quien] == ZP_BOTH || (ZR_IsClientZombie(client) && Items[quien] == ZP_ZOMBIES) || (ZR_IsClientHuman(client) && Items[quien] == ZP_HUMANS))
				{
					if(special[client])
					{
						PrintToChat(client," \x04[SM_Franug-ZombiePlague] \x05%t","No puedes comprar cosas siendo un ser especial");
						return;
					}
					g_creditos[client] -= Items[precio];
						
					Call_StartForward(EnPremioComprado);
					Call_PushCell(client);
					Call_PushString(info);
					Call_Finish();
				}
				else
				{
					PrintToChat(client, " \x04[SM_Franug-ZombiePlague] \x05%t","Este premio no esta disponible para tu equipo");
				}
			}
			else
			{
				PrintToChat(client, " \x04[SM_Franug-ZombiePlague] \x05%t","Tienes que estar vivo para poder comprar premios");
			}
		}
		else
		{
			PrintToChat(client, " \x04[SM_Franug-ZombiePlague] \x05%t","Necesitas creditos", g_creditos[client],Items[precio]);
		}
		//DID(client);
		DisplayMenuAtItem(menu, client, GetMenuSelectionPosition(), MENU_TIME_FOREVER);
		
	}
/* 	else if (action == MenuAction_End)
		CloseHandle(menu); */
}

public OnClientPostAdminCheck(client)
{
	g_creditos[client] = 0;
	special[client] = false;
}

public Action:InicioRonda(Handle:event, const String:name[], bool:dontBroadcast)
{
	primero = false;
	nomadrezombi = false;
}

public Action:ZR_OnClientInfect(&client, &attacker, &bool:motherInfect, &bool:respawnOverride, &bool:respawn)
{
	if(!primero && !nomadrezombi)
	{
		primero = true;
		RondaEspecial();
	}
	if(motherInfect && nomadrezombi) return Plugin_Handled;
	
	return Plugin_Continue;
}

RondaEspecial()
{
	if(GetArraySize(array_rondas) == 0) return;
	
	if(GetRandomInt(0, 100) < RADIO)
	{
		HacerRonda(0);
	}
}

HacerRonda(intentos)
{
	++intentos;
	if(intentos > 10) return;
	
	new Items[Rondas];
	new ronda = GetRandomInt(0, GetArraySize(array_rondas)-1);
	GetArrayArray(array_rondas, ronda, Items[0]);
	if(GetRandomInt(0, 100) < Items[probabilidad])
	{
		ZP_ChooseRound(Items[Nombre]);
	}
	else HacerRonda(intentos);
}

public OnMapStart()
{
	ClearArray(oros);
}

public OnEntityDestroyed(entity)
{
	new arma = FindValueInArray(oros, entity);
	if(arma != -1) RemoveFromArray(oros, arma);
}
public IsValidClient( client ) 
{ 
	if ( !( 1 <= client <= MaxClients ) || !IsClientInGame(client) ) 
	return false; 
	
	return true; 
}
public OnClientPutInServer(client)
{  
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}
public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if (IsValidClient(attacker))
	{
		//PrintToChat(attacker, "atacado");
		new WeaponIndex = GetEntPropEnt(attacker, Prop_Send, "m_hActiveWeapon");
		
		if(!IsValidEdict(WeaponIndex) || !IsValidEdict(WeaponIndex)) return Plugin_Continue;
		
		if(FindValueInArray(oros, WeaponIndex) != -1)  
		{ 
			//PrintToChat(attacker, "atacado con dorada");
			if (GetClientTeam(attacker) != GetClientTeam(victim))
			{
				IgniteEntity(victim, 1.0);
				damage = (damage * GetConVarFloat(dorada));
				return Plugin_Changed;
			}
		}
	}
	return Plugin_Continue;
}

DarEfecto(ent,client)
{
	SetEntityRenderMode(ent, RENDER_TRANSCOLOR);
	SetEntityRenderColor(ent, 255, 215, 0);
	//SetEntData(ent, FindSendPropInfo("CBaseCombatWeapon", "m_iClip1"), 999);
	//IgniteEntity(ent, 0.0);
	decl String:tName[128];
	Format(tName, sizeof(tName), "lighttarget%i", ent);
	DispatchKeyValue(ent, "targetname", tName);
						
	decl String:light_name[128];
	Format(light_name, sizeof(light_name), "light%i", ent);
						
	new luz = CreateEntityByName("light_dynamic");
						
						
	DispatchKeyValue(luz,"targetname", light_name);
	DispatchKeyValue(luz, "parentname", tName);
	DispatchKeyValue(luz, "inner_cone", "0");
	DispatchKeyValue(luz, "cone", "100");
	DispatchKeyValue(luz, "brightness", "1");
	DispatchKeyValueFloat(luz, "spotlight_radius", 300.0);
						
	DispatchKeyValue(luz, "pitch", "200");
	DispatchKeyValue(luz, "style", "5");
	DispatchKeyValue(luz, "classname", "luzxd");
	DispatchKeyValue(luz, "_light", "255 255 0 255");
	DispatchKeyValueFloat(luz, "distance", 300.0);
	DispatchSpawn(luz);
						
	new Float:ClientsPos[3];
	GetClientAbsOrigin(client, ClientsPos);
	//Entity_GetAbsOrigin(ent, ClientsPos);
	//ClientsPos[2] += 90.0;
	TeleportEntity(luz, ClientsPos, NULL_VECTOR, NULL_VECTOR);
	SetVariantString(tName);
	AcceptEntityInput(luz, "SetParent");
	SetEntPropEnt(ent, Prop_Send, "m_hEffectEntity", luz);
	//Entity_SetParent(luz, ent);
	AcceptEntityInput(luz, "TurnOn");
	//AcceptEntityInput(luz, "DisableShadow");
						
	//SetEntData(ent, FindSendPropInfo("CBaseCombatWeapon", "m_iClip1"), 999);
	//IgniteEntity(ent, 0.0);
/* 	new ent2 = CreateEntityByName("_firesmoke");
	if(ent2 != -1)
	{
		DispatchKeyValue(ent2, "classname", "fuegoxd");
		DispatchSpawn(ent2);
		TeleportEntity(ent2, ClientsPos, NULL_VECTOR, NULL_VECTOR);
		SetVariantString("!activator");
		AcceptEntityInput(ent2, "SetParent", luz);
	} */
	
}