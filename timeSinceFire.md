---
title: "timeSinceFire Manual"
subtitle: "v.1.2.1"
date: "Last updated: 2022-11-08"
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



[![made-with-Markdown](figures/markdownBadge.png)](http://commonmark.org)

<!-- if knitting to pdf remember to add the pandoc_args: ["--extract-media", "."] option to yml in order to get the badge images -->

#### Authors:

Steve G Cumming <stevec@sbf.ulaval.ca> [aut, cre], Alex M Chubaty <achubaty@for-cast.ca> [ctb]
<!-- ideally separate authors with new lines, '\n' not working -->

## Module Overview

### Module summary

Yet Another Age Map Maintainer.
This one is peculiar to the LandWeb application.

`ageMap` is incremented without bound on all flammable cells;
cells identified as having been burned in the current year are set to 0.

Any statistics on age structure are to be calculated here, but none are yet implemented...because with the current fire model they would be pretty boring. 

### Module inputs and parameters

Table \@ref(tab:moduleInputs-timeSinceFire) shows the full list of module inputs.

<table class="table" style="margin-left: auto; margin-right: auto;">
<caption>(\#tab:moduleInputs-timeSinceFire)List of (ref:timeSinceFire) input objects and their description.</caption>
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
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
  </tr>
</tbody>
</table>

A summary of user-visible parameters is provided in Table \@ref(tab:moduleParams-timeSinceFire).

<table class="table" style="margin-left: auto; margin-right: auto;">
<caption>(\#tab:moduleParams-timeSinceFire)List of (ref:timeSinceFire) parameters and their description.</caption>
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
   <td style="text-align:left;"> .plots </td>
   <td style="text-align:left;"> character </td>
   <td style="text-align:left;"> screen </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> Used by Plots function, which can be optionally used here </td>
  </tr>
  <tr>
   <td style="text-align:left;"> .plotInitialTime </td>
   <td style="text-align:left;"> numeric </td>
   <td style="text-align:left;"> start(sim) </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> Describes the simulation time at which the first plot event should occur. </td>
  </tr>
  <tr>
   <td style="text-align:left;"> .plotInterval </td>
   <td style="text-align:left;"> numeric </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> Describes the simulation time interval between plot events. </td>
  </tr>
  <tr>
   <td style="text-align:left;"> .saveInitialTime </td>
   <td style="text-align:left;"> numeric </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> Describes the simulation time at which the first save event should occur. </td>
  </tr>
  <tr>
   <td style="text-align:left;"> .saveInterval </td>
   <td style="text-align:left;"> numeric </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> This describes the simulation time interval between save events. </td>
  </tr>
  <tr>
   <td style="text-align:left;"> .studyAreaName </td>
   <td style="text-align:left;"> character </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> Human-readable name for the study area used - e.g., a hash of the studyarea obtained using `reproducible::studyAreaName()` </td>
  </tr>
  <tr>
   <td style="text-align:left;"> .seed </td>
   <td style="text-align:left;"> list </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> Named list of seeds to use for each event (names). </td>
  </tr>
  <tr>
   <td style="text-align:left;"> .useCache </td>
   <td style="text-align:left;"> logical </td>
   <td style="text-align:left;"> FALSE </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> Should caching of events or module be used? </td>
  </tr>
</tbody>
</table>

### Events

#### Init

The `Init` event creates the RasterLayer `rstTimeSinceFire`.
To do this, it rasterizes the template vegetation map `LCC05` using the `FireReturnInterval` field of the SpatialPoygonDataFrame `shpStudyRegion`.
This procedure retains the `NA`s which mask the actual study region within the template bounding rectangle. 

Then, the RasterLayer `rstFlammable` is used to mask out areas of open water, rock, etc which can't burn and thus for which `timeSinceFire` is not applicable.
These become `NA`s in `rstTimeSinceFire`. 

The results is that all flammable cells within each polygon in the shapefile are set to the fire return interval specified for that polygon / ecoregion.
Under the basic van Wagner model being implemented, this is the expected landscape mean age.
The ecoregion age structure will equilibrate to the exponential distribution within a few multiples of the return interval. 

No colour ramp or legend is created for this layer.

In the short term, this initial uniform age distribution will result in very high proportions of cells with tsf's greater than the return interval.
If this becomes a problem, one could initialize to the regional median age.
This can be done by multiplying the `FireReturnInterval` by $log(2)$ and then rounding; or some other lower quantile could be chosen: see the [wikipedia page](https://en.wikipedia.org/wiki/Exponential_distribution) for the general quantile function.

Alternatively, a random exponential age structure could be generated for each ecoregion from the current `rstTimeSinceFire`, roughly as follows.
See the wiki page for details and possible alternative methods.


```r
U_ <- runif(ncell(rstTimeSinceFire))
T_ <- (-log(U_)) * rstTimeSinceFire[]
rstTimeSinceFire[] <- round(T_)
```

#### Plotting

A bare call to `Plot(sim$rstTimeSinceFire)`.
If you really want to see this, you'll have to live with the automated colour scheme and legend, or hack `Init` to your satisfaction.

#### Saving

Nothing is saved at present. 

#### Age

This is the main event. `rstFlammable` is incremented by one.
Then burned cells, as specified in the input vector `burnLoci` are set to age 0.

### Module outputs

Description of the module outputs (Table \@ref(tab:moduleOutputs-timeSinceFire)).

<table class="table" style="margin-left: auto; margin-right: auto;">
<caption>(\#tab:moduleOutputs-timeSinceFire)List of (ref:timeSinceFire) outputs and their description.</caption>
 <thead>
  <tr>
   <th style="text-align:left;"> objectName </th>
   <th style="text-align:left;"> objectClass </th>
   <th style="text-align:left;"> desc </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
  </tr>
</tbody>
</table>

### Code and data availability

Code available from <https://github.com/fRI-Research/timeSinceFire>.

### Links to other modules

Originally developed as part of the [LandWeb](https://github.com/PredictiveEcology/LandWeb) project.
