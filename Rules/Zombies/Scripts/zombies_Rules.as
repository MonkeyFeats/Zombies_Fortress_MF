//Zombies gamemode logic script
//Edited by Monkey_Feats
#define SERVER_ONLY

#include "CTF_Structs.as";
#include "RulesCore.as";
#include "RespawnSystem.as";
#include "CTF_PopulateSpawnList.as"

//simple config function - edit the variables below to change the basics
void Config(ZombiesCore@ this)
{
    string configstr = "../Mods/" + sv_gamemode + "/Rules/" + "Zombies" + "/zombies_vars.cfg";
	if (getRules().exists("Zombiesconfig")) {
	   configstr = getRules().get_string("Zombiesconfig");
	}
	ConfigFile cfg = ConfigFile( configstr );

	s32 warmUpTimeSeconds = cfg.read_s32("warmup_time", 5);
	this.warmUpTime = (getTicksASecond() * warmUpTimeSeconds);
	
	this.gameDuration = 0;
	getRules().set_bool("no timer", true);
	 
	s32 max_zombies = cfg.read_s32("max_zombies",125);
	if (max_zombies<100) max_zombies=100;
	getRules().set_s32("max_zombies", max_zombies);
    //spawn after death time 
    this.spawnTime = (getTicksASecond() * cfg.read_s32("spawn_time", 30));	
}

const s32 spawnspam_limit_time = 10;
shared string base_name() { return "ruinstorch"; }

void onRender(CRules@ this)
{
	CBlob@[] ruins;
	getBlobsByName(base_name(), @ruins);

	for (uint i = 0; i < ruins.length; i++)
	{
		CBlob@ base = ruins[0];
		if (base !is null && base.hasTag("dmgmsg"))
		{
			Vec2f dim(getScreenWidth()/2, getScreenHeight()-128);	

			u8 health = Maths::Min( 100, Maths::Round( base.getHealth() * 5 ) );
				
			GUI::DrawTextCentered("The Sacred Flame is under attack!"+"\nHealth Left: "+ health+" %", dim, SColor(170,255,0,0));
		}
	}
}

