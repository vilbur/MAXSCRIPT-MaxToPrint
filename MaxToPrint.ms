clearListener(); print("Cleared in:"+getSourceFileName())

filein( getFilenamePath(getSourceFileName()) + "/../MAXSCRIPT-UI-framework/Lib/ContentLoader/ContentLoader.ms" )	--"./../MAXSCRIPT-UI-framework/Lib/ContentLoader/ContentLoader.ms"


current_dir = getFilenamePath(getSourceFileName())


/*------------------------------------------------------------------------------
	START VilTools
------------------------------------------------------------------------------*/
try(


	/** LOAD CONTENT */
	--ContentLoader	= ContentLoader_v path:(current_dir+"\\content") -- WITHOUT INI FILE --DEV
	ContentLoader	= ContentLoader_v path:(current_dir+"\\content") ini:( getSourceFileName())



	/* CHANGE PROPERTIES oF ROLLOUTS */
	--ContentLoader.Dialog.title = "MaxToPrint"

	--/* CREATE DIALOG */
	MaxToPrint = ContentLoader.create width:420 height:1024

	--MaxToPrint.register()

)catch(
	format "\n——————————————— ERROR IN FILE ———————————————\n\n%\n" (getSourceFileName())
	format "\n————————————————— EXCEPTION —————————————————\n\n%\n" (getCurrentException())
	format "\n——————————————————— TRACE ———————————————————\n%\n"   (getCurrentExceptionStackTrace())
	format "\n——————————————————— STACK ———————————————————\n%\n"   (getCurrentExceptionCallStack())
)
