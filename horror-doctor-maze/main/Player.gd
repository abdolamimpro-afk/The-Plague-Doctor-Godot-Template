extends CharacterBody3D

var _current_flash_yaw: float = 0.0
var _current_flash_pitch: float = 0.0
var _infinite_stamina: bool = false

@export_group("Speed & Movement")
@export var walk_speed: float = 4.0
@export var run_speed: float = 7.0
@export var exhausted_speed: float = 2.0
@export var run_noise_radius: float = 9.0
@export var walk_noise_radius: float = 3.2
@export var noise_interval: float = 0.4

@export_group("Stamina System")
@export var max_stamina: float = 100.0
@export var stamina_drain: float = 30.0
@export var stamina_recover: float = 15.0
var current_stamina: float = 100.0
var _is_exhausted: bool = false

@export_group("Flashlight System")
@onready var label_2: Label = %Label2
@export var max_battery: float = 100.0
@export var battery_drain_rate: float = 3.0
@export var flashlight_follow_speed: float = 4.0
var current_battery: float = 100.0
var _is_flashlight_on: bool = false

@export_group("Flashlight Flicker")
@export var flicker_enabled: bool = true
@export var flicker_low_battery_threshold: float = 25.0
@export var flicker_chance_per_second: float = 0.6
@export var flicker_min_duration: float = 0.04
@export var flicker_max_duration: float = 0.25
var _is_flickering: bool = false
var _flicker_time_left: float = 0.0

@export_group("Horror Head Bobbing")
@export var bob_walk_freq: float = 8.0
@export var bob_run_freq: float = 14.0
@export var bob_walk_vertical_amp: float = 0.035
@export var bob_run_vertical_amp: float = 0.08
@export var bob_walk_horizontal_amp: float = 0.02
@export var bob_run_horizontal_amp: float = 0.05
@export var run_tilt_deg: float = 2.5
@export var run_fov_boost: float = 8.0
@export var base_fov: float = 75.0
@export var landing_bounce_amp: float = 0.06

@export_group("Heartbeat System")
@export var heartbeat_danger_range: float = 20.0
@export var heartbeat_min_volume_db: float = -20.0
@export var heartbeat_max_volume_db: float = 8.0
@export var heartbeat_min_pitch: float = 0.8
@export var heartbeat_max_pitch: float = 1.8

@export_group("Fear / Tunnel Vision")
@export var fear_fov_shrink: float = 10.0
@export var fear_vignette_path: NodePath
@onready var _fear_vignette: CanvasItem = get_node_or_null(fear_vignette_path)
@onready var _interaction_label: Label = get_node_or_null("%InteractionLabel")
var _current_fear: float = 0.0

@export_group("Crouch / Stealth")
@export var crouch_speed: float = 1.8
@export var crouch_noise_radius: float = 1.4
@export var crouch_cam_height_offset: float = -0.45
@export var crouch_key: Key = KEY_C
var _is_crouching: bool = false

@export_group("Ambient Dread")
@export var whisper_min_interval: float = 18.0
@export var whisper_max_interval: float = 45.0
@export var whisper_trigger_fear: float = 0.35
var _whisper_timer: float = 0.0

@export_group("Sound Trap / Fake Jumpscare")
@export var random_scare_min_interval: float = 60.0
@export var random_scare_max_interval: float = 150.0
var _scare_timer: float = 0.0

const GRAVITY: float = 18.0

var _is_dead: bool = false
var _noise_timer: float = 0.0
var _pitch: float = 0.0

var _bob_time: float = 0.0
var _breath_time: float = 0.0
var _was_on_floor: bool = true
var _landing_bounce_time: float = 0.0
var _landing_bounce_active: bool = false

