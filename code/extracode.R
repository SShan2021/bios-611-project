#Extra Code 
#if we want the rand data to be in long form 
rand_long <- rbind(
  rand_raw %>% transmute(medicare_provider_number,
                         service_category="outpatient",
                         number_of_services=number_of_outpatient_services,
                         total_private_allowed_millions=total_private_allowed_amount_for_outpatient_services_millions,
                         simulated_medicare_allowed_amount_millions=simulated_medicare_allowed_amount_for_outpatient_services_millions,
                         relative_price=relative_price_for_outpatient_services,
                         standardized_price=standardized_price_per_outpatient_service),
  
  rand_raw %>% transmute(medicare_provider_number,
                         service_category="inpatient",
                         number_of_services=number_of_inpatient_stays,
                         total_private_allowed_millions=total_private_allowed_amount_for_inpatient_services_millions,
                         simulated_medicare_allowed_amount_millions=simulated_medicare_allowed_amount_for_inpatient_services_millions,
                         relative_price=relative_price_for_inpatient_services,
                         standardized_price=standardized_price_per_inpatient_stay),
  
  rand_raw %>% transmute(medicare_provider_number,
                         service_category="inpatient_and_outpatient",
                         number_of_services=NA,
                         total_private_allowed_millions=total_private_allowed_amount_for_inpatient_and_outpatient_services_millions,
                         simulated_medicare_allowed_amount_millions=simulated_medicare_allowed_amount_for_inpatient_and_outpatient_services_millions,
                         relative_price=relative_price_for_inpatient_and_outpatient_services,
                         standardized_price=NA),
  rand_raw %>% transmute(medicare_provider_number,
                         service_category="professional_inpatient_and_outpatient",
                         number_of_services=NA,
                         total_private_allowed_millions=NA,
                         simulated_medicare_allowed_amount_millions=simulated_medicare_allowed_amount_for_professional_inpatient_and_outpatient_services_millions,
                         relative_price=relative_price_for_professional_inpatient_and_outpatient_services,
                         standardized_price=NA), 
  
  rand_raw %>% transmute(medicare_provider_number,
                         service_category="inpatient_facility",
                         number_of_services=NA,
                         total_private_allowed_millions=NA,
                         simulated_medicare_allowed_amount_millions=NA,
                         relative_price=relative_price_for_inpatient_facility_services,
                         standardized_price=NA), 
  
  rand_raw %>% transmute(medicare_provider_number,
                         service_category="outpatient_facility",
                         number_of_services=NA,
                         total_private_allowed_millions=NA,
                         simulated_medicare_allowed_amount_millions=NA,
                         relative_price=relative_price_for_outpatient_facility_services,
                         standardized_price=NA), 
  
  rand_raw %>% transmute(medicare_provider_number,
                         service_category="facility_inpatient_and_outpatient_services",
                         number_of_services=NA,
                         total_private_allowed_millions=total_private_allowed_amount_for_facility_inpatient_and_outpatient_services_millions,
                         simulated_medicare_allowed_amount_millions=simulated_medicare_allowed_amount_for_facility_inpatient_and_outpatient_services_millions,
                         relative_price=relative_price_for_outpatient_facility_services,
                         standardized_price=NA)
) %>% arrange(medicare_provider_number)

#get the percentage of unique in every columns
for (col in columns) {
  n <- length(unique(nashp_raw[[col]]));
  print(sprintf("%s %f\n", col, n/nr))
}