/** Support modifiers
 */
struct SupportModifiers_v
(

	/* construct */
	Options,
	--mat_ids,

	/* properties */
	supports,
	raft_mode = false,


	/* options */
	chamfer_values = Dictionary(),


	/* dependency */
	/* reference */
	/* inhered */

	/** Add modifiers
	  *
	  */
	function addModifiers supports =
	(
		format "\n"; print "SupportModifiers_v._addModifiers()"
		--format "supports	= % \n" supports
		--format "supports.count	= % \n" supports.count
		this.supports = supports

		this._setChamferValues()

		if not this._modifiersExists() then
		(
			select supports

			this._sanitizeMaxChamferValue()

			max modify mode

			this._addEditSpline()

			this._addSweepModifier("Bar Width") (  if raft_mode then this.Options.raft_width else this.Options.bar_width )

			--format "RAFT_MODE	= % \n" raft_mode
			--format "not raft_mode	= % \n" (not raft_mode)
			if not raft_mode then
			(
				this._selectFace("Select Base")(this.Options.mat_ids[#BASE])

				this._extrude("Extrude Base") (this.Options.base_width)

				this._chamfer("Chamfer Base") (this.chamfer_values[#BASE])
			)


			this._chamfer("Chamfer Bar")  (this.chamfer_values[ if raft_mode then #RAFT else #TOP]) selection_option:#ALL materialoption:( if raft_mode then #OFF else #DIFFERENT )  material_ID:( if raft_mode then this.Options.mat_ids[#MIDDLE] )

			this._selectFace("Select Top Face")(this.Options.mat_ids[ if raft_mode then #MIDDLE else #TOP ]) invert_sel:raft_mode

			this._extrude("Extrude Top")(this.Options.extrude_top)

		)
		else
			this._copyModifiers()
	),

	private

	/** Modifiers exists
	 */
	function _modifiersExists =
	(
		--format "\n"; print "SupportModifiers_v._modifiersExists()"
		(this._getSupportsWithModfiers()).count > 0
	),

	/** Copy modifiers
	 */
	function _copyModifiers =
	(
		--format "\n"; print "SupportModifiers_v._copyModifiers()"

		/* DIRTY CODE - TIME RPOEASSURE */

		support_with_modifiers	= (this._getSupportsWithModfiers())[1]
		support_modifiers	= support_with_modifiers.modifiers
		supports_no_modifiers	= this._getSupportsWithoutModfiers()



		for support_no_modifiers in supports_no_modifiers do
			for i = support_modifiers.count to 1 by -1 do
				addModifierWithLocalData support_no_modifiers support_modifiers[i] support_with_modifiers support_modifiers[i] -- instance the modifier


		--for i = support_modifiers.count to 1 by -1 do
		--	try(
		--			addModifier supports_no_modifiers support_modifiers[i]
		--	)catch()

	),


	/** Get obejcts with modfiers
	 */
	function _getSupportsWithModfiers =
	(
		for obj in supports where obj.modifiers.count > 0 collect obj
	),

	/** Get obejcts with modfiers
	 */
	function _getSupportsWithoutModfiers =
	(
		for obj in supports where obj.modifiers.count == 0 collect obj
	),

	/** Make sure that chamfer value is less then radius
	  */
	function _sanitizeMaxChamferValue =
	(
		--format "\n"; print "PlatformModifiers_v._sanitizeMaxChamferValue()"

		if this.Options.bar_width / 2 == this.Options.chamfer_top then
			this.Options.chamfer_top -= 0.05
	),

	/** Add edit spline
	  *
	  */
	function _addEditSpline =
	(
		format "\n"; print "PlatformModifiers_v._addEditSpline()"
		modPanel.addModToSelection (Edit_Spline ())
	),

	/** SWEEP Modifier
	  *
	  */
	function _addSweepModifier name diameter =
	(
		format "\n"; print "SupportModifiers_v._addSweepModifier()"

		/** Reset mod prpertis -- sweep mpdofoer keeps its settings if newly created, i dont know why.. oteh modifiers dont do that :D

			QUICK SOLUTION - FOR MORE MODIFIERS OR PROPERTIES SHOULD COMPLEX SOLUTUION EXISTS

		 */
		function resetSeepModPrpertis sweep_mod =
		(
			sweep_mod.MirrorXZPlane = off
			sweep_mod.MirrorXYPlane = off

			sweep_mod.XOffset = 0
			sweep_mod.yOffset = 0

			sweep_mod.angle = 0
			sweep_mod.SmoothSection = off
			sweep_mod.SmoothPath = off
			sweep_mod.PivotAlignment = 4


			sweep_mod.GenMatIDs = on
			sweep_mod.UseSectionIDs = off
			sweep_mod.UsePathIDs = off
		)

		sweep_mod = sweep name:name

		resetSeepModPrpertis (sweep_mod)

		modPanel.addModToSelection ( sweep_mod ) --ui:on

		sweep_mod.CurrentBuiltInShape = 4 -- Set cylinder

		redrawViews() -- IMPORTANT TO UPDATE AFTER SETTING SHAPE AND BEFORE EDITING ITS PROPERTIES

		sweep_mod[#Cylinder_Section].radius	= diameter / 2
		sweep_mod[#Cylinder_Section].steps	= 6 -- Interpolation

		--sweep_mod[#Bar_Section].cornerRadius = 0

		/* GENERATE MATERIAL ID */
		sweep_mod.UseSectionIDs	= false
		sweep_mod.UsePathIDs	= true

	),

	/** Add SELECT modifier
	  *
	  */
	function _selectFace name mat_id invert_sel:false =
	(
		format "\n"; print "SupportModifiers_v._selectFace()"
		--format "Adding Volume Select\n"

		volume_sel_mod = Vol__Select name:name

		volume_sel_mod.level	= 2	-- select face
		volume_sel_mod.volume	= 5	-- select by material ID
		volume_sel_mod.matID	= mat_id	-- select face by mat ID
		volume_sel_mod.invert	= invert_sel	-- select face by mat ID

		modPanel.addModToSelection ( volume_sel_mod ) --ui:on
	),

	/** Chamfer
	  *
	  *
	  * @param #DIFFERENT|#OFF materialoption
	  */
	function _chamfer name amount selection_option:#STACK materialoption:#OFF material_ID: /* minangle:  */ =
	(
		format "\n"; print "SupportModifiers_v._chamfer()"
		--format "%:	% \n" name amount

		chamfer_mod = Chamfer name:name

		chamfer_mod.selectionoption = case selection_option of
		(
			#STACK:	0 -- from stack
			#ALL:	5 -- all edges
		)

		/* SET CHAMFER VALUES */
		chamfer_mod.amount 	 = amount

		chamfer_mod.segments = 0

		/* UNSMOOTH OBJECT */
		chamfer_mod.smooth 	= true

		chamfer_mod.SmoothType = 0

		chamfer_mod.smooththreshold = 0

		chamfer_mod.materialoption = case materialoption of -- CHAMFER MATERIAL
									(
										#OFF:	0 -- mat_ids off
										#DIFFERENT:	1 -- different mat_ids
									)
		/* ALLOW MATERIAL */
		chamfer_mod.setmaterial	= classOf material_ID == integer


		/* ASSIGN CHAMFER MATERIAL */
		if classOf material_ID == integer then
			chamfer_mod.materialID	= material_ID

		/* BACKUP MAYBE IT WILL BE NEEDE NEEDED

			--chamfer_mod.minangle = minangle

		*/

		modPanel.addModToSelection ( chamfer_mod ) --ui:on
	),

	/** Set chamfer values, derivated from bar width
	  *
	  */
	function _setChamferValues =
	(
		--format "\n"; print "SupportOptions_v._setChamferValues()"
		--format "base_height	= % \n" base_height
		--format "chamfer_top	= % \n" chamfer_top
		this.chamfer_values[#BASE]	= this.Options.base_height / 2
		this.chamfer_values[#TOP]	= (this.Options.bar_width / 2 / 10) * this.Options.chamfer_top -- chamfer in steps between 0-10
		this.chamfer_values[#RAFT]	= (this.Options.raft_width / 2 / 10) * this.Options.chamfer_top

		--format "this.chamfer_values: %\n" this.chamfer_values

	),

	/** Add extrude modifier
	  *
	  */
	function _extrude name amount scale: =
	(
		format "\n"; print "SupportModifiers_v._extrudeBase()"
		extrude_mod = Face_Extrude name:name

		extrude_mod.amount	= amount

		--if scale != unsupplied then
			--extrude_mod.scale	= scale

		modPanel.addModToSelection ( extrude_mod ) --ui:on
	),


	/**
	 */
	on create do
	(
		--format "\n"; print "PlatformModifiers.onCreate()"
		--for prop in #(  ) where getProperty this prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of this struct properties necessary to run
		--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof this as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )

	)
)
