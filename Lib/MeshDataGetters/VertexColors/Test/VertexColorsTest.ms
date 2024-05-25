clearListener(); print("Cleared in:\n"+getSourceFileName())

filein( getFilenamePath(getSourceFileName()) + "/../VertexColors.ms" )	--"./../VertexColors.ms"

/**
  */
function createSourceMesh segments:8 add_modifiers:false =
(
	format "\n"; print "MeshVertexGetterTest.ms.createSourceMesh()"
	delete objects

	--if  obj == unsupplied then
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


	if add_modifiers then
	(
		addModifier obj meshsmooth

		addModifier obj Edit_Poly
	)


	obj --return
)

/** Select verts
 */
function selectVerts obj verts =
(
	--format "\n"; print ".selectVerts()"
	max modify mode

	subObjectLevel = 1

	if classOf (_mod = modPanel.getCurrentObject() ) == Edit_Poly then
	(
		_mod.SetSelection #Vertex #{}

		_mod.Select #Vertex verts
	)
	else
		if classOf _mod == Editable_Poly then
			_mod.SetSelection #Vertex verts

	verts --return
)


/*--------------------------------------------------------------------
	CREATE TEST OBJECTS
--------------------------------------------------------------------------------*/

obj = if selection.count == 0 then
(
	--createSourceMesh()
	createSourceMesh segments:16
	--createSourceMesh segments:16 add_modifiers:true
	--createSourceMesh segments:64
	--createSourceMesh segments:128
	--createSourceMesh segments:1024

	--createSourceMesh segments:64 vertex_selection:#{1..32} vertex_color:red
	--createSourceMesh segments:8 vertex_selection:#{1..8} vertex_color:red
)
else
	selection[1]


/*--------------------------------------------------------------------
	SET RANDOM VERTEX SELECTION, IF NOT SET BU USER
--------------------------------------------------------------------------------*/

vertex_count	= getNumVerts obj.mesh
vertex_sel	= getVertSelection obj.mesh

verts_first = random 1 vertex_count
verts_last  = random (verts_first+1) vertex_count

format "vertex_sel.numberSet: %\n" vertex_sel.numberSet
if vertex_sel.numberSet == 0 then
	vertex_sel	= selectVerts obj #{verts_first..verts_last}


/*==============================================================================
		RUN TESTS
================================================================================*/

/* SET NEW CLASS INSTANCE */
VertexColors = VertexColors_v(obj)


/* GET ALL VERTS SORTED BY COLORS */
all_verts_by_colors = VertexColors.getVertsAndColors()
--for color_data in all_verts_by_colors do format "COLOR: %	VERTS: %\n" color_data.key color_data.value

--/* GET ALL VERTS SORTED BY COLORS OF SELECTED VERTS */
verts_by_selected_colors = VertexColors.getVertsAndColors verts:vertex_sel
--for color_data in verts_by_selected_colors do format "COLOR: %	VERTS: %\n" color_data.key color_data.value


/* GET VERTS WITH SAME COLORS */
verts_of_same_colors = VertexColors.getVertsWithSameColors (vertex_sel)
--selectVerts (obj) (verts_of_same_colors)



