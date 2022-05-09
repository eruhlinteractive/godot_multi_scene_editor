tool
extends Node

# Prefabs
var add_dialog_prefab = preload("res://addons/multi_scene_editor/add_dialog.tscn")
var remove_dialog_prefab = preload("res://addons/multi_scene_editor/remove_dialog.tscn")
var add_script_dialog_prefab = preload("res://addons/multi_scene_editor/add_script_dialog.tscn")
var apply_material_dialog_prefab = preload("res://addons/multi_scene_editor/apply_material_dialog.tscn")


# Variables

export var dialog_holder_path:NodePath
var dialog_holder

export var operation_dropdown_path:NodePath
var operation_dropdown

export var add_item_button_path:NodePath
var add_item_button

export var clear_operations_button_path:NodePath
var clear_operations_button:Button

export var apply_operations_button_path:NodePath
var apply_operations_button

export var add_scene_button_path:NodePath
var add_scene_button:Button

export var file_dialog_path:NodePath
var file_dialog:FileDialog

export var scene_holder_path:NodePath
var scene_holder

export var action_confirmation_dialog_path:NodePath
var action_confirmation_dialog:ConfirmationDialog 

export var warning_dialog_path:NodePath
var warning_dialog:AcceptDialog

export var save_options_dialog_path:NodePath
var save_options_dialog:WindowDialog

export var edit_save_options_button_path:NodePath
var edit_save_options_button:Button


var current_dialog_requester

var scenes_to_edit = []

var save_options

var multi_scene_edit_script

var scene_label_prefab = preload("res://addons/multi_scene_editor/scene_label.tscn")

func _enter_tree():

	# Reference setup
	dialog_holder = get_node(dialog_holder_path)
	add_item_button = get_node(add_item_button_path)
	operation_dropdown = get_node(operation_dropdown_path)
	file_dialog = get_node(file_dialog_path)
	add_scene_button = get_node(add_scene_button_path)
	scene_holder = get_node(scene_holder_path)
	warning_dialog = get_node(warning_dialog_path)
	action_confirmation_dialog = get_node(action_confirmation_dialog_path)
	apply_operations_button = get_node(apply_operations_button_path)
	clear_operations_button = get_node(clear_operations_button_path)

	save_options_dialog = get_node(save_options_dialog_path)
	edit_save_options_button = get_node(edit_save_options_button_path)

	# Center warning text label
	warning_dialog.get_child(1).align = HALIGN_CENTER

# ---------------------- Connection Setup -------------------------------------
	var _connection
	# Connect signals
	if(!add_item_button.is_connected("pressed",self,"add_operation")):
		_connection = add_item_button.connect("pressed",self,"add_operation")
		pass

	if(!add_scene_button.is_connected("pressed",self,"open_add_scene")):
		_connection = add_scene_button.connect("pressed",self,"open_add_scene")
		pass

	if(!clear_operations_button.is_connected("pressed",self,"clear_operations")):
		_connection = clear_operations_button.connect("pressed",self,"clear_operations")
		pass

	if(!apply_operations_button.is_connected("pressed",self,"show_confirmation_message")):
		_connection = apply_operations_button.connect("pressed",self,"show_confirmation_message")
		pass

	if(!action_confirmation_dialog.is_connected("confirmed",self,"apply_all_operations")):
		_connection = action_confirmation_dialog.connect("confirmed",self,"apply_all_operations")
		pass
	
	# File dialog connections
	if(!file_dialog.is_connected("file_selected",self,"file_dialog_confirmed")):
		_connection = file_dialog.connect("file_selected",self,"file_dialog_confirmed")
		pass

	if(!file_dialog.is_connected("dir_selected",self,"file_dialog_confirmed")):
		_connection = file_dialog.connect("dir_selected",self,"file_dialog_confirmed")
		pass

	# Save option connections
	if(!save_options_dialog.is_connected("open_file_pressed",self,"request_file_dialog")):
		_connection = save_options_dialog.connect("open_file_pressed",self,"request_file_dialog",[save_options_dialog])
		pass	

	if(!edit_save_options_button.is_connected("pressed",self,"open_save_options_dialog")):
		edit_save_options_button.connect("pressed",self,"open_save_options_dialog")
		pass

	# TODO: Add support for multi file selection
	pass
	# ------------------------------------------------------------------------------------

