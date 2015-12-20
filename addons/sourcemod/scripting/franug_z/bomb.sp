




new Handle:bomb_damage;
new Handle:bomb_radius;

new fire13;
new white13;
new g_HaloSprite13;
new g_ExplosionSprite13;


new bool:g_Bomba[MAXPLAYERS+1] = {false, ...};

OnPluginStartbomba()
{

    bomb_damage = CreateConVar("bomb_damage", "90000", "Damage ");
    bomb_radius = CreateConVar("bomb_radius", "600", "Radius");	

}

OnMapStartbomba()
{
	// Misc
	AddFileToDownloadsTable("sound/jihad/jihad.wav");
	PrecacheSound("jihad/jihad.wav");
	PrecacheSound("ambient/explosions/explode_1.wav");

	fire13=PrecacheModel("materials/sprites/fire2.vmt");
	white13=PrecacheModel("materials/sprites/white.vmt");
	
	g_ExplosionSprite13 = PrecacheModel("sprites/sprite_fire01.vmt");

	PrecacheSound( "ambient/explosions/explode_8.wav", true);


}

Detonate(client)
{
   if (( (IsClientInGame(client)) && (IsPlayerAlive(client) && g_Bomba[client])) )
   {
	// Explosion!
	new ExplosionIndex = CreateEntityByName("env_explosion");
	if (ExplosionIndex != -1)
	{
		//new radius = GetConVarInt(g_cvar_SizeMultiplier) * _:g_Clients[client][(ClientData:Bomb)];
		SetEntProp(ExplosionIndex, Prop_Data, "m_spawnflags", 16384);
		SetEntProp(ExplosionIndex, Prop_Data, "m_iMagnitude", GetConVarInt(bomb_damage));
		SetEntProp(ExplosionIndex, Prop_Data, "m_iRadiusOverride", GetConVarInt(bomb_radius));

		DispatchSpawn(ExplosionIndex);
		ActivateEntity(ExplosionIndex);
		
		new Float:playerEyes[3];
		GetClientEyePosition(client, playerEyes);
		new clientTeam = GetEntProp(client, Prop_Send, "m_iTeamNum");

		TeleportEntity(ExplosionIndex, playerEyes, NULL_VECTOR, NULL_VECTOR);
		SetEntPropEnt(ExplosionIndex, Prop_Send, "m_hOwnerEntity", client);
		SetEntProp(ExplosionIndex, Prop_Send, "m_iTeamNum", clientTeam);

		//EmitAmbientSound("ambient/explosions/explode_1.wav", NULL_VECTOR, client);

                EmitAmbientSound("ambient/explosions/explode_1.wav", NULL_VECTOR, client);

	        PyroExplode(playerEyes, client);
	        PyroExplode2(playerEyes, client);
		
		AcceptEntityInput(ExplosionIndex, "Explode");
		AcceptEntityInput(ExplosionIndex, "Kill");

                g_Bomba[client] = false;
	}
   }
}

public Action:Bumb(client,args)
{

	if (GetClientTeam(client) != 1 && IsPlayerAlive(client))
        {
              if (g_Bomba[client])
              {

                      EmitAmbientSound("jihad/jihad.wav", NULL_VECTOR, client);

                      //g_Bomba[client] = false;

                      CreateTimer(2.5, Bombazo, client);
              }
              else
              {
                 PrintToChat(client, "\x04[SM_Franug-ZombiePlague] \x05Tienes que ser un KAMIKAZE EXPLOSIVO para usar este comando!");
              }
        }
        else
        {
            PrintToChat(client, "\x04[SM_Franug-ZombiePlague] \x05Tienes que estar VIVO para usarlo!");
        }
}

public Action:Bombazo(Handle:timer, any:client)
{
   Detonate(client);
}

public PyroExplode(Float:vec1[3], any:client)
{
	new color[4]={188,220,255,200};
        EmitAmbientSound("ambient/explosions/explode_8.wav", vec1, client);
	TE_SetupExplosion(vec1, g_ExplosionSprite13, 10.0, 1, 0, 0, 1500); // 600
	TE_SendToAll();
	TE_SetupBeamRingPoint(vec1, 10.0, 500.0, white13, g_HaloSprite13, 0, 10, 0.6, 10.0, 0.5, color, 10, 0);
  	TE_SendToAll();
}

public PyroExplode2(Float:vec1[3], any:client)
{
	vec1[2] += 10;
	new color[4]={188,220,255,255};
        EmitAmbientSound("ambient/explosions/explode_8.wav", vec1, client);
	TE_SetupExplosion(vec1, g_ExplosionSprite13, 10.0, 1, 0, 0, 2000); // 600
	TE_SendToAll();
	TE_SetupBeamRingPoint(vec1, 10.0, 750.0, fire13, g_HaloSprite13, 0, 66, 6.0, 128.0, 0.2, color, 25, 0);
  	TE_SendToAll();
}