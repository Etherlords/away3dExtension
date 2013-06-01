package away3d.textures
{
	import away3d.arcane;

	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.TextureBase;

	use namespace arcane;

	public class Texture2DBase extends TextureProxyBase
	{
		public function Texture2DBase()
		{
			super();
			
		}

		override protected function createTexture(context : Context3D) : TextureBase
		{
			try
			{
				return context.createTexture(_width, _height, Context3DTextureFormat.BGRA, false);
			}
			catch (e:Error)
			{
				log('Texture2DBase try crate texture, but fail', this.name, this.assetFullPath, this._width, this.height);
			}
			
			return null
		}
	}
}
