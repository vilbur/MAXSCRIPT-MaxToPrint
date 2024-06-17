-- DEV IMPORT
filein( getFilenamePath(getSourceFileName()) + "/Lib/SupportManager/getSupportManagerInstance.ms" )	--"./Lib/SupportManager/getSupportManagerInstance.ms"


--/**
--  *
--  */
--macroscript	_print_generator_cross_section
--category:	"_3D-Print"
--buttontext:	"Cross Section"
--tooltip:	"Connect columns of platform with ccross beams"
--icon:	"across:2|control:checkbox"
--(
--	format "EventFired:	% \n" EventFired
--)
/**  Export format
  *
 */
macroscript	_print_generator_beams_connect_increment
category:	"_Export"
buttontext:	"[Connect]"
toolTip:	"Where support is connected to beam"
icon:	"control:radiobuttons|across:1|align:#CENTER|items:#('END', 'MIDDLE', 'THIRD', 'QUATER')|columns:4|offset:[ -72, 0 ]"
(
	--export_dir = execute ("@"+ "\""+EventFired.Roll.export_dir.text +"\"")

	--DosCommand ("explorer \""+export_dir+"\"")
	--format "EventFired	= % \n" EventFired
)

/**
  *
  */
macroscript	_print_generator_beams_max_distance
category:	"_3D-Print"
buttontext:	"Max Distance"
--tooltip:	""
icon:	"across:3|control:spinner|type:#integer|range:[ 1, 999, 5 ]|width:64|offset:[ 36, 6 ]|tooltip:Max distance in mm between supports to generate beam."
(
	format "EventFired:	% \n" EventFired
)

/**
  *
  */
macroscript	_print_generator_beams_max_length
category:	"_3D-Print"
buttontext:	"Min Height"
tooltip:	"Min Height of supports where beam is created"
icon:	"across:3|control:spinner|type:#integer|range:[ 1, 999, 5 ]|width:64|offset:[ 0, 6 ]"
(
	format "EventFired:	% \n" EventFired
)

/**
  *
  */
macroscript	_print_generator_beams_max_length
category:	"_3D-Print"
buttontext:	"Same Height"
tooltip:	"Set height of beams on each support"
icon:	"across:3|control:checkbox|offset:[ 0, 6 ]"
(
	format "EventFired:	% \n" EventFired
)

/*==============================================================================

		GENERATE BUTTON

================================================================================*/
/*
*/
macroscript	_print_support_generator_beams
category:	"_3D-Print"
buttontext:	"BEAMS"
icon:	"across:1|offset:[ 0, 6 ]|width:242|height:32|tooltip:GEENERATE BEAMS between supports.\n\nWORKS ON SELECTION OF:\n\t1) SOURCE OBJECT\n\t2) POINTS\n\t3) SUPPORTS"
(
	on execute do
		undo "Generate Beams" on
		(
			clearListener(); print("Cleared in:\n"+getSourceFileName())
			filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-SUPPORTS\BEAMS.mcr"

			(getSupportManagerInstance(ROLLOUT_supports)).createBeams( selection as Array )
		)
)