module collada.model;

import std.stdio;
import std.file;
import std.algorithm;
import std.range;
import std.array;
import std.math;
import std.string;
import std.parallelism;
import std.path;
//import std.windows.charset;

import collada.collada;
import collada.base;
import collada.dataflow;
import collada.geometry;
import collada.image;
import collada.effect;
import collada.material;
import collada.controller;
import collada.instance;
import collada.scene;
import collada.transform;
import collada.animation;

import kxml.xml;

import derelict.opengl3.gl;
import derelict.opengl3.gl3;
import derelict.glfw3.glfw3;

import derelict.freeimage.freeimage;

import gl3n.linalg;
import gl3n.interpolate;


vec3 getVertex( WrappedBone* b )
{
    vec4 cv = vec4( 0.0, 0.0, 0.0, 1.0 );
    //vec4 cv = vec4( b.matrix[0][3], b.matrix[1][3], b.matrix[2][3], 1.0 );
    //if( cv.x != 0.0 ) cv.x *= -1;
    //if( cv.y != 0.0 ) cv.y *= -1;
    //if( cv.z != 0.0 ) cv.z *= -1;

    //cv = cv * b.matrix;
    cv = cv * b.pose;

    auto p = b.parent;
    while( p != null )
    {
        cv = cv * p.pose;
        p = p.parent;
    }

    return vec3( cv );
}

void multr( ref float[4] v, ref const mat4 mat )
{
    float v0 = v[0];
    float v1 = v[1];
    float v2 = v[2];
    float v3 = v[3];

    auto m = mat.matrix;
    
    //v[0] = v0*m[0][0] + v1*m[1][0] + v2*m[2][0] + v3*m[3][0];
    //v[1] = v0*m[0][1] + v1*m[1][1] + v2*m[2][1] + v3*m[3][1];
    //v[2] = v0*m[0][2] + v1*m[1][2] + v2*m[2][2] + v3*m[3][2];
    //v[3] = v0*m[0][3] + v1*m[1][3] + v2*m[2][3] + v3*m[3][3];

    v[0] = v0*m[0][0] + v1*m[0][1] + v2*m[0][2] + v3*m[0][3];
    v[1] = v0*m[1][0] + v1*m[1][1] + v2*m[1][2] + v3*m[1][3];
    v[2] = v0*m[2][0] + v1*m[2][1] + v2*m[2][2] + v3*m[2][3];
    v[3] = v0*m[3][0] + v1*m[3][1] + v2*m[3][2] + v3*m[3][3];

}

template isPermitted(T)
{
    enum bool isPermitted = ( is(T==float) || is(T==int) || is(T==bool) || is(T==string) );
}

struct WrappedSource(T) if ( isPermitted!T )
{
    alias T type;
    Source _self;

    string id;
    
    struct InnerArray
    {
        string aid;
        T[] _init;
        
        this(TypeArray!T typeArray)
        {
            aid = typeArray.id;
            _init  = typeArray.dup;
        }
    }
    InnerArray _array;
    
    
    struct BW
    {
        WrappedBone* _bone;
        float _weight;
    }
    struct InnerParam
    {
        T[] _value;
        T[] _writeValue;
        
        T*[][] _triRefs;
        BW[] _bwRefs;

        static if( is( T == float ) )
        {
        float[4] __vertex;
        float[4] __v;
        //vec4 __vertex;
        //vec4 __v;
        void calc()
        {
            __vertex[0] = 0.0;
            __vertex[1] = 0.0;
            __vertex[2] = 0.0;
            __vertex[3] = 0.0;
            //__vertex = vec4( 0.0, 0.0, 0.0, 0.0 );
            
            for( int i = 0; i < _bwRefs.length; ++i )
            {
                __v[0] = _value[0];
                __v[1] = _value[1];
                __v[2] = _value[2];
                __v[3] = 1.0;
                //__v = vec4( _value[0], _value[1], _value[2], 1.0 );

                multr( __v, _bwRefs[i]._bone.matrix );
                multr( __v, _bwRefs[i]._bone.pose );
                //__v = __v * _bwRefs[i]._bone.matrix;
                //__v = __v * _bwRefs[i]._bone.pose;
                
                auto p = _bwRefs[i]._bone.parent;
                while( p != null )
                {
                    multr( __v, p.pose );
                    //__v = __v * p.pose;
                    p = p.parent;
                }

                __v[0] = __v[0] * _bwRefs[i]._weight;
                __v[1] = __v[1] * _bwRefs[i]._weight;
                __v[2] = __v[2] * _bwRefs[i]._weight;
                //__v.x = __v.x * _bwRefs[i]._weight;
                //__v.y = __v.y * _bwRefs[i]._weight;
                //__v.z = __v.z * _bwRefs[i]._weight;
                
                __vertex[0] = __vertex[0] + __v[0];
                __vertex[1] = __vertex[1] + __v[1];
                __vertex[2] = __vertex[2] + __v[2];
                //__vertex.x = __vertex.x + __v.x;
                //__vertex.y = __vertex.y + __v.y;
                //__vertex.z = __vertex.z + __v.z;
                
            }
            
            for( int j = 0; j < _triRefs.length; ++j )
            {
                *(_triRefs[j][0]) = __vertex[0];
                *(_triRefs[j][1]) = __vertex[1];
                *(_triRefs[j][2]) = __vertex[2];
                //*(_triRefs[j][0]) = __vertex.x;
                //*(_triRefs[j][1]) = __vertex.y;
                //*(_triRefs[j][2]) = __vertex.z;
            }
            
        }
        
        }
    }
    InnerParam[] _accessor;
    
    static if( is( T == float ) )
    void calc()
    {
        foreach( ref param; taskPool.parallel( _accessor ) )
        //foreach( ref param; _accessor )
            param.calc();
    }

    this( Source source )
    {
        _self = source;
        id = source.id;
        static if( is( T == string ) )
        {
            assert( source.type == ARRAYTYPE.NAME );
            _array = InnerArray( source.nameArray );
        }
        else static if( is( T == float ) )
        {
            assert( source.type == ARRAYTYPE.FLOAT );
            _array = InnerArray( source.floatArray );
        }
        else static if( is( T == int ) )
        {
            assert( source.type == ARRAYTYPE.INT );
            _array = InnerArray( source.intArray );
        }
        else static if( is( T == bool ) )
        {
            assert( source.type == ARRAYTYPE.BOOL );
            _array = InnerArray( source.boolArray );
        }
        else static if( true )
        {
            throw new Exception("dame!"); 
        }
        
        _accessor.length = _self.common.accessor.count;
        uint stride = _self.common.accessor.stride;
        for( int i = 0; i < _self.common.accessor.count; ++i )
        {
            uint start = i*stride;
            uint end   = start+stride;
            _accessor[i]._value = _array._init[ start..end ];
        }
        
    }
}

auto wrapSource(T)( Source source ) if ( isPermitted!T )
{
    return WrappedSource!T(source);
}

