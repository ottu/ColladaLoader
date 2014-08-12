module collada.animation;

import collada.dataflow;
import collada.utils;

version( unittest )
{
	import std.stdio;
}

struct Channel
{
	string source;
	string target;
	
	void load( XmlNode xml )
	in
	{
		assert( xml.getName == "channel" );
		assert( xml.getAttributes.length == 2 );
		assert( xml.getChildren.length == 0 );
	}
	out
	{
		assert( source != "" );
		assert( target != "" );
	}
	body
	{
		foreach( key, value; xml.getAttributes )
		{
			switch( key )
			{
				case "source" : { source = value; } break;
				case "target" : { target = value; } break;
				default : { throw new Exception( "Channel attribute switch failed." ); } break;
			}
		}
	}
	
}

struct Sampler
{
	string id;
	
	InputA[] inputs;
	
	void load( XmlNode xml )
	in
	{
		assert( xml.getName == "sampler" );
		assert( xml.getAttributes.length <= 1 );
		assert( xml.getChildren.length >= 1 );
	}
	out
	{
		assert( inputs.length >= 1 );
	}
	body
	{
        auto attrs = xml.getAttributes;
        if( "id" in attrs )
            id = attrs["id"];
			
		foreach( elem; xml.getElements )
		{
			switch( elem.getName )
			{
				case "input" :
				{
					InputA input;
					input.load( elem );
					inputs ~= input;
				} break;
				
				default : { throw new Exception( "Sampler element switch failed." ); }
			}
		}
			
	}

}

struct Animation
{
	string id;
	string name;
	
	//asset
	Animation[] animations;
	Source[]    sources;
	Sampler[]   samplers;
	Channel[]   channels;
	//[] extra	
		
	void load( XmlNode xml )
	in
	{
		assert( xml.getName == "animation" );
	}
	out
	{
		assert(
			( animations.length >= 1 )
			||
			(
				( samplers.length >= 1 )
				&&
				( channels.length >= 1 )
				&&
				( samplers.length == channels.length )
			)
		);
	
	}
	body
	{
		foreach( key, value; xml.getAttributes )
		{
			switch( key )
			{
				case "id" : { id = value; } break;
				case "name" : { name = value; } break;
				default : { throw new Exception( "Animation attribute switch failed." ); } break;
			}
		}
		
		foreach( elem; xml.getElements )
		{
			switch( elem.getName )
			{
				//case "asset" : {} break;
				case "animation" :
				{
					Animation animation;
					animation.load( elem );
					animations ~= animation;
				} break;
				
				case "source" :
				{
					Source source;
					source.load( elem );
					sources ~= source;
				} break;
				
				case "sampler" :
				{
					Sampler sampler;
					sampler.load( elem );
					samplers ~= sampler;
				} break;
				
				case "channel" :
				{
					Channel channel;
					channel.load( elem );
					channels ~= channel;
				} break;
				
				//case "extra" : {} break;
				default : { throw new Exception( "Animation element switch failed." ); }
			}
		}
	}

}

struct LibraryAnimations
{
	string id;
	string name;
	
	//asset
	Animation[] animations;
	//[] extra
	
	void load( XmlNode xml )
	in
	{
		assert( xml.getName == "library_animations");
		assert( xml.getChildren.length >= 1 );
	}
	out
	{
		assert( animations.length >= 1 );		
	}
	body
	{
		foreach( key, value; xml.getAttributes )
		{
			switch( key )
			{
				case "id" : { id = value; } break;
				case "name" : { name = value; } break;
				default : { throw new Exception( "LibraryAnimations attribute switch failed." ); } break;
			}
		}
		
		foreach( elem; xml.getElements )
		{
			switch( elem.getName )
			{
				//case "asset" : {} break;
				case "animation" :
				{
					Animation animation;
					animation.load( elem );
					animations ~= animation;
				} break;
				//case "extra" : {} break;
				default : { throw new Exception( "LibraryAnimations element switch failed." ); }
			}
		}
	}

}
