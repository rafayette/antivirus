@tool
class_name RichTextGradientEffect
extends Control



@onready var rtl: RichTextLabel = get_parent()
@export var texture: GradientTexture2D
@export var start_char: int = 0
@export var end_char: int = -1
var debug: bool = false ## Shows the outline rectangles for each individual glyph
var characters: Array[Rect2]
var paragraph = TextParagraph.new()



func _ready() -> void:
	# Sets the anchor mode to full rect (so it has the same dimensions as the RichTextLabel parent)
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT,Control.PRESET_MODE_MINSIZE)
	
	# Gets the text information from the RichTextLabel parent
	paragraph.add_string(rtl.text,rtl.get_theme_default_font(),rtl.get_theme_font_size("default"))
	paragraph.width = size.x



func _draw() -> void:
	# Get the primary text server
	var text_server = TextServerManager.get_primary_interface()
	var x = 0.0
	var y = 0.0
	var ascent = 0.0
	var descent = 0.0
	
	# for each line
	for i in paragraph.get_line_count():
		# reset x
		x = 0.0
		# get the ascent and descent of the line
		ascent = paragraph.get_line_ascent(i)
		descent = paragraph.get_line_descent(i)

		# get the rid of the line
		var line_rid = paragraph.get_line_rid(i)
		# get all the glyphs that compose the line
		var glyphs = text_server.shaped_text_get_glyphs(line_rid)

		# for each glyph
		for glyph in glyphs:
			# get the advance (how much the we need to move x)
			var advance = glyph.get("advance", 0)
			# get the offset, I'm not sure what this does but it may be needed
			var offset = glyph.get("offset", Vector2.ZERO)
			# draw a red rect surrounding the glyph
			var glyph_rect = Rect2(Vector2(x, y), Vector2(advance, ascent + descent))
			if debug:
				draw_rect(glyph_rect, Color.RED, false)
			characters.append(glyph_rect)
			# add the advance to x
			x += advance

		# update y with the ascent and descent of the line
		y += ascent + descent
	
	var new_rect = TextureRect.new()
	rtl.add_child(new_rect)
	var text_rect = get_text_rect(start_char,end_char)
	new_rect.position = text_rect.position
	new_rect.size = text_rect.size
	new_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	new_rect.texture = texture
	
	rtl.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW

func get_text_rect(start_char,end_char) -> Rect2:
	var top_left_corner = characters[start_char].position
	var bottom_right_corner = characters[end_char].position + characters[end_char].size
	var text_rect_size = bottom_right_corner - top_left_corner
	
	# Correcting size if end char is -1
	# Since -1 is the end of the string, you basically wouldn't use it unless
	# you want the whole textbox to have the gradient effect
	if end_char == -1:
		text_rect_size = size
		
	var text_rect = Rect2(top_left_corner,text_rect_size)
	return text_rect
