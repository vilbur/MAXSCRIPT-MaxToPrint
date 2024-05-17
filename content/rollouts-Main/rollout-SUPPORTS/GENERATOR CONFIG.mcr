/**
  *
  */
macroscript	_print_support_generate_quet
category:	"_3D-Print"
buttontext:	"Quiet Mode"
--toolTip:	"For objects to keep position on export\n\n(Create boxes in corners of print plane to keep exported position)"
icon:	"control:checkbox|across:1|offset:[ 12, 2 ]"
(
	--format "EventFired	= % \n" EventFired
	--(PrinterVolume_v()).createVolume(#box)(ROLLOUT_export.SPIN_export_size.value)
)
