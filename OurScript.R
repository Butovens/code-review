## Loading Necessary Libraries ----
library(tidyverse)
library(skimr)
library(visdat)
library(ggplot2)

## Path to data (can be changed by user) 
data_dir <- "data"
target_file <- file.path(data_dir,"CrowdstormingDataJuly1st.csv")

## Load data
soccer_data <- read_csv(target_file)

## Skim the data ----
skim(soccer_data)

#' The data shows that there are 28 variables, but the README file only mention 27. It appears that
#' "ALPHA_3" is the additional variable on the dataset. It is a character variable with 160 unique abservations
#' in it. 


## Visualization of missing data
# vis_miss(soccer_data,
#          warn_large_data = FALSE)
#' This is commented out because it takes a long time to run. Run at your own risk. :)

## Visualization of smaller dataset
set.seed(2020-10-22)
soc_small <- sample_n(soccer_data, 15000)

vis_miss(soc_small,
         cluster = TRUE,
         sort_miss = TRUE)

#' From this we can see that observation for variables photo ID, rater1 and rater2 are missing together. This makes sense 
#' as the raters need the players' pictures to rate their skin tones.


## Plots ----
plt_viol <- ggplot(data = soccer_data,
                   aes(leagueCountry,
                       meanIAT,
                       fill = leagueCountry)) +
            geom_violin() +
            labs(title = "Mean Implicit Bias Score by Country League",
                 subtitle = "IAT scores for referrees' country of origin",
                 x = "European League Country",
                 y = "Mean IAT Score")

plt_viol + theme(axis.text = element_text(size = 12),
                 axis.title = element_text(size = 14,
                                           face="italic"))

#' The plot above seems to show that Spain has a higher tendency than the other countries in the league 
#' to associate white with good and black with bad. However this visualization might not be the best.
#' Let's looks at histograms per Country

plt_hist <- ggplot(data = soccer_data,
                   aes(x = meanIAT,
                       color = leagueCountry,
                       fill = leagueCountry)) +
            geom_histogram() +
            labs(title = "Mean Implicit Bias Score by Country League",
                 subtitle = "IAT scores for referrees' country of origin",
                 x = "Mean IAT Score")

plt_hist + theme(axis.text = element_text(size = 12),
                 axis.title = element_text(size = 14,
                                           face="italic"))
  
plt_hist + facet_wrap(vars(leagueCountry))

#' This view is better. Although Spain has the higher IAT mean, it is also the country with the less observations
#' Let's look at the relationship between implicit and explicit bias 
                 
plt_point <- ggplot(data = soccer_data,
                    aes(meanIAT,
                        meanExp,
                        color = leagueCountry)) +
             geom_point() +
             labs(title = "Mean Implicit Bias Score Vs Mean Explicit Bias Score",
                  subtitle = "IAT and racial thermometer scores for referrees' country of origin",
                  x = "Mean IAT Score",
                  y = "Mean Racial Thermometer Score")

plt_point + theme(axis.text = element_text(size = 12),
                  axis.title = element_text(size = 14,
                                            face ="italic"))

#' There seem to be a strong positive correlation between implicit and explicit bias in the league.
#' We can look at that association per Country:

plt_point + facet_wrap(vars(leagueCountry)) + geom_smooth(method = "lm",
                                                          col = "firebrick")

#' The plots look very similar between countries, almost identical (except for a few observations)...


## Diving into the data ----

#' Let's look at the number of yellowCards, yellowReds, redCards given by each country

## Number of Yellow cards by country league:
Tot_Yel_Crd <- soccer_data %>% 
                  group_by(leagueCountry) %>% 
                  summarize(total_Ycard = sum(yellowCards)) %>% 
                  ungroup()

Tot_Yel_Crd 
#' It appears that the Spanish league has the highest number of yellow cards given


## Number of Yellow-Red cards by country league:
Tot_YelRed_Crd <- soccer_data %>% 
                      group_by(leagueCountry) %>% 
                      summarize(total_YRcard = sum(yellowReds)) %>% 
                      ungroup()

Tot_YelRed_Crd 
#' It also appears that the Spanish league has a higher number of yellow cards leading to a red given. 
#' But given the total number of games played this is not really different


## Number of Red cards by country league:
Tot_Red_Crd <- soccer_data %>% 
                  group_by(leagueCountry) %>% 
                  summarize(total_Rcard = sum(redCards)) %>% 
                  ungroup()

Tot_Red_Crd 
#' The Spanish league has also the highest number of red cards given (shortly followed by England with only 3 less given)

Tot_Crd <- soccer_data %>% 
              group_by(leagueCountry) %>% 
              summarize(total_card = sum(yellowCards,yellowReds, redCards)) %>% 
              ungroup()

Tot_Crd
#' With no the surprise the Spanish league gave out the highest numbers of cards


## ANOVA ----
## Run a quick anova
res.aov <- aov(redCards ~ leagueCountry, data = soccer_data)
summary(res.aov)

## Run quick post hoc
TukeyHSD(res.aov)

#' Based on our ANOVA, there are significant differences in means for red cards between France & England, Germany & England,
#' Spain & England, Germany & France, and Spain & Germany. However, there isn't a significant difference between Spain & France.
#' This is consistent with conventional beliefs about the soccer cultures in Spain and France.


## Other types of analysis ----

## Number of player in the different leagues that have been identified as mostly dark-skinned by both raters
soccer_data %>% 
  group_by(leagueCountry) %>% 
  filter(rater1 > .5 & rater2 > .5) %>% 
  count() %>% 
  ungroup()
  
## Number of player in the different leagues that have been identified as mostly light-skinned by both raters  
  
soccer_data %>% 
  group_by(leagueCountry) %>% 
  filter(rater1 <= .5 & rater2 <= .5) %>% 
  count() %>% 
  ungroup()

## Number of Red cards in the different leagues received by players who have been rated dark-skinned by both raters    
 
  soccer_data %>% 
    group_by(leagueCountry) %>% 
    filter(rater1 > .5 & rater2 > .5) %>% 
    summarize(total_card = sum(redCards)) %>% 
    ungroup()
 
## Number of Red cards in the different leagues received by players who have been rated dark-skinned by both raters  
  
  soccer_data %>% 
    group_by(leagueCountry) %>% 
    filter(rater1 <= .5 & rater2 <= .5) %>% 
    summarize(total_card = sum(redCards)) %>% 
    ungroup()
  
#' From these is seems that light skinned and dark-skinned player are affected similarly by red cards (i.e. in 
#' identical proportion)







