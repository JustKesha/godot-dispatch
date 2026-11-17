@icon("uid://5651e0e7xytr")
class_name Simulation2D
extends Node2D


@onready var camera: Camera2D = %Camera
@onready var devices: Node2D = %Devices


func find_device(target_name: String) -> Device2D:
	return devices.find_child(target_name)
