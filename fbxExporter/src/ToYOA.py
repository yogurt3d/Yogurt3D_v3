import sys
import os
from FbxCommon import *
import glo
import defs


SIGNED_INT = 'i'
UNSIGNED_INT = 'I'
SIGNED_SHORT = 'h'
UNSIGNED_SHORT = 'H'
SIGNED_CHAR = 'b'
FLOAT = 'f'
DOUBLE = 'd'

def ToYOA(lSdkManager, lScene):
    
    
    if not glo.y3d:
        lResult = LoadScene(lSdkManager, lScene, os.path.join(glo.FBXPath, glo.FBXName))
        
        RootNode = lScene.GetRootNode()
        defs.EvalNode2Child(RootNode)
        defs.EvalRootBoneName('RootNode')
    
    
        if len(glo.RootBoneName) == 0:
            print "\n\n------------     \nToYOA(): NO SKELETON DETECTED in the Scene.\n------------\n"
            return
    
        lNode = lScene.GetRootNode()
        defs.EvaluateBoneMap(lNode, lNode)
    
        defs.DisplayHierarchy(lScene)
        


    
    if len(glo.RootBoneName) == 0:
        print "\n\n------------     \nToYOA(): NO SKELETON DETECTED in the Scene.\n------------\n"
        return
    
    
    nbAnimStack = lScene.GetSrcObjectCount(FbxAnimStack.ClassId)

    fps = FbxTime()
    fps = fps.GetFrameRate(lScene.GetGlobalSettings().GetTimeMode())
    print "fps", fps
    print "nbAnimStack =" , nbAnimStack
    if nbAnimStack == 0:
        print "\nNo Animation Stacks found. Aborting DisplayAnimation()..."
        print " Aborting ..."
        sys.exit(0)
        
    if nbAnimStack > 1:
        print "\n nbAnimStack =", nbAnimStack 
        print " ToYOA.py doesn't admit more than 1 AnimStacks."
        print " Aborting ..."
        sys.exit(0)
    
    lAnimStack = lScene.GetSrcObject(FbxAnimStack.ClassId, 0)  
    #lAnimLayer = lAnimStack.GetSrcObject(FbxAnimLayer.ClassId) # (FbxAnimLayer.ClassId, 7) ??
    #nbAnimLayers = lAnimStack.GetSrcObjectCount(FbxAnimLayer.ClassId)
    #print "nbAnimLayers", nbAnimLayers
    for a in range(1):
        # print "AnimationStack: Stack #", a + 1, "/", nbAnimStack
        lAnimStack = lScene.GetSrcObject(FbxAnimStack.ClassId, a)
        yoaFileName  = AnimationStack(lAnimStack, fps, lScene)
        defs.LZMACompression(yoaFileName, glo.outputFolder + "/" + glo.FBXName + '.yoa')


        

def AnimationStack(pAnimStack, fps, pScene):
    
    #print " Safak GetTimeMode()", pScene.GetGlobalSettings().GetTimeMode()
    #print " Safak GetDuration()", pAnimStack.GetReferenceTimeSpan().GetDuration().GetFrameCount(pScene.GetGlobalSettings().GetTimeMode())
    #print " Safak GetStart()", pAnimStack.GetReferenceTimeSpan().GetStart().GetFrameCount(pScene.GetGlobalSettings().GetTimeMode())
    #print " Safak GetStop()", pAnimStack.GetReferenceTimeSpan().GetStop().GetFrameCount(pScene.GetGlobalSettings().GetTimeMode())
    
    frameCount = pAnimStack.GetReferenceTimeSpan().GetStop().GetFrameCount(pScene.GetGlobalSettings().GetTimeMode())
    print "frameCount", frameCount
    pYoaFile, yoaFileName = WriteHeader(frameCount, fps)
    
    WriteBoneName(pScene.GetRootNode(), pYoaFile, yoaFileName)
    
    lTime = FbxTime()
    for f in range(frameCount):
        print "\n.......................\n  frame no =", f, "/", frameCount - 1, "\n.......................\n"
        lTime.SetSecondDouble(f / fps)
        TraverseChildren(pScene.GetRootNode(), pScene, lTime, pYoaFile, yoaFileName)
    pYoaFile.close()
    return yoaFileName;


