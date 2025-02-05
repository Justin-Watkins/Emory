source("code/setup.R")
#-------------------------------------------------------------------------------
# Load data sets
#-------------------------------------------------------------------------------
past_seasons <- vroom::vroom('data/top_down_season_data.csv')
data_2025    <- vroom::vroom('data/top_down_future_data.csv')
#-------------------------------------------------------------------------------
# Prep data
#-------------------------------------------------------------------------------
past_seasons <- as.data.frame(past_seasons)  %>%
  janitor::clean_names()                     %>%
  na.omit()                                  %>% 
  select(-date)

data_2025 <- as.data.frame(data_2025)    %>%
  janitor::clean_names()                 %>%
  na.omit()                              %>% 
  select(-date)
#-------------------------------------------------------------------------------
# Explore the data
#-------------------------------------------------------------------------------
x_label  <- ('Ticket Sales')
y_label  <- ('Density')
title    <- ('Ticket Sales Distribution')
legend   <- ('')

past_seasons                                        %>%
  ggplot2::ggplot(
    aes(x = ticket_sales,
        color = factor(season)))                      +
  # facet_grid(.~ season)                             +
  geom_density(size = 1.2)                            +
  geom_rug(color = 'steelblue4')                      +
  scale_y_continuous(label = scales::comma)           +
  scale_x_continuous(label = scales::comma)           +
  scale_color_manual(legend, values = palette)        +  
  xlab(x_label)                                       + 
  ylab(y_label)                                       + 
  ggtitle(title)                                      +
  graphics_theme_1

ggsave(
  'images/ticket_sales_distributions.png',
  plot = last_plot(),
  device = NULL,
  scale = 1,
  width = 8,
  height = 6,
  dpi = 300
)
#-------------------------------------------------------------------------------
# Predict Sales with boosted model
#-------------------------------------------------------------------------------
# prep for parallel processing
all_cores <- parallel::detectCores(logical = FALSE)
registerDoParallel(cores = all_cores)
# set the random seed so we can reproduce any simulated results.
set.seed(755)
# split into training and testing datasets. Stratify by Rating
model_split <- rsample::initial_split(
  past_seasons, 
  prop = 0.8, 
  strata = ticket_sales
)
#-------------------------------------------------------------------------------
# preprocessing "recipe"
preprocessing_recipe <- 
  recipes::recipe(ticket_sales ~ ., data = training(model_split )) %>%
  # convert categorical variables to factors
  recipes::step_string2factor(all_nominal()) %>%
  # combine low frequency factor levels
  # recipes::step_other(all_nominal(), threshold = 0.01) %>%
  # remove no variance predictors which provide no predictive information 
  recipes::step_nzv(all_nominal()) %>%
  prep()
#-------------------------------------------------------------------------------
model_cv_folds <- 
  recipes::bake(
    preprocessing_recipe, 
    new_data = training(model_split)
  ) %>%  
  rsample::vfold_cv(v = 10)
#-------------------------------------------------------------------------------
# XGBoost model specification
xgboost_model <- 
  parsnip::boost_tree(
    mode = "regression",
    trees = 500,
    min_n = tune(),
    tree_depth = tune(),
    learn_rate = tune(),
    loss_reduction = tune()
  ) %>%
  set_engine("xgboost", objective = "reg:squarederror")
#-------------------------------------------------------------------------------
xgboost_params <- 
  dials::parameters(
    min_n(),
    tree_depth(),
    learn_rate(),
    loss_reduction()
  )
#-------------------------------------------------------------------------------
xgboost_grid <- 
  dials::grid_max_entropy(
    xgboost_params, 
    size = 60
  )
knitr::kable(head(xgboost_grid))
#-------------------------------------------------------------------------------
xgboost_wf <- 
  workflows::workflow() %>%
  add_model(xgboost_model) %>% 
  add_formula(ticket_sales ~ .)
