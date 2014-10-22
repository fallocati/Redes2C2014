require(ggplot2)
require(grid)
require(plyr)
require(rjson)
require(maps)
require(geosphere)
require(data.table)

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
    rows.list = vector(mode="list",nrow(data))
    
    for (experiment in 1:nrow(data)) {
        for (j in seq(2, ncol(data), 2)) {
            ttl <- j / 2
            name <- sprintf("%02d - %s", ttl, data[experiment, j])
            ip <- data[experiment, j]
            rtt <- data[experiment, j + 1]
            #melted <- rbind(melted, data.frame(ttl, experiment, name, ip, rtt))
            rows.list[[length(rows.list)+1]] <- data.frame(ttl, experiment, name, ip, rtt)
        }
    }
    
    melted <- rbindlist(rows.list)
    melted$name <- as.character(melted$name)
    melted$ip <- as.character(melted$ip)
    
    melted[melted$ttl > 0, ]
}

geolocateIps <- function(ip) {        
    ret <- data.frame()
        
    for (i in 1:length(ip)) {        
        if (is.na(ip[i]))
            next
        
        url <- paste(c("http://www.plotip.com/ip/", ip[i]), collapse='')
        html <- readLines(url, warn=FALSE)
        html <- html[grep(x=html, pattern="Latitude/Longitude") + 1]
        sapply(unlist(strsplit(html, "([+-]?\\d+.\\d+)|\\s")), function (x) { html <<- sub(x, "", html) })
        html <- unlist(strsplit(sub("^\\s+", "", html), " "))
        
        if (length(html) != 2) {            
            url <- paste(c("http://freegeoip.net/json/", ip[i]), collapse='')            
            value <- fromJSON(readLines(url, warn=FALSE))
            ret <- rbind(ret, data.frame(ip = ip[i], longitude = as.numeric(value$longitude),
            latitude = as.numeric(value$latitude)))            
        } else {
            ret <- rbind(ret, data.frame(ip = ip[i], longitude = as.numeric(html[2]),
            latitude = as.numeric(html[1])))
        }        
    }
    
    #ret <- rbindlist(rows.list)
    ret    
}

summarizeData <- function (melted) {
    geoData <<- geolocateIps(unique(melted$ip)) 
    
    res <- ddply(melted, ~name, summarise, ip = unique(ip), 
    longitude = as.numeric(replace(geoData[!is.na(unique(ip)) & geoData$ip == unique(ip), c("longitude")], nrow(geoData[!is.na(unique(ip)) & geoData$ip == unique(ip),]) == 0, NA)),
    latitude = as.numeric(replace(geoData[!is.na(unique(ip)) & geoData$ip == unique(ip), c("latitude")], nrow(geoData[!is.na(unique(ip)) & geoData$ip == unique(ip),]) == 0, NA)),
    #city = replace(geoData[!is.na(unique(ip)) & geoData$ip == unique(ip), c("city")], nrow(geoData[!is.na(unique(ip)) & geoData$ip == unique(ip),])  == 0, NA),
    #country = replace(geoData[!is.na(unique(ip)) & geoData$ip == unique(ip), c("country_name")], nrow(geoData[!is.na(unique(ip)) & geoData$ip == unique(ip),]) == 0, NA),
    mean = replace(mean(rtt, na.rm = T), is.nan(mean(rtt, na.rm = T)), NA),
    sd = replace(sd(rtt, na.rm = T), is.nan(sd(rtt, na.rm = T)), NA)    )
    
    res[order(as.character(res$name)), ]
}

filterHops <- function (hops){
    result_ttls <- vector()
    result_ttls[1] <- nrow(hops) #No puede faltar el ultimo salto = destino
    paths_indexes <- order(as.numeric(hops$mean)) #paths_indexes[i] == ttl_j == hops[j]
    
    hop_ptr = which.max(paths_indexes)-1
    while (hop_ptr >= 1)
    {
        if (paths_indexes[hop_ptr] > result_ttls[length(result_ttls)]){
            if(hops$sd[paths_indexes[hop_ptr]] < hops$sd[result_ttls[length(result_ttls)]]){
                result_ttls[length(result_ttls)] <- paths_indexes[hop_ptr]
            }
            
        } else {
            result_ttls[length(result_ttls)+1] <- paths_indexes[hop_ptr]
        }
        hop_ptr <- hop_ptr-1 #paths_indexes esta ordenado de menor a mayor segun mean
    }
    
    res <- hops[result_ttls,]
    
    #Agregamos NA
    for (i in 1:nrow(hops)){
        if(! (i %in% result_ttls)){
            res <- rbind(res,hops[i,])
            res$name[nrow(res)] <- sprintf("%02d - Filtrado", i)
            res$ip[nrow(res)] <- NA
            res$longitude[nrow(res)] <- NA
            res$latitude[nrow(res)] <- NA
            res$country[nrow(res)] <- NA
            res$city[nrow(res)] <- NA
            res$mean[nrow(res)] <- NA
            res$sd[nrow(res)] <- NA
        }
    }

    #hops[result_ttls,]
    res[order(res$name),]
}

