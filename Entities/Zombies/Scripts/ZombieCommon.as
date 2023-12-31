
namespace ZombieStates
{
	enum States
	{
		normal = 0,
		attack_drawn,
		attack_start,
		attack_mid,
		attack_mid_down,
		attack_up,
		attack_down,
		attack_power,
		attack_power_super
	}
}

const string[] ZombieNames = 
{ 
	"skeleton",
	"zombie",
	"zombiechicken",
	"zombiebunny",
	"zombieknight",
	"abomination",
	"wraith",
	"greg",
};

shared class ZombieInfo
{	
	u8 BlobDamageAmount;
	u8 TileDamageAmount;
	u8 AttackCooldownTime;
	u8 AttackArcDegrees;
	u8 AttackDistance;
	u8 AttackChargeLimit;
	u8 AttackHitLimitCount;
	bool DoubleAttack;

	string attackSound;
	string IdleSound;
	string DieSound;

	u8 AttackChargeTimer;
	u8 tileDestructionLimiter;
	u8 state;	
	Vec2f attack_direction;
};


void SetupInfo(CBlob@ this)
{
	string blobname = this.getName();
	ZombieInfo zombie;

	switch (ZombieNames.find(blobname))
	{
		case 0: //skeleton
		zombie.AttackChargeLimit   = 15;
		zombie.BlobDamageAmount    = 5;
		zombie.TileDamageAmount    = 1;
		zombie.AttackCooldownTime  = 15;
		zombie.AttackArcDegrees    = 60;
		zombie.AttackDistance 	   = 25;
		zombie.AttackChargeLimit   = 25;
		zombie.AttackHitLimitCount = 1;
		break;

		case 1: //zombie
		zombie.AttackChargeLimit   = 17;
		zombie.BlobDamageAmount    = 10;
		zombie.TileDamageAmount    = 10;
		zombie.AttackCooldownTime  = 15;
		zombie.AttackArcDegrees    = 60;
		zombie.AttackDistance 	   = 25;
		zombie.AttackChargeLimit   = 25;
		zombie.AttackHitLimitCount = 1;
		break;

		case 2: //zombiechicken
		zombie.AttackChargeLimit   = 13;
		zombie.BlobDamageAmount    = 10;
		zombie.TileDamageAmount    = 10;
		zombie.AttackCooldownTime  = 15;
		zombie.AttackArcDegrees    = 60;
		zombie.AttackDistance 	   = 25;
		zombie.AttackChargeLimit   = 25;
		zombie.AttackHitLimitCount = 1;
		break;

		case 4: //zombieknight
		zombie.AttackChargeLimit   = 25;
		zombie.BlobDamageAmount    = 10;
		zombie.TileDamageAmount    = 10;
		zombie.AttackCooldownTime  = 15;
		zombie.AttackArcDegrees    = 60;
		zombie.AttackDistance 	   = 25;
		zombie.AttackChargeLimit   = 25;
		zombie.AttackHitLimitCount = 3;
		break;

		case 5: //abomination
		zombie.AttackChargeLimit   = 25;
		zombie.BlobDamageAmount    = 10;
		zombie.TileDamageAmount    = 10;
		zombie.AttackCooldownTime  = 15;
		zombie.AttackArcDegrees    = 60;
		zombie.AttackDistance 	   = 25;
		zombie.AttackChargeLimit   = 25;
		zombie.AttackHitLimitCount = 1;
		break;

		case 6: //wraith
		zombie.AttackChargeLimit   = 12;
		zombie.BlobDamageAmount    = 10;
		zombie.TileDamageAmount    = 10;
		zombie.AttackCooldownTime  = 15;
		zombie.AttackArcDegrees    = 60;
		zombie.AttackDistance 	   = 25;
		zombie.AttackChargeLimit   = 25;
		zombie.AttackHitLimitCount = 1;
		break;

		default: //zombie name not listed
		zombie.AttackChargeLimit   = 15;
		zombie.BlobDamageAmount    = 10;
		zombie.TileDamageAmount    = 10;
		zombie.AttackCooldownTime  = 15;
		zombie.AttackArcDegrees    = 60;
		zombie.AttackDistance 	   = 25;
		zombie.AttackChargeLimit   = 25;
		zombie.AttackHitLimitCount = 1;
		break;
	}

	this.set("zombieInfo", @zombie);
}

shared class ZombieMovementVars
{
	Vec2f walkForce;  
	Vec2f runForce ;
	Vec2f slowForce;
	Vec2f jumpForce;
	f32 maxVelocity;
	f32 flyModifier;
};

