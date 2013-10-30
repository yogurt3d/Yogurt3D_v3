# 2013.01.09 18:52:41 EET
# to do list:
# change index to indexList
# compare len(lControlPoints) to len(vertexList) (or similarly indexCount and vertexCount)

import sys
import os
from fbx import *
from FbxCommon import *
import glo
import inspect

import pylzma, struct
from time import time
from psd_tools import PSDImage

SIGNED_INT = 'i'
UNSIGNED_INT = 'I'
SIGNED_SHORT = 'h'
UNSIGNED_SHORT = 'H'
SIGNED_CHAR = 'b'
FLOAT = 'f'
DOUBLE = 'd'


def DisplayNodeContent(pNode, lSdkManager, lScene):
    pNode.GetName()
    if pNode.GetNodeAttribute() == None:
        #print "DisplayNodeContent: NULL Node Attribute"
        pass
    elif pNode.GetNodeAttribute().GetAttributeType() == FbxNodeAttribute.eMesh:
        DisplayBoneAndMesh(pNode.GetName(), pNode.GetNodeAttribute(), lSdkManager, lScene)

    for i in xrange(pNode.GetChildCount()):
        DisplayNodeContent(pNode.GetChild(i), lSdkManager, lScene)

    return


def DisplayBoneAndMesh(nodeName, lMesh, lSdkManager, pScene):
    # print("\n\n---------\nDisplayNodeContent: Mesh Name: ",  nodeName, "\n---------\n")

    if not lMesh.IsTriangleMesh():
        geomConv = FbxGeometryConverter(lSdkManager)
        lMesh = geomConv.Triangulate(lMesh, 0)
        # print ".... MESH TRIANGULATION SUCCESSFUL\n"
    vertexConsolidated, normalConsolidated, index, uvConsolidated = GetMeshList(lMesh, nodeName)

    vertex1by3N, normal1by3N = FoldInto1D(vertexConsolidated, normalConsolidated)

    ComputeNodeWeightsAndIndices(lMesh, vertex1by3N) # computes glo.bone2Params{}

    pY3dUncompressedFile, y3dUncompressedFileName, y3dFileName = WriteHeader(nodeName, len(vertex1by3N) / 3, len(index),
                                                                             len(uvConsolidated))

    # if the mesh is animated:
    if glo.animFlag == 1:
        EvalRootBoneName('RootNode')
        # print "Entering WriteY3dBone, RootBoneName =", glo.RootBoneName
        RootBoneName = glo.RootBoneName
        WriteY3dBone(RootBoneName, pY3dUncompressedFile)

    WriteY3dMesh(y3dUncompressedFileName, lMesh, pY3dUncompressedFile, vertex1by3N, normal1by3N, index, uvConsolidated)

    LZMACompression(y3dUncompressedFileName, y3dFileName)

    return


def LZMACompression(inputFileName, outputFileName):
    import pylzma, struct

    i = open(inputFileName, 'rb')
    o = open(outputFileName, 'wb')
    i.seek(0)
    s = pylzma.compressfile(i, eos=1)

    statinfo = os.stat(inputFileName)

    result = s.read(5)
    # size of uncompressed data
    result += struct.pack('<Q', statinfo.st_size)
    # compressed data
    result += s.read()

    o.write(result)
    o.close()
    i.close()

    oSize = float(os.path.getsize(outputFileName))
    iSize = float(os.path.getsize(inputFileName))

    os.remove(inputFileName)



    # print "%s                  %5.1f %s %5.1f %s                   %s%5.2f" % \
    # ("LZMACompression():\n", iSize/1000, "KB -->", oSize/1000, "KB\n", "Compression Ratio = ", iSize/oSize)
    # print 'Written to "', outputFileName, '" -- Removed according uncompressed file'
    print outputFileName, "\n"
    sys.stdout.flush()
    return


def EvalRootBoneName(pName):
    #print "glo.node2Child[pName]", pName, glo.node2Child[pName]
    if isinstance(glo.node2Child[pName][0], FbxSkeleton):
        glo.RootBoneName = pName
        #print "EvalRootBoneName() found RootBoneName =", glo.RootBoneName
        return

    for key in glo.node2Child[pName][1:]:
        EvalRootBoneName(key)


