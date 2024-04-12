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
	face_islands_in_layer	= #(), -- #( #{ faces_ids } ) array of faceverts of faces sorted by island the occupy
	verts_islands	= #(), -- #( #{ veret_ids } ) array of faceverts of verts sorted by island the occupy

	face_islands = #(),

	new_islands = #(),

	verts_processed = #{}, -- store verts in current layer and layers bellow

	/* private */
	/* dependency */
	/* reference */
	/* inhered */


	/** Analyze layers
	 */
	function analyzeLayers verts_all verts_used verts_layers =
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

		delete Helpers

		islands_processed = #()

		verts_above = copy verts_all
		verts_bellow = #{}
		--format "VERTS_USED: %\n" verts_used

		counter = 1
		for layer = 1 to verts_layers.count where classOf ( all_verts_in_layer = verts_layers[layer] ) == BitArray do -- layer has not verts if item is integer ( layer number )
		(

			--vert_color.hue = ( random 0 255 )
			--format "\n==============\nlayer: %\n" layer
			format "\n==============\nlayer: %\n" counter
			format "all_verts_in_layer: %\n" all_verts_in_layer

			--format "new_islands: %\n" new_islands
			this.new_islands	= #()

			verts_above -= all_verts_in_layer

			verts_other_layers = verts_all - all_verts_in_layer


			/* GET FACES IN LAYER */
			faces_in_layer = polyop.getFacesUsingVert obj all_verts_in_layer
			format "faces_in_layer: %\n" faces_in_layer

			verts_of_faces_in_layer = polyop.getVertsUsingFace obj faces_in_layer
			format "verts_of_faces_in_layer: %\n" verts_of_faces_in_layer


			faceverts_in_layer = for face_id in faces_in_layer collect polyop.getVertsUsingFace obj #{face_id}   -- ( #{1..4}, #{2,4,5,6} ) -- faces definded by verts
			format "faceverts_in_layer: %\n" faceverts_in_layer


			for i = 1 to faceverts_in_layer.count do
				faceverts_in_layer[i] -= verts_above


			format "faceverts_in_layer: %\n" faceverts_in_layer

			vert_islands_in_layer = this._mergeBitArraysbySharedBits (faceverts_in_layer) #() --return vert_islands_in_layer
			format "vert_islands_in_layer: %\n" vert_islands_in_layer


			verts_islands =  this._mergeBitArraysbySharedBits (join verts_islands vert_islands_in_layer) #()

			for verts_island in verts_islands where (verts_island * verts_bellow).isEmpty do
			(
				format "NEW ISLAND: %\n" verts_island

				pos_center = point3 0 0 0

				positions = in coordsys world meshop.getVerts obj.mesh verts_island node:obj

				format "positions: %\n" positions
				for pos in positions do pos_center += pos

				pos_center /= positions.count

				Point pos:pos_center size:1 wirecolor:green

			)



			format "verts_islands: %\n" verts_islands
			format "verts_bellow: %\n" verts_bellow

			verts_bellow += all_verts_in_layer

			counter += 1


		)
	),

	/** Sort faces by islands
	 */
	function _sortFacesByIslands faces_in_layer vert_islands_in_layer =
	(
		--format "\n"; print "VerIslandFinder_v._sortFacesByIslands()"
		--format "faces_in_layer: %\n" faces_in_layer

		face_islands_in_layer = for island in vert_islands_in_layer collect #{}

		faceverts = for face_id in faces_in_layer collect polyop.getVertsUsingFace obj #{face_id}
		format "faceverts: %\n" faceverts


		--for vert_island in vert_islands_in_layer do
		for i = 1 to vert_islands_in_layer.count do
		(
			vert_island = vert_islands_in_layer[i]


			for x = 1 to faceverts.count do
			--for verts_of_face in faceverts do
			(
				face_id = faces_in_layer[x]

				verts_of_face = faceverts[x]

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

		faceverts = for face_id in face_ids_of_verts collect polyop.getVertsUsingFace obj #{face_id} -- ( #{1..4}, #{2,4,5,6} ) -- faces definded by verts

		--format "faceverts: %\n" faceverts

		this._mergeBitArraysbySharedBits #()  (faceverts)   --return vert_islands_in_layer
	),


	private


	/** Merge bit arrays wich shared bits
	  *
	  * @param #( #{} ) bitarrays Array of bittarays
	 */
	function _mergeBitArraysbySharedBits bitarrays bitarrays_merged =
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
