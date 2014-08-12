module collada.effect;

import collada.base;
import collada.utils;

import std.algorithm;
import std.conv : to;

version( unittest )
{
	import std.stdio;
}

enum PROFILETYPE : byte
{
	BRIDGE,
	CG,
	GLES,
	GLES2,
	GLSL,
	COMMON,
	NONE
}

struct ProfileBRIDGE
{

	void load( XmlNode xml )
	in
	{
	
	}
	out
	{
	
	}
	body
	{
	
	}
}

struct ProfileCG
{

	void load( XmlNode xml )
	in
	{
	
	}
	out
	{
	
	}
	body
	{
	
	}
}

struct ProfileGLES
{

	void load( XmlNode xml )
	in
	{
	
	}
	out
	{
	
	}
	body
	{
	
	}
}

struct ProfileGLES2
{

	void load( XmlNode xml )
	in
	{
	
	}
	out
	{
	
	}
	body
	{
	
	}
}

struct ProfileGLSL
{

	void load( XmlNode xml )
	in
	{
	
	}
	out
	{
	
	}
	body
	{
	
	}
}

enum SURFACETYPE : byte
{
	UNTYPED,
	ONED,
	TWOD,
	THREED,
	CUBE,
	DEPTH,
	RECT,
	NONE
}

//tekitou
struct Surface
{
	SURFACETYPE type = SURFACETYPE.NONE;
	string initFrom;
	string format;
	
	void load( XmlNode xml )
	in
	{
		assert( xml.getName == "surface" );
		assert( xml.getAttributes.length == 1 );
        assert( "type" in xml.getAttributes );
	}
	out
	{
		assert( type != SURFACETYPE.NONE );
	}
	body
	{
        switch( xml.getAttributes["type"] )
        {
            case "UNTYPED" : { type = SURFACETYPE.UNTYPED; } break;
            case "1D"      : { type = SURFACETYPE.ONED;     } break;
            case "2D"      : { type = SURFACETYPE.TWOD;     } break;
            case "3D"      : { type = SURFACETYPE.THREED;   } break;
            case "CUBE"    : { type = SURFACETYPE.CUBE;     } break;
            case "DEPTH"   : { type = SURFACETYPE.DEPTH;    } break;
            case "RECT"    : { type = SURFACETYPE.RECT;     } break;
            default : { throw new Exception("Surface(effect) attribute switch faild." ); }
        }

		foreach( elem; xml.getElements )
		{
			switch( elem.getName )
			{
				case "init_from" : { initFrom = elem.getTexts[0]; } break;
				case "format"    : { format = elem.getTexts[0]; } break;
				default : { throw new Exception("Surface(effect) element switch faild." ); }
			}
		}
	
	}

}

struct Sampler2D
{
	string source;
	//wrap_s
	//wrap_t
	string minfilter;
	string magfilter;
	string mipfilter;
	int    border_color = 0;
	ubyte  mipmap_maxlevel = 255;
	int    mipmap_bias = 0;
	//[] extra
	
	void load( XmlNode xml )
	in
	{
		assert( xml.getName == "sampler2D" );
		assert( xml.getAttributes.length == 0 );
		assert( xml.getElements.length >= 1 );
	}
	out
	{
		assert( source != "" );
	}
	body
	{
		foreach( elem; xml.getElements )
		{
			switch( elem.getName )
			{
				case "source" : { source = elem.getTexts[0]; } break;
				//case "wrap_s" : {} break;
				//case "wrap_t" : {} break;
				case "minfilter" : { minfilter = elem.getTexts[0]; } break;
				case "magfilter" : { magfilter = elem.getTexts[0]; } break;
				case "mipfilter" : { mipfilter = elem.getTexts[0]; } break;
				case "border_color" : { border_color = elem.getTexts[0].to!int; } break;
				case "mipmap_maxlevel" : { mipmap_maxlevel = elem.getTexts[0].to!ubyte; } break;
				case "mipmap_bias" : { mipmap_bias = elem.getTexts[0].to!int; } break;
				default : { throw new Exception("Sampler2D(effect) element switch faild."); }
			}
		}
	}
}

enum NEWPARAMTYPE : byte
{
	FLOAT1,
	FLOAT2,
	FLOAT3,
	SURFACE,
	SAMPLER2D,
	NONE
}

struct NewParamCOMMON
{
	string sid;

	string semantic;
	union
	{
		Float1 float1;
		Float2 float2;
		Float3 float3;
		Surface surface;
		Sampler2D sampler2d;
	}
	NEWPARAMTYPE type = NEWPARAMTYPE.NONE;
	
