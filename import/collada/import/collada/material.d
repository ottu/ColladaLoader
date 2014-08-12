module collada.material;

import collada.base;
import collada.instance;
import collada.utils;

import std.algorithm;

version( unittest )
{
    import std.stdio;
    import std.conv : to;
}

struct Material
{
    string id;
    string name;

    //asset
    InstanceEffect effect;
    //[] extra

    void load( XmlNode xml )
    in
    {
        assert( xml.getName == "material" );
    }
    out
    {
        assert( effect.url != "" );
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
                case "asset"           : {} break;
                case "instance_effect" : { effect.load( elem ); } break;
                case "extra"           : {} break;
                default : {} break;
            }
        }
    }
}

struct LibraryMaterials
{
    string id;
    string name;

    //asset
    Material[] materials;
    //[] extra

    void load( XmlNode xml )
    in
    {
        assert( xml.getName == "library_materials" );
    }
    out
    {
        assert( materials.length >= 1 );
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
                case "material" :
                {
                    Material material;
                    material.load( elem );
                    materials ~= material;

                } break;

                case "extra" : {} break;
                default : {} break;
            }
        }
    }
}

unittest
{
    writeln( "----- collada.material.LibraryMaterials unittest -----" );

    LibraryMaterials lib;
    lib.load( q{
        <library_materials>
            <material id="Blue" name="Blue">
                <instance_effect url="#Blue-fx"/>
            </material>
        </library_materials>
    }.readDocument.getChildren[0] );

    assert( lib.materials[0].id == "Blue" );
    assert( lib.materials[0].name == "Blue" );
    assert( lib.materials[0].effect.url == "#Blue-fx" );

    writeln( "----- LibraryMaterials done -----" );
}
