require(ggplot2)
require(plyr)

# Helper functions
insertRow <- function(existingDF, newrow) {    
    rbind(existingDF, newrow)
}

# Analisis functions
loadData <- function (filename) {
    setClass("myDate")
    setAs("character", "myDate", function(from) as.POSIXct(from, format = "%Y%m%d%H%M") )
    firstCol <- read.csv(filename, header = F, sep = ";", nrows = 1)
    ttls <- (ncol(firstCol) - 1) / 2
    
    raw <- read.csv(filename, header = F, sep=";", na.strings = "*", dec=".",
    allowEscapes = T, colClasses = as.vector(c("myDate", rep(c("character", "numeric"),
    ttls))), col.names = c(c("DateTime"), rbind(paste("IP_TTL_", 0:ttls, sep = ""), 
    paste("RTT_TTL_", 0:ttls, sep = ""))))
    
    raw[, c(1, 4:(ncol(raw) - 2))]
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
    sapply(data[, rttColumns(data)], mean, na.rm = T)
}

rttSd <- function (data) {
    sapply(data[, rttColumns(data)], sd, na.rm = T)
}

meltedData <- function (data) {
    melted <- data.frame(ttl = integer(0), experiment = integer(0), ip = character(0),
    rtt=numeric(0))
    
    for (experiment in 1:nrow(data)) {
        for (j in seq(2, ncol(data), 2)) {
            ttl <- j / 2
            ip <- sprintf("Hop %02d - %s", ttl, data[experiment, j])
            rtt <- data[experiment, j + 1]
            melted <- insertRow(melted, data.frame(ttl, experiment, ip, rtt))
        }
    }
    
    melted[melted$ttl > 0, ]
}

summariseData <- function (data) {    
    res <- ddply(meltedData(data), ~ip, summarise, mean = replace(mean(rtt, na.rm = T), 
    is.nan(mean(rtt, na.rm = T)), NA), sd = replace(sd(rtt, na.rm = T),
    is.nan(sd(rtt, na.rm = T)), NA), min = min(rtt), max = max(rtt))
    
    res[order(as.character(res$ip)), ]
}

plotAcumulated <- function (summarized, melted) {
    ggplot(data = summarized, aes(ip, mean, group = 1)) + 
    geom_point(aes(x = ip, y = rtt), data = melted[melted$ip %in% summarized$ip, ], colour = "red") +
    geom_point(shape = 21, size = 6, fill = "white") +
    geom_errorbar(width = 0.5, aes(ymin = mean - sd, ymax = mean + sd)) +
    #geom_smooth(aes(ymin = mean - sd, ymax = mean + sd), stat = "identity") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) 
}

plotOriginal <- function (data) {
    plotAcumulated(summariseData(data), meltedData(data))
}