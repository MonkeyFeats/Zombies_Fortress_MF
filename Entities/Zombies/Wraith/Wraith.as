
#include "FireCommon.as";
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

	
	if (blob.hasTag("activated"))
	{
		if (XORRandom(70)==0)
		{
			//this.PlaySound( "/SkeletonAttack" );
		}			
		this.SetAnimation("bite");
	}
	else if (zombie.state == ZombieStates::normal)
	{		
		this.SetAnimation("idle");		
	}
	else if (zombie.state == ZombieStates::attack_drawn)
	{		
		this.SetAnimation("draw");		
	}
	else if (walking)
	{
		this.SetAnimation("walk");
	}	
	else
	{
		if (XORRandom(200)==0)
		{
			this.PlaySound( "/SkeletonSayDuh" );
		}
		this.SetAnimation("idle");
	}
}

void onInit(CBlob@ this)
{		
//  this.Tag("bomberman_style");
//	this.set_f32("map_bomberman_width", 24.0f);
    this.set_f32("explosive_radius", 16.0f);
    this.set_f32("explosive_damage",1.0f);
    this.set_u8("custom_hitter", Hitters::keg);
    this.set_string("custom_explosion_sound", "Entities/Items/Explosives/KegExplosion.ogg");
    this.set_f32("map_damage_radius", 48.0f);
    this.set_f32("map_damage_ratio", 0.5f);
    this.set_bool("map_damage_raycast", true);
	this.set_f32("keg_time", 180.0f);
	this.set_bool("explosive_teamkill", true);
}

void onTick(CBlob@ this)
{	
	ZombieInfo@ zombie;
	if (!this.get("zombieInfo", @zombie))
	{
		return;
	}

	if(zombie.state == ZombieStates::attack_drawn)
	{
		if (!this.hasTag("activated"))
		{
			this.Tag("activated");
			this.set_s32("explosion_timer", getGameTime() + this.get_f32("keg_time"));
			this.Tag("exploding");				
			this.Sync("activated",true);
			this.Sync("exploding",true);
			this.Sync("explosion_timer",true);
			server_setFireOn(this);
		}
	}

	if (this.hasTag("activated"))
	{
		this.SetLight( true );
		this.SetLightRadius( 24.0f );
		this.SetLightColor( SColor(255, 211, 121, 224 ) );
		
		s32 timer = this.get_s32("explosion_timer") - getGameTime();
		
		if (timer <= 0)
		{
			if (getNet().isServer()) {
				this.server_SetHealth(-1.0f);
				this.server_Die();				
			}
		}
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (this.hasTag("activated"))
	{
		if (getNet().isServer()) 
		{
			this.server_SetHealth(-1.0f);
			this.server_Die();				
		}		
	}
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	if (blob.hasTag("dead"))
		return false;

	return true;
}