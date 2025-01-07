extends Node2D

@export var card_textures: Array[Texture2D]
@export var card_name_textures: Array[Texture2D]
@export var number_textures: Array[Texture2D]
@export var card_names: Array[String]
@export var number_characters: Array[String]
@export var index_colors: Array[Color]
@export var result_feeling: Array[Texture2D]


@export var phase = ""
var resultText = ""

var appearedCardCount = 0

var cardProgress = 0

@export var appearSound: AudioStream
@export var turnSound: AudioStream
@export var mainBGM: AudioStream

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("RESET")
	playMusic(mainBGM)
	
func cardsAppear():
	$もやもや.get_child(appearedCardCount).appear()
	playSE(appearSound)
	appearedCardCount += 1
	if appearedCardCount == 6:
		$Timer.one_shot = true
		$Timer.wait_time = 0.7
		$Timer.timeout.disconnect(cardsAppear)
		$Timer.timeout.connect(cardsShuffle)
		$Timer.start()

func cardsShuffle():
	for i in range(6):
		var child = $もやもや.get_child(i)
		child.shuffle()
	$AnimationPlayer.play("dawn")
		
func cardPressed(index, symbol):
	playSE(turnSound)
	if phase == "play":
		if cardProgress == index:
			resultText += number_characters[index] + card_names[symbol]
			cardProgress += 1
			if cardProgress == 6:
				print("win")
				$結果ラベル.text = resultText
				$Feeling.texture = result_feeling[0]
				$AnimationPlayer.play("win")
		else:
			print("lose")
			$結果ラベル.text = "思い出せなかった... "
			$Feeling.texture = result_feeling[1]
			$AnimationPlayer.play("win")
			appearedCardCount = 0
			cardProgress = 0
			resultText = ""
			phase = "transitionToResult"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func dream():
	$Timer.one_shot = false
	$Timer.wait_time = 0.5
	if $Timer.timeout.is_connected(cardsShuffle):
		$Timer.timeout.disconnect(cardsShuffle)
	$Timer.timeout.connect(cardsAppear)
	$Timer.start()

func _start(viewport, event, shape_idx):
	if event is InputEventMouseButton && phase == "":
		if (event as InputEventMouseButton).pressed && (event as InputEventMouseButton).button_index == 1:
			var array = [0, 1, 2, 3, 4, 5];
			for i in range(6):
				var child = $もやもや.get_child(i)
				var symbol = array.pick_random()
				child.symbol = symbol
				child.index = i
				array.remove_at(array.find(symbol))
				
				child.card_texture = card_textures[symbol]
				child.card_name = card_name_textures[symbol]
				child.index_texture = number_textures[i]
				child.index_color = index_colors[i]
				if !child.pressed.is_connected(cardPressed):
					child.pressed.connect(cardPressed)
				child.init()
			appearedCardCount = 0
			cardProgress = 0
			resultText = ""
			phase = "play"
			$AnimationPlayer.play("start")
	if event is InputEventMouseButton && phase == "result":
		if (event as InputEventMouseButton).pressed && (event as InputEventMouseButton).button_index == 1:
			$AnimationPlayer.play("return_start")
	
func playAnimation(str):
	$AnimationPlayer.play(str)

func playMusic(audio: AudioStream):
	$Music.stream = audio
	$Music.play()

func playSE(audio: AudioStream):
	$SE.stream = audio
	$SE.play()
