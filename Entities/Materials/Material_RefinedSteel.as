
void onInit(CBlob@ this)
{
	this.server_setTeamNum(6);
  	this.maxQuantity = 25;
  	this.getCurrentScript().runFlags |= Script::remove_after_this;
}
