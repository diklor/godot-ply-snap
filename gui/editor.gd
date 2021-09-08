tool
extends Spatial

const SelectionMode = preload("../utils/selection_mode.gd")

var edited_node = null setget set_node
func set_node(n):
	if n == edited_node:
		return
	if edited_node:
		edited_node.ply_mesh.disconnect("mesh_updated", self, "_handle_mesh_updated")
	edited_node = n
	if edited_node:
		edited_node.ply_mesh.connect("mesh_updated", self, "_handle_mesh_updated")
	render()

var is_visible = true
var plugin = null

var mode = SelectionMode.MESH setget set_mode
func set_mode(m):
	if mode == m:
		return
	mode = m
	render()

const FaceScene = preload("./face.tscn")
const EdgeScene = preload("./edge.tscn")
const VertexScene = preload("./vertex.tscn")

func clear_children():
	for n in get_children():
		n.queue_free()

func _handle_mesh_updated():
	#TODO: handle deletions when that's added
	match mode:
		SelectionMode.EDGE:
			for idx in range(get_child_count()-1, edited_node.ply_mesh.edge_count()-1, -1):
				get_child(idx).queue_free()
			for idx in range(get_child_count(), edited_node.ply_mesh.edge_count()):
				instance_edge(idx)
		SelectionMode.FACE:
			for idx in range(get_child_count()-1, edited_node.ply_mesh.edge_count()-1, -1):
				get_child(idx).queue_free()
			for idx in range(get_child_count(), edited_node.ply_mesh.face_count()):
				instance_face(idx)

func instance_face(idx):
	var sc = FaceScene.instance()
	sc.name = "face_%s" % [idx]
	sc.face_idx = idx
	sc.ply_mesh = edited_node.ply_mesh
	sc.plugin = plugin
	add_child(sc)

func render():
	match mode:
		SelectionMode.MESH:
			clear_children()
		SelectionMode.FACE:
			render_faces()
		SelectionMode.EDGE:
			render_edges()
		SelectionMode.VERTEX:
			render_vertices()

func render_faces():
	clear_children()
	if not edited_node:
		return 
	for idx in range(edited_node.ply_mesh.face_count()):
		instance_face(idx)

func instance_edge(idx):
	var sc = EdgeScene.instance()
	sc.name = "edge_%s" % [idx]
	sc.edge_idx = idx
	sc.ply_mesh = edited_node.ply_mesh
	sc.plugin = plugin
	add_child(sc)


func render_edges():
	clear_children()
	if not edited_node:
		return
	for idx in range(edited_node.ply_mesh.edge_count()):
		instance_edge(idx)

func render_vertices():
	clear_children()
	if not edited_node:
		return
	for idx in range(edited_node.ply_mesh.vertex_count()):
		var v = edited_node.ply_mesh.vertexes[idx]
		var sc = VertexScene.instance()
		sc.name = "vertex_%s" % [idx]
		sc.vertex_idx = idx
		sc.ply_mesh = edited_node.ply_mesh
		sc.transform.origin = v
		sc.plugin = plugin
		add_child(sc)

func _process(_delta):
	if not is_visible:
		hide()
		return
	if not edited_node:
		return
	transform = edited_node.global_transform
	show()
	