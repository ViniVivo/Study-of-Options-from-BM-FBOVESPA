## Set your directory
setwd("Documents/Operacoes_Vol/TXT/NEG/")

if(!require(RCurl)){
        install.packages("Rcurl")
        library(RCurl)
}

url <- "ftp://ftp.bmf.com.br/MarketData/Bovespa-Opcoes/" 

##All files in FTP "/n"
filenames <- getURL(url = url, dirlistonly = TRUE)

##Split files names
fn <- unlist(strsplit(filenames, "\n")) 
fn

##Download Files according to "fn" line "(options(max.print=1000000))"
output = NULL
for (i in 543:544) {
        fn_required <- fn[i]
        ## Name of the file
        urlfile <- paste0(url, fn_required)
        lapply(fn_required, function(x) download.file(url = urlfile, destfile = fn_required, method = "curl"))
        ## unzip the file and store
        fn_txt <- substr(fn_required,1,19)
        unzip(fn_required, paste0(fn_txt,".TXT"))
        ## Delete file ".zip"
        unlink(fn_required)
}


## Extract Options with Market Maker ## Joint above changing "namefile" for paste0(fn_txt,".TXT")

if(!require(data.table)){
        install.packages("data.table")
        library(data.table)
}

## In the "Terminal"      1. cd /Users/Vini_Vivo/Documents/Operacoes_Vol/TXT/NEG
##                        2. cat * > NEG_OPCOES.TXT
##-----------------------------------------------------------------------------------------
NEG <- as.data.frame(read.table("NEG_OPCOES.TXT", nrows = read.table(unique_file, skip = 1, 
                                stringsAsFactors = FALSE, sep = ";", fill = TRUE)-1
                                ,skip = 1, stringsAsFactors = FALSE, sep = ";", fill = TRUE))

## Including namo of comlumns according ftp://ftp.bmf.com.br/MarketData/NEG_LAYOUT_english.txt
colnamesNEG <- c("Session Date", "Instrument Symbol", "Trade Number", "Trade Price", "Traded Quantity", 
                 "Trade Time", "Trade Indicator", "Buy Order Date", "Sequential Buy Order Number", 
                 "Secondary Order ID - Buy Order", "Aggressor Buy Order Indicator", "Sell Order Date", 
                 "Sequential Sell Order Number", "Secondary Order ID - Sell Order", 
                 "Aggressor Sell Order Indicator", "Cross Trade Indicator", "Buy Member", "Sell Member")

##Including Column names on the file
names(NEG) <- colnamesNEG

##Extract for the database only Market Maker "instrument symbols"
ABEV <- NEG[grep("ABEV", NEG$`Instrument Symbol`), ]
IBOV <- NEG[grep("IBOV", NEG$`Instrument Symbol`), ]
NEG<- rbind(ABEV, IBOV)

## Remove spaces for "instrument symbols"
if(!require(stringr)){
        install.packages("stringr")
        library(stringr)
}

FNEG$`Instrument Symbol` <- str_trim(FNEG$`Instrument Symbol`)

## Mutating date and time
if(!require(lubridate)){
        install.packages("lubridate")
        library(lubridate)
}
NEG$`Session Date` <- ymd(NEG$`Session Date`)
NEG$`Buy Order Date` <- ymd(NEG$`Buy Order Date`)
NEG$`Sell Order Date` <- ymd(NEG$`Sell Order Date`)

if(!require(chron)){
        install.packages("chron")
        library(chron)
}
NEG$`Trade Time`<- chron(times. = NEG$`Trade Time`, format = c(times = "h:m:s"))

## ADD new column "object symbol"
NEG["Object Symbol"] <- substr(NEG$`Instrument Symbol`,1,4)


if(!require(dplyr)){
        install.packages("dplyr")
        library(dplyr)
}
