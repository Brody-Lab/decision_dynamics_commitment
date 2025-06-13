
function out = FigPos(module)

	fig = findobj('type','figure','tag',module)
	out = get(fig,'pos');