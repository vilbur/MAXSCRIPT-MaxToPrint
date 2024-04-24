filein( getFilenamePath(getSourceFileName()) + "/../MeshDataGetter/MeshDataGetter.ms" )	--"./../MeshDataGetter/MeshDataGetter.ms"
filein( getFilenamePath(getSourceFileName()) + "/../VertexLayers/VertexLayers.ms" )	--"./../VertexLayers/VertexLayers.ms"
filein( getFilenamePath(getSourceFileName()) + "/../VertexGrid/VertexGrid.ms" )	--"./../VertexGrid/VertexGrid.ms"
filein( getFilenamePath(getSourceFileName()) + "/../VertexGridGetter/VertexGridGetter.ms" )	--"./../VertexGridGetter/VertexGridGetter.ms"

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
	obj_original,	-- not collapesd original object
	obj,	-- editable poly object used to process

	/* properties */
	sel_modified = #{},
	face_elements = #(),

	--resolution = 5,
	--resolution = 10,

	/* dependency */
	MeshDataGetter,
	VertexGridGetter,
	VertexLayers,

	/* reference */
	/* inhered */

	/** Get lowest verts in grid
	 */
	function selectLowestVertsInGrid resolution:10 =
	(
		--format "\n"; print "VertSelector_v.selectLowestVertsInGrid()"
		VertexGridGetter.resolution = resolution

		this.sel_modified = VertexGridGetter.getLowestVertsInGrid()

		this._selectVertsAndReturn(true) --return

	),

	/** Get lowest verts in grid
	 */
	function selectChecker resolution:10 invert_sel:false =
	(
		format "\n"; print "VertSelector_v.selectChecker()"
		format "RESOLUTION: %\n" resolution
		VertexGridGetter.resolution = resolution

		this.sel_modified = VertexGridGetter.getCheckerPattern invert_sel:invert_sel

		this._selectVertsAndReturn(true) --return

	),

	/** Find islands per layer
	 */
	function findIslandsPerLayer =
	(
		--format "\n"; print "VertSelector_v.findIlandsPerLayer()"

		new_islands = VertexLayers.findVerts()
		format "new_islands: %\n" new_islands

		--for new_island in new_islands do
		--format "new_island: %\n" new_island
			--this.sel_modified += new_island
		--format "this.sel_modified: %\n" this.sel_modified
		--this._selectVertsAndReturn(true) --return

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

	/** Detach method
	 */
	function setFaceElements faces_of_verts =
	(
		--format "\n"; print ".detachMethod()"
		--format "faces_of_verts: %\n" faces_of_verts
		obj_snap = snapshot obj

		convertTo obj_snap PolyMeshObject

		polyop.detachFaces obj_snap faces_of_verts delete:true

		local poGetElementsUsingFace = polyop.getElementsUsingFace

		while not faces_of_verts.isEmpty do
        (
			face = (faces_of_verts as array)[1]

			element = poGetElementsUsingFace obj_snap #(face)

			append face_elements element

			faces_of_verts -= element
		)

		delete obj_snap

		--face_elements --return
	),

	/** Select and return mofified selection
	 */
	function _selectVertsAndReturn make_selection =
	(
		if make_selection then
			this.setSelection this.sel_modified

		this.sel_modified  --return
	),

	/** Set object
	 */
	function _setObject =
	(
		--format "\n"; print "GridLayerManager_v.setObject()"

		this.obj = this.obj_original -- DEV

		--this.obj  = snapshot this.obj_original

		--convertTo this.obj PolyMeshObject
	),

	/**
	 */
	on create do
	(
		--format "\n"; print "VertSelector.onCreate()"
		this._setObject()

		VertexGrid 	= VertexGrid_v( obj )
		MeshDataGetter 	= MeshDataGetter_v( obj )
		VertexGridGetter 	= VertexGridGetter_v( obj )
		VertexLayers 	= VertexLayers_v( obj )

	)



)
