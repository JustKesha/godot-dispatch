@icon("uid://dhivvk11px2tj")
class_name Terminal
extends Container


signal output_changed(text: String)
signal input_submitted(text: String)
signal new_error_message(raw: String)
signal new_warning_message(raw: String)
signal new_success_message(raw: String)
signal new_message(raw: String)

@export_group("Input", "input")
@export var input_text: String:
	set(value):
		input_text = value
		set_input(input_text)
@export var input_strip: bool
@export_subgroup("History", "input_history")
@export var input_history_limit: int = 100
@export var input_history_ignore_consecutive_duplicates: bool = true
@export var input_history_action_next: StringName = &"ui_down"
@export var input_history_action_previous: StringName = &"ui_up"
@export_subgroup("Submit", "input_submit")
@export var input_submit_allow_empty: bool
@export var input_submit_clear: bool = true
@export var input_submit_log: bool
@export var input_submit_log_format: String = ">%s"
@export_subgroup("Placeholder", "input_placeholder")
@export var input_placeholder_text: String:
	set(value):
		input_placeholder_text = value
		_set_placeholder(input_placeholder_text)
@export_range(0.0, 1.0, 0.1) var input_placeholder_opacity: float = 0.5:
	set(value):
		input_placeholder_opacity = value
		_set_color(color_text)
@export_group("Output", "output")
@export_multiline var output_text: String:
	set(value):
		output_text = value
		set_output(output_text)
@export_subgroup("Format", "output_format")
@export var output_format_error: String = "ERROR: %s"
@export var output_format_warning: String = "WARNING: %s"
@export var output_format_success: String = "SUCCESS: %s"
@export_subgroup("Ignore", "output_ignore")
@export var output_ignore_error: bool
@export var output_ignore_warning: bool
@export var output_ignore_success: bool
@export_group("Theme")
@export var font_size: int = 16:
	set(value):
		font_size = value
		_set_font_size(font_size)
@export_subgroup("Colors", "color")
@export var color_error: Color = Color.RED
@export var color_warning: Color = Color.ORANGE
@export var color_success: Color = Color.GREEN
@export var color_text: Color = Color.WHITE:
	set(value):
		color_text = value
		_set_color(color_text)
@export var color_background: Color:
	set(value):
		color_background = value
		_set_background_color(color_background)

@onready var background: ColorRect = %Background
@onready var output: RichTextLabel = %Output
@onready var input: LineEdit = %Input

var _input_history: Array[String] = []
var _history_current_index: int = 0


func _ready():
	_set_color(color_text)
	_set_background_color(color_background)
	_set_font_size(font_size)
	_set_placeholder(input_placeholder_text)
	set_input(input_text)
	set_output(output_text)


func _add_input_to_history(new_text: String):
	if _input_history.is_empty() or \
			(not input_history_ignore_consecutive_duplicates or _input_history.back() != new_text):
		
		_input_history.append(new_text)
		
		while _input_history.size() > input_history_limit and input_history_limit >= 0:
			_input_history.remove_at(0)
	
	_history_current_index = _input_history.size()


func _input_history_step(step: int = 1) -> String:
	_history_current_index = clampi(_history_current_index + step, 0, _input_history.size())
	if _history_current_index >= _input_history.size():
		return ""
	return _input_history[_history_current_index]


func _on_input_text_submitted(new_text: String):
	if not new_text.strip_edges() and not input_submit_allow_empty:
		return
	if input_strip:
		new_text = new_text.strip_edges()
	if input_submit_clear:
		set_input("")
	if input_submit_log:
		write(input_submit_log_format % new_text)
	_add_input_to_history(new_text) 
	input_submitted.emit(new_text)


func _on_input_gui_input(event: InputEvent):
	if event.is_action_pressed(input_history_action_next, true):
		set_input(_input_history_step(1))
		input.caret_column = input.text.length()
		input.accept_event()
	elif event.is_action_pressed(input_history_action_previous, true):
		set_input(_input_history_step(-1))
		input.caret_column = input.text.length()
		input.accept_event()


func _set_color(color: Color):
	if output:
		output.add_theme_color_override("default_color", color)
		output.add_theme_color_override("selection_color", color)
	
	if input:
		input.add_theme_color_override("font_color", color)
		input.add_theme_color_override("font_uneditable_color", color)
		input.add_theme_color_override("caret_color", color)
		input.add_theme_color_override("selection_color", color)
		
		var placeholder_color := color
		placeholder_color.a = input_placeholder_opacity
		input.add_theme_color_override("font_placeholder_color", placeholder_color)


func _set_background_color(color: Color):
	if background:
		background.color = color
	
	if output:
		output.add_theme_color_override("font_selected_color", color)
	
	if input:
		input.add_theme_color_override("font_selected_color", color)


func _set_font_size(new_font_size: int):
	if output:
		output.add_theme_font_size_override("normal_font_size", new_font_size)
		output.add_theme_font_size_override("bold_font_size", new_font_size)
		output.add_theme_font_size_override("bold_italics_font_size", new_font_size)
		output.add_theme_font_size_override("italics_font_size", new_font_size)
		output.add_theme_font_size_override("mono_font_size", new_font_size)
	
	if input:
		input.add_theme_font_size_override("font_size", new_font_size)


func _set_placeholder(placeholder: String):
	if input:
		input.placeholder_text = placeholder


func set_output(content: Variant):
	if not output:
		return
	output.text = str(content)
	output_changed.emit(output.text)


func add_output(content: Variant):
	if not output:
		return
	output.text += str(content)


func set_input(content: Variant):
	if not input:
		return
	input.text = str(content)


func add_input(content: Variant):
	if not input:
		return
	input.text += str(content)


func write(message: Variant, color: Color = color_text, end: String = "\n"):
	if not output:
		return
	message = str(message)
	output.text += "[color=#%s]%s[/color]" % [color.to_html(), message + end]
	new_message.emit(message)


func error(message: Variant):
	if output_ignore_error:
		return
	message = str(message)
	write(output_format_error % message, color_error)
	new_error_message.emit(message)


func warning(message: Variant):
	if output_ignore_warning:
		return
	message = str(message)
	write(output_format_warning % str(message), color_warning)
	new_warning_message.emit(message)


func success(message: Variant):
	if output_ignore_success:
		return
	message = str(message)
	write(output_format_success % str(message), color_success)
	new_success_message.emit(message)


func read() -> String:
	return output.text if output else ""


func clear():
	if not output:
		return
	output.text = ""


func submit(message: Variant = ""):
	if message == "":
		message = input.text
	_on_input_text_submitted(message)


func listen() -> String:
	var text: String = await input_submitted
	return text
