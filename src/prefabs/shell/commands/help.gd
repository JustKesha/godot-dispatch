class_name ShellCommandHelp
extends ShellBatchCommand


func _on_execute(shell: Shell, args: Array[Variant] = [], io: Terminal = null) -> bool:
	if not shell.commands:
		await sleep(shell)
		io.error("Shell has no available commands.")
		return false
	return await super(shell, args, io)


func _on_batch_empty(shell: Shell, io: Terminal = null) -> bool:
	await sleep(shell)
	io.write(_get_commands_info(shell))
	return true


func _process_item(shell: Shell, command_name: Variant, io: Terminal = null) -> bool:
	await sleep(shell)
	
	var command := shell.get_command(str(command_name))
	
	if not command:
		io.error("Could not find command %s."  % command_name)
		return false
	
	io.write(_get_command_info(shell, command))
	return true


func _get_commands_info(shell: Shell) -> String:
	var sections: Array[String]
	var commands := shell.get_commands()
	
	for command in commands:
		sections.append("%s (%ss) - %s" % [
			", ".join(commands[command]),
			_get_command_execution_time(command),
			command.description,
			])
	
	return "\n".join(sections)


func _get_command_info(shell: Shell, command: ShellCommand) -> String:
	var sections: Array[String]
	var aliases := shell.get_commands().get(command, []) as Array
	
	sections.append("COMMAND: " + aliases[0])
	if len(aliases) > 1:
		sections.append("ALIASES: " + ", ".join(aliases.slice(1)))
	sections.append("DESCRIPTION: " + command.description)
	sections.append("EXECUTION TIME: %s SEC" % _get_command_execution_time(command))
	
	return "\n".join(sections)


func _get_command_execution_time(command: ShellCommand) -> String:
	if command.execution_time_consistent:
		return String.num(command.execution_time, 1)
	return "%.1f-%.1f" % [command.execution_time_min, command.execution_time_max]
