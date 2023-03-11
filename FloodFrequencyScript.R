setwd('~/WinW-R-workshop/')

library('dataRetrieval')
library('ggplot2')
library('scales')

site_id <- '13317000' # Salmon River At White Bird ID

start_date <- '1915-10-01'
end_date <- '2022-09-30'

# Retrieve the data
df <- readNWISpeak(site_id, startDate = start_date, endDate = end_date)

station_nm <- attr(df, 'siteInfo')$station_nm

ggplot(data = df, aes(x = peak_dt, y = peak_va)) + geom_point()

q_sort <- sort(df$peak_va, decreasing = TRUE)
rank <- 1:length(q_sort)

# Compute return intervals of flows using Weibull plotting position
p_e_weibull <- rank / (length(q_sort) + 1)
t_weibull <- 1 / p_e_weibull

# Compute return intervals of flows using Gringorten plotting position
p_e_gringorten <- (rank - 0.44) / (length(q_sort) + 1 - 2*0.44)
t_gringorten <- 1 / p_e_gringorten

# Compute return intervals of flows using Gumbel
xbar <- mean(q_sort)
s_x <- sd(q_sort)
alpha <- sqrt(6)*s_x / pi
u <- xbar - 0.5772*alpha

p_e_gumbel <- 1 - exp(-exp(-(q_sort - u)/alpha))
t_gumbel <- 1 / p_e_gumbel 

p2 <- ggplot() + 
  geom_point(data = NULL, aes(t_gringorten,q_sort), color='red') + 
  geom_point(data = NULL, aes(t_weibull,q_sort), color='blue') + 
  geom_line(data = NULL, aes(t_gumbel,q_sort), color='chartreuse4') +
  scale_x_continuous(trans = 'log10') + 
  scale_y_continuous(labels = comma) +
  labs(title = paste('Flood Frequency for Site',site_id, station_nm), 
  x = 'Return Interval [Years]', y = 'Peak Flow [cfs]')

