# required packages
library(rms)

# load MLRA 17, 18, 22A model
load('S:/NRCS/Lab_Data/mlra-17-18-22A-BS82-model.Rda')

# predict BS82 from BS7: 65% base saturation at pH7
# with 90% prediction interval
round(unlist(predict(l.bs, newdata=data.frame(bs7=65), conf.type ='individual', conf.int=0.9)))
