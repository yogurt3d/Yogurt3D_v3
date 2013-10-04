#!/usr/bin/env python
# encoding: utf-8

"""
main.py:

Created by Safak Ozkan on 2012-12-26.
Copyright (c) 2012 __MyCompanyName__. All rights reserved.


Install the following Libraries and modules for python 2.6:
		Python26  (then update PATH C:\Python26;C:\Python26\Scripts;)
		Python FBX SDK (add teh following to s�te-packages: FbxCommon.py, fbx.pyd, sip.pyd)
		easy_install (to help with installation of modules)
		pylzma
		psd_tools
		PIL
		wx

---------- ---------- ---------- ---------- ---------- ----------

Building the Mac OS X .app file: (http://svn.pythonmac.org/py2app/py2app/trunk/doc/index.html#create-a-setup-py-file)

        py2applet --make-setup main.py
        rm -rf build dist
        python setup.py py2app -A

Then run it:

        ./dist/main.app/Contents/MacOS/main
        open -a dist/main.app
        open -a Console
        
Build for deployment:    

        python setup.py py2app
        
---------- ---------- ---------- ---------- ---------- ----------

Running the script on terminal:

        python main.py ../fbx/Female_Body_nbAnimLayer=2.fbx 1 1
        
N.B. asking for sys.argv on the python terminal returns ['main.py', '../fbx/Female_Body_nbAnimLayer=2.fbx', '1', '1']
     sys.argv[1] : the relative path and name of the FBX file
     sys.argv[2] : pass '1' to create y3d file
     sys.argv[3] : pass '1' to create yoa file
     
"""

import sys
import os
import string
from defs import *
from FbxCommon import *
import glo
import wx
import re
from ToYOA import *
from ToY3D import *

wildcard = "Python source (*.py)|*.py|" \
            "All files (*.*)|*.*"

def main():
    
    cwd = os.getcwd() #"/Users/ozkansafak/Source Code/YogurtTech/fbx_to_y3d/src"
    fileName = sys.argv[1]
    
    if len(sys.argv) == 2:
        sys.argv.append("1")
        sys.argv.append("1")
    if len(sys.argv) == 3:
        sys.argv.append("1")
    
    if sys.argv[2] == "1":
        # print "Set glo.y3d = True"
        glo.y3d = True
    if sys.argv[3] == "1":
        # print "Set glo.yoa = True"
        glo.yoa = True
    

    glo.FBXName = os.path.basename(fileName) # "Female_Body_nbAnimLayer=2.fbx"
    print "File Name: ", glo.FBXName
    glo.FBXPath = string.replace(fileName, glo.FBXName, "") # '/Users/ozkansafak/Source Code/YogurtTech/fbx_to_y3d/fbx'
   
    fileName, fileExtension = os.path.splitext(glo.FBXName)

    glo.outputFolder =  glo.FBXPath + fileName
    print "File Path: ", glo.FBXPath
    print "Output folder: ", glo.outputFolder, "\n"

    sys.stdout.flush()
    
    start = time()
    lSdkManager, lScene = InitializeSdkObjects()
    if glo.y3d == True:
        lSdkManager, lScene = ToY3D(lSdkManager, lScene)
        
    if glo.yoa == True:
        ToYOA(lSdkManager, lScene)

    if os.path.exists( glo.outputFolder + '.fbm'): # the Texture Files Folder
        import shutil
        shutil.rmtree( glo.outputFolder + '.fbm')
        
    lSdkManager.Destroy()
    return start
        


    #----------------------------------------------------------------------


if __name__ == '__main__':
    start = main()
    
    Timer(start, "The TOTAL")
    sys.exit(0)
    
    