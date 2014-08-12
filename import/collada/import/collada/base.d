module collada.base;

import collada.utils;

import std.algorithm;
import std.conv;

version( unittest )
{
	import std.stdio;
}

struct SIDValue
{
	string sid;
	float value = float.nan;
	alias value this;
	
	void load( XmlNode xml )
	in
	{
		assert( xml.getTexts.length == 1 );
	}
	out
	{
		assert( this.isValid );
	}
	body
	{
		if( xml.getAttributes.length == 1 )
		{
			assert( "sid" in xml.getAttributes );
			this.sid = xml.getAttributes["sid"];
		}
		
		this.value = to!float( xml.getTexts[0] );
	}
	
	bool isValid() { return this.value != float.nan; }
}

struct FloatCount(int count)
{
	float[count] value;
	alias value this;
	
	void load( XmlNode xml )
	in
	{
		//assert( xml.getName == "color" );
		assert( xml.getTexts[0].split.length == count );
	}
	out
	{
		assert( this.isValid );
	}
	body
	{
		foreach( i, text; xml.getTexts[0].split )
        {
			value[i] = to!float( text );
        }
	}
		
	bool isValid() { return reduce!"a && (b != float.nan)"( true, value[] ); }
}

alias FloatCount!(1) Float1;
alias FloatCount!(2) Float2;
alias FloatCount!(3) Float3;
alias FloatCount!(4) Float4;
alias FloatCount!(16) Float16;

enum COLORTEXTURETYPE : byte
{
	COLOR,
	PARAM,
	TEXTURE,
	NONE
}

struct Texture
{
	string texture;
	string texcoord;
	//[]extra
	
	void load( XmlNode xml )
	in
	{
		assert( xml.getName == "texture" );
		assert( xml.getAttributes.length == 2 );
		assert( xml.getElements.length == 0 );
	}
	out
	{
		assert( texture != "" );
		assert( texcoord != "" );
	}
	body
	{
		foreach( key, value; xml.getAttributes )
		{
			switch( key )
			{
				case "texture"  : { texture  = value; } break;
				case "texcoord" : { texcoord = value; } break;
				default : { throw new Exception("Texture(base) attribure switch faild." ); } break;
			}
		}
	}
}

struct CommonColorOrTextureType
{
	union
	{
		Float4 color;
		Float4 param;
		Texture texture;
	}
	
	COLORTEXTURETYPE type = COLORTEXTURETYPE.NONE;
	
	void load( XmlNode xml )
	in
	{
		assert( [ "ambient", "diffuse", "emission", 
		          "reflective", "specular", "transparent" ].find( xml.getName ) != [] );
		assert( xml.getElements.length == 1 );
	}
	out
	{
		assert( type != COLORTEXTURETYPE.NONE );
	}
	body
	{
        auto elem = xml.getElements[0];
		switch( elem.getName )
		{
			case "color" :
			{ 
				type = COLORTEXTURETYPE.COLOR;
				color.load( elem );
			}break;
			
			case "param" : 
			{
				type = COLORTEXTURETYPE.PARAM;
				param.load( elem );
			} break;
			
			case "texture" :
			{
				type = COLORTEXTURETYPE.TEXTURE;
				texture.load( elem );
			} break;
			
			default : { throw new Exception("CommonColorOrTextureType element switch faild."); }
		}
	}
		
}

enum FLOATPARAMTYPE : byte
{
	FLOAT,
	PARAM,
	NONE
}

struct CommonFloatOrParamType
{

	union
	{
		Float1 float_;
		Float1 param;
	}
	
	FLOATPARAMTYPE type = FLOATPARAMTYPE.NONE;
	
	void load( XmlNode xml )
	in
	{
		//assert( [ "shininess", "reflectivity", "transparency", "index_of_refraction" ].find!( xml.getName ) != [] );
		assert( xml.getElements.length == 1 );
	}
	out
	{
		assert( type != FLOATPARAMTYPE.NONE );
	}
	body
	{
        auto elem = xml.getElements[0];
		switch( elem.getName )
		{
			case "float" :
			{
				type = FLOATPARAMTYPE.FLOAT;
				float_.load( elem );
			} break;
			
			case "param" :
			{ 
				type = FLOATPARAMTYPE.PARAM;
				param.load( elem );
			} break;
			
			default : {} break;
		}
	}		
}

struct Constant
{

	void load( XmlNode xml )
	in
	{
		assert( xml.getName == "constant" );
	}
	out
	{
	
	}
	body
	{
	
	}

}

struct Lambert
{

	void load( XmlNode xml )
	in
	{
		assert( xml.getName == "lambert" );
	}
	out
	{
	
	}
	body
	{
	
	}
}

struct Phong
{

	CommonColorOrTextureType emission;
	CommonColorOrTextureType ambient;
	CommonColorOrTextureType diffuse;
	CommonColorOrTextureType specular;
	CommonFloatOrParamType   shininess;
	CommonColorOrTextureType reflective;
	CommonFloatOrParamType   reflectivity;
	CommonColorOrTextureType transparent;
	CommonFloatOrParamType   transparency;
	CommonFloatOrParamType   index_of_refraction;	

	void load( XmlNode xml )
	in
	{
		assert( xml.getName == "phong" );
	}
	out
	{
	
	}
	body
	{
	
		foreach( elem; xml.getElements )
		{
			switch( elem.getName )
			{
				case "emission"     : { emission.load( elem ); } break;
				case "ambient"      : { ambient.load( elem ); } break;
				case "diffuse"      : { diffuse.load( elem ); } break;
				case "specular"     : { specular.load( elem ); } break;
				case "shininess"    : { shininess.load( elem ); } break;
				case "reflective"   : { reflective.load( elem ); } break;
				case "reflectivity" : { reflectivity.load( elem ); } break;
				case "transparent"  : { transparent.load( elem ); } break;
				case "transparency" : { transparency.load( elem ); } break;
				case "index_of_refraction" : { index_of_refraction.load( elem ); } break;
				default : {} break;
			}
		}	
	}
}

struct Blinn
{

	void load( XmlNode xml )
	in
	{
		assert( xml.getName == "blinn" );
	}
	out
	{
	
	}
	body
	{
	
	}
}