unittest
{
    Source source;
    source.load( q{
        <source id="Position">
          <float_array id="Position-Array" count="9"> 1 2 3 4 5 6 7 8 9 </float_array>
          <technique_common>
            <accessor source="#Position-Array" count="3" stride="3">
              <param type="float" name="X" />
              <param type="float" name="Y" />
              <param type="float" name="Z" />
            </accessor>
          </technique_common>
        </source>
    }.readDocument.getChildren[0] );
    
    auto wSource = source.wrapSource!float;
    assert( wSource._array._init == [ 1, 2, 3, 4, 5, 6, 7, 8, 9 ] );
    assert( wSource._accessor[0]._value == [1,2,3] );
    assert( wSource._accessor[1]._value == [4,5,6] );
    assert( wSource._accessor[2]._value == [7,8,9] );
        
}

struct WrappedInputB(T) if ( is(T==float) || is(T==int) || is(T==bool) )
{
    InputB _self;

    T[] _init;
    T[] _values;
    alias _values this;

    this( InputB input, uint[] indices, WrappedSource!(T)* wsource )
    {
        assert( input.source[1..$] == wsource.id );

        _self = input;
        
        foreach( i; indices )
            _init ~= wsource._accessor[i]._value;
        
        _values = _init.dup;
        
        int count = 0;
        foreach( i; indices )
            wsource._accessor[i]._triRefs ~= _self.semantic == SEMANTICTYPE.TEXCOORD 
                                            ? [ &(_values[count++]), &(_values[count++]) ]
                                            : [ &(_values[count++]), &(_values[count++]), &(_values[count++]) ];

    }

    void init()
    {
        assert( _values.length == _init.length );
        for( int i = 0; i < _init.length; ++i )
            _values[i] = _init[i];
    }
}

auto wrapInputB(T)( InputB input, uint[] indexes, WrappedSource!(T)* wsource ) 
                if ( is(T==float) || is(T==int) || is(T==bool) )
{
    return WrappedInputB!T( input, indexes, wsource );
}

struct WrappedTriangles(T) if ( is(T==float) || is(T==int) )
{
    Triangles _self;

    WrappedInputB!(T)[] _inputs;
    //alias _inputs this;

    this( Triangles triangles, WrappedSource!(T)[] wsources )
    {
        _self = triangles;

        uint[][] indices;
        indices.length = _self.inputs.length;
        
        foreach( i, index; _self.p )
            indices[ i % _self.inputs.length ] ~= index;
        
        foreach( input; _self.inputs )
            _inputs ~= wrapInputB!T( input, indices[input.offset],
                                    &(filter!( (ref wsource) => input.source[1..$] == wsource.id )
                                           ( wsources[] ).array[0] ) );

       writefln( "Trialnges [%s] loaded!", _self.material );
    }

    void load( bool enableTexture = true )
    {
        //glPolygonMode(GL_FRONT_AND_BACK, enableTexture ? GL_FILL : GL_LINE );
        //glPolygonMode(GL_FRONT, enableTexture ? GL_FILL : GL_LINE );
        if( enableTexture )
            glPolygonMode( GL_FRONT, GL_FILL );
        else
            glPolygonMode( GL_FRONT_AND_BACK, GL_LINE );
        
        glEnableClientState( GL_VERTEX_ARRAY );
        glEnableClientState( GL_NORMAL_ARRAY );
        glEnableClientState( GL_TEXTURE_COORD_ARRAY );

        glVertexPointer( 3, GL_FLOAT, 0, _inputs[0]._values.ptr );
        glNormalPointer( GL_FLOAT, 0, _inputs[1]._values.ptr );
        glTexCoordPointer( 2, GL_FLOAT, 0, _inputs[2]._values.ptr );
        
        glDrawArrays( GL_TRIANGLES, 0, 3*_self.count );

        glDisableClientState( GL_TEXTURE_COORD_ARRAY );
        glDisableClientState( GL_NORMAL_ARRAY );
        glDisableClientState( GL_VERTEX_ARRAY );
    }
}

auto wrapTriangles(T)( Triangles triangles, ref WrappedSource!(T)[] wsources )
                    if ( is(T==float) || is(T==int) )
{
    return WrappedTriangles!T( triangles, wsources );
}

unittest
{
    Source source;
    source.load( q{
        <source id="Position">
          <float_array id="Position-Array" count="18"> 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 </float_array>
          <technique_common>
            <accessor source="#Position-Array" count="6" stride="3">
              <param type="float" name="X" />
              <param type="float" name="Y" />
              <param type="float" name="Z" />
            </accessor>
          </technique_common>
        </source>
    }.readDocument.getChildren[0] );
    
    auto wSource = source.wrapSource!float;
    
    WrappedSource!(float)[] wSources;
    wSources ~= wSource;

    Triangles tri;
    tri.load( q{
        <triangles count="3" material="Symbol">
          <input semantic="VERTEX" source="#Position" offset="0" />
          <p> 0 3 4 4 1 0 1 4 5 </p>
        </triangles>
    }.readDocument.getChildren[0] );
    
    auto wTri = tri.wrapTriangles!float( wSources );
/*    
    assert( wTri._inputs[0]._init == [  0, 1, 2,  9,10,11, 12,13,14,
                                       12,13,14,  3, 4, 5,  0, 1, 2,
                                        3, 4, 5, 12,13,14, 15,16,17 ] );
    assert( wTri._inputs[0]._values == [  0, 1, 2,  9,10,11, 12,13,14,
                                         12,13,14,  3, 4, 5,  0, 1, 2,
                                          3, 4, 5, 12,13,14, 15,16,17 ] );
*/    
}

struct WrappedMesh(T) if ( is(T==float) || is(T==int) )
{
    Mesh _self;
    
    WrappedSource!(T)[]    _wsources;
    WrappedSource!(T)*     _vertices;
    WrappedTriangles!(T)[] _wtriangles;
    alias _wtriangles this;
    
    this( Mesh mesh )
    {
        writeln( "Mesh loading..." );
    
        _self = mesh;
        
        auto wss = _self.sources.map!( (a) => a.wrapSource!T ).array;
        foreach( ref ws; wss )
        {
            if( _self.vertices.inputs[0].source[1..$] != ws.id ) continue;
            ws.id = _self.vertices.id;
            _vertices = &ws;
        }
        
        _wsources = wss;
        
        _wtriangles = _self.triangles.map!( (a) => a.wrapTriangles!T( _wsources ) ).array;
        
        writeln( "done!" );
    }
}

auto wrapMesh(T)( Mesh mesh ) if ( is(T==float) || is(T==int) )
{
    return WrappedMesh!T( mesh );
}

struct WrappedGeometry
{
    Geometry _self;
    
    string id;
    WrappedMesh!float mesh;
    
    this( Geometry geometry )
    {
        _self = geometry;
        
        id = geometry.id;
        
        assert( geometry.type == GEOMETRYTYPE.MESH );
        mesh = geometry.mesh.wrapMesh!float;
    }
}

