class_name ShellCommandUnalias
extends ShellCommand


func _on_execute(shell: Shell, args: Array[Variant] = [], io: Terminal = null) -> bool:
	if len(args) != 1:
		if io: io.error("Usage: unalias <NAME>.")
		return false
	
	var alias := str(args[0])
	
	if not shell.remove_alias(alias):
		if io: io.error("Could not remove name %s." % alias)
		return false
	
	if io: io.success("Removed name %s." % alias)
	return true
