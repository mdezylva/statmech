import numpy as np
# import scipy as sp
import matplotlib.pyplot as plt
import scipy.stats as stats
import seaborn as sns

class super_simulation:
    def __init__(self, lam, alpha, runtime_years, D, step_size, num_sims):
        self.lam = lam
        self.alpha = alpha
        self.runtime_years = runtime_years
        self.step_size = step_size
        self.num_sims = num_sims
        self.D = D
        self.data = np.zeros(shape=(runtime_years, num_sims))
        self.data = self.run_sim()

    def __repr__(self):
        return f'Superannuation Simulation with Yearly Deposit ({self.lam!r}), Interest rate,({self.alpha!r}), run over ({self.runtime_years!r}) years, and ({self.num_sims!r}) simulations containing ({self.data!r})'

    def run_sim(self):
        for i in range(1,self.runtime_years):
                for j in range(self.num_sims):
                        self.data[i][j] = self.data[i-1][j] + self.step_size *                   (self.data[i-1][j]*(self.alpha + np.random.normal(loc = 0.0,scale = 2*self.D)) + self.lam)

    def plot_super(self):
            for i in range(self.runtime_years):
                    plt.plot(self.data[:][i])
            plt.show()

    def histogram(self):
            d = self.data[:][-1]
            sns.distplot(d)
            sns.distplot(d, fit=stats.invgauss, kde=False)
            plt.xlabel("Amount $")
            plt.show()

    def plot_mean(self):
            means = np.mean(self.data,axis=1)
            plt.plot(means,'bo')
            times = np.arange(0,self.runtime_years)
            plt.plot(times, self.expected_mean(times),'k')
            plt.title("Mean of Ensemble of Simulations")
            plt.ylabel("Amount ($)")
            plt.xlabel("Time (years)")
            plt.show()

    def plot_variance(self):
            variances = np.var(self.data,axis=1)
            plt.plot(variances)
            plt.title("Variance of Ensemble of Simulations")
            plt.ylabel("Amount ($)")
            plt.xlabel("Time (years)")
            plt.show()

    def expected_mean(self,time):
            fac_1 = self.lam/(self.alpha + self.D)
            fac_2 = np.exp((self.alpha+self.D)*time) - 1
            return(fac_1*fac_2) 


if __name__ == '__main__':
        lam = float(input("Enter a yearly contribution amount (lambda): "))
        alpha = float(input("Enter an interest rate (alpha): "))
        assert -1 < alpha < 1, "Interest rate must be between -100 percent and 100 percent (-1 and 1)"
        h = float(input("Enter the step size (h) : "))
        years = int(input("Enter the number of years to run the simulation by : "))
        num_sims = int(input("Enter the number of simulations to run: "))
        runtime = int(years/h)
        dispersion = float(input("Enter the return dispersion of the fun (D):"))

        simulation = super_simulation(lam,alpha,years,dispersion,h,num_sims)
        simulation.run_sim()
        simulation.plot_super()
        simulation.plot_mean()


        
