clearListener(); print("Cleared in:\n"+getSourceFileName())




/*------------------------------------------------------------------------------
	PREPARE SCENE
--------------------------------------------------------------------------------*/

delete objects

--segments = 10
segments = 100
--segments = 200
--segments = 300

obj	= Plane width:100 length:100 pos:[ 0, 0, 0 ]  widthsegs:segments lengthsegs:segments
Plane_2	= Plane width:100 length:100 pos:[ 0, 0, 10 ] widthsegs:segments lengthsegs:segments

select objects

macros.run "Modifier Stack" "Convert_to_Poly"

obj.EditablePoly.attach Plane_2 obj


/*------------------------------------------------------------------------------
	MERGE
--------------------------------------------------------------------------------*/
test = timeStamp()

islands = #()

vertex_count = getNumVerts obj.mesh

format "vertex_count: %\n" vertex_count

all_verts = #{1..(vertex_count)}


/*------ SPLIT TO ISLANDS ------*/

verts = all_verts - #{23..44, 144..165}

format "verts: %\n" verts
faces_of_verts = polyop.getFacesUsingVert obj verts


format "faces_of_verts: %\n" faces_of_verts


--_append = 0
--_join   = 0
--_merge = 0

for face in faces_of_verts do
(
	face_verts = polyop.getVertsUsingFace obj face

	intesections = for i = 1 to islands.count where not (islands[i] * face_verts).isEmpty collect i

	--islands_merged = #()

	--if intesections.count > 0 then
	--	for i = intesections.count to 1 by -1 do
	--	(
	--		face_verts += islands[intesections[i]]
	--
	--		deleteItem islands intesections[i]
	--	)
	--
	--append islands face_verts

	--if intesections.count > 1 then
	--(
	--	_merge += 1
	--
	--	for i = intesections.count to 2 by -1 do
	--	(
	--		islands[intesections[1]] += face_verts
	--
	--		deleteItem islands intesections[i]
	--	)
	--)
	--else if intesections.count == 1 then
	--(
	--	_join += 1
	--
	--	islands[intesections[1]] += face_verts
	--)
	--else
	--(
	--	_append += 1
	--	append islands face_verts
	--)



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

	--format "islands: %\n" islands

)

format "\n test: % ms\n" (( timeStamp()) - test)

--
--format "_append: %\n" _append
--format "_join: %\n" _join
--format "_merge: %\n" _merge

format "RESULT: %\n" islands





gc light:true



























