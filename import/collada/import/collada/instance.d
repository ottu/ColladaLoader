module collada.instance;

import collada.base;
import collada.dataflow;
import collada.utils;

struct InstanceType( string getNameName )
{
    string sid;
    string name;
    string url;
    //[] extra;

    void load( XmlNode xml )
    in
    {
        assert( xml.getName == getNameName );
        assert( xml.getAttributes.length >= 1 );
    }
    out
    {
        assert( url != "" );
    }
    body
    {
        foreach( key, value; xml.getAttributes )
        {
            switch( key )
            {
                case "sid"  : { sid  = value; } break;
                case "name" : { name = value; } break;
                case "url"  : { url  = value; } break;
                default : {} break;
            }
        }
    }
}

alias InstanceType!("instance_camera") InstanceCamera;
alias InstanceType!("instance_light")  InstanceLight;
alias InstanceType!("instance_node")   InstanceNode;

struct BindVertexInput
{
    string semantic;
    string input_semantic;
    int    input_set;

    void load( XmlNode xml )
    in
    {
        assert( xml.getName == "bind_vertex_input" );
        assert( xml.getAttributes.length >= 2 );
        assert( xml.getElements.length == 0 );
    }
    out
    {
        assert( semantic != "" );
        assert( input_semantic != "" );
    }
    body
    {
        foreach( key, value; xml.getAttributes )
        {
            switch( key )
            {
                case "semantic" : { semantic = value; } break;
                case "input_semantic" : { input_semantic = value; } break;
                case "input_set": { input_set = value.to!int; } break;
                default : {} break;
            }
        }
    }
}

struct InstanceEffect
{
    string sid;
    string name;
    string url;

    //[] technique_hint
    //[] setparam
    //[] extra

    void load( XmlNode xml )
    in
    {
        assert( xml.getName == "instance_effect" );
        assert( xml.getAttributes.length == 1 );
        assert( "url" in xml.getAttributes );
    }
    out
    {
        assert( url != "" );
    }
    body
    {
        url = xml.getAttributes["url"];

        foreach( elem; xml.getElements )
        {
            switch( elem.getName )
            {
                //case "technique_hint" : {} break;
                //case "setparam" : {} break;
                //case "extra" : {} break;
                default : { throw new Exception("InstanceEffect element switch failed."); }
            }
        }
    }
}

struct InstanceMaterial
{
    string sid;
    string name;
    string target;
    string symbol;

    //Bind[] binds;
    BindVertexInput[] bind_vertex_inputs;
    //extra

    void load( XmlNode xml )
    in
    {
        assert( xml.getName == "instance_material" );
        assert( xml.getAttributes.length >= 2 );
    }
    out
    {
        assert( target != "" );
        assert( symbol != "" );
    }
    body
    {
        foreach( key, value; xml.getAttributes )
        {
            switch( key )
            {
                case "sid"    : { sid    = value; } break;
                case "name"   : { name   = value; } break;
                case "target" : { target = value; } break;
                case "symbol" : { symbol = value; } break;
                default : {} break;
            }
        }

        foreach( elem; xml.getElements )
        {
            switch( elem.getName )
            {
                case "bind" : {} break;

                case "bind_vertex_input" :
                {
                    BindVertexInput bvi;
                    bvi.load( elem );
                    bind_vertex_inputs ~= bvi;
                } break;

                case "extra" : {} break;
                default : {} break;
            }
        }
    }

}

struct TechniqueCommon
{
    InstanceMaterial[] instanceMaterials;

    void load( XmlNode xml )
    in
    {
        assert( xml.getName == "technique_common" );
        assert( xml.getAttributes.length == 0 );
        assert( xml.getElements.length >= 1 );
    }
    out
    {
        assert( instanceMaterials.length >= 1 );
    }
    body
    {
        foreach( elem; xml.getElements )
        {
            InstanceMaterial im;
            im.load( elem );
            instanceMaterials ~= im;
        }

    }
}

struct BindMaterial
{
    Param[] params;
    TechniqueCommon common;
    //[] techniques;
    //[] extra;

    void load( XmlNode xml )
    in
    {
        assert( xml.getName == "bind_material" );
        assert( xml.getAttributes.length == 0 );
        assert( xml.getElements.length >= 1 );
    }
    out
    {
        assert( common.instanceMaterials.length > 0 );
    }
    body
    {
        foreach( elem; xml.getElements )
        {
            switch( elem.getName )
            {
                case "param" :
                {
                    Param param;
                    param.load( elem );
                    params ~= param;
                } break;

                case "technique_common" : {    common.load( elem );} break;
                case "technique" : {} break;
                case "extra" : {} break;
                default : {} break;
            }
        }
    }
}

struct InstanceGeometry
{
    string sid;
    string name;
    string url;

    BindMaterial bindMaterial;
    //[] extra;

    void load( XmlNode xml )
    in
    {
        assert( xml.getName == "instance_geometry" );
        assert( xml.getAttributes.length >= 1 );
    }
    out
    {
        assert( url != "" );
    }
    body
    {
        foreach( key, value; xml.getAttributes )
        {
            switch( key )
            {
                case "sid"  : { sid  = value; } break;
                case "name" : { name = value; } break;
                case "url"  : { url  = value; } break;
                default : {} break;
            }
        }

        foreach( elem; xml.getElements )
        {
            switch( elem.getName )
            {
                case "bind_material" : { bindMaterial.load( elem ); } break;
                case "extra" : {} break;
                default : {} break;
            }
        }
    }
}

struct InstanceController
{
    string sid;
    string name;
    string url;

    string[] skeletons;
    BindMaterial bindMaterial;
    //[] extra;

    void load( XmlNode xml )
    in
    {
        assert( xml.getName == "instance_controller" );
        assert( xml.getAttributes.length >= 1 );
    }
    out
    {
        assert( url != "" );
    }
    body
    {
        foreach( key, value; xml.getAttributes )
        {
            switch( key )
            {
                case "sid"  : { sid  = value; } break;
                case "name" : { name = value; } break;
                case "url"  : { url  = value; } break;
                default : {} break;
            }
        }

        foreach( elem; xml.getElements )
        {
            switch( elem.getName )
            {
                case "skeleton" :
                {
                    skeletons ~= elem.getTexts[0];
                } break;

                case "bind_material" : { bindMaterial.load( elem );    } break;
                case "extra" : {} break;
                default : {} break;
            }
        }
    }
}
