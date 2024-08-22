# Dependency python-xlib
# need NotoSansMono Nerd Font for rofi

import sys
import os
import subprocess

from dataclasses import dataclass
from Xlib import X, display
from Xlib.ext import randr
import pprint


@dataclass
class Mode:
    id: int
    width: int
    height: int
    preferred: bool
    rates: list[float]

    def to_string(self):
        return f"{self.id} {self.width}x{self.height} preferred:{self.preferred}"

@dataclass
class Output:
    id: int
    name: str
    isPrimary: bool
    isConnected: bool
    isActive: bool
    modes: list[Mode]

    def to_string(self):
        string = f"{self.name} ({self.id}) primary:{self.isPrimary} connected:{self.isConnected} active:{self.isActive}\n"
        for mode in self.modes:
            string += "     " + mode.to_string() + "\n"
        return string


class Action:
    pass

@dataclass
class Disable(Action):
    output: Output

@dataclass
class Alone(Action):
    output: Output

@dataclass
class Primary(Action):
    output: Output

@dataclass
class RightOf(Action):
    output: Output
    target: Output

@dataclass
class LeftOf(Action):
    output: Output
    target: Output

@dataclass
class AboveOf(Action):
    output: Output
    target: Output

@dataclass
class BelowOf(Action):
    output: Output
    target: Output

def get_action_key(a: Action):
    if isinstance(a, Disable):
        return f"襤 Disable"
    if isinstance(a, Alone):
        return f" Alone"
    if isinstance(a, Primary):
        return f" Primary"
    if isinstance(a, LeftOf):
        return f" Left of {a.target.name}"
    if isinstance(a, RightOf):
        return f" Right of {a.target.name}"
    if isinstance(a, AboveOf):
        return f" Above of {a.target.name}"
    if isinstance(a, BelowOf):
        return f" Below of {a.target.name}"

def generate_xrandr_cmd(a: Action, active_output: list[Output]):
    if isinstance(a, Disable):
        return ["xrandr", "--output", a.output.name ,"--off"]
    if isinstance(a, Alone):
        cmd = ["xrandr", "--output", a.output.name ,"--primary", "--auto"]
        for o in active_output: 
            if o.name != a.output.name:
                cmd.append("--output")
                cmd.append(o.name)
                cmd.append("--off")
        return cmd
    if isinstance(a, Primary):
        return ["xrandr", "--output", a.output.name, "--auto" ,"--primary"]
    if isinstance(a, LeftOf):
        return ["xrandr", "--output", a.output.name, "--auto" ,"--left-of", a.target.name]
    if isinstance(a, RightOf):
        return ["xrandr", "--output", a.output.name, "--auto" ,"--right-of", a.target.name]
    if isinstance(a, AboveOf):
        return ["xrandr", "--output", a.output.name, "--auto" ,"--above", a.target.name]
    if isinstance(a, BelowOf):
        return ["xrandr", "--output", a.output.name, "--auto" ,"--below", a.target.name]
        
def map_modes(output_modes, mode_list, index_preferred):
    modes = []
    if len(output_modes) > 0:
        preferred_mode = output_modes[index_preferred-1]
        for i, mode in enumerate(mode_list):
            if mode.id in output_modes:
                id = mode.id
                width = mode.width
                height = mode.height
                preferred = True if (mode.id == preferred_mode) else False
                rates = []
                modes.append(Mode(id, width, height, preferred, rates))

    return modes

def get_outputs(window, d):
    outputs=[]
    resources = window.xrandr_get_screen_resources()._data
    primary = window.xrandr_get_output_primary().output
    modes_list = resources['modes']
    for output in resources['outputs']:
        id = int("%d" % (output, ))
        output_info = d.xrandr_get_output_info(output, resources['config_timestamp'])
        name = output_info.name
        is_primary = True if (primary == id) else False
        is_connected = True if (output_info.connection == 0) else False
        is_active = False if (output_info.crtc == 0) else True
        num_preferred = output_info.num_preferred

        print(output_info.__dict__)
        output_modes = map_modes(output_info.modes, modes_list, num_preferred)

        outputs.append(Output(id, name, is_primary, is_connected, is_active, output_modes))

    return list(reversed(sorted(outputs, key=lambda o: (o.isPrimary, o.name))))

