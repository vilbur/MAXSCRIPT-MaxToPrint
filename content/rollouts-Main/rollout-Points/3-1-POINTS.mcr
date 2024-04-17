filein( getFilenamePath(getSourceFileName()) + "/Lib/SupportManager/SupportManager.ms" )	--"./Lib/SupportManager/SupportManager.ms"

/*==============================================================================

		COTNROLS ROW 1

================================================================================*/

/**  Export format
  *
 */
macroscript	_print_generator_normal_mode
category:	"_Export"
buttontext:	"Second Point Direction"
toolTip:	"Where support is connected to beam"
icon:	"across:3|align:#LEFT|control:radiobuttons|items:#( 'NORMAL', 'DOWN' )|columns:3|offset:[ 4, 2]"
(
	--export_dir = execute ("@"+ "\""+EventFired.Roll.export_dir.text +"\"")

	--DosCommand ("explorer \""+export_dir+"\"")
	format "EventFired	= % \n" EventFired
)


/** CHECKBOX
 */
macroscript	_print_platform_generator_normals_up
category:	"_3D-Print"
buttontext:	"Normal Limit"
icon:	"across:3|control:checkbox|offset:[ 16, 14]|tooltip:TRUE: Use all verts\n\nFALSE: Use only verts which normal is pointing down or side"

(
	format "EventFired:	% \n" EventFired
)



/** SPINNER
  */
macroscript	_print_platform_generator_normal_length
category:	"_3D-Print"
buttontext:	"Normal Length"
tooltip:	"Length of first segment of platform facing to vertex normal"
icon:	"across:3|control:spinner|offset:[ 0, 14]|fieldwidth:24|range:[ 1, 999, 3 ]"
(
	format "EventFired:	% \n" EventFired
)

--/** CHECKBOX
--  */
--macroscript	_print_platform_generator_normal_use
--category:	"_3D-Print"
--buttontext:	"Use Normals"
--tooltip:	"Use normals to get support direction.\n\nPoints direction is to ground if FALSE "
--icon:	"across:2|control:checkbox|range:[ 1, 999, 3 ]"
--(
--	format "EventFired:	% \n" EventFired
--)

/*==============================================================================

		COTNROLS ROW 2

================================================================================*/

/** CHECKBOX
 */
macroscript	_print_platform_generator_normal_always_down
category:	"_3D-Print"
buttontext:	"Keep Down"
icon:	"across:2|align:#CENTER|offset:[ 24, 8]|control:checkbox|tooltip:Keep secon helper point always lower then first.\n\nIt makes to part of support always pointing down printable."

(
	format "EventFired:	% \n" EventFired
)
/** SPINNER
  */
macroscript	_print_platform_generator_normal_always_down_limit
category:	"_3D-Print"
buttontext:	"Keep down Limit"
tooltip:	"How much must be second point bellow first"
icon:	"across:2|offset:[ 0, 8]|fieldwidth:24|control:spinner|type:#integer|range:[ 1, 99, 1 ]"
(
	format "EventFired:	% \n" EventFired
)


/*==============================================================================

		COTNROLS ROW 3

================================================================================*/





/*==============================================================================

		GENERATE BUTTON

================================================================================*/
/** GENERATE POINTS
 */
macroscript	_print_support_generate_points
category:	"_3D-Print"
buttontext:	"POINTS"
tooltip:	"Generate Points"
icon:	"across:3|offset:[ 16, 8 ]|height:32|width:128|align:#LEFT|tooltip:CTRL: RESET all points on object.\n\n\n\n\nLAST OBJECT IS USED IF NOTHING SELECTED.\n\nIMPORTANT: VERTEX MUST HAS SINGLE VERTEX COLOR,\notherwise then generator could not work properly."
(
	on execute do
		undo "Generate Points" on
		--undo off
		(
			clearListener(); print("Cleared in:\n"+getSourceFileName())
			--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-viltools3\VilTools\rollouts-Tools\rollout-PRINT-3D\3-1-POINTS.mcr"
			points_created = (getSupportManagerInstance()).generatePointHelpers( selection as Array ) reset_helpers: keyboard.controlPressed

			--format "POINTS_CREATED: %\n" points_created
			if points_created != undefined then
				select points_created

			if points_created.count == 0 then
				format "NO POINTS HAS BEEN GEERATED"
		)
)

/** GENERATE POINTS
 */
macroscript	_print_support_generate_points_auto
category:	"_3D-Print"
buttontext:	"AUTO Points"
tooltip:	"Generate Points"
icon:	"across:3|offset:[ 16, 8 ]|height:32|width:128|align:#LEFT|tooltip:CTRL: RESET all points on object.\n\n\n\n\nLAST OBJECT IS USED IF NOTHING SELECTED.\n\nIMPORTANT: VERTEX MUST HAS SINGLE VERTEX COLOR,\notherwise then generator could not work properly."
(
	on execute do
		undo "AUTO Points" on
		--undo off
		(
			clearListener(); print("Cleared in:\n"+getSourceFileName())
			filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-viltools3\VilTools\rollouts-Tools\rollout-PRINT-3D\3-1-POINTS.mcr"

			obj	= selection[1]
			VertSelector 	= VertSelector_v( obj )

			polyop.unHideAllVerts obj

			PolyToolsSelect.Normal 3 120 true

			verts_sel	= getVertSelection obj.mesh

			polyop.setHiddenVerts  obj -verts_sel

			convex_verts = VertSelector.getConvexVerts mode:#CONVEX verts:verts_sel

			polyop.setHiddenVerts obj -convex_verts




		)
)


--
--/** SPINNER
--  */
--macroscript	_print_platform_generator_use_every_vertex
--category:	"_3D-Print"
--buttontext:	"Use nth vertex"
--tooltip:	"Use every nth vertex of spline"
--icon:	"across:3|offset:[ 0, 12]|control:spinner|align:#RIGHT|fieldwidth:24|type:#integer|range:[ 1, 99,1 ]"
--(
--	format "EventFired:	% \n" EventFired
--)
