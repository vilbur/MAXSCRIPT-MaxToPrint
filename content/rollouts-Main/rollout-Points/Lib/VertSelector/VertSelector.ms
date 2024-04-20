filein( getFilenamePath(getSourceFileName()) + "/../MeshDataGetter/MeshDataGetter.ms" )	--"./../MeshDataGetter/MeshDataGetter.ms"

filein( getFilenamePath(getSourceFileName()) + "/../SupportVertexFinder/SupportVertexFinder.ms" )	--"./../SupportVertexFinder/SupportVertexFinder.ms"


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
	--resolution = 10,

	--points_grid 	= #(), -- 2DMatrix of verts which share same cell in grid points_grid[X_CELL][Y_CELL]
	sel_modified 	= #{}, -- modified selection for selecting
	--round_grid	= #( #(), #(), #() ), -- 3D matrix of points positions rounded into 3 grid - round_grid[AXIS][CELL][VERT]

	/* dependency */
	MeshDataGetter,
	SupportVertexFinder,

	/* reference */
	data_verts,	-- MeshDataGetter.data_verts
	data_faces,	-- MeshDataGetter.data_faces

	/* inhered */


	/** Get convex points
	 */
	function selectConvex subobject:#VERTEX =
	(
		format "\n"; print "SupportVertexFinder_v.selectConvex()"

		max modify mode

		setSelectionLevel obj subobject

		sel_old = this._getSelection subobject

		--PolyToolsSelect.ConvexConcave 0.1 2 -- select convex and convex-concave
		PolyToolsSelect.ConvexConcave 0.001 2 -- select convex and convex-concave
		--PolyToolsSelect.ConvexConcave 0.0001 2 -- select convex and convex-concave

		sel_new = this._getSelection subobject
		--format "not (sel_old * sel_new).isEmpty: %\n" (not (sel_old * sel_new).isEmpty)
		--if not sel_old.isEmpty and not (sel_old - sel_new).isEmpty then
		if not sel_old.isEmpty then
			this.setSelection ( sel_new * sel_old) subobject:subobject



		--if subobject == #FACE then getFaceSelection obj.mesh else  getVertSelection obj.mesh -- return
		--if subobject == #FACE then polyop.getFaceSelection obj else polyop.getVertSelection obj -- return

	),

	/** Get bottom verts
	 */
	function selectBottom subobject:#VERTEX  =
	(
		--format "\n"; print "SupportVertexFinder_v.getBottom()"
		max modify mode

		setSelectionLevel obj subobject

		sel_old = this._getSelection subobject

		--PolyToolsSelect.Normal 3 120 true
		PolyToolsSelect.Normal 3 150 true
		--PolyToolsSelect.Normal 3 170 true

		sel_new = this._getSelection subobject
		--format "not (sel_old * sel_new).isEmpty: %\n" (not (sel_old * sel_new).isEmpty)
		if not sel_old.isEmpty then
			this.setSelection ( sel_new * sel_old ) subobject:subobject


		--if subobject == #FACE then getFaceSelection obj.mesh else  getVertSelection obj.mesh -- return
		--if subobject == #FACE then polyop.getFaceSelection obj else polyop.getVertSelection obj -- return

	),

	/** Get selection
	 */
	function _getSelection subobject =
	(
		--format "\n"; print "SupportVertexFinder_v._getSelection()"
		if subobject == #FACE then polyop.getFaceSelection obj else polyop.getVertSelection obj -- return
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


	/** Select lowest
	 */
	function getLowestVerts resolution sel:true =
	(
		format "\n"; print "VertSelector_v.getLowestVerts()"

		--MeshDataGetter.VertNormalLimits.z = [ 135, 180 ]

		data_verts = MeshDataGetter.getVertexData verts:#ALL_OR_SELECTED positions:true --normals:true



		SupportVertexFinder._getVertsInGrid(data_verts)

		--this.sel_modified = copy data_verts[#VERTS]
		this.sel_modified = #{}
		surrounding_points = #{}

		round_grid = SupportVertexFinder.round_grid

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
	function getCheckerSelection resolution invert_sel:false sel:true =
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
	function selectVerts subobject:#VERTEX =
	(
		format "\n"; print "VertSelector_v.selectVerts()"
		--format "verts: %\n" verts

		max modify mode

		setSelectionLevel obj subobject

		_mod = modPanel.getCurrentObject()

		_mod.SetSelection subobject #{}

		if classOf _mod == Edit_Poly then
			_mod.Select subobject this.sel_modified

		else if classOf _mod  == Editable_Poly then
			_mod.SetSelection subobject this.sel_modified
	),

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

	private


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
		SupportVertexFinder 	= SupportVertexFinder_v( obj )
	)
)
