/** Set print elevation
  *
  */
function getPlaneZpozition layer_index =
(
	--format "\n"; print "PRINTER DUMMY.mcr.setPrintElevation()"
	volume_height	= (PrinterVolume_v(ROLLOUT_export.SPIN_export_size.value)).printer_size.z
	layer_height	= ROLLOUT_print_3d.SPIN_layer_height.value
	layer_current	= DIALOG_elevation_slider.SLIDER_elevation.value
	layers_count	= volume_height / layer_height

	if layer_index < 0 or layer_index > layers_count then
		layer_index = 	if layer_index < 0  then 0 else layers_count

	layer_index * layer_height --return z poz
)
