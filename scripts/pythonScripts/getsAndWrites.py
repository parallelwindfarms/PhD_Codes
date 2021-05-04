#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Feb 20 18:05:20 2020

@author: jigar
"""

import pyvista as pv

# <codecell> 
"""
Read OpenFOAM case mesh acces to grid and cell values
"""
def getMeshInfo(cwd, vtkFile):
  
    mesh    = pv.UnstructuredGrid(cwd + vtkFile)
    nCells  = mesh.n_cells
    sized   = mesh.compute_cell_sizes()
    cVols   = sized.cell_arrays["Volume"]
    mVol    = mesh.volume
    volAvg  = cVols/mVol
    
    return mesh, nCells, volAvg

# <codecell> 
"""
writing gPC-KLE modes of lognormal nut
"""
def writeNutPCEModes(i, nutMode, nCells, dirName, phyDim):
    outputFile = open(dirName+"nut"+str(i),"w+")
    
    outputFile.write('''\
/*--------------------------------*- C++ -*----------------------------------*\\
| =========                 |                                                 |
| \\\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox           |
|  \\\    /   O peration     | Version:  v1806                                 |
|   \\\  /    A nd           | Web:      www.OpenFOAM.com                      |
|    \\\/     M anipulation  |                                                 |
\*---------------------------------------------------------------------------*/
FoamFile
{
version     2.0;
format      ascii;
class       volScalarField;
location    "0";
object      nut'''+str(i)+''';
}
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //
dimensions      [0 2 -1 0 0 0 0];

internalField   nonuniform List<scalar> \n'''+

    str(nCells)+'''\n(\n''')

    for j in range(nCells):
        outputFile.write(str(nutMode[j][0]) + "\n")
    
    outputFile.write('''\
)
;

boundaryField
{
    "(inlet|outlet)"
    {
        type            cyclic;
    }''')
    
    if phyDim==2 :
        outputFile.write('''
        "(front|back)"
        {
            type            empty;
        }''')
        
    if phyDim==3 :
        outputFile.write('''
        "(front|back)"
        {
            type            cyclic;
        }''')
    
    outputFile.write('''
    "(top|hills)"
    {
        type            nutkWallFunction;
        value           uniform 0;
    }
}

''')
    outputFile.close()
    
    
# <codecell> 
"""
writing gPC-KLE modes of lognormal nut
"""
def writeEnKF_U_UQ_Updated_Modes_PerHill(i, mode, nCells, dirName, phyDim):
    outputFile = open(dirName+"U"+str(i),"w+")
    
    outputFile.write('''\
/*--------------------------------*- C++ -*----------------------------------*\\
| =========                 |                                                 |
| \\\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox           |
|  \\\    /   O peration     | Version:  v1806                                 |
|   \\\  /    A nd           | Web:      www.OpenFOAM.com                      |
|    \\\/     M anipulation  |                                                 |
\*---------------------------------------------------------------------------*/
FoamFile
{
version     2.0;
format      ascii;
class       volVectorField;
location    "0";
object      U'''+str(i)+''';
}
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //
dimensions      [0 1 -1 0 0 0 0];

internalField   nonuniform List<vector> \n'''+

    str(nCells)+'''\n(\n''')

    for j in range(nCells):
        outputFile.write("("+str(mode[j][0]) +")"+"\n")
    
    outputFile.write('''\
)
;

boundaryField
{
    "(inlet|outlet)"
    {
        type            cyclic;
    }''')
    
    if phyDim==2 :
        outputFile.write('''
        "(front|back)"
        {
            type            empty;
        }''')
        
    if phyDim==3 :
        outputFile.write('''
        "(front|back)"
        {
            type            cyclic;
        }''')
    
    outputFile.write('''
    "(top|hills)"
    {
        type            noSlip;
    }
}

''')
    outputFile.close()
    
    
# <codecell> 
"""
writing gPC-KLE modes of lognormal nut
"""
def writeEnKF_nut_UQ_Updated_Modes_PerHill(i, mode, nCells, dirName, phyDim):
    outputFile = open(dirName+"nut"+str(i),"w+")
    
    outputFile.write('''\
/*--------------------------------*- C++ -*----------------------------------*\\
| =========                 |                                                 |
| \\\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox           |
|  \\\    /   O peration     | Version:  v1806                                 |
|   \\\  /    A nd           | Web:      www.OpenFOAM.com                      |
|    \\\/     M anipulation  |                                                 |
\*---------------------------------------------------------------------------*/
FoamFile
{
version     2.0;
format      ascii;
class       volScalarField;
location    "0";
object      nut'''+str(i)+''';
}
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //
dimensions      [0 2 -1 0 0 0 0];

internalField   nonuniform List<scalar> \n'''+

    str(nCells)+'''\n(\n''')

    for j in range(nCells):
        outputFile.write(str(mode[j][0])+"\n")
    
    outputFile.write('''\
)
;

boundaryField
{
    "(inlet|outlet)"
    {
        type            cyclic;
    }''')
    
    if phyDim==2 :
        outputFile.write('''
        "(front|back)"
        {
            type            empty;
        }''')
        
    if phyDim==3 :
        outputFile.write('''
        "(front|back)"
        {
            type            cyclic;
        }''')
    
    outputFile.write('''
    "(top|hills)"
    {
        type            calculated;
        value           uniform 1e-15;
    }
}

''')
    outputFile.close()
    
    
# <codecell> 
"""
writing gPC-KLE modes of lognormal k
"""
def writeKGPCModes(i, kMode, nCells, dirName, phyDim):
    outputFile = open(dirName+"k"+str(i),"w+")
    
    outputFile.write('''\
/*--------------------------------*- C++ -*----------------------------------*\\
| =========                 |                                                 |
| \\\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox           |
|  \\\    /   O peration     | Version:  v1806                                 |
|   \\\  /    A nd           | Web:      www.OpenFOAM.com                      |
|    \\\/     M anipulation  |                                                 |
\*---------------------------------------------------------------------------*/
FoamFile
{
version     2.0;
format      ascii;
class       volScalarField;
location    "0";
object      k'''+str(i)+''';
}
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //
dimensions      [0 2 -2 0 0 0 0];

internalField   nonuniform List<scalar> \n'''+

    str(nCells)+'''\n(\n''')

    for j in range(nCells):
        outputFile.write(str(kMode[j][0]) + "\n")
    
    outputFile.write('''\
)
;

boundaryField
{
    "(inlet|outlet)"
    {
        type            cyclic;
    }''')
    
    if phyDim==2 :
        outputFile.write('''
        "(front|back)"
        {
            type            empty;
        }''')
        
    if phyDim==3 :
        outputFile.write('''
        "(front|back)"
        {
            type            cyclic;
        }''')
    
    outputFile.write('''
    "(top|hills)"
    {
        type            zeroGradient;
        value           uniform 0;
    }
}

''')
    outputFile.close()

# <codecell> 
"""
writing gPC coeffients 
"""
def writeExpGpPCECoeffs(i, expGpCoeffs, nCells, dirName, phyDim):
    outputFile = open(dirName+"expGpCoeffs"+str(i),"w+")
    
    outputFile.write('''\
/*--------------------------------*- C++ -*----------------------------------*\\
| =========                 |                                                 |
| \\\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox           |
|  \\\    /   O peration     | Version:  v1806                                 |
|   \\\  /    A nd           | Web:      www.OpenFOAM.com                      |
|    \\\/     M anipulation  |                                                 |
\*---------------------------------------------------------------------------*/
FoamFile
{
version     2.0;
format      ascii;
class       volScalarField;
location    "0";
object      nutCoeffs'''+str(i)+''';
}
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //
dimensions      [0 0 0 0 0 0 0];

internalField   nonuniform List<scalar> \n'''+

    str(nCells)+'''\n(\n''')

    for j in range(nCells):
        outputFile.write(str(expGpCoeffs[j][0]) + "\n")
    
    outputFile.write('''\
)
;

boundaryField
{
    "(inlet|outlet)"
    {
        type            zeroGradient;
    }''')
    
    if phyDim==2 :
        outputFile.write('''
        "(front|back)"
        {
            type            empty;
        }''')
        
    if phyDim==3 :
        outputFile.write('''
        "(front|back)"
        {
            type            zeroGradient;
        }''')
    
    outputFile.write('''
    "(top|hills)"
    {
     	type            zeroGradient;
    }
}

''')
    outputFile.close()
    
# <codecell> 
"""
writing gPC coeffients 
"""
def writeExpGpPCECoeffsCyl(i, expGpCoeffs, nCells, dirName, phyDim):
    outputFile = open(dirName+"expGpCoeffs"+str(i),"w+")
    
    outputFile.write('''\
/*--------------------------------*- C++ -*----------------------------------*\\
| =========                 |                                                 |
| \\\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox           |
|  \\\    /   O peration     | Version:  v1806                                 |
|   \\\  /    A nd           | Web:      www.OpenFOAM.com                      |
|    \\\/     M anipulation  |                                                 |
\*---------------------------------------------------------------------------*/
FoamFile
{
version     2.0;
format      ascii;
class       volScalarField;
location    "0";
object      nutCoeffs'''+str(i)+''';
}
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //
dimensions      [0 0 0 0 0 0 0];

internalField   nonuniform List<scalar> \n'''+

    str(nCells)+'''\n(\n''')

    for j in range(nCells):
        outputFile.write(str(expGpCoeffs[j][0]) + "\n")
    
    outputFile.write('''\
)
;

boundaryField
{
    "(right|left|cylinder)"
    {
        type            zeroGradient;
    }''')
    
    if phyDim==2 :
        outputFile.write('''
        "(front|back)"
        {
            type            empty;
        }''')
        
    if phyDim==3 :
        outputFile.write('''
        "(front|back)"
        {
            type            zeroGradient;
        }
}''')

    outputFile.close()
    
# <codecell> 
"""
writing gPC coeffients 
"""
def writeExpGpPCECoeffsWT(i, expGpCoeffs, nCells, dirName, phyDim):
    outputFile = open(dirName+"expGpCoeffs"+str(i),"w+")
    
    outputFile.write('''\
/*--------------------------------*- C++ -*----------------------------------*\\
| =========                 |                                                 |
| \\\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox           |
|  \\\    /   O peration     | Version:  v1806                                 |
|   \\\  /    A nd           | Web:      www.OpenFOAM.com                      |
|    \\\/     M anipulation  |                                                 |
\*---------------------------------------------------------------------------*/
FoamFile
{
version     2.0;
format      ascii;
class       volScalarField;
location    "0";
object      expGpCoeffs'''+str(i)+''';
}
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //
dimensions      [0 0 0 0 0 0 0];

internalField   nonuniform List<scalar> \n'''+

    str(nCells)+'''\n(\n''')

    for j in range(nCells):
        outputFile.write(str(expGpCoeffs[j][0]) + "\n")
    
    outputFile.write('''\
)
;

boundaryField
{
    "(.*)"
    {
        type            zeroGradient;
    }
}

''')
    outputFile.close()
    
# <codecell> 
"""
writing gPC-KLE modes of lognormal nut
"""
def writeGmatPCEModes(i, GMode, nCells, dirName, phyDim):
    outputFile = open(dirName+"GCoeffs"+str(i),"w+")
    
    outputFile.write('''\
/*--------------------------------*- C++ -*----------------------------------*\\
| =========                 |                                                 |
| \\\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox           |
|  \\\    /   O peration     | Version:  v1806                                 |
|   \\\  /    A nd           | Web:      www.OpenFOAM.com                      |
|    \\\/     M anipulation  |                                                 |
\*---------------------------------------------------------------------------*/
FoamFile
{
version     2.0;
format      ascii;
class       volTensorField;
location    "0";
object      GCoeffs'''+str(i)+''';
}
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //
dimensions      [0 0 0 0 0 0 0];

internalField   nonuniform List<tensor> \n'''+

    str(nCells)+'''\n(\n''')

    for j in range(nCells):
        outputFile.write('''( ''')
        for p in range(3):
            for q in range(3):
                outputFile.write(str(GMode[j,p,q]) + " ")
        outputFile.write(''')\n''')
    
    outputFile.write('''\
)
;

boundaryField
{
    "(inlet|outlet)"
    {
        type            zeroGradient;
    }''')
    
    if phyDim==2 :
        outputFile.write('''
        "(front|back)"
        {
            type            empty;
        }''')
        
    if phyDim==3 :
        outputFile.write('''
        "(front|back)"
        {
            type            zeroGradient;
        }''')
    
    outputFile.write('''
    "(top|hills)"
    {
        type            zeroGradient;
    }
}

''')
    outputFile.close()
    
# <codecell> 
"""
writing gPC-KLE modes of lognormal nut
"""
def writeGmatPCEModesCyl(i, GMode, nCells, dirName, phyDim):
    outputFile = open(dirName+"GCoeffs"+str(i),"w+")
    
    outputFile.write('''\
/*--------------------------------*- C++ -*----------------------------------*\\
| =========                 |                                                 |
| \\\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox           |
|  \\\    /   O peration     | Version:  v1806                                 |
|   \\\  /    A nd           | Web:      www.OpenFOAM.com                      |
|    \\\/     M anipulation  |                                                 |
\*---------------------------------------------------------------------------*/
FoamFile
{
version     2.0;
format      ascii;
class       volTensorField;
location    "0";
object      GCoeffs'''+str(i)+''';
}
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //
dimensions      [0 0 0 0 0 0 0];

internalField   nonuniform List<tensor> \n'''+

    str(nCells)+'''\n(\n''')

    for j in range(nCells):
        outputFile.write('''( ''')
        for p in range(3):
            for q in range(3):
                outputFile.write(str(GMode[j,p,q]) + " ")
        outputFile.write(''')\n''')
    
    outputFile.write('''\
)
;

boundaryField
{
    "(right|left|cylinder)"
    {
        type            zeroGradient;
    }''')
    
    if phyDim==2 :
        outputFile.write('''
        "(front|back)"
        {
            type            empty;
        }''')
        
    if phyDim==3 :
        outputFile.write('''
        "(front|back)"
        {
            type            zeroGradient;
        }
}

''')
    outputFile.close()
    
# <codecell> 
"""
writing gPC coeffients 
"""
def writeExpGpPCECoeffsDuct(i, expGpCoeffs, nCells, dirName, phyDim):
    outputFile = open(dirName+"expGpCoeffs"+str(i),"w+")
    
    outputFile.write('''\
/*--------------------------------*- C++ -*----------------------------------*\\
| =========                 |                                                 |
| \\\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox           |
|  \\\    /   O peration     | Version:  v1806                                 |
|   \\\  /    A nd           | Web:      www.OpenFOAM.com                      |
|    \\\/     M anipulation  |                                                 |
\*---------------------------------------------------------------------------*/
FoamFile
{
version     2.0;
format      ascii;
class       volScalarField;
location    "0";
object      expGpCoeffs'''+str(i)+''';
}
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //
dimensions      [0 0 0 0 0 0 0];

internalField   nonuniform List<scalar> \n'''+

    str(nCells)+'''\n(\n''')

    for j in range(nCells):
        outputFile.write(str(expGpCoeffs[j][0]) + "\n")
    
    outputFile.write('''\
)
;

boundaryField
{
    inlet
    {
        type            cyclic;
    }
    outlet
    {
        type            cyclic;
    }
    fixedWalls
    {
        type            zeroGradient;
    }
    "symmPlanes.*"
    {
        type            symmetryPlane;
    }
}

''')
    outputFile.close()
    
# <codecell> 
"""
writing gPC-KLE modes of lognormal nut
"""
def writeGmatPCEModesDuct(i, GMode, nCells, dirName, phyDim):
    outputFile = open(dirName+"GCoeffs"+str(i),"w+")
    
    outputFile.write('''\
/*--------------------------------*- C++ -*----------------------------------*\\
| =========                 |                                                 |
| \\\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox           |
|  \\\    /   O peration     | Version:  v1806                                 |
|   \\\  /    A nd           | Web:      www.OpenFOAM.com                      |
|    \\\/     M anipulation  |                                                 |
\*---------------------------------------------------------------------------*/
FoamFile
{
version     2.0;
format      ascii;
class       volTensorField;
location    "0";
object      GCoeffs'''+str(i)+''';
}
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //
dimensions      [0 0 0 0 0 0 0];

internalField   nonuniform List<tensor> \n'''+

    str(nCells)+'''\n(\n''')

    for j in range(nCells):
        outputFile.write('''( ''')
        for p in range(3):
            for q in range(3):
                outputFile.write(str(GMode[j,p,q]) + " ")
        outputFile.write(''')\n''')
    
    outputFile.write('''\
)
;

boundaryField
{''')
    if phyDim==2:
        outputFile.write('''
    inlet
    {

        type cyclic;
    }
    outlet
    {
        type cyclic;
    }
    wall // fixedWalls
    {
        type zeroGradient;
    }
    /*"symmPlanes.*"
    {
        type            symmetryPlane;
    }*/
}
    
''')
    elif phyDim==3:
        outputFile.write('''
    inlet
    {

        type zeroGradient;
    }
    outlet
    {
        type zeroGradient;
    }
    fixedWalls
    {
        type zeroGradient;
    }
}

''')

    outputFile.close()


# <codecell> 
"""
writing gPC-KLE modes of lognormal nut
"""
def writeGmatPCEModesWT(i, GMode, nCells, dirName, phyDim):
    outputFile = open(dirName+"GCoeffs"+str(i),"w+")
    
    outputFile.write('''\
/*--------------------------------*- C++ -*----------------------------------*\\
| =========                 |                                                 |
| \\\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox           |
|  \\\    /   O peration     | Version:  v1806                                 |
|   \\\  /    A nd           | Web:      www.OpenFOAM.com                      |
|    \\\/     M anipulation  |                                                 |
\*---------------------------------------------------------------------------*/
FoamFile
{
version     2.0;
format      ascii;
class       volTensorField;
location    "0";
object      GCoeffs'''+str(i)+''';
}
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //
dimensions      [0 0 0 0 0 0 0];

internalField   nonuniform List<tensor> \n'''+

    str(nCells)+'''\n(\n''')

    for j in range(nCells):
        outputFile.write('''( ''')
        for p in range(3):
            for q in range(3):
                outputFile.write(str(GMode[j,p,q]) + " ")
        outputFile.write(''')\n''')
    
    outputFile.write('''\
)
;

boundaryField
{
    "(.*)"
    {
        type            zeroGradient;
    }
}
''')

    outputFile.close()
    
    
# <codecell> 
"""
writing gPC-KLE modes of lognormal nut
"""
def writeRSamplesDuct(i, RSample, nCells, dirName, phyDim):
    outputFile = open(dirName+"RSample"+str(i),"w+")
    
    outputFile.write('''\
/*--------------------------------*- C++ -*----------------------------------*\\
| =========                 |                                                 |
| \\\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox           |
|  \\\    /   O peration     | Version:  v1806                                 |
|   \\\  /    A nd           | Web:      www.OpenFOAM.com                      |
|    \\\/     M anipulation  |                                                 |
\*---------------------------------------------------------------------------*/
FoamFile
{
version     2.0;
format      ascii;
class       volSymmTensorField;
location    "0";
object      R;
}
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //
dimensions      [0 2 -2 0 0 0 0];

internalField   nonuniform List<symmTensor> \n'''+

    str(nCells)+'''\n(\n''')

    for j in range(nCells):
        outputFile.write('''( ''')
        for p in range(3):
            for q in range(3):
                if (q>=p): # for volSymmTensorField
                    outputFile.write(str(RSample[j,p,q]) + " ")
        outputFile.write(''')\n''')
    
    outputFile.write('''\
)
;

boundaryField
{''')
    if phyDim==2:
        outputFile.write('''
    inlet
    {
        type cyclic;
    }
    outlet
    {
        type cyclic;
    }
    wall
    //fixedWalls
    {
        type            fixedValue;
        value           uniform (0 0 0 0 0 0);
    }
    /*
    "symmPlanes.*"
    {
        type            symmetryPlane;
    }//*/
}
    
''')

    outputFile.close()
    
# <codecell> 
"""
writing gPC-KLE modes of lognormal nut
"""
def writeUDuct(U, nCells, fileName, dirName, phyDim):
    outputFile = open(dirName+fileName,"w+")
    
    outputFile.write('''\
/*--------------------------------*- C++ -*----------------------------------*\\
| =========                 |                                                 |
| \\\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox           |
|  \\\    /   O peration     | Version:  v1806                                 |
|   \\\  /    A nd           | Web:      www.OpenFOAM.com                      |
|    \\\/     M anipulation  |                                                 |
\*---------------------------------------------------------------------------*/
FoamFile
{
version     2.0;
format      ascii;
class       volVectorField;
location    "1000";
object      '''+fileName+''';
}
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //
dimensions      [0 1 -1 0 0 0 0];

internalField   nonuniform List<vector> \n'''+

    str(nCells)+'''\n(\n''')

    for j in range(nCells):
        outputFile.write('''( ''')
        for p in range(3):
            outputFile.write(str(U[j,p])+' ')
        outputFile.write(''')\n''')
    
    outputFile.write('''\
)
;

boundaryField
{
    inlet
    {

        type cyclic;
    }
    outlet
    {
        type cyclic;
    }
    wall  
    //fixedWalls
    {
        type    fixedValue;
        value   uniform (0 0 0);
    }
    /*
    "symmPlanes.*"
    {
        type            symmetryPlane;
    }//*/
}
    
''')