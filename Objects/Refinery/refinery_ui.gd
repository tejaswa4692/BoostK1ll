extends Control

var set_amount: int = 0:
	set(value):
		set_amount = value
		scraps_in_amount.text = str(set_amount)
var prepared: int = 0:
	set(value):
		prepared = value
		scraps_prepared_amount.text = str(prepared)
var prepared_estimate: int = 0:
	set(value):
		prepared_estimate = value
		expected_out_amount.text = str(prepared_estimate)

@onready var more: Button = $More
@onready var less: Button = $Less
@onready var take: Button = $Take

@onready var scraps_in_amount: Label = $ScrapsInAmount
@onready var expected_out_amount: Label = $expectedOutAmount
@onready var scraps_prepared_amount: Label = $ScrapsPreparedAmount
@onready var item_list: ItemList = $ItemList
@onready var cook_btn: Button = $Cook
@onready var timer_visualiser: HSlider = $TimerVisualiser
@onready var timer: Timer = $CookTimer
var initial_set_amount: int = 0


var selected_text: String

var typeofmat: Dictionary = {
	"Refined scrap": 1,
	"Copper": 1,
	"Iron" : 1,
}


func _ready() -> void:
	item_list.select(0)
	scraps_in_amount.text = str(set_amount)
	scraps_prepared_amount.text = str(prepared)
	expected_out_amount.text = str(prepared_estimate)

func add_more() -> void:
	if get_parent().player.scraps > set_amount:
		set_amount += 10
		handleestimate()

func add_less() -> void:
	if set_amount > 10:
		set_amount -= 10
	handleestimate()

func handleestimate() -> void:
	match selected_text:
		"Refined scrap":
			prepared_estimate = set_amount * 1
		"Copper":
			prepared_estimate = set_amount * 0.75
		"Iron":
			prepared_estimate = set_amount * 0.5

func returnratio():
	match selected_text:
		"Refined scrap":
			return 1
		"Copper":
			return 0.75
		"Iron":
			return 0.5

func _on_item_list_item_selected(index: int) -> void:
	cook_btn.disabled = false
	selected_text = item_list.get_item_text(index)
	handleestimate()

func _on_cook_pressed() -> void:
	initial_set_amount = set_amount
	for i in item_list.item_count:
		item_list.set_item_selectable(i, false)
		item_list.set_item_disabled(i, true)
	more.disabled = true
	less.disabled = true
	cook_btn.disabled = true
	timer.start(int(selected_text))


func _on_cook_timer_timeout() -> void:
	var scrapsnum: int = prepared_estimate
	if scrapsnum > 0:
		scrapsnum -= 1
		prepared += 1
		prepared_estimate = scrapsnum
		set_amount = scrapsnum / returnratio()
		print("added 1")
		timer.start()
	else:
		take.disabled = false
		timer.stop()


func _on_take_pressed() -> void:
	var player = get_parent().player
	match selected_text:
		"Refined scrap":
			player.refinedscraps += prepared
			player.scraps -= initial_set_amount
			prepared = 0
		"Copper":
			player.copper += prepared
			prepared = 0
			player.scraps -= initial_set_amount
		"Iron":
			player.iron += prepared
			prepared = 0
			player.scraps -= initial_set_amount
		
	for i in item_list.item_count:
		item_list.set_item_selectable(i, true)
		item_list.set_item_disabled(i, false)
	more.disabled = false
	less.disabled = false
	cook_btn.disabled = false
	take.disabled = true
