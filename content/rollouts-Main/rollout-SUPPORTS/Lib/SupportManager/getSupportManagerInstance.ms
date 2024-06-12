filein( getFilenamePath(getSourceFileName()) + "/SupportManager.ms" )	--"./SupportManager.ms"

/** GET INSTANCE OF SUPPORT GENERATOR
  *
  */
function getSupportManagerInstance _rollout =
(
	/** Reg ex replace
	 */
	function regExReplace _string search _replace = ( dotNetObject "System.Text.RegularExpressions.Regex" search ).Replace ( _string as string ) _replace


	export_size = if ROLLOUT_export == undefined then
	(
		format "\n============= WARNING =============\n"

		print "VilTools Exporter does not exists"
		print "Export Size 1 is used"

		1 --return
	)
	else
	  ROLLOUT_export.SPIN_export_size.value


	SupportManager = SupportManager_v export_size:export_size --use_every_nth_vert_of_spline:ROLLOUT_print_3d.SPIN_use_nth_vertex.value

	control_type_to_fetch_values = "SPIN|CBX|RB"

	/** FILL SupportManager PROPERTIES WITH DATA FROM UI
	  *
	  * Perform kind of this in loop:
	  *   Options.base_extrude	= roll.SPIN_base_width.value
	  */
	for ctrl in _rollout.controls where (prop_key = regExReplace ctrl.name ("^("+control_type_to_fetch_values+")_") "") != undefined and hasProperty SupportManager.Options prop_key do
		SupportManager.Options.setOptionValue prop_key ( if classOf ctrl == CheckBoxControl or classOf ctrl == RadioControl  then ctrl.state else ctrl.value )

    --SupportManager.BeamGenerator.same_height	= _rollout.CBX_same_height.state

	--SupportManager.Options.init()

	SupportManager --return
)
