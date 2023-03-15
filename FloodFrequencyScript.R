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

p1 <- ggplot(data = df, aes(x = peak_dt, y = peak_va)) + geom_point() +
  labs(title=paste('Peak Flow for',site_id, station_nm), x='Time', 
       y='Peak Flow [cfs]')
ggsave('geos212-ffa-fig1.png',p1, width=10, height=8, units='in')


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

p_e_gumbel <- seq(from = 0.001, to = 0.999, by = 0.001)
t_gumbel <- 1 / (1 - p_e_gumbel)

q_gumbel = u - alpha*log(-log(p_e_gumbel))

p2 <- ggplot() + 
  geom_point(data = NULL, aes(t_gringorten,q_sort), color='red') + 
  geom_point(data = NULL, aes(t_weibull,q_sort), color='blue') + 
  geom_line(data = NULL, aes(t_gumbel,q_gumbel), color='chartreuse4') +
  scale_x_continuous(trans = 'log10') + 
  scale_y_continuous(labels = comma) +
  labs(title = paste('Flood Frequency for Site',site_id, station_nm), 
  x = 'Return Interval [Years]', y = 'Peak Flow [cfs]')

p2
ggsave('geos212-ffa-fig2.png',p2, width=10, height=8, units='in')

q100_weibull = approx(t_weibull,q_sort, 100.0, method='linear')
q100_gringorton = approx(t_gringorten,q_sort, 100.0, method='linear')
q100_gumbel = approx(t_gumbel,q_gumbel, 100.0, method='linear')

q100_weibull
q100_gringorton
q100_gumbel

qdates <- df$peak_dt
daynum <- df$peak_dt - as.Date(format(df$peak_dt, format='%Y-01-01'))

df_new <- data.frame(qdates,daynum)

p3 <- ggplot(df_new, aes(x = qdates, y = daynum)) + 
  geom_point() +
  scale_y_continuous(labels = comma) +
  labs(title = paste(site_id, station_nm), 
       x = 'Date', y = 'What is This?') +
  stat_smooth(method='lm', formula = y ~ x)

p3
ggsave('geos212-ffa-fig3.png',p3, width=10, height=8, units='in')