#-------------------------------------------------------------------------------
# hyperparameter tuning
xgboost_tuned <- tune::tune_grid(
  object = xgboost_wf,
  resamples = model_cv_folds,
  grid = xgboost_grid,
  metrics = yardstick::metric_set(rmse, rsq, mae),
  control = tune::control_grid(verbose = TRUE)
)
#-------------------------------------------------------------------------------
xgboost_tuned %>%
  tune::show_best(metric = "rmse") %>%
  
knitr::kable()
#-------------------------------------------------------------------------------
xgboost_best_params <- xgboost_tuned %>%
  tune::select_best("rmse")

knitr::kable(xgboost_best_params)
#-------------------------------------------------------------------------------
xgboost_model_final <- xgboost_model %>% 
  finalize_model(xgboost_best_params)
#-------------------------------------------------------------------------------
train_processed  <- bake(preprocessing_recipe,  new_data = training(model_split))

train_prediction <- xgboost_model_final %>%
  # fit the model on all the training data
  fit(
    formula = ticket_sales ~ ., 
    data    = train_processed
  ) %>%
  # predict the sale prices for the training data
  predict(new_data = train_processed) %>%
  bind_cols(training(model_split))

xgboost_score_train <- 
  train_prediction %>%
  yardstick::metrics(ticket_sales, .pred) %>%
  mutate(.estimate = format(round(.estimate, 2), big.mark = ","))

knitr::kable(xgboost_score_train)
#-------------------------------------------------------------------------------
test_processed  <- bake(preprocessing_recipe, new_data = testing(model_split))
test_prediction <- xgboost_model_final %>%
  # fit the model on all the training data
  fit(
    formula = ticket_sales ~ .,
    data    = train_processed
  ) %>%
  # use the training model fit to predict the test data
  predict(new_data = test_processed) %>%
  bind_cols(testing(model_split))

# measure the accuracy of our model using `yardstick`
xgboost_score <-
  test_prediction %>%
  yardstick::metrics(ticket_sales, .pred) %>%
  mutate(.estimate = format(round(.estimate, 2), big.mark = ","))

knitr::kable(xgboost_score)
#-------------------------------------------------------------------------------
# Visualize the residuals
#-------------------------------------------------------------------------------
final_prediction_residual <- test_prediction %>%
  arrange(.pred) %>%
  mutate(residual_pct = (ticket_sales - .pred) / .pred) 

#final_prediction_residual <- 
#  final_prediction_residual  %>% 
#  filter(residual_pct > -.75,
#         residual_pct < .75 )

ggplot(final_prediction_residual, aes(x = .pred, y = residual_pct)) +
  geom_point(alpha = .9,color= 'steelblue4')                        +
  xlab("Ticket Sales Prediction")                                   +
  ylab("Residual (%)")                                              +
  scale_x_continuous(labels = scales::comma)                        +
  scale_y_continuous(labels = scales::percent)                      +
  graphics_theme_1                                                  +
  labs(x="Tickets Prediction",
       y="Residual (%)",
       title = "Tickets Prediction and Residual Error",
       subtitle = "",
       caption  = "[note]")                                         +
  theme(plot.caption = element_text(hjust = 0, 
                                    face= "italic",
                                    color = "grey10"),
        plot.title.position = "plot", 
        plot.caption.position =  "plot",
        plot.subtitle = element_text(color = "grey10"))  

ggsave(
  'images/xgboost_error_actual.png',
  plot = last_plot(),
  device = NULL,
  scale = 1,
  width = 8,
  height = 6,
  dpi = 300
)
#-------------------------------------------------------------------------------
# Separate data sets for other models. 
#-------------------------------------------------------------------------------
train <- as.data.frame(training(model_split))
test  <- as.data.frame(testing(model_split))
#-------------------------------------------------------------------------------
# Attach boosted estimates to test data set
#-------------------------------------------------------------------------------
# Apply gradient boosting predictions
xgb_preds <- xgboost_model_final %>%
  fit(
    formula = ticket_sales ~ .,
    data    = train_processed
  )                              %>%
  predict(new_data = test)

