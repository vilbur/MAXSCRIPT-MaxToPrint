filein( getFilenamePath(getSourceFileName()) + "/../../../../MAXSCRIPT-UI-framework/Lib/Menus/RcMenu/RcMenu.ms" )	--"./../../../../MAXSCRIPT-UI-framework/Lib/Menus/RcMenu/RcMenu.ms"

global VERTEX_COLOR_PARAM

/** Call vertex color submenu
  *
  * 1) Macro	-> Open Submenu openVertexColorSubmenu()	-- Choose used method
  *     2) Submenu Item	-> Call Function callVertexColorMethod()	-- Choose color used for method
  *         3) Function	-> Call Desired Vertex Color Method	-- Run used method with choosed color ( Set color|Select By Color|Hide by Color|... )
  *
 */
function openVertexColorSubmenu method =
(
	format "\n"; print "openVertexColorSubmenu()"
	format "method: %\n" method

	/* DEFINE MAIN MENU */
	Menu = RcMenu_v name:"TestMenu"



	call = "callVertexColorMethod \""+method + "\" "
	--Menu.item "&Main Item 1" "messagebox \"Main Item 1\""

	if VERTEX_COLOR_PARAM != undefined then
	(
		--if method == "color_select_by_selection" then

		call_first_item = case method of
		(
			("color_select"): "callVertexColorMethod \""+method +"_by_selection"+ "\" "
			default: call
		)

		case method of
		(
			("color_set"):	Menu.item "Set &Color"	( call_first_item + " " + VERTEX_COLOR_PARAM as string	)
			("color_select"):	Menu.item "Select Color By &Selection"	( call_first_item + " " + VERTEX_COLOR_PARAM as string	)
			--default:
		)

	)


	Menu.item "&RED"	( call + "red"	)
	Menu.item "&GREEN"	( call + "green"	)
	Menu.item "&BLUE"	( call + "blue"	)



	popUpMenu (Menu.create())

)


/** Call vertex color macro
 */
function callVertexColorMethod method _color =
(
	format "\n"; print "callVertexColorMethod()"

	method = "epoly_vertex_" + method
	format "method: %\n" method
	format "_color: %\n" _color

	VERTEX_COLOR_PARAM = _color

	macros.run "_Epoly-Vertex-Color" ( method )
	--messageBox (param as string ) title:method
)
c

/**
  *
  */
macroscript	epoly_vertex_color_hide_submenu
category:	"_Epoly-Vertex-Color"
buttonText:	"Menu"
toolTip:	""
icon:	"MENU:&Hide Color"
(
	on execute do
		openVertexColorSubmenu "color_hide"
)

/**
  *
  */
macroscript	epoly_vertex_color_unhide_submenu
category:	"_Epoly-Vertex-Color"
buttonText:	"Menu"
toolTip:	""
icon:	"MENU:&Hide Color"
(
	on execute do
		openVertexColorSubmenu "color_unhide"
)



/*==============================================================================
	Color Set
================================================================================*/

/**
  *
  */
