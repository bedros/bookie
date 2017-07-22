#!/bin/python3

import re


class Version:
    def __init__(self, number, name):
        self.number = number
        self.name = name

    def elm(self):
        return (  'version =\n'
               + f'    ( "{self.number}", "{self.name}" )'
               )

    def python(self):
        return f"VERSION = ('{self.number}', '{self.name}')"

    def __repr__(self):
        return f'Version("{self.number}", "{self.name}")'


def parse_version(data):
    data_list = data.split()
    number = data_list[0]
    name = ' '.join(data_list[1:])
    return Version(number, name)


def get_version():
    return parse_version(open('VERSION', 'r').read().strip())


def generic_update(filename, regex, version_code):
    with open(filename, 'r+') as f:
        data = f.read()
        print('Updating {} occurrences in {}'
                .format(len(re.findall(regex, data)), filename)
        )
        updated_data = re.sub(regex , version_code, data)
        f.seek(0)
        f.write(updated_data)


def update_elm(version):
    regex = 'version =\s*\([a-zA-Z0-9 "\.,]+\)'
    generic_update('frontend/Main.elm', regex, version.elm())
    #  data = f.read()
    #  print('Updating {} occurrences'.format(len(re.findall(regex, data))))
    #  updated_data = re.sub(regex , version.elm(), data)
    #  f.seek(0)
    #  f.write(updated_data)


def update_python(version):
    regex = 'VERSION = \([a-zA-Z0-9 \'\.,]+\)'
    generic_update('bookie/__init__.py', regex, version.python())
    #  with open('bookie/__init__.py', 'r+') as f:
    #      data = f.read()
    #      print('Updating {} occurrences'.format(len(re.findall(regex, data))))
    #      updated_data = re.sub(regex , version.python(), data)
    #      f.seek(0)
    #      f.write(updated_data)


if __name__ == '__main__':
    version = get_version()
    print(f'Updating code to {version}')
    update_elm(version)
    update_python(version)
