@abstract
class_name ShellDeviceCommand
extends ShellBatchCommand


func _process_item(shell: Shell, item: Variant, io: Terminal = null) -> bool:
	var interactable := shell.simulation.find_device(item)
	
	if not interactable:
		await _on_interactable_not_found(shell, item, io)
		return false
	
	@warning_ignore("redundant_await")
	return await _process_interactable(shell, interactable, io)


@warning_ignore("unused_parameter")
func _process_interactable(shell: Shell, interactable: Device2D, io: Terminal = null) -> bool:
	return true


@warning_ignore("unused_parameter")
func _on_interactable_not_found(shell: Shell, item: Variant, io: Terminal = null):
	if io: io.error("Could not find %s." % item)