auto wrapGeometry( Geometry geometry )
{
    return WrappedGeometry( geometry );
}

struct WrappedGeometries
{
    LibraryGeometries _self;
    
    WrappedGeometry[] _geometries;
    alias _geometries this;
    
    this( LibraryGeometries libGeometries )
    {
        _self = libGeometries;
        
        _geometries = array( map!( (a) => a.wrapGeometry )( libGeometries.geometries ) );
    }
}

auto wrapGeometries( LibraryGeometries libGeometries )
{
    return WrappedGeometries( libGeometries );
}

struct WrappedImage
{
    Image _self;

    string id;

    int _width;
    int _height;

    GLuint _textureID;
    GLubyte* _texture;

    this( Image image, string path = "" )
    {
        _self = image;

        id = _self.id;

        auto image_path = ( path ~ "/" ~ _self.initFrom ).toStringz;
        FREE_IMAGE_FORMAT image_format = FreeImage_GetFileType( image_path, 0 );
        FIBITMAP* image_original = FreeImage_Load( image_format, image_path );
        FIBITMAP* image_converted = FreeImage_ConvertTo32Bits( image_original );
        FreeImage_Unload( image_original );

        _width  = FreeImage_GetWidth( image_converted );
        _height = FreeImage_GetHeight( image_converted );

        GLubyte[] temp = new GLubyte[4 * _width * _height];
        _texture = temp.ptr;
        char* pixels = cast(char*)FreeImage_GetBits( image_converted );
        FreeImage_Unload( image_converted );

        //色情報の入れ替え。外すと色反転？
        for( int i = 0; i < _width * _height; i++ ){
            _texture[i*4+0]= pixels[i*4+2];
            _texture[i*4+1]= pixels[i*4+1];
            _texture[i*4+2]= pixels[i*4+0];
            _texture[i*4+3]= pixels[i*4+3];
        }

        //テクスチャIDの初期化。setTextureの中に移動すると Effectの数だけ ID作られてしまうのでここから動かさない事。
        glGenTextures( 1, &_textureID );

        writefln("Image [%s] is loaded! width = %d, height = %d", _self.initFrom, _width, _height );
    }

    void release()
    {
        writefln( "Image [%s](ID : %d) release.", _self.initFrom, _textureID );
        glDeleteTextures( 1, &_textureID );
    }

    void setTexture( int format_type )
    {
        //初期化中に WrappedEffect の中で一度だけ呼び出される。
        glBindTexture( GL_TEXTURE_2D, _textureID );

        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
        glTexImage2D( GL_TEXTURE_2D, 0, GL_RGBA, _width, _height, 0, GL_RGBA, GL_UNSIGNED_BYTE, cast(GLvoid*)_texture );

        writefln("Image [%s] is binded texture ID at %d", _self.initFrom, _textureID );
    }

    void bind()
    {
        //モデルが描画される度に、貼付けるテクスチャの交換を行う。
        glBindTexture( GL_TEXTURE_2D, _textureID );
    }
}

auto wrapImage( Image image, string path = "" )
{
    return WrappedImage( image, path );
}

struct WrappedImages
{
    LibraryImages _self;
    WrappedImage[] _images;
    alias _images this;
    
    this( LibraryImages libImages, string path = "" )
    {
        writeln("Images loading...");
        
        _self = libImages;
        
        _images = array( map!( (a) => a.wrapImage( path ) )( libImages.images ) );
        
        writeln("done!");
    }
}

auto wrapImages( LibraryImages libImages, string path = "" )
{
    return WrappedImages( libImages, path );
}

struct WrappedEffect
{
    Effect _self;

    string id;

    float[4] _ambient;
    float[4] _specular;
    float    _shininess;
    //diffuse type
    COLORTEXTURETYPE type;
    
    //type == COLOR
    float[4] _color;
    
    //type == TEXTURE
    //string texcoord    
    int _minfilter;
    int _magfilter;
    //source    
    int _format;
    WrappedImage* _initFrom;

    this( Effect effect, WrappedImages* wimages )
    {
        
        _self = effect;
        
        id = effect.id;
        
        assert( _self.profiles[0].type == PROFILETYPE.COMMON );
        assert( _self.profiles[0].common.technique.type == SHADERELEMENTTYPE.PHONG );
        
        Phong phong = _self.profiles[0].common.technique.phong;        
        _ambient   = phong.ambient.color;
        _specular  = phong.specular.color;
        _shininess = phong.shininess.float_[0];
        
        type = phong.diffuse.type;
        
        if( type == COLORTEXTURETYPE.TEXTURE )
        {
            //assert( phong.diffuse.type == COLORTEXTURETYPE.TEXTURE );
            
            NewParamCOMMON sampler = array( filter!( (a) => a.sid == phong.diffuse.texture.texture )( _self.profiles[0].common.newparams ) )[0];
            
            assert( sampler.type == NEWPARAMTYPE.SAMPLER2D );
            assert( sampler.sampler2d.minfilter == "LINEAR_MIPMAP_LINEAR" );
            _minfilter = GL_LINEAR_MIPMAP_LINEAR;
            assert( sampler.sampler2d.magfilter == "LINEAR" );
            _magfilter = GL_LINEAR;
            
            NewParamCOMMON surface = array( filter!( (a) => a.sid == sampler.sampler2d.source )( _self.profiles[0].common.newparams ) )[0];
            
            assert( surface.type == NEWPARAMTYPE.SURFACE );
            assert( surface.surface.type == SURFACETYPE.TWOD );
            assert( surface.surface.format == "A8R8G8B8" );
            _format = GL_RGBA8;
            
            _initFrom = &( array( filter!( (ref a) => a.id == surface.surface.initFrom )( (*wimages)[] ) )[0] );
            assert( _initFrom._self.type == IMAGETYPE.INITFROM );

            _initFrom.setTexture( _format );
        }
        else if( type == COLORTEXTURETYPE.COLOR )
        {
            _color = phong.diffuse.color;
        }
        else
        {
            throw new Exception("Unmatched type in WrappedEffect.");
        }
        writefln( "Effect [%s] is loaded!", _self.id );
    }

    void load( bool enableTexture )
    {
        if( enableTexture )
        {
            if( type == COLORTEXTURETYPE.TEXTURE )
                _initFrom.bind;
            else if( type == COLORTEXTURETYPE.COLOR )
                glMaterialfv( GL_FRONT, GL_DIFFUSE, _color.ptr );
                
            glMaterialfv( GL_FRONT, GL_AMBIENT,  _ambient.ptr );
            glMaterialfv( GL_FRONT, GL_SPECULAR, _specular.ptr );
            glMaterialf( GL_FRONT, GL_SHININESS, _shininess );
        }
        else
        {
            static float[4] defAmb = [ 0.2, 0.2, 0.2, 1.0 ];
            static float[4] defSpc = [ 0.0, 0.0, 0.0, 1.0 ];
            static float    defShn = 0.0;
        
            glMaterialfv( GL_FRONT, GL_AMBIENT,  defAmb.ptr );
            glMaterialfv( GL_FRONT, GL_SPECULAR, defSpc.ptr );
            glMaterialf( GL_FRONT, GL_SHININESS, defShn );
        }
    }

}

