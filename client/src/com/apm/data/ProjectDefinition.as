/**
 *        __       __               __
 *   ____/ /_ ____/ /______ _ ___  / /_
 *  / __  / / ___/ __/ ___/ / __ `/ __/
 * / /_/ / (__  ) / / /  / / /_/ / /
 * \__,_/_/____/_/ /_/  /_/\__, /_/
 *                           / /
 *                           \/
 * http://distriqt.com
 *
 * @author 		Michael (https://github.com/marchbold)
 * @created		18/5/21
 */
package com.apm.data
{
	import com.apm.client.IO;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	
	/**
	 * Handles loading and saving a project definition file
	 */
	public class ProjectDefinition
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "ProjectDefinition";
		
		
		public static const DEFAULT_FILENAME:String = "project.apm";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _data:Object;
		
		private var _sourceFile:File;
		
		private var _repositories:Vector.<Repository>;
		private var _dependencies:Vector.<Dependency>;
		private var _configuration:Object;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function ProjectDefinition()
		{
			_data = {};
			
			_repositories = new Vector.<Repository>();
			_dependencies = new Vector.<Dependency>();
			_configuration = {};
		}
		
		
		public function parse( content:String ):void
		{
			try
			{
				_data = JSON.parse( content );
				
				if (_data.hasOwnProperty( "repositories" ))
				{
					_repositories = new Vector.<Repository>();
					for each (var rep:Object in _data.repositories)
					{
						_repositories.push( Repository.fromObject( rep ) );
					}
				}
				
				if (_data.hasOwnProperty( "dependencies" ))
				{
					_dependencies = new Vector.<Dependency>();
					for each (var dep:Object in _data.dependencies)
					{
						_dependencies.push( Dependency.fromObject( dep ) );
					}
				}
				
				if (_data.hasOwnProperty("configuration"))
				{
					_configuration = _data.configuration;
				}
				
			}
			catch (e:Error)
			{
				IO.out( "Invalid project file - setting to defaults" );
			}
		}
		
		
		public function stringify():String
		{
			return JSON.stringify( toObject(), null, 4 );
		}
		
		
		public function toObject():Object
		{
			var data:Object = {};
			
			data[ "id" ] = applicationId;
			data[ "name" ] = applicationName;
			data[ "version" ] = version;
			
			var repos:Array = [];
			for each (var repo:Repository in _repositories)
			{
				repos.push( repo.toObject() );
			}
			data[ "repositories" ] = repos;
			
			var deps:Array = [];
			for each (var dep:Dependency in _dependencies)
			{
				deps.push( dep.toObject() );
			}
			data[ "dependencies" ] = repos;
			
			data.configuration = _configuration;
			
			_data = data;
			
			return data;
		}
		
		
		//
		//	OPTIONS
		//
		
		public function get applicationId():String { return _data[ "id" ]; }
		public function set applicationId( value:String ):void { _data[ "id" ] = value; }
		
		
		public function get applicationName():String { return _data[ "name" ]; }
		public function set applicationName( value:String ):void { _data[ "name" ] = value; }
		
		
		public function get version():String { return _data[ "version" ]; }
		public function set version( value:String ):void { _data[ "version" ] = value; }
		
		
		public function get repositories():Vector.<Repository> { return _repositories; }
		
		public function get dependencies():Vector.<Dependency> { return _dependencies; }
		
		public function get configuration():Object { return _configuration; }
		
		
		/**
		 * Retrieves the specified configuration parameter
		 * @param key	The name of the parameter
		 * @return	The value for the parameter or null if the parameter name could not be found
		 */
		public function getConfigurationParam( key:String ):String
		{
			if (_configuration.hasOwnProperty(key))
			{
				return _configuration[key];
			}
			return null;
		}
		
		
		/**
		 * Sets a value for the configuration parameter
		 *
		 * @param key		The name of the parameter
		 * @param value		The value for the parameter
		 */
		public function setConfigurationParam( key:String, value:String ):void
		{
			if (_configuration == null) _configuration = {};
			_configuration[key] = value;
		}
		
		
		
		//
		//	IO
		//
		
		/**
		 * Saves this project definition into the specified file.
		 *
		 * @param f
		 */
		public function save( f:File = null ):void
		{
			if (f == null)
			{
				f = _sourceFile;
			}
			
			if (f == null)
			{
				throw new Error( "No output file specified" );
			}
			
			var content:String = stringify();
			
			var fs:FileStream = new FileStream();
			fs.open( f, FileMode.WRITE );
			fs.writeUTFBytes( content );
			fs.close();
		}
		
		
		/**
		 * Loads the specified file as a project definition file
		 *
		 * @param f
		 *
		 * @return
		 */
		public function load( f:File ):ProjectDefinition
		{
			if (!f.exists)
			{
				throw new Error( "File doesn't exist" );
			}
			
			_sourceFile = f;
			
			var fs:FileStream = new FileStream();
			fs.open( f, FileMode.READ );
			var content:String = fs.readUTFBytes( fs.bytesAvailable );
			fs.close();
			
			parse( content );
			
			return this;
		}
		
		
	}
	
}
