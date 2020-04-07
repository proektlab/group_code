import pandas as pd
import csv
import numpy as np

print("Loading DAT files")

landmarks = [];
with open('landmarks.dat', 'rt') as csvfile:
    reader = csv.reader(csvfile, delimiter=',')
    for row in reader:
        landmarks.append([float(i) for i in row])
landmarks = np.array(landmarks)

distances = [];
with open('distances.dat', 'rt') as csvfile:
    reader = csv.reader(csvfile, delimiter=',')
    for row in reader:
        distances.append([float(i) for i in row])
distances = np.array(distances)


witnesses = [];
with open('distances.dat', 'rt') as csvfile:
    reader = csv.reader(csvfile, delimiter=',')
    for row in reader:
        witnesses.append([float(i) for i in row])
witnesses = np.array(distances)

landmarksFrame = pd.DataFrame()#(len(data["landmarks"]),len(data["landmarks"][0]["position"])))
distancesFrame = pd.DataFrame()#(len(data["landmarks"]),len(data["landmarks"][i]["distance"])))
witnessesFrame = pd.DataFrame()#(len(data["witnesses"]),len(data["witnesses"][0])))

for i in range(landmarks.shape[0]):
    landmarksFrame['col_{}'.format(i)] = landmarks[i,:]

for i in range(distances.shape[0]):
    distancesFrame['col_{}'.format(i)] = distances[i,:]

for i in range(witnesses.shape[0]):
    witnessesFrame['col_{}'.format(i)] = witnesses[i,:]

print("Saving to HDF5")

landmarksFrame.to_hdf('landmarks.hdf', 'main', format='fixed')
distancesFrame.to_hdf('distances.hdf', 'main', format='fixed')
witnessesFrame.to_hdf('witnesses.hdf', 'main', format='fixed')
