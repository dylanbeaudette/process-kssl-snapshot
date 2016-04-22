#### This requires 32bit R and libraries ...

## data are exported as-is, with minimal processing, cleaning up and summary happens in a follow-up step


## 2016-04-22: first version, procesing Analysis PC export DB

## basic NASIS site data
q.site <- "SELECT
pedlabsampnum, geomposhill, geomposmntn, geompostrce, geomposflats, hillslopeprof, geomslopeseg, bedrckkind, bedrckhardness, pmgroupname, drainagecl
FROM 
(
pedon LEFT OUTER JOIN siteobs ON pedon.siteobsuidref = siteobs.siteobsiid)
LEFT OUTER JOIN site ON site.siteiid = siteobs.siteiidref
WHERE pedlabsampnum IS NOT NULL
ORDER BY pedlabsampnum;"

## color data
q.color <- "SELECT
labsampnum, colorpct, colorhue, colorvalue, colorchroma, colormoistst
FROM
(
phorizon INNER JOIN phsample ON phorizon.phiid = phsample.phiidref)
INNER JOIN phcolor ON phorizon.phiid = phcolor.phiidref
WHERE labsampnum IS NOT NULL
ORDER BY labsampnum;"

## rock fragment data
q.frags <- "SELECT
labsampnum, fragvol, fragkind, fragsize_l, fragsize_r, fragsize_h, fragshp, fraground, fraghard
FROM
(
  phorizon INNER JOIN phsample ON phorizon.phiid = phsample.phiidref)
  INNER JOIN phfrags ON phorizon.phiid = phfrags.phiidref
  WHERE labsampnum IS NOT NULL
  ORDER BY labsampnum;"


## pores
q.pores <- "SELECT
labsampnum, poreqty, poresize, poreshp
FROM
  (
  phorizon INNER JOIN phsample ON phorizon.phiid = phsample.phiidref)
  INNER JOIN phpores ON phorizon.phiid = phpores.phiidref
  WHERE labsampnum IS NOT NULL
  ORDER BY labsampnum;"


## structure
q.structure <- "SELECT
labsampnum, structgrade, structsize, structtype, structid, structpartsto
FROM
  (
  phorizon INNER JOIN phsample ON phorizon.phiid = phsample.phiidref)
  INNER JOIN phstructure ON phorizon.phiid = phstructure.phiidref
  WHERE labsampnum IS NOT NULL
  ORDER BY labsampnum;"


# setup connections
nasis.channel <- odbcConnectAccess('C:/Users/Dylan.Beaudette/Desktop/kssl_and_morph-web-service/analysis_pc_2.1_63600_pedons_April_2016.mdb', readOnlyOptimize=TRUE)

# get data from KSSL snapshot
s <- sqlQuery(nasis.channel, q.site, stringsAsFactors=FALSE)
h.color <- sqlQuery(nasis.channel, q.color, stringsAsFactors=FALSE)
h.frags <- sqlQuery(nasis.channel, q.frags, stringsAsFactors=FALSE)
h.pores <- sqlQuery(nasis.channel, q.pores, stringsAsFactors=FALSE)
h.structure <- sqlQuery(nasis.channel, q.structure, stringsAsFactors=FALSE)


# close connections
odbcCloseAll()


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


# save to CSV files for upload to soilweb
write.csv(s, file=gzfile('kssl-nasis-site.csv.gz'), row.names=FALSE)
write.csv(h.color, file=gzfile('kssl-nasis-phcolor.csv.gz'), row.names=FALSE)
write.csv(h.frags, file=gzfile('kssl-nasis-phfrags.csv.gz'), row.names=FALSE)
write.csv(h.pores, file=gzfile('kssl-nasis-phpores.csv.gz'), row.names=FALSE)
write.csv(h.structure, file=gzfile('kssl-nasis-phstructure.csv.gz'), row.names=FALSE)

