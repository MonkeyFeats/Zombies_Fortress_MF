// Builder animations

#include "BuilderCommon.as"
#include "FireCommon.as"
#include "Requirements.as"
#include "RunnerAnimCommon.as"
#include "RunnerCommon.as"
#include "Knocked.as"
#include "PixelOffsets.as"
#include "RunnerTextures.as"

const string buildertools_layer = "Tool Layer";

void onInit(CSprite@ this)
{
	addRunnerTextures(this, "builder", "Builder");

	this.getCurrentScript().runFlags |= Script::tick_not_infire;

	// add Pickaxe layer
	this.RemoveSpriteLayer(buildertools_layer);
	CSpriteLayer@ buildertools = this.addSpriteLayer(buildertools_layer, "BuilderToolLayer.png", 32, 32, 1, 0);
	if (buildertools !is null)
	{
		Animation@ empty = buildertools.addAnimation("default", 0, false);
		empty.AddFrame(5);

		Animation@ strike = buildertools.addAnimation("strike", 2, true);
		int[] strike_frames = {0, 1, 2, 3, 4, 0};
		strike.AddFrames(strike_frames);

		Animation@ build = buildertools.addAnimation("build", 2, true);
		int[] build_frames = {6, 6, 7, 8, 7, 7}; 
		build.AddFrames(build_frames);

		buildertools.SetVisible(true);
		buildertools.SetRelativeZ(0.5f);
		buildertools.SetOffset(Vec2f(0, -4));
	}
}

void onPlayerInfoChanged(CSprite@ this)
{
	ensureCorrectRunnerTexture(this, "builder", "Builder");
}

void onTick(CSprite@ this)
{
	CSpriteLayer@ buildertools = this.getSpriteLayer(buildertools_layer);
	if (buildertools is null) return;

	// store some vars for ease and speed
	CBlob@ blob = this.getBlob();

	if (blob.hasTag("dead"))
	{
		this.SetAnimation("dead");
		Vec2f vel = blob.getVelocity();

		if (vel.y < -1.0f)
		{
			this.SetFrameIndex(0);
		}
		else if (vel.y > 1.0f)
		{
			this.SetFrameIndex(2);
		}
		else
		{
			this.SetFrameIndex(1);
		}
		return;
	}
	// animations

	const u8 knocked = getKnocked(blob);
	const bool action2 = blob.isKeyPressed(key_action2);
	const bool action1 = blob.isKeyPressed(key_action1);	

	if (!blob.hasTag(burning_tag)) //give way to burning anim
	{
		const bool left = blob.isKeyPressed(key_left);
		const bool right = blob.isKeyPressed(key_right);
		const bool up = blob.isKeyPressed(key_up);
		const bool down = blob.isKeyPressed(key_down);
		const bool inair = (!blob.isOnGround() && !blob.isOnLadder());
		Vec2f pos = blob.getPosition();

		RunnerMoveVars@ moveVars;
		if (!blob.get("moveVars", @moveVars))
		{
			return;
		}

		if (knocked > 0)
		{
			if (inair)
			{
				buildertools.SetAnimation("default");
				this.SetAnimation("knocked_air");
			}
			else
			{
				buildertools.SetAnimation("default");
				this.SetAnimation("knocked");
			}
		}
		else if (blob.hasTag("seated"))
		{
			buildertools.SetAnimation("default");
			this.SetAnimation("crouch");
		}
		else if (action2 || (this.isAnimation("strike") && !this.isAnimationEnded()))
		{
			buildertools.SetAnimation("strike");
			this.SetAnimation("strike");
		}
		else if (action1  || (this.isAnimation("build") && !this.isAnimationEnded()))
		{
			buildertools.SetAnimation("build");			
			this.SetAnimation("build");
		}
		else if (inair)
		{			
			RunnerMoveVars@ moveVars;
			if (!blob.get("moveVars", @moveVars))
			{
				return;
			}
			Vec2f vel = blob.getVelocity();
			f32 vy = vel.y;
			if (vy < -0.0f && moveVars.walljumped)
			{
				buildertools.SetAnimation("default");
				this.SetAnimation("run");
			}
			else
			{
				buildertools.SetAnimation("default");
				this.SetAnimation("fall");
				this.animation.timer = 0;

				if (vy < -1.5)
				{
					this.animation.frame = 0;
				}
				else if (vy > 1.5)
				{
					this.animation.frame = 2;
				}
				else
				{
					this.animation.frame = 1;
				}
			}
		}
		else if ((left || right) ||
		         (blob.isOnLadder() && (up || down)))
		{
			buildertools.SetAnimation("default");
			this.SetAnimation("run");
		}
		else
		{
			buildertools.SetAnimation("default");
			// get the angle of aiming with mouse
			Vec2f aimpos = blob.getAimPos();
			Vec2f vec = aimpos - pos;
			f32 angle = vec.Angle();
			int direction;

			if ((angle > 330 && angle < 361) || (angle > -1 && angle < 30) ||
			        (angle > 150 && angle < 210))
			{
				direction = 0;
			}
			else if (aimpos.y < pos.y)
			{
				direction = -1;
			}
			else
			{
				direction = 1;
			}

			defaultIdleAnim(this, blob, direction);
		}
	}

	//set the attack head

	if (knocked > 0)
	{
		blob.Tag("dead head");
	}
	else if (action2 || blob.isInFlames())
	{
		blob.Tag("attack head");
		blob.Untag("dead head");
	}
	else
	{
		blob.Untag("attack head");
		blob.Untag("dead head");
	}
}

