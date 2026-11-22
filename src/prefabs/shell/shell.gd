@icon("uid://cbrc6nruckpqs")
class_name Shell
extends Node


signal command_executed(command: ShellCommand)

@export var simulation: Simulation2D
@export var terminal: Terminal
@export var commands: Dictionary[String, ShellCommand]
@export_multiline var ready_message: String


func _ready():
	if not simulation:
		simulation = _get_parent_simulation()
	if terminal:
		terminal.write(ready_message)


func _get_parent_simulation() -> Simulation2D:
	var parent: Node = self.get_parent()
	
	while parent:
		if parent is Simulation2D:
			return parent
		parent = parent.get_parent()
	
	return null


func get_command(command_name: String) -> ShellCommand:
	return commands.get(command_name)


func get_commands() -> Dictionary[ShellCommand, Array]:
	var grouped_commands: Dictionary[ShellCommand, Array]
	
	for command_name in commands:
		var command := commands[command_name]
		if not command:
			continue
		if not grouped_commands.has(command):
			grouped_commands[command] = []
		grouped_commands[command].append(command_name)
	
	for command in grouped_commands:
		grouped_commands[command].sort_custom(func(a: String, b: String) -> bool:
			return a.length() > b.length()
		)
	
	return grouped_commands


func rename_command(old_name: String, new_name: String) -> bool:
	var command := get_command(old_name)
	
	if not command or old_name == new_name:
		return false
	
	var existing := get_command(new_name)
	
	if existing and existing != command:
		return false
	
	commands.erase(old_name)
	commands[new_name] = command
	
	return true


func add_alias(command_name: String, alias: String) -> bool:
	var command := get_command(command_name)
	
	if not command or get_command(alias):
		return false
	
	commands[alias] = command
	
	return true


func remove_alias(alias: String) -> bool:
	var command := get_command(alias)
	
	if not command:
		return false
	
	var names := get_commands().get(command, []) as Array
	
	if len(names) <= 1:
		return false
	
	commands.erase(alias)
	
	return true


func execute(command_name: String, args: Array[Variant] = [], io: Terminal = null) -> bool:
	var command := get_command(command_name)
	
	if not command:
		return false
	
	if not io:
		io = terminal
	
	@warning_ignore("redundant_await")
	var output := await command.execute(self, args, io)
	
	command_executed.emit(command)
	
	return output


func parse_and_execute(input: String, io: Terminal = null, delimiter: String = " ") -> bool:
	var input_sections: Array[String]
	
	input_sections.assign(input.split(delimiter))
	
	return await execute(input_sections.get(0), input_sections.slice(1), io)


func sleep(sleep_time: float):
	if sleep_time <= 0:
		return
	var tree := get_tree()
	if tree:
		await tree.create_timer(sleep_time).timeout
