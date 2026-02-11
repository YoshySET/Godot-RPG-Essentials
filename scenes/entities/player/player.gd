extends CharacterBody2D

signal game_over(victorious: bool)
signal update_hp_bar(hp_bar_value: int)

enum State {
	IDLE,
	RUN,
	ATTACK,
	DEAD
}

@export_category("Stats")
@export var speed: int = 400
@export var attack_damage: int = 60
@export var hitpoints: int = 150

var state: State = State.IDLE
var move_direction: Vector2 = Vector2.ZERO
var last_facing_dir: Vector2 = Vector2.RIGHT
var attack_speed: float
var hitpoins_max: int

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_playback: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]

func _ready() -> void:
	hitpoins_max = hitpoints
	animation_tree.set_active(true)
	calculate_stats()
	

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		attack()

func _physics_process(_delta: float) -> void:
	if not state == State.ATTACK:
		movement_loop()
	
func calculate_stats() -> void:
	attack_speed = Equations.calculate_attack_speed()
	var time_factor: float = Equations.BASE_ATTACK_SPEED / attack_speed
	animation_tree.set("parameters/attack/TimeScale/scale", time_factor)
	print("my new attack speed: %s" % [attack_speed])
	
	
func movement_loop() -> void:
	move_direction.x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	move_direction.y = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))

	if move_direction != Vector2.ZERO:
		last_facing_dir = move_direction.normalized()

	var motion := move_direction.normalized() * speed
	set_velocity(motion)
	move_and_slide()
	
	if state == State.IDLE or State.RUN:
		if move_direction.x < 0:
			$Sprite2D.flip_h = true
		elif move_direction.x > 0:
			$Sprite2D.flip_h = false
	
	if motion != Vector2.ZERO and state == State.IDLE:
		state = State.RUN
		update_animation()
	if motion == Vector2.ZERO and state == State.RUN:
		state = State.IDLE
		update_animation()
		
		
func update_animation():
	match state:
		State.IDLE:
			animation_playback.travel("idle")
		State.RUN:
			animation_playback.travel("run")
		State.ATTACK:
			animation_playback.travel("attack")
			
			
func attack():
	if state == State.ATTACK:
		return
	state = State.ATTACK
	
	var attack_dir := move_direction.normalized() if move_direction != Vector2.ZERO else last_facing_dir
	if attack_dir == Vector2.ZERO:
		attack_dir = Vector2.RIGHT
	$Sprite2D.flip_h = attack_dir.x < 0 and abs(attack_dir.x) >= abs(attack_dir.y)
	animation_tree.set("parameters/attack/BlendSpace2D/blend_position", attack_dir)
	update_animation()
	
	await get_tree().create_timer(attack_speed).timeout
	state = State.IDLE


func take_damage(damage_taken: int) -> void:
	hitpoints -= damage_taken
	@warning_ignore("integer_division")
	update_hp_bar.emit((hitpoints * 100) / hitpoins_max)
	if hitpoints <= 0:
		death()
		
		
func death() -> void:
	game_over.emit(false)


func _on_hit_box_area_entered(area: Area2D) -> void:
	area.owner.take_damage(attack_damage)
	
	
