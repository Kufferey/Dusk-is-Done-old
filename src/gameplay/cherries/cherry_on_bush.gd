extends Node3D
class_name CherryBush

signal collectCherry

@export_category("Cherry Options")
@export var Type:String
@export var Model:int
@export var isGood:bool
@export var isEatable:bool

func _ready() -> void:
	match Type:
		'normal':
			isGood = true
			isEatable = true
			var randomModel:int = randi_range(0, 1)
			match randomModel:
				0:
					$Models/cherry1.show()
					$Models/cherry2.hide()
					$Models/cherrySpoiled.hide()
					$Models/cherryWithDon2005.hide()
				1:
					$Models/cherry1.hide()
					$Models/cherry2.show()
					$Models/cherrySpoiled.hide()
					$Models/cherryWithDon2005.hide()
			
		'spoiled':
			isGood = false
			isEatable = false
			$Models/cherry1.hide()
			$Models/cherry2.hide()
			$Models/cherrySpoiled.show()
			$Models/cherryWithDon2005.hide()
			
		'donStory':
			isGood = false
			isEatable = false
			$Models/cherry1.hide()
			$Models/cherry2.hide()
			$Models/cherryWithDon2005.show()
		_:
			Type = 'normal'
	#match Model:
		#0:
			#pass
		#1:
			#pass
		#2:
			#pass
		#3:
			#pass
		#4:
			#pass
		#_:
			#pass

func _on_collect_cherry() -> void:
	queue_free()
	print("Cherry deleted!")
