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
	SearchTarget(this, false);	

	CBlob@ blob = this.getBlob();
	CBlob@ target = this.getTarget();

	this.getCurrentScript().tickFrequency = 30;	

	if (target !is null)
	{
		this.getCurrentScript().tickFrequency = 1;
		u8 strategy = blob.get_u8("strategy");
		f32 distance;
		const bool visibleTarget = isVisible(blob, target, distance);
		if (visibleTarget && distance < 220.0f)
		{
			strategy = Strategy::attacking;
		}
		else
		{
			strategy = Strategy::chasing;
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
		//DefaultChaseBlob(blob, target);
		SimpleChase(blob, target);
	}
	else if (strategy == Strategy::attacking)
	{
		AttackBlob(blob, target);
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

	//if (targetDistance > blob.getRadius() + 15.0f)
	{
		//if (!isFriendAheadOfMe(blob, target))
		{
			SimpleChase(blob, target);
		}
	}

	JumpOverObstacles(blob);

	// aim always at enemy
	blob.setAimPos(targetPos);
	
	if (targetDistance < 240.0f && zombie.state == ZombieStates::normal)
	{
		zombie.state = ZombieStates::attack_drawn;
	}

	if ( zombie.state == ZombieStates::attack_drawn && zombie.AttackChargeTimer == zombie.AttackChargeLimit) // release and attack when appropriate
	{		
		zombie.state = ZombieStates::attack_start;
	}
}