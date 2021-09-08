tool
extends Spatial

const SelectionMode = preload("../utils/selection_mode.gd")

var _plugin = null

func _init(plugin):
    _plugin = plugin

var previous_xform = Transform.IDENTITY
func _ready():
    previous_xform = transform

export var selected_idxs = []

func _set_selected_idxs():
    self.selected_idxs = []
    for n in _plugin.selector.selection:
        match _plugin.selector.mode:
            SelectionMode.FACE:
                self.selected_idxs.push_back(n.face_idx)
            SelectionMode.EDGE:
                self.selected_idxs.push_back(n.edge_idx)
            SelectionMode.VERTEX:
                self.selected_idxs.push_back(n.vertex_idx)

func _process(_delta):
    if not _plugin:
        return
    _set_selected_idxs()
    match _plugin.selector.mode:
        SelectionMode.FACE:
            var f_idxs = []
            for n in _plugin.selector.selection:
                f_idxs.push_back(n.face_idx)
            _plugin.selector.editing.ply_mesh.transform_faces(f_idxs, previous_xform, transform)
        SelectionMode.EDGE:
            var e_idxs = []
            for n in _plugin.selector.selection:
                e_idxs.push_back(n.edge_idx)
            _plugin.selector.editing.ply_mesh.transform_edges(e_idxs, previous_xform, transform)
        SelectionMode.VERTEX:
            var v_idxs = []
            for n in _plugin.selector.selection:
                v_idxs.push_back(n.vertex_idx)
            _plugin.selector.editing.ply_mesh.transform_vertexes(v_idxs, previous_xform, transform)
    previous_xform = transform