import numpy as np
import scipy
import matplotlib

class acquisition:
    def __init__(self, dataset, acqType):
        pass


data = open("/home/mori/MatlabFiles/simulator/50galileo2.bin", "rb")
t= np.array([])
t = data.read(10)
num = t.hex()
print(type(num))

print(type(t))
acquisition(data, "galileoL5")