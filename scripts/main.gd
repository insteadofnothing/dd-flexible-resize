# Flexible Resize
#
# This mod adds x and y scale bars to the select tool so that they may be
# scaled independently.


var script_class = "tool"


var select_tool = null
var tool_panel = null
var sliders_off = true


var scale_section = null
var scale_children = null

var x_scale = null
var y_scale = null

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
    x_scale.value = selected[0].global_scale.x
    y_scale.value = selected[0].global_scale.y


func add_scales():
  # Add the scale UI to the select tool panel.
  for child in scale_children:
    tool_panel.Align.add_child(child)
    tool_panel.Align.move_child(child, 13)


func remove_scales():
  # Remove the scale UI from the select tool panel.
  for child in scale_children:
    tool_panel.Align.remove_child(child)

func get_last_added():
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


func start():
  select_tool = Global.Editor.Tools["SelectTool"]
  var icon = get_icon("cursor")
  tool_panel = Global.Editor.Toolset.GetToolPanel("SelectTool")

  scale_children = []
  # Add the x scale and hook connect it to the scaling function.
  tool_panel.CreateLabel("X Scale")
  scale_children.append(get_last_added())
  x_scale = tool_panel.CreateSlider("XSliderID", 1, 0.1, 25, 0.01, true)
  x_scale.connect("value_changed", self, "on_x_value_changed")
  scale_children.append(get_last_added())

  # Add the y scale and hook connect it to the scaling function.
  tool_panel.CreateLabel("Y Scale")
  scale_children.append(get_last_added())
  y_scale = tool_panel.CreateSlider("YSliderID", 1, 0.1, 25, 0.01, true)
  y_scale.connect("value_changed", self, "on_y_value_changed")
  scale_children.append(get_last_added())

  tool_panel.CreateSeparator()
  scale_children.append(get_last_added())

  # Invert the children so that they will be re-added in the proper order.
  scale_children.invert()

  remove_scales()

