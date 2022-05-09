tool
extends "res://addons/multi_scene_editor/scripts/base_operation.gd"

# References
var add_to_root_check:CheckBox
var non_root_add


export var scene_to_add_label_path:NodePath
var scene_to_add_label:LineEdit


export var set_added_scene_button_path:NodePath
var set_added_scene_button:Button

export var remove_operation_path:NodePath
var remove_operation

export var non_root_add_error_path:NodePath
var non_root_add_error_item:OptionButton


# Data fields 
export(Dictionary) var data_input_fields = {}
export(Dictionary) var data_toggles = {}

signal open_file_pressed(filters,selection_mode)

# Called when the node enters the scene tree for the first time.
func _enter_tree():
	add_to_root_check = $MarginContainer/Wrapper/Body/Parameters/AddToRoot
	non_root_add = $MarginContainer/Wrapper/Body/Parameters/NonRootAdd
	remove_operation = get_node(remove_operation_path)
	set_added_scene_button = get_node(set_added_scene_button_path)
	scene_to_add_label = get_node(scene_to_add_label_path)
	error_label = get_node(error_label_path)
	non_root_add_error_item = get_node(non_root_add_error_path)

	var _connection = add_to_root_check.connect("toggled",self,"add_to_root_changed")
	_connection = remove_operation.connect("pressed",self,"remove_button_pressed")
	_connection = set_added_scene_button.connect("pressed",self,"open_file_pressed")

	if(!scene_to_add_label.is_connected("text_changed",self,"verify_input")):
		_connection = scene_to_add_label.connect("text_changed",self,"verify_input")
		pass

	#print(data_input_fields.keys())
	for object_path in data_input_fields.keys():
		var node = get_node(data_input_fields[object_path])
		if(node is LineEdit):
			node.connect("text_changed",self,"verify_input")
			continue
			pass
	
		pass


	for object_path in data_toggles.keys():
		var node = get_node(data_toggles[object_path])
		if(node is CheckBox):
			node.connect("toggled",self,"verify_input")
			continue
			pass
	
		pass
	

	# Setup initial variables
	add_to_root_check.pressed = true
	non_root_add.visible = false

	# Run initial check
	verify_input(null)
	pass

# Get the parameters of the operation
func get_operation_parameters():
	var operation_parameters = {}

	operation_parameters['operation_type'] = "add"
	operation_parameters['scene_to_modify'] = scene_to_add_label.text
	operation_parameters['add_to_root'] = get_node(data_toggles['add_to_root']).pressed

	operation_parameters['non_root_add_name'] = get_node(data_input_fields["non_root_add_name"]).text

	var non_root_failure_choice = "exit" if non_root_add_error_item.selected == 0 else "add_to_root"

	operation_parameters['non_root_add_error'] = non_root_failure_choice

	# Position offset

	# Set default if blank
	get_node(data_input_fields['offset_x']).text = "0" if get_node(data_input_fields['offset_x']).text == "" else get_node(data_input_fields['offset_x']).text
	get_node(data_input_fields['offset_y']).text = "0" if get_node(data_input_fields['offset_y']).text == "" else get_node(data_input_fields['offset_y']).text
	get_node(data_input_fields['offset_z']).text = "0" if get_node(data_input_fields['offset_z']).text == "" else get_node(data_input_fields['offset_z']).text

	var node_pos_offset = Vector3(float(get_node(data_input_fields['offset_x']).text),float(get_node(data_input_fields['offset_y']).text),float(get_node(data_input_fields['offset_z']).text))
	operation_parameters['node_offset'] = node_pos_offset

	# Rotation

	# Set default if blank
	get_node(data_input_fields['rot_x']).text = "0" if get_node(data_input_fields['rot_x']).text == "" else get_node(data_input_fields['rot_x']).text
	get_node(data_input_fields['rot_y']).text = "0" if get_node(data_input_fields['rot_y']).text == "" else get_node(data_input_fields['rot_y']).text
	get_node(data_input_fields['rot_z']).text = "0" if get_node(data_input_fields['rot_z']).text == "" else get_node(data_input_fields['rot_z']).text


	var node_rotation = Vector3(float(get_node(data_input_fields['rot_x']).text),float(get_node(data_input_fields['rot_y']).text),float(get_node(data_input_fields['rot_z']).text))
	operation_parameters['node_rotation'] = node_rotation

	# Scale

	# Set default if blank
	get_node(data_input_fields['scale_x']).text = "0" if get_node(data_input_fields['scale_x']).text == "" else get_node(data_input_fields['scale_x']).text
	get_node(data_input_fields['scale_y']).text = "0" if get_node(data_input_fields['scale_y']).text == "" else get_node(data_input_fields['scale_y']).text
	get_node(data_input_fields['scale_z']).text = "0" if get_node(data_input_fields['scale_z']).text == "" else get_node(data_input_fields['scale_z']).text

	var node_scale = Vector3(float(get_node(data_input_fields['scale_x']).text),float(get_node(data_input_fields['scale_y']).text),float(get_node(data_input_fields['scale_z']).text))
	operation_parameters['node_scale'] = node_scale


	return operation_parameters
	pass

	