getRttiDividiendo <- function (summarized) {
    rttis <- data.frame(ttl = numeric(0), ip = character(0), rtti = numeric(0))
    
    lastRTT <- 0
    lastHost <- "Host"
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
                rttis <- rbind(rttis, data.frame(ttl = newI, name = sprintf("%02d: %s - %s", newI, lastHost, summarized$ip[newI]), rtti = diff))
                lastHost <- summarized$ip[newI]
            }
        } else {
            rttis <- rbind(rttis, data.frame(ttl = i, name = sprintf("%02d: %s - %s", i, lastHost, summarized$ip[i]), rtti = diff))
        }
        
        lastHost <- summarized$ip[i]
        lastRTT <- currRTT
        wasNA <- FALSE
        countNA <- 0    
    }
    
    meanRtti <- mean(rttis$rtti)
    sdRtti <- sd(rttis$rtti)
    
    rttis$zscore <- sapply(rttis$rtti, function (x) { (x - meanRtti) / sdRtti } )
    rttis$name <- as.character(rttis$name)
    
    rttis
}

getRttiSalteandoNA <- function (summarized) {
    rttis <- data.frame(ttl = numeric(0), ip = character(0), rtti = numeric(0))
    
    lastRTT <- 0
    lastHost <- "Host"
        
    for (i in 1:nrow(summarized)) {
        currRTT <- summarized$mean[i]
        diff <- NA
                
        if (!is.na(currRTT)) {
            diff <- currRTT - lastRTT
            lastRTT <- currRTT
        }
        
        rttis <- rbind(rttis, data.frame(ttl = i, name = sprintf("%02d: %s - %s", i, lastHost, summarized$ip[i]), rtti = diff))
        
        lastHost <- summarized$ip[i]
    }
    
    meanRtti <- mean(rttis$rtti, na.rm=T)
    sdRtti <- sd(rttis$rtti, na.rm=T)
    
    rttis$zscore <- sapply(rttis$rtti, function (x) { (x - meanRtti) / sdRtti } )
    rttis$name <- as.character(rttis$name)
    
    rttis
}

plotAcumulated <- function (summarized, melted, filename) {    
    ggplot(data = summarized, aes(name, mean, group = 1)) + 
    geom_point(aes(x = name, y = rtt), data = melted[melted$ip %in% summarized$ip, ], colour = "red") +
    geom_point(shape = 21, size = 6, fill = "white") +
    geom_errorbar(width = 0.5, aes(ymin = mean - sd, ymax = mean + sd)) +    
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    labs(title = 'RTT a cada Host Intermedio', x = "TTL - IP", y = "RTT [ms]")
    
    ggsave(filename, width = 8, height = 8)
}

plotZscore <- function (rttis, filename) {
    ggplot(data=rttis, aes(name, zscore), na.rm = TRUE) +    
    geom_bar(stat="identity", position = "identity") + 
    scale_x_discrete(labels=rttis$name) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1), 
    plot.margin = unit(c(1, 1, 1, 1), "cm")) +
    labs(title = 'Z Score de cada Hop', x = "Hop", y = "Z Score")
    
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
    summary_filtered <- filterHops(summary)
    rttis_dividiendo <- getRttiDividiendo(summary)
    rttis_dividiendo_filtered <- getRttiDividiendo(summary_filtered)
    rttis_salteando <- getRttiSalteandoNA(summary)
    rttis_salteando_filtered <- getRttiSalteandoNA(summary_filtered)
    
    plotAcumulated(summary, melted, paste(filename, ".rtt_acum.pdf", sep=""))
    plotAcumulated(summary_filtered, melted, paste(filename, ".rtt_acum_filtered.pdf", sep=""))
    
    plotZscore(rttis_dividiendo, paste(filename, ".rtti_dividiendo_zscore.pdf", sep=""))    
    plotZscore(rttis_salteando, paste(filename, ".rtti_salteando_zscore.pdf", sep=""))
    plotZscore(rttis_dividiendo_filtered, paste(filename, ".rtti_dividiendo_zscore_filtered.pdf", sep=""))
    plotZscore(rttis_salteando_filtered, paste(filename, ".rtti_salteando_zscore_filtered.pdf", sep=""))
    
    plotMap(summary, paste(filename, ".map.pdf", sep=""))
    plotMap(summary_filtered, paste(filename, ".map_filtered.pdf", sep=""))
    
    print("RTT a cada Host")
    print(summary)
    
    print("RTTi (Dividiendo) con Z Score")
    print(rttis_dividiendo)
    
    print("RTTi (Salteando) con Z Score")
    print(rttis_salteando)
            
    print("RTT a cada Host Filtrado")
    print(summary_filtered)
    
    print("RTTi (Dividiendo) con Z Score Filtrado")
    print(rttis_dividiendo_filtered)
    
    print("RTTi (Salteando) con Z Score Filtrado")
    print(rttis_salteando_filtered)
}