package away3d.loaders.parsers
{
	import away3d.animators.ParticleAnimationSet;
	import away3d.animators.ParticleAnimator;
	import away3d.arcane;
	import away3d.bounds.BoundingSphere;
	import away3d.core.base.ParticleGeometry;
	import away3d.entities.Mesh;
	import away3d.loaders.misc.ResourceDependency;
	import away3d.loaders.parsers.particleSubParsers.AllSubParsers;
	import away3d.loaders.parsers.particleSubParsers.materials.MaterialSubParserBase;
	import away3d.loaders.parsers.particleSubParsers.nodes.ParticleNodeSubParserBase;
	import away3d.loaders.parsers.particleSubParsers.nodes.ParticleTimeNodeSubParser;
	import away3d.loaders.parsers.particleSubParsers.utils.MatchingTool;
	import away3d.loaders.parsers.particleSubParsers.values.setters.oneD.OneDCurveSetter;
	import away3d.loaders.parsers.particleSubParsers.values.setters.SetterBase;
	import flash.geom.Vector3D;
	import flash.net.URLRequest;
	
	
	use namespace arcane;
	
	public class ParticleAnimationParser extends CompositeParserBase
	{
		protected var _particleMesh:Mesh;
		protected var _particleAnimator:ParticleAnimator;
		protected var _particleAnimationSet:ParticleAnimationSet;
		protected var _particleGeometry:ParticleGeometry;
		protected var _bounds:Number;

		protected var _nodeParsers:Vector.<ParticleNodeSubParserBase>;
		protected var _particleMaterialParser:MaterialSubParserBase;
		protected var _particlegeometryParser:ParticleGeometryParser;

		public function ParticleAnimationParser()
		{
		}
		
		public static function supportsType(extension:String):Boolean
		{
			extension = extension.toLowerCase();
			return extension == "pam";
		}
		
		public static function supportsData(data:*):Boolean
		{
			return false;
		}
		
		override protected function proceedParsing():Boolean
		{
			if (_isFirstParsing)
			{
				//bounds
				_bounds = _data.bounds;
				
				//material
				var object:Object = _data.material;
				var id:Object = object.id;
				var subData:Object = object.data;
				var parserCls:Class = MatchingTool.getMatchedClass(id, AllSubParsers.ALL_MATERIALS)
				if (!parserCls)
				{
					dieWithError("Unknown matierla parser");
				}
				
				_particleMaterialParser = new parserCls();
				addSubParser(_particleMaterialParser);
				_particleMaterialParser.parseAsync(subData);
				
				
				//animation nodes:
				_nodeParsers = new Vector.<ParticleNodeSubParserBase>;
				
				var nodeDatas:Array = _data.nodes;
				
				for each (var nodedata:Object in nodeDatas)
				{
					subData = nodedata.data;
					id = nodedata.id;
					parserCls = MatchingTool.getMatchedClass(id, AllSubParsers.ALL_PARTICLE_NODES);
					
					if (!parserCls)
					{
						dieWithError("Unknown node parser");
					}
					
					var nodeParser:ParticleNodeSubParserBase = new parserCls;
					addSubParser(nodeParser);
					nodeParser.parseAsync(subData);
					_nodeParsers.push(nodeParser);
				}
				
				//geometry:
				var geometryData:Object = _data.geometry;
				if (geometryData.embed)
				{
					_particlegeometryParser = new ParticleGeometryParser();
					addSubParser(_particlegeometryParser);
					_particlegeometryParser.parseAsync(geometryData.data);
				}
				else
				{
					addDependency("geometry", new URLRequest(geometryData.url), true);
				}
			}
			
			
			if (super.proceedParsing() == PARSING_DONE)
			{
				generateAnimation();
				return PARSING_DONE;
			}
			else
				return MORE_TO_PARSE;
		}
		
		override arcane function resolveDependency(resourceDependency:ResourceDependency):void
		{
			if (resourceDependency.id == "geometry")
			{
				_particlegeometryParser = new ParticleGeometryParser();
				addSubParser(_particlegeometryParser);
				_particlegeometryParser.parseAsync(resourceDependency.data);
			}
		}
		
		override arcane function resolveDependencyFailure(resourceDependency:ResourceDependency):void
		{
			dieWithError("resolveDependencyFailure");
		}
		
		protected function generateAnimation():void
		{
			//animation Set:
			
			var timeNode:ParticleTimeNodeSubParser = _nodeParsers[0] as ParticleTimeNodeSubParser;
			_particleAnimationSet = new ParticleAnimationSet(timeNode.usesDuration, timeNode.usesLooping, timeNode.usesDelay);
			
			var len:int = _nodeParsers.length;
			var handlers:Vector.<SetterBase> = new Vector.<SetterBase>();
			for (var i:int; i < _nodeParsers.length; i++)
			{
				if (i != 0)
					_particleAnimationSet.addAnimation(_nodeParsers[i].particleAnimationNode);
				var setters:Vector.<SetterBase> = _nodeParsers[i].setters;
				
				//trace(_nodeParsers[i].setters);
				
				for each (var setter:SetterBase in setters)
				{
					handlers.push(setter);
					
				}
			}
			var particleInitializer:ParticleInitializer = new ParticleInitializer(handlers);
			_particleAnimationSet.initParticleFunc = particleInitializer.initHandler;
			
			finalizeAsset(_particleAnimationSet);
			//animator:
			createAnimationParser()
			
			//mesh:
			_particleMesh = new Mesh(_particlegeometryParser.particleGeometry, _particleMaterialParser.material);
			_particleMesh.bounds = new BoundingSphere();
			_particleMesh.bounds.fromSphere(new Vector3D, _bounds);
			
			if (_data.hasOwnProperty("shareAnimationGeometry"))
			{
				_particleMesh['shareAnimationGeometry'] = _data.shareAnimationGeometry;
			}
			//_particleMesh.showBounds = true;
			_particleMesh.animator = _particleAnimator;
		
			finalizeAsset(_particleMesh);
		}
		
		protected function createAnimationParser():void
		{
			_particleAnimator = new ParticleAnimator(_particleAnimationSet);
		}

		public function get particleMesh():Mesh
		{
			return _particleMesh;
		}
	}

}


import away3d.animators.data.ParticleProperties;
import away3d.loaders.parsers.particleSubParsers.values.setters.SetterBase;


class ParticleInitializer
{
	private var _setters:Vector.<SetterBase>;
	
	public function ParticleInitializer(setters:Vector.<SetterBase>)
	{
		_setters = setters;
	}
	
	public function initHandler(prop:ParticleProperties):void
	{
		for each (var setter:SetterBase in _setters)
		{
			setter.setProps(prop);
		}
	}
}
