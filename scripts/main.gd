# Flexible Resize
#
# This mod adds x and y scale bars to the select tool so that they may be
# scaled independently.


var script_class = "tool"


var select_tool = null
var select_panel = null
var sliders_off = true

var object_tool = null
var object_panel = null

var object_x_scale = null
var object_y_scale = null

var scale_section = null
var scale_children = null

var select_x_scale = null
var select_y_scale = null

var last_size = 0


func get_icon(name: String) -> String:
  return Global.Root + "icons/" + name + ".png"


func get_selected_objects():
  # Returns all currently selected objects.
  var objects = []
  # Selectables will crash if the user has shift-clicked and selected the same
  # object twice. Use RawSelectables instead and skip duplicates.
  for raw in select_tool.RawSelectables:
    if raw.Type != 4 or raw.Thing in objects:
      continue
    objects.append(raw.Thing)
  return objects


func update(delta):
  # Add the UI when objects are selected, and remove it when they aren't.
  var selected = get_selected_objects()
  if len(selected) > 0 and sliders_off:
    add_scales()
    sliders_off = false
    last_size = len(selected)
  elif len(selected) == 0 and not sliders_off:
    remove_scales()
    sliders_off = true
    last_size = 0
  elif not sliders_off and len(selected) == last_size and len(selected) > 0:
    # Update the UI to match the current selected scale.
    select_x_scale.value = selected[0].global_scale.x
    select_y_scale.value = selected[0].global_scale.y

  if object_tool.Preview:
    object_tool.Preview.global_scale = Vector2(
        object_x_scale.value, object_y_scale.value)


func add_scales():
  # Add the scale UI to the select tool panel.
  for child in scale_children:
    select_panel.Align.add_child(child)
    select_panel.Align.move_child(child, 13)


func remove_scales():
  # Remove the scale UI from the select tool panel.
  for child in scale_children:
    select_panel.Align.remove_child(child)

func get_last_added(tool_panel):
  # Get the last item added to the panel, since it isn't always returned.
  return tool_panel.Align.get_children()[len(tool_panel.Align.get_children()) - 1]


func on_x_value_changed(value):
  # Return if this is just a manual move (no selection box).
  if select_tool.manualAction:
    return

  # Scale each selected object to the new x value.
  for object in get_selected_objects():
    object.global_scale.x = value
    select_tool.EnableTransformBox(true)


func on_y_value_changed(value):
  # Return if this is just a manual move (no selection box).
  if select_tool.manualAction:
    return

  # Scale each selected object to the new y value.
  for object in get_selected_objects():
    object.global_scale.y = value
    select_tool.EnableTransformBox(true)


func on_object_scale_changed(value):
  # Set the x and y scale values to the vanilla scale if the user has changed
  # it manually.
  object_x_scale.value = value
  object_y_scale.value = value


func init_select_scales():
  scale_children = []
  # Add the x scale and hook connect it to the scaling function.
  select_panel.CreateLabel("X Scale")
  scale_children.append(get_last_added(select_panel))
  select_x_scale = select_panel.CreateSlider("XSliderID", 1, 0.1, 25, 0.01, true)
  select_x_scale.connect("value_changed", self, "on_x_value_changed")
  scale_children.append(get_last_added(select_panel))

  # Add the y scale and hook connect it to the scaling function.
  select_panel.CreateLabel("Y Scale")
  scale_children.append(get_last_added(select_panel))
  select_y_scale = select_panel.CreateSlider("YSliderID", 1, 0.1, 25, 0.01, true)
  select_y_scale.connect("value_changed", self, "on_y_value_changed")
  scale_children.append(get_last_added(select_panel))

  select_panel.CreateSeparator()
  scale_children.append(get_last_added(select_panel))

  # Invert the children so that they will be re-added in the proper order.
  scale_children.invert()
  remove_scales()

func get_object_scale_slider():
  # Get the scale slider using a hard-coded children index.

  # The scale slider is currently the first child of an HBoxContainer located
  # at index 7. Other mods or changes to Dungeondraft may break this.
  return object_panel.Align.get_children()[7].get_children()[0]

func init_object_scales():
  # Add the x and y scales to the object tool panel and register the signal.
  object_panel.CreateLabel("X Scale")
  object_panel.Align.move_child(get_last_added(object_panel), 8)
  object_x_scale = object_panel.CreateSlider("XSliderID", 1, 0.1, 25, 0.01, true)
  object_panel.Align.move_child(get_last_added(object_panel), 9)

  object_panel.CreateLabel("Y Scale")
  object_panel.Align.move_child(get_last_added(object_panel), 10)
  object_y_scale = object_panel.CreateSlider("YSliderID", 1, 0.1, 25, 0.01, true)
  object_panel.Align.move_child(get_last_added(object_panel), 11)

  var object_scale = get_object_scale_slider()
  object_scale.connect("value_changed", self, "on_object_scale_changed")


func start():
  select_tool = Global.Editor.Tools["SelectTool"]
  select_panel = Global.Editor.Toolset.GetToolPanel("SelectTool")
  init_select_scales()

  object_tool = Global.Editor.Tools["ObjectTool"]
  object_panel = Global.Editor.Toolset.GetToolPanel("ObjectTool")
  init_object_scales()

