
/** Get platform generator instance
  *
  */
function getPlatformGeneratorInstance =
(
	--format "\n"; print "PLATFORMS GENERATOR.mcr.getPlatformGeneratorInstance()"
	PlatformGenerator = PlatformGenerator_v export_size:ROLLOUT_export.SPIN_export_size.value use_every_nth_vert_of_spline:ROLLOUT_print_3d.SPIN_use_nth_vertex.value


	PlatformGenerator.Options.base_extrude	= ROLLOUT_print_3d.SPIN_base_width.value
	PlatformGenerator.Options.extrude_top	= ROLLOUT_print_3d.SPIN_top_extrude.value

	PlatformGenerator.Options.layer_height	= ROLLOUT_print_3d.SPIN_layer_height.value
	PlatformGenerator.Options.bar_width	= ROLLOUT_print_3d.SPIN_bar_width.value
	PlatformGenerator.Options.chamfer_top_divider	= ROLLOUT_print_3d.SPIN_top_chamfer_multiplier.value
	PlatformGenerator.Options.normal_length	= ROLLOUT_print_3d.SPIN_normal_length.value

	PlatformGenerator.Options.cross_section	= ROLLOUT_print_3d.CBX_cross_section.state
	PlatformGenerator.Options.cross_section_max	= ROLLOUT_print_3d.SPIN_max_distance.value


	PlatformGenerator --return
)