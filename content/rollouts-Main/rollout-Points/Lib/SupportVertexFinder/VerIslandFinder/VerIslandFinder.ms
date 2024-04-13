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
	islands	= #(), -- #( #{ veret_ids } ) array of faceverts of verts sorted by island the occupy

	new_islands = #(),

	/* private */
	/* dependency */
	/* reference */
	/* inhered */

	/** Analyze layers
	 */
	function analyzeLayers verts_all verts_used verts_layers =
	(
		format "\n"; print "SupportVertexFinder_v._analyzeLayers()"
		format "vertex count: %\n" verts_all.numberSet

		layers_count = verts_layers.count

		max create mode

		with redraw off
		(
			for layer = 1 to layers_count where classOf ( all_verts_in_layer = verts_layers[layer] ) == BitArray do -- layer has not verts if item is integer ( layer number )
			(
				----vert_color.hue = ( random 0 255 )
				--format "\n==============\nlayer: %\n" layer

				if mod layer 10 == 0 then
					(format "layer: % of: %\n" layer layers_count)

				verts_used_in_layer = all_verts_in_layer * verts_used

				--format "ISLANDS: %\n" islands

				/* GET FACES IN LAYER */
				faces_in_layer = polyop.getFacesUsingVert obj all_verts_in_layer
				--format "faces_in_layer: %\n" faces_in_layer

				face_islands_in_layer = this._detachMethod (faces_in_layer)
				--format "face_islands_in_layer: %\n" face_islands_in_layer

				for face_island_in_layer in face_islands_in_layer do
				(
					island = polyop.getVertsUsingFace obj face_island_in_layer
					--format "\nisland: %\n" island

					island_used = island * verts_used_in_layer -- island only from used verts
					--format "island_used: %\n" island_used

					if island_used.numberSet > 0 then
					(
						--intesections = for i = 1 to islands.count where (islands[i] * island_used).numberSet > 1 collect i
						intesections = for i = 1 to islands.count where not (islands[i] * island_used).isEmpty collect i
						--format "intesections: %\n" intesections

						intesections_count = intesections.count

						if intesections_count == 0 then
							append this.new_islands island_used

						case intesections_count of
						(
							/* JOIN TO EXISTING BITARRAY */
							(1):	islands[intesections[1]] += island

							/* ADD NEW BITARRAY */
							(0): append islands island

							/* MERGE MULTIPLE BITARRAYS */
							default:(

								for i = intesections.count to 1 by -1 do
								(
									index = intesections[i]

									island += islands[index]

									deleteItem islands index
								)

								append islands island
							)
						)
					)
				)

			)

			islands_final = this._mergeBitArraysbySharedBits (islands) #()

			format "\n\nNEW ISLANDS: %\n" this.new_islands
			format "\n\nNEW ISLANDS COUNT: %\n" this.new_islands.count

			format "\n\nISLANDS FINAL: %\n" islands_final

			delete Helpers -- DEV

			for new_island in this.new_islands do
				this._getCenterOfIsland (new_island)
		)

		redrawViews()

		gc light:true
	),


	/** Detach method
	 */
	function _detachMethod faces_of_verts =
	(
		--format "\n"; print ".detachMethod()"
		--format "faces_of_verts: %\n" faces_of_verts
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

		elements --return
	),

	/** Get center of island
	 */
	function _getCenterOfIsland verts =
	(
		--format "\n"; print "VerIslandFinder_v.getCenterOfIsland()"

		pos_center = point3 0 0 0

		positions = in coordsys world meshop.getVerts obj.mesh verts node:obj


		for pos in positions do pos_center += pos

		pos_center /= positions.count

		Point pos:pos_center size:5 wirecolor:red

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

		for bit_array in bitarrays do
		(
			--format "\n--------------------\n"
			--format "bit_array: %\n" bit_array

			matches =  for i = 1 to bitarrays_merged.count where not ( bitarrays_merged[i] * bit_array ).isEmpty collect i

			case matches.count  of
			(
				/* ADD NEW BITARRAY */
				(0):	append bitarrays_merged bit_array

				/* JOIN TO EXISTING BITARRAY */
				(1): bitarrays_merged[matches[1]] += bit_array

				/*  (matches.count > 1)  MERGE MULTIPLE BITARRAYS if more than one amtch found */
				default: bitarrays_merged = mergeBitArraysInBitArray(bit_array)(bitarrays_merged)(matches)
			)
		)

		bitarrays_merged --return
	),


	/** Search vert in islands
	 */
	function _getSharedIslands vert =
	(
		--format "\n"; print "VerIslandFinder_v._getSharedIslands()"

		function facesShareVerts verts1 verts2 = not ( verts1 * verts2 ).isEmpty

		for i = 1 to islands.count where islands[i][vert] collect i

	),

	/** Merge islands
	 */
	function _mergeIslands islands_to_merge vert =
	(
		--format "\n"; print "VerIslandFinder_v._mergeIslands()"

		merged_island = #{vert}

		for i = islands_to_merge.count to 1 by -1 do
		(
			merged_island += islands[i]

			deleteItem islands i
		)

		 append islands merged_island
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
