loadData <- function (filename) {
    setClass("myDate")
    setAs("character","myDate", function(from) as.POSIXct(from, format="%Y%m%d%H%M") )
    firstCol <- read.csv(filename, header=F, sep=";", nrows=1)
    ttls <- (ncol(firstCol) - 1) / 2
    
    read.csv(filename, header=F, sep=";", na.strings = "*",
    colClasses=as.vector(c("myDate", rep(c("character", "numeric"), ttls))),
    col.names=c(c("DateTime"), rbind(paste("IP_TTL_", 1:ttls, sep=""), 
    paste("RTT_TTL_", 1:ttls, sep=""))))
}
