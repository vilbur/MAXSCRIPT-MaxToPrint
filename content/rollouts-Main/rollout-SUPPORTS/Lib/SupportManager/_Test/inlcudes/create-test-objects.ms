
/** Get pos
  *
  */
function getUnit val  =
(
	--format "\n"; print "SupportManagerTest.ms.getUnit()"
	display_units = case units.SystemType of
	(
	   #Centimeters:	10.0
	   #Meters:	1000.0
	   default:	1.0
	)

	val / display_units / EXPORT_SIZE --return
)

/** Select verts
 */
function selectVertsForTest obj vert_sel =
(
	--format "\n"; print ".selectVertsForTest()"
	select obj

	max modify mode

	subObjectLevel = 1

	obj.modifiers[#Edit_Poly].SetSelection #Vertex #{}
	obj.modifiers[#Edit_Poly].Select #Vertex vert_sel

)

/**
  */
function createSourceMesh segments:1 vertex_selection:#{} test_shifted_pivot:false obj:#PLANE vertex_color: =
(
	format "\n"; print "SupportManagerTest.ms.createSourceMesh()"
	delete objects

	segment_size = getUnit(10)

	_obj = case obj of
	(
		#SPHERE:	Sphere radius:(getUnit(50)) pos:[0,0, getUnit(100) ] segments:segments -- diameter 3 cm
		#BOX:	Box  pos:[0,0, getUnit(200) ]  lengthsegs:segments widthsegs:segments heightsegs:segments

		DEFAULT:	Plane length:( segment_size * segments ) width:( segment_size * segments ) pos:[ 0, 0, getUnit(200) ] widthsegs:segments lengthsegs:segments backfacecull: off
	)


	 _obj.showVertexColors	= true
	 _obj.vertexColorsShaded	= true


	select _obj

	macros.run "Modifier Stack" "Convert_to_Poly"


	if test_shifted_pivot then
		$.pos.x = $.pos.y = $.pivot.x = $.pivot.y = 100

	Rotate _obj ( AngleAxis 180 [1,0,0]) -- rotate object upside down

	--modPanel.addModToSelection ( meshsmooth ()) ui:on

	if vertex_selection.count > 0 then
	(
		subObjectLevel = 1

		if vertex_color != unsupplied then
			polyop.setVertColor _obj 0 vertex_selection vertex_color

		_obj.EditablePoly.SetSelection #Vertex vertex_selection
	)

	modPanel.addModToSelection (Edit_Poly ()) ui:on
)


/** Create test line
  *
  */
function createSourceSpline =
(
	--format "\n"; print "SupportManagerTest.ms.createSourceSpline()"
	delete objects

	_Circle = Circle radius:( getUnit(30.0) ) pos:[0,0, getUnit(30.0) ] isSelected:on -- diameter 3 cm

	normalize_mod = Normalize_Spline2 NormalizeType:1 numKnots: 10

	modPanel.addModToSelection (normalize_mod) ui:on

	_Circle_child = copy _Circle

	_Circle_child.parent = _Circle

	_Circle_child.pos.z -=  getUnit(10)
	_Circle_child.radius += getUnit(10)

	select _Circle
)

--/** Create test line
--  *
--  */
--function createSourcePoints =
--(
--	--format "\n"; print "SupportManagerTest.ms.createSourceSpline()"
--	delete objects
--
--	point_A = Point pos:[ 0, 0, getUnit(30) ]	name:"point_A" wirecolor:blue
--
--	point_B	= Point pos:[ getUnit(30), 0, getUnit(30) ]	name:"point_B"
--	point_B_child1	= Point pos:[ getUnit(30), getUnit(10), getUnit(15) ] 	name:"point_B_child1"
--	point_B_child2	= Point pos:[ getUnit(20), getUnit(10), getUnit(10) ] 	name:"point_B_child2"
--
--	point_B_child1.parent = point_B
--	point_B_child2.parent = point_B_child1
--
--	select $point_A
--	selectmore $point_B
--)