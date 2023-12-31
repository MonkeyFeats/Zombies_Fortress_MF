// Knight animations

#include "KnightCommon.as";
#include "RunnerAnimCommon.as";
#include "RunnerCommon.as";
#include "Knocked.as";
#include "PixelOffsets.as"
#include "RunnerTextures.as"

const string shiny_layer = "shiny bit";
const string sword_layer = "Sword Layer";

void onInit(CSprite@ this)
{
	addRunnerTextures(this, "knight", "Knight");

	// add blade
	this.RemoveSpriteLayer("chop");
	CSpriteLayer@ chop = this.addSpriteLayer("chop","KnightSwordLayer.png", 32, 32, 1, 0);

	if (chop !is null)
	{
		Animation@ anim = chop.addAnimation("default", 0, true);
		anim.AddFrame(17);
		anim.AddFrame(18);
		anim.AddFrame(19);
		chop.SetVisible(false);
		chop.SetRelativeZ(1000.0f);
		chop.SetOffset(Vec2f(0, -4));
	}

	// add shiny
	this.RemoveSpriteLayer(shiny_layer);
	CSpriteLayer@ shiny = this.addSpriteLayer(shiny_layer, "AnimeShiny.png", 16, 16);

	if (shiny !is null)
	{
		Animation@ anim = shiny.addAnimation("default", 2, true);
		int[] frames = {0, 1, 2, 3};
		anim.AddFrames(frames);
		shiny.SetVisible(false);
		shiny.SetRelativeZ(1.0f);
	}

	// add sword
	this.RemoveSpriteLayer(sword_layer);
	CSpriteLayer@ sword = this.addSpriteLayer(sword_layer, "KnightSwordLayer.png", 32, 32, 1, 0);
	if (sword !is null)
	{
		Animation@ point = sword.addAnimation("point", 0, false);
		int[] point_frames = {13, 14, 15}; 
		point.AddFrames(point_frames);

		Animation@ draw_sword = sword.addAnimation("draw_sword", 0, false);
		draw_sword.AddFrame(20); // empty

		Animation@ strike_up = sword.addAnimation("strike_up", 3, false);
		int[] strike_up_frames = {0, 1, 1, 0};
		strike_up.AddFrames(strike_up_frames);

		Animation@ strike_mid = sword.addAnimation("strike_mid", 3, false);
		int[] strike_mid_frames = {2, 3, 3, 16}; 
		strike_mid.AddFrames(strike_mid_frames);

		Animation@ strike_mid_down = sword.addAnimation("strike_mid_down", 3, false);
		int[] strike_mid_down_frames = {2, 11, 11, 16}; 
		strike_mid_down.AddFrames(strike_mid_down_frames);

		Animation@ strike_down = sword.addAnimation("strike_down", 3, false);
		int[] strike_down_frames = {9, 10, 10, 2}; 
		strike_down.AddFrames(strike_down_frames);

		Animation@ strike_power_ready = sword.addAnimation("strike_power_ready", 0, false);
		int[] strike_power_ready_frames = {4, 5}; 
		strike_power_ready.AddFrames(strike_power_ready_frames);

		Animation@ strike_power = sword.addAnimation("strike_power", 3, false);
		int[] strike_power_frames = {5, 5, 8, 3, 7, 7}; 
		strike_power.AddFrames(strike_power_frames);

		sword.SetVisible(false);
		sword.SetRelativeZ(0.3f);
		sword.SetOffset(Vec2f(0, -4));
	}

	// add shield
	this.RemoveSpriteLayer("Shield Layer");
	CSpriteLayer@ shield = this.addSpriteLayer("Shield Layer", "KnightShieldLayer.png", 32, 32, 3, 0);
	if (shield !is null)
	{
		Animation@ idle = shield.addAnimation("default", 0, false);
		idle.AddFrame(0);

		Animation@ crouch = shield.addAnimation("crouch", 0, false);
		crouch.AddFrame(8);

		Animation@ point = shield.addAnimation("point", 0, false);
		int[] point_frames = {53, 54, 55}; 
		point.AddFrames(point_frames);

		Animation@ run = shield.addAnimation("run", 3, true);
		int[] run_frames = {1, 2, 3, 4}; 
		run.AddFrames(run_frames);

		Animation@ fall = shield.addAnimation("fall", 5, false);
		int[] fall_frames = {5, 6, 7}; 
		fall.AddFrames(fall_frames);

		Animation@ knocked = shield.addAnimation("knocked", 3, false);
		knocked.AddFrame(40);

		Animation@ knocked_air = shield.addAnimation("knocked_air", 3, false);
		knocked_air.AddFrame(41);

		Animation@ dead = shield.addAnimation("dead", 0, false);
		int[] dead_frames = {48, 49, 50, 51}; 
		dead.AddFrames(dead_frames);

		Animation@ draw_sword = shield.addAnimation("draw_sword", 5, false);
		draw_sword.AddFrame(29);
		draw_sword.AddFrame(29);


		Animation@ strike_up = shield.addAnimation("strike_up", 3, false);
		int[] strike_up_frames = {22, 23, 23, 22}; 
		strike_up.AddFrames(strike_up_frames);

		Animation@ strike_mid = shield.addAnimation("strike_mid", 3, false);
		int[] strike_mid_frames = {30, 31, 31, 62}; 
		strike_mid.AddFrames(strike_mid_frames);

		Animation@ strike_mid_down = shield.addAnimation("strike_mid_down", 3, false);
		int[] strike_mid_down_frames = {30, 47, 47, 62}; 
		strike_mid_down.AddFrames(strike_mid_down_frames);

		Animation@ strike_down = shield.addAnimation("strike_down", 3, false);
		int[] strike_down_frames = {45, 46, 46, 30}; 
		strike_down.AddFrames(strike_down_frames);

		Animation@ strike_power_ready = shield.addAnimation("strike_power_ready", 0, false);
		int[] strike_power_ready_frames = {36, 37}; 
		strike_power_ready.AddFrames(strike_power_ready_frames);

		Animation@ strike_power = shield.addAnimation("strike_power", 3, false);
		int[] strike_power_frames = {37, 37, 44, 31, 39, 39}; 
		strike_power.AddFrames(strike_power_frames);

		Animation@ shield_raised = shield.addAnimation("shield_raised", 0, false);
		int[] shield_raised_frames = {9, 10, 11, 21}; 
		shield_raised.AddFrames(shield_raised_frames);

		Animation@ shield_run = shield.addAnimation("shield_run", 3, true);
		int[] shield_run_frames = {12, 13, 14, 15}; 
		shield_run.AddFrames(shield_run_frames);

		Animation@ shield_run_up = shield.addAnimation("shield_run_up", 3, true);
		int[] shield_run_up_frames = {10, 56, 57, 58}; 
		shield_run_up.AddFrames(shield_run_up_frames);

		Animation@ shield_run_down = shield.addAnimation("shield_run_down", 3, true);
		int[] shield_run_down_frames = {11, 59, 60, 61}; 
		shield_run_down.AddFrames(shield_run_down_frames);

		Animation@ shield_bash = shield.addAnimation("shield_bash", 10, false);
		int[] shield_bash_frames = {13, 13, 13, 14, 14, 15, 15}; 
		shield_bash.AddFrames(shield_bash_frames);		

		Animation@ shield_drop = shield.addAnimation("shield_drop", 5, false);
		int[] shield_drop_frames = {41, 42}; 
		shield_drop.AddFrames(shield_drop_frames);

		Animation@ shield_glide = shield.addAnimation("shield_glide", 4, true);
		int[] shield_glide_frames = {32, 33, 34, 33}; 
		shield_glide.AddFrames(shield_glide_frames);

		Animation@ carry_low = shield.addAnimation("carry_low", 3, false);
		carry_low.AddFrame(16);

		Animation@ carry_low_run = shield.addAnimation("carry_low_run", 3, true);
		int[] carry_low_run_frames = {17, 18, 19, 20}; 
		carry_low_run.AddFrames(carry_low_run_frames);

		Animation@ carry_low_jump = shield.addAnimation("carry_low_jump", 3, false);
		int[] carry_low_jump_frames = {17, 17, 18}; 
		carry_low_jump.AddFrames(carry_low_jump_frames);

		Animation@ carry_high = shield.addAnimation("carry_high", 3, false);
		carry_high.AddFrame(24);

		Animation@ carry_high_run = shield.addAnimation("carry_high_run", 3, true);
		int[] carry_high_run_frames = {25, 26, 27, 28}; 
		carry_high_run.AddFrames(carry_high_run_frames);

		Animation@ carry_high_jump = shield.addAnimation("carry_high_jump", 3, false);
		int[] carry_high_jump_frames = {25, 25, 26}; 
		carry_high_jump.AddFrames(carry_high_jump_frames);

		Animation@ wall_climb = shield.addAnimation("wall_climb", 4, true);
		int[] wall_climb_frames = {52, 52, 53, 54, 55}; 
		wall_climb.AddFrames(wall_climb_frames);

		Animation@ wall_slide = shield.addAnimation("wall_slide", 3, false);
		wall_slide.AddFrame(52);

		Animation@ on_fire = shield.addAnimation("on_fire", 3, true);
		int[] on_fire_frames = {25, 26, 27, 28}; 
		on_fire.AddFrames(on_fire_frames);

		shield.SetVisible(true);
		shield.SetOffset(Vec2f(0, -4));
		shield.SetRelativeZ(0.2f);
	}
}

