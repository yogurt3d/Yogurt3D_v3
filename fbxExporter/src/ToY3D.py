#!/usr/bin/env python
# encoding: utf-8
"""

Created by Safak Ozkan on 2012-12-26.
Copyright (c) 2012 __MyCompanyName__. All rights reserved.

"""


import sys
import os
from defs import *
from FbxCommon import *
import glo
import wx
import re
from ToYOA import *



def ToY3D(lSdkManager, lScene):
    
    # print "glo.FBXPath", glo.FBXPath
    # print "glo.FBXName", glo.FBXName
    
    # Prepare the FBX SDK and Load the Scene
    lSdkManager, lScene = InitializeSdkObjects()
    
    path = os.path.join(glo.FBXPath, glo.FBXName)
    lResult = LoadScene(lSdkManager, lScene, path)
        
    
    DisplayHierarchy(lScene)

    lNode = lScene.GetRootNode()
    EvaluateBoneMap(lNode, lNode)
    
    #if len(glo.bone2Parent) > 0:
    #    print "\n\n---------\nglo.bone2Parent{}\n---------\n"
    #    for key in glo.bone2Parent:
    #        print "                ", key, ":" , glo.bone2Parent[key]
    
    RootNode = lNode
    EvalNode2Child(RootNode)
    
    #print("\n\n---------\nglo.node2Child{}\n---------\n")
    #for key in glo.node2Child:
    #   print "                ", key, ": ", glo.node2Child[key]
    #print ""
    
    
    # Traverse Mesh
    for i in range(lNode.GetChildCount()):
        DisplayNodeContent(lNode.GetChild(i), lSdkManager, lScene)
    #
        
    TextureFiles()
    
    
    return lSdkManager, lScene

    
    

def cdDotDot(path):
    
    occurences = [m.start() for m in re.finditer(glo.s, path)] # returns [0, 6, 17, 29, 40, 51, 55]
    L = len(occurences) # 7
    return path[0 : occurences[L - 1]]
