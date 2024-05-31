

/** Mesh vert to color vertex convertor
 */
struct MeshVertToColorVertexConvertor_v
(
	/* construct */
	obj,

	get_single_vert = false,

	/* properties */
	--faces_of_vert_cache   	= Dictionary (#integer),
	map_verts_of_face_cache = Dictionary (#integer),
	mesh_verts_of_face_cache = Dictionary (#integer),

	/* dependency */
	/* reference */
	/* inhered */

	/** Get Color per vertex indexes of verts by geo vert
	  *
	  * @param boolean flat if true then ARRAY is returned not 2D MATRIX - handy if getting sinlge vertex
	  *
	  * @return array|2Dmatrix
	 */
	function meshVertsToMapVerts verts flat:false =
	(
		format "\n"; print "MeshVertToColorVertexConvertor_v.meshVertsToMapVerts()"
		/** Get map vert from face
		 */
		function getMapVertFromFace vert face_id =
		(
			--format "\n"; print "MeshVertToColorVertexConvertor_v.getMapVertFromFace()"
			mesh_verts	= if (mesh_verts_cache = mesh_verts_of_face_cache[face_id]) == undefined then
					getFace obj.mesh face_id
				else
					mesh_verts_cache

			map_verts_arr	= if (map_verts_cache = map_verts_of_face_cache[face_id]) == undefined then
			(
				map_verts	= getVCFace	obj.mesh	face_id

				#( mesh_verts.x, mesh_verts.y, mesh_verts.z )
			)
			else
				map_verts_cache

			vert_index	= findItem map_verts_arr vert

			map_verts[vert_index] as integer --return
		)

		/** Flattern array
		 */
		function flatternArray matrix =
		(
			--format "\n"; print "MeshVertToColorVertexConvertor_v.flatternArray()"
			array_flat = #()

			for arr in matrix do
				join array_flat arr

			array_flat --return flattern matrix
		)


		if classOf verts == integer then
			verts = #( verts )

		else if classOf verts == BitArray then
			verts = verts as Array

		CPV_verts_all = deepCopy verts

		/*------ FLATTERN RESULT ARRAY ------*/
		for i = 1 to verts.count do
		(
			vert = verts[i]

			faces =  ( meshop.getFacesUsingVert obj.mesh vert ) as Array

			if not get_single_vert then
				CPV_verts_all[i] = for face_id in faces collect getMapVertFromFace(vert)(face_id)

			else
				CPV_verts_all[i] = getMapVertFromFace(vert)(faces[1])
		)

		/*------ LOOP VERTS ------*/
		if flat and not get_single_vert then
			flatternArray(CPV_verts_all) --return
		else
			CPV_verts_all --return
	),


	/** Map verts to mesh verts
	 */
	function mapVertsToMeshVerts map_verts =
	(
		--format "\n"; print "MeshVertToColorVertexConvertor_v.mapVertsToMeshVerts()"

		if classOf map_verts == Array then map_verts = map_verts as BitArray

		local mesh_verts = #{}

		v = 1

		while mesh_verts.numberSet < map_verts.numberSet do
		(
			map_verts_of_vert = (this.meshVertsToMapVerts(v) flat:true) as BitArray

			intersection = map_verts * map_verts_of_vert -- test if arrays contains same indexes

			if not intersection.isEmpty then
				mesh_verts[v] = true

			v += 1
		)

		gc()	--Garbage Collection.

		mesh_verts --return
	),


	private

	/**
	 */
	on create do
	(
		--format "\n"; print "MeshVertToColorVertexConvertor.onCreate()"
		--for prop in #(  ) where getProperty this prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of this struct properties necessary to run
		--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof this as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )
	)

)
