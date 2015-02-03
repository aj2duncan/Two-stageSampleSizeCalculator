---
title: "Two-Stage Sample Size Calculator"
author: "Andrew Duncan"
date: ""
output: html_document
---

<div style='text-align:justify'>
<div style='text-align:center'>
<a target="_blank"><img src="CattleHeader.png"></a>
</div>


### Two-Stage Sample Size Calculator

This calculator is intended to help design surveys to estimate Herd Level Prevalence when the individual test is imperfect (1).

* The 1^st stage is to try different herd-level sensitivity and specificity values. These determine the number of animals to test to achieve the desired test performance (at herd level) and the calculator will find these.
* The 2^nd stage, given a particular herd-level sensitivity and specificity, and given your desired confidence and tolerance around the herd-level prevalence, is to calculate the necessary number of herds. The calculator will do this for you.

This calculator runs both of these stages together to allow you to see the effect of adjusting parameters on the sampling at __both__ stages. You may realise that there is no “single answer” because there is usually a trade-off between the number of animals to test and the number of herds.

We hope the value of the calculator is to allow the user to “experiment” with different values in order to focus in on their own preferred design whilst recognising the impact of those values on the predicted performance of the survey.

### Using the Calculator

The calculator is controlled using the inputs on the left-hand side of the __Graphical Output__ page. The following parameters can be adjusted

* Test Sensitivity
* Test Specificity
* Herd Specificity
* Confidence of Result
* An a priori estimate of the between herd prevalence (aka ‘herd level prevalence’) for the disease
* Within Herd Prevalence of the Disease
* Herd Size - where herd sizes vary substantially then the simplest approach is to seek to achieve the same minimum herd sensitivity and specificity for each size class of herd. That is best done directly using <a target="_blank" href="http://www.ausvet.com.au/content.php?page=software#freecalc">Freecalc</a>.

The results are expressed as the number of animals needing tested plotted against the number of herds. A range of values for tolerance and herd sensitivity are given. For more information, hover over the individual points.

### References

[1]:[Humphry et. al., 2004, A Practical Approach to calculate sample size for her prevalence surveys, Prev. Vet Med., 65, 173-188.](http://www.sciencedirect.com/science/article/pii/S0167587704001412)

------

This two-stage sample size calculator was built by <a target="_blank" href="http://www.aj2duncan.com">Andrew Duncan</a>. If you have any comments or suggestions about improvements that can be made please get in [touch](<mailto:andrew.duncan.ic@uhi.ac.uk>). If you are interested in developing this further, the code is currently hosted on <a target="_blank" href="https://github.com/aj2duncan/Two-stageSampleSizeCalculator">Github</a>.


<div style='text-align:center'>
<a target="_blank" href="http:///www.sruc.ac.uk"><img src="SRUC-logo.png"></a>
<a target="_blank" href="http://www.inverness.uhi.ac.uk/"><img src="IC-logo.jpg"></a> 
</div>

------

This was funded by the <a target="_blank" href="http://www.scotland.gov.uk/">Scottish Government</a> within the RESAS WP6.5 knowledge transfer programme.
<div style='text-align:center'>
<a target="_blank" href="http://www.scotland.gov.uk/"><img src="SG-logo.png"></a>
</div>
</div> 
