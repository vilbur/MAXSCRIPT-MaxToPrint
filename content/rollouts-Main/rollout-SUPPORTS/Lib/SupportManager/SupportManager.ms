--filein( getFilenamePath(getSourceFileName()) + "/../../../rollout-VERTEX-COLOR/Lib/meshVertToColorVertexConvertor/MeshVertToColorVertexConvertor.ms" )	--"./../rollout-VERTEX-COLOR/Lib/meshVertToColorVertexConvertor/MeshVertToColorVertexConvertor.ms"


--filein( getFilenamePath(getSourceFileName()) + "/../../../rollout-LAYERS/Lib/LayersManager/LayersManager.ms" )	--"./../../../rollout-LAYERS/Lib/LayersManager/LayersManager.ms"

--filein( getFilenamePath(getSourceFileName()) + "/../../../rollout-SELECTION - EDIT POLY/Lib/MeshDataGetter/MeshDataGetter.ms" )	--"./../../../rollout-SELECTION - EDIT POLY/Lib/MeshDataGetter/MeshDataGetter.ms"
--filein( getFilenamePath(getSourceFileName()) + "/../MeshDataGetter/MeshDataGetter.ms" )	--"./../MeshDataGetter/MeshDataGetter.ms"
--filein( getFilenamePath(getSourceFileName()) + "/../../../../../../MAXSCRIPT-viltools3/VilTools/rollouts-Tools/rollout-SELECTION - EDIT POLY/Lib/MeshDataGetter/MeshDataGetter.ms" )	--"./../../../../../../MAXSCRIPT-viltools3/VilTools/rollouts-Tools/rollout-SELECTION - EDIT POLY/Lib/MeshDataGetter/MeshDataGetter.ms"
--filein @"c:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-vilTools3\VilTools\rollouts-Tools\rollout-SELECTION - EDIT POLY\Lib\MeshDataGetter\MeshDataGetter.ms"

--filein( getFilenamePath(getSourceFileName()) + "/../../../rollout-VERTEX SELECTION/Lib/MeshDataGetter/MeshDataGetter.ms" )	--"./../../../rollout-VERTEX SELECTION/Lib/MeshDataGetter/MeshDataGetter.ms"
filein( getFilenamePath(getSourceFileName()) + "/../../../../../Lib/MeshDataGetter/MeshDataGetter.ms" )	--"./../../../../../Lib/MeshDataGetter/MeshDataGetter.ms"

filein( getFilenamePath(getSourceFileName()) + "/ShapeKnotGetter/ShapeKnotGetter.ms" )	--"./ShapeKnotGetter/ShapeKnotGetter.ms"

filein( getFilenamePath(getSourceFileName()) + "/SupportModifiers/SupportModifiers.ms" )	--"./SupportModifiers/SupportModifiers.ms"
filein( getFilenamePath(getSourceFileName()) + "/SupportOptions/SupportOptions.ms" )	--"./SupportOptions/SupportOptions.ms"

filein( getFilenamePath(getSourceFileName()) + "/SourceObject/SourceObject.ms" )	--"./SourceObject/SourceObject.ms"
filein( getFilenamePath(getSourceFileName()) + "/HelperObject/HelperObject.ms" )	--"./HelperObject/HelperObject.ms"
filein( getFilenamePath(getSourceFileName()) + "/SupportObject/SupportObject.ms" )	--"./SupportObject/SupportObject.ms"
--filein( getFilenamePath(getSourceFileName()) + "/BeamObject/BeamObject.ms" )	--"./BeamObject/BeamObject.ms"
filein( getFilenamePath(getSourceFileName()) + "/../../../rollout-PINS/Lib/PinsGenerator.ms" )	--"./../../../rollout-PINS/Lib/PinsGenerator.ms"

filein( getFilenamePath(getSourceFileName()) + "/HelperGenerator/HelperGenerator.ms" )	--"./HelperGenerator/HelperGenerator.ms"
filein( getFilenamePath(getSourceFileName()) + "/SupportGenerator/SupportGenerator.ms" )	--"./SupportGenerator/SupportGenerator.ms"
filein( getFilenamePath(getSourceFileName()) + "/BeamGenerator/BeamGenerator.ms" )	--"./BeamGenerator/BeamGenerator.ms"

--filein( getFilenamePath(getSourceFileName()) + "/MeshOverlapFinder/MeshOverlapFinder.ms" )	--"./MeshOverlapFinder/MeshOverlapFinder.ms"
filein( getFilenamePath(getSourceFileName()) + "/SupportUpdater/SupportUpdater.ms" )	--"./SupportUpdater/SupportUpdater.ms"

