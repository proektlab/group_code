import time
import numpy as np
import dionysus as d
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import math
import scipy.spatial
import sklearn.metrics
import pandas as pd
import csv
import sklearn.decomposition

import sys
print (sys.version)

NUM_LOOPS = 2

positions = [];
with open('C:/Users/Connor/Dropbox/Cohomolgy/positions.dat', 'rt') as csvfile:
    reader = csv.reader(csvfile, delimiter=',')
    for row in reader:
        positions.append([float(i) for i in row])
positions = np.array(positions)

positions = positions.transpose()

distances = [];
with open('C:/Users/Connor/Dropbox/Cohomolgy/distances.dat', 'rt') as csvfile:
    reader = csv.reader(csvfile, delimiter=',')
    for row in reader:
        distances.append([float(i) for i in row])
distances = np.array(distances)

for i in range(0, distances.shape[1]):
    distances[i,i] = 0

# fig = plt.figure()
# ax = fig.add_subplot(111)
# ax.set_aspect('equal')
# plt.imshow(distances, interpolation='nearest', cmap=plt.cm.ocean)
# plt.colorbar()
# plt.show()

vectorDistances = scipy.spatial.distance.squareform(distances)

print(vectorDistances.shape)

clusterRatio = 1 - distances.mean(axis=1);
clusterRatio = (clusterRatio - np.min(clusterRatio)) / (np.max(clusterRatio) - np.min(clusterRatio));

pca = sklearn.decomposition.PCA(n_components=3)
dsiplayWitnesses = pca.fit_transform(positions)
#plt.scatter(dsiplayWitnesses[:, 0], dsiplayWitnesses[:, 1])

fig = plt.figure()
ax = fig.add_subplot(111, projection='3d')

ax.scatter(np.matmul(positions,np.transpose(pca.components_[0,:])), np.matmul(positions,np.transpose(pca.components_[1,:])), np.matmul(positions,np.transpose(pca.components_[2,:])), c=clusterRatio)
plt.show()

startTime = time.time()

print("Data loaded: ")

prime = 11
f = d.fill_rips(vectorDistances, 2, np.inf)
print("Rips finished")

exit(0)

print("Rips time: ", time.time() - startTime)
startTime = time.time()
p = d.cohomology_persistence(f, prime, True)
print("Cohomology time: ",time.time() - startTime)
dgms = d.init_diagrams(p, f)

d.plot.plot_bars(dgms[1], show = True)

sortedList = sorted(dgms[1], key = lambda pt: pt.death - pt.birth)

nearNeighbors = sklearn.metrics.pairwise_distances(positions)
smallDist = np.percentile(nearNeighbors[nearNeighbors != 0], 1/len(positions)/len(positions))

allLoopValues = np.zeros((len(positions),NUM_LOOPS))
clusterIDs = np.zeros((len(positions),NUM_LOOPS))
clusterWeights = np.zeros((len(positions),NUM_LOOPS))
finalClusterIDs = np.zeros((len(positions)))

if NUM_LOOPS > 1:
    for i in range(NUM_LOOPS):
        pt = sortedList[len(sortedList)-i-1]

        cocycle = p.cocycle(pt.data)

        f_restricted = d.Filtration([s for s in f if s.data <= (pt.death + pt.birth)/2])

        vertex_values = d.smooth(f_restricted, cocycle, prime)

        velocities = np.zeros(len(positions))
        for j in range(len(positions)):
            NUM_NEIGHBORS = 2

            thisDistances = np.sort(nearNeighbors[:, j])
            thisNeighbors = np.argsort(nearNeighbors[:, j])
            thisNeighbors = thisNeighbors[1:1+NUM_NEIGHBORS]
            thisDistances = thisDistances[1:1+NUM_NEIGHBORS]

            nearVelocities = np.zeros(len(thisNeighbors))

            for k in range(len(thisNeighbors)):
                angleDiff = np.arctan2(math.sin(vertex_values[j]-vertex_values[thisNeighbors[k]]), math.cos(vertex_values[j]-vertex_values[thisNeighbors[k]]))
                nearVelocities[k] = math.sqrt(abs(angleDiff) / max(smallDist, thisDistances[k]))

            nearVelocities = np.sort(nearVelocities)
            velocities[j] = np.percentile(nearVelocities, 95)

        for j in range(len(positions)):
            SMOOTH_NEIGHBORS = 20

            thisDistances = np.sort(nearNeighbors[:, j])
            thisNeighbors = np.argsort(nearNeighbors[:, j])
            thisNeighbors = thisNeighbors[1:1+SMOOTH_NEIGHBORS]
            thisDistances = thisDistances[1:1+SMOOTH_NEIGHBORS]

            velocityList = velocities[thisNeighbors]
            velocityList = np.append(velocityList, velocities[j])

            weights = np.exp(-np.power(thisDistances,2))
            weights = np.append(weights, 1)
            weights = weights / np.sum(weights)

            velocities[j] = np.sum(np.multiply(velocityList, weights))

        allLoopValues[:,i] = velocities

        #    plt.subplot(2, 2, 2*(i-1)+1)
        #    plt.scatter(points[:, 0], points[:, 1], c=vertex_values, cmap='hsv')
        #    plt.subplot(2, 2, 2*(i-1)+2)
        #    plt.scatter(points[:, 0], points[:, 1], c=velocities, cmap='jet')
        #    plt.colorbar()

        UNIQUE_CLUSTER_CUTOFF = 1.5

        for i in range(NUM_LOOPS):
            thisValues = allLoopValues[:, i]
            otherIndices = np.fromiter(range(NUM_LOOPS), dtype="int")
            otherIndices = np.delete(otherIndices, i)
            otherValues = allLoopValues[:, otherIndices]

            clusterWeights[:,i] = np.divide(thisValues,otherValues.max(1))
            clusterIDs[:,i] = 1*(clusterWeights[:,i] > 1/UNIQUE_CLUSTER_CUTOFF)

        #    unknownClusters = np.where(np.logical_and(clusterWeight < UNIQUE_CLUSTER_CUTOFF, clusterWeight > 1/UNIQUE_CLUSTER_CUTOFF))[0]
        #    clusterID[unknownClusters] = 2

        scalers = np.fromiter(range(NUM_LOOPS), dtype="int")

        for i in range(len(positions)):
            finalClusterIDs[i] = np.sum(np.multiply(clusterIDs[i,:], np.power(2,scalers)))

clusterFile = open('clusterIDs.txt', 'w')

for clusterID in finalClusterIDs:
    clusterFile.write("%s\n" % clusterID)

if (True):
    pca = sklearn.decomposition.PCA(n_components=2)
    dsiplayPositions = pca.fit_transform(positions)

    #plt.subplot(2, 2, 1)
    #plt.scatter(positions[:, 0], positions[:, 1], c=clusterIDs[:,0], cmap='Dark2')
    #plt.subplot(2, 2, 2)
    #plt.scatter(positions[:, 0], positions[:, 1], c=clusterIDs[:,1], cmap='Dark2')
    #plt.subplot(2, 2, 3)
    #plt.scatter(points[:, 0], points[:, 1], c=clusterIDs[:,2], cmap='Dark2')
    #plt.subplot(2, 2, 4)
    plt.scatter(dsiplayPositions[:, 0], dsiplayPositions[:, 1], c=finalClusterIDs, cmap='Dark2')

    plt.show()

