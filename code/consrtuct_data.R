source("code/setup.R")
#-------------------------------------------------------------------------------
# Generate past season's data
#-------------------------------------------------------------------------------
season_2022 <- 
  FOSBAAS::f_build_season(seed1 = 3000, season_year = 2022,
                          seed2 = 714, num_games = 81, seed3 = 366, num_bbh = 5,
                          num_con = 3, num_oth = 5, seed4 = 309, seed5  = 25,
                          mean_sales = 29000, sd_sales = 3500)
season_2023 <- 
  FOSBAAS::f_build_season(seed1 = 755, season_year = 2023,
                          seed2 = 4256, num_games = 81, seed3 = 54, num_bbh = 6,
                          num_con = 4, num_oth = 7, seed4 = 309, seed5  = 25,
                          mean_sales = 30500, sd_sales = 3000)
season_2024 <- 
  FOSBAAS::f_build_season(seed1 = 2892, season_year = 2024,
                          seed2 = 714, num_games = 81, seed3 = 366, num_bbh = 9,
                          num_con = 2, num_oth = 6, seed4 = 6856, seed5  = 2892,
                          mean_sales = 32300, sd_sales = 2900)
season_2025 <- 
  FOSBAAS::f_build_season(seed1 = 147, season_year = 2025,
                          seed2 = 900, num_games = 81, seed3 = 204, num_bbh = 10,
                          num_con = 23, num_oth = 5, seed4 = 1238, seed5  = 8524,
                          mean_sales = 33800, sd_sales = 2700)
#-------------------------------------------------------------------------------
# Write data sets
#-------------------------------------------------------------------------------
model_data   <- dplyr::bind_rows(season_2022,season_2023,season_2024)
# Clean and standardize names
model_data  <-  model_data  %>% janitor::clean_names()  
season_2025 <-  season_2025 %>% janitor::clean_names()  
# write output
vroom::vroom_write(model_data,'data/top_down_season_data.csv',delim = ",")
vroom::vroom_write(season_2025,'data/top_down_future_data.csv',delim = ",")
#-------------------------------------------------------------------------------
# END
#-------------------------------------------------------------------------------
