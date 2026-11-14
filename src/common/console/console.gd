class_name Console
extends Container


signal output_changed(text: String)
signal input_submitted(text: String)

@export_group("Input", "input")
@export var input_text: String:
	set(value):
		input_text = value
		set_input(input_text)
@export_subgroup("Submit", "input_submit")
@export var input_submit_allow_empty: bool
@export var input_submit_clear: bool = true
@export var input_submit_log: bool
@export var input_submit_log_form: String = ">%s"
@export_subgroup("Placeholder", "input_placeholder")
@export var input_placeholder_text: String:
	set(value):
		input_placeholder_text = value
		_set_placeholder(input_placeholder_text)
@export_range(0.0, 1.0, 0.1) var input_placeholder_opacity: float = 0.5:
	set(value):
		input_placeholder_opacity = value
		_set_color(color_text)
@export_group("Ouput", "output")
@export_multiline var output_text: String:
	set(value):
		output_text = value
		set_output(output_text)
@export var output_error_form: String = "ERROR: %s"
@export var output_warning_form: String = "WARNING: %s"
@export_group("Theme")
@export var font_size: int = 16:
	set(value):
		font_size = value
		_set_font_size(font_size)
@export_subgroup("Colors", "color")
@export var color_error: Color = Color.RED
@export var color_warning: Color = Color.ORANGE
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


func _ready():
	_set_color(color_text)
	_set_background_color(color_background)
	_set_font_size(font_size)
	_set_placeholder(input_placeholder_text)
	set_input(input_text)
	set_output(output_text)


func _on_input_text_submitted(new_text: String):
	if not new_text and not input_submit_allow_empty:
		return
	if input_submit_clear:
		set_input("")
	if input_submit_log:
		write(input_submit_log_form % new_text)
	input_submitted.emit(new_text)


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
	output.text += "[color=#%s]%s[/color]" % [color.to_html(), str(message) + end]


func error(message: Variant):
	write(output_error_form % str(message), color_error)


func warning(message: Variant):
	write(output_warning_form % str(message), color_warning)


func read() -> String:
	return output.text if output else ""


func clear():
	if not output:
		return
	output.text = ""
	input.text = ""


func sumbit(message: Variant = ""):
	if message == "":
		message = input.text
	_on_input_text_submitted(message)


func listen() -> String:
	var text: String = await input_submitted
	return text
