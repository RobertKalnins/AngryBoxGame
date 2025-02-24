extends RigidBody3D

const SPEED = 55.0
const JUMP_VELOCITY = 14.5
const KICK_FORCE = 5.0  # Strength of the kick
const SPIN_FORCE = 20.0  # Strength of the spin

var GRAVITY: float  # Must be initialized at runtime
var is_grounded = false

func _ready() -> void:
	GRAVITY = ProjectSettings.get_setting("physics/3d/default_gravity")

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	is_grounded = false
	for contact in state.get_contact_count():
		if state.get_contact_local_normal(contact).y > 0.5:
			is_grounded = true
			break

	# Apply gravity manually
	if not is_grounded:
		apply_central_force(Vector3(0, -GRAVITY * mass, 0))

	# Handle jump
	if Input.is_action_just_pressed("ui_accept") and is_grounded:
		apply_impulse(Vector3(0, JUMP_VELOCITY * mass, 0))

	# Handle movement
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction != Vector3.ZERO:
		apply_central_force(direction * SPEED * mass)

	# Handle random kick with spinning
	if Input.is_action_just_pressed("ui_select"):  # Spacebar or assigned button
		kick()

func kick() -> void:
	# Generate a random direction for the kick (X, Y, Z)
	var random_direction = Vector3(
		randf_range(-1.0, 1.0),  # Random X direction
		randf_range(0.5, 1.5),   # Slight upward Y force
		randf_range(-1.0, 1.0)   # Random Z direction
	).normalized()

	# Apply the linear impulse for the kick
	apply_impulse(random_direction * KICK_FORCE * mass)

	# Add a random spin on the X, Y, and Z axes for rotation
	var random_spin = Vector3(
		randf_range(-1.0, 1.0),  # Spin around X axis
		randf_range(-1.0, 1.0),  # Spin around Y axis
		randf_range(-1.0, 1.0)   # Spin around Z axis
	).normalized()

	# Apply angular impulse (spinning)
	apply_torque(random_spin * SPIN_FORCE * mass)
