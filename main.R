library(RODBC)
library(aqp)
library(rgdal)
library(maps)
library(plyr)
library(latticeExtra)
library(hexbin)
library(rms)
library(RPostgreSQL)


## TODO: the Bulk_Density_and_Moisture table as some data split over multiple rows, filtering for now using prep_code = 'S'

## TODO: flag and fix pedons with bad horizonation
## CA Data NOTE: MLRA derived from the site area overlap table cannot be trusted
## CA Data NOTE: SoilVeg pedons have saturated paste pH...
## CA Data NOTE: missing bs82 estimated via bs7
## CA Data NOTE: C and N values of 0 are replaced with NA

## !!! aggregating (via slab) profiles with missing horizons fills memory... filtering complete profiles removes some good data
## !!! filtering based on prep code may exclude some good data !!! figure this out


## extract data from Access DB
# This requires 32bit R and libraries ...
# saves 's' and 'h' to 'S:/NRCS/Lab_Data/cached-data/kssl-site-and-horizon-data.Rda'
source('extract-from-access-DB.R')

## clean-up data
# estimate pH 1:1 water, oc, om
# saves 'lab' to 'cached-data/kssl-SPC.Rda'
source('data-cleaning.R')

## Sonora office specific
# estimate BS82 from BS7
# subset to MLRAs 17, 18, 22A
source('sonora-office-specific-stuff.R')

## now update SoilWeb with new data




