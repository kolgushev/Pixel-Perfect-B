import os
import yaml
import re

unparsed_blocks = {}

script_dir = os.path.dirname(os.path.abspath(__file__))
blocks_file_path = os.path.join(
    script_dir, 'datasets', 'blocks.yml')

with open(blocks_file_path, "r") as file:
    blocks = yaml.safe_load(file)

    for category in blocks:
        for block in blocks[category]:
            if block in unparsed_blocks:
                unparsed_blocks[block].append(category)
            else:
                unparsed_blocks[block] = [category]

parsed_blocks = {}
for block in unparsed_blocks:
    pattern = r'^(\w+:)?(\w+)((?::\w+?=\w+?)+)?$'
    match = re.match(pattern, block)
    categories = unparsed_blocks[block]

    if match:
        namespace = match.group(1) or 'minecraft:'
        block_name = match.group(2)
        properties = match.group(3)

        if properties:
            properties = properties.lstrip(':').split(':')
            properties.sort()
        else:
            properties = []

        current_property_names = set(property.split('=')[0] for property in properties)
        property_key = ':'.join(properties)

        if namespace + block_name in parsed_blocks:
            obj = parsed_blocks[namespace + block_name]

            if current_property_names != obj['property_names']:
                print(f"Warning: Properties need to be enumerated for '{
                      namespace + block_name}': '{current_property_names}' does not match '{obj['property_names']}'")

            obj['possible_properties'][property_key] = {
                'categories': categories,
                'properties': properties,
            }
        else:
            parsed_blocks[namespace + block_name] = {
                'property_names': current_property_names,
                'possible_properties': {property_key: {
                    'categories': categories,
                    'properties': properties,
                }}
            }

    else:
        print(f"Warning: Unable to parse block '{block}'")

block_ids = {}
category_checks = {}
for block in parsed_blocks:
    for property in parsed_blocks[block]['possible_properties']:
        categories = parsed_blocks[block]['possible_properties'][property]['categories']

        category_combination_name = 'BLOCKS_' + '_AND_'.join(categories).upper()
        if category_combination_name not in block_ids:
            block_ids[category_combination_name] = []
            print(f"New category combination: {category_combination_name}")

        for category in categories:
            if category not in category_checks:
                category_checks[category] = [category_combination_name]
            elif category_combination_name not in category_checks[category]:
                category_checks[category].append(category_combination_name)

        block_string = block + (':' + property if property else '')
        block_ids[category_combination_name].append(block_string)

block_properties_str = ''
block_aliases_str = ''

i = 0
for block_id in block_ids:
    i += 1
    block_aliases_str += f'#define {block_id} {i}\n'
    block_properties_str += f'\n# {block_id}\nblock.{i} ='
    for block in block_ids[block_id]:
        block_properties_str += f' {block}'
    block_properties_str += '\n'

for check in category_checks:
    check_name = ''.join(word.capitalize() for word in check.split('_'))
    block_aliases_str += f'#define isBlock{check_name}(id) ({' || '.join(
        [f'id == {name}' for name in category_checks[check]])})\n'

# Write block_properties_str to block.properties
with open(os.path.join(script_dir, '..', '..', 'block.properties'), 'w') as f:
    f.write(block_properties_str)

# Write block_aliases_str to block_aliases.glsl
with open(os.path.join(script_dir, '..', '..', 'block_aliases.glsl'), 'w') as f:
    f.write(block_aliases_str)

print("Block properties and aliases have been written to their respective files.")
