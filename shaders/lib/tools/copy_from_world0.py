import os
import shutil

# Get the current directory (where the script is located)
current_dir = os.path.dirname(os.path.abspath(__file__))

# Navigate up to the 'shaders' directory
shaders_dir = os.path.dirname(os.path.dirname(current_dir))

# List of folders to delete
folders = [
    {
        'folder': 'world-1',
		'dimension': 'nether',
	}, 
    {
        'folder': 'world1',
		'dimension': 'end',
	},
    {
        'folder': 'world5',
		'dimension': 'twilight',
	},
    {
        'folder': 'world7',
		'dimension': 'twilight',
	},
]

for folder in folders:
    folder_path = os.path.join(shaders_dir, folder['folder'])
    if os.path.exists(folder_path):
        try:
            for filename in os.listdir(folder_path):
                file_path = os.path.join(folder_path, filename)
                if os.path.isfile(file_path):
                    os.remove(file_path)
                    print(f"Deleted file: {file_path}")
            print(f"Deleted files in folder: {folder['folder']}")
        except Exception as e:
            print(f"Error deleting files in folder {folder['folder']}: {e}")
    else:
        print(f"Folder not found: {folder['folder']}")

print("Deletion process completed.")

# Copy files from world0 to other dimension folders
world0_path = os.path.join(shaders_dir, 'world0')

for folder in folders:
    dest_folder = os.path.join(shaders_dir, folder['folder'])
    dimension = folder['dimension'].upper().replace(' ', '_')
    
    if not os.path.exists(dest_folder):
        os.makedirs(dest_folder)
    
    for filename in os.listdir(world0_path):
        src_file = os.path.join(world0_path, filename)
        dest_file = os.path.join(dest_folder, filename)
        
        if os.path.isfile(src_file):
            with open(src_file, 'r') as f:
                content = f.read()
            
            # Replace the dimension define
            content = content.replace('#define DIM_OVERWORLD', f'#define DIM_{dimension}')
            
            with open(dest_file, 'w') as f:
                f.write(content)
            
            print(f"Copied and modified: {dest_file}")

print("Copy process completed.")
