# How to use LUTs with this shader

*Please note that **by default** LUTs work specifically within Linear ACEScg, after tonemapping. See "Customizing LUTs" for more information.*

LUTs, short for LookUp Tables, can be used to store colorgrading profiles in a file. This shader contains a python script that allows you to add your own colorgrading to this shader. This tutorial assumes you know how to make and export colorgrading profiles as `.cube` files and are using Windows 10/11.

If you have trouble following these instructions, I have created [a custom GPT](https://chatgpt.com/g/g-z9us9kwWg-shader-lut-assistant) to assist you. Unfortunately, although you can access it as a free user, your messages will be limited.

Make sure you can see file extensions before following these steps. To see file extensions in Windows file explorer, click `View > Show > File name extensions`.

If you have a raw lookup table with the `cube` extension (example: `LookupTable.cube` or `LookupTable.CUBE`), do the following:

1. Install the [Python programming language](https://www.python.org/downloads/), if you don't already have it.
2. Open the command prompt
3. Check that you have Python enabled in the command prompt by running `python --version` and `pip --version`
4. Navigate to the `shaderpacks` folder in your Minecraft install (for instance by clicking the "Open Shader Pack Folder" in Iris)
5. Extract the zip file for the shader into a folder of the same name
    - Right-click the zipped file
    - Click "Extract All"
    - Without changing the directory, click "Extract"
6. Open the extracted folder
7. In the extracted folder, navigate to `shaders`
8. In `shaders`, right-click `LUTs` and click "Copy as Path"
9. Drag your `.cube` file into `LUTs`.
10. In the command prompt, run `cd <the path you just copied>`.
     - This will move the command prompt into the `LUTs` folder.
     - Alternatively, if you're using Windows 11, you can just right-click the folder and select "Open in Terminal".
11. In the command prompt/terminal, run
     - `pip install --upgrade pip`. If it results in an error, follow the instructions in the error message.
     - `pip install opencv-python`. This will install the library used to process the debug image.
     - `python convert.py`. This will run the script that converts your `.cube` file into a format the shader can use.
     - Reload the shader (`F3 + R` in Optifine) and your new colorgrading will be applied.

If something went wrong, an `error.md` file describing the problem should appear.

*NOTE: Some LUTs are copyrighted or licensed, so make sure to follow applicable law when redistributing converted files.*



# Customizing LUTs

If you upload the `.cube` file to the custom GPT I mentioned earlier, it can help you with the customization process (but it's not very good at it).

The script can also read some settings that aren't included in your `.cube` file by default. You can open the `.cube` file with any text editor (Notepad should work fine) and add the following lines to the top of the file:

```
# tonemap: <The tonemap used by the LUT> (ACES_FITTED_TONEMAP by default)
# input colorspace: <The colorspace of the image the LUT uses> (SRGB_COLORSPACE by default)
# output colorspace: <The colorspace of the image the LUT outputs> (SRGB_COLORSPACE by default)
```

You can use these to mod the shader to potentially work with WCG colors.


If you change (or add, if it's not already present) `DOMAIN_MAX` in the `.cube` file, the shader will also be able to work with HDR colors.
An example:
```
DOMAIN_MAX 10.0 10.0 10.0
```

The 10s mean that the shader will pass colors divided by 10 to the LUT, allowing it to use as input colors that would usually be 10 times brighter than the maximum screen brightness. You can change these values to anything other than 10.0 if you want.


Supported tonemaps:

- NONE_TONEMAP
- REINHARD_TONEMAP
- HABLE_TONEMAP
- ACES_FITTED_TONEMAP
- ACES_APPROX_TONEMAP
- CUSTOM_TONEMAP

Supported colorspaces:

- SRGB_COLORSPACE
- DCI_P3_COLORSPACE
- DISPLAY_P3_COLORSPACE
- REC2020_COLORSPACE
- ADOBE_RGB_COLORSPACE
- REC709_COLORSPACE
- REC2100_HLG_COLORSPACE
- ACESCG_COLORSPACE
- ACES2065_1_COLORSPACE
- LINEAR_RGB_COLORSPACE
- XYZ_COLORSPACE
- OKLAB_COLORSPACE