	void load( XmlNode xml )
	in
	{
		assert( xml.getName == "newparam" );
		assert( xml.getAttributes.length == 1 );
        assert( "sid" in xml.getAttributes );
	}
	out
	{
		assert( sid != "" );
		assert( type != NEWPARAMTYPE.NONE );
	}
	body
	{
	    sid = xml.getAttributes["sid"];
			
		foreach( elem; xml.getElements )
		{
			switch( elem.getName )
			{
				case "semantic" : { semantic = elem.getTexts[0]; } break;
				
				case "float" :
				{
					type = NEWPARAMTYPE.FLOAT1;
					float1.load( elem );					
				} break;
				
				case "float2" :
				{
					type = NEWPARAMTYPE.FLOAT2;
					float2.load( elem );
				} break;
				
				case "float3" :
				{
					type = NEWPARAMTYPE.FLOAT3;
					float3.load( elem );
				} break;
				
				case "surface" :
				{
					type = NEWPARAMTYPE.SURFACE;
					surface.load( elem );
				} break;
				
				case "sampler2D" :
				{
					type = NEWPARAMTYPE.SAMPLER2D;
					sampler2d.load( elem );
				} break;
				
				default : { throw new Exception( "NewParam(effect) element switch faild." ); }
			}
		}
	
	}
}

enum SHADERELEMENTTYPE : byte
{
	CONSTANT,
	LAMBERT,
	PHONG,
	BLINN,
	NONE
}

struct TechniqueCOMMON
{
	string id;
	string sid;
	
	//asset
	//image
	union
	{
		Constant constant;
		Lambert  lambert;
		Phong    phong;
		Blinn    blinn;
	}
	SHADERELEMENTTYPE type = SHADERELEMENTTYPE.NONE;
	//[] extra
	
	void load( XmlNode xml )
	in
	{
		assert( xml.getName == "technique" );
		assert( xml.getAttributes.length >= 1 );
	}
	out
	{
		assert( sid != "" );
		assert( type != SHADERELEMENTTYPE.NONE );
	}
	body
	{
	
        foreach( key, value; xml.getAttributes )
		{
			switch( key )
			{
				case "id"  : { id  = value; } break;
				case "sid" : { sid = value; } break;
				default : {} break;
			}
		}
		
		foreach( elem; xml.getElements )
		{
			switch( elem.getName )
			{
				case "asset" : {} break;
				
				case "constant" :
				{
					type = SHADERELEMENTTYPE.CONSTANT;
					constant.load( elem );
				} break;
				
				case "lambert" :
				{
					type = SHADERELEMENTTYPE.LAMBERT;
					lambert.load( elem );
				} break;
				
				case "phong" :
				{
					type = SHADERELEMENTTYPE.PHONG;
					phong.load( elem );
				} break;
				
				case "blinn" :
				{
					type = SHADERELEMENTTYPE.BLINN;
					blinn.load( elem );
				} break;
				
				case "extra" : {} break;
				default : {} break;
			}		
		}
	
	}
}

struct ProfileCOMMON
{
	string id;
	
	//asset
	NewParamCOMMON[] newparams;
	TechniqueCOMMON technique;
	//[] extra
	
	void load( XmlNode xml )
	in
	{
		assert( xml.getName == "profile_COMMON" );
		assert( xml.getAttributes.length <= 1 );
	}
	out
	{
		assert( technique.sid != "" );
	}
	body
	{
        if( "id" in xml.getAttributes )
            id = xml.getAttributes["id"];
		
		foreach( elem; xml.getElements )
		{
			switch( elem.getName )
			{
				//case "asset"     : {} break;
				case "newparam"  : 
				{
					NewParamCOMMON newparam;
					newparam.load( elem );
					newparams ~= newparam;
				} break;				
				case "technique" : { technique.load( elem ); } break;
				//case "extra"     : {} break;
				default : { throw new Exception("ProfileCOMMON(effect) element switch faild."); }
			}
		}
	
	}
}

struct Profile
{

	union
	{
		ProfileBRIDGE bridge;
		ProfileCG     cg;
		ProfileGLES   gles;
		ProfileGLES2  gles2;
		ProfileGLSL   glsl;
		ProfileCOMMON common;
	}
	
	PROFILETYPE type = PROFILETYPE.NONE;
	
