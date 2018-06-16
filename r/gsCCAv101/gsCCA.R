#
# Implementation of Bayesian CCA via group sparsity
# based on the publication
#   S. Virtanen, A. Klami, S. Kaski:
#   Bayesian CCA via Group Sparsity
#   In proceedings of ICML'11
#
# For questions and bug reports please contact
# seppo.j.virtanen@aalto.fi
#
# Copyright 2011 Seppo Virtanen and Arto Klami. All rights reserved.
# The software is licensed under the FreeBSD license; see LICENSE
# included in the package.
#

gsCCAexperiment <- function(Y,K,opts,Nrep=10) {
  #
  # A wrapper for running the gsCCA model Nrep times
  # and choosing the final model based on the best
  # lower bound. This is the recommended way of applying
  # the algorithm.
  #
  # See gsCCA() for description of the inputs.
  #
  if(Nrep==1) {
    return(gsCCA(Y,K,opts))
  }

  lb <- vector() # Lower bounds
  models <- vector("list")
  for(rep in 1:Nrep){
    model <- gsCCA(Y,K,opts)
    models[[rep]] <- model
    lb[rep] <- tail(model$cost,1)
    if(opts$verbose==1) {
      print(paste("Run ",rep,"/",Nrep,": ",length(model$cost)," iterations with final cost ",lb[rep],sep=""))
    }
  }

  k <- which.max(lb)
  model <- models[[k]]

  return(model)
}

