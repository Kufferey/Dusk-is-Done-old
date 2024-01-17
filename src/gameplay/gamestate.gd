extends Node3D

# Cherry
var cherriesContainer:Node3D

func _create_cherry_on_bush(typeOfCherry:String, positionObject:Vector3, rotationObject:Vector3, amount:int) -> void:
	if amount >= 5:
		amount = 5
	
	for i in amount:
		var cherryOnBushInstance:Node3D = load("res://scenes/prefab/objects/cherry_on_bush.tscn").instantiate()
		cherryOnBushInstance.Type = typeOfCherry
		cherryOnBushInstance.position = positionObject
		cherryOnBushInstance.rotation = rotationObject
		
		cherriesContainer.add_child(cherryOnBushInstance)
		
	print(amount, " ", typeOfCherry, " Cherry(s) Created. ", " AT POSITION: ", positionObject, " ROTATION OF: ", rotationObject)

func _remove_all_cherries() -> void:
	var totalCount:int = cherriesContainer.get_child_count(true)
	var totalObjects:Array[Node] = cherriesContainer.get_children(true)
	
	if totalCount <= 0 || totalObjects == []:
		print("Could not remove objects. None to remove.")
		return
	elif totalCount != 0 || totalObjects != null:
		for cherries in totalObjects:
			cherries.queue_free()
			print(cherries, " Cherry Deleted.")
	
	print(totalCount, " Objects Deleted.")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# start
	cherriesContainer = $cherries
	_create_cherry_on_bush('normal', Vector3(0,0,0), Vector3(0,0,0), 1)
	await get_tree().create_timer(2).timeout
	_create_cherry_on_bush('donStory', Vector3(0.2,0,0), Vector3(3,5,2), 1)
	await get_tree().create_timer(2).timeout
	_create_cherry_on_bush('normal', Vector3(0.1,0,0.1), Vector3(0,0,0), 1)
	await get_tree().create_timer(2).timeout
	_create_cherry_on_bush('spoiled', Vector3(0,0.0,0.2), Vector3(0,1,0), 2)
	await get_tree().create_timer(4).timeout
	_remove_all_cherries()
	await get_tree().create_timer(4).timeout
	_remove_all_cherries()
