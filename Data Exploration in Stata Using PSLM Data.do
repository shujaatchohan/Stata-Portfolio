clear 

use "D:\STATA\stata_data_pslm_2019_20\stata data\roster.dta" 

codebook province

// DISTRICTS WITH HIGHEST AND LOWEST AVG AGE BY PROVINCE

tabstat age if province ==1 , stat (mean) by(district)
tabstat age if province ==2 , stat (mean) by(district)
tabstat age if province ==3 , stat (mean) by(district)
tabstat age if province ==4 , stat (mean) by(district)

** In KPK District Haripur has the highest AvgAge of 27.14 where Bajor has lowest AvgAge of 19.46
** In Punjab District Chakwal has the highest AvgAge of 29.39 where Rajanpur has lowest AvgAge of 21.85
** In Sindh  District Karachi South has the highest AvgAge of 28.36 where Kashmore has lowest AvgAge of 19.27
** In Balochistan District Kohlu has the highest AvgAge of 32.52 where Sohbatpur has lowest AvgAge of 17.61



// DISTRICTS WITH HIGHEST MEDIAN AGE BY PROVINCE

tabstat age if province ==1 , stat (median) by(district)
tabstat age if province ==2 , stat (median) by(district)
tabstat age if province ==3 , stat (median) by(district)
tabstat age if province ==4 , stat (median) by(district)

** In KPK District Bajor has lowest Median Age of 13
** In Punjab District Rajanpur has lowest Median Age of 16
** In Sindh District Kashmore has lowest Median of 15
** In Balochistan District Dera Bugti, Kharan, Khuzdar and Sohbat has lowest Median Age of 14
