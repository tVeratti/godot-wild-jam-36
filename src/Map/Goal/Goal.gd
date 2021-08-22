extends Area

onready var _score_audio = $ScoreSound

func _on_Goal_body_entered(body):
	if body.has_method("score"):
		body.score()
		_score_audio.play()
		Signals.emit_signal("debris_scored", body)
