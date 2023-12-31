
void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed(true);
	this.getShape().getConsts().collideWhenAttached = true;
	Vec2f offset(32,6);
	//front bits
	{
		Vec2f[] shape = { Vec2f(-7.0   , -28.0)+offset,
		                  Vec2f( 4.0   , -31.0)+offset,
		                  Vec2f( 4.0   ,  27.0)+offset,
		                  Vec2f(-7.0   ,  32.0)+offset
		                };

		this.getShape().AddShape(shape);
	}
}

void onTick(CBlob@ this)
{
	f32 angvel = this.getShape().getAngularVelocity();
	if (angvel < 3.0f)
	this.getShape().SetAngularVelocity(angvel+ 0.01f);
}

//toggling on/off
void SetWindMillOn(CBlob@ this, const bool on)
{
	this.set_bool("windmill_on", on);
}

bool getWindMillOn(CBlob@ this)
{
	return this.get_bool("windmill_on");
}