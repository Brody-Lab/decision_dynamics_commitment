import numpy as np
import math as math
def radial_basis_functions(D, N, begins_at_0=False, ends_at_0=False):
    # Unitary radial basis functions
    #
    # Each of `D` radial basis functions are evaluated at `N` values. The basis functions are orthogonalized and constained to have unit norm.
    #
    # Parameters:
    #   D: (integer) number of basis functions
    #   N : (integer) number of values for which the basis functions are evaluated
    #   begins_at_0 : (bool, optional) whether the output of the basis functions are set to be 0 for the first element
    #   ends_at_0 : (bool, optional) whether the output of the basis functions are set to be 0 for the last element
    #
    # Returns:
    #  Phi : values of the unitary radial basis functions
    #  Phiraw : values of the non-unitary radial basis functions
    if begins_at_0:
        if ends_at_0:
            Delta_centers = N/(D+3)
        else:
            Delta_centers = N/(D+1)
    else:
        if ends_at_0:
            Delta_centers = N/(D+1)
        else:
            Delta_centers = N/(D-1)
    firstcenter = 1+2*Delta_centers if begins_at_0 else 1
    lastcenter = N-2*Delta_centers if ends_at_0 else N
    centers = np.linspace(firstcenter, lastcenter, D)
    x = np.linspace(1,N,N)
    y = np.reshape(x, (N,1)) - np.reshape(centers, (1,np.size(centers)))
    y = y*math.pi/Delta_centers/2
    y = np.minimum(math.pi, y)
    y = np.maximum(-math.pi,y)
    Phiraw = (np.cos(y) + 1)/2;
    if (not begins_at_0) and (not ends_at_0) and (D % 2 == 0):
        Phi = np.hstack((np.ones((N,1)),Phiraw))
    else:
        Phi = Phiraw
    U, S, Vh = np.linalg.svd(Phiraw)
    Phi = U[:,0:D]
    return (Phi, Phiraw)