# icon from NotoSansMono Nerd Font (see rofi theme)
def output_display(output): 
    name = output.name
    display_name = name if (output.isPrimary == False) else f"{name}*"
    if name.startswith("eDP") or name.startswith("e-DP"):
        return f" {display_name}"
    else: 
        return f" {display_name}"
    

def rofi_cmd(title, nb_lines):
    return [
        "rofi", 
        "-dmenu", 
        "-i", 
        "-lines", str(nb_lines), 
        "-p", title, 
        "-theme", "~/.config/rofi/monitor-switcher.rasi"
    ]

def run_rofi(title, menu_dic):
    cancel_key=" Cancel"
    menu_dic[cancel_key]= None

    kwargs = {}
    kwargs['stdout'] = subprocess.PIPE
    kwargs['universal_newlines'] = True

    cmd = rofi_cmd(title, len(menu_dic))
    input = "\n".join(str(x) for (x) in menu_dic.keys())

    #print(f"CMD {cmd}")
    #print(f"Input {input}")
    result = subprocess.run(cmd, input=input, **kwargs)

    #print(result.returncode)
    if result.returncode == 0:
        selection=result.stdout.strip("\n")
        #print(selection)
        if selection == cancel_key:
            sys.exit("Cancel")
        else:
            return menu_dic[selection]
    else:
        sys.exit("Cancel")

def select_output(connected_outputs):
    
    menu_dic=dict()
    for o in connected_outputs:
        menu_dic[output_display(o)] = o

    return run_rofi("Select output", menu_dic)


def active_different_filter(candidate: Output, current: Output):
    return candidate.name != selected_output.name and candidate.isActive == True

def select_enable_action(connected_outputs, selected_output):
    actions = [
        Alone(selected_output)
    ]

    for o in connected_outputs:
        if o.name != selected_output.name and o.isActive == True:
            actions.append(RightOf(selected_output, o))
            actions.append(LeftOf(selected_output, o))
            actions.append(AboveOf(selected_output, o))
            actions.append(BelowOf(selected_output, o))

    menu_dic=dict()
    for a in actions:
        menu_dic[get_action_key(a)] = a
    
    return run_rofi("Select Action", menu_dic)


def select_disable_action(connected_outputs, selected_output):
    actions = [
        Disable(selected_output),
        Alone(selected_output)
    ]
    if not selected_output.isPrimary:
        actions.append(Primary(selected_output))

    for o in connected_outputs:
        if o.name != selected_output.name and o.isActive == True:
            actions.append(RightOf(selected_output, o))
            actions.append(LeftOf(selected_output, o))
            actions.append(AboveOf(selected_output, o))
            actions.append(BelowOf(selected_output, o))

    menu_dic=dict()
    for a in actions:
        menu_dic[get_action_key(a)] = a
    
    return run_rofi("Select Action", menu_dic)

pp = pprint.PrettyPrinter(indent=4)
d = display.Display()
s = d.screen()
window = s.root.create_window(0, 0, 1, 1, 1, s.root_depth)

outputs = get_outputs(window, d)

connected_outputs = list(filter(lambda o: o.isConnected, outputs))
active_outputs = list(filter(lambda o: o.isActive, connected_outputs))

selected_output = select_output(connected_outputs)
print(f"Selected output {selected_output}")

action = None
if selected_output.isActive == True:
    action = select_disable_action(connected_outputs, selected_output)
    print(f"Action {action}")

else:
    action = select_enable_action(connected_outputs, selected_output)
    print(f"Action {action}")


xrandr_cmd = generate_xrandr_cmd(action, active_outputs)

kwargs = {}
kwargs['stdout'] = subprocess.PIPE
kwargs['universal_newlines'] = True

print(f"Xrandr CMD {xrandr_cmd}")
result = subprocess.run(xrandr_cmd, **kwargs)
print(result.returncode)
print(result.stdout)