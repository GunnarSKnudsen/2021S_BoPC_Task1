library("tidyverse")
library(kableExtra)

# Settings
options(digits=2)
#setwd("~/tuWien/2021S_191114_Basics_of_parallel_Computing/assignments/assignment1/bopc-julia-python_20210420/julia_set/serverOutput")
setwd("C:/Users/Tom/Documents/GitHub/2021S_BoPC_Task1/serverOutput")
#Helper 
latexTable <- function(iDf, iTitle) {
    kbl(iDf, booktabs = TRUE, caption = iTitle, format = "latex", digits = 2) %>%
        kable_styling(latex_options = c("striped"
                                        , "HOLD_position"
                                        #, "scale_down"
        )
        #, position = "left"
        )
}

# Read in files
output_q2 <- read.csv2("output_exp_q2.dat"
                        , header = FALSE
                        , dec = "."
                        , col.names = c("size","patch","nprocs","time")
                        , colClasses = c("numeric", "numeric", "numeric", "numeric")
            )

output_q3 <- read.csv2("output_exp_q3.dat"
                       , header = FALSE
                       , dec = "."
                       , col.names = c("size","patch","nprocs","time")
                       , colClasses = c("numeric", "numeric", "numeric", "numeric")
            )
output_q4 <- read.csv2("output_exp_q4.dat"
                       , header = FALSE
                       , dec = "."
                       , col.names = c("size","patch","nprocs","time")
                       , colClasses = c("numeric", "numeric", "numeric", "numeric")
            )


output_q2_agg <- output_q2 %>% 
    group_by(size, nprocs) %>%
    summarize(meanVal = mean(time))


# Compute Speedup
su200 = output_q2_agg[output_q2_agg$size == 200 & output_q2_agg$nprocs==1,]$meanVal / 
    output_q2_agg[output_q2_agg$size == 200,]$meanVal

su1000 = output_q2_agg[output_q2_agg$size == 1000 & output_q2_agg$nprocs==1,]$meanVal / output_q2_agg[output_q2_agg$size == 1000,]$meanVal

su = c(su200, su1000)
su
output_q2_agg$su = su
output_q2_agg$parEff = output_q2_agg$su / output_q2_agg$nprocs



# Table Res:
output_q2_res <- output_q2_agg %>% rename("size" = size
                                          , "p" = nprocs
                                          , "mean runtime (s)" = meanVal
                                          , "speed-up" = su
                                          , "par.eff." = parEff)

# Latex formatting
res <- output_q2_res  %>% latexTable("Best solutions for both methods")
print(res)

output_q2_res
# Graph(s)

# Absolute Time:
ggplot(output_q2_res, aes(x=p, y=`mean runtime (s)`, color=factor(size))) +
    geom_point() +
    geom_line() + 
    labs(title = "Comparison Absolute Time")

ggsave("2_abs_time.png")


# Speed-up:
ggplot(output_q2_res, aes(x=p, y=`speed-up`, color=factor(size))) +
    geom_abline(slope=1, col="black", linetype="dashed", size=1) +
    geom_point() +
    geom_line() + 
    labs(title = "Comparison Speed-up")

ggsave("2_speedup.png")


# Parallel efficiency:
ggplot(output_q2_res, aes(x=p, y=`par.eff.`, color=factor(size))) +
    geom_hline(yintercept=1, col="black", linetype="dashed", size=1) +
    geom_point() +
    geom_line() + 
    labs(title = "Comparison parallel efficiency")

ggsave("2_parallel_eff.png")

# 3

output_q3_agg <- output_q3 %>% 
    group_by(size, nprocs, patch) %>%
    summarize(meanVal = mean(time))

output_q3_agg

output_q3_res <- output_q3_agg %>% rename("size" = size
                                          , "p" = nprocs
                                          , "patch" = patch
                                          , "mean runtime (s)" = meanVal
                                          )

# Latex formatting
res3 <- output_q3_res  %>% latexTable("Comparing patch size effect on fixed problem.")
print(res3)
output_q3_res


# Plot
ggplot(output_q3_res, aes(x=patch, y=`mean runtime (s)`))+
    geom_point() +
    geom_line() + 
    labs(title = "Comparison patch size")

ggsave("3.png")





# 4

output_q4_agg <- output_q4 %>% 
    group_by(size, nprocs, patch) %>%
    summarize(meanVal = mean(time))

output_q4_agg

output_q4_res <- output_q4_agg %>% rename("size" = size
                                          , "p" = nprocs
                                          , "patch" = patch
                                          , "mean runtime (s)" = meanVal
)

# Latex formatting
res4 <- output_q4_res  %>% latexTable("Finding the best patch size")
print(res4)
output_q4_res


# Plot
ggplot(output_q4_res, aes(x=patch, y=`mean runtime (s)`))+
    geom_point() +
    geom_line() + 
    labs(title = "Comparison patch size")

ggsave("4.png")

