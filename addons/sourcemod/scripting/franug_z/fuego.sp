





#define ADMIN_LEVEL ADMFLAG_SLAY

new flameAmount[MAXPLAYERS+1] = 0;



new String:GameName[64];



public OnPluginStart20()
{
	//RegConsoleCmd("sm_fire", Flame, " -  Use the flamethrower");
	
	
	GetGameFolderName(GameName, sizeof(GameName));
}

public OnMapStart20()
{
		
		PrecacheSound("weapons/rpg/rocketfire1.wav", true);

}



public Action:SetFlame(Handle:timer, any:client)
{
	flameAmount[client] += 1;
}

public Action:Flame(any:client)
{


			//if (GetClientTeam(client) != 1 && IsPlayerAlive(client))
			//{
				//if (flameAmount[client] > 0)
				//{
						
						new Float:vAngles[3];
						new Float:vOrigin[3];
						new Float:aOrigin[3];
						new Float:EndPoint[3];
						new Float:AnglesVec[3];
						new Float:targetOrigin[3];
						new Float:pos[3];
						
						flameAmount[client]--;
						PrintToChat(client, "\x04[SM_Franug-JailPlugins] \x05Numero de Lanzallamas: %i", flameAmount[client]);
						
						new String:tName[128];
						
						new Float:distance = 600.0;
						
						GetClientEyePosition(client, vOrigin);
						GetClientAbsOrigin(client, aOrigin);
						GetClientEyeAngles(client, vAngles);
						
						// A little routine developed by Sollie and Crimson to find the endpoint of a traceray
						// Very useful!
						GetAngleVectors(vAngles, AnglesVec, NULL_VECTOR, NULL_VECTOR);
						
						EndPoint[0] = vOrigin[0] + (AnglesVec[0]*distance);
						EndPoint[1] = vOrigin[1] + (AnglesVec[1]*distance);
						EndPoint[2] = vOrigin[2] + (AnglesVec[2]*distance);
												
						new Handle:trace = TR_TraceRayFilterEx(vOrigin, EndPoint, MASK_SHOT, RayType_EndPoint, TraceEntityFilterPlayer20, client)	;
						
						// Ident the player
						Format(tName, sizeof(tName), "target%i", client);
						DispatchKeyValue(client, "targetname", tName);

		                                //new Float:playerEyes[3];
		                                //GetClientEyePosition(client, playerEyes);
						
						EmitAmbientSound("weapons/rpg/rocketfire1.wav", NULL_VECTOR, client);
						
						// Create the Flame
						new String:flame_name[128];
						Format(flame_name, sizeof(flame_name), "Flame%i", client);
						new flame = CreateEntityByName("env_steam");
						DispatchKeyValue(flame,"targetname", flame_name);
						DispatchKeyValue(flame, "parentname", tName);
						DispatchKeyValue(flame,"SpawnFlags", "1");
						DispatchKeyValue(flame,"Type", "0");
						DispatchKeyValue(flame,"InitialState", "1");
						DispatchKeyValue(flame,"Spreadspeed", "10");
						DispatchKeyValue(flame,"Speed", "800");
						DispatchKeyValue(flame,"Startsize", "10");
						DispatchKeyValue(flame,"EndSize", "250");
						DispatchKeyValue(flame,"Rate", "15");
						DispatchKeyValue(flame,"JetLength", "400");
						DispatchKeyValue(flame,"RenderColor", "180 71 8");
						DispatchKeyValue(flame,"RenderAmt", "180");
						DispatchSpawn(flame);
						TeleportEntity(flame, aOrigin, AnglesVec, NULL_VECTOR);
						SetVariantString(tName);
						AcceptEntityInput(flame, "SetParent", flame, flame, 0);
						
						if (StrEqual(GameName, "dod") || StrEqual(GameName, "insurgency"))
						{
							SetVariantString("anim_attachment_RH");
						}
						else
						{
							SetVariantString("forward");
						}
						
                                                //SetEntityRenderColor(flame, 255, 100, 0, 255);
						AcceptEntityInput(flame, "SetParentAttachment", flame, flame, 0);
						AcceptEntityInput(flame, "TurnOn");
						
						// Create the Heat Plasma
						new String:flame_name2[128];
						Format(flame_name2, sizeof(flame_name2), "Flame2%i", client);
						new flame2 = CreateEntityByName("env_steam");
						DispatchKeyValue(flame2,"targetname", flame_name2);
						DispatchKeyValue(flame2, "parentname", tName);
						DispatchKeyValue(flame2,"SpawnFlags", "1");
						DispatchKeyValue(flame2,"Type", "1");
						DispatchKeyValue(flame2,"InitialState", "1");
						DispatchKeyValue(flame2,"Spreadspeed", "10");
						DispatchKeyValue(flame2,"Speed", "600");
						DispatchKeyValue(flame2,"Startsize", "50");
						DispatchKeyValue(flame2,"EndSize", "400");
						DispatchKeyValue(flame2,"Rate", "10");
						DispatchKeyValue(flame2,"JetLength", "500");
						DispatchKeyValue(flame2,"RenderColor", "180 71 8");
						DispatchSpawn(flame2);
						TeleportEntity(flame2, aOrigin, AnglesVec, NULL_VECTOR);
						SetVariantString(tName);
						AcceptEntityInput(flame2, "SetParent", flame2, flame2, 0);
						
						if (StrEqual(GameName, "dod") || StrEqual(GameName, "insurgency"))
						{
							SetVariantString("anim_attachment_RH");
						}
						else
						{
							SetVariantString("forward");
						}
						
						AcceptEntityInput(flame2, "SetParentAttachment", flame2, flame2, 0);
						AcceptEntityInput(flame2, "TurnOn");
						
						new Handle:flamedata = CreateDataPack();
						CreateTimer(1.0, KillFlame, flamedata);
						WritePackCell(flamedata, flame);
						WritePackCell(flamedata, flame2);
								
						if(TR_DidHit(trace))
						{							
							TR_GetEndPosition(pos, trace);
						}
						CloseHandle(trace);
												
						for (new i = 1; i <= GetMaxClients(); i++)
						{
							if (i == client)
								continue;
							
							if (IsClientInGame(i) && IsPlayerAlive(i))
							{
								new ff_on = GetConVarInt(FindConVar("mp_friendlyfire"));
								
								if (ff_on)
								{
									GetClientAbsOrigin(i, targetOrigin);
									
									if ((GetVectorDistance(targetOrigin, pos) < 200)  && (GetVectorDistance(targetOrigin, vOrigin) < 600))
									{
										IgniteEntity(i, 10.0, false, 1.5, false);
									}
								}
								else
								{
									if (GetClientTeam(i) == GetClientTeam(client))
										continue;
										
									GetClientAbsOrigin(i, targetOrigin);
									
									if ((GetVectorDistance(targetOrigin, pos) < 200)  && (GetVectorDistance(targetOrigin, vOrigin) < 600))
									{
										IgniteEntity(i, 10.0, false, 1.5, false);
									}
								}
							}
						}

				//}
				//else
				//{
				//	PrintToChat(client, "[SM] Lanzallamas sin fuel");
				//	//EmitSoundToClient(client, "weapons/ar2/ar2_empty.wav", _, _, _, _, 0.8);
                                //        EmitAmbientSound("weapons/ar2/ar2_empty.wav", NULL_VECTOR, client);
				//}
			//}
	
						return Plugin_Handled;
}

public bool:TraceEntityFilterPlayer20(entity, contentsMask, any:data)
{
	return data != entity;
} 

public Action:KillFlame(Handle:timer, Handle:flamedata)
{
	ResetPack(flamedata);
	new ent1 = ReadPackCell(flamedata);
	new ent2 = ReadPackCell(flamedata);
	CloseHandle(flamedata);
	
	new String:classname[256];
	
	if (IsValidEntity(ent1))
    {
		AcceptEntityInput(ent1, "TurnOff");
		GetEdictClassname(ent1, classname, sizeof(classname));
		if (StrEqual(classname, "env_steam", false))
        {
            RemoveEdict(ent1);
        }
    }
	
	if (IsValidEntity(ent2))
    {
		AcceptEntityInput(ent2, "TurnOff");
		GetEdictClassname(ent2, classname, sizeof(classname));
		if (StrEqual(classname, "env_steam", false))
        {
            RemoveEdict(ent2);
        }
    }
}