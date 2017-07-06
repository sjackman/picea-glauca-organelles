# Align linked reads of white spruce and Sitka spruce to their organelles

Align Chromium sequencing of *Picea glauca* and *Picea sitchensis* to their respective organellar assemblies using Longranger. Create a Loupe summary report of molecule statistics as a quality assurance metric.

# Longranger Loupe Summary Report

| Species         | Sample  | Library | Lane        | Report
|-----------------|---------|---------|-------------|-------
| *P. glauca*     | PG29    | A70676  | HG3VHALXX_4 | [pglaucacpmt.HG3VHALXX_4.longranger.wgs.loupe.png](pglaucacpmt.HG3VHALXX_4.longranger.wgs.loupe.png)
| *P. glauca*     | PG29    | A70677  | HG3VHALXX_5 | [pglaucacpmt.HG3VHALXX_5.longranger.wgs.loupe.png](pglaucacpmt.HG3VHALXX_5.longranger.wgs.loupe.png)
| *P. glauca*     | WS77111 | A64454  | H352FALXX_5 | [pglaucacpmt.H352FALXX_5.longranger.wgs.loupe.png](pglaucacpmt.H352FALXX_5.longranger.wgs.loupe.png)
| *P. sitchensis* | Q903    | E00132  | HYN5VCCXX_4 | [psitchensiscpmt_2.HYN5VCCXX_4.longranger.wgs.loupe.png](psitchensiscpmt_2.HYN5VCCXX_4.longranger.wgs.loupe.png)

The original Loupe report of *Picea sitchensis* Q903 E00132 HYN5VCCXX_4 is at `/projects/btl/sjackman/picea-sitchensis-mitochondrion/psitchensiscpmt_2_psitchensis_longranger_wgs/outs/loupe.loupe`

# RMarkdown Summary Report

| Species         | Sample  | Library | Lane        | Report
|-----------------|---------|---------|-------------|-------
| *P. glauca*     | WS77111 | A64454  | H352FALXX_5 | [pglaucacpmt.H352FALXX_5.as100.nm5.bam.mi.bx.molecule.summary.md](pglaucacpmt.H352FALXX_5.as100.nm5.bam.mi.bx.molecule.summary.md)
| *P. sitchensis* | Q903    | E00132  | HYN5VCCXX_4 | [psitchensisnuc.HYN5VCCXX_4.as100.nm5.bam.mi.bx.molecule.summary.md](psitchensisnuc.HYN5VCCXX_4.as100.nm5.bam.mi.bx.molecule.summary.md)

# Data

| Species         | Sample  | Platform | Data
|-----------------|---------|----------|-----
| *P. glauca*     | PG29    | Chromium | /projects/btl/sjackman/picea-glauca-organelles/data/HG3VHALXX_4/files
| *P. glauca*     | PG29    | Chromium | /projects/btl/sjackman/picea-glauca-organelles/data/HG3VHALXX_5/files
| *P. glauca*     | WS77111 | Chromium | /projects/spruceup/pglauca/WS77111/data/reads/chromium-reads.in
| *P. sitchensis* | Q903    | Chromium | /projects/spruceup/psitchensis/Q903/data/reads/chromium-reads-longranger.in
| *P. sitchensis* | Q903    | Gemcode  | /projects/spruceup/psitchensis/Q903/data/reads/gemcode-reads.in
