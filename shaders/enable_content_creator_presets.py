import re

# Define the file path
FILE_PATH = 'shaders.properties'

# Read the file contents
with open(FILE_PATH, 'r') as file:
    content = file.readlines()

# Process the lines using regex
processed_content = [re.sub(r'^# (profile\.CONTENT_(ONE|TWO|THREE) = )', r'\1', line) for line in content]

# Write the modified content back to the file
with open(FILE_PATH, 'w') as file:
    file.writelines(processed_content)