gsCCA <- function(Y,K,opts) {
  #
  # The main function (gsCCA stands for group sparsity CCA)
  #
  # Inputs:
  #   Y    : List of two data matrices. Y[[1]] is a matrix with
  #          N rows (samples) and D_1 columns (features). Similarly
  #          Y[[2]] has N rows and D_2 columns
  #          NOTE: Both of these should be centered, so that the mean
  #                of each feature is zero
  #          NOTE: The algorithm is roughly invariant to the scale
  #                of the data, but extreme values should be avoided.
  #                Data with roughly unit variance or similar scale
  #                is recommended.
  #   K    : The number of components
  #   opts : List of options (see function getDefaultOpts())
  #
  # Output:
  # The trained model, which is a list that contains the following elements:
  #   Z    : The mean of the latent variables; N times K matrix
  #   covZ : The covariance of the latent variables; K times K matrix
  #   ZZ   : The second moments ZZ^T; K times K matrix
  #
  #   W    : List of the mean projections; D_i times K matrices
  #   covW : List of the covariances of the projections; D_i times D_i matrices
  #   WW   : List of the second moments WW^T; K times K matrices
  #
  #   tau  : The mean precisions (inverse variance, so 1/tau gives the
  #          variances denoted by sigma in the paper); 2-element vector
  #
  #   alpha: The mean precisions of the projection weights, the
  #          variances of the ARD prior; 2 times K matrix
  #
  #   cost : Vector collecting the variational lower bounds for each
  #          iteration
  #   D    : Data dimensionalities; 2-element vector
  #   datavar   : The total variance in the data sets, needed for
  #               gsCCAtrim()
  #   addednoise: The level of extra noise as in opts$addednoise
  #
  
  #
  # Store dimensionalities of data sets 
  #
  M <- length(Y)              # Should be two
  D <- unlist(lapply(Y,ncol)) # Collect the number of features in vector D
  Ds <- sum(D)                # Total number of features
  N <- nrow(Y[[1]])           # The number of samples
  datavar <- vector()                 # The total variance of the data, needed
  for(m in 1:M) {                     #     for scaling in the initialization
    datavar[m]=sum(diag(cov(Y[[m]]))) #     and for gsCCAtrim()
  }
  
  # Some constants for speeding up the computation
  const <- - N*Ds/2*log(2*pi) # Constant factors for the lower bound
  Yconst <- unlist(lapply(Y,function(x){sum(x^2)}))
  id <- rep(1,K)              # Vector of ones for fast matrix calculations
  alpha_0 <- opts$prior.alpha_0   # Easier access for hyperprior values
  beta_0 <- opts$prior.beta_0
  alpha_0t <- opts$prior.alpha_0t
  beta_0t <- opts$prior.beta_0t
  
  #
  # Initialize the model randomly; other initializations could
  # be done, but overdispersed random initialization is quite good.
  # 
  
  # Latent variables
  Z <- matrix(rnorm(N*K,0,1),N,K) # The mean 
  covZ <- diag(1,K)               # The covariance
  ZZ <- covZ + covZ*N             # The second moments

  # ARD and noise parameters
  alpha <- matrix(1,M,K)          # The mean of the ARD precisions
  logalpha <- matrix(1,M,K)       # The mean of <\log alpha >
  b_ard <- matrix(1,M,K)          # The parameters of the Gamma distribution
  a_ard <- alpha_0 + D/2          #     for ARD precisions
  tau <- rep(opts$init.tau,M)     # The mean noise precisions
  a_tau <- alpha_0t + N*D/2       # The parameters of the Gamma distribution
  b_tau <- rep(0,M)               #     for the noise precisions

  # Alpha needs to be initialized to match the data scale
  for(m in 1:M) {
    alpha[m,] <- K*D[m]/(datavar[m]-1/tau[m])
  }
  
  # The projections
  # No need to initialize the projections randomly, since their updating
  # step is the first one; just define the variables here
  W <- vector("list",length=M)    # The means
  covW <- vector("list",length=M) # The covariances
  WW <- vector("list",length=M)   # The second moments
  for(i in 1:M) {
    W[[i]] <- matrix(0,D[i],K)
    covW[[i]] <- diag(1,K)
    WW[[i]] <- crossprod(W[[i]]) + covW[[i]]*D[i]
  }

  # Rotation parameters
  R <- diag(K)      # The rotation matrix
  Rinv <- diag(K)   # Its inverse
  r <- as.vector(R) # Vectorized version of R

  # parameter list for the optimization function (see ?optim)
  par <- list(K=K,D=D,Ds=Ds,N=N,WW=WW,ZZ=ZZ,M=M)

  cost <- vector()  # For storing the lower bounds

  #
  # The main loop
  #
  for(iter in 1:opts$iter.max){ 
    
    #
    # Update the projections
    #
    for(m in 1:M){
      # Efficient and robust way of computing
      # solve(sqrt(diag(alpha)) + tau * ZZ^T)
      tmp <- 1/sqrt(alpha[m,])
      covW[[m]] <- 1/tau[m] * outer(tmp,tmp) *
        chol2inv(chol(outer(tmp,tmp)*ZZ + diag(1/tau[m],K)))
      
      # An alternative way; could be tried in case of 
      #   issues with numerical stability
      #eS <- eigen( outer( tmp, tmp )*ZZ + diag(1/tau[m],K) , symmetric=TRUE)
      #covW[[m]] <- 1/tau[m] * outer( tmp, tmp ) * tcrossprod( eS$vectors*outer( id, 1/eS$values), eS$vectors )
        
      W[[m]] <- crossprod(Y[[m]],Z)%*%covW[[m]]*tau[m]		
      WW[[m]] <- crossprod(W[[m]]) + covW[[m]]*D[m]
    }
    
    # 
    # Update the latent variables
    #

    # Efficient and robust way of computing
    # solve(diag(1,K) + tau * WW^t)
    covZ <- diag(1,K)
    for(m in 1:M) {
      covZ <- covZ + tau[m]*WW[[m]]
    }
    covZ <- chol2inv(chol(covZ))
    # An alternative way; could be tried in case of 
    #   issues with numerical stability
    #eS <- eigen( covZ ,symmetric=TRUE)
    #covZ <- tcrossprod( eS$vectors*outer(id,1/eS$values), eS$vectors )

    Z <- Y[[1]]%*%W[[1]]*tau[1]
    for(m in 2:M)
      Z <- Z + Y[[m]]%*%W[[m]]*tau[m]
    Z <- Z%*%covZ
    ZZ <- crossprod(Z) + N*covZ

    #
    # Optimization of the rotation (only start after the first
    # iteration)
    #
    if(opts$rotate && iter > 1){
      # Update the parameter list for the optimizer
      par[[5]] <- WW
      par[[6]] <- ZZ

      # Always start from the identity matrix, i.e. no rotation
      r <- as.vector(diag(K))
      if(opts$opt.method == "BFGS") {
        r.opt <- try( optim(r,E,gradE,par,method="BFGS",control=list(reltol=opts$opt.bfgs.crit, maxit=opts$opt.iter)), silent=TRUE)
      }
      if(opts$opt.method== "L-BFGS") {
        r.opt <- try( optim(r,E,gradE,par,method="L-BFGS-B",control=list(maxit=opts$opt.iter,factr=opts$lbfgs.factr)), silent=TRUE)
      }

      # For large K the optimizer occasionally fails due to problems
      # in the svd() routine
      if(inherits(r.opt,"try-error")) {
        print("Failure in optimizing the rotation. Turning the rotation off.")
        opts$rotate <- FALSE
      }else{
        # Update the parameters involved in the rotation: 
        R <- matrix(r.opt$par,K)
        eS <- svd(R)
        R.inv <- tcrossprod( eS$v*outer(id, 1/eS$d), eS$u)

        Z <- tcrossprod(Z,R.inv)
        covZ <- tcrossprod( R.inv%*%covZ, R.inv)
        ZZ <- crossprod(Z) + N*covZ

        for(m in 1:M){
          W[[m]] <- W[[m]]%*%R
          covW[[m]] <- crossprod(R,covW[[m]])%*%R
          WW[[m]] <- crossprod(W[[m]]) + covW[[m]]*D[m]
        }
      }
    }
    
    #
    # Update alpha, the ARD parameters
    #
    for(m in 1:M){
      tmp <- beta_0 + diag(WW[[m]])/2
      alpha[m,] <- a_ard[m]/tmp
      b_ard[m,] <- tmp
    }
    
    #
    # Update tau, the noise precisions
    #
    for(m in 1:M) {
      b_tau[m] <- beta_0t + ( Yconst[m] + sum(WW[[m]]*ZZ)
                             - 2*sum( tcrossprod(Z,W[[m]])*Y[[m]] ) )/2
    }
    tau <- a_tau/b_tau

    #
    # Calculate the lower bound.
    # Consists of calculating the likelihood term and 
    # KL-divergences between the factorization and the priors
    #

    # The precision terms
    logtau <- digamma(a_tau) - log(b_tau)
    for(m in 1:M) {
      logalpha[m,] <- digamma(a_ard[m]) - log(b_ard[m,])
    }
    lb.p <- const + sum(N*D/2*logtau) - sum( (b_tau - beta_0t)*tau )
    lb <- lb.p

    # E[ ln p(Z)] - E[ ln q(Z) ]
    lb.px <- - sum(diag(ZZ))/2
    
    lb.qx <- - N*sum(log(svd(covZ,nu=0,nv=0)$d))/2 - N*K/2 
    lb <- lb + lb.px - lb.qx

    # E[ ln p(W)] - E[ ln q(W)]
    lb.pw <- D[1]/2*sum(logalpha[1,]) -  sum(diag(WW[[1]])*alpha[1,])/2
    for(m in 2:M) {
      lb.pw <- lb.pw +
        D[m]/2*sum(logalpha[m,]) -  sum(diag(WW[[m]])*alpha[m,])/2
    }
    lb.qw <- -D[1]*sum(log(svd(covW[[1]],nu=0,nv=0)$d))/2 -D[1]*K/2
    for(m in 2:M) {
      lb.qw <- lb.qw - D[m]*sum(log(svd(covW[[m]],nu=0,nv=0)$d))/2 -D[m]*K/2
    }
    lb <- lb + lb.pw - lb.qw

    # E[ln p(alpha)] - E[ln q(alpha)]
    lb.pa <- M*K*( -lgamma(alpha_0) + alpha_0*log(beta_0) ) + (alpha_0-1)*sum(logalpha) - beta_0*sum(alpha)
    lb.qa <- -K*sum(lgamma(a_ard)) + sum(a_ard*rowSums( log(b_ard) )) + sum((a_ard-1)*rowSums(logalpha)) - sum(b_ard*alpha)
    lb <- lb + lb.pa - lb.qa

    # E[ln p(tau)] - E[ln q(tau)]
    lb.pt <- -M*lgamma(alpha_0t) + M*alpha_0t*log(beta_0t) + sum((alpha_0t-1)*logtau) - sum(beta_0t*tau)
    lb.qt <- -sum(lgamma(a_tau)) + sum(a_tau*log(b_tau)) + sum((a_tau-1)*logtau) - sum(b_tau*tau)
    lb <- lb + lb.pt - lb.qt

    # Store the cost function
    cost[iter] <- lb

    if(opts$verbose==2) {
      print(paste("Iteration:",iter,"/ cost:",lb))
    }
    # Convergence if the relative change in cost is small enough
    if(iter>1){
      diff <- cost[iter]-cost[iter-1]
      if( abs(diff)/abs(cost[iter]) < opts$iter.crit | iter == opts$iter.max ){ 
        break
      }
    }
  } # the main loop of the algorithm ends

  # Add a tiny amount of noise on top of the latent variables,
  # to supress possible artificial structure in components that
  # have effectively been turned off
  Z <- Z + opts$addednoise*matrix(rnorm(N*K,0,1),N,K) %*% chol(covZ)

  # return the output of the model as a list
  list(W=W,covW=covW,ZZ=ZZ,WW=WW,Z=Z,covZ=covZ,tau=tau,alpha=alpha,cost=cost,D=D,K=K,addednoise=opts$addednoise,datavar=datavar)
}