test$.pred_xgb <- xgb_preds$.pred
#-------------------------------------------------------------------------------
# Linear Regression
#-------------------------------------------------------------------------------
lm_fit <- lm(ticket_sales ~ ., data = train)

summary(lm_fit)
#library(performance)
#lm_fit %>% check_model()
#plot(lm_fit)

test$.pred_lm <- predict(lm_fit,newdata = test)
#-------------------------------------------------------------------------------
# Use GLM to model on a gamma distribution.
#-------------------------------------------------------------------------------
#help(glm) 
#help(family)

glm_fit <- 
  glm(ticket_sales ~ .,
      data = train,
      family = Gamma(link = "inverse"))
# What should you do here? Transform the data?
test$.pred_glm <- predict(glm_fit,
                          newdata = test,
                          type="response")
#-------------------------------------------------------------------------------
# Robust Linear Regression: Omit here
#-------------------------------------------------------------------------------
#rlm_fit <- MASS::rlm(ticket_sales ~ .,
#                     data = train)

#test$.pred_rlm <- predict(rlm_fit,newdata = test)
#-------------------------------------------------------------------------------
# Compare Residuals
#-------------------------------------------------------------------------------
lm_resid    <-  test$ticket_sales - test$.pred_lm
glm_resid   <-  test$ticket_sales - test$.pred_glm
xgb_resid   <-  test$ticket_sales - test$.pred_xgb

observation <- seq(from = 1, to = length(lm_resid), by = 1)

residuals <- tibble::tibble(linear   = lm_resid,
                            glm      = glm_resid,
                            xgb      = xgb_resid,
                            observation = observation)

residuals <- residuals %>% pivot_longer(!observation, 
                                        names_to = "model", 
                                        values_to = "residual")

residuals %>% filter(observation <= 100) %>% 
  ggplot(aes(x = observation,
             y = residual, 
             group = model, 
             color = model))                                      +
  geom_point()                                                    +
  scale_color_manual(values = palette)                            +
  scale_x_continuous(labels = scales::comma)                      +
  scale_y_continuous(labels = scales::comma)                      +
  graphics_theme_1 +
  labs(x="Observation",
       y="Residual",
       title = "Comparing residiuals between models",
       subtitle = "",
       caption  = "[note] LM vs. GLM vs. XGB Models")            +
  theme(plot.caption = element_text(hjust = 0, 
                                    face= "italic",
                                    color = "grey10"),
        plot.title.position = "plot", 
        plot.caption.position =  "plot",
        plot.subtitle = element_text(color = "grey10")) 


ggsave(
  'images/model_residuals.png',
  plot = last_plot(),
  device = NULL,
  scale = 1,
  width = 8,
  height = 6,
  dpi = 300)
#-------------------------------------------------------------------------------
# Further evaluatation
#-------------------------------------------------------------------------------
# XGB
knitr::kable(xgboost_score)
# Linear Model
RSS <- c(crossprod(lm_fit$residuals))
MSE <- RSS / length(lm_fit$residuals)
RMSE <- sqrt(MSE)

print(paste("LM:  ",RMSE))

RSS <- c(crossprod(glm_fit$residuals))
MSE <- RSS / length(glm_fit$residuals)
RMSE <- sqrt(MSE)

print(paste("GLM:  ",RMSE))

#-------------------------------------------------------------------------------
# predictions graph XGB
#-------------------------------------------------------------------------------
model_graph <- test %>% select(ticket_sales,.pred_lm,.pred_glm,.pred_xgb) %>%
  mutate(observation = seq(1,nrow(test),by = 1))

model_graph %>% 
  ggplot(aes(x = ticket_sales,
             y = .pred_xgb))                                      +
  geom_point(color = 'steelblue4',alpha = .9)                     +
  geom_smooth(lty = 1, color = 'coral',se = F)                    +
  scale_color_manual(values = palette)                            +
  scale_x_continuous(labels = scales::comma)                      +
  scale_y_continuous(labels = scales::comma)                      +
  graphics_theme_1 +
  labs(x="Tickets Sold",
       y="XGB Prediction",
       title = "XGB Model Performance",
       subtitle = "",
       caption  = "")            +
  theme(plot.caption = element_text(hjust = 0, 
                                    face= "italic",
                                    color = "grey10"),
        plot.title.position = "plot", 
        plot.caption.position =  "plot",
        plot.subtitle = element_text(color = "grey10")) 

