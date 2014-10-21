require(ggplot2)
require(plyr)
require(rjson)
require(maps)
require(geosphere)

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

meltedData <- function (data) {
    melted <- data.frame(ttl = integer(0), experiment = integer(0), name = character(0),
    ip = character(0), rtt = numeric(0))
    
    for (experiment in 1:nrow(data)) {
        for (j in seq(2, ncol(data), 2)) {
            ttl <- j / 2
            name <- sprintf("Hop %02d - %s", ttl, data[experiment, j])
            ip <- data[experiment, j]
            rtt <- data[experiment, j + 1]
            melted <- rbind(melted, data.frame(ttl, experiment, name, ip, rtt))
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

summarizeData <- function (melted) {
    geoData <<- geolocateIps(unique(melted$ip)) 
    
    res <- ddply(melted, ~name, summarise, ip = unique(ip), 
    longitude = as.numeric(replace(geoData[!is.na(unique(ip)) & geoData$ip == unique(ip), c("longitude")], nrow(geoData[!is.na(unique(ip)) & geoData$ip == unique(ip),]) == 0, NA)),
    latitude = as.numeric(replace(geoData[!is.na(unique(ip)) & geoData$ip == unique(ip), c("latitude")], nrow(geoData[!is.na(unique(ip)) & geoData$ip == unique(ip),]) == 0, NA)),
    city = replace(geoData[!is.na(unique(ip)) & geoData$ip == unique(ip), c("city")], nrow(geoData[!is.na(unique(ip)) & geoData$ip == unique(ip),])  == 0, NA),
    country = replace(geoData[!is.na(unique(ip)) & geoData$ip == unique(ip), c("country_name")], nrow(geoData[!is.na(unique(ip)) & geoData$ip == unique(ip),]) == 0, NA),
    mean = replace(mean(rtt, na.rm = T), is.nan(mean(rtt, na.rm = T)), NA),
    sd = replace(sd(rtt, na.rm = T), is.nan(sd(rtt, na.rm = T)), NA)    )
    
    res[order(as.character(res$name)), ]
}

getRtti <- function (summarized) {
    rttis <- data.frame(ttl = numeric(0), rtti = numeric(0))
    
    lastRTT <- 0
    wasNA <- FALSE
    countNA <- 0
    
    for (i in 1:nrow(summarized)) {
        currRTT <- summarized$mean[i]
        
        if (is.na(currRTT)) {
            wasNA <- TRUE
            countNA <- countNA + 1
            next
        }
        
        diff <- currRTT - lastRTT
        
        if (wasNA) {            
            diff <- diff / (countNA + 1)
            for (j in countNA:0) {
                newI <- i - j
                rttis <- rbind(rttis, data.frame(ttl = newI, rtti = diff))	
            }
        } else {
            rttis <- rbind(rttis, data.frame(ttl = i, rtti = diff))
        }
        
        lastRTT <- currRTT
        wasNA <- FALSE
        countNA <- 0    
    }
    
    meanRtti <- mean(rttis$rtti)
    sdRtti <- sd(rttis$rtti)
    
    rttis$zscore <- sapply(rttis$rtti, function (x) { (x - meanRtti) / sdRtti } )
    
    rttis
}


plotAcumulated <- function (summarized, melted, filename) {    
    ggplot(data = summarized, aes(name, mean, group = 1)) + 
    geom_point(aes(x = name, y = rtt), data = melted[melted$ip %in% summarized$ip, ], colour = "red") +
    geom_point(shape = 21, size = 6, fill = "white") +
    geom_errorbar(width = 0.5, aes(ymin = mean - sd, ymax = mean + sd)) +    
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    labs(title = 'RTT a cada Host Intermedio', x = "Hop", y = "RTT")
    
    ggsave(filename, width = 8, height = 8)
}

plotZscore <- function (rttis, filename) {
    ggplot(data=rttis, aes(x=ttl, y=zscore), na.rm = TRUE) +    
    geom_bar(stat="identity",position = "identity") + 
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    labs(title = 'Z Score de cada RTTi', x = "RTTi", y = "Z Score")     
        
    ggsave(filename, width = 8, height = 8)
}

plotMap <-  function (summarized, filename) {    
    pdf(filename)
    
    data <- summarized[!is.na(summarized$longitude) & summarized$longitude != 0 & !is.na(summarized$latitude) & summarized$latitude != 0, c("longitude", "latitude")]
            
    map("world", col = "#f2f2f2", fill = TRUE, bg = "white", lwd=0.05)
    points(x = data$longitude, y = data$latitude, col = 'red', cex=0.5, pch=19)    
    
    firstNonNa <- -1
        
    for(i in 1:nrow(summarized)) {            
        if (!is.na(summarized$longitude[i]) & summarized$longitude[i] != 0 & !is.na(summarized$latitude[i]) & summarized$latitude[i] != 0) {
            firstNonNa <- i
            break
        }
    }
    
    if (firstNonNa == -1)
        return
        
    wasNA <- FALSE
        
    lastLongitude <- summarized$longitude[firstNonNa]
    lastLatitude <- summarized$latitude[firstNonNa]
    
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
        } else {
            lines(greatCircle, lwd= 0.5, lty = 1)            
        }
        
        lastLongitude <- currLongitude
        lastLatitude <- currLatitude
        wasNA <- FALSE        
    }

    dev.off()
}

doAll <- function (filename) {
    data <- loadData(filename)
    melted <- meltedData(data)
    summary <- summarizeData(melted)
    rttis <- getRtti(summary)
    
    plotAcumulated(summary, melted, paste(filename, ".rtt_acum.pdf", sep=""))
    plotZscore(rttis, paste(filename, ".rtti_zscore.pdf", sep=""))
    plotMap(summary, paste(filename, ".map.pdf", sep=""))
    
    print("RTT a cada Host")
    print(summary)
    
    print("RTTi con Z Score")
    print(rttis)
    
}