E <- function(r,par) {
  #
  # Evaluates the (negative) cost function value wrt the transformation
  # matrix R used in the generic optimization routine
  #
  R <- matrix(r,par$K)
  eS <- svd(R)

  val <- -sum(par$ZZ*(tcrossprod(eS$u*outer(rep(1,par$K),1/eS$d^2))),eS$u)/2
  val <- val + (par$Ds-par$N)*sum(log(eS$d))
  for(i in 1:par$M) {
    val <- val - par$D[i]*sum( log( colSums(R*(par$WW[[i]]%*%R)) ))/2
  }
  return(-val)
}

gradE <- function(r,par) {
  #
  # Evaluates the (negative) gradient of the cost function E()
  #
  R <- matrix(r,par$K)
  eS <- svd(R)
  Rinv <- tcrossprod(eS$v*outer(rep(1,par$K),1/eS$d), eS$u)
  gr <- as.vector( tcrossprod( tcrossprod( eS$u*outer(rep(1,par$K),1/eS$d^2) , eS$u )%*%par$ZZ + diag(par$Ds - par$N,par$K), Rinv) )

  tmp1 <- par$WW[[1]]%*%R
  tmp2 <- 1/colSums(R*tmp1)
  tmp1 <- par$D[1]*as.vector( tmp1*outer(rep(1,par$K),tmp2) )
  gr <- gr - tmp1
  for(i in 2:par$M){
    tmp1 <- par$WW[[i]]%*%R
    tmp2 <- 1/colSums(R*tmp1)
    tmp1 <- par$D[i]*as.vector( tmp1*outer(rep(1,par$K),tmp2) )
    gr <- gr - tmp1
  }
  return(-gr)
}

