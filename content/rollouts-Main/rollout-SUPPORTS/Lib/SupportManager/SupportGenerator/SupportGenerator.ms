/** Support generator
 */
struct SupportGenerator_v
(
	/* construct */
	--point_helpers,

	/* properties */
	--support_objects = #(),

	/* dependency */
	--SupportModifiers	= SupportModifiers_v	Options:Options,

	/* reference */
	/* inhered */
	Options,
	SupportObject, -- --"./../SupportObject/SupportObject.ms"

	/** Create supports
	  *
	  *
	  * @reurn Array of nodes
	 */
	function generateSupports point_helpers =
	(
		--format "\n"; print "SupportGenerator_v.createSupports()"
		--format "point_helpers	= % \n" point_helpers
		--format "POINT_HELPERS	= % \n" point_helpers
		--format "(classOf point_helpers)	= % \n" (classOf point_helpers)

		--for point_helper in point_helpers do
			--format "POINT_HELPER: %\n" point_helper

		supports_created = for vertex_index in sort point_helpers.keys collect
		(
			--format "vertex_index	= % \n" vertex_index
			point_helper = point_helpers[vertex_index]

			/* DELETE OLD SUPPORT (RESET) */
			--this._deleteSupportByHelper( point_helper )

			if ( support = this._getSupportByHelper(point_helper) ) == undefined then
			(
				/* CREATE NEW SUPPORT */
				support = SupportObject.generateSupport( point_helper ) --support_exists:(this._getSupport( point_helper ))

				/* ADD TO LAYER OF POINT OBJECT */
				point_helper.layer.addNode support

				/* ADD TO GORUP OF POINT OBJECT */
				this._addToGroup support point_helper

				/* SET DATA TO USER PROPS OF OBJECT */
				this._saveSyncPointer ( point_helper ) (support)

			)
			else
				SupportObject.updateSupport( support ) ( point_helper )

			support --return
		)

		--for SupportObject in supportObjects collect SupportObject.support
		--if isGroupMember point_helper then
		--format "SOURCE_OBJ.PARENT: %\n" source_obj.parent
			--attachNodesToGroup support point_helper.parent

		/* GET ALL SUPPORTS GENERATED FOR OBJECT */
		--supports_by_object = for helper_data in point_helpers where ( support = this._getSupportByHelper(helper_data.value) ) != undefined collect support

		supports_created --return
	),


	private


	/** Get support by helper
	 */
	function _getSupport point_helper =
	(
		this._getSupportByHelper(point_helper)
	),

	/** Get support by helper
	 */
	function _deleteSupportByHelper point_helper =
	(
		--format "\n"; print "SupportGenerator_v._deleteSupportByHelper()"
		if ( support = this._getSupportByHelper(point_helper) ) != undefined then
			delete support
	),

	/** Save pointer for connection of point and support
	 */
	function _saveSyncPointer point_helper support =
	(
		--format "\n"; print "HelperObject_v.saveUserData()"
		--Options.setProp support #pointer_sync (( Options.getProp point_helper #pointer_sync ) as IntegerPtr )
		Options.syncProp point_helper support #pointer_sync
	),

	/** Get support by helper
	 */
	function _getSupportByHelper point_helper =
	(
		--format "\n"; print "SupportGenerator_v._getSupportByHelper()"

		children = #(point_helper)

		this._getAllChildren(point_helper) (children)

		--supports = for child_data in children where superClassOf child_data.value.baseobject == shape collect child_data.value
		supports = for child in children where superClassOf child.baseobject == shape collect child

		supports[1] --return
	),

	/** Add to group
	 */
	function _addToGroup new_members search_group_obj =
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
		if ( _group = _findGroup search_group_obj ) != undefined then
			attachNodesToGroup new_members _group
	),



	mapped function _getAllChildren _node &children = ( join children _node.children; if _node.children.count > 0 then this._getAllChildren _node.children &children ),

	/**
	 */
	on create do
	(
		--format "\n"; print "SupportGenerator_v.onCreate()"
		--format "Options	= % \n" Options
		SupportObject = SupportObject_v Options:Options
	)
)