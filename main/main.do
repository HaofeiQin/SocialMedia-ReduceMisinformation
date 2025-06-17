*! Project: Effect of Social Media on GDP Inflation
*! Description: This do-file generates Table 1, Table 2 and Extended Data Table 3
clear all
set more off

* --- Set Working Directory ---
* IMPORTANT: Change this path to where your 'panel_data_gdp.csv' file is located
* --- Load Data ---
insheet using "panel_data_gdp.csv", clear

* --- Generate Dependent Variables (Log Transformed) ---
gen log_freq_city_gdpcontent = log(freq_city_gdpcontent + 1)
gen log_freq_city_gdpdata    = log(freq_city_gdpdata + 1)
gen log_freq_city_gdpnodata  = log(freq_city_gdpnodata + 1)

* --- Generate Instrumental Variables (Mean by Province and Year) ---
bysort province year: egen iv_freq_city_gdpcontent = mean(freq_city_gdpcontent)
bysort province year: egen iv_freq_city_gdpdata    = mean(freq_city_gdpdata)
bysort province year: egen iv_freq_city_gdpnodata  = mean(freq_city_gdpnodata)

* --- Generate Log-Transformed Instrumental Variables ---
gen log_iv_freq_city_gdpcontent = log(iv_freq_city_gdpcontent + 1)
gen log_iv_freq_city_gdpdata    = log(iv_freq_city_gdpdata + 1)
gen log_iv_freq_city_gdpnodata  = log(iv_freq_city_gdpnodata + 1)

* --- Handle Missing Values and Outliers ---
* Note: Your original 'drop if' statement implies dropping based on missingness
* of certain key variables.
* drop 2017, add a separate `drop if year == 2017` line to create Table A1.1, Table A1.2 and Table A1.4.
drop if missing(gdp_ratio) | missing(if_officialwechat) | missing(population) | missing(area) | missing(populationdensity) | missing(gdp_growthrate) | missing(gdp_percapita) | missing(proportion_secondaryindustry) | missing(proportion_thirdindustry) | missing(retailassumption) | missing(leader_change)

* --- Summarize Key Variables, Extended Data Table 2 ---
summarize gdp_ratio if_officialwechat population area populationdensity gdp_growthrate gdp_percapita proportion_secondaryindustry proportion_thirdindustry retailassumption leader_change
summarize log_freq_city_gdpcontent log_freq_city_gdpdata log_freq_city_gdpnodata

* --- Generate Moderator Variables ---
gen political_per = politescore / population
egen political_per_z = std(political_per)
egen log_freq_city_gdpcontent_z = std(log_freq_city_gdpcontent)
egen log_iv_freq_city_gdpcontent_z = std(log_iv_freq_city_gdpcontent)

* --- Generate Interaction Terms ---
gen interaction_adoption    = political_per_z * if_officialwechat
gen interaction_gdpcontent  = political_per_z * log_freq_city_gdpcontent_z
gen iv_interaction_adoption = political_per_z * iv_if_officialwechat
gen iv_interaction_gdpcontent = political_per_z * log_iv_freq_city_gdpcontent_z

* --- Summarize Moderator Variable ---
summarize political_per_z

* --- ANOVA (One-way) ---
anova political_per_z city_code

* --- Declare Panel Data Structure ---
xtset city_code year

* --- Regression Models ---
* --- Table 1: Effect of Social Media on Government Data Manipulations---
* Column 1
xtreg gdp_ratio if_officialwechat population area populationdensity gdp_growthrate gdp_percapita proportion_secondaryindustry proportion_thirdindustry retailassumption leader_change i.year, fe cluster(city_code)

* Column 2
xtivreg gdp_ratio (if_officialwechat = iv_if_officialwechat) population area populationdensity gdp_growthrate gdp_percapita proportion_secondaryindustry proportion_thirdindustry retailassumption leader_change i.year, fe vce(cluster city_code) first

* Column 3
xtreg gdp_ratio log_freq_city_gdpcontent population area populationdensity gdp_growthrate gdp_percapita proportion_secondaryindustry proportion_thirdindustry retailassumption leader_change i.year, fe cluster(city_code)

* Column 4
xtivreg gdp_ratio (log_freq_city_gdpcontent = log_iv_freq_city_gdpcontent) population area populationdensity gdp_growthrate gdp_percapita proportion_secondaryindustry proportion_thirdindustry retailassumption leader_change i.year, fe vce(cluster city_code) first

* Column 5
xtreg gdp_ratio log_freq_city_gdpdata population area populationdensity gdp_growthrate gdp_percapita proportion_secondaryindustry proportion_thirdindustry retailassumption leader_change i.year, fe cluster(city_code)

