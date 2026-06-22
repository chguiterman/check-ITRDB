## Assess ITRDB check returns
# CHG 2023-01-18

library(tidyverse)
library(dplR)

url <-"https://www.ncei.noaa.gov/pub/data/paleo/treering/measurements/"

chk <- read_csv("data/ITRDB_RWL_files.csv")

bad_files <- chk %>% 
  filter(result != "rwl") %>% 
  mutate(result = map2(region, file_name,
                           ~ {
                             if (.x %in% c("canada", "mexico", "usa")) {
                               url <- str_glue("{url}northamerica/")
                             }
                             try(
                               read.rwl(str_glue("{url}{.x}/{.y}"),
                                        format = "tucson")
                             )
                           }),
         reason = map_chr(result, ~ attr(.x, "condition")[["message"]])
  )


read.rwl("https://www.ncei.noaa.gov/pub/data/paleo/treering/measurements/asia/chin067.rwl")

write_csv(bad_files %>% 
            select(-result),
          str_glue("Analysis/{lubridate::today()}_ITRDB_problem_RWL_files.csv"))
