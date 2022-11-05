# Made with the help of Adobe's Cube LUT Specification: https://wwwimages2.adobe.com/content/dam/acom/en/products/speedgrade/cc/pdfs/cube-lut-specification-1.0.pdf

import glob, os, re, cv2
import numpy as np

# find all files with ".cube" extension
os.chdir('.')
file_names = glob.glob('*.cube')

PACK = False

if len(file_names) >= 1:
    # read first file
    raw_file = open(file_names[0], 'r')
    raw_text = raw_file.read()

    # find metadata
    meta_1D_list = re.findall(r'^LUT_1D_SIZE ([\d]+)$', raw_text, re.M)
    meta_3D_list = re.findall(r'^LUT_3D_SIZE ([\d]+)$', raw_text, re.M)
    meta_domain_min_list = re.findall(r'^DOMAIN_MIN ([\d\. ]+)$', raw_text, re.M)
    meta_domain_max_list = re.findall(r'^DOMAIN_MAX ([\d\. ]+)$', raw_text, re.M)
    columns = re.findall(r'^ *([\d\. e+-]+) *$', raw_text, re.M)

    # find custom options
    raw_text_lower = raw_text.lower()
    viewing_transform = re.findall(r'^# *viewing transform *: *(\d+) *$', raw_text_lower, re.M)
    output_colorspace = re.findall(r'^# *output colorspace *: *(\d+) *$', raw_text_lower, re.M)
    gamma_correction = re.findall(r'^# *gamma correction *: *(\w+) *$', raw_text_lower, re.M)
    if viewing_transform:
        print('found viewing transform setting')
        viewing_transform = viewing_transform[0]
    if output_colorspace:
        print('found output colorspace setting')
        output_colorspace = output_colorspace[0]
    if gamma_correction:
        print('found gamma correction setting')
        gamma_correction = gamma_correction[0]

    # check for linear mapping (to avoid unnecessary calculations)
    meta_domain_min = re.findall(r'\d+(?:\.\d+)?', meta_domain_min_list[0]) if len(meta_domain_min_list) >= 1 else ['0.0', '0.0', '0.0']
    meta_domain_max = re.findall(r'\d+(?:\.\d+)?', meta_domain_max_list[0]) if len(meta_domain_max_list) >= 1 else ['1.0', '1.0', '1.0']


    # ensure file validity
    if len(columns) >= 6 and (len(meta_1D_list) == 1 or len(meta_3D_list) == 1):
        # intepret data as 2D array
        data = []
        for item in columns:
            rgb_data_str = re.findall(r'\d+(?:\.\d+)?(?:e[+-]\d+)?', item)
            rgb_data = []
            for channel in rgb_data_str:
                rgb_data.append(float(channel))
            data.append(rgb_data)

        meta_max_color = 0.0
        for color in data:
            for channel in color:
                if channel > meta_max_color:
                    meta_max_color = channel

        # extract first instance of metadata from found lists
        meta_1D = len(meta_1D_list) == 1
        meta_dimensions = 1 if meta_1D else 3
        meta_size = int(meta_1D_list[0]) if meta_1D else int(meta_3D_list[0])

        # pregenerate some meta values
        meta_domain_mult = []
        linear_mapping = True
        for i in range(len(meta_domain_min)):
            minNum = float(meta_domain_min[i])
            maxNum = float(meta_domain_max[i])
            if(minNum != 0.0 or maxNum != 1.0):
                linear_mapping = False
            meta_domain_mult.append(str(maxNum - minNum))

        meta_domain_add_str = ", ".join(meta_domain_min)
        meta_domain_mult_str = ", ".join(meta_domain_mult)

        # write metadata to file
        lut_meta = open('lut_meta.glsl', 'w')
        write_str = f"""\
#define LUT_DIM {meta_dimensions}
#define LUT_SIZE {meta_size}
#define LUT_SIZE_RCP {1 / meta_size}
#define LUT_SIZE_RCP1 {1 / (meta_size - 1)}
{"" if linear_mapping else "// "}#define LUT_LINEAR_MAPPING
#define LUT_DOMAIN_ADD vec3({meta_domain_add_str.strip()})
#define LUT_DOMAIN_MULT vec3({meta_domain_mult_str.strip()})
#define LUT_RANGE_MULT {1 / meta_max_color}

"""
        
        if viewing_transform:
            write_str += f'#define LUT_LMT_MODE {viewing_transform}\n'
        if output_colorspace:
            write_str += f'#define LUT_OUTPUT_COLORSPACE {output_colorspace}\n'
        if gamma_correction:
            write_str += f'#define LUT_OVERRIDE_GAMMA_CORRECT\n{"" if gamma_correction.lower() == "on" else "// "}#define LUT_GAMMA_CORRECT'

        lut_meta.write(write_str)

        # reformat data into 3D array to use as intake for openCV
        img = []
        tex_size = 0;
        if(meta_dimensions == 1):
            file = open('error.md', 'w')
            file.write("Error: One-dimensional LUTs are currently unsupported.")
        else:
            if PACK:
                num_tiles = int(np.ceil(np.sqrt(meta_size)))
                tex_size = num_tiles * meta_size
                for y_id in range(tex_size):
                    row = []
                    for x_id in range(tex_size):
                        pixel_id = y_id * meta_size + x_id
                        
                        tile_pos = [int(np.floor(x_id / meta_size)), int(np.floor(y_id / meta_size))]
                        tile_id = tile_pos[1] * num_tiles + tile_pos[0]
                        
                        within_tile_pos = [x_id - tile_pos[0] * meta_size, y_id - tile_pos[1] * meta_size]
                        within_tile_id = within_tile_pos[1] * num_tiles + within_tile_pos[0]

                        index = np.clip(within_tile_pos[1] + within_tile_pos[0] * meta_size + tile_id * pow(meta_size, 2), 0, pow(meta_size, 3) - 1)
                        rgba = data[index]
                        # rgba = within_tile_id / pow(32, 2) * 4
                        # rgba.append(1.0)
                        row.append(rgba)
                    img.append(row)
            else:
                tex_size = meta_size
                for column_id in range(pow(tex_size, 2)):
                    column = []
                    for pixel_id in range(tex_size):
                        index = column_id * tex_size + pixel_id
                        rgba = data[index]
                        rgba.reverse()
                        rgba.append(1.0)
                        column.append(rgba)
                    img.append(column)
        np_img = np.asarray(img, dtype=np.float32)

        # img_up_res = 1024
        # up_mult = int(np.floor(img_up_res / tex_size))
        # img_up = cv2.resize(np_img, None, fx=up_mult, fy=up_mult, interpolation=cv2.INTER_LINEAR)

        # write image
        cv2.imwrite('lut.png', 255 * np_img)
        print('done')
    else:
        print(len(meta_1D_list))
        print(len(meta_3D_list))
        print(len(meta_domain_min_list))
        print(len(meta_domain_max_list))
        print(len(columns))
        print(raw_text[0:300])
        file = open('error.md', 'w')
        file.write("Error: Invalid CUBE file. Please make sure the file you're using is formatted correctly.")
else:
    file = open('error.md', 'w')
    file.write("Error: No files recognized. Make sure your file has the `.cube` extension in all-lowercase.")