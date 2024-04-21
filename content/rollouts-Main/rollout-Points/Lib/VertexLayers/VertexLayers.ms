filein( getFilenamePath(getSourceFileName()) + "/VerIslandFinder/VerIslandFinder.ms" )	--"./VerIslandFinder/VerIslandFinder.ms"

/**
 */
struct VertexLayers_v
(
	/* construct */
	obj,

	/* required */

	/* properties */
	vertex_count,
	verts_all,
	verts_process, -- canditate for supports
	verts_pos,
	verts_layers, -- #( #{3..8}, 2 ) vertex numbers in layer, if layer is empty, then layer index is stored

	verts_support = #{},	-- final verts used for supports

	bbox,
	layer_height = 0.05, -- height of print layer in mm


	/* reference */
	/* inhered */
	/** Find points
	 */
	function findVerts =
	(
		format "\n"; print "VertexLayers_v.findVerts()"
		this.vertex_count = getNumVerts obj.mesh

		verts_all = #{1..(vertex_count)}
		format "VERTEX_COUNT: %\n" vertex_count

		/* GET VERTS WITH NORMAL POINTING DOWN */
		--bottom_verts = this.getBottom()

		/* GET ONLY CONVEX VERTS */
		--convex_verts = this.selectConvex()

		visible_verts = -( polyop.getHiddenVerts obj)


		polyop.setVertColor obj.baseobject 0 verts_all white


		--format "convex_verts: %\n" convex_verts
		--format "bottom_verts: %\n" bottom_verts

		--verts_process = bottom_verts * convex_verts * visible_verts
		verts_process = polyop.getVertSelection obj

		verts_process *= visible_verts

		verts_pos = this._getVertsPositions()

		this._sortVertsToLayers()


		VerIslandFinder.analyzeLayersByDetach(verts_all)(verts_process)(verts_layers)
		--VerIslandFinder.getNewIslandsPerLayer(verts_all)(verts_process)(verts_layers)

		--gc()

		--format "\n analyzeLayers: % seconds\n" ((( timeStamp()) - analyzeLayers) / 1000.0)
		--format "\n analyzeLayers: % ms\n" (( timeStamp()) - analyzeLayers)


		--format "verts_process: %\n" verts_process


		--this.selectVerts(bottom_verts * convex_verts * visible_verts)


		--this.selectVerts(bottom_verts)

		--this.selectVerts(verts_process)

		--this.selectVerts(convex_verts)

		--this.selectVerts( verts_layers[1]  )
		--
		--this.selectVerts( verts_layers[1] * verts_process )

	),











	--private

	/** Select final selection
	 */
	function setSelection verts subobject:#VERTEX =
	(
		format "\n"; print "VertSelector_v.selectVerts()"
		--format "verts: %\n" verts

		max modify mode

		setSelectionLevel obj subobject

		_mod = modPanel.getCurrentObject()

		_mod.SetSelection subobject #{}

		if classOf _mod == Edit_Poly then
			_mod.Select subobject verts

		else if classOf _mod  == Editable_Poly then
			_mod.SetSelection subobject verts
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
		format "\n"; print "VertexLayers_v._sortVertsToLayers()"
		bbox = nodeGetBoundingBox obj ( Matrix3 1)

		min_z = bbox[1].z

		obj_height = bbox[2].z - min_z

		layers_count = ceil (obj_height / layer_height)

		this.verts_layers = #{1..(layers_count + 1)} as Array
		----this.verts_layers = #()
		--format "VERTS_LAYERS: %\n" verts_layers


		--format "layers_count: %\n" layers_count
		for v = 1 to verts_pos.count do
		(
			layer = floor ( (verts_pos[v].z - min_z) / layer_height) + 1

			if superClassOf this.verts_layers[layer] == Number then
				this.verts_layers[layer] = #{v} -- get first ert in layer

			else
				this.verts_layers[layer][v] = true
		)

		format "VERTS_LAYERS: %\n" verts_layers
		format "VERTS_LAYERS: %\n" verts_layers.count
	),

	/**
	 */
	on create do
	(
		--format "\n"; print "VertexLayers.onCreate()"
		VerIslandFinder.obj = obj
	)

)
