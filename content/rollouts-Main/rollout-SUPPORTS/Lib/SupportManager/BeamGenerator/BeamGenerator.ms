/** Beam generator
 */
struct BeamGenerator_v
(
	/* construct */
	supports,

	/* properties */
	same_height	= false, -- Set height of beams on each support

	beams_created = #(),

	--cross_instance = false,  -- obsolete

	/* dependency */
	/* reference */
	/* inhered */
	Options,	--SupportOptions_v()

	/** Create cross section between supports
	  *
	  *
	  */
	function createBeams _supports = --cross_instance:cross_instance =
	(
		format "\n"; print "BeamGenerator_v.createBeams()"
		--format "this.Options.connect: %\n" this.Options.connect
		--format "this.Options.min_height: %\n" this.Options.min_height
		--format "this.Options.max_distance: %\n" this.Options.max_distance
		--format "_supports	= % \n" _supports
		--format "_supports.count	= % \n" _supports.count

		this.supports = _supports

		--beams_created = #()

		this.filterEditSplineObjects()

		if supports.count < 2 then
			return false

		this.sortSupportsByDistance()

		max create mode

		--format "supports.count:	% \n" supports.count
		for i = 1 to supports.count where supports[i + 1] != undefined do
			this._createBeamsBetweenTwoSupports (supports[i]) (supports[i + 1])

		beams_created --return
	),

	/** Update
	 */
	function updateBeams beams =
	(
		format "\n"; print "BeamGenerator_v.updateBeams()"

		supports_all = for obj in objects where superClassOf obj.baseobject == shape and getUserPropVal obj "raft_mode" != undefined collect obj

		for beam in beams do
		(
			support_pointers = getUserPropVal beam "beam_supports"

			support_A = (for support in supports_all where getUserPropVal support "this" == support_pointers[1] collect support)[1]
			support_B = (for support in supports_all where getUserPropVal support "this" == support_pointers[2] collect support)[1]

			if support_A != undefined and support_B != undefined then
				this._createBeamsBetweenTwoSupports (support_A) (support_B) beam:beam
		)
	),

	private

	/** Create beams
	 */
	function _createBeamsBetweenTwoSupports support_A support_B beam: =
	(
		format "\n"; print "BeamGenerator_v._createBeamsBetweenTwoSupports()"

		/** Get posiotion of point on line
		 */
		function getPosOnLine direction point_data offset =
		(
			dir = if direction == #BOTTOM then -1 else 1

			point_data[direction]	+ ( offset	* point_data[#VECTOR] * dir)
		)

		--if same_height then
		--(
		--	/* GET BOTTOM POS WHICH IS UPPER */
		--	pos_bottom_1 = if pos_bottom_1.z > pos_bottom_2.z then pos_bottom_1 else pos_bottom_2
		--	pos_bottom_2 = if pos_bottom_1.z > pos_bottom_2.z then pos_bottom_1 else pos_bottom_2
		--
		--
		--	/* GET TOP POS WHICH IS LOWER */
		--	pos_top_1 = pos_top_2 = if pos_top_1.z > pos_top_2.z then pos_top_1 else pos_top_2
		--)
		beams_created = #()

		if ( support_A == undefined or support_B == undefined ) or  distance support_A.pos support_B.pos > this.Options.max_distance  then
			return beams_created

		point_data_A = this._getSegmentEndPoints(support_A)
		point_data_B = this._getSegmentEndPoints(support_B)


		length_A = distance point_data_A[#BOTTOM] point_data_A[#TOP]
		length_B = distance point_data_B[#BOTTOM] point_data_B[#TOP]

		if length_A < this.Options.min_height and length_B < this.Options.min_height then
			return beams_created

		/* DISTANCE FROM END POINTS */
		offset_A = length_A / this.Options.connect -- Divide by 0|1|3 this.Options.connect:radiobuttons items:#('END', 'MIDDLE', 'QUATER')
		offset_B = length_B / this.Options.connect


		/* BEAM 1 */
		pos_bottom_1  	= getPosOnLine #BOTTOM	point_data_A offset_A
		pos_top_1	= getPosOnLine #TOP	point_data_B offset_B

		/* BEAM 2 */
		pos_bottom_2  	= getPosOnLine #BOTTOM	point_data_B offset_B
		pos_top_2	= getPosOnLine #TOP	point_data_A offset_A


		/* CREATE NEW BEAM */
		if beam == unsupplied then
		(
			this._createBeam support_A support_B pos_bottom_1 pos_top_1

			if this.Options.connect != 2 then
				this._createBeam support_B support_A pos_bottom_2 pos_top_2
		)
		/* UPDATE NEW BEAM */
		else
		(
			deleteSpline beam 1

			this._drawLine (beam) (pos_bottom_1) (pos_top_1)
		)

		--append beams_created new_beam
		--
		--beams_created --return
	),

	/** Get segment point_data
	 */
	function _getSegmentEndPoints support =
	(
		--format "\n"; print "BeamGenerator_v.getSegmentEnds()"
		num_knots	= ( numKnots support )

		/* GET INDEX OF USED POINTS */
		index_bottom	= if ( numSegments support 1) == 1 then 2 else num_knots - 1 -- get second point or second point from end ( above ground point )
		index_top	= index_bottom - 1

		/* GET POSITIONS OF POINTS */
		point_bottom	= getKnotPoint support	1 index_bottom	-- get 2. point from bottom
		point_top	= getKnotPoint support	1 index_top	-- get 1. or 2. point from top

		Dictionary #( #BOTTOM, point_bottom ) #( #TOP, point_top ) #( #VECTOR, normalize (point_bottom - point_top) ) --return
	),

	/** Create beam
	 */
	function _createBeam support_A support_B pos_bottom pos_top =
	(
		--format "\n"; print "BeamGenerator_v._createBeam()"

		new_beam = SplineShape name:(support_A.name + "-beam") wirecolor:(this._shiftWirecolor(support_A.wirecolor) )

		new_beam = this._drawLine (new_beam) (pos_bottom) (pos_top)

		this._addToGroup (new_beam) (support_A)

		new_beam.parent	= support_A
		new_beam.pivot  = new_beam.center


		Options.setProp new_beam #THIS (getHandleByAnim new_beam)

		Options.setProp new_beam #BEAM_SUPPORTS #( Options.getThisPointer (support_A), Options.getThisPointer (support_B) )

		/* COPY MODIFIERS OF PARENT SUPPORT NAME WHICH NAME IS MATCHING: "*BAR*" */
		for i = support_A.modifiers.count to 1 by -1 where matchPattern support_A.modifiers[i].name pattern:"*BAR*" do
			addModifier new_beam support_A.modifiers[i]

		/* GET DISTANCE BETWEEN POINTS */
		--distance_between_points = this.getPointDistance (copy beam_start) (copy beam_end_top )
		--distance_between_points = this.getPointDistance (point_bottom_1) (point_bottom_2 )

		/* CHECK MAX DISTANCE BETWEEN POINTS */
		--if distance_between_points < this.Options.max_distance then
			--new_beam = this._drawLine (support_1) (beam_start) (beam_end_top)

		--new_beam --return
		 --return
	),



	/** Draw line
	 */
	function _drawLine beam_obj start_point end_point =
	(
		--format "\n"; print "BeamGenerator_v.drawLine()"
		cross_spline_id = 1 -- index of spline


		addNewSpline beam_obj

		addKnot beam_obj cross_spline_id #corner #line start_point
		addKnot beam_obj cross_spline_id #corner #line end_point

		setMaterialID beam_obj cross_spline_id 1 this.Options.mat_ids[#BEAM] -- setMaterialID <splineShape> <spline_index> <seg_index> <matID>

		updateShape beam_obj


		--for i = support_A.modifiers.count to 1 by -1 do
		--	addModifier beam_obj support_A.modifiers[i]

		beam_obj --return
	),


	--/** Get distance between points in 2D FROM TOP VIEW
	--  */
	--function getPointDistance point_1 point_2 =
	--(
	--	--format "\n"; print "BeamGenerator_v.getPointDistance()"
	--	--point_1.z = point_2.z = 0 -- get distance in 2D -- COPY OF PARAMETERS IS NEEDED FOR THIS E.G.: point_1_copy = copy point_1
	--
	--	distance point_1 point_2 --return
	--),

	/** Filter edit spline objects
	  *
	  */
	function filterEditSplineObjects =
	(
		for support in supports where superClassOf support.baseobject == shape collect support
	),

	/** Sort supports by distance
	 */
	function sortSupportsByDistance =
	(
		format "\n"; print "BeamGenerator_v.sortSupportsByDistance()"

		supports_positions	= for support in supports collect support.pos
		proccessed_supports 	= #{1..supports.count} * #{}

		next_support_i	= 1
		supports_sorted = #(supports[next_support_i])

		while next_support_i != undefined do
		(
			min_distance = 9999999
			next_support	= supports[next_support_i]
			next_support_pos	= next_support.pos

			proccessed_supports[next_support_i]	= true

			next_support_i = undefined
			--supports_to_search = for i = 1 to supports.count where not proccessed_supports[i] collect i

			for i = 1 to supports.count where not proccessed_supports[i] do
			--if supports_to_search.count > 0 then
			(
				--for i in supports_to_search do
					if (dist = distance next_support_pos supports_positions[i] ) < min_distance then
					(
						min_distance = dist


						--proccessed_supports[i]	= true

						next_support_i = i
					)
			)
			--else
				--next_support_i = undefined

			if next_support_i != undefined then
				append supports_sorted supports[next_support_i]
		)

		--this.supports = makeUniqueArray supports_sorted
		this.supports = supports_sorted
	),

	/** Add to group
	 */
	function _addToGroup support point_helper =
	(
		/** Find group
		 */
		function _findGroup obj =
		(
			--format "\n"; print "SupportGenerator_v.findGroup()"

			if isGroupMember obj then
			(
				while not isGroupHead obj.parent do
					obj = obj.parent

				obj.parent --return
			)
		)

		--format "\n"; print "SupportGenerator_v.addToGroup()"
		if ( _group = _findGroup point_helper ) != undefined then
			attachNodesToGroup support _group
	),

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
		--format "\n"; print "BeamObject.onCreate()"
		--for prop in #(  ) where getProperty this prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of this struct properties necessary to run
		--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof this as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )
	)

)
