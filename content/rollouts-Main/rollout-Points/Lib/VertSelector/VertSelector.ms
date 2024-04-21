filein( getFilenamePath(getSourceFileName()) + "/../MeshDataGetter/MeshDataGetter.ms" )	--"./../MeshDataGetter/MeshDataGetter.ms"
filein( getFilenamePath(getSourceFileName()) + "/../VertexGrid/VertexGrid.ms" )	--"./../VertexGrid/VertexGrid.ms"


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
	sel_modified = #{},

	--resolution = 5,
	--resolution = 10,

	/* dependency */
	VertexGrid,
	MeshDataGetter,

	/* reference */
	/* inhered */


	/** Select lowest
	 */
	function getLowestVerts resolution: sel:true =
	(
		format "\n"; print "VertSelector_v.getLowestVerts()"

		--MeshDataGetter.VertNormalLimits.z = [ 135, 180 ]

		data_verts = MeshDataGetter.getVertexData verts:#ALL_OR_SELECTED positions:true --normals:true

		VertexGrid._getVertsInGrid(data_verts)

		--this.sel_modified = copy data_verts[#VERTS]
		this.sel_modified = #{}
		surrounding_points = #{}

		round_grid = VertexGrid.round_grid

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



	/** Get selection
	 */
	function _getSelection subobject =
	(
		--format "\n"; print "SupportVertexFinder_v._getSelection()"
		if subobject == #FACE then polyop.getFaceSelection obj else polyop.getVertSelection obj -- return
	),

	--/** Select final selection
	-- */
	--function selectVerts subobject:#VERTEX =
	--(
	--	format "\n"; print "VertSelector_v.selectVerts()"
	--	--format "verts: %\n" verts
	--
	--	max modify mode
	--
	--	setSelectionLevel obj subobject
	--
	--	_mod = modPanel.getCurrentObject()
	--
	--	_mod.SetSelection subobject #{}
	--
	--	if classOf _mod == Edit_Poly then
	--		_mod.Select subobject this.sel_modified
	--
	--	else if classOf _mod  == Editable_Poly then
	--		_mod.SetSelection subobject this.sel_modified
	--),

	/** Select final selection
	 */
	function setSelection sel_bitarray subobject:#VERTEX =
	(
		format "\n"; print "VertSelector_v.selectVerts()"
		--format "sel_bitarray: %\n" sel_bitarray

		max modify mode

		setSelectionLevel obj subobject

		_mod = modPanel.getCurrentObject()

		_mod.SetSelection subobject #{}

		if classOf _mod == Edit_Poly then
			_mod.Select subobject sel_bitarray

		else if classOf _mod  == Editable_Poly then
			_mod.SetSelection subobject sel_bitarray
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
			this.setSelection this.sel_modified

		this.sel_modified  --return
	),


	/**
	 */
	on create do
	(
		--format "\n"; print "VertSelector.onCreate()"
		VertexGrid 	= VertexGrid_v( obj )
		MeshDataGetter 	= MeshDataGetter_v( obj )

	)
)
