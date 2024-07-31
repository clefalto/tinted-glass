extends Sprite2D

func _process(delta: float):
    var mouse_angle = (get_global_mouse_position() - global_position).normalized().angle()
    if mouse_angle < 0:
        mouse_angle += TAU
    # print(deg_to_rad(mouse_angle))
    var chunked_angle = floor(mouse_angle / TAU * 8)
    # print(chunked_angle)

    frame = chunked_angle + 1