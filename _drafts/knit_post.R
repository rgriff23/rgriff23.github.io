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
  
  # CHANGE EXTENSION
  file2 <- gsub(".Rmd", ".md", file)
  
  # KNIT AND SEND TO POSTS FOLDER
  if (windows == TRUE) {
    setwd("C://Users//Randi Griffin//Documents//GitHub//rgriff23.github.io//_drafts/")
    knitr::knit(input = file,
                output = paste0("C://Users//Randi Griffin//Documents//GitHub//rgriff23.github.io//_posts//", file2))
  } else {
    setwd("~/Documents/GitHub/rgriff23.github.io/_drafts/")
    knitr::knit(input = file,
                output = paste0("~/Documents/GitHub/rgriff23.github.io/_posts/", file2))
  }
  
  # RETURN TO ORIGINAL DIRECTORY
  setwd(current_dir)
  
}