###############################################################################
#####################   make script executable bin   ##########################
"""
# How to make your 'poop.py' script executable bin

1. put this at the top of script:
    #!/usr/bin/env python

2. `chmod +x poop.py`  # you are already finished at this step

3. ln -sf poop.py dir/thats/in/PATH/poop

# Call like you would other bins from cli:
$ poop
"pooping in the toilet"

$ poop airplane
"pooping in the airplane"

"""


###############################################################################
######################    Numpy, restore shape      ###########################

def restore_axis_shape(x, ax, d):
    """ Restores an axis ax that was reduced from x
    to it's original shape d
    Just a wrapper for the tedious
    broadcast_to(expand_dims(...)...) op

    Assumes
    -------
        x.ndim >= 1
        ax : int  (only one dim being restored through ax)
    """
    assert x.ndim >= 1 and isinstance(ax, int)

    # Restore shape
    bcast_shape = x.shape[:ax] + (d,) + x.shape[ax:]
    return np.broadcast_to(np.expand_dims(x, ax), bcast_shape)


###############################################################################
#######################       Relative imports      ###########################
import os
import sys

# TO GET TRUE FILE DIRECTORY PATH, USE:
os.path.abspath(os.path.dirname(__file__))
#----> EVERYTHING ELSE FUCKED, does pathing from caller path

"""
sandbox
├── data
│   ├── dataset.py
│   └── Iris
│       ├── iris_info.txt
│       ├── iris.npy
│       ├── iris_test.npy
│       └── iris_train.npy
│  
├── deep_learning
│   ├── CrossVal.ipynb
│   ├── functions.py
│   ├── initializers.py
│   ├── layers.py
│   ├── network.py
│   ├── optimizers.py
│   ├── train.py
│   └── utils.py
└── nature
    └── GA.py
"""

# GA <---- dataset
#=======================
fpath = os.path.abspath(os.path.dirname(__file__)) # /home/evan/Projects/AI-Sandbox/sandbox/nature
path_to_dataset = fpath.rstrip(fpath.split('/')[-1]) + 'data'
sys.path.append(path_to_dataset)


###############################################################################
########################         ARGPARSE          ############################


import argparse

P = argparse.ArgumentParser()

#==============================================================================
# add_args : the rules, the format
#==============================================================================


#------------------------------------------------------------------------------
#                           Optional args: '-arg'
#------------------------------------------------------------------------------
# Optional arguments
# ========================================

# "optional" args must be preceded by the '-' character
#   - any arguments following the optionals are considered "positional"
#----> The parser has no issue not receiving any vals for optionals
P.add_args('-f', '--foo', help='my_foo') # -f, --foo are optional, help positional

#  OKAY:
# >>> P.parse_args([])
# Namespace(foo=None)
# >>> P.parse_args(['-f', 'bar'])
# Namespace(foo='bar')

#------------------------------------------------------------------------------
#                           Required args: 'arg'
#------------------------------------------------------------------------------
# Required arguments
# ========================================
# Required args, on the other hand, are not preceded by '-', and must
# receive a value. They cannot follow optional args either.

P.add_args('-f', '--foo', help='my_foo')
P.add_args('poop')

#===== BAD
# >>> P.parse_args([])
#   usage: aparse.py [-h] [-f FOO] poop
#   aparse.py: error: the following arguments are required: poop
#   An exception has occurred, use %tb to see the full traceback.
#===== BAD
# >>> P.parse_args(['-f', 'bar'])
#   usage: aparse.py [-h] [-f FOO] poop
#   aparse.py: error: the following arguments are required: poop
#   An exception has occurred, use %tb to see the full traceback.

#==== OKAY:
# >>> P.parse_args(['diarrhea'])
# Namespace(poop='diarrhea')
#==== OKAY:
# >>> P.parse_args(['smells graet', '--foo', '80085'])
# Namespace(poop='smells graet', foo='80085')


#------------------------------------------------------------------------------
#                   Booleans in argparse:
#                      action='store_true'
#------------------------------------------------------------------------------
# Arparse does not really support type=bool,
#  BUT, you can get bool values directly, without type interp
#  through the action='store_true' flag
P.add_args('-f', '--foo', help='my_foo')
P.add_args('-d', '--use_dropout', action='store_true')

