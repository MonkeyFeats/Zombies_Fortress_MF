#include "ZombieCommon.as";
#include "ShieldCommon.as";
#include "Knocked.as";
#include "Hitters.as";

void onInit(CBlob@ this)
{
	SetupInfo(this);
	zombie_actorlimit_setup(this);
	
	this.getBrain().server_SetActive( true );
	this.getShape().SetRotationsAllowed(false);
	this.set_f32("gib health", -0.0f);	
	this.Tag("flesh");
	this.Tag("zombie");

	this.getCurrentScript().runFlags = Script::tick_not_attached;
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
    return this.getTeamNum() == byBlob.getTeamNum(); //maybe make a knocked out state? for loading to cata?
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
	u8 knocked = getKnocked(this);	
	
	
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
	
	if (knocked > 0) //cancel any attacks
	{
		DoKnockedUpdate(this);
		zombie.state = ZombieStates::normal;
		zombie.AttackChargeTimer = 0;
		zombie.DoubleAttack = false;

		walking = false;
	}
	else if (zombie.state == ZombieStates::attack_drawn)
	{		
		zombie_clear_actor_limits(this);
		if (zombie.AttackChargeTimer < 128)
		{
			zombie.AttackChargeTimer++;	
		}
		else
		{
			zombie.state = ZombieStates::normal;
			warn("AttackChargeTimer didnt work");
		}
	}
	else if (inMiddleOfAttack(zombie.state))
	{		
		if (direction == -1)
		{
			zombie.state = ZombieStates::attack_up;
		}
		else if (direction == 0)
		{
			if (aimpos.y < pos.y)
			{
				zombie.state = ZombieStates::attack_mid;
			}
			else
			{
				zombie.state = ZombieStates::attack_mid_down;
			}
		}
		else
		{
			zombie.state = ZombieStates::attack_down;
		}

		f32 attackarc = 60.0f;
		f32 attackAngle = getCutAngle(this, zombie.state);

		if ( attackState && this.getSprite().isAnimation("bite") && this.getSprite().isAnimationEnded())
		{
			DoAttack(this, 1.0f, attackAngle, attackarc, Hitters::bite, zombie);
			zombie.AttackChargeTimer = 0;
			zombie.state = ZombieStates::normal;
		}
	}

	if (!attackState && getNet().isServer())
	{
		zombie_clear_actor_limits(this);
		zombie.AttackChargeTimer = 0;
		zombie.state = ZombieStates::normal;
	}
}

