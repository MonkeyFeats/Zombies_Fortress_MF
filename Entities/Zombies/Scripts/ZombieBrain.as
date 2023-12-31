//brain

#define SERVER_ONLY

#include "ZombieBrainCommon.as"
#include "ZombieCommon.as"

void onInit( CBrain@ this )
{
	InitBrain(this);
	this.server_SetActive( true );	
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
}

void onTick( CBrain@ this )
{
	SearchTarget(this, true);	

	CBlob@ blob = this.getBlob();
	CBlob@ target = this.getTarget();

	this.getCurrentScript().tickFrequency = 30;	

	if (target !is null)
	{
		this.getCurrentScript().tickFrequency = 1;
		u8 strategy = blob.get_u8("strategy");
		f32 distance;
		if (distance < 50.0f)
		{
			strategy = Strategy::attacking;
		}

		if (strategy == Strategy::idle)
		{
			strategy = Strategy::chasing;
		}
		else if (strategy == Strategy::chasing)
		{

		}
		else if (strategy == Strategy::attacking)
		{
			if (distance > 120.0f)
			{
				strategy = Strategy::chasing;
			}
		}

		UpdateBlob(blob, target, strategy);

		if (LoseTarget(this, target))
		{
			strategy = Strategy::idle;
		}
		blob.set_u8("strategy", strategy);
	}
}

void UpdateBlob(CBlob@ blob, CBlob@ target, const u8 strategy)
{
	Vec2f targetPos = target.getPosition();
	Vec2f myPos = blob.getPosition();
	if (strategy == Strategy::chasing)
	{
		DefaultChaseBlob(blob, target);	
		AttackWalls(blob);	
	}
	else if (strategy == Strategy::attacking)
	{
		AttackBlob(blob, target);
		AttackWalls(blob);
	}
}

void AttackWalls(CBlob@ blob)
{
	ZombieInfo@ zombie;
	if (!blob.get("zombieInfo", @zombie))
	{
		return;
	}

	Vec2f pos = blob.getPosition();
	const f32 radius = blob.getRadius();
	const s32 difficulty = blob.get_s32("difficulty");
	const u32 gametime = getGameTime();
	CMap@ map = getMap();

	// start attack
	if (zombie.state == ZombieStates::normal)
	{
		Vec2f vr = pos + Vec2f(  radius +  4.0f, 0);
		Vec2f vl = pos + Vec2f( -radius + -4.0f, 0);
		Vec2f vu = pos + Vec2f( 0, -radius + -4.0f);
		Vec2f vd = pos + Vec2f( 0,  radius +  4.0f);

		Tile r = map.getTile(vr);
		Tile l = map.getTile(vl);
		Tile u = map.getTile(vu);
		Tile d = map.getTile(vd);		
		
		if  ( blob.isKeyPressed(key_up)    && (map.isTileSolid( u )  || map.isTileBackgroundNonEmpty(u)) )
			{ zombie.state = ZombieStates::attack_drawn; blob.setAimPos( vu );}
		else  
		if  ( blob.isKeyPressed(key_down)  && (map.isTileSolid( d )  || map.isTileBackgroundNonEmpty(d)) )
			{ zombie.state = ZombieStates::attack_drawn; blob.setAimPos( vd );}
		else
		if  ( blob.isKeyPressed(key_right) && (map.isTileSolid( r ) || map.isTileBackgroundNonEmpty(r)) )
			{ zombie.state = ZombieStates::attack_drawn; blob.setAimPos( vr );}
		else
		if	( blob.isKeyPressed(key_left)  && (map.isTileSolid( l )  || map.isTileBackgroundNonEmpty(l)) )
			{ zombie.state = ZombieStates::attack_drawn; blob.setAimPos( vl );}			
	}

	if ( zombie.state == ZombieStates::attack_drawn && zombie.AttackChargeTimer == zombie.AttackChargeLimit) // release and attack when appropriate
	{		
		zombie.state = ZombieStates::attack_start;
	}
}

void AttackBlob(CBlob@ blob, CBlob @target)
{
	ZombieInfo@ zombie;
	if (!blob.get("zombieInfo", @zombie))
	{
		return;
	}

	Vec2f mypos = blob.getPosition();
	Vec2f targetPos = target.getPosition();
	Vec2f targetVector = targetPos - mypos;
	f32 targetDistance = targetVector.Length();
	const s32 difficulty = blob.get_s32("difficulty");

	if (targetDistance > blob.getRadius() + 15.0f)
	{
		//if (!isFriendAheadOfMe(blob, target))
		{
			SimpleChase(blob, target);
		}
	}

	JumpOverObstacles(blob);

	// aim always at enemy
	blob.setAimPos(targetPos);
	
	if (targetDistance < 40.0f && zombie.state == ZombieStates::normal)
	{
		zombie.state = ZombieStates::attack_drawn;
	}

	if ( zombie.state == ZombieStates::attack_drawn && zombie.AttackChargeTimer == zombie.AttackChargeLimit) // release and attack when appropriate
	{		
		zombie.state = ZombieStates::attack_start;
	}
}