void DrawCursorAt(Vec2f position, string& in filename)
{
	position = getMap().getAlignedWorldPos(position);
	if (position == Vec2f_zero) return;
	position = getDriver().getScreenPosFromWorldPos(position - Vec2f(1, 1));
	GUI::DrawIcon(filename, position, getCamera().targetDistance * getDriver().getResolutionScaleFactor());
}

// render cursors

const string cursorTexture = "Entities/Characters/Sprites/TileCursor.png";

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (!blob.isMyPlayer())
	{
		return;
	}
	if (getHUD().hasButtons())
	{
		return;
	}

	// draw tile cursor

	if (blob.isKeyPressed(key_action1) || this.isAnimation("strike"))
	{

		HitData@ hitdata;
		blob.get("hitdata", @hitdata);
		CBlob@ hitBlob = hitdata.blobID > 0 ? getBlobByNetworkID(hitdata.blobID) : null;

		if (hitBlob !is null) // blob hit
		{
			if (!hitBlob.hasTag("flesh"))
			{
				hitBlob.RenderForHUD(RenderStyle::outline);
			}
		}
		else// map hit
		{
			DrawCursorAt(hitdata.tilepos, cursorTexture);
		}
	}
}

void onGib(CSprite@ this)
{
	if (g_kidssafe)
	{
		return;
	}

	CBlob@ blob = this.getBlob();
	Vec2f pos = blob.getPosition();
	Vec2f vel = blob.getVelocity();
	vel.y -= 3.0f;
	f32 hp = Maths::Min(Maths::Abs(blob.getHealth()), 2.0f) + 1.0;
	const u8 team = blob.getTeamNum();
	CParticle@ Body     = makeGibParticle("Entities/Characters/Builder/BuilderGibs.png", pos, vel + getRandomVelocity(90, hp , 80), 0, 0, Vec2f(16, 16), 2.0f, 20, "/BodyGibFall", team);
	CParticle@ Arm1     = makeGibParticle("Entities/Characters/Builder/BuilderGibs.png", pos, vel + getRandomVelocity(90, hp - 0.2 , 80), 1, 0, Vec2f(16, 16), 2.0f, 20, "/BodyGibFall", team);
	CParticle@ Arm2     = makeGibParticle("Entities/Characters/Builder/BuilderGibs.png", pos, vel + getRandomVelocity(90, hp - 0.2 , 80), 1, 0, Vec2f(16, 16), 2.0f, 20, "/BodyGibFall", team);
	CParticle@ Shield   = makeGibParticle("Entities/Characters/Builder/BuilderGibs.png", pos, vel + getRandomVelocity(90, hp , 80), 2, 0, Vec2f(16, 16), 2.0f, 0, "Sounds/material_drop.ogg", team);
	CParticle@ Sword    = makeGibParticle("Entities/Characters/Builder/BuilderGibs.png", pos, vel + getRandomVelocity(90, hp + 1 , 80), 3, 0, Vec2f(16, 16), 2.0f, 0, "Sounds/material_drop.ogg", team);
}
