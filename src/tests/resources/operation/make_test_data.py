import json
from pathlib import Path

DATA_PATH = Path(__file__).parent
RANDOM_COFIG_FILE =  DATA_PATH/'random_config.json'
TEST_PATH_FILE = DATA_PATH/'test_path.json'

def make_test_data(random_config, test_path):
    return


if __name__ == '__main__':
    with open(RANDOM_COFIG_FILE, 'r', encoding='utf-8') as file:
        random_config = json.load(file)
    with open(TEST_PATH_FILE, 'r', encoding='utf-8') as file:
        test_path = json.load(file)
    
    make_test_data(random_config, test_path)