auto wrapEffect( Effect effect, WrappedImages* wimages )
{
    return WrappedEffect( effect, wimages );
}

struct WrappedEffects
{
    LibraryEffects _self;
    WrappedEffect[] _effects;
    alias _effects this;
    
    this( LibraryEffects libEffects, WrappedImages* wimages )
    {
        writeln( "Effects loading..." );
    
        _self = libEffects;
        
        _effects = array( map!( (a) => a.wrapEffect( wimages ) )( libEffects.effects ) );
        
        writeln( "done!" );
    }
}

auto wrapEffects( LibraryEffects libEffects, WrappedImages* wimages )
{
    return WrappedEffects( libEffects, wimages );
}

struct WrappedMaterial
{
    Material _self;
    string id;
    WrappedEffect* _instance;
    alias _instance this;
    
    this( Material material, WrappedEffects* weffects )
    {
        _self = material;
        
        id        = material.id;
        _instance = &( array( filter!( (ref a) => _self.effect.url[1..$] == a.id )( (*weffects)[] ) )[0] );
        
        writefln( "Material [%s] loaded!", _self.id );
    }
    
}

auto wrapMaterial( Material material, WrappedEffects* weffects )
{
    return WrappedMaterial( material, weffects );
}

struct WrappedMaterials
{
    LibraryMaterials _self;
    WrappedMaterial[] _materials;
    alias _materials this;
    
    this( LibraryMaterials libMaterials, WrappedEffects* weffects )
    {
        writeln( "Materials loading..." );
    
        _self = libMaterials;
        
        _materials = array( map!( (a) => a.wrapMaterial( weffects ) )( libMaterials.materials ) );
        
        writeln( "done!" );
    }
}

auto wrapMaterials( LibraryMaterials libMaterials, WrappedEffects* weffects )
{
    return WrappedMaterials( libMaterials, weffects );
}

struct WrappedVertexWeights
{
    int[2][][] _values;
    alias _values this;

    this( VertexWeights vw )
    {
        assert( vw.count == vw.vcount.length );
        
        int[][] bw;
        bw.length = 1;
        bw = reduce!( (a, b){ if(a[$-1].length < 2) a[$-1] ~= b; else a ~= [b]; return a; } )( bw, vw.v );
        
        foreach( count; vw.vcount )
        {
            int[2][] v;
            for( int i = 0; i < count; ++i )
            {
                v ~= [ bw.front[0], bw.front[1] ];
                bw.popFront;
            }
            _values ~= v;
        }
        
        assert( vw.count == _values.length );
    }
}

auto wrapVertexWeights( VertexWeights vw )
{
    return WrappedVertexWeights( vw );
}

unittest
{
    Source source;
    source.load( q{
        <source id="Position">
          <float_array id="Position-Array" count="27"> 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 </float_array>
          <technique_common>
            <accessor source="#Position-Array" count="9" stride="3">
              <param type="float" name="X" />
              <param type="float" name="Y" />
              <param type="float" name="Z" />
            </accessor>
          </technique_common>
        </source>
    }.readDocument.getChildren[0] );
    
    auto wSource = source.wrapSource!float;
    assert( wSource._accessor.length == 9 );
    assert( wSource._accessor[0]._value.length == 3 );
    assert( wSource._accessor[0]._value == [0,1,2] );
    assert( wSource._accessor[8]._value.length == 3 );
    assert( wSource._accessor[8]._value == [24,25,26] );
    
    Triangles tri;
    tri.load( q{
        <triangles count="3" material="Symbol">
          <input semantic="VERTEX" source="#Position" offset="0" />
          <p> 5 8 3 1 7 4 0 6 2 </p>
        </triangles>
    }.readDocument.getChildren[0] );
    
    WrappedSource!(float)[] wSources;
    wSources ~= wSource;
    
    auto wTri = tri.wrapTriangles!float( wSources );
    assert( wTri._inputs.length == 1 );
//    assert( wTri._inputs[0]._init == [15,16,17, 24,25,26,  9,10,11,
//                                       3, 4, 5, 21,22,23, 12,13,14,
//                                       0, 1, 2, 18,19,20,  6, 7, 8 ] );
    
    Source names;
    names.load( q{
        <source id="Joint">
          <Name_array id="Joint-Array" count="5"> Bone0 Bone1 Bone2 Bone3 Bone4 </Name_array>
          <technique_common>
            <accessor source="#Joint-Array" count="5" stride="1">
              <param name="JOINT" type="Name" />
            </accessor>
          </technique_common>
        </source>
    }.readDocument.getChildren[0] );
    
    auto wNames = names.wrapSource!string;
    assert( wNames._accessor.length == 5 );
    assert( wNames._accessor[0]._value == [ "Bone0" ] );
    assert( wNames._accessor[4]._value == [ "Bone4" ] );
    
    Source weights;
    weights.load( q{
        <source id="Weight">
          <float_array id="Weight-Array" count="2"> 1.000000 0.500000 </float_array>
          <technique_common>
            <accessor source="#Weight-Array" count="2" stride="1">
              <param name="WEIGHT" type="float" />
            </accessor>
          </technique_common>
        </source>
    }.readDocument.getChildren[0] );
    
    auto wWeights = weights.wrapSource!float;
    assert( wWeights._accessor.length == 2 );
    assert( wWeights._accessor[0]._value == [ 1.000000 ] );
    assert( wWeights._accessor[1]._value == [ 0.500000 ] );

    VertexWeights vws;
    vws.load( q{
        <vertex_weights count="9">
          <input semantic="JOINT" source="#Joint" offset="0" />
          <input semantic="WEIGHT" source="#Weight" offset="1" />
          <vcount>1 1 1 1 1 1 1 1 2</vcount>
          <v>0 0 1 0 2 0 3 0 4 0 0 0 1 0 2 0 3 1 4 1</v>
        </vertex_weights>
    }.readDocument.getChildren[0] );
    
    auto wVWs = vws.wrapVertexWeights;
    assert( wVWs._values.length == 9 );
    assert( wVWs._values[0].length == 1 );
    assert( wVWs._values[0][0] == [0,0] );
    assert( wVWs._values[8].length == 2 );
    assert( wVWs._values[8][0] == [3,1] );
    assert( wVWs._values[8][1] == [4,1] );
    
}

struct WrappedSkin
{
    struct VW
    {
        int   index;
        float weight;
    }
    struct Result
    {
        float[] matrix;
        VW[] vws;
    }
    
    Skin _self;
    
    string source;
    Result[string] result;

