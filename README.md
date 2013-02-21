Yogurt3D Version 3 Beta 1
=============

This is the new version of Yogurt3D. 

The current release can be found in [Yogurt3D Github](http://www.github.com/yogurt3d/Yogurt3D)

## Compiling Yogurt3D
There 2 two different options to compile Yogurt3D with.

#### External Dependencies
They can be found under /libs folder
* [as3-signals](https://github.com/robertpenner/as3-signals)
* [swift-suspenders](https://github.com/tschneidereit/SwiftSuspenders)
* [As3 Zip](http://nochump.com/blog/archives/15)

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
    
    
### Simple Scene Setup
    import com.yogurt3d.core.Scene3D;
    import com.yogurt3d.core.Viewport;
    import com.yogurt3d.presets.material.MaterialFill;
    import com.yogurt3d.presets.sceneobjects.PlaneSceneObject;
    
    import flash.display.Sprite;
    
    [SWF(width="800",height="600")]
    public class SetupSample extends Sprite {
        private var viewport:Viewport;
        private var m_plane:PlaneSceneObject;
    
        public function SetupSample() {
            viewport = new Viewport( );
            viewport.autoResize = true;
            viewport.autoUpdate = true;
            viewport.pickingEnabled = true;
    
            viewport.scene = new Scene3D();
            viewport.scene.sceneColor.setColorf(1,0,0,1);
            
            viewport.camera = new Camera3D();
            
            m_plane = new PlaneSceneObject(1000,1000, 30,30);
            m_plane.material = new MaterialFill(0x333333);
    
            viewport.scene.addChild(m_plane);
        
            this.addChild( viewport );
        }
    }
