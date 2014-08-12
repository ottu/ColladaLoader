module collada.light;

import collada.base;
import collada.utils;

import std.algorithm;

version( unittest ) 
{ 
	import std.stdio; 
	import std.conv : to;
}

enum LIGHTTYPE : byte
{
	AMBIENT,
	DIRECTIONAL,
	POINT,
	SPOT,
	NONE
}

struct Ambient
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

struct Directional
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

struct Point
{
	Float3 color;
	SIDValue constant;
	SIDValue linear;
	SIDValue quadratic;
	
	void load( XmlNode xml )
	in
	{
		assert( xml.getName == "point" );
	}
	out
	{
		assert( color.isValid );
		assert( quadratic.isValid );
	}
	body
	{
		foreach( elem; xml.getElements )
		{
			switch( elem.getName )
			{
				case "color"                 : { color.load( elem ); } break;
				case "constant_attenuation"  : { constant.load( elem ); } break;
				case "linear_attenuation"    : { linear.load( elem ); } break;
				case "quadratic_attenuation" : { quadratic.load( elem ); } break;
				default : {} break;
			}
		}
	}

}

struct Spot
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

struct Common
{
	union
	{
		Ambient     ambient;
		Directional directional;
		Point       point;
		Spot        spot;
	}
	
	LIGHTTYPE type = LIGHTTYPE.NONE;
	
	void load( XmlNode xml )
	in
	{
		assert( xml.getName == "technique_common" );
		assert( xml.getElements.length == 1 );
	}
	out
	{
		assert( type != LIGHTTYPE.NONE );
	}
	body
	{
		switch( xml.getElements[0].getName )
		{
			case "ambient" :
			{
				type = LIGHTTYPE.AMBIENT;
				ambient.load( xml.getElements[0] );
			} break;
			
			case "directional" :
			{ 
				type = LIGHTTYPE.DIRECTIONAL;
				directional.load( xml.getElements[0] ); 
			} break;
			
			case "point" :
			{
				type = LIGHTTYPE.POINT;
				point.load( xml.getElements[0] );			
			} break;
			
			case "spot" :
			{
				type = LIGHTTYPE.SPOT;
				spot.load( xml.getElements[0] );
			} break;
			
			default : {} break;
		}
	}
}

struct Technique
{

}

struct Light
{
	string id;
	string name;
	
	//asset
	Common common;
	//[] technique
	//[] extra
	
	void load( XmlNode xml )
	in
	{
		assert( xml.getName == "light" );
	}
	out
	{
		assert( common.type != LIGHTTYPE.NONE );
	}
	body
	{
        foreach( key, value; xml.getAttributes )
		{
			switch( key )
			{
				case "id"   : { id = value; } break;
				case "name" : { name = value; } break;
				default : {} break;
			}
		}
	
		foreach( elem; xml.getElements )
		{
			switch( elem.getName )
			{
				case "technique_common" : { common.load( elem ); } break;				
				case "technique"        : {} break;
				case "extra"            : {} break;
				default : {} break;
			}
		}
	}
}

struct LibraryLights
{
	string id;
	string name;
	
	//asset
	Light[] lights;
	//[] extra
	
	void load( XmlNode xml )
	in
	{
		assert( xml.getName == "library_lights" );
	}
	out
	{
		assert( lights.length >= 1 );
	}
	body
	{
        foreach( key, value; xml.getAttributes )
		{
			switch( key )
			{
				case "id"   : { id = value; } break;
				case "name" : { name = value; } break;
				default : {} break;
			}
		}
		
		foreach( elem; xml.getElements )
		{
			switch( elem.getName )
			{
				case "asset" : {} break;
				case "light" :
				{
					Light light;
					light.load( elem );
					lights ~= light;
				
				} break;
				
				case "extra" : {} break;
				default : {} break;
			}
		}
	}
}

unittest
{
	writeln( "----- collada.light.LibraryLights unittest -----" );

	LibraryLights lib;
	lib.load( q{
		<library_lights>
			<light id="Lt_Light-lib" name="Lt_Light">
				<technique_common>
					<point>
						<color>1 1 1</color>
						<constant_attenuation>1</constant_attenuation>
						<linear_attenuation>0</linear_attenuation>
						<quadratic_attenuation>0</quadratic_attenuation>
					</point>
				</technique_common>
			</light>
		</library_lights>
	}.readDocument.getChildren[0] );
	
	assert( lib.lights[0].id == "Lt_Light-lib" );
	assert( lib.lights[0].name == "Lt_Light" );
	assert( lib.lights[0].common.type == LIGHTTYPE.POINT );
	assert( lib.lights[0].common.point.color.value[0].to!string == "1" );
	assert( lib.lights[0].common.point.color.value[1].to!string == "1" );
	assert( lib.lights[0].common.point.color.value[2].to!string == "1" );
	assert( lib.lights[0].common.point.constant.value.to!string == "1" );
	assert( lib.lights[0].common.point.linear.value.to!string == "0" );
	assert( lib.lights[0].common.point.quadratic.value.to!string == "0" );
	
	writeln( "----- LibraryLights done -----" );
}
