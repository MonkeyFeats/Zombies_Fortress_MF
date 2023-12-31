
void onInit(CBlob@ this)
{
	this.Tag("temp blob"); // temp builder blob
	this.Tag("ignore blocking actors");
}

void onTick(CBlob@ this)
{

}

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	CBlob@ connectedBlob = getBlobByNetworkID(blob.get_u16("ConnectedID"));
	CBlob@ playerBlob = getBlobByNetworkID(blob.get_u16("ConnectedID2"));

	CControls@ controls = getControls();
	Vec2f mousePos = controls.getMouseWorldPos();

	GUI::DrawLine( connectedBlob.getPosition(), mousePos, SColor(255,10,10,10));
}