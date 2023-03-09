library(haven)
setwd("C:/Users/miche/OneDrive/Documenti/USA/School/SPRING 2023/Thesis Workshop V2/Thesis_code/Data/Wrangling")

GSS_ANES_01 <- read_dta("02_ANES_GSS_merge_2018_2020.dta")

library(dplyr)
library(tidyr)
library(magrittr)
library(labelled)
library(ggplot2)


# Changing Format from Wide to Long and creating observation duplicates for each year
GSS_ANES_02 <- GSS_ANES_01 %>%
  select(!c(year_1b,year_2)) %>%
  pivot_longer(
    cols = -c(samptype, yearid, fileversion, panstat, anesid, version, V200001, V200017b, V200017c, V200017d, V202022, V202352, V202470, V202542, V202543, V202544, V202545, V202546, V202547, V202629, V202630, "_merge"),
    names_sep = "_",
    names_to = c(".value", "year"),
    names_repair = "minimal")

#panstat tracks if the respondent was followed throughout the entire length of the study (initial interview, 2020 and ANES addendum).
#The slice removes variables which did not have a 2020 observations.
GSS_ANES_03 <- GSS_ANES_02 %>%
  filter(panstat == 1) %>%
  slice(1619:3646) %>%
  mutate(year = case_when(
    year == "1b" ~ "2018",
    year == 2 ~ "2020"
  ))

#Relevant Variables
library(forcats)
GSS_ANES_04 <- GSS_ANES_03 %>%
  select(c(23:28, 32, 33, 35, 36, 40:44, 47, 50, 54:63)) %>%
  mutate(year = fct(year))

write_dta(GSS_ANES_04, file.path("C:/Users/miche/OneDrive/Documenti/USA/School/SPRING 2023/Thesis Workshop V2/Thesis_code/Data/Analysis/03_GSS_ANES_merge.dta"))

#Missing Variable Analysis
library(naniar)

any_na(GSS_ANES_04)
# How many?
n_miss(GSS_ANES_04)
prop_miss(GSS_ANES_04)
# Which variables are affected?
GSS_ANES_04 %>% is.na() %>% colSums()
miss_var_summary(GSS_ANES_04)
miss_var_table(GSS_ANES_04)
# Get number of missings per participant (n and %)
miss_case_summary(GSS_ANES_04)
miss_case_table(GSS_ANES_04)
vis_miss(GSS_ANES_04,cluster = TRUE) + theme(axis.text.x = element_text(angle=80))
gg_miss_var(GSS_ANES_04)
# Which combinations of variables occur to be missing together?
gg_miss_upset(GSS_ANES_04)

library(mice)
md.pattern(GSS_ANES_04, rotate.names = TRUE) 

library(VIM)
aggr_plot <- aggr(GSS_ANES_04, col=c('navyblue','red'), numbers=TRUE, sortVars=TRUE, labels=names(data), cex.axis=.7, gap=3, ylab=c("Histogram of missing data","Pattern"))

#Imputing our variables with Missforest
library(visdat)

vis_miss(GSS_ANES_04)


ggplot(GSS_ANES_04, aes(intcntct, happy)) + 
  geom_miss_point() + 
  facet_wrap(~ year)

gg_miss_var(GSS_ANES_04, facet = year)

gg_miss_upset(data)

gg_miss_fct(x = variable1, fct = variable2)



library(missForest)

GSS_miss <- prodNA(GSS_ANES_04, noNA)






seed <- list(660:666)

GSS_ANES_miss %>%
  

for (i in seed){
  temp[[i]] <- missForest(GSS_ANES_04)
}

set.seed(666)
GSS_ANES_mis <- prodNA(iris, noNA = 0.1)
head(GSS_ANES_mis)
class(GSS_ANES_mis)
summary(GSS_ANES_mis)

GSS_ANES_imp <- missForest(GSS_ANES_mis)
GSS_ANES_imp$OOBerror
