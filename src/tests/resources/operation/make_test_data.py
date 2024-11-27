import json,random
import copy,os
from pathlib import Path

DATA_PATH = Path(__file__).parent
RANDOM_COFIG_FILE =  DATA_PATH/'random_config.json'
TEST_PATH_FILE = DATA_PATH/'test_path.json'


class test_data:
    output_filr: Path
    config: dict
    output_data: list
    num: int

    def __init__(self, config: dict, output_file: Path):
        self.output_file = output_file
        self.config = config
        self.output_data = []
        self.num = 0

    def randomBuild(self, now_data: list,index: int) -> bool:
        bits_num = self.config['type'][index]
        box_size = 1
        box_size = 2**bits_num
        if index == 0:
            while self.num < self.config['mode']:
                x=random.randint(0,box_size-1)
                now_data.append([x,bits_num])
                if index != self.config['length']-1:
                    self.randomBuild(now_data,index+1)
                else:
                    self.output_data.append(copy.deepcopy(now_data))
                    self.num += 1
                now_data.pop()
        else:
            x=random.randint(0,box_size-1)
            now_data.append([x,bits_num])
            if index != self.config['length']-1:
                self.randomBuild(now_data,index+1)
            else:
                self.output_data.append(copy.deepcopy(now_data))
                self.num += 1
            now_data.pop()
        return True

    def add1(self, now_data: list,index: int) -> bool:
        box_size = 1
        bits_num = self.config['type'][index]
        box_size = 2**bits_num
        for x in range(box_size):
            now_data.append([x,bits_num])
            if index != self.config['length']-1:
                self.add1(now_data,index+1)
            else:
                self.output_data.append(copy.deepcopy(now_data))
            now_data.pop()
        return True

    def write(self):
        output_dict = {}
        output_dict['inputs'] = self.output_data
        with open(self.output_file, 'w', encoding='utf-8') as file:
            json.dump(output_dict, file, indent=4)

def make_test_data(random_config, test_path):
    output_filr = {}
    for level1 in test_path['level1']:
        directory = level1['name']
        for operation in level1['operation']:
            output_filr[operation] = DATA_PATH/directory/operation/'test_data.json'
    #预处理路径信息对于操作名字

    for config in random_config['config']:
        if config['name'] in output_filr:
            if os.path.exists(output_filr[config['name']]) != True:
                misson = test_data(config = config, output_file=output_filr[config['name']])
                #全枚举 &随机  
                if config['length'] == 0:
                    misson.output_data = []
                elif config['mode'] > 0:
                    misson.randomBuild([],0)
                elif config['mode'] == 0:
                    misson.add1([],0)
                    
                if 'clock' in config and config['clock'] == 1:
                    for index, out1 in enumerate(misson.output_data):
                        out1[0][0] = (index+1)%2
                misson.write()
    return


if __name__ == '__main__':
    with open(RANDOM_COFIG_FILE, 'r', encoding='utf-8') as file:
        random_config = json.load(file)
    with open(TEST_PATH_FILE, 'r', encoding='utf-8') as file:
        test_path = json.load(file)
    
    make_test_data(random_config, test_path)