def GetMeshList(pMesh, nodeName):
    lPolygonCount = pMesh.GetPolygonCount()
    lControlPoints = pMesh.GetControlPoints()
    vertexList = []
    normalList = []
    indexList = []
    uvList = []
    uvSorted = []

    print "lPolygonCount", lPolygonCount

    if pMesh.GetLayerCount() > 0:
        for l in xrange(pMesh.GetLayerCount()):
            leUV = pMesh.GetLayer(l).GetUVs()

            if leUV:
                uvList.append([])
                uvSorted.append([])

    normalvec = FbxVector4()

    # leUV = pMesh.GetLayer(1).GetUVs()
    # print  "GetDirectArray", leUV.GetDirectArray().GetAt(1)
    # print  "GetIndexArray", leUV.GetIndexArray().GetAt(1)


    """ Below is O(N)"""
    for i in xrange(lPolygonCount):

        for j in xrange(3):
            lGlobIndex = pMesh.GetPolygonVertex(i, j) # s.o. compare len(lControlPoints) to len(vertexList)
            vertex_xyz = [lControlPoints[lGlobIndex][0], lControlPoints[lGlobIndex][1], lControlPoints[lGlobIndex][2]]

            pMesh.GetPolygonVertexNormal(i, j, normalvec)
            normal_xyz = [normalvec[0], normalvec[1], normalvec[2]]

            vertexList.append(vertex_xyz)
            normalList.append(normal_xyz)

            for l in xrange(len(uvList)):
                leUV = pMesh.GetLayer(l).GetUVs()
                if leUV.GetMappingMode() == FbxLayerElement.eByPolygonVertex:
                    vertexId = i*3+j
                    if leUV.GetReferenceMode() == FbxLayerElement.eDirect:
                        uvVec = leUV.GetDirectArray().GetAt(vertexId)
                    elif leUV.GetReferenceMode() == FbxLayerElement.eIndexToDirect:
                        id = leUV.GetIndexArray().GetAt(vertexId)
                        uvVec = leUV.GetDirectArray().GetAt(id)
                elif leUV.GetMappingMode() == FbxLayerElement.eByControlPoint:
                    if leUV.GetReferenceMode() == FbxLayerElement.eDirect:
                        uvVec = leUV.GetDirectArray().GetAt(lGlobIndex)
                    elif leUV.GetReferenceMode() == FbxLayerElement.eIndexToDirect:
                        id = leUV.GetIndexArray().GetAt(lGlobIndex)
                        if id < leUV.GetDirectArray().GetCount():
                            uvVec = leUV.GetDirectArray().GetAt(id)

                uvList[l].append(uvVec[0])
                uvList[l].append(uvVec[1])

    """ Below is O(N)"""

    # for l in xrange(len(uvList)):
    #     print "var uvConsolidated" + str(l) + ":Array = ", uvList[l]




