
theme_30DayMapChallenge_black <- function(...) {
    theme_minimal() %+replace% 
        theme(
            text = element_text(family = "Montserrat", colour = "#ffffff"),
            title = element_text(family = "Montserrat", colour = "#ffffff"),
            plot.subtitle = element_text(size = 16, hjust = 0.5,
                                         margin = margin(t = 10, b = 10, unit = "pt")),
            plot.title = element_text(hjust = 0.5, size = 20, family = "Keep Calm Med",
                                      margin = margin(t = 10, b = 10, unit = "pt")),
            legend.title = element_text(size = 14),
            axis.text = element_blank(),
            axis.title = element_blank(),
            plot.margin = unit(c(0.5, 0.5, 0.5, 0.5), units = "cm"),
            plot.background = element_rect(fill = "#2d2d2d", colour = NA),
            panel.background = element_rect(fill = "#2d2d2d", colour = NA),
            panel.grid.major = element_blank(),
            panel.grid.minor = element_blank(),
            plot.caption = element_text(size = 9, lineheight = 1, hjust = 1),
            legend.position = "bottom",
            ...
        )
}

theme_30DayMapChallenge_black_reduced <- function(...) {
    theme_minimal() %+replace% 
        theme(
            text = element_text(family = "Montserrat", colour = "#ffffff"),
            title = element_text(family = "Montserrat", colour = "#ffffff"),
            plot.subtitle = element_text(size = 16, hjust = 0.5,
                                         margin = margin(t = 5, b = 5, unit = "pt")),
            plot.title = element_text(hjust = 0.5, size = 20, family = "Keep Calm Med",
                                      margin = margin(t = 5, b = 5, unit = "pt")),
            legend.title = element_text(size = 14),
            axis.text = element_blank(),
            axis.title = element_blank(),
            plot.margin = unit(c(0.1, 0.1, 0.1, 0.1), units = "cm"),
            plot.background = element_rect(fill = "#2d2d2d", colour = NA),
            panel.background = element_rect(fill = "#2d2d2d", colour = NA),
            panel.grid.major = element_blank(),
            panel.grid.minor = element_blank(),
            plot.caption = element_text(size = 9, lineheight = 1, hjust = 1),
            legend.position = "bottom",
            ...
        )
}

theme_30DayMapChallenge_clear <- function(...) {
    theme_minimal() %+replace% 
        theme(
            text = element_text(family = "Montserrat", colour = "#22211d"),
            title = element_text(family = "Montserrat", colour = "#22211d"),
            plot.subtitle = element_text(size = 16, hjust = 0.5,
                                         margin = margin(t = 10, b = 10, unit = "pt")),
            plot.title = element_text(hjust = 0.5, size = 20, family = "Keep Calm Med",
                                      margin = margin(t = 10, b = 10, unit = "pt")),
            legend.title = element_text(size = 14),
            axis.text = element_blank(),
            axis.title = element_blank(),
            plot.margin = unit(c(0.5, 0.5, 0.5, 0.5), units = "cm"),
            plot.background = element_rect(fill = "#f5f5f2", colour = NA),
            panel.background = element_rect(fill = "#f5f5f2", colour = NA),
            panel.grid.major = element_blank(),
            panel.grid.minor = element_blank(),
            plot.caption = element_text(size = 9, lineheight = 1, hjust = 1),
            legend.position = "bottom",
            ...
        )
}

theme_30DayMapChallenge_white <- function(...) {
    theme_minimal() %+replace% 
        theme(
            text = element_text(family = "Montserrat", colour = "#404040"),
            title = element_text(family = "Montserrat", colour = "#404040"),
            plot.subtitle = element_text(size = 16, hjust = 0.5,
                                         margin = margin(t = 10, b = 10, unit = "pt")),
            plot.title = element_text(hjust = 0.5, size = 20, family = "Keep Calm Med",
                                      margin = margin(t = 10, b = 10, unit = "pt")),
            legend.title = element_text(size = 14),
            axis.text = element_blank(),
            axis.title = element_blank(),
            plot.margin = unit(c(0.5, 0.5, 0.5, 0.5), units = "cm"),
            plot.background = element_rect(fill = "#FFFFFF", colour = NA),
            panel.background = element_rect(fill = "#FFFFFF", colour = NA),
            panel.grid.major = element_blank(),
            panel.grid.minor = element_blank(),
            plot.caption = element_text(size = 9, lineheight = 1, hjust = 1),
            legend.position = "bottom",
            ...
        )
}

theme_30DayMapChallenge_white_reduced <- function(...) {
    theme_minimal() %+replace% 
        theme(
            text = element_text(family = "Montserrat", colour = "#404040"),
            title = element_text(family = "Montserrat", colour = "#404040"),
            plot.subtitle = element_text(size = 16, hjust = 0.5,
                                         margin = margin(t = 5, b = 5, unit = "pt")),
            plot.title = element_text(hjust = 0.5, size = 20, family = "Keep Calm Med",
                                      margin = margin(t = 5, b = 5, unit = "pt")),
            legend.title = element_text(size = 14),
            axis.text = element_blank(),
            axis.title = element_blank(),
            plot.margin = unit(c(0.1, 0.1, 0.1, 0.1), units = "cm"),
            plot.background = element_rect(fill = "#FFFFFF", colour = NA),
            panel.background = element_rect(fill = "#FFFFFF", colour = NA),
            panel.grid.major = element_blank(),
            panel.grid.minor = element_blank(),
            plot.caption = element_text(size = 9, lineheight = 1, hjust = 1),
            legend.position = "bottom",
            ...
        )
}

theme_30DayMapChallenge_whiter_ultrareduced <- function(...) {
    theme_minimal() %+replace% 
        theme(
            text = element_text(family = "Montserrat", colour = "#808080"),
            title = element_text(family = "Montserrat", colour = "#808080"),
            plot.subtitle = element_text(size = 16, hjust = 0.5,
                                         margin = margin(t = 5, b = 5, unit = "pt")),
            plot.title = element_text(hjust = 0.5, size = 20, family = "Keep Calm Med",
                                      margin = margin(t = 5, b = 5, unit = "pt")),
            legend.title = element_text(size = 14),
            axis.text = element_blank(),
            axis.title = element_blank(),
            plot.margin = unit(c(0, 0, 0, 0), units = "cm"),
            plot.background = element_rect(fill = "#FFFFFF", colour = NA),
            panel.background = element_rect(fill = "#FFFFFF", colour = NA),
            panel.grid.major = element_blank(),
            panel.grid.minor = element_blank(),
            plot.caption = element_text(size = 9, lineheight = 1, hjust = 1),
            legend.position = "bottom",
            ...
        )
}
