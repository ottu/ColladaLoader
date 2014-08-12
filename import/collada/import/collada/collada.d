module collada.collada;

public
{
    import collada.animation;
    import collada.camera;
    import collada.controller;
    import collada.effect;
    import collada.geometry;
    import collada.image;
    import collada.light;
    import collada.model;
    import collada.material;
    import collada.scene;
    import collada.utils;
}

import std.stdio;
import std.algorithm;
import std.array;
import std.file;

private string Gen( string lib, string name )
{
    return "vals = elems.find!( elem => elem.getName ==\"" ~ name ~ "\" );" ~
           "if( vals.length > 0 ) { writeln( \"" ~ name ~ "\" ); " ~ lib ~ ".load( vals[0] ); }";
}


class Collada
{
    XmlNode _self;

	//asset
	LibraryAnimations   libAnimations;
	LibraryCameras      libCameras;
	LibraryControllers  libControllers;
	LibraryEffects      libEffects;
	LibraryGeometries   libGeometries;
	LibraryImages       libImages;
	LibraryLights       libLights;
	LibraryMaterials    libMaterials;
	LibraryVisualScenes libVisualScenes;
	//[] extra
	
    this( string filePath )
    {
        XmlDocument doc = XmlDocument( readText( filePath ) );
        _self = doc.getElements.find!( elem => elem.getName == "COLLADA" ).array[0];

        auto elems = _self.getElements;
        XmlNode[] vals = [];

        mixin( Gen( "libAnimations",   "library_animations" ) );
        mixin( Gen( "libCameras",      "library_cameras" ) );
        mixin( Gen( "libControllers",  "library_controllers" ) );
        mixin( Gen( "libEffects",      "library_effects" ) );
        mixin( Gen( "libGeometries",   "library_geometries" ) );
        mixin( Gen( "libImages",       "library_images" ) );
        mixin( Gen( "libLights",       "library_lights" ) );
        mixin( Gen( "libMaterials",    "library_materials" ) );
        mixin( Gen( "libVisualScenes", "library_visual_scenes" ) );
    }	
	
    ~this() { }

}

unittest
{
	writeln("----- collada.Collada unittest -----");
	//Collada collada = new Collada;
	//collada.load( parseXML( import("multimtl_triangulate.dae") ).root );
	//collada.load( parseXML( import("Appearance_Miku.dae") ).root );
	
	writeln("----- Collada done -----");
}
