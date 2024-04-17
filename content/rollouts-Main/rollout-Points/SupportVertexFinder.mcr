filein( getFilenamePath(getSourceFileName()) + "/Lib/SupportVertexFinder/SupportVertexFinder.ms" )	--"./Lib/SupportVertexFinder/SupportVertexFinder.ms"


/** Select verts by cavity
	All verts are used if nothing selected

  @param #CONVEX|#CONCAVE|#MIXED|#CORNER


	CTRL:  Use all verts
	SHIFT: Select convex\concave and mixed
	ALT:	Hide other types of verts

 */
function selectConcexOrBottomFacesOrVers mode subobject:#VERTEX =
(
	--format "\n"; print ".selectVertsByCavity()"
		obj	= selection[1]


		SupportVertexFinder 	= SupportVertexFinder_v( obj  )

		ctrl	= keyboard.controlPressed
		alt	= keyboard.altPressed
		shift	= keyboard.shiftPressed



		if ctrl then
		(
			obj.EditablePoly.unhideAll subobject

			obj.EditablePoly.SetSelection subobject #{}
		)


		if mode == #CONVEX then
			SupportVertexFinder.selectConvex subobject:subobject
		else
			SupportVertexFinder.selectBottom subobject:subobject


		if alt then
			obj.EditablePoly.unhideAll subobject


		if subobject != #FACE and not alt then
		(
			actionMan.executeAction 0 "40044"  -- Selection: Select Invert

			obj.EditablePoly.hide subobject

			actionMan.executeAction 0 "40021"  -- Selection: Select All

		)


)




/**
 *
 */
macroscript	maxtoprint_get_convex_verts
category:	"maxtoprint"
buttontext:	"Sel Convex"
toolTip:	"VERTS"
icon:	"tooltip:CTRL: Clear selection"
(
	on execute do
	(
		filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-Points\SupportVertexFinder.mcr"

		selectConcexOrBottomFacesOrVers #CONVEX
	)
)

/**
 *
 */
macroscript	maxtoprint_get_convex_faces
category:	"maxtoprint"
buttontext:	"Sel Convex"
toolTip:	"FACES"
icon:	"tooltip:CTRL: Clear selection"
(
	on execute do
	(
		filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-Points\SupportVertexFinder.mcr"

		selectConcexOrBottomFacesOrVers #CONVEX subobject:#FACE
	)
)



/**
 *
 */
macroscript	maxtoprint_get_bottom_verts
category:	"maxtoprint"
buttontext:	"Sel Bottom"
toolTip:	"VERTS"
icon:	"tooltip:CTRL: Clear selection"
(
	on execute do
	(
		filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-Points\SupportVertexFinder.mcr"

		selectConcexOrBottomFacesOrVers #BOTTOM
	)
)

/**
 *
 */
macroscript	maxtoprint_get_bottom_faces
category:	"maxtoprint"
buttontext:	"Sel Bottom"
toolTip:	"FACES"
icon:	"tooltip:CTRL: Clear selection"
(
	on execute do
	(
		filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-Points\SupportVertexFinder.mcr"

		selectConcexOrBottomFacesOrVers #BOTTOM subobject:#FACE
	)
)


/**
 *
 */
macroscript	maxtoprint_get_elements
category:	"maxtoprint"
buttontext:	"Get Elements"
toolTip:	""
icon:	"tooltip:CTRL: Clear selection"
(

	on execute do
	(
		filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-Points\SupportVertexFinder.mcr"

		SupportVertexFinder 	= SupportVertexFinder_v( selection[1]  )

		obj	= selection[1]
		--SupportVertexFinder.selectConvex subobject:#VERTS
		--if subobject == #FACE then polyop.getFaceSelection obj else polyop.getVertSelection obj -- return

		--SupportVertexFinder.setSelection (SupportVertexFinder.selectConvex())

		elements = SupportVertexFinder.VerIslandFinder.getElementsOfFaces ( polyop.getFaceSelection obj )
		--getElementsOfFaces ( getFaceSelection obj.mesh )

		for element in elements do
			format "element: %\n" element

		format "elements.count: %\n" elements.count

	)

)
