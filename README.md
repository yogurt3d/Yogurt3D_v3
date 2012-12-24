Yogurt3D Version 3 Beta 1
=============

This is the new version of Yogurt3D. 

The current release can be found in [Yogurt3D Github](http://www.github.com/yogurt3d/Yogurt3D)

## Compiling Yogurt3D
There 2 two different options to compile Yogurt3D with.

### Debug
Add -load-config+=y3d_config_debug.xml to your compiler option.
* Y3DCONFIG::TRACE = true
* Y3DCONFIG::DEBUG = true
* Y3DCONFIG::RELEASE = false
* Y3DCONFIG::RENDER_LOOP_TRACE = false

### Release
Add -load-config+=y3d_config_debug.xml to your compiler option.
* Y3DCONFIG::TRACE = false
* Y3DCONFIG::DEBUG = false
* Y3DCONFIG::RELEASE = true
* Y3DCONFIG::RENDER_LOOP_TRACE = false

### Ant Build
There is an attached ant file which compiles as both release and debug. It also attaches an asdoc.
    ant build.xml