func _exit_tree():
	# Disconnect all connected signals
	if(add_item_button.is_connected("pressed",self,"add_operation")):
		add_item_button.disconnect("pressed",self,"add_operation")
		pass
	if(add_scene_button.is_connected("pressed",self,"open_file_dialog")):
		add_scene_button.disconnect("pressed",self,"open_file_dialog")
		pass

	pass

# Request that the file dialog be opened
func request_file_dialog(file_extensions,selection_mode,requester):
	current_dialog_requester = requester
	open_file_dialog(file_extensions,selection_mode)
	pass

# Opens the file dialog with scene type filters
func open_add_scene():
	open_file_dialog(["*.tscn"],0)
	pass

# Opens the save options dialog
func open_save_options_dialog():
	save_options_dialog.popup()
	pass

# Opens the file dialog with the given file extensions
func open_file_dialog(file_extensions=[],selection_mode=0):
	# FILE MODES:
	# 0 - Only allow selecting one file
	# 2 - Only allow selecting a directory
	file_dialog.mode = selection_mode
	file_dialog.filters = file_extensions
	file_dialog.popup()
	pass


func set_multi_scene_edit(multi_scene_edit):
	multi_scene_edit_script = multi_scene_edit
	pass

# Selection was confirmed in the file dialog
func file_dialog_confirmed(new_file):
	
	var file_path = new_file

	# Return the selected file to the requester
	#  NOTE: Adding a scene to the list of scenes to modify does not set the dialog requester, so this will be skipped
	if(current_dialog_requester != null):
		if(current_dialog_requester.has_method("return_file_dialog_path")):
			current_dialog_requester.return_file_dialog_path(file_path)
			pass

		# reset requester
		current_dialog_requester = null

		file_dialog.hide()
		return
		pass

	# Show warning that scene is already in the list
	if(scenes_to_edit.has(file_path)):
		warning_dialog.dialog_text = "File path " + file_path + " is already in the list of scenes to modify!"
		warning_dialog.popup()
		return
		pass


	# Add new scene label
	var new_scene_label = scene_label_prefab.instance()
	scene_holder.add_child(new_scene_label)
	new_scene_label.set_path(file_path)
	scenes_to_edit.push_back(file_path)

	
	var _connection = new_scene_label.connect("remove_button_pressed",self,"remove_scene_callback")
	file_dialog.hide()
	pass

# Clear all added operations
func clear_operations():
	for child in dialog_holder.get_children():
		child.queue_free()
		pass
	pass

# Make sure the user wants to apply the operations
func show_confirmation_message():
	# No scenes are being edited
	if(scenes_to_edit.empty()):
		warning_dialog.dialog_text = "You have not selected any scenes to edit!"
		warning_dialog.popup()
		return
		pass

	# No modifications configured
	if(dialog_holder.get_child_count() == 0):
		warning_dialog.dialog_text = "There are no pending operations!"
		warning_dialog.popup()
		return
		pass

	# Make sure all operations are valid
	for operation in dialog_holder.get_children():
		if(!operation.get_is_operation_valid()):
			warning_dialog.dialog_text = "One or more operations are not valid! Please verify all input is valid"
			warning_dialog.popup()
			return 
		pass

	var warning = "You are about to make changes to the scenes below. Are you sure you want to continue?"
	var scene_string = "** Scenes To Edit ** \n"

	for path in scenes_to_edit:
		scene_string += "- " + path +"\n"
		pass


	# Display save option review
	var save_option_string = "** Save Options ** \n"

	save_options = save_options_dialog.get_save_options()

	if(save_options['search'] != ""):
		save_option_string += "- Search: " + save_options['search'] +'\n'
		save_option_string += "- Replace With: "
		save_option_string += ("DELETE MATCHED" if save_options['replace'] == "" else save_options['replace']) + '\n'
		save_option_string += "- Use Regex Search: " + ("Yes" if save_options['use_regex'] else "No") + '\n'
	
	# Show prefix and suffix
	save_option_string += "- Prefix: " + ("(NONE)" if save_options['prefix'] == "" else save_options['prefix']) + '\n'
	save_option_string += "- Suffix: " + ("(NONE)" if save_options['suffix'] == "" else save_options['suffix']) + '\n'

	save_option_string += "- Save Directory: " + (save_options['directory'] + "/" if save_options['directory'] != "" else "(ORIGINAL DIRECTORY)") + '\n'


	# Apply text and show confirmation popup
	action_confirmation_dialog.dialog_text = warning + "\n \n" + save_option_string + "\n \n" +  scene_string
	action_confirmation_dialog.popup()
	pass

