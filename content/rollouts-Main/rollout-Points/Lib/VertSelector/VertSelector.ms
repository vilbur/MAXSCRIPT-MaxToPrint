filein( getFilenamePath(getSourceFileName()) + "/../MeshDataGetter/MeshDataGetter.ms" )	--"./../MeshDataGetter/MeshDataGetter.ms"

/** Get lowest verts in grid


	IMPORTANT:
		  DIFFERENT METHODS CAN RETURN DIFFERENT BitArray ON SAME SELECTION e.g.: #{1..157090} and #{1..930, 932..157091} -- vertext index 931 is missing and array is larger

		  In polyop methods is one vertex index missing in middle of BitArray

			Noticed on model imported from Zbrush

		  SOLUTION: REXPORT OBJECT, xform and attach to new object doesnt help

		  A) 'getVertSelection obj.mesh'	returns #{1..1000}
		  B) 'polyop.getVertSelection obj'	returns #{1..930, 932..1001}


 */
struct VertSelector_v
(
	/* construct */
	obj,

	/* properties */
	--resolution = 5,
	resolution = 10,

	points_grid 	= #(), -- 2DMatrix of verts which share same cell in grid points_grid[X_CELL][Y_CELL]
	sel_modified 	= #{}, -- modified selection for selecting
	round_grid	= #( #(), #(), #() ), -- 3D matrix of points positions rounded into 3 grid - round_grid[AXIS][CELL][VERT]

	/* dependency */
	MeshDataGetter,

	/* reference */
	data_verts,	-- MeshDataGetter.data_verts
	data_faces,	-- MeshDataGetter.data_faces

	/* inhered */

	/** Select lowest
	 */
	function getLowestVerts sel:true =
	(
		format "\n"; print "VertSelector_v.getLowestVerts()"

		--MeshDataGetter.VertNormalLimits.z = [ 135, 180 ]

		data_verts = MeshDataGetter.getVertexData verts:#ALL_OR_SELECTED positions:true --normals:true

		this._getVertsInGrid()

		--this.sel_modified = copy data_verts[#VERTS]
		this.sel_modified = #{}
		surrounding_points = #{}



		--for x = 1 to round_grid[1].count where (slice_x = round_grid[1][x]).count > 0 do
		--	for y = 1 to round_grid[2].count where (slice_y = round_grid[2][y]).count > 0 do
		--		this._filterOnlyMinZVerts ( slice_x * slice_y )

		for x = 1 to round_grid[1].count where (slice_x = round_grid[1][x]).count > 0 do
			for y = 1 to round_grid[2].count where (slice_y = round_grid[2][y]).count > 0 do
				for z = 1 to round_grid[3].count where (slice_z = round_grid[3][z]) != undefined and slice_z.count > 0 do
				(
					verts_in_cell = slice_x * slice_y * slice_z
					lowest_vert = this._filterOnlyMinZVerts ( verts_in_cell - surrounding_points )

					if lowest_vert != undefined then
					(
						--format "surrounding_points: %\n" surrounding_points
						faces_of_vert = polyop.getFacesUsingVert obj lowest_vert

						surrounding_points +=  polyop.getVertsUsingFace obj faces_of_vert

					)
				)

		
		this._selectVertsAndReturn(sel) --return
	),

	/* Get Convexity State
	 *
	 * @param BitArray|#name 	verts #ALL|#SELECTED|#ALL_OR_SELECTED
	 * @param name|array convex #CONVEX|#CONCAVE|#MIXED|#CORNER - type of verts to select, can be single #NAME or Array of names e.g.: #( #CONVEX, #MIXED )
	*/
	function getConvexVerts verts:#ALL_OR_SELECTED mode:#CONVEX sel:true =
	(
		format "\n"; print "VertSelector_v.getConvexVerts()"

		if classOf mode != Array then
			mode = #(mode)

		data_verts = MeshDataGetter.getVertexData convexity:true verts:verts

		this.sel_modified = #{}

		verts_by_type = data_verts[#CONVEXITY]
		--format "verts_by_type: %\n" verts_by_type
		--format "verts.count: %\n" verts.count
		--format "verts_types.count: %\n" verts_types.count
		--this.sel_modified = (for i = 1 to verts_types.count where findItem mode verts_types[i] > 0 collect verts[i]) as BitArray

		format "mode: %\n" mode

		for single_mode in mode do
			this.sel_modified += verts_by_type[single_mode]


		this._selectVertsAndReturn(sel) --return
	),

	/** Get verts by normal
	 */
	function getVertsByNormalLimit sel:true =
	(
		--format "\n"; print "VertSelector_v.getVertsByNormalLimit()"
		this._getVertsToProcess normals:true

		this.sel_modified = this._filterVertsByNormalLimit(verts_process)

		this._selectVertsAndReturn(sel) --return
	),

	/** Get 3D checker pattern of verts
	  *
	  * SHOW HOW TO ACCES TO CELLS
	 */
	function getCheckerSelection invert_sel:false sel:true =
	(
		--format "\n"; print "VertSelector_v.getCheckerSelection()"
		--this._getVertsToProcess()

		/** Is even
		 */
		function isEven n =  ( mod n 2 ) == 0

		--this._getVertsToProcess normals:false
		data_verts = MeshDataGetter.getVertexData positions:true

		timer_getVertsInGrid = timeStamp()
		this._getVertsInGrid()
		--format "\n getVertsInGrid: % ms\n" (( timeStamp()) - timer_getVertsInGrid)

		this.sel_modified = #{}

		for x = 1 to round_grid[1].count where (slice_x = round_grid[1][x]).count > 0 do
		(
			for y = 1 to round_grid[2].count where (slice_y = round_grid[2][y]).count > 0 do
			(
				test_X = ( not isEven(x) and isEven(y))
				test_Y = ( not isEven(y) and isEven(x))

				for z = 1 to round_grid[3].count where (slice_z = round_grid[3][z]).count > 0 do
				(
					if     (isEven(z) and    (test_X or test_Y)) \
					or (not isEven(z) and not (test_X or test_Y)) then
						this.sel_modified +=( slice_x * slice_y * slice_z)

					/* DEBUG
						this.sel_modified = slice_x
						this.sel_modified = slice_y
						this.sel_modified = slice_z
					*/

				)
			)
		)

		this._selectVertsAndReturn(sel) --return
	),

	/** Select sinlge vert per face island

		Point with lowest position on Z
	 */
	function getSingleVertPerFaceIsland sel:true =
	(
		format "\n"; print "VertSelector_v.getSingleVertPerFaceIsland()"

		data_verts = MeshDataGetter.getVertexData verts:#SELECTED positions:true

		hidden_verts = polyop.getHiddenVerts obj

		------if  data_verts[#VERTS].numberSet == 0 then
		------	return false

		this.sel_modified = #{}

		--this.sel_modified = copy data_verts[#VERTS]

		/* LOOP EACH ISLAND OF VERTS */
		for verts_island in (verts_islands = this._sortVertsByIslands()) do
		(
			--format "VERTS_ISLAND: %\n" verts_island

			this._filterOnlyMinZVerts (verts_island *  data_verts[#VERTS])
		)
		--gc()

		this._selectVertsAndReturn(sel) --return
	),


	/** Select final selection
	 */
	function selectVerts =
	(
		format "\n"; print "VertSelector_v.selectVerts()"
		--if this.sel_modified.isEmpty then
			--this.sel_modified = deepCopy data_verts[#VERTS]
		--format "this.sel_modified: %\n" this.sel_modified

		--if not this.sel_modified.isEmpty then
		--(
			max modify mode

			subObjectLevel = 1

			_mod = modPanel.getCurrentObject()

			_mod.SetSelection #Vertex #{}

			if classOf _mod == Edit_Poly then
				_mod.Select #Vertex this.sel_modified

			else if classOf _mod  == Editable_Poly then
				_mod.SetSelection #Vertex this.sel_modified
		--)
	),

	private

	/**  Left only single lowest vert of verts
	  *   Verts above are removed from selection
	 */
	function _filterOnlyMinZVerts verts =
	(
		--format "\n"; print "VertSelector_v._SelectOnlyMinZVerts()"
		--format "verts: %\n" verts

		/* VERTS CAN BE UNDEFINED IF CELL IS EMPTY */
		if verts.numberSet > 0 and ( lowest_vert = this._getLowestVertOnZaxis(verts) ) != undefined then
			this.sel_modified[lowest_vert] = true

		lowest_vert --return

		/* REMOVE OTHER VERTS FROM SELECTION */
		--for vert in verts_to_remove do
			--this.sel_modified[vert] = false
	),

	/** Get vert with min z pos
	  *
	  * @param BitArray verts
	 */
	function _getLowestVertOnZaxis verts =
	(
		--format "\n"; print "VertSelector_v._getLowestVertOnZaxis()"
		verts_arr = verts as Array

		/* GET LOWEST POINT IN CELL */
		if verts_arr.count > 1 then
		(
			z_positions = for vert in verts_arr collect MeshDataGetter.getPosition(vert) axis:#Z
			--z_positions = for pos in (meshop.getVerts obj.mesh verts node:obj) collect pos.z

			if ( index = findItem z_positions (amin z_positions) ) > 0 then
				verts_arr[index] --return
		)
		else
			verts_arr[1] --return

			--verts_arr[1] --return
	),


	/** Filter verts by normal
	 */
	function _filterVertsByNormalLimit verts =
	(
		--format "\n"; print "VertSelector_v._filterVertsByNormalLimit()"
		(for vert in verts where (MeshDataGetter.getNormal(vert)).z < normal_limit collect vert) as BitArray
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


		faces_by_verts = ( polyop.getFacesUsingVert obj  data_verts[#VERTS]) as Array

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


	/** Get point in grid

		return 2 matrix of cells on XY grid
			#(
				#( #{x1y1}, #{x1y2} )
				#( #{x2y1}, #{x2y2} )
				#( #{x3y1}, #{x3y2} )
			)
	 */
	function _getVertsInGrid =
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



		verts_arr = data_verts[#VERTS] as Array

		pos_by_axis = MeshDataGetter.getPositionsSplitByAxis()

		min_pos = #( amin pos_by_axis[1], amin pos_by_axis[2], amin pos_by_axis[3])

		/* FILL MATRIX
			round_grid[AXIS][CELL][VERT]
		*/
		for i = 1 to verts_arr.count do
		(
			vert	= verts_arr[i]
			vert_pos	= data_verts[#POSITIONS][i]

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


	/** Select and return mofified selection
	 */
	function _selectVertsAndReturn make_selection =
	(
		if make_selection then
			this.selectVerts()

		this.sel_modified  --return
	),

	/**
	 */
	on create do
	(
		--format "\n"; print "VertSelector.onCreate()"
		MeshDataGetter 	= MeshDataGetter_v( obj )
	)
)
