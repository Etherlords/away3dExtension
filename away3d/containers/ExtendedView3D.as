package away3d.containers 
{
	import away3d.cameras.Camera3D;
	import flash.geom.Vector3D;
	
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	
	import away3d.core.render.RendererBase;
	
	/**
	 * ...
	 * @author Nikro
	 */
	public class ExtendedView3D extends View3D 
	{
		private var _isUseRatioFromStage:Boolean = false;
		
		public function ExtendedView3D(scene:Scene3D=null, camera:Camera3D=null, renderer:RendererBase=null, forceSoftware:Boolean=false, profile:String = 'baseline') 
		{
			super(scene, camera, renderer, forceSoftware);
			
			
		}
		
		override public function unproject(mX:Number, mY:Number, mZ:Number):Vector3D 
		{
			var actualWidth:Number = x + _stage3DProxy.width;
			var actualHeight:Number = y + _stage3DProxy.height;
			
			return _camera.unproject((mX * 2 - actualWidth) / actualWidth , (mY * 2 - actualHeight) / actualHeight, mZ);
		}
		
		override public function get width():Number 
		{
			return super.width;
		}
		
		override public function set width(value:Number):void 
		{
			super.width = value;
			
			/**
			 * ##NOTE: Поменял с _width вьюва т.е конейнера стейджа 3д на стейдж вид т.к факт изменения размера контейнера не должен влеять на как бы отображаемую картину
			 */
			
			 if(_isUseRatioFromStage)
				_aspectRatio = (stage? stage.stageWidth:width) / height;
			else
				_aspectRatio = width / height;
		}
		
		override public function get height():Number 
		{
			return super.height;
		}
		
		override public function set height(value:Number):void 
		{
			super.height = value;
			
			/**
			 * ##NOTE: Поменял с _width вьюва т.е конейнера стейджа 3д на стейдж вид т.к факт изменения размера контейнера не должен влеять на как бы отображаемую картину
			 */
			
			 if(_isUseRatioFromStage)
				_aspectRatio = (stage? stage.stageWidth:width) / height;
			else
				_aspectRatio = width / height;
		}
		
		public function get isUseRatioFromStage():Boolean 
		{
			return _isUseRatioFromStage;
		}
		
		public function set isUseRatioFromStage(value:Boolean):void 
		{
			_isUseRatioFromStage = value;
		}
		
	}

}