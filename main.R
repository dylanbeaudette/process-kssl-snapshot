library(DBI)
library(aqp)
library(rgdal)
library(maps)
library(plyr)
library(latticeExtra)
library(hexbin)
library(viridis)
library(rms)
library(RPostgreSQL)


## TODO: transition to latest version of the LDM snapshot

## TODO: flag and fix pedons with bad horizonation
## CA Data NOTE: MLRA derived from the site area overlap table cannot be trusted
## CA Data NOTE: SoilVeg pedons have saturated paste pH...
## CA Data NOTE: missing bs82 estimated via bs7
## CA Data NOTE: C and N values of 0 are replaced with NA

## LIMS horizon data
## 2017-09-11: now based on SQLite DB
# saves 's' and 'h' to 'S:/NRCS/Lab_Data/cached-data/kssl-site-and-horizon-data.Rda'
# this saves files for upload to SoilWeb export/
source('process-KSSL-data.R')

## geochem, optical, XRD tables from the latest snapshot
## many TODO items remain
source('process-geochem-mineralogy.R')


## extract NASIS morphologic data
## 2017-09-06: now based on SQLite DB
# this saves files for upload to SoilWeb export/
source('process-NASIS-morph-data.R')


## clean-up data
# estimate pH 1:1 water, oc, om
# saves 'lab' to 'cached-data/kssl-SPC.Rda'
source('data-cleaning.R')

## Sonora office specific
# estimate BS82 from BS7
# subset to MLRAs 17, 18, 22A
source('sonora-office-specific-stuff.R')

## now update SoilWeb (2-1 and 2-2) with new data




