# Helper functions
insertRow <- function(existingDF, newrow) {    
    rbind(existingDF, newrow)
}

# Analisis functions
loadData <- function (filename) {
    setClass("myDate")
    setAs("character","myDate", function(from) as.POSIXct(from, format="%Y%m%d%H%M") )
    firstCol <- read.csv(filename, header=F, sep=";", nrows=1)
    ttls <- (ncol(firstCol) - 1) / 2
    
    raw <- read.csv(filename, header=F, sep=";", na.strings = "*",
    colClasses=as.vector(c("myDate", rep(c("character", "numeric"), ttls))),
    col.names=c(c("DateTime"), rbind(paste("IP_TTL_", 1:ttls, sep=""), 
    paste("RTT_TTL_", 1:ttls, sep=""))))    
}

ipColumns <- function (data) {    
    seq(2, ncol(data), 2)
}

rttColumns <- function (data) {    
    seq(3, ncol(data), 2)
}

rttMatrix <- function (data) {
    data.matrix(data[, rttColumns(data)])
}

rttMeans <- function (data) {
    sapply(data[, rttColumns(data)], mean, na.rm=T)
}

rttSd <- function (data) {
    sapply(data[, rttColumns(data)], sd, na.rm=T)
}

meltedData <- function (data) {
    melted <- data.frame(ttl=integer(0), experiment=integer(0), ip=character(0), rtt=numeric(0))
    
    for (experiment in 1:nrow(data)) {
        for (j in seq(2, ncol(data), 2)) {
            ttl <- j / 2
            ip <- data[experiment, j]
            rtt <- data[experiment, j + 1]
            melted <- insertRow(melted, data.frame(ttl, experiment, ip, rtt))
        }
    }
    
    melted
}

ggplot(melted, aes(experiment, rtt)) + geom_point() + facet_wrap(~ttl)
ggplot(melted, aes(ip, rtt)) + geom_point()