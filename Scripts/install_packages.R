# List of required packages
required_packages <- c(
  "pacman",
  "ggplot2",  
  "dplyr",     
  "ggpubr",   
  "cobalt",    
  "gridExtra", 
  "geepack",    
  "broom",  
  "MatchIt",    
  "bcaboot",
  "magrittr",
  "FDRestimation",
  "tidyr",
  "quickmatch",
  "gt"
)

# Available Versions used
package_versions <- c(
  "pacman" = "0.5.0",
  "dplyr" = "1.1.4",
  "ggpubr" = "0.6.0",
  "cobalt" = "4.5.5",
  "gridExtra" = "2.3",
  "broom" = "1.0.6",
  "bcaboot" = "0.2-3",
  "magrittr" = "2.0.3",
  "FDRestimation" = "1.0.1",
  "tidyr" = "1.3.1",
  "quickmatch" = "0.2.2",
  "gt" = "0.10.1"
)

# Function to check if a package is installed and install it if necessary
install_if_missing <- function(package, version) {
  if (!require(package, character.only = TRUE)) {
    if (!requireNamespace("remotes", quietly = TRUE)) {
      install.packages("remotes")
    }
    remotes::install_version(package, version = version)
    library(package, character.only = TRUE)
  }
}

# Install and load all required packages
invisible(lapply(names(package_versions),
                 function(pkg) install_if_missing(pkg, 
                                                  package_versions[[pkg]])))
