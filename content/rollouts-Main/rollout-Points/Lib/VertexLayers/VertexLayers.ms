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
		--format "\n"; print "VertexLayers_v.findVertsOfNewIslands()"

		/* ========= DEV DESELECT ALL VERTS ========= */
		--obj.EditablePoly.SetSelection #Vertex #{}


		this.vertex_count = getNumVerts obj.mesh

		verts_all = #{1..(vertex_count)}
		--format "VERTEX_COUNT: %\n" vertex_count

		/* GET VERTS WITH NORMAL POINTING DOWN */
		--bottom_verts = this.getBottom()

		/* GET ONLY CONVEX VERTS */
		--convex_verts = this.selectConvex()

		visible_verts = -( polyop.getHiddenVerts obj)


		--polyop.setVertColor obj.baseobject 0 verts_all white

		verts_sel = polyop.getVertSelection obj

		--format "convex_verts: %\n" convex_verts
		--format "bottom_verts: %\n" bottom_verts

		--verts_process = bottom_verts * convex_verts * visible_verts
		--verts_process = polyop.getVertSelection obj
		verts_process = if (verts_sel = polyop.getVertSelection obj ).numberSet > 0 then verts_sel else verts_all

		--format "verts_all: %\n" verts_all
		--format "verts_sel: %\n" verts_sel
		--format "verts_process: %\n" verts_process
		verts_process *= visible_verts

		verts_pos = this._getVertsPositions()

		this._sortVertsToLayers()


		GET_ISLANDS = timeStamp()

		VertIslandFinder.verts_all	= verts_all
		VertIslandFinder.layer_height	= layer_height
		VertIslandFinder.verts_layers	= verts_layers


		--VertIslandFinder.analyzeLayersByDetach(verts_all)(verts_process)(verts_layers)
		VertIslandFinder.getNewIslandsPerLayer()


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
		in coordsys world meshop.getVerts obj.mesh this.verts_all node:obj
	),

	/** Sort verts to layers
	 */
	function _sortVertsToLayers =
	(
		format "\n"; print "VertexLayers_v._sortVertsToLayers()"

		/* SET ALL VERTS TO LAYERS */
		if verts_process.numberSet == verts_all.numberSet then
		(
			print "SET ALL VERTS TO LAYERS"
			bbox = nodeGetBoundingBox obj ( Matrix3 1)

			pos_z_min = bbox[1].z

			mesh_height = bbox[2].z - pos_z_min

			VertIslandFinder.verts_process	= verts_process

			verts_fit = copy verts_all
		)
		/* SET ONLY SELECTED VERTS TO LAYERS */
		else
		(
			print "SET ONLY SELECTED VERTS TO LAYERS"
			verts_above	= #{}
			verts_fit	= #{}
			verts_bellow	= #{}

			verts_pos_z = for vert in verts_process collect verts_pos[vert].z

			pos_z_min = amin verts_pos_z
			pos_z_max = amax verts_pos_z

			mesh_height = pos_z_max - pos_z_min
			--for vert in verts_process where ( vert_pos_z = verts_pos[vert].z ) >= pos_z_min and vert_pos_z <= pos_z_max do verts_in_layers[vert] = true

			for vert in verts_all do
			(
				vert_pos_z = verts_pos[vert].z

				case of
				(
					(vert_pos_z > pos_z_max ):	verts_above[vert]	= true
					(vert_pos_z < pos_z_min ):	verts_bellow[vert]	= true
					default:	verts_fit[vert]	= true
				)
			)

			VertIslandFinder.verts_above = verts_above

			VertIslandFinder.setVertsProcessed(verts_bellow)
		)

		layers_count = ceil ( mesh_height / layer_height)
		format "LAYERS_COUNT: %\n" layers_count

		this.verts_layers  = #{1..(layers_count + 1)} as Array

		for vert in verts_fit do
		--for v = 1 to verts_pos.count do
		(
			layer = floor ( (verts_pos[vert].z - pos_z_min) / layer_height) + 1

			if superClassOf this.verts_layers [layer] == Number then
				this.verts_layers [layer] = #{vert} -- get first vert in layer

			else
				this.verts_layers [layer][vert] = true
		)

		format "verts_above: %\n" verts_above
		format "verts_fit: %\n" verts_fit
		format "verts_bellow: %\n" verts_bellow

		--VertIslandFinder.verts_above = verts_above

			--verts_above	= #{}
			--verts_fit	= #{}
			--verts_bellow	= #{}

		--format "VERTS_LAYERS: %\n" verts_layers
		--format "VERTS_LAYERS: %\n" verts_layers.count
		--VertIslandFinder.verts_layers = verts_layers --return
	),

	/** Sort verts to layers
	 */
	function _sortVertsToLayersOld =
	(
		format "\n"; print "VertexLayers_v._sortVertsToLayers()"
		bbox = nodeGetBoundingBox obj ( Matrix3 1)

		min_z = bbox[1].z

		--obj_height = bbox[2].z - min_z
		obj_height = bbox[2].z

		layers_count = ceil (obj_height / layer_height)

		this.verts_layers = #{1..(layers_count + 1)} as Array
		----this.verts_layers = #()
		--format "VERTS_LAYERS: %\n" verts_layers


		--format "layers_count: %\n" layers_count
		for v = 1 to verts_pos.count do
		(
			--layer = floor ( (verts_pos[v].z - min_z) / layer_height) + 1
			layer = floor ( verts_pos[v].z / layer_height) + 1

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
		VertIslandFinder = VertIslandFinder_v(obj)
	)

)
