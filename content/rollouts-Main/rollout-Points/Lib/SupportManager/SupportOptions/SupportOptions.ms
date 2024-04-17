/** Support options
 */
struct SupportOptions_v
(
	/* construct */
	export_size = 1,

	_DO_NOT_MODIFY_PROPERTIES = #( #display_units, #export_size, #use_nth_vertex , #chamfer_top, #connect, #second_point_direction ),

	/* POINT GENERATOR OPTIONS */
	use_normals	= true,
	normal_limit	= false,
	keep_down	= true,
	normal_length	= 3,
	keep_down_limit	= 1,

	second_point_direction	= 1,

	use_nth_vertex	= 1,


	/* SUPPORT OBJECT OPTIONS */
	layer_height = 0.05,

	bottom_layers_count = 15,


	/* SUPPORT MODIFIERS */
	bar_width 	= 1.5, -- default width is 1.5mm

	base_height	= 1.0,
	base_width	= 4.0,

	extrude_top	= 0.5,

	chamfer_base = 2,
	chamfer_top	= 5,	-- CHAMFER MIN: 0 - CHAMFER MAX: 10

	--cross_section	= false, -- connect columns of platform with cross beams
	--cross_section_max	= 20,	-- max distance between platforms
	--cross_section_min_height	= 10,	-- generate cross section only if platform is higher than this number

	max_distance	= 20,	-- max distance between platforms
	min_height	= 10,	-- generate cross section only if platform is higher than this number


	/* RAFT OPTIONS */
	raft_width 	= 0.5,

	/* BEAMS OPTIONS */
	connect = 1,

	/* PINS OPTIONS */
	pin_width	= 3.0, -- outter diametter of outter pin
	pin_height	= 5.0, -- outter diametter of outter pin
	pin_gap 	= 0.2, -- size of gap between inner and outter pin


	/* PRIVATE PROPERTIES */
	display_units = 1, -- correct size of platforms, E.g.: IF MODEL IS MADE IN METERS BUT IT IS PRINTED SCALED DOWN TO MILIMETERS

	quiet_mode = false,

	mat_ids	= Dictionary #( #TOP, 1 /* READ-ONLY */ ) #( #MIDDLE, 3 ) #( #BASE, 4 ) #( #BOTTOM, 2 /* READ-ONLY */ ) #( #CHMAFER, 5 ) #( #BEAM, 6 ), -- #top and #bottom are read-only and they are default by Edit Spline

	propkeys = Dictionary	#( #source_object,	"pointer_sync_source" )	\
		#( #source_vert,	"source_vert" )	\
		#( #pointer_sync,	"pointer_sync" )	\
		#( #this,	"this" )	\
		#( #beam_supports,	"beam_supports" )	\
		#( #raft_mode,	"raft_mode" ), -- keys used for node`s user data

	/** Init
	  *
	  */
	function init =
	(
		--format "\n"; print "SupportOptions_v.init()"
		this._setUnitsMuliplier()

		this._setDimensions()

		--format "chamfer_top_divider	= % \n" chamfer_top_divider
	),

	/** Get node prop data
	 */
	function getProp obj key_of_key as_string:false =
	(
		--format "\n"; print "SupportOptions_v.getProp()"
		getUserPropVal obj propkeys[key_of_key] asString:as_string --return
	),

	/** Set node prop data
	 */
	function setProp obj key_of_key val =
	(
		--format "\n"; print "SupportOptions_v.setProp()"
		setUserPropVal obj propkeys[key_of_key] val --return
	),

	/** Set node prop data from node to node
	 */
	function syncProp from_object to_object from_key destination_key: =
	(
		--format "\n"; print "SupportOptions_v.setProp()"
		if destination_key == unsupplied then
			destination_key = from_key

		setUserPropVal to_object propkeys[from_key] ( getUserPropVal from_object propkeys[destination_key] )
	),

	/** Get this pointer
	 */
	function getThisPointer obj =
	(
		--format "\n"; print "SupportOptions_v.getThisPointer()"
		local this_pointer

		if ( this_pointer = this.getProp obj #THIS ) == undefined then
		(
			this_pointer = getHandleByAnim obj

			this.setProp obj #THIS this_pointer
		)

		this_pointer as string --return
	),


	private


	/** Set units muliplier
	  *
	  */
	function _setUnitsMuliplier =
	(
		--format "\n"; print "SupportOptions_v.setUnitsMuliplier()"

		display_units = case units.SystemType of -- convert to milimeters
		--this.display_units = case units.MetricType of -- convert to dispaly units
		(
			#millimeters:	1
			#centimeters:	10
			#meters:	1000
			#kilometers:	1000000
			default:	1 -- non metric units
		)
	),

	/** Set dimensions
	  *
	  */
	function _setDimensions =
	(
		format "\n"; print "SupportOptions_v._setDimensions()"
		--format "DISPLAY_UNITS:	% \n" display_units
		--format "EXPORT_SIZE:	% \n" export_size

		for prop in getPropNames this where ( superClassOf (val = getProperty this prop )) == Number do
			if val != undefined and findItem _DO_NOT_MODIFY_PROPERTIES prop == 0  then
			(
				--format "\n\n"
				--format "val: %\n" val
				modified_val = (val / display_units	/ export_size)
				--format "modified_val: %\n" modified_val
				setProperty this prop modified_val
			)
	),

	/** Set base height
	  *
	  */
	function _setBaseHeight =
	(
		--format "\n"; print "SupportOptions_v._setBaseHeight()"
		base_height = this.bottom_layers_count * this.layer_height / export_size
	),


	/**
	 *
	 */
	on create do
	(
		--format "\n"; print "SupportOptions_v.create()"
		--format "\nIMPORTANT\n"
		--format "EXPORT_SIZE:	% \n" export_size
	)
)
