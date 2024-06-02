--filein( getFilenamePath(getSourceFileName()) + "/../rollout-VERTEX SELECTION/Lib/VertSelector/VertSelector.ms" )	--"./../rollout-VERTEX SELECTION/Lib/VertSelector/VertSelector.ms"
filein( getFilenamePath(getSourceFileName()) + "/../../../../MAXSCRIPT-UI-framework/Lib/Menus/RcMenu/RcMenu.ms" )	--"./../../../../MAXSCRIPT-UI-framework/Lib/Menus/RcMenu/RcMenu.ms"
--filein( getFilenamePath(getSourceFileName()) + "/Lib/VertexColorProcessor.ms" )	--"./Lib/VertexColorProcessor.ms"


global VERTEX_COLOR_PARAM

global COLOR_BLUE = ( color 0 135 255 )

/** Call vertex color submenu
  *
  * 1) Macro	-> Open Submenu openVertexColorSubmenu()	-- Choose used method
  *     2) Submenu Item	-> Call Function callMethodByVertexColor()	-- Choose color used for method
  *         3) Function	-> Call Desired Vertex Color Method	-- Run used method with choosed color ( Set color|Select By Color|Hide by Color|... )
  *
 */
function openVertexColorSubmenu method =
(
	format "\n"; print "openVertexColorSubmenu()"
	--format "method: %\n" method


	/* FIRST ITEM */
	item_title = case method of
	(
		--#SET:	"Set &Color"
		#SELECT:	"&Select By Selection"
		#HIDE:	"&Hide By Selection"
		#UNHIDE:	"&Unide By Selection"
		#ISOLATE:	"&Isolate By Selection"

	)


	category = "_Epoly-Vertex-Color"

	macro_name = "epoly_vertex_color_" + method as string  + (if method == #SET then "_by_last_color" else "_by_selection")

	/* ITEMS BY COLOR */
	call_fn = "callMethodByVertexColor #"+ method as string + " "


	/* DEFINE MAIN MENU */
	Menu = RcMenu_v name:"TestMenu"


	if method != #SET then
		Menu.item item_title	( "macros.run" + "\"" + category + "\"" + "\"" + macro_name + "\""	) -- macros.run "_Epoly-Vertex-Color" "color_set_by_selection"

	Menu.item "&RED"	( call_fn + "red"	)
	Menu.item "&GREEN"	( call_fn + "green"	)
	Menu.item "&BLUE"	( call_fn + " " + COLOR_BLUE as string	)
	Menu.item "&ORANGE"	( call_fn + "orange"	)
	Menu.item "&WHITE"	( call_fn + "white"	)


	popUpMenu (Menu.create())

)


/** Call vertex color macro
 */
function callMethodByVertexColor method _color =
(
	format "\n"; print "callMethodByVertexColor()"
	format "method: %\n" method
	format "VERTEX_COLOR_PARAM: %\n" VERTEX_COLOR_PARAM

	obj = selection[1]

	VERTEX_COLOR_PARAM = _color

	VertexColorProcessor = VertexColorProcessor_v(obj)

	vertex_sel	= getVertSelection obj.mesh


	if method == #SET then
		VertexColorProcessor.setVertexColor vertex_sel VERTEX_COLOR_PARAM

	else
		VertexColorProcessor.byColor method VERTEX_COLOR_PARAM


	--messageBox (param as string ) title:method
)


/*==============================================================================
	Color Set
================================================================================*/

/**
  *
  */
macroscript	epoly_vertex_color_set_by_last_color
category:	"_Epoly-Vertex-Color"
buttonText:	"SET"
toolTip:	"Set vertex color to selected vertex.\n\nVertex can be selected in modifiers like:\nEdit Poly|Poly Select\n\nLMB: Green\nCTRL:#RED"
icon:	"across:6|width:56|MENU:&Color Set|tooltip:\n\n----------------------\n\nFIX IF NOT WORK PROPERLY:\\n1) Try clean mesh, weld verts and close borders"
(
	on isVisible return subObjectLevel != 0

	on execute do if ( obj = selection[1] ) != undefined then
	undo "Set Vertex Color" on
	(
		--clearListener(); print("Cleared in:\n"+getSourceFileName())
		--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-VERTEX COLORS\1-VERTEX COLOR.mcr"

		if (vertex_sel = getVertSelection obj.mesh).numberSet > 0 then
		(
			VertexColorProcessor = VertexColorProcessor_v(obj)

			if VERTEX_COLOR_PARAM != undefined then
				(VertexColorProcessor_v(obj)).setVertexColor (vertex_sel) (VERTEX_COLOR_PARAM)
			else
				openVertexColorSubmenu #SET
		)


	)
)


--/**
--  *
--  */
--macroscript	epoly_vertex_color_set_submenu
--category:	"_Epoly-Vertex-Color"
--buttonText:	"Color Set"
--toolTip:	""
--icon:	"MENU:&Color Set"
--(
--	on isVisible return subObjectLevel != 0
--
--	on execute do
--		openVertexColorSubmenu #SET
--)

/**
  *
  */
macroscript	epoly_vertex_color_set_red
category:	"_Epoly-Vertex-Color"
buttonText:	"RED"
toolTip:	""
icon:	"MENU:Set &RED"
(
	on isVisible return subObjectLevel != 0

	on execute do
		callMethodByVertexColor #SET red
)

/**
  *
  */
macroscript	epoly_vertex_color_set_green
category:	"_Epoly-Vertex-Color"
buttonText:	"GREEN"
toolTip:	""
icon:	"MENU:Set &GREEN"
(
	on isVisible return subObjectLevel != 0

	on execute do
		callMethodByVertexColor #SET green
)

/**
  *
  */
macroscript	epoly_vertex_color_set_blue
category:	"_Epoly-Vertex-Color"
buttonText:	"BLUE"
toolTip:	""
icon:	"MENU:Set &BLUE"
(
	on isVisible return subObjectLevel != 0

	on execute do
		callMethodByVertexColor #SET COLOR_BLUE
)

/**
  *
  */
macroscript	epoly_vertex_color_set_orange
category:	"_Epoly-Vertex-Color"
buttonText:	"ORANGE"
toolTip:	""
icon:	"MENU:Set &ORANGE"
(
	on isVisible return subObjectLevel != 0

	on execute do
		callMethodByVertexColor #SET orange
)
/**
  *
  */
macroscript	epoly_vertex_color_set_white
category:	"_Epoly-Vertex-Color"
buttonText:	"WHITE"
toolTip:	""
icon:	"MENU:Set &WHITE"
(
	on isVisible return subObjectLevel != 0

	on execute do
		callMethodByVertexColor #SET white
)
