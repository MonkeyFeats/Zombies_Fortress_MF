#define SERVER_ONLY
#include "ZombieCommon.as";

//blob
void onInit(CBlob@ this)
{
	SetupMoveVars(this);
	// force no team
	this.server_setTeamNum(-1);

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag	= "dead";
}

//movement
void onInit( CMovement@ this )
{
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().runFlags = 0;
	this.getCurrentScript().removeIfTag	= "dead";   
}

void onTick( CMovement@ this )
{
    CBlob@ blob = this.getBlob();
	ZombieMovementVars@ vars;
	if (!blob.get( "vars", @vars )) return;

	u8 strategy = blob.get_u8("strategy");

	const bool left = blob.isKeyPressed(key_left);
	const bool right = blob.isKeyPressed(key_right);
	bool up = blob.isKeyPressed(key_up);
	bool down = blob.isKeyPressed(key_down);
	Vec2f vel = blob.getVelocity();

	Vec2f addforce;

	if (left) { 
		addforce.x = -1.0f * vars.walkForce.x;		
	}
	if (right) {
		addforce.x =  1.0f * vars.walkForce.x;
	}
	if (up) {
		addforce.y = -1.0f * vars.walkForce.y;
	}
	if (down) {
		addforce.y =  1.0f * vars.walkForce.y;
	}
	
	Vec2f pos = blob.getPosition();
	CMap@ map = blob.getMap();

	Vec2f bottom = Vec2f(pos.x, map.tilemapheight * map.tilesize);
	Vec2f end;
	
	// strategy != 2 &&
	if ( map.rayCastSolid(pos,bottom,end)) // strat not attacking, maintain height
	{
		f32 y = end.y;

		if ( (y-pos.y) < (vars.jumpForce.y*map.tilesize) || blob.hasAttached())
		{
			blob.AddForce(Vec2f( 0, -vars.walkForce.y));
		}
	}

	blob.AddForce(addforce);

	CShape@ shape = blob.getShape();	

	// too fast - slow down
	if (shape.vellen > vars.maxVelocity)
	{		  
		Vec2f vel = blob.getVelocity();
		blob.AddForce( Vec2f(-vel.x * vars.slowForce.x, -vel.y * vars.slowForce.y) );
	}
}
