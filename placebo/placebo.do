*! Project: Placebo Test: Pollution Emission Data Manipulation
*! Description: This do-file generates Table 3
clear all
set more off

* --- Set Working Directory ---
* IMPORTANT: Change this path to where your 'panel_data_so2.csv' file is located
* --- Load Data ---
insheet using "C:/Govern Index/new result2/panel_data_so2_new.csv", clear
gen so2_ratio=log( officialso2 )/log( satelliteso2*area*1000/625 )

* --- Generate Dependent and Instrumental Variables (Log Transformed) ---
gen log_freq_city_envircontent=log( freq_city_envircontent +1)
gen log_iv_freq_city_envircontent=log( iv_freq_city_envircontent+1 )

gen log_freq_city_gdpcontent = log(freq_city_gdpcontent + 1)
gen log_freq_city_gdpdata    = log(freq_city_gdpdata + 1)

bysort province year: egen iv_freq_city_gdpcontent = mean(freq_city_gdpcontent)
bysort province year: egen iv_freq_city_gdpdata    = mean(freq_city_gdpdata)
gen log_iv_freq_city_gdpcontent = log(iv_freq_city_gdpcontent + 1)
gen log_iv_freq_city_gdpdata    = log(iv_freq_city_gdpdata + 1)

* --- Handle Missing Values and Outliers ---
* Note: Your original 'drop if' statement implies dropping based on missingness
* of certain key variables.
* drop 2017, add a separate `drop if year == 2017` line to create Table A1.4.
drop if missing(so2_ratio) | missing(if_officialwechat)| missing(population) |missing(populationdensity) |  missing(gdp_percapita) | missing(proportion_secondaryindustry) | missing(proportion_thirdindustry) | missing(retailassumption) | missing(leader_change)|missing(mayor_tenure )|missing(municipal_tenure )

summarize so2_ratio log_freq_city_envircontent

* --- Declare Panel Data Structure ---
xtset city_code year

* --- Regression Models ---
* --- Table 3: Placebo Test using SO2 Pollution Emissions Manipulation ---
* Column 1
xtreg so2_ratio if_officialwechat population populationdensity gdp_percapita  proportion_secondaryindustry proportion_thirdindustry retailassumption leader_change  mayor_tenure municipal_tenure i.year,fe cluster(city_code)

* Column 2
xtivreg so2_ratio ( if_officialwechat= iv_if_officialwechat) population populationdensity gdp_percapita  proportion_secondaryindustry proportion_thirdindustry retailassumption leader_change  mayor_tenure municipal_tenure i.year,fe vce(cluster city_code) first

* Column 3
xtreg so2_ratio log_freq_city_envircontent  population populationdensity gdp_percapita  proportion_secondaryindustry proportion_thirdindustry retailassumption leader_change  mayor_tenure municipal_tenure i.year,fe cluster(city_code) 

* Column 4
xtivreg so2_ratio  ( log_freq_city_envircontent= log_iv_freq_city_envircontent )   population populationdensity gdp_percapita  proportion_secondaryindustry proportion_thirdindustry retailassumption leader_change  mayor_tenure municipal_tenure i.year,fe  vce(cluster city_code) first

* Column 5
xtreg so2_ratio log_freq_city_gdpcontent population populationdensity  gdp_percapita proportion_secondaryindustry proportion_thirdindustry retailassumption leader_change  mayor_tenure municipal_tenure  i.year, fe cluster(city_code)

* Column 6
xtivreg so2_ratio (log_freq_city_gdpcontent = log_iv_freq_city_gdpcontent) population populationdensity  gdp_percapita proportion_secondaryindustry proportion_thirdindustry retailassumption leader_change  mayor_tenure municipal_tenure  i.year, fe vce(cluster city_code) first

* Column 7
xtreg so2_ratio log_freq_city_gdpdata population populationdensity  gdp_percapita proportion_secondaryindustry proportion_thirdindustry retailassumption leader_change  mayor_tenure municipal_tenure  i.year, fe cluster(city_code)

* Column 8
xtivreg so2_ratio (log_freq_city_gdpdata = log_iv_freq_city_gdpdata) population populationdensity  gdp_percapita proportion_secondaryindustry proportion_thirdindustry retailassumption leader_change  mayor_tenure municipal_tenure  i.year, fe vce(cluster city_code) first

