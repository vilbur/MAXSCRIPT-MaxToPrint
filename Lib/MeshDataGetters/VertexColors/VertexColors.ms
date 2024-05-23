filein( getFilenamePath(getSourceFileName()) + "/MeshVertToColorVertexConvertor/MeshVertToColorVertexConvertor.ms" )	--"./MeshVertToColorVertexConvertor/MeshVertToColorVertexConvertor.ms"
filein( getFilenamePath(getSourceFileName()) + "/ConvexVertFinder/ConvexVertFinder.ms" )	--"./ConvexVertFinder/ConvexVertFinder.ms"
/** Vertex colors getter
 */
struct VertexColors_v
(
	/* construct */
	obj,

	/* required */


	/* properties */
	colors 	= Dictionary #STRING,

	/* private */
	/* dependency */
	MeshVertToColorVertexConvert,
	ConvexVertFinder,


	/* reference */
	/* inhered */

	/** Set vertex colors Ditionary
	  *
	  * SINGLE MESH VERT CAN APPEAR IN MULTIPLE COLORS - Each map vert can has its own color
	  *
	  * NOTES:
	  *		1) getvertcolor()	INPUT CPV vertex
	  *		2) getVertsByColor()	RETURN MESH VERTEX
	  *
	  *
	  * KNOWING ISSUE: remove_multi_colored_verts_from_white
	  *				If vertex has mutliple colors, then first is used, include white color.
	  *				Only way to make it work seem to iterate all map verts. THIS IS OVERKIL FOR SUCH SIPMPLE OPARTION ON HIGH VERTEX COUNT OBJECTS... MAX SUCKS !
	  *
	  * @param boolean remove_multi_colored_verts_from_white TRUE: collect first non white color | FALSE: collect all colors for vert ( mesh vert is occuring in muliple colors )
	  *
	  * @return Dictionary of BitArrays of mesh verts sorted by color E.G.: #( "color 255 255 255", #{1..999}  )  #( "color 0 255 255", #{1..3}  )
	  */
	function getAllColors =
	(
		format "\n"; print "MeshDataGetter_v._getVertexColors()"
		/** Loop map verts of single mesh vert
		  *
		  * Test if vertex color is new
		  *
		  * @retrun color of map vertex
		 */
		function _searchNewVertexColor colors map_verts =
		(
			--format "\n"; print "MeshDataGetter_v._searchNewVertexColor()"
			--format "map_verts: %\n" map_verts
			--format "this.colors: %\n" this.colors
			--format "COLOR: %\n" (getvertcolor obj.mesh map_verts[1])
			local color_of_vert

			i = 1
			while map_verts[i] != undefined and hasDictValue colors ( (color_of_vert = getvertcolor obj.mesh map_verts[i]) as string )  do
				i += 1

			color_of_vert --return
		)

		/** White verts exists
		 */
		function whiteVertsExists colors = hasDictValue colors ( white as string )


		local white_clr = white as string

		local color_of_vert


		/* IF VERTEX COLORS EXISTS */
		if  (getNumCPVVerts obj.mesh != 0) then
		(
			MeshVertToColorVertexConvert.get_single_vert = false

			verts_get_colors = #{1..(getNumVerts obj.mesh)}

			while not verts_get_colors.isEmpty do
			(
				mesh_vert = ( verts_get_colors as Array )[1]

				map_verts_of_mesh_vert = makeUniqueArray (MeshVertToColorVertexConvert.meshVertsToMapVerts (mesh_vert) flat:true )

				color_of_vert = _searchNewVertexColor (colors) (map_verts_of_mesh_vert)

				mesh_verts_by_color = meshop.getVertsByColor obj.mesh color_of_vert 0.01 0.01 0.01 	-- get all verts by thath color

				colors[ color_of_vert as string ] = mesh_verts_by_color

				verts_get_colors -= mesh_verts_by_color
			)

			/* REMOVE MULTI COLORED VERTS FROM WHITE - (if one of vert colors is not white, then vert is not white) */
			if whiteVertsExists(colors) then
				for clr in colors.keys  where clr != white_clr do
					colors[white_clr] -= colors[clr]
		)

		colors --return
	),

	/** Get colors of selected verts
	 */
	function getColorsOfSelectedVerts =
	(
		format "\n"; print "VertexColors_v.getColorsOfSelectedVerts()"

		selected_colors = #()

		if colors.count == 0 then
			this.getAllColors()

		vertex_sel	= getVertSelection obj.mesh --else #{} -- ignore vertex selection if not suobject level active

		for clr in colors.keys where (colors[clr] * vertex_sel).numberSet > 0 collect execute clr

	),

	private


	/**
	 */
	on create do
	(
		--format "\n"; print "VertexColorsGetter.onCreate()"
		ConvexVertFinder	= ConvexVertFinder_v(obj)
		MeshVertToColorVertexConvert	= MeshVertToColorVertexConvertor_v(obj)
	)

)
