library(afex)
library(car)
library(ez)
library(nlme)
library(lmerTest)
library(jmv)
rm(list=ls())

data <- read.csv("resources//BIRD.csv")
data_long <- data %>%
  pivot_longer(
    cols = 3:5,
    names_to = "Spacing",
    values_to = "Yield")%>%
  dplyr::select(subj,Group,Spacing,Yield)
data_long$Group <- as.factor(data_long$Group)

#afex
mod_aov_ez <- aov_ez("subj", "Yield", data_long, within = "Spacing", between = "Group")
summary(mod_aov_ez)
sum_emm_btwn <- emmeans(mod_aov_ez, "Group")
sum_emm_btwn

#base_R - not the same result
mod_aov <- aov(Yield ~ Spacing * Group + Error(subj/Spacing), data = data_long)
sum <- summary(mod_aov)
sum_emm_btwn <- emmeans(mod_aov, "Group")
sum_emm_btwn

#car-didnt work
mod_Anova <- lm(Yield ~ Spacing * Group + Error(subj/Spacing), data = data_long)
Anova(mod_Anova, type = "III")
#?
mod_aov <- aov(Yield ~ Spacing * Group + Error(subj/Spacing), data = data_long)
anova_results_aov <- Anova(mod_aov, type = "III")
summary(anova_results_aov)

#ez-didnt work
mod_ez <- ezANOVA(data = data_long, dv = .(Yield), wid = .(subj), within = .(Spacing), between = .(Group), type = 3)
mod_ez #?

#nlme
mod_lme <- lme(Yield ~ Spacing * Group, random = ~1 | subj, data = data_long)
summary(mod_lme)

#lmerTest
mod_lmer <- lmer(Yield ~ Spacing * Group + (1 | subj), data = data_long)
anova(mod_lmer) #???

#jmv
mod_RM <- anovaRM(data_long, dep = "Yield", rm = list("Spacing"), bs = "Group", subject = "subj")
summary(mod_RM)


afex_options(emmeans_model = "multivariate")
recover_data(mod_aov_ez)
