# mtSinai

This model was used to analyze the temporal sensitivity data collected at the Mt Sinai 7T scanner, and reported in Patterson et al,. 2022.

The model simultaneously fits the shape of the HRF (using the FLOBS components), and the neural amplitude parameters for a conventional linear model. The model minimizes the L2 norm of the model fit.

The model accepts several key-values, which are used to create a nuanced metric value. These key-values include:

  stimLabels    - A cell array of char vectors, one for each row of the
                  stimulus matrix.
  confoundStimLabel - A char vector that matches a particular stimLabel.
                  This stimulus condition will be considered a
                  "confound", and its effects removed in calculating the
                  metric.
  avgAcqIdx - A cell array of vectors, all of the same length, with a
                  total length equal to the length of the data. This
                  vector controls how the data and model time-series from
                  various acquisitions may be averaged together. Consider
                  an experiment that has 6 acquisitions of length 100,
                  consisting of 3 repetitions of the same stimulus
                  sequence (with each sequence split over two
                  acquisitions). To average these time-series together,
                  one would pass {[1:200],[201:400],[401:600]};

These key-values are used to compute an R-squared metric. First, the effect of the confoundStimLabel is partialed from the timeSeries data, and this effect is excluded from the model. Then, the timeSeries data and the model are averaged following the avgAcqIdx function. Finally, the square of the correlation between the resulting timeSeries and model is obtained and stored. While the metric is not used for model fitting, it is available as a way of evaluating the overall explanatory power of the model, without the influence of the confound stimulus label.

In the context of the temporal sensitivity experiment, this model was used to remove the effect of an attention event when judging the explanatory power of the time-series model fit.
