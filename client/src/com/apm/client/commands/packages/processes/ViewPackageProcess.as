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
 * @created		15/6/21
 */
package com.apm.client.commands.packages.processes
{
	import com.apm.client.APMCore;
	import com.apm.client.processes.ProcessBase;
	import com.apm.data.packages.PackageDefinition;
	import com.apm.remote.repository.RepositoryAPI;
	
	
	public class ViewPackageProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "ViewPackageProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _core:APMCore;
		private var _packageIdentifier:String;
		private var _repositoryAPI:RepositoryAPI;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function ViewPackageProcess( core:APMCore, packageIdentifier:String )
		{
			super();
			_core = core;
			_packageIdentifier = packageIdentifier;
			_repositoryAPI = new RepositoryAPI();
		}
		
		
		override public function start():void
		{
			_core.io.showSpinner( "Finding package : " + _packageIdentifier );
			_repositoryAPI.getPackage( _packageIdentifier, function ( success:Boolean, packageDefinition:PackageDefinition ):void {
				_core.io.stopSpinner( success, "No package found matching : " + _packageIdentifier, success );
				if (success)
				{
					_core.io.writeLine( packageDefinition.toString() );
					
					if (packageDefinition.versions.length == 0)
					{
						_core.io.writeLine( "└── (empty)" );
					}
					else
					{
						for (var i:int = 0; i < packageDefinition.versions.length; i++)
						{
							_core.io.writeLine(
									(i == packageDefinition.versions.length - 1 ? "└──" : "├──") +
									packageDefinition.versions[ i ].toDescriptiveString() );
						}
					}
					
				}
				complete();
			} );
			
		}
		
		
	}
	
}