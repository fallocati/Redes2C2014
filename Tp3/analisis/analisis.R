require(rgl)

loadData <- function (filename) {
  raw <- read.csv(filename, header = F,comment.char = "#", sep = ";", col.names = c("time","prob","delay","alpha", "beta","rto","rtt"))
	raw <- raw[order(raw$alpha) , ] #sort by alpha
  raw
}

#usando distintas libs
plot_alpha_beta_rto <- function(data){
  #library(hdrcde)
  
  plot3d(data$alpha, data$beta, data$rto, xlab = "alpha", ylab = "beta", zlab = "rto", type="s", col=heat.colors(150), size=1, box = F, xlim=c(0,1),ylim=c(0,1),zlim=c(0,1))
  
  #rgl.viewpoint( theta = 0, phi = 15, fov = 60, zoom = 0.5, scale = par3d("scale"))
	#r3dDefaults$windowRect <- c(0,50, 700, 700) 
  
  #rgl.snapshot(filename="captura.png",fmt="png") 
}

plot2 <- function(data){
  library(akima)
  require(fields)
  require(stats)
  
  x <- data$alpha
  y <- data$beta
  z <- data$rto
   
  spline <- interp(x,y,z,linear=FALSE, duplicate=TRUE)
  open3d(scale=c(1/diff(range(x)), 1/diff(range(y)), 1/diff(range(z))))
  plot3d(data$alpha, data$beta, data$rto, xlab = "alpha", ylab = "beta", zlab = "rto", type = "s", col = heat.colors(1500), size = 1, box = F, xlim = c(0,0.5),ylim = c(0,0.5),zlim = c(0,0.5))
  with(spline,surface3d(x,y,z,alpha=.9))
  axes3d()

}

plot3 <- function(data){
#   library(MBA)
#   
#   x <- data$alpha
#   y <- data$beta
#   z <- data$rto
#   
#   spline <- mba.surf(data.frame(x,y,z),100,100)  
#   open3d(scale=c(1/diff(range(x)),1/diff(range(y)),1/diff(range(z))))
#   plot3d(data$alpha, data$beta, data$rto, xlab = "alpha", ylab = "beta", zlab = "rto", type = "s", col = heat.colors(150), size = 1, box = F, xlim = c(0,0.5),ylim = c(0,0.5),zlim = c(0,0.5))
#   with(spline$xyz,surface3d(x,y,z,alpha=.2))
#   axes3d()
  library(Rcmdr)
  attach(mtcars)
  
  scatter3d(data$alpha, data$beta, data$rto,  point.col="black", axis.scales=TRUE,sphere.size=2, threshold=0.01, fov=60) 
  
}

#plot4 <- function(data){
  #require(rms)
#}

regressionplot <- function(data){
  
  plot3d(data$alpha, data$beta, data$rto, box=FALSE, col=rainbow(1000), type="s", size=1,alpha=0.75)
  fit <- lm(data$rto ~ data$alpha + data$beta)
  coefs <- coef(fit)
  planes3d(a=coefs["data$alpha"], b=coefs["data$beta"], -1, coefs["(Intercept)"], alpha=0.50, col="plum2")  
  #play3d( spin3d(axis=c(1,1,0)), duration=5 )
}

wireframeplot <- function(data){
  library(TeachingDemos)
  library(lattice)
  #attach(data)
  #plot3d(data$alpha, data$beta, data$rto, col="red", size=4)
  #detach(data)
  x <- data$alpha
  y <- data$beta
  z <- data$rto
  
  rotate.wireframe(z ~ x+y, data = data,xlab="alpha",ylab="beta", zlab ="RTO", # label axes
  scales = list(arrows = FALSE), # turn arrows off
  drape = F, # do not drape in color
  shade=F, # no illumination model
  zoom=0.95 ) #zoom
}
