import("Actor.lua")

Dummy = Actor:subclass
{
	name = "Dummy";

	defaultproperties = {
		bitmap = nil,-- m_get_bitmap("zaklamp.bmp"),
	};
}