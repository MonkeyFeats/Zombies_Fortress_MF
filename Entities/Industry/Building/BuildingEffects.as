#include "MakeDustParticle.as";

void onDie(CBlob@ this)
{
	if (this.isAttached() || this.hasTag("temp blob")) return;

	if (!this.getSprite().getVars().gibbed)
	{
		this.getSprite().PlaySound("/BuildingExplosion");
	}

	// gib no matter what
	this.getSprite().Gib();
	// effects
	MakeDustParticle(this.getPosition(), "Smoke.png");

}