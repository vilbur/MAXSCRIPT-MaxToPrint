--filein( getFilenamePath(getSourceFileName()) + "/Lib/VertexLayers/VertexLayers.ms" )	--"./Lib/VertexLayers/VertexLayers.ms"
--filein( getFilenamePath(getSourceFileName()) + "/Lib/VertexLayers/VertexLayers.ms" )	--"./Lib/VertexLayers/VertexLayers.ms"
--filein( getFilenamePath(getSourceFileName()) + "/Lib/VertexGrid/VertexGrid.ms" )	--"./Lib/VertexGrid/VertexGrid.ms"
filein( getFilenamePath(getSourceFileName()) + "/Lib/VertSelector/VertSelector.ms" )	--"./Lib/VertSelector/VertSelector.ms"

/**  Export format
  *
 */
macroscript	_print_select_vets_grid_resolution
category:	"_Print-Points-Tools"
buttonText:	"GRID"
toolTip:	"Get only signlge vertex of each face island"
icon:	"MENU:false|id:#SPIN_grid_step|control:spinner|range:[1, 100, 10]|type:#integer|across:1|height:24|offset:[ 12, 4]|align:#left|fieldwidth:32"
(
	on execute do
		format "EventFired	= % \n" EventFired

)

/**  Export format
  *
 */
macroscript	_print_select_lowest_verts_in_grid
category:	"_Print-Points-Tools"
buttonText:	"GRID"
toolTip:	"SELECT LOWEST SINGLE VERTEX of each face island.\n\Vert with lowest position on Z axis is selected"
icon:	"MENU:true|across:4|height:24"
(
	on execute do
	if selection.count > 0 then
	(
		clearListener(); print("Cleared in:\n"+getSourceFileName())
		filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-viltools3\VilTools\rollouts-Tools\rollout-PRINT-3D\3-1-3-VERTEX SELECTION TOOLS.mcr"

		VertSelector 	= VertSelector_v( selection[1]  )

		VertSelector.selectLowestVertsInGrid resolution:ROLLOUT_points.SPIN_grid_step.value
		--VertexGridSelector.selectVerts()

		gc()
	)
)

/**  Export format
  *
 */
macroscript	_print_select_by_print_layer
category:	"_Print-Points-Tools"
buttonText:	"LAYERS"
toolTip:	"Get only single vertex of each face island.\n\Vert with lowest position on Z axis is selected"
icon:	"MENU:true|across:4|height:24"
(
	on execute do
	if selection.count > 0 then
	(
		clearListener(); print("Cleared in:\n"+getSourceFileName())
		filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-viltools3\VilTools\rollouts-Tools\rollout-PRINT-3D\3-1-3-VERTEX SELECTION TOOLS.mcr"

		--obj	= selection[1]

		VertSelector 	= VertSelector_v( selection[1]  )

		VertSelector.findIslandsPerLayer()

	)
)




/**
  *
  */
macroscript	_print_select_single_vert_of_faces
category:	"_Print-Points-Tools"
buttonText:	"1 on island"
toolTip:	"Get only signlge vertex of each face island"
icon:	"MENU:true|across:4|height:24"
(
	on execute do
	if subObjectLevel == 1 then
	undo "Filter 1 vert per face" on
	(
		clearListener(); print("Cleared in:\n"+getSourceFileName())
		--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-viltools3\VilTools\rollouts-Tools\rollout-PRINT-3D\3-1-3-VERTEX SELECTION TOOLS.mcr"
		--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-Points\Lib\VertSelector\VertSelector.ms"

		VertSelector 	= VertSelector_v( selection[1] )

		VertSelector.selectSingleVertPerFaceIsland()
		--VertSelector.selectVerts()

		gc()
	)
)



/**  Checkerboard selection
  *
 */
macroscript	_print_select_verts_checker_pattern
category:	"_Print-Points-Tools"
buttonText:	"Checker"
toolTip:	"Get selection of selected vertices in cheker pattern"
icon:	"MENU:false|across:4|height:24"
(
	on execute do
	if selection.count > 0 then
	(
		clearListener(); print("Cleared in:\n"+getSourceFileName())
		--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-viltools3\VilTools\rollouts-Tools\rollout-PRINT-3D\3-1-3-VERTEX SELECTION TOOLS.mcr"
		--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-Points\Lib\VertSelector\VertSelector.ms"

		obj	= selection[1]

		VertSelector 	= VertSelector_v( obj ) -- resolution:ROLLOUT_points.SPIN_grid_step.value

		VertSelector.selectChecker resolution:ROLLOUT_points.SPIN_grid_step.value invert_sel:( keyboard.controlPressed )

		--VertSelector.selectVerts()

	)
)
