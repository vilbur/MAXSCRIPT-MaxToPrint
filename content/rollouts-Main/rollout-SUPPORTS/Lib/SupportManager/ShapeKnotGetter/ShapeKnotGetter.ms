/** Shape knot getter
 */
struct ShapeKnotGetter_v
(
	/* construct */
	source_obj,

	use_nth_vertex = 1,

	/* properties */

	/* dependency */
	/* reference */
	/* inhered */

	/** Get vertex positions from spline
	  *
	  *
	  *
	  * @return Dictionary KEYS: #VERTS|#POSITIONS|#COLORS|#NORMALS  VALUES:knot_ids|knots_positions|knots_colors|knots_normals
	*/
	function getVetexData =
	(
		format "\n"; print "PlatformGenerator_v._getVertexPositionsFromShape()"

		--knots_data = #( #{ }, #(), #(), #() )
		knots_data = Dictionary() -- KEYS MUST BE COMPATIBLE WITH MeshDataGetter_v.verts_data

		knots_data[#VERTS]	= #{}
		knots_data[#POSITIONS]	= #()
		knots_data[#NORMALS]	= #()
		knots_data[#COLORS]	= Dictionary #STRING

		knots_data[#COLORS][ source_obj.wirecolor as string ] = #{ 1..1000 }

		source_shapes = this._copyAndCollapseSourceObject( this._getChildrenShape (source_obj) )
		--format "source_shapes: %\n" source_shapes
		--format "source_shapes.count: %\n" source_shapes.count
		/* Get platform object for each pline vertex */
		for spline_i = 1 to numSplines source_shapes[1] do
			for knot_i = 1 to numKnots source_shapes[1] spline_i where this._isNthVertex (knot_i) do
			(

				/* add knot to generate */
				knots_data[#VERTS][ knots_data[#VERTS].numberset +1 ] = true

				/* knot position  */
				append knots_data[#POSITIONS] (getKnotPoint source_shapes[1] spline_i knot_i)

				--/* knot wirecolor  */
				--append knots_data[#COLORS] source_shapes[1].wirecolor

				/* knot normal  */
				append knots_data[#NORMALS] [0,0, 1] -- PLACEHOLDER METHOD current


				/* PLACEHOLDER METHOD FPR GETTING KNOT NORMAL BY DORECTION TO SECN SHAPE */
				--if source_shapes.count > 1 then
				--	for shape_child_i = 2 to source_shapes.count do
				--		append knots_data[2] (getKnotPoint source_shapes[shape_child_i] spline_i knot_i)
			)

		--for knot_data in knots_data do
		--	format "knot_data: %\n" knot_data

		delete source_shapes

		knots_data --return
	),


	private


	/** Get children of given object with same class
	  */
	function _getChildrenShape obj =
	(
		--format "\n"; print "PlatformGenerator_v.getChildren()"

		fn getChildPoint parent_obj = (for i = 1 to parent_obj.children.count where classOf parent_obj.children[i] == classOf parent_obj collect parent_obj.children[i] ) [1]

		children = #(obj)


		if classOf ( parent_obj = obj ) == classOf obj then
			while (child_obj = getChildPoint (parent_obj)) != undefined do
			(
				append children child_obj

				parent_obj = child_obj
			)

		children --return
	),

	/** Copy and collapse source spline
	  */
	function _copyAndCollapseSourceObject source_objects =
	(
		nnl = #()

		maxOps.cloneNodes source_objects cloneType:#copy newNodes:&nnl

		convertTo nnl SplineShape

		nnl --return
	),

	/** test if vertexx index is nth vertex in spline
	  */
	function _isNthVertex index =
	(
		--format "\n"; print "PlatformGenerator_v.isNthVertex"
		is_nth_vertex = index == 1 or use_nth_vertex == 1 or ceil (test = (index - 1)/use_nth_vertex as float ) == test

		is_nth_vertex --return
	),


	/**
	 */
	on create do
	(
		--format "\n"; print "ShapeKnotGetter.onCreate()"
		--for prop in #(  ) where getProperty this prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of this struct properties necessary to run
		--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof this as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )
	)

)
