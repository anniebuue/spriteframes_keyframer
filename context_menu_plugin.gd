@tool
extends EditorContextMenuPlugin

func _popup_menu(paths : PackedStringArray) -> void:
	var proceed : bool = false
	for path in paths:
		if ResourceLoader.exists(path) and ResourceLoader.load(path) is SpriteFrames:
			proceed = true
	
	if not proceed:
		return
	
	add_context_menu_item("Make AnimationLibrary", _make_library)

func _make_library(args : Array) -> void:
	var path : String = args[0]
	var frames : SpriteFrames = ResourceLoader.load(path)
	
	var library : AnimationLibrary = AnimationLibrary.new()
	for anim_name in frames.get_animation_names():
		var animation : Animation = Animation.new()
		animation.step = 1.0 / frames.get_animation_speed(anim_name)
		animation.length = animation.step * frames.get_frame_count(anim_name)
		
		var anim_track_idx : int = animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_path(anim_track_idx, ".:animation")
		animation.value_track_set_update_mode(anim_track_idx, Animation.UPDATE_CONTINUOUS)
		var anim_track_key_idx : int = animation.track_insert_key(anim_track_idx, 0, anim_name)
		animation.track_set_key_transition(anim_track_idx, anim_track_key_idx, 0.0)
		
		var frame_track_idx : int = animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_path(frame_track_idx, ".:frame")
		animation.value_track_set_update_mode(frame_track_idx, Animation.UPDATE_CONTINUOUS)
		var last_frame : Texture2D
		for i in frames.get_frame_count(anim_name):
			var cur_tex : Texture2D = frames.get_frame_texture(anim_name, i)
			if cur_tex == last_frame:
				continue
			
			var frame_track_key_idx : int = animation.track_insert_key(frame_track_idx, i * animation.step, i)
			animation.track_set_key_transition(frame_track_idx, frame_track_key_idx, 0.0)
			
			last_frame = cur_tex
		
		library.add_animation(anim_name, animation)
	
	var directory : String = path.get_base_dir()
	var file_name : String = path.get_file().replace("." + path.get_extension(), "")
	
	ResourceSaver.save(library, "%s/%s_library.tres" % [directory, file_name])
