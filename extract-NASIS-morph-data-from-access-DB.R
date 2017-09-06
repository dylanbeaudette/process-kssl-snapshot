
## 2017-09-06: first cut at reading SQLite snapshot based on Adolfo's products
## 2017-04-24: these queries no longer appear to work... switching over to new snapshots from Adolfo
## 2016-04-22: first version, procesing Analysis PC export DB


## TODO:
# 1. parent material
# 2. bedrock
# 3. geomorphology
# 4. spatial data

## taxonomic history
q.taxa <- "SELECT peiidref as peiid, classdate, classtype, taxonname, localphase, taxonkind, taxorder, taxsuborder, taxgrtgroup, taxsubgrp, taxpartsize, taxpartsizemod, taxceactcl, taxreaction, taxtempcl, taxmoistscl, taxtempregime, soiltaxedition, psctopdepth, pscbotdepth, osdtypelocflag
FROM petaxhistory
ORDER BY peiidref;"

## basic NASIS site data
q.site <- "SELECT
peiid, pedlabsampnum, geomposhill, geomposmntn, geompostrce, geomposflats, hillslopeprof, geomslopeseg, pmgroupname, drainagecl
FROM 
pedon 
LEFT OUTER JOIN siteobs ON pedon.siteobsiidref = siteobs.siteobsiid
LEFT OUTER JOIN site ON site.siteiid = siteobs.siteiidref
ORDER BY peiid;"

## color data
q.color <- "SELECT
phiid, labsampnum, colorpct, colorhue, colorvalue, colorchroma, colormoistst
FROM
phorizon 
JOIN phcolor ON phorizon.phiid = phcolor.phiidref
LEFT JOIN phsample ON phorizon.phiid = phsample.phiidref
ORDER BY phiid;"

## rock fragment data
q.frags <- "SELECT
phiid, labsampnum, fragvol, fragkind, fragsize_l, fragsize_r, fragsize_h, fragshp, fraground, fraghard
FROM
phorizon 
JOIN phfrags ON phorizon.phiid = phfrags.phiidref
LEFT JOIN phsample ON phorizon.phiid = phsample.phiidref
ORDER BY phiid;"

## pores
q.pores <- "SELECT
phiid, labsampnum, poreqty, poresize, poreshp
FROM
phorizon 
JOIN phpores ON phorizon.phiid = phpores.phiidref
LEFT JOIN phsample ON phorizon.phiid = phsample.phiidref
ORDER BY labsampnum;"


## structure
q.structure <- "SELECT
phiid, labsampnum, structgrade, structsize, structtype, structid, structpartsto
FROM
phorizon 
JOIN phstructure ON phorizon.phiid = phstructure.phiidref
LEFT JOIN phsample ON phorizon.phiid = phsample.phiidref
ORDER BY phiid;"


# setup connection to SQLite DB from FGDB export
db <- dbConnect(RSQLite::SQLite(), "E:/working_copies/lab-data-delivery/code/text-file-to-sqlite/NASIS-pedons.sqlite")

# reformat raw data and return as DF
s <- dbGetQuery(db, q.site)
h.color <- dbGetQuery(db, q.color)
h.frags <- dbGetQuery(db, q.frags)
h.pores <- dbGetQuery(db, q.pores)
h.structure <- dbGetQuery(db, q.structure)
h.taxa <- dbGetQuery(db, q.taxa)

## TODO: this is very slow ~ 20 minutes
# select the most relevant taxonomic record
h.taxa$classdate <- as.Date(h.taxa$classdate, format="%m/%d/%Y")
best.tax.data <- ddply(h.taxa, 'peiid', soilDB:::.pickBestTaxHistory, .progress='text')


# create table defs-- these will likely need to be modified
cat(postgresqlBuildTableDefinition(PostgreSQL(), name='kssl.nasis_site', obj=s[1, ], row.names=FALSE), file='nasis-tables.sql')

cat('\n\n', file='nasis-tables.sql', append = TRUE)
cat(postgresqlBuildTableDefinition(PostgreSQL(), name='kssl.nasis_phcolor', obj=h.color[1, ], row.names=FALSE), file='nasis-tables.sql', append = TRUE)

cat('\n\n', file='nasis-tables.sql', append = TRUE)
cat(postgresqlBuildTableDefinition(PostgreSQL(), name='kssl.nasis_phfrags', obj=h.frags[1, ], row.names=FALSE), file='nasis-tables.sql', append = TRUE)

cat('\n\n', file='nasis-tables.sql', append = TRUE)
cat(postgresqlBuildTableDefinition(PostgreSQL(), name='kssl.nasis_phpores', obj=h.pores[1, ], row.names=FALSE), file='nasis-tables.sql', append = TRUE)

cat('\n\n', file='nasis-tables.sql', append = TRUE)
cat(postgresqlBuildTableDefinition(PostgreSQL(), name='kssl.nasis_phstructure', obj=h.structure[1, ], row.names=FALSE), file='nasis-tables.sql', append = TRUE)

cat('\n\n', file='nasis-tables.sql', append = TRUE)
cat(postgresqlBuildTableDefinition(PostgreSQL(), name='kssl.nasis_taxhistory', obj=best.tax.data[1, ], row.names=FALSE), file='nasis-tables.sql', append = TRUE)


# save to CSV files for upload to soilweb
write.csv(s, file=gzfile('kssl-nasis-site.csv.gz'), row.names=FALSE)
write.csv(h.color, file=gzfile('kssl-nasis-phcolor.csv.gz'), row.names=FALSE)
write.csv(h.frags, file=gzfile('kssl-nasis-phfrags.csv.gz'), row.names=FALSE)
write.csv(h.pores, file=gzfile('kssl-nasis-phpores.csv.gz'), row.names=FALSE)
write.csv(h.structure, file=gzfile('kssl-nasis-phstructure.csv.gz'), row.names=FALSE)
write.csv(best.tax.data, file=gzfile('kssl-nasis-taxhistory.csv.gz'), row.names=FALSE)



