
## 2017-09-06: first cut at reading SQLite snapshot based on Adolfo's products
## 2017-04-24: these queries no longer appear to work... switching over to new snapshots from Adolfo
## 2016-04-22: first version, procesing Analysis PC export DB


## TODO:

# !!! remove pedon "copies": multiple peiid / pedlabsampnum

# 1. parent material
# 2. bedrock
# 3. geomorphology
# 4. duplicates rows from FGDB export (https://github.com/ncss-tech/lab-data-delivery/issues/5) -- use DISTINCT for now
# 5. duplicates in these queries can be caused by two things:
#     - duplicates in NASIS
#     - apparent duplicates due to errors / lack of table primary keys in query results
#       see: 

## taxonomic history
q.taxa <- "SELECT DISTINCT
peiidref as peiid, classdate, classtype, taxonname, localphase, taxonkind, taxorder, taxsuborder, taxgrtgroup, taxsubgrp, taxpartsize, taxpartsizemod, taxceactcl, taxreaction, taxtempcl, taxmoistscl, taxtempregime, soiltaxedition, psctopdepth, pscbotdepth, osdtypelocflag
FROM petaxhistory
ORDER BY peiidref;"

## basic NASIS site data
# adapted from soilDB queries
q.site <- "SELECT DISTINCT siteiid, peiid, usiteid as site_id, upedonid as pedon_id, pedlabsampnum, labdatadescflag,
obsdate,
longstddecimalde as x, latstddecimaldeg as y, gpspositionalerr, 
bedrckdepth, bedrckkind, bedrckhardness,
shapeacross, shapedown, geomposhill, geomposmntn, geompostrce, geomposflats, hillslopeprof, geomslopeseg, 
pmgroupname, drainagecl,
objwlupdated
FROM
site 
INNER JOIN siteobs ON site.siteiid = siteobs.siteiidref
LEFT JOIN pedon ON siteobs.siteobsiid = pedon.siteobsiidref
LEFT JOIN 
(
  SELECT siteiidref, bedrckdepth, bedrckkind, bedrckhardness
  FROM sitebedrock
  ORDER BY bedrckdepth ASC
  LIMIT 1
) as sb ON site.siteiid = sb.siteiidref
  
  ORDER BY pedon.peiid ;"

## color data
q.color <- "SELECT DISTINCT
phiid, labsampnum, colorpct, colorhue, colorvalue, colorchroma, colormoistst
FROM
phorizon 
JOIN phcolor ON phorizon.phiid = phcolor.phiidref
LEFT JOIN phsample ON phorizon.phiid = phsample.phiidref
ORDER BY phiid;"

## rock fragment data
q.frags <- "SELECT DISTINCT
phiid, labsampnum, fragvol, fragkind, fragsize_l, fragsize_r, fragsize_h, fragshp, fraground, fraghard
FROM
phorizon 
JOIN phfrags ON phorizon.phiid = phfrags.phiidref
LEFT JOIN phsample ON phorizon.phiid = phsample.phiidref
ORDER BY phiid;"

## pores
q.pores <- "SELECT DISTINCT
phiid, labsampnum, poreqty, poresize, poreshp
FROM
phorizon 
JOIN phpores ON phorizon.phiid = phpores.phiidref
LEFT JOIN phsample ON phorizon.phiid = phsample.phiidref
ORDER BY labsampnum;"


## structure
q.structure <- "SELECT DISTINCT
phiid, labsampnum, structgrade, structsize, structtype, structid, structpartsto
FROM
phorizon 
JOIN phstructure ON phorizon.phiid = phstructure.phiidref
LEFT JOIN phsample ON phorizon.phiid = phsample.phiidref
ORDER BY phiid;"


# setup connection to SQLite DB from FGDB export
db <- dbConnect(RSQLite::SQLite(), "E:/working_copies/lab-data-delivery/code/text-file-to-sqlite/NASIS-pedons.sqlite")

# reformat raw data and return as DF
nasis.site <- dbGetQuery(db, q.site)
h.color <- dbGetQuery(db, q.color)
h.frags <- dbGetQuery(db, q.frags)
h.pores <- dbGetQuery(db, q.pores)
h.structure <- dbGetQuery(db, q.structure)
h.taxa <- dbGetQuery(db, q.taxa)

dbDisconnect(db)

### SoilWeb related ###


## not sure if this is any faster, and it isn't working... study time
# library(data.table)
# DT <- data.table(h.taxa, key='peiid')
# best.tax.data <- DT[, .pickBestTaxHistory(.SD), by='peiid']

## process tax history: 1 row / peiid
## this is very slow ~ 40 minutes
# select the most relevant taxonomic record
h.taxa$classdate <- as.Date(h.taxa$classdate, format="%m/%d/%Y")
system.time(best.tax.data <- ddply(h.taxa, 'peiid', soilDB:::.pickBestTaxHistory, .progress='text'))

write.csv(best.tax.data, file=gzfile('export/kssl-nasis-taxhistory.csv.gz'), row.names=FALSE)



# create table defs-- these will likely need to be modified
cat(postgresqlBuildTableDefinition(PostgreSQL(), name='kssl.nasis_site', obj=nasis.site[1, ], row.names=FALSE), file='table-defs/nasis-tables.sql')

cat('\n\n', file='nasis-tables.sql', append = TRUE)
cat(postgresqlBuildTableDefinition(PostgreSQL(), name='kssl.nasis_phcolor', obj=h.color[1, ], row.names=FALSE), file='table-defs/nasis-tables.sql', append = TRUE)

cat('\n\n', file='nasis-tables.sql', append = TRUE)
cat(postgresqlBuildTableDefinition(PostgreSQL(), name='kssl.nasis_phfrags', obj=h.frags[1, ], row.names=FALSE), file='table-defs/nasis-tables.sql', append = TRUE)

cat('\n\n', file='nasis-tables.sql', append = TRUE)
cat(postgresqlBuildTableDefinition(PostgreSQL(), name='kssl.nasis_phpores', obj=h.pores[1, ], row.names=FALSE), file='table-defs/nasis-tables.sql', append = TRUE)

cat('\n\n', file='nasis-tables.sql', append = TRUE)
cat(postgresqlBuildTableDefinition(PostgreSQL(), name='kssl.nasis_phstructure', obj=h.structure[1, ], row.names=FALSE), file='table-defs/nasis-tables.sql', append = TRUE)

cat('\n\n', file='nasis-tables.sql', append = TRUE)
cat(postgresqlBuildTableDefinition(PostgreSQL(), name='kssl.nasis_taxhistory', obj=best.tax.data[1, ], row.names=FALSE), file='table-defs/nasis-tables.sql', append = TRUE)


# save to CSV files for upload to soilweb
write.csv(nasis.site, file=gzfile('export/kssl-nasis-site.csv.gz'), row.names=FALSE)
write.csv(h.color, file=gzfile('export/kssl-nasis-phcolor.csv.gz'), row.names=FALSE)
write.csv(h.frags, file=gzfile('export/kssl-nasis-phfrags.csv.gz'), row.names=FALSE)
write.csv(h.pores, file=gzfile('export/kssl-nasis-phpores.csv.gz'), row.names=FALSE)
write.csv(h.structure, file=gzfile('export/kssl-nasis-phstructure.csv.gz'), row.names=FALSE)




