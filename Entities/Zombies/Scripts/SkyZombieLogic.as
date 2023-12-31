#include "ZombieCommon.as";

void onInit(CBlob@ this)
{
	SetupInfo(this);	
	this.getShape().SetRotationsAllowed(false);
	this.Tag("flesh");
	this.Tag("zombie");
	this.getCurrentScript().runFlags = Script::tick_not_attached;
	this.getShape().SetGravityScale(0.5f);
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
    return false; //maybe make a knocked out state? for loading to cata?
}

void onTick(CBlob@ this)
{
	ZombieInfo@ zombie;
	if (!this.get("zombieInfo", @zombie))
	{
		return;
	}

	Vec2f pos = this.getPosition();
	Vec2f vel = this.getVelocity();
	Vec2f aimpos = this.getAimPos();	
	
	if (this.isKeyPressed(key_left)) {
		this.SetFacingLeft( true );
	}
	else 
	if (this.isKeyPressed(key_right)) {
		this.SetFacingLeft( false );
	}

	bool attackState = isAttackState(zombie.state);
	bool walking = (this.isKeyPressed(key_left) || this.isKeyPressed(key_right));

	Vec2f vec;

	const int direction = this.getAimDirection(vec);
	const f32 side = (this.isFacingLeft() ? 1.0f : -1.0f);
	
	if (zombie.state == ZombieStates::attack_drawn)
	{		
		zombie_clear_actor_limits(this);
		if (zombie.AttackChargeTimer < 255)
		{
			zombie.AttackChargeTimer++;
		}
		//else
		//{
		//	zombie.state = ZombieStates::normal;
		//	zombie.AttackChargeTimer = 0;
		//	//warn("AttackChargeTimer didnt work");
		//}
	}
	else if (zombie.state == ZombieStates::attack_start)
	{	
		f32 swoopangle = (aimpos - pos).Angle();
		Swoop(this, (aimpos - pos));
	}

	if (!attackState && getNet().isServer())
	{
		zombie_clear_actor_limits(this);
		zombie.AttackChargeTimer = 0;
		zombie.state = ZombieStates::normal;
	}
}

void Swoop(CBlob@ this, Vec2f pos)
{
	if (!getNet().isServer())
	{
		return;
	}
	
	this.AddForce(pos/8);	
}