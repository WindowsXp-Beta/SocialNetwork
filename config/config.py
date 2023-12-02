import json

def load_config(file_path):
    with open(file_path, 'r') as file:
        return json.load(file)

def replace_placeholders(template, config):
    updated_template = template
    for key, value in config.items():
        placeholder = f'<<{key.upper()}>>'
        updated_template = updated_template.replace(placeholder, value)
    return updated_template

def main():
    config_file = 'config/config.json'
    template_file = 'socialNetwork/docker-compose-swarm.yml.template'
    template_files = ['socialNetwork/runtime_files/rubbos.properties_100.template',
                      'socialNetwork/docker-compose-swarm.yml.template']
    for template_file in template_files:
        output_file = template_file.rsplit('.template', 1)[0]
        # with open(config_file, 'r') as file:
        config = json.load(open(config_file))
        # config = load_config(config_file)

        with open(template_file, 'r') as file:
            template_content = file.read()

        updated_yaml = replace_placeholders(template_content, config)

        with open(output_file, 'w') as file:
            file.write(updated_yaml)

        print(f"Updated YAML file generated: '{output_file}'")

if __name__ == "__main__":
    main()
