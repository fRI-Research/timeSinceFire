defineModule(sim, list(
  name = "timeSinceFire",
  description = "This tracks time since fire for the LandWeb application.",
  keywords = c("fire", "LandWeb"),
  authors = c(person(c("Steve", "G"), "Cumming", email = "stevec@sbf.ulaval.ca", role = c("aut", "cre"))),
  childModules = character(),
  version = list(SpaDES.core = "0.2.3.9009", numeric_version("1.2.1")),
  spatialExtent = raster::extent(rep(NA_real_, 4)),
  timeframe = as.POSIXlt(c(NA, NA)),
  timeunit = "year",
  citation = list(),
  documentation = list("README.txt", "timeSinceFire.Rmd"),
  reqdPkgs = list("raster"),
  parameters = rbind(
    #defineParameter("paramName", "paramClass", value, min, max, "parameter description")),
    defineParameter("returnInterval", "numeric", 1.0, NA, NA, desc = "interval between main events"),
    defineParameter("startTime","numeric", 0, NA, NA, desc = "time of first burn event"),
    defineParameter(".plotInitialTime", "numeric", NA, NA, NA,
                    desc = "simulation time at which the first plot event should occur"),
    defineParameter(".plotInterval", "numeric", NA, NA, NA,
                    desc = "simulation time at which the first plot event should occur"),
    defineParameter(".saveInitialTime", "numeric", NA, NA, NA,
                    desc = "simulation time at which the first save event should occur"),
    defineParameter(".saveInterval", "numeric", NA, NA, NA,
                    desc = "simulation time at which the first save event should occur"),
    defineParameter(".useCache", "logical", FALSE, NA, NA,
                    desc = "simulation time at which the first save event should occur")
  ),
  inputObjects = data.frame(
    objectName = c("rstFlammable", "fireReturnInterval", "rstCurrentBurn", "fireTimestep"),
    objectClass = c("RasterLayer","RasterLayer", "RasterLayer", "numeric"),
    sourceURL = "",
    desc = c("A binary Raster, where 1 means 'can burn' ",
             "A Raster where the pixels represent the fire return interval, in years",
             "A binary Raster, where 1 means that there was a fire in the current year in that pixel",
             "The time between burn events, in years. Only tested with this equal to 1"),
    stringsAsFactors = FALSE
  ),
  outputObjects = data.frame(
    objectName = c("rstTimeSinceFire", "burnLoci"),
    objectClass = c("RasterLayer", "numeric"),
    desc = c("A Raster where the pixels represent the number of years since last burn.",
             "A integer vector of cell indices where burns occurred in the latest year. It is derived from rstCurrentBurn"),
    stringsAsFactors = FALSE
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
    fireTimestep <- if (is.null(sim$fireTimestep)) P(sim)$returnInterval else sim$fireTimestep
    sim$rstTimeSinceFire[] <- as.integer(sim$rstTimeSinceFire[]) + as.integer(fireTimestep) # preserves NAs
    sim$rstTimeSinceFire[sim$burnLoci] <- 0L
    # schedule next age event
    sim <- scheduleEvent(sim, time(sim) + fireTimestep, "timeSinceFire", "age")
  } else if (eventType == "plot") {
    rtsf <- sim$rstTimeSinceFire
    plotFn(rtsf, title = "Time since fire (age)", new = TRUE)
    # schedule next plot event
    sim <- scheduleEvent(sim, time(sim) + P(sim)$.plotInterval, "timeSinceFire", "plot")
  } else if (eventType == "save") {
    # ! ----- EDIT BELOW ----- ! #
    # do stuff for this event

    # e.g., call your custom functions/methods here
    # you can define your own methods below this `doEvent` function

    # schedule future event(s)

    # e.g.,
    # sim <- scheduleEvent(sim, time(sim) + increment, "timeSinceFire", "save")

    # ! ----- STOP EDITING ----- ! #
  } else {
    warning(paste("Undefined event type: '", current(sim)[1, "eventType", with = FALSE],
                  "' in module '", current(sim)[1, "moduleName", with = FALSE], "'", sep = ""))
  }
  return(invisible(sim))
}

## event functions
#   - follow the naming convention `modulenameEventtype()`;
#   - `modulenameInit()` function is required for initialization;
#   - keep event functions short and clean, modularize by calling subroutines from section below.

### template initialization
Init <- function(sim) {
  if (is.null(sim$burnLoci)) {
    sim$burnLoci <- which(sim$rstCurrentBurn[] == 1)
  }

  if (is.null(sim$rstTimeSinceFire)) {
    if (is.null(sim$fireReturnInterval)) {
      stop(currentModule(sim), " needs a rstTimeSinceFire map. If this does not exist, then passing ",
           "a fireReturnInterval map will assign the fireReturnInterval as rstTimeSinceFire")

    }
    # Much faster than calling rasterize() again
    sim$rstTimeSinceFire <- sim$fireReturnInterval
    #sim$rstTimeSinceFire[] <- factorValues(sim$rasterToMatch, sim$rasterToMatch[],
    #                                       att = "fireReturnInterval")[[1]]
    sim$rstTimeSinceFire[sim$rstFlammable[] == 0L] <- NA #non-flammable areas are permanent.
    sim$rstTimeSinceFire[] <- as.integer(sim$rstTimeSinceFire[])
  }
  return(invisible(sim))
}

plotFn <- function(rtsf, title = "Time since fire (age)", new = TRUE) {
  Plot(rtsf, title = title, new = new)
}