void SetupMoveVars(CBlob@ this)
{
	string blobname = this.getName();
	ZombieMovementVars vars;
	//float difficulty = getRules().get_f32("difficulty")/4.0;

	switch (ZombieNames.find(blobname))
	{
		case 0: //skeleton
		vars.walkForce.Set(3.0f,0.0f);
		vars.runForce.Set( 4.0f,0.0f);
		vars.slowForce.Set(1.5f,0.0f);
		vars.jumpForce.Set(0.0f,-1.2f);
		vars.maxVelocity  = 1.0f;
		break;

		case 1: //zombie
		vars.walkForce.Set(2.0f,0.0f);
		vars.runForce.Set(3.0f,0.0f);
		vars.slowForce.Set(3.0f,0.0f);
		vars.jumpForce.Set(0.0f,-1.2f);
		vars.maxVelocity  = 1.0f;
		break;

		case 2: //zombiechicken
		vars.walkForce.Set(6.0f,0.0f);
		vars.runForce.Set( 5.0f,0.0f);
		vars.slowForce.Set(6.0f,0.0f);
		vars.jumpForce.Set(0.0f,-1.5f);
		vars.maxVelocity  = 1.0f;
		break;

		case 4: //zombieknight
		vars.walkForce.Set(2.0f,0.0f);
		vars.runForce.Set( 3.0f,0.0f);
		vars.slowForce.Set(1.5f,0.0f);
		vars.jumpForce.Set(0.0f,-1.0f);
		vars.maxVelocity  = 1.0f;
		break;

		case 5: //abomination
		vars.walkForce.Set(1.0f,0.0f);
		vars.runForce.Set( 2.0f,0.0f);
		vars.slowForce.Set(1.5f,0.0f);
		vars.jumpForce.Set(0.0f,-1.0f);
		vars.maxVelocity  = 1.0f;
		break;

		case 6: //wraith
		vars.walkForce.Set(3.0f,7.0f); //fly force
		vars.runForce.Set( 10.0f,10.0f);
		vars.slowForce.Set(5.5f,5.5f);
		vars.jumpForce.Set(0.0f, 12.0f); // min height/tiles away from ground
		vars.maxVelocity  = 3.0f;
		break;

		case 7: //greg
		vars.walkForce.Set(15.0f,15.0f);
		vars.runForce.Set( 15.0f,0.0f);
		vars.slowForce.Set(5.5f,0.0f);
		vars.jumpForce.Set(0.0f,-34.0f);
		vars.maxVelocity  = 3.0f;
		vars.flyModifier = 1.0f;
		break;

		default: //zombie name not listed
		vars.walkForce.Set(4.0f,0.0f);
		vars.runForce.Set( 4.0f,0.0f);
		vars.slowForce.Set(1.5f,0.0f);
		vars.jumpForce.Set(0.0f,-1.0f);
		vars.maxVelocity  = 1.0f;
		break;
	}

	this.set( "vars", vars );
}

void zombie_actorlimit_setup(CBlob@ this)
{
	u16[] networkIDs;
	this.set("LimitedActors", networkIDs);
}

bool zombie_has_hit_actor(CBlob@ this, CBlob@ actor)
{
	u16[]@ networkIDs;
	this.get("LimitedActors", @networkIDs);
	return networkIDs.find(actor.getNetworkID()) >= 0;
}

u32 zombie_hit_actor_count(CBlob@ this)
{
	u16[]@ networkIDs;
	this.get("LimitedActors", @networkIDs);
	return networkIDs.length;
}

void zombie_add_actor_limit(CBlob@ this, CBlob@ actor)
{
	this.push("LimitedActors", actor.getNetworkID());
}

void zombie_clear_actor_limits(CBlob@ this)
{
	this.clear("LimitedActors");
}

////checking state stuff

bool isAttackState(u8 state)
{
	return (state >= ZombieStates::attack_drawn && state <= ZombieStates::attack_power_super);
}

bool inMiddleOfAttack(u8 state)
{
	return ((state > ZombieStates::attack_drawn && state <= ZombieStates::attack_power_super));
}

//checking angle stuff
f32 getCutAngle(CBlob@ this, u8 state)
{
	f32 attackAngle = (this.isFacingLeft() ? 180.0f : 0.0f);

	if (state == ZombieStates::attack_mid)
	{
		attackAngle += (this.isFacingLeft() ? 30.0f : -30.0f);
	}
	else if (state == ZombieStates::attack_mid_down)
	{
		attackAngle -= (this.isFacingLeft() ? 30.0f : -30.0f);
	}
	else if (state == ZombieStates::attack_up)
	{
		attackAngle += (this.isFacingLeft() ? 80.0f : -80.0f);
	}
	else if (state == ZombieStates::attack_down)
	{
		attackAngle -= (this.isFacingLeft() ? 80.0f : -80.0f);
	}

	return attackAngle;
}

f32 getCutAngle(CBlob@ this)
{
	Vec2f aimpos = this.getMovement().getVars().aimpos;
	int tempState;
	Vec2f vec;
	int direction = this.getAimDirection(vec);

	if (direction == -1)
	{
		tempState = ZombieStates::attack_up;
	}
	else if (direction == 0)
	{
		if (aimpos.y < this.getPosition().y)
		{
			tempState = ZombieStates::attack_mid;
		}
		else
		{
			tempState = ZombieStates::attack_mid_down;
		}
	}
	else
	{
		tempState = ZombieStates::attack_down;
	}

	return getCutAngle(this, tempState);
}