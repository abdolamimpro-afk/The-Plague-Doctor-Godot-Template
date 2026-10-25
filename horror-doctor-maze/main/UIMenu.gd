extends CanvasLayer

# --- تعريف العقد بالأنواع الصحيحة تماماً ---
@onready var color_rect: ColorRect = $ColorRect
@onready var title_label: Label = %TitleLabel

# تفعيل نوع Control أو VBoxContainer لتفادي التعارض
@onready var main_menu_panel: Control = %MainMenuPanel
@onready var play_button: Button = $MainMenuPanel/PlayButton
@onready var quit_button: Button = $MainMenuPanel/QuitButton

@onready var story_panel: Control = %StoryPanel
@onready var story_title: Label = $StoryPanel/StoryTitle
@onready var story_text: Label = $StoryPanel/StoryText

@onready var continue_button: Button = %ContinueButton
@onready var click: AudioStreamPlayer = %Click
@onready var music: AudioStreamPlayer = %AudioStreamPlayer


func _ready() -> void:
	if music:
		music.play()
		
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	_setup_initial_ui_state()
	
	if play_button:
		play_button.pressed.connect(_on_play_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)
	if continue_button:
		continue_button.pressed.connect(_on_continue_pressed)


func _setup_initial_ui_state() -> void:
	if title_label:
		title_label.visible = true
	if main_menu_panel:
		main_menu_panel.visible = true
		
	if color_rect:
		color_rect.visible = false
	if story_panel:
		story_panel.visible = false
	if continue_button:
		continue_button.visible = false


func _on_play_pressed() -> void:
	_play_click_sound()
	
	if title_label:
		title_label.visible = false
	if main_menu_panel:
		main_menu_panel.visible = false
		
	if color_rect:
		color_rect.visible = true
	if story_panel:
		story_panel.visible = true
	if continue_button:
		continue_button.visible = true


func _on_continue_pressed() -> void:
	_play_click_sound()
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if music:
		music.stop()
		
	get_tree().change_scene_to_file("res://main/Main.tscn")


func _on_quit_pressed() -> void:
	_play_click_sound()
	get_tree().quit()


func _play_click_sound() -> void:
	if click:
		click.play()