# .............................................................
    """ O(N . logN) sort-routine"""
    indices = SortVertexList(vertexList)

    inverseMap = []
    for i in xrange(len(indices)):
        inverseMap.append(0)


    normalSorted = []
    vertexSorted = []
    
    for i in indices:
        normalSorted.append(normalList[i])
        vertexSorted.append(vertexList[i])
    
        for l in xrange(len(uvList)):
            uvSorted[l].append(uvList[l][i * 2])
            uvSorted[l].append(uvList[l][i * 2 + 1])
    
    
    
    uvList = uvSorted
    normalList = normalSorted
    vertexList = vertexSorted

    # .............................................................
    ### Now evaluate indexList

    N = len(vertexList)
    g_index = 0
    indexList.append(0)

    """ Here is the previously O(N^2) part
        Now an O(N) algorithm"""

    if vertexList[0][0] == vertexList[1][0]:
        iP = 0
    else:
        iP = 1

    for i in xrange(1, N):
        """
        . . . . . . . . . . . . . . . . .
        \_______________________/ |
                  j               i
        
        If there exists a j < i, such that:
            vertex[j] = vertex[i] and  
            normal[j] = normal[i] and 
            uv[l][j]  = uv[l][i], for all l = 1,.. layerCount
        then 
            newPair = False
        """

        newPair = True

        for j in xrange(iP, i):

            # Check if all uv-values are identical between i and j.
            isUvSame = True

            for l in xrange(len(uvList)):
                if \
                    uvList[l][i * 2] != uvList[l][j * 2] or \
                    uvList[l][i * 2 + 1] != uvList[l][j * 2 + 1]:
                    isUvSame = False
                    break

            if isUvSame and \
                            vertexList[i][0] == vertexList[j][0] and \
                            vertexList[i][1] == vertexList[j][1] and \
                            vertexList[i][2] == vertexList[j][2] and \
                            normalList[i][0] == normalList[j][0] and \
                            normalList[i][1] == normalList[j][1] and \
                            normalList[i][2] == normalList[j][2]:
                indexList.append(indexList[j])
                newPair = False
                break
            # j-loop

        #print "newPair", newPair

        if newPair:
            iP = j
            g_index += 1
            indexList.append(g_index)
        # i-loop

    """
    vdummy = []
    idummy = []
    for i in range(len(indices)):
        vdummy.append(0) 
        idummy.append(indexList[i])

    for i in range(len(indices)):
        vdummy[indices[i]] = vertexList[i]

    vertexList = vdummy
    """

    vertexConsolidated = [vertexList[0]]
    normalConsolidated = [normalList[0]]
    uvConsolidated = []
    #if len(uvList) > 0: # .so. You don't need this line. Just delete it!
    for l in xrange(len(uvList)):
        uvConsolidated.append([])

    for l in xrange(len(uvList)):
        uvConsolidated[l].append(uvList[l][0])
        uvConsolidated[l].append(uvList[l][1])

    ind = indexList[0]
    ind1 = ind + 1
    for i in xrange(1, N):
        if indexList[i] == ind1:
            vertexConsolidated.append(vertexList[i])
            normalConsolidated.append(normalList[i])
            ind = indexList[i]
            ind1 = ind + 1
    
    for l in xrange(len(uvList)):
        ind = indexList[0]
        ind1 = ind + 1
        for i in xrange(1, N):
            if indexList[i] == ind1:
                i2 = i * 2
                uvConsolidated[l].append(uvList[l][i2])
                uvConsolidated[l].append(uvList[l][i2 + 1])
                ind = indexList[i]
                ind1 = ind + 1

    """Below algorithm runs O(N^2 . logN)
        :(
    """
    idummy =[]
    for i in xrange(len(indices)):
        inverseMap[indices[i]] = i
    
    for i in xrange(len(indices)):
        idummy.append(indexList[inverseMap[i]])
    
    indexList = idummy
    # print "var indexList:Array = ", indexList
    #
    # for l in xrange(len(uvConsolidated)):
    #     print "var uvConsolidated" + str(l) + ":Array = ", uvConsolidated[l]



    # print "    --> Some STATS about the VERTEX CONSOLIDATION:"
    # print "    --> len(vertexConsolidated)", len(vertexConsolidated)
    # print "    --> float(len(vertexList))/len(lControlPoints)  , float(len(vertexConsolidated))/len(lControlPoints)   --" , float(len(vertexList))/len(lControlPoints)  , float(len(vertexConsolidated))/len(lControlPoints)   

    #return (vertexConsolidated,
    # normalConsolidated,
    # indexList,
    # uvConsolidated)
    return (vertexConsolidated,
            normalConsolidated,
            indexList,
            uvConsolidated)


def SortVertexList(vertexList):
    x = []
    for elem in vertexList:
        x.append(elem[0])

    indices = sorted(range(len(x)), key=lambda k: x[k])

    return indices


