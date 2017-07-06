# Align linked reads to the white spruce organelles
# Written by Shaun Jackman @sjackman

# Picea glauca plastid
pglaucacp=KT634228

# Picea glauca mitochondrion
pglaucamt=LKAM01

# Number of threads
t=64

# Report run time and memory usage
export SHELL=zsh -opipefail
export REPORTTIME=1
export TIMEFMT=time user=%U system=%S elapsed=%E cpu=%P memory=%M job=%J

.DELETE_ON_ERROR:
.SECONDARY:
.PHONY: all data pglaucacpmt psitchensiscpmt_6 psitchensisnuc

all: data pglaucacpmt psitchensiscpmt_6 psitchensisnuc

data: \
	data/HG3VHALXX_4/files.sha256 \
	data/HG3VHALXX_5/files.sha256 \
	data/H352FALXX_5/files.sha256

pglaucacpmt:
	$(MAKE) ref=$@ \
		pglaucacpmt.HG3VHALXX_4.longranger.wgs.bam \
		pglaucacpmt.HG3VHALXX_5.longranger.wgs.bam \
		pglaucacpmt.H352FALXX_5.longranger.wgs.bam \
		pglaucacpmt.H352FALXX_5.as100.nm5.bam.mi.bx.molecule.summary.html

psitchensiscpmt_6:
	$(MAKE) ref=$@ \
		psitchensiscpmt_6.HYN5VCCXX_4.as100.nm5.bam.mi.bx.molecule.summary.html

psitchensisnuc:
	$(MAKE) ref=$@ \
		psitchensisnuc.HYN5VCCXX_4.as100.nm5.bam.mi.bx.molecule.summary.html

# Calculate the SHA-256 of the data.
%/files.sha256: %/files
	gsha256sum `<$<` >$@

# Entrez Direct

# Fetch data from NCBI.
$(pglaucacp).fa: %.fa:
	efetch -db nuccore -id $* -format fasta | seqtk seq | sed 's/^>/>$* /' >$@

# Download the white spruce mitochondrion FASTA.
LKAM01.fa:
	curl ftp://ftp.ncbi.nlm.nih.gov/sra/wgs_aux/LK/AM/LKAM01/LKAM01.1.fsa_nt.gz | gunzip -c | seqtk seq \
		| awk '/^>/ { $$0 = ">" ++i " " substr($$0, 2) } { print }' >$@

# Make a reference genome of the white spruce organelles.
$(ref).fa:
	cat $(pglaucacp).fa $(pglaucamt).fa >$@

# BWA

# Index the target genome.
%.fa.bwt: %.fa
	bwa index $<

# Align paired-end reads to the target genome and sort.
$(ref).%.bam: %.fq.gz $(ref).fa.bwt
	bwa mem -t$t -pC $(ref).fa $< | samtools view -h -F4 | samtools sort -@$t -o $@

# samtools

# Index a FASTA file.
%.fa.fai: %.fa
	samtools faidx $<

# Index a BAM file.
%.bam.bai: %.bam
	samtools index $<

# Remove alignments with an alignment score below a threshold.
as=100
%.as$(as).bam: %.bam
	samtools view -h -F4 $< | gawk -F'\t' ' \
			/^@/ { print; next } \
			{ as = 0 } \
			match($$0, "AS:.:([^\t]*)", x) { as = x[1] } \
			as >= $(as)' \
		| samtools view -@$t -b -o $@

# Select alignments with number of mismatches below a threshold.
nm=5
%.nm$(nm).bam: %.bam
	samtools view -h -F4 $< \
		| gawk -F'\t' ' \
			/^@/ { print; next } \
			{ nm = 999999999 } \
			match($$0, "NM:i:([^\t]*)", x) { nm = x[1] } \
			nm < $(nm)' \
		| samtools view -@$t -b -o $@

# Barcodes

# Extract the alignment score, number of mismatches, barcode and molecule identifier.
%.bam.bx.tsv: %.bam
	samtools view -F4 $< | gawk -F'\t' ' \
		BEGIN { print "Flags\tRname\tPos\tMapq\tAS\tNM\tBX\tMI" } \
		{ as = bx = mi = nm = "NA" } \
		match($$0, "AS:.:([^\t]*)", x) { as = x[1] } \
		match($$0, "NM:.:([^\t]*)", x) { nm = x[1] } \
		match($$0, "BX:Z:([^\t]*)", x) { bx = x[1] } \
		match($$0, "MI:i:([^\t]*)", x) { mi = x[1] } \
		{ print $$2 "\t" $$3 "\t" $$4 "\t" $$5 "\t" as "\t" nm "\t" bx "\t" mi }' >$@

# Group reads into molecules and add molecule identifiers.
%.bam.mi.bx.tsv: %.bam.bx.tsv
	./mi.r $< $@

# Create a TSV file of molecule extents.
%.bx.molecule.tsv: %.bx.tsv
	mlr --tsvlite \
		then stats1 -g BX,MI,Rname -a count,min,p50,max -f Pos,Mapq,AS,NM \
		then rename Pos_min,Start,Pos_max,End,Mapq_p50,Mapq_median,AS_p50,AS_median,NM_p50,NM_median,Pos_count,Reads \
		then put '$$Size = $$End - $$Start' \
		then cut -o -f Rname,Start,End,Size,BX,MI,Reads,Mapq_median,AS_median,NM_median \
		then filter '$$Reads >= 4' \
		$< >$@

# Create a BED file of molecule extents.
%.bx.molecule.bed: %.bx.molecule.tsv
	mlr --tsvlite --headerless-csv-output \
		put '$$Start = $$Start - 1; $$End = $$End - 1' \
		then put '$$Name = "Reads=" . $$Reads . ",Size=" . $$Size . ",Mapq=" . $$Mapq_median . ",AS=" . $$AS_median . ",NM=" . $$NM_median . ",BX=" . $$BX . ",MI=" . $$MI' \
		then cut -o -f Rname,Start,End,Name,Reads $< >$@

# LongRanger

# Index the target genome.
refdata-%/fasta/genome.fa.bwt: %.fa
	longranger mkref $<

# Align reads to the target genome, call variants, phase variants, and create a Loupe file.
$(ref)_%_longranger_wgs/outs/phased_possorted_bam.bam: data/%/files refdata-$(ref)/fasta/genome.fa.bwt
	longranger wgs --id=$(ref)_$*_longranger_wgs --sex=female --reference=refdata-$(ref) --fastqs=$(<D)

# Symlink the longranger wgs bam file.
$(ref).%.longranger.wgs.bam: $(ref)_%_longranger_wgs/outs/phased_possorted_bam.bam
	ln -sf $< $@

# Align reads to the target genome, call variants, and create a Loupe file.
$(ref)_%_longranger_wgs_vconly/outs/phased_possorted_bam.bam: data/%/files refdata-$(ref)/fasta/genome.fa.bwt
	longranger wgs --id=$(ref)_$*_longranger_wgs_vconly --vconly --sex=female --reference=refdata-$(ref) --fastqs=$(<D)

# Symlink the longranger wgs bam file.
$(ref).%.longranger.wgs.vconly.bam: $(ref)_%_longranger_wgs_vconly/outs/phased_possorted_bam.bam
	ln -sf $< $@

# RMarkdown

# Report summary statistics of a Chromium library
%.bx.molecule.summary.html: %.bx.molecule.tsv
	Rscript -e 'rmarkdown::render("summary.rmd", "html_document", "$@", params = list(input_tsv="$<", output_tsv="$*.summary.tsv"))'