func open_file_pressed():
	emit_signal("open_file_pressed",["*.tscn"],0)
	pass

# A filepath was returned by the main dialog control
func return_file_dialog_path(file_path):
	scene_to_add_label.text = file_path
	verify_input(null)

	return

func vec_three_to_json(x,y,z)-> Dictionary:
	var new_dict = {}
	new_dict['x'] = x;
	new_dict['y'] = y;
	new_dict['z'] = z;
	return new_dict
	pass

# Returns bool indicating if all values in the operation valid
func get_is_operation_valid()->bool: return is_operation_valid

# Verify that all input is correct
func verify_input(var _null_arg):

	var valid_pos = get_node(data_input_fields['offset_x']).text.strip_edges().is_valid_float() \
					&& get_node(data_input_fields['offset_y']).text.strip_edges().is_valid_float() \
					&& get_node(data_input_fields['offset_z']).text.strip_edges().is_valid_float()

	if(!valid_pos):
		error_label.text = "ERROR: Invalid POSITION"
		error_label.visible = true
		is_operation_valid = false
		return
		pass


	var valid_rot =    get_node(data_input_fields['rot_x']).text.strip_edges().is_valid_float() \
					&& get_node(data_input_fields['rot_y']).text.strip_edges().is_valid_float() \
					&& get_node(data_input_fields['rot_z']).text.strip_edges().is_valid_float()

	if(!valid_rot):
		error_label.text = "ERROR: Invalid ROTATION"
		error_label.visible = true
		is_operation_valid = false
		return
		pass

	var valid_scale =    get_node(data_input_fields['scale_x']).text.strip_edges().is_valid_float() \
					&& get_node(data_input_fields['scale_y']).text.strip_edges().is_valid_float() \
					&& get_node(data_input_fields['scale_z']).text.strip_edges().is_valid_float()


	# Also make sure scale is not (0,0,0)
	if(valid_scale):
		valid_scale = Vector3(float(get_node(data_input_fields['scale_x']).text.strip_edges()),float(get_node(data_input_fields['scale_y']).text.strip_edges()),float(get_node(data_input_fields['scale_z']).text.strip_edges())) != Vector3.ZERO
		pass


	# Validate non-root add
	if(!get_node(data_toggles["add_to_root"]).pressed && get_node(data_input_fields["non_root_add_name"]).text == ""):
		error_label.text = "ERROR: Non-root parent name not defined!"
		error_label.visible = true
		is_operation_valid = false
		return
		pass

	#print(scene_to_add_label.text)
	if(scene_to_add_label.text == ""):
		error_label.text = "ERROR: No scene selected!"
		error_label.visible = true
		is_operation_valid = false
		return

	if(!valid_scale):
		error_label.text = "ERROR: Invalid SCALE"
		error_label.visible = true
		is_operation_valid = false
		return


	error_label.visible = false
	is_operation_valid = true
	pass

func remove_button_pressed():
	self.queue_free()
	pass

func _exit_tree():
	if(add_to_root_check.is_connected("toggled",self,"add_to_root_changed")):
		add_to_root_check.disconnect("toggled",self,"add_to_root_changed")
		pass
	if(remove_operation.is_connected("pressed",self,"remove_button_pressed")):
		remove_operation.disconnect("pressed",self,"remove_button_pressed")
		pass
	if(set_added_scene_button.is_connected("pressed",self,"open_file_pressed")):
		set_added_scene_button.disconnect("pressed",self,"open_file_pressed")
		pass

	pass

func add_to_root_changed(is_checked:bool):
	non_root_add.visible = !is_checked
	pass