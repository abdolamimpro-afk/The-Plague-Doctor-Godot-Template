extends CanvasLayer

@onready var retry_button: Button = %RetryButton
@onready var menu_button: Button = %MenuButton
@onready var continue_button: Button = %ContinueButton
@onready var volume_slider: HSlider = %Volume
@onready var sensitivity_slider: HSlider = %Sensivity
@onready var click: AudioStreamPlayer = %Click

func _ready() -> void:
	# تأكد إن القائمة تشتغل حتى واللعبة موقوفة (Paused)
	process_mode = Node.PROCESS_MODE_ALWAYS

	# --- 1. إعدادات الصوت (Volume) ---
	if volume_slider:
		volume_slider.min_value = -40.0
		volume_slider.max_value = 6.0
		volume_slider.step = 0.5
		
		var master_bus = AudioServer.get_bus_index("Master")
		volume_slider.value = AudioServer.get_bus_volume_db(master_bus)
		volume_slider.value_changed.connect(_on_volume_changed)

	# --- 2. إعدادات الحساسية (Sensitivity) ---
	if sensitivity_slider:
		sensitivity_slider.min_value = 0.0005
		sensitivity_slider.max_value = 0.0100
		sensitivity_slider.step = 0.0005
		
		# القيمة تُقرأ من Settings مباشرة، مش من الـ Player
		sensitivity_slider.value = Settings.mouse_sensitivity
		sensitivity_slider.value_changed.connect(_on_sensitivity_changed)

	# --- 3. ربط الأزرار ---
	if continue_button:
		continue_button.pressed.connect(_on_continue_pressed)
	if retry_button:
		retry_button.pressed.connect(_on_retry_pressed)
	if menu_button:
		menu_button.pressed.connect(_on_menu_pressed)


# زر Continue: استكمال اللعبة من نفس النقطة
func _on_continue_pressed() -> void:
	_play_click()
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	queue_free()


# زر Retry: إعادة تحميل المستوى
func _on_retry_pressed() -> void:
	_play_click()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main/Main.tscn")


# زر Main Menu: العودة للقائمة الرئيسية
func _on_menu_pressed() -> void:
	_play_click()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main/Menu.tscn")


# تغيير الصوت
func _on_volume_changed(value: float) -> void:
	var master_bus = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(master_bus, value)
	AudioServer.set_bus_mute(master_bus, value <= volume_slider.min_value)


# تغيير الحساسية — تُكتب مباشرة بـ Settings (القيمة العالمية)
func _on_sensitivity_changed(value: float) -> void:
	Settings.mouse_sensitivity = value


func _play_click() -> void:
	if click:
		click.play()
