
/**
  *
  */
macroscript	epoly_vertex_color_select_by_selection
category:	"_Epoly-Vertex-Color"
buttonText:	"SELECT Color"
toolTip:	""
--icon:	"MENU:&Select Color"
(
	on isVisible return subObjectLevel != undefined and subObjectLevel != 0

	on execute do if ( obj = selection[1] ) != undefined then
	undo "Hide Verts By Selection" on
	(
		--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-VERTEX COLORS\MANAGE VERTEX COLORS.mcr"

		VertexColorProcessor = VertexColorProcessor_v(obj)

		/* SELECT BY SELECTION */
		if (vertex_sel = getVertSelection obj.mesh).numberSet > 0 then
			VertexColorProcessor.byVerts #SELECT vertex_sel

		/* SELECT BY COLOR */
		else
			VertexColorProcessor.byColor #SELECT VERTEX_COLOR_PARAM

	)
)


/**
  *
  */
macroscript	epoly_vertex_color_select_submenu
category:	"_Epoly-Vertex-Color"
buttonText:	"SELECT Color"
toolTip:	""
icon:	"MENU:&SELECT Color"
(
	on isVisible return subObjectLevel != undefined and subObjectLevel != 0

	on execute do
		openVertexColorSubmenu #SELECT
)



/*------------------------------------------------------------------------------
	HIDE BY COLOR
--------------------------------------------------------------------------------*/
/**
  *
  */
macroscript	epoly_vertex_color_hide_by_selection
category:	"_Epoly-Vertex-Color"
buttonText:	"HIDE Color"
toolTip:	""
--icon:	"MENU:&Hide Color"
(
	on isVisible return subObjectLevel != undefined and subObjectLevel != 0

	on execute do if ( obj = selection[1] ) != undefined then
	undo "Hide Verts By Selection" on
	(
		--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-VERTEX COLORS\MANAGE VERTEX COLORS.mcr"

		VertexColorProcessor = VertexColorProcessor_v(obj)

		/* HIDE BY SELECTION */
		if (vertex_sel = getVertSelection obj.mesh).numberSet > 0 then
			VertexColorProcessor.byVerts #HIDE vertex_sel

		/* HIDE BY COLOR */
		else
			VertexColorProcessor.byColor #HIDE VERTEX_COLOR_PARAM

	)
)


/**
  *
  */
macroscript	epoly_vertex_color_hide_submenu
category:	"_Epoly-Vertex-Color"
buttonText:	"HIDE Color"
toolTip:	""
icon:	"MENU:&HIDE Color"
(
	on isVisible return subObjectLevel != undefined and subObjectLevel != 0

	on execute do
		openVertexColorSubmenu #HIDE
)


/*------------------------------------------------------------------------------
	HIDE BY COLOR
--------------------------------------------------------------------------------*/
/**
  *
  */
macroscript	epoly_vertex_color_unhide_by_selection
category:	"_Epoly-Vertex-Color"
buttonText:	"UNHIDE Color"
toolTip:	""
--icon:	"MENU:&UNHIDE Color"
(
	on isVisible return subObjectLevel != undefined and subObjectLevel != 0


	on execute do if ( obj = selection[1] ) != undefined then
	undo "Hide Verts By Selection" on
	(
		--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-VERTEX COLORS\MANAGE VERTEX COLORS.mcr"

		VertexColorProcessor = VertexColorProcessor_v(obj)

		if (vertex_sel = getVertSelection obj.mesh).numberSet > 0 then
			VertexColorProcessor.byVerts #UNHIDE vertex_sel
	)
)


/**
  *
  */
macroscript	epoly_vertex_color_unhide_submenu
category:	"_Epoly-Vertex-Color"
buttonText:	"UNHIDE Color"
toolTip:	""
icon:	"MENU:&UNHIDE Color"
(
	on isVisible return subObjectLevel != undefined and subObjectLevel != 0

	on execute do
		openVertexColorSubmenu #UNHIDE
)


/*------------------------------------------------------------------------------
	ISOLATE BY COLOR
--------------------------------------------------------------------------------*/

/**
  *
  */
macroscript	epoly_vertex_color_isolate_by_selection
category:	"_Epoly-Vertex-Color"
buttonText:	"ISOLATE Color"
toolTip:	"Hide verts by vertex color of selected verts.White color is used, if nothing selected.\n\nCTRL: ISOLATE MODE (Show all verts of selected colors ).\n\nQUICK SCRIPT, TESTED ONLY ON EDITABLE POLY"
icon:	"across:4"
(
	on execute do if ( obj = selection[1] ) != undefined then
	undo "Hide Colored Verts" on
	(
		--clearListener(); print("Cleared in:\n"+getSourceFileName())
		--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-VERTEX COLORS\MANAGE VERTEX COLORS.mcr"
		VertexColorProcessor = VertexColorProcessor_v(obj)

		vertex_sel	= getVertSelection obj.mesh

		VertexColorProcessor.byVerts #ISOLATE vertex_sel

	)
)



