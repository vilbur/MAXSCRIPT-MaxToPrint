clearListener(); print("Cleared in:\n"+getSourceFileName())


filein( getFilenamePath(getSourceFileName()) + "/../ShapeKnotGetter.ms" )	--"./../ShapeKnotGetter.ms"

/**
  */
function createSourceMesh segments:8 vertex_selection:#{} test_shifted_pivot:false obj:#PLANE vertex_color: =
(
	format "\n"; print "MeshVertexGetterTest.ms.createSourceMesh()"
	delete objects

	segment_size = 10

	--_obj = Plane length:( segment_size * segments ) width:( segment_size * segments ) pos:[ 0, 0, 300 ] widthsegs:segments lengthsegs:segments backfacecull: off
	_obj = Sphere radius:15 pos:[0,0, 50 ] segments:segments showVertexColors:true	vertexColorsShaded:true -- diameter 3 cm

	select _obj

	Rotate _obj ( AngleAxis 180 [1,0,0]) -- rotate object upside down

	macros.run "Modifier Stack" "Convert_to_Poly"

	if vertex_selection.count > 0 then
	(
		subObjectLevel = 1

		if vertex_color != unsupplied then
			polyop.setVertColor _obj 0 vertex_selection vertex_color


		polyop.setVertColor _obj 0 vertex_selection.count red -- color last vertex in red color

		--_obj.EditablePoly.SetSelection #Vertex vertex_selection
	)

	modPanel.addModToSelection (Edit_Poly ()) ui:on
)



/*--------------------------------------------------------------------
	PREPARE TEST OBJECTS
--------------------------------------------------------------------------------*/
--createSourceMesh()
 createSourceMesh vertex_selection:#{2..3} vertex_color:green
 -- createSourceMesh vertex_selection:#{1..100}  vertex_color:orange segments:64


/* SELECT SOURCE OBJECTS - IMPORTANT  */
select objects[1]
--source_objects = for obj in selection collect obj


/*------------------------------------------------------------------------------
	SET INSTANCE
--------------------------------------------------------------------------------*/

ShapeKnotGetter 	= ShapeKnotGetter_v(selection[1])


/*------------------------------------------------------------------------------
	RUN TESTS
--------------------------------------------------------------------------------*/
all_colored_verts = ShapeKnotGetter.getVetexData quiet:true



/*------------------------------------------------------------------------------
	PRINT RESULT
--------------------------------------------------------------------------------*/
for vert_data in all_colored_verts do
	format "vert_data	= % \n" vert_data
