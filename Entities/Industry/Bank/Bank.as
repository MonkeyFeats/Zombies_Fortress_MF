// Storage.as

void onInit(CSprite@ this)
{
	// Building
	this.SetZ(-60); //-60 instead of -50 so sprite layers are behind ladders

	// Stone
	CSpriteLayer@ stone = this.addSpriteLayer("mat_stone", "BankLayers.png", 24, 16);
	if (stone !is null)
	{
		{
			stone.addAnimation("default", 0, false);
			int[] frames = { 0, 5, 10 };
			stone.animation.AddFrames(frames);
		}
		stone.SetOffset(Vec2f(10.0f, -3.0f));
		stone.SetRelativeZ(1);
		stone.SetVisible(false);
	}

	// Wood
	CSpriteLayer@ wood = this.addSpriteLayer("mat_wood", "BankLayers.png", 24, 16);
	if (wood !is null)
	{
		{
			wood.addAnimation("default", 0, false);
			int[] frames = { 1, 6, 11 };
			wood.animation.AddFrames(frames);
		}
		wood.SetOffset(Vec2f(-7.0f, -2.0f));
		wood.SetRelativeZ(1);
		wood.SetVisible(false);
	}

	// Gold
	CSpriteLayer@ gold = this.addSpriteLayer("mat_gold", "BankLayers.png", 24, 16);
	if (gold !is null)
	{
		{
			gold.addAnimation("default", 0, false);
			int[] frames = { 2, 7, 12 };
			gold.animation.AddFrames(frames);
		}
		gold.SetOffset(Vec2f(-7.0f, -10.0f));
		gold.SetRelativeZ(1);
		gold.SetVisible(false);
	}

	// Bombs
	CSpriteLayer@ bombs = this.addSpriteLayer("mat_bombs", "BankLayers.png", 24, 16);
	if (bombs !is null)
	{
		{
			bombs.addAnimation("default", 0, false);
			int[] frames = { 3, 8 };
			bombs.animation.AddFrames(frames);
		}
		bombs.SetOffset(Vec2f(-7.0f, 5.0f));
		bombs.SetRelativeZ(2);
		bombs.SetVisible(false);
	}

	// Rope
	CSpriteLayer@ rope = this.addSpriteLayer("rope", "BankLayers.png", 24, 16);
	if (rope !is null)
	{
		{
			rope.addAnimation("default", 0, false);
			int[] frames = { 4 };
			rope.animation.AddFrames(frames);
		}
		rope.SetOffset(Vec2f(5.0f, -8.0f));
		rope.SetRelativeZ(2);
	}
}

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);
	this.getShape().getConsts().mapCollisions = false;

	AddIconToken("$deposit_coins$", "CustomIcons.png", Vec2f(16, 16), 0);
	AddIconToken("$withdraw_coins$", "CustomIcons.png", Vec2f(16, 16), 1);

	this.set_u16("Stored Coins", 0);

	this.inventoryButtonPos = Vec2f(12, 0);
	this.addCommandID("deposit");
	this.addCommandID("withdraw");
	this.getCurrentScript().tickFrequency = 60;
}


void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if(caller.getTeamNum() == this.getTeamNum() && caller.isOverlapping(this))
	{	
		CPlayer@ player = caller.getPlayer();
		if (player !is null)
		{			
			CBitStream params;
			params.write_u16(caller.getNetworkID());
			CButton@ dbutton = caller.CreateGenericButton("$deposit_coins$", Vec2f(-6, 0), this, this.getCommandID("deposit"), getTranslatedString("Deposit 10c"), params);
			if (dbutton !is null)
			{				
				dbutton.deleteAfterClick = false;
				dbutton.enableRadius = 16;

				if(	player.getCoins() < 10 )
				{
					dbutton.SetEnabled(false);
				}
			}

			
			CButton@ wbutton = caller.CreateGenericButton("$withdraw_coins$", Vec2f(6, 0), this, this.getCommandID("withdraw"), getTranslatedString("Withdraw 10c"), params);
			if (wbutton !is null)
			{				
				wbutton.deleteAfterClick = false;
				wbutton.enableRadius = 16;

				if(this.get_u16("Stored Coins") < 10)
				{
					wbutton.SetEnabled(false);
				}
			}
		}
	}	
}

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return;

	const f32 scalex = getDriver().getResolutionScaleFactor();
	const f32 zoom = getCamera().targetDistance * scalex;
	Vec2f aligned = getDriver().getScreenPosFromWorldPos(blob.getPosition() + Vec2f(0 , -8));

	u16 coins = blob.get_u16("Stored Coins");
	GUI::DrawTranslatedText("C: " + coins, aligned, color_white);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (getNet().isServer())
	{
		if (cmd == this.getCommandID("deposit"))
		{
			CBlob@ caller = getBlobByNetworkID(params.read_u16());
			if (caller !is null)
			{		
				CPlayer@ player = caller.getPlayer();
				if (player !is null && player.getCoins() >= 10)
				{
					player.server_setCoins(player.getCoins() - 10);
					u16 coins = this.get_u16("Stored Coins");
					this.set_u16("Stored Coins", coins+10);
				}
				else
				{
					//sound
				}
			}
		}

		if (cmd == this.getCommandID("withdraw"))
		{
			if(this.get_u16("Stored Coins") >= 10)
			{
				CBlob@ caller = getBlobByNetworkID(params.read_u16());
				if (caller !is null)
				{		
					CPlayer@ player = caller.getPlayer();
					if (player !is null)
					{
						player.server_setCoins(player.getCoins() + 10);
						u16 coins = this.get_u16("Stored Coins");
						this.set_u16("Stored Coins", coins-10);
					}
				}
			}
			else
			{
				//sound
			}
		}
	}
}

void onAddToInventory(CBlob@ this, CBlob@ blob)
{
	updateLayers(this, blob);
}

void onRemoveFromInventory(CBlob@ this, CBlob@ blob)
{
	updateLayers(this, blob);
}

void updateLayers(CBlob@ this, CBlob@ blob)
{
	
}

void onDie(CBlob@ this)
{
	
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return (forBlob.getTeamNum() == this.getTeamNum() && forBlob.isOverlapping(this));
}