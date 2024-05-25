--filein( getFilenamePath(getSourceFileName()) + "/Lib/PinsGenerator.ms" )	--"./Lib/PinsGenerator.ms"

/**
  *
  */
macroscript	_print_generator_pins_width
category:	"_3D-Print"
buttontext:	"Pin Width"
tooltip:	"Diameter of inner pin"
icon:	"across:3|control:spinner|type:#float|range:[ 1, 999, 3 ]|width:64|offset:[ 36, 6 ]"
(
	format "EventFired:	% \n" EventFired
)

/**
  *
  */
macroscript	_print_generator_pins_height
category:	"_3D-Print"
buttontext:	"Pin Height"
tooltip:	"Height of inner pin"
icon:	"across:3|control:spinner|type:#float|range:[ 1, 999, 5 ]|width:64|offset:[ 36, 6 ]"
(
	format "EventFired:	% \n" EventFired
)
/**
  *
  */
macroscript	_print_generator_pins_gap
category:	"_3D-Print"
buttontext:	"Pin Gap"
tooltip:	"Size of gap between inner and outter pin"
icon:	"across:3|control:spinner|type:#float|range:[ 0.1, 999, 0.2 ]|width:64|offset:[ 24, 6 ]"
(
	format "EventFired:	% \n" EventFired
)


/*==============================================================================

		GENERATE BUTTON

================================================================================*/
/*
*/
macroscript	_print_generator_pins
category:	"_3D-Print"
buttontext:	"PINS"
icon:	"across:1|offset:[ 0, 6 ]|width:242|height:32|tooltip:GEENERATE PINS for selected verts"
(
	on execute do
		undo "Generate Pins" on
		(
			clearListener(); print("Cleared in:\n"+getSourceFileName())
			--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-viltools3\VilTools\rollouts-Tools\rollout-LAYERS\Lib\SceneLayers\SceneLayers.ms"
			--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-viltools3\VilTools\rollouts-Tools\rollout-PRINT-3D\Lib\SupportManager\SupportManager.ms"
			--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-viltools3\VilTools\rollouts-Tools\rollout-PRINT-3D\5-PINS.mcr"

			(getSupportManagerInstance(ROLLOUT_points)).createPins( selection as Array )
		)
)