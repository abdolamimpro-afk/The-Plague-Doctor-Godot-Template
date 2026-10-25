extends CharacterBody3D

enum State { PATROL, INVESTIGATE, CHASE }

@export_group("Patrol Settings")
@export var patrol_points: Array[NodePath] = []
@export var randomize_patrol: bool = true            # تفعيل اختيار النقاط عشوائياً
@export var patrol_speed: float = 2.0
@export var investigate_speed: float = 4.0
@export var chase_speed: float = 6.0
@export var rotation_speed: float = 6.0
var _is_deaf: bool = false

@export_group("Detection Settings")
@export var vision_range: float = 14.0
@export var vision_angle_deg: float = 65.0
@export var catch_distance: float = 1.1
@export var lose_player_time: float = 3.0
@export var eye_height: float = 1.5

@export_group("Animation Clip Names")
@export var anim_walk: String = "scp-049_skeleton|3_walkcycle01"
@export var anim_chase: String = "scp-049_skeleton|3_walkcycle01"
@export var anim_investigate: String = "cherche"
@export var investigate_wait_time: float = 3.0

const GRAVITY: float = 18.0

var _state: int = State.PATROL
var _patrol_targets: Array[Vector3] = []
var _patrol_index: int = 0
var _investigate_point: Vector3 = Vector3.ZERO
var _player: Node3D = null
var _lose_timer: float = 0.0
var _player_caught: bool = false
var _is_investigating_idle: bool = false

var _nav_agent: NavigationAgent3D = null
var _anim_player: AnimationPlayer = null

func _ready() -> void:
	add_to_group("monsters")

	_nav_agent = get_node_or_null("%NavigationAgent3D")
	if _nav_agent == null:
		push_warning("Doctor: NavigationAgent3D not found.")

	_anim_player = get_node_or_null("%AnimationPlayer")
	if _anim_player == null:
		push_warning("Doctor: AnimationPlayer not found.")

	for p in patrol_points:
		var node := get_node_or_null(p)
		if node:
			_patrol_targets.append(node.global_position)

	_player = get_tree().get_first_node_in_group("player")

	await get_tree().physics_frame
	await get_tree().physics_frame

	if randomize_patrol and not _patrol_targets.is_empty():
		_patrol_index = randi() % _patrol_targets.size()

func hear_noise(pos: Vector3, radius: float) -> void:
	if _is_deaf or _player_caught or _state == State.CHASE:
		return
	if global_position.distance_to(pos) <= radius:
		_investigate_point = pos
		_state = State.INVESTIGATE
		_is_investigating_idle = false

func _physics_process(delta: float) -> void:
	if _player_caught:
		return

	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = 0.0

	_check_vision(delta)

	match _state:
		State.PATROL:
			_do_patrol(delta)
		State.INVESTIGATE:
			_do_investigate(delta)
		State.CHASE:
			_do_chase(delta)

	_update_animations()
	_check_catch()

# ============================================
# إدارة أنيميشن الحركة والتفقد
# ============================================
func _update_animations() -> void:
	if not _anim_player:
		return

	if _is_investigating_idle:
		return

	match _state:
		State.CHASE:
			if _anim_player.has_animation(anim_chase):
				_anim_player.play(anim_chase)
				_anim_player.speed_scale = chase_speed * 0.5
		State.PATROL, State.INVESTIGATE:
			if _anim_player.has_animation(anim_walk):
				_anim_player.play(anim_walk)
				var speed := patrol_speed if _state == State.PATROL else investigate_speed
				_anim_player.speed_scale = speed * 0.5

func _check_vision(delta: float) -> void:
	if not _player:
		return

	var eye_pos := global_position + Vector3(0, eye_height, 0)
	var player_pos := _player.global_position + Vector3(0, 1.0, 0)
	var to_player := player_pos - eye_pos
	var dist := to_player.length()

	if dist > vision_range:
		if _state == State.CHASE:
			_lose_timer -= delta
			if _lose_timer <= 0.0:
				_investigate_point = _player.global_position
				_state = State.INVESTIGATE
				_is_investigating_idle = false
		return

	var facing := -global_transform.basis.z
	var flat_to_player := to_player
	flat_to_player.y = 0.0
	var angle := rad_to_deg(facing.normalized().angle_to(flat_to_player.normalized()))

	if angle <= vision_angle_deg or _state == State.CHASE:
		var space_state := get_world_3d().direct_space_state
		var query := PhysicsRayQueryParameters3D.create(eye_pos, player_pos)
		query.exclude = [self]
		var result := space_state.intersect_ray(query)
		if result.is_empty() or result.get("collider") == _player:
			_state = State.CHASE
			_is_investigating_idle = false
			_lose_timer = lose_player_time

