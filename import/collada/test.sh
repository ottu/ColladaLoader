#!/bin/bash
dmd $1 -main -unittest -debug -g \
    -I../../import \
    -I~/.dub/packages/gl3n-master/import \
    -I~/.dub/packages/kxml-master/source \
    -I~/.dub/packages/derelict-master/import \
    animation.d \
    base.d \
    camera.d \
    collada.d \
    controller.d \
    dataflow.d \
    effect.d \
    geometry.d \
    image.d \
    instance.d \
    light.d \
    material.d \
    scene.d \
    transform.d \
    utils.d \
    ~/.dub/packages/gl3n-master/libgl3n.a \
    ~/.dub/packages/derelict-master/lib/dmd/libDerelictFI.a \
    ~/.dub/packages/derelict-master/lib/dmd/libDerelictGL3.a \
    ~/.dub/packages/derelict-master/lib/dmd/libDerelictGLFW3.a \
    ~/.dub/packages/derelict-master/lib/dmd/libDerelictUtil.a \
    ~/.dub/packages/kxml-master/libkxml.a
