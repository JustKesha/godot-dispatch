class_name ScreenLight
extends AreaLight3D


@export_group ("Source", "source")
@export var source_viewport: SubViewport
@export var source_update_interval: float = 0.1
@export_group ("Response", "response")
@export var response_energy_multiplier: float = 30
@export var response_smoothing: float = 8.0


var _timer: float
var _target_color: Color
var _target_energy: float
var _ready_to_read: bool = false


func _ready():
	if source_viewport == null:
		push_error("ScreenLight: Viewport is null, can't proceed")
		return
	await RenderingServer.frame_post_draw
	var avg := _get_avarege_color()
	_get_target_color_and_energy(avg)
	light_color = _target_color
	light_energy = _target_energy
	_ready_to_read = true


func _get_avarege_color() -> Color:
	var img := source_viewport.get_texture().get_image()

	while img.get_width() > 1 or img.get_height() > 1:
		var new_w := maxi(1, img.get_width() / 2)
		var new_h := maxi(1, img.get_height() / 2)
		img.resize(new_w, new_h, Image.INTERPOLATE_BILINEAR)

	return img.get_pixel(0, 0)


func _get_target_color_and_energy(avg: Color):
	var peak := maxf(avg.r, maxf(avg.g, avg.b))
	if peak < 0.001:
		_target_energy = 0.0
	else:
		_target_color = Color(avg.r / peak, avg.g / peak, avg.b / peak)
		_target_energy = avg.get_luminance() * response_energy_multiplier


func _process(delta):
	if not _ready_to_read:
		return
	_timer += delta
	if _timer >= source_update_interval:
		_timer -= source_update_interval
		var avg := _get_avarege_color()
		_get_target_color_and_energy(avg)
	var t := 1.0 - exp(-response_smoothing * delta)
	light_color = light_color.lerp(_target_color, t)
	light_energy = lerpf(light_energy, _target_energy, t)
