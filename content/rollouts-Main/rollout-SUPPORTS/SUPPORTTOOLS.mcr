
/**
  *
  */
macroscript	print_tools_test_support_intersection
category:	"_3D-Print-Support-Tools"
buttontext:	"Intersect"
tooltip:	"Find which support intesect source object"
icon:	"across:5|height:32"
(
	on execute do
		(
			clearListener(); print("Cleared in:\n"+getSourceFileName())
			filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-SUPPORTS\Lib\SupportManager\SupportManager.ms"
			filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-SUPPORTS\SUPPORTTOOLS.mcr"


			(getSupportManagerInstance(ROLLOUT_supports)).findIntersections( selection as Array )


		)
)



/**
  *
  */
macroscript	print_tools_connect_selected_poins
category:	"_3D-Print-Support-Tools"
buttontext:	"Verts To Line"
tooltip:	"Connect selected vers of Edit Poly object with line"
icon:	"across:5|height:32"
(
	on execute do
		(
			clearListener(); print("Cleared in:\n"+getSourceFileName())
			--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-viltools3\VilTools\rollouts-Tools\rollout-PRINT-3D\PLATFORM-TOOLS.mcr"

			--createElevationSliderDialog()
			--verts_pos = #()

			obj = selection[1]

			vertex_sel = (getVertSelection obj.mesh) as Array

			verts_pos = for vert in vertex_sel collect (getVert obj.mesh vert) * obj.transform
			--format "verts_pos	= % \n" verts_pos

			if verts_pos.count >= 2 then
			(

				_shape = SplineShape name:(obj.name + "-connect")

				addNewSpline _shape

				for vert_pos in verts_pos do
					addKnot _shape 1 #corner #line vert_pos

				updateShape _shape

			)

			select _shape

		)
)
