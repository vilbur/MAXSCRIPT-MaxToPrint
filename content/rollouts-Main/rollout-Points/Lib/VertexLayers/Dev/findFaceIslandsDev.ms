clearListener(); print("Cleared in:\n"+getSourceFileName())

/** Count which method is used more often - append, join or merge bitarrays
 */
function devMethodWithCounter faces_of_verts =
(
	--format "\n"; print ".devMethodWithCounter()"
	_append = 0
	_join   = 0
	_merge = 0

	for face in faces_of_verts do
	(
		face_verts = polyop.getVertsUsingFace obj face

		intesections = for i = 1 to islands.count where not (islands[i] * face_verts).isEmpty collect i

		if intesections.count > 1 then
		(
			_merge += 1

			for i = intesections.count to 2 by -1 do
			(
				islands[intesections[1]] += face_verts

				deleteItem islands intesections[i]
			)
		)
		else if intesections.count == 1 then
		(
			_join += 1

			islands[intesections[1]] += face_verts
		)
		else
		(
			_append += 1
			append islands face_verts
		)

	)
	format "_append: %\n" _append
	format "_join: %\n" _join
	format "_merge: %\n" _merge
)

/** Case method
 */
function faceVertsMethod faces_of_verts =
(
	--format "\n"; print ".faceVertsMethod()"
	face_verts = polyop.getVertsUsingFace obj face

	intesections = for i = 1 to islands.count where not (islands[i] * face_verts).isEmpty collect i


	case intesections.count of
	(
		/* JOIN TO EXISTING BITARRAY */
		(1):	islands[intesections[1]] += face_verts

		/* ADD NEW BITARRAY */
		(0): append islands face_verts

		/* MERGE MULTIPLE BITARRAYS */
		default:
			for i = intesections.count to 2 by -1 do
			(
				islands[intesections[1]] += face_verts

				deleteItem islands intesections[i]
			)
	)
)

/** Detach method
 */
function detachMethod obj faces_of_verts =
(
	--format "\n"; print ".detachMethod()"

	obj_snap = snapshot obj

	convertTo obj_snap PolyMeshObject

	polyop.detachFaces obj_snap faces_of_verts delete:true

	local poGetElementsUsingFace = polyop.getElementsUsingFace

	elements = #()

	while not faces_of_verts.isEmpty do
																									(
		face = (faces_of_verts as array)[1]

		element = poGetElementsUsingFace obj_snap #(face)

		append elements element

		faces_of_verts -= element
	)

	delete obj_snap

	format "elements: %\n" elements
)


/*------------------------------------------------------------------------------
	PREPARE SCENE
--------------------------------------------------------------------------------*/

delete objects

segments = 10
--segments = 20
--segments = 100
--segments = 200
--segments = 300

obj	= Plane width:100 length:100 pos:[ 0, 0, 0 ]  widthsegs:segments lengthsegs:segments
Plane_2	= Plane width:100 length:100 pos:[ 0, 0, 50 ] widthsegs:segments lengthsegs:segments

select objects

macros.run "Modifier Stack" "Convert_to_Poly"

obj.EditablePoly.attach Plane_2 obj


/*------------------------------------------------------------------------------
	SET TEST DATA
--------------------------------------------------------------------------------*/

global islands = #()

vertex_count = getNumVerts obj.mesh
format "vertex_count: %\n" vertex_count

all_verts = #{1..(vertex_count)}

/*------ SPLIT TO ISLANDS ------*/

verts = all_verts - #{23..44, 144..165}
--format "verts: %\n" verts
faces_of_verts = polyop.getFacesUsingVert obj verts
--format "faces_of_verts: %\n" faces_of_verts


/*------------------------------------------------------------------------------

	RUN TESTT

--------------------------------------------------------------------------------*/



test = timeStamp()

/* DEV */
--devMethodWithCounter (faces_of_verts)

/* SLOW ON HIGH VERTEX COUNT */
--faceVertsMethod (faces_of_verts)

/* DETACH FACES AND GET LEMENTS COUNT */
detachMethod (obj) (faces_of_verts)

--format "faces_of_verts: %\n" faces_of_verts

format "\n test: % ms\n" (( timeStamp()) - test)

format "RESULT: %\n" islands



gc light:true
