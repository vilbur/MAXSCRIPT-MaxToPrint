clearListener(); print("Cleared in:\n"+getSourceFileName())

filein( getFilenamePath(getSourceFileName()) + "/../SupportManager.ms" )	-- "./../SupportManager.ms"


/*------------------------------------------------------------------------------

	 DIFFERENT SETUP OF SCENE UNITS

--------------------------------------------------------------------------------*/

/* UNITS MILLIMETERS */
--units.SystemType	= #millimeters
--units.MetricType	= #millimeters
--EXPORT_SIZE	= 1


/* UNITS MILLIMETERS, DISPLAY CENTIMETERS */
units.SystemType	= #millimeters
units.MetricType	= #centimeters
EXPORT_SIZE	= 1



/* EXPORT SIZE */
--units.SystemType	= #centimeters
--units.MetricType	= #centimeters
--EXPORT_SIZE	= 0.01

/* maust be after EXPORT_SIZE definition */
filein( getFilenamePath(getSourceFileName()) + "/inlcudes/create-test-objects.ms" )	--"./inlcudes/create-test-objects.ms"

/*==============================================================================

		PREPARE SCENE

================================================================================*/

/*------------------------------------------------------------------------------
	CREATE MESH SOURCE OBJECT
--------------------------------------------------------------------------------*/

/* ALL VERTS - NO SELECTION OR VERTEX COLOR */
 --createSourceMesh segments:2
 --createSourceMesh segments:8 obj:#SPHERE
-- createSourceMesh segments:4 obj:#BOX


/* VERTICES SELECTED */
--createSourceMesh segments:256 vertex_selection:#{1..2}
--createSourceMesh segments:256 obj:#SPHERE vertex_selection:#{1..1000}
-- createSourceMesh segments:12 obj:#SPHERE vertex_selection:#{32}


/* VERTEX COLOR */
--createSourceMesh segments:2 vertex_color:orange vertex_selection:#{1..2}
--createSourceMesh segments:12 vertex_color:orange vertex_selection:#{1..6} obj:#SPHERE
createSourceMesh segments:16 obj:#SPHERE vertex_selection:#{1..32} vertex_color:orange


/* TEST ON TRANSFORMED OBJECT - test  of vertex postion */
--createSourceMesh segments:1 test_shifted_pivot:true


/* SPLINE object as source for supports  */
--createSourceSpline()


/* POINTS object as source for supports */
--createSourcePoints()


/*------------------------------------------------------------------------------
	CREATE SPLINE SOURCE OBJECT
--------------------------------------------------------------------------------*/
--createSourceSpline()





/*------------------------------------------------------------------------------
	SET SOURCE OBEJCTS - IMPORTANT: ALL TESTS NEED IT
--------------------------------------------------------------------------------*/
--_source_object = selection as Array
_source_object = objects[1]
format "SOURCE_OBJECTS A: %\n" _source_object



print "---------------- CREATE INSTANCE OF SUPPORT MANAGER ----------------"

--SupportManager 	= SupportManager_v bind_to_parent:true
SupportManager 	= SupportManager_v EXPORT_SIZE:EXPORT_SIZE



print "---------------- CONFIGURE GENERATOR ----------------"

/* renaming source objects and layers are managed without asking */
SupportManager.Options.quiet_mode = true

/* use all normals without angle limit */
SupportManager.Options.normal_limit = false

/* Distance to second point of support or raft */
SupportManager.Options.normal_length = 10




--print "---------------- GENERATE POINTS BY VERTEX COLOR SOURCE OBJECT ----------------"
--
--new_points = SupportManager.generatePointHelpers ( _source_object )
--format "NEW_POINTS	= % \n" new_points

--
--
--
--print "---------------- GENERATE SUPPORTS ----------------"
--
--new_supports = SupportManager.createSupports( new_points )
--format "NEW_SUPPORTS	= % \n" new_supports
--


--
--print "---------------- GENERATE BEAMS ----------------"
--
--SupportManager.Options.max_distance = 100
--
--/* CONNECT ENDS */
--bbeames_connect_ends = SupportManager.createBeams( new_supports )
--
--
--/* CONNECT MIDDLES */
--SupportManager.Options.connect = 2
--beames_connect_middle = SupportManager.createBeams( new_supports )
--
--/* CONNECT IN THIRD OF SUPPORTS HEIGHT */
--SupportManager.Options.connect = 3
--beames_connect_third = SupportManager.createBeams( new_supports )
--
--/* CONNECT IN QUATER OF SUPPORTS HEIGHT */
--SupportManager.Options.connect = 4
--beames_connect_quater = SupportManager.createBeams( new_supports )
--


--
--print "---------------- GENERATE POINTS FROM SELECTED VERTS ----------------"
--
--select _source_object

--selectVertsForTest _source_object #{3..6}
--
--new_points_by_selection = SupportManager.generatePointHelpers ( selection as Array )
--format "NEW_POINTS	= % \n" new_points_by_selection
--
--
--print "---------------- GENERATE RAFTS ----------------"
--
--new_rafts = SupportManager.createSupports( new_points ) raft_mode:true
--format "NEW_RAFTS	= % \n" new_rafts
--
--
--print "---------------- GENERATE RAFTS BEAMS ----------------"
--
--beames_rafts = SupportManager.createBeams( new_rafts )


--
--print "---------------- GENERATE PINS ----------------"
--delete shapes

selectVertsForTest _source_object #{ 1,3,51,62 }
--selectVertsForTest _source_object #{ 51 }
--selectVertsForTest _source_object #{ 62 }

pins = SupportManager.createPins( _source_object )
