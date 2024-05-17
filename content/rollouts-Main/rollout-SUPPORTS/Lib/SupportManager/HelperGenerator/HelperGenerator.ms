/** Helper generator
 */
struct HelperGenerator_v
(
	/* construct */

	/* properties */
	source_obj,
	point_helpers,
	verts_data,


	/* dependency */
	/* reference */
	/* inhered */
	Options,

	/** Generate instanced point helpers from selected verts
	  *
	  * @param node	source_obj	to generate from
	  * @param Dictionary	point_helpers	which allready exists #( KEY:vertex_index VALUE:node )
	  * @param Boolean|BitArray	reset_verts of vertex indexes to generate
	  *			TRUE:	All points will be generated, existing will be reseted
	  *			FASLE:	New points or missing points from selected or colored verts will be generated. Point which esits will be left as it is
	  *			BitArray: vertex indexes to generated ( way how to reset selected helpers )
	  *
	  *
	  *
	  * @return Array of new created helpers
	  */
	function generatePointHelpers source_obj point_helpers_of_object reset_verts:true =
	(
		format "\n"; print "HelperGenerator_v.generatePointHelpers()"
		--format "source_obj	= % \n" source_obj
		--format "point_helpers_of_object	= % \n" point_helpers_of_object
		--format "RESET_HELPERS: %\n" reset_verts

		--function getWireColor source_obj wirecolor = if wirecolor != white then wirecolor else source_obj.wirecolor
		point_helpers_new = #()

		this.source_obj = source_obj

		/* IF ANY POINT HELEPER NOT EXIST YET */
		this.point_helpers = if point_helpers_of_object != undefined then point_helpers_of_object else Dictionary #integer -- Dictionary #( vert_number, point_helper ) -- all point  helpers of of source obejct

		/* IF USER CANCEL GETTIN DATA */
		--if ( this.verts_data = this._getVertsData() ) == undefined then
			--return point_helpers_new
		this.verts_data = this._getVertsData()

		/* FIND VERTS if not defined */
		--if verts_to_generate.numberSet == 0 and reset_verts then
			--verts_to_generate = this._getVertsToGenerateFromObjects (reset_verts)

		verts_to_generate = if classOf reset_verts == BooleanClass then
								this._getVertsToGenerateFromObjects (reset_verts)
							else
								reset_verts

		format "VERTS_TO_GENERATE: %\n" verts_to_generate
		format "verts_data[#VERTS]: %\n" verts_data[#VERTS]
		format "verts_data[#POSITIONS]: %\n" verts_data[#POSITIONS]
		format "verts_data[#NORMALS]: %\n" verts_data[#NORMALS]
		format "verts_data[#COLORS]: %\n" verts_data[#COLORS]


		if verts_to_generate.numberSet > 0 then
		(
			/* SET USER PROP DATA - MUST BE SET BEFORE HELEPRS CREATION*/
			if verts_to_generate.count > 0 then
				this._setUserDataToSourceObject(source_obj)


			/* GENERATE POINTS FOR EACH VERTEX */ -- TODO: loop should has its own method
			for vertex_index in verts_to_generate do
			(
				data_index	= findItem ( verts_data[#VERTS] as Array ) vertex_index -- find vertex in all verts data
				--format "vertex_index: %\n" vertex_index
				--format "data_index: %\n" data_index

				HelperObject = HelperObject_v \
									Options:Options	\
									source_obj:source_obj	\
									vertex_index:vertex_index	\
									pos:verts_data[#POSITIONS][data_index]	\
									normal:verts_data[#NORMALS][data_index]	\
									old_points:(this._getOldPointsChain(vertex_index))	\
									wirecolor:(this._getWireColor(verts_data[#COLORS])(vertex_index))	\ --point_helper:point_helpers[verts_to_generate[i]] -- get point helepr by vertex number



				if ( point_new = HelperObject.createHelper() ) != undefined then
				(
					this.point_helpers[vertex_index] = point_new -- IF POINT IS NOT CREATED, THEN VALUE IS undefined, so failed ponts can be managed too

					append point_helpers_new point_new
				)
			)

			/* REINSTANCE ALL POINTS PER OBEJCT */
			if point_helpers_new.count > 0 then
				this._reinstancePointByLevel(point_helpers_new)
		)
		else
			messageBox "NO POINT HELPER HAS BEEN GENERATED" title:"HelperGenerator"

		gc()

		point_helpers_new --return
	),

	/** Find masterpoin by any object in chain
	 */
	function getMasterPointByObj obj =
	(
		--format "\n"; print "HelperGenerator_v.getMasterPointByObj()"

		while obj.parent != undefined and classOf obj.parent == Point do
			obj = obj.parent

		if (getUserPropVal obj "pointer_sync") != undefined then -- test if point is from support system
			obj --return
	),

	private

	/** Set vers data
	 */
	function _getVertsData =
	(
		--format "\n"; print "HelperGenerator_v.setVersData()"
		if superClassOf source_obj != shape then
			/* GET DATA FROM MESH */
			(MeshDataGetter_v(source_obj)).getVertexData verts:#ALL_OR_SELECTED positions:true colors:true normals:true
		else
			/* GET DATA FROM SHAPE */
			(ShapeKnotGetter_v(source_obj)(Options.use_nth_vertex)).getVetexData() -- SHAPE OBJECT
	),

	/** Get verts to generate from objects
	 */
	function _getVertsToGenerateFromObjects reset_verts =
	(
		--format "\n"; print "HelperGenerator_v._getVertsToGenerateFromObjects()"
		--format "this.point_helpers: %\n" this.point_helpers
		--format "this.point_helpers.keys: %\n" this.point_helpers.keys
		function helperExists vertex_index = this.point_helpers[vertex_index] != undefined

		/* FILTER EXISTING VERTS */
		--if not reset_verts then
		--	(for vertex_index in this.verts_data[#VERTS] where not helperExists(vertex_index) collect vertex_index) as BitArray  --return
		--else
			verts_data[#VERTS]  --return
	),

	/** set current pointer to source object
	  *
	  * BECAUSE POINTER IS CHANGI EACH TIME IS CENE LOADED
	 */
	function _setUserDataToSourceObject source_obj =
	(
		--format "\n"; print "HelperGenerator_v._setUserDataToSourceObject()"
		if (Options.getProp source_obj #source_object ) == undefined then
			 Options.setProp source_obj #source_object (getHandleByAnim source_obj )
	),

	/** Reinstance helper points
	  *
	  * Each level of points is different instance
	  *
	  */
	function _reinstancePointByLevel point_helpers_new =
	(
		--format "\n"; print "HelperGenerator_v._reinstancePointByLevel()"
		fn helpersInSameLevel point_chains i = for point_level in point_chains where point_level[i] != undefined and isValidNode point_level[i] collect point_level[i]

		--point_chains = for vertex_index in point_helpers.keys collect this._getPointsChain( point_helpers[vertex_index] )
		point_chains	= for point_helper in point_helpers_new collect this._getPointsChain( point_helper )
		point_chains_max	= amax (for point_chain in point_chains collect point_chain.count)

		/* GET OLD CHAIN OF OLD POINTS - to get mster objects for reinstancing */
		old_points = for key in point_helpers.keys where findItem point_helpers_new point_helpers[key] == 0 collect point_helpers[key]

		 master_chain =  if old_points.count > 0 then
		 (
			point_chains_old = for point_helper in old_points collect this._getPointsChain( point_helper )

			max_count_old	= amax (for point_chain in point_chains_old collect point_chain.count) -- get max count of arrays

			master_chain = (for point_chain in point_chains_old where point_chain.count = max_count_old collect point_chain)[1] -- get array with max count

			for i = 1 to point_chains[1].count where master_chain[i] == undefined do master_chain[i] = point_chains[1][i] -- fill missing old points with new points ( if new points has more points in chain then old )

			master_chain --return
		 )
		 else
			point_chains[1]


		if point_chains_max != undefined then
			for i = 1 to point_chains_max do
				this._reinstancePoint( helpersInSameLevel(point_chains)(i) ) master_chain[i]
	),

	/** Reinstance points
	  */
	function _reinstancePoint for_replace master_object =
	(
		--format "\n"; print "HelperGenerator_v._reinstancePoint()"
		if for_replace.count < 2 then
			return false

		max create mode

		if  master_object != undefined then
			for _point in for_replace where _point != master_object do
				_point.baseobject = master_object.baseobject
	),



	/** Get old point
	 */
	function _getOldPointsChain vertex_index =
	(
		--format "\n"; print "HelperGenerator_v._getOldPoint()"
		children = #()

		if ( old_point = point_helpers[vertex_index] ) != undefined then
		(
			append children old_point

			this._getAllChildPoints (old_point) (children)
		)

		children --return
	),

	/* USE OBJECT WIRE COLOR IF VERTEX COLOR IS WHITE
	*/
	function _getWireColor wirecolors vertex_index =
	(
		--format "\n"; print "HelperGenerator_v._getWireColor()"
		--format "wirecolors: %\n" wirecolors

		vertex_colors = for clr in wirecolors.keys where wirecolors[clr][vertex_index] collect execute clr
		--format "vertex_colors: %\n" vertex_colors

		--if classOf vertex_colors =  == Array then wirecolor = wirecolor[1]

		 if vertex_colors.count > 0 then vertex_colors[1] else this.source_obj.wirecolor --return
	),

	/** Get point chains
	 */
	function _getPointsChain point_helper =
	(
		--format "\n"; print "HelperGenerator_v.getPointTrees()"
		children = #()

		if isValidNode point_helper then
		(
			children = #(point_helper)

			this._getAllChildPoints(point_helper) (children)
		)

		children --return
	),

	mapped function _getAllChildPoints _node &children = ( if isValidNode _node then ( for child in _node.children where classOf child == Point do append children child ) else return children; if _node.children.count > 0 then this._getAllChildPoints _node.children &children ),

	--mapped function _getAllChildren _node &children = ( join children _node.children; if _node.children.count > 0 then this._getAllChildren _node.children &children ),
	mapped function _getAllChildren _node &children = ( if isValidNode _node then join children _node.children else return children; if _node.children.count > 0 then this._getAllChildren _node.children &children ),

	/**
	 */
	on create do
	(
		--format "\n"; print "HelperGenerator.onCreate()"
		--for prop in #(  ) where getProperty this prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of this struct properties necessary to run
		--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof this as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )
	)

)