/**
  *
  */
macroscript	epoly_vertex_color_isolate_submenu
category:	"_Epoly-Vertex-Color"
buttonText:	"ISOLATE Color"
toolTip:	""
icon:	"MENU:&ISOLATE Color"
(
	on isVisible return subObjectLevel != undefined and subObjectLevel != 0

	on execute do
		openVertexColorSubmenu #ISOLATE
)


--/**
--  *
--  */
--macroscript	epoly_vertex_color_unhide_submenu
--category:	"_Epoly-Vertex-Color"
--buttonText:	"Menu"
--toolTip:	""
--icon:	"MENU:&Hide Color"
--(
--	on isVisible return subObjectLevel != undefined and subObjectLevel != 0
--
--	on execute do
--		openVertexColorSubmenu "color_unhide"
--)

--
--/**
--  *
--  */
--macroscript	epoly_vertex_color_reset
--category:	"_Epoly-Vertex-Color"
--buttonText:	"RESET Color"
--toolTip:	"Hide verts by vertex color of selected verts.White color is used, if nothing selected.\n\nCTRL: ISOLATE MODE (Show all verts of selected colors ).\n\nQUICK SCRIPT, TESTED ONLY ON EDITABLE POLY"
--icon:	"across:4|MENU:true"
--(
--	on execute do
--	undo "Reset Vertex Color" on
--	(
--		--clearListener(); print("Cleared in:\n"+getSourceFileName())
--		filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-VERTEX COLORS\VERTEX COLOR.mcr"
--
--
--		obj = selection[1]
--
--		--if getNumCPVVerts obj.mesh > 0 then
--		if polyop.getNumMapVerts obj.baseObject 0 > 0 then
--		(
--			--vertex_sel = getVertSelection obj.mesh
--
--			verts = passVertexSelectionToEditablePoly()
--
--			if verts.isEmpty then
--				verts = #ALL
--
--
--			--/* GET SELECTED OR ALL VERTS */
--			--verts = if vertex_sel.isEmpty then
--			--(
--			--	all_verts =  #{1..(getNumVerts obj.mesh)}
--			--	white_verts = meshop.getVertsByColor obj.mesh white 0.001 0.001 0.001
--			--
--			--	all_verts - white_verts
--			--)
--			--else
--			--	vertex_sel
--
--
--			polyop.setVertColor  obj.baseobject 0 verts white
--
--			--print ("VERTEX COLOR OF "+ (if vertex_sel.isEmpty then "ALL"else "SELECTED") +" SET TO WHITE")
--
--		)
--		else
--			messageBox ("There is not any vertex color on object:\n\n"+obj.name) title:"NO VERTEX COLOR"
--	)
--)

/**
  *
  */
macroscript	epoly_vertex_color_property_toggle
category:	"_Epoly-Vertex-Color"
buttonText:	"SHOW-Colors"
toolTip:	"Toggle show\hide"
icon:	"across:4|MENU:true"
(
	on isVisible return subObjectLevel != undefined and subObjectLevel != 0

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

/**
  *
  */
macroscript	epoly_vertex_color_channel_info
category:	"_Epoly-Vertex-Color"
buttonText:	"Channel Info"
toolTip:	"Open or Update Channel Info Dialog"
--icon:	"across:4|MENU:true"
(
	on isVisible return subObjectLevel != undefined and subObjectLevel != 0

	on execute do
	(
		channelInfo.Dialog ()

		channelInfo.Update ()

	)
)
/**
  *
  */
macroscript	epoly_vertex_color_list_vertex_colors
category:	"_Epoly-Vertex-Color"
buttonText:	"List Colors"
toolTip:	"List Vertex Colors"
--icon:	"across:4|MENU:true"
(
	on isVisible return subObjectLevel != undefined and subObjectLevel != 0

	on execute do
	(
		obj	= selection[1]
		/* SET NEW CLASS INSTANCE */
		VertexColors = VertexColors_v(obj)


		/* GET ALL VERTS SORTED BY COLORS */
		colors = VertexColors.getVertsAndColors()

		for colors_data in colors do format "\n********\n\nCOLOR: %\nVERTS: %\nCOUNT: %\n" colors_data.key colors_data.value colors_data.value.numberSet

	)
)


/**
  *
  */
macroscript	epoly_vertex_color_reset_vertex_colors
category:	"_Epoly-Vertex-Color"
buttonText:	"Reset Colors"
toolTip:	"Reset Vertex Colors"
--icon:	"across:4|MENU:true"
(
	on isVisible return subObjectLevel != undefined and subObjectLevel != 0

	on execute do
	if queryBox "Reest Vertex Colors ?" title:"RESET VERTEX COLORS" then

	(
		obj	= selection[1]
		/* SET NEW CLASS INSTANCE */
		VertexColorProcessor = VertexColorProcessor_v(obj)

		VertexColorProcessor.resetCPVVerts()
	)
)
