# forwardModel

Framework for non-linear fitting of parameterized models to fMRI time-series data.

The fMRI data are passed as a voxel x time matrix; the stimulus is specified in a matrix with the temporal domain as the last dimension. Data and stimuli from multiple acquisitions may be passed in as a cell array of matrices. The stimulus may have a different temporal resolution than the data, in which case the key-value stimTime defines the mapping between stimulus and data. All voxels in the data are processed unless a subset are specified in the key-value vxs.

The key-value modelClass determines the model to be fit to the data. Each model is implemented as an object oriented class within the models directory. The behavior of the model may be controlled by passing modelOpts, and by passing additional materials in the modelPayload.

Multiple, cascading stages of non-linear fitting are supported with the ability to define sets of parameters that are fixed or float in a given search, with the results of a search passing to initialize the next stage.

This framework uses several utility functions from Kendrick Kay's analyzePRF toolbox:

	https://github.com/kendrickkay/analyzePRF

The pRF modelClass draws from Kendricks' code in the approach to creating seeds, and the inclusion of a compressive non-linearity in the modeled neural response, which is taken from:

  Kay KN, Winawer J, Mezer A and Wandell BA (2013) Compressive spatial summation in human visual cortex. J. Neurophys. doi: 10.1152/jn.00105.2013

The pRF modelClass implemented here differs from Kendrick's original code in a few ways:
  - The HRF is with FLOBS parameters
  - For retinotopic mapping designs that play the same stimulus forward and reverse in time, the model will estimate a shift of the HRF time-to-peak to best fit the data.
  - Upper and lower bounds are enforced with an fmincon search.
