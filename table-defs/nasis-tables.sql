CREATE TABLE "kssl.nasis_site" 
( "siteiid" integer,
	"peiid" integer,
	"site_id" text,
	"pedon_id" text,
	"pedlabsampnum" text,
	"labdatadescflag" text,
	"obsdate" text,
	"x" float8,
	"y" float8,
	"gpspositionalerr" float8,
	"bedrckdepth" integer,
	"bedrckkind" text,
	"bedrckhardness" text,
	"shapeacross" text,
	"shapedown" text,
	"geomposhill" text,
	"geomposmntn" text,
	"geompostrce" text,
	"geomposflats" text,
	"hillslopeprof" text,
	"geomslopeseg" text,
	"pmgroupname" text,
	"drainagecl" text,
	"objwlupdated" text 
)

CREATE TABLE "kssl.nasis_phcolor" 
( "phiid" integer,
	"labsampnum" text,
	"colorpct" integer,
	"colorhue" text,
	"colorvalue" float8,
	"colorchroma" integer,
	"colormoistst" text 
)

CREATE TABLE "kssl.nasis_phfrags" 
( "phiid" integer,
	"labsampnum" text,
	"fragvol" float8,
	"fragkind" text,
	"fragsize_l" integer,
	"fragsize_r" integer,
	"fragsize_h" integer,
	"fragshp" text,
	"fraground" text,
	"fraghard" text 
)

CREATE TABLE "kssl.nasis_phpores" 
( "phiid" integer,
	"labsampnum" text,
	"poreqty" float8,
	"poresize" text,
	"poreshp" text 
)

CREATE TABLE "kssl.nasis_phstructure" 
( "phiid" integer,
	"labsampnum" text,
	"structgrade" text,
	"structsize" text,
	"structtype" text,
	"structid" integer,
	"structpartsto" integer 
)

