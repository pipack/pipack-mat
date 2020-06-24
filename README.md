# pipack-mat
A Matlab package for investigating the stability properties of polynomial integrators and computing their coefficients.

Below we describe how to use the key features of this library. Example scripts that showcase all the features descriebd in this document are available in the repository
https://github.com/pipack/pipack-mat-examples

## Initializing A Polynomial Method Generator

Polynomial integrators are described by general construction strategies that are not limited to a single node set. 
This code is designed so that you can initialize a generator object that can construct families of PBMs with any
number of nodes. 

To initialize a method generator, you must first select a node set generator, ODE polynomial generator, and for Adams methods an expansion point generator.

### Node Generators

Node set generators inherit from the abstract class *NodeSetGenerator* and are located in *classes/generators/nodes/families.* Several currently available families of nodes generators are:

- IEquiNSG: imaginary equispaced nodes <img style="vertical-align:middle" src="https://latex.codecogs.com/gif.latex?z_j=-i+2ij/q"> <!-- z_j = -i + 2ij/q -->
- IChebNSG: imaginary chebyshev nodes <img style="vertical-align:middle" src="https://latex.codecogs.com/gif.latex?z_j=i\cos(\pi(j-1)/(q-1))"> <!-- z_j = i \cos(\pi(j-1)/(q-1)) -->
- EquiNSG:  equispaced nodes <img style="vertical-align:middle" src="https://latex.codecogs.com/gif.latex?z_j=\cos(\pi(j-1)/(q-1))"> <!-- z_j = \cos(\pi(j-1)/(q-1))$ -->
- ChebNSG:  chebyshev nodes <img style="vertical-align:middle" src="https://latex.codecogs.com/gif.latex?z_j=-1+2j/q">  <!-- z_j = -i + 2ij/q -->

All node set generators are initialized in the following way:
```
NodeSetGenerator(ordering, precision, options)
```
where the parameters are:
1. ordering: string with value 'leftsweep' | 'rightsweep' | 'inwards' | 'outwards' | 'classical'| 'rclassical'
2. precision: string with value 'double' | 'vpa' | 'sym'
3. options: optional struct with additional options.

### Endpoint Generators (Adams Methods)

Adams methods also require a generator for the expansion points (also called left integration endpoints). Endpoint generators inherit from
the abstract class *JD_ExpansionPointGenerator* and are located in *classes/generators/expansionpoints/families*. 
Currently available expansion points are:
1. FixedInputEPG
2. SweepingInputEPG
3. VariableINputEPG

All endpoint generators can be initilized in the following way:
```
ExpansionPointGenerator(options)
```
where options is a struct with specific options pertinant to the endpoints. For example, FixedInputEPG reacts to the
field 'l' that denotes the index of the node used for the endpoint.

### ODE Polynomial Generators

ODE polynomials generators inherit from the abstract class *JD_ODEPolynomialGenerator*, and are located in 
*classes/generators/odepolynomials/families. Three example families are 
- Adams_PG: an Adams ODE polynomial
- BDF_PG: A BDF ODE polynomial
- GBDF_PG: A GBDF ODE polynomial

The constructors for these polynomial differ depending on the family. BDF and GBDF ODE polynomials generators
can be initialized using
```
GBDF_PG(IBSet, type)
```
where the parameter are:
1. IBSet: string with value 'PMFO', 'PMFOmj', 'SMFO', 'SMFOmj', or 'SMVO'. It describes the AII and AOI sets I(j) and B(j).
2. type: string with value 'explicit' or 'diagonally_implicit'.

For Adams ODE polynomials the ODE polynomial generators can be initialized using
```
Adams_PG(Ly_IBSet, LF_IBSet, EP_generator, type)
```
where the parameter are:
1. Ly_IBSet: string with value 'PMFO', 'PMFOmj', 'SMFO', 'SMFOmj', or 'SMVO'. Describes AII and AOI set for polynomial <img style="vertical-align:middle" src="https://latex.codecogs.com/gif.latex?L_y(\tau)"> <!-- $L_y(\tau)$ -->
2. LF_IBSet: string with value 'PMFO', 'PMFOmj', 'SMFO', 'SMFOmj', or 'SMVO'. Describes AII and AOI set for polynomial <img style="vertical-align:middle" src="https://latex.codecogs.com/gif.latex?L_F(\tau)"> <!-- $L_F(\tau)$ -->
3. type: string with value 'explicit' or 'diagonally_implicit'