ggsave(
  'images/performance_xgb.png',
  plot = last_plot(),
  device = NULL,
  scale = 1,
  width = 8,
  height = 6,
  dpi = 300)
#-------------------------------------------------------------------------------
# predictions graph GLM
#-------------------------------------------------------------------------------
model_graph %>% 
  ggplot(aes(x = ticket_sales,
             y = .pred_glm))                                      +
  geom_point(color = 'steelblue4',alpha = .9)                     +
  geom_smooth(lty = 1, color = 'coral',se = F)                    +
  scale_color_manual(values = palette)                            +
  scale_x_continuous(labels = scales::comma)                      +
  scale_y_continuous(labels = scales::comma)                      +
  graphics_theme_1 +
  labs(x="Tickets Sold",
       y="GLM Prediction",
       title = "GLM Model Performance",
       subtitle = "",
       caption  = "")            +
  theme(plot.caption = element_text(hjust = 0, 
                                    face= "italic",
                                    color = "grey10"),
        plot.title.position = "plot", 
        plot.caption.position =  "plot",
        plot.subtitle = element_text(color = "grey10")) 
ggsave(
  'images/performance_glm.png',
  plot = last_plot(),
  device = NULL,
  scale = 1,
  width = 8,
  height = 6,
  dpi = 300)
#-------------------------------------------------------------------------------
# predictions graph LM
#-------------------------------------------------------------------------------
model_graph %>% 
  ggplot(aes(x = ticket_sales, 
             y = .pred_lm))                                       +
  geom_point(color = 'steelblue4',alpha = .9)                     +
  geom_smooth(lty = 1, color = 'coral',se = F)                    +
  scale_color_manual(values = palette)                            +
  scale_x_continuous(labels = scales::comma)                      +
  scale_y_continuous(labels = scales::comma)                      +
  graphics_theme_1 +
  labs(x="Tickets Sold",
       y="LM Prediction",
       title = "LM Model Performance",
       subtitle = "",
       caption  = "")            +
  theme(plot.caption = element_text(hjust = 0, 
                                    face= "italic",
                                    color = "grey10"),
        plot.title.position = "plot", 
        plot.caption.position =  "plot",
        plot.subtitle = element_text(color = "grey10")) 

ggsave(
  'images/performance_lm.png',
  plot = last_plot(),
  device = NULL,
  scale = 1,
  width = 8,
  height = 6,
  dpi = 300)
#-------------------------------------------------------------------------------
# Predict on 2025 data
#-------------------------------------------------------------------------------
# Clean
data_2025 <- data_2025 %>% filter(team %in% c('NYY', 'PIT', 'TOR') == F)

# LM
data_2025$.pred_lm <- predict(lm_fit,
                              newdata = data_2025)
# GLM
data_2025$.pred_glm <- predict(glm_fit,
                               newdata = data_2025,
                               type="response")
# XGB
xgb_preds <- xgboost_model_final %>%
  fit(
    formula = ticket_sales ~ .,
    data    = train_processed
  ) %>%
  predict(new_data = data_2025)

data_2025$.pred_xgb <- xgb_preds$.pred
#-------------------------------------------------------------------------------
# Compare 2025 data
#-------------------------------------------------------------------------------

model_graph <- data_2025 %>% select(ticket_sales,
                                    .pred_lm,.pred_glm,.pred_xgb)        %>%
  pivot_longer(!ticket_sales, 
               names_to = "model",  
               values_to = "value")

