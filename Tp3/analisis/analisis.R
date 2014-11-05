require(rgl)

loadData <- function (filename) {

  raw <- read.csv(filename, header = F, sep = "\t", col.names = c("time", "alpha", "beta","rto","rtt"))
	raw
}

#usando distintas libs
plot_alpha_beta_rto <- function(data){
  
  plot3d(data$alpha, data$beta, data$rto, xlab = "alpha", ylab = "beta", zlab = "rto", type="s", col=heat.colors(150), size=3, box = F, xlim=c(0,1),ylim=c(0,1),zlim=c(0,1))
	
  #rgl.viewpoint( theta = 0, phi = 15, fov = 60, zoom = 0.5, scale = par3d("scale"))
	#r3dDefaults$windowRect <- c(0,50, 700, 700) 
  
  #aspect3d(3,3,3) # aspect:ratio
	#browseURL(paste("file://", writeWebGL(dir=file.path(tempdir(), "webGL"), width=500), sep=""))
  #rgl.snapshot(filename="captura.png",fmt="png") 
}

plot2 <- function(data){
  library(akima)
  
  x <- data$alpha
  y <- data$beta
  z <- data$rto
  
  spline <- interp(x,y,z,linear=FALSE, duplicate=TRUE)
  open3d(scale=c(1/diff(range(x)), 1/diff(range(y)), 1/diff(range(z))))
  plot3d(data$alpha, data$beta, data$rto, xlab = "alpha", ylab = "beta", zlab = "rto", type = "s", col = heat.colors(150), size = 2, box = F, xlim = c(0,0.5),ylim = c(0,0.5),zlim = c(0,0.5))
  with(spline,surface3d(x,y,z,alpha=.2))
  axes3d()
  
}

plot3 <- function(data){
  library(MBA)
  
  x <- data$alpha
  y <- data$beta
  z <- data$rto
  
  spline <- mba.surf(data.frame(x,y,z),100,100)  
  open3d(scale=c(1/diff(range(x)),1/diff(range(y)),1/diff(range(z))))
  plot3d(data$alpha, data$beta, data$rto, xlab = "alpha", ylab = "beta", zlab = "rto", type = "s", col = heat.colors(150), size = 2, box = F, xlim = c(0,0.5),ylim = c(0,0.5),zlim = c(0,0.5))
  with(spline$xyz,surface3d(x,y,z,alpha=.2))
  axes3d()
  
}

#plot4 <- function(data){
  #require(rms)
#}

regressionplot <- function(data){
  
  plot3d(data$alpha, data$beta, data$rto, box=FALSE, col="steelblue", type="s", size=3,alpha=0.75)
  fit <- lm(data$rto ~ data$alpha + data$beta)
  coefs <- coef(fit)
  planes3d(a=coefs["data$alpha"], b=coefs["data$beta"], -1, coefs["(Intercept)"], alpha=0.50, col="plum2")  
 # play3d( spin3d(axis=c(1,1,0)), duration=5 )
}
