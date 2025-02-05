#-----------------------------------------------------------------
# creating a color palette
#-----------------------------------------------------------------
require(ggplot2)
palette <- c('grey25','dodgerblue','mediumseagreen','coral',
             'orchid','firebrick','goldenrod','cyan',
             'brown','steelblue','magenta')
#-----------------------------------------------------------------
# Creating a custom theme
#-----------------------------------------------------------------
graphics_theme_1 <- ggplot2::theme() + 
  theme(axis.text.x  = element_text(angle  = 0, size  = 14, 
                                    vjust  = 0, color = "grey10"),  
        axis.text.y  = element_text(angle  = 0, size  = 14, 
                                    vjust  = 0, color = "grey10"),  
        axis.title.x = element_text(size   = 16, face = "plain", 
                                    colour = "grey10"), 
        axis.title.y = element_text(size   = 16, face = "plain", 
                                    color  = "grey10"), 
        legend.title = element_text(size   = 14, face = "plain", 
                                    color  = "grey10"), 
        legend.text  = element_text(size   = 11, 
                                    color  = "grey10"), 
        plot.title   = element_text(colour = "grey10", 
                                    size   = 14, angle = 0, 
                                    hjust  = .5, vjust = .5, 
                                    face   = "bold"), 
        legend.position   = "right", 
        legend.background = element_rect(fill     = "#ffffff", 
                                         linewidth =  3,  
                                         linetype = "solid", 
                                         colour   = "#ffffff"), 
        legend.key        = element_rect(fill     = "#ffffff", 
                                         color    = "#ffffff"), 
        strip.background  = element_rect(fill     =  "#ffffff", 
                                         colour   = "#ffffff"), 
        strip.text        = element_text(size     = 14, 
                                         face     = "plain", 
                                         color    = "grey10"), 
        panel.grid.major  = element_line(colour   = "grey80"),  
        panel.grid.minor  = element_line(colour   = "grey80"), 
        panel.background  = element_rect(fill     = "#ffffff", 
                                         colour   = "#ffffff"), 
        plot.background   = element_rect(fill     = "#ffffff", 
                                         colour   = "#ffffff"))