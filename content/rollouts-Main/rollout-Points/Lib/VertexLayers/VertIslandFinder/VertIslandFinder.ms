/** Ver island finder

	1) Loop each layer
	2) Get verts in each layer
	3) Find how many mesh island exsits


	4) Test if new or old island - in old, then faces exist in all island

 */
struct VertIslandFinder_v
(
	/* construct */
	obj,

	/* required */

	/* properties */
	verts_process	= #{},
	verts_all	= #{},

	verts_layers	= #(),	-- each item is BitArray of verts in layer
	verts_above	= #{},	-- store verts above last layer, or not yet iterated layers
	verts_processed	= #{},

	islands_all	= #(),
	new_islands = #(),

	/* private */
	/* dependency */
	/* reference */
	/* inhered */
	--layer_height,

	/** GET NEW ISLANDS PER LAYER
	  *
	  * Loop each print layer and search for new islands_all
	  *
	  * This method is usefel up to 100k vertex count, higher vertex count is slow
	  * Use lots of RAM memory
	  *
	  * @return #( #{ verts of new islands_all } )
	 */
	function getNewIslandsPerLayer =
	(
		format "\n"; print "SupportVertexFinder_v.getNewIslandsPerLayer()"
		format "verts_process: %\n" verts_process
		format "verts_layers: %\n" verts_layers
		--verts_processed = #{}
		findIslandsPerLayer_timer = timeStamp()

		if verts_above.isEmpty then
			verts_above = copy verts_all

		layers_with_verts = for index = 1 to verts_layers.count where classOf ( all_verts_in_layer = verts_layers[index] ) == BitArray and not ( all_verts_in_layer * verts_process ).isEmpty  collect index -- layer has not verts if item is integer ( layer number )

		used_layers_count = layers_with_verts.count

		format "layers_with_verts: %\n" layers_with_verts
		format "used_layers_count: %\n" used_layers_count

		for layer in layers_with_verts do
		(
			--format "\nlayer: %\n" layer
			--format "\n==============================\nlayer: %\n" layer
			if mod layer 50 == 0 then (format "layer: % of: %\n" layer used_layers_count)

			layer_verts_processed = #{}

			all_verts_in_layer = verts_layers[layer]
			--format "all_verts_in_layer: %\n" all_verts_in_layer
			verts_above  -= all_verts_in_layer



			layer_verts_process = all_verts_in_layer

			vert = ( layer_verts_process as Array )[1]

			while not layer_verts_process.isEmpty do
			(
			--	format "\n"
			--	format "vert: %\n" vert

				faces_of_vert	= polyop.getFacesUsingVert obj vert
				verts_of_faces	= polyop.getVertsUsingFace obj faces_of_vert

				verts_of_faces -= verts_above

				--if ( verts_of_faces - layer_verts_processed ).numberSet > 0 then
				if not ( verts_of_faces - layer_verts_processed ).isEmpty then
				(
					append islands_all verts_of_faces
					--append islands_all (verts_of_faces * all_verts_in_layer)

				--	format "islands_all: %\n" islands_all
					this._mergeBitArraysbySharedBits (islands_all) merge_if_more_than_one_bit_is_shared:true
				--	format "islands_all: %\n" islands_all
					layer_verts_process	-= verts_of_faces
					layer_verts_processed	+= verts_of_faces


					/* VERY IMPORTANT

						Get next vertex from neighbor face speeds up script incredibly

						Getting next vert by vertex index makes script slover in square root of time ( 8 X vertex count = 64 times slower )

					*/
					next_verts = verts_of_faces - layer_verts_processed

					vert = (next_verts as Array )[1]
				)

				/* FALLBACK if neighbor face does not exists */
				if vert == undefined then
					vert = (layer_verts_process as Array )[1]
			)


			for verts_island in islands_all where (verts_island * verts_processed ).isEmpty do
				--append this.new_islands verts_island
				append this.new_islands (verts_island * verts_process)

			verts_processed	+= all_verts_in_layer

		)

		format "\n------\n\n"
		format "findIslandsPerLayer_timer: % seconds\n" ((( timeStamp()) - findIslandsPerLayer_timer) / 1000.0)


		/*------------------------------------------------------------------------------
			DEV
		--------------------------------------------------------------------------------*/
		delete Helpers --

		obj.showVertexColors	= true
		obj.vertexColorsShaded	= true

		polyop.setVertColor obj.baseobject 0 verts_all white

		for new_island in this.new_islands do
		(
			--format "new_island: %\n" new_island
			polyop.setVertColor obj.baseobject 0 (new_island) red

			this._getCenterOfIsland (new_island)
		)

		/*------------------------------------------------------------------------------ */

		--gc light:true
		gc light:true delayed:true
		--gc()
		--gc delayed:true

		--format "FIRST ISLAND: %\n" this.new_islands[1]

		this.new_islands --return
	),

	/** Set verts processed
	 */
	function setVertsProcessed verts =
	(
		--format "\n"; print "VertIslandFinder_v.setVertsProcessed()"

		format "\n"; print "VertIslandFinder_v.setVertsProcessed()"
		format "verts: %\n" verts

		islands = #()

		while not verts.isEmpty do
		(
			faces_of_vert = polyop.getFacesUsingVert obj (verts as Array )[1]

			verts_of_faces = polyop.getVertsUsingFace obj faces_of_vert
			--format "verts_of_faces: %\n" verts_of_faces
			verts_of_faces -= this.verts_above

			append islands verts_of_faces

			verts -= verts_of_faces
		)

		this.islands_all = this._mergeBitArraysbySharedBits(islands)

	),

	/** Get center of island
	 */
	function _getCenterOfIsland verts =
	(
		--format "\n"; print "VertIslandFinder_v.getCenterOfIsland()"

		pos_center = point3 0 0 0

		positions = in coordsys world meshop.getVerts obj.mesh verts node:obj


		for pos in positions do pos_center += pos

		pos_center /= positions.count

		_Point = Point pos:pos_center size:5 wirecolor:red

		_Point.parent = obj

	),

	/**
	  * @param BitArray verts which faces will be sorted by islands
	  *
	  * @return #( #{..} ) array of vertex ids, each array are verts of one island
	 */
	function _sortVertsByIslands face_ids_of_verts =
	(

	),

	private

	/** Merge bit arrays wich shared bits
	  *
	  * @param #( #{} ) bitarrays Array of bittarays
	 */
	function _mergeBitArraysbySharedBits bitarrays merge_if_more_than_one_bit_is_shared:false =
	(
		limit = if merge_if_more_than_one_bit_is_shared then 1 else 0
		--format "\n"; print ".mergeBitArraysTest2()"

		for x = bitarrays.count to 1 by -1 do
		(
			merged = false

			--for y = bitarrays.count to 1 by -1 where x != y and not ( bitarrays[x] * bitarrays[y] ).isEmpty do -- "not ( bitarrays[x] * bitarrays[y] ).isEmpty" WILL CONNECT FACES WHICH SHARE SIGNLGE VERTEX - IT IS NOT ACCURATE
			--for y = bitarrays.count to 1 by -1 where x != y and ( bitarrays[x] * bitarrays[y] ).numberSet > 1 do -- "not ( bitarrays[x] * bitarrays[y] ).isEmpty" WILL CONNECT FACES WHICH SHARE SIGNLGE VERTEX - IT IS NOT ACCURATE
			for y = bitarrays.count to 1 by -1 where x != y and ( bitarrays[x] * bitarrays[y] ).numberSet > limit do -- "not ( bitarrays[x] * bitarrays[y] ).isEmpty" WILL CONNECT FACES WHICH SHARE SIGNLGE VERTEX - IT IS NOT ACCURATE
			(
				bitarrays[y] += bitarrays[x]

				merged = true
			)

			if merged then
				deleteItem bitarrays x
		)

		bitarrays --return
	),


	/**
	 */
	on create do
	(
		--format "\n"; print "VertIslandFinder.onCreate()"
		--for prop in #(  ) where getProperty this prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of this struct properties necessary to run
		--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof this as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )
	)

)
