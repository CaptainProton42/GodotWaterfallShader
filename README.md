# Godot Waterfall Shader

![](waterfall.gif)

These are Godot project files for a simple waterfall shader that allows interaction with meshes. It works by reading position information from the depth buffer with a separate camera and discarding all fragments below objects.

The (commented) waterfall shader is located at [assets/shader/waterfall.shader](assets/shader/waterfall.shader).

The shader used to retrieve position information is located at [assets/shader/world_position_from_camera.shader](assets/shader/world_position_from_camera.shader). This is largely the same technique as described in the Godot documentation: [Advanced post-processing](https://docs.godotengine.org/en/3.2/tutorials/shading/advanced_postprocessing.html)

All other shader files are located at [assets/shader/](assets/shader/).

You can also play around with the different shader parameters in the editor to get a feel for how the shader works.

## Caveats

The waterfall is aligned inside a unit (1m x 1m x 1m) cube at the origin for simplicity. Repositioning and resizing might not work without some adjustments to the shader code.

In order to prevent artifacts, certain objects need to visible only or invisible to the depth buffer viewport's camera. I used the following layers:

* **Layer 2**: Meshes that can interact with the waterfall. The viewport's camera will will cull all meshes that are not on this layer.
* **Layer 20**: The main camera will not render this layer. Used for the quad mesh inside the depth buffer viewport since it should only be visible to the viewport's camera.

## More

This shader was inspired by these tweets which use similar techniques:

https://twitter.com/hippowombat/status/1188785787912896512

https://twitter.com/Cyanilux/status/1190253359703482369
