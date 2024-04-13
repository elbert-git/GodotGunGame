extends Label

#s tates
var score = 0

func add_score(addition:int):
	score += addition
	text = "%06d" % score

