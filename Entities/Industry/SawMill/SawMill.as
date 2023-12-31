
const string working_prop = "working";

void onInit(CSprite@ this)
{
	CSpriteLayer@ blade = this.addSpriteLayer("blade", "SawMill.png", 16, 16);
	if (blade !is null)
	{		
		Animation@ anim = blade.addAnimation("default", 0, true);
		anim.AddFrame(17);		

		blade.SetOffset(Vec2f(10.0f, 10.0f));
		blade.SetRelativeZ(-2.0f);
		blade.SetVisible(true);
	}

	CSpriteLayer@ s_log = this.addSpriteLayer("s_log", "Log.png", 16, 16);
	if (s_log !is null)
	{		
		Animation@ anim = s_log.addAnimation("default", 0, true);
		int[] frames = { 0, 1 };
		anim.AddFrames(frames);

		s_log.SetRelativeZ(-1.0f);
		s_log.SetOffset(Vec2f(-18.0f, 7.0f));
		s_log.SetVisible(false);
		s_log.RotateBy(90.0f,Vec2f_zero);
	}

	CSpriteLayer@ m_log = this.addSpriteLayer("m_log", "Logs.png", 16, 32);
	if (m_log !is null)
	{		
		Animation@ anim = m_log.addAnimation("default", 0, true);
		int[] frames = { 16, 17};
		anim.AddFrames(frames);

		m_log.SetRelativeZ(-1.0f);
		m_log.SetOffset(Vec2f(-14.0f, 7.0f));
		m_log.SetVisible(false);
		m_log.RotateBy(90.0f,Vec2f_zero);
	}

	this.SetEmitSound("SawLoop.ogg");
	this.SetEmitSoundPaused(true);
}

void onInit(CBlob@ this)
{
	//this.set_TileType("background tile", CMap::tile_wood_back);
	this.getSprite().SetZ(-50);
	this.getShape().getConsts().mapCollisions = false;

	this.addCommandID("add s_log");
	this.addCommandID("add m_log");
	SetSawOn(this, false);
}

void SetSawOn(CBlob@ this, const bool on)
{
	this.set_bool("saw_on", on);
}

bool getSawOn(CBlob@ this)
{
	return this.get_bool("saw_on");
}

void SetLog(CBlob@ this, bool biglog)
{
	CSprite@ sprite = this.getSprite();
	if (sprite is null) return;
	CSpriteLayer@ s_log = sprite.getSpriteLayer("s_log");
	if (s_log is null) return;
	CSpriteLayer@ m_log = sprite.getSpriteLayer("m_log");
	if (m_log is null) return;

	if (biglog)
	{
		m_log.SetVisible(true);
		s_log.SetVisible(false);
	}
	else
	{
		m_log.SetVisible(false);
		s_log.SetVisible(true);
	}
}

void onTick(CBlob@ this)
{	
	CSprite@ sprite = this.getSprite();
	if (sprite is null) return;
	CSpriteLayer@ blade = sprite.getSpriteLayer("blade");
	if (blade is null) return;
	CSpriteLayer@ s_log = sprite.getSpriteLayer("s_log");
	if (s_log is null) return;
	CSpriteLayer@ m_log = sprite.getSpriteLayer("m_log");
	if (m_log is null) return;	

	if (getSawOn(this))
	{
		sprite.SetEmitSoundPaused(false);		
		f32 production_time = (getGameTime() - this.get_f32("production time"));
		f32 gametime = getGameTime();

		Vec2f around(0.5f, -0.5f);
		blade.RotateBy(60.0f, around);
		s_log.SetOffset(Vec2f(-18.0f + production_time*0.25f, 7.0f));
		m_log.SetOffset(Vec2f( -14.0f + production_time*0.25f, 7.0f));

		if (production_time >= 30 &&  production_time < 105)
		{
			if (getGameTime() % 5 == 0)
			{
				makeWoodParticle(this, this.getPosition()+Vec2f(-10,8));
				sprite.SetEmitSound("SawLog.ogg");
			}
			
		}
		if (production_time == 45)
		{
			m_log.SetVisible(false);
			s_log.SetVisible(true);
		}
		if (production_time == 105)
		{			
			s_log.SetVisible(false);
			m_log.SetVisible(false);
			s_log.SetOffset(Vec2f(-18.0f, 7.0f));
			m_log.SetOffset(Vec2f( -14.0f, 7.0f));

			SetSawOn(this, false);
		}		
	}	
	else
	{
		sprite.SetEmitSoundPaused(true);
		sprite.SetEmitSound("SawLoop.ogg");
	}
}


void GetButtonsFor(CBlob@ this, CBlob@ caller)
{

	if (caller.getCarriedBlob() is null)
	return;

	string heldname = caller.getCarriedBlob().getName();

	if (heldname == "log")
	{
		CBitStream params;
		params.write_u16(caller.getCarriedBlob().getNetworkID());
		params.write_bool(false);
		CButton@ addlog_button = caller.CreateGenericButton("$log$", Vec2f(6.0f, 5.0f), this, this.getCommandID("add s_log"), getTranslatedString("Add Log"), params);
		if (addlog_button !is null)
		{
			addlog_button.deleteAfterClick = true;
			addlog_button.SetEnabled(!getSawOn(this));
		}		
	}	
	else if (heldname == "m_log")
	{
		CBitStream params;
		params.write_u16(caller.getCarriedBlob().getNetworkID());
		params.write_bool(true);
		CButton@ addlog_button = caller.CreateGenericButton("$log$", Vec2f(6.0f, 5.0f), this, this.getCommandID("add m_log"), getTranslatedString("Add Log"), params);
		if (addlog_button !is null)
		{
			addlog_button.deleteAfterClick = true;
			addlog_button.SetEnabled(!getSawOn(this));
		}		
	}	
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("add s_log"))
	{		
		CBlob @carryBlob = getBlobByNetworkID(params.read_u16());
		if (carryBlob !is null)	carryBlob.server_Die();
			
		bool set = !getSawOn(this);
		SetSawOn(this, set);
		this.set_f32("production time", getGameTime());
		SetLog(this, false);
	}
	else if (cmd == this.getCommandID("add m_log"))
	{
		CBlob @carryBlob = getBlobByNetworkID(params.read_u16());
		if (carryBlob !is null)	carryBlob.server_Die();
		
		bool set = !getSawOn(this);
		SetSawOn(this, set);
		this.set_f32("production time", getGameTime());
		SetLog(this, true);
	}
}

void SpawnWood(CBlob@ this)
{

}

void makeWoodParticle(CBlob@ this, Vec2f pos)
{
	if (!getNet().isClient()) return;
	makeGibParticle("/GenericGibs", pos, getRandomVelocity(115.0f, 3.5f , 25.0f), 1, 4 + XORRandom(4), Vec2f(8, 8), 2.0f, 0, "", 0);
}