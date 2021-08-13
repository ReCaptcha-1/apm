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
	import com.apm.client.commands.packages.utils.FileUtils;
	import com.apm.client.commands.packages.utils.PackageFileUtils;
	import com.apm.client.processes.ProcessBase;
	import com.apm.data.packages.PackageDefinition;
	import com.apm.data.packages.PackageDefinitionFile;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import org.as3commons.zip.Zip;
	
	
	/**
	 * Creates a zip for a package structure in the specified path.
	 */
	public class PackageContentCreateProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "PackageDefinitionCreateProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _core:APMCore;
		private var _packageDir:File;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function PackageContentCreateProcess( core:APMCore, packageDir:File )
		{
			_core = core;
			_packageDir = packageDir;
		}
		
		
		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );
			if (!_packageDir.exists || !_packageDir.isDirectory)
			{
				_core.io.writeError( _packageDir.name, "Specified package directory does not exist" );
				return failure();
			}
			
			_core.io.showSpinner( "Building package" );
			
			var packageDefinitionFile:File = _packageDir.resolvePath( PackageDefinitionFile.DEFAULT_FILENAME );
			if (!packageDefinitionFile.exists)
			{
				_core.io.writeError( PackageDefinitionFile.DEFAULT_FILENAME, "Package definition file does not exist" );
				return failure();
			}
			var packDefFile:PackageDefinitionFile = new PackageDefinitionFile().load( packageDefinitionFile );
			
			
			var zip:Zip = new Zip();
			
			
			var aneDir:File = _packageDir.resolvePath( PackageFileUtils.AIRPACKAGE_ANE_DIR );
			var swcDir:File = _packageDir.resolvePath( PackageFileUtils.AIRPACKAGE_SWC_DIR );
			var srcDir:File = _packageDir.resolvePath( PackageFileUtils.AIRPACKAGE_SRC_DIR );
			var readmeFile:File = _packageDir.resolvePath( "README.md" );
			var changeLogFile:File = _packageDir.resolvePath( "CHANGELOG.md" );
			var licenseFile:File = _packageDir.resolvePath( "LICENSE.md" );
			
			addFileToZip( zip, packageDefinitionFile );
			addFileToZip( zip, readmeFile );
			
			if (changeLogFile.exists) addFileToZip( zip, changeLogFile );
			if (licenseFile.exists) addFileToZip( zip, licenseFile );
			
			switch (packDefFile.packageDef.type)
			{
				case PackageDefinition.TYPE_SWC:
					addFileToZip( zip, swcDir );
					break;
				case PackageDefinition.TYPE_ANE:
					addFileToZip( zip, aneDir );
					break;
				case PackageDefinition.TYPE_SRC:
					addFileToZip( zip, srcDir );
					break;
			}
			
			var assetsDir:File = _packageDir.resolvePath( PackageFileUtils.AIRPACKAGE_ASSETS );
			if (assetsDir.exists)
			{
				FileUtils.removeEmptyDirectories( assetsDir );
				addFileToZip( zip, assetsDir );
			}

			// TODO:: Manifests etc...
//			var androidFile:File = _packageDir.resolvePath( "android.xml" );
//			var iosFile:File = _packageDir.resolvePath( "ios.xml" );
//
//			if (androidFile.exists) addFileToZip( zip, androidFile );
//			if (iosFile.exists) addFileToZip( zip, iosFile );
			
			
			
			var packageFileName:String = packDefFile.packageDef.identifier + "_" + packDefFile.version.version.toString() + "." + PackageFileUtils.AIRPACKAGEEXTENSION;
			var packageFilePath:String = _core.config.workingDir + File.separator + packageFileName;
			var packageFile:File = new File( packageFilePath );
			
			var outStream:FileStream = new FileStream();
			outStream.open( packageFile, FileMode.WRITE );
			zip.serialize( outStream );
			outStream.close();
			
			_core.io.stopSpinner( true, "Package built: " + packageFileName );
			
			complete();
		}
		
		
		private function addFileToZip( zip:Zip, f:File, path:String = "" ):void
		{
			_core.io.updateSpinner();
			if (f.isDirectory)
			{
				var files:Array = f.getDirectoryListing();
				for each (var dirFile:File in files)
				{
					addFileToZip( zip, dirFile, path + f.name + "/" );
				}
			}
			else
			{
				var content:ByteArray = new ByteArray();
				
				var fs:FileStream = new FileStream();
				fs.open( f, FileMode.READ );
				fs.readBytes( content );
				fs.close();
				
				var filePath:String = path + f.name;
				
				zip.addFile( filePath, content );
			}
		}
		
		
	}
	
}
