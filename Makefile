# Align linked reads to the white spruce organelles
# Written by Shaun Jackman @sjackman

# Reference genome
ref=pglaucacpmt

# Picea glauca plastid
pglaucacp=KT634228

# Picea glauca mitochondrion
pglaucamt=LKAM01

# Report run time and memory usage
export SHELL=zsh -opipefail
export REPORTTIME=1
export TIMEFMT=time user=%U system=%S elapsed=%E cpu=%P memory=%M job=%J

.DELETE_ON_ERROR:
.SECONDARY:

all: \
	data/HG3VHALXX_4/files.sha256 \
	data/HG3VHALXX_5/files.sha256 \
	data/H352FALXX_5/files.sha256 \
	$(ref).HG3VHALXX_4.longranger.wgs.bam \
	$(ref).HG3VHALXX_5.longranger.wgs.bam \
	$(ref).H352FALXX_5.longranger.wgs.bam

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
