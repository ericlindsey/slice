SLICE: Efficient N-Dimensional Monte Carlo Inversion Algorithm
-----

Eric Lindsey
Written: Oct 2010
Revised: June 2013

The slice sampler is a Monte Carlo algorithm used to generate samples in an
arbitrary-dimensional space whose long-term distribution exactly matches the
posterior probability distribution function. Slice has significant advantages
over traditional Markov Chain Monte Carlo methods such as the Metropolis
algorithm, because for well-behaved pdfs the correlation timescale of samples
is very close to zero -- thus no significant 'burn in' period is required, and
nearly all the samples generated can be used in the final distribution. For
ill-behaved pdfs, such as those with widely separated misfit minima, individual
random walks may become trapped in a single minimum, but this problem is easily
overcome by combining the results of a large number of independent walks.

This program is an implementation of the Slice sampling algorithm first described by R. Neal in 2003, and was written for part of my PhD thesis. Citations should include both of these references:

R. Neal, "Slice Sampling", Ann. Stat. (2003), v. 31, pp. 705-767, https://www.jstor.org/stable/3448413.

Lindsey, E. O. and Y. Fialko, Geodetic Slip Rates in the Southern San Andreas Fault System: Effects of Elastic Heterogeneity and Fault Geometry (2013), J. Geophys. Res. Solid Earth, v. 118, pp. 689–697, doi:10.1029/2012JB009358.

The program accepts any user-defined misfit function (written as a subroutine in Fortran) and returns the 1-D and 2-D marginal distribution of samples along each dimension, plus their means, standard deviations and the correlation matrix.

Parallelization in MPI makes use of the statistical independence of separate
Markov Chains. To parallelize efficently, use more walks than the number of
processors. MPI overhead can become significant for a large number of walks or
a large number of dimensions, in which case the arrays become large. Testing on
a simple pdf is advised before running the code with your full forward model.

Installation
-----
Compile the program as follows: 
For gfortran: type 'make all'.
Other compilers: edit src/Makefile first.

Note that the program requires you to write several F90 routines to compute your
specific misfit function before compiling. The program is distributed with a
basic line-fitting example, to be replaced with your problem of choice.

Program Setup
-----
The code in src/fwd_mod.f90 must be modified to suit the needs of the problem.
This may entail adding other modules, libraries, etc. as needed.

The two routines which need to be changed are:

fwd_init()
Runs once at the beginning. It may load any data, static parameters, greens
functions, etc. into memory as needed. A simple example is provided which loads
parameters from the file 'fwd.param', then loads some data from a filename
specified in that file. At a minimum, this routine should load the vector 'dat',
and 'weights', which will be compared with the model 'values' to compute the
misfit.

calc_model(model,values):
Will be called many (thousands of) times, generally requiring ~5 calls per
random-walk step along each dimension (the number of calls per step is a basic
characteristic of the slice algorithm, although setting the expected
distribution width accurately may help -- see below, or see Neal (2003)).
Input: vector of model parameters 'model'
Output: predicted values for comparison with data
The default misfit function is the L2 norm, using the provided data uncertainty
for each point but assuming independent observations (diagonal covariance 
matrix). Since this routine is run so many times, it's a good idea to make sure
it is as efficient as possible.

Other subroutines in fwd_mod:

forward(model,fwd)
Calls calc_model to get the model values and then computes the misfit via:
fwd=-0.5\*sum(((values-dat)/weights)\*\*2). Given gaussian statistics and
uncorrelated errors, the value exp(fwd) is proportional to the model probability
distribution function (pdf). The sampler works with the log of the pdf to avoid
numerical instability that comes when you exponentiate a large negative number.
You might want to change this function if you want to use the entire data 
covariance matrix instead of diagonal weights, or you want a different norm.

write_meanmodel(meanmodel)
Calculate the forward model one last time and save the output. This allows easy
visualization of the best-fitting result. Change the misfit function here if you
also changed it in forward().

Parameters
-----
The file slice.param (or whatever you want to name it) must contain
the following parameters (in the listed order) to control the program's
execution. Lines starting with # are ignored.

number of walks: suggested 100.
A large number of independent walks helps ensure accurate sampling of the model
pdf and prevent biases that can be caused by a single walk getting stuck in a
local minimum. This may be a particular problem if your pdf has widely separated
local minima, or if two variables are strongly correlated: the algorithm
formally fails when the correlation is =1, and values above 0.95 may require an
infeasible number of walks to resolve properly. If you're certain correlations
are not large, and there is only one minimum, you can keep this number small and
increase the number of steps per walk accordingly.

steps per walk: suggested 1000.
Experiment with this number to increase the accuracy and noise level in your
output pdfs. Note that the total number of forward model calls is approximately
10*nparam*nwalk*(nsteps+nburn), though only nwalk*nsteps independent samples are
actually generated.

steps to burn: suggested 100.
When the random walk begins, it may be in a very unfavorable location in model
space. Until the model converges, recording the steps will bias the result. So,
we drop some initial number of them. This increases the cost of the model run,
so you may push this value lower to keep more steps. Watch out! If you see
the marginal pdfs sitting on top of a band of white noise, you may need to
increase the value of nburn.

number of bins: suggested 100.
This value specifies the discretization used for each axis when binning the
sample distribution prior to calculating the statistics and marginal pdfs. A
larger value implies better accuracy in the statistics, but the marginal pdfs
will look noisier. You may wish to set this value very high to maximize accuracy
in the computed statistics, and do your own binning afterward to plot nice pdfs.

iseed:
seed for random number generator. (-1) gets a seed from the system clock.

distribution width:
sets the default step size during the random walk. Ideally, this should be close
to the expected width of the pdf, or larger. If it is too small, the random walk
may take a very long time to find any local minima, and you will get a highly
biased result. If it is too big, the model will run somewhat slower. See Neal
(2003) for more details.

whether to write out models: default 0.
If =1, the parameter values of all sampled steps will be written to the file
models.dat. Warning: this file may be very large!

number of parameters:
Specifies the number of dimensions in the model space. (program will expect this
number of additional lines to appear below)

min/max/name for each parameter:
The final nparam lines specify the bounds for each dimension, and a label to
give that dimension when reporting the results. If the bounds are set too wide,
the random walk may take a very long time to find any real minima, and the
resulting pdf will not be accurate. On the other hand, if some of the pdf is cut
off by the bounds, the calculated mean and standard deviation will be incorrect.
Therefore, the bounds should be wide enough to include the full pdf in each
dimension, but not much larger.

Running the code
-----
Slice takes the name of the parameter file as input. To run, the basic usage is:

slice slice.param

You may submit multiple jobs in separate directories. Add an '&' to submit
several jobs at once; see the script rundirs.sh for examples.
