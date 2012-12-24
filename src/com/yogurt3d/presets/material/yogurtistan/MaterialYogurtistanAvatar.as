package com.yogurt3d.presets.material.yogurtistan
{
	import com.yogurt3d.core.cameras.Camera3D;
	import com.yogurt3d.core.lights.Light;
	import com.yogurt3d.core.material.MaterialBase;
	import com.yogurt3d.core.sceneobjects.SceneObjectRenderable;
	import com.yogurt3d.core.texture.TextureMap;
	import com.yogurt3d.core.utils.Color;
	
	import flash.display3D.Context3D;

	public class MaterialYogurtistanAvatar extends MaterialBase
	{
		private var m_pass:YogurtistanPassAvatar;
		
		public function MaterialYogurtistanAvatar(_gradient:TextureMap,
												  _emmisiveMask:TextureMap=null,
												  _colorMap:TextureMap=null,
												  _specularMap:TextureMap=null,
												  _shinenessMask:TextureMap=null,
												  _specularColor:Color=null,
												  _specular:Number=1.0,
												  _shineness:Number=1.0,
												  _rimShineness:Number=1.0,
												  _rim:Number=1.0,
												  _blendConstant:Number=1.0,
												  _fspecPower:Number=1.0,
												  _fRimPower:Number=2.0,
												  _opacity:Number=1.0)
		{
			super(false);
			
			m_pass = new YogurtistanPassAvatar(_gradient,
				_emmisiveMask,_colorMap,
				_specularMap,_shinenessMask,_specularColor,
				_specular,_shineness,
				_rimShineness,_rim,
				_blendConstant,_fspecPower,
				_fRimPower,_opacity);	
			
		}
		
		public function get gradient():TextureMap
		{
			return m_pass.gradient;
		}
				
		public function set gradient(value:TextureMap):void
		{
			m_pass.gradient = value;	
		}
		
		public function get colorMap():TextureMap
		{
			return m_pass.colorMap;
		}
				
		public function set colorMap(value:TextureMap):void
		{
			m_pass.colorMap = value;	
		}
		
		public function get shinenessMask():TextureMap
		{
			return m_pass.shinenessMask;
		}
		
		public function set shinenessMask(value:TextureMap):void
		{
			m_pass.shinenessMask = value;
		}
		
		public function get emmisiveMask():TextureMap
		{
			return m_pass.emmisiveMask;
		}
		
		public function set emmisiveMask(value:TextureMap):void
		{
			m_pass.emmisiveMask = value;
		}
		
		public function get specularMap():TextureMap
		{
			return m_pass.specularMap;
		}
		
		public function set specularMap(value:TextureMap):void
		{
			m_pass.specularMap = value;
		}


		public function get specular():Number{
			return m_pass.specular;
		}
		
		public function set specular(_value:Number):void{
			m_pass.specular = _value;
		}
		
		public function get specColor():Color
		{
			return m_pass.specColor;
		}
		
		public function set specColor(value:Color):void
		{
			m_pass.specColor = value;
		}
		
		public function get rim():Number{
			return m_pass.rim;
		}
		
		public function set rim(value:Number):void{
			m_pass.rim = value;
		}
		
		public function get rimShineness():Number{
			return m_pass.rimShineness;
		}
		
		public function set rimShineness(value:Number):void{
			m_pass.rimShineness = value;
		}
		
		public function get shineness():Number{
			return m_pass.shineness;
		}
		
		public function set shineness(_value:Number):void{
			m_pass.shineness = _value;
		}
		
		public function get fRimPower():Number
		{
			return m_pass.fRimPower;
		}
				
		public function set fRimPower(value:Number):void
		{
			m_pass.fRimPower = value;
		}
		
		public function get fspecPower():Number
		{
			return m_pass.fspecPower;
		}
				
		public function set fspecPower(value:Number):void
		{
			m_pass.fspecPower = value;
		}
		
		public function get blendConstant():Number{
			return m_pass.blendConstant;
		}
		
		public function set blendConstant(_value:Number):void{
			m_pass.blendConstant= _value;
		}
		
		public function get opacity():Number
		{
			return m_pass.opacity;
		}
		
		public function set opacity(value:Number):void
		{
			m_pass.opacity = value;
		}
		
		
		public override function set vertexFunction(value:Function):void
		{
			if( value != null )
			{
				m_vertexFunction = value;
			}else{
				m_vertexFunction = emptyFunction;
			}
			m_pass.vertexFunction = m_vertexFunction;
		}
		
		public override function render(_object:SceneObjectRenderable, 
										_lights:Vector.<Light>, _device:Context3D, _camera:Camera3D):void
		{		
			
			m_pass.render(_object, _lights[0], _device,_camera);
			
		}
	}
}