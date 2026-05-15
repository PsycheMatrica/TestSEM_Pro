# TestSEM Pro

**TestSEM Pro** is a MATLAB toolbox for running Monte Carlo simulations to evaluate the performance of structural equation modeling (SEM) estimators across various model scenarios.

**Author:** GyeongCheol Cho  

**Repository:** https://github.com/PsycheMatrica/TestSEM_Pro

<img src="resources/TestSEM_Pro.png" alt="TestSEM Pro" width="350">

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.15844368.svg)](https://doi.org/10.5281/zenodo.15844368)
[![MATLAB R2025b](https://img.shields.io/badge/MATLAB-R2025b-blue)](https://www.mathworks.com/)

---

### Features

- Support for basic and higher-order SEM designs with both factors and components
- Support for interaction and CoMe analyses for component-based models
- Assessment of parameter recovery, convergence rates, rejection rates, and coverage
- Generation of comprehensive result summaries
- Example scripts for running simulations and summarizing results

---

### Supported Model Designs

| Analysis type | Supported constructs |
| --- | --- |
| Basic SEM design | Factors and components |
| Higher-order SEM design | Factors and components |
| Interaction analysis | Components |
| CoMe analysis | Components |

---

### Compatibility

- **Tested:** MATLAB R2025b on Windows/macOS/Linux
- **Likely works:** R2025a and newer

---

### Toolbox Requirements

- MATLAB
- Optimization Toolbox may be required for population model specification when `fmincon` is used.
- Parallel Computing Toolbox is required only when parallel computing options are enabled.

---

### Installation

Download the latest release from:

https://github.com/PsycheMatrica/TestSEM_Pro/releases/latest

Install the `.mltbx` file in MATLAB by double-clicking it or by opening it from MATLAB.

---

### Getting Started

For a brief entry point, open the MATLAB Live Script:

```matlab
open docs/GettingStarted.mlx
```

The **GettingStarted.mlx** file provides a brief entry point for setting up the toolbox and locating the example scripts. The example scripts themselves provide step-by-step instructions for running simulations and summarizing results.

---

### Typical Workflow

A typical workflow in **TestSEM Pro** is:

1. Initiate the three main inputs for the simulation study: `DGP`, `Estimators`, and `SimulationOption`.
   - Specify the type of data-generating process (DGP).
   - Specify the basic information about the DGP and the names of the estimators.
2. Enter detailed information for the three inputs.
   - Specify the true parameter values for the DGP.
   - Enter the estimation methods and their corresponding input arguments in `Estimators`.
   - Specify the simulation options in `SimulationOption`.
3. Run the simulation study.
4. Summarize and save the results.

---

### Citation

If you use **TestSEM Pro**, please cite:

 Cho, G. (2025). *TestSEM Pro: A MATLAB toolbox for Monte Carlo evaluation of structural equation modeling estimators* [Computer software]. Zenodo. https://doi.org/10.5281/zenodo.15844368
