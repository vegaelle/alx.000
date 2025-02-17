import os
import argparse
import json
from typing import Iterator, Optional, TypedDict, NotRequired
import subprocess
import tempfile
import logging
import dataclasses
import unicodedata
import enum

import typeguard
import lib3mf


logger = logging.getLogger()
logging.basicConfig(level=logging.INFO)

SCAD_FILE = 'pg1316s_keycap.scad'
OPENSCAD_COMMAND = 'openscad'
KEY_MODEL = "pg1316s"

@dataclasses.dataclass
class MultiLabel:
    top_left: str = ''
    top_center: str = ''
    top_right: str = ''
    middle_left: str = ''
    middle_center: str = ''
    middle_right: str = ''
    bottom_left: str = ''
    bottom_center: str = ''
    bottom_right: str = ''
    front_left: str = ''
    front_center: str = ''
    front_right: str = ''


    @classmethod
    def from_string(cls, s: str) -> 'MultiLabel':
        items = s.split('\n')
        if len(items) == 1:
            return cls(middle_center=s)
        positions = [
            'top_left',
            'bottom_left',
            'top_right',
            'bottom_right',
            'front_left',
            'front_right',
            'middle_left',
            'middle_right',
            'top_center',
            'middle_center',
            'bottom_center',
            'front_center',
        ]
        args = {}
        for pos, label in enumerate(items):
            args[positions[pos]] = label

        return cls(**args)

    def __len__(self) -> int:
        """
        Returns the number of non-empty labels
        """
        return sum([1 for f in dataclasses.fields(self) if getattr(self, f.name) != ''])
    
    def __str__(self) -> str:
        members = ', '.join([f'{k}={v!r}' for k, v in self.items()])
        return f'{self.__class__.__name__}({members})'

    def main_label(self) -> str:
        # TODO: complete this method so it can read secondary labels
        return self.middle_center

    def items(self) -> Iterator[tuple[str, str]]:
        for field in dataclasses.fields(self):
            value = getattr(self, field.name)
            if value:
                yield (field.name, value)



class KeyboardModifier(TypedDict, total=False):
    x: NotRequired[float]
    y: NotRequired[float]
    t: NotRequired[str]  # label color
    a: NotRequired[int]  # ??
    f: NotRequired[int]  # font size
    n: NotRequired[bool]  # homing
    

KeyboardLayout = list[list[KeyboardModifier | str]]


class RenderTarget(enum.Enum):
    keycap = 'keycap'
    labels = 'labels'
    all = 'all'


def keyboard_layout(filename: str) -> KeyboardLayout:

    fd = argparse.FileType('r')(filename)
    data = json.load(fd)
    del data[0]  # should be keyboard metadata
    if not typeguard.check_type(data, KeyboardLayout):
        raise ValueError('JSON format is incorrect')
    return data


def render_model(render_type: RenderTarget, label: Optional[MultiLabel],
                 file_name, modifier: KeyboardModifier, pos_x: float, pos_y: float):
    """
    Calls OpenSCAD to render a script into a file
    """
    logger.info('Calling render %s for %s key at position (%.2f,%.2f)', render_type.name, label,
                pos_x, pos_y)
    args = [OPENSCAD_COMMAND, '--export-format', 'binstl', '-o', file_name, '-D',
            f'kc_part="{render_type.value}"']
    if label is not None and len(label):
        for label_pos, label_text in label.items():
            args += ['-D', f'kc_label_{label_pos}="{label_text}"']
    args.append(SCAD_FILE)
    proc = subprocess.run(args, capture_output=True)
    if proc.returncode == 0:
        logger.info('Render complete')
    else:
        logger.error('Render failed with return code %d!', proc.returncode)
        raise RuntimeError(f'Rendering of {label} ({render_type}) keycap failed!')



def generate_key_into_model(model: lib3mf.Model,
                            label: MultiLabel,
                            modifier: KeyboardModifier,
                            pos_x: float, pos_y: float):
    """
    Generates a combined keycap model for a given key, and imports it into a model.
    """
    main_label = label.main_label()
    reader = model.QueryReader('stl')

    with tempfile.TemporaryDirectory() as tmp_dir:
        if isinstance(main_label, str):
            if not main_label.isalpha():
                main_label = unicodedata.name(main_label).replace(' ', '_')
            main_label = main_label.lower()

            keycap_file = f"{KEY_MODEL}_keycap_{main_label}.stl"
            label_file = f"{KEY_MODEL}_label_{main_label}.stl"
            render_model(RenderTarget.keycap, label,
                         os.path.join(tmp_dir, keycap_file), modifier, pos_x, pos_y)
            reader.ReadFromFile(os.path.join(tmp_dir, keycap_file))
            render_model(RenderTarget.labels, label,
                         os.path.join(tmp_dir, label_file), modifier, pos_x, pos_y)
            reader.ReadFromFile(os.path.join(tmp_dir, label_file))
        else:  # key without any label
            all_file = f"{KEY_MODEL}_all_{main_label}.stl"
            render_model(RenderTarget.all, None,
                         os.path.join(tmp_dir, all_file), modifier, pos_x, pos_y)
            reader.ReadFromFile(os.path.join(tmp_dir, all_file))
    

def main():
    parser = argparse.ArgumentParser(description='Generate a set of labeled keycaps '
                                     'from a keyboard layout definition')
    parser.add_argument('layout_file', type=keyboard_layout)
    parser.add_argument('dest_file', type=argparse.FileType('w'))
    args = parser.parse_args()
    args.dest_file.close()

    wrapper = lib3mf.get_wrapper()
    model = wrapper.CreateModel()
    assert isinstance(model, lib3mf.Model)
    cur_y = 0
    cur_modifier: KeyboardModifier = {}
    keys_count = 0
    for line in args.layout_file[:1]:
        cur_x = 0
        for item in line:
            try:
                typeguard.check_type(item, KeyboardModifier)
                cur_modifier = item
                if 'y' in cur_modifier:
                    cur_y += cur_modifier['y']
                if 'x' in cur_modifier:
                    cur_x += cur_modifier['x']
            except typeguard.TypeCheckError:
                generate_key_into_model(model,
                                        MultiLabel.from_string(item),
                                        cur_modifier,
                                        cur_x, cur_y)

                keys_count += 1
            cur_x += 1

        cur_y += 1

    writer = model.QueryWriter('3mf')
    writer.WriteToFile(args.dest_file.name)
    logger.info('Written %d models into %s', keys_count, args.dest_file.name)


if __name__ == '__main__':
    main()
