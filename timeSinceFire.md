---
title: "timeSinceFire Manual"
subtitle: "v.3.0.0"
date: "Last updated: 2025-10-06"
output:
  bookdown::html_document2:
    toc: true
    toc_float: true
    theme: sandstone
    number_sections: false
    df_print: paged
    keep_md: yes
editor_options:
  chunk_output_type: console
  bibliography: citations/references_timeSinceFire.bib
citation-style: citations/ecology-letters.csl
link-citations: true
always_allow_html: true
---

# timeSinceFire Module

<!-- the following are text references used in captions for LaTeX compatibility -->
(ref:timeSinceFire) *timeSinceFire*



:::{.rmdwarning}
This documentation is work in progress.
Please report any discrepancies or omissions at <https://github.com/fRI-Research/timeSinceFire/issues>.
:::

#### Authors:

Steve G Cumming <stevec@sbf.ulaval.ca> [aut], Alex M. Chubaty <achubaty@for-cast.ca> [aut, cre]
<!-- ideally separate authors with new lines, '\n' not working -->

## Module Overview

### Module summary

Yet Another Age Map Maintainer.

`ageMap` is incremented without bound on all flammable cells;
cells identified as having been burned in the current year are set to 0.

### Module inputs and parameters

Table \@ref(tab:moduleInputs-timeSinceFire) shows the full list of module inputs.

