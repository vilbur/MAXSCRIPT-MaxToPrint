clearListener(); print("Cleared in:\n"+getSourceFileName())

filein( getFilenamePath(getSourceFileName()) + "/../VertexColors.ms" )	--"./../VertexColors.ms"


/**
  */
function createSourceMesh obj: segments:8 vertex_selection:#{} vertex_color: =
(
	format "\n"; print "MeshVertexGetterTest.ms.createSourceMesh()"
	delete objects

	if  obj == unsupplied then
		obj = Sphere radius:15 pos:[0,0, 50 ] segments:segments isSelected:on --showVertexColors:true	vertexColorsShaded:true -- diameter 3 cm

	macros.run "Modifier Stack" "Convert_to_Poly"

	vertex_count = getNumVerts obj.mesh

	--all_verts = #{1..(vertex_count)}

	--Rotate obj ( AngleAxis 180 [1,0,0]) -- rotate object upside down

	/* VERTEX COLORS */
	obj.showVertexColors	= true
	obj.vertexColorsShaded	= true

	colors = #( white, red, green, blue )

	vertex_count_step = (vertex_count / (colors.count +1) ) as integer

	format "vertex_count: %\n" vertex_count
	format "vertex_count_step: %\n" vertex_count_step

	counter = 1

	for i = 1 to colors.count do
		polyop.setVertColor obj 0 #{ (i * vertex_count_step )..(vertex_count)} colors[i]

	obj --return
)



/*--------------------------------------------------------------------
	PREPARE TEST OBJECTS
--------------------------------------------------------------------------------*/

obj = if selection.count == 0 then
(
	--createSourceMesh()
	createSourceMesh segments:16
	--createSourceMesh segments:64
	--createSourceMesh segments:128
	--createSourceMesh segments:1024

	--createSourceMesh segments:64 vertex_selection:#{1..32} vertex_color:red
	--createSourceMesh segments:8 vertex_selection:#{1..8} vertex_color:red
)
else
	selection[1]

/* set random vertex selection */
subObjectLevel = 1

vertex_count = getNumVerts obj.mesh

verts_first = random 1 vertex_count
verts_last  = random (verts_first+1) vertex_count

obj.EditablePoly.SetSelection #Vertex #{verts_first..verts_last}



/*==============================================================================
		RUN TESTS
================================================================================*/

/* SET NEW CLASS INSTANCE */
VertexColors = VertexColors_v(obj)


/* GET ALL COLORS */
all_verts_by_colors = VertexColors.getAllColors()
--for color_data in all_verts_by_colors do format "color_data: %\n" color_data


/* GET COLORS OF SELECTED VERTS */

colors_of_selected_verts = VertexColors.getColorsOfSelectedVerts()
--format "colors_of_selected_verts: %\n" colors_of_selected_verts


/* SELECTED ALL VERTS OF COLORS */
verts_by_colors = #{}

for clr in colors_of_selected_verts do verts_by_colors += all_verts_by_colors[clr as string ]

obj.EditablePoly.SetSelection #Vertex verts_by_colors








