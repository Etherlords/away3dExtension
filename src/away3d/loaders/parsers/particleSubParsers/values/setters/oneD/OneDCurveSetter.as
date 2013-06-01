package away3d.loaders.parsers.particleSubParsers.values.setters.oneD
{
	import away3d.animators.data.ParticleProperties;
	import away3d.loaders.parsers.particleSubParsers.values.setters.SetterBase;
	
	public class OneDCurveSetter extends SetterBase
	{
		protected var _anchors:Vector.<Anchor>;
		private var generateOneValueStrategies:Object;
		
		public function OneDCurveSetter(propName:String, anchorDatas:Array)
		{
			super(propName);
			
			initilize(anchorDatas);
		}
		
		private function initilize(anchorDatas:Array):void 
		{
			generateOneValueStrategies = { };
			generateOneValueStrategies[Anchor.LINEAR] = getLinearValue;
			generateOneValueStrategies[Anchor.CONST] = getConstValue;
			
			var len:int = anchorDatas.length;
			_anchors = new Vector.<Anchor>(len, true);
			for (var i:int; i < len; i++)
			{
				_anchors[i] = new Anchor(anchorDatas[i].x, anchorDatas[i].y, anchorDatas[i].type);
			}
		}
		
		override public function setProps(prop:ParticleProperties):void
		{
			prop[_propName] = generateOneValue(prop.index, prop.total);
		}
		
		override public function generateMaxValue():* 
		{
			return _anchors[_anchors.length - 1].y;
		}
		
		override public function generateOneValue(index:int = 0, total:int = 1):*
		{
			//todo:optimise
			var percent:Number = index / total;
			var i:int = 0;
			var l:int = _anchors.length - 1;
			var params:Array;
			var strategie:Function;
			
			for (; i < l ; i++)
			{
				if (_anchors[i + 1].x > percent)
				{
					strategie = generateOneValueStrategies[_anchors[i].type];
					
					params = [i, percent];
					
					return strategie.apply(null, params);
				}
			}
			
			return _anchors[i].y;
		}
		
		private function getLinearValue(i:int, percent:Number):*
		{
			return _anchors[i].y + (percent - _anchors[i].x) / (_anchors[i + 1].x - _anchors[i].x) * (_anchors[i + 1].y - _anchors[i].y);
		}
		
		private function getConstValue(i:int, percent:Number):*
		{
			return _anchors[i].y;
		}
	}
}



class Anchor
{
	//TODO: add the bezier curve support
	public static const LINEAR:int = 0;
	public static const CONST:int = 1;
	public static const BEZIER:int = 2;
	
	public var x:Number;
	public var y:Number;
	public var type:int;
	
	public function Anchor(x:Number, y:Number, type:int)
	{
		this.x = x;
		this.y = y;
		this.type = type;
	}
}
