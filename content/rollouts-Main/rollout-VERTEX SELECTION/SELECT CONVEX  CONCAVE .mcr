filein( getFilenamePath(getSourceFileName()) + "/Lib/VertSelector/VertSelector.ms" )	--"./Lib/VertSelector/VertSelector.ms"



/** Select verts by cavity
	All verts are used if nothing selected

  @param #CONVEX|#CONCAVE|#MIXED|#CORNER


	CTRL:  Use all verts
	SHIFT: Select convex\concave and mixed
	ALT:	Hide other types of verts

 */
function selectConcexOrBottomFacesOrVers mode subobject:#VERTEX =
(

		fn _getSelection obj subobject = if subobject == #FACE then polyop.getFaceSelection obj else polyop.getVertSelection obj -- return
		/** Select final selection
		 */
		fn setSelection obj verts subobject:#VERTEX =
		(
			format "\n"; print "VertSelector_v.selectVerts()"
			--format "verts: %\n" verts

			max modify mode

			setSelectionLevel obj subobject

			_mod = modPanel.getCurrentObject()

			_mod.SetSelection subobject #{}

			if classOf _mod == Edit_Poly then
				_mod.Select subobject verts

			else if classOf _mod  == Editable_Poly then
				_mod.SetSelection subobject verts
		)

	--format "\n"; print ".selectVertsByCavity()"
		obj	= selection[1]

		--VertSelector 	= VertSelector_v( obj  )

		ctrl	= keyboard.controlPressed
		alt	= keyboard.altPressed
		shift	= keyboard.shiftPressed



		if ctrl then
		(
			obj.EditablePoly.unhideAll subobject

			obj.EditablePoly.SetSelection subobject #{}
		)

		max modify mode

		setSelectionLevel obj subobject

		sel_old = _getSelection obj subobject

		if mode == #BOTTOM then
		(
			--PolyToolsSelect.Normal 3 120 true
			PolyToolsSelect.Normal 3 150 true
			--PolyToolsSelect.Normal 3 170 true

			sel_new = _getSelection obj subobject
			--format "not (sel_old * sel_new).isEmpty: %\n" (not (sel_old * sel_new).isEmpty)
			if not sel_old.isEmpty then
				setSelection obj ( sel_new * sel_old ) subobject:subobject
		)
		else
		(
			--PolyToolsSelect.ConvexConcave 0.1 2 -- select convex and convex-concave
			--PolyToolsSelect.ConvexConcave 0.001 2 -- select convex and convex-concave
			PolyToolsSelect.ConvexConcave 0.0001 2 -- select convex and convex-concave

			sel_new = _getSelection obj subobject
			--format "not (sel_old * sel_new).isEmpty: %\n" (not (sel_old * sel_new).isEmpty)
			--if not sel_old.isEmpty and not (sel_old - sel_new).isEmpty then
			if not sel_old.isEmpty then
				setSelection obj ( sel_new * sel_old) subobject:subobject

		)


		if alt then
			obj.EditablePoly.unhideAll subobject


		if subobject != #FACE and not alt then
		(
			actionMan.executeAction 0 "40044"  -- Selection: Select Invert

			obj.EditablePoly.hide subobject

			actionMan.executeAction 0 "40021"  -- Selection: Select All

		)

	--if subobject == #FACE then polyop.getFaceSelection obj else polyop.getVertSelection obj -- return
)




/**
 *
 */
macroscript	maxtoprint_get_convex_verts
category:	"maxtoprint"
buttontext:	"CONVEX"
toolTip:	"VERTS"
icon:	"tooltip:CTRL: Reset selection"
(
	on execute do
	(
	--	filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-Points\3-1-2-SELECT CONVEX - CONCAVE .mcr"

		selectConcexOrBottomFacesOrVers #CONVEX
	)
)

/**
 *
 */
macroscript	maxtoprint_get_convex_faces
category:	"maxtoprint"
buttontext:	"CONVEX"
toolTip:	"FACES"
--icon:	"tooltip:CTRL: Reset selection"
(
	on execute do
	(
	--	filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-Points\3-1-2-SELECT CONVEX - CONCAVE .mcr"

		selectConcexOrBottomFacesOrVers #CONVEX subobject:#FACE
	)
)



/**
 *
 */
macroscript	maxtoprint_get_bottom_verts
category:	"maxtoprint"
buttontext:	"BOTTOM"
toolTip:	"VERTS"
icon:	"tooltip:CTRL: Reset selection"
(
	on execute do
	(
	--	filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-Points\3-1-2-SELECT CONVEX - CONCAVE .mcr"

		selectConcexOrBottomFacesOrVers #BOTTOM
	)
)

/**
 *
 */
macroscript	maxtoprint_get_bottom_faces
category:	"maxtoprint"
buttontext:	"BOTTOM"
toolTip:	"FACES"
--icon:	"tooltip:CTRL: Reset selection"
(
	on execute do
	(
	--	filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-Points\3-1-2-SELECT CONVEX - CONCAVE .mcr"

		selectConcexOrBottomFacesOrVers #BOTTOM subobject:#FACE
	)
)





/**
 *
 */
