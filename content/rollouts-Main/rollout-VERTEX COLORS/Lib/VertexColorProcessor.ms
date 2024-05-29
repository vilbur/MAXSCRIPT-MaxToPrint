( getFilenamePath(getSourceFileName()) + "/../../../../Lib/MeshDataGetters/VertexColors/VertexColors.ms" )	--"./../../../../Lib/MeshDataGetters/VertexColors/VertexColors.ms"

/** Vertex color processor
 */
struct VertexColorProcessor_v
(
	/* construct */
	obj,

	/* required */

	/* properties */
	curr_mod,


	/* private */
	/* dependency */
	VertexColors,
	MeshVertToColorVertexConvert,

	/* reference */
	/* inhered */

	/** Set vertex color
	 */
	function setVertexColor verts clr =
	(
		format "\n"; print "VertexColors_v.setVertexColor()"
		format "verts: %\n" verts

		verts_base = this._getBaseObjectVerts(verts)
		format "verts_base: %\n" verts_base

		map_verts = makeUniqueArray (MeshVertToColorVertexConvert.meshVertsToMapVerts (verts_base) flat:true )
		format "map_verts: %\n" map_verts
		polyop.setVertColor obj.baseobject 0 map_verts clr
	),

	/** Process operation on verts by vertex color
	 */
	function byColor method colors =
	(
		format "\n"; print "VertexColorProcessor_v.byColor()"

		verts_by_colors = #{}

		all_verts_by_colors = VertexColors.getVertsAndColors()

		if classOf colors != Array then colors = #(colors)

		for clr in colors where (verts_of_color = all_verts_by_colors[ clr as string ]) != undefined do
			verts_by_colors += verts_of_color

		this._callMethod (method) (verts_by_colors)
	),

	/** Process operation on verts by vertex color of given verts
	 */
	function byVerts method verts =
	(
		format "\n"; print "VertexColorProcessor_v.byVerts()"

		verts_by_colors = #{}

		all_verts_by_colors = VertexColors.getVertsAndColors()

		for clr in all_verts_by_colors.keys where not ( all_verts_by_colors[clr] * verts ).isEmpty do
			verts_by_colors += all_verts_by_colors[clr]

		this._callMethod (method) (verts_by_colors)
	),

	private

	/** Call method
	 */
	function _callMethod method verts =
	(
		--format "\n"; print "VertexColorProcessor_v._callMethod()"

		subObjectLevel = 1

		case method of
		(
			 #SELECT:	this._selectVerts	(verts)
			 #HIDE:	this._hideVerts	(verts)
			 #UNHIDE:	this._unhideVerts	(verts)
			 #ISOLATE:	this._isolateVerts	(verts)
		)


	),

	/**  hide verts
	 */
	function _hideVerts verts =
	(
		--format "\n"; print "VertexColorProcessor_v._HideVerts()"

		if classOf curr_mod == Edit_Poly then
		(
			curr_mod.SetSelection #VERTEX #{}

			curr_mod.Select #VERTEX verts

			curr_mod.ButtonOp #HideVertex
		)
		else if classOf curr_mod  == Editable_Poly then
			polyop.setHiddenVerts curr_mod verts

	),

	/**  unhide verts
	 */
	function _unhideVerts verts_unhide =
	(
		format "\n"; print "VertexColorProcessor_v._unhideVerts()"

		if classOf curr_mod == Edit_Poly then
		(
			verts_all	= #{1..( getNumVerts obj.mesh)}

			curr_mod.SetSelection #VERTEX verts_all

			visible_verts	= curr_mod.GetSelection #Vertex

			hidden_verts = verts_all - visible_verts

			curr_mod.ButtonOp #UnhideAllVertex

			curr_mod.SetSelection #VERTEX #{}

			curr_mod.Select #VERTEX (hidden_verts - verts_unhide)

			curr_mod.ButtonOp #HideVertex
		)
		else if classOf curr_mod  == Editable_Poly then
		(
			--verts_all	= #{1..( getNumVerts obj.mesh)} as Array
			vertex_sel	= getVertSelection obj.mesh

			hidden_verts = 	polyop.getHiddenVerts obj

			polyop.unHideAllVerts obj

			polyop.setHiddenVerts obj ( hidden_verts - verts_unhide )
		)

	),

	/**  hide verts
	 */
	function _isolateVerts isolate_verts =
	(
		--format "\n"; print "VertexColorProcessor_v._HideVerts()"
		verts_all	= #{1..( getNumVerts obj.mesh)}

		if classOf curr_mod == Edit_Poly then
			curr_mod.ButtonOp #UnhideAllVertex

		else if classOf curr_mod  == Editable_Poly then
			polyop.unHideAllVerts obj

		this._hideVerts( verts_all - isolate_verts )

	),
	/** Test map verts
	 */
	function prepareObject =
	(
		format "\n"; print "VertexColors_v.prepareObject()"
		--format "TEST: %\n" ( polyop.getMapSupport obj 0)

		if not polyop.getMapSupport obj 0 then
		(
			polyop.setMapSupport obj 0 true

			subObjectLevel = 1
		)

		--verts_count	= polyop.getNumVerts obj.baseObject
		--
		--verts_count_VC	= polyop.getNumMapVerts obj.baseObject 0

		--
		--if verts_count == verts_count_VC then
		--

	),

	/** Pass vertex selection to editable poly
	  *
	  * 1) Get selected verts in modifier like Edit Poly|Poly Select
	  * 2) Find same vertex by position in Editable Poly baseobject
	  *
	  * #return BitArray of vertex indexes of Editable Poly Baseobject
	 */
	function _getBaseObjectVerts verts =
	(
		--format "\n"; print ".getBaseObjectVerts ()"

		if classof curr_mod != Editable_Poly then
		(
			verts_all	= #{1..( getNumVerts obj.mesh)} as Array
			verts_all_base	= #{1..( polyop.getNumVerts obj.baseobject)} as Array

			verts_sel_pos = #()

			verts_baseobject = #()

			verts_pos_baseobjects = polyop.getVerts obj.baseobject verts_all_base node:obj

			if verts.count > 0 then
			(
				verts_sel_pos  = polyop.getVerts obj verts node:obj
				--format "VERTS_SEL_POS	= % \n" VERTS_SEL_POS

				for vert_pos in verts_sel_pos where (index = findItem verts_pos_baseobjects (vert_pos)) > 0 do
					append verts_baseobject index
			)

			verts_baseobject --return
		)
		else
			verts --return
	),
	/** Select final selection
	 */
	function _selectVerts sel_bitarray =
	(
		format "\n"; print "VertSelector_v.selectVerts()"
		format "sel_bitarray: %\n" sel_bitarray
		format "classOf curr_mod: %\n" (classOf curr_mod)
		--max modify mode
		--subObjectLevel = 1

		curr_mod.SetSelection #VERTEX #{}

		if classOf curr_mod == Edit_Poly then
			curr_mod.Select #VERTEX sel_bitarray

		else if classOf curr_mod  == Editable_Poly then
			curr_mod.SetSelection #VERTEX sel_bitarray
	),

	/**
	 */
	on create do
	(
		curr_mod	= modPanel.getCurrentObject()

		this.prepareObject()

		VertexColors	= VertexColors_v(obj.baseobject)
		MeshVertToColorVertexConvert	= MeshVertToColorVertexConvertor_v(obj)

		VertexColors.MeshVertToColorVertexConvert = MeshVertToColorVertexConvert
	)

)
