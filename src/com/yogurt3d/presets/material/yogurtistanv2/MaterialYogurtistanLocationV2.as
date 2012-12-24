package com.yogurt3d.presets.material.yogurtistanv2
{
	import com.yogurt3d.core.sceneobjects.camera.Camera3D;
	import com.yogurt3d.core.sceneobjects.lights.Light;
	import com.yogurt3d.core.material.MaterialBase;
	import com.yogurt3d.core.sceneobjects.SceneObjectRenderable;
	import com.yogurt3d.core.texture.CubeTextureMap;
	import com.yogurt3d.core.texture.TextureMap;
	import com.yogurt3d.utils.Color;
	
	import flash.display3D.Context3D;

	public class MaterialYogurtistanLocationV2 extends MaterialBase
	{
		private var m_pass:YogurtistanPassLocationV2;
		
		public function MaterialYogurtistanLocationV2(	_gradient:TextureMap,
														_ambientUpColor:Color,
														_ambientDownColor:Color,
														_lightMap:TextureMap=null,
														_colorMap:TextureMap=null,
														_specularMap:TextureMap=null,
														_emmisiveMask:TextureMap=null,
														_reflectionMap:CubeTextureMap=null,
														_specularColor:Color=null,
														_specular:Number=0.0,
														_blendConstant:Number=1.0,
														_shineness:Number=1.0,
														_fresnelReflectance:Number=0.028,
														_fresnelPower:Number=5,
														_opacity:Number=1.0,
														_emmisiveAlpha:Number=1.0,
														_refAlpha:Number=0.0)
		{
			super(false);
			
			m_pass = new YogurtistanPassLocationV2(
				_gradient,	 _ambientUpColor, _ambientDownColor, _lightMap,	_colorMap,
				_specularMap,	_emmisiveMask,
				_reflectionMap, _specularColor,
				_specular,_blendConstant,_shineness,
				_fresnelReflectance,_fresnelPower,
				_opacity,_emmisiveAlpha,_refAlpha);
			
		}
		
		public function get gradient():TextureMap{
			return m_pass.gradient;
		}
		
		public function set gradient(value:TextureMap):void
		{
			m_pass.gradient = value;
		}
		
		public function get lightMap():TextureMap
		{
			return m_pass.lightMap;
		}
		
		public function set lightMap(value:TextureMap):void
		{
			m_pass.lightMap = value;	
		}
		
		public function get colorMap():TextureMap
		{
			return m_pass.colorMap;
		}
		
		public function set colorMap(value:TextureMap):void
		{
			m_pass.colorMap = value;
		}
		
		public function get specularMap():TextureMap
		{
			return m_pass.specularMap;
		}
		
		public function set specularMap(value:TextureMap):void
		{
			m_pass.specularMap = value;
		}
		
		public function get emmisiveMask():TextureMap
		{
			return m_pass.emmisiveMask;
		}
		
		public function set emmisiveMask(value:TextureMap):void
		{
			m_pass.emmisiveMask = value;
		}
		
		public function get reflectionMap():CubeTextureMap
		{
			return m_pass.reflectionMap;
		}
		
		public function set reflectionMap(value:CubeTextureMap):void
		{
			m_pass.reflectionMap = value;
		}
		
		/******************************************************************************************************
		 * Set/Get Constants
		 *****************************************************************************************************/
		public function get specColor():Color
		{
			return m_pass.specColor;
		}
		
		public function set specColor(value:Color):void
		{
			m_pass.specColor = value;
		}
		
		public function get ambientUpColor():Color{
			return m_pass.ambientUpColor;
		}
		
		public function set ambientUpColor(_value:Color):void{
			m_pass.ambientUpColor = _value;
		}
		
		public function get ambientDownColor():Color{
			return m_pass.ambientDownColor;
		}
		
		public function set ambientDownColor(_value:Color):void{
			m_pass.ambientDownColor = _value;
		}
		
		public function get specular():Number
		{
			return m_pass.specular;
		}
		
		public function set specular(value:Number):void
		{
			m_pass.specular = value;
		}
		
		public function get blendConstant():Number{
			return m_pass.blendConstant;
		}
		
		public function set blendConstant(value:Number):void{
			m_pass.blendConstant = value;
		}
		
		public function get shineness():Number
		{
			return m_pass.shineness;
		}
		
		public function set shineness(value:Number):void
		{
			m_pass.shineness = value;
		}
		
		public function get fresnelReflectance():Number
		{
			return m_pass.fresnelReflectance;
		}
		
		public function set fresnelReflectance(value:Number):void
		{
			m_pass.fresnelReflectance = value;
		}
		
		public function get fresnelPower():Number
		{
			return m_pass.fresnelPower;
		}
		
		public function set fresnelPower(value:Number):void
		{
			m_pass.fresnelPower = value;
		}
		
		public function get opacity():Number{
			return m_pass.opacity;
		}
		
		public function set opacity(_value:Number):void{
			m_pass.opacity = _value;
		}	
		
		public function get emmisiveAlpha():Number
		{
			return m_pass.emmisiveAlpha;
		}
		
		public function set emmisiveAlpha(value:Number):void
		{
			m_pass.emmisiveAlpha = value;
		}
		
		public function get reflectionAlpha():Number
		{
			return m_pass.reflectionAlpha;
		}
		
		public function set reflectionAlpha(value:Number):void
		{
			m_pass.reflectionAlpha = value;
		}
		
		public override function render(_object:SceneObjectRenderable, 
										_lights:Vector.<Light>, _device:Context3D, _camera:Camera3D):void
		{		
			m_pass.render(_object, _lights[0], _device,_camera);
		}
	}
}