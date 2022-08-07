# ------------------------ #
# see Appendix 1 of Li2009 #
# ------------------------ #

# predict deaths from parameters
update_dhxt <- function(Ext, ax, bx, kt){
  Ext*exp(sweep(outer(bx, kt), 1, ax, "+"))
} 

update_fxt <- function(dxt, lambdax, wxt){
  ans <- matrix(nrow=nrow(dxt), ncol=ncol(dxt))
  for (x in 1:nrow(ans)){
    lambda <- lambdax[x]
    for (t in 1:ncol(ans)){
      if (wxt[x, t]==1){
        d <- dxt[x, t]
        if (d==0){
          ans[x, t] <- 0
        }
        else {
          i <- 0:(d-1)
          ans[x, t] <- sum(i/(1+lambda*i) - 1/lambda)
        }
      }
    }
  }
  return(ans)
}

update_gxt <- function(dxt, dhxt, lambdax){
  dhxt*sweep(dxt, 1, 1/lambdax, "+")/
  (1+sweep(dhxt, 1, lambdax, "*"))
}

update_hxt <- function(dxt, lambdax, wxt){
  ans <- matrix(nrow=nrow(dxt), ncol=ncol(dxt))
  for (x in 1:nrow(ans)){
    lambda <- lambdax[x]
    for (t in 1:ncol(ans)){
      if (wxt[x, t]==1){
        d <- dxt[x, t]
        if (d==0){
          ans[x, t] <- 0
        }
        else{
          i <- 0:(d-1)
          ans[x, t] <- sum(-(i/(1+lambda*i))^2 - 1/lambda^2)
        }
      }
    }
  }
  return(ans)
}


update_rxt <- function(dhxt, lambdax){
  sweep(log(1+sweep(dhxt, 1, lambdax, "*")), 1, lambdax^2, "/")
}

update_ax <- function(dxt, dhxt, ax, lambdax, gxt){
  ax - 
  rowSums(dxt-sweep(gxt, 1, lambdax, "*"), na.rm = TRUE)/
  rowSums((-sweep(gxt, 1, lambdax, "*"))/
          (1+sweep(dhxt, 1, lambdax, "*")), na.rm = TRUE)
}

update_bx <- function(dxt, dhxt, bx, kt, lambdax, gxt){
  bx - 
  rowSums(sweep(dxt, 2, kt, "*")-
          outer(lambdax, kt)*gxt, na.rm = TRUE)/
  rowSums((-outer(lambdax, kt^2)*gxt)/
          (1+sweep(dhxt, 1, lambdax, "*")), na.rm = TRUE)
}

update_kt <- function(dxt, dhxt, bx, kt, lambdax, gxt){
  kt - 
  colSums(sweep(dxt, 1, bx, "*")-
            sweep(gxt, 1, lambdax*bx, "*"), na.rm = TRUE)/
  colSums(-sweep(gxt, 1, lambdax*bx^2, "*")/
          (1+sweep(dhxt, 1, lambdax, "*")), na.rm = TRUE)
}

update_lambdax <- function(dxt, dhxt, lambdax, fxt, gxt, hxt, rxt){
  lambdax - 
  rowSums(fxt-gxt+rxt+sweep(dxt, 1, lambdax, "/"), na.rm = TRUE)/
  rowSums(hxt-sweep(dxt+sweep(2*rxt, 1, lambdax, "*"), 1, lambdax^2, "/")+
          sweep(gxt, 1, 2/lambdax^2, "+")*
          (dhxt/(1+sweep(dhxt, 1, lambdax, "*"))), na.rm = TRUE)
}

# computes the log-likelihood for the model (outside of independent constant)
negbinom_loglik <- function(dxt, dhxt, lambdax, wxt){
  loglik <- sum(dxt*log(sweep(dhxt, 1, lambdax, "*")) - 
            sweep(dxt, 1, 1/lambdax, "+")*
            log(1+sweep(dhxt, 1, lambdax, "*")), na.rm = TRUE)
  for (x in 1:nrow(dxt)){
    lambda <- lambdax[x]
    for (t in 1:ncol(dxt)){
      if (wxt[x, t]==1){
        d <- dxt[x, t]
        if (d>0){
          i <- 0:(d-1)
          total <- sum(log((1+lambda*i)/lambda))
          loglik <- loglik + total
        }
      }
    }
  }
  return(as.numeric(loglik))
}

# computes the deviance of the model
negbinom_deviance <- function(dxt, dhxt, lambdax){
  2*sum(dxt*log(dxt/dhxt) - 
  sweep(dxt, 1, 1/lambdax, "+")*
  log((1+sweep(dxt, 1, lambdax, "*"))/
  (1+sweep(dhxt, 1, lambdax, "*"))), na.rm = TRUE)
}

# fit negative binomial model
# best to have the starting parameters be the MLE Poisson parameters
LCnegbinom <- function(start_param, dxt, Ext, wxt, maxiter){
  # start_param
  ax <- as.vector(start_param$ax)
  bx <- as.vector(start_param$bx)
  kt <- as.vector(start_param$kt)
  dhxt <- update_dhxt(Ext, ax, bx, kt)
  lambdax <- apply(dxt/dhxt, 1, var, na.rm=TRUE)
  
  i <- 1
  for (k in 1:maxiter){
    #0
    fxt <- update_fxt(dxt, lambdax, wxt)
    gxt <- update_gxt(dxt, dhxt, lambdax)
    hxt <- update_hxt(dxt, lambdax, wxt)
    #1
    ax <- update_ax(dxt, dhxt, ax, lambdax, gxt)
    #2
    dhxt <- update_dhxt(Ext, ax, bx, kt)
    gxt <- update_gxt(dxt, dhxt, lambdax)
    bx <- update_bx(dxt, dhxt, bx, kt, lambdax, gxt)
    bx <- bx/sum(bx)
    #3
    dhxt <- update_dhxt(Ext, ax, bx, kt)
    gxt <- update_gxt(dxt, dhxt, lambdax)
    kt <- update_kt(dxt, dhxt, bx, kt, lambdax, gxt)
    kt <- kt - 1/ncol(dxt)*sum(kt)
    #4
    dhxt <- update_dhxt(Ext, ax, bx, kt)
    rxt <- update_rxt(dhxt, lambdax)
    gxt <- update_gxt(dxt, dhxt, lambdax)
    lambdax <- update_lambdax(dxt, dhxt, lambdax, fxt, gxt, hxt, rxt)

    if (i == maxiter){
      break
    }
    i <- i+1
    # loglik <- negbinom_loglik(dxt, dhxt, lambdax, wxt)
    # print(loglik)
  }
  new_deviance <- negbinom_deviance(dxt, dhxt, lambdax)
  new_loglik <- negbinom_loglik(dxt, dhxt, lambdax, wxt)
  return(list(ax=ax, bx=bx, kt=kt, lambdax=lambdax, 
              deviance=new_deviance, loglik=new_loglik))
}