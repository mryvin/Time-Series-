library(readxl)
library(dplyr)
library(tidyr)
library(fpp2)

# Set working directory and seed
setwd()
set.seed(538)

# Load and clean data
my_data <- read_excel("CPIPrice.xlsx")[-c(1, 360),]
my_data <- data.frame(lapply(my_data, as.numeric))

# Function to perform analysis on a given dataset for a specified start year
perform_analysis <- function(data, start_year) {
  # Loop over the columns of the data (excluding the first column)
  for(w in 2:15) {
    # If the current column is the 9th, skip it because there's not enough data
    if(w == 9) next  
    
    # Get the end year of the time series data for the current column
    start <- tsp(ts(data[[w]], frequency = 12))[2] - 1
    
    # Generate bootstrap simulations for the time series data of the current column
    sim <- bld.mbb.bootstrap(ts(data[[w]], frequency = 12), 10) %>%
      as.data.frame() %>%
      ts(frequency = 12, start = start_year)
    
    # Forecast the mean of the bootstrap simulations
    fc <- purrr::map(as.list(sim), function(x) {forecast(ets(x))[["mean"]]}) %>%
      as.data.frame() %>%
      ts(frequency = 12, start = start + start_year)
    
    # Plot the original time series data, the bootstrap simulations, and the forecast
    print(autoplot(ts(data[[w]], frequency = 12, start = start_year)) +
            autolayer(sim, colour = TRUE) +
            autolayer(fc, colour = TRUE) +
            autolayer(ts(data[[w]], frequency = 12, start = start_year), colour = FALSE) +
            ylab("Consumer Price Index") +
            guides(colour = "none") + ggtitle(names(data[w])) )
    
    # Print the average predicted value for the current column
    cat("The average predicted value for", names(data[w]), "(", start_year, "-", start_year + 1, ") is:", mean(fc), "\n")
    
    # Print the standard deviation of the predicted value for the current column
    cat("The standard deviation of the predicted value for", names(data[w]), "(", start_year, "-", start_year + 1, ") is:", sd(fc), "\n")
  }
}


# Perform analysis for different time periods
perform_analysis(my_data, 1989.5)  # 1989-2019
perform_analysis(my_data[275:359,], 2012.333)  # 2012-2019
perform_analysis(my_data[335:359,], 2017.333)  # 2017-2019

##############################################################################
# CODE NOT USED FOR PRESENTATION
##############################################################################

# Bootstrap Auto-correlation Estimation
# ----------------------------------------------------------------------

# Define constants
k <- 4       # size of moving blocks
nrep <- 1000 # number of bootstrap replications

# Loop over columns in the data frame
for(w in 2:15) {
  
  # Skip column 9 due to insufficient data
  if(w == 9) next
  
  # Select column and convert to data frame
  my_data2 <- data.frame(my_data[, w])
  
  # Length of the time series
  N <- nrow(my_data2)
  
  # Create artificial data with auto-correlation
  series <- rnorm(N)
  series[-1] <- series[-1] + series[-N]
  
  # Initialize vector for bootstrap values of the auto-correlation estimate
  lag.cor.bt <- rep(NA, nrep)
  
  # Bootstrap loop
  for(irep in 1:nrep) {
    # Initialize local vector for a bootstrap replication
    series.bt <- rep(NA, N)
    
    # Fill the vector with random blocks
    for(i in 1:ceiling(N/k)) {
      # Randomly sample endpoints
      endpoint <- sample(k:N, size=1)
      
      # Copy blocks
      series.bt[(i-1)*k+1:k] <- lapply(my_data2[endpoint-(k:1)+1,], as.numeric)
      series.bt <- unlist(series.bt, recursive=FALSE)
    }
    
    # Trim overflow when k doesn't divide N
    series.bt <- series.bt[1:N]
    
    # Compute the auto-correlation estimate
    lag.cor.bt[irep] <- cor(series.bt[-1], series.bt[-N])
  }
  
  # Visualize bootstrap distribution
  hist(lag.cor.bt, col="gray", ncl=20, main = names(my_data[w]))
  
  # Compute significance level
  print(sum(lag.cor.bt<0, na.rm=TRUE) / 1000)
  
  # Compute 95% confidence interval
  print(quantile(lag.cor.bt, c(0.025, 0.975), na.rm=TRUE))
}


# Bootstrap Series Visualization
# ----------------------------------------------------------------------

# Bootstrap the series
bootseries <- bld.mbb.bootstrap(my_data$Developing.Asia, 100) %>%
  as.data.frame() %>%
  ts(start=0, frequency=1)

# Plot the original and bootstrapped series
autoplot(ts(my_data$Developing.Asia)) +
  autolayer(bootseries, colour=TRUE) +
  autolayer(ts(my_data$Developing.Asia), colour=FALSE) +
  ylab("Bootstrapped series") +
  guides(colour="none")


# Bootstrap Simulation and Forecasting
# ----------------------------------------------------------------------

# Define constants
nsim <- 1000L
h <- 36L

# Bootstrap the series
sim <- bld.mbb.bootstrap(ts(my_data$Developing.Asia), nsim)

# Initialize matrix for future values
future <- matrix(0, nrow=nsim, ncol=h)

# Simulate future values
for(i in seq(nsim)) {
  future[i,] <- simulate(ets(sim[[i]]), nsim=h)
}

# Get start time of the series
start <- tsp(ts(my_data$Developing.Asia))[2]

# Create forecast structure
simfc <- structure(list(
  mean = ts(colMeans(future), start=start, frequency=1),
  lower = ts(apply(future, 2, quantile, prob=0.05), start=start, frequency=1),
  upper = ts(apply(future, 2, quantile, prob=0.95), start=start, frequency=1),
  level=90),
  class="forecast")

# Forecast using ETS model
etsfc <- forecast(ets(ts(my_data$Developing.Asia)), h=h, level=90)

# Plot the original, simulated, and ETS forecasted series
autoplot(ts(my_data$Developing.Asia)) +
  ggtitle("Developing.Asia") +
  xlab("Month") + ylab("Consumer Price Index") +
  autolayer(simfc, series="Simulated") +
  autolayer(etsfc, series="ETS")


# ETS and BaggedETS Forecasting and Visualization
# ----------------------------------------------------------------------

# Forecast using ETS model
etsfc <- ts(my_data$Developing.Asia) %>% 
  ets() %>% 
  forecast(h=36)

# Forecast using BaggedETS model
baggedfc <- ts(my_data$Developing.Asia) %>% 
  baggedETS() %>% 
  forecast(h=36)

# Plot the original, ETS forecasted, and BaggedETS forecasted series
autoplot(ts(my_data$Developing.Asia)) +
  autolayer(baggedfc, series="BaggedETS", PI=FALSE) +
  autolayer(etsfc, series="ETS", PI=FALSE) +
  guides(colour=guide_legend(title="Forecasts"))
