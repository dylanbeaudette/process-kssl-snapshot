## 2020-03-12: first version, using latest LDM snapshot

## TODO: check prep codes
## TODO: split into sub-tables


## geochemical data
q.geochem <- "SELECT DISTINCT *
FROM geochemical
ORDER BY labsampnum;"

## optical / glass
q.optical <- "SELECT DISTINCT *
FROM glass
ORDER BY labsampnum;"

## XRD / thermal
q.xrd <- "SELECT DISTINCT *
FROM xray_thermal
ORDER BY labsampnum;"



# setup connection to SQLite DB from FGDB export
db <- dbConnect(RSQLite::SQLite(), "E:/NASIS-KSSL-LDM/LDM/LDM-compact.sqlite")

# reformat raw data and return as DF
geochem <- dbGetQuery(db, q.geochem)
optical <- dbGetQuery(db, q.optical)
xrd <- dbGetQuery(db, q.xrd)

dbDisconnect(db)


## save to CSV files for upload to soilweb
write.csv(geochem, file=gzfile('export/geochem.csv.gz'), row.names=FALSE)
write.csv(optical, file=gzfile('export/optical.csv.gz'), row.names=FALSE)
write.csv(xrd, file=gzfile('export/xrd.csv.gz'), row.names=FALSE)


## approximate table defs, re-run if tables have changed

## manual intervention required:
# semi-colon
# new-lines
# data types

# cat(postgresqlBuildTableDefinition(PostgreSQL(), name='kssl.geochem', obj=geochem[1, ], row.names=FALSE), file='table-defs/geochem-tables.sql')
# 
# cat(postgresqlBuildTableDefinition(PostgreSQL(), name='kssl.optical', obj=optical[1, ], row.names=FALSE), file='table-defs/geochem-tables.sql', append = TRUE)
# 
# cat(postgresqlBuildTableDefinition(PostgreSQL(), name='kssl.xrd_thermal', obj=xrd[1, ], row.names=FALSE), file='table-defs/geochem-tables.sql', append = TRUE)
# 





