#define SERVER_ONLY
#include "ZombieCommon.as";

//blob
void onInit(CBlob@ this)
{
	SetupMoveVars(this);

	this.server_setTeamNum(-1);
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag	= "dead";
	this.set_s32("climb",0);
}

void onInit( CMovement@ this )
{
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag	= "dead";   
}

void onTick( CMovement@ this )
{
	CBlob@ blob = this.getBlob();
	ZombieMovementVars@ vars;
	if (!blob.get( "vars", @vars )) return;
	if (blob.getHealth() <= 0.0) return; // dead
   
	int difficulty = getRules().get_f32("difficulty")*4.0;
	
	const bool left = blob.isKeyPressed(key_left);
	const bool right = blob.isKeyPressed(key_right);
	bool up = blob.isKeyPressed(key_up);

	Vec2f vel = blob.getVelocity();
	if (left) {
		//warn("Force"+vars.walkForce.x);
		blob.AddForce(Vec2f( -1.0f * vars.walkForce.x, vars.walkForce.y));
	}
	if (right) {
		blob.AddForce(Vec2f( 1.0f * vars.walkForce.x, vars.walkForce.y));
	}

	// jump if blocked

	if (left || right || up)
	{
		Vec2f pos = blob.getPosition();
		CMap@ map = blob.getMap();
		const f32 radius = blob.getRadius();
		
		if (blob.isOnGround()) blob.set_s32("climb",1);
		
		if (
		(blob.isOnGround() || blob.isInWater()) && 
		(up || (right && map.isTileSolid( Vec2f( pos.x + (radius+1.0f), pos.y ))) || (left && map.isTileSolid( Vec2f( pos.x - (radius+1.0f), pos.y )))))
		{ 
			f32 mod = blob.isInWater() ? 0.23f : 1.0f;
			blob.AddForce(Vec2f( mod*vars.jumpForce.x*blob.getMass(), mod*vars.jumpForce.y*blob.getMass()));
			blob.set_s32("climb",1);
		} else
		if (( (right && map.isTileSolid( Vec2f( pos.x + (radius+1.0f), pos.y ))) || (left && map.isTileSolid( Vec2f( pos.x - (radius+1.0f), pos.y )))))
		{
			s32 climb = blob.get_s32("climb");
			if ((climb>0))
			{
				f32 mod = blob.isInWater() ? 0.23f : 1.0f;
				blob.AddForce(Vec2f( mod*vars.jumpForce.x*blob.getMass()/2.2, mod*vars.jumpForce.y*blob.getMass()/2.2));
				climb++;
				if (XORRandom(10+difficulty) == 0) climb=0;
				blob.set_s32("climb",climb);
				
			}
		}
		blob.Sync("climb",true);
	}

	CShape@ shape = blob.getShape();

	// too fast - slow down
	if (shape.vellen > vars.maxVelocity)
	{		  
		Vec2f vel = blob.getVelocity();
		blob.AddForce( Vec2f(-vel.x * vars.slowForce.x, -vel.y * vars.slowForce.y) );
	}

	// too slow - probs stuck in a tiny hole
	//if (shape.vellen < 0.1 && (left || right || up))
	//{
	//	blob.AddForce(Vec2f( vars.jumpForce.x*blob.getMass(), vars.jumpForce.y*blob.getMass()));
	//}
}
