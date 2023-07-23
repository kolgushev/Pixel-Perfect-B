# The script creates a 3D .dat file containing one noise texture per z-level.

import os

from PIL import Image
import regex

img_dir = 'constituents'

binary_file = 'combined.dat'

# initialize the counter for total bytes written
total_bytes = 0
total_files = 0
resolution = 0

# reset file
if os.path.exists(binary_file):
    os.remove(binary_file)

# loop over all files in the directory
for filename in os.listdir(img_dir):
    # check if the file is an image
    if filename.endswith('.png') or filename.endswith('.jpg'):
        # generate the full file path
        filepath = os.path.join(img_dir, filename)

        # open the image and convert to RGBA
        img = Image.open(filepath).convert('RGBA')

        # log the image resolution
        if resolution == 0:
            resolution = img.width
        
        if resolution != img.width:
            raise ValueError(f'Previous resolution of {resolution} does not match the current image\'s resolution of {img.width}.')
        print(f'Resolution of {filename}: {img.width}x{img.height}')

        # create/open a binary file in append mode
        with open(binary_file, 'ab') as f:
            # loop over each pixel
            for pixel in list(img.getdata()):
                for channel in pixel:
                    # print(channel, channel.to_bytes(1, 'little'))
                    # write each channel of the pixel to the file
                    f.write(channel.to_bytes(1, 'little'))
                    total_bytes += 1

        total_files += 1

# log the final number of bits written to the file
print(f'Total bytes written: {total_bytes}')
print(f'Total files written: {total_files}')


# write the proper specs in shaders.properties & noise_meta
PROPS_FILE_DIR='../../shaders.properties'
with open(PROPS_FILE_DIR, 'r') as props_file:
    text = props_file.read()

text = regex.sub(r'texture\.(\w+\.\w+(?:\.\d)? *)= *\/tex\/noise\/combined.dat +TEXTURE_3D +\w+ \w+ \w+ \w+ \w+ \w+',
    fr'texture.\g<1>=/tex/noise/combined.dat TEXTURE_3D RGBA8 {resolution} {resolution} {total_files} RGBA UNSIGNED_BYTE',
    text)

with open(PROPS_FILE_DIR, 'w') as props_file:
    props_file.write(text)


META_FILE_DIR='./noise_meta.glsl'
with open(META_FILE_DIR, 'w') as meta_file:
    meta_file.write(f"""#define NOISETEX_TILES_RES {resolution}
#define NOISE_LAYER_COUNT {total_files}""")