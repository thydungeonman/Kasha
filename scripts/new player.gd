extends KinematicBody2D



class State:
	var firstframe = false
	
	#grab all possible inputs that might matter within the state and act on them
	func Logic():
		pass
	#check for conditions that might change the state and set the state to be changed
	#possible reset this states values
	func ConditionCheck():
		pass

class IdleState:
	extends State
	func Logic():
		#no logic other than regular physics and gravity
		pass
	
	func ConditionCheck():
		#is hit by enemy
		#presses direction
		#jumps
		#attack key is pressed
		pass

class WalkState:
	extends State
	func Logic():
		#in addition to regular physics we move the player
		pass
	
	func ConditionCheck():
		#is hit by enemy
		#direction key is not pressed
		#jump key is pressed/we walk off a ledge
		#attack key is pressed
		pass

class JumpState: # also a falling state
	extends State
	func Logic():
		#no logic other than regular physics and gravity
		pass
	
	func ConditionCheck():
		#is hit by enemy
		#we press the attack button
		#we land
	
	#it is possible to enter this state while dashing, some dash variable should be maintained
	
		pass

class JumpAttackState:
	extends State
	
	func Logic():
		# regular physics and gravity
		#on the first frame we spawn in the jump attack node
		pass
	
	func ConditionCheck():
		#is hit by enemy
		#presses direction
		#jumps
		pass

class AttackState:
	extends State
	func Logic():
		#regular physics and gravity
		pass
	
	func ConditionCheck():
		#is hit by enemy
		#player taps attack
		pass
		
class RapidAttackState:
	extends State
	func Logic():
		#regular physics and gravity
		#check to see if player is still tapping
		pass
	
	func ConditionCheck():
		#is hit by enemy
		#jump
		pass


class MovingAttackState:
	extends State
	func Logic():
		#regular physics and gravity
		#put down the attack node
		#check for direction change
		pass
	
	func ConditionCheck():
		#is hit by enemy
		#attack is held
		pass

class Dash1State:
	extends State
	func Logic():
		#regular physics and gravity
		#increase speed
		pass
	
	func ConditionCheck():
		#is hit by enemy
		#presses direction
		#jumps
		#attack is held
		pass

class Dash2State:
	extends State
	func Logic():
		#regular physics and gravity
		#increase speed
		pass
	
	func ConditionCheck():
		#is hit by enemy
		#presses direction
		#jumps
		#attack is held
		pass

class Dash3State:
	extends State
	func Logic():
		#regular physics and gravity
		#particles are emitted
		pass
	
	func ConditionCheck():
		#is hit by enemy - pretty unlikely
		#presses direction
		#jumps
		pass

class DashJumpAttackState:
	extends State
	func Logic():
		#regular physics and gravity
		#spawn in dash jump attack node
		pass
	
	func ConditionCheck():
		#is hit by enemy - probably not possible
		#land
		pass



#should be set at ready 
var currentstate = null

# Called when the node enters the scene tree for the first time.
func _ready():
	set_physics_process(true)
	pass # Replace with function body.


func _process(delta):
	pass


func _physics_process(delta):
	
	if(currentstate != null):
		currentstate.Logic()
		currentstate.ConditionsCheck()
	
	pass