* Column 6
xtivreg gdp_ratio (log_freq_city_gdpdata = log_iv_freq_city_gdpdata) population area populationdensity gdp_growthrate gdp_percapita proportion_secondaryindustry proportion_thirdindustry retailassumption leader_change i.year, fe vce(cluster city_code) first

* Column 7
xtreg gdp_ratio log_freq_city_gdpdata log_freq_city_gdpnodata population area populationdensity gdp_growthrate gdp_percapita proportion_secondaryindustry proportion_thirdindustry retailassumption leader_change i.year, fe cluster(city_code)

* Column 8
xtivreg gdp_ratio (log_freq_city_gdpdata log_freq_city_gdpnodata = log_iv_freq_city_gdpdata log_iv_freq_city_gdpnodata) population area populationdensity gdp_growthrate gdp_percapita proportion_secondaryindustry proportion_thirdindustry retailassumption leader_change i.year, fe vce(cluster city_code) first

* --- Table 2: Moderating Effect of Public Scrutiny Level in Political Matters---
* Column 1
xtreg gdp_ratio if_officialwechat political_per_z interaction_adoption population area populationdensity gdp_growthrate gdp_percapita proportion_secondaryindustry proportion_thirdindustry  retailassumption leader_change i.year,fe cluster(city_code)

* Column 2
xtivreg gdp_ratio ( if_officialwechat  interaction_adoption = iv_if_officialwechat  iv_interaction_adoption) political_per_z population area populationdensity gdp_growthrate gdp_percapita proportion_secondaryindustry proportion_thirdindustry retailassumption leader_change i.year,fe vce(cluster city_code) first

* Column 3
xtreg gdp_ratio log_freq_city_gdpcontent_z political_per_z interaction_gdpcontent population area populationdensity gdp_growthrate gdp_percapita proportion_secondaryindustry proportion_thirdindustry  retailassumption leader_change i.year,fe cluster(city_code) 

* Column 4
xtivreg gdp_ratio  ( log_freq_city_gdpcontent_z interaction_gdpcontent= log_iv_freq_city_gdpcontent_z iv_interaction_gdpcontent)  political_per_z  population area populationdensity gdp_growthrate gdp_percapita proportion_secondaryindustry proportion_thirdindustry retailassumption leader_change  i.year,fe vce(cluster city_code) first
 
* --- Extended Data Table 3: Alternative Measure for GDP Manipulations ---
egen gdp_rank = rank(gdp_real), by(year) field
egen nightlight_rank = rank(nightlight), by(year) field
gen rank_diff=nightlight_rank-gdp_rank

* Column 1
xtreg rank_diff if_officialwechat  population area populationdensity gdp_growthrate gdp_percapita proportion_secondaryindustry proportion_thirdindustry retailassumption leader_change i.year,fe cluster(city_code)

* Column 2
xtivreg rank_diff ( if_officialwechat= iv_if_officialwechat)  population area populationdensity gdp_growthrate gdp_percapita proportion_secondaryindustry proportion_thirdindustry  retailassumption leader_change i.year,fe vce(cluster city_code) first

* Column 3
xtreg rank_diff log_freq_city_gdpcontent  population area populationdensity gdp_growthrate gdp_percapita proportion_secondaryindustry proportion_thirdindustry  retailassumption leader_change i.year,fe cluster(city_code) 

* Column 4
xtivreg rank_diff  ( log_freq_city_gdpcontent=log_iv_freq_city_gdpcontent )  population area populationdensity gdp_growthrate gdp_percapita proportion_secondaryindustry proportion_thirdindustry  retailassumption leader_change  i.year,fe vce(cluster city_code) first

* Column 5
xtreg rank_diff log_freq_city_gdpdata  population area populationdensity gdp_growthrate gdp_percapita proportion_secondaryindustry proportion_thirdindustry  retailassumption leader_change i.year,fe cluster(city_code) 

* Column 6
xtivreg rank_diff  ( log_freq_city_gdpdata=log_iv_freq_city_gdpdata )  population area populationdensity gdp_growthrate gdp_percapita proportion_secondaryindustry proportion_thirdindustry  retailassumption leader_change  i.year,fe vce(cluster city_code) first

* Column 7
xtreg rank_diff log_freq_city_gdpdata log_freq_city_gdpnodata population area populationdensity gdp_growthrate gdp_percapita  proportion_secondaryindustry proportion_thirdindustry  retailassumption leader_change i.year,fe cluster(city_code)

* Column 8
xtivreg rank_diff  ( log_freq_city_gdpdata log_freq_city_gdpnodata=log_iv_freq_city_gdpdata log_iv_freq_city_gdpnodata )  population area populationdensity gdp_growthrate gdp_percapita proportion_secondaryindustry proportion_thirdindustry  retailassumption leader_change  i.year,fe vce(cluster city_code) first


