/*
* Stats.as
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

package com.yogurt3d.presets.ui.debug{

	import com.yogurt3d.core.Viewport;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.system.System;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.utils.getTimer;

	public class Stats extends Sprite {	

		public const WIDTH : uint = 92;
		public const HEIGHT : uint = 72;

		protected var xml : XML;

		protected var text : TextField;
		protected var style : StyleSheet;

		protected var timer : uint;
		protected var fps : uint;
		protected var ms : uint;
		protected var ms_prev : uint;
		protected var mem : Number;
		protected var mem_max : Number;
		protected var colors : Colors = new Colors();
		private var m_viewport:Viewport;

		/**
		 * <b>Stats</b> FPS, MS and MEM, all in one.
		 */
		public function Stats(_viewport:Viewport) : void {

			mem_max = 0;
			m_viewport = _viewport;

			xml = <xml><rCount>RCOUNT:</rCount><poly>POLY:</poly><fps>FPS:</fps><ms>MS:</ms><mem>MEM:</mem><memMax>MAX:</memMax></xml>;
			
			style = new StyleSheet();
			style.setStyle('xml', {fontSize:'9px', fontFamily:'_sans', leading:'-2px'});
			style.setStyle('poly', {color: hex2css(colors.polygon)});
			style.setStyle('rCount', {color: hex2css(colors.rCount)});
			style.setStyle('fps', {color: hex2css(colors.fps)});
			style.setStyle('ms', {color: hex2css(colors.ms)});
			style.setStyle('mem', {color: hex2css(colors.mem)});
			style.setStyle('memMax', {color: hex2css(colors.memmax)});
			style.setStyle('driver', {color: hex2css(colors.driver)});

			text = new TextField();
			text.width = WIDTH - 2;
			text.height = HEIGHT;
			text.styleSheet = style;
			text.condenseWhite = true;
			text.selectable = false;
			text.mouseEnabled = false;
			text.x = 3;
			text.y = 3;
	
			addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, destroy, false, 0, true);

		}

		private function init(e : Event) : void {

			graphics.beginFill(colors.polygon);
			graphics.drawRect(0, 0, WIDTH, HEIGHT);
			graphics.endFill();
			
			graphics.beginFill(colors.bg);
			graphics.drawRect(1, 1, WIDTH - 2, HEIGHT- 2);
			graphics.endFill();
			
			addChild(text);
			
			xml.driver = stage.stage3Ds[0].context3D.driverInfo;
			
			addEventListener(MouseEvent.CLICK, onClick);
			addEventListener(Event.ENTER_FRAME, update);

		}

		private function destroy(e : Event) : void {

			graphics.clear();

			while(numChildren > 0)
				removeChildAt(0);			
			
			removeEventListener(MouseEvent.CLICK, onClick);
			removeEventListener(Event.ENTER_FRAME, update);

		}

		private function update(e : Event) : void {

			timer = getTimer();

			if( timer - 1000 > ms_prev ) {

				ms_prev = timer;
				mem = Number((System.totalMemory * 0.000000954).toFixed(3));
				mem_max = mem_max > mem ? mem_max : mem;

				xml.fps = "FPS: " + fps + " / " + stage.frameRate; 
				xml.mem = "MEM: " + mem;
				xml.memMax = "MAX: " + mem_max;	
				
				xml.poly = "POLY: " + m_viewport.scene.triangleCount;
				xml.rCount = "RCOUNT: " + m_viewport.scene.getRenderableSet().getRenderableCount();
				fps = 0;
			}

			fps++;

			xml.ms = "MS: " + (timer - ms);
			ms = timer;

			text.htmlText = xml;
		}

		private function onClick(e : MouseEvent) : void {

			mouseY / height > .5 ? stage.frameRate-- : stage.frameRate++;
			xml.fps = "FPS: " + fps + " / " + stage.frameRate;  
			text.htmlText = xml;

		}

		// .. Utils
		private function hex2css( color : int ) : String {

			return "#" + color.toString(16);
		}
	}

}

class Colors {

	public var bg : uint = 0x000000;
	public var polygon : uint = 0xFFFFFF;
	public var rCount : uint = 0xAB1BE0;
	public var fps : uint = 0xffff00;
	public var ms : uint = 0x00ff00;
	public var mem : uint = 0x00ffff;
	public var memmax : uint = 0xff0070;
	public var driver : uint = 0x000000;

}