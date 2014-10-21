require(ggplot2)
require(plyr)
require(rjson)
require(maps)

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
    paste("RTT_TTL_", 0:ttls, sep = ""))), nrows = 20)
    
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
    melted <- data.frame(ttl = integer(0), experiment = integer(0), name = character(0),
    ip = character(0), rtt = numeric(0))
    
    for (experiment in 1:nrow(data)) {
        for (j in seq(2, ncol(data), 2)) {
            ttl <- j / 2
            name <- sprintf("Hop %02d - %s", ttl, data[experiment, j])
            ip <- data[experiment, j]
            rtt <- data[experiment, j + 1]
            melted <- insertRow(melted, data.frame(ttl, experiment, name, ip, rtt))
        }
    }
    
    melted$name <- as.character(melted$name)
    melted$ip <- as.character(melted$ip)
    
    melted[melted$ttl > 0, ]
}

geolocateIps <- function(ip) {        
    ret <- data.frame()
    
    for (i in 1:length(ip)) {
        if (is.na(ip[i]))
            next
        
        url <- paste(c("http://freegeoip.net/json/", ip[i]), collapse='')
        
        value <- data.frame(t(unlist(fromJSON(readLines(url, warn=FALSE)))), stringsAsFactors = F)
                
        ret <- rbind(ret, value)
    }
    
    ret    
}

summariseData <- function (melted) {
    geoData <<- geolocateIps(unique(melted$ip)) 
    
    res <- ddply(melted, ~name, summarise, ip = unique(ip), 
    longitude = as.numeric(replace(geoData[!is.na(unique(ip)) & geoData$ip == unique(ip), c("longitude")], nrow(geoData[!is.na(unique(ip)) & geoData$ip == unique(ip),]) == 0, NA)),
    latitude = as.numeric(replace(geoData[!is.na(unique(ip)) & geoData$ip == unique(ip), c("latitude")], nrow(geoData[!is.na(unique(ip)) & geoData$ip == unique(ip),]) == 0, NA)),
    city = replace(geoData[!is.na(unique(ip)) & geoData$ip == unique(ip), c("city")], nrow(geoData[!is.na(unique(ip)) & geoData$ip == unique(ip),])  == 0, NA),
    country = replace(geoData[!is.na(unique(ip)) & geoData$ip == unique(ip), c("country_name")], nrow(geoData[!is.na(unique(ip)) & geoData$ip == unique(ip),]) == 0, NA),
    mean = replace(mean(rtt, na.rm = T), is.nan(mean(rtt, na.rm = T)), NA),
    sd = replace(sd(rtt, na.rm = T), is.nan(sd(rtt, na.rm = T)), NA),
    min = min(rtt), max = max(rtt))
    
    res[order(as.character(res$name)), ]
}

plotAcumulated <- function (summarized, melted) {
    ggplot(data = summarized, aes(ip, mean, group = 1)) + 
    geom_point(aes(x = ip, y = rtt), data = melted[melted$ip %in% summarized$ip, ], colour = "red") +
    geom_point(shape = 21, size = 6, fill = "white") +
    geom_errorbar(width = 0.5, aes(ymin = mean - sd, ymax = mean + sd)) +
    #geom_smooth(aes(ymin = mean - sd, ymax = mean + sd), stat = "identity") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    labs(title = 'RTT a cada Host Intermedio', x = "Hop", y = "RTT")
}

plotZscore <- function (zscore) {    
    ggplot(data=zscore, aes(x=ip, y=prom),na.rm = TRUE) +    
    geom_bar(stat="identity",position = "identity") + 
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    labs(title = 'ZScore de cada RTTi', x = "IP", y = "ZScore")     
    #ggsave(file="zscore.pdf") 
}

plotMap <-  function(summarized) {    
    #xlim <- c(-171.738281, -56.601563)
    #ylim <- c(12.039321, 71.856229)
    
    data <- summarized[!is.na(summarized$longitude) & summarized$longitude != 0 & !is.na(summarized$latitude) & summarized$latitude != 0, c("longitude", "latitude")]
            
    map("world", col = "#f2f2f2", fill = TRUE, bg = "white", lwd=0.05)
    points(x = data$longitude, y = data$latitude, col = 'red', cex=0.5, pch=19)    
    
    firstNonNa <- -1
    
    
    for(i in 1:nrow(summarized)) {            
        if (!is.na(summarized$longitude[i]) & summarized$longitude[i] != 0 & !is.na(summarized$latitude[i]) & summarized$latitude[i] != 0)
        {
            firstNonNa <- i
            break
        }
    }
    
    if (firstNonNa == -1)
        return
        
    wasNA <- FALSE
    
    # lat_d2 <- as.numeric(geo[13,5])
    # lon_d2 <- as.numeric(geo[13,6])
    # inter <- gcIntermediate(c(lon_o, lat_o), c(lon_d, lat_d), n=50, addStartEnd=TRUE)
    # inter2 <- gcIntermediate(c(lon_d, lat_d), c(lon_d2, lat_d2), n=50, addStartEnd=TRUE)
    # lines(inter)
    # lines(inter2)
    #inter <- gcIntermediate(c(lon_o, lat_o), c(lon_d, lat_d), n=50, addStartEnd=TRUE)
    #lines(inter)
    
    lastLongitude <- summarized$longitude[firstNonNa]
    lastLatitude <- summarized$latitude[firstNonNa]
    
    pallete <- topo.colors(nrow(data) + 1)
    nextColor <- 1
    
    for (i in (firstNonNa + 1):nrow(summarized)) {
        
        currLongitude <- summarized$longitude[i]
        currLatitude <- summarized$latitude[i]
        
        if (is.na(currLongitude) | is.na(currLatitude)) {
            wasNA <- TRUE
            next
        }
        
        if (lastLongitude == currLongitude & lastLatitude == currLatitude) {
            next
        }
        
        greatCircle <- gcIntermediate(c(lastLongitude, lastLatitude), c(currLongitude, currLatitude), n=5000, addStartEnd=TRUE)
                
        if (wasNA) {
            lines(greatCircle, lwd= 0.5, lty = 2)
            #arrows(lastLongitude, lastLatitude, currLongitude, currLatitude, code=2, lwd= 0.5, length = 0.03, col = pallete[nextColor])
        } else {
            lines(greatCircle, lwd= 0.5, lty = 1)
            #arrows(lastLongitude, lastLatitude, currLongitude, currLatitude, code=2, lwd= 0.5, length = 0.03, col = pallete[nextColor])
        }
        lastLongitude <- currLongitude
        lastLatitude <- currLatitude
        wasNA <- FALSE
        nextColor <- nextColor + 1
    }
    
     dev.print(pdf, file="filename.pdf");
     dev.off()
}