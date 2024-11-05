# Psy2R - an R package for better inference in multivariate statistical analysis   

<br>

**A list of contributors so far**

Kelly Garner  
Christopher Nolan  
Jonathan Rittmo  
Kimberly Rogge-Obando  
Jessica Lee  
Julie Chow  
Josh Wooley  
Josh Mosse-Robinson  
Lydia Barnes  
Kateryna Marchenko  
Ambica Golyala  
Mariia Ptukha   
Sonny Li  
Kevin Bird   


<br>

## About

We consistently use massive datasets across neuroscience and psychology. The routine gathering of big data requires that we are well equipped with tools that allow us to conduct appropriate multivariate statistics. This project aims to produce an R package that allows the researcher to overcome little discussed limitations of traditional multivariate statistical analyses. 

Multivariate statistical analysis (e.g. MANOVA and repeated-measures ANOVA) typically follows a two stage procedure; an omnibus test of the global null hypothesis followed by post-hoc tests of specific effects. It is not well known that under certain circumstances, such as when the omnibus test is overpowered, that the type 1 error rate for this procedure is drastically inflated, sometimes to a type 1 error rate of 1! It is even less well known that this procedure can lead to an even lessor known type IV error, which is the incorrect interpretation of a correctly rejected hypothesis. This is caused when the follow-up contrasts are inadequate to test the question of interest, as can occur when testing simple effects.

It is possible to avoid these dragons by using an alternative procedure where all inferences are derived from simultaneous confidence intervals (SCIs) on contrasts of interests. The 'simultaneous' bit means that the same statistic contributes to both the omnibus and the contrast tests for significance, which controls the type 1 error rate. Even better, computing confidence intervals on contrasts of interests allows reseachers to move away from binary decision-making (is something significant or not?) to interpretations involving magnitude (how big is this effect likely to be at the population level?). 

One piece of software (PSY) can produce SCIs appropriate for both planned analyses (where contrasts are defined independently of the data) and for more flexible analyses where contrasts are defined on a post-hoc basis. However, this software is only available for use on windows and cannot be scripted into reproducible workflows. Our goal is to build an R package that implements the functions of PSY, and to make this method of statistical inference available to the masses!

<br>

## Getting started

Want to contribute to the project? Yay! Thank you :) To do so, here's how to get started:  

### Contributing code

We'll use a 'fork and pull request' workflow for code contributions. The first step is to make a fork of the repository. The steps are described [here](https://docs.github.com/en/get-started/exploring-projects-on-github/contributing-to-a-project).

### Getting familiar with Psy

Our Zotero library is [here](https://www.zotero.org/groups/5561818/psy2r/library). The papers you need to understand the logic of simultaneous confidence intervals and what the Psy software does are in the folder 'logic-of-simultaenous-procedures-and-psy'. Bird & Hadzi-Pavlovic (1983) provides the logic, and Bird (2002) provides the formulae used by Psy to compute confidence intervals.

### Download and use Psy on your machine

Download the Psy software from [here](https://www.unsw.edu.au/science/our-schools/psychology/our-research/research-tools/psy-statistical-program). If you don't have a Windows machine (which is a requirement of Psy), you can install [WINE](https://www.winehq.org/), which allows you to run Windows applications on your Linux or macOS. See [here](https://wiki.winehq.org/Wine_User%27s_Guide) for a user's guide on how to use WINE. The **Quick Start** section is particularly helpful.  

Once you have wine installed, you can perform a simple data analysis that will be our testing dataset/analysis, when comparing outputs between Psy and our R implementation.  

A good exercise is to load the 'BIRD.csv' data file from the [resources](https://github.com/kel-github/PSY2R/tree/main/resources) folder of this repository, and then compute the following contrasts:  

**Between Group**  
Groups 1 and 2 vs groups 3 and 4  
Group 1 vs  2  
Group 3 vs 4  

**Repeated-measures**
Spacing 20 vs 40  
Spacing 20 vs 60  
Quadratic trend  

You can check your output to those stored in the resources folder :)  

## Have done the above and ready to go?

Jump on the [project board](https://github.com/users/kel-github/projects/4) and find some tasks!







    




