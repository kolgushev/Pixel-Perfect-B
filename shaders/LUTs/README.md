# How to use LUTs with this shader

LUTs, short for LookUp Tables, can be used to store colorgrading profiles in a file. This shader contains a python script that allows you to add your own colorgrading to this shader. This tutorial assumes you know how to make and export colorgrading profiles as `.cube` files and are using Windows 10/11.

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
     - `pip install --upgrade pip`. If it results in an error, follow the instructions.
     - `pip install opencv-python`. This will install the library used to process the debug image.
     - `python convert.py`. This will run the script that converts your `.cube` file into a format the shader can use.
     - Reload the shader (`F3 + R` in Optifine) and your new colorgrading will be applied.

If something went wrong, an `error.md` file describing the problem should appear.

*NOTE: Some LUTs are copyrighted or licensed, so make sure to follow applicable law when redistributing converted files.*