model_graph %>% 
  ggplot(aes(x = ticket_sales,
             y = value,
             color = model))                                      +
  geom_point(alpha = .9)                                          +
  geom_smooth(lty = 1,se = F)                                     +
  scale_color_manual(values = palette)                            +
  scale_x_continuous(labels = scales::comma)                      +
  scale_y_continuous(labels = scales::comma)                      +
  graphics_theme_1 +
  labs(x="Tickets Sold",
       y="Model Predictions",
       title = "Model Performance",
       subtitle = "",
       caption  = "")                                             +
  theme(plot.caption = element_text(hjust = 0, 
                                    face= "italic",
                                    color = "grey10"),
        plot.title.position = "plot", 
        plot.caption.position =  "plot",
        plot.subtitle = element_text(color = "grey10")) 

ggsave(
  'images/performance_2025.png',
  plot = last_plot(),
  device = NULL,
  scale = 1,
  width = 8,
  height = 6,
  dpi = 300)
#-------------------------------------------------------------------------------
# Look at residuals
#-------------------------------------------------------------------------------
lm_resid    <-  data_2025$ticket_sales - data_2025$.pred_lm
glm_resid   <-  data_2025$ticket_sales - data_2025$.pred_glm
xgb_resid   <-  data_2025$ticket_sales - data_2025$.pred_xgb

observation <- seq(from = 1, to = length(lm_resid), by = 1)

residuals <- tibble::tibble(linear   = lm_resid,
                            glm     = glm_resid,
                            xgb     = xgb_resid,
                            observation = observation)

residuals <- residuals %>% pivot_longer(!observation, 
                                        names_to = "model", 
                                        values_to = "residual")

residuals %>% filter(observation <= 100) %>% 
  ggplot(aes(x = observation,
             y = residual, 
             group = model, 
             color = model))                                      +
  geom_point()                                                    +
  scale_color_manual(values = palette)                            +
  scale_x_continuous(labels = scales::comma)                      +
  scale_y_continuous(labels = scales::comma)                      +
  graphics_theme_1 +
  labs(x="Observation",
       y="Residual",
       title = "Comparing residiuals between models for 2025",
       subtitle = "",
       caption  = "[note] LM vs. GLM vs. XGB Models")             +
  theme(plot.caption = element_text(hjust = 0, 
                                    face= "italic",
                                    color = "grey10"),
        plot.title.position = "plot", 
        plot.caption.position =  "plot",
        plot.subtitle = element_text(color = "grey10")) 


ggsave(
  'images/model_residuals_2025.png',
  plot = last_plot(),
  device = NULL,
  scale = 1,
  width = 8,
  height = 6,
  dpi = 300)

knitr::kable(
  residuals %>% group_by(model) %>%
    summarize(sum_resid = scales::comma(sum(residual^2))))
#-------------------------------------------------------------------------------
# Build event scores
#-------------------------------------------------------------------------------
data_2025$event_score <- as.vector(scale(data_2025$.pred_xgb) * 100)
data_2025 <- data_2025[order(-data_2025$event_score),]
#-------------------------------------------------------------------------------
# Observe differences in event scores
#-------------------------------------------------------------------------------
data_2025$order <- seq(1:nrow(data_2025))

x_label  <- ('\n Game')
y_label  <- ('Event Scores \n')
title   <- ('Ordered event scores')

  ggplot2::ggplot(data  = data_2025, 
                  aes(x = order,
                      y = event_score))            +
  geom_point(size = 1.3,color = 'dodgerblue')      +
  geom_line()                                      +
  scale_color_manual(values = palette)             +
  scale_y_continuous(label = scales::comma)        +
  xlab(x_label)                                    + 
  ylab(y_label)                                    + 
  ggtitle(title)                                   +
  graphics_theme_1

  ggsave(
    'images/event_scores_attendance.png',
    plot = last_plot(),
    device = NULL,
    scale = 1,
    width = 8,
    height = 6,
    dpi = 300)

# What is wrong with this?
# Constrained Demand.
# Is there a better method?
#-------------------------------------------------------------------------------
# END
#-------------------------------------------------------------------------------





