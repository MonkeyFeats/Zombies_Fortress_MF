
#include "PaletteSwap.as"
#include "PixelOffsets.as"

shared class BlobTextures
{
	PixelOffsetsCache offsets;

	string shortname;
	string filename;

	bool loaded;

	BlobTextures(string shortname, string texture_prefix)
	{
		loaded = false;
		shortname = shortname;
		filename = texture_prefix+".png";
	}

	void Load(Vec2f framesize)
	{
		if(loaded) return;

		SColor[] nil; //no need for pixel head colour offsets... for now
		createAndLoadPixelOffsets(shortname, filename, framesize, nil, @offsets);

		loaded = true;
	}

	void Load(CSprite@ sprite)
	{
		if(loaded) return;

		Load(_sprite_to_framesize(sprite));
	}

	//get the texture name

	string texname(CSprite@ sprite)
	{
		return texname(sprite);
	}

	//get the actual cached offsets

	PixelOffsetsCache@ cached_offsets(CSprite@ sprite)
	{
		return cached_offsets(sprite);
	}
};

string getBlobTeamTexture(BlobTextures@ textures, int team_num, int skin_num)
{
	if(textures is null) return "";
	return ApplyTeamTexture(textures.shortname, team_num, skin_num);
}

string getBlobTextureName(CSprite@ sprite)
{
	CBlob@ b = sprite.getBlob();
	return getBlobTeamTexture(getBlobTextures(sprite), b.getTeamNum(), 0);
}

void setBlobTexture(CSprite@ sprite)
{
	string t = getBlobTextureName(sprite);

	//only change if we need it and if it exists
	if(sprite.getTextureName() != t && t != "")
	{
		sprite.SetTexture(t);
	}
}

//call this in oninit from the script housing the object
//it'll change the texture of the sprite to the one for the right

BlobTextures@ fetchFromRules(string shortname, string texture_prefix)
{
	BlobTextures@ tex = null;
	string rules_key = "blob_tex_"+shortname+"_"+texture_prefix;
	if(!getRules().get(rules_key, @tex) || tex is null)
	{
		getRules().set(rules_key, BlobTextures(shortname, texture_prefix));
		//re-fetch
		return fetchFromRules(shortname, texture_prefix);
	}
	return tex;
}

BlobTextures@ addBlobTextures(CSprite@ sprite, string shortname, string texture_prefix)
{
	//fetch it or set it up
	BlobTextures@ tex = fetchFromRules(shortname, texture_prefix);
	//load it out
	tex.Load(sprite);
	//store needed stuff in blob
	CBlob@ b = sprite.getBlob();
	b.set("blob_textures", @tex);
	//set the correct texture
	setBlobTexture(sprite);
	//done
	return tex;
}

//get the textures object directly

BlobTextures@ getBlobTextures(CBlob@ blob)
{
	BlobTextures@ tex = null;
	blob.get("blob_textures", @tex);
	return tex;
}

BlobTextures@ getBlobTextures(CSprite@ sprite)
{
	return getBlobTextures(sprite.getBlob());
}

//ensure the right texture is used
void ensureCorrectBlobTexture(CSprite@ sprite, string shortname, string texture_prefix)
{
	if(getBlobTextures(sprite) is null)
	{
		//first time set up
		addBlobTextures(sprite, shortname, texture_prefix);
	}
	else
	{
		//just set the texture
		CBlob@ b = sprite.getBlob();
		setBlobTexture(sprite);
	}
}