void onPlayerInfoChanged(CSprite@ this)
{
	ensureCorrectRunnerTexture(this, "knight", "Knight");
}

void onTick(CSprite@ this)
{	
	// store some vars for ease and speed
	CBlob@ blob = this.getBlob();
	Vec2f pos = blob.getPosition();
	Vec2f aimpos;

	KnightInfo@ knight;
	if (!blob.get("knightInfo", @knight))
	{
		return;
	}
	CSpriteLayer@ swordlayer = this.getSpriteLayer(sword_layer);
	if (swordlayer is null) return;
	CSpriteLayer@ shieldlayer = this.getSpriteLayer("Shield Layer");
	if (shieldlayer is null) return;

	const u8 knocked = getKnocked(blob);

	bool shieldState = isShieldState(knight.state);
	bool specialShieldState = isSpecialShieldState(knight.state);
	bool swordState = isSwordState(knight.state);

	bool pressed_a1 = blob.isKeyPressed(key_action1);
	bool pressed_a2 = blob.isKeyPressed(key_action2);

	bool walking = (blob.isKeyPressed(key_left) || blob.isKeyPressed(key_right));

	aimpos = blob.getAimPos();
	bool inair = (!blob.isOnGround() && !blob.isOnLadder());

	Vec2f vel = blob.getVelocity();

	swordlayer.SetVisible(swordState || (shieldlayer.isAnimation("point") && !inair && !walking));

	if (blob.hasTag("dead"))
	{
		if (this.animation.name != "dead")
		{
			this.RemoveSpriteLayer(shiny_layer);

			shieldlayer.SetAnimation("dead");
			this.SetAnimation("dead");
		}
		Vec2f oldvel = blob.getOldVelocity();

		//TODO: trigger frame one the first time we server_Die()()
		if (vel.y < -1.0f)
		{
			shieldlayer.animation.SetFrameIndex(1);
			this.SetFrameIndex(1);
		}
		else if (vel.y > 1.0f)
		{
			shieldlayer.animation.SetFrameIndex(3);
			this.SetFrameIndex(3);
		}
		else
		{
			shieldlayer.animation.SetFrameIndex(2);
			this.SetFrameIndex(2);
		}

		CSpriteLayer@ chop = this.getSpriteLayer("chop");

		if (chop !is null)
		{
			chop.SetVisible(false);
		}

		return;
	}

	// get the angle of aiming with mouse
	Vec2f vec;
	int direction = blob.getAimDirection(vec);

	// set facing
	bool facingLeft = this.isFacingLeft();
	// animations
	bool ended = this.isAnimationEnded() || this.isAnimation("shield_raised");
	bool wantsChopLayer = false;
	s32 chopframe = 0;
	f32 chopAngle = 0.0f;

	const bool left = blob.isKeyPressed(key_left);
	const bool right = blob.isKeyPressed(key_right);
	const bool up = blob.isKeyPressed(key_up);
	const bool down = blob.isKeyPressed(key_down);

	bool shinydot = false;

	if (knocked > 0)
	{
		if (inair)
		{
			shieldlayer.SetAnimation("knocked_air");
			this.SetAnimation("knocked_air");
		}
		else
		{
			shieldlayer.SetAnimation("knocked");
			this.SetAnimation("knocked");
		}
	}
	else if (blob.hasTag("seated"))
	{
		shieldlayer.SetAnimation("crouch");
		this.SetAnimation("crouch");
	}
	else if (knight.state == KnightStates::shieldgliding)
	{
		shieldlayer.SetAnimation("shield_glide");
		this.SetAnimation("shield_glide");
	}
	else if (knight.state == KnightStates::shielddropping)
	{
		shieldlayer.SetAnimation("shield_drop");
		this.SetAnimation("shield_drop");
	}
	else if (knight.state == KnightStates::shielding)
	{
		if (walking)
		{
			if (direction == 0)
			{
				shieldlayer.SetAnimation("shield_run");
				this.SetAnimation("shield_run");
			}
			else if (direction == -1)
			{
				shieldlayer.SetAnimation("shield_run_up");
				this.SetAnimation("shield_run_up");
			}
			else if (direction == 1)
			{
				shieldlayer.SetAnimation("shield_run_down");
				this.SetAnimation("shield_run_down");
			}
		}
		else
		{
			shieldlayer.SetAnimation("shield_raised");
			this.SetAnimation("shield_raised");

			if (direction == 1)
			{
				shieldlayer.animation.frame = 2;
				this.animation.frame = 2;
			}
			else if (direction == -1)
			{
				if (vec.y > -0.97)
				{
					shieldlayer.animation.frame = 1;
					this.animation.frame = 1;
				}
				else
				{
					shieldlayer.animation.frame = 3;
					this.animation.frame = 3;
				}
			}
			else
			{
				shieldlayer.animation.frame = 0;
				this.animation.frame = 0;
			}
		}
	}
	else if (knight.state == KnightStates::sword_drawn)
	{
		if (knight.swordTimer < KnightVars::slash_charge)
		{
			swordlayer.SetAnimation("draw_sword");
			shieldlayer.SetAnimation("draw_sword");
			this.SetAnimation("draw_sword");
		}
		else if (knight.swordTimer < KnightVars::slash_charge_level2)
		{
			swordlayer.SetAnimation("strike_power_ready");
			swordlayer.animation.frame = 0;
			shieldlayer.SetAnimation("strike_power_ready");
			shieldlayer.animation.frame = 0;
			this.SetAnimation("strike_power_ready");
			this.animation.frame = 0;
		}
		else if (knight.swordTimer < KnightVars::slash_charge_limit)
		{
			swordlayer.SetAnimation("strike_power_ready");
			swordlayer.animation.frame = 1;
			shieldlayer.SetAnimation("strike_power_ready");
			shieldlayer.animation.frame = 1;
			this.SetAnimation("strike_power_ready");
			this.animation.frame = 1;
			shinydot = true;
		}
		else
		{
			swordlayer.SetAnimation("draw_sword");
			shieldlayer.SetAnimation("draw_sword");
			this.SetAnimation("draw_sword");
		}
	}
	else if (knight.state == KnightStates::sword_cut_mid)
	{
		swordlayer.SetAnimation("strike_mid");
		shieldlayer.SetAnimation("strike_mid");
		this.SetAnimation("strike_mid");
	}
	else if (knight.state == KnightStates::sword_cut_mid_down)
	{
		swordlayer.SetAnimation("strike_mid_down");
		shieldlayer.SetAnimation("strike_mid_down");
		this.SetAnimation("strike_mid_down");
	}
	else if (knight.state == KnightStates::sword_cut_up)
	{
		swordlayer.SetAnimation("strike_up");
		shieldlayer.SetAnimation("strike_up");
		this.SetAnimation("strike_up");
	}
	else if (knight.state == KnightStates::sword_cut_down)
	{
		swordlayer.SetAnimation("strike_down");
		shieldlayer.SetAnimation("strike_down");
		this.SetAnimation("strike_down");
	}
	else if (knight.state == KnightStates::sword_power || knight.state == KnightStates::sword_power_super)
	{
		swordlayer.SetAnimation("strike_power");
		shieldlayer.SetAnimation("strike_power");
		this.SetAnimation("strike_power");

		if (knight.swordTimer <= 1)
			{
				swordlayer.animation.SetFrameIndex(0);
				shieldlayer.animation.SetFrameIndex(0);
			 	this.animation.SetFrameIndex(0);
			}

		u8 mintime = 6;
		u8 maxtime = 8;
		if (knight.swordTimer >= mintime && knight.swordTimer <= maxtime)
		{
			wantsChopLayer = true;
			chopframe = knight.swordTimer - mintime;
			chopAngle = -vec.Angle();
		}
	}
	else if (inair)
	{
		RunnerMoveVars@ moveVars;
		if (!blob.get("moveVars", @moveVars))
		{
			return;
		}
		f32 vy = vel.y;
		if (vy < -0.0f && moveVars.walljumped)
		{
			shieldlayer.SetAnimation("run");
			this.SetAnimation("run");
		}
		else
		{
			shieldlayer.SetAnimation("fall");
			shieldlayer.animation.timer = 0;
			this.SetAnimation("fall");
			this.animation.timer = 0;

			if (vy < -1.5)
			{
				shieldlayer.animation.frame = 0;
				this.animation.frame = 0;
			}
			else if (vy > 1.5)
			{
				shieldlayer.animation.frame = 2;
				this.animation.frame = 2;
			}
			else
			{
				shieldlayer.animation.frame = 1;
				this.animation.frame = 1;
			}
		}
	}
	else if (walking ||
	         (blob.isOnLadder() && (blob.isKeyPressed(key_up) || blob.isKeyPressed(key_down))))
	{
		shieldlayer.SetAnimation("run");
		this.SetAnimation("run");
	}
	else
	{
		shieldlayer.SetAnimation("default");
		defaultIdleAnim(this, blob, direction);
	}

	CSpriteLayer@ chop = this.getSpriteLayer("chop");

	if (chop !is null)
	{
		chop.SetVisible(wantsChopLayer);
		if (wantsChopLayer)
		{
			f32 choplength = 5.0f;

			chop.animation.frame = chopframe;
			Vec2f offset = Vec2f(choplength, 0.0f);
			offset.RotateBy(chopAngle, Vec2f_zero);
			if (!this.isFacingLeft())
				offset.x *= -1.0f;
			offset.y += this.getOffset().y * 0.5f;

			chop.SetOffset(offset);
			chop.ResetTransform();
			if (this.isFacingLeft())
				chop.RotateBy(180.0f + chopAngle, Vec2f());
			else
				chop.RotateBy(chopAngle, Vec2f());
		}
	}

	//set the shiny dot on the sword

	CSpriteLayer@ shiny = this.getSpriteLayer(shiny_layer);

	if (shiny !is null)
	{
		shiny.SetVisible(shinydot);
		if (shinydot)
		{
			f32 range = (KnightVars::slash_charge_limit - KnightVars::slash_charge_level2);
			f32 count = (knight.swordTimer - KnightVars::slash_charge_level2);
			f32 ratio = count / range;
			shiny.RotateBy(10, Vec2f());
			shiny.SetOffset(Vec2f(12, -2 + ratio * 8));
		}
	}

	//set the head anim
	if (knocked > 0)
	{
		blob.Tag("dead head");
	}
	else if (blob.isKeyPressed(key_action1))
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
	f32 hp = Maths::Min(Maths::Abs(blob.getHealth()), 2.0f) + 1.0f;
	const u8 team = blob.getTeamNum();
	CParticle@ Body     = makeGibParticle("Entities/Characters/Knight/KnightGibs.png", pos, vel + getRandomVelocity(90, hp , 80), 0, 0, Vec2f(16, 16), 2.0f, 20, "/BodyGibFall", team);
	CParticle@ Arm      = makeGibParticle("Entities/Characters/Knight/KnightGibs.png", pos, vel + getRandomVelocity(90, hp - 0.2 , 80), 1, 0, Vec2f(16, 16), 2.0f, 20, "/BodyGibFall", team);
	CParticle@ Shield   = makeGibParticle("Entities/Characters/Knight/KnightGibs.png", pos, vel + getRandomVelocity(90, hp , 80), 2, 0, Vec2f(16, 16), 2.0f, 0, "Sounds/material_drop.ogg", team);
	CParticle@ Sword    = makeGibParticle("Entities/Characters/Knight/KnightGibs.png", pos, vel + getRandomVelocity(90, hp + 1 , 80), 3, 0, Vec2f(16, 16), 2.0f, 0, "Sounds/material_drop.ogg", team);
}


// render cursors

void DrawCursorAt(Vec2f position, string& in filename)
{
	position = getMap().getAlignedWorldPos(position);
	if (position == Vec2f_zero) return;
	position = getDriver().getScreenPosFromWorldPos(position - Vec2f(1, 1));
	GUI::DrawIcon(filename, position, getCamera().targetDistance * getDriver().getResolutionScaleFactor());
}

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

	if (blob.isKeyPressed(key_action1))
	{
		CMap@ map = blob.getMap();
		Vec2f position = blob.getPosition();
		Vec2f cursor_position = blob.getAimPos();
		Vec2f surface_position;
		map.rayCastSolid(position, cursor_position, surface_position);
		Vec2f vector = surface_position - position;
		f32 distance = vector.getLength();
		Tile tile = map.getTile(surface_position);

		if ((map.isTileSolid(tile) || map.isTileGrass(tile.type)) && map.getSectorAtPosition(surface_position, "no build") is null && distance < 16.0f)
		{
			DrawCursorAt(surface_position, cursorTexture);
		}
	}
}
