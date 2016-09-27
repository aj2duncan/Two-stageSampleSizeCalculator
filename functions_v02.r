#function to calculate cutpoint calculation
calculate_cutpoint = function(n,Sp,beta){
  cutpoint = 0
  P_disfree = 0
  cutpoint_success = 0
  ##find cutpoint
  while(cutpoint <= n){
    P_disfree = P_disfree + 1*dbinom(cutpoint,n,1-Sp)
    if(P_disfree>=1-beta){ ##having the eps in is just making this difficult - as soon as it is bigger you are happier regardless of how much bigger
#      print(c(n,cutpoint,P_disfree))
      return(list(cutpoint,P_disfree)) #returning P_disfree as this is calc herd specificity
    }else if (cutpoint==n){
      return(list(-1,0))
    }else{
      cutpoint = cutpoint + 1
    }
  }
}

#function for doing the summation over j and multiplying by P(y)
P_in = function(x,y,n,Se,Sp,d,N){
  j = seq(0,min(x,y))
  P = sum(dbinom(j,y,Se)*dbinom(x-j,n-y,1-Sp))
  return(dhyper(y,d,N-d,n)*P)
}

#function to calculate sample size (number of animals)
num_anim = function(Se,Sp,prev,N,alpha,beta){
#eps = 0.0001 #not actually used
d = ceiling(prev*N)

#check whether cut-point and sample size satisfy alpha
n = 1
success = 0
P_inside = 0
P_outside = 0
while(success==0 && n <= N){
  P = 0
  cutpoint_results = calculate_cutpoint(n,Sp,beta)
  cutpoint = cutpoint_results[[1]]
  calc_herd_spec = cutpoint_results[[2]]
  if(cutpoint!=-1){
  for(x in c(0:cutpoint)){
    for(y in c(0:min(n,d))){
      P_inside = P_in(x,y,n,Se,Sp,d,N)
      P_outside = P_outside + P_inside
    } #finish y
    P = P + P_outside
    P_outside = 0
  } #finish x 
  if(P <= alpha){ #as we know this is the smallest n, started at 0, we don't need eps
#    print("Success")
    sample_size = n
    sample_cutpoint = cutpoint
    success = 1
  }else if(n==N){
    sample_size = -1
    sample_cutpoint = -1
    n = n + 1
  }else{
#    print(c(n,cutpoint))
    n = n + 1
  }
  }else{ #if we got a null result from cutpoint then try the next size up
    n = n + 1
  }
} #finish while
calc_herd_sens = 1 - P #returning calculated herd sensitivity
return(c(sample_size,sample_cutpoint,calc_herd_sens,calc_herd_spec))
}


#function calculate number of herds
num_herds = function(C,L,HSENS,HSPEC,HTP){
  Z = qnorm(1-(1-C)/2)
  Numerator = (HSENS*HTP+(1-HSPEC)*(1-HTP))*(1-HSENS*HTP-(1-HSPEC)*(1-HTP))
  Denominator = (HSENS+HSPEC-1)^2
  HN = ceiling((Z/L)^2 * (Numerator/Denominator))
  return(HN)
}


#function to return blank dataframes
return_blanks = function(){
  Results_without_errors = as.data.frame(cbind(Test.Sensitivity=numeric(0),
                                               Test.Specificity=numeric(0),
                                               Herd.Size=numeric(0),
                                               Prevalence=numeric(0),
                                               Herd.Prevalence=numeric(0),
                                               Confidence=numeric(0),
                                               Tolerance=numeric(0),
                                               Herd.Sensitivity=numeric(0),
                                               Herd.Specificity=numeric(0),
                                               Calc.Herd.Sensitivity=numeric(0),
                                               Calc.Herd.Specificity=numeric(0),
                                               Number.Herds=numeric(0),
                                               Number.Animals=numeric(0),
                                               Cutpoint=numeric(0)))
  Results_with_errors = as.data.frame(cbind(Test.Sensitivity=numeric(0),
                                            Test.Specificity=numeric(0),
                                            Herd.Size=numeric(0),
                                            Prevalence=numeric(0),
                                            Herd.Prevalence=numeric(0),
                                            Confidence=numeric(0),
                                            Tolerance=numeric(0),
                                            Herd.Sensitivity=numeric(0),
                                            Herd.Specificity=numeric(0),
                                            Calc.Herd.Sensitivity=numeric(0),
                                            Calc.Herd.Specificity=numeric(0),
                                            Number.Herds=numeric(0),
                                            Number.Animals=numeric(0),
                                            Cutpoint=numeric(0)))
  return(list(Results_without_errors,Results_with_errors))
}





