
#include "BlobTextures.as"
//#include "RunnerTextures.as"

const string[] colourNames = 
{ 
	"Blue",
	"Red",
	"Green",
	"Purple",
	"Orange",
	"Teal",
	"Navy",
	"Brown",
	"Gold",
	"Silver",
	"Grey"
};

void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 0;

	this.addCommandID("open");
	this.addCommandID("close");

	for (uint i = 0; i < colourNames.length; i++)
	{
		string colourname = colourNames[i];
		this.addCommandID("pick "+colourname);

		AddIconToken("$"+colourname+"$", "TeamPaletteIcons.png", Vec2f(8, 8), i);
	}

	this.set_Vec2f("inventory offset", Vec2f(0.0f, 160.0f));

	// used by RunnerMovement.as & ActivateHeldObject.as
	this.Tag("medium weight");

	AddIconToken("$chest_open$", "InteractionIcons.png", Vec2f(32, 32), 20);
	AddIconToken("$chest_close$", "InteractionIcons.png", Vec2f(32, 32), 13);

	CSprite@ sprite = this.getSprite();
	if(sprite !is null)
	{
		//u8 team_color = XORRandom(7);
		this.set_u8("team_color", 8);

		sprite.SetZ(-10.0f);
		//sprite.ReloadSprites(team_color, 0);
	}
}

void onInit(CSprite@ this)
{
	addBlobTextures(this, "chest", "Chest");
	onReload(this);
}
void onReload(CSprite@ this)
{
	ensureCorrectBlobTexture(this, "chest", "Chest");
}

void onTick(CBlob@ this)
{
	u16 ownerID = this.get_u16("ownerID");

	bool ownerFound = false;
	CBlob@[] overlapping;
	if (this.getOverlapping(@overlapping))
	{		
		for (uint i = 0; i < overlapping.length; i++)
		{
			CBlob@ b = overlapping[i];

			if (b.getPlayer().getNetworkID() == ownerID)
			{
				ownerFound = true;
			}			
		}
	}
	if (!ownerFound)
	{
		this.SendCommand(this.getCommandID("close"));
	}
}

const u8 GRID_SIZE = 48;
const u8 GRID_PADDING = 12;

void onCreateInventoryMenu(CInventory@ this, CBlob@ forBlob, CGridMenu@ menu)
{
	CBlob@ blob = this.getBlob();
	if(blob is null) return;

	blob.ClearGridMenusExceptInventory();

	const Vec2f TOOL_POS = menu.getUpperLeftPosition() - Vec2f(GRID_PADDING, 0) + Vec2f(colourNames.length/2, -3) * GRID_SIZE / 2;

	CGridMenu@ ColourPickMenu = CreateGridMenu(TOOL_POS, blob, Vec2f(colourNames.length/2, 2), getTranslatedString("Personalize"));
	if(ColourPickMenu !is null)
	{
		ColourPickMenu.SetCaptionEnabled(false);

		for (uint i = 0; i < colourNames.length; i++)
		{
			string colourname = colourNames[i];
			CGridButton@ colourbutt = ColourPickMenu.AddButton("$"+colourname+"$", getTranslatedString(colourNames[i]), this.getBlob().getCommandID("pick " + colourname));
			if(colourbutt !is null)
			{
				colourbutt.SetHoverText(getTranslatedString("Stop building\n"));
				colourbutt.selectOneOnClick = true;
			}
		}
	}

	CBitStream params;
	params.write_u16(forBlob.getNetworkID());
	blob.SendCommand(blob.getCommandID("open"), params);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if(cmd == this.getCommandID("open"))
	{
		if(getNet().isServer())
		{
			u16 id;
			if(!params.saferead_u16(id)) return;

			CBlob@ caller = getBlobByNetworkID(id);
			if(caller is null) return;
		}

		this.getCurrentScript().tickFrequency = 6;
		this.Tag("_chest_open");
		this.Sync("_chest_open", true);
		CSprite@ sprite = this.getSprite();
		if(sprite !is null)
		{
			sprite.SetAnimation("open");
			sprite.PlaySound("ChestOpen.ogg", 3.0f);
		}
	}

	if(cmd == this.getCommandID("close"))
	{
		this.getCurrentScript().tickFrequency = 0;
		this.Tag("_chest_closed");
		this.Sync("_chest_closed", true);
		CSprite@ sprite = this.getSprite();
		if(sprite !is null)
		{
			sprite.SetAnimation("close");
			sprite.PlaySound("ChestClose.ogg", 3.0f);
		}
	}

	for (uint i = 0; i < colourNames.length; i++)
	{
		if (cmd == this.getCommandID("pick " + colourNames[i]))
		{
			this.server_setTeamNum(i);

			CSprite@ sprite = this.getSprite();
			if(sprite !is null)
			{
				sprite.ReloadSprites(i, 0);
			}
			break;
		}
	}
}

void onDie(CBlob@ this)
{
	//dropinv
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (hitterBlob.hasTag("player") && hitterBlob.getPlayer().getNetworkID() != this.get_u16("ownerID"))
		damage *= 0.2f; //other players are slow to grief

	return damage;
}


bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.getShape().isStatic() && blob.isCollidable();
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return (forBlob.getPlayer().getNetworkID() == this.get_u16( "ownerID") && forBlob.isOverlapping(this));
}