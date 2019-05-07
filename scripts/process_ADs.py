#
#
#
#
#


## -------------------------------------------------------------------------------------------
## AS4 Adenylation Domains

import glob
import json
import os
from Bio import SeqIO

gbks    = glob.glob("results/antismash4/*/*.final.gbk")
outfile = "domains_as4.txt"

with open(outfile, "w") as f:
    for gbk in gbks:

        MIBIGID = os.path.basename(gbk).split('.')[0]
        print(MIBIGID)

        gbk_handle = open(gbk, 'r')
        for record in SeqIO.parse(gbk_handle, 'gb'):
            domains = [feat for feat in record.features if feat.type=="aSDomain"]
            ADs     = [d for d in domains if d.qualifiers['domain'][0] == "AMP-binding"]
            print(len(domains), len(ADs))

            for idx, AD in enumerate(ADs):

                DOMAINID = AD.qualifiers["asDomain_id"][0]
                specificities =  AD.qualifiers['specificity']
                for spec in specificities:
                        print(spec)
                        try:
                            code, val = spec.split(":")
                            code = code.strip()
                            val = val.strip()
                            f.write("{}\t{:02d}\t{}\t{}\t{}\n".format(MIBIGID, idx, DOMAINID, code, val))
                        except:
                            pass

        gbk_handle.close()



## -------------------------------------------------------------------------------------------
## AS5 Adenylation Domains


jsons    = glob.glob("results/antismash5/*/*.json")
outfile  = "domains_as5.txt"

with open(outfile, "w") as f:
    for js in jsons:

        json_handle = open(js, 'r')
        record_dict = json.load(json_handle)

        records = record_dict['records']


        for record in records:
            MIBIGID = record['id'].split(".")[0]

            # domains = [feat for feat in record['features'] if feat['type'] == "aSDomain"]
            # ADs     = [d for d in domains if d['qualifiers']['aSDomain'][0] == "AMP-binding"]
            # AD_labels  = [d['qualifiers']['domain_id'] for d in ADs]
            # AD_labels  = [d['qualifiers']['label'] for d in ADs]
            # locus_tags = set([d['qualifiers']['locus_tag'][0] for d in ADs])

            if not 'antismash.modules.nrps_pks' in record['modules'].keys():
                break
            print(record['modules'].keys())
            domain_results = record['modules']['antismash.modules.nrps_pks']['domain_predictions']
            domains =  sorted(domain_results.keys())
            AD_domains = [d for d in domains if "AMP" in d]


            for idx, AD_domain in enumerate(AD_domains):

                DOMAINID = AD_domain

                domain_data = domain_results[AD_domain]['NRPSPredictor2']

                for code, val in domain_data.items():

                    if isinstance(val, list):
                        val = "|".join(val)

                    try:
                        f.write("{}\t{:02d}\t{}\t{}\t{}\n".format(MIBIGID, idx, DOMAINID, code, val))
                    except:
                        pass


        json_handle.close()

