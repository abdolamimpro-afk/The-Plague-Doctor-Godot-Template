extends CanvasLayer

# VBoxContainer اليسار (للعناصر الدائمة)
@onready var orange_label: Label = $VBoxContainer/OrangeLabel
@onready var red_label: Label = $VBoxContainer/RedLabel

# RightVBoxContainer اليمين (للأزرق والأخضر)
@onready var blue_label: Label = $RightVBoxContainer/BlueLabel
@onready var green_label: Label = $RightVBoxContainer/GreenLabel

var _blue_timer: float = 0.0
var _green_timer: float = 0.0

func _ready() -> void:
	add_to_group("ui")
	
	# إخفاء نصوص القدرات المؤقتة في البداية
	if blue_label: blue_label.visible = false
	if green_label: green_label.visible = false
	
	# إعطاء القيم الأولية للعدادات اليسرى
	update_fuse_counters(0, 4, 0, 3)

func _process(delta: float) -> void:
	# العداد التنازلي للفيوز الأزرق (في الحاوية اليمنى)
	if _blue_timer > 0.0:
		_blue_timer -= delta
		if blue_label:
			blue_label.text = "⚡ Stamina Boost: " + str(snapped(_blue_timer, 0.1)) + "s"
		if _blue_timer <= 0.0 and blue_label:
			blue_label.visible = false

	# العداد التنازلي للفيوز الأخضر (في الحاوية اليمنى)
	if _green_timer > 0.0:
		_green_timer -= delta
		if green_label:
			green_label.text = "🔇 Monster Deaf: " + str(snapped(_green_timer, 0.1)) + "s"
		if _green_timer <= 0.0 and green_label:
			green_label.visible = false

# تحديث العدادات البرتقالية والحمراء (يسار الشاشة)
func update_fuse_counters(cur_orange: int, req_orange: int, cur_red: int, req_red: int) -> void:
	if orange_label:
		orange_label.text = "Orange Fuses: " + str(cur_orange) + " / " + str(req_orange)
	if red_label:
		red_label.text = "Red Fuses: " + str(cur_red) + " / " + str(req_red)

# تفعيل قدرة الفيوز الأزرق
func show_blue_power(duration: float) -> void:
	_blue_timer = duration
	if blue_label:
		blue_label.visible = true
		blue_label.text = "⚡ Stamina Boost: " + str(snapped(_blue_timer, 0.1)) + "s"

# تفعيل قدرة الفيوز الأخضر
func show_green_power(duration: float) -> void:
	_green_timer = duration
	if green_label:
		green_label.visible = true
		green_label.text = "🔇 Monster Deaf: " + str(snapped(_green_timer, 0.1)) + "s"