macroscript	maxtoprint_find_islands
category:	"maxtoprint"
buttontext:	"FIND ISLANDS"
toolTip:	""
icon:	"tooltip:CTRL: New selection"
(

	on execute do
	(
	--	filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-Points\3-1-2-SELECT CONVEX - CONCAVE .mcr"


		obj	= selection[1]

		VertSelector 	= VertSelector_v(obj )
		--if subobject == #FACE then polyop.getFaceSelection obj else polyop.getVertSelection obj -- return

		new_islands_all = VertSelector.findIslandsPerLayer()

		--format "new_islands_all: %\n" new_islands_all

		VertSelector.setSelection ( new_islands_all )

		gc()
		--elements = VertSelector.VerIslandFinder.getElementsOfFaces ( polyop.getFaceSelection obj )
		----getElementsOfFaces ( getFaceSelection obj.mesh )
		--
		--for element in elements do
		--	format "element: %\n" element
		--
		--format "elements.count: %\n" elements.count

	)
)
















--
--
--/** Select verts by cavity
--	All verts are used if nothing selected
--
--  @param #CONVEX|#CONCAVE|#MIXED|#CORNER
--
--
--	CTRL:  Use all verts
--	SHIFT: Select convex\concave and mixed
--	ALT:	Hide other types of verts
--
-- */
--function selectVertsByCavity mode =
--(
--	--format "\n"; print ".selectVertsByCavity()"
--		obj	= selection[1]
--
--		VertSelector 	= VertSelector_v( obj )
--
--		ctrl	= keyboard.controlPressed
--		alt	= keyboard.altPressed
--		shift	= keyboard.shiftPressed
--
--		--mode = case of
--		--(
--		--	( shift ):	#( mode,  #MIXED	)
--		--	--( ctrl and shift ):	#( #CONCAVE, #MIXED	)
--		--	--( alt and shift):	#( #CORNER,  #MIXED	)
--		--	--( alt ):	#MIXED
--		--
--		--	default:	mode
--		--)
--		if shift then
--			mode = #( mode, #MIXED  )
--
--
--		verts = case of
--		(
--			( ctrl ):	#ALL
--			default:	#ALL_OR_SELECTED
--		)
--
--		timer_CONVEX = timeStamp()
--
--		verts_by_type = VertSelector.getConvexVerts mode:mode verts:verts
--
--		--format "verts_by_type: %\n" verts_by_type
--		--hideunselected
--		if alt then
--			polyop.setHiddenVerts obj -verts_by_type
--
--)
--
--
--/* CONVEX VERTS
--  *
--  */
--macroscript	_print_select_verts_convex
--category:	"_Print-Select-by-cavity"
--buttonText:	"Convex"
--toolTip:	"Select Convex Verts"
--icon:	"MENU:true|across:4|height:24|tooltip:CTRL:  #Concave\n:ALT:   #Flat\nSHIFT: #Convex and #Flat\n\nCTRL + SHIFT: #Convex and #Flat\nALT  +  SHIFT: #Corner and #Flat\n"
--(
--	on execute do
--		undo "Select Convex Verts" on
--	(
--		clearListener(); print("Cleared in:\n"+getSourceFileName())
--	--	filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-Points\3-1-2-SELECT CONVEX - CONCAVE .mcr"
--			selectVertsByCavity #CONVEX
--
--	)
--)
--
--
--/* CONCAVE VERTS
--  *
--  */
--macroscript	_print_select_verts_concave
--category:	"_Print-Select-by-cavity"
--buttonText:	"Concave"
--toolTip:	"Select Concave Verts"
--icon:	"MENU:true|across:4|height:24"
--(
--	on execute do
--		undo "Select Concave Verts" on
--	(
--		clearListener(); print("Cleared in:\n"+getSourceFileName())
--	--	filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-Points\3-1-2-SELECT CONVEX - CONCAVE .mcr"
--			selectVertsByCavity #CONCAVE
--
--	)
--)
--
--/* CORNER VERTS
--  *
--  */
--macroscript	_print_select_verts_corner
--category:	"_Print-Select-by-cavity"
--buttonText:	"Corner"
--toolTip:	"Select Corner Verts"
--icon:	"MENU:true|across:4|height:24"
--(
--	on execute do
--		undo "Select Corner Verts" on
--	(
--		clearListener(); print("Cleared in:\n"+getSourceFileName())
--	--	filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-Points\3-1-2-SELECT CONVEX - CONCAVE .mcr"
--			selectVertsByCavity #CORNER
--
--	)
--)
--
--
--/* CONCAVE VERTS
--  *
--  */
--macroscript	_print_select_verts_mixed
--category:	"_Print-Select-by-cavity"
--buttonText:	"Mixed"
--toolTip:	"Select Convex\Concave Verts"
--icon:	"MENU:true|across:4|height:24"
--(
--	on execute do
--		undo "Select Convex\Concave Verts" on
--	(
--		clearListener(); print("Cleared in:\n"+getSourceFileName())
--	--	filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-Points\3-1-2-SELECT CONVEX - CONCAVE .mcr"
--			selectVertsByCavity #MIXED
--
--	)
--)