macroscript	epoly_vertex_color_set
category:	"_Epoly-Vertex-Color"
buttonText:	"Color Set"
toolTip:	"Set vertex color to selected vertex.\n\nVertex can be selected in modifiers like:\nEdit Poly|Poly Select\n\nLMB: Green\nCTRL:#RED"
icon:	"across:4|tooltip:\n\n----------------------\n\nFIX IF NOT WORK PROPERLY:\\n1) Try clean mesh, weld verts and close borders"
(

	on execute do

	if selection.count > 0 then undo "Set Vertex Color" on
	(
		clearListener(); print("Cleared in:\n"+getSourceFileName())
		filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-VERTEX COLORS\VERTEX COLOR.mcr"


		--_mod = modPanel.getCurrentObject()f
		--format "_mod	= % \n" _mod
		--format "_mod == Editable_Poly	= % \n" (_mod == Editable_Poly)

		--format "VERTS_BASEOBJECTS	= % \n" verts_baseobjects

		--verts_count	= getNumVerts obj.mesh
		--verts_count_VC	= getNumCPVVerts obj.mesh
		obj = selection[1]

		if not polyop.getMapSupport obj 0 then
			polyop.setMapSupport obj 0 true


		verts_count	= polyop.getNumVerts obj.baseObject

		verts_count_VC	= polyop.getNumMapVerts obj.baseObject 0


		if verts_count == verts_count_VC then
		(

			--setNumCPVVerts obj.baseObject.mesh (verts_count) true -- WORKS BUT IT RESET VERTEX COLORS
			--setNumCPVVerts obj.baseObject.mesh (verts_count)		 -- SEEM TO WORKING, RESULT IS



			--format "verts_count_VC	= % \n" (getNumCPVVerts obj.baseObject.mesh)

			--if verts_count == verts_count_VC then
			--(
			verts_baseobjects = passVertexSelectionToEditablePoly()

			format "VERTS_BASEOBJECTS	= % \n" verts_baseobjects
			--if not verts_baseobjects.isEmpty then
			--(
			--
			--	/* SELECT VERTEX IN BASEOBJECT MANNUALY - Direct assigment without swithching to */
			--	if classof _mod != Editable_Poly then
			--		modPanel.setCurrentObject(obj.baseobject)
			--
			--	obj.EditablePoly.SetSelection #Vertex verts_baseobjects
			--
			--	subObjectLevel = 1
			--
			--	polyop.setVertColor obj 0 verts_baseobjects (if keyboard.controlPressed then red else green )
			--
			--	obj.EditablePoly.SetSelection #Vertex #{}
			--
			--	subObjectLevel = 0
			--
			--	if _mod != ( modPanel.getCurrentObject()) then
			--		 modPanel.setCurrentObject(_mod)
			--)


			/* CODE BELLOW OFTEN ASSIGN COLORS TO MANY OTHER VERTS */

			if not verts_baseobjects.isEmpty then
				polyop.setVertColor obj.baseobject 0 (verts_baseobjects) VERTEX_COLOR_PARAM

			obj.showVertexColors	= true
			obj.vertexColorsShaded	= true

			redrawViews()


		)
		else
		(
			format "getNumVerts	= % \n" verts_count
			format "getNumMapVerts	= % \n" verts_count_VC

			addModifier obj (UVW_Mapping_Clear mapID:0) before:obj.modifiers.count

			messageBox "VERTEX COUNT AND COUNT OF COLORED VERTS IS NOT EQUAL\n\nPLEASE RESET UV CHANNEL.\n\nModifier has been added" title:"ERROR"
		)

		--)
		--else if queryBox "RESET OF VERTEX COLORS IS NEEDED.\n\nCONTINUE ?" title:"RESET VERTEX COLORS"  beep:true then
		--(
		--	polyop.defaultMapFaces obj.baseobject 0
		--
		--	messageBox "RESET VERTEX COLORS FINISHED" title:"SUCCESS"
		--)
	)
)


/**
  *
  */
macroscript	epoly_vertex_color_set_submenu
category:	"_Epoly-Vertex-Color"
buttonText:	"Color Set"
toolTip:	""
icon:	"MENU:&Color Set"
(
	on execute do
		openVertexColorSubmenu "color_set"
)



/*==============================================================================
	Color Set
================================================================================*/



/**
  *
  */
macroscript	epoly_vertex_color_select
category:	"_Epoly-Vertex-Color"
buttonText:	"Select Color"
icon:	"across:4|tooltip:Select all verts with same vertex color as selected verts.\n\nSELECT ALL COLORED VERTS IF NOTHING SELECTED"
(
	on execute do if ( obj = selection[1] ) != undefined then
		undo "Select Vertex Color" on
		(
			print "Select Vertex Color"
			format "VERTEX_COLOR_PARAM: %\n" VERTEX_COLOR_PARAM

			if VERTEX_COLOR_PARAM != undefined then
			(
				/* SELECT SINGLE VERTEX COLOR */
				obj.vertSelectionColor = VERTEX_COLOR_PARAM

				macros.run "Ribbon - Modeling" "SelectByVertexColor"

				--VERTEX_COLOR_PARAM = undefined
			)
			else
				openVertexColorSubmenu "color_select"
		)
)



/**
  *
  */
macroscript	epoly_vertex_color_select_submenu
category:	"_Epoly-Vertex-Color"
buttonText:	"Select Color"
toolTip:	""
icon:	"MENU:&Select Color"
(
	on execute do
		openVertexColorSubmenu "color_select"
)




/**
  *
  */
macroscript	epoly_vertex_color_select_by_selection
category:	"_Epoly-Vertex-Color"
buttonText:	"Select By Sel"
icon:	"tooltip:Select all verts with same vertex color as selected verts.\n\nSELECT ALL COLORED VERTS IF NOTHING SELECTED"
(
	on execute do if ( obj = selection[1] ) != undefined then
		undo "Select Vertex Color By Selection" on
		(
			--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-VERTEX COLORS\VERTEX COLOR.mcr"
		print "Select Vertex Color By Selection"

			vertex_sel	= getVertSelection obj.mesh


				verts_by_colors_flat = #{}

				VertexColors = VertexColors_v(obj)


				verts_by_colors =  VertexColors.getVertsAndColors verts:vertex_sel

				for color_verts in verts_by_colors do verts_by_colors_flat += color_verts.value


				/* GET ALL COLORED VERTS */
				if vertex_sel.isEmpty then
				(
					/* GET ONLY WHITE VERTS */
					white_verts = if ( white_verts = verts_by_colors[white as string ] ) != undefined then white_verts else #{}

					verts_by_colors_flat -= white_verts -- get all colored verts
				)


				if classOf (_mod = modPanel.getCurrentObject() ) == Edit_Poly then
				(
					_mod.SetSelection #Vertex #{}

					_mod.Select #Vertex verts_by_colors_flat
				)
				else
					if classOf _mod == Editable_Poly then
						_mod.SetSelection #Vertex verts_by_colors_flat



			subObjectLevel = 1
		)
)


