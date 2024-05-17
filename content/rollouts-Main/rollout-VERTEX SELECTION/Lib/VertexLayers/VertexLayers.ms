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

		/* GET VERTS WITH NORMAL POINTING DOWN */
		--bottom_verts = this.getBottom()

		/* GET ONLY CONVEX VERTS */
		--convex_verts = this.selectConvex()

		visible_verts = -( polyop.getHiddenVerts obj)
		format "visible_verts.numberSet: %\n" visible_verts.numberSet

		verts_sel = polyop.getVertSelection obj

		verts_process = if (verts_sel = polyop.getVertSelection obj ).numberSet > 0 then verts_sel else verts_all

		verts_process *= visible_verts

		verts_pos = this._getVertsPositions()

		this._sortVertsToLayers()

		VertIslandFinder.verts_all	= verts_all
		VertIslandFinder.verts_process	= verts_process
		VertIslandFinder.verts_layers	= verts_layers

		GET_ISLANDS = timeStamp()
		--format "verts_process.numberSet: %\n" verts_process.numberSet
		--format "VertIslandFinder.verts_process.numberSet: %\n" VertIslandFinder.verts_process.numberSet
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
		--VertIslandFinder.new_islands --return

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
		--if verts_process.numberSet == verts_all.numberSet then
		(
			print "SET ALL VERTS TO LAYERS"
			bbox = nodeGetBoundingBox obj ( Matrix3 1)

			pos_z_min = bbox[1].z

			--mesh_height = bbox[2].z - pos_z_min
			mesh_height = bbox[2].z

			verts_fit = copy verts_all
		)
		/* SET ONLY SELECTED VERTS TO LAYERS */
		--else
		--(
		--	print "SET ONLY SELECTED VERTS TO LAYERS"
		--	verts_above	= #{}
		--	verts_fit	= #{}
		--	verts_bellow	= #{}
		--
		--	verts_pos_z = for vert in verts_process collect verts_pos[vert].z
		--
		--	pos_z_min = amin verts_pos_z
		--	pos_z_max = amax verts_pos_z
		--
		--	--mesh_height = pos_z_max - pos_z_min
		--	mesh_height = pos_z_max
		--	--for vert in verts_process where ( vert_pos_z = verts_pos[vert].z ) >= pos_z_min and vert_pos_z <= pos_z_max do verts_in_layers[vert] = true
		--
		--	for vert in verts_all do
		--	(
		--		vert_pos_z = verts_pos[vert].z
		--
		--		case of
		--		(
		--			(vert_pos_z > pos_z_max ):	verts_above[vert]	= true
		--			(vert_pos_z < pos_z_min ):	verts_bellow[vert]	= true
		--			default:	verts_fit[vert]	= true
		--		)
		--	)
		--
		--	VertIslandFinder.verts_above = verts_above
		--
		--	VertIslandFinder.setVertsProcessed(verts_bellow)
		--)


		layers_count = ceil ( mesh_height / layer_height)
		format "LAYERS_COUNT: %\n" layers_count

		this.verts_layers  = #{1..(layers_count + 1)} as Array -- create with

		for vert in verts_fit do
		--for v = 1 to verts_pos.count do
		(
			--layer = floor ( (verts_pos[vert].z - pos_z_min) / layer_height) + 1
			layer = ceil ( (verts_pos[vert].z ) / layer_height) + 1

			if classOf this.verts_layers [layer] == BitArray then
				this.verts_layers [layer][vert] = true

			else
				this.verts_layers [layer] = #{vert} -- set first vert in layer
		)
		--
		--format "verts_above: %\n" verts_above
		--format "verts_fit: %\n" verts_fit
		--format "verts_bellow: %\n" verts_bellow

	),


	/**
	 */
	on create do
	(
		--format "\n"; print "VertexLayers.onCreate()"
		VertIslandFinder = VertIslandFinder_v(obj)
	)

)