    this( Skin skin, WrappedGeometry* geometry )
    {
        assert( skin.source[1..$] == (*geometry).id );
        
        _self = skin;
        
        source = skin.source;

        //Name Source
        auto ns = filter!( (a) => a.type == ARRAYTYPE.NAME )( skin.sources[] ).array;
        assert( ns.length == 1 );
        
        //Name WrappedSource
        auto nws = WrappedSource!string( ns[0] );
        //Float WrappedSources
        auto fwss = map!( (a) => wrapSource!float(a) )( filter!( (b) => b.type != ARRAYTYPE.NAME )( skin.sources[] ) );
        
        //joints
        //Joint Joints Input
        auto jji = array( filter!( (a) => a.semantic == SEMANTICTYPE.JOINT )( skin.joints.inputs[] ) )[0];
        assert( jji.source[1..$] == nws.id );
        //Inverse Input
        auto ii = array( filter!( (a) => a.semantic == SEMANTICTYPE.INV_BIND_MATRIX )( skin.joints.inputs[] ) )[0];
        //Inverse WrappedSource
        auto iws = array( filter!( (a) => a.id == ii.source[1..$] )( fwss ) )[0];
        
        foreach( a, b; lockstep( nws._accessor, iws._accessor ) )
            result[ a._value[0] ] = Result( b._value, null );
        
        //vertex_weights
        //Joint Vertex Input
        auto jvi = array( filter!( (a) => a.semantic == SEMANTICTYPE.JOINT )( skin.vertex_weights.inputs[] ) )[0];
        assert( jvi.source[1..$] == nws.id );
        //Weight Input
        auto wi = array( filter!( (a) => a.semantic == SEMANTICTYPE.WEIGHT )( skin.vertex_weights.inputs[] ) )[0];
        //Weight WrappedSource
        auto wws = array( filter!( (a) => a.id == wi.source[1..$] )( fwss ) )[0];
        
        //Wrapped Vertex_Weight
        auto wvw = skin.vertex_weights.wrapVertexWeights;
        assert( wvw[].length == geometry.mesh._vertices._accessor.length );        
        
        int idx = 0;
        foreach( vw, ref param; lockstep( wvw[], geometry.mesh._vertices._accessor ) )
        {
            foreach( v; vw )
                result[ nws._accessor[v[0]]._value[0] ].vws ~= VW( idx, wws._accessor[v[1]]._value[0] );
            
            ++idx;
        }
        
        foreach( key, value; result )
            writefln( "Skin.Result[%s].vws.length = %d", key, value.vws.length );

    }
}

auto wrapSkin( Skin skin, WrappedGeometry* geometry )
{
    return WrappedSkin( skin, geometry );
}

struct WrappedController
{
    Controller _self;
    
    string id;
    WrappedSkin skin;
    
    this( Controller controller, WrappedGeometry* geometry )
    {
        _self = controller;
        
        id = controller.id;
        skin = controller.skin.wrapSkin( geometry );
    }
}

auto wrapController( Controller controller, WrappedGeometry* geometry )
{
    return WrappedController( controller, geometry );
}

struct WrappedControllers
{
    LibraryControllers _self;
    
    WrappedController[] _controllers;
    alias _controllers this;
    
    this( LibraryControllers controllers, WrappedGeometry* geometry )
    {
        _self = controllers;
        
        _controllers = array( map!( (a) => a.wrapController( geometry ) )( _self.controllers ) );
    }
}

auto wrapControllers( LibraryControllers controllers, WrappedGeometry* geometry )
{
    return WrappedControllers( controllers, geometry );
}

struct WrappedAnimation
{
    struct KeyFrame
    {
        float time;
        float[16] pose;
        string interpolation;
    }

    Animation _self;
    
    KeyFrame[] _values;
    
    string target;

    float[16] transpose( float[] matrix )
    {
        assert( matrix.length == 16 );
        return [ matrix[0], matrix[4], matrix[8],  matrix[12],
                 matrix[1], matrix[5], matrix[9],  matrix[13],
                 matrix[2], matrix[6], matrix[10], matrix[14],
                 matrix[3], matrix[7], matrix[11], matrix[15] ];
    }

    
    this( Animation animation )
    {
        _self = animation;
        
        target = _self.channels[0].target.split("/")[0];
        
        auto tws = _self.sources.filter!( (a) => a.id.split("-")[2] == "Time" ).array[0].wrapSource!(float);
        auto pws = _self.sources.filter!( (a) => a.id.split("-")[2] == "Pose" ).array[0].wrapSource!(float);
        auto iws = _self.sources.filter!( (a) => a.id.split("-")[2] == "Interpolation" ).array[0].wrapSource!(string);
        
        assert( tws._accessor.length == pws._accessor.length );
        assert( pws._accessor.length == iws._accessor.length );
        assert( iws._accessor.length == tws._accessor.length );
        
        foreach( time, pose, interpolation; lockstep( tws._accessor, pws._accessor, iws._accessor ) )
        {
            KeyFrame keyframe;
            keyframe.time = time._value[0];
            // OpenGL
            //keyframe.pose = transpose( pose._value );
            keyframe.pose = pose._value;
            keyframe.interpolation = interpolation._value[0];

            _values ~= keyframe;
        }
        
        writefln( "Animation [%s] loaded!", _self.id );
    }

}

auto wrapAnimation( Animation animation )
{
    return WrappedAnimation( animation );
}

struct WrappedAnimations
{
    LibraryAnimations _self;
    
    WrappedAnimation[] animations;
    
    this( LibraryAnimations libAnimations )
    {
        writeln( "Animations loading..." );
        
        _self = libAnimations;
        
        animations = array( map!( (a) => a.wrapAnimation() )( _self.animations ) );
        
        writeln( "done!" );
    }

}

auto wrapAnimations( LibraryAnimations libAnimations )
{
    return WrappedAnimations( libAnimations );
}

enum Step { NEXT, PREV };

struct WrappedBone
{
    WrappedBone*  parent;
    Node          _self; 
    WrappedBone[] children;
    
    string id;
    mat4 matrix = mat4.identity;
    mat4 pose   = mat4.identity;
    
    //アニメーション計算用
    WrappedAnimation.KeyFrame[] keyframes;
    bool hasAnimation = false;
    uint startIndex = -1;
    uint endIndex = -1;
    
    //IK計算用
    bool isIK = false;
    WrappedBone* IKTarget;
    int IKChain;
    int IKIterations;
    float IKWeight;

    //さかのぼれる限りの親と自分の poseを乗算した結果
    //これを持っておけば子の pose計算時に毎回親をさかのぼる必要が無くなり
    //(親の pp x 自分の pose だけで済む) 計算量が減らせる。
    //mat4 pp = mat4.identity;

    mat4 toMat4( const float[] m )
    {
        assert( m.length == 16 );
        return mat4( m[0], m[1], m[2], m[3], m[4], m[5], m[6], m[7], m[8], m[9], m[10], m[11], m[12], m[13], m[14], m[15] );
    }
    
