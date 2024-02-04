class_name DaySelectSlot extends Node2D

@export
var DayName:String
@export
var DayEvents:String
@export
var DayDescription:String
@export
var Icon:int

@onready var day_name:Label = $Control/DayName
@onready var day_events:Label = $Control/DayEvents

func _ready() -> void:
	day_name.text = (
		"DAY: " + DayName
	)
	day_events.text = (
		"EVENTS: " + DayEvents
	)