	void load( XmlNode xml )
	in
	{
		assert( [ "profile_BRIDGE", "profile_CG", "profile_GLES", 
		          "profile_GLES2", "profile_GLSL", "profile_COMMON" ].find( xml.getName ) != [] );
	}
	out
	{
		assert( type != PROFILETYPE.NONE );
	}
	body
	{
		switch( xml.getName )
		{
			
			case "profile_BRIDGE" : 
			{
				type = PROFILETYPE.BRIDGE;
				bridge.load( xml );					
			} break;
			
			case "profile_CG" : 
			{
				type = PROFILETYPE.CG;
				cg.load( xml );					
			} break;
			
			case "profile_GLES" : 
			{
				type = PROFILETYPE.GLES;
				gles.load( xml );
			} break;
			
			case "profile_GLES2" : 
			{
				type = PROFILETYPE.GLES2;
				gles2.load( xml );
			} break;
			
			case "profile_GLSL" : 
			{
				type = PROFILETYPE.GLSL;
				glsl.load( xml );
			} break;
			
			case "profile_COMMON" : 
			{
				type = PROFILETYPE.COMMON;
				common.load( xml );
			} break;
			
			default : { throw new Exception("Profile(effect) element switch fault."); }
		}
	}
}

struct Effect
{
	string id;
	string name;
	
	//asset
	//[] annotate
	//[] newparam
	Profile[] profiles;
	//[] extra
	
	void load( XmlNode xml )
	in
	{
		assert( xml.getName == "effect" );
	}
	out
	{
		assert( profiles.length >= 1 );
	}
	body
	{
        foreach( key, value; xml.getAttributes )
		{
			switch( key )
			{
				case "id"   : { id = value; } break;
				case "name" : { name = value; } break;
				default : { throw new Exception("Element attribute switch fault."); } break;
			}
		}
	
		foreach( elem; xml.getElements )
		{
			switch( elem.getName )
			{
				//case "asset"           : {} break;
				
				case "profile_BRIDGE" :
				case "profile_CG" : 
				case "profile_GLES" :
				case "profile_GLES2" :
				case "profile_GLSL" : 
				case "profile_COMMON" : 
				{
					Profile profile;
					profile.load( elem );
					profiles ~= profile;
				} break;
				
				//case "extra" : {} break;
				default : { throw new Exception("Effect element switch fault."); }
			}
		}
	}
}

struct LibraryEffects
{
	string id;
	string name;
	
	//asset
	Effect[] effects;
	//[] extra
	
	void load( XmlNode xml )
	in
	{
		assert( xml.getName == "library_effects" );
	}
	out
	{
		assert( effects.length >= 1 );
	}
	body
	{
        foreach( key, value; xml.getAttributes )
		{
			switch( key )
			{
				case "id"   : { id = value; } break;
				case "name" : { name = value; } break;
				default : { throw new Exception("LibraryEffects attribute switch fault."); } break;
			}
		}
		
		foreach( elem; xml.getElements )
		{
			switch( elem.getName )
			{
				//case "asset" : {} break;
				case "effect" :
				{
					Effect effect;
					effect.load( elem );
					effects ~= effect;
				
				} break;				
				//case "extra" : {} break;
				default : { throw new Exception("LibraryEffects element switch fault."); }
			}
		}
	}
}

