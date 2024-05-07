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

	face_islands	= #(),
	verts_layers	= #(),	-- each item is BitArray of verts in layer
	verts_above	= #{},	-- store verts above last layer, or not yet iterated layers
	--verts_bellow	= #{},
	verts_processed	= #{},

	faces_processed	= #{},
	islands_all	= #(), -- store silands of verts bellow first layer, or already itearated layers

	new_islands = #(),
	/* private */
	/* dependency */
	/* reference */
	/* inhered */
	layer_height,

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
		format "\n"; print "VertIslandFinder_v.getNewIslandsPerLayer()"

		format "verts_process.numberSet: %\n" verts_process.numberSet
		--format "layers_count: %\n" layers_count
		--verts_processed = #{}
		findIslandsPerLayer_timer = timeStamp()

		if verts_above.isEmpty then
			verts_above = copy verts_all

		layers_with_verts = for layer_index = 1 to verts_layers.count where classOf ( all_verts_in_layer = verts_layers[layer_index] ) == BitArray collect layer_index -- layer has not verts if item is integer ( layer number )

		used_layers_count = layers_with_verts.count


		for layer in layers_with_verts do -- layer has not verts if item is integer ( layer number )
		(
			--format "layer: %\n" layer
			--format "\n==============================\nlayer: %\n" layer
			if mod layer 50 == 0 then (format "layer: % of: %\n" layer used_layers_count)

			layer_verts_processed = #{}

			all_verts_in_layer = verts_layers[layer]

			verts_above  -= all_verts_in_layer

			layer_verts_process = copy all_verts_in_layer
			--layer_verts_process = all_verts_in_layer * verts_process


			vert = ( layer_verts_process as Array )[1]


			while not layer_verts_process.isEmpty do
			(
				faces_of_vert	= polyop.getFacesUsingVert obj vert
				verts_of_faces	= polyop.getVertsUsingFace obj faces_of_vert

				verts_of_faces -= verts_above

				if ( verts_of_faces - layer_verts_processed ).numberSet > 0 then
				(
					append islands_all verts_of_faces

					this._mergeBitArraysbySharedBits (islands_all) merge_if_more_than_one_bit_is_shared:true

					layer_verts_process	-= verts_of_faces
					layer_verts_processed	+= verts_of_faces

					next_verts = verts_of_faces - layer_verts_processed

					vert = (next_verts as Array )[1]
				)

				if vert == undefined then
					vert = (layer_verts_process as Array )[1]
			)


			for verts_island in islands_all where (verts_island * verts_processed ).isEmpty do
				append this.new_islands verts_island

			verts_processed	+= all_verts_in_layer

		)

		format "\n------\n\n"
		format "findIslandsPerLayer_timer: % seconds\n" ((( timeStamp()) - findIslandsPerLayer_timer) / 1000.0)

		delete Helpers -- DEV

		obj.showVertexColors	= true
		obj.vertexColorsShaded	= true

		polyop.setVertColor obj.baseobject 0 verts_all white

		for new_island in this.new_islands do
		(
			polyop.setVertColor obj.baseobject 0 (new_island) red

			this._getCenterOfIsland (new_island)

		)
		--gc light:true
		gc()
		--gc delayed:true

		this.new_islands --return
	),

	/** Slice layers
	 */
	function _sliceLayers layers_with_verts =
	(
		format "\n"; print "VertIslandFinder_v._sliceLayers()"
		bbox	= ( nodeGetBoundingBox obj ( Matrix3 1) ) -- get bbox before slice

		max create mode

		--slice_mod = SliceModifier name:"SLICE_LAYERS" Slice_Type:2 Faces___Polygons_Toggle:1 SetMaterial:on materialID:999
		slice_mod = SliceModifier name:"SLICE_LAYERS" Slice_Type:2 Faces___Polygons_Toggle:1 --SetMaterial:on materialID:999

		--select_mod = Vol__Select name:"SELECT_LAYER" level:2 volume:5 matID:999 invert:true
		--epoly_mod = Edit_Poly name:"Edit_Poly_LAYER"


		addModifier obj slice_mod
		--addModifier obj select_mod
		--addModifier obj epoly_mod


		--size_z = bbox[2].z - bbox[1].z
		--format "size_z: %\n" size_z
		--
		----layer_height = 1
		----layer_height = 0.1
		--
		----layers_count = (size_z / layer_height) as integer
		--
		--
		--format "layers_count: %\n" layers_count
		--
		--elements_all = #()
		elements_count_changed = #()
		--
		count_old = 0

		--loop_layers = timeStamp()
		--format "\n loop_layers: % ms\n" (( timeStamp()) - loop_layers)
		with redraw off

		for layer in layers_with_verts do -- layer has not verts if item is integer ( layer number )
		--for layer = 1 to layers_count do
		(
			--format "\n==============================\nlayer: %\n" layer
			layer_TM = Matrix3 1
			--layer_TM.position.z = bbox[1].z
			layer_TM.position.z = layer * layer_height
			--layer_TM.position.z += layer_height -- set first layer


			temp_TM =	layer_TM * ( Inverse obj.transform )

			slice_mod.slice_plane.transform = temp_TM


			elements = this.getElementsOfFaces ()



			--_mergeBitArraysbySharedBits elements &elements_all


			--format "count: % elements: % elements_all: \n" elements.count elements elements_all
			if elements.count > count_old  then
			(
				--format "\n==============================\nlayer: %\n" layer
				--
				--format "elements: %\n" elements
				--format "elements.count : %\n" elements.count

				append elements_count_changed layer
			)


			count_old = elements.count

		)

		deleteModifier obj slice_mod
		--deleteModifier obj select_mod


		elements_count_changed --return
	),


	/** Get first layer
	 */
	function _getFirstLayerIslands =
	(
		format "\n"; print "VertIslandFinder_v._getFirstLayer()"
		for layer = 1 to verts_layers.count where classOf ( all_verts_in_layer = verts_layers[layer] ) == BitArray and not ( all_verts_in_layer * verts_process ).isEmpty  do -- layer has not verts if item is integer ( layer number )
		(
			faces_in_layer = polyop.getFacesUsingVert obj all_verts_in_layer
			format "faces_in_layer: %\n" faces_in_layer
			this.faces_processed += faces_in_layer


			this.islands_all = this.getVertexIslands ( polyop.getVertsUsedOnlyByFaces obj faces_in_layer)
			--this.islands_all = this.getVertexIslands ( polyop.getVertsUsingFace obj faces_in_layer)

			return layer
		)

	),

	/** Set verts processed
	 */
	function setVertsProcessed verts =
	(
		--format "\n"; print "VertIslandFinder_v.setVertsProcessed()"
		this.islands_all = this.getVertexIslands (verts)
	),

	/** Set verts processed
	 */
	function getVertexIslands verts =
	(
		--format "\n"; print "VertIslandFinder_v.getVertexIslands()"
		--verts_processed = verts
		--
		----faceverts = for face_id in faces_of_verts collect ( polyop.getVertsUsingFace obj face_id )
		--
		--islands_all = this._sortVertsByIslands( polyop.getFacesUsingVert obj verts_processed
		islands = #()

		--verts_used = copy verts
		--face_verts = polyop.getVertsUsingFace obj face

		--vertex_count = getNumVerts obj.mesh
		--format "vertex_count: %\n" vertex_count
		--
		--all_verts = #{1..(vertex_count)}

		--faces_sel = polyop.getFaceSelection obj
		--format "faces_sel: %\n" faces_sel
		--/*------ SPLIT TO ISLANDS ------*/
		--verts_sel = polyop.getVertsUsingFace obj faces_sel
		--format "verts_sel: %\n" verts_sel

		while not verts.isEmpty do
		(
			faces_of_vert = polyop.getFacesUsingVert obj (verts as Array )[1]

			verts_of_faces = polyop.getVertsUsingFace obj faces_of_vert
			format "verts_of_faces: %\n" verts_of_faces
			verts_of_faces -= this.verts_above

			append islands verts_of_faces

			verts -= verts_of_faces
		)

		this._mergeBitArraysbySharedBits(islands) --return

		--islands --return
	),

	/** Analyze layers
	 */
	function analyzeLayersByDetach verts_all verts_process verts_layers =
	(
		format "\n"; print "VertIslandFinder_v.analyzeLayersByDetach()"
		format "vertex count: %\n" verts_all.numberSet

		layers_count = verts_layers.count

		--getFacesUsingVert = polyop.getFacesUsingVert
		--getVertsUsingFace = polyop.getVertsUsingFace

		max create mode

		with redraw off
		(
			for layer = 1 to layers_count where classOf ( all_verts_in_layer = verts_layers[layer] ) == BitArray do -- layer has not verts if item is integer ( layer number )
			(
				----vert_color.hue = ( random 0 255 )
				--format "\n==============\nlayer: %\n" layer

				if mod layer 100 == 0 then
					(format "layer: % of: %\n" layer layers_count)

				verts_used_in_layer = all_verts_in_layer * verts_used

				--format "ISLANDS: %\n" islands_all

				/* GET FACES IN LAYER */
				faces_in_layer = polyop.getFacesUsingVert obj all_verts_in_layer
				--faces_in_layer = getFacesUsingVert obj all_verts_in_layer
				--format "faces_in_layer: %\n" faces_in_layer

				face_islands_in_layer = this.getElementsOfFaces (faces_in_layer)
				--format "face_islands_in_layer: %\n" face_islands_in_layer

				for face_island_in_layer in face_islands_in_layer do
				(
					island = polyop.getVertsUsingFace obj face_island_in_layer
					--island = getVertsUsingFace obj face_island_in_layer
					--format "\nisland: %\n" island

					island_used = island * verts_used_in_layer -- island only from used verts
					--format "island_used: %\n" island_used

					if island_used.numberSet > 0 then
					(
						--intesections = for i = 1 to islands_all.count where (islands_all[i] * island_used).numberSet > 1 collect i
						intesections = for i = 1 to islands_all.count where not (islands[i] * island_used).isEmpty collect i
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

			--gc light:true

			)

			--
			--islands_final = #()
			--
			--this._mergeBitArraysbySharedBits (islands) &islands_final
			--
			--format "\n\nNEW ISLANDS: %\n" this.new_islands
			--format "\n\nNEW ISLANDS COUNT: %\n" this.new_islands.count
			--
			--format "\n\nISLANDS FINAL: %\n" islands_final

			delete Helpers -- DEV

			for new_island in this.new_islands do
				this._getCenterOfIsland (new_island)
		)

		redrawViews()

		--gc()
	),


	/** Detach method
	 */
	function getElementsOfFaces =
	(
		--format "\n"; print ".detachMethod()"
		--format "faces_of_verts: %\n" faces_of_verts
		obj_snap = snapshot obj

		convertTo obj_snap PolyMeshObject

		--polyop.detachFaces obj_snap faces_of_verts delete:true
		--
		--local poGetElementsUsingFace = polyop.getElementsUsingFace
		--vertex_count = getNumVerts obj.mesh
		--_mod	= modPanel.getCurrentObject()

		faces = #{1..( polyop.getNumFaces obj_snap)}

		elements = #()

		while not faces.isEmpty do
																										(
			face = (faces as array)[1]

			element = polyop.getElementsUsingFace obj_snap #(face)

			append elements element

			faces -= element
		)

		delete obj_snap

		elements --return
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
		--format "\n"; print "VertSelector_v._sortVertsByIslands()"

		--face_ids_of_verts = ( polyop.getFacesUsingVert obj verts_in_layer ) as Array
		--format "face_ids_of_verts: %\n" face_ids_of_verts
		islands = #()

		faceverts = for face_id in face_ids_of_verts collect polyop.getVertsUsingFace obj #{face_id} -- ( #{1..4}, #{2,4,5,6} ) -- faces definded by verts

		--this._mergeBitArraysbySharedBits (faceverts) (&islands)
		join islands faceverts

		islands = this._mergeBitArraysbySharedBits(islands)
	),


	private

	/** Get face layers
	 */
	function getFaceLayers faces_in_layer =
	(
		--format "\n"; print "VertIslandFinder_v.getFaceLayers()"
	),


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
