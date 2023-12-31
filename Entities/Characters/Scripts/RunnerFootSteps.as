#define CLIENT_ONLY

#include "RunnerCommon.as"

void onInit(CSprite@ this)
{
	this.getCurrentScript().runFlags |= Script::tick_onground;
	this.getCurrentScript().runFlags |= Script::tick_not_inwater;
	this.getCurrentScript().runFlags |= Script::tick_moving;
	this.getCurrentScript().removeIfTag = "dead";
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (/*blob.isOnGround() && */(blob.isKeyPressed(key_left) || blob.isKeyPressed(key_right)))
	{
		RunnerMoveVars@ moveVars;
		if (!blob.get("moveVars", @moveVars))
		{
			return;
		}
		if ((blob.getNetworkID() + getGameTime()) % (moveVars.walkFactor < 1.0f ? 14 : 8) == 0)
		{
			f32 volume = Maths::Min(0.1f + Maths::Abs(blob.getVelocity().x) * 0.1f, 1.0f);
			TileType tile = blob.getMap().getTile(blob.getPosition() + Vec2f(0.0f, blob.getRadius() + 4.0f)).type;

			if (blob.getMap().isTileGroundStuff(tile))
			{
				this.PlayRandomSound("/EarthStep", volume);
			}
			else if ((tile >= 437 && tile <= 446) || (tile >= 459 && tile <= 462))
			{
				this.PlaySound( "/WetStep"+(1+XORRandom(5)));
			}
			else
			{
				this.PlayRandomSound("/StoneStep", volume);
			}
		}
	}
}