func _do_patrol(delta: float) -> void:
	if _patrol_targets.is_empty():
		return
	var target: Vector3 = _patrol_targets[_patrol_index]
	_move_toward_nav(target, patrol_speed, delta)

	if _nav_agent and _nav_agent.is_navigation_finished():
		_select_next_patrol_target()

func _select_next_patrol_target() -> void:
	if _patrol_targets.size() <= 1:
		return

	if randomize_patrol:
		var next_index := _patrol_index
		while next_index == _patrol_index:
			next_index = randi() % _patrol_targets.size()
		_patrol_index = next_index
	else:
		_patrol_index = (_patrol_index + 1) % _patrol_targets.size()

func _do_investigate(delta: float) -> void:
	if _is_investigating_idle:
		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		return

	_move_toward_nav(_investigate_point, investigate_speed, delta)

	if _nav_agent and _nav_agent.is_navigation_finished():
		_start_investigate_idle()

func _start_investigate_idle() -> void:
	_is_investigating_idle = true
	velocity.x = 0.0
	velocity.z = 0.0

	if _anim_player and _anim_player.has_animation(anim_investigate):
		_anim_player.play(anim_investigate)
		_anim_player.speed_scale = 2.0

	await get_tree().create_timer(investigate_wait_time).timeout

	if _state == State.INVESTIGATE and not _player_caught:
		_is_investigating_idle = false
		_state = State.PATROL

func _do_chase(delta: float) -> void:
	if _player:
		_move_toward_nav(_player.global_position, chase_speed, delta)

func _move_toward_nav(target: Vector3, speed: float, delta: float) -> void:
	if _nav_agent == null:
		var direction := target - global_position
		direction.y = 0.0
		if direction.length() < 0.05:
			velocity.x = 0.0
			velocity.z = 0.0
			return
		direction = direction.normalized()
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		_smooth_face(direction, delta)
		move_and_slide()
		return

	_nav_agent.target_position = target
	if _nav_agent.is_navigation_finished():
		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		return

	var next_pos := _nav_agent.get_next_path_position()
	var dir := next_pos - global_position
	dir.y = 0.0
	if dir.length() > 0.05:
		dir = dir.normalized()
		velocity.x = dir.x * speed
		velocity.z = dir.z * speed
		_smooth_face(dir, delta)
	else:
		velocity.x = 0.0
		velocity.z = 0.0

	move_and_slide()

func _smooth_face(dir: Vector3, delta: float) -> void:
	var target_angle := atan2(dir.x, dir.z)
	rotation.y = lerp_angle(rotation.y, target_angle, clamp(delta * rotation_speed, 0.0, 1.0))

func _check_catch() -> void:
	if _player_caught:
		return
	if _player and global_position.distance_to(_player.global_position) <= catch_distance:
		if _player.has_method("trigger_jumpscare"):
			_player.trigger_jumpscare(self)
		else:
			_player_caught = true
			velocity = Vector3.ZERO
			move_and_slide()
			get_tree().call_group("game_manager", "on_player_caught")

func freeze_for_jumpscare() -> void:
	set_physics_process(false)
	velocity = Vector3.ZERO
	if _nav_agent:
		_nav_agent.target_position = global_position
	if _anim_player:
		_anim_player.stop()

func set_debug_ignore_player(ignore: bool) -> void:
	if ignore:
		_state = State.PATROL
		_player = null
		_is_investigating_idle = false
		velocity = Vector3.ZERO
	else:
		_player = get_tree().get_first_node_in_group("player")

func apply_deafness(duration: float) -> void:
	_is_deaf = true
	await get_tree().create_timer(duration).timeout
	_is_deaf = false
