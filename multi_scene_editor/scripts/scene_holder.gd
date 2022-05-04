tool
extends Control

var path:String = ""

export var remove_button_path:NodePath
var remove_button:Button


export var scene_label_path:NodePath
var scene_label:Label

signal remove_button_pressed(pressed_from)

func _enter_tree():
	scene_label = get_node(scene_label_path)
	remove_button = get_node(remove_button_path)
	var _connection = remove_button.connect("pressed",self,"remove_pressed")

	pass

func set_path(new_path:String):
	if(path != ""):
		printerr("Scene Holder path was already set!")
		pass
	else:
		path = new_path
		hint_tooltip = new_path
		scene_label.text = path
	pass

func get_scene_path()->String: return path

func remove_pressed():
	emit_signal("remove_button_pressed",self)
	pass


func _exit_tree():
	if(remove_button.is_connected("pressed",self,"remove_pressed")):
		remove_button.disconnect("pressed",self,"remove_pressed")
		return

	pass