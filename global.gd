extends Node



func _ready():
	pass # Replace with function body.

#return vector with x multiplied by vector.x
func VX(vector,x):
	vector.x *= x
	return vector

#return vector with y multiplied by vector.y
func VY(vector,y):
	vector.y *= y
	return vector
