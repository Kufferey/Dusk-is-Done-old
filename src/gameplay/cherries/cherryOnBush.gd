class_name CherryOnBush extends InteractableObject

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
					$Model/cherry1.show()
					$Model/cherry2.hide()
					$Model/cherrySpoiled.hide()
					$Model/cherryWithDon2005.hide()
				1:
					$Model/cherry1.hide()
					$Model/cherry2.show()
					$Model/cherrySpoiled.hide()
					$Model/cherryWithDon2005.hide()
			
		'spoiled':
			isGood = false
			isEatable = false
			$Model/cherry1.hide()
			$Model/cherry2.hide()
			$Model/cherrySpoiled.show()
			$Model/cherryWithDon2005.hide()
			
		'donStory':
			isGood = false
			isEatable = false
			$Model/cherry1.hide()
			$Model/cherry2.hide()
			$Model/cherryWithDon2005.show()
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