@onready var _cam: Camera3D = get_node_or_null("%Head/Camera3D") if get_node_or_null("%Head/Camera3D") else get_node_or_null("Head/Camera3D")
@onready var _flashlight: SpotLight3D = get_node_or_null("%FlashLight") if get_node_or_null("%FlashLight") else get_node_or_null("FlashLight")
@onready var _interaction_ray: RayCast3D = get_node_or_null("%Head/Camera3D/RayCast3D") if get_node_or_null("%Head/Camera3D/RayCast3D") else get_node_or_null("Head/Camera3D/RayCast3D")
@onready var _heartbeat_audio: AudioStreamPlayer = get_node_or_null("%HeartbeatAudio") 

@onready var stamina_bar: ProgressBar = get_node_or_null("%StaminaBar")
@onready var battery_bar: ProgressBar = get_node_or_null("%BatteryBar")
@onready var _footstep_audio: AudioStreamPlayer3D = get_node_or_null("%FootstepAudio")
@onready var _breath_audio: AudioStreamPlayer = get_node_or_null("%BreathAudio")
@onready var _jumpscare_audio: AudioStreamPlayer = get_node_or_null("%JumpscareAudio")
@onready var _whisper_audio: AudioStreamPlayer = get_node_or_null("%WhisperAudio")
@onready var _scare_audio: AudioStreamPlayer = get_node_or_null("%RandomScareAudio")

@onready var _original_cam_pos: Vector3 = _cam.position if _cam else Vector3.ZERO
@onready var _original_cam_rot_z: float = _cam.rotation.z if _cam else 0.0

var _jumpscare_triggered: bool = false
var _spawn_protection: bool = true # متغير حماية البداية
var _phone_ui: CanvasLayer = null # واجهة الهاتف

func _ready() -> void:
	# SDK
	if CrazySDK.hasSDK():
		CrazySDK.gameplayStart()
	
	
	label_2.visible = true
	_current_flash_yaw = global_rotation.y
	_current_flash_pitch = _pitch
	add_to_group("player")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if stamina_bar:
		stamina_bar.max_value = max_stamina
		stamina_bar.value = current_stamina

	if battery_bar:
		battery_bar.max_value = max_battery
		battery_bar.value = current_battery

	if _cam:
		_cam.fov = base_fov

	_reset_whisper_timer()
	_reset_scare_timer()

	# إنشاء واجهة الهاتف
	_spawn_phone_ui()

	# مهلة حماية مدتها ثانيتان لمنع تلامس الـ Area عند بداية اللعبة
	_spawn_protection = true
	await get_tree().create_timer(2.0).timeout
	_spawn_protection = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			# إذا الهاتف مفتوح، أغلقه أولاً
			if _phone_ui and _phone_ui.has_method("is_phone_open") and _phone_ui.is_phone_open():
				_phone_ui.toggle()
				get_viewport().set_input_as_handled()
				return
			# التأكد من أن القائمة غير مفتوحة مسبقاً لتجنب التكرار
			if not has_node("PauseMenu"):
				get_tree().paused = true
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				var pause_inst = load("res://main/pause_menu.tscn").instantiate()
				pause_inst.name = "PauseMenu"
				add_child(pause_inst)
		
	if _is_dead:
		return

	# منع الإدخالات أثناء فتح الهاتف
	if _phone_ui and _phone_ui.has_method("is_phone_open") and _phone_ui.is_phone_open():
		return

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * Settings.mouse_sensitivity)
		_pitch = clamp(_pitch - event.relative.y * Settings.mouse_sensitivity, deg_to_rad(-80), deg_to_rad(80))
		if _cam:
			_cam.rotation.x = _pitch

	if event is InputEventKey and event.pressed and event.keycode == KEY_F:
		label_2.visible = false
		if current_battery > 0.0:
			_is_flashlight_on = !_is_flashlight_on
			if _flashlight:
				_flashlight.visible = _is_flashlight_on

	if event is InputEventKey and event.pressed and event.keycode == KEY_E:
		_try_interact()

	if event is InputEventKey and event.pressed and event.keycode == crouch_key:
		_is_crouching = !_is_crouching

	if event is InputEventKey and event.pressed and event.keycode == KEY_TAB:
		if _phone_ui and _phone_ui.has_method("toggle"):
			_phone_ui.toggle()
		get_viewport().set_input_as_handled()

