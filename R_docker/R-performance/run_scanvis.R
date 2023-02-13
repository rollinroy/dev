args<-commandArgs(TRUE)
YM<-args[1]   #202205

dirout<-'/work/kuraisar/agius/scn10_out/'

lof<-list.files(path=paste0('/work/kuraisar/agius/clinical_m2gen_deid/clinical_',YM),
                full.names=TRUE)
cml<-read.csv(lof[grep('ClinicalMol',lof)])
q<-which(cml$RNASeq!='')
slids<-as.matrix(cml[q,1])
names(slids)<-as.matrix(cml$RNASeq[q])

fin<-list.files(path='/work/kuraisar/agius/tab',full.names=TRUE,pattern='\\.tab')
names(fin)<-list.files(path='/work/kuraisar/agius/tab',pattern='\\.tab')
if(length(args)>1)
  fin<-fin[as.numeric(args[2]):as.numeric(args[3])]

tmp<-gsub('.SJ.out.tab','',names(fin))
q<-which(is.element(tmp,intersect(tmp,names(slids))))
if(length(q)==0)
  stop('Error in run_scanvis --- No samples found to run!')
tmp<-tmp[q]
fin<-fin[q]
fout<-paste0(slids[tmp],'_',names(slids[tmp]),'.SJ.out.scn10')
fout<-paste0(dirout,fout)

library(SCANVIS)
library(Matrix)
library(parallel)
gen32<-get(load('/work/kuraisar/agius/gen32.Rdata'))
RCUT=10
system.time(
    {
        for(i in 1:length(fin)){
          print(fin[i])
          print(fout[i])
          sj<-SCANVISread_STAR(fin[i])
          scn<-SCANVISscan(sj,gen32,Rcut=RCUT)
          write.table(scn,fout[i],sep='\t',quote=F,row.names=F)
#          system(paste('rm',fin[i]))
        }
    }
)

quit(save='no')