def WriteHeader(nodeName, vertexCount, indexCount, uvCount):
    from array import array

    """
    .	Yogurt3D, UTF8 String
	.	version: 2bytes, short integer (3 ile baslayip 4-5 gidecez)
	.	type, 2bytes, short integer,
	.	0 - inanimate mesh
	.	1 - animated mesh
	.	2 - scene (set of inanimate meshes)
	.	3 - animation
	.	exporter: (Eg. 3dsMax 2010) UTF8 String
	.	upVector, 2 bytes, short integer, (0 - x, 1 - y, 2 - z)
	.	Vertex count, 4bytes, integer
	.	Indexcount, 4bytes, integer
	.	tangentsIncluded, 1 byte, boolean
	.	AABB data 24bytes (min.xyz, max.xyz)
	"""
    if not os.path.exists(glo.outputFolder):
        os.makedirs(glo.outputFolder)

    y3dUncompressedFileName = glo.outputFolder + glo.s + nodeName + '_Uncompressed.y3d'
    y3dFileName = glo.outputFolder + glo.s + nodeName + '.y3d'
    pY3dUncompressedFile = open(y3dUncompressedFileName, 'wb')

    array(UNSIGNED_SHORT, [8]).tofile(pY3dUncompressedFile)           # (=len("Yogurt3D"))
    uString = u'Yogurt3D'.encode('utf-8')
    pY3dUncompressedFile.write(uString)                               # _exportType (="Yogurt3D")
    array(SIGNED_SHORT, [3]).tofile(pY3dUncompressedFile)             # version (=3)

    # print "WriteHeader(): glo.animFlag =",glo.animFlag
    array(SIGNED_SHORT, [glo.animFlag]).tofile(pY3dUncompressedFile) # type:uint (=0,1)
    uString = u'3dsMax 2010'.encode('utf-8')
    array(SIGNED_SHORT, [len(uString)]).tofile(pY3dUncompressedFile)  # len("3dsMax 2010")
    pY3dUncompressedFile.write(uString)                               # exporter:String (="3dsMax 2010")
    array(SIGNED_SHORT, [2]).tofile(pY3dUncompressedFile)             # upVector:uint (="2")

    array(SIGNED_INT, [vertexCount]).tofile(pY3dUncompressedFile)     # vertexCount:int
    array(SIGNED_INT, [indexCount]).tofile(pY3dUncompressedFile)      # indexCount:int
    array(SIGNED_CHAR, [0]).tofile(pY3dUncompressedFile)              # tangentsIncluded:Boolean (=0, =False)

    array(SIGNED_SHORT, [uvCount]).tofile(pY3dUncompressedFile)       # uvCount:int 
    array(SIGNED_CHAR, [0]).tofile(pY3dUncompressedFile)
    array(FLOAT, [0, 0, 0, 0, 0, 0]).tofile(pY3dUncompressedFile)

    return pY3dUncompressedFile, y3dUncompressedFileName, y3dFileName


def WriteY3dBone(boneName, pY3dUncompressedFile):
    from array import array
    #print "start boneName, glo.node2Child[boneName] = ", boneName, glo.node2Child[boneName]

    if boneName not in glo.bone2Params:
        list = glo.node2Child[boneName][1:]
        # print "list ", list
        for ele in list:
            WriteY3dBone(ele, pY3dUncompressedFile)
        return

    MT, MQ, MS, parentBoneName, lIndices, lWeights, lIndexCount = glo.bone2Params[boneName]

    if parentBoneName == 'RootNode':
        boneCount = len(glo.bone2Parent.keys())
        array(SIGNED_SHORT, [boneCount]).tofile(pY3dUncompressedFile)   # (boneCount:int)
        # print " boneCount = ", boneCount, " being written to pY3dUncompressedFile."


    # lIndexCount (_boneIndicesCount) = no. of Control Points that have nonzero weights at bones[i].

    array(SIGNED_INT, [lIndexCount]).tofile(pY3dUncompressedFile)           # lIndexCount (_boneIndicesCount:int)

    MT_array = array(FLOAT, MT)
    MQ_array = array(FLOAT, MQ)
    MS_array = array(FLOAT, MS)

    MT_array.tofile(pY3dUncompressedFile)                # _bone.translation
    MQ_array.tofile(pY3dUncompressedFile)                # _bone.rotation
    MS_array.tofile(pY3dUncompressedFile)                # _bone.scale

    uString = unicode(boneName).encode('utf-8')
    array(SIGNED_SHORT, [len(uString)]).tofile(pY3dUncompressedFile)    # len(boneName)
    pY3dUncompressedFile.write(uString)                                 # boneName:String (=boneName)

    uString = unicode(parentBoneName).encode('utf-8')
    array(SIGNED_SHORT, [len(uString)]).tofile(pY3dUncompressedFile)   # len(parentBoneName)
    pY3dUncompressedFile.write(uString)                                 # parentBoneName:String (=bone.ParentName)

    if lIndexCount != 0:
        lIndices_array = array(SIGNED_INT, lIndices)
        print "Bone IndiceCount: ", len(lIndices_array), boneName
        lIndices_array.tofile(pY3dUncompressedFile)                     # _bone.indices

        lWeights_array = array(FLOAT, lWeights)
        lWeights_array.tofile(pY3dUncompressedFile)                     # _bone.weights

    for i in xrange(1, len(glo.node2Child[boneName])):
        WriteY3dBone(glo.node2Child[boneName][i], pY3dUncompressedFile)

    return