/** Support manager
  *
  *  DESCRIPTION OF SUPPORT SYSTEM:
  *			• Objects are linked for easy manipulation. LINK IS NOT REQUIRED
  *
  *			• Objects are linked via user data. Data are saved on: Source object, Master Point, Support|Raft,
  *					Master Point know source object
  *					Support|Raft know source object
  *					Beams knows his 2 supports
  *
  *
  *  HIERARCHY OF OBJECTS:
  *
  *		1) SOURCE OBJECT: Mesh object from which are support points generated. Parent of all objects:
  *					// Used vertices  1) SELECTED verts 2) ALL vertex with colors if nothing selected 3) ALL vertices if selection and colors not exists
  *
  * 			2) MASTER POINT ON TOP OF PLAFTORM - Dispalyed as: #BOX and #CROSS - Main point synced with source object by user prop data.
  *					//  Master poin knows which source object and vert has been used.
  *
  * 				3) NORMAL POINT - Dispalyed as: #BOX : Point aligned with source vertex normal
  *
  * 					3) OTHER POINTS - Dispalyed as: #CROSS - Points defining shape of support linked in chain to each other
  *						//  Support points straight to the ground from last point in chain
  *
  * 					4a) RAFT     Same as support obejct, but ends on last point in chain
  * 					4b) SUPPORT: Line connecting all points in chain.
  *
  *		 					5) BEAM: Cross lines between supports
  *
  *
  *
  *
  * NOTICES: Pointers of objects are changing throught sessions
  *
  * USER PROPS KEYS:
  *	#SOURCE_OBJECT	- Pointer of support source object saved into user props of sources object on first use of support system
  *
  *	#POINTER_SYNC	- #SOURCE_OBJECT Pointer saved to POINTS, SUPPORTS and BEAMS to keep connection with source object. #SOURCE_OBJECT==#POINTER_SYNC
  *
  *	#THIS        	- Pointer of object itself saved on object creation.
  *
  *	#SOURCE_VERT 	- Save index of vert of which was used as origin for point helper
  *
  *	#RAFT_MODE   	- Used on SUPPORTS and RAFTS - Differentiate types of objects
  *
  *	#BEAM_SUPPORTS	- Used on BEAMS - Array of supports pointers which beam connects E.G.: #( 1st_support, 2nd_pointer )
  *
  *
  *
  *
  *
 */
