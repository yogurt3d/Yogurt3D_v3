"""
Usage:
    python setup.py py2exe
"""

from distutils.core import setup
import py2exe
import sys

APP = ['main.py']
DATA_FILES = []
OPTIONS = {
            "py2exe":{
            "dll_excludes": ["MSVCP90.dll","WSOCK32.dll","KERNEL32.dll","USER32.dll","SHELL32.dll","ADVAPI32.dll","GDI32.dll"],
            'includes': ['sip','psd_tools','fbx','PIL','pylzma']
            }
        }
setup(options=OPTIONS, console=APP)

