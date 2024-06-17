/** Mesh overlap finder
 */
struct MeshOverlapFinder_v
(
	/* construct */
	obj,
	obj_snap,

	/* required */


	/* properties */
	vol_modifier = Vol__Select level:2 volume:3 type:1,

	selected_faces,

	/* private */
	/* dependency */
	/* reference */
	/* inhered */

	/** Find overlaps
	 */
	function findOverlaps test_objects =
	(
		--format "\n"; print "MeshOverlapFinder_v.findOverlaps()"
		obj_snap = snapshot obj

		addModifier obj_snap vol_modifier

		--for test_obj in test_objects where intersects obj_snap test_obj do
		for test_obj in test_objects do
			this._findOverlaps (test_obj)



		verts_of_faces = meshop.getVertsUsedOnlyByFaces obj_snap (selected_faces as BitArray )

		format "verts_of_faces: %\n" verts_of_faces


		delete obj_snap

		--select obj
		--subobjectLevel = 4
		--
		--
		--setFaceSelection obj.mesh selected_faces


		--select obj.baseObject.mesh.faces[#{277, 279..280, 307..308, 310}]


	),

	private

	/** Find overlaps
	 */
	function _findOverlaps test_obj =
	(
		format "\n"; print "MeshOverlapFinder_v._findOverlaps()"
		format "test_obj: %\n" test_obj

		test_obj_snap = snapshot test_obj

		vol_modifier.node = test_obj_snap


		selected_faces = for i in obj_snap.selectedFaces collect i.index
		--selected_faces = obj_snap.selectedFaces

		selected_poly = meshop.getPolysUsingFace obj_snap (selected_faces as BitArray )


		format "selected_faces: %\n" (selected_faces as BitArray )
		format "selected_poly: %\n" selected_poly

		delete test_obj_snap
	),

	/**
	 */
	on create do
	(
		--format "\n"; print "MeshOverlapFinder.onCreate()"
		--for prop in #(  ) where getProperty this prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of this struct properties necessary to run
		--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof this as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )
	)

)
