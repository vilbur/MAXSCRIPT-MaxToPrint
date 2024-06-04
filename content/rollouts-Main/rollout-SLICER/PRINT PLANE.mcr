

/*------------------------------------------------------------------------------

	EDIT PRINT PLANE

--------------------------------------------------------------------------------*/



/*------------------------------------------------------------------------------

	 BUTTONS

--------------------------------------------------------------------------------*/
--
--/** ELEVATION +\-
-- */
--macroscript	_print_plane_set_elevation_plus
--category:	"_3D-Print"
--buttontext:	"+\-"
--toolTip:	"Shift plane UP"
--icon:	"across:4|id:#BTN_print_plane_pos_increment|#height:32|width:64|align:#left|offset:[ -4, 0 ]"
--(
--
--	--format "EventFired	= % \n" EventFired
--	--clearListener(); print("Cleared in:\n"+getSourceFileName())
--	--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-vilTools3\VilTools\rollouts-Tools\rollout-PRINT-3D\2-PRINT PLANE.mcr"
--
--	val = if keyboard.controlPressed then 10 else 1
--
--	updateSlicePlaneSystem val incremental:true
--)
--
--
--/** ELEVATION +\- RIGHTCLICK
-- */
--macroscript	_print_plane_set_elevation_minus
--category:	"_3D-Print"
--buttontext:	"+\-"
--toolTip:	"Shift plane DOWN\n\nCTRL: value is 10"
--icon:	"across:4|id:#BTN_print_plane_pos_increment|#height:32|width:32|align:#left|offset:[ -4, 0 ]"
--(
--
--	--format "EventFired	= % \n" EventFired
--	--clearListener(); print("Cleared in:\n"+getSourceFileName())
--	--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-vilTools3\VilTools\rollouts-Tools\rollout-PRINT-3D\2-PRINT PLANE.mcr"
--
--	val = if keyboard.controlPressed then -10 else -1
--
--	updateSlicePlaneSystem val incremental:true
--)m


/** NORMAL BUTTON
 */
