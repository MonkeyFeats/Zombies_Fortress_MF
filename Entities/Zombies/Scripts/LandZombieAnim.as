#include "ZombieCommon.as";
#include "Knocked.as";

void onInit(CSprite@ this)
{
	CBlob@ blob = this.getBlob();	
    this.ReloadSprites(blob.getTeamNum(),0); 
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	ZombieInfo@ zombie;
	if (!blob.get("zombieInfo", @zombie)) { return; }

	const u8 knocked = getKnocked(blob);
	bool attackState = isAttackState(zombie.state);
	bool walking = (blob.isKeyPressed(key_left) || blob.isKeyPressed(key_right));
	bool ended = this.isAnimationEnded();
	bool facingLeft = this.isFacingLeft();

	Vec2f vec;
	int direction = blob.getAimDirection(vec);

	if (knocked > 0)
	{
		this.SetAnimation("knocked");
	}
	else if (zombie.state == ZombieStates::normal)
	{		
		this.SetAnimation("idle");		
	}
	else if (zombie.state == ZombieStates::attack_drawn)
	{		
		this.SetAnimation("draw");		
	}
	else if(zombie.state > ZombieStates::attack_drawn)
	{
		if (XORRandom(70)==0)
		{
			this.PlaySound( "/SkeletonAttack" );
		}			
		this.SetAnimation("bite");
	}
	else if (walking)
	{
		this.SetAnimation("walk");
	}	
	//else if (blob.getHealth() <= 0.0)
	//{
	//	if (!this.isAnimation("dead"))
	//	{
	//		this.SetAnimation("dead");
	//		this.PlaySound( "/SkeletonBreak1" );
	//	}
	//	this.getCurrentScript().runFlags |= Script::remove_after_this;
	//}
	else
	{
		if (XORRandom(200)==0)
		{
			this.PlaySound( "/SkeletonSayDuh" );
		}
		this.SetAnimation("idle");
	}
}

void onGib(CSprite@ this)
{
    if (g_kidssafe) {
        return;
    }

    CBlob@ blob = this.getBlob();
    Vec2f pos = blob.getPosition();
    Vec2f vel = blob.getVelocity();
	vel.y -= 3.0f;
    f32 hp = Maths::Min(Maths::Abs(blob.getHealth()), 2.0f) + 1.0;
	const u8 team = blob.getTeamNum();
    CParticle@ Body     = makeGibParticle( "ZombieGibs.png", pos, vel + getRandomVelocity( 90, hp , 80 ),       0, 0, Vec2f (8,8), 2.0f, 20, "/BodyGibFall", team );
    CParticle@ Arm1     = makeGibParticle( "ZombieGibs.png", pos, vel + getRandomVelocity( 90, hp - 0.2 , 80 ), 0, 1, Vec2f (8,8), 2.0f, 20, "/BodyGibFall", team );
    CParticle@ Arm2     = makeGibParticle( "ZombieGibs.png", pos, vel + getRandomVelocity( 90, hp - 0.2 , 80 ), 0, 2, Vec2f (8,8), 2.0f, 20, "/BodyGibFall", team );
    CParticle@ Shield   = makeGibParticle( "ZombieGibs.png", pos, vel + getRandomVelocity( 90, hp , 80 ),       0, 3, Vec2f (8,8), 2.0f, 0,  "/BodyGibFall", team );
    CParticle@ Attack   = makeGibParticle( "ZombieGibs.png", pos, vel + getRandomVelocity( 90, hp + 1 , 80 ),   0, 4, Vec2f (8,8), 2.0f, 0,  "/BodyGibFall", team );
}