<table class="table" style="color: black; width: auto !important; margin-left: auto; margin-right: auto;">
<caption>(\#tab:moduleInputs-timeSinceFire)(\#tab:moduleInputs-timeSinceFire)List of (ref:timeSinceFire) input objects and their description.</caption>
 <thead>
  <tr>
   <th style="text-align:left;"> objectName </th>
   <th style="text-align:left;"> objectClass </th>
   <th style="text-align:left;"> desc </th>
   <th style="text-align:left;"> sourceURL </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> fireReturnInterval </td>
   <td style="text-align:left;"> SpatRaster </td>
   <td style="text-align:left;"> A Raster where the pixels represent the fire return interval, in years. </td>
   <td style="text-align:left;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> rstCurrentBurn </td>
   <td style="text-align:left;"> SpatRaster </td>
   <td style="text-align:left;"> Binary raster of fires, 1 meaning 'burned', 0 or NA is non-burned </td>
   <td style="text-align:left;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> rstFlammable </td>
   <td style="text-align:left;"> SpatRaster </td>
   <td style="text-align:left;"> A binary Raster, where 1 means 'can burn'. </td>
   <td style="text-align:left;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> rstTimeSinceFire </td>
   <td style="text-align:left;"> SpatRaster </td>
   <td style="text-align:left;"> A Raster where the pixels represent the number of years since last burn. </td>
   <td style="text-align:left;"> NA </td>
  </tr>
</tbody>
</table>

A summary of user-visible parameters is provided in Table \@ref(tab:moduleParams-timeSinceFire).

<table class="table" style="color: black; width: auto !important; margin-left: auto; margin-right: auto;">
<caption>(\#tab:moduleParams-timeSinceFire)(\#tab:moduleParams-timeSinceFire)List of (ref:timeSinceFire) parameters and their description.</caption>
 <thead>
  <tr>
   <th style="text-align:left;"> paramName </th>
   <th style="text-align:left;"> paramClass </th>
   <th style="text-align:left;"> default </th>
   <th style="text-align:left;"> min </th>
   <th style="text-align:left;"> max </th>
   <th style="text-align:left;"> paramDesc </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> fireTimestep </td>
   <td style="text-align:left;"> integer </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> The number of time units between successive fire events. </td>
  </tr>
  <tr>
   <td style="text-align:left;"> returnInterval </td>
   <td style="text-align:left;"> numeric </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> interval between main events </td>
  </tr>
  <tr>
   <td style="text-align:left;"> startTime </td>
   <td style="text-align:left;"> numeric </td>
   <td style="text-align:left;"> 0 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> time of first burn event </td>
  </tr>
  <tr>
   <td style="text-align:left;"> .plotInitialTime </td>
   <td style="text-align:left;"> numeric </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> simulation time at which the first plot event should occur </td>
  </tr>
  <tr>
   <td style="text-align:left;"> .plotInterval </td>
   <td style="text-align:left;"> numeric </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> simulation time at which the first plot event should occur </td>
  </tr>
  <tr>
   <td style="text-align:left;"> .plots </td>
   <td style="text-align:left;"> character </td>
   <td style="text-align:left;"> screen </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> Passed to `types` in `Plots` (see `?Plots`). There are a few plots that are made within this module, if set. Note that plots (or their data) saving will ONLY occur at `end(sim)`. If `NA`, plotting is turned off completely (this includes plot saving). </td>
  </tr>
  <tr>
   <td style="text-align:left;"> .saveInitialTime </td>
   <td style="text-align:left;"> numeric </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> simulation time at which the first save event should occur </td>
  </tr>
  <tr>
   <td style="text-align:left;"> .saveInterval </td>
   <td style="text-align:left;"> numeric </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> simulation time at which the first save event should occur </td>
  </tr>
  <tr>
   <td style="text-align:left;"> .useCache </td>
   <td style="text-align:left;"> logical </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> simulation time at which the first save event should occur </td>
  </tr>
</tbody>
</table>

### Events

#### Init

The `Init` event creates the RasterLayer `rstTimeSinceFire`.
To do this, it rasterizes the template vegetation map `LCC05` using the `FireReturnInterval` field of the `studyAreaReporting` polygons.
This procedure retains the `NA`s which mask the actual study region within the template bounding rectangle. 

Then, the `rstFlammable` raster is used to mask out areas of open water, rock, ice, etc. which can't burn and thus for which `timeSinceFire` is not applicable.
These become `NA`s in `rstTimeSinceFire`. 

The results is that all flammable cells within each polygon are set to the fire return interval specified for that polygon.
Under the basic van Wagner model being implemented, this is the expected landscape mean age.
The polygon age structure will equilibrate to the exponential distribution within a few multiples of the return interval. 

No colour ramp or legend is created for this layer.

In the short term, this initial uniform age distribution will result in very high proportions of cells with TSFs greater than the return interval.
If this becomes a problem, one could initialize to the regional median age.
This can be done by multiplying the `FireReturnInterval` by $log(2)$ and then rounding; or some other lower quantile could be chosen: see the [wikipedia page](https://en.wikipedia.org/wiki/Exponential_distribution) for the general quantile function.

Alternatively, a random exponential age structure could be generated for each polygon from the current `rstTimeSinceFire`, roughly as follows.
See the wiki page for details and possible alternative methods.


``` r
U_ <- runif(ncell(rstTimeSinceFire))
T_ <- (-log(U_)) * rstTimeSinceFire[]
rstTimeSinceFire[] <- round(T_)
```

#### Plotting

A bare call to `terra::plot(sim$rstTimeSinceFire)`.
If you really want to see this, you'll have to live with the automated colour scheme and legend, or hack `Init` to your satisfaction.

#### Saving

Nothing is saved at present. 

#### Age

This is the main event: `rstFlammable` is incremented by one.
Then burned cells, as specified in the `burnLoci` vector are set to age 0.

### Module outputs

Description of the module outputs (Table \@ref(tab:moduleOutputs-timeSinceFire)).

<table class="table" style="color: black; width: auto !important; margin-left: auto; margin-right: auto;">
<caption>(\#tab:moduleOutputs-timeSinceFire)(\#tab:moduleOutputs-timeSinceFire)List of (ref:timeSinceFire) outputs and their description.</caption>
 <thead>
  <tr>
   <th style="text-align:left;"> objectName </th>
   <th style="text-align:left;"> objectClass </th>
   <th style="text-align:left;"> desc </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> burnLoci </td>
   <td style="text-align:left;"> integer </td>
   <td style="text-align:left;"> Cell indices where burns occurred in the latest year. It is derived from `rstCurrentBurn`. </td>
  </tr>
  <tr>
   <td style="text-align:left;"> rstTimeSinceFire </td>
   <td style="text-align:left;"> SpatRaster </td>
   <td style="text-align:left;"> A Raster where the pixels represent the number of years since last burn. </td>
  </tr>
</tbody>
</table>

### Code and data availability

Code available from <https://github.com/fRI-Research/timeSinceFire>.

### Links to other modules

Originally developed as part of the [LandWeb](https://github.com/PredictiveEcology/LandWeb) project.