def WriteY3dMesh(y3dUncompressedFileName, pMesh, pY3dUncompressedFile, vertex1by3N, normal1by3N, index, uvConsolidated):
    from array import array

    """
    .	Vertex data, (xyz coords), 3 * 4bytes * vertexcount, float
	.	UV data, 2 * 4bytes * vertex count
	.	Normal data, 3 * 4bytes * vertex count
	.	tangent data, 3 * 4bytes * vertex count (if tangentsIncluded)
	.	Index data, 4 bytes * indice count, integer
	"""
    vertex_array = array(FLOAT, vertex1by3N)
    uv_array = []
    if len(uvConsolidated) > 0:
        for l in xrange(len(uvConsolidated)):
            uv_array.append([])

    for l in xrange(len(uv_array)):
        uv_array[l] = array(FLOAT, uvConsolidated[l])

    normal_array = array(FLOAT, normal1by3N)
    index_array = array(SIGNED_INT, index)
    vertex_array.tofile(pY3dUncompressedFile)
    print "Vertex Count: ", len(vertex_array) / 3
    for l in xrange(len(uv_array)):
        uv_array[l].tofile(pY3dUncompressedFile)

    normal_array.tofile(pY3dUncompressedFile)
    index_array.tofile(pY3dUncompressedFile)
    pY3dUncompressedFile.close()

    #print 'Written to "', y3dUncompressedFileName, '"'

    return


def FoldInto1D(vertexConsolidated, normalConsolidated):
    N = len(vertexConsolidated)
    vertex1by3N = [0] * 3 * N
    normal1by3N = [0] * 3 * N
    for i in xrange(N):
        vertex1by3N[i * 3 + 0] = vertexConsolidated[i][0]
        vertex1by3N[i * 3 + 1] = vertexConsolidated[i][1]
        vertex1by3N[i * 3 + 2] = vertexConsolidated[i][2]
        normal1by3N[i * 3 + 0] = normalConsolidated[i][0]
        normal1by3N[i * 3 + 1] = normalConsolidated[i][1]
        normal1by3N[i * 3 + 2] = normalConsolidated[i][2]

    return (vertex1by3N, normal1by3N)


def DisplayControlsPoints(pMesh):
    lControlPointsCount = pMesh.GetControlPointsCount()
    lControlPoints = pMesh.GetControlPoints()
    # print 'Vertex xyz coords, 3 * 4bytes * vertexcount, float'
    for i in xrange(lControlPointsCount):
        # print '%f %f %f\n' % (lControlPoints[i][0], lControlPoints[i][1], lControlPoints[i][2])
        pass

        # print ''


def WeightsCorrector(pMesh, lIndices, lWeights, vertex1by3N, lControlPoints, eps):
    """
    Input:  lIndices, lWeights, lControlPoints, vertex1by3N
    output: cIndices, cWeights
    """

    """ O(N .lIndices)"""
    """
    #lControlPoints = pMesh.GetControlPoints()
    cWeights = []
    cIndices = []
    for i in xrange(len(lIndices)):
        vec = lControlPoints[lIndices[i]]
        for k in xrange(len(vertex1by3N) / 3):
            
            k3 = k * 3
            a = abs(vec[0] - vertex1by3N[k3])
            a += abs(vec[1] - vertex1by3N[k3 + 1])
            a += abs(vec[2] - vertex1by3N[k3 + 2])
            
            if a / 3 < .00000001:
                cIndices.append(k)
                cWeights.append(lWeights[i])
                
                
    return cIndices, cWeights
    """

    cIndices = []
    cWeights = []

    # vertex1by3N is sorted according to x-coor. Let's take advantage of it.    
    vertex_x = []
    for i in range(len(vertex1by3N) / 3):
        vertex_x.append(vertex1by3N[i * 3])
        # vertex_x routine can be taken into the main calling function


    for i in range(len(lIndices)):
        vec = lControlPoints[lIndices[i]]
        k = vertex_x.index(vec[0])
        #print "\nk =", k , ", vertex_x[k] =", vertex_x[k], ", vec[0] =", vec[0]
        while True:
            if k != 0 and abs(vertex_x[k - 1] - vec[0]) < eps:
                k = k - 1
                #print "          k reduction occured at k =", k, ", vertex_x[k] =", vertex_x[k], ", vec[0] =", vec[0]
                pass
            else:
                break
            # k is the smallest index where vertex_x[k] = vec[0]

        while k <= len(vertex_x) - 1:
            k3 = k * 3
            a = abs(vec[0] - vertex1by3N[k3])
            if a > eps:
                break

            b = abs(vec[1] - vertex1by3N[k3 + 1])
            c = abs(vec[2] - vertex1by3N[k3 + 2])

            if (b + c) / 2 < .001:
                #print "appending cIndices and cWeights, k =", k
                cIndices.append(k)
                cWeights.append(lWeights[i])
            k += 1

    return cIndices, cWeights


