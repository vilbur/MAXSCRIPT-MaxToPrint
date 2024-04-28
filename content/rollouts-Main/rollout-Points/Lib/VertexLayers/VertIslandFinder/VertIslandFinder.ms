filein( getFilenamePath(getSourceFileName()) + "/VertIslandFinder/VertIslandFinder.ms" )	--"./VertIslandFinder/VertIslandFinder.ms"

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

	/* dependency */
	VertIslandFinder,

	/* reference */
	/* inhered */
	/** Find points
	 */
	function findVertsOfNewIslands =
	(
		format "\n"; print "VertexLayers_v.findVertsOfNewIslands()"
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
--
		--verts_process = bottom_verts * convex_verts * visible_verts
		verts_process = if (verts_sel = polyop.getVertSelection obj ).numberSet > 0 then verts_sel else verts_all

		verts_process *= visible_verts

		verts_layers = this._sortVertsToLayers(verts_process)
		format "verts_layers: %\n" verts_layers

		GET_ISLANDS = timeStamp()

		--VertIslandFinder.analyzeLayersByDetach(verts_all)(verts_process)(verts_layers)
		VertIslandFinder.getNewIslandsPerLayer(verts_all)(verts_process)(verts_layers)

		--format "\n GET_ISLANDS: % ms\n" (( timeStamp()) - GET_ISLANDS)
		--format "\n GET_ISLANDS: % seconds\n" ((( timeStamp()) - GET_ISLANDS) / 1000.0)

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
		VertIslandFinder.new_islands --return

	),


	/** Set verts positions
	 */
	function _getVertsPositions =
	(
		format "\n"; print "VertDataGetter_v._getVertsPositions()"
		in coordsys world meshop.getVerts obj.mesh verts_all node:obj
	),

	/** Sort verts to layers
	 */
	function _sortVertsToLayers verts_process =
	(
		format "\n"; print "VertexLayers_v._sortVertsToLayers()"
		--fn compareZpos pos1 pos2 = if pos1.z < pos2.z then -1 else 1
		verts_in_layers = #{}

		verts_pos = this._getVertsPositions()

		if verts_process.numberSet == verts_all.numberSet then
		(
			bbox = nodeGetBoundingBox obj ( Matrix3 1)

			pos_z_min = bbox[1].z

			mesh_height = bbox[2].z - pos_z_min

			verts_in_layers = copy verts_all
		)
		else
		(
			verts_pos_z = for pos in verts_pos collect pos.z

			pos_z_min = amin verts_pos_z
			pos_z_max = amax verts_pos_z

			mesh_height = pos_z_max - pos_z_min

			for vert in verts_process where ( vert_pos_z = verts_pos[vert].z ) >= pos_z_min and vert_pos_z <= pos_z_max do verts_in_layers[vert] = true
		)

		layers_count = ceil ( mesh_height / layer_height)

		this.verts_layers = #{1..(layers_count + 1)} as Array

		for vert in verts_in_layers do
		--for v = 1 to verts_pos.count do
		(
			layer = floor ( (verts_pos[vert].z - pos_z_min) / layer_height) + 1

			if superClassOf this.verts_layers[layer] == Number then
				this.verts_layers[layer] = #{vert} -- get first ert in layer

			else
				this.verts_layers[layer][vert] = true
		)

		--format "VERTS_LAYERS: %\n" verts_layers
		--format "VERTS_LAYERS: %\n" verts_layers.count
		verts_layers --return
	),

	/**
	 */
	on create do
	(
		--format "\n"; print "VertexLayers.onCreate()"
		VertIslandFinder = VertIslandFinder_v(obj)
	)

)
