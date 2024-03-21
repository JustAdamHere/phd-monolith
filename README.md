# PhD-Monolith

A repository for most of the code used for modelling placental flow in my PhD project from October 2020 to May 2024. Feel free to contact me if you want to use any part of this, as it is generally pretty undocumented.

Essentially, there is a friendly Python wrapper that interfaces with Fortran AptoFEM code (an internal University of Nottingham FEM library), as well as a few other smaller pieces of software such as Gmsh, ParaView, and some MRI code written in MATLAB.

## Features

- A simple Python wrapper for AptoFEM
- Approximates the Navier-Stokes-Darcy and a reaction-advection-diffusion equation using a symmetric interior penalty discontinuous Galerkin finite element method
- Easy to use driver files, especially when running 1000s of simulations
- Calculates numerical MRI signals
- Handles moving mesh simulations under a prescribed domain velocity
- Interfaces with Gmsh for mesh generation
- Interfaces with ParaView for visualisation

## Getting started

This is tested with Python3.11, and is known to be broken for Python3.6 and lower.

A good place to start is to try out some of the driver files, such as `run.py`. All parameter options are visible at the top of the `programs/velocity_transport.py' file.

A sample output from one of the driver files might look a little like the following. This gives a good idea of the order in which things are run.

```
##########################
🔨 Setting up simulations...
2024-03-21 12:37:58.560816
##########################
Skipping cleaning.
Starting compilation... Done in 1s.
##########################port...
Running simulation # 1...
##########################
Starting mesh generation... Done in 3s.
Starting AptoFEM set parameters... Done in 1s.
Starting AptoFEM simulation... Done in 627s.
  aptofem_run_no = 1, no_elements = 156,040, velocity_dofs = 2,340,600, newton_residual = 1.6532e-12, transport_dofs = 468,120, newton_iterations = 7
😁 Within tolerance: velocity limits = (0.00000, 0.99996)
⚠ Warning: transport limits = (-0.00289, 1.12768)
Starting plotting... Done in 57s.
Starting average velocity computation... Done in 18s.
Starting velocity sample computation... Done in 13s.
Starting compressing and cleaning files... Done in 63s.
```
