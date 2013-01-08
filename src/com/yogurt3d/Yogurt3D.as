/*
* Yogurt3D.as
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

package com.yogurt3d
{
	import com.yogurt3d.core.Viewport;
	import com.yogurt3d.physics.plugin.IYogurt3DPhysicsPlugin;
	import com.yogurt3d.utils.Time;
	
	import flash.display.Stage;
	import flash.events.Event;
	import flash.utils.getTimer;
	
	import org.osflash.signals.PrioritySignal;
	
	public class Yogurt3D
	{
		public static var physics							:IYogurt3DPhysicsPlugin;
		private static var m_lastEnterFrame					:uint;
		
		public static var m_viewportList					:Vector.<Viewport> 		= new Vector.<Viewport>();
		private static var m_isEnterFrameRegistered			:Boolean 				= false;
		
		private static var m_isPlaying						:Boolean 				= true;
		
		public static const onFrameStart					:PrioritySignal 		= new PrioritySignal();
		public static const onUpdate						:PrioritySignal 		= new PrioritySignal();
		public static const onFrameEnd						:PrioritySignal 		= new PrioritySignal();
		
		public static function get onPrePhysics():PrioritySignal	{ return onUpdate; }
		public static function get onPostPhysics():PrioritySignal	{ return onFrameEnd; }
		public static function get onPreRender():PrioritySignal		{ return onFrameStart; }
		public static function get onPostRender():PrioritySignal	{ return onUpdate; }
		
		private static var m_stage:Stage;
		
		/**
		 * @private
		 *  
		 * @param viewport
		 * 
		 */
		YOGURT3D_INTERNAL static function registerViewport( viewport:Viewport ):void{
			m_viewportList.push( viewport );
			if( !m_isEnterFrameRegistered && viewport.stage )
			{
				m_stage = viewport.stage;
				viewport.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame );
				m_lastEnterFrame = getTimer();
				m_isEnterFrameRegistered = true;
			}
		}
		/**
		 * @private
		 *  
		 * @param viewport
		 * 
		 */		
		YOGURT3D_INTERNAL static function deregisterViewport( viewport:Viewport ):void{
			// find index of viewport
			var index:int = m_viewportList.indexOf( viewport );
			if( index != -1 )
			{
				// if viewport is in the viewport list
				// remove from viewport list
				m_viewportList.splice( index, 1 );
			}
		}
		
		public static function pause():void{
			m_stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame );
			m_isPlaying = false;
		}
		public static function play():void{
			m_lastEnterFrame = getTimer();
			m_stage.addEventListener(Event.ENTER_FRAME, onEnterFrame );
			m_isPlaying = true;
		}
		public static function get isPlaying():Boolean{
			return m_isPlaying;
		}
		
		/**
		 * This function is called on everyframe. It dispatches the frame signals updates physics and then draws the new frame. 
		 * @param event
		 * 
		 */
		private static function onEnterFrame( event:Event ):void{
			// Update the time values
			Time.YOGURT3D_INTERNAL::m_frameCount+=1;
			var now:uint = getTimer();
			Time.YOGURT3D_INTERNAL::m_deltaTime = (now - m_lastEnterFrame) * Time.timeScale;
			Time.YOGURT3D_INTERNAL::m_deltaTimeSeconds = Time.YOGURT3D_INTERNAL::m_deltaTime / 1000;
			Time.YOGURT3D_INTERNAL::m_time += Time.YOGURT3D_INTERNAL::m_deltaTime;
			Time.YOGURT3D_INTERNAL::m_timeSeconds = Time.YOGURT3D_INTERNAL::m_time / 1000;
			m_lastEnterFrame = now;
			
//			Y3DCONFIG::RENDER_LOOP_TRACE{
//				trace("[Yogurt3D][onEnterFrame] start", Time);
//			}
			
			onFrameStart.dispatch();
			for( var i:int = 0; i < m_viewportList.length; i++ )
			{
				if( m_viewportList[i].autoUpdate )
					m_viewportList[i].update();
			}
			onUpdate.dispatch();
			if(physics!=null)
			{
				physics.step();
			}
			onFrameEnd.dispatch();
			
//			Y3DCONFIG::RENDER_LOOP_TRACE{
//				trace("[Yogurt3D][onEnterFrame] end\n");
//			}
		}
		
		
	}
}