macroscript	_print_plane_set_normal
category:	"_3D-Print"
buttontext:	"Normal"
toolTip:	"Create\Unhide Plane\n\nToggle Normal if plane exists\n\nCTRL:	2-Sided\n\nSHIFT:	Xray\n\nALT:	Toggle Grey\Green"
icon:	"across:4|id:#BTN_print_plane_nomal|#height:32|width:48|align:#left|offset:[ -16, 0 ]"
(

--	filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-vilTools3\VilTools\rollouts-Tools\rollout-PRINT-3D\2-PRINT PLANE.mcr"

	if $SELECT_PRINT_LAYER == undefined then
		(PrinterVolume_v dummy_name:"SELECT PRINT LAYER" export_size:ROLLOUT_export.SPIN_export_size.value volume_height:ROLLOUT_print_3d.SPIN_layer_height.value ).createVolume(#RECTANGLE)


	if not $SELECT_PRINT_LAYER.isHidden then
	(
		_plane = $SELECT_PRINT_LAYER

		normal_modifier = _plane.modifiers[#NORMAL]

		if normal_modifier == undefined then
		(
			normal_modifier = Normalmodifier()

			addModifier _plane normal_modifier
		)

		if not normal_modifier.enabled then
			normal_modifier.enabled = true

		if keyboard.controlPressed or keyboard.altPressed or keyboard.shiftPressed then
		(
			normal_modifier.enabled = true

			if keyboard.controlPressed then
				_plane.backfacecull = not ( _plane.backfacecull )

			if keyboard.shiftPressed then
				_plane.xray = not ( _plane.xray )

			if keyboard.altPressed then
				_plane.showFrozenInGray = not ( _plane.showFrozenInGray )


		)
		else
			normal_modifier.flip = not ( normal_modifier.flip )

	)
	else
	(
		$SELECT_PRINT_LAYER.layer.on = true
		$SELECT_PRINT_LAYER.isHidden = false
	)


)

/**
 */
macroscript	_print_plane_set_normal_rightclick
category:	"_3D-Print"
buttontext:	"Normal"
toolTip:	"Toggle Normnal"
icon:	"id:#BTN_print_plane_nomal|across:4|width:42|offset:[8,0]"
(

	if $SELECT_PRINT_LAYER != undefined then
		$SELECT_PRINT_LAYER.modifiers[#Normal].enabled = not $SELECT_PRINT_LAYER.modifiers[#Normal].enabled
)


/*------------------------------------------------------------------------------

	SPINNERS

--------------------------------------------------------------------------------*/
--/**
-- */
--macroscript	_print_plane_current_layer
--category:	"_3D-Print"
--buttontext:	"Current"
--tooltip:	"Set Current Layer"
--icon:	"across:4|control:spinner|id:#SPIN_current_layer|type:#integer|range:[ 0, 5000, 0 ]|fieldwidth:32|offset:[ -32, 8 ]|align:#left"
--(
--	--format "EventFired:	% \n" EventFired
--
--	--ROLLOUT_print_3d.SLIDER_set_elevation.value = EventFired.val
--
--	--macros.run "_3D-Print" "_print_plane_set_elevation"
--	updateSlicePlaneSystem (EventFired.val)
--)





/*------------------------------------------------------------------------------

	SLIDER

--------------------------------------------------------------------------------*/

--/**
--  *
--  */
--macroscript	_print_plane_set_elevation
--category:	"_3D-Print"
--buttontext:	"Set Elevation"
--toolTip:	"Set Printer Plane Elevation"
--icon:	"across:1|control:slider|orient:#horizontal|range:[ 0, 5000, 0 ]|ticks:5000|type:#integer"
--(
--	--clearListener(); print("Cleared in:\n"+getSourceFileName())
--	--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-vilTools3\VilTools\rollouts-Tools\rollout-PRINT-3D\2-PRINT PLANE.mcr"
--
--	--format "EventFired:	% \n" EventFired
--
--	updateSlicePlaneSystem (EventFired.val)
--
--
--	--clearListener(); print("Cleared in:\n"+getSourceFileName())
--	--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-vilTools3\VilTools\rollouts-Tools\rollout-EXPORT\rollouts-ExportTo\rollout-3D-PRINT\Lib\PrinterVolume\PrinterVolume.ms"
--	--
--	--(PrinterVolume_v(ROLLOUT_export.SPIN_export_size.value)).createVolume(#RECTANGLE)
--)

--/**
--  *
--  */
--macroscript	_print_plane_set_elevation_rightclick
--category:	"_3D-Print"
--buttontext:	"Set Elevation"
--toolTip:	"Reset plane to 0 on z Axis.\n\nDOUBLE RIGHTCLICK:Delete Plane"
----icon:	"control:slider|orient:#horizontal|across:1|range:[ 0, 5000, 0 ]|ticks:5000|type:#integer"
--icon:	"control:slider"
--(
--	--clearListener(); print("Cleared in:\n"+getSourceFileName())
--	--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-vilTools3\VilTools\rollouts-Tools\rollout-PRINT-3D\2-PRINT PLANE.mcr"
--
--	/* SET LAYER 0 */
--	if $SELECT_PRINT_LAYER != undefined and $SELECT_PRINT_LAYER.pos.z > 0 then
--		updateSlicePlaneSystem 0
--
--	/* DELTE PLANE */
--	else if $SELECT_PRINT_LAYER != undefined then
--		delete $SELECT_PRINT_LAYER
--)


/*------------------------------------------------------------------------------
	PRINTER DUMMY
--------------------------------------------------------------------------------*/

--/**
--  *
--  */
--macroscript	_print_dummy_create_plane
--category:	"_3D-Print"
--buttontext:	"Create Dummy"
--toolTip:	"Create\Delete dummy palne of 3D printer plane"
--icon:	"height:64|across:2"
--(
--
--	--format "EventFired	= % \n" EventFired
--	clearListener(); print("Cleared in:\n"+getSourceFileName())
----	filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-vilTools3\VilTools\rollouts-Tools\rollout-PRINT-3D\PRINTER DUMMY.mcr"
--
--	(PrinterVolume_v(ROLLOUT_export.SPIN_export_size.value)).createVolume(#RECTANGLE)
--)
--
--
--
--/**
--  *
--  */
--macroscript	_print_dummy_create_volume
--category:	"_3D-Print"
--buttontext:	"Create Dummy"
--toolTip:	"Create\Delete dummy of 3D printer volume"
----icon:	"across:3"
--(
--	--format "EventFired	= % \n" EventFired
--	(PrinterVolume_v(ROLLOUT_export.SPIN_export_size.value)).createVolume(#box)
--)
