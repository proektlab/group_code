import time
import numpy as np
import dionysus as d
import matplotlib.pyplot as plt
import math
import scipy.spatial
import sklearn.metrics
import json5
from pprint import pprint

NUM_ITERATIONS = 1

data = json5.load(open('data.json'))

landmarks = np.zeros((len(data["landmarks"]),len(data["landmarks"][0]["position"])))
witnesses = np.zeros((len(data["witnesses"]),len(data["witnesses"][0])))

for i in range(len(data["landmarks"])):
    landmarks[i,:] = data["landmarks"][i]["position"];

for i in range(len(data["witnesses"])):
    witnesses[i,:] = data["witnesses"][i];



clusterValues = np.zeros((NUM_ITERATIONS,4))
for t in range(NUM_ITERATIONS):
    #np.random.seed(44)

    points1 = np.random.normal(size = (100,2))
    points2 = np.random.normal(size = (100,2))
    points3 = np.random.normal(size = (100,2))

    for i in range(points1.shape[0]):
        points1[i] = points1[i] / np.linalg.norm(points1[i], ord=2) * np.random.uniform(1, 1.9) + [1, 0]

    for i in range(points2.shape[0]):
        points2[i] = points2[i] / np.linalg.norm(points2[i], ord=2) * np.random.uniform(1, 1.9) + [-1, 0]

    for i in range(points3.shape[0]):
        points3[i] = points3[i] / np.linalg.norm(points3[i], ord=2) * np.random.uniform(1, 1.9) + [0, -math.sqrt(2)]

    points = np.zeros(shape=(6, 2))

    for i in range(points.shape[0]):
        if i == 1:
            points[i,:] = (0, 0)
        elif i == 2:
            points[i,:] = (0, 1)
        elif i == 3:
            points[i,:] = (1, 1.1)
        elif i == 4:
            points[i,:] = (1.2, 0)
        elif i == 5:
            points[i, :] = (0.5, 1.5)
        elif i == 6:
            points[i, :] = (0.5, 2.5)

    #points = np.concatenate((points1, points2, points3))
    #points = np.concatenate((points1))

    startTime = time.time()

    prime = 11
    f = d.fill_rips(points, 100, 2.)
    print("Rips time: ", time.time() - startTime)
    startTime = time.time()
    p = d.cohomology_persistence(f, prime, True)
    print("Cohomology time: ",time.time() - startTime)
    dgms = d.init_diagrams(p, f)

    d.plot.plot_bars(dgms[1], show = True)

    sortedList = sorted(dgms[1], key = lambda pt: pt.death - pt.birth)

    nearNeighbors = sklearn.metrics.pairwise_distances(points)
    smallDist = np.percentile(nearNeighbors[nearNeighbors != 0], 1/len(points)/len(points))

    print(f)

    for l in [3]:#[2,3,4,5]:
        NUM_LOOPS = l

        allLoopValues = np.zeros((len(points),NUM_LOOPS))

        for i in range(NUM_LOOPS):
            pt = sortedList[len(sortedList)-i-1]
            print("Cocycle: ", pt)
            cocycle = p.cocycle(pt.data)

            print("Cocycle: ", cocycle)

            f_restricted = d.Filtration([s for s in f if s.data <= (pt.death + pt.birth)/2])

            vertex_values = d.smooth(f_restricted, cocycle, prime)

            velocities = np.zeros(len(points))
            for j in range(len(points)):
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

            for j in range(len(points)):
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

        clusterIDs = np.zeros((len(points),NUM_LOOPS))
        clusterWeights = np.zeros((len(points),NUM_LOOPS))

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
        finalClusterIDs = np.zeros((len(points)))
        for i in range(len(points)):
            finalClusterIDs[i] = np.sum(np.multiply(clusterIDs[i,:], np.power(2,scalers)))

        #print(finalClusterIDs)

        clusterEntropies = np.zeros((len(points)))
        for i in range(len(points)):
            clusterEntropies[i] = scipy.stats.entropy(allLoopValues[i,:]) / np.log(l)
           # print(allLoopValues[i,:], " -> ", clusterEntropies[i])

        clusterValues[t,l-2] = np.mean(clusterEntropies)
        print(l, " -> ", clusterValues[t,l-2] )
      #  print(np.divide(1,(1+np.exp(-allLoopValues+1))))
        #print(clusterEntropies)

print(np.argmax(clusterValues,1))

if (True):
    plt.subplot(2, 2, 1)
    plt.scatter(points[:, 0], points[:, 1], c=clusterIDs[:,0], cmap='Dark2')
    plt.subplot(2, 2, 2)
    plt.scatter(points[:, 0], points[:, 1], c=clusterIDs[:,1], cmap='Dark2')
    plt.subplot(2, 2, 3)
    #plt.scatter(points[:, 0], points[:, 1], c=clusterIDs[:,2], cmap='Dark2')
    #plt.subplot(2, 2, 4)
    plt.scatter(points[:, 0], points[:, 1], c=finalClusterIDs, cmap='Dark2')

    plt.show()

