/** Ver island finder

	1) Loop each layer
	2) Get verts in each layer

	3) Get face islands in each layer

	4) Test if new or old island - in old, then faces exist in all island

 */
struct VerIslandFinder_v
(
	/* construct */
	obj,

	/* required */

	/* properties */
	face_islands	= #(), -- #( #{ faces_ids } ) array of bitarrays of faces sorted by island the occupy
	verts_islands	= #(), -- #( #{ veret_ids } ) array of bitarrays of verts sorted by island the occupy


	/* private */
	/* dependency */
	/* reference */
	/* inhered */


	/** Analyze layers
	 */
	function analyzeLayers print_layers =
	(
		format "\n"; print "SupportVertexFinder_v._analyzeLayers()"
		format "print_layers: %\n" print_layers

		for layer = 1 to print_layers.count where classOf ( verts_in_layer = print_layers[layer] ) == BitArray do
		(
			format "\n--------------\nlayer: %\n" layer

			this._sortVertsByIslands (verts_in_layer)
			format "verts_islands: %\n" verts_islands
		)
	),

	/**
	  * @param BitArray verts which faces will be sorted by islands
	  *
	  * @return #( #{..} ) array of vertex ids, each array are verts of one island
	 */
	function _sortVertsByIslands verts =
	(
		--format "\n"; print "VertSelector_v._sortVertsByIslands()"

		face_ids_of_verts = ( polyop.getFacesUsingVert obj verts ) as Array
		--format "face_ids_of_verts: %\n" face_ids_of_verts

		faces_definded_by_verts = for face_id in face_ids_of_verts collect polyop.getVertsUsingFace obj #{face_id} -- ( #{1..4}, #{2,4,5,6} ) -- faces definded by verts

		--format "faces_definded_by_verts: %\n" faces_definded_by_verts

		this._mergeBitArraysWithSharedBits(faces_definded_by_verts)

		verts_islands --return
	),


	private

	/** Merge bit arrays with shared bits
	 */
	function _mergeBitArraysWithSharedBits bitarrays =
	(
		--format "\n"; print ".mergeBitArraysWithSharedBits()"

		/** Merge bit arrays in bit array
		 */
		function mergeBitArraysInBitArray bit_array verts_islands matches =
		(
			--format "\n"; print ".mergeBitArraysInBitArray()"
			for m = matches.count to 1 by -1 do
			(
				bit_array += verts_islands[matches[m]]

				deleteItem verts_islands matches[m]
			)

			append verts_islands bit_array

			verts_islands --return
		)


		for bit_array in bitarrays do
		(
			--format "\n--------------------\n"
			--format "bit_array: %\n" bit_array

			matches =  for i = 1 to verts_islands.count where not ( bit_array * verts_islands[i] ).isEmpty collect i

			--format "matches: %\n" matches

			case matches.count  of
			(
				/* ADD NEW BITARRAY */
				(0):	append verts_islands bit_array

				/* JOIN TO EXISTING BITARRAY */
				(1): verts_islands[matches[1]] += bit_array

				/*  (matches.count > 1)  MERGE MULTIPLE BITARRAYS if more than one amtch found */
				default: verts_islands = mergeBitArraysInBitArray(bit_array)(verts_islands)(matches)
			)
		)
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
