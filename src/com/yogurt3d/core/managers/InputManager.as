/*
* InputManager.as
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

package com.yogurt3d.core.managers
{
	import com.yogurt3d.Yogurt3D;
	
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	import org.osflash.signals.natives.NativeSignal;
	import com.yogurt3d.YOGURT3D_INTERNAL;
	
	public class InputManager
	{
		private static var m_keyDown			:NativeSignal;
		private static var m_keyUp				:NativeSignal;
		private static var m_mouseUp			:NativeSignal;
		private static var m_mouseMove			:NativeSignal;
		private static var m_mouseDown			:NativeSignal;
		
		private static var m_keyDict			:Dictionary 	= new Dictionary();
		private static var m_keyJustDict		:Dictionary 	= new Dictionary();
		
		private static var m_lastMousePosX		:Number			= 0;
		private static var m_lastMousePosY		:Number			= 0;
		
		private static var m_isMouseButtonDown	:Boolean 		= false;
		
		public static var mouseDeltaX			:Number			= 0;
		public static var mouseDeltaY			:Number			= 0;
		
		YOGURT3D_INTERNAL static function setStage( stage:Stage ):void{
			if( m_keyDown != null )
			{
				m_keyDown.removeAll();
				m_keyDown = null;
			}
			if(  m_keyUp != null )
			{
				m_keyUp.removeAll();
				m_keyUp = null;
			}
			if(  m_mouseDown != null )
			{
				m_mouseDown.removeAll();
				m_mouseDown = null;
			}
			if(  m_mouseUp != null )
			{
				m_mouseUp.removeAll();
				m_mouseUp = null;
			}
			if(  m_mouseMove != null )
			{
				m_mouseMove.removeAll();
				m_mouseMove = null;
			}
			m_keyDown = new NativeSignal(stage, KeyboardEvent.KEY_DOWN, KeyboardEvent);
			m_keyUp = new NativeSignal(stage, KeyboardEvent.KEY_UP, KeyboardEvent);
			m_mouseDown = new NativeSignal(stage, MouseEvent.MOUSE_DOWN);
			m_mouseUp = new NativeSignal(stage, MouseEvent.MOUSE_UP);
			m_mouseMove = new NativeSignal(stage, MouseEvent.MOUSE_MOVE);
			m_lastMousePosX = stage.mouseX;
			m_lastMousePosY = stage.mouseY;
			m_keyDown.add( onKeyDown );
			m_keyUp.add( onKeyUp );
			m_mouseDown.add( onMouseDown );
			m_mouseUp.add( onMouseUp );
			m_mouseMove.add( onMouseMove );
			
			// call onFrameEnd on every frame as last executed function
			Yogurt3D.onFrameEnd.addWithPriority(onFrameEnd, int.MAX_VALUE);
		}
		
		public static function isKeyDown( value:uint ):Boolean{
			return m_keyDict[value] != null;
		}
		
		public static function isKeyJustDown( value:uint ):Boolean{
			return m_keyJustDict[value] != null;
		}
		
		private static function onKeyDown( event:KeyboardEvent ):void{
			m_keyDict[ event.keyCode ] = true;
			m_keyJustDict[ event.keyCode ] = true;
		}
		
		private static function onKeyUp( event:KeyboardEvent ):void{
			delete m_keyDict[ event.keyCode ];
		}
		
		private static function onMouseDown( event:MouseEvent ):void{
			m_lastMousePosX = event.stageX;
			m_lastMousePosY = event.stageY;
			m_isMouseButtonDown = true;
		}
		
		private static function onMouseUp( event:MouseEvent ):void{
			m_isMouseButtonDown = false;
		}
		private static function onMouseMove( event:MouseEvent ):void{
			mouseDeltaX = m_lastMousePosX - event.stageX;
			mouseDeltaY = m_lastMousePosY - event.stageY;
			m_lastMousePosX = event.stageX;
			m_lastMousePosY = event.stageY;
		}
		
		private static function onFrameEnd( ):void{
			for( var key:Object in m_keyJustDict){
				delete m_keyJustDict[key];
			}
			mouseDeltaY = 0;
			mouseDeltaX = 0;
		}
	}
}