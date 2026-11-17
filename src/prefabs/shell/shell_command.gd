@abstract
@icon("uid://bvg1uy2b88a0g")
class_name ShellCommand
extends Resource


@export_multiline var description: String
@export_group("Requirements", "requires")
@export var requires_shell: bool = true
@export var requires_simulation: bool = true
@export var requires_terminal: bool = false
@export_range(0, 100, 1) var requires_arguments: int
@export_group("Execution Time", "execution_time")
@export_range(0.0, 60.0, 0.1) var execution_time_min: float = 0.0
@export_range(0.0, 60.0, 0.1) var execution_time_max: float = 0.0

var execution_time: float:
	set(value):
		execution_time_min = value
		execution_time_max = 0.0
	get():
		if execution_time_min <= 0.0 and execution_time_max <= 0.0:
			return 0.0
		if execution_time_min >= execution_time_max:
			return execution_time_min
		return randf_range(execution_time_min, execution_time_max)
var execution_time_consistent: bool:
	get():
		if execution_time_min <= 0.0 and execution_time_max <= 0.0:
			return true
		if execution_time_min >= execution_time_max:
			return true
		return false


@warning_ignore("unused_parameter")
func _on_execute(shell: Shell, args: Array[Variant] = [], io: Terminal = null) -> bool:
	return true


func execute(shell: Shell, args: Array[Variant] = [], io: Terminal = null) -> bool:
	if not can_execute(shell, args, io):
		return false
	@warning_ignore("redundant_await")
	return await _on_execute(shell, args, io)


func can_execute(shell: Shell, args: Array[Variant] = [], io: Terminal = null) -> bool:
	if len(args) < requires_arguments:
		if io: io.error("Command requires at least %s arguments." % requires_arguments)
		return false
	if requires_shell and not (shell and shell.is_node_ready()):
		if io: io.error("Shell is not specified or not ready.")
		return false
	if requires_simulation and not (shell.simulation and shell.simulation.is_node_ready()):
		if io: io.error("Shell does not have access to a simulation or the smulation is not ready.")
		return false
	if requires_terminal and not (io and io.is_node_ready()):
		return false
	return true


func sleep(shell: Shell, ratio: float = 1.0):
	if shell and execution_time > 0.0:
		await shell.sleep(execution_time * ratio)
