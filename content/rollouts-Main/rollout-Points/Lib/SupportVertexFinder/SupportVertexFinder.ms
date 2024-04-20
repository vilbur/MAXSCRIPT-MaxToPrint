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
	verts_process, -- canditate for supports
	verts_pos,
	verts_layers, -- #( #{3..8}, 2 ) vertex numbers in layer, if layer is empty, then layer index is stored

	verts_support = #{},	-- final verts used for supports

	bbox,
	layer_height = 0.05, -- height of print layer in mm



	/* reference */
	verts_data,	-- MeshDataGetter.verts_data
	data_faces,	-- MeshDataGetter.data_faces


	/* private */
	/* dependency */
	VerIslandFinder = VerIslandFinder_v(),


	--resolution = 10,

	points_grid 	= #(), -- 2DMatrix of verts which share same cell in grid points_grid[X_CELL][Y_CELL]
	--sel_modified 	= #{}, -- modified selection for selecting
	round_grid	= #( #(), #(), #() ), -- 3D matrix of points positions rounded into 3 grid - round_grid[AXIS][CELL][VERT]

	MeshDataGetter,


	/* reference */
	/* inhered */
	/** Find points
	 */
	function findVerts =
	(
		format "\n"; print "SupportVertexFinder_v.findVerts()"
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

	/** Get point in grid

		return 2 matrix of cells on XY grid
			#(
				#( #{x1y1}, #{x1y2} )
				#( #{x2y1}, #{x2y2} )
				#( #{x3y1}, #{x3y2} )
			)
	 */
	function _getVertsInGrid verts_data =
	(
		--format "\n"; print "VertSelector_v._getVertsInGrid()"
		/** Get cell by position
		 */
		function cellByPos vert_pos_on_axis axis_origin =
		(
			((( vert_pos_on_axis - axis_origin ) / this.resolution) as integer ) + 1
		)

		fn roundPoint3 p3 dp =
		(
			--format "p3: %\n" p3
			local tempArr = #(p3.x,p3.y,p3.z)
			local mult = 10.00^(dp as float)
			local rp3Arr = for c in tempArr collect ((floor ((c * mult)+0.5)) / mult)
			point3 rp3Arr[1] rp3Arr[2] rp3Arr[3]
		)



		verts_arr = verts_data[#VERTS] as Array

		pos_by_axis = this.getPositionsSplitByAxis(verts_data)

		min_pos = #( amin pos_by_axis[1], amin pos_by_axis[2], amin pos_by_axis[3])

		/* FILL MATRIX
			round_grid[AXIS][CELL][VERT]
		*/
		for i = 1 to verts_arr.count do
		(
			vert	= verts_arr[i]
			vert_pos	= verts_data[#POSITIONS][i]

			for axis = 1 to 3 do
			(
				level = cellByPos(vert_pos[axis])(min_pos[axis])

				if (round_grid[axis][level]) == undefined then
					round_grid[axis][level] = #{}

				/* SET VERT TO BITARRAY OF CELL */
				round_grid[axis][level][vert] = true
			)
		)

		--gc()

		--format "POINTS_GRID: %\n" points_grid

		points_grid --return
	),



	/** Get ace islands by verts
	  *
	  * @param BitArray verts which faces will be sorted by islands
	  *
	  * @return #( #{..} ) array of vertex ids, each array are verts of one island
	 */
	function _sortVertsByIslands =
	(
		format "\n"; print "VertSelector_v._sortVertsByIslands()"

		function facesShareVerts verts1 verts2 = not ( verts1 * verts2 ).isEmpty

		tested_pairs	= #{} -- store stringified array of face id used in loop already
		verts_islands	= #() -- #( #{ veret_ids } ) array of bitarrays of verts sorted by island the occupy
		--face_islands	= #() -- #( #{ faces_ids } ) array of bitarrays of faces sorted by island the occupy
		verts_per_faces	= #()


		faces_by_verts = ( polyop.getFacesUsingVert obj  verts_data[#VERTS]) as Array

		verts_per_faces = for face_id in faces_by_verts collect polyop.getVertsUsingFace obj #{face_id}

		timer_start = timeStamp()

		for f = 1 to faces_by_verts.count do
		(
			face_joined = true

			for i = 1 to verts_islands.count do
				if facesShareVerts (verts_islands[i]) (verts_per_faces[f]) then
				(
					verts_islands[i] +=  verts_per_faces[f]

					/* CURENTLY NOT NEEDED, GET FACE IDS BY ISLAND */
					--append face_islands[i] faces_by_verts[f]

					face_joined = false
				)

			if face_joined then
			(
					/* CURENTLY NOT NEEDED, GET FACE IDS BY ISLAND */
				--append face_islands #(faces_by_verts[f])

				append verts_islands verts_per_faces[f]
			)

		)

		verts_islands --return
	),


	/** Check selection ingerity
	 */
	function _checkSelectionIngerity mesh_sel polyop_sel =
	(
		--format "\n"; print "VertSelector_v._checkSelectionIngerity()"

		if mesh_sel[mesh_sel.count] 1= polyop_sel[polyop_sel.count] then
			messageBox ("Object '"+obj.name+"' needs to be rexported.\n\nVertex needs to be reindexed" )title:"VertSelector_v"
	),


	/** Get positions of each vert splitted to XYZ
	  * Usefull for gettin min and max values oe verts by each axis separatly
	  *
	  * @return #( #(X pos), #(Y pos), #(Z pos) )
	 */
	function getPositionsSplitByAxis verts_data =
	(
		--format "\n"; print "MeshDataGetter_v.getPositionsSplitted()"
		if verts_data[#POSITIONS] == undefined then
			verts_data[#POSITIONS] = this._getVertsPositions()


		x_positions = #()
		y_positions = #()
		z_positions = #()

		for pos in verts_data[#POSITIONS] do
		(
			append x_positions pos.x
			append y_positions pos.y
			append z_positions pos.z
		)

		#( x_positions, y_positions, z_positions  ) --return
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
		format "\n"; print "SupportVertexFinder_v._sortVertsToLayers()"
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
		--format "\n"; print "SupportVertexFinder.onCreate()"
		VerIslandFinder.obj = obj
	)

)
