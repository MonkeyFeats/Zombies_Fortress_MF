#include "BlobTextures.as"

const string fuel = "mat_wood";
const string steel_ore = "mat_steel";
//const string copper_ore =  "mat_copper";
const string gold_ore =  "mat_gold";

//balance
const int input = 250;					//input cost in fuel
const int output = 25;					//output amount in ore

const int fuel_min_input = Maths::Ceil(input/output);

const bool has_ore = false;

const int ore_needed = 100;
const int max_ore = 100;
const int mid_ore = 50;
const int low_ore = 25;

const int max_fuel = 500;
const int mid_fuel = 250;
const int low_fuel = 125;

//property names
const string fuel_prop = "fuel_level";
const string ore_prop = "ore_level";
const string working_prop = "working";

void onInit(CSprite@ this)
{
	addBlobTextures(this, "foundry", "Foundry");
	ensureCorrectBlobTexture(this, "foundry", "Foundry");	
	string texname = getBlobTextureName(this);

	this.ReloadSprites(8, 0);			

	this.RemoveSpriteLayer("crucible");	

	CSpriteLayer@ crucible = this.addTexturedSpriteLayer("crucible", texname, 16, 16);
	if (crucible !is null)
	{		
		Animation@ anim = crucible.addAnimation("default", 0, true);
		int[] frames = { 7, 15, 19, 20, 21, 22, 23, 27, 7};
		anim.AddFrames(frames);		

		crucible.SetOffset(Vec2f(-15.0f, -1.0f));
		crucible.SetRelativeZ(-2.0f);
		crucible.SetVisible(true);
	}

	CSpriteLayer@ shoot = this.addTexturedSpriteLayer("shoot", texname, 32, 16);
	if (shoot !is null)
	{		
		Animation@ anim = shoot.addAnimation("default", 0, true);
		int[] frames = { 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31 };
		anim.AddFrames(frames);

		shoot.SetRelativeZ(0.25f);
		shoot.SetOffset(Vec2f(8.0f, 7.0f));
		shoot.SetVisible(false);
	}

	//this.SetEmitSound("/Quarry.ogg");
	//this.SetEmitSoundPaused(true);
}

void onInit(CBlob@ this)
{
	this.server_setTeamNum(8);			
	this.set_TileType("background tile", CMap::tile_castle_back);
	this.getSprite().SetZ(-50);
	this.getShape().getConsts().mapCollisions = false;

	this.set_s16(fuel_prop, 0);
	this.set_bool(working_prop, false);	

	this.addCommandID("add fuel");
	this.addCommandID("add ore");
}

void onTick(CBlob@ this)
{
	if(getNet().isServer())
	{
		int fuelCount = this.get_s16(fuel_prop);
		int oreCount = this.get_s16(ore_prop);

		if ((fuelCount >= fuel_min_input) && (oreCount == ore_needed))
		{
			if (!this.get_bool(working_prop))
			{
				this.set_f32("production time", getGameTime());	
				this.set_bool(working_prop, true);
				this.Sync(working_prop, true);
			  //this.Sync(fuel_prop, true);
			}
		}
		if (this.get_bool(working_prop))
		{
			f32 production_time = (getGameTime() - this.get_f32("production time"));
			animateCrucible(this, production_time);

			if (production_time/60 == 15)
			{
				spawnOre(this);
			}			
		}
	}

	CSprite@ sprite = this.getSprite();
	if (sprite.getEmitSoundPaused())
	{
		if (this.get_bool(working_prop))
		{
			sprite.SetEmitSoundPaused(false);
		}
	}
	else if (!this.get_bool(working_prop))
	{
		sprite.SetEmitSoundPaused(true);
	}
}

void animateCrucible(CBlob@ this, f32 production_time)
{
	CSprite@ sprite = this.getSprite();
	if (sprite is null) return;
	CSpriteLayer@ crucible = sprite.getSpriteLayer("crucible");
	if (crucible is null) return;
	Animation@ crucible_anim = crucible.getAnimation("default");
	if (crucible_anim is null) return;	
	CSpriteLayer@ shoot = sprite.getSpriteLayer("shoot");
	if (shoot is null) return;
	Animation@ shoot_anim = shoot.getAnimation("default");
	if (shoot_anim is null) return;	

	u16 production_time_secs = production_time/60;
	f32 gametime = getGameTime();	

	if (production_time_secs < 11)
	{
		if (production_time_secs == 2)
		{
			crucible_anim.frame = 1;
		}
	}
	else if (production_time_secs >= 11 && production_time_secs < 12)
	{
		crucible.RotateBy(-1, Vec2f(0,4)); //tilt down
	}
	else if (production_time_secs >= 12 && production_time_secs < 13)
	{		
		shoot.SetVisible(true);
		if (gametime % 5 == 0)
		crucible_anim.frame++;
		if (gametime % 3 == 0)		
		shoot_anim.frame++;
	}
	else if (production_time_secs >= 13 && production_time_secs < 14)
	{
		crucible.RotateBy( 1, Vec2f(0,4)); //tilt up
		shoot.SetVisible(false);
		shoot_anim.frame = crucible_anim.frame = 0;
	}

	if (production_time_secs < 11)
	{
		Vec2f SteamPos = this.getPosition()+Vec2f(15,-8);

		if (gametime % 6 == 0)
		makeSteamParticle(this, Vec2f(), SteamPos, production_time_secs*3.0f);
	}
	else if (production_time_secs < 18)
	{
		Vec2f SteamPos = this.getPosition()+Vec2f(Maths::Max( -10 ,15-(production_time_secs-10)*8.5f), Maths::Min( 8 ,-8+(production_time_secs-10)*8.0f));

		if (gametime % 3 == 0)
		makeSteamParticle(this, Vec2f(), SteamPos, production_time_secs*2.6f);
	}
}

