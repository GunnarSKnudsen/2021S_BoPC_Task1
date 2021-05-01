library("tidyverse")
library(kableExtra)

# Settings
options(digits=16)
setwd("~/tuWien/2021S_191114_Basics_of_parallel_Computing/assignments/assignment1/bopc-julia-python_20210420/julia_set/serverOutput")

#Helper 
latexTable <- function(iDf, iTitle) {
    kbl(iDf, booktabs = TRUE, caption = iTitle) %>%
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
                       , col.names = c("size","patch","nprocs","time")
                       , colClasses = c("numeric", "numeric", "numeric", "numeric")
            )
output_q4 <- read.csv2("output_exp_q4.dat"
                       , header = FALSE
                       , col.names = c("size","patch","nprocs","time")
                       , colClasses = c("numeric", "numeric", "numeric", "numeric")
            )


output_q2_agg <- output_q2 %>% 
    group_by(size, nprocs) %>%
    summarize(meanVal = mean(time))


# Compute Speedup
### FUUUCK THIS IS BADLY CODED _ REFACOTR!
su200 = output_q2_agg[output_q2_agg$size == 200 & output_q2_agg$nprocs==1,]$meanVal / 
    output_q2_agg[output_q2_agg$size == 200,]$meanVal

su1000 = output_q2_agg[output_q2_agg$size == 1000 & output_q2_agg$nprocs==1,]$meanVal / output_q2_agg[output_q2_agg$size == 1000,]$meanVal

su = c(su200, su1000)
su
output_q2_agg$su = su
output_q2_agg$parEff = output_q2_agg$su / output_q2_agg$nprocs

### AAAARGH! Why you no print?
(res <- output_q2_agg%>% latexTable("Best solutions for both methods"))
# And even worse? AS HTML?
dput(res)

# Table Res:
output_q2_res <- output_q2_agg %>% select("size" = size
                                          , "p" = nprocs
                                          , "mean runtime (s)" = meanVal
                                          , "speed-up" = su
                                          , "par.eff." = parEff)
output_q2_res
# Graph(s)

# Absolute Time:
ggplot(output_q2_res, aes(x=p, y=`mean runtime (s)`, color=factor(size))) +
    geom_point() +
    geom_line() + 
    labs(title = "title",
         subtitle = "Subtitle",
         caption = "Parameters")



# Speed-up:
ggplot(output_q2_res, aes(x=p, y=`speed-up`, color=factor(size))) +
    geom_abline(slope=1, col="black", linetype="dashed", size=1) +
    geom_point() +
    geom_line() + 
    labs(title = "title",
         subtitle = "Subtitle",
         caption = "Parameters")



# Parallel efificency:
ggplot(output_q2_res, aes(x=p, y=`par.eff.`, color=factor(size))) +
    geom_hline(yintercept=1, col="black", linetype="dashed", size=1) +
    geom_point() +
    geom_line() + 
    labs(title = "parallel efficiency for both problem sizes and nprocs",
         subtitle = "Subtitle",
         caption = "Parameters")

