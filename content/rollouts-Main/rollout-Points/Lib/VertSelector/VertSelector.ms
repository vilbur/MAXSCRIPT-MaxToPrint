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

	data_verts,
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
		format "\n"; print "VertSelector_v.findIlandsPerLayer()"

		new_islands = VertexLayers.findVertsOfNewIslands()
		format "new_islands: %\n" new_islands

		for new_island in new_islands do
			this.sel_modified += new_island
		format "this.sel_modified: %\n" this.sel_modified
		this._selectVertsAndReturn(true) --return

	),

	/** Select sinlge vert per face island

		Point with lowest position on Z
	 */
	function selectSingleVertPerFaceIsland sel:true =
	(
		format "\n"; print "VertSelector_v.selectSingleVertPerFaceIsland()"

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

	/**  Left only single lowest vert of verts
	  *   Verts above are removed from selection
	 */
	function _filterOnlyMinZVerts verts =
	(
		--format "\n"; print "VertexGridGetter_v._SelectOnlyMinZVerts()"
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
		--format "\n"; print "VertexGridGetter_v._getLowestVertOnZaxis()"
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
