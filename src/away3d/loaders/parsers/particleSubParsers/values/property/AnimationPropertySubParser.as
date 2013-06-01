package away3d.loaders.parsers.particleSubParsers.values.property
{
	import away3d.loaders.parsers.particleSubParsers.AllIdentifiers;
	import away3d.loaders.parsers.particleSubParsers.values.ValueSubParserBase;
	import away3d.loaders.parsers.particleSubParsers.values.setters.SetterBase;
	import away3d.loaders.parsers.particleSubParsers.values.setters.property.AnimationPropertySubSetter;
	import away3d.loaders.parsers.particleSubParsers.values.threeD.ThreeDConstValueSubParser;
	
	public class AnimationPropertySubParser extends ValueSubParserBase
	{
		private var _positionValue:ThreeDConstValueSubParser;
		private var _rotationValue:ThreeDConstValueSubParser;
		private var _scaleValue:ThreeDConstValueSubParser;
		
		public function AnimationPropertySubParser(propName:String)
		{
			super(propName, CONST_VALUE);
		}
		
		override protected function proceedParsing():Boolean
		{
			if (_isFirstParsing)
			{
				if (_data.position)
				{
					_positionValue = new ThreeDConstValueSubParser(null);
					addSubParser(_positionValue);
					_positionValue.parseAsync(_data.position);
				}
				if (_data.rotation)
				{
					_rotationValue = new ThreeDConstValueSubParser(null);
					addSubParser(_rotationValue);
					_rotationValue.parseAsync(_data.rotation);
				}
				if (_data.scale)
				{
					_scaleValue = new ThreeDConstValueSubParser(null);
					addSubParser(_scaleValue);
					_scaleValue.parseAsync(_data.scale);
				}
				
			}
			
			if (super.proceedParsing() == PARSING_DONE)
			{
				initSetter();
				return PARSING_DONE;
			}
			else
				return MORE_TO_PARSE;
		}
		
		private function initSetter():void
		{
			var positionSetter:SetterBase = _positionValue ? _positionValue.setter : null;
			var rotationSetter:SetterBase = _rotationValue ? _rotationValue.setter : null;
			var scaleSetter:SetterBase = _scaleValue ? _scaleValue.setter : null;
			_setter = new AnimationPropertySubSetter(_propName, positionSetter, rotationSetter, scaleSetter);
		}
		
		public static function get identifier():*
		{
			return AllIdentifiers.AnimationPropertySubParser;
		}
	}
}
