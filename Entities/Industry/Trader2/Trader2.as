// Builder Workshop

#include "Descriptions.as";
#include "CheckSpam.as";

void onInit( CBlob@ this )
{	 
	this.set_TileType("background tile", CMap::tile_wood_back);
	
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.addCommandID("open shop");
	for (uint i = 0; i < itemNames.size(); i++)
	{
		this.addCommandID("sell"+itemNames[i]);
		this.addCommandID("buy"+itemNames[i]);
	}		
}

const string[]itemNames = { "Wood",
                           "Stone",
                           "Steel",
                           "Gold",
                           "Lantern"
                         };

const string[] itemIcons = {  "$mat_wood$",
                              "$mat_stone$",
                              "$mat_steel$",
                              "$mat_gold$",
                              "$lantern$"
                           };

const string[] itemBlobNames = { "mat_wood",
                                 "mat_stone",
                                 "mat_steel",
                                 "mat_gold",
                                 "lantern"
                               };

const u16[] itemSellQuantity = 	{ 250,  // "mat_wood",
                                  250,  // "mat_stone",
                                  250, // "mat_steel",
                                  250, // "mat_gold",
                                  1   // "lantern",
                               };

const u16[] itemSellPrice = 	{ 15,  // "mat_wood",
                                  40,  // "mat_stone",
                                  100, // "mat_steel",
                                  150, // "mat_gold",
                                  1   // "lantern",
                               };

const u16[] itemBuyCosts = 		{ 50,  // "mat_wood",
                                  200, // "mat_stone",
                                  400, // "mat_steel",
                                  500, // "mat_gold",
                                  15  // "lantern",
                               };


void MakeTradeMenu(CBlob@ this, CBlob@ caller)
{
	//this.ClearGridMenusExceptInventory();
	Vec2f buyoffset(  -76 ,-24);
	Vec2f selloffset(  76 ,-24);

	CGridMenu@ sellmenu = CreateGridMenu(caller.getScreenPos() + selloffset, this, Vec2f(itemNames.length/2, 4), getTranslatedString("Sell"));
	if (sellmenu !is null)
	{
		sellmenu.deleteAfterClick = false;

		CBitStream params;
		params.write_u16(caller.getNetworkID());

		for (uint i = 0; i < itemNames.size(); i++)
		{			
			CGridButton @button = sellmenu.AddButton(itemIcons[i], "Sell", this.getCommandID("sell"+itemNames[i]), params);
			if (button !is null)
			{
				bool enabled = caller.getBlobCount(itemNames[i]) >= itemSellQuantity[i];
				button.SetEnabled(enabled);
				button.hoverText = getTranslatedString("Sell ")+ itemSellQuantity[i]+ " "+getTranslatedString(itemNames[i])+ "\n"+"   For "+itemSellPrice[i]+"₵";				
			}
		}
	}

	CGridMenu@ buymenu = CreateGridMenu(caller.getScreenPos() + buyoffset, this, Vec2f(itemNames.length/2, 4), getTranslatedString("Buy"));
	if (buymenu !is null)
	{
		buymenu.deleteAfterClick = false;

		CBitStream params;
		params.write_u16(caller.getNetworkID());

		for (uint i = 0; i < itemNames.size(); i++)
		{
			CGridButton @button = buymenu.AddButton(itemIcons[i], getTranslatedString(itemNames[i]), this.getCommandID("buy"+itemNames[i]), params);

			if (button !is null)
			{
				CPlayer@ player = caller.getPlayer();
				if(player !is null && player.isMyPlayer())
				{	
					bool enabled = player.getCoins() >= itemBuyCosts[i];
					button.SetEnabled(enabled);
					button.hoverText = getTranslatedString("Buy ")+ itemSellQuantity[i]+ " "+getTranslatedString(itemNames[i])+ "\n"+"   For "+itemBuyCosts[i]+"₵";
				}
			}
		}
	}
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if(caller.getTeamNum() == this.getTeamNum() && caller.isOverlapping(this))
	{	
		CPlayer@ player = caller.getPlayer();
		if (player !is null)
		{			
			CBitStream params;
			params.write_u16(caller.getNetworkID());
			CButton@ button = caller.CreateGenericButton("$COIN$", Vec2f(0, 0), this, this.getCommandID("open shop"), getTranslatedString("Trade Items"), params);
			if (button !is null)
			{				
				button.deleteAfterClick = true;
				button.enableRadius = 20;
			}
		}
	}
}
								   
void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	u16 callerID;
	if (!params.saferead_u16(callerID))
		return;
	CBlob@ caller = getBlobByNetworkID(callerID);	
	if (caller is null) { return; }

	if (cmd == this.getCommandID("open shop"))
	{			
		MakeTradeMenu(this, caller);
	}
	else
	{
		CPlayer@ player = caller.getPlayer();
		if(player !is null && player.isMyPlayer())
		{		
			CInventory@ callerInv = caller.getInventory();
			if (callerInv is null) return;

			for (uint i = 0; i < itemNames.size(); i++)
			{
				if (cmd == this.getCommandID("sell"+itemNames[i]) && caller.getBlobCount(itemNames[i]) >= itemSellQuantity[i])
				{	
					player.server_setCoins(player.getCoins() + itemSellPrice[i]);
					this.getSprite().PlaySound( "/ChaChing.ogg" );

					//remove from inv

					caller.ClearGridMenus();
					CBitStream params;
					params.write_u16(caller.getNetworkID());
					this.SendCommand(this.getCommandID("open shop"), params);
				}

				if (cmd == this.getCommandID("buy"+itemNames[i]) && player.getCoins() >= itemBuyCosts[i])
				{						
					CBlob@ blob = server_CreateBlob(itemBlobNames[i], caller.getTeamNum(), caller.getPosition());				
					if (blob !is null)
					{
						player.server_setCoins(player.getCoins() - itemBuyCosts[i]);
						this.getSprite().PlaySound( "/ChaChing.ogg" );

						bool pickable = blob.getAttachments() !is null && blob.getAttachments().getAttachmentPointByName("PICKUP") !is null;				
						if (!blob.canBePutInInventory(caller))
						{
							caller.server_Pickup(blob);
						}
						else if (!callerInv.isFull())
						{
							caller.server_PutInInventory(blob);
						}
						else if (pickable)
						{
							caller.server_Pickup(blob);
						}

						caller.ClearGridMenus();
						CBitStream params;
						params.write_u16(caller.getNetworkID());
						this.SendCommand(this.getCommandID("open shop"), params);
					}
				}
			}
		}
	}	
}
