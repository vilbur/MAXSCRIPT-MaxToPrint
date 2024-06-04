--filein( getFilenamePath(getSourceFileName()) + "/../MeshDataGetter/MeshDataGetter.ms" )	--"./../MeshDataGetter/MeshDataGetter.ms"



/** Grid vert selector
 */
struct VertexGrid_v
(
	/* construct */
	obj,

	/* required */


	/* properties */
	--resolution = 5,
	resolution = 10,


	/* private */
	/* dependency */
	/* reference */
	/* inhered */



	/* reference */
	verts_data,	-- MeshDataGetter.verts_data
	data_faces,	-- MeshDataGetter.data_faces


	/* private */
	/* dependency */
	--VerIslandFinder = VerIslandFinder_v(),


	--resolution = 10,

	points_grid 	= #(), -- 2DMatrix of verts which share same cell in grid points_grid[X_CELL][Y_CELL]
	--sel_modified 	= #{}, -- modified selection for selecting
	round_grid	= #( #(), #(), #() ), -- 3D matrix of points positions rounded into 3 grid - round_grid[AXIS][CELL][VERT]

	--MeshDataGetter,


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
			--for axis = 1 to 2 do
			(
				level = cellByPos(vert_pos[axis])(min_pos[axis])

				/* CRTEATE NEW CELL */
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










	private


	/**
	 */
	on create do
	(
		--format "\n"; print "VertexGrid.onCreate()"
		--MeshDataGetter 	= MeshDataGetter_v( obj )
		--for prop in #(  ) where getProperty this prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of this struct properties necessary to run
		--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof this as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )
	)



)
