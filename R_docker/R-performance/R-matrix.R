set.seed (1)
m <- 10000
n <-  5000
A <- matrix (runif (m*n),m,n)
# Matrix multiply
system.time (B <- crossprod(A))

# test using multiple cores (2nd case doesn't work with veclib)
#A <- matrix (rnorm(m*n),m)
#library(parallel)
#system.time(res <- mclapply(1:4, function(i) {crossprod(A + i)}, mc.cores = 1))
#system.time(res <- mclapply(1:4, function(i) {crossprod(A + i)}, mc.cores = 2))

# Cholesky Factorization
system.time (C <- chol(B))
# Singular Value Deomposition
m <- 10000
n <- 2000
A <- matrix (runif (m*n),m,n)
system.time (S <- svd (A,nu=0,nv=0))
# Principal Components Analysis
m <- 10000
n <- 2000
A <- matrix (runif (m*n),m,n)
system.time (P <- prcomp(A))
# Linear Discriminant Analysis
library('MASS')
g <- 5
k <- round (m/2)
A <- data.frame (A, fac=sample (LETTERS[1:g],m,replace=TRUE))
train <- sample(1:m, k)
system.time (L <- lda(fac ~., data=A, prior=rep(1,g)/g, subset=train))
