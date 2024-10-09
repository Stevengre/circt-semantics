#!/usr/bin/env python3

import sys
import fire

def drop_hw_param_decl(input: str, output: str):
    """drop start with `#hw.param.decl` end up with `,`"""
    with open(input, 'r') as infile, open(output, 'w') as outfile:
        for line in infile:
            while '#hw.param.decl' in line:
                start = line.find('#hw.param.decl')
                end = line.find(',', start) + 1
                if end > 0:
                    if ']' in line[start:end]:
                        # 找到start前最近的[
                        start = start - line[start::-1].find('[')
                        start = start + 1
                        end = end - 2
                    print(line[start:end])
                    line = line[:start] + line[end:]
                else:
                    break
            outfile.write(line)

if __name__ == "__main__":
    fire.Fire()