/**
  *
  */
macroscript	epoly_vertex_color_hide
category:	"_Epoly-Vertex-Color"
buttonText:	"HIDE By Color"
toolTip:	"Hide verts by vertex color of selected verts.White color is used, if nothing selected.\n\nCTRL: ISOLATE MODE (Show all verts of selected colors ).\n\nQUICK SCRIPT, TESTED ONLY ON EDITABLE POLY"
icon:	"across:4|MENU:buttonText"
(
	on execute do
	undo "Hide Colored Verts" on
	(
		--clearListener(); print("Cleared in:\n"+getSourceFileName())
		filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-VERTEX COLORS\VERTEX COLOR.mcr"

		if (colored_verts_num = polyop.getNumMapVerts obj.baseObject 0  ) > 0 then
		(
			verts_by_colors_flat = #{}

			vertex_sel	= getVertSelection obj.mesh

			verts_by_colors =  VertexColors.getVertsAndColors verts:vertex_sel

			for color_verts in verts_by_colors do verts_by_colors_flat += color_verts.value

			if keyboard.controlPressed then
			(
				/* ISOLATE ONLY VERTS OF GIVEN COLOR */
				polyop.unHideAllVerts obj

				polyop.setHiddenVerts obj  (#{1..(getNumVerts obj.mesh)} - verts_by_colors_flat)
			)
			else /* ONLY HIDE VERTS OF GIVEN COLOR */
				polyop.setHiddenVerts obj verts_by_colors_flat

			subObjectLevel = 1
		)
		else
			messageBox ("There is not any vertex color on object:\n\n"+obj.name) title:"NO VERTEX COLOR"
	)
)


/**
  *
  */
macroscript	epoly_vertex_color_reset
category:	"_Epoly-Vertex-Color"
buttonText:	"RESET Color"
toolTip:	"Hide verts by vertex color of selected verts.White color is used, if nothing selected.\n\nCTRL: ISOLATE MODE (Show all verts of selected colors ).\n\nQUICK SCRIPT, TESTED ONLY ON EDITABLE POLY"
icon:	"across:4|MENU:true"
(
	on execute do
	undo "Reset Vertex Color" on
	(
		--clearListener(); print("Cleared in:\n"+getSourceFileName())
		filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-VERTEX COLORS\VERTEX COLOR.mcr"


		obj = selection[1]

		--if getNumCPVVerts obj.mesh > 0 then
		if polyop.getNumMapVerts obj.baseObject 0 > 0 then
		(
			--vertex_sel = getVertSelection obj.mesh

			verts = passVertexSelectionToEditablePoly()

			if verts.isEmpty then
				verts = #ALL


			--/* GET SELECTED OR ALL VERTS */
			--verts = if vertex_sel.isEmpty then
			--(
			--	all_verts =  #{1..(getNumVerts obj.mesh)}
			--	white_verts = meshop.getVertsByColor obj.mesh white 0.001 0.001 0.001
			--
			--	all_verts - white_verts
			--)
			--else
			--	vertex_sel


			polyop.setVertColor  obj.baseobject 0 verts white

			--print ("VERTEX COLOR OF "+ (if vertex_sel.isEmpty then "ALL"else "SELECTED") +" SET TO WHITE")

		)
		else
			messageBox ("There is not any vertex color on object:\n\n"+obj.name) title:"NO VERTEX COLOR"
	)
)

/**
  *
  */
macroscript	epoly_vertex_color_property_toggle
category:	"_Epoly-Vertex-Color"
buttonText:	"SHOW-Colors"
toolTip:	"Toggle show\hide"
icon:	"across:4|MENU:true"
(
	on execute do
	undo "Show Vertex Colors" on
	(
		--clearListener(); print("Cleared in:\n"+getSourceFileName())
		--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-VERTEX COLORS\VERTEX COLOR.mcr"

		if selection.count > 0 then
		(
			$.showVertexColors = not selection[1].showVertexColors
			$.vertexColorsShaded = on
			$.vertexColorType = 0
		)
	)
)
