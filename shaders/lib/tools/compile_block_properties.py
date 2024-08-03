import os
import yaml
import re


def enumerate_block_properties(existing_property_names, existing_property_values, to_enumerate, counter=[0]):
    # if dict is empty
    if not to_enumerate:
        counter[0] += 1
        return [[f'{existing_name}={existing_value}' for existing_name, existing_value in zip(existing_property_names, existing_property_values)]]

    property_name, values = next(iter(to_enumerate.items()))
    remaining_properties = dict(list(to_enumerate.items())[1:])

    if property_name in existing_property_names:
        return enumerate_block_properties(existing_property_names, existing_property_values, remaining_properties, counter)

    permutations = []
    if 'values' in values:
        for value in values['values']:
            for property in enumerate_block_properties(existing_property_names, existing_property_values, remaining_properties, counter):
                property.append(f"{property_name}={value}")
                permutations.append(property)

    if 'range' in values:
        for value in range(values['range'][0], values['range'][1] + 1):
            for property in enumerate_block_properties(existing_property_names, existing_property_values, remaining_properties, counter):
                property.append(f"{property_name}={value}")
                permutations.append(property)

    return permutations


parsed_blocks = {}

script_dir = os.path.dirname(os.path.abspath(__file__))
blocks_file_path = os.path.join(
    script_dir, 'datasets', 'blocks.yml')

# load yml
with open(blocks_file_path, "r") as file:
    parsed_file = yaml.safe_load(file)
    categories = parsed_file['categories']
    templates_raw = parsed_file['templates']

    templates = {}
    # add namespace to templates
    for template in templates_raw:
        split = template.split(':')
        if len(split) == 1:
            templates[f'minecraft:{template}'] = templates_raw[template]
        else:
            templates[template] = templates_raw[template]

    # parse and enumerate all block properties
    # for each block
    for category in categories:
        for block in categories[category]:
            raw_name = block if isinstance(
                block, str) else next(iter(block.items()))[0]
            # parse
            pattern = r'^(?:(\w+):)?(\w+)((?::\w+?=\w+?)+)?$'
            match = re.match(pattern, raw_name)

            # assert parseable
            if match:
                namespace = match.group(1) or 'minecraft'
                block_name = match.group(2)
                properties = match.group(3)
                full_name = f'{namespace}:{block_name}'

                # property values to list
                if properties:
                    properties = properties.lstrip(':').split(':')
                    properties.sort()
                else:
                    properties = []

                current_property_names = [property.split(
                    '=')[0] for property in properties]
                current_property_values = [property.split(
                    '=')[1] for property in properties]

                to_enumerate = None

                # if a block is a dict, enumerate all permutations of property values
                if isinstance(block, dict):
                    _, to_enumerate = next(iter(block.items()))
                    # add template properties (not in the block already) to the to_enumerate dict
                    # in order to avoid non-matching properties when parsing
                    if full_name in templates:
                        for property in templates[full_name]:
                            if property not in to_enumerate:
                                to_enumerate[property] = templates[full_name][property]
                else:
                    to_enumerate = templates[full_name] if full_name in templates else {
                    }

                counter = [0]

                property_permutations = enumerate_block_properties(
                    current_property_names, current_property_values, to_enumerate, counter)

                if counter[0] > 1:
                    print(f"Permuted {
                          full_name} {counter[0]} times")

                is_new_block = full_name not in parsed_blocks
                if is_new_block:
                    parsed_blocks[full_name] = {
                        'property_names': current_property_names,
                        'possible_properties': {}
                    }

                for permutation in property_permutations:
                    # add unrecorded property names
                    current_property_names = [property.split(
                        '=')[0] for property in permutation]
                    for property_name in current_property_names:
                        if property_name not in parsed_blocks[full_name]['property_names']:
                            parsed_blocks[full_name]['property_names'].append(
                                property_name)
                            if not is_new_block:
                                print(f"Warning: Properties do not match for '{full_name}': '{
                                    property_name}' is not enumerated somewhere.")
                    # add new possible properties
                    property_key = ':'.join(permutation)
                    if property_key not in parsed_blocks[full_name]['possible_properties']:
                        parsed_blocks[full_name]['possible_properties'][property_key] = {
                            'categories': [category],
                            'properties': properties,
                        }
                    else:
                        block_state_categories = parsed_blocks[full_name][
                            'possible_properties'][property_key]['categories']
                        if category not in block_state_categories:
                            block_state_categories.append(category)
                        else:
                            print(f"Warning: Duplicate block state for '{
                                  full_name}:{property_key}'.")

            else:
                raise ValueError(f"Unable to parse block '{block}'")

# find blocks with shared categories and create ids accordingly
block_ids = {}
category_checks = {}
for block in parsed_blocks:
    for property in parsed_blocks[block]['possible_properties']:
        categories = parsed_blocks[block]['possible_properties'][property]['categories']

        category_combination_name = 'BLOCKS_' + \
            '_AND_'.join(categories).upper()
        if category_combination_name not in block_ids:
            block_ids[category_combination_name] = []

        for category in categories:
            if category not in category_checks:
                category_checks[category] = [category_combination_name]
            elif category_combination_name not in category_checks[category]:
                category_checks[category].append(category_combination_name)

        block_string = block + (':' + property if property else '')
        block_ids[category_combination_name].append(block_string)

# parse block ids and category checks into `block.properties` and `block_aliases.glsl`
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