    //constructor内で childに親情報として &thisを渡そうと思ったが
    //アドレスが何処かで置き換えられるらしく正常な参照先を渡せないので
    //その処理か下記の connectKeyFramesで合わせて行う。
    this( Node node )
    {
        _self = node;
        
        id = node.id;

        assert( node.matrixes.length == 1 );
        pose = toMat4( node.matrixes[0] );

        // OpenGL
        //pose.transpose;

        writefln( "Bone [%s] loaded!", _self.id );
        
        foreach( child; node.nodes )
            children ~= child.wrapBone;
    }

    //選択されたアニメーションをモデルに読み込む
    void connectKeyFrames( WrappedAnimations* animations )
    {
        foreach( ref animation; animations.animations )
        {
            if( animation.target != _self.id ) continue;
            keyframes = animation._values;
            hasAnimation = true;
            assert( keyframes.length >= 2 );
            startIndex = 0;
            endIndex = 1;
            
            writefln( "Bone [%s] keyframes connected!", _self.id );
            break;
        }
        
        foreach( ref child; children )
        {
            child.parent = &this;
            child.connectKeyFrames( animations );
        }
    }
    
    void connectVertexWeights( WrappedSource!(float)* source, WrappedController* controller )
    {
        if( _self.id in controller.skin.result )
        {
            auto result = controller.skin.result[ _self.id ];
            matrix = toMat4( result.matrix );
            
            // OpenGL
            //matrix.transpose;

            foreach( vw; result.vws )
                source._accessor[ vw.index ]._bwRefs ~= WrappedSource!float.BW( &this, vw.weight );
            
            writefln( "Bone [%s] vertex weights connected!", _self.id );
        }
        else
        {
            writefln( "%s's skin not found.", _self.id );
        }
        
        foreach( ref child; children )
            child.connectVertexWeights( source, controller );
    }

    void calcPose( Step step, ref const float time )
    {
        
        if( hasAnimation )
        {

            final switch( step )
            {
                case Step.NEXT :
                {
                    while( time > keyframes[ endIndex ].time )
                    {
                        if( endIndex < keyframes.length -1 )
                        {
                            startIndex++;
                            endIndex++;
                        }
                        else break;
                    }
                } break;

                case Step.PREV :
                {
                    while( keyframes[ startIndex ].time > time )
                    {
                        if( startIndex > 0 )
                        {
                            startIndex--;
                            endIndex--;
                        }
                        else break;
                    }
                } break;
            }

            auto s = &(keyframes[startIndex]);
            auto e = &(keyframes[endIndex]);
            
            if( s.pose != e.pose )
            {
                float t = time - s.time;
                t /= e.time - s.time;

                mat4 sm = toMat4( s.pose );
                mat4 em = toMat4( e.pose );
                
                quat sq = quat.from_matrix( sm.rotation );
                //if( sq.w < 0.0 ) sq.invert;
                quat eq = quat.from_matrix( em.rotation );
                //if( eq.w < 0.0 ) eq.invert;

                if( eq.x < 0.0 ) {
                    if( sq.x == 1 ) sq.x = -1;
                } else {
                    if( sq.x == -1 ) sq.x = 1;
                }
                if( eq.y < 0.0 ) {
                    if( sq.y == 1 ) sq.y = -1;
                } else {
                    if( sq.y == -1 ) sq.y = 1;
                }
                if( eq.z < 0.0 ) {
                    if( sq.z == 1 ) sq.z = -1;
                } else {
                    if( sq.z == -1 ) sq.z = 1;
                }

                pose.rotation( slerp( sq, eq, t ).to_matrix!(3,3) );

                mat4 st = sm.translation;
                mat4 et = em.translation;

                mat4 ct = mat4.translation( lerp( st[0][3], et[0][3], t ),
                                            lerp( st[1][3], et[1][3], t ),
                                            lerp( st[2][3], et[2][3], t ) );
                pose.translation( ct );

/+                
                if( ( id == "左足IK" ) || ( id == "右足IK" ) )
                {
                    writeln( "----- id : ", id, " -----" );
                    writeln( "t : ", t );
                    writeln( "s.pose : ", s.pose );
                    writeln( "e.pose : ", e.pose );
                    writeln( "sq : ", sq );
                    writeln( "eq : ", eq );
                    writeln( "slerp : ", Slerp( sq, eq, t ) );
                    writeln( "pose : ", pose );
                    writeln( "" );
                }
+/
                
            }
            else
                pose = toMat4( s.pose );
                
        }
        
        //if( parent == null )
        //    pp = pose;
        //else
        //    pp = pose * parent.pp;
        
        //foreach( ref child; taskPool.parallel( children ) )
        foreach( ref child; children )
            child.calcPose( step, time );
            
    }

    void calcIK()
    {

        if( isIK )
        {
            for( int i = 0; i < IKIterations; ++i )
            {
                auto effector = &(IKTarget.children[0]);
                auto joint = effector.parent;
                
                for( int j = 0; j < IKChain; ++j )
                {

                    vec3 before = getVertex( effector );
                    before -= getVertex( joint );
                    
                    vec3 after = getVertex( &this );
                    after -= getVertex( joint );

                    //mat3 inv = joint.pose.rotation;
                    //inv.invert;
                    
                    //before = before * inv;
                    //after  = after * inv;
                    
                    before.normalize;
                    after.normalize;

                    auto angle = acos( dot( before, after ) );
                    if( angle > IKWeight )
                        angle = IKWeight;
                    else if ( angle < -IKWeight )
                        angle = -IKWeight;

                    if( angle > 1.0e-5 )
                    {
                        auto axis = cross( before, after );
                        axis.normalize;

                        //quat q = quat.axis_rotation( angle, axis );
                        //mat3 qm = q.to_matrix!(3,3);
                        //mat3 jm = joint.pose.rotation;

                        //joint.pose.rotation( jm * qm );

                        quat q1 = quat.axis_rotation( angle, axis );
                        quat q2 = quat.from_matrix( joint.pose.rotation );
/+
                        if( ( joint.id == "左ひざ" ) || ( joint.id == "右ひざ" ) )
                        {
                            if( i == 0 )
                            {
                                if( angle < 0.0f ) angle = -angle;
                                axis = vec3( 1.0, 0.0, 0.0 );
                                q1 = quat.axis_rotation( angle, axis );
                            }
                            else
                            {
                                real[3] e1 = [ q1.yaw, q1.pitch, q1.roll ];
                                real[3] e2 = [ q2.yaw, q2.pitch, q2.roll ];

                                if( e1[2] + e2[2] > PI )
                                    e1[2] = PI - e2[2];

                                if( e1[2] + e2[2] < 0.002 )
                                    e1[2] = 0.002 - e2[2];

                                if( e1[2] > IKWeight )
                                    e1[2] = IKWeight;
                                else if ( e1[2] < -IKWeight )
                                    e1[2] = -IKWeight;

                                q1 = quat.euler_rotation( 0.0, 0.0, e1[2] );

                            }
                        }
+/
                        joint.pose.rotation( (q2 * q1).to_matrix!(3,3) );

                    }
                    
/+
                    if( (joint.id == "左ひざ") || (joint.id == "右ひざ") )
                    {
                        if( i == 0 )
                        {
                            if( radian < 0.0f )
                                radian = -radian;
                            axis = [ 1.0, 0.0, 0.0 ];
                            q1 = makeQuaternion( axis, radian );
                        }
                        else
                        {
                            Vector3 euler1 = q1.toEuler;
                            Vector3 euler2 = joint.pose.getTransform.toQuaternion.toEuler;
                            
                            if( euler1[2] + euler2[2] > PI )
                                euler1[2] = PI - euler2[2];
                                
                            if( euler1[2] + euler2[2] < 0.002f )
                                euler1[2] = 0.002f - euler2[2];
                                
                            if( euler1[2] > IKWeight )
                                euler1[2] = IKWeight;
                            else if( euler1[2] < -IKWeight )
                                euler1[2] = -IKWeight;
                                                
                            q1 = makeQuaternion( 0.0, 0.0, euler1[2] );
                        
                        }
                    }
+/
                    joint = joint.parent;

                }//for IKChain
            }//for IKIterations
        }//if( isIK )

        foreach( ref child; children )
            child.calcIK();
    }//calcIK

}

