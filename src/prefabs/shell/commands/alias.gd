class_name ShellCommandAlias
extends ShellCommand


func _on_execute(shell: Shell, args: Array[Variant] = [], io: Terminal = null) -> bool:
	if len(args) != 2:
		if io: io.error("Usage: alias <COMMAND> <NAME>.")
		return false
	
	var command_name := str(args[0])
	var alias := str(args[1])
	
	if not shell.add_alias(command_name, alias):
		if io: io.error("Could not add name %s for %s." % [alias, command_name])
		return false
	
	if io: io.success("Added name %s for %s." % [alias, command_name])
	return true
