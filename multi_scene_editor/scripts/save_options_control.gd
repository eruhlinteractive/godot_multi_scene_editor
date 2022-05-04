tool
extends WindowDialog


export var search_text_path:NodePath
var search_text:LineEdit

export var replace_text_path:NodePath
var replace_text:LineEdit

export var use_regex_path:NodePath
var use_regex_toggle:CheckBox

export var prefix_text_path:NodePath
var prefix_text:LineEdit

export var suffix_text_path:NodePath
var suffix_text:LineEdit

export var folder_path_text_path:NodePath
var folder_path_text:LineEdit

export var accept_button_path:NodePath
var accept_button:Button

export var cancel_button_path:NodePath
var cancel_button:Button

export var reset_options_button_path:NodePath
var reset_options_button:Button

export var select_folder_button_path:NodePath
var select_folder_button:Button

export var clear_folder_button_path:NodePath
var clear_folder_button:Button

export var error_text_path:NodePath
var error_text:Label

var save_options:Dictionary = {}

signal open_file_pressed(filters,selection_mode)

func _enter_tree():

	# Init references
	search_text = get_node(search_text_path)
	replace_text = get_node(replace_text_path)
	use_regex_toggle = get_node(use_regex_path)
	prefix_text = get_node(prefix_text_path)
	suffix_text = get_node(suffix_text_path)
	folder_path_text = get_node(folder_path_text_path)
	accept_button = get_node(accept_button_path)
	cancel_button = get_node(cancel_button_path)
	error_text = get_node(error_text_path)
	select_folder_button = get_node(select_folder_button_path)
	clear_folder_button = get_node(clear_folder_button_path)
	reset_options_button = get_node(reset_options_button_path)

	error_text.visible = false

	# Setup connections
	if(!search_text.is_connected("text_changed",self,"verify_options")):
		var _connection = search_text.connect("text_changed",self,"verify_options")
		pass

	if(!accept_button.is_connected("pressed",self,"accept_button_pressed")):
		var _connection = accept_button.connect("pressed",self,"accept_button_pressed")
		pass

	if(!use_regex_toggle.is_connected("toggled",self,"verify_options")):
		var _connection = use_regex_toggle.connect("toggled",self,"verify_options")
		pass

	if(!cancel_button.is_connected("pressed",self,"cancel_button_pressed")):
		var _connection = cancel_button.connect("pressed",self,"cancel_button_pressed")
		pass

	if(!select_folder_button.is_connected("pressed",self,"select_folder_pressed")):
		var _connection = select_folder_button.connect("pressed",self,"select_folder_pressed")
		pass
	
	if(!clear_folder_button.is_connected("pressed",self,"clear_folder_button_pressed")):
		var _connection = clear_folder_button.connect("pressed",self,"clear_folder_button_pressed")
		pass

	if(!reset_options_button.is_connected('pressed',self,'reset_options')):
		reset_options_button.connect('pressed',self,'reset_options')
		pass

	# Initialize default options
	init_default_options()

	pass

# Set up default save options
func init_default_options():
	save_options['directory'] = ""
	save_options['prefix'] = ""
	save_options['suffix'] = ""
	save_options['use_regex'] = false
	save_options['search'] = ""
	save_options['replace'] = ""
	pass

# Resets option display and hides popup
func cancel_button_pressed():
	update_ui_display()
	visible = false
	pass

# Updates UI to match save_options
func update_ui_display():
	folder_path_text.text 		= save_options['directory']
	prefix_text.text 			= save_options['prefix']
	suffix_text.text 			= save_options['suffix']
	use_regex_toggle.pressed 	= save_options['use_regex'] 
	search_text.text 			= save_options['search']
	replace_text.text 			= save_options['replace']
	pass

# Resets options to default
func reset_options():
	init_default_options()
	update_ui_display()
	pass

# Clears the save directory input
func clear_folder_button_pressed():
	folder_path_text.text = ""
	pass

# Update the save options
func accept_button_pressed():
	# TODO: Update preferences json
	save_options['directory'] = folder_path_text.text
	save_options['prefix'] = prefix_text.text
	save_options['suffix'] = suffix_text.text
	save_options['use_regex'] = use_regex_toggle.pressed
	save_options['search'] = search_text.text
	save_options['replace'] = replace_text.text
	visible = false
	pass

# Verifies the options
func verify_options(_null):

	# Verify regex search
	if(use_regex_toggle.pressed):
		var reg = RegEx.new()
		var compile_result = reg.compile(search_text.text)

		# Check if the regex match is valid
		if(compile_result != 0 || search_text.text == ""):
			error_text.text = "ERROR: Regex match invalid!"
			error_text.visible = true
			accept_button.disabled = true
			return
		pass

	# All checks passed
	accept_button.disabled = false
	error_text.visible = false
	pass

# Callback for main control file passback
func return_file_dialog_path(file_path):
	folder_path_text.text = file_path
	verify_options(null)
	return

# Request the file browser be opened
func select_folder_pressed():
	emit_signal("open_file_pressed",[],2)
	pass

# Returns a dictionary of the defined save options
func get_save_options():
	return save_options
	pass