def TraverseChildren(pNode, pScene, lTime, pYoaFile, yoaFileName):
    
    if isinstance(pNode.GetNodeAttribute(), FbxSkeleton):
        WriteYoa(pScene, pNode, lTime, pYoaFile, yoaFileName)
        
    for i in range(pNode.GetChildCount()):
        TraverseChildren(pNode.GetChild(i), pScene, lTime, pYoaFile, yoaFileName)
    
    return


def WriteHeader(frameCount, fps):
    from array import array
    
    yoaFileName = glo.outputFolder + "/" + glo.FBXName + '_uncompressed.yoa'
    pYoaFile = open(yoaFileName, 'wb')
    
    array(UNSIGNED_SHORT, [8]).tofile(pYoaFile)           # (=len("Yogurt3D"))
    uString = u'Yogurt3D'.encode('utf-8')          
    pYoaFile.write(uString)                               # _exportType (="Yogurt3D")
    array(SIGNED_SHORT, [3]).tofile(pYoaFile)             # version (=3)
    
    array(SIGNED_SHORT, [1]).tofile(pYoaFile)             # type:uint (=0,1)
    uString = u'3dsMax 2010'.encode('utf-8')
    array(SIGNED_SHORT, [len(uString)]).tofile(pYoaFile)  # len("3dsMax 2010")
    pYoaFile.write(uString)                               # exporter:String (="3dsMax 2010")
    
    array(SIGNED_SHORT, [len(glo.bone2Parent)]).tofile(pYoaFile)     # _boneCount:int
    array(SIGNED_SHORT, [frameCount]).tofile(pYoaFile)    # _frameCount:int
    array(SIGNED_SHORT, [int(fps)]).tofile(pYoaFile)      # _frameRate:int
    
    return pYoaFile, yoaFileName


def WriteBoneName(pNode, pYoaFile, yoaFileName):
    from array import array
    
    if isinstance(pNode.GetNodeAttribute(), FbxSkeleton):
        uString = pNode.GetName().encode('utf-8')
        array(SIGNED_SHORT, [len(uString)]).tofile(pYoaFile)  # len(pNode.GetName())
        pYoaFile.write(uString)                               # _boneList.push(_value.readMultiByte(nameLength, "utf-8"))
        
        
    for i in range(pNode.GetChildCount()):
        WriteBoneName(pNode.GetChild(i), pYoaFile, yoaFileName)
    
    return
    

def WriteYoa(pScene, pNode, pTime, pYoaFile, yoaFileName):
    """WriteYoa() is called by TraverseChildren() for each FbxSkeleton pNode."""
    from array import array
    
    lMatrix = pNode.EvaluateGlobalTransform(pTime, FbxNode.eSourcePivot, False, True)
    """   Compute parentMatrix   """
    #print "RootBoneName: ", glo.RootBoneName 
    if pNode.GetName() == glo.RootBoneName: 
        parentMatrix = FbxAMatrix()
        parentMatrix.SetIdentity()
        
    else:
        parentBone = pNode.GetParent()
        
        while not isinstance(parentBone.GetNodeAttribute(), FbxSkeleton):
            parentBone = parentBone.GetParent()
            
        parentMatrix = parentBone.EvaluateGlobalTransform(pTime, FbxNode.eSourcePivot, False, True)
    
    lMatrix = parentMatrix.Inverse() * lMatrix
    
    MT = [lMatrix.GetT()[0], lMatrix.GetT()[1], lMatrix.GetT()[2]] 
    MQ = [lMatrix.GetQ()[3], lMatrix.GetQ()[0], lMatrix.GetQ()[1], lMatrix.GetQ()[2]]
    MS = [lMatrix.GetS()[0], lMatrix.GetS()[1], lMatrix.GetS()[2]]
    
    #print "pNode.GetName() ", pNode.GetName()
    #print "      MT", MT
    #print "      MQ", MQ
    
    MT_array = array(FLOAT, MT)
    MQ_array = array(FLOAT, MQ)
    MS_array = array(FLOAT, MS)
    
    MT_array.tofile(pYoaFile)                # translation
    MQ_array.tofile(pYoaFile)                # rotation
    MS_array.tofile(pYoaFile)                # scale
    
    return


if __name__ == '__main__':
    from time import time
    start = time()
    
    ToYOA()
    
    T = time() - start
    minutes = int(T / 60)
    sec = T % 60
    print "Time Elapsed ...", minutes, "mins", sec, "secs"
    sys.exit(0)


    




