defineModule(sim, list(
  name = "timeSinceFire",
  description = "This tracks time since fire for the LandWeb application.",
  keywords = c("fire", "LandWeb"),
  authors = c(
    person(c("Steve", "G"), "Cumming", email = "stevec@sbf.ulaval.ca", role = c("aut", "cre")),
    person(c("Alex", "M."), "Chubaty", email = "achubaty@for-cast.ca", role = c("ctb"))
  ),
  childModules = character(),
  version = list(numeric_version("2.0.0")),
  spatialExtent = raster::extent(rep(NA_real_, 4)),
  timeframe = as.POSIXlt(c(NA, NA)),
  timeunit = "year",
  citation = list(),
  documentation = list("README.md", "timeSinceFire.Rmd"), ## same file
  reqdPkgs = list("raster", "terra"),
  parameters = rbind(
    #defineParameter("paramName", "paramClass", value, min, max, "parameter description")),
    defineParameter("fireTimestep", "integer", 1, NA, NA,
                    desc = "The number of time units between successive fire events."),
    defineParameter("returnInterval", "numeric", 1.0, NA, NA, desc = "interval between main events"),
    defineParameter("startTime","numeric", 0, NA, NA, desc = "time of first burn event"),
    defineParameter(".plotInitialTime", "numeric", NA, NA, NA,
                    desc = "simulation time at which the first plot event should occur"),
    defineParameter(".plotInterval", "numeric", NA, NA, NA,
                    desc = "simulation time at which the first plot event should occur"),
    defineParameter(".plots", "character", c("screen"), NA, NA,
                    paste("Passed to `types` in `Plots` (see `?Plots`).",
                          "There are a few plots that are made within this module, if set.",
                          "Note that plots (or their data) saving will ONLY occur at `end(sim)`.",
                          "If `NA`, plotting is turned off completely (this includes plot saving).")),
    defineParameter(".saveInitialTime", "numeric", NA, NA, NA,
                    desc = "simulation time at which the first save event should occur"),
    defineParameter(".saveInterval", "numeric", NA, NA, NA,
                    desc = "simulation time at which the first save event should occur"),
    defineParameter(".useCache", "logical", FALSE, NA, NA,
                    desc = "simulation time at which the first save event should occur")
  ),
  inputObjects = bindrows(
    expectsInput("fireReturnInterval", "SpatRaster",
                 desc = "A Raster where the pixels represent the fire return interval, in years.",
                 sourceURL = NA),
    expectsInput("rstCurrentBurn", "SpatRaster",
                 desc = "Binary raster of fires, 1 meaning 'burned', 0 or NA is non-burned",
                 sourceURL = NA),
    expectsInput("rstFlammable", "SpatRaster",
                 desc = "A binary Raster, where 1 means 'can burn'.",
                 sourceURL = NA),
    expectsInput("rstTimeSinceFire", "SpatRaster",
                 sourceURL = NA,
                 desc = "A Raster where the pixels represent the number of years since last burn.")
  ),
  outputObjects = bindrows(
    createsOutput("burnLoci", "integer",
                  desc = paste("Cell indices where burns occurred in the latest year.",
                               "It is derived from `rstCurrentBurn`.")),
    createsOutput("rstTimeSinceFire", "SpatRaster",
                  desc = "A Raster where the pixels represent the number of years since last burn.")
  )
))

doEvent.timeSinceFire <- function(sim, eventTime, eventType, debug = FALSE) {
  if (eventType == "init") {
    ### check for more detailed object dependencies:
    ### (use `checkObject` or similar)

    # do stuff for this event
    sim <- Init(sim)

    # schedule future event(s)
    sim <- scheduleEvent(sim, P(sim)$.plotInitialTime, "timeSinceFire", "plot")
    sim <- scheduleEvent(sim, P(sim)$.saveInitialTime, "timeSinceFire", "save")
    sim <- scheduleEvent(sim, P(sim)$startTime, "timeSinceFire", "age")
  } else if (eventType == "age") {
    sim$burnLoci <- which(sim$rstCurrentBurn[] == 1)
    fireTimestep <- if (is.null(P(sim)$fireTimestep)) P(sim)$returnInterval else P(sim)$fireTimestep
    sim$rstTimeSinceFire[] <- as.integer(sim$rstTimeSinceFire[]) + as.integer(fireTimestep) # preserves NAs
    sim$rstTimeSinceFire[sim$burnLoci] <- 0L
    # schedule next age event
    sim <- scheduleEvent(sim, time(sim) + fireTimestep, "timeSinceFire", "age")
  } else if (eventType == "plot") {
    if (anyPlotting(P(sim)$.plots) && any(P(sim)$.plots == "screen")) {
      rtsf <- sim$rstTimeSinceFire
      plotFn(rtsf, title = "Time since fire (age)", new = TRUE)
      # schedule next plot event
      sim <- scheduleEvent(sim, time(sim) + P(sim)$.plotInterval, "timeSinceFire", "plot")
    }
  } else {
    warning(paste("Undefined event type: '", current(sim)[1, "eventType", with = FALSE],
                  "' in module '", current(sim)[1, "moduleName", with = FALSE], "'", sep = ""))
  }
  return(invisible(sim))
}

Init <- function(sim) {
  compareGeom(sim$fireReturnInterval, sim$rstCurrentBurn, sim$rstFlammable, sim$rstTimeSinceFire,
              crs = TRUE, extent = TRUE, rowcol = TRUE, res = TRUE)

  sim$burnLoci <- which(sim$rstCurrentBurn[] == 1)

  return(invisible(sim))
}

plotFn <- function(rtsf, title = "Time since fire (age)", new = TRUE) {
  Plot(rtsf, title = title, new = new)
}

.inputObjects <- function(sim) {
  cacheTags <- c(currentModule(sim), "function:.inputObjects")
  mod$dPath <- asPath(getOption("reproducible.destinationPath", dataPath(sim)), 1)
  message(currentModule(sim), ": using dataPath '", mod$dPath, "'.")

  # ! ----- EDIT BELOW ----- ! #

  if (!suppliedElsewhere("rstFlammable", sim)) {
    vegMap <- prepInputsLCC(
      year = 2005,
      destinationPath = dPath,
      studyArea = sim$studyArea,
      rasterToMatch = sim$rasterToMatch,
      userTags = c("prepInputsLCC", "studyArea")
    )
    vegMap[] <- asInteger(vegMap[])
    sim$rstFlammable <- defineFlammable(vegMap,
                                        mask = sim$rasterToMatch,
                                        nonFlammClasses = c(13L, 16L:19L))
  }

  if (!suppliedElsewhere("rstTimeSinceFire", sim)) {
    if (!suppliedElsewhere("fireReturnInterval", sim)) {
      stop(currentModule(sim), " needs a rstTimeSinceFire map. If this does not exist, then passing ",
           "a fireReturnInterval map will assign the fireReturnInterval as rstTimeSinceFire.")
    }
    ## Much faster than calling rasterize() again
    sim$rstTimeSinceFire <- sim$fireReturnInterval
    sim$rstTimeSinceFire[sim$rstFlammable[] == 0L] <- NA ## non-flammable areas are permanent
    sim$rstTimeSinceFire[] <- as.integer(sim$rstTimeSinceFire[])
  }

  # ! ----- STOP EDITING ----- ! #
  return(invisible(sim))
}
