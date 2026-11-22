class_name ShellCommandRename
extends ShellCommand

func _on_execute(shell: Shell, args: Array[Variant] = [], io: Terminal = null) -> bool:
	if len(args) != 2:
		if io: io.error("Usage: rename <COMMAND> <NEW_NAME>.")
		return false
	
	var old_name := str(args[0])
	var new_name := str(args[1])
	
	if not shell.rename_command(old_name, new_name):
		if io: io.error("Could not rename %s to %s." % [old_name, new_name])
		return false
	
	if io: io.success("Renamed %s to %s." % [old_name, new_name])
	return true
