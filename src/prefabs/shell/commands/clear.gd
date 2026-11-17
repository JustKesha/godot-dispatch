class_name ShellCommandClear
extends ShellCommand


@warning_ignore("unused_parameter")
func _on_execute(shell: Shell, args: Array[Variant] = [], io: Terminal = null) -> bool:
	io.clear()
	return true


func can_execute(shell: Shell, args: Array[Variant] = [], io: Terminal = null) -> bool:
	return super(shell, args, io) and io