### Polynomial Method Generators

The function *PBMGenerator(options)* can be used to quickly initialize a method generator. It accepts a single parameter of type struct. 
The struct should have at minimum the following fields
- NodeSet_generator: Object of type *NodeSetGenerator* that described the node set
- ODEPoly_generator: Object of type *JD_ODEPolynomialGenerator* that describes the ODE polynomial family

For example a diagonally-implicit Adams Method with imaginary equispaced nodes, SMFO active sets, and FixedInput endpoints can be initialized using
```
adams_generator = PBMGenerator(struct( ...
    'NodeSet_generator', IEquiNSG('inwards', 'double'), ...
    'ODEPoly_generator', Adams_PG('PMFO', 'SMFOmj', FixedInputEPG(struct('l', 2)), 'diagonally_implicit') ...
));
```

Similarly, an implicit BDF with imaginary nodes and SMVO method can be initilized with
```
bdf_generator = PBMGenerator(struct( ...
    'NodeSet_generator', IEquiNSG('inwards', 'double'), ...
    'ODEPoly_generator', BDF_PG('SMVO', 'diagonally_implicit') ...
));
```

The generators can now be used to initilize methods of any number of nodes. For example we can use the result of the previous two commands to initialize methods with four nodes by running the commands
```
bdf_method = bdf_generator.generate(4);
adams_method = adams_generator.generate(4);
```
The returned type will inherit from the class *PBM*.


## Initializing Coefficients

You compute the coefficients for any object of type *PBM* using
```
[A, B, C, D] = method.blockMatrices(alpha, format);
```
where the parameters are:
1. alpha: positive real number representing the extrapolation factor
2. format: string with value 'full' or 'compact' or 'full_traditional' or 'compact_traditional':

    - if 'full' matrices scale with r and
        <img style="vertical-align:middle" src="https://latex.codecogs.com/gif.latex?y^{[n+1]}=Ay^{[n]}+rBf^{[n]}+Cy^{[n+1]}+rDf^{[n+1]}">

    - if 'compact' matrices scale with r and
        <img style="vertical-align:middle" src="https://latex.codecogs.com/gif.latex?y^{[n+1]}=Ay^{[n]}+rBf^{[n]}+rCf^{[n+1]}">

    - if 'full_traditional', then matrices scale with h and
        <img style="vertical-align:middle" src="https://latex.codecogs.com/gif.latex?y^{[n+1]}=Ay^{[n]}+hBf^{[n]}+Cy^{[n+1]}+hDf^{[n+1]}">

    - if 'compact_traditional', then matrices scale with h and
        <img style="vertical-align:middle" src="https://latex.codecogs.com/gif.latex?y^{[n+1]}=Ay^{[n]}+hBf^{[n]}+hCf^{[n+1]}">

**Note.** If the method is initialized with a NodeSetGenerator with precision='double', then coefficients will have double precision. Similarly, 
a method generated using a NodeSetGenerator with precision='vpa' will produce coefficients in variable precision, and finally if precision='sym' then coefficients will be fully symbolic. 
To obtain exact coefficients, initialize the method using a MethodGenerator with a NodeSetGenerator with precision='sym' then set with sym(alpha).

## Making ODE Polynomial Diagrams

You can visualize the polynomial diagram of a method, or the expansion point diagram by calling:

```
adams_method.polynomialDiagram();
adams_method.expansionPointDiagram();
```

## Stability Plots and Movies

The stability of methods can be investigated with a variety of functions

```
alpha = 1/2
re_z = linspace(-5, 1, 100)
im_z = linspace(-5, 5, 200)
stabilityFigure(method, alpha, re_z, im_z) % plots stabilty region in complex z-plane
imStabilityFigure(method,alpha, im_z) % plots stability region along imaginary axis
isRootStable(method, alpha)     % root stability
stabilityTheta(method, alpha)   % stability angle
stabilityOfAlphaMovie(method, alphas, z_real, z_imag, struct('path', 'movie.mp4'))
```