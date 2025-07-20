extends CenterContainer

func on_starting():
	$ColorRect.color = Color(1,1,0)

func on_started():
	$ColorRect.color = Color(0,1,0)
	
func on_closed():
	$ColorRect.color = Color(1,0,0)
