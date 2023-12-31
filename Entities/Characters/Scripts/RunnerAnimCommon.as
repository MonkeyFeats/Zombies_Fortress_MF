#include "EmotesCommon.as";

void defaultIdleAnim(CSprite@ this, CBlob@ blob, int direction)
{
	CSpriteLayer@ shieldlayer = this.getSpriteLayer("Shield Layer");
	CSpriteLayer@ swordlayer = this.getSpriteLayer("Sword Layer");

	if (blob.isKeyPressed(key_down))
	{
		if (shieldlayer !is null)
		shieldlayer.SetAnimation("crouch");

		this.SetAnimation("crouch");
	}
	else if (is_emote(blob, 255, true))
	{
		if (swordlayer !is null)
		{
			swordlayer.SetAnimation("point"); 
		    swordlayer.animation.frame = 1 + direction;
		}

		if (shieldlayer !is null)
		{
			shieldlayer.SetAnimation("point"); 
		    shieldlayer.animation.frame = 1 + direction;
		}

		this.SetAnimation("point");
		this.animation.frame = 1 + direction;
	}
	else
	{
		if (swordlayer !is null)
		swordlayer.SetAnimation("draw_sword");

		if (shieldlayer !is null)
		shieldlayer.SetAnimation("default");
		
		this.SetAnimation("default");
	}
}
