@abstract
class_name ShellBatchCommand
extends ShellCommand


func _on_execute(shell: Shell, items: Array[Variant] = [], io: Terminal = null) -> bool:
	if not items:
		@warning_ignore("redundant_await")
		return await _on_batch_empty(shell, io)
	
	var successful_executions := 0
	
	await _on_batch_execution_begin(shell, items, io)
	for item in items:
		@warning_ignore("redundant_await")
		if await _process_item(shell, item, io):
			successful_executions += 1
	await _on_batch_execution_end(shell, items, io)
	
	return successful_executions > 0


@warning_ignore("unused_parameter")
func _on_batch_empty(shell: Shell, io: Terminal = null) -> bool:
	if io: io.error("Batch commands require at least 1 argument.")
	return false


@warning_ignore("unused_parameter")
func _on_batch_execution_begin(shell: Shell, args: Array[Variant] = [], io: Terminal = null):
	pass


@warning_ignore("unused_parameter")
func _on_batch_execution_end(shell: Shell, args: Array[Variant] = [], io: Terminal = null):
	pass


@warning_ignore("unused_parameter")
func _process_item(shell: Shell, item: Variant, io: Terminal = null) -> bool:
	return true
