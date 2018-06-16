Bayesian CCA via group sparsity (gsCCA)
Copyright (C) 2011 Seppo Virtanen and Arto Klami


LICENCE

The code is released under the FreeBSD license. See license.txt
for details.


CITING

If you use the software, please cite the following publication:
Seppo Virtanen, Arto Klami, Samuel Kaski: Bayesian CCA via group
sparsity. Proceedings of the 28th International Conference on Machine
Learning (ICML). 2011.


CONTACT INFORMATION

Seppo Virtanen, seppo.j.virtanen@aalto.fi

Aalto University
Department of Information and Computer Science
Helsinki Institute for Information Technology HIIT

http://research.ics.aalto.fi/mi/



DOCUMENTATION
=============

INTRODUCTION

This package includes:
- source code for the R implementation of the Bayesian CCA (gsCCA.R)
- some additional tools for analysing the results (gsCCAtools.R)
- an example of how the code can be used (gsCCAexample.R)
- readme.txt (this file) and license.txt

The model is described in the publication 'Bayesian CCA via group
sparsity' in ICML'11, available at
http://www.icml-2011.org/papers/318_icmlpaper.pdf .  This package is
available at http://research.ics.tkk.fi/mi/software/gsCCA/ .

The package is tested with a Linux platform and R version 2.12.0.

MANUAL

See gsCCAexample.R for a practical example on using the code.

In the simplest form, the code is applied as
***
  opts <- getDefaultOpts()
  model <- gsCCAexperiment(Y,K)
***
Here Y is a two-element list containing NxD1 and NxD2 data matrices
with co-occurring samples, and K is the number of components. The data
is assumed to be zero-mean, so remember to remove the mean of each
feature. The rest of the parameters for the model can be changed by
modifying the contents of the opts-variable. See the description of
getDefaultOpts() in the gsCCA.R file for details.

After running the model, it is typically a good idea to apply
***
  model <- gsCCAtrim(model)
***
to prune out components that are not needed. For very high component
numbers the optional threshold parameter should be set for lower
value.

One application scenario for CCA is multi-label prediction where
one of the data sets contains labels that are to be predicted.
The prediction can be done by
***
  observed <- c(0,1)
  pred <- gsCCApred(observed,Ytest,model)
***
where the vector observed tells which of the data sets are
observed (value 1) and which need to be predicted (value 0).

gsCCA can also be applied for data analysis scenarios. The
latent variables stored at model$Z give a lower-dimensional
representation for the data. A representation capturing only
the dependencies (correlations) between the data sets is
obtained by
***
  trimmed <- gsCCAtrim(model)
  # Shared representation for training data
  sharedTrain <- trimmed$Z[,which(apply(trimmed$active,2,sum)==2)]

  # Shared representation for test data
  observed <- c(1,1)
  pred <- gsCCApred(observed,Ytest,trimmed)
  sharedTest <- pred$Z[,which(apply(trimmed$active,2,sum)==2)]
***

Note that the code does not guarantee orhtogonal latent variables
(i.e. corr(model$Z[,i],model$Z[,j] = delta_ij)) and hence does not
necessarily result in solutions identical with classical CCA for all
cases. However, it attempts to learn a model for which the variables
are maximally non-correlating.

Further examples of analyzing the results can be found in
gsCCAexample.R.


CHANGES
=======

Changes from version 1.0 to version 1.01:
 - gsCCAtrim() in gsCCAtools.R referred to K when they should have
   referred to model$K, reading the value from the global variable scope.
   This has been fixed.
 - gsCCApred() referred to opts$addednoise, without taking opts
   as an argument. It is now fixed to model$addednoise.
 - The gsCCApred() function now supports drawing samples from the
   predictive posterior
