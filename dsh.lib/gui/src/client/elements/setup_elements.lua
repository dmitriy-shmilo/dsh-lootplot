return function(gui)
	gui.elements = {}
	require("client.elements.DescriptionBox")(gui)
	require("client.elements.ImageButton")(gui)
	require("client.elements.DisclosureButton")(gui)
	require("client.elements.Toggle")(gui)
	require("client.elements.PagedUniformList")(gui)
end