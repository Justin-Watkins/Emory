source("code/setup.R")
#-------------------------------------------------------------------------------
# Build data set
#-------------------------------------------------------------------------------
# Build a simple data set
set.seed(755)
price <- as.data.frame(round(rbeta(4000,5,3)*100,0))
sales <- as.data.frame(table(price))

names(sales) <- c("price","sales")
sales$price <- as.numeric(as.character(sales$price))
str(sales)

vroom::vroom_write(sales,'data/simulated_ticket_sales.csv',delim = ",")
#-------------------------------------------------------------------------------
# The Price response function
#-------------------------------------------------------------------------------
x_label  <- ('\n Price')
y_label  <- ('Ticket Sales \n')
title    <- ('Ticket Sales by Price')

  ggplot2::ggplot(data  = sales, 
                  aes(x = price,
                      y = sales))                 +
  geom_point(size = 1,color = 'steelblue4')       +
  scale_x_continuous(label = scales::dollar)      +
  xlab(x_label)                                   + 
  ylab(y_label)                                   + 
  ggtitle(title)                                  +
  graphics_theme_1                                +
  geom_line(color = "steelblue4")                 +
  geom_smooth(method = 'lm',se =F, 
              color = "coral") 
  
ggsave(
  'images/prf_linear.png',
  plot = last_plot(),
  device = NULL,
  scale = 1,
  width = 8,
  height = 6,
  dpi = 300
)
#-------------------------------------------------------------------------------
# The Price response function
#-------------------------------------------------------------------------------
x_label  <- ('\n Price')
y_label  <- ('Ticket Sales \n')
title    <- ('Ticket Sales by Price')

ggplot2::ggplot(data = sales, 
                aes(x = price,
                y = sales))                       +
  geom_point(size = 1,color = 'steelblue4')       +
  scale_x_continuous(label = scales::dollar)      +
  xlab(x_label)                                   + 
  ylab(y_label)                                   + 
  ggtitle(title)                                  +
  graphics_theme_1                                +
  geom_line(color = 'steelblue4')                 +          
  stat_smooth(method = "lm",color = 'coral', 
              formula = y ~ x + poly(x, 2)-1,
              se = F)                             +
  coord_cartesian(ylim = c(0,120))

ggsave(
  'images/prf_poly.png',
  plot = last_plot(),
  device = NULL,
  scale = 1,
  width = 8,
  height = 6,
  dpi = 300
)
#-------------------------------------------------------------------------------
# Build Fit
#-------------------------------------------------------------------------------
fit <- lm(sales$sales~poly(sales$price,2,raw=TRUE))
#-------------------------------------------------------------------------------
# Function to return sales based on price
#-------------------------------------------------------------------------------
f_get_poly_fit <- function(new_var,dist_fit){
      
    len_poly   <- length(dist_fit$coefficients)
    exponents  <- seq(1:(len_poly-1))
    value_list <- list()
      
    for(i in 1:length(exponents)){
        value_list[i] <- coef(dist_fit)[i+1] * new_var^exponents[i]
    }
    sum(do.call(sum, value_list),coef(dist_fit)[1])
  }
#-------------------------------------------------------------------------------
# Function to return sales based on price
#-------------------------------------------------------------------------------     
old_prices      <- sales$price
estimated_sales <- sapply(old_prices, function(x) f_get_poly_fit(x,fit))     
#------------------------------------------------------------------------------- 
# Use f_get_sales to get modeled demand at each price level
#------------------------------------------------------------------------------- 
# f_get_poly_fit(55)      
#------------------------------------------------------------------------------- 
# Calculations
#------------------------------------------------------------------------------- 
# sales <- coef(fit)[1] + (coef(fit)[2]*new_price + 
#          (coef(fit)[3] * new_price^2))
      
# Function from fit
# sales = -88.16618 + 5.35142x + -0.04375x^2

# Use Math engine to calculate derivative:
#https://www.wolframalpha.com/input?i=-88.16618+%2B+5.35142x+%2B+-0.04375x%5E2

# Derivative
# 5.35142 = - 0.0875*x

# Solve for 0
# abs(5.35142/-0.0875) = 61.15909
#------------------------------------------------------------------------------- 
# Demonstrate the highest point on the curve
#------------------------------------------------------------------------------- 
x_label  <- ('\n Price')
y_label  <- ('Ticket Sales \n')
title   <- ('Ticket Sales by Price')
  ggplot2::ggplot(data  = sales, 
                  aes(x = price,
                      y = sales))                     +
  geom_point(size = 1,color = 'steelblue4')           +
  scale_x_continuous(label = scales::dollar)          +
  xlab(x_label)                                       + 
  ylab(y_label)                                       + 
  ggtitle(title)                                      +
  graphics_theme_1                                    +
  geom_line(color = "steelblue4")                     +                                         
  stat_smooth(method = "lm", color = 'coral',
              formula = y ~ x + poly(x, 2)-1, se = F) +
  geom_hline(yintercept = f_get_poly_fit(61.15909,fit), 
             lty = 2, size = .9)                      +
  geom_vline(xintercept = 61.15909, 
             lty = 2, size = .9)                      +
  coord_cartesian(ylim = c(0,120))

ggsave(
  'images/prf_max.png',
  plot = last_plot(),
  device = NULL,
  scale = 1,
  width = 8,
  height = 6,
  dpi = 300
  )
#------------------------------------------------------------------------------- 
# Look for optimum price levels
#------------------------------------------------------------------------------- 
estimated_prices <- seq(from = 25, to = 80, by = 1)
estimated_sales <- sapply(estimated_prices,
                            function(x) f_get_poly_fit(x,fit))
  
estimated_revenue <- tibble::tibble(
  sales      = estimated_sales,
  price      = estimated_prices,
  revenue    = estimated_sales * estimated_prices,
  totalSales = rev(cumsum(rev(sales)))
  ) 
#------------------------------------------------------------------------------- 
# Look for optimum price levels to Maximize revenue
#------------------------------------------------------------------------------- 
x <- 1
revenue <- list()
while(x <= nrow(estimated_revenue)){
    
  revenue[x] <- estimated_revenue[x,2] * estimated_revenue[x,4]
  x <- x + 1
}
estimated_revenue$totalRevenue <- unlist(revenue)  
#------------------------------------------------------------------------------- 
# Look for optimum price levels to Maximize revenue
#-------------------------------------------------------------------------------   
# Calculate optimum price
op_price <- estimated_revenue[which(estimated_revenue$totalRevenue == 
                              max(estimated_revenue$totalRevenue)),]$price
  
  x_label  <- ('Price')
  y_label  <- ('Total Revenue at Price Level')
  title   <- ('Estimated Demand Curve at Each Price Level')
  ggplot2::ggplot(data  = estimated_revenue, 
                  aes(x = price,
                      y = totalRevenue))                +
    geom_point(size = 1,color = 'steelblue4')           +
    scale_x_continuous(label = scales::dollar)          +
    scale_y_continuous(label = scales::dollar)          +
    xlab(x_label)                                       + 
    ylab(y_label)                                       + 
    ggtitle(title)                                      +
    graphics_theme_1                                    +
    geom_line(color = "steelblue4")                     +
    geom_vline(xintercept = op_price,lty = 2, size = .9)

ggsave(
  'images/prf_rev_max.png',
  plot = last_plot(),
  device = NULL,
  scale = 1,
  width = 8,
  height = 6,
  dpi = 300
)
#------------------------------------------------------------------------------- 
# END
#-------------------------------------------------------------------------------    
  

  
