/*
* FreeFlightCamera.as
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

package com.yogurt3d.presets.cameras
{
import com.yogurt3d.Yogurt3D;
import com.yogurt3d.core.sceneobjects.camera.Camera3D;

import flash.display.DisplayObject;
import flash.events.Event;
    import flash.events.GestureEvent;
    import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
    import flash.events.TouchEvent;
    import flash.events.TransformGestureEvent;
    import flash.system.Capabilities;
    import flash.system.TouchscreenType;
    import flash.ui.Multitouch;

    public class FreeFlightCamera extends Camera3D
	{
		
		private var m_isCtrlDown:Boolean;
		private var m_isShiftDown:Boolean;
		
		private var m_leftKey		:Boolean = false;
		private var m_rightKey		:Boolean = false;
		private var m_upKey			:Boolean = false;
		private var m_downKey		:Boolean = false;
		
		private var m_mouseLastX:Number;
		private var m_mouseLastY:Number;
		
		private var m_viewport:DisplayObject;

        public var speed:Number;

		public function FreeFlightCamera(_viewport:DisplayObject, _speed:Number = 5, _initInternals:Boolean=true)
		{
			super(_initInternals);
			
			if( _viewport.stage )
			{
				_viewport.stage.addEventListener(KeyboardEvent.KEY_DOWN, 	onKeyDown);
				_viewport.stage.addEventListener(KeyboardEvent.KEY_UP, 		onKeyUp );
			}else{
				_viewport.addEventListener(Event.ADDED_TO_STAGE, function( _e:Event ):void{
					_e.target.removeEventListener( 	 Event.ADDED_TO_STAGE, 		arguments.callee );
					_e.target.stage.addEventListener(KeyboardEvent.KEY_DOWN, 	onKeyDown);
					_e.target.stage.addEventListener(KeyboardEvent.KEY_UP, 		onKeyUp );
				});
			}
            if( Multitouch.supportsGestureEvents){
                _viewport.addEventListener(TransformGestureEvent.GESTURE_ZOOM , 	onGestureZoom );
                _viewport.addEventListener(TransformGestureEvent.GESTURE_PAN , 	onGesturePan );
                _viewport.addEventListener(TransformGestureEvent.GESTURE_SWIPE , 	onGestureSwipe );
            } else{
                _viewport.addEventListener(MouseEvent.MOUSE_MOVE, 	onMouseMoveEvent );
                _viewport.addEventListener(MouseEvent.MOUSE_WHEEL, 	onMouseWheelEvent );
            }
            speed = _speed;

			
			m_viewport = _viewport;
			
			Yogurt3D.onUpdate.add( updateWithTimeInfo );
		}
		
		public function updateWithTimeInfo():void{
			if( m_leftKey  )
			{
				moveLocalX( -speed  );
			}
			if( m_rightKey )
			{
				moveLocalX( speed  );
			}
			if( m_downKey )
			{
				moveLocalZ(speed  );
			}
			if( m_upKey  )
			{
				moveLocalZ( -speed  );
			}
		}


        public function moveLocalX( _value:Number ):void{
            transformation.moveAlongLocal( _value,0,0 );
        }
        public function moveLocalY( _value:Number ):void{
            transformation.moveAlongLocal( 0,_value,0 );
        }
		public function moveLocalZ( _value:Number ):void{
			transformation.moveAlongLocal( 0,0,_value );
		}

        protected function onMouseWheelEvent(event:MouseEvent):void{
            moveLocalZ(event.delta  );
        }
        protected function onGestureZoom(event:TransformGestureEvent):void{
            moveLocalZ((1-event.scaleY)*10  );
        }
        protected function onGesturePan(event:TransformGestureEvent):void{
            moveLocalX(-event.offsetX  );
            moveLocalY(event.offsetY  );
        }
        protected function onGestureSwipe(event:TransformGestureEvent):void{
            transformation.rotationY += event.offsetX ;
            transformation.rotationX += event.offsetY ;
        }


		protected function onMouseMoveEvent(event:MouseEvent):void
		{
			var _offsetX:Number 	= m_mouseLastX - event.localX;
			var _offsetY:Number 	= m_mouseLastY - event.localY;
			
			if (event.buttonDown )
			{
				transformation.rotationY += _offsetX ;
				transformation.rotationX += _offsetY ;
			}
			
			m_mouseLastX 	= event.localX;
			m_mouseLastY 	= event.localY;
			
			
		}
		
		
		protected function onKeyDown(event:KeyboardEvent):void
		{
			switch(event.keyCode)
			{
				case 65: // A key
					m_leftKey = true;
					break;
				case 68: // D Key
					m_rightKey = true;
					break;
				case 83: // S Key
					m_downKey = true;
					break;
				case 87: // W Key
					m_upKey = true;
					break;
				case 76: // L Key
					break;
				
				case 16: // SHIFT key
					if (!m_isShiftDown) {
						m_isShiftDown = true;
					}
					
					break;
				
				case 17: // CTRL key
					if (!m_isCtrlDown) {
						m_isCtrlDown = true;
					}
					break;	
				
			}
			
			
			
		}
		
		protected  function onKeyUp(event:KeyboardEvent):void
		{
			m_mouseLastX = m_viewport.mouseX;
			m_mouseLastY = m_viewport.mouseY;
			
			switch(event.keyCode)
			{
				case 65: // A key
					m_leftKey = false;
					break;
				case 68: // D Key
					m_rightKey = false;
					break;
				case 83: // S Key
					m_downKey = false;
					break;
				case 87: // W Key
					m_upKey = false;
					break;
				
				case 16: // SHIFT key
					m_isShiftDown = false;
					break;
				
				case 17: // CTRL Key
					m_isCtrlDown = false;
					break;	
				
			}
		}
	}
}