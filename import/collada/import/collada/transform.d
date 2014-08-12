module collada.transform;

import collada.base;
import collada.utils;

import std.conv : to;
import std.algorithm;
import std.array;

version( unittest )
{
    import std.stdio;
}

struct LookAt
{
    string sid;
    Float3 P;
    Float3 I;
    Float3 UP;

    FloatCount!(9) value;
    alias value this;

    void load( XmlNode xml )
    in
    {
        assert( xml.getName == "lookat" );
        assert( xml.getAttributes.length <= 1 );
        assert( xml.getElements.length == 0 );
        assert( xml.getTexts[0].split.length == 9 );
    }
    out
    {
        assert( P.isValid );
        assert( I.isValid );
        assert( UP.isValid );
        assert( value.isValid );
    }
    body
    {
        if( "sid" in xml.getAttributes )
            sid = xml.getAttributes["sid"];

        float[] values = xml.getTexts[0].split.map!"a.to!float".array;
        P  = [ values[0], values[1], values[2] ];
        I  = [ values[3], values[4], values[5] ];
        UP = [ values[6], values[7], values[8] ];

        value = P ~ I ~ UP;
    }
}

unittest
{
    writeln( "----- collada.transform.LookAt unittest -----" );

    LookAt lookat;
    lookat.load( q{
        <lookat>
            2.0 0.0 3.0
            0.0 0.0 0.0
            0.1 1.1 0.1
        </lookat>
    }.readDocument.getChildren[0] );

    assert( lookat.P[0].to!string == "2" );
    assert( lookat.P[1].to!string == "0" );
    assert( lookat.P[2].to!string == "3" );
    assert( lookat.I[0].to!string == "0" );
    assert( lookat.I[1].to!string == "0" );
    assert( lookat.I[2].to!string == "0" );
    assert( lookat.UP[0].to!string == "0.1" );
    assert( lookat.UP[1].to!string == "1.1" );
    assert( lookat.UP[2].to!string == "0.1" );

    writeln( "----- LookAt done -----" );
}


struct TransformType(int count, string name)
{
    string sid;

    FloatCount!(count) value;
    alias value this;

    void load( XmlNode xml )
    in
    {
        assert( xml.getName == name );
        assert( xml.getAttributes.length <= 1 );
        assert( xml.getElements.length == 0 );
        assert( xml.getTexts[0].split.length == count );
    }
    out
    {
        assert( value.isValid );
    }
    body
    {
        if( "sid" in xml.getAttributes )
            sid = xml.getAttributes["sid"];

        foreach( i, text; xml.getTexts[0].split )
            value[i] = text.to!float;
    }
}

alias TransformType!( 16, "matrix"    ) Matrix;
alias TransformType!(  4, "rotate"    ) Rotate;
alias TransformType!(  3, "scale"     ) Scale;
alias TransformType!(  7, "skew"      ) Skew;
alias TransformType!(  3, "translate" ) Translate;

unittest
{
    writeln( "----- collada.transform.Matrix unittest -----" );

    Matrix matrix;
    matrix.load( q{
        <matrix>
            1.0 0.0 0.0 2.0
            0.0 1.0 0.0 3.0
            0.0 0.0 1.0 4.0
            0.0 0.0 0.0 1.0
        </matrix>
    }.readDocument.getChildren[0] );

    assert( matrix[].map!( (a){ return a.to!int; } ).array == [ 1, 0, 0, 2, 0, 1, 0, 3, 0, 0, 1, 4, 0, 0, 0, 1 ] );

    writeln( "----- Matrix done -----" );
}

unittest
{
    writeln( "----- collada.transform.Rotate unittest -----" );

    Rotate rotate;
    rotate.load( q{
        <rotate>
            0.0 1.0 0.0 90.0
        </rotate>
    }.readDocument.getChildren[0] );

    assert( rotate[].map!( (a){ return a.to!int; } ).array == [ 0, 1, 0, 90 ] );

    writeln( "----- Rotate done -----" );
}

unittest
{
    writeln( "----- collada.transform.Scale unittest -----" );

    Scale scale;
    scale.load( q{
        <scale>
            2.0 2.0 2.0
        </scale>
    }.readDocument.getChildren[0] );

    assert( scale[].map!( (a){ return a.to!int; } ).array == [ 2, 2, 2 ] );

    writeln( "----- Scale done -----" );
}

unittest
{
    writeln( "----- collada.transform.Skew unittest -----" );

    Skew skew;
    skew.load( q{
        <skew>
            45.0 0.0 1.0 0.0 1.0 0.0 0.0
        </skew>
    }.readDocument.getChildren[0] );

    assert( skew[].map!( (a){ return a.to!int; } ).array == [ 45, 0, 1, 0, 1, 0, 0 ] );

    writeln( "----- Skew done -----" );
}

unittest
{
    writeln( "----- collada.transform.Translate unittest -----" );

    Translate translate;
    translate.load( q{
        <translate>
            10.0 0.0 0.0
        </translate>
    }.readDocument.getChildren[0] );

    assert( translate[].map!( (a){ return a.to!int; } ).array == [ 10, 0, 0 ] );

    writeln( "----- Translate done -----" );
}
