


/** Set print elevation
  *
  */
function updateSlicePlaneSystem layer_index incremental:false =
(
	format "\n"; print "updateSlicePlaneSystem.ms.updateSlicePlaneSystem()"
	--format "layer_index:	% \n" layer_index


	--function showLayerHud layer_index =
	--(
	--	--format "\n"; print "PRINTER DUMMY.mcr.showLayerHud()"
	--	unregisterRedrawViewsCallback viewportHudCallback
	--
	--	HUD = Hud_v pos:#( #RIGHT,	#CENTER ) offset:[ 64, 0 ]
	--
	--	HUD.row #( "Layer Index:", layer_index as string )
	--
	--	HUD_DATA[#SLICE_LAYER_CURRENT] = HUD
	--
	--	registerRedrawViewsCallback viewportHudCallback
	--
	--)


	/* OPEN SLIDER IF NOT OPENED */
	if DIALOG_elevation_slider == undefined or GetDialogPos DIALOG_elevation_slider == [0,0] then
		createElevationSliderDialog()

	export_size = DIALOG_content.SPIN_export_size.value
	--export_size = 1
	--format "EXPORT SIZE TEMPORARY SET TO: %\n" export_size
	volume_height	= (PrinterVolume_v(export_size)).printer_size.z

	/* TODO: ACCESS TO UI VALUES SHOULD BE OUTSIDE FUNCTION

	*/
	layer_current	= DIALOG_elevation_slider.SLIDER_elevation.value

	layer_height	= DIALOG_content.SPIN_layer_height.value

	cap_slice	= ROLLOUT_slicer.CBX_cap_slice.state
	select_plane	= ROLLOUT_slicer.CBX_slice_select_plane.state
	slice_top	= ROLLOUT_slicer.CBX_slice_top.state
	slice_bottom	= ROLLOUT_slicer.CBX_slice_bottom.state

	layers_count	= volume_height / layer_height

	if layer_index == undefined then
		layer_index = layer_current

	/* SET DEAGFULT SLICE TOP */
	if not (slice_top and slice_bottom) then
		slice_top = true


	format "slice_top:	% \n" slice_top
	format "slice_bottom % \n" slice_bottom

	/* GET INCREMENTAL LAYER INDEX */
	if incremental then
		layer_index = layer_current + layer_index

	format "LAYER_INDEX: %\n" layer_index

	--try(
		--DisableSceneRedraw()

		/* ADD MODIFIERS */
		if slice_top then
			setSlicePlaneModifier (#TOP) (#TRUE) (layer_index) (cap_slice)

		if slice_bottom then
			setSlicePlaneModifier (#BOTTOM) (#TRUE) (layer_index - 1) (cap_slice)

		----format "select_plane	= % \n" select_plane
		--if select_plane then
		--	setSelectPlaneModifier(layer_index) slice_top:slice_top slice_bottom:slice_bottom

		/* UPDATE UI */
		--ROLLOUT_export.SPIN_current_layer.value	= layer_index
		DIALOG_elevation_slider.SPIN_layer_current.value	= layer_index
		DIALOG_elevation_slider.SLIDER_elevation.value	= layer_index

	--)catch(
	--	--EnableSceneRedraw()
	--)

	--EnableSceneRedraw()

	--redrawViews()

	--showLayerHud(layer_index)

)