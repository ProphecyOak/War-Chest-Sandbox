extends ScrollContainer
class_name Log

func _get_log_time():
	var datetime_dict = Time.get_datetime_dict_from_system()
	return "[%s-%s-%s %s:%s:%s]" % [
		datetime_dict.month,
		datetime_dict.day,
		datetime_dict.year,
		datetime_dict.hour,
		datetime_dict.minute,
		datetime_dict.second
		]

func add_to_log(text: String):
	$PanelContainer/Label.text += "%s - %s\n" % [_get_log_time(), text]

func wipe_log():
	$PanelContainer/Label.text = ""
