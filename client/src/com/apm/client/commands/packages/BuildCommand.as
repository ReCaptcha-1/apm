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
package com.apm.client.commands.packages
{
	import com.apm.client.APMCore;
	import com.apm.client.commands.Command;
	import com.apm.client.commands.packages.processes.PackageContentCreateProcess;
	import com.apm.client.commands.packages.processes.PackageContentVerifyProcess;
	import com.apm.client.commands.packages.processes.PackageDependenciesVerifyProcess;
	import com.apm.client.commands.packages.processes.ViewPackageProcess;
	import com.apm.client.processes.ProcessQueue;
	
	import flash.filesystem.File;
	
	
	public class BuildCommand implements Command
	{
		
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "BuildCommand";
		
		public static const NAME:String = "build";
		
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _parameters:Array;
		private var _queue:ProcessQueue;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function BuildCommand()
		{
			super();
			_queue = new ProcessQueue();
		}
		
		
		public function setParameters( parameters:Array ):void
		{
			_parameters = parameters;
		}
		
		
		public function get name():String
		{
			return NAME;
		}
		
		
		public function get category():String
		{
			return "";
		}
		
		
		public function get requiresNetwork():Boolean
		{
			return false;
		}
		
		
		public function get requiresProject():Boolean
		{
			return false;
		}
		
		
		public function get description():String
		{
			return "create a package template for a new package in the repository";
		}
		
		
		public function get usage():String
		{
			return description + "\n" +
					"\n" +
					"apm build          build a package in the current directory\n" +
					"apm build <foo>    build a package in a directory named <foo>\n";
		}
		
		
		public function execute( core:APMCore ):void
		{
			var path:String = "";
			if (_parameters != null && _parameters.length > 0)
			{
				path = _parameters[0];
			}
			
			core.io.writeLine( "Building package" );
			
			var packageDir:File = new File( core.config.workingDir + File.separator + path );
			
			_queue.addProcess( new PackageContentVerifyProcess( core, packageDir ));
			_queue.addProcess( new PackageContentCreateProcess( core, packageDir ));
			
			_queue.start(
					function ():void
					{
						core.exit( APMCore.CODE_OK );
					},
					function ( message:String ):void
					{
						core.exit( APMCore.CODE_ERROR );
					}
			);
		}
		
	}
	
}