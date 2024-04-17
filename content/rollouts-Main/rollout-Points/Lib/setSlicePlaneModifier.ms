/** Set slice plane modifier
  *
  * @param int|float layer_index_or_z_pos position where slice plane is elevated
  *		1) FLOAT:	z pozition in world units
  *		2) INTEGER:	index of print layer
  *
  */
function setSlicePlaneModifier mode state layer_index_or_z_pos cap_state =
(
	format "\n"; print ("setSlicePlaneModifier.ms.setSlicePlaneModifier( #"+mode as string +" )")
	format "state:	% \n" state
	format "mode:	% \n" mode
	format "layer_index_or_z_pos:	% \n" layer_index_or_z_pos

	mod_name = "SLICE_PLANE_" + toUpper (mode as string )


	mods_in_scene = for mod_in_scene in ( getClassInstances ( SliceModifier )) where mod_in_scene.name == mod_name collect mod_in_scene

	--local slice_mod

	--if mods_in_scene.count == 0 then
	if ( slice_mod = mods_in_scene[1] ) == undefined then
		return false



	z_pos = if classOf layer_index_or_z_pos == integer then getPlaneZpozition (layer_index_or_z_pos) else layer_index_or_z_pos
	format "Z_POS:	% \n" z_pos

	/* SET SLICE PLANE POSITION */
	final_TM = Matrix3 1

	final_TM.position.z = z_pos


	--pos01 = [ 0,	0,	z_pos ]
	--pos02 = [ 10,	0,	z_pos ]
	--pos03 = [ 0,	10,	z_pos ]
	--
	--vect1 = normalize (pos02 - pos01)
	--vect2 = normalize (pos03 - pos02)
	--vect3 = normalize (cross vect2 vect1)
	--
	--vect2 = cross vect3 vect1
	--
	--final_TM =  (( Matrix3 vect1 vect2 vect3 ((pos01 + pos02 + pos03) / 3) ))

	/*  UPDATE MODIFIER PROPERTIES */
	slice_mod.slice_plane.transform = final_TM

	slice_mod.Slice_Type = (if mode == #TOP then 2 else 3 )

	slice_mod.cap = cap_state

)