extends Label

func _process(delta):
	var game_time: Game.HumanTime = Game.game_time
	
	if game_time == null: return
	text = str(game_time.hours) if game_time.hours >= 10 else "0"+str(game_time.hours)
	text += ":"
	text += str(game_time.minutes) if game_time.minutes >= 10 else "0"+str(game_time.minutes)
	
	var day = game_time.day + 1
	text += " | "+str(day)
	if day > 3:
		text += tr("th")
	elif day == 2:
		text += tr("nd")
	elif day == 1:
		text += tr("st")
	
	text += " "+tr("day")+" "+tr("of")+" "
	match game_time.season:
		0:
			text += tr("Spring")
		1:
			text += tr("Summer")
		2:
			text += tr("Autumn")
		3:
			text += tr("Winter")
	text += " "+str(game_time.year+3000)
