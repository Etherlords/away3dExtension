package away3d.loaders.parsers 
{
	import away3d.animators.data.ParticleGroupEventProperty;
	import away3d.animators.data.ParticleInstanceProperty;
	import away3d.animators.ParticleAnimatorExtend;
	import away3d.library.assets.IAsset;
	
	import away3d.arcane;
	
	import away3d.entities.Mesh;
	import away3d.entities.ParticleGroup;
	
	import away3d.loaders.misc.ResourceDependency;
	
	import away3d.loaders.parsers.particleSubParsers.values.property.InstancePropertySubParser;
	
	import flash.net.URLRequest;
	
	use namespace arcane;
	/**
	 * ...
	 * @author Nikro
	 */
	public class ParticleGroupParserExtend extends ParticleGroupParser 
	{
		
		public function ParticleGroupParserExtend() 
		{
			super();
			
		}
		
		public static function supportsType(extension:String):Boolean
		{
			return ParticleGroupParser.supportsType(extension);	
		}
		
		public static function supportsData(data:*):Boolean
		{
			return ParticleGroupParser.supportsData(data);	
		}
		
		override protected function generateGroup():void
		{
			var len:int = _animationParsers.length;
			var particleMeshes:Vector.<Mesh> = new Vector.<Mesh>;
			var instanceProperties:Vector.<ParticleInstanceProperty> = new Vector.<ParticleInstanceProperty>(len, true);
			
			var isLoop:Boolean = false;
			var maxAnimationTime:Number = 0
			
			for (var index:int; index < _animationParsers.length; index++)
			{
				var animationParser:ParticleAnimationParserExtend = _animationParsers[index] as ParticleAnimationParserExtend;
				
				if (_instancePropertyParsers[index])
				{
					instanceProperties[index] = ParticleInstanceProperty(_instancePropertyParsers[index].setter.generateOneValue());
				}
				particleMeshes.push(animationParser.particleMesh);
				var animator:ParticleAnimatorExtend = animationParser.particleMesh.animator as ParticleAnimatorExtend;
				
				if(animator.isUsesLoop)
					isLoop = true;
					
				var currentInstanceProp:ParticleInstanceProperty = instanceProperties[index]	
				var playSpeed:Number = 1;
				
				if (currentInstanceProp)
					playSpeed = currentInstanceProp.playSpeed;
					
				var currentAbsoluteTime:Number = animator.absoluteAnimationTime / playSpeed;
				if (maxAnimationTime < currentAbsoluteTime)
					maxAnimationTime = currentAbsoluteTime
			}
			
			if (!isLoop)
			{
				
				if (!_particleEvents)
					_particleEvents = new Vector.<ParticleGroupEventProperty>;
				
				var animationEndEvent:ParticleGroupEventProperty = new ParticleGroupEventProperty(maxAnimationTime, 'AnimationGroupEnded');
				_particleEvents.push(animationEndEvent);
			}
			
			_particleGroup = new ParticleGroup(particleMeshes, instanceProperties, _customParameters, _particleEvents);
		}
		
		override arcane function resolveDependency(resourceDependency:ResourceDependency):void
		{
			var index:int = int(resourceDependency.id);
			var animationParser:ParticleAnimationParserExtend = new ParticleAnimationParserExtend();
			addSubParser(animationParser);
			animationParser.parseAsync(resourceDependency.data);
			_animationParsers[index] = animationParser;
		}
		
		override protected function proceedParsing():Boolean
		{
			if (_isFirstParsing)
			{
				_customParameters = _data.customParameters;
				var animationDatas:Array = _data.animationDatas;
				_animationParsers = new Vector.<ParticleAnimationParser>(animationDatas.length, true);
				_instancePropertyParsers = new Vector.<InstancePropertySubParser>(animationDatas.length, true);
				
				var particleEventsData:Array = _data.particleEvents as Array;
				if (particleEventsData)
				{
					_particleEvents = new Vector.<ParticleGroupEventProperty>;
					for each (var event:Object in particleEventsData)
					{
						_particleEvents.push(new ParticleGroupEventProperty(event.occurTime, event.name));
					}
				}
				
				for (var index:int = 0; index < animationDatas.length; index++)
				{
					var animationData:Object = animationDatas[index];
					var propertyData:Object = animationData.property;
					if (propertyData)
					{
						var instancePropertyParser:InstancePropertySubParser = new InstancePropertySubParser(null);
						addSubParser(instancePropertyParser);
						instancePropertyParser.parseAsync(propertyData.data);
						_instancePropertyParsers[index] = instancePropertyParser;
					}
					if (animationData.embed)
					{
						var animationParser:ParticleAnimationParserExtend = new ParticleAnimationParserExtend();
						addSubParser(animationParser);
						animationParser.parseAsync(animationData.data);
						_animationParsers[index] = animationParser;
					}
					else
					{
						addDependency(index.toString(), new URLRequest(animationData.url), true);
					}
				}
			}
			
			if (callSupeProceedParsing() == PARSING_DONE)
			{
				generateGroup();
				finalizeAsset(_particleGroup);
				return PARSING_DONE;
			}
			else
				return MORE_TO_PARSE;
		
		}
		
	}

}