library(gridExtra)
library(ggplot2)
theme_set(theme_bw())

load("PLAT.RData")


# Plat Male

ax <- ggplot() + 
  geom_line(aes(x=as.numeric(names(PLATM$ax)), y=as.vector(PLATM$ax))) +
  xlab("t") + ylab(expression(alpha[x])) +
  ggtitle(expression(alpha[x])) +
  theme(text = element_text(size=9), plot.title = element_text(hjust = 0.5)) 

kt1 <- ggplot() + 
  geom_line(aes(x=as.numeric(names(PLATM$kt[[1]]$y)), y=as.vector(PLATM$kt[[1]]$y))) +
  xlab("t") + ylab(expression(kappa[t]^{(1)})) +
  ggtitle(expression(kappa[t]^{(1)})) +
  theme(text = element_text(size=9), plot.title = element_text(hjust = 0.5)) 

kt2 <- ggplot() + 
  geom_line(aes(x=as.numeric(names(PLATM$kt[[2]]$y)), y=as.vector(PLATM$kt[[2]]$y))) +
  xlab("t") + ylab(expression(kappa[t]^{(2)})) +
  ggtitle(expression(kappa[t]^{(2)})) +
  theme(text = element_text(size=9), plot.title = element_text(hjust = 0.5)) 

kt3 <- ggplot() + 
  geom_line(aes(x=as.numeric(names(PLATM$kt[[3]]$y)), y=as.vector(PLATM$kt[[3]]$y))) +
  xlab("t") + ylab(expression(kappa[t]^{(3)})) +
  ggtitle(expression(kappa[t]^{(3)})) +
  theme(text = element_text(size=9), plot.title = element_text(hjust = 0.5)) 

gc <- ggplot() + 
  geom_line(aes(x=as.numeric(names(PLATM$gc$y)), y=as.vector(PLATM$gc$y))) +
  xlab("c") + ylab(expression(gamma[c])) +
  ggtitle(expression(gamma[c])) +
  theme(text = element_text(size=9), plot.title = element_text(hjust = 0.5)) 



(PLATM_param_graphM <- grid.arrange(ax, kt1, kt2, kt3, gc, ncol=1, top="Male"))


# Plat Female

ax <- ggplot() + 
  geom_line(aes(x=as.numeric(names(PLATF$ax)), y=as.vector(PLATF$ax))) +
  xlab("t") + ylab(expression(alpha[x])) +
  ggtitle(expression(alpha[x])) +
  theme(text = element_text(size=9), plot.title = element_text(hjust = 0.5)) 

kt1 <- ggplot() + 
  geom_line(aes(x=as.numeric(names(PLATF$kt[[1]]$y)), y=as.vector(PLATF$kt[[1]]$y))) +
  xlab("t") + ylab(expression(kappa[t]^{(1)})) +
  ggtitle(expression(kappa[t]^{(1)})) +
  theme(text = element_text(size=9), plot.title = element_text(hjust = 0.5)) 

kt2 <- ggplot() + 
  geom_line(aes(x=as.numeric(names(PLATF$kt[[2]]$y)), y=as.vector(PLATF$kt[[2]]$y))) +
  xlab("t") + ylab(expression(kappa[t]^{(2)})) +
  ggtitle(expression(kappa[t]^{(2)})) +
  theme(text = element_text(size=9), plot.title = element_text(hjust = 0.5)) 

kt3 <- ggplot() + 
  geom_line(aes(x=as.numeric(names(PLATF$kt[[3]]$y)), y=as.vector(PLATF$kt[[3]]$y))) +
  xlab("t") + ylab(expression(kappa[t]^{(3)})) +
  ggtitle(expression(kappa[t]^{(3)})) +
  theme(text = element_text(size=9), plot.title = element_text(hjust = 0.5)) 

gc <- ggplot() + 
  geom_line(aes(x=as.numeric(names(PLATF$gc$y)), y=as.vector(PLATF$gc$y))) +
  xlab("c") + ylab(expression(gamma[c])) +
  ggtitle(expression(gamma[c])) +
  theme(text = element_text(size=9), plot.title = element_text(hjust = 0.5)) 



(PLATF_param_graphF <- grid.arrange(ax, kt1, kt2, kt3, gc, ncol=1, top="Female"))


win.graph(width=6, height=10)
grid.arrange(PLATM_param_graphM, PLATF_param_graphF, ncol=2)