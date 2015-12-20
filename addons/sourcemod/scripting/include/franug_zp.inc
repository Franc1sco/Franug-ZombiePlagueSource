// Zombie Plague natives by Franc1sco franug


// Teams index for Zombie Plague plugin
#define ZP_HUMANS 1
#define ZP_ZOMBIES 2
#define ZP_BOTH 3


/**
 * Add a Award to the main plugin.
 *
 * @param name            Award name.
 * @param price           Award Price.
 * @param teamallowed            Team allowed for use this award.
 * 
 * @noreturn			       
 */
native ZP_AddAward(const String:name[], price, teamallowed);

/**
 * Add a Special round to the main plugin.
 *
 * @param name            Round name.
 * @param price           Round Chance.
 * 
 * @noreturn			       
 */
native ZP_AddRound(const String:name[], chance); 

/**
 * Select a special round to do this round.
 *
 * @param name            Round name.
 * 
 * @noreturn			       
 */
native ZP_ChooseRound(const String:name[]);

/**
 * Called when a Award has been bought.
 *
 * @param client            Client that bought the award.
 * @param price           Award Bought.		       
 */
forward ZP_OnAwardBought( client, const String:awardbought[]);

/**
 * Called when a Round has been Selected.
 *
 * @param name            Name of the round.	       
 */
forward ZP_OnRoundSelected(const String:name[]);

/**
 * Remove a Award to the main plugin.
 *
 * @param name            Award name.
 * 
 * @noreturn			       
 */
native ZP_RemoveAward(const String:name[]);

/**
 * Remove a Special Round to the main plugin.
 *
 * @param name            Round name.
 * 
 * @noreturn			       
 */
native ZP_RemoveRound(const String:name[]); 

/**
 * Set as special class (can´t buy awards) a player.
 *
 * @param client            Client target.
 * @param special            Set true or false the state of "special class".
 * 
 * @noreturn			       
 */
native ZP_SetSpecial(client, bool:special);

/**
 * Check if a player is a special class.
 *
 * @param name            Round name.
 * 
 * @return			        True if Special class, false if not.
 */
native bool:ZP_GetSpecial(client);

/**
 * Set credits to a client.
 *
 * @param client            Client target.
 * @param credits            Number of credit for set.
 * 
 * @noreturn			       
 */
native ZP_SetCredits(client, credits);

/**
 * Check if a player is a special class.
 *
 * @param client            Client target.
 * 
 * @return			        Return current credits of the target
 */
native ZP_GetCredits(client);

/**
 * Sent translations to the main plugin.
 *
 * @param client            File with translations.
 * 
 * @noreturn			       
 */
native ZP_LoadTranslations(const String:langfile[]); 

/**
 * Set as golden weapon.
 *
 * @param client            client target.
 * @param weapon            Weapon target.
 * 
 * @noreturn			       
 */
native ZP_AddGoldenWeapon(client, weapon);