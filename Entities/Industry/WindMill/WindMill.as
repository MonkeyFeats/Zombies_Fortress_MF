// BuilderShop.as

#include "Requirements.as"
#include "ShopCommon.as";
#include "Descriptions.as";
#include "WARCosts.as";
#include "CheckSpam.as";

const string toggle_id = "toggle_power";
const string wire_id = "add_wire";


void onInit(CBlob@ this)
{
	this.Tag("windmill");

	this.addCommandID(toggle_id);
	this.addCommandID(wire_id);
	SetWindMillOn(this, true);

	//block knight sword
	this.Tag("blocks sword");
	this.getShape().SetOffset(Vec2f(0, -20));

	// create and attach moving platform
	if (getNet().isServer())
	{	
		CBlob@ arm = server_CreateBlob("windmillarm", this.getTeamNum(), this.getPosition() );
		if (arm !is null)
		{			
			this.set_u16("childID", arm.getNetworkID());
			arm.set_u16("ownerID", this.getNetworkID());
			this.server_AttachTo(arm, "ARM");
		}		
	}
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

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (caller.getTeamNum() != this.getTeamNum() || this.getDistanceTo(caller) > 16) return;

	CBitStream params;
	params.write_u16(caller.getNetworkID());
	caller.CreateGenericButton(8, Vec2f_zero, this, this.getCommandID(wire_id), "Create Wire", params);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID(wire_id))
	{
		u16 callerID;
		if (!params.saferead_u16(callerID))
			return;

		CBlob@ caller = getBlobByNetworkID(callerID);
		if (caller is null) { return; }

		if (getNet().isServer())
		{	
			CBlob@ wire = server_CreateBlob("fakewire", this.getTeamNum(), this.getPosition() );
			if (wire !is null)
			{			
				wire.set_u16("ConnectedID", this.getNetworkID());
				wire.set_u16("ConnectedID2", caller.getNetworkID());
				caller.server_Pickup(wire);
			}		
		}
	}
}

