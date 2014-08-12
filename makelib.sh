#!/bin/bash

dmd -lib -oflibCollada.a \
    source/collada/animation.d \
    source/collada/base.d \
    source/collada/camera.d \
    source/collada/collada.d \
    source/collada/controller.d \
    source/collada/dataflow.d \
    source/collada/effect.d \
    source/collada/geometry.d \
    source/collada/image.d \
    source/collada/instance.d \
    source/collada/light.d \
    source/collada/material.d \
    source/collada/model.d \
    source/collada/scene.d \
    source/collada/transform.d \
    source/collada/utils.d \
    -I~/.dub/packages/kxml-master/source \
    ~/.dub/packages/kxml-master/source/kxml/xml.d
    -I~/.dub/packages/derelict-master/source \
    ~/.dub/packages/derelict-master/source/opengl \

    
