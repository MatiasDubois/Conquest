extends Node2D

@onready var mapImage = $MapProvinces

func _ready():
	load_province()

func _process(delta):
	pass

# Load provinces from provinces.txt
func load_province():
	var image = mapImage.get_texture().get_image()
	var pixel_color_dict = get_pixel_color_dict(image)
	var province_dict = import_file("res://Map/provinces.txt")
	
	if province_dict != null:
		print(province_dict)
	
	for province_color in province_dict:
		if province_dict.has(province_color):  # Check if the key exists
			var province = load ("res://Scenes/Provinces_Area.tscn").instantiate()
			province.province_name = province_dict[province_color]
			province.set_name(province_color)
			get_node("Provinces").add_child(province)
			
			var polygons = get_polygons(image, province_color,pixel_color_dict)
			for polygon in polygons:
				var province_collision = CollisionPolygon2D.new()
				var province_polygon = Polygon2D.new()
				
				province_collision.polygon = polygon
				province_polygon.polygon = polygon
				
				province.add_child(province_collision)
				province.add_child(province_polygon)
		else:
			print("Warning: Key not found in province_dict: ", province_color)


func get_pixel_color_dict(image):
	var pixel_color_dict = {}
	for y in range(image.get_height()):
		for x in range(image.get_width()):
				var pixel_color = "#" + str(image.get_pixel(int(x), int(y)).to_html(false))
				if pixel_color not in pixel_color_dict:
					pixel_color_dict[pixel_color] = []
				pixel_color_dict[pixel_color].append(Vector2(x,y))
	return pixel_color_dict


# Generate a Polygons on the correct pixel
func get_polygons(image, province_color, pixel_color_dict):
	var targetImage = Image.create(image.get_size().x,image.get_size().y, false, Image.FORMAT_RGBA8)
	for value in pixel_color_dict[province_color]:
		targetImage.set_pixel(value.x, value.y, "#ffffff")
		
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(targetImage)
	var polygons = bitmap.opaque_to_polygons(Rect2(Vector2(0,0), bitmap.get_size()), 0.1)
	return polygons


#Import JSON files and converts to listsor dictionary
func import_file(filepath):
	var file = FileAccess.open(filepath, FileAccess.READ)
	if file != null:
		return JSON.parse_string(file.get_as_text().replace("_" , " "))
	else :
		print("Failed to Open file : ", filepath)
		return null