unittest
{
	writeln( "----- collada.effect.LibraryEffects unittest -----" );
	
	LibraryEffects lib;
	lib.load( q{
		<library_effects>
			<effect id="Blue-fx">
				<profile_COMMON>
					<technique sid="common">
						<phong>
							<emission>
								<color>0 0 0 1</color>
							</emission>
							<ambient>
								<color>0 0 0 1</color>
							</ambient>
							<diffuse>
								<color>0.137255 0.403922 0.870588 1</color>
							</diffuse>
							<specular>
								<color>0.5 0.5 0.5 1</color>
							</specular>
							<shininess>
								<float>10</float>
							</shininess>
							<reflective>
								<color>0 0 0 1</color>
							</reflective>
							<reflectivity>
								<float>0.5</float>
							</reflectivity>
							<transparent>
								<color>0 0 0 1</color>
							</transparent>
							<transparency>
								<float>1</float>
							</transparency>
							<index_of_refraction>
								<float>0</float>
							</index_of_refraction>
						</phong>
					</technique>
				</profile_COMMON>
			</effect>
		</library_effects>
	}.readDocument.getChildren[0] );
	
	assert( lib.effects[0].id == "Blue-fx" );
	assert( lib.effects[0].profiles[0].type == PROFILETYPE.COMMON );
	assert( lib.effects[0].profiles[0].common.technique.sid == "common" );
	assert( lib.effects[0].profiles[0].common.technique.type == SHADERELEMENTTYPE.PHONG );
	assert( lib.effects[0].profiles[0].common.technique.phong.emission.type == COLORTEXTURETYPE.COLOR );
	assert( lib.effects[0].profiles[0].common.technique.phong.emission.color.value[0].to!string == "0" );
	assert( lib.effects[0].profiles[0].common.technique.phong.emission.color.value[1].to!string == "0" );
	assert( lib.effects[0].profiles[0].common.technique.phong.emission.color.value[2].to!string == "0" );
	assert( lib.effects[0].profiles[0].common.technique.phong.emission.color.value[3].to!string == "1" );
	
	assert( lib.effects[0].profiles[0].common.technique.phong.ambient.type == COLORTEXTURETYPE.COLOR );
	assert( lib.effects[0].profiles[0].common.technique.phong.ambient.color.value[0].to!string == "0" );
	assert( lib.effects[0].profiles[0].common.technique.phong.ambient.color.value[1].to!string == "0" );
	assert( lib.effects[0].profiles[0].common.technique.phong.ambient.color.value[2].to!string == "0" );
	assert( lib.effects[0].profiles[0].common.technique.phong.ambient.color.value[3].to!string == "1" );
	
	assert( lib.effects[0].profiles[0].common.technique.phong.diffuse.type == COLORTEXTURETYPE.COLOR );
	assert( lib.effects[0].profiles[0].common.technique.phong.diffuse.color.value[0].to!string == "0.137255" );
	assert( lib.effects[0].profiles[0].common.technique.phong.diffuse.color.value[1].to!string == "0.403922" );
	assert( lib.effects[0].profiles[0].common.technique.phong.diffuse.color.value[2].to!string == "0.870588" );
	assert( lib.effects[0].profiles[0].common.technique.phong.diffuse.color.value[3].to!string == "1" );
	
	assert( lib.effects[0].profiles[0].common.technique.phong.specular.type == COLORTEXTURETYPE.COLOR );
	assert( lib.effects[0].profiles[0].common.technique.phong.specular.color.value[0].to!string == "0.5" );
	assert( lib.effects[0].profiles[0].common.technique.phong.specular.color.value[1].to!string == "0.5" );
	assert( lib.effects[0].profiles[0].common.technique.phong.specular.color.value[2].to!string == "0.5" );
	assert( lib.effects[0].profiles[0].common.technique.phong.specular.color.value[3].to!string == "1" );
	
	assert( lib.effects[0].profiles[0].common.technique.phong.shininess.type == FLOATPARAMTYPE.FLOAT );
	assert( lib.effects[0].profiles[0].common.technique.phong.shininess.float_.value[0].to!string == "10" );
	
	assert( lib.effects[0].profiles[0].common.technique.phong.reflective.type == COLORTEXTURETYPE.COLOR );
	assert( lib.effects[0].profiles[0].common.technique.phong.reflective.color.value[0].to!string == "0" );
	assert( lib.effects[0].profiles[0].common.technique.phong.reflective.color.value[1].to!string == "0" );
	assert( lib.effects[0].profiles[0].common.technique.phong.reflective.color.value[2].to!string == "0" );
	assert( lib.effects[0].profiles[0].common.technique.phong.reflective.color.value[3].to!string == "1" );
	
	assert( lib.effects[0].profiles[0].common.technique.phong.reflectivity.type == FLOATPARAMTYPE.FLOAT );
	assert( lib.effects[0].profiles[0].common.technique.phong.reflectivity.float_.value[0].to!string == "0.5" );
	
	assert( lib.effects[0].profiles[0].common.technique.phong.transparent.type == COLORTEXTURETYPE.COLOR );
	assert( lib.effects[0].profiles[0].common.technique.phong.transparent.color.value[0].to!string == "0" );
	assert( lib.effects[0].profiles[0].common.technique.phong.transparent.color.value[1].to!string == "0" );
	assert( lib.effects[0].profiles[0].common.technique.phong.transparent.color.value[2].to!string == "0" );
	assert( lib.effects[0].profiles[0].common.technique.phong.transparent.color.value[3].to!string == "1" );
	
	assert( lib.effects[0].profiles[0].common.technique.phong.transparency.type == FLOATPARAMTYPE.FLOAT );
	assert( lib.effects[0].profiles[0].common.technique.phong.transparency.float_.value[0].to!string == "1" );
	
	assert( lib.effects[0].profiles[0].common.technique.phong.index_of_refraction.type == FLOATPARAMTYPE.FLOAT );
	assert( lib.effects[0].profiles[0].common.technique.phong.index_of_refraction.float_.value[0].to!string == "0" );
	
	writeln( "----- LibraryEffects done -----" );
}

