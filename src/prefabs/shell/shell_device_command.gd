@abstract
class_name ShellDeviceCommand
extends ShellBatchCommand


func _process_item(shell: Shell, device_name: Variant, io: Terminal = null) -> bool:
	var device := shell.simulation.find_device(device_name)
	
	if not device:
		await _on_device_not_found(shell, device_name, io)
		return false
	
	@warning_ignore("redundant_await")
	return await _process_device(shell, device, io)


@warning_ignore("unused_parameter")
func _process_device(shell: Shell, device: Device2D, io: Terminal = null) -> bool:
	return true


@warning_ignore("unused_parameter")
func _on_device_not_found(shell: Shell, device_name: Variant, io: Terminal = null):
	if io: io.error("Could not find %s." % device_name)
