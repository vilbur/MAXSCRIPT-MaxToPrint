/** Support object
 */
struct SupportObject_v
(
	/* construct */

	/* properties */
	support,
	raft_mode = false,

	/* dependency */
	/* reference */
	/* inhered */
	Options,

	/** Generate support
	 */
	function generateSupport point_helper =
	(
		--format "\n"; print "SupportObject_v.generateSupport()"
		--format "point_helper	= % \n" point_helper
		--format "point_helper.wirecolor: %\n" point_helper.wirecolor

		this.support = SplineShape name:(this._getName(point_helper.name)) wirecolor:(this._shiftWirecolor(point_helper.wirecolor) ) pos:point_helper.pos

		helpers_chain =  this._getPointsChain (point_helper)

		this._createLineFromPoints(support)(helpers_chain)

		support.parent = helpers_chain[helpers_chain.count]

		Options.setProp support #this (getHandleByAnim support)

		Options.setProp support #raft_mode raft_mode

		this.support --return
	),

	/** Rebuild existing support
	  *
	  * @pram Node support_exists existing support for rebuid
	 */
	function rebuildSupport support =
	(
		--format "\n"; print "SupportObject_v.rebuildSupport()"
		--format "point_helper	= % \n" point_helper
		line_updated = SplineShape()

		helpers_chain =  this._getPointsChain (point_helper)

		deleteSpline support 1

		this._createLineFromPoints(line_updated)(helpers_chain) _raft_mode:( Options.getProp support_exists #raft_mode ) -- raft mode by existing support|raft

		support.pos = line_updated.pos

		support.baseobject = line_updated.baseobject

		delete line_updated

		support --return
	),


	private


	/** Create line netween point helpers
	  */
	function _createLineFromPoints spline_shape helpers_chain =
	(
		--format "\n"; print "SupportObject_v._createLineForVertex()"
		--format "HELPERS_TREE: %\n" helpers_chain

		spline_index = 1

		addNewSpline spline_shape

		/*------------------------------------------------------------------------------
			ADD KNOTS BY POINTS FROM TOP TO BOTTOM
		--------------------------------------------------------------------------------*/
		for point_helper in helpers_chain do
			addKnot spline_shape spline_index #corner #line point_helper.pos

		if raft_mode then
			setMaterialID spline_shape spline_index 1 this.Options.mat_ids[#MIDDLE] -- setMaterialID <splineShape> <spline_index> <seg_index> <matID>

		if not raft_mode then
		(
			/*------------------------------------------------------------------------------
				ABOVE POINT ABOVE GROUND - NOT IF RAFT MODE
			--------------------------------------------------------------------------------*/
			pos =  helpers_chain[helpers_chain.count].pos -- get pos of last point above ground

			pos.z = this.Options.base_height -- set knot above ground to set base height and keep last segment straight for extrude

			addKnot spline_shape spline_index #corner #line pos

			pos.z = 0 -- set spline_shape to ground


			/*------------------------------------------------------------------------------
				GROUND POINT
			--------------------------------------------------------------------------------*/
			addKnot spline_shape spline_index #corner #line pos


			/*------ SET MATERIAL TO SEGMENTS ------*/
			num_of_segments = numSegments spline_shape ( numSplines spline_shape)

			for segment_i = 1 to num_of_segments do
				setMaterialID spline_shape spline_index segment_i this.Options.mat_ids[#MIDDLE] -- setMaterialID <splineShape> <spline_index> <seg_index> <matID>

			/*------ SET MATERIAL TO BOTTOM SEGMENT ------*/

			setMaterialID spline_shape spline_index num_of_segments this.Options.mat_ids[#BASE] -- setMaterialID <splineShape> <spline_index> <seg_index> <matID>
		)

		updateShape spline_shape

		spline_shape --return
	),

	/** Remove "-point" of source point helper E.G.: "foo-support-point-12" >>> "foo-support-12"
	 */
	function _getName point_helper_name =
	(
		--format "\n"; print "HelperObject_v._getName()"
		substituteString point_helper_name "-point" ( if raft_mode then "-raft" else "")
	),

	/** Get points hierarchy
	  *
	  * @param Boolean pop_last retrun only last point of hierarchy
	  * @return Array|Point array of  point hierarchy
	 */
	function _getPointsChain master_point pop_last:false =
	(
		--format "\n"; print "SupportObject_v.getPointsTree()"
		--format "MASTER_POINT	= % \n" master_point

		if isValidNode master_point then
		(
			children = #(master_point)

			this._getAllChildPoints(master_point) (children)

			--for child in children do
			--format "child	= % \n" child

			if pop_last then children[children.count] else children --return
		)
		else
			#() --return
	),

	mapped function _getAllChildPoints _node &children = ( if isValidNode _node then ( for child in _node.children where classOf child == Point do append children child ) else return children; if _node.children.count > 0 then this._getAllChildPoints _node.children &children ),

	--mapped function getAllChildren _node &children = ( join children _node.children; if _node.children.count > 0 then this.getAllChildren _node.children &children ),

	/** Shift wirecolor sligtly to +1 - Helper points are shifter -1
	  *
	  *
	  *
	  * Each level of points has different wirecolor for better selection
	  */
	function _shiftWirecolor wirecolor =
	(
		--format "\n"; print "PlatformGenerator_v.shiftWirecolor()"
		--format "WIRECOLOR:	% \n" wirecolor
		i = 1

		wirecolor_shifted = copy wirecolor

		if wirecolor_shifted.r <= 254 then wirecolor_shifted.r += i
		if wirecolor_shifted.g <= 254 then wirecolor_shifted.g += i
		if wirecolor_shifted.b <= 254 then wirecolor_shifted.b += i
		--format "WIRECOLOR_SHIFTED:	% \n" wirecolor_shifted

		wirecolor_shifted --return
	),

	/**
	 */
	on create do
	(
		--format "\n"; print "SupportObject_v.onCreate()"
		--format "Options	= % \n" Options
	)
)