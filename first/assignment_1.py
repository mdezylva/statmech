import numpy as np
import scipy as sp
import pandas as pd
import random as rand
import matplotlib.pyplot as plt
import matplotlib.colors as colors
import matplotlib.animation as animation
import scipy.signal


class fire_sim_world:
    def __init__(self, dim, f, p):
        self.data = np.random.randint(0, 2, dim)
        self.p = p
        self.f = f
        if self.f == 0:
            ind_1 = np.random.randint(0,len(self.data))
            ind_2 = np.random.randint(0,len(self.data[ind_1]))
            self.data[ind_1][ind_2] = 100

    def __repr__(self):
        return f'World({self.data!r})\n with probabilities ({self.p!r},{self.f!r})'

    def calc_s(self, runtime):
        '''
        Simulates behaviour for a given runtime, and gives the S-value (total number of pixels on fire) pdf
        '''
        assert runtime > 1000 , "Runtime needs to be greater than 1000"
        s_values = np.ndarray([runtime-1000])
        for i in range(runtime):
            number_on_fire = 0
            self.simple_update()
            if i > 1000:
                for j in range(len(self.data)):
                    for k in range(len(self.data[j])):
                        if self.data[j][k] > 99:
                            number_on_fire += 1
                s_values[i-1000] = number_on_fire
        return(s_values)

    def get_wait_times(self,runtime):
        '''
        Calculates the Wait Time (amount of time a pixel must wait before being reignited) Pdf 
        '''
        wait_times = np.zeros(np.shape(self.data))
        for i in range(runtime):
            self.simple_update()
            for j in range(len(self.data)):
                for k in range(len(self.data[j])):
                    if self.data[j][k] > 99:
                        wait_times[j][k] = 0 
                    else:
                        wait_times[j][k] += 1
        wait_times = np.ravel(wait_times)
        return(wait_times)

                            

    def simple_update(self):
        '''
        Utilises a simple method for updating the world based on conditions specified in question
        '''

        'Convolution creates a check matrix, with Periodic Boundary Conditions which we can check for behaviour '
        check = sp.signal.convolve2d(self.data, np.array(
            [[0., 1., 0.], [1., 0., 1.], [0., 1., 0.]]), mode='same', boundary='wrap')

        for i in range(len(self.data)):
            for j in range(len(self.data[i])):

                'Behaviour for Red Cells'
                if self.data[i][j] > 99:
                    self.data[i][j] = 0

                'Behaviour for Green Cells'
                if self.data[i][j] == 1:
                    if check[i][j] > 5:
                        self.data[i][j] = 100
                    if rand.random() < self.f:
                        self.data[i][j] = 100

                'Behaviour for Black Cells'
                if self.data[i][j] == 0:
                    if rand.random() < self.p:
                        self.data[i][j] = 1


    def complex_update(self):
        '''
        Utilises a more complex method for updating the world based on conditions specified in question, and realistic updates to the system

        Allows for jumping multiple cells.
        '''

        'Convolution creates a check matrix, with Periodic Boundary Conditions which we can check for behaviour '
        check = sp.signal.convolve2d(self.data, np.array(
            [[0., 0., 1., 0., 0.], [0., 0., 1., 0., 0.], [0., 1., 0., 1.,0],[0., 0., 1., 0.,0],[0., 0., 1., 0.,0]]), mode='same', boundary='wrap')

        for i in range(len(self.data)):
            for j in range(len(self.data[i])):

                'Behaviour for Red Cells'
                if self.data[i][j] > 99:
                    self.data[i][j] = 0

                'Behaviour for Green Cells'
                if self.data[i][j] == 1:
                    if check[i][j] > 5:
                        self.data[i][j] = 100
                    if rand.random() < self.f:
                        self.data[i][j] = 100

                'Behaviour for Black Cells'
                if self.data[i][j] == 0:
                    if check[i][j] < 5 and check[i][j] > 0:
                        if rand.random() < (self.p - 0.2):
                            self.data[i][j] = 1
                    if rand.random() < self.p:
                        self.data[i][j] = 1


def animate(i):
    sim.simple_update()
    ax.imshow(sim.data, interpolation='nearest', cmap=cmap, norm=norm)


def generate_pdf(sim, sim_runs):
    assert sim_runs>1000, "Sim run must exceed 1000 time-steps"
    s_values = np.ndarray(sim_runs)
    for i in range(sim_runs):
        s_values[i]= sim.generate_pdf(sim_runs)
    return(s_values)

def calc_wait_time(sim):
    index_1 = np.random.randint(0,len(sim.data))
    index_2 = np.random.randint(0,len(sim.data[0]))
    count = 0
    while sim.data[index_1][index_2] < 99:
        count += 1
        sim.simple_update()
    return(count)

if __name__ == '__main__':
    f_prob = float(
        input("Enter probability of a Green Site catching fire (f) : "))
    p_prob = float(
        input("Enter probability of a black site regenerating (p) : "))
    size = int(input("Enter dimension (NxN) of simulation: "))

    sim = fire_sim_world([size, size], f_prob, p_prob)

    cmap = colors.ListedColormap(['black', 'green', 'red'])
    bounds = [0, 0.8, 5, 105]
    norm = colors.BoundaryNorm(bounds, cmap.N)
    speed = 100

    fig, ax = plt.subplots(figsize=(15, 15))
    ani = animation.FuncAnimation(fig, animate,
                                  frames=100, interval=speed,
                                  save_count=50)
    plt.draw()
    plt.show()