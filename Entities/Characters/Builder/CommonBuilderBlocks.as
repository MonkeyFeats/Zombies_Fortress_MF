
#include "BuildBlock.as";
#include "Requirements.as";
#include "CustomBlocks.as";

const string blocks_property = "blocks";
const string inventory_offset = "inventory offset";

void addCommonBuilderBlocks(BuildBlock[][]@ blocks)
{
	BuildBlock[] page_0;
	blocks.push_back(page_0);

	{
		BuildBlock b(0, "building", "$building$", "Small Building Scaffold");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 150);
		//b.buildOnGround = true;
		b.size.Set(40, 24);
		blocks[0].push_back(b);
	}
	//{
	//	BuildBlock b(0, "buildingM", "$buildingM$", "Medium Building Scaffold");
	//	AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 250);
	//	//b.buildOnGround = true;
	//	b.size.Set(40, 32);
	//	blocks[0].push_back(b);
	//}
	{
		BuildBlock b(0, "buildingL", "$buildingL$", "Large Building Scaffold");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 500);
		//b.buildOnGround = true;
		b.size.Set(56, 32);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "chest", "$chest$", "Personal Storage");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		//b.buildOnGround = true;
		//b.size.Set(16, 16);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "ladder", "$ladder$", "Ladder\nAnyone can climb it");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 15);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_wood_back, "back_wood_block", "$back_wood_block$", "Back Wood Wall\nCheap extra support");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 5);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_wood, "wood_block", "$wood_block$", "Wood Block\nCheap block\nwatch out for fire!");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "wooden_door", "$wooden_door$", "Wooden Door\nPlace next to walls");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 30);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "wooden_platform", "$wooden_platform$", "Wooden Platform\nOne way platform");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 15);
		blocks[0].push_back(b);
	}

	{
		BuildBlock b(CMap::tile_castle_back, "back_stone_block", "$back_stone_block$", "Back Stone Wall\nExtra support");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 2);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_castle, "stone_block", "$stone_block$", "Stone Block\nBasic building block");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "stone_door", "$stone_door$", "Stone Door\nPlace next to walls");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 50);
		blocks[0].push_back(b);
	}	
	{
		BuildBlock b(0, "trap_block", "$trap_block$", "Trap Block\nOnly enemies can pass");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 25);
		blocks[0].push_back(b);
	}
	{
		//AddIconToken( "$woodtriangle$", "triangle.png", Vec2f(8,8), 0);
		BuildBlock b( 0, "woodtriangle", "$woodtriangle$", "Wooden Triangle" );
		AddRequirement( b.reqs, "blob", "mat_wood", "Wood", 30 );
		blocks[0].push_back(b);
	}
	{
		//AddIconToken( "$woodtriangle$", "triangle.png", Vec2f(8,8), 0);
		BuildBlock b( 0, "stonetriangle", "$stonetriangle$", "Stone Triangle" );
		AddRequirement( b.reqs, "blob", "mat_stone", "Stone", 20 );
		blocks[0].push_back(b);
	}
	{
		//AddIconToken( "$woodtriangle$", "triangle.png", Vec2f(8,8), 0);
		BuildBlock b( 0, "goldtriangle", "$goldtriangle$", "Gold Triangle" );
		//AddRequirement( b.reqs, "blob", "mat_gold", "Gold", 25 );
		blocks[0].push_back(b);
	}
	{
		//AddIconToken( "$woodtriangle$", "triangle.png", Vec2f(8,8), 0);
		BuildBlock b( 0, "steeltriangle", "$steeltriangle$", "Steel Triangle" );
		//AddRequirement( b.reqs, "blob", "mat_gold", "Gold", 25 );
		blocks[0].push_back(b);
	}
	{
		AddIconToken( "$SteelBrick$", "Sprites/World.png", Vec2f(8,8), CMap::tile_steelbrick);
		BuildBlock b(CMap::tile_steelbrick, "SteelBrick", "$SteelBrick$", "Steel Block\nStrong Building Block");
		//AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 20);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "steel_door", "$steel_door$", "Steel Door\nVery Strong");
		//AddRequirement(b.reqs, "blob", "mat_steel", "Steel", 40);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "spikes", "$spikes$", "Spikes\nPlace on Stone Block\nfor Retracting Trap");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
		blocks[0].push_back(b);
	}
	//{
	//	BuildBlock b(-1, "", "", "");
	//	blocks[0].push_back(b);
	//}
	{
		AddIconToken( "$GoldBrick$", "Sprites/World.png", Vec2f(8,8), CMap::tile_goldenbrick);
		BuildBlock b(CMap::tile_goldenbrick, "GoldBrick", "$GoldBrick$", "Gold Block\nRich Building Block\nNot Stronger Than Steel");
		//AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 20);
		blocks[0].push_back(b);
	}
	{
		//AddIconToken( "$gold_door$", "1x1GoldDoor.png", Vec2f(16,8), 0);
		BuildBlock b(0, "gold_door", "$gold_door$", "Gold Door\nRich Building Block");
		AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 40);
		blocks[0].push_back(b);
	}
	//{
	//	BuildBlock b(-1, "", "", ""); // empty spacer button
	//	blocks[0].push_back(b);
	//}	


	BuildBlock[] page_1;
	blocks.push_back(page_1);
	{
		BuildBlock b(0, "wire", "$wire$", "Wire");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "elbow", "$elbow$", "Elbow");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "tee", "$tee$", "Tee");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "junction", "$junction$", "Junction");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 20);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "diode", "$diode$", "Diode");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "resistor", "$resistor$", "Resistor");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "inverter", "$inverter$", "Inverter");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 20);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "oscillator", "$oscillator$", "Oscillator");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "transistor", "$transistor$", "Transistor");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "toggle", "$toggle$", "Toggle");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 20);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "randomizer", "$randomizer$", "Randomizer");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 20);
		blocks[1].push_back(b);
	}

	{
		BuildBlock b(0, "lever", "$lever$", "Lever");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "push_button", "$push_button$", "Button");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 40);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "pressure_plate", "$pressure_plate$", "Pressure Plate");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "sensor", "$sensor$", "Motion Sensor");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 40);
		blocks[1].push_back(b);
	}

	{
		BuildBlock b(0, "lamp", "$lamp$", "Lamp");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "emitter", "$emitter$", "Emitter");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "receiver", "$receiver$", "Receiver");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "magazine", "$magazine$", "Magazine");
		AddRequirement(b.reqs, "blob", "mat_stone", "Wood", 20);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "bolter", "$bolter$", "Bolter");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "dispenser", "$dispenser$", "Dispenser");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "obstructor", "$obstructor$", "Obstructor");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 50);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "spiker", "$spiker$", "Spiker");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 40);
		blocks[1].push_back(b);
	}
	
}