def FindParentBoneName(lCluster):
    return glo.bone2Parent[lCluster.GetLink().GetName()]


def ComputeLMatrix(lName, parentBoneName):
    if glo.bone2Parent[lName] == 'RootNode':
        parentMatrix = FbxAMatrix()
        parentMatrix.SetIdentity()
    else:
        parentMatrix = glo.bone2Matrix[parentBoneName]

    lMatrix = FbxAMatrix()
    lMatrix = glo.bone2Matrix[lName]
    lMatrix = parentMatrix.Inverse() * lMatrix;

    return lMatrix


def ComputeNodeWeightsAndIndices(pMesh, vertex1by3N):
    # output: glo.bone2Params{}

    lSkinCount = pMesh.GetDeformerCount(FbxDeformer.eSkin)
    print "lSkinCount =", lSkinCount

    if lSkinCount > 1:
        print ".....\nTrouble!!!"
        print " lSkinCount ", lSkinCount, " (!= 1)\n....\n\n\n\n\n\n\n\n"
        sys.exit(0)
        pass

    if lSkinCount == 0:
        glo.animFlag = 0
        return

    writtenBoneList = []

    lClusterCount = pMesh.GetDeformer(0, FbxDeformer.eSkin).GetClusterCount()
    # This needs to be checked
    if lClusterCount != 0:
        glo.animFlag = 1
        #print"ComputeNodeWeightsAndIndices(): glo.animFlag", glo.animFlag, ", lClusterCount =", lClusterCount

    print "lClusterCount", lClusterCount
    for j in xrange(lClusterCount): # traverse all bones
        lCluster = pMesh.GetDeformer(0, FbxDeformer.eSkin).GetCluster(j)
        #print "\n...................\n    Cluster ", i
        print "    Name: ", lCluster.GetLink().GetName()

        parentBoneName = FindParentBoneName(lCluster)

        lMatrix = ComputeLMatrix(lCluster.GetLink().GetName(), parentBoneName)

        MT = [lMatrix.GetT()[0], lMatrix.GetT()[1], lMatrix.GetT()[2]]
        MQ = [lMatrix.GetQ()[3], lMatrix.GetQ()[0], lMatrix.GetQ()[1], lMatrix.GetQ()[2]]
        MS = [lMatrix.GetS()[0], lMatrix.GetS()[1], lMatrix.GetS()[2]]
        """ N.B.  FBX: [q_x, q_y, q_z, q_w], 
            Y3D: [q_w, q_x, q_y, q_z] 
        """

        """ Compute Skinning Parameters (Control Point Indices, Weights) """

        lIndices = lCluster.GetControlPointIndices(); # print "Safak: lIndices = _bone.indices  ", lIndices
        lWeights = lCluster.GetControlPointWeights(); # print "Safak: lWeights = _bone.weights  ", lWeights ,"\n\n"
        print "         IndiceCount: ", len(lIndices)
        if lCluster.GetLink():
            boneName = lCluster.GetLink().GetName()
            # print "Safak: boneName ", boneName
        else:
            print "ERROR!: lCluster doesn't have a link!!"
            pass

        writtenBoneList.append(boneName)
        lControlPoints = pMesh.GetControlPoints() # pass lControlPoints from the main calling function as input.
        correctedIndices, correctedWeights = WeightsCorrector(pMesh, lIndices, lWeights, vertex1by3N, lControlPoints,
                                                              0.0000001)

        lIndexCount = len(correctedWeights)
        glo.bone2Params[boneName] = [MT, MQ, MS, parentBoneName, correctedIndices, correctedWeights, lIndexCount]
        # j-loop


    # . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
    # Compute glo.bone2Params{} for bones with zero-weight.
    for key in glo.bone2Parent.keys():
        if key not in writtenBoneList:
            boneName, parentBoneName = key, glo.bone2Parent[key]

            lMatrix = ComputeLMatrix(boneName, parentBoneName)
            MT = [lMatrix.GetT()[0], lMatrix.GetT()[1], lMatrix.GetT()[2]]
            MQ = [lMatrix.GetQ()[3], lMatrix.GetQ()[0], lMatrix.GetQ()[1], lMatrix.GetQ()[2]]
            MS = [lMatrix.GetS()[0], lMatrix.GetS()[1], lMatrix.GetS()[2]]

            glo.bone2Params[boneName] = [MT, MQ, MS, parentBoneName, None, None, 0]

    return


