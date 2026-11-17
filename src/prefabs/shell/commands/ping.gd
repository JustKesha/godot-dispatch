class_name ShellCommandPing
extends ShellDeviceCommand


@warning_ignore("unused_parameter")
func _on_batch_execution_begin(shell: Shell, args: Array[Variant] = [], io: Terminal = null):
	match len(args):
		1: if io: io.write("Pinging %s..." % args[0])
		_: if io: io.write("Pinging %s targets..." % len(args))


func _on_device_not_found(shell: Shell, item: Variant, io: Terminal = null):
	await sleep(shell)
	if io: io.error("Could not ping %s." % item)


func _process_device(shell: Shell, device: Device2D, io: Terminal = null) -> bool:
	await sleep(shell)
	if io: io.write(_get_target_info(device, io))
	return true


func _get_target_info(device: Device2D, io: Terminal) -> String:
	var sections: Array[String]
	
	sections.append("TARGET: " + device.name)
	sections.append("STATUS: " + (
		"[color=%s]LIVE[/color]" % io.color_success
		if device.enabled else
		"[color=%s]DISABLED[/color]" % io.color_error
		))
	
	return "\n".join(sections)
