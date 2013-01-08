/*
* PostProcessingEffectBase.as
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

package com.yogurt3d.core.render.post
{
	import com.yogurt3d.core.render.base.RenderTargetBase;
	import com.yogurt3d.core.render.renderer.PostProcessRenderer;
	
	import flash.display3D.textures.TextureBase;
	
	public class PostProcessingEffectBase extends RenderTargetBase
	{
		public var overrideToFront			:Boolean = false;
		public var overrideToBack			:Boolean = false;
		public var priority					:uint 	 = 0;
		public var effects					:Vector.<EffectBase>;
		
		private var m_sampler				:TextureBase;
		
		private var m_needsDepth			:Boolean = false;
		private var m_needOriginalScene		:Boolean = false;
		
		public function PostProcessingEffectBase()
		{
			renderer = new PostProcessRenderer();
			effects = new Vector.<EffectBase>();
		}
		
		public function get needOriginalScene():Boolean
		{
			return m_needOriginalScene;
		}

		public function set needOriginalScene(value:Boolean):void
		{
			m_needOriginalScene = value;
		}

		public function get needsDepth():Boolean
		{
			return m_needsDepth;
		}

		public function set needsDepth(value:Boolean):void
		{
			m_needsDepth = value;
		}

		/**
		 * This is the previos screen to be used as a sampler\n
		 * This will be set before render is called
		 */
		public function get sampler():TextureBase
		{
			return m_sampler;
		}

		/**
		 * @private
		 */
		public function set sampler(value:TextureBase):void
		{
			m_sampler = value;

		}
	}
}