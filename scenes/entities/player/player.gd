extends CharacterBody2D


@export_category("Stats")
@export var speed := 400

var move_direction := Vector2.ZERO


func _physics_process(delta: float) -> void:
	movement_loop()
	

func movement_loop() -> void:
	move_direction.x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	move_direction.y = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
	var motion := move_direction.normalized() * speed
	set_velocity(motion)
	move_and_slide()
