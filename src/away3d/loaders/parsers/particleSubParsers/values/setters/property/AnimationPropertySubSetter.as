package away3d.loaders.parsers.particleSubParsers.values.setters.property
{
	import away3d.animators.data.ParticleProperties;
	import away3d.loaders.parsers.particleSubParsers.utils.AnimationPropertyMaker;
	import away3d.loaders.parsers.particleSubParsers.values.setters.SetterBase;
	
	import flash.geom.Vector3D;
	
	public class AnimationPropertySubSetter extends SetterBase
	{
		private var _positionSetter:SetterBase;
		private var _rotationSetter:SetterBase;
		private var _scaleSetter:SetterBase;
		
		public function AnimationPropertySubSetter(propName:String, positionSetter:SetterBase, rotationSetter:SetterBase, scaleSetter:SetterBase)
		{
			super(propName);
			_positionSetter = positionSetter;
			_rotationSetter = rotationSetter;
			_scaleSetter = scaleSetter;
		}
		
		override public function setProps(prop:ParticleProperties):void
		{
			prop[_propName] = generateOneValue(prop.index, prop.total);
		}
		
		override public function generateOneValue(index:int = 0, total:int = 1):*
		{
			var position:Vector3D = _positionSetter ? _positionSetter.generateOneValue(index, total) : null;
			var rotation:Vector3D = _rotationSetter ? _rotationSetter.generateOneValue(index, total) : null;
			var scale:Vector3D = _scaleSetter ? _scaleSetter.generateOneValue(index, total) : null;
			return new AnimationPropertyMaker(position, rotation, scale);
		}
	}
}
