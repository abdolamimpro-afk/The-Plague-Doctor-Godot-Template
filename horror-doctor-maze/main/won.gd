extends CanvasLayer


@onready var menu_button: Button = $VBoxContainer/MenuButton
@onready var retry_button: Button = $VBoxContainer/RetryButton
@onready var click: AudioStreamPlayer = %Click

func _ready() -> void:
	if menu_button:
		menu_button.visible = true
	if retry_button:
		retry_button.visible = true

	# ربط الأحداث بالأزرار
	if menu_button:
		menu_button.pressed.connect(_on_menu_pressed)
	if retry_button:
		retry_button.pressed.connect(_on_retry_pressed)
	


# عند ضغط PLAY: يختفي العنوان والقائمة الرئيسية ويظهر الدليل
func _on_menu_pressed() -> void:
	click.play()
	get_tree().change_scene_to_file("res://main/Menu.tscn")
	
func _on_retry_pressed() -> void:
	click.play()
	get_tree().change_scene_to_file("res://main/Main.tscn")
	
	
	