auto wrapBone( Node node )
{
    return WrappedBone( node );
}

struct WrappedNode
{
    struct Instance
    {
        WrappedTriangles!(float)* triangles;
        WrappedMaterial*          material;
        
        void load( bool enableTexture )
        {
            material.load( enableTexture );
            triangles.load( enableTexture );
        }
    }

    Node _self;

    string id;
    Translate[] translates;
    Rotate[]    rotates;
    Scale[]     scales;

    Instance[] instances;

    this( Node node, WrappedGeometry* geometry, WrappedMaterials* materials )
    {
        writeln( "Nodes loading..." );
        
        _self = node;
        
        translates = _self.translates;
        rotates    = _self.rotates;
        scales     = _self.scales;

        foreach( ins; node.instanceControllers[0].bindMaterial.common.instanceMaterials )
        {
            instances ~= Instance( &(array( filter!( (ref a) => a._self.material == ins.symbol )( (*geometry).mesh[]) )[0] ),
                                   &(array( filter!( (ref b) => b.id == ins.target[1..$] )( (*materials)[]) )[0] ) );
            writefln( "Instance [%s] loaded!", ins.symbol );
        }
        
        writeln( "done!" );
    }

    void load( bool enableTexture )
    {
        foreach( ref translate; translates )
            glTranslatef( translate[0], translate[1], translate[2] );
            
        foreach( ref rotate; rotates )
            glRotatef( rotate[3], rotate[0], rotate[1], rotate[2] );
            
        foreach( ref scale; scales )
            glScalef( scale[0], scale[1], scale[2] );
            
        foreach( ref instance; instances )
            instance.load( enableTexture );
    }
}

auto wrapNode( Node node, WrappedGeometry* geometry, WrappedMaterials* materials )
{
    return WrappedNode( node, geometry, materials );
}

struct IKConfig
{
    XmlNode self;

    this( string filePath )
    {
        assert( exists( filePath ) );
        self = readText( filePath ).readDocument.getChildren[1];
    }
    
    void set( WrappedBone* bone )
    {
        WrappedBone* findBone( WrappedBone* _bone, string name )
        {
            if( name == _bone.id )
                return _bone;
            
            foreach( ref child; _bone.children )
            {
                WrappedBone* temp = findBone( &child, name );
                if( temp != null ) return temp;
            }
            
            return null;
        }
    
        foreach( ik; self.getElements )
        {
            auto attrs = ik.getAttributes;

            assert( "target" in attrs );
            auto ikEffect = findBone( bone, attrs["target"] );
            assert( ikEffect != null );
            ikEffect.isIK = true;
            
            assert( "name" in attrs );
            ikEffect.IKTarget = findBone( bone, attrs["name"] );
            assert( ikEffect.IKTarget != null );

            assert( "chain" in attrs );
            ikEffect.IKChain = attrs["chain"].to!int;

            assert( "iteration" in attrs );
            ikEffect.IKIterations = attrs["iteration"].to!int;

            assert( "weight" in attrs );
            ikEffect.IKWeight = attrs["weight"].to!float * PI;
        }
    }
}

struct ColladaModel
{
    Collada _self;

    WrappedImages images;
    WrappedEffects effects;
    WrappedMaterials materials;
    WrappedGeometries geometries;
    WrappedControllers controllers;
    WrappedAnimations[] animations;

    WrappedBone bone;
    WrappedNode node;

    bool enableTexture = true;
    bool enableBone    = true;

    float startTime = 0.0;
    float currentTime = 0.0;
    bool isMoving = false;

    this( string modelPath )
    {
        _self = new Collada( modelPath );

        images = _self.libImages.wrapImages( dirName( modelPath ) );
        effects = _self.libEffects.wrapEffects( &images );
        materials = _self.libMaterials.wrapMaterials( &effects );
        geometries = _self.libGeometries.wrapGeometries;
        controllers = _self.libControllers.wrapControllers( &(geometries[0]) );
        animations ~= _self.libAnimations.wrapAnimations;
        
        bone = _self.libVisualScenes.visualScenes[0].nodes[0].wrapBone();
        bone.connectVertexWeights( geometries[0].mesh._vertices, &(controllers[0]) );
        
        node = _self.libVisualScenes.visualScenes[0].nodes[1].wrapNode( &(geometries[0]), &materials );

        string conf = stripExtension( modelPath ) ~ "_ik.config";
        assert( exists( conf ) );
        auto ik = IKConfig( conf );
        ik.set( &bone );

        writeln( "model done" );

    }

    ~this()
    {
        foreach( image; images[] )
            image.release;
    }

    // IKを読み込むタイミングで modelの<部位>ＩＫ(全角英字) が IK (半角文字)に変換されてしまっている為
    //マッチする boneが無い状態になっていてモーション読み込みが失敗している様子。
    void selectAnimation( uint number )
    {
        writeln( "selected Animation" );
        assert( number < animations.length );
        
        bone.connectKeyFrames( &( animations[number] ) );
        
        isMoving = true;
        startTime = glfwGetTime();
        currentTime = 0.0;
    }

    float __interval = 0.0;
    void suspend()
    {
        if( !isMoving ) return;

        isMoving = false;
        __interval = glfwGetTime();
    }
    
    void resume()
    {
        if( isMoving ) return;
        if( __interval == 0.0 ) return;

        __interval = glfwGetTime() - __interval;

        isMoving = true;
        startTime += __interval;
        __interval = 0.0;
    }
    
