tool
extends "res://addons/multi_scene_editor/scripts/base_operation.gd"

var material_path:NodePath

var regex_match_string

export var apply_to_path:NodePath
var apply_to:OptionButton

export var material_label_path:NodePath 
var material_label:LineEdit

export var application_options_path:NodePath
var application_options

export var regex_match_input_path:NodePath
var regex_match_input:LineEdit

export var surface_indexes_edit_path:NodePath
var surface_indexes_edit:LineEdit

var application_selection:int = 0

# The pattern to match against node names
var regex_pattern = ""

signal open_file_pressed(filters,selection_mode)

func _enter_tree():
	material_label = get_node(material_label_path)

	apply_to = get_node(apply_to_path)
	application_options = get_node(application_options_path)
	application_options.visible = false
	regex_match_input = get_node(regex_match_input_path)
	surface_indexes_edit = get_node(surface_indexes_edit_path)

	# Connections
	var _connection
	if(!apply_to.is_connected("item_selected",self,"apply_to_changed")):
		_connection = apply_to.connect("item_selected",self,"apply_to_changed")
		pass
	if(!regex_match_input.is_connected("text_changed",self,"regex_matched_changed")):
		_connection = regex_match_input.connect("text_changed",self,"regex_matched_changed")
		pass
	if(!surface_indexes_edit.is_connected("text_changed",self,"indexes_changed")):
		_connection = surface_indexes_edit.connect("text_changed",self,"indexes_changed")
		pass

	verify_input("")
	pass

# Returns a JSON object of parameters
func get_operation_parameters():
	var operation_parameters = {}

	operation_parameters['operation_type'] = "apply_material"
	operation_parameters['material_to_apply'] = material_path
	operation_parameters['application_type'] = "all" if application_selection == 0 else "match_name"
	operation_parameters['regex_pattern'] = regex_pattern


	# Material slot index
	var indexes_to_apply = surface_indexes_edit.text.split(",",false)
	var indexes = []
	for index in indexes_to_apply:
		if(int(index) != null):
			indexes.push_back(int(index))
			pass
		pass

	operation_parameters['material_indexes'] = indexes

	return operation_parameters
	pass

# Triggers the open file dialog
func select_material_button_pressed():
	emit_signal("open_file_pressed",["*.tres","*.material","*.res"],0)
	pass

# A filepath was returned by the main dialog control
func return_file_dialog_path(file_path):
	material_path = file_path
	material_label.text = file_path
	verify_input("")
	pass

# Signal handler for when RegEx match changes
func regex_matched_changed(new_pattern):
	regex_pattern = new_pattern
	verify_input("")
	pass

func indexes_changed(new_indexes):
	verify_input("")
	pass

# How we're applying the material changed
func apply_to_changed(new_index:int):
	application_selection = new_index

	match(new_index):
		# All Meshes
		0:
			application_options.visible = false
			pass
		# RegEx match
		1:
			application_options.visible = true
			pass
		_:
			return

	verify_input("")
	pass


func verify_input(_null_arg):
	is_operation_valid  = false
	
	if(material_path == "" || material_path == null):
		error_label.visible = true
		error_label.text = "ERROR: No Material Selected!"
		return

	if(application_selection == 1 && regex_pattern == ""):
		error_label.visible = true
		error_label.text = "ERROR: No RegEx Pattern Defined!"
		return

	if(surface_indexes_edit.text == ""):
		error_label.visible = true
		error_label.text = "ERROR: No Material Indexes Defined!"
		return

	# All checks have passed, operation is valid
	is_operation_valid = true
	error_label.visible = false
	pass
