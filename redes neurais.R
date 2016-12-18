##Atualização 11/12

library(readxl)
tbl=read_excel("20160718_BPDunifesp_proteinsmeasurements_nofilter.xlsx", skip=2)
tbl=tbl[,-c(2:11)]
dados=apply(tbl[,-1], 2, as.double)
nms=colnames(dados)
nms=gsub("--", "-", nms)
colnames(dados)=nms

names=tbl[[1]]
names = sapply(strsplit(names, ";"), '[', 1)
names=gsub("--", "-", names)
rownames(dados)=names
rm(names, nms, tbl)

data=data.frame(t(dados))
rm(dados)

nms=rownames(data)
data$amostras = sapply(strsplit(nms, "-"), '[', 1)
library(plyr)
data=ddply(data, .(amostras), function(mdf) {
  idx=grep("amostras", names(mdf))
  colMeans(mdf[,-idx])
})
rm(nms)

#Grupo de afetados é 1, 0 se controle
rownames(data)=data[[1]]
id=substr(data$amostras, start = 1, stop = 1)!="C"
#grepl("^C", data$amostras)
#regularexpression
id=as.factor(id)
data$amostras=id

set.seed(148255)
##Separando 20% do banco de dados para predição
# ind=sample(1:dim(data)[1], 0.2*dim(data)[1])
# pred=data[ind,]
# dados=data[-ind,]

##Separando 20% do banco de dados para validação
ind=sample(1:dim(data)[1], 0.2*dim(data)[1])
valid=data[ind,]
train=data[-ind,]
#rm(data, ind, id)

#Transformando os dados em h2o
library(h2o)
h2o.init(nthreads = 2, max_mem_size = "2G")

#pred=as.h2o(pred)
#train=as.h2o(train)
#valid=as.h2o(valid)
data=as.h2o(data)

table(dados[[1]])

fit=h2o.deeplearning(x=names(data)[-1], y="amostras", training_frame = data, nfolds = 5
  ,hidden = c(32,16)
)