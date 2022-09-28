extends Node

class SignalEmitter:
	signal scene_loaded

var scenes_loading: Dictionary = {};

func load_scene(scene_path: String) -> SignalEmitter:
	if scenes_loading.has(scene_path):
		return scenes_loading[scene_path];
	var emitter: SignalEmitter = SignalEmitter.new();
	scenes_loading[scene_path] = emitter;
	ResourceLoader.load_threaded_request(scene_path, "PackedScene");
	return emitter;

func _process(_delta) -> void:
	for scene_path in scenes_loading.keys():
		var status: int = ResourceLoader.load_threaded_get_status(scene_path);
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			var scene: PackedScene = ResourceLoader.load_threaded_get(scene_path);
			scenes_loading[scene_path].scene_loaded.emit(scene.instantiate());
			scenes_loading.erase(scene_path);