# Applies all operations
func apply_all_operations():

	var operations_to_apply = []
	var operation_dialogs = dialog_holder.get_children()
	save_options = save_options_dialog.get_save_options()

	for operation in operation_dialogs:
		operations_to_apply.push_front(operation.get_operation_parameters())
		pass

	#print("Applying " + str(operations_to_apply.size()) + " operations!")
	#print(operations_to_apply)

	# TODO: Actually apply operations
	for operation in operations_to_apply:
		match(operation["operation_type"]):

			"add":
				var error = run_add_operation(scenes_to_edit,operation)
				pass
			"remove":
				var error = run_remove_operation(scenes_to_edit,operation)
				pass
			"add_script":
				var error = run_add_script_operation(scenes_to_edit,operation)
				pass
			"apply_material":
				var error = run_apply_material_operation(scenes_to_edit,operation)
			_:
				printerr("WARNING: Operation " + operation["type"] + " is unmatched!")
		pass

	# TODO: Show dialog confirming operations complete 
	# TODO: Once operations have been applied, clear all operations and scenes
	clear_operations()


	warning_dialog.dialog_text = str(operations_to_apply.size()) + " operations have been applied to " + str(scenes_to_edit.size()) + " packed scenes. Please reload any modified scenes."
	warning_dialog.popup()
	pass

func file_dialog_canceled():
	# NO-OP
	pass

# ------------------- Operation Application ------------------------------

# Applies the add operation
func run_add_operation(scenes_to_edit,add_operation_parameters):
	for scene in scenes_to_edit:
		var editable_scene = load(scene)
		
		var edit_root = editable_scene.instance()

		var scene_to_add = load(add_operation_parameters["scene_to_modify"])
		var add_instance = scene_to_add.instance()

		if(!add_operation_parameters["add_to_root"]):
			var node_to_add_to = edit_root.find_node(add_operation_parameters["non_root_add_name"],true)
			

			# Non-root node was not found in the scene tree
			if(node_to_add_to == null):
				match(add_operation_parameters["non_root_add_error"]):
					"exit":
						# No changes are made,resave with no changes
						pass
					"add_to_root":
						# Add to the scene root and set the owner
						edit_root.add_child(add_instance)
						add_instance.set_owner(edit_root)						
						pass
				pass

			# Non-root node was found
			else:
				node_to_add_to.add_child(add_instance)
				add_instance.set_owner(edit_root)
				pass
			pass
			
		# Just add to the root of the scene
		else:
			# Add to the scene root and set the owner
			edit_root.add_child(add_instance)
			add_instance.set_owner(edit_root)
			

		
		# Set transform
		add_instance.transform.origin = add_operation_parameters["node_offset"]

		var rot = add_operation_parameters["node_rotation"]
		var new_rotation = Vector3(deg2rad(rot.x),deg2rad(rot.y),deg2rad(rot.z))
		add_instance.transform.basis = add_instance.transform.basis.slerp(Basis(new_rotation),1.0)
		add_instance.transform = add_instance.transform.scaled(add_operation_parameters["node_scale"])
		 
		editable_scene.pack(edit_root)

		var new_resource_path = apply_save_options(scene)
		# Resave the scene
		ResourceSaver.save(new_resource_path,editable_scene)

		# Unload the current scene
		edit_root.queue_free()
		pass

	pass

