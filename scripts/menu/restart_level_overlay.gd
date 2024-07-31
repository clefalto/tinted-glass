extends Control

@onready var color_rect: ColorRect = $ColorRect
@onready var b_restart_level: Button = $RestartLevelButton
@onready var b_main_menu: Button = $MainMenuButton

# Called when the node enters the scene tree for the first time.
func _ready():
	color_rect.color.a = 0.0
	b_restart_level.button_down.connect(LevelManager.reset_level)
	b_main_menu.button_down.connect(LevelManager.return_to_menu)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	color_rect.color.a = clamp(color_rect.color.a + delta, 0.0, 0.6)
