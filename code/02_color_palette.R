# ==============================
# ANC REPORT COLOR SYSTEM
# ==============================

# --- Main color palette ---
my_palette <- c(
  "turmeric"    = "#E6B800",  # muted amber highlight
  "dark_purple" = "#6E5A8C",  # intellectual tone
  "aquamarine"  = "#66C5CC",  # calm blue-green
  "muted_teal"  = "#4C8C8A",  # balanced neutral
  "warm_gray"   = "#C7BEBE",  # subtle contrast
  "deep_slate"  = "#2C2C34"   # for text, strong accent
)

# --- Neutral pastel palette (for secondary charts or backgrounds) ---
neutral_palette <- c("#F4EAD5", "#D7CCC8", "#B0BEC5", "#90A4AE", "#78909C")

# ==============================
# PALETTE FUNCTIONS
# ==============================

# Retrieve the ANC palette as a vector of hex colors
ss_pal <- function(palette = c("main", "neutral"), reverse = FALSE) {
  palette <- match.arg(palette)
  pal <- if (palette == "main") my_palette else neutral_palette
  if (reverse) pal <- rev(pal)
  pal
}

# Color scale for discrete variables
scale_color <- function(palette = "main", reverse = FALSE, ...) {
  pal <- ss_pal(palette, reverse)
  ggplot2::scale_color_manual(values = pal, ...)
}

# Fill scale for discrete variables
scale_fill <- function(palette = "main", reverse = FALSE, ...) {
  pal <- ss_pal(palette, reverse)
  ggplot2::scale_fill_manual(values = pal, ...)
}

# Gradient fill for continuous variables (uses first & last palette colors)
scale_fill_continuous <- function(palette = "main", reverse = FALSE, ...) {
  pal <- ss_pal(palette, reverse)
  ggplot2::scale_fill_gradientn(colors = pal, ...)
}

# ==============================
# THEME FUNCTION
# ==============================

theme_ss_report <- function(base_size = 12, base_family = "") {
  ggplot2::theme_minimal(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      text = ggplot2::element_text(color = my_palette["deep_slate"]),
      plot.title = ggplot2::element_text(
        face = "bold", hjust = 0.5, size = base_size + 1, color = my_palette["dark_purple"]
      ),
      plot.subtitle = ggplot2::element_text(
        hjust = 0.5, size = base_size - 1, color = my_palette["muted_teal"]
      ),
      axis.title = ggplot2::element_text(face = "bold"),
      axis.text = ggplot2::element_text(color = my_palette["deep_slate"]),
      panel.grid.major = ggplot2::element_line(color = "#EAEAEA"),
      panel.grid.minor = ggplot2::element_blank(),
      plot.background = ggplot2::element_rect(fill = "white", color = NA),
      legend.title = ggplot2::element_text(face = "bold"),
      legend.background = ggplot2::element_rect(fill = "transparent", color = NA),
      plot.margin = ggplot2::margin(10, 10, 10, 10)
    )
}
