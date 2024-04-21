import os
import shutil

def adapt_shader_content(original_content, target_world):
    # Replace world-specific identifiers in the shader content
    dim_map = {
        'world0': 'OVERWORLD',
        'world-1': 'NETHER',
        'world1': 'END',
        'world5': 'TWILIGHT',
        'world7': 'TWILIGHT',
    }
    original_dim = original_content.split('\n')[1].split(' ')[1]
    new_dim = f"DIM_{dim_map[target_world]}"
    adapted_content = original_content.replace(original_dim, new_dim)
    return adapted_content

def copy_and_adapt_shaders(source_dir, target_dirs):
    for target_dir in target_dirs:
        target_world = os.path.basename(target_dir)
        if not os.path.exists(target_dir):
            os.makedirs(target_dir)
        for filename in os.listdir(source_dir):
            source_file = os.path.join(source_dir, filename)
            target_file = os.path.join(target_dir, filename)
            if os.path.isfile(source_file):
                # Copy file
                shutil.copy2(source_file, target_file)
                # Read, adapt, and write the shader file
                with open(target_file, 'r') as file:
                    content = file.read()
                adapted_content = adapt_shader_content(content, target_world)
                with open(target_file, 'w') as file:
                    file.write(adapted_content)

# Directory of the extracted shaders
base_path = '../'

# Define source and target directories
source_directory = os.path.join(base_path, 'world0')
target_directories = [os.path.join(base_path, dir_name) for dir_name in ['world-1', 'world1', 'world5', 'world7']]

# Execute the copy function
copy_and_adapt_shaders(source_directory, target_directories)
