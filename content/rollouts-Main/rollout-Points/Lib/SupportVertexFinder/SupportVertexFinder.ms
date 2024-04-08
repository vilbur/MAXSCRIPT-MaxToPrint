filein( getFilenamePath(getSourceFileName()) + "/VerIslandFinder/VerIslandFinder.ms" )	--"./VerIslandFinder/VerIslandFinder.ms"

/**
 */
struct SupportVertexFinder_v
(
	/* construct */
	obj,

	/* required */


	/* properties */
	vertex_count,
	verts_all,
	verts_test, -- canditate for supports
	verts_pos,
	print_layers, -- #( #{3..8}, 2 ) vertex numbers in layer, if layer is empty, then layer index is stored

	verts_support = #{},	-- final verts used for supports

	bbox,
	layer_height = 0.05, -- height of print layer


	/* private */
	/* dependency */
	VerIslandFinder = VerIslandFinder_v(),

	/* reference */
	/* inhered */
	/** Find points
	 */
	function findVerts =
	(
		format "\n"; print "SupportVertexFinder_v.findVerts()"
		this.vertex_count = getNumVerts obj.mesh

		verts_all = #{1..(vertex_count)}
		--format "vertex_count: %\n" vertex_count

		/* GET VERTS WITH NORMAL POINTING DOWN */
		bottom_verts = this._getBottomVerts()

		/* GET ONLY CONVEX VERTS */
		convex_verts = this._getConvexPoints()

		--format "convex_verts: %\n" convex_verts
		--format "bottom_verts: %\n" bottom_verts

		verts_test = bottom_verts * convex_verts

		verts_pos = this._getVertsPositions()

		this._sortVertsToLayers()

		VerIslandFinder.analyzeLayers(print_layers)

		--format "verts_test: %\n" verts_test


		--this.selectVerts(verts_test)
		--this.selectVerts(verts_support)
		--this.selectVerts( print_layers[1]  )
		--
		--this.selectVerts( print_layers[1] * verts_test )

	),

	private


	/** Get ace islands by verts
	  *
	  * @param BitArray verts which faces will be sorted by islands
	  *
	  * @return #( #{..} ) array of vertex ids, each array are verts of one island
	 */
	function _sortVertsByIslands verts =
	(
		--format "\n"; print "VertSelector_v._sortVertsByIslands()"

		function facesShareVerts verts1 verts2 = not ( verts1 * verts2 ).isEmpty

		tested_pairs	= #{} -- store stringified array of face id used in loop already
		verts_islands	= #() -- #( #{ veret_ids } ) array of bitarrays of verts sorted by island the occupy
		verts_per_faces	= #()
		face_islands_in_layer = #{}

		faces_by_verts = ( polyop.getFacesUsingVert obj verts ) as Array

		verts_per_faces = for face_id in faces_by_verts collect polyop.getVertsUsingFace obj #{face_id}


		for f = 1 to faces_by_verts.count do
		(
			face_joined = true

			for v = 1 to verts_islands.count do

				if facesShareVerts (verts_islands[v]) (verts_per_faces[f]) then
				(
					verts_islands[v] +=  verts_per_faces[f]

					/* CURENTLY NOT NEEDED, GET FACE IDS BY ISLAND */
					--append face_islands_in_layer[i] faces_by_verts[f]

					face_joined = false
				)

			if face_joined then
			(
					/* CURENTLY NOT NEEDED, GET FACE IDS BY ISLAND */
				--append face_islands_in_layer #(faces_by_verts[f])
				append face_islands_in_layer #(faces_by_verts[f])

				append verts_islands verts_per_faces[f]
			)

		)

		format "face_islands_in_layer: %\n" face_islands_in_layer

		for face_island_in_layer in face_islands_in_layer do
		(



		)




		verts_islands --return
	),

	/** Set verts to layers
	 */
	function setVertsToLayers =
	(
		--format "\n"; print "SupportVertexFinder_v.setVertsToLayers()"
	),

	/** Select final selection
	 */
	function selectVerts verts =
	(
		format "\n"; print "VertSelector_v.selectVerts()"
		format "verts: %\n" verts

		max modify mode

		subObjectLevel = 1

		_mod = modPanel.getCurrentObject()

		_mod.SetSelection #Vertex #{}

		if classOf _mod == Edit_Poly then
			_mod.Select #Vertex verts

		else if classOf _mod  == Editable_Poly then
			_mod.SetSelection #Vertex verts
	),

	/** Get convex points
	 */
	function _getConvexPoints =
	(
		format "\n"; print "SupportVertexFinder_v._getConvexPoints()"

		max modify mode

		subObjectLevel = 1

		PolyToolsSelect.ConvexConcave 0.1 2 -- select convex and convex-concave

		getVertSelection obj.mesh -- return
	),

	/** Get bottom verts
	 */
	function _getBottomVerts =
	(
		--format "\n"; print "SupportVertexFinder_v._getBottomVerts()"
		max modify mode

		subObjectLevel = 1

		PolyToolsSelect.Normal 3 120 true

		getVertSelection obj.mesh -- return
	),

	/** Set verts positions
	 */
	function _getVertsPositions =
	(
		format "\n"; print "VertDataGetter_v._getVertsPositions()"
		in coordsys world meshop.getVerts obj.mesh this.verts_all node:obj
	),

	/** Sort verts to layers
	 */
	function _sortVertsToLayers =
	(
		format "\n"; print "SupportVertexFinder_v.sort_VertsToLayers()"
		bbox = nodeGetBoundingBox obj ( Matrix3 1)

		min_z = bbox[1].z

		obj_height = bbox[2].z - min_z

		layers_count = ceil (obj_height / layer_height)

		this.print_layers = #{1..(layers_count + 1)} as Array


		--format "layers_count: %\n" layers_count
		for v = 1 to verts_pos.count do
		(

			layer = ceil ( (verts_pos[v].z - min_z) / layer_height) + 1

			if superClassOf this.print_layers[layer] == Number then
				this.print_layers[layer] = #{v} -- get first ert in layer

			else
				this.print_layers[layer][v] = true
		)

		format "VERTS_LAYERS: %\n" print_layers
		format "VERTS_LAYERS: %\n" print_layers.count
	),

	/**
	 */
	on create do
	(
		--format "\n"; print "SupportVertexFinder.onCreate()"
		VerIslandFinder.obj = obj
	)

)
