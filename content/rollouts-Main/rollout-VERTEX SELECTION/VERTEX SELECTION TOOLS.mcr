

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
	--	filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-viltools3\VilTools\rollouts-Tools\rollout-PRINT-3D\3-1-3-VERTEX SELECTION TOOLS.mcr"

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

		VertSelector 	= VertSelector_v( obj ) -- resolution:ROLLOUT_vertex_selection.SPIN_grid_step.value

		VertSelector.selectChecker resolution:ROLLOUT_vertex_selection.SPIN_grid_step.value invert_sel:( keyboard.controlPressed )

		--VertSelector.selectVerts()

	)
)
