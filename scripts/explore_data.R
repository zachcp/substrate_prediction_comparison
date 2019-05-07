
library(dplyr)
library(data.table)

## --------------------------------------------------------------------------------------------------------------
## Data Loading/Munging 

columns <- c("mibig", "AD_domain_idx", "AD_domain_id", "code_type", "prediction" )

as4 <- data.table::fread("output/domains_as4.txt", col.names = columns)
as5 <- data.table::fread("output/domains_as5.txt", col.names = columns)

# fix domain IDs
as5$AD_domain_id <-  gsub("AMP-binding\\.", "A", as5$AD_domain_id)


as4$code_type <-  gsub("Stachelhaus code", "stachelhaus_predictions_4", as4$code_type)
as4$code_type <-  gsub("NRPSpredictor3 SVM", "nrpspredictor3_svm_single", as4$code_type)

as5$code_type <-  gsub("stachelhaus_predictions", "stachelhaus_predictions_5", as5$code_type)
as5$code_type <-  gsub("single_amino_pred", "nrpspredictor2_single", as5$code_type)


#combined_data_frame <- rbindlist(list(as4,as5))
#combined_data_frame <- combined_data_frame %>%
#  filter(code_type %in% c("stachelhaus_predictions_4", "nrpspredictor3_svm_single", 
#                          "stachelhaus_predictions_5", "nrpspredictor2_single"))


as4 <- as4  %>% filter(
  code_type %in% c("stachelhaus_predictions_4", "nrpspredictor3_svm_single", 
                   "stachelhaus_predictions_5", "nrpspredictor2_single"))

as5 <- as5  %>% filter(
  code_type %in% c("stachelhaus_predictions_4", "nrpspredictor3_svm_single", 
                   "stachelhaus_predictions_5", "nrpspredictor2_single",
                   "physicochemical_class"))


as4_wide <-  data.table::dcast(as4, mibig+AD_domain_idx+AD_domain_id~code_type)
as5_wide <-  data.table::dcast(as5, mibig+AD_domain_idx+AD_domain_id~code_type)



#all_data <- dplyr::full_join(as4_wide, as5_wide, by=c("mibig", "AD_domain_idx", "AD_domain_id")) %>% 
all_data <- dplyr::full_join(as4_wide, as5_wide, by=c("mibig", "AD_domain_id")) %>% 
  group_by(mibig) %>% 
  add_count() %>%
  ungroup() %>%
  arrange(mibig, AD_domain_id )



all_data$compare_stach1 <- as.logical(purrr::map2(all_data$stachelhaus_predictions_4, all_data$stachelhaus_predictions_5,
             ~.x == .y))

all_data$compare_stach2 <- as.logical(purrr::map2(all_data$stachelhaus_predictions_4, all_data$stachelhaus_predictions_5,
                                    ~grepl(.x, .y)))

all_data$compare_nrpspred <- as.logical(purrr::map2(all_data$nrpspredictor2_single, all_data$nrpspredictor3_svm_single,
                                                  ~.x == .y))


table(all_data$compare_stach1) # 897/1903 T/F
table(all_data$compare_stach2) # 1598/1320 T/F
table(all_data$compare_nrpspred) # 2249/551 T/F


## Look at the Stachelhaus Calls first
## 
## of the non no-calls, what are the other problems?
not_no_call <- all_data %>% filter(compare_stach2 == FALSE, stachelhaus_predictions_4 != "no_call")

## lots of phenylalanine
sort(table(not_no_call$stachelhaus_predictions_5))

not_no_call  %>% filter(stachelhaus_predictions_5  == "phe")
  

not_no_call  %>% 
  filter(stachelhaus_predictions_5  == "phe") %>% 
  .$stachelhaus_predictions_4 %>%
  table() %>%
  sort()


## 
## Check the NRPSPedictor Calls
## 
all_data %>% filter(compare_nrpspred == FALSE) %>% .$nrpspredictor2_single %>% table() %>% sort() # 324 NA on NRPS-Predictor2: order of magnitude more that others
all_data %>% filter(compare_nrpspred == FALSE) %>% .$physicochemical_class %>% table() %>% sort() # 275 Hydrophobic-aliphatic; 80 hydophobic-aromatic; 115 hydrophilic

# AS5 - mnay fewer types of sequence
all_data %>% filter(compare_nrpspred == FALSE) %>% .$nrpspredictor3_svm_single %>% table() %>% sort() # 164 NAs. Then 95 leucine.

names(all_data)

all_data %>% filter(grepl("lyse", stachelhaus_predictions_5)) %>%
  ggplot(aes(x=stachelhaus_predictions_4)) + geom_histogram(stat="count") +
  ggtitle("What is AS4 Stachelhaus code when AS5 is d-lyserg")



all_data %>% filter(grepl("pip", stachelhaus_predictions_4)) %>%
  ggplot(aes(x=stachelhaus_predictions_5)) + geom_histogram(stat="count") +
  ggtitle("What is AS5 Stachelhaus code when AS4 is pip")