shared class ZombiesSpawns : RespawnSystem
{
    ZombiesCore@ Zombies_core;

    bool force;
    s32 limit;
	
	void SetCore(RulesCore@ _core)
	{
		RespawnSystem::SetCore(_core);
		@Zombies_core = cast<ZombiesCore@>(core);
		
		limit = spawnspam_limit_time;
	}

    void Update()
    {
        for (uint team_num = 0; team_num < Zombies_core.teams.length; ++team_num )
        {
            CTFTeamInfo@ team = cast<CTFTeamInfo@>( Zombies_core.teams[team_num] );           

            for (uint i = 0; i < team.spawns.length; i++)
            {
                CTFPlayerInfo@ info = cast<CTFPlayerInfo@>(team.spawns[i]);                
                UpdateSpawnTime(info, i);				
				DoSpawnPlayer( info );
            }
        }
    }
    
    void UpdateSpawnTime(CTFPlayerInfo@ info, int i)
    {
		if ( info !is null )
		{
			u8 spawn_property = 255;
			
			if(info.can_spawn_time > 0) {
				info.can_spawn_time--;
				spawn_property = u8(Maths::Min(250,(info.can_spawn_time / 30)));
			}
			
			string propname = "Zombies spawn time "+info.username;
			
			Zombies_core.rules.set_u8( propname, spawn_property );
			Zombies_core.rules.SyncToPlayer( propname, getPlayerByUsername(info.username) );
		}
	}

	bool SetMaterials( CBlob@ blob,  const string &in name, const int quantity )
	{
		CInventory@ inv = blob.getInventory();

		//already got them?
		if(inv.isInInventory(name, quantity))
			return false;

		//otherwise...
		inv.server_RemoveItems(name, quantity); //shred any old ones

		CBlob@ mat = server_CreateBlob( name );
		if (mat !is null)
		{
			mat.Tag("do not set materials");
			mat.server_SetQuantity(quantity);
			if (!blob.server_PutInInventory(mat))
			{
				mat.setPosition( blob.getPosition() );
			}
		}

		return true;
	}

    void DoSpawnPlayer( PlayerInfo@ p_info )
    {
        if (canSpawnPlayer(p_info))
        {
			//limit how many spawn per second
			if(limit > 0)
			{
				limit--;
				return;
			}
			else
			{
				limit = spawnspam_limit_time;
			}
			
            CPlayer@ player = getPlayerByUsername(p_info.username); // is still connected?

            if (player is null)
            {
				RemovePlayerFromSpawn(p_info);
                return;
            }
            if (player.getTeamNum() != int(p_info.team))
            {
				player.server_setTeamNum(p_info.team);
			}

			// remove previous players blob	  			
			if (player.getBlob() !is null)
			{
				CBlob @blob = player.getBlob();
				blob.server_SetPlayer( null );
				blob.server_Die();					
			}

			p_info.blob_name = "builder"; //hard-set the respawn blob
            CBlob@ playerBlob = SpawnPlayerIntoWorld( getSpawnLocation(p_info), p_info);

            if (playerBlob !is null)
            {
                p_info.spawnsCount++;
                RemovePlayerFromSpawn(player);

				// spawn resources
				SetMaterials( playerBlob, "mat_wood", 500 );
				SetMaterials( playerBlob, "mat_stone", 250 );
				SetMaterials( playerBlob, "mat_gold", 100 );
				//SetMaterials( playerBlob, "mat_arrows", 30 );
            }
        }
    }

    bool canSpawnPlayer(PlayerInfo@ p_info)
    {
        CTFPlayerInfo@ info = cast<CTFPlayerInfo@>(p_info);

        if (info is null) { warn("Zombies LOGIC: Couldn't get player info ( in bool canSpawnPlayer(PlayerInfo@ p_info) ) "); return false; }

        if (force) { return true; }

        return info.can_spawn_time <= 0;
    }

    Vec2f getSpawnLocation(PlayerInfo@ p_info)
	{
		CTFPlayerInfo@ c_info = cast < CTFPlayerInfo@ > (p_info);
		if (c_info !is null)
		{
			CBlob@ pickSpawn = getBlobByNetworkID(c_info.spawn_point);
			if (pickSpawn !is null &&
			        pickSpawn.hasTag("respawn") && pickSpawn.getTeamNum() == p_info.team)
			{
				return pickSpawn.getPosition();
			}
			else
			{
				CBlob@[] spawns;
				PopulateSpawnList(spawns, p_info.team);

				for (uint step = 0; step < spawns.length; ++step)
				{
					if (spawns[step].getTeamNum() == s32(p_info.team))
					{
						return spawns[step].getPosition();
					}
				}
			}
		}

		return Vec2f(0, 0);
	}

    void RemovePlayerFromSpawn(CPlayer@ player)
    {
        RemovePlayerFromSpawn(core.getInfoFromPlayer(player));
    }
    
    void RemovePlayerFromSpawn(PlayerInfo@ p_info)
    {
        CTFPlayerInfo@ info = cast<CTFPlayerInfo@>(p_info);
        
        if (info is null) { warn("Zombies LOGIC: Couldn't get player info ( in void RemovePlayerFromSpawn(PlayerInfo@ p_info) )"); return; }

        string propname = "Zombies spawn time "+info.username;
        
        for (uint i = 0; i < Zombies_core.teams.length; i++)
        {
			CTFTeamInfo@ team = cast<CTFTeamInfo@>(Zombies_core.teams[i]);
			int pos = team.spawns.find(info);

			if (pos != -1) {
				team.spawns.erase(pos);
				break;
			}
		}
		
		Zombies_core.rules.set_u8( propname, 255 ); //not respawning
		Zombies_core.rules.SyncToPlayer( propname, getPlayerByUsername(info.username) ); 
		
		info.can_spawn_time = 0;
	}

    void AddPlayerToSpawn( CPlayer@ player )
    {
		s32 tickspawndelay = 0;
		if (player.getDeaths() != 0)
		{
			int gamestart = getRules().get_s32("gamestart");
			int day_cycle = getRules().daycycle_speed*60;
			int timeElapsed = ((getGameTime()-gamestart)/getTicksASecond()) % day_cycle;
			tickspawndelay = (day_cycle - timeElapsed)*getTicksASecond();
			if (timeElapsed<5) tickspawndelay=0; // less than 5 secs into day 
		}
        
        CTFPlayerInfo@ info = cast<CTFPlayerInfo@>(core.getInfoFromPlayer(player));

        if (info is null) { warn("Zombies LOGIC: Couldn't get player info  ( in void AddPlayerToSpawn(CPlayer@ player) )"); return; }

		RemovePlayerFromSpawn(player);
		if (player.getTeamNum() == core.rules.getSpectatorTeamNum())
			return;

		if (info.team < Zombies_core.teams.length)
		{
			CTFTeamInfo@ team = cast<CTFTeamInfo@>(Zombies_core.teams[info.team]);
			
			info.can_spawn_time = tickspawndelay;
			
			info.spawn_point = player.getSpawnPoint();
			team.spawns.push_back(info);
		}
		else
		{
			error("PLAYER TEAM NOT SET CORRECTLY!");
		}
    }

	bool isSpawning( CPlayer@ player )
	{
		CTFPlayerInfo@ info = cast<CTFPlayerInfo@>(core.getInfoFromPlayer(player));
		for (uint i = 0; i < Zombies_core.teams.length; i++)
        {
			CTFTeamInfo@ team = cast<CTFTeamInfo@>(Zombies_core.teams[i]);
			int pos = team.spawns.find(info);

			if (pos != -1) {
				return true;
			}
		}
		return false;
	}
};

