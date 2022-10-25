.PHONY: clean

clean:
	rm -rf figures
	rm -rf derived_data
	rm -rf .created-dirs #can't add empty directory into git
											 #if you have empty directories for artifacts
											 #(you need to build empty directories for artifacts, the first time
											 #someone runs our code from git)
	rm -f writeup.pdf

.created-dirs:
	mkdir -p figures
	mkdir -p derived_data
	touch .created-dirs #add this for any directories to through source code
											#if you want to save to a location, gotta make sure
											#that location exists

derived_data/rand_raw.csv\
derived_data/rand_metadata.csv: .created-dirs code/tidy_rand.R \
	source_data/Supplemental_Material.xlsx
		Rscript code/tidy_rand.R

figures/fiscal_year_2019.png: .created-dirs code/tidy_nashp.R \
	source_data/NASHP_HCT_Data_2022_April.xlsx
		Rscript code/tidy_nashp.R
		
HospitalOutcomesReport_SophieShan.pdf: HospitalOutcomesReport_SophieShan.Rmd \
 figures/fiscal_year_2019.png
	Rscript -e "rmarkdown::render('HospitalOutcomesReport_SophieShan.Rmd', output_format='pdf_document')"