void spawnOre(CBlob@ this)
{
	int oreCount = this.get_s16(ore_prop);
	int actual_input = Maths::Min(input, oreCount);

	CBlob@ _ore = server_CreateBlobNoInit("mat_refined_gold");

	if (_ore is null) return;

	int amountToSpawn = 25; //Maths::Floor(output * actual_input / input);
	//round to 5
	int remainder = amountToSpawn % 5;
	amountToSpawn += (remainder < 3 ? -remainder : (5 - remainder));
	//setup res
	_ore.Tag("custom quantity");
	_ore.Init();
	_ore.setPosition(this.getPosition() + Vec2f(-8.0f, 0.0f));
	_ore.server_SetQuantity(amountToSpawn);

	this.set_s16(fuel_prop, oreCount - actual_input); //burn wood

	this.set_bool(working_prop, false);
	this.Sync(working_prop, true);
}

void makeSteamParticle(CBlob@ this, const Vec2f vel, Vec2f pos, u16 xDist)
{
	if (!getNet().isClient()) return;
	const string filename = "SmallSteam";

	const f32 rad = this.getRadius();
	Vec2f random = Vec2f(XORRandom(xDist) - xDist/2, XORRandom(12) - 6) * 0.015625f * rad;
	ParticleAnimated(CFileMatcher(filename).getFirst(), pos + random, vel, float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -0.1f, false);
}

//void makeSteamPuff(CBlob@ this, const f32 velocity = 1.0f, const int smallparticles = 1, const bool sound = true)
//{
//	if (sound)
//	{
//		this.getSprite().PlaySound("Steam.ogg");
//	}
//
//	makeSteamParticle(this, Vec2f(), "MediumSteam", Vec2f());
//	for (int i = 0; i < smallparticles; i++)
//	{
//		f32 randomness = (XORRandom(8) + 8) * 0.015625f * 0.5f + 0.75f;
//		Vec2f vel = getRandomVelocity(-90, velocity * randomness, 360.0f);
//		makeSteamParticle(this, vel, Vec2f());
//	}
//}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());

	if (this.get_s16(fuel_prop) < max_fuel)
	{
		CButton@ fuel_button = caller.CreateGenericButton("$mat_wood$", Vec2f(6.0f, 5.0f), this, this.getCommandID("add fuel"), getTranslatedString("Add fuel"), params);
		if (fuel_button !is null)
		{
			fuel_button.deleteAfterClick = false;
			fuel_button.SetEnabled(caller.hasBlob(fuel, 1));
		}
	}
	if (this.get_s16(ore_prop) < max_ore)
	{
		CButton@ ore_button = caller.CreateGenericButton("$mat_gold$", Vec2f(6.0f, -4.0f), this, this.getCommandID("add ore"), getTranslatedString("Add ore"), params);
		if (ore_button !is null)
		{
			ore_button.deleteAfterClick = false;
			ore_button.SetEnabled(caller.hasBlob("mat_gold", 1));
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("add fuel"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if(caller is null) return;

		int requestedAmount = Maths::Min(250, max_fuel - this.get_s16(fuel_prop));
		if (requestedAmount <= 0) return;

		CBlob@ carried = caller.getCarriedBlob();
		int callerQuantity = caller.getInventory().getCount(fuel) + (carried !is null && carried.getName() == fuel ? carried.getQuantity() : 0);

		int ammountToStore = Maths::Min(requestedAmount, callerQuantity);
		if(ammountToStore > 0)
		{
			caller.TakeBlob(fuel, ammountToStore);
			this.set_s16(fuel_prop, this.get_s16(fuel_prop) + ammountToStore);
		}
	}

	if (cmd == this.getCommandID("add ore"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if(caller is null) return;

		int requestedAmount = Maths::Min(250, max_ore - this.get_s16(ore_prop));
		if (requestedAmount <= 0) return;

		CBlob@ carried = caller.getCarriedBlob();
		int callerQuantity = caller.getInventory().getCount(gold_ore) + (carried !is null && carried.getName() == gold_ore ? carried.getQuantity() : 0);

		int ammountToStore = Maths::Min(requestedAmount, callerQuantity);
		if(ammountToStore > 0)
		{
			caller.TakeBlob(gold_ore, ammountToStore);
			this.set_s16(ore_prop, this.get_s16(ore_prop) + ammountToStore);
		}
	}
}