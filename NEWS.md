Known issues: <https://github.com/fRI-Research/timeSinceFire/issues>

# timeSinceFire 3.0.0 (2025-10-14)

Note: this module is being retired in LandWeb v3, superseded by the
`NRV_summary` module together with the `nrvtools` package. This is the final
release of `timeSinceFire`.

* completed the migration to `terra`: dropped `raster` from `reqdPkgs`
  (now `terra` only).
* replaced `prepInputsLCC(year = 2005)` with
  `LandR::prepInputs_SCANFI_LCC_FAO(year = 2020)`, using `cropTo` in place of
  `studyArea`/`rasterToMatch`.
* pinned inputs-only dependencies `PredictiveEcology/LandR@development` and
  `PredictiveEcology/reproducible@development`.
* named the module in the version metadata
  (`version = list(timeSinceFire = ...)`) and removed a duplicate metadata
  block left behind by a merge conflict.
* removed the `plotFn()` helper; `startTime` now defaults to `start(sim)` and
  `fireTimestep` uses an integer literal.
* updated authorship roles, description, and keywords; dependency fixes and
  minor cleanup.

# timeSinceFire 2.1.0 (2024-05-07)

* added explicit `loadOrder` metadata (run after `fireSense_SpreadPredict`,
  `LandMine`, `scfmSpread`, and `LandWeb_output`).
* shortened the module description.

# timeSinceFire 2.0.0 (2023-09-21)

* migrated raster inputs/outputs to `terra`: `fireReturnInterval`,
  `rstCurrentBurn`, `rstFlammable`, and `rstTimeSinceFire` changed from
  `RasterLayer` to `SpatRaster`, and `terra` was added to `reqdPkgs`. (The
  commit that did this is labelled "use raster instead of terra", but the diff
  moves the module onto `terra`/`SpatRaster`.)
* replaced `compareRaster()` with `compareGeom()` (uses `ext`, not `extent`).
* removed a stray `browser()` call.
* use `inputPath()` instead of `dataPath()`.

# timeSinceFire 1.2.1 (2018-05-31)

* module update (pre-`terra` era; `raster`-based).