getDefaultOpts <- function(){
  #
  # A function for generating a default set of parameters.
  #
  # To run the algorithm with other values:
  #   opts <- getDefaultOpts()
  #   opts$opt.method <- "BFGS"
  #   model <- gsCCA(Y,K,opts)
  
  #
  # Whether to use the rotation explained in the ICML'11 paper.
  # Using the rotation is strongly recommended, only turn this
  # off if it causes problems.
  #  - TRUE|FALSE
  #
  rotate <- TRUE

  #
  # Parameters for controlling how the rotation is solved
  #  - opt.method chooses the optimization method and
  #    takes values "BFGS" or "L-BFGS". The former
  #    is typically faster but takes more memory, so the latter
  #    is the default choice. For small K may use BFGS instead.
  #  - opt.iter is the maximum number of iterations
  #  - lbfgs.factr is convergence criterion for L-BFGS; smaller
  #    values increase the accuracy (10^7 or 10^10 could be tried
  #    to speed things up)
  #  - bfgs.crit is convergence criterion for BFGS; smaller
  #    values increase the accuracy (10^-7 or 10^-3 could also be used)
  #
  opt.method <- "L-BFGS"
  opt.iter <- 10^5
  lbfgs.factr <- 10^3
  bfgs.crit <- 10^-5

  #
  # Initial value for the noise precisions. Should be large enough
  # so that the real structure is modeled with components
  # instead of the noise parameters (see Luttinen&Ilin, 2010)
  #  Values: Positive numbers, but generally should use values well
  #          above 1
  #
  init.tau <- 10^3

  #
  # Parameters for controlling when the algorithm stops.
  # It stops when the relative difference in the lower bound
  # falls below iter.crit or iter.max iterations have been performed.
  #
  iter.crit <- 10^-6
  iter.max <- 10^5

  #
  # Additive noise level for latent variables. The latent variables
  # of inactive components (those with very large alpha) occasionally
  # show some structure in the mean values, even though the distribution
  # matches very accurately the prior N(0,I). This structure disappears
  # is a tiny amount of random noise is added on top of the
  # mean estimates. Setting the value to 0 will make the predictions
  # deterministic
  #
  addednoise <- 1e-5
  
  #
  # Hyperparameters
  # - alpha_0, beta_0 for the ARD precisions
  # - alpha_0t, beta_0t for the residual noise predicions
  #
  prior.alpha_0 <- prior.beta_0 <- 1e-14
  prior.alpha_0t <- prior.beta_0t <- 1e-14

  #
  # Verbosity level
  #  0: Nothing
  #  1: Final cost function value for each run of gsCCAexperiment()
  #  2: Cost function values for each iteration
  #
  verbose <- 2
 
  return(list(rotate=rotate, init.tau=init.tau, iter.crit=iter.crit,
              iter.max=iter.max, opt.method=opt.method,
              lbfgs.factr=lbfgs.factr, bfgs.crit=bfgs.crit, opt.iter=opt.iter,
              addednoise=1e-6,
              prior.alpha_0=prior.alpha_0,prior.beta_0=prior.beta_0,
              prior.alpha_0t=prior.alpha_0t,prior.beta_0t=prior.beta_0t,
              verbose=verbose))
}

