extends Node

# مسار حفظ البيانات القياسي (يعمل تلقائياً على الجوال والحاسوب)
const SAVE_PATH = "user://game_save.dat"

# ============================================
# متطلبات الفوز للمرحلة الحالية
# ============================================
@export_group("Level Win Requirements")
@export var required_orange: int = 4
@export var required_red: int = 3

# ============================================
# العدادات الحالية والتقدم
# ============================================
var current_orange: int = 0
var current_red: int = 0
var current_level: int = 1 # رقم المستوى الحالي

func _ready() -> void:
	add_to_group("game_manager")

func add_orange_fuse(amount: int = 1) -> void:
	current_orange += amount
	_update_ui_and_check_win()

func add_red_fuse(amount: int = 1) -> void:
	current_red += amount
	_update_ui_and_check_win()

func _update_ui_and_check_win() -> void:
	get_tree().call_group("ui", "update_fuse_counters", current_orange, required_orange, current_red, required_red)
	
	if current_orange >= required_orange and current_red >= required_red:
		trigger_win()

# ============================================
# الفوز والخسارة
# ============================================
func trigger_win() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file("res://main/won.tscn")

func on_player_caught() -> void:
	print("Game Over: الإمساك باللاعب!")
	
	# إخفاء واجهة المستخدم المباشرة وإظهار الماوس
	get_tree().call_group("ui", "hide")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# تصفير العدادات لإعادة محاولة نفس المستوى
	_reset_counters()
	
	# الانتقال المباشر لشاشة الخسارة
	get_tree().change_scene_to_file("res://main/game_over.tscn")

func _reset_counters() -> void:
	current_orange = 0
	current_red = 0