def EvaluateBoneMap(pNode, parent):
    for i in xrange(pNode.GetChildCount()):
        if isinstance(pNode.GetChild(i).GetNodeAttribute(), FbxSkeleton):
            #print "EvaluateBoneMap 1" 
            print pNode.GetChild(i).GetName(), "==>", parent.GetName()
            glo.bone2Parent[pNode.GetChild(i).GetName()] = parent.GetName()
            glo.bone2Matrix[pNode.GetChild(i).GetName()] = pNode.GetChild(i).EvaluateGlobalTransform()

            # New FbxSkeleton parent detected. Call EvaluateBoneMap() recursively.
            EvaluateBoneMap(pNode.GetChild(i), pNode.GetChild(i))

        else:
            #print "EvaluateBoneMap 2"
            # call EvaluateBoneMap() with next Child, parent unchanged
            EvaluateBoneMap(pNode.GetChild(i), parent)


def EvalNode2Child(lNode):
    glo.node2Child[lNode.GetName()] = [lNode.GetNodeAttribute()]

    for i in xrange(lNode.GetChildCount()):
        glo.node2Child[lNode.GetName()].append(lNode.GetChild(i).GetName())
        EvalNode2Child(lNode.GetChild(i))


def DisplayHierarchy(pScene):
    print "---------\nHierarchy\n---------"
    lRootNode = pScene.GetRootNode()

    DisplayNodeHierarchy(lRootNode, 0)
    print "\n"
    return


def DisplayNodeHierarchy(pNode, pDepth):
    lString = ""
    for i in xrange(pDepth):
        lString += "      "

    lString += ("%s%s" % (str(pDepth), ".  "))
    lString += pNode.GetName()
    lString += ("%s%s%s" % (" - ", pNode.GetNodeAttribute(), "  "))

    print(lString)

    for i in xrange(pNode.GetChildCount()):
        DisplayNodeHierarchy(pNode.GetChild(i), pDepth + 1)


def TextureFiles():
    """
    Converts psd files to png files and
    moves them to location .outputFolder = <FBXName>/
    """
    import shutil

    # first convert the .psd files to .png

    FbmDir = glo.outputFolder + '.fbm'

    for d1, d2, filenames in os.walk(FbmDir):
        for filename in filenames:
            """filename: vitrin_diffuse.psd
            """
            # print "TextureFiles():", filename
            if filename[-4:].upper() == '.PSD':
                #print "   -- FbmDir:" , FbmDir
                #print "   -- in the if clause with filename:" , filename
                #print "   -- glo.outputFolder" , glo.outputFolder
                # FbmDir = '../fbx/simplelifeembedmedia.fbm'
                # filename = 'shelves_light.PSD'
                PsdToPngConverter(FbmDir, filename)

                # Move only the .png file to the ../png/ directory
                filename = filename[:-4] + '.png'
                src = os.path.join(FbmDir, filename)
            elif filename[0] != '.':
                src = os.path.join(FbmDir, filename)
                pass

            shutil.copy(src, glo.outputFolder)
            print os.path.join(glo.outputFolder, filename), "\n"
            sys.stdout.flush()
            # for d1, d2, files in os.walk(glo.outputFolder):
            #     if not filename in files:
            #         #print "moving: ", files, filename, not filename in files
            #         shutil.copy(src, glo.outputFolder)
            #         print os.path.join(glo.outputFolder, filename), "\n"
            # else:
            #     print "%s/%s already exists. File not moved" % (glo.outputFolder,filename)


def PsdToPngConverter(directory, filename):
    psd = PSDImage.load(directory + glo.s + filename)
    #print "psd.header\n         " , psd.header
    merged_image = psd.as_PIL()
    # print "image being saved to:     " , directory + glo.s + filename[:-4] + '.png'
    merged_image.save(directory + glo.s + filename[:-4] + '.png')

    return


def Timer(start, prefix=""):
    T = time() - start
    minutes = int(T / 60)
    sec = T % 60
    print prefix, "Time Elapsed ...", minutes, "mins", sec, "secs"
    sys.stdout.flush()

    





