#!/usr/bin/python
# install if necessary the topmed pipeline packages
from        argparse  import ArgumentParser
import      sys
import      os
import      os.path
import      subprocess


def pError(msg):
    print ">>> Error creating topmed pkg install script:\n\t" + msg

defScript = "installm2gen.R"
parser = ArgumentParser( description = "Create script to install m2gen R packages" )
parser.add_argument( "rlibpath",help = "Path to the m2gen r-packages" )
parser.add_argument("-i", "--installscript",help = "Name of the install script to create",
                    default = defScript )
parser.add_argument("-R","--rscript",help = "R script")

args = parser.parse_args()
rlibpath = args.rlibpath
iscript = args.installscript
rscript = args.rscript

print(">>> Creating script to install m2gen R packages into " + rlibpath)
# check if it exists

if not os.path.isdir( rlibpath ):
    pError( "R library path " + rlibpath + " does not exist" )
    sys.exit(2)

# list of bioconductor and other r packages
bioc_pkgs=[ "LPE", "affy",
            "sva", "ggbiplot",
            "rhdf5", "VariantAnnotation", "annotate", "bumphunter",
            "clusterProfiler", "ComplexHeatmap", "DO.db", "DOSE", "edgeR",
            "genefilter", "GEOquery", "GO.db", "GOSemSim", "graph", "Heatplus",
            "hgu133a.db", "hgu95av2.db",
            "IlluminaHumanMethylation450kanno.ilmn12.hg19",
            "IlluminaHumanMethylation450kmanifest", "illuminaio", "impute",
            "KEGGREST", "limma", "minfi", "minfiData", "multtest",
            "org.Hs.eg.db", "preprocessCore", "qvalue", "siggenes", "topGO"]

r_pkgs=["pheatmap",  "reshape2", "plyr", "matrixStats", "xlsx", "ggplot2",
        "survival", "fmsb", "Hmisc", "gdata", "vcfR", "acepack",
        "AnnotationDbi", "ape", "assertthat", "base", "beanplot",
        "BH", "Biobase", "BiocGenerics", "BiocInstaller", "BiocParallel",
        "biomaRt", "Biostrings","bitops", "boot", "BradleyTerry2", "brglm",
        "broom", "car", "caret", "caTools", "cgdsr", "chron",
        "circlize", "class", "cluster", "clValid", "codetools",
        "coin", "colorspace", "combinat", "compiler", "corpcor",
        "corrplot", "covr", "crayon", "Cubist", "curl", "data.table", "datasets",
        "DBI", "dendextend", "DEoptimR", "devtools", "dichromat", "digest",
        "diptest", "doBy", "doParallel", "doRNG", "dplyr",
        "dynamicTreeCut", "e1071", "earth", "ellipse", "entropy",
        "evaluate", "fastcluster", "fastICA", "flexmix", "foreach", "foreign",
        "forestmodel", "forestplot", "formatR", "Formula", "fpc", "futile.logger",
        "futile.options", "gam", "gapminder", "gdata", "gdtools",
        "GenomeInfoDb", "GenomicAlignments", "GenomicFeatures", "GenomicRanges",
        "GetoptLong", "ggplot2", "ggplot2movies", "git2r",
        "GlobalOptions", "GMD", "gplots",
        "graphics", "grDevices", "grid", "gridBase", "gridExtra", "gtable",
        "gtools", "heatmap3", "hexbin",
        "highr", "Hmisc", "htmltools", "httr", "igraph",
        "infotheo", "ipred", "IRanges", "irlba",
        "iterators", "jsonlite", "kernlab", "KernSmooth", "klaR",
        "KMsurv", "knitr", "kohonen", "labeling", "lambda.r", "lattice",
        "latticeExtra", "lava", "lazyeval", "lme4", "locfit", "magrittr",
        "mapproj", "maps", "maptools", "markdown", "MASS", "Matrix", "MatrixModels",
        "matrixStats", "mclust", "mda", "memoise", "memuse", "methods", "mgcv",
        "mime", "minqa", "mix", "mixOmics", "mlbench",
        "mnormt", "modeltools", "MSIseq", "multcomp", "munsell",
        "mvtnorm", "nlme", "nloptr", "NMF", "nnet", "nor1mix", "numDeriv", "OIsurv",
        "openssl", "openxlsx", "pamr", "parallel", "party",
        "pbkrtest", "permute", "pheatmap", "pinfsc50", "pkgmaker", "plotmo",
        "plotrix", "pls", "plyr", "png", "prabclus", "praise",
        "pROC", "prodlim", "profileModel", "proxy", "psych", "purrr", "quadprog",
        "quantreg", "R.methodsS3", "R.oo", "R.utils", "R6", "randomForest",
        "RankAggreg", "RANN", "RColorBrewer", "Rcpp", "RcppEigen", "RCurl",
        "refGenome", "registry", "reshape", "reshape2", "rex", "rgl", "rhdf5",
        "rJava", "rjson", "rmarkdown", "rngtools", "robustbase", "rpart",
        "Rsamtools", "RSQLite", "rstudioapi", "rtracklayer", "RWeka", "RWekajars",
        "S4Vectors", "sandwich", "scales", "shape", "snow", "sp",
        "SparseM", "spatial", "splines", "spls", "statmod", "stats", "stats4",
        "stringi", "stringr", "strucchange", "subselect", "SummarizedExperiment",
        "superpc", "survival", "survminer", "svglite", "tcltk", "TeachingDemos",
        "testthat", "TH.data", "tibble", "tidyr", "tools", "trimcluster",
        "utils", "vcfR", "vegan", "viridis", "viridisLite", "WGCNA", "whisker",
        "withr", "XLConnect", "XLConnectJars", "XML", "xtable", "XVector", "yaml",
        "zlibbioc", "zoo" ]

add_bp=False
fileHdr='#!' + rscript + ' --no-save --slave\n'
for bp in bioc_pkgs:
    # check if the directory exist; if not
    if not os.path.isdir( rlibpath+"/"+bp ):
        if not add_bp:
            add_bp=True
            # open the file; write the the first lines
            sfile=open(iscript,'w')
            sfile.write(fileHdr)
            sfile.write('install.packages("BiocManager", repos="https://ftp.osuosl.org/pub/cran/")\n')
        # write the PKG
        sfile.write('BiocManager::install("' + bp + '", lib="' + rlibpath + '")\n')

add_rp=False
for rp in r_pkgs:
    # check directory
    if not os.path.isdir( rlibpath+"/"+rp ):
        line = 'install.packages("' + rp + '", "' + rlibpath + '", dependencies=TRUE, rep="https://ftp.osuosl.org/pub/cran/", quiet=TRUE)\n'
        if add_rp or add_bp:
            sfile.write(line)
        else:
            add_rp=True
            sfile=open(iscript,'w')
            sfile.write(fileHdr)
            sfile.write(line)
# close the file
if add_rp or add_bp:
    sfile.close()
sys.exit(0)
