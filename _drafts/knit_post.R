# FUNCTION TO PUBLISH A BLOG POST
knit_post <- function(file) {
  
  # DETECT SYSTEM 
  if (.Platform$OS.type == "windows") {
    windows = TRUE
  } else if (Sys.info()["sysname"] == "Darwin") {
    windows = FALSE
  }
  
  # SAVE CURRENT DIRECTORY
  current_dir <- getwd()
  
  # KNIT AND SEND TO POSTS FOLDER
  if (windows == TRUE) {
    setwd("C://Users//Randi Griffin//Documents//GitHub//rgriff23.github.io//_drafts/")
    knitr::knit(input = file,
                output = paste0("C://Users//Randi Griffin//Documents//GitHub//rgriff23.github.io//_posts//", file))
  } else {
    setwd("~/Documents/GitHub/rgriff23.github.io/_drafts/")
    knitr::knit(input = file,
                output = paste0("~/Documents/GitHub/rgriff23.github.io/_posts/", file))
  }
  
  # RETURN TO ORIGINAL DIRECTORY
  setwd(current_dir)
  
}