CREATE TABLE "kssl.nasis_site" 
( "pedlabsampnum" text,
	"geomposhill" text,
	"geomposmntn" text,
	"geompostrce" text,
	"geomposflats" text,
	"hillslopeprof" text,
	"geomslopeseg" text,
	"bedrckkind" text,
	"bedrckhardness" text,
	"pmgroupname" text,
	"drainagecl" text 
)

CREATE TABLE "kssl.nasis_phcolor" 
( "labsampnum" text,
	"colorpct" integer,
	"colorhue" text,
	"colorvalue" float8,
	"colorchroma" integer,
	"colormoistst" text 
)

CREATE TABLE "kssl.nasis_phfrags" 
( "labsampnum" text,
	"fragvol" integer,
	"fragkind" text,
	"fragsize_l" integer,
	"fragsize_r" integer,
	"fragsize_h" integer,
	"fragshp" text,
	"fraground" text,
	"fraghard" text 
)

CREATE TABLE "kssl.nasis_phpores" 
( "labsampnum" text,
	"poreqty" float8,
	"poresize" text,
	"porecont" text,
	"poreshp" text 
)

CREATE TABLE "kssl.nasis_phstructure" 
( "labsampnum" text,
	"structgrade" text,
	"structsize" text,
	"structtype" text,
	"structid" integer,
	"structpartsto" integer 
)