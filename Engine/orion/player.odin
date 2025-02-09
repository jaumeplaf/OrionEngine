package orion

import "core:fmt"

// Define PlayerState enum
PlayerState :: enum {
	Idle,
	MovingForward,
	MovingBackward,
	MovingLeft,
	MovingRight,
	Sprinting,
	Jumping,
	Crouching,
}