    void moveStep( Step step, float time )
    {
        if( isMoving ) return;

        final switch( step )
        {
            case Step.NEXT :
            {
                currentTime += time;
                bone.calcPose( Step.NEXT, currentTime );
                bone.calcIK();
            } break;

            case Step.PREV : 
            { 
                currentTime -= time;
                bone.calcPose( Step.PREV, currentTime );
                bone.calcIK();
            } break;
        }

        geometries[0].mesh._vertices.calc();
    }

    void move()
    {
        if( !isMoving ) return;
        
        currentTime = glfwGetTime() - startTime;
        bone.calcPose( Step.NEXT, currentTime );
        bone.calcIK();
        geometries[0].mesh._vertices.calc();
        
    }

    void draw()
    {
        
        if( enableTexture )
        {
            glEnable( GL_LINE_SMOOTH );
            glEnable( GL_TEXTURE_2D );
            glEnable( GL_BLEND );
            glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        
            glPushMatrix();
                node.load( true );
            glPopMatrix();
            
            glDisable( GL_BLEND );
            glDisable( GL_TEXTURE_2D );
            glDisable( GL_LINE_SMOOTH );
        }
        else
        {            
            glPushMatrix();
                node.load( false );
            glPopMatrix();
        }

        if( enableBone ) drawBone();
        
    }
    
    void drawBone()
    {
        void makeBone( WrappedBone current, vec3 pv, int depth = 0 )
        {
            
            vec3 cv = getVertex( &current );
            
            if( ( current.id == "右足ＩＫ" ) || ( current.id == "右つま先ＩＫ") )
                glColor3f( 0, 1, 0 );

            if( ( current.id == "右足首先" ) || ( current.id == "右足首" ) ||
                ( current.id == "右ひざ" ) || ( current.id == "右足" ) )
                glColor3f( 0, 1, 1 );

            if( ( current.id == "左足ＩＫ" ) || ( current.id == "左つま先ＩＫ") )
                glColor3f( 1, 0, 0 );
            
            if( ( current.id == "左足首先" ) || ( current.id == "左足首" ) ||
                ( current.id == "左ひざ" ) || ( current.id == "左足" ) )
                glColor3f( 1, 0, 1 );

            glBegin( GL_POINTS );
            glVertex3f( cv.x, cv.y, cv.z );
            glEnd();
            
            glBegin( GL_LINES );
            glVertex3f( pv.x, pv.y, pv.z );
            glVertex3f( cv.x, cv.y, cv.z );
            glEnd();

            glColor3f( 0.8, 0.8, 0.8 );
/+
            if( ( current.id == "左ひざ" ) || ( current.id == "左足" ) || 
                ( current.id == "右ひざ" ) || ( current.id == "右足" ) )
            {
                float[4] cv_;
                cv_[0] = current.matrix[12] == 0.0 ? 0.0 : -current.matrix[12];
                cv_[1] = current.matrix[13] == 0.0 ? 0.0 : -current.matrix[13];
                cv_[2] = current.matrix[14] == 0.0 ? 0.0 : -current.matrix[14];
                cv_[3] = 1.0;
                
                float[4] cvx = cv_.dup;
                cvx[0] += 1.0;
                float[4] cvy = cv_.dup;
                cvy[1] += 1.0;
                float[4] cvz = cv_.dup;
                cvz[2] += 1.0;
                
                multr( cv_, current.matrix );
                multr( cvx, current.matrix );
                multr( cvy, current.matrix );
                multr( cvz, current.matrix );
                
                multr( cv_, current.pose );
                multr( cvx, current.pose );
                multr( cvy, current.pose );
                multr( cvz, current.pose );
                
                auto _p = current.parent;
                while( _p != null )
                {
                    multr( cv_, _p.pose );
                    multr( cvx, _p.pose );
                    multr( cvy, _p.pose );
                    multr( cvz, _p.pose );
                    _p = _p.parent;
                }
            
                glBegin( GL_POINTS );
                glColor3f( 1, 0, 0 );
                glVertex3f( cvx[0], cvx[1], cvx[2] );
                glColor3f( 0, 1, 0 );
                glVertex3f( cvy[0], cvy[1], cvy[2] );
                glColor3f( 0, 0, 1 );
                glVertex3f( cvz[0], cvz[1], cvz[2] );
                glEnd();
                
                glBegin( GL_LINES );
                glColor3f( 1, 0, 0 );
                glVertex3f( cv_[0], cv_[1], cv_[2] );
                glVertex3f( cvx[0], cvx[1], cvx[2] );
                glColor3f( 0, 1, 0 );
                glVertex3f( cv_[0], cv_[1], cv_[2] );
                glVertex3f( cvy[0], cvy[1], cvy[2] );
                glColor3f( 0, 0, 1 );
                glVertex3f( cv_[0], cv_[1], cv_[2] );
                glVertex3f( cvz[0], cvz[1], cvz[2] );
                glEnd();    
                
                glColor3f( 0.8, 0.8, 0.8 );
            }
+/
            if( current.children.empty ) return;

            foreach( child; current.children )
                makeBone( child, cv, depth+1 );
        }
        
        glDisable(GL_DEPTH_TEST);
        
        glPushMatrix();
            glEnable(GL_LINE_SMOOTH);
            glLineWidth(2);
            glPointSize(8);
            glColor3f( 0.8, 0.8, 0.8 );        
            makeBone( bone, vec3( 0.0, 0.0, 0.0 ) );
            glColor3f( 1, 1, 1 );        
            glPointSize(1);
            glLineWidth(1);
            glDisable(GL_LINE_SMOOTH);
        glPopMatrix();
        
        glEnable(GL_DEPTH_TEST);
    }
}

string readModelPath()
{
    typeof(return) result;

    string[string] list;

    int num = 0;
    foreach( DirEntry e; dirEntries("./public", SpanMode.shallow).filter!"a.isDir" )
    {
        foreach( name; dirEntries( e.name, "*.dae", SpanMode.shallow ) )
        {
            writefln( "%3d: %s", num, name );
            list[num++.to!string] = name;
        }
    }

    string line;
    while( (line = readln.chop) !is null )
    {
        if( line.empty )
            break;
        else  if( line in list )
        {
            result = list[line];
            break;
        }
        else
            writeln( "please exist number." );
    }

    return result;
}


shared static this()
{
    writeln("collada.model initializing...");

    writeln("Derelict GL load...");
    DerelictGL.load();

    writeln("Derelict GL3 load...");
    DerelictGL3.load();

    writeln("Derelict GLFW3 load...");
    DerelictGLFW3.load();

    writeln("Derelict FreeImage load...");
    DerelictFI.load();
}

shared static ~this()
{
    writeln("collada.model finalizing...");

    writeln("Derelict FreeImage unload...");
    DerelictFI.unload();

    writeln("Derelict GLFW3 unload...");
    DerelictGLFW3.unload();

    writeln("Derelict GL3 unload...");
    DerelictGL3.unload();

    writeln("Derelict GL unload...");
    DerelictGL.unload();
}