func _physics_process(delta: float) -> void:
	_check_interaction_prompt()

	if _is_dead:
		_update_heartbeat(delta)
		return

	# تجميد الحركة عند فتح الهاتف
	if _phone_ui and _phone_ui.has_method("is_phone_open") and _phone_ui.is_phone_open():
		velocity.x = 0.0
		velocity.z = 0.0
		if not is_on_floor():
			velocity.y -= GRAVITY * delta
		else:
			velocity.y = 0.0
		move_and_slide()
		_update_heartbeat(delta)
		_update_ambient_dread(delta)
		return

	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = 0.0

	var input_dir := Vector2.ZERO
	if Input.is_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_D): input_dir.x += 1.0
	if Input.is_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_A): input_dir.x -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_S): input_dir.y += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_W): input_dir.y -= 1.0
	input_dir = input_dir.normalized()

	var shift_pressed := Input.is_key_pressed(KEY_SHIFT) or Input.is_physical_key_pressed(KEY_SHIFT)
	var wants_to_run := shift_pressed and input_dir.length() > 0.0 and not _is_crouching

	if current_stamina <= 0.0:
		_is_exhausted = true
	elif current_stamina >= max_stamina * 0.25:
		_is_exhausted = false

	var is_running := false
	if wants_to_run and not _is_exhausted:
		is_running = true
		if not _infinite_stamina:
			current_stamina = max(0.0, current_stamina - stamina_drain * delta)
	else:
		current_stamina = min(max_stamina, current_stamina + stamina_recover * delta)

	if stamina_bar:
		stamina_bar.value = current_stamina

	var speed: float
	if _is_crouching:
		speed = crouch_speed
	elif is_running:
		speed = run_speed
	elif _is_exhausted:
		speed = exhausted_speed
	else:
		speed = walk_speed

	var dir3 := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	velocity.x = dir3.x * speed
	velocity.z = dir3.z * speed

	move_and_slide()

	if not _was_on_floor and is_on_floor():
		_landing_bounce_active = true
		_landing_bounce_time = 0.0
	_was_on_floor = is_on_floor()

	_handle_flashlight_and_battery(delta)
	_update_flashlight_rotation(delta)
	_handle_camera_and_audio(delta, is_running)
	_update_heartbeat(delta)
	_update_ambient_dread(delta)

	if input_dir.length() > 0.0:
		_noise_timer -= delta
		if _noise_timer <= 0.0:
			_noise_timer = noise_interval
			var radius := run_noise_radius if is_running else (crouch_noise_radius if _is_crouching else walk_noise_radius)
			get_tree().call_group("monsters", "hear_noise", global_position, radius)

# دالة التلامس الخاصة بـ Area3D المحمية لمنع الخطأ الفوري
func _on_area_3d_body_entered(body: Node3D) -> void:
	if _spawn_protection or _jumpscare_triggered or _is_dead:
		return

	if body.is_in_group("monsters"):
		trigger_jumpscare(body)

