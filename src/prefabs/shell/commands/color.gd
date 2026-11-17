class_name ShellCommandColor
extends ShellCommand


@warning_ignore("unused_parameter")
func _on_execute(shell: Shell, args: Array[Variant] = [], io: Terminal = null) -> bool:
	io.color_text = Color.from_string(args[0], io.color_text)
	return true
