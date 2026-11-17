class_name ShellCommandCall
extends ShellDeviceCommand


@warning_ignore("unused_parameter")
func _on_batch_execution_begin(shell: Shell, args: Array[Variant] = [], io: Terminal = null):
	match len(args):
		1: if io: io.write("Calling %s..." % args[0])
		_: if io: io.write("Calling %s targets..." % len(args))


func _on_interactable_not_found(shell: Shell, item: Variant, io: Terminal = null):
	await sleep(shell)
	if io: io.error("Could not call %s." % item)


func _process_interactable(shell: Shell, target: Device2D, io: Terminal = null) -> bool:
	await sleep(shell)
	if target.interact():
		if io: io.success("Successfully called %s." % target.name)
	else:
		if io: io.error("%s call was rejected." % target.name)
	return true
