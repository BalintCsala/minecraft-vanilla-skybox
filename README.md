# Archived

From at least 1.21.9 onward it's no longer possible to make this pack work in the way it was designed, so until this changes, this template will remain archived.

In the meantime I updated the assets to at least not error out in 26.3.

In case you want to take on the challenge, here are the current issues that need to be solved:

1.) The current version was made with the assumption that celestials get their own textures, but now they're in an atlas and on top of that, the textures get padded (the number of padding pixels is based on the aniso setting). I made changes to accomodate most of these, but they might be broken in some cases.

2.) Most of the celestial objects are seemingly in model space now and use a model matrix, meaning it's impossible to determine what the global "up" direction is. This means the only way to get this effect working would be to once again pass everything to post shaders and draw the sky there. This has multiple drawbacks:
  - Stuff in the sky always renders in the back, so you have to punch holes through everything in the game to make sure the control pixels remain visible. This requires changing basically every shader and thus is very prone to break when the game updates.
  - Since neither the sky, nor the sun gets a proper world aligned model view matrix, you have to get that from something else and I'm not sure what would make sense here. I'd check if maybe the tars can help, but I wouldn't hold my breath. In general you need some object that is always rendered and you can either make do without it or you can replace it somehow.

# Minecraft vanilla skybox template pack

Only supports 1.21.5 and up (plus 25w10a and up for snapshots)!

An implementation of skyboxes in vanilla minecraft.

You're free to use the pack forever in return of a credit and link to this github repository on the distribution site. If these terms don't work for you, contact me on Discord (@balintcsala) or through GitHub.

![example](./images/example.png)

## Customization

All customization happens through the sun texture (`assets/minecraft/textures/environment/sun.png`).

Make sure you have a list of skybox textures in the [OptiFine format](https://optifine.readthedocs.io/custom_sky.html?h=skybox). You need to choose two timestamps for each of them: A starting and ending interpolation time. When the current time is between these two values, the respective skybox will slowly replace the previous one in the list (or the last one if it's the first) and will reach full opacity at the ending interpolation time.

The current time is based on the angle of the sun around the Z axis and is between 0 and 255 (inclusive) according the following diagram:

![angles](./images/angles.png)

For reference the default sun.png includes two skyboxes, a day skybox that starts at 64 (dawn) and reaches full opacity at 80, and a night skybox that starts at 176 and reaches full opacity at 192.

Order the skyboxes such that the start times are in increasing order. `sun.png` should be created based on the following steps:

1. Put the original sun texture in the top left corner.
1. For every skybox in your list:
    1. Right below the previous placed image goes a single row of pixels encoding the interpolation times for the next skybox. The red channels of each should contain the starting and ending interpolation times for the next skybox.
    1. Place the skybox below the previous row
1. After adding every skybox, crop your image to the minimum size, then add a border of 1 pixels around it, fill it with pixels containing the following RGBA color: (255, 0, 255, 123)
1. Overwrite the second and third pixels of image (so these should fall within the border of added previously), these should contain the width and height of the sun texture. If `width` and `height` are the width and height respectively:
    - For the second pixel in the row the red channel should contain `floor(width / 256)` where `floor(x)` means rounding down and the green channel should contain `width - floor(width / 256) * 256`, or in other words, the remainder when dividing by 256.
    - Same for the third pixel, except use `height` in the calculations.
    - Example: For the vanilla sun texture (which is 32x32) both pixels would contain the following RGB value: (0, 32, 0)

Check `assets/minecraft/textures/environment/celestial/sun.png` for a reference.

## Other customizations

### Solid moon

Some packs require the moon to be solid instead of behaving additively. For this you'll have to provide an alpha mask for the moon:

1. Take one sprite/frame from your moon_phases texture (`assets/minecraft/textures/environment/moon_phases.png`) and scale it up or down to the height of your original `sun.png` texture (before you added the skyboxes).
2. If the background of the texture isn't transparent, remove it from the image (with Photoshop or Gimp). Make sure only the solid parts are kept, stuff like the glow from the moon shouldn't be.
3. Place the edited image right next to the original sun texture in the edited `sun.png`.

The example `sun.png` texture includes this feature if you need some reference.

The solution doesn't support changing moon shapes and might be at a lower resolution, than the original texture (though you can counteract this by making the sun texture larger).

By default instead of behaving fullbright object, the background will be averaged out behind the moon to act as a faux "ambient" term, to disable this effect, go to `assets/minecraft/shaders/include/config.glsl` and set `AVERAGE_MOON_LIGHTING` to `false`. On the image below this paragraph you can see the effect of an averaged background on the left versus a fully black background on the right.

![Averaged lighting result comparison](./images/average_lighting.png)

### Return fog

The shader removes fog by default, because it might clash with the skybox. To revert this, delete `assets/minecraft/shaders/include/fog.glsl`.

### Return the horizon

The shader removes the horizon of the game (only appears at sunset and gives the lower edge of the sky an orangeish hue). If you want to revert this, delete `assets/minecraft/shaders/core/position_color.vsh`.

## Limitations

- Skyboxes can only be based on time for now, not weather or other events.
- Skybox interpolation times can't overlap, the ending interpolation time of a skybox _must_ be less, than the starting interpolation time of the next one in the list.
- The sun texture has to be narrower, than the skyboxes.
- The sun is placed additively on top of the skybox, this means that it will disappear when the background is white.
- Most likely not compatible with graphics mods, e.g. Sodium, IRIS, OptiFine.
- GPUs have differing maximum supported texture sizes. If the sun texture exceeds these in height or width, the shader won't load and the game might crash.
  - Intel igpus: 8192
  - AMD: 16384
  - Nvidia: 32768

## Example configuration

This configuration matches the default one in the pack.

`sun.png`:

- Original sun.png with a modified alpha value of 17 in the top left 32x32 pixels.
- First skybox:
  - Row 34, pixel 0: Red channel is 64
  - Row 34, pixel 1: Red channel is 80
  - Skybox placed between (0, 34) and (768, 546)
- Second skybox:
  - Row 548, pixel 0: Red channel is 176
  - Row 548, pixel 1: Red channel is 192
  - Skybox placed between (0, 548) and (768, 1060)

Example timestamps:

- **Time = 0 to Time = 63**: The night skybox is shown
- **Time = 64**: The day skybox starts taking over
- **Time = 72**: The day skybox is 50% visible
- **Time = 80 to Time = 175**: The day skybox is fully visible
- **Time = 176**: The night skybox starts taking over
- **Time = 184**: The night skybox is 50% visible
- **Time = 192 to Time = 255**: The night skybox is fully visible

## Examples for incorrect configurations

### Skyboxes overlapping

first skybox:

- starting interp time: 128
- ending interp time: 192

second skybox:

- starting interp time: 160
- ending interp time: 250

### Skyboxes are in the wrong order

first skybox:

- starting interp time: 160
- ending interp time: 250

second skybox:

- starting interp time: 128
- ending interp time: 136

### Skybox ending interpolation time is before the starting interpolation time

skybox:

- starting interp time: 250
- ending interp time: 160
