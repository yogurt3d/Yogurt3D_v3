/*
 * Copyright (c) 2013. Yogurt Computing Tech.
 *
 * This file is part of Yogurtistan. Any usage of this file
 * outside of Yogurtistan violates it's license. Do not use
 * it in any other application without proper approval.
 *
 * Module: Yogurt3D_v3
 * File: IPickRenderer.as
 * Changes:
 */

/**
 * Created with IntelliJ IDEA.
 * User: Gurel Erceis
 * Date: 25.11.2013
 * Time: 19:53
 * To change this template use File | Settings | File Templates.
 */
package com.yogurt3d.core.render.renderer {
    import com.yogurt3d.core.Scene3D;
    import com.yogurt3d.core.sceneobjects.SceneObjectRenderable;
    import com.yogurt3d.core.sceneobjects.camera.Camera3D;

    import flash.display3D.Context3D;
    import flash.geom.Rectangle;

    import flash.geom.Vector3D;

    public interface IPickRenderer {
        function get localHitPosition():Vector3D;

        function set localHitPosition(value:Vector3D):void;

        function get lastHit():SceneObjectRenderable;

        function set lastHit(value:SceneObjectRenderable):void;

        function get mouseCoordY():Number;

        function set mouseCoordY(value:Number):void;

        function get mouseCoordX():Number;

        function set mouseCoordX(value:Number):void;

        function render( device:Context3D, _scene:Scene3D=null, _camera:Camera3D=null, rect:Rectangle=null, excludeList:Array = null ):void;
    }
}