#==== OKAY:
# >>> vars(P.parse_args(['-d']))
#    {'foo': None, 'use_dropout': True}

# >>> vars(P.parse_args([]))
#    {'foo': None, 'use_dropout': False}

# >>> vars(P.parse_args(['-f', '123']))
#    {'foo': '123', 'use_dropout': False}

# >>> vars(P.parse_args(['--use_dropout']))
#    {'foo': None, 'use_dropout': True}

#------------------------------------------------------------------------------
#                   ARGPARSE FROM A CONFIG FILE
#           get args and defaults from a yaml or json file
#------------------------------------------------------------------------------

class Parser:
    def __init__(self, config_path=config_path):
        self.argparser = argparse.ArgumentParser()
        self.config_path = config_path
        self.process_config()

    def process_config(self):
        with open(self.config_path) as conf:
            config = yaml.load(conf)
            for key, val in config.items():
                self.argparser.add_argument(f'--{key}', default=val)

    def parse(self):
        self.args = self.argparser.parse_args()
        return self.args




###############################################################################
########################       MY DECORATORS       ############################

# Nifty decorator to both comment and prevent running unfinished funcs
def TODO(f):
    """ Serves as a convenient, clear flag for developers and insures
        wrapee func will not be called """
    @wraps(f)
    def not_finished():
        print('\n  {} IS INCOMPLETE'.format(f.__name__))
    return not_finished


def NOTIMPLEMENTED(f):
    """ Like TODO, but for functions in a class
        raises error when wrappee is called """
    @wraps(f)
    def not_implemented(*args, **kwargs):
        func_class = args[0]
        f_class_name = func_class.get_class_name()
        f_name = f.__name__
        msg = '\n  Class: {}, function: {} has not been implemented!\n'
        print(msg.format(f_class_name, f_name))
        raise NotImplementedError
    return not_implemented


def INSPECT(f):
    """ Will interupt code execution and enter an interactive shell
    where you can test out the input/output values.

    (it's even better just to put that code.interact line directly
    before the line in the actual function you want to inspect)
    """
    @wraps(f)
    def inspector(*args, **kwargs):
        print('\n Inspecting function: <{}>'.format(f.__name__))
        x = args
        y = kwargs
        z = f(*args, **kwargs)
        code.interact(local=dict(globals(), **locals())) # DEBUGGING-use
        return z
    return inspector



# Class method decorators
#------------------------
# Yes, that's right, they can access/mutate class instances through self!

def preserve_default(method):
    """ always saves method inputs to fn_vars """
    @wraps(method)
    def preserve_args(self, *args, **kwargs):
        self.fn_vars = args
        return method(self, *args, **kwargs)
    return preserve_args


def preserve(inputs=True, outputs=True):
    """ Preserve inputs and outputs to fn_vars
    Also provides kwargs for individual cases
     - sometimes you only need inputs, or outputs
       this decorator allows you to choose which
       parts of the function you want to preserve
    """
    def inner_preserve(method):
        """ outer preserve is like a decorator to this
        decorator
        """
        @wraps(method)
        def preserve_args(self, *args, **kwargs):
            my_args = ()
            if inputs:
                my_args += args
            ret = method(self, *args, **kwargs)
            if outputs:
                my_args += (ret,)
            self.fn_vars = my_args
            return ret
        return preserve_args
    return inner_preserve


###############################################################################
########################       Special chars       ############################

py_lits = {'Bell a':'\a', 'Backspace b':'\b', 'Formfeed f':'\f',
           'Linefeed n':'\n', 'Carriage Return r':'\r',
           'Horizontal tab t':'\t', 'Vertical tab v':'\v'}

# Difference Between
#  - newline char "\n"
#  - carriage return char "\r"
#=================================================
"""
# Both are control characters that control printing/write of text.
  * They both move the 'cursor' or RW pointer wrt the console,
    or whatever output device is being used
BUT
* '\n' moves the cursor to the *next line* of the console
* '\r' moves the cursor to the *BEGINNING* of the current line in console
"""
NEWLINE = '\n'
print("Hello \nWorld")
'Hello'
'World'

print("Hell\no World")
'Hell'
'o World'


CARRIAGE_RETURN = '\r'
print("Hello \rWorld")
'World'

