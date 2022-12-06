.PHONY: clean

clean:
	rm -rf figures
	rm -rf derived_data
	rm -rf .created-dirs #can't add empty directory into git
											 #if you have empty directories for artifacts
											 #(you need to build empty directories for artifacts, the first time
											 #someone runs our code from git)
	rm -f HospitalValuesReport_SophieShan.pdf

.created-dirs:
	mkdir -p figures
	mkdir -p derived_data
	touch .created-dirs #add this for any directories to through source code
											#if you want to save to a location, gotta make sure
											#that location exists

derived_data/tidy_rand.csv: .created-dirs code/tidy_rand.R \
	source_data/Supplemental_Material.xlsx
		Rscript code/tidy_rand.R

figures/nashp_strangefiscalyear.pdf\
derived_data/tidy_nashp_2016_2018.csv: .created-dirs code/tidy_nashp.R \
	source_data/NASHP_HCT_Data_2022_April.xlsx
		Rscript code/tidy_nashp.R
		
figures/nashp_bed_size_plot.pdf\
figures/nashp_facility_type_plot.pdf\
figures/nashp_state_plot.pdf\
figures/nashp_hospital_ownership_type_plot.pdf\
derived_data/nashp_characteristics_2016.csv: .created-dirs code/characteristics_nashp.R \
	derived_data/tidy_nashp_2016_2018.csv
		Rscript code/characteristics_nashp.R
		
figures/rand_medicare_star_rating_plot.pdf\
derived_data/rand_characteristics.csv: .created-dirs code/characteristics_rand.R \
	derived_data/tidy_rand.csv
		Rscript code/characteristics_rand.R
		
derived_data/charity_uninsured_care_data.csv: .created-dirs \
	code/charity_uninsured_care.R \
	derived_data/tidy_nashp.R
		Rscript code/charity_uninsured_care.R
		
derived_data/merged_characteristics.csv\
figures/hospital_ownership_type_medicare_star_rating_plot.pdf\
figures/facility_type_medicare_star_rating_plot.pdf: .created-dirs \
	code/join_nashp_rand.R \
	derived_data/nashp_characteristics_2016.csv \
	derived_data/rand_characteristics.csv 
		Rscript code/join_nashp_rand.R
		
derived_data/merged_dummy.csv: .created-dirs \
	code/one_hot_encode.R \
	derived_data/merged_characteristics.csv
		Rscript code/one_hot_encode.R
		
figures/pca_variance_plot.pdf\
figures/k_means_silhouette_plot.pdf\
figures/k_means_plot.pdf\
figures/spectral_clustering_plot.pdf: .created-dirs \
	code/clustering.R \
	derived_data/merged_dummy.csv
		Rscript code/clustering.R
		
figures/k_means_plot_reduceddata.pdf\
figures/hospital_ownership_type_cluster_plot.pdf\
figures/medicare_star_rating_cluster_plot.pdf\
figures/facility_type_cluster_plot.pdf\
figures/bed_size_cluster_plot.pdf\
figures/uninsured_payer_mix_plot.pdf\
figures/charity_care_payer_mix_plot.pdf: .created-dirs \
	code/clustering_reduceddata.R \
	derived_data/merged_dummy.csv \
	derived_data/merged_characteristics.csv \
	derived_data/charity_uninsured_care_data.csv 
		Rscript code/clustering_reduceddata.R
		
HospitalValuesReport_SophieShan.pdf: HospitalValuesReport_SophieShan.Rmd \
	figures/nashp_strangefiscalyear.pdf \
	figures/nashp_bed_size_plot.pdf \
	figures/nashp_facility_type_plot.pdf \
	figures/nashp_state_plot.pdf \
	figures/nashp_hospital_ownership_type_plot.pdf \
	figures/rand_medicare_star_rating_plot.pdf \
	figures/hospital_ownership_type_medicare_star_rating_plot.pdf \
  figures/facility_type_medicare_star_rating_plot.pdf \
  figures/pca_variance_plot.pdf \
  figures/k_means_silhouette_plot.pdf \
  figures/k_means_plot.pdf \
  figures/spectral_clustering_plot.pdf \
  figures/k_means_plot_reduceddata.pdf \
  figures/hospital_ownership_type_cluster_plot.pdf \
  figures/medicare_star_rating_cluster_plot.pdf \
  figures/facility_type_cluster_plot.pdf \
  figures/bed_size_cluster_plot.pdf \
  figures/uninsured_payer_mix_plot.pdf \
  figures/charity_care_payer_mix_plot.pdf 
		Rscript -e "rmarkdown::render('HospitalValuesReport_SophieShan.Rmd', output_format='pdf_document')"