func trigger_jumpscare(monster: Node3D) -> void:
	if _jumpscare_triggered:
		return
	_jumpscare_triggered = true
	_is_dead = true

	process_mode = Node.PROCESS_MODE_ALWAYS
	if _cam:
		_cam.process_mode = Node.PROCESS_MODE_ALWAYS

	if monster.has_method("freeze_for_jumpscare"):
		monster.freeze_for_jumpscare()

	if _footstep_audio: _footstep_audio.stop()
	if _breath_audio: _breath_audio.stop()
	if _heartbeat_audio: _heartbeat_audio.stop()
	if stamina_bar: stamina_bar.visible = false
	if battery_bar: battery_bar.visible = false

	if not _jumpscare_audio:
		_jumpscare_audio = find_child("JumpscareAudio", true, false) as AudioStreamPlayer
	if _jumpscare_audio:
		_jumpscare_audio.process_mode = Node.PROCESS_MODE_ALWAYS
		_jumpscare_audio.play()

	var jumpscare_cam: Camera3D = monster.get_node_or_null("%JumpscareCamera")

	if jumpscare_cam:
		jumpscare_cam.process_mode = Node.PROCESS_MODE_ALWAYS
		jumpscare_cam.current = true
		jumpscare_cam.make_current()

		var jumpscare_light: Light3D = monster.get_node_or_null("%JumpscareLight")
		if jumpscare_light:
			jumpscare_light.process_mode = Node.PROCESS_MODE_ALWAYS
			jumpscare_light.visible = true

		var start_pos: Vector3 = jumpscare_cam.position
		var shake_tween = create_tween()
		shake_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		for i in range(8):
			var offset := Vector3(randf_range(-0.03, 0.03), randf_range(-0.03, 0.03), 0.0)
			shake_tween.tween_property(jumpscare_cam, "position", start_pos + offset, 0.03)
		shake_tween.tween_property(jumpscare_cam, "position", start_pos, 0.03)
	
	get_tree().create_timer(2.0, true).timeout.connect(func():
		get_tree().paused = false
		get_tree().call_group("game_manager", "on_player_caught")
)

func _handle_flashlight_and_battery(delta: float) -> void:
	if _is_flashlight_on and current_battery > 0.0:
		current_battery = max(0.0, current_battery - battery_drain_rate * delta)
		var battery_ratio := current_battery / max_battery

		if _flashlight:
			_flashlight.visible = true
			if flicker_enabled:
				_process_flicker(delta, battery_ratio)
			if not _is_flickering:
				_flashlight.light_energy = battery_ratio * 3.0

		if current_battery <= 0.0:
			if _flashlight: _flashlight.visible = false
			_is_flashlight_on = false
	else:
		if _flashlight and current_battery <= 0.0:
			_flashlight.visible = false

	if battery_bar:
		battery_bar.value = current_battery
		var battery_ratio := current_battery / max_battery
		var bar_color: Color
		if battery_ratio > 0.5:
			bar_color = Color.GREEN.lerp(Color.YELLOW, (1.0 - battery_ratio) * 2.0)
		else:
			bar_color = Color.YELLOW.lerp(Color.RED, (0.5 - battery_ratio) * 2.0)
		battery_bar.modulate = bar_color

func _process_flicker(delta: float, battery_ratio: float) -> void:
	if _is_flickering:
		_flicker_time_left -= delta
		if _flicker_time_left <= 0.0:
			_is_flickering = false
			if _flashlight:
				_flashlight.light_energy = battery_ratio * 3.0
				_flashlight.visible = true
		else:
			if _flashlight:
				_flashlight.visible = int(_flicker_time_left * 40.0) % 2 == 0
		return

	if battery_ratio * max_battery <= flicker_low_battery_threshold:
		var low_ratio := 1.0 - (battery_ratio * max_battery / flicker_low_battery_threshold)
		var chance := flicker_chance_per_second * low_ratio * delta
		if randf() < chance:
			_is_flickering = true
			_flicker_time_left = randf_range(flicker_min_duration, flicker_max_duration)

func add_battery_energy(amount: float) -> void:
	current_battery = min(max_battery, current_battery + amount)
	_is_flashlight_on = true
	if _flashlight:
		_flashlight.visible = true

func _try_interact() -> void:
	if _interaction_ray and _interaction_ray.is_colliding():
		var target: Node = _interaction_ray.get_collider()
		while target != null:
			if target.has_method("interact"):
				target.interact(self)
				break
			target = target.get_parent()

func _update_flashlight_rotation(delta: float) -> void:
	if not _flashlight or not _cam:
		return

	_flashlight.global_position = _cam.global_position

	var target_yaw: float = global_rotation.y
	var target_pitch: float = _cam.rotation.x

	var weight: float = 1.0 - exp(-flashlight_follow_speed * delta)

	_current_flash_yaw = lerp_angle(_current_flash_yaw, target_yaw, weight)
	_current_flash_pitch = lerp(_current_flash_pitch, target_pitch, weight)

	_flashlight.global_basis = Basis.from_euler(Vector3(_current_flash_pitch, _current_flash_yaw, 0.0))

