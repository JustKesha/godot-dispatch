@icon("uid://dp6yqtjttme6r")
class_name Device2D
extends Node2D


signal interacted()
signal enabled_changed(value: bool)


@export var enabled: bool = true:
	set(value):
		if enabled == value:
			return
		enabled = value
		update_label()
		enabled_changed.emit(enabled)

@onready var label := get_node_or_null("%Label") as Label


func _ready():
	update_label()


func _on_interact() -> bool:
	return true


func _get_label_text() -> String:
	return name


func interact() -> bool:
	if not enabled or not _on_interact():
		return false
	interacted.emit()
	return true


func update_label():
	if not label:
		return
	label.visible = enabled
	label.text = _get_label_text()
