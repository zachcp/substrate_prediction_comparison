########### constants ###########
MIBIGVERSION = 1.4
GBKDIR       = gbks
JSONDIR      = json
FASTADIR     = fasta
AS5DATA      = /mnt/DataDrive1/antismash_data/


########### download the data ###########
$(GBKDIR)/BGC0001833.gbk:
	wget  https://mibig.secondarymetabolites.org/mibig_gbk_$(MIBIGVERSION).tar.gz
	tar -xvf  mibig_gbk_$(MIBIGVERSION).tar.gz
	mkdir -p $(GBKDIR)
	mv *gbk $(GBKDIR)

$(JSONDIR)/BGC0001833.json:
	wget https://mibig.secondarymetabolites.org/mibig_json_$(MIBIGVERSION).tar.gz
	tar -xvf  mibig_json_$(MIBIGVERSION).tar.gz
	mkdir -p $(JSONDIR)
	mv *json $(JSONDIR)

$(FASTADIR)/BGC0001833.fasta: $(GBKDIR)/BGC0001833.gbk
	mkdir -p $(FASTADIR)
	cd $(FASTADIR) && parallel "seqmagick convert {} {/.}.fasta" ::: ../$(GBKDIR)/*.gbk

get_gbks:   $(GBKDIR)/BGC0001833.gbk
get_json:   $(JSONDIR)/BGC0001833.json
make_fasta: $(FASTADIR)/BGC0001833.fasta

# note that Antismash5 requires separate install of the databases. this needs to be done outside of docker
# requires conda ev for making sure prerequisites are installed
get_antismash_data:
	docker run -it --entrypoint download-antismash-databases antismash/antismash-dev --database-dir $(AS5DATA)

update_images:
	docker pull antismash/standalone:4.0.2
	docker pull antismash/antismash-dev:latest

run_AS4:
	mkdir -p results/antismash4
	parallel -j 4 "bash scripts/run_smash4.sh {} results/antismash4 " ::: ls fasta/*.fasta

run_AS5:
	mkdir -p results/antismash5
	parallel -j 4 "bash scripts/run_smash4.sh {} results/antismash5 --genefinding-tool prodigal" ::: ls fasta/*.fasta

output/domains_as4.txt:
	python process_ADs.py


########### build rules ###########
download: get_gbks get_json make_fasta get_antismash_data update_images

runsmash: run_AS4 run_AS5  

clean:
	rm *.gz