func _handle_camera_and_audio(delta: float, is_running: bool) -> void:
	if not _cam:
		return

	var horizontal_speed := Vector3(velocity.x, 0, velocity.z).length()
	var fatigue_ratio := 1.0 - (current_stamina / max_stamina)
	var is_moving := is_on_floor() and horizontal_speed > 0.2

	var target_fov := base_fov
	var target_tilt := 0.0
	var bob_offset := Vector3.ZERO

	if is_moving:
		var freq: float = 0.0
		var v_amp: float = 0.0
		var h_amp: float = 0.0

		if _is_crouching:
			freq = bob_walk_freq * 0.5
			v_amp = bob_walk_vertical_amp * 0.5
			h_amp = bob_walk_horizontal_amp * 0.5
		elif is_running:
			freq = bob_run_freq
			v_amp = bob_run_vertical_amp
			h_amp = bob_run_horizontal_amp
			target_fov = base_fov + run_fov_boost
			target_tilt = deg_to_rad(run_tilt_deg) * sin(_bob_time * 0.5)
		elif _is_exhausted:
			freq = bob_walk_freq * 0.6
			v_amp = bob_walk_vertical_amp * 0.7
			h_amp = bob_walk_horizontal_amp * 0.7
		else:
			freq = bob_walk_freq
			v_amp = bob_walk_vertical_amp
			h_amp = bob_walk_horizontal_amp

		_bob_time += delta * freq

		var vertical: float = abs(sin(_bob_time)) * v_amp
		var horizontal: float = sin(_bob_time * 0.5) * h_amp

		bob_offset = Vector3(horizontal, vertical, 0.0)

		if _footstep_audio and _footstep_audio.stream:
			_footstep_audio.pitch_scale = 1.35 if is_running else (0.75 if _is_exhausted else 1.0)
			if not _footstep_audio.playing:
				_footstep_audio.play()
	else:
		var breath_speed := 1.5 + (fatigue_ratio * 2.0)
		_breath_time += delta * breath_speed
		var breath_y := sin(_breath_time) * (0.008 + fatigue_ratio * 0.01)
		bob_offset = Vector3(0.0, breath_y, 0.0)

		if _footstep_audio and _footstep_audio.playing:
			_footstep_audio.stop()

	if _landing_bounce_active:
		_landing_bounce_time += delta * 10.0
		var bounce := sin(min(_landing_bounce_time, PI)) * landing_bounce_amp
		bob_offset.y -= bounce
		if _landing_bounce_time >= PI:
			_landing_bounce_active = false

	var crouch_offset: float = crouch_cam_height_offset if _is_crouching else 0.0
	var fear_fov_penalty: float = fear_fov_shrink * _current_fear

	_cam.position = _cam.position.lerp(_original_cam_pos + bob_offset + Vector3(0, crouch_offset, 0), delta * 12.0)
	_cam.rotation.z = lerp(_cam.rotation.z, _original_cam_rot_z + target_tilt, delta * 6.0)
	_cam.fov = lerp(_cam.fov, target_fov - fear_fov_penalty, delta * 6.0)

	if _breath_audio and _breath_audio.stream:
		if fatigue_ratio > 0.2:
			_breath_audio.pitch_scale = 0.9 + (fatigue_ratio * 0.3)
			if not _breath_audio.playing:
				_breath_audio.play()
		else:
			if _breath_audio.playing:
				_breath_audio.stop()

