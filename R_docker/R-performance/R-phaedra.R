rnaurl='/work/kuraisar/agius/Pharma_20220217_ClinicalMolLinkage_V4.csv'
rna=read.csv(rnaurl)
rna2=rna[which(rna$RNASeq!=''),]
dt<-gsub(' ','',as.vector(rna2$Disease.Type))
dt<-gsub('\\&','',dt)
dt<-gsub(',','',dt)
tt=dt[4]  # "NEU-BrainCancer" (small)
tt=dt[5]  # "BRE-BreastCancer" (medium)
rna3=rna2[which(dt==tt),]


library(SCANVISutils)
fnames=list.files(path='/work/agius/sj/scn10/',full.names=TRUE)
q=unlist(lapply(levels(rna3$RNASeq),function(x) grep(x,fnames)))
fnames<-fnames[q]

#fout=paste0('/work/agius/sj/scn10_usj/USJ.',tt)
#scn2mat(fnames,fout,filters='-annot no')

fout=paste0('/work/kuraisar/agius/perf_out/ASJ.',tt)
system.time({scn2mat(fnames,fout,filters='-annot yes')})

# performance on preview 3; clone
library(SCANVISutils)
rnaurl='/work/agius/Data/clinical_20220217/Pharma_20220217_ClinicalMolLinkage_V4.csv'
rna=read.csv(rnaurl)
rna2=rna[which(rna$RNASeq!=''),]
dt<-gsub(' ','',as.vector(rna2$Disease.Type))
dt<-gsub('\\&','',dt)
dt<-gsub(',','',dt)

tt=dt[9]
#tt=dt[18]
message(tt)
rna3=rna2[which(dt==tt),]
fnames2=list.files(path='/work/agius/sj/scn10',full.names=TRUE)
q=unlist(lapply(rna3$RNASeq,function(x) grep(x,fnames2)))
fnames2<-fnames2[q]
str(rna3)
length(fnames2)
fout=paste0('/work/ubuntu/agius/ASJ.',tt)
system.time({scn2mat(fnames2,fout,filters='-annot yes')})

# performance on aws
library(SCANVISutils)
rnaurl='/work/agius/Data/clinical_20220217/Pharma_20220217_ClinicalMolLinkage_V4.csv'
rna=read.csv(rnaurl)
rna2=rna[which(rna$RNASeq!=''),]
dt<-gsub(' ','',as.vector(rna2$Disease.Type))
dt<-gsub('\\&','',dt)
dt<-gsub(',','',dt)

tt=dt[9]
message(tt)
rna3=rna2[which(dt==tt),]
fnames2=list.files(path='/work/ubuntu/agius/scn10',full.names=TRUE)
q=unlist(lapply(rna3$RNASeq,function(x) grep(x,fnames2)))
fnames2<-fnames2[q]
str(rna3)
length(fnames2)
fout=paste0('/work/ubuntu/agius/ASJ.',tt)
system.time({scn2mat(fnames2,fout,filters='-annot yes')})

# find tt/Disease
tt=dt[9]
message(tt)
rna3=rna2[which(dt==tt),]
fnames2=list.files(path='/work/ubuntu/agius/scn10',full.names=TRUE)
q=unlist(lapply(rna3$RNASeq,function(x) grep(x,fnames2)))
fnames2<-fnames2[q]
str(rna3)
length(fnames2)
