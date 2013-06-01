package away3d.animators 
{
	import away3d.animators.states.ParticleStateBase;
	import away3d.arcane;
	use namespace arcane;
	
	public class ParticleAnimatorExtend extends ParticleAnimator
	{
		private var animationEnded:Boolean = false;
		
		arcane var _duration:Number = 0;
		arcane var _isUsesLoop:Boolean = false;
		arcane var _maxStartTime:Number = 0;
		arcane var _absoluteAnimationTime:Number = 0;
		
		public function ParticleAnimatorExtend(particleAnimationSet:ParticleAnimationSet) 
		{
			super(particleAnimationSet);
		}
		
		override public function get playbackSpeed():Number 
		{
			return super.playbackSpeed;
		}
		
		override public function set playbackSpeed(value:Number):void 
		{
			//_duration *= playbackSpeed;
			//_maxStartTime *= playbackSpeed;
			//_absoluteAnimationTime *= playbackSpeed;
			
			super.playbackSpeed = value;
			
			//_duration /= playbackSpeed;
			//_maxStartTime /= playbackSpeed;
			//_absoluteAnimationTime /= playbackSpeed;
			
			//trace(_duration, _maxStartTime, _absoluteAnimationTime, playbackSpeed, 'TTTTTTTTT');
		}
		
		override public function clone():IAnimator 
		{
			return new ParticleAnimatorExtend(_particleAnimationSet);
		}
		
		override protected function updateDeltaTime(dt:Number):void
		{
			_absoluteTime += dt;
			
			if (animationEnded)
				return;
				
			for each (var state:ParticleStateBase in _timeParticleStates)
			{
				
				state.update(_absoluteTime);
			}
			
			if(!_isUsesLoop && _absoluteAnimationTime > 0)
				animationEnded = _absoluteTime >= _absoluteAnimationTime * 1000
		}
		
		public function get duration():Number 
		{
			return _duration;
		}
		
		public function get isUsesLoop():Boolean 
		{
			return _isUsesLoop;
		}
		
		public function get maxStartTime():Number 
		{
			return _maxStartTime;
		}
		
		public function get absoluteAnimationTime():Number 
		{
			return _absoluteAnimationTime;
		}
		
	}

}