# Remove operation
func run_remove_operation(scenes_to_edit,remove_operation_parameters):
	for scene in scenes_to_edit:
		var editable_scene = load(scene)
		var edit_root = editable_scene.instance()
		var node_to_delete = edit_root.find_node(remove_operation_parameters["node_name_to_remove"],true)
		
		# Delete the path if it was found
		if(node_to_delete != null):
			edit_root.remove_child(node_to_delete)
			node_to_delete.queue_free()
			pass
		else:
			print("WARNING: Node of name " + remove_operation_parameters["node_name_to_remove"] + " could not be found. Skipping remove operation...")
			pass


		# Cleanup and resave
		editable_scene.pack(edit_root)

		var new_resource_path = apply_save_options(scene)
		ResourceSaver.save(new_resource_path,editable_scene)

		# Unload the current scene
		edit_root.queue_free()
		pass
	pass

# Apply material operation
func run_apply_material_operation(scenes_to_edit,apply_material_operation_parameters):

	var regex:RegEx = RegEx.new()
	for scene in scenes_to_edit:
		var editable_scene = load(scene)
		var edit_root = editable_scene.instance()

		var material_path = str(apply_material_operation_parameters['material_to_apply'])
		
		var material = load(material_path)

		# Invalid material, bail
		if(material == null || !(material is Material)):
			print("Invalid material at: " + str(apply_material_operation_parameters['material_to_apply']))
			edit_root.queue_free()
			return
			pass

		var meshes_to_apply_material = []
		if(apply_material_operation_parameters['application_type'] == "all"):
			meshes_to_apply_material = get_all_meshes_in_scene(edit_root,edit_root)
			pass
		else:
			meshes_to_apply_material = get_all_meshes_in_scene(edit_root,edit_root)
			# RegEx match
			# https://docs.godotengine.org/en/stable/classes/class_regex.html
			var regex_pattern = apply_material_operation_parameters['regex_pattern']
			regex.compile(regex_pattern)
			if(!regex.is_valid()):
				print("RegEx pattern " + str(regex_pattern) + " is invalid!")
				edit_root.queue_free()
				return

			var matched_meshes = []
			for m in meshes_to_apply_material:
				if(regex.search(m.name) != null):
					matched_meshes.push_back(m)
					pass
				pass
			# Reassign to original array
			meshes_to_apply_material = matched_meshes
			pass

		# Apply material
		for mesh in meshes_to_apply_material:
			if mesh is CSGMesh:
				mesh.material = material
				pass
			elif(mesh is MeshInstance):
				# Apply to multiple slots ('surfaces')
				for i in apply_material_operation_parameters['material_indexes']:
					mesh.set_surface_material(i,material)
				pass
			pass
		

		# Cleanup and resave
		editable_scene.pack(edit_root)
		
		var new_resource_path = apply_save_options(scene)
		ResourceSaver.save(new_resource_path,editable_scene)

		# Unload the current scene
		edit_root.queue_free()
		pass	
	pass

# Add script operation
func run_add_script_operation(scenes_to_edit,add_script_operation_parameters):
	for scene in scenes_to_edit:
		var editable_scene = load(scene)
		var edit_root = editable_scene.instance()
		var script = load(add_script_operation_parameters["script_path"])
		
		# Add to non-root node
		if(!add_script_operation_parameters["add_to_root"]):
			var node_to_add_to = edit_root.find_node(add_script_operation_parameters["non_root_add_name"],true,true)

			# Check the root as well if nothing was found
			if(node_to_add_to == null):
				if(edit_root.name.match(add_script_operation_parameters["non_root_add_name"])):
					node_to_add_to = edit_root
					pass

			# Apply the script if the node is found
			if(node_to_add_to != null):
				node_to_add_to.set_script(script)
				pass

			# Fallback
			else:
				match(add_script_operation_parameters["non_root_add_error"]):
					"exit":
						# No changes are made,resave with no changes
						pass
					"add_to_root":
						# Add to the scene root and set the owner
						edit_root.set_script(script)					
						pass
				pass
			pass

		# Add to root of the scene
		else:
			edit_root.set_script(script)
			pass


		# Cleanup and resave
		editable_scene.pack(edit_root)
		
		var new_resource_path = apply_save_options(scene)
		ResourceSaver.save(new_resource_path,editable_scene)

		# Unload the current scene
		edit_root.queue_free()
		pass
	
