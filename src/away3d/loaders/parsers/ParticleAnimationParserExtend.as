package away3d.loaders.parsers 
{
	import away3d.animators.ParticleAnimator;
	import away3d.animators.ParticleAnimatorExtend;
	import away3d.arcane;
	import away3d.loaders.parsers.particleSubParsers.nodes.ParticleTimeNodeSubParser;
		   
	use namespace arcane;
	
	public class ParticleAnimationParserExtend extends ParticleAnimationParser 
	{
		
		public function ParticleAnimationParserExtend() 
		{
			super();
			
		}
		
		override protected function createAnimationParser():void 
		{
			var timeNode:ParticleTimeNodeSubParser = _nodeParsers[0] as ParticleTimeNodeSubParser;
			var animator:ParticleAnimatorExtend = new ParticleAnimatorExtend(_particleAnimationSet);
			
			animator._maxStartTime = timeNode._startTimeValue.setter.generateMaxValue();
			
		
			if (timeNode.usesDuration)
			{
				animator._duration = timeNode._durationValue.setter.generateOneValue();
				animator._absoluteAnimationTime = animator._duration + animator._maxStartTime;
			}
			else
			{
				animator._duration  = 0;
				animator._absoluteAnimationTime = 0;
			}
			
			
			animator._isUsesLoop = timeNode.usesLooping;
			
			_particleAnimator = animator;
		}
		
	}

}