extends Node3D

@export var water_drop_scene: PackedScene
@export var basket_scene: PackedScene
@export var sugar_enemy_scene: PackedScene
@onready var gridmap = $GridMap
@onready var buttonsContainer = $CanvasLayer/HBoxContainer
@onready var enemySpawnTimer = $EnemySpawnTimer

var selected_plant_scene: PackedScene = null
var selected_plant_cost: int = 0
var active_button: Button = null

func _ready():
	for child in buttonsContainer.get_children():
		if child is Button:
			child.card_selected.connect(_on_card_selected)
			child.card_deselected.connect(_on_card_deselected)
			
	spawn_baskets()
	enemySpawnTimer.timeout.connect(_on_enemy_spawn_timer_timeout)

func _on_enemy_spawn_timer_timeout():
	spawn_enemy()

func spawn_enemy():
	if sugar_enemy_scene:
		var new_enemy = sugar_enemy_scene.instantiate()
		add_child(new_enemy)
		
		var random_row = randi_range(0, 5)
		
		var spawn_col = 10 
		
		var grid_pos = Vector3i(spawn_col, 0, random_row)
		var world_pos = gridmap.map_to_local(grid_pos)
		
		new_enemy.position = world_pos
		
		print("Enemy spawned at Row: ", random_row)
	
func _on_card_selected(plant_scene, cost, btn_ref):
	if active_button != null and active_button != btn_ref:
		active_button.force_deselect()
	
	active_button = btn_ref
	selected_plant_scene = plant_scene
	selected_plant_cost = cost
	print("Selected: ", plant_scene)

func _on_card_deselected():
	selected_plant_scene = null
	selected_plant_cost = 0
	active_button = null
	print("Deselected. Ready to select new unit.")

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		
		var camera = get_viewport().get_camera_3d()
		var mouse_pos = get_viewport().get_mouse_position()
		var from = camera.project_ray_origin(mouse_pos)
		var to = from + camera.project_ray_normal(mouse_pos) * 1000
		
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(from, to)
		
		query.collide_with_areas = true 
		query.collide_with_bodies = true
		
		var result = space_state.intersect_ray(query)
		
		if result:
			var hit_object = result.collider
			
			var tile_coords = gridmap.local_to_map(result.position)
			if tile_coords.x < 1:
				print("Cannot plant in the Basket Zone!")
				return
			
			if hit_object.is_in_group("plant"):
				print("Cannot plant here: Space occupied by ", hit_object.name)
				return
			
			elif hit_object.is_in_group("terrain"):
				# Check if we actually have a card selected
				if selected_plant_scene == null:
					return
				
				if GameData.water_balance < selected_plant_cost:
					print("Not enough Water!")
					return
				
				plant_unit(result.position)
			
			else:
				print("Clicked invalid target: ", hit_object.name)

func plant_unit(hit_position):
	var tile_coords = gridmap.local_to_map(hit_position)
	var snap_pos = gridmap.map_to_local(tile_coords)
	
	for child in get_children():
		if child.is_in_group("plant"):
			if child.position.distance_to(snap_pos) < 0.1:
				print("Grid cell already occupied!")
				return

	GameData.spend_water(selected_plant_cost)
	
	var new_plant = selected_plant_scene.instantiate()
	add_child(new_plant)
	new_plant.position = snap_pos
	
	if active_button:
		active_button.force_deselect()
		
	selected_plant_scene = null
	active_button = null

func _on_water_timer_timeout():
	spawn_sky_drop()

func spawn_sky_drop():
	var new_drop = water_drop_scene.instantiate()
	add_child(new_drop)
	
	var rand_x = randi_range(0, 10)
	var rand_z = randi_range(0, 5)
	
	var tile_pos = gridmap.map_to_local(Vector3i(rand_x, 0, rand_z))
	
	tile_pos.y = 10.0 
	
	new_drop.position = tile_pos

func spawn_baskets():
	for row in range(6): 
		var new_basket = basket_scene.instantiate()
		add_child(new_basket)
		
		var grid_coord = Vector3i(0, 0, row) 
		new_basket.position = gridmap.map_to_local(grid_coord)
		
		new_basket.basket_destroyed.connect(_on_game_over)

func _on_game_over():
	print("TRIGGER GAME OVER SCREEN")
	get_tree().paused = true
