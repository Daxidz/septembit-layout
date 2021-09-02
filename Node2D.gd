extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const SMALL_LIMIT = 25
const MEDIUM_LIMIT = 29
const BIG_LIMIT = 30

const SMALL_SPRITE_SIZE = 24
const MEDIUM_SPRITE_SIZE = 32
const BIG_SPRITE_SIZE = 48

const UPER_MARGIN = 27
const LEFT_MARGIN = 22
const RECT_MARGIN = 1
const SEPARATION = 7

const NB_PER_LINE = 5


# load gif exporter module
const GIFExporter = preload("res://gdgifexporter/gifexporter.gd")
# load quantization module that you want to use
const MedianCutQuantization = preload("res://gdgifexporter/quantization/median_cut.gd")

var exporter

func load_imgs(path):
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				if (file_name.to_int() != 0):
					var dir2 = Directory.new()
					if dir2.open(path + "/" + file_name) == OK:
						dir2.list_dir_begin()
						var sprite = AnimatedSprite.new()
						var texture = dir2.get_next()
						while texture != "":
							if texture.ends_with(".aseprite"):
								var frames = load(path + "/" + file_name + "/" + texture)
								sprite.frames = frames
								add_child(sprite)
								var num = file_name.to_int()
								sprite.playing = true
								if num <= SMALL_LIMIT:
									sprite.position.x = LEFT_MARGIN + (24+1+SEPARATION) * ((num-1) % NB_PER_LINE) + 13
									sprite.position.y = UPER_MARGIN + (24+1+SEPARATION) * ((num-1) / NB_PER_LINE) + 13
								elif num <= MEDIUM_LIMIT:
									sprite.position.x = LEFT_MARGIN + (32+1+SEPARATION) * ((num-1) % 4) + 17
									sprite.position.y = 188 + 16
								else:
									sprite.position.x = 75 + 24
									sprite.position.y = 228 + 24
							texture = dir2.get_next()
						
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

var loaded: bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
	load_imgs("img/anim")
	exporter = GIFExporter.new(198, 292)
	
# https://www.reddit.com/r/godot/comments/lv7pon/not_for_a_game_but_i_made_a_short_animation_using/
var max_frames: int  = 40
var current_frame:int  = 0

const FPS: int = 30
var cur_time: float = 0.0

func _input(event):
	if event.is_action_pressed("ui_accept"):
		loaded = true

func _process(delta):
	
	if !loaded:
		return
	var img : Image = get_viewport().get_texture().get_data()
	img.convert(Image.FORMAT_RGBA8)
	
	img.flip_y()
	img.crop(198, 292)
	
	cur_time += delta
	
	if cur_time > 1.0 / float(FPS):
		if current_frame < max_frames:
			exporter.write_frame(img, current_frame * (1/FPS), MedianCutQuantization)
			current_frame += 1
			cur_time = 0.0
		else:
			var file: File = File.new()
			file.open("res://result2.gif", File.WRITE)
			file.store_buffer(exporter.export_file_data())
			file.close()
			get_tree().quit()
	


