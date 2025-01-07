extends Node2D

var symbol: int
var index: int
var card_texture: Texture2D
var card_name: Texture2D
var index_color: Color
var index_texture: Texture2D

var transition = ""
var transitionFrame = 0
var transitionDuration = 0.2
var padding = 360 * 2
var phase = "dreaming"

signal pressed(index, symbol)

func _ready():
	modulate.a = 0

func init():
	$picture.texture = card_texture
	$name.texture = card_name
	position.x = (index - 2.5) * padding
	position.y = 0
	$number.visible = false
	$number.texture = index_texture
	phase = "dreaming"
	modulate.a = 0
	$base.modulate = Color.WHITE
	transition = ""
	transitionFrame = 0

func appear():
	transitionDuration = 0.6
	transition = "fading"
	transitionFrame = 0

func shuffle():
	transitionDuration = 0.25
	transition = "assembling"
	transitionFrame = 0

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton && phase == "remembering" && transition == "":
		if (event as InputEventMouseButton).pressed && (event as InputEventMouseButton).button_index == 1:
			transitionDuration = 0.3
			transitionFrame = 0
			transition = "scaling"

func _process(delta):
	if transition != "":
		transitionFrame += delta
		match transition:
			"fading":
				modulate.a = transitionFrame / transitionDuration
			"scaling":
				scale.x = abs((transitionFrame - (transitionDuration / 2)) / transitionDuration) * 4
				if transitionFrame > transitionDuration / 2 && phase == "remembering":
					phase = "result"
					$base.modulate = index_color
					$number.visible = true
					pressed.emit(index, symbol)
					
			"assembling":
				position.x = (index - 2.5) * padding * (1 - (transitionFrame / transitionDuration))
				if transitionFrame > transitionDuration:
					transition = "aligning"
					transitionFrame = 0
					$picture.texture = card_texture
			"aligning":
				position.x = (symbol - 2.5) * padding * (transitionFrame / transitionDuration)
		if transitionFrame > transitionDuration:
			match transition:
				"fading":
					modulate.a = 1
				"scaling":
					scale.x = 2
				"aligning":
					position.x = (symbol - 2.5) * padding
					phase = "remembering"
			transition = ""
			transitionFrame = 0
		