void DoAttack(CBlob@ this, f32 damage, f32 aimangle, f32 arcdegrees, u8 type, ZombieInfo@ info)
{
	if (!getNet().isServer())
	{
		return;
	}

	if (aimangle < 0.0f)
	{
		aimangle += 360.0f;
	}

	Vec2f blobPos = this.getPosition();
	Vec2f vel = this.getVelocity();
	Vec2f thinghy(1, 0);
	thinghy.RotateBy(aimangle);	
	vel.Normalize();	

	f32 radius = this.getRadius();
	f32 attack_distance = radius * 2.0f;

	CMap@ map = this.getMap();
	bool dontHitMore = false;
	bool dontHitMoreMap = false;

	//get the actual aim angle
	f32 exact_aimangle = (this.getAimPos() - blobPos).Angle();

	// this gathers HitInfo objects which contain blob or tile hit information
	HitInfo@[] hitInfos;
	if (map.getHitInfosFromArc(blobPos, aimangle, arcdegrees, attack_distance, this, @hitInfos))
	{
		//HitInfo objects are sorted, first come closest hits
		for (uint i = 0; i < hitInfos.length; i++)
		{
			HitInfo@ hi = hitInfos[i];
			CBlob@ b = hi.blob;
			if (b !is null && !dontHitMore) // blob
			{
				//big things block attacks
				const bool large = b.hasTag("blocks sword") && !b.isAttached() && b.isCollidable();

				if (!canHit(this, b))
				{
					// no TK
					if (large)
						dontHitMore = true;

					continue;
				}

				if (zombie_has_hit_actor(this, b))
				{
					if (large)
						dontHitMore = true;

					continue;
				}

				zombie_add_actor_limit(this, b);
				if (!dontHitMore)
				{
					Vec2f velocity = b.getPosition() - blobPos;
					this.server_Hit(b, hi.hitpos, velocity, damage, type, true);  // server_Hit() is server-side only

					// end hitting if we hit something solid, don't if its flesh
					if (large)
					{
						dontHitMore = true;
					}
				}
			}
			else  // hitmap
			if (!dontHitMoreMap)
			{
				bool ground = map.isTileGround(hi.tile);
				bool dirt_stone = map.isTileStone(hi.tile);
				bool gold = map.isTileGold(hi.tile);
				bool wood = map.isTileWood(hi.tile);					
				bool customtile = hi.tile > 255;
				//if (ground || wood || dirt_stone || gold || customtile)
				{						
					info.tileDestructionLimiter = 0;

					dontHitMoreMap = true;
					map.server_DestroyTile(hi.hitpos, 5.5f, this);						
				}
			}
		}
	}

	// destroy grass

	if (((aimangle >= 0.0f && aimangle <= 180.0f) || damage > 1.0f) ) // hit only once
	{
		f32 tilesize = map.tilesize;
		int steps = Maths::Ceil(2 * radius / tilesize);
		int sign = this.isFacingLeft() ? -1 : 1;

		for (int y = 0; y < steps; y++)
			for (int x = 0; x < steps; x++)
			{
				Vec2f tilepos = blobPos + Vec2f(x * tilesize * sign, y * tilesize);
				TileType tile = map.getTile(tilepos).type;

				if (map.isTileGrass(tile) || tile >= 440 )
				{
					map.server_DestroyTile(tilepos, damage, this);

					//if (damage <= 1.0f)
					//{
					//	return;
					//}
				}
			}
	}
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{		
	if (damage>this.getHealth() && this.getHealth()>0)
	{
		if (hitterBlob.hasTag("player"))
		{
			CPlayer@ player = hitterBlob.getPlayer();
			//player.server_setCoins( player.getCoins() + 10 );		
		} else
		if(hitterBlob.getDamageOwnerPlayer() !is null)
		{
			CPlayer@ player = hitterBlob.getDamageOwnerPlayer();
			//player.server_setCoins( player.getCoins() + 10 );		
		}
		//server_DropCoins(hitterBlob.getPosition() + Vec2f(0,-3.0f), 10);		
	}
	if (customData == Hitters::arrow) damage*=2.0;
	return damage;
}

// Blame Fuzzle.
bool canHit(CBlob@ this, CBlob@ b)
{
	if (b.hasTag("invincible"))
		return false;

	// Don't hit temp blobs and items carried by teammates.
	if (b.isAttached())
	{
		CBlob@ carrier = b.getCarriedBlob();

		if (carrier !is null)
			if (carrier.hasTag("player")
			        && (this.getTeamNum() == carrier.getTeamNum() || b.hasTag("temp blob")))
				return false;

	}

	if (b.hasTag("dead"))
		return true;

	return b.getTeamNum() != this.getTeamNum();

}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	if (blob.hasTag("dead"))
		return false;
	if (!blob.hasTag("zombie") && blob.hasTag("flesh") && this.getTeamNum() == blob.getTeamNum()) return false;
	if (blob.hasTag("zombie") && blob.getHealth()<0.0) return false;
	return true;
}

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	ZombieInfo@ zombie;
	if (!this.get("zombieInfo", @zombie))
	{
		return;
	}

	if (customData == Hitters::bite &&
	        ( //is a jab - note we dont have the dmg in here at the moment :/
	            zombie.state == ZombieStates::attack_mid ||
	            zombie.state == ZombieStates::attack_mid_down ||
	            zombie.state == ZombieStates::attack_up ||
	            zombie.state == ZombieStates::attack_down
	        )
	        && blockAttack(hitBlob, velocity, 0.0f))
	{
		this.getSprite().PlaySound("/Stun", 1.0f, this.getSexNum() == 0 ? 1.0f : 1.5f);
		SetKnocked(this, 30);
	}

	if (customData == Hitters::shield)
	{
		SetKnocked(hitBlob, 20);
		this.getSprite().PlaySound("/Stun", 1.0f, this.getSexNum() == 0 ? 1.0f : 1.5f);
	}
}