# ------------------------------------------------------------------------

# Callback for when a scene is removed from the list of scenes to edit
func remove_scene_callback(label_to_remove):

	# Remove from the list of scenes to edit
	if(scenes_to_edit.has(label_to_remove.get_scene_path())):
		scenes_to_edit.erase(label_to_remove.get_scene_path())
		pass

	# Delete the node
	label_to_remove.queue_free()
	pass

# Recursive function to build array of all meshes
func get_all_meshes_in_scene(node,scene_root):
	# Base case
	if(node.get_child_count() == 0):
		if(node is GeometryInstance):
			return [node]
		else:
			return []
		pass
	else:
		var meshes = []
		for n in node.get_children():
			var children = get_all_meshes_in_scene(n,scene_root)
			if(children != []):
				meshes.append_array(children)
			pass
		return meshes
	pass

	pass

# Modify the save string by applying the save options
func apply_save_options(original_scene_path:String):
	var modified_scene_path = ""

	var reg = RegEx.new()

	# Match isolates the resource name in a scene path
	var compilation = reg.compile("([^\\/]*.(?=\\.))")

	var scene_name = reg.search(original_scene_path).get_string()

	# Match isolates the scene extension (should not be changed by save options)
	compilation = reg.compile("([\\.].*$)")

	var scene_extension = reg.search(original_scene_path).get_string()
	var scene_path = original_scene_path.replace(scene_name,"").replace(scene_extension,"")

	# Overwrite scene path if it has been changed in the save options
	modified_scene_path += save_options['directory'] if save_options['directory'] != "" else scene_path

	var new_scene_name = scene_name
	var regex_compilation_failed = false

	# Apply regex replace to scene name
	if(save_options['use_regex']):
		# Escape any backslashes in the regex pattern
		var regex_pattern = save_options["search"].replacen('\\','\\\\')

		#print(regex_pattern)
		#print(')

		var compilation_status = reg.compile(regex_pattern)

		# Compilation of regex failed
		if(compilation_status != 0):
			printerr("ERROR: Could not compile regex pattern: " + str(regex_pattern))
			regex_compilation_failed = true
			pass
		else:
			new_scene_name = reg.sub(new_scene_name,save_options["replace"],true)
			pass
		pass
	
	# Regex failed or we didn't use it in the first place
	if(save_options['use_regex'] && regex_compilation_failed || !save_options['use_regex']):
		new_scene_name = new_scene_name.replacen(save_options["search"],save_options["replace"])
		pass

	# Apply suffix
	new_scene_name = save_options["prefix"] + new_scene_name + save_options["suffix"]

	# Rebuild resource path
	modified_scene_path += "/" + new_scene_name + scene_extension

	#print(original_scene_path)
	#print(modified_scene_path)
	#print(scene_name)
	#print(scene_extension)
	#print(scene_path)

	#print("======================")

	return modified_scene_path

# Adds an operation to the operation list
func add_operation():
	var selected_option = operation_dropdown.selected

	var new_dialog 

	# Create the dialog and connect signals
	match(selected_option):
		# Add 
		0:
			new_dialog = add_dialog_prefab.instance()
			var _new_connection = new_dialog.connect("open_file_pressed",self,"request_file_dialog",[new_dialog])
			pass

		# Remove
		1:
			new_dialog = remove_dialog_prefab.instance()
			pass

		# Add Script
		2:
			new_dialog = add_script_dialog_prefab.instance()
			var _new_connection = new_dialog.connect("open_file_pressed",self,"request_file_dialog",[new_dialog])
			pass
		# Apply material
		3:
			new_dialog = apply_material_dialog_prefab.instance()
			var _new_connection = new_dialog.connect("open_file_pressed",self,"request_file_dialog",[new_dialog])
			pass
		_:
			pass


	if(new_dialog != null):
		dialog_holder.add_child(new_dialog)
		#print("Added dialog")
		pass
	pass