shared class ZombiesCore : RulesCore
{
    s32 warmUpTime;
    s32 gameDuration;
    s32 spawnTime;

    ZombiesSpawns@ Zombies_spawns;
    ZombiesCore() {}
    ZombiesCore(CRules@ _rules, RespawnSystem@ _respawns )
    {
        super(_rules, _respawns );
    }
    void Setup(CRules@ _rules = null, RespawnSystem@ _respawns = null)
    {
        RulesCore::Setup(_rules, _respawns);
        @Zombies_spawns = cast<ZombiesSpawns@>(_respawns);
        server_CreateBlob( "Entities/Meta/WARMusic.cfg" );
		int gamestart = getGameTime();
		rules.set_s32("gamestart",gamestart);
		rules.SetCurrentState(WARMUP);
    }

    void Update()
    {		
        if (rules.isGameOver()) { return; }

		s32 ticksToStart = warmUpTime - getGameTime();
		Zombies_spawns.force = false;

		if (ticksToStart <= 0 && (rules.isWarmup()))
		{
			rules.SetCurrentState(GAME);
		}
		else if (ticksToStart > 0 && rules.isWarmup())
		{
			Zombies_spawns.force = true;
		}   		

		int day_cycle = getRules().daycycle_speed * 60;
		int transition = rules.get_s32("transition");
		int max_zombies = rules.get_s32("max_zombies");
		int num_zombies = rules.get_s32("num_zombies");
		int gamestart = rules.get_s32("gamestart");
		int timeElapsed = getGameTime()-gamestart;
		float difficulty = 2.0*(getGameTime()-gamestart)/getTicksASecond()/day_cycle;
		float actdiff = 4.0*((getGameTime()-gamestart)/getTicksASecond()/day_cycle);
		int dayNumber = ((getGameTime()-gamestart)/getTicksASecond()/day_cycle)+1;
		if (actdiff>9) { actdiff=9; difficulty=difficulty-1.0; } else { difficulty=1.0; }
		
		rules.set_f32("difficulty",difficulty/3.0);
		int intdif = difficulty;
		if (intdif<=0) intdif=1;
		int spawnRate = getTicksASecond() * (6-(difficulty/2.0));
		int extra_zombies = 0;
		if (dayNumber > 10) extra_zombies=(dayNumber-10)*10;
		if (extra_zombies>max_zombies-10) extra_zombies=max_zombies-10;
		if (spawnRate<8) spawnRate=8;
		int wraiteRate = 2 + (intdif/4);
		if (getGameTime() % 300 == 0)
		{
			CBlob@[] zombie_blobs;
			getBlobsByTag("zombie", @zombie_blobs );
			num_zombies = zombie_blobs.length;
			rules.set_s32("num_zombies",num_zombies);			
		}
			
	    if (getGameTime() % (spawnRate) == 0 && num_zombies<100+extra_zombies)
        {			
			CMap@ map = getMap();
			if (map !is null)
			{
				Vec2f[] zombiePlaces;
				rules.SetGlobalMessage( "Day "+ dayNumber);			
				
				getMap().getMarkers("zombie spawn", zombiePlaces );
				
				if (zombiePlaces.length<=0)
				{
					
					for (int zp=8; zp<16; zp++)
					{
						Vec2f col;
						getMap().rayCastSolid( Vec2f(zp*8, 0.0f), Vec2f(zp*8, map.tilemapheight*8), col );
						col.y-=16.0;
						zombiePlaces.push_back(col);
						
						getMap().rayCastSolid( Vec2f((map.tilemapwidth-zp)*8, 0.0f), Vec2f((map.tilemapwidth-zp)*8, map.tilemapheight*8), col );
						col.y-=16.0;
						zombiePlaces.push_back(col);
					}
					//zombiePlaces.push_back(Vec2f((map.tilemapwidth-8)*4,(map.tilemapheight/2)*8));
				}
				//if (map.getDayTime()>0.1 && map.getDayTime()<0.2)
				if (map.getDayTime()>0.7 && map.getDayTime()<1.0)
				{
					//Vec2f sp(XORRandom(4)*(map.tilemapwidth/4)*8+(90*8),(map.tilemapheight/2)*8);
					
				//	Vec2f sp = zombiePlaces[XORRandom(zombiePlaces.length)];
				//	int r;
				//	if (actdiff>9) r = XORRandom(9); else r = XORRandom(actdiff);
				//	int rr = XORRandom(8);
				//	if (r==8 && rr<wraiteRate)
				//	server_CreateBlob( "wraith", -1, sp);
				//	else										
				//	if (r==7 && rr<3)
				//	server_CreateBlob( "greg", -1, sp);
				//	else					
				//	if (r==6)
				//	server_CreateBlob( "zombieknight", -1, sp);
				//	else
				//	if (r>=3)
				//	server_CreateBlob( "zombie", -1, sp);
				//	else
				//	server_CreateBlob( "skeleton", -1, sp);
				//	server_CreateBlob( "zombiechicken", -1, sp);
//
				//	if (transition == 1 && (dayNumber % 5) == 0)
				//	{
				//		transition=0;
				//		rules.set_s32("transition",0);
				//		Vec2f sp = zombiePlaces[XORRandom(zombiePlaces.length)];
				//		server_CreateBlob( "abomination", -1, sp);
				//	}
					
				}
				else
				{
					if (transition == 0)
					{	
						rules.set_s32("transition",1);
					}
				}
			}
		}
		
        RulesCore::Update(); //update respawns
        CheckTeamWon();

    }

    void SetupBase(CBlob@ base)
	{
		if (base is null)
		{
			return;
		}

		//nothing to do
	}
	void SetupBases()
	{
		// destroy all previous spawns if present
		CBlob@[] oldBases;
		getBlobsByName(base_name(), @oldBases);

		for (uint i = 0; i < oldBases.length; i++)
		{
			oldBases[i].server_Die();
		}

		CMap@ map = getMap();

		if (map !is null && map.tilemapwidth != 0)
		{
			Vec2f respawnPos;
			f32 mapcenter = (map.tilemapwidth/2) * 8.0f;
			
			respawnPos = Vec2f(mapcenter, map.getLandYAtX(mapcenter / map.tilesize) * map.tilesize - 16.0f);
			
			respawnPos.y -= 8.0f;
			SetupBase(server_CreateBlob(base_name(), 0, respawnPos));

			map.server_SetTile(respawnPos + Vec2f(-16, 16), CMap::tile_bedrock);
			map.server_SetTile(respawnPos + Vec2f(-8, 16), CMap::tile_bedrock);
			map.server_SetTile(respawnPos + Vec2f(0, 16), CMap::tile_bedrock);
			map.server_SetTile(respawnPos + Vec2f(8, 16), CMap::tile_bedrock);
			map.server_SetTile(respawnPos + Vec2f(16, 16), CMap::tile_bedrock);

			map.server_SetTile(respawnPos + Vec2f(-24, 24), CMap::tile_bedrock);
			map.server_SetTile(respawnPos + Vec2f(-16, 24), CMap::tile_bedrock);
			map.server_SetTile(respawnPos + Vec2f(-8, 24), CMap::tile_bedrock);
			map.server_SetTile(respawnPos + Vec2f(0, 24), CMap::tile_bedrock);
			map.server_SetTile(respawnPos + Vec2f(8, 24), CMap::tile_bedrock);
			map.server_SetTile(respawnPos + Vec2f(16, 24), CMap::tile_bedrock);
			map.server_SetTile(respawnPos + Vec2f(24, 24), CMap::tile_bedrock);
		}
		else
		{
			SetupBase(server_CreateBlob(base_name(), 0, Vec2f(0,0)));
		}
		//rules.SetCurrentState(WARMUP);
	}

    //team stuff

    void AddTeam(CTeam@ team)
    {
        CTFTeamInfo t(teams.length, team.getName());
        teams.push_back(t);
    }

    void AddPlayer(CPlayer@ player, u8 team = 0, string default_config = "")
    {
        CTFPlayerInfo p(player.getUsername(), 0, "builder" );
        players.push_back(p);
        ChangeTeamPlayerCount(p.team, 1);
		getRules().Sync("gold_structures",true);
    }

	void onPlayerDie(CPlayer@ victim, CPlayer@ killer, u8 customData)
	{
		if (!rules.isMatchRunning()) { return; }

		if (victim !is null )
		{
			if (killer !is null && killer.getTeamNum() != victim.getTeamNum())
			{
				addKill(killer.getTeamNum());
			}
		}
	}

    //checks
    void CheckTeamWon( )
    {
        if (!rules.isMatchRunning()) { return; }
		//set up an array of which teams are alive
		array<bool> teams_alive;
		s32 teams_alive_count = 0;
		for (int i = 0; i < teams.length; i++)
			teams_alive.push_back(false);

		//check with each player
		for (int i = 0; i < getPlayersCount(); i++)
		{
			CPlayer@ p = getPlayer(i);
			CBlob@ b = p.getBlob();
			s32 team = p.getTeamNum();
			if (b !is null && //blob alive
			        team >= 0 && team < teams.length) //team sensible
			{
				if (!teams_alive[team])
				{
					teams_alive[team] = true;
					teams_alive_count++;
				}
			}
		}

		bool[] has_hall(teams.length, false);

		//mask out teams that have halls
		CBlob@[] bases;
		getBlobsByName(base_name(), @bases);

		if (bases.length == 0)
		{
			rules.SetCurrentState(GAME_OVER);
			int gamestart = rules.get_s32("gamestart");			
			int day_cycle = getRules().daycycle_speed*60;			
			int dayNumber = ((getGameTime()-gamestart)/getTicksASecond()/day_cycle)+1;
            rules.SetGlobalMessage( "                     Gameover! \n The Sacred Stone Was destroyed \n                       On day "+ dayNumber);
		}
		else if (teams_alive_count == 0)
		{
			rules.SetCurrentState(GAME_OVER);
			int gamestart = rules.get_s32("gamestart");			
			int day_cycle = getRules().daycycle_speed*60;			
			int dayNumber = ((getGameTime()-gamestart)/getTicksASecond()/day_cycle)+1;
            rules.SetGlobalMessage( "You survived for "+ dayNumber+" days" );
		}
    }

    void addKill(int team)
    {
        if (team >= 0 && team < int(teams.length))
        {
            CTFTeamInfo@ team_info = cast<CTFTeamInfo@>( teams[team] );
        }
    }

};

void onInit(CRules@ this)
{
	Reset(this);
    this.set_s32("restart_rules_after_game_time", 15 * 30); // endgame nextmap timer	
}

void onRestart(CRules@ this)
{
	Reset(this);
}

void Reset(CRules@ this)
{
    ZombiesSpawns spawns();
    ZombiesCore core(this, spawns);
    Config(core);
    core.SetupBases();
    this.set("core", @core);
    this.set("start_gametime", getGameTime() + core.warmUpTime);
    this.set_u32("game_end_time", getGameTime() + core.gameDuration); //for TimeToEnd.as  
	this.set_bool("everyones_dead",false);
}

