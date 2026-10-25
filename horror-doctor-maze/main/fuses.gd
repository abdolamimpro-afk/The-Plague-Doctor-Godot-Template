extends StaticBody3D

# ============================================
# أنواع الـ Fuse
# ============================================
enum FuseType { ORANGE, RED, BLUE, GREEN }
@onready var fuse_sound: AudioStreamPlayer3D = %FuseSound

@export var fuse_type: FuseType = FuseType.ORANGE:
	set(value):
		fuse_type = value
		_update_color()

# ============================================
# البرتقالي: يضيف نقطة فوز
# ============================================
@export_group("Orange - Win Point")
@export var win_points: int = 1

# ============================================
# الأحمر: يجذب الوحش + يكشف مكان اللاعب
# ============================================
@export_group("Red - Alert Monster")
@export var attract_radius: float = 50.0
@export var reveal_duration: float = 4.0
@export var alert_sound: AudioStream

# ============================================
# الأزرق: يعطي Stamina لانهائية + سرعة
# ============================================
@export_group("Blue - Speed & Unlimited Stamina")
@export var stamina_amount: float = 100.0
@export var blue_duration: float = 25.0
@export var blue_speed_multiplier: float = 1.5

# ============================================
# الأخضر: يجعل الوحش أصم
# ============================================
@export_group("Green - Deaf Monster")
@export var deaf_duration: float = 25.0

# ============================================
# مظهر عام
# ============================================
@export_group("Visual")
@export var orange_color: Color = Color(1.0, 0.55, 0.0)
@export var red_color: Color = Color(1.0, 0.0, 0.0)
@export var blue_color: Color = Color(0.0, 0.5, 1.0)
@export var green_color: Color = Color(0.0, 1.0, 0.25)
@export var bob_height: float = 0.15
@export var bob_speed: float = 2.0
@export var spin_speed: float = 1.2
@export var light_energy: float = 2.0

@export_group("Interaction")
@export var prompt_text: String = "اضغط E لأخذ الفيوز"

var _mesh: MeshInstance3D = null
var _collision: CollisionShape3D = null
var _light: OmniLight3D = null
var _audio: AudioStreamPlayer3D = null
var _base_y: float = 0.0
var _time: float = 0.0
var _collected: bool = false

func _ready() -> void:
	add_to_group("fuses")

	_mesh = get_node_or_null("%MeshInstance3D")
	_collision = get_node_or_null("%CollisionShape3D")
	_light = get_node_or_null("%OmniLight3D")
	_audio = get_node_or_null("%FuseSound")

	_base_y = position.y
	_update_color()

func _process(delta: float) -> void:
	if _collected:
		return
	_time += delta
	if _mesh:
		_mesh.rotation.y += spin_speed * delta
	position.y = _base_y + sin(_time * bob_speed) * bob_height

func _update_color() -> void:
	if not _mesh:
		_mesh = get_node_or_null("%MeshInstance3D")
	if not _mesh:
		return

	var mat := StandardMaterial3D.new()
	var c := _get_color_for_type()
	mat.albedo_color = c
	mat.emission_enabled = true
	mat.emission = c
	mat.emission_energy_multiplier = 1.5
	_mesh.material_override = mat

	if not _light:
		_light = get_node_or_null("%OmniLight3D")
	if _light:
		_light.light_color = c
		_light.light_energy = light_energy

func _get_color_for_type() -> Color:
	match fuse_type:
		FuseType.ORANGE:
			return orange_color
		FuseType.RED:
			return red_color
		FuseType.BLUE:
			return blue_color
		FuseType.GREEN:
			return green_color
	return Color.WHITE

func interact(player: Node) -> void:
	if _collected:
		return
	if not player or not player.is_in_group("player"):
		return

	_collected = true

	# 1. تفعيل توهج الشاشة باللون المناسب
	_trigger_screen_glow(player, _get_color_for_type())

	# 2. تنفيذ قدرات الفيوز
	match fuse_type:
		FuseType.ORANGE:
			_apply_orange()
		FuseType.RED:
			_apply_red(player)
		FuseType.BLUE:
			_apply_blue(player)
		FuseType.GREEN:
			_apply_green(player)

	_disable_pickup()
	_finish_pickup()

func _apply_orange() -> void:
	get_tree().call_group("game_manager", "add_orange_fuse", win_points)
	_play_default_sound()

func _apply_red(player: Node) -> void:
	get_tree().call_group("monsters", "hear_noise", global_position, attract_radius)
	if player.has_method("show_location_reveal"):
		player.show_location_reveal(reveal_duration)
	else:
		get_tree().call_group("player", "show_location_reveal", reveal_duration)
		
	get_tree().call_group("game_manager", "add_red_fuse", win_points)
	
	if _audio and alert_sound:
		_audio.stream = alert_sound
		_audio.play()
	else:
		_play_default_sound()

func _apply_blue(player: Node) -> void:
	if player.has_method("add_stamina_boost"):
		player.add_stamina_boost(stamina_amount, blue_duration)
	if player.has_method("apply_speed_boost"):
		player.apply_speed_boost(blue_speed_multiplier, blue_duration)

	# إرسال الأمر للواجهة مباشرة وعبر المجموعات
	var ui_node = player.get_node_or_null("UI")
	if ui_node and ui_node.has_method("show_blue_power"):
		ui_node.show_blue_power(blue_duration)
	get_tree().call_group("ui", "show_blue_power", blue_duration)

	_play_default_sound()

func _apply_green(player: Node) -> void:
	get_tree().call_group("monsters", "apply_deafness", deaf_duration)

	# إرسال الأمر للواجهة مباشرة وعبر المجموعات
	var ui_node = player.get_node_or_null("UI")
	if ui_node and ui_node.has_method("show_green_power"):
		ui_node.show_green_power(deaf_duration)
	get_tree().call_group("ui", "show_green_power", deaf_duration)

	_play_default_sound()

func _trigger_screen_glow(player: Node, color: Color) -> void:
	var ui_node = player.get_node_or_null("UI")
	if not ui_node:
		return

	var glow = ColorRect.new()
	glow.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	var glow_color = color
	glow_color.a = 0.35
	glow.color = glow_color
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE

	ui_node.add_child(glow)

	var tween = create_tween()
	tween.tween_property(glow, "color:a", 0.0, 0.8)
	tween.tween_callback(glow.queue_free)

func _play_default_sound() -> void:
	if _audio and _audio.stream:
		fuse_sound.play()

func _disable_pickup() -> void:
	if _mesh:
		_mesh.visible = false
	if _collision:
		_collision.disabled = true
	if _light:
		_light.visible = false

func _finish_pickup() -> void:
	if _audio and _audio.playing:
		await _audio.finished
	queue_free()
