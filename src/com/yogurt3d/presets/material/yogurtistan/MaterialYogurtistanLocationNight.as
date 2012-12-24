package com.yogurt3d.presets.material.yogurtistan
{
	import com.yogurt3d.core.cameras.Camera3D;
	import com.yogurt3d.core.lights.Light;
	import com.yogurt3d.core.material.MaterialBase;
	import com.yogurt3d.core.sceneobjects.SceneObjectRenderable;
	import com.yogurt3d.core.texture.CubeTextureMap;
	import com.yogurt3d.core.texture.TextureMap;
	import com.yogurt3d.core.utils.Color;
	
	import flash.display3D.Context3D;

	public class MaterialYogurtistanLocationNight extends MaterialBase{
		
		private var m_pass:YogurtistanPassLocationNight;
		
		public function MaterialYogurtistanLocationNight(
			_gradient:TextureMap,
			_lightMap:TextureMap=null,
			_colorMap:TextureMap=null,
			_specularMap:TextureMap=null,
			_emmisiveMask:TextureMap=null,
			_specularMask:TextureMap=null,
			_reflectionMap:CubeTextureMap=null, 
			_color:Color=null,
			_specularColor:Color=null,
			_emmisiveAlpha:Number=1.0,
			_ks:Number=0.0,
			_kr:Number=0.0,
			_blendConstant:Number=1.5,
			_fspecPower:Number=1.0,
			_fRimPower:Number=2.0,
			_kRim:Number=1.0, 
			_kSpec:Number=1.0,
			_opacity:Number=1.0, 	
			_refAlpha:Number=0.0,
			_fresnelReflectance:Number=0.028,
			_fresnelPower:Number=5)
		{
			
			super(false);
			
			m_pass = new YogurtistanPassLocationNight(
				_gradient,_lightMap,_colorMap,
				_specularMap,_emmisiveMask,_specularMask,
				_reflectionMap, _color,_specularColor,_emmisiveAlpha,
				_ks,_kr,_blendConstant,_fspecPower,
				_fRimPower,_kRim, _kSpec,_opacity, 	
				_refAlpha,_fresnelReflectance,_fresnelPower);
		}
		
		public override function render(_object:SceneObjectRenderable, 
										_lights:Vector.<Light>, _device:Context3D, _camera:Camera3D):void
		{		
			
			m_pass.render(_object, _lights[0], _device,_camera);
			
		}
		
		/******************************************************************************************************
		 * Set/Get Constants
		 *****************************************************************************************************/
		public function get blendConstant():Number{
			return m_pass.blendConstant;
		}
		
		public function set blendConstant(_value:Number):void{
			m_pass.blendConstant = _value;
		}
			
		public function get opacity():Number{
			return m_pass.opacity;
		}
		
		public function set opacity(_value:Number):void{
			m_pass.opacity = _value;
		}
		
		public function get fresnelReflectance():Number{
			return m_pass.fresnelReflectance;
		}
		
		public function set fresnelReflectance(_value:Number):void{
			m_pass.fresnelReflectance = _value;
		}
		
		public function get fresnelPower():Number{
			return m_pass.fresnelPower;		
		}
		
		public function set fresnelPower(_value:Number):void{
			m_pass.fresnelPower = _value;
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
		
		public function set ksColor(value:Number):void{
			m_pass.ksColor = value;
		}
		
		public function get ksColor():Number{
			return m_pass.ksColor;
		}
		
		public function get krColor():Number{
			return m_pass.krColor;
		}
		
		public function set krColor(value:Number):void{
			m_pass.krColor = value;
		}
		
		public function get fRimPower():Number
		{
			return m_pass.fRimPower;
		}
		
		public function set fRimPower(value:Number):void
		{
			m_pass.fRimPower = value;
		}
		
		public function get kRim():Number{
			return m_pass.kRim;
		}
		
		public function set kRim(value:Number):void{
			m_pass.kRim = value;
		}
		
		public function get fspecPower():Number
		{
			return m_pass.fspecPower;
		}
		
		public function set fspecPower(value:Number):void
		{
			m_pass.fspecPower = value;
		}
		
		public function get kSpec():Number
		{
			return m_pass.kSpec;
		}
		
		public function set kSpec(value:Number):void
		{
			m_pass.kSpec = value;
		}
		
		public function get color():Color
		{
			return m_pass.color;
		}
		
		public function set color(value:Color):void
		{
			m_pass.color = value;
		}
		
		public function get specColor():Color
		{
			return m_pass.specColor;
		}
		
		public function set specColor(value:Color):void
		{
			m_pass.specColor = value;
		}
		
		/******************************************************************************************************
		 * Set/Get Textures
		 *****************************************************************************************************/
		
		public function get gradient():TextureMap
		{
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
		
		public function get specularMask():TextureMap
		{
			return m_pass.specularMask;
		}
		
		public function set specularMask(value:TextureMap):void
		{
			m_pass.specularMask = value;
		}
		
		public function get reflectionMap():CubeTextureMap
		{
			return m_pass.reflectionMap;
		}
		
		public function set reflectionMap(value:CubeTextureMap):void
		{
			m_pass.reflectionMap = value;	
		}
		
	}
}