/*
 * DependencyManager.as
 * This file is part of Yogurt3D Flash Rendering Engine
 *
 * Copyright (C) 2011 - Yogurt3D Corp.
 *
 * Yogurt3D Flash Rendering Engine is free software; you can redistribute it and/or
 * modify it under the terms of the YOGURT3D CLICK-THROUGH AGREEMENT
 * License.
 *
 * Yogurt3D Flash Rendering Engine is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *
 * You should have received a copy of the YOGURT3D CLICK-THROUGH AGREEMENT
 * License along with this library. If not, see <http://www.yogurt3d.com/yogurt3d/downloads/yogurt3d-click-through-agreement.html>.
 */

package com.yogurt3d.core.managers {
    import com.yogurt3d.core.objects.EngineObject;
    import com.yogurt3d.core.objects.IController;
    import com.yogurt3d.core.objects.IEngineObject;
    import com.yogurt3d.core.sceneobjects.SceneObject;

    import org.swiftsuspenders.Injector;
    import org.swiftsuspenders.mapping.InjectionMapping;

    public class DependencyManager {
        private static var m_injector:Injector = new Injector();
        /*{
         m_injector.map(EngineObject).toProvider( new EngineObjectUserIdDependencyProvider() );
         }*/
        public static function map(type:Class, name:String = ""):InjectionMapping {
            return m_injector.map(type, name);
        }

        public static function registerObject(sceneObject:IEngineObject, script:IController):void {
            if (sceneObject is SceneObject) {
                sceneObject.injector.map(SceneObject).toValue(sceneObject);
            } else if (sceneObject is EngineObject) {
                sceneObject.injector.map(EngineObject).toValue(sceneObject);
            }

            sceneObject.injector.map(Object(sceneObject).constructor).toValue(sceneObject);

            sceneObject.injector.injectInto(script);

            script.initialize();
        }

        public static function get injector():Injector {
            return m_injector;
        }

    }
}