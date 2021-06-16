extends Node


var targets = []


func register_target(target):
	targets.append(target)


func send_to_targets(message):
	for target in targets:
		target.log_message(message)


func info(message):
	send_to_targets("[info]: %s" % message)


func warning(message):
	send_to_targets("[warning]: %s" % message)


func error(message):
	send_to_targets("[error]: %s" % message)

