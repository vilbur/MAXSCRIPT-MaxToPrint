/** Ver island finder

	1) Loop each layer
	2) Get verts in each layer
	3) Find how many mesh island exsits


	4) Test if new or old island - in old, then faces exist in all island

 */
struct VerIslandFinder_v
(
	/* construct */
	obj,

	/* required */

	/* properties */
	face_islands_in_layer	= #(), -- #( #{ faces_ids } ) array of faces_definded_by_verts of faces sorted by island the occupy
	verts_islands	= #(), -- #( #{ veret_ids } ) array of faces_definded_by_verts of verts sorted by island the occupy

	face_islands = #(),

	new_islands = #(),

	verts_processed = #{}, -- store verts in current layer and layers bellow

	/* private */
	/* dependency */
	/* reference */
	/* inhered */


	/** Analyze layers
	 */
	function analyzeLayers verts_used verts_layers =
	(
		--format "\n"; print "SupportVertexFinder_v._analyzeLayers()"
		--format "verts_layers: %\n" verts_layers
		fn isVertInLayerInIsland verts_in_layer verts_island = not ( verts_in_layer * verts_island ).isEmpty

		/** Is same bit array
		 */
		function isSameBitArray bitarray_1 bitarray_2 =
		(
			--format "\n"; print "VerIslandFinder_v.isSameBitArray()"
			compare = bitarray_1 * bitarray_2

			bitarray_1.count == compare.count and bitarray_1.numberSet == compare.numberSet --return
		)

		vert_color = blue
		--format "VERTS_USED: %\n" verts_used

		for layer = 1 to verts_layers.count where classOf ( all_verts_in_layer = verts_layers[layer] ) == BitArray do -- layer has not verts if item is integer ( layer number )
		(

			--vert_color.hue = ( random 0 255 )
			format "\n==============\nlayer: %\n" layer
			format "all_verts_in_layer: %\n" all_verts_in_layer

			--format "new_islands: %\n" new_islands
			this.new_islands	= #()

			/* GET VERTS IN LAYER - only used for supports ( without concave verts, normal top, etc.. ) */
			verts_used_in_layer = all_verts_in_layer * verts_used
			format "verts_used_in_layer: %\n" verts_used_in_layer

			verts_processed += verts_used_in_layer
			format "verts_processed: %\n" verts_processed


			/* GET FACES IN LAYER */
			faces_in_layer = polyop.getFacesUsingVert obj all_verts_in_layer
			format "faces_in_layer: %\n" faces_in_layer

			/* GET ISALNDS OF VERTS IN LAYER */
			vert_islands_in_layer = this._sortVertsByIslands (faces_in_layer)
			format "vert_islands_in_layer: %\n" vert_islands_in_layer

			/* GET ISALNDS OF FACES IN LAYER */
			face_islands_in_layer = this._sortFacesByIslands(faces_in_layer as Array )(vert_islands_in_layer)
			format "face_islands_in_layer: %\n" face_islands_in_layer
			format "\n"


			/* MERGE FACE ISLAND OF LAYER TO ALL ISLANDS */

			for face_island in face_islands_in_layer do
			(

				for face in face_island do
				(

					verts_of_face = polyop.getVertsUsingFace obj face
					--format "verts_of_face: %\n" verts_of_face

					if not isSameBitArray (verts_of_face) (verts_of_face * verts_processed ) then
						face_island[face] = false
				)

				if face_island.numberSet > 0 then
					append face_islands face_island
			)

			format "face_islands: %\n" face_islands

			for face_island in face_islands do
			(
				verts_of_siland = polyop.getVertsUsingFace obj face_island

				append verts_islands verts_of_siland
			)

			verts_islands = this._mergeBitArraysbySharedBits( verts_islands )( verts_islands )

			format "verts_islands: %\n" verts_islands



			--islands_in_layer_used = for i = 1 to vert_islands_in_layer.count collect vert_islands_in_layer[i] * verts_used_in_layer

			--format "islands_in_layer_used: %\n" islands_in_layer_used


			--face_islands = this._mergeBitArraysbySharedBits( face_islands )( faces_in_layer )
			--format "face_islands: %\n" face_islands

			----format "new_islands: %\n" this.new_islands
			--
			----if face_islands.count != face_islands.count then
			--for new_island in islands_in_layer_used do
			--(
			--	--verts_for_vertex_color = id new_island.numberSet <= 4 then new_island else
			--
			--
			--	polyop.setVertColor obj.baseobject 0 ( new_island ) vert_color
			--)
			--
			--
			--face_islands = face_islands

			--format "face_islands: %\n" face_islands
			--format "face_islands: %\n" face_islands
			--if verts_islands.count > last_islands_count then
			--if this.new_islands then
				--for island in verts_islands where isVertInLayerInIsland verts_in_layer island do
			--for island in new_islands do
				--polyop.setVertColor obj.baseobject 0 island vert_color

		)
	),

	/** Sort faces by islands
	 */
	function _sortFacesByIslands faces_in_layer vert_islands_in_layer =
	(
		--format "\n"; print "VerIslandFinder_v._sortFacesByIslands()"
		--format "faces_in_layer: %\n" faces_in_layer

		face_islands_in_layer = for island in vert_islands_in_layer collect #{}

		faces_definded_by_verts = for face_id in faces_in_layer collect polyop.getVertsUsingFace obj #{face_id}
		format "faces_definded_by_verts: %\n" faces_definded_by_verts


		--for vert_island in vert_islands_in_layer do
		for i = 1 to vert_islands_in_layer.count do
		(
			vert_island = vert_islands_in_layer[i]


			for x = 1 to faces_definded_by_verts.count do
			--for verts_of_face in faces_definded_by_verts do
			(
				face_id = faces_in_layer[x]

				verts_of_face = faces_definded_by_verts[x]

				shared_verts = vert_island * verts_of_face
				--format "% shared_verts: %\n" faces_in_layer[x] shared_verts

				if not shared_verts.isEmpty then
					face_islands_in_layer[i][face_id] = true

			)
		)

		face_islands_in_layer --return`

	),


	/**
	  * @param BitArray verts which faces will be sorted by islands
	  *
	  * @return #( #{..} ) array of vertex ids, each array are verts of one island
	 */
	function _sortVertsByIslands face_ids_of_verts =
	(
		--format "\n"; print "VertSelector_v._sortVertsByIslands()"

		--face_ids_of_verts = ( polyop.getFacesUsingVert obj verts_in_layer ) as Array
		--format "face_ids_of_verts: %\n" face_ids_of_verts

		faces_definded_by_verts = for face_id in face_ids_of_verts collect polyop.getVertsUsingFace obj #{face_id} -- ( #{1..4}, #{2,4,5,6} ) -- faces definded by verts

		--format "faces_definded_by_verts: %\n" faces_definded_by_verts

		this._mergeBitArraysbySharedBits #() (faces_definded_by_verts)  --return vert_islands_in_layer
	),


	private


	/** Merge bit arrays wich shared bits
	  *
	  * @param #( #{} ) bitarrays Array of bittarays
	 */
	function _mergeBitArraysbySharedBits bitarrays_merged bitarrays =
	(
		--format "\n"; print ".mergeBitArraysWithSharedBits()"
		--format "bitarrays_merged: %\n" bitarrays_merged
		--format "bitarrays: %\n" bitarrays

		/** Merge bit arrays in bit array
		 */
		function mergeBitArraysInBitArray bit_array bitarrays_merged matches =
		(
			--format "\n"; print ".mergeBitArraysInBitArray()"
			for m = matches.count to 1 by -1 do
			(
				bit_array += bitarrays_merged[matches[m]]

				deleteItem bitarrays_merged matches[m]
			)

			append bitarrays_merged bit_array

			bitarrays_merged --return
		)

		--bitarrays_merged	= #()


		for bit_array in bitarrays do
		(
			--format "\n--------------------\n"
			--format "bit_array: %\n" bit_array

			matches =  for i = 1 to bitarrays_merged.count where not ( bitarrays_merged[i] * bit_array ).isEmpty collect i

			--format "matches: %\n" matches

			case matches.count  of
			(
				/* ADD NEW BITARRAY */
				(0):	append bitarrays_merged bit_array

				/* JOIN TO EXISTING BITARRAY */
				(1): bitarrays_merged[matches[1]] += bit_array

				/*  (matches.count > 1)  MERGE MULTIPLE BITARRAYS if more than one amtch found */
				default: bitarrays_merged = mergeBitArraysInBitArray(bit_array)(bitarrays_merged)(matches)
			)

			if matches.count == 0 then
				append this.new_islands bit_array

		)

		bitarrays_merged --return
	),


	/** Search vert in islands
	 */
	function _getSharedIslands vert =
	(
		--format "\n"; print "VerIslandFinder_v._getSharedIslands()"

		function facesShareVerts verts1 verts2 = not ( verts1 * verts2 ).isEmpty

		for i = 1 to verts_islands.count where verts_islands[i][vert] collect i

	),

	/** Merge islands
	 */
	function _mergeIslands islands_to_merge vert =
	(
		--format "\n"; print "VerIslandFinder_v._mergeIslands()"

		merged_island = #{vert}

		for i = islands_to_merge.count to 1 by -1 do
		(
			merged_island += verts_islands[i]

			deleteItem verts_islands i
		)

		 append verts_islands merged_island
	),

	/**
	 */
	on create do
	(
		--format "\n"; print "VerIslandFinder.onCreate()"
		--for prop in #(  ) where getProperty this prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of this struct properties necessary to run
		--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof this as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )
	)

)
