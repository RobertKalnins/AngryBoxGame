extends RigidBody3D

@export var target: Node3D  # Assign the target in the Inspector
const ROTATION_SPEED = 3.0  # Speed toward the target
const SMOOTHING_FACTOR = 0.5  # Smoother response
const BRAKE_FORCE = 2.0  # Slows down rotation near target
const UPRIGHT_FORCE_BASE = 2.0  # Max upright correction
const SPIN_THRESHOLD = 0.5  # Below this, full correction applies

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if not target:
		return

	# Get direction to target
	var to_target = (target.global_transform.origin - global_transform.origin).normalized()

	# Get current forward direction
	var forward = -global_transform.basis.z.normalized()

	# Compute rotation axis using cross product
	var rotation_axis = forward.cross(to_target)

	# Compute angle difference
	var alignment = forward.dot(to_target)
	var angle = acos(alignment)

	# Scale torque based on angle
	var torque_strength = angle * SMOOTHING_FACTOR

	# Apply torque toward the target
	apply_torque(rotation_axis * torque_strength * ROTATION_SPEED)

	# === Braking Force ===
	if angle < 0.1:
		angular_velocity *= 1.0 - (BRAKE_FORCE * state.step)  # Smooth stop

	# === Adaptive Upright Correction ===
	var current_up = global_transform.basis.y.normalized()
	var upright_axis = current_up.cross(Vector3.UP)
	var upright_angle = acos(current_up.dot(Vector3.UP))

	# Get the current spin speed (angular velocity length)
	var spin_speed = angular_velocity.length()

	# Scale upright force inversely to spin speed (fast spin = weak correction)
	var upright_force = UPRIGHT_FORCE_BASE * clamp(1.0 - (spin_speed / SPIN_THRESHOLD), 0.1, 1.0)

	if upright_angle > 0.01:
		apply_torque(upright_axis * upright_angle * upright_force)
