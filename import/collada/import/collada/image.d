module collada.image;

import collada.base;
import collada.utils;

version( unittest )
{
    import std.stdio;
}

enum IMAGETYPE : byte
{
    DATA,
    INITFROM,
    NONE
}

struct Image
{
    string id;
    string name;
    string format;
    uint height;
    uint width;
    uint depth;

    //asset
    //union
    //{
    //    string data
        string initFrom;
    //}
    IMAGETYPE type = IMAGETYPE.NONE;
    //imager
    //[] extra

    void load( XmlNode xml )
    in
    {
        assert( xml.getName == "image" );
    }
    out
    {
        assert( type != IMAGETYPE.NONE );
    }
    body
    {
        foreach( key, value; xml.getAttributes )
        {
            switch( key )
            {
                case "id"   : { id   = value; } break;
                case "name" : { name = value; } break;
                default     : { throw new Exception("Image attribute switch fault."); }
            }
        }

        foreach( elem; xml.getElements )
        {
            switch( elem.getName )
            {
                //case "asset"  : {} break;
                //case "data" : {} break;
                case "init_from" :
                {
                    type = IMAGETYPE.INITFROM;
                    initFrom = elem.getTexts[0];
                } break;
                //case "extra"  : {} break;
                default     : { throw new Exception("Image element switch fault."); }
            }
        }
    }
}

struct LibraryImages
{
    string id;
    string name;

    //asset
    Image[] images;
    //[] extra

    void load( XmlNode xml )
    in
    {
        assert( xml.getName == "library_images" );
    }
    out
    {
        assert( images.length > 0 );
    }
    body
    {
        foreach( key, value; xml.getAttributes )
        {
            switch( key )
            {
                case "id"   : { id = value; } break;
                case "name" : { name = value; } break;
                default : { throw new Exception("LibraryImages attribute switch fault"); }
            }
        }

        foreach( elem; xml.getElements )
        {
            switch( elem.getName )
            {
                //case "asset" : {} break;
                case "image" :
                {
                    Image image;
                    image.load( elem );
                    images ~= image;
                } break;
                //case "extra" : {} break;
                default : { throw new Exception("LibraryImages element switch fault"); }
            }
        }
    }
}

unittest
{
    writeln( "----- collada.light.LibraryImages unittest -----" );

    LibraryImages lib;
    lib.load( q{
        <library_images>
            <image id="Image-00">
                <init_from>huku3.bmp</init_from>
            </image>
            <image id="Image-01">
                <init_from>huku1.bmp</init_from>
            </image>
            <image id="Image-02">
                <init_from>kami.bmp</init_from>
            </image>
            <image id="Image-03">
                <init_from>kami_ol.bmp</init_from>
            </image>
            <image id="Image-04">
                <init_from>heltudofon.bmp</init_from>
            </image>
            <image id="Image-05">
                <init_from>huku3w.bmp</init_from>
            </image>
            <image id="Image-06">
                <init_from>me.bmp</init_from>
            </image>
            <image id="Image-07">
                <init_from>hoho.png</init_from>
            </image>
        </library_images>
    }.readDocument.getChildren[0] );

    assert( lib.images.length == 8 );
    assert( lib.images[0].id == "Image-00" );
    assert( lib.images[0].initFrom == "huku3.bmp" );

    writeln( "----- LibraryImages done -----" );
}
