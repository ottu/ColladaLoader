module collada.camera;

import collada.base;
import collada.utils;

import std.algorithm;

version( unittest )
{
    import std.stdio;
    import std.conv : to;
}

enum CAMERATYPE : byte
{
    ORTHOGRAPHIC,
    PERSPECTIVE,
    NONE
}

struct Orthographic
{
    SIDValue xmag;
    SIDValue ymag;
    SIDValue aspect_ratio;
    SIDValue znear;
    SIDValue zfar;

    void load( XmlNode xml )
    in
    {
        assert( xml.getName == "orthographic" );
    }
    out
    {
        assert( ( aspect_ratio.isValid ) || ( xmag.isValid ) || ( ymag.isValid ) );
        assert( znear.isValid );
        assert( zfar.isValid );
    }
    body
    {
        foreach( elem; xml.getElements )
        {
            switch( elem.getName )
            {
                case "xmag"         : { xmag.load( elem ); } break;
                case "ymag"         : { ymag.load( elem ); } break;
                case "aspect_ratio" : { aspect_ratio.load( elem ); } break;
                case "znear"        : { znear.load( elem ); } break;
                case "zfar"         : { zfar.load( elem ); } break;
                default : {} break;
            }
        }
    }

}

struct Perspective
{
    SIDValue xfov;
    SIDValue yfov;
    SIDValue aspect_ratio;
    SIDValue znear;
    SIDValue zfar;

    void load( XmlNode xml )
    in
    {
        assert( xml.getName == "perspective" );
    }
    out
    {
        assert( ( aspect_ratio.isValid ) || ( xfov.isValid ) || ( yfov.isValid ) );
        assert( znear.isValid );
        assert( zfar.isValid );
    }
    body
    {
        foreach( elem; xml.getElements )
        {
            switch( elem.getName )
            {
                case "xfov"         : { xfov.load( elem ); } break;
                case "yfov"         : { yfov.load( elem ); } break;
                case "aspect_ratio" : { aspect_ratio.load( elem ); } break;
                case "znear"        : { znear.load( elem ); } break;
                case "zfar"         : { zfar.load( elem ); } break;
                default : {} break;
            }
        }
    }

}

struct TechniqueCommon
{
    union
    {
        Orthographic orthographic;
        Perspective  perspective;
    }

    CAMERATYPE type = CAMERATYPE.NONE;

    void load( XmlNode xml )
    in
    {
        assert( xml.getName == "technique_common" );
        assert( xml.getElements.length == 1 );
    }
    out
    {
        assert( type != CAMERATYPE.NONE );
    }
    body
    {
        switch( xml.getElements[0].getName )
        {
            case "orthographic" :
            {
                type = CAMERATYPE.ORTHOGRAPHIC;
                orthographic.load( xml.getElements[0] );
            } break;

            case "perspective" :
            {
                type = CAMERATYPE.PERSPECTIVE;
                perspective.load( xml.getElements[0] );
            } break;

            default : {} break;
        }
    }
}

struct Technique
{

}

struct Optics
{

    TechniqueCommon common;
    //[] technique
    //[] extra

    void load( XmlNode xml )
    in
    {
        assert( xml.getName == "optics" );
    }
    out
    {
        assert( this.common.type != CAMERATYPE.NONE );
    }
    body
    {
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

struct Camera
{
    string id;
    string name;

    //asset
    Optics optics;
    //imager
    //[] extra

    void load( XmlNode xml )
    in
    {
        assert( xml.getName == "camera" );
    }
    out
    {
        assert( optics.common.type != CAMERATYPE.NONE );
    }
    body
    {
        foreach( key, value; xml.getAttributes )
        {
            switch( key )
            {
                case "id"   : { id   = value; } break;
                case "name" : { name = value; } break;
                default     : {} break;
            }
        }

        foreach( elem; xml.getElements )
        {
            switch( elem.getName )
            {
                case "asset"  : {} break;
                case "optics" : { optics.load( elem ); } break;
                case "imager" : {} break;
                case "extra"  : {} break;
                default : {} break;
            }
        }
    }
}

struct LibraryCameras
{
    string id;
    string name;

    //asset
    Camera[] cameras;
    //[] extra

    void load( XmlNode xml )
    in
    {
        assert( xml.getName == "library_cameras" );
    }
    out
    {
        assert( cameras.length > 0 );
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
                //case "asset" : {} break;
                case "camera" :
                {
                    Camera camera;
                    camera.load( elem );
                    cameras ~= camera;

                } break;

                //case "extra" : {} break;
                default : { throw new Exception("LibraryCameras Element Switch fault"); }
            }
        }
    }
}

unittest
{
    writeln( "----- collada.camera.LibraryCameras unittest -----" );

    LibraryCameras libcams;
    libcams.load( q{
        <library_cameras>
            <camera id="cl_unnamed_1" name="cl_unnamed_1">
                <optics>
                    <technique_common>
                        <perspective>
                            <yfov>37.8493</yfov>
                            <aspect_ratio>1</aspect_ratio>
                            <znear>10</znear>
                            <zfar>1000</zfar>
                        </perspective>
                    </technique_common>
                </optics>
            </camera>
        </library_cameras>
    }.readDocument.getChildren[0] );

    assert( libcams.cameras.length == 1 );
    assert( libcams.cameras[0].id == "cl_unnamed_1" );
    assert( libcams.cameras[0].name == "cl_unnamed_1" );
    assert( libcams.cameras[0].optics.common.type == CAMERATYPE.PERSPECTIVE );
    assert( libcams.cameras[0].optics.common.perspective.yfov.value.to!string == "37.8493" );
    assert( libcams.cameras[0].optics.common.perspective.aspect_ratio.value.to!string == "1" );
    assert( libcams.cameras[0].optics.common.perspective.znear.value.to!string == "10" );
    assert( libcams.cameras[0].optics.common.perspective.zfar.value.to!string == "1000" );

    writeln( "----- LibraryCameras done -----" );
}
