package com.yogurt3d.core.sceneobjects
{
	import com.yogurt3d.Yogurt3D;
	import com.yogurt3d.core.Scene3D;
	
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	public class Sound3D extends SceneObject
	{
		private var pos:Vector3D = new Vector3D();
		
		private var _soundChannel:SoundChannel;
		private var _soundTransform:SoundTransform;
		private var _loops:int;
		private var _currLoop:int;
		
		public var radius:Number;
		public var smooth:Number;
		public var sound:Sound;
		public var reactivate:Boolean = true;
		
		
		public function Sound3D(_initInternals:Boolean, sound:Sound, loops:int = -1, radius:Number = 500, smooth:Number = 0.3)
		{
			super(_initInternals);
			
			this.sound = sound;
			this.smooth = smooth;
			this.radius = radius;
			
			_loops = loops;
			_currLoop = loops;
			_soundTransform = new SoundTransform( 0, 0 );
			
			onAddedToScene.add(onAdded);
			onRemovedFromScene.add(onRemoved);
		}
		/**
		 * 
		 * @param scnObj
		 * @param scn
		 * 
		 */
		private function onAdded(scnObj:SceneObject, scn:Scene3D):void{
			Yogurt3D.onFrameStart.add(draw);
			trace("onAdded");
		}
		private function onRemoved(scnObj:SceneObject, scn:Scene3D):void{
			Yogurt3D.onFrameStart.remove(draw);
			// stop sound
			trace("onRemoved");
		}
		
		private function soundPlayEvent(e:Event = null):Boolean
		{
			if ( _currLoop != 0 ) {
				_soundChannel = sound.play();
				_soundChannel.addEventListener( Event.SOUND_COMPLETE, soundPlayEvent );
			}
			else {
				if ( _soundChannel ) _soundChannel.stop();
				_soundChannel = null;
				return false;
			}
			
			_currLoop--;
			
			return true;
		}
		
		public function draw():void
		{
			
			// gets the sound global position.
			this.transformation.globalPosition;
			
			// transform to the camera space.
			scene.cameraSet[0].transformation.globalToLocal(this.transformation.globalPosition, pos );
			
				// calculates the volume using the sound to camera distance.
				var volume:Number = ( radius - pos.length ) / radius;
				
				if ( volume > 0 ) {
					if ( !_soundChannel && soundPlayEvent() == false ) return;
				} else 
				{
					if ( reactivate ) _currLoop = _loops;
					if ( _soundChannel ) _soundChannel.stop();
					_soundChannel = null;
					return;
				}
				
				// updates the sound panning.
				var pan:Number = pos.x / radius;
				if ( pan > 1 ) pan = 1 else if ( pan < -1 ) pan = -1;
				
				// update the sound and smooth interpolate the values.
				_soundTransform.volume += ( volume - _soundTransform.volume ) * smooth;
				_soundTransform.pan += ( pan - _soundTransform.pan ) * smooth;
				
				_soundChannel.soundTransform = _soundTransform;
				}
	}
}