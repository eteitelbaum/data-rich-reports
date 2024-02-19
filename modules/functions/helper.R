# build recession shading function 
library(ecm)

add_rec_shade<-function(st_date,ed_date,shade_color, y_min, y_max) # are st_date and ed_date being used in this function?
{
  
  recession<-fredr(series_id = "USRECD",observation_start = as.Date(st_date),observation_end = as.Date(ed_date))
  
  recession$diff<-recession$value-lagpad(recession$value,k=1) #code 1 for 1st day of recession, -1 for first day after recession ends
  recession<-recession[!is.na(recession$diff),] #drop 1st N.A. value
  recession.start<-recession[recession$diff==1,]$date #create vector of recession start dates
  recession.end<-recession[recession$diff==(-1),]$date #create vector of recession end dates
  
  if(length(recession.start)>length(recession.end)) # if there are more dates listed in recession.start than recession.end
  {recession.end<-c(recession.end,Sys.Date())} # enter system date for last date in recession.end
  if(length(recession.end)>length(recession.start)) # if there are more dates listed in recession.end than recession.start         
  {recession.start<-c(min(recession$date),recession.start)} # enter the earliest date in recession$date as first date in recession.start
  
  recs<-as.data.frame(cbind(recession.start,recession.end)) # make a dataframe out of recession.start and recession.end
  recs$recession.start<-as.Date(as.numeric(recs$recession.start),origin=as.Date("1970-01-01")) # convert recession.start into a date
  recs$recession.end<-as.Date(recs$recession.end,origin=as.Date("1970-01-01")) # convert recession.end into a 
  if(nrow(recs)>0) # if the number of rows in recs > 0
  {
    rec_shade<-geom_rect(data=recs, inherit.aes=F, #inherit.aes=F overrides default aesthetics
                         aes(xmin=recession.start, xmax=recession.end, ymin=y_min, ymax=y_max), 
                         fill=shade_color, alpha=0.5)
    return(rec_shade)
  }
}