struct SupportManager_v
(
	/* construct */
	export_size,

	/* properties */
	point_helpers_by_objects = Dictionary #string, -- 2DMATRIX - Array of Dictionary #( "source_object_pionter", Dictionary #( integer:vertex_index, node:PointHelper   )   )

	/* dependency */
	Options,

	HelperGenerator,
	SupportGenerator,
	BeamGenerator,

	SupportModifiers,
	PinsGenerator,

	SupportObject = SupportObject_v(),

	/* reference */
	/* inhered */

	/** Generate instanced point helpers from selected verts
	  *
	  *  I LOVE spagetti
	  *
	  */
	function generatePointHelpers source_objects reset_helpers:true =
    (
        format "\n"; print "SupportManager_v.generatePointHelpers()"
		this.Options.init()

		local new_points_by_objects
		--local selected_helpers_by_objects

        local new_points_all = #()
        local source_object_valid	= #()
        --local verts_to_generate	= #{}

		/* GET   */
		local source_object_valid = this.getSourceObjects(source_objects)


		/* IF NEW SOURCE OBJECT IS USED */
		if source_object_valid.count == 0 then
			 source_object_valid = for source_obj in source_objects where superClassOf source_obj == GeometryClass or superClassOf source_obj == shape collect source_obj

		format "SOURCE_OBJECT_VALID: %\n" source_object_valid
		/* GET SELECTED POINT HELPERS and their source obejcts */


		/* GENEARTE POINTS FOR EACH OBJECT - BUG !!!!!!!!!!!!!! - if multiuple objects are selected, then normal does not work properly, coord system should be checked probably */
		if source_object_valid.count > 0 then
			new_points_by_objects = for source_obj in source_object_valid collect
			(
				this._manageNameAndLayer(source_obj)

				all_points_of_object = this.getAllPointsOfObject source_obj
				format "all_points_of_object: %\n" all_points_of_object

				indexes_of_selected_helpers = for vertex_index in (this._fiterSelectedHelpers (all_points_of_object)).keys collect vertex_index
				format "indexes_of_selected_helpers: %\n" indexes_of_selected_helpers
				/* RESET SELECTED POINTS  */
				if not reset_helpers and indexes_of_selected_helpers.count > 0 then
					reset_helpers = indexes_of_selected_helpers as BitArray

				select source_obj -- QUICK WORKAROUND: created Points has differenet direction along vertex normals - IF MUTLIPLE OBJECTS SELECTED, something with "coordsys"

				new_points = HelperGenerator.generatePointHelpers(source_obj)(all_points_of_object) reset_verts:reset_helpers

				join new_points_all new_points
			)

		else
			messageBox "ERROR CREATE SUPPORTS \n\nNot any valid source object is selected" title:"SupportManager"  beep:false

        redrawViews()

		new_points_all --return
	),

	/** Create supports
	 */
	function createSupports source_objects raft_mode:false =
	(
		--format "\n"; print "SupportManager_v.createSupports()"
		this.Options.init()

        new_supports    = #()
        beams_to_update = #()

        SupportModifiers.raft_mode               = raft_mode
        SupportGenerator.SupportObject.raft_mode = raft_mode

		all_beams = for obj in objects where superClassOf obj.baseobject == shape and getUserPropVal obj "beam_supports" != undefined collect obj

		if (helpers_by_source_obj = this.getSourceHelpers(source_objects)).count > 0 then
		(
			/* GENERATE SUPPORTS FOR EACH SOURCE OBJECTS */
			for source_obj_pointer in helpers_by_source_obj.keys do
			(
				new_supports_of_obj =(SupportGenerator.generateSupports(helpers_by_source_obj[source_obj_pointer]))
				--format "NEW_SUPPORTS_OF_OBJ: %\n" new_supports_of_obj

				/* GET ALL SUPPORTS OF SOURCE OBJECTS */
				all_supports_of_obj = this.getSupports pointer_sync:source_obj_pointer
				--format "ALL_SUPPORTS_OF_OBJ: %\n" all_supports_of_obj

				join new_supports new_supports_of_obj

				/* ADD MODIFIER INSTANCES */
				SupportModifiers.addModifiers(all_supports_of_obj) -- SUPPORT OBJECT MUST BE SELECTED TO APPLY MODIFIERS

				pointers_of_new_supports = for new_support in new_supports_of_obj collect getUserPropVal new_support "this"

				/* GET BEAMS OF NEW SUPPORTS */
				for beam in all_beams do
					for pointer_of_supports in getUserPropVal beam "beam_supports" where findItem pointers_of_new_supports pointer_of_supports > 0 do
						append beams_to_update beam
			)

			/* UPDATE BEAMS */
			 BeamGenerator.updateBeams (beams_to_update)

		)
		else
			messageBox "ERROR CREATE SUPPORTS \n\nNot any valid source object selected" title:"SupportManager.ms"  beep:false

		new_supports --return
	),

	/** Create Beams
	  *
	  * Connect any line with cross beams
	 */
	function createBeams _objects =
	(
		format "\n"; print "SupportManager_v.createBeams()"
		this.Options.init()

        beams    = #()
        supports = #()

		_shapes = for obj in _objects where superClassOf obj.baseobject == shape collect obj

		for _shape in _shapes do
			if getUserPropVal _shape "beam_supports" != undefined then
				append beams _shape
			else
				append supports _shape

		format "beams: %\n" beams
		format "supports: %\n" supports


		if supports.count > 0 then
			beams_created = BeamGenerator.createBeams (supports)

		if beams.count > 0 then
			beams_updated = BeamGenerator.updateBeams (beams)


		--else
		--	messageBox "ERROR CREATE BEAMS\n\nNot any valid source object selected" title:"SupportManager.ms"  beep:false

	),

	/** Create pins
	 */
	function createPins source_objects =
	(
		format "\n"; print "SupportManager_v.createPins()"
		source_obj = selection[1]

		new_pins = PinsGenerator.createPins(source_obj)
	),


	/** Find intersections
	 */
	function findIntersections source_objects =
	(
		format "\n"; print "SupportManager_v.findIntersections()"

		local source_objects_valid = this.getSourceObjects(source_objects)

		source_object_valid = source_objects_valid[1]

		source_obj_pointer = this._getPointerOfSourceObject (source_object_valid)
		format "source_obj_pointer: %\n" source_obj_pointer

		all_supports_of_obj = this.getSupports pointer_sync:source_obj_pointer


		format "source_object_valid: %\n" source_object_valid
		format "all_supports_of_obj: %\n" all_supports_of_obj

		MeshOverlapFinder = MeshOverlapFinder_v(source_object_valid)

		MeshOverlapFinder.findOverlaps(all_supports_of_obj)


	),

	/*------------------------------------------------------------------------------

		FIND OBEJCTS BY OBEJCTS OR IN SCENE

	--------------------------------------------------------------------------------*/

	/** GET ALL MASTER POINTS USED BY OBJECT
	  *
	  * @return Dictionary #( KEY:vertex_index VALUE:point_helper )
	 */
	function getAllPointsOfObject source_obj =
	(
		format "\n"; print "SupportManager_v.getAllPointsOfObject()"
		if classOf source_obj == Array then source_obj = source_obj[1]

		/* INIT SET POINTS IF NOT SET */
		if point_helpers_by_objects.keys.count == 0 then
			this._setPointHelpersByObject()

		if ( pointer_sync = this._getPointerOfSourceObject(source_obj) ) != undefined then
			point_helpers_by_objects[pointer_sync as string]
	),



	/** GET MASTER POINTS in scene by objects

		 REMOVE THIS METHOD
	  *
	  * @return Array of 2D Dictionaries #( KEY:sourec_object_pointer VALUE: #( KEY:vertex_index VALUE:helper_point ) ) )
	 */
	function getSourceHelpers objects_array =
	(
		format "\n"; print "SupportManager_v.filterSourceObjects()"

        --SupportObject	= SupportObject_v()
        helpers_of_source_obj	= Dictionary #string

		/* 1)  GET POINT HELPERS FROM SELECTED SOURCE OBJECTS */
		for source_obj in source_objs = this.filterSourceObjects(objects_array) do
			helpers_of_source_obj[this._getPointerOfSourceObject(source_obj)] = this.getAllPointsOfObject(source_obj)


		/* 2) GET HELPERS FROM SELECTED OBJECTS */
		for obj in objects_array where (master_point = HelperGenerator.getMasterPointByObj(obj)) != undefined do
		(
			sync_pointer = Options.getProp master_point #pointer_sync as_string:true

			if not HasDictValue helpers_of_source_obj sync_pointer then
				helpers_of_source_obj[sync_pointer] = Dictionary #integer

			helpers_of_source_obj[sync_pointer][Options.getProp master_point #source_vert ] = master_point
		)

		--for key in helpers_of_source_obj.keys collect helpers_of_source_obj[key]  --return
		helpers_of_source_obj --return
	),


	/** Find source obejct by any object
	  *
	  * @return Array of source objects
	 */
	function getSourceObjects objects_array =
	(
		format "\n"; print "SupportManager_v.filterSourceObjects()"

        --SupportObject	= SupportObject_v()
        source_objects	= this.filterSourceObjects(objects_array)


		/*  GET SOURCE OBEJCTS BY HELPERS */
		for obj in objects_array where (master_point = HelperGenerator.getMasterPointByObj(obj)) != undefined do
		(
			sync_pointer = Options.getProp master_point #pointer_sync

			if ( source_obj = this._getSourceObjectBySyncPointer sync_pointer ) != undefined then
				appendIfUnique source_objects source_obj
		)

		source_objects --return
	),

	/** GET SOURCE OBJECTS by objects
	 */
	function filterSourceObjects source_objects =
	(
		--format "\n"; print "SupportManager_v.filterSourceObjects()"
		for obj in source_objects where this._getPointerOfSourceObject(obj) != undefined collect obj
	),

	/** Fiter selected ohelpers
	 */
	function _fiterSelectedHelpers helpers_by_source_obj =
	(
		format "\n"; print "SupportManager_v.fiterSelectedOhelpers()"
		selected_helpers = Dictionary #integer
		format "helpers_by_source_obj: %\n" helpers_by_source_obj
		if  helpers_by_source_obj != undefined then
			for vertex_index in helpers_by_source_obj.keys where helpers_by_source_obj[vertex_index].isSelected do
				selected_helpers[vertex_index] = helpers_by_source_obj[vertex_index]

		selected_helpers --return
	),


	/** GET SUPPORTS by objects or scene if source_objects:unsupplied
	 */
	function getSupports source_objects: pointer_sync: =
	(
		--format "\n"; print "SupportManager_v.getSupportsBySyncInter()"
		--for _shape in shapes where Options.getProp _shape "pointer_sync" == pointer_sync as string collect _shape
		if source_objects == unsupplied then
			--source_objects = shapes
			source_objects = objects

		if pointer_sync != unsupplied then
			/* GET ALL SUPPORTS */
			for _shape in source_objects where superClassOf _shape.baseobject == shape and Options.getProp _shape #pointer_sync != undefined collect _shape

		else
			/* GET SUPPORTS OF SINGLE OBJECT */
			for _shape in source_objects where superClassOf _shape.baseobject == shape and Options.getProp _shape #pointer_sync == pointer_sync as IntegerPtr  collect _shape
	),


	private

	/** Get source object by sync pointer
	  *
	  * @return node
	 */
	function _getSourceObjectBySyncPointer sync_pointer =
	(
		--format "\n"; print "SupportManager_v._getSourceObjectBySyncPointer()"

		source_objects = this.filterSourceObjects( geometry )
		source_shapes  = this.filterSourceObjects( shapes )

		join source_objects source_shapes

		/* FIND OBJECT MATCHI STRING IN USER PROPS */
		source_objects_by_pointer = for source_obj in source_objects where this._getPointerOfSourceObject (source_obj) == sync_pointer as string collect source_obj


		if isValidNode source_objects_by_pointer[1] then
			source_objects_by_pointer[1] --return
	),


	/** FIND MASTER POINTS IN SCENE AND SAVE THEM BY OBJECT POINTER TO DICTIONARY
	 */
	function _setPointHelpersByObject =
	(
		format "\n"; print "SupportManager_v._setPointHelpersByObject()"

		for _helper in helpers where classOf _helper == Point and ( source_obj_pointer = Options.getProp _helper #pointer_sync as_string:true ) != undefined do
		(
			if point_helpers_by_objects[source_obj_pointer] == undefined then
				point_helpers_by_objects[source_obj_pointer] = Dictionary #integer

			if ( vertex_index = Options.getProp _helper #source_vert ) != undefined then
				point_helpers_by_objects[source_obj_pointer][ vertex_index as integer ] = _helper
		)
	),

	/** Get origin poiter
	 */
	function _getPointerOfSourceObject source_obj =
	(
		--format "\n"; print "SupportManager_v._getPointerOfSourceObject()"
		Options.getProp source_obj #SUPPORTS_SOURCE as_string:true
	),


	/** Manage name and layer
	 */
	function _manageNameAndLayer source_obj =
	(
		--format "\n"; print "SupportManager_v._manageNameAndLayer()"

		local layer

		quiet_mode = Options.quiet_mode

		source_obj_suffix = "support-source"
		layer_name_suffix = "support"

	new_name	= source_obj.name + "-" + source_obj_suffix
	layer_name	= (substituteString source_obj.name source_obj_suffix "" ) + "-" + layer_name_suffix -- remove object suffix and add layer suffix

		/* IF SOURCE OBJECT IS  1st USED, THEN RENAME SOURCE OBEJT AND TO ITS OWN LAYER*/
		if this._getPointerOfSourceObject (source_obj) == undefined \
			and not matchPattern source_obj.name pattern:("*"+source_obj_suffix) and \
			(quiet_mode or queryBox ("Rename source object ?\n\nFROM:\n\n"+source_obj.name + "\n\nTO:\n\n" + new_name ) title:"SupportManager.ms" ) then
			(
				source_obj.name = new_name

				/* ADD TO LAYER */
				if not matchPattern source_obj.layer.name pattern:("*"+layer_name_suffix+"*") and \
					( quiet_mode or queryBox ("MOVE\n\n"+source_obj.name + "\n\nTO LAYER\n\n" + layer_name +" ? " ) title:"SupportManager.ms" ) then
					(
						if ( layer = LayerManager.getLayerFromName layer_name ) == undefined then
						(
							layer = LayerManager.newLayerFromName layer_name

							layer.setParent source_obj.layer
						)

						layer.addnode (source_obj)
					)
			)
	),

	/**
	*/
	on create do
	(
		Options = SupportOptions_v(export_size)

        HelperGenerator  = HelperGenerator_v Options:Options
        SupportGenerator = SupportGenerator_v Options:Options
        SupportModifiers = SupportModifiers_v Options:Options
        BeamGenerator    = BeamGenerator_v Options:Options
        PinsGenerator    = PinsGenerator_v Options:Options
	)
)
