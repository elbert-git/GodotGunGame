extends Label

#s tates
var score = 0

func _ready():
	var enemy_pool = get_node("/root/Root").get_important_node("enemy_pool")
	enemy_pool.enemy_has_died.connect(on_enemy_has_died)

func add_score(addition:int):
	score += addition
	text = "%06d" % score

func on_enemy_has_died():
	add_score(20)