print("Hell\ro World")
'o World'

#========== Using '\r' to make a simple animation

import time
import sys

animation = '|/-\|'

for i in range(100):
    time.sleep(0.1)
    sys.stdout.write("\r" + animation[i % len(animation)])
    sys.stdout.flush()
print('End!')


###############################################################################
########################     Access parent attr    ############################

class Foo:
    def __init__(self):
        self._cache = None

    @property
    def cache(self):
        if self._cache is not None:
            tmp_obj = self._cache
            self._cache = None
            return tmp_obj
        #return self._cache

    @cache.setter
    def cache(self, x):
        self._cache = x

    def boo(self, x):
        print(f'BOO! haha, got {x} thx')
        self.cache = x

    def poo(self):
        print('going poop, you can have your x back')
        x = self.cache
        return x



class Baz(Foo):
    @property
    def cache(self):
        foo_cache = Foo.cache.fget(self)
        if foo_cache is not None:
            return foo_cache

    @cache.setter
    def cache(self, x):
        Foo.cache.fset(self, x)
        self.xlen = len(x)

    def bar(self):
        xlen = self.xlen
        self.xlen = None
        print(f'in bar, here is your silly xlen: {xlen}')
        return xlen


###############################################################################
#######################     f-string formatting     ###########################
""" In general, f-string format specifiers are the same as '{}'.format() """

# Floating-point
#------------------
my_float = 2**(1/2)
print(f'{my_float}')
# 1.4142135623730951

print(f'{my_float: .3f}')
# 1.414


# Strings
#----------------
hw = 'Hello world'
w  = 'world'
#==== no formatting
print(f'{hw}\n{w}')
'Hello world'
'world'

#==== with formatting
print(f'{hw:>12}\n{w:>12}')
' Hello world'
'       world'

###############################################################################
#######################        arg parsers          ###########################

# Fire
# ====
from fire import Fire

def neg(num):
    return -num

def poop(location='floor'):
    return f'poop on the {location}'

if __name__ == '__main__':
  # Fire()      # both neg and poop available at CLI, but can only use one :[
  # Fire(poop)  # 'fire_example.py airplane' ---> `poop on the airplane`

#====

###############################################################################
#######################             Misc            ###########################

# Get current date
#-------------------
import datetime
datetime.datetime.now().date()


# Handy dict
#------------------
class AttrDict(dict):
    # just a dict mutated/accessed by attribute instead index
    # NB: not pickleable
    __getattr__ = dict.__getitem__
    __setattr__ = dict.__setitem__
    __delattr__ = dict.__delitem__



# It turns out Python actually...has an array?
# --------------------------------------------
# And it's std lib...
from array import array

"""
class array(builtins.object)
 |  array(typecode [, initializer]) -> array
 |
 |  Return a new array whose items are restricted by typecode, and
 |  initialized from the optional initializer value, which must be a list,
 |  string or iterable over elements of the appropriate type.
 |
 |  Arrays represent basic values and behave very much like lists, except
 |  the type of objects stored in them is constrained. The type is specified
 |  at object creation time by using a type code, which is a single character.
 |  The following type codes are defined:
 |
 |      Type code   C Type             Minimum size in bytes
 |      'b'         signed integer     1
 |      'B'         unsigned integer   1
 |      'u'         Unicode character  2 (see note)
 |      'h'         signed integer     2
 |      'H'         unsigned integer   2
 |      'i'         signed integer     2
 |      'I'         unsigned integer   2
 |      'l'         signed integer     4
 |      'L'         unsigned integer   4
 |      'q'         signed integer     8 (see note)
 |      'Q'         unsigned integer   8 (see note)
 |      'f'         floating point     4
 |      'd'         floating point     8
 |
 |  NOTE: The 'u' typecode corresponds to Python's unicode character. On
 |  narrow builds this is 2-bytes on wide builds this is 4-bytes.
 |
 |  NOTE: The 'q' and 'Q' type codes are only available if the platform
 |  C compiler used to build Python supports 'long long', or, on Windows,
 |  '__int64'.

# Essentially all the same operations as normal collection data structures
#  like list. Just that it requires type specified in init.
#  Obviously faster ops for certain things, such as arr.count

"""