func _update_heartbeat(delta: float) -> void:
	if _is_dead or not _heartbeat_audio:
		return

	# 1. البحث عن الوحش في الجروب
	var monster = get_tree().get_first_node_in_group("monsters")
	if not monster:
		monster = get_tree().current_scene.find_child("*monster*", true, false)

	# إذا لم يجد وحشاً، يوقف الصوت بهدوء
	if not monster or not (monster is Node3D):
		if _heartbeat_audio.playing:
			_heartbeat_audio.stop()
		return

	# 2. حساب المسافة المباشرة بين اللاعب والوحش
	var dist: float = global_position.distance_to(monster.global_position)

	# 3. إذا كان الوحش خارج المدى المحدد (مثلاً أبعد من heartbeat_danger_range)
	if dist > heartbeat_danger_range:
		if _heartbeat_audio.playing:
			_heartbeat_audio.stop()
		return

	# 4. إذا كان داخل المدى: نشغل الصوت مرة واحدة فقط إن لم يكن يعمل
	if not _heartbeat_audio.playing:
		_heartbeat_audio.play()

	# 5. حساب نسبة الخوف من 0.0 (بعيد عند الحافة) إلى 1.0 (ملاصق تماماً)
	var target_fear: float = clamp(1.0 - (dist / heartbeat_danger_range), 0.0, 1.0)
	
	# تنعيم الانتقال بـ lerp لكي لا يقفز الصوت فجأة
	_current_fear = lerp(_current_fear, target_fear, delta * 4.0)

	# 6. تطبيق علو الصوت والسرعة مباشرة
	_heartbeat_audio.volume_db = lerp(heartbeat_min_volume_db, heartbeat_max_volume_db, _current_fear)
	_heartbeat_audio.pitch_scale = lerp(heartbeat_min_pitch, heartbeat_max_pitch, _current_fear)



func _update_fear_vignette() -> void:
	if _fear_vignette:
		_fear_vignette.modulate.a = _current_fear

func _reset_whisper_timer() -> void:
	_whisper_timer = randf_range(whisper_min_interval, whisper_max_interval)

func _reset_scare_timer() -> void:
	_scare_timer = randf_range(random_scare_min_interval, random_scare_max_interval)

func _update_ambient_dread(delta: float) -> void:
	_whisper_timer -= delta
	if _whisper_timer <= 0.0:
		_reset_whisper_timer()
		if _current_fear >= whisper_trigger_fear and _whisper_audio and _whisper_audio.stream:
			_whisper_audio.pitch_scale = randf_range(0.85, 1.15)
			_whisper_audio.play()

	_scare_timer -= delta
	if _scare_timer <= 0.0:
		_reset_scare_timer()
		if _scare_audio and _scare_audio.stream:
			_scare_audio.pitch_scale = randf_range(0.9, 1.1)
			_scare_audio.play()

func add_stamina_boost(amount: float, duration: float) -> void:
	current_stamina = clamp(current_stamina + amount, 0.0, max_stamina)
	_infinite_stamina = true
	await get_tree().create_timer(duration).timeout
	_infinite_stamina = false

func apply_speed_boost(multiplier: float, duration: float) -> void:
	walk_speed *= multiplier
	run_speed *= multiplier
	await get_tree().create_timer(duration).timeout
	walk_speed /= multiplier
	run_speed /= multiplier

func show_location_reveal(duration: float) -> void:
	var sphere := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 1.5
	mesh.height = 3.0
	sphere.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1, 0, 0, 0.35)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sphere.material_override = mat
	add_child(sphere)
	await get_tree().create_timer(duration).timeout
	sphere.queue_free()

func _check_interaction_prompt() -> void:
	if not _interaction_label or not _interaction_ray:
		return

	if _interaction_ray.is_colliding():
		var target: Node = _interaction_ray.get_collider()

		var found_interactable := false
		var prompt_msg := "Press E to interact"

		while target != null:
			if target.has_method("interact"):
				found_interactable = true
				if "prompt_text" in target:
					prompt_msg = target.prompt_text
				break
			target = target.get_parent()

		if found_interactable:
			_interaction_label.text = prompt_msg
			_interaction_label.visible = true
			return

	_interaction_label.visible = false


# ============================================
# Phone UI
# ============================================
func _spawn_phone_ui() -> void:
	var phone_scene: PackedScene = load("res://main/phone_ui.tscn")
	if phone_scene:
		_phone_ui = phone_scene.instantiate() as CanvasLayer
		_phone_ui.name = "PhoneUI"
		add_child(_phone_ui)
