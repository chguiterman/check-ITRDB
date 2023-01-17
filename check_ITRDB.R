# Check readability of RWL files in ITRDB measurements
## CHG 2022-12-15

# get index of all files in each folder
## help: https://stackoverflow.com/questions/15954463/read-list-of-file-names-from-web-into-r
## 

library(dplyr)
library(tidyr)
library(stringr)
library(purrr)
library(rvest)
library(dplR)

url <-"https://www.ncei.noaa.gov/pub/data/paleo/treering/measurements/"

regions <- c("asia", "africa", "atlantic", "australia", 
             "centralamerica", "europe", "canada", "mexico", "usa", 
             "southamerica") 
  
file_index <-
  tibble(region = as.factor(regions),
         file_name = map(regions, 
                         ~ {
                           if (.x %in% c("canada", "mexico", "usa")) {
                             url <- str_glue("{url}northamerica/")
                           } 
                           read_html(str_glue("{url}{.x}")) %>% 
                             html_elements("a") %>% 
                             html_text2()
                         })
  ) %>% 
  unnest(file_name) %>% 
  filter(str_detect(file_name, ".rwl")
  ) 


meas_files <- file_index %>% 
  filter(!str_detect(file_name, "-noaa"))


meas_file_check <- meas_files %>%
  # filter(region == "africa") %>%
  mutate(result = map2_chr(region, file_name,
                      ~ {
                        if (.x %in% c("canada", "mexico", "usa")) {
                          url <- str_glue("{url}northamerica/")
                        }
                        class(
                          try(
                            read.rwl(str_glue("{url}{.x}/{.y}"),
                                     format = "tucson")
                            )
                          )[[1]]
                      })
  )

write.csv(meas_file_check, "data/ITRDB_RWL_files.csv")
