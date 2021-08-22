extends Node


signal beam_activated()
signal beam_deactivated()

signal debris_attached(debris)
signal debris_detached(debris)

signal debris_removed(debris)
signal debris_collision(debris, collider)
signal debris_broken(debris, children)
signal debris_count_changed()
signal debris_scored(debris)

signal score_changed()
