#! /bin/bash

dmd -unittest ../source/app.d \
    -I~/.dub/packages/derelict-master/import \
    ~/.dub/packages/derelict-master/lib/dmd/libDerelictGL3.a \
    ~/.dub/packages/derelict-master/lib/dmd/libDerelictGLFW3.a \
    ~/.dub/packages/derelict-master/lib/dmd/libDerelictIL.a \
    ~/.dub/packages/derelict-master/lib/dmd/libDerelictUtil.a \
    -I~/.dub/packages/gl3n-master \
    ~/.dub/packages/gl3n-master/gl3n/aabb.d \
    ~/.dub/packages/gl3n-master/gl3n/ext/hsv.d \
    ~/.dub/packages/gl3n-master/gl3n/ext/matrixstack.d \
    ~/.dub/packages/gl3n-master/gl3n/frustum.d \
    ~/.dub/packages/gl3n-master/gl3n/interpolate.d \
    ~/.dub/packages/gl3n-master/gl3n/linalg.d \
    ~/.dub/packages/gl3n-master/gl3n/math.d \
    ~/.dub/packages/gl3n-master/gl3n/plane.d \
    ~/.dub/packages/gl3n-master/gl3n/util.d \
    -I~/Programming/D/mylib/adjustxml \
    ~/Programming/D/mylib/adjustxml/libAdjustXML.a \
    -I~/Programming/D/mylib/collada \
    ~/Programming/D/mylib/collada/collada/animation.d \
    ~/Programming/D/mylib/collada/collada/base.d \
    ~/Programming/D/mylib/collada/collada/camera.d \
    ~/Programming/D/mylib/collada/collada/collada.d \
    ~/Programming/D/mylib/collada/collada/controller.d \
    ~/Programming/D/mylib/collada/collada/dataflow.d \
    ~/Programming/D/mylib/collada/collada/effect.d \
    ~/Programming/D/mylib/collada/collada/geometry.d \
    ~/Programming/D/mylib/collada/collada/image.d \
    ~/Programming/D/mylib/collada/collada/instance.d \
    ~/Programming/D/mylib/collada/collada/light.d \
    ~/Programming/D/mylib/collada/collada/material.d \
    ~/Programming/D/mylib/collada/collada/model.d \
    ~/Programming/D/mylib/collada/collada/modelutils.d \
    ~/Programming/D/mylib/collada/collada/scene.d \
    ~/Programming/D/mylib/collada/collada/transform.d \
    -J../public/AppearanceMiku
