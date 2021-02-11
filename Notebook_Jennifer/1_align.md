# 1 Align

Authors: Mou & Jennifer

Okay so we are looking at **gsnap** alignment. However is this even installed on Atlas? If not, either install natively / via miniconda / via singularity containers.

# Is GSNAP installed?

The usual way to check if a program is installed is using:

```
module spider <programname>

#aka
module spider gsnap   # gmap? similar sounding name?
```

However this checks for a program one at a time. I prefer listing All modules that are available on an HPC and then using `less` or `grep` to search for the program or similarly named program.

Check what modules are available

```
(module avail) &> module_list.txt
```

Let's look at (`less`) the text file `module_list.txt`.

```
less module_list.txt
```

Which gives us a list of modules

```
------------------------------------------- /apps/modulefiles/core -------------------------------------------
   advisor/2020.2     gnuplot/5.2.7          mpich/3.3.2              python/3.7.5
   antlr/2.7.7        go/1.13.5              munge/0.5.13             qt/5.12.1
   boost/1.70         grace/5.1.25           namd/2.14                r/4.0.2
   bowtie2/2.4.1      gsl/2.6                ncl/6.6.2                rdesktop/2.2.0
   cairo/1.17.2       hdf5/1.10.6            nco/4.9.3                root/6.22.00
   canu/2.1           htslib/1.10.2          netcdf/4.7.4             rstudio/1.3.1073
   chapel/1.22.1      hwloc/2.2.0            nwchem/7.0.0             seqkit/0.14.0
   cmake/3.18.1       impi/2020.2            openblas/0.3.10          singularity/3.5.2
   contrib/0.1        intel/2020.2           openjdk/14.0.2           singularity/3.7.1 (D)
   cuda/11.0.3        intelpython3/2020.2    openmpi/4.0.4            slurm/20.02.4
   eigen/3.3.7        jasper/1.900.1         ovito/3.2.0              snopt/7.7
   exonerate/2.2.0    jellyfish/2.3.0        p4vasp/0.3.30            sparsehash/2.0.4
   fastqc/0.11.9      julia/1.5.1            parallel/20200722        sqlite/3.32.3
   ferret/7.5.0       kentutils/407          paraview/5.7.0           szip/2.1.1
   ffmpeg/4.3.1       local/0.1              pdsh/2.34                tassel/5.2.64
   fftw/3.3.8         make/4.3               perl/5.32.0              udunits/2.2.26
   gcc/10.2.0         matlab/2019b           pgi/2019-19.9            vep/100.4
   gd/2.3.0           mauve/2.4.0            pgi/2020-20.4     (D)    vmd/1.9.3
   gdal/3.1.2         meryl/1.0              pigz/2.4                 vtune/2020.2
   gdb/10.1           mesa/20.1.6            plink2/2.3               w3lib/2.0.6
   gempak/7.5.1       minimap2/2.17          prodigal/2.6.3           xcrysden/1.5.60
   geos/3.8.1         minpath/1.4            proj/7.1.0               xpdf/4.02
   git/2.28.0         mkl/2020.2             pycharm/2020.2           zlib/1.2.11

  Where:
   D:  Default Module

Use "module spider" to find all possible modules and extensions.
Use "module keyword key1 key2 ..." to search for all possible modules matching any of the "keys".
```

If we want to use any of the programs in this module list, we simply have to call

```
module load <module name>

# You could load a particular version module
module load singularity/3.5.2      #<= recommended to keep version number, for analysis reproducibility

# Or take the default version
module load singularity            #<= will load 3.7.1, since that has a "D" = default next to it in list
```

I'm not seeing GSNAP on the list...hmm, but there's `singularity` so we could install it via a singularity image. I'm surprised there isn't `miniconda` so we could install the python libraries. Mou and I worked on installing miniconda and GSNAP.

## Install GSNAP locally

Before we get into installing your own programs in the HPC. We need to touch on file organization on an HPC.

----

### Side Tangent: Setting up folders in a HPC

This is my general template for organizing folders and files on an HPC. Since the home folder has a ~5GB memory limit, I tend to create folders in my project directory (larger memory) and then softlink (`ln -s`) them to home folder.  

```
/project/projectname/
           |_ software/              #<= soft link to home (shared programs across a research group)
           |_ Jennifer/
                |_ inbox/            #<= softlink to home
                |_ outbox/           #<= softlink to home
                |_ dot_files/
                    |_ .singularity/ #<= softlink to home
                    |_ .conda/       #<= softlink to home
                    |_ .nextflow/    #<= softlink to home
                    |_ R/            #<= softlink to home
```

* `inbox` and `outbox`  are nice b.c. I can do ssh mylocalfile.tar.gz jenchang@atlas:inbox/.  and don't have to think about 5gb limit
* dotfiles (`.singularity`, `.conda`) are usually invisible folders that get large as you install conda packages, or singularity images. These can eat up your home folder ~5GB memory limit if they're not softlinked

---

Initially, I was indecisive on compiling GSNAP from source or installing via miniconda. Compiling from source is always going to run faster (more natively) then installing via miniconda/singularity/other containerization program. Installing from a miniconda/singularity/etc will tend to be easier. In the end, we were able to get it installed from source.

* GMAP and GSNAP Source code is available at first link - [http://research-pub.gene.com/gmap/](http://research-pub.gene.com/gmap/)

```
# ==== Place in shared software folder
cd /project/project_name/software   

# ==== Fetch GSNAP Source code
wget http://research-pub.gene.com/gmap/src/gmap-gsnap-2020-12-17.tar.gz

# ==== Unzip the tar.gz compressed folder
tar -xvzf gmap-gsnap-2020-12-17.tar.gz

# ==== Look around, notice there's a README, with an INSTALL file
cd gmap-2020-12-17
ls
#> acinclude.m4  AUTHORS	 config       configure     COPYING  LICENSE	  Makefile.in  NOTICE  src    util
#> aclocal.m4    ChangeLog  config.site  configure.ac  INSTALL  Makefile.am  NEWS	       README  tests  VERSION
```

Any C program with a Makefile can usually be installed with `./configure` -> `make` -> `make install`. 

If we look at the `README` instructions, it shows the `configure` -> `make` -> `make install` method of building.  Here, we're going to modify the `./configure` slightly to place the `gmap` executable in the `software` folder.

``` 
# ==== Compile
./configure --prefix=/project/project_name/software/gmap-2020-12-17 --with-gmapdb=/project/project_name/software/gmapdb
make
make install

# ==== Look around to see what has changed
ls
#> acinclude.m4  ChangeLog    config.status  INSTALL      Makefile.in  src
#> aclocal.m4    config	   configure	  LICENSE      NEWS	    tests
#> AUTHORS       config.log   configure.ac   Makefile     NOTICE	    util
#> bin	      config.site  COPYING	  Makefile.am  README	    VERSION
```

Difficult to see in the list, but now there's a `bin` folder. Look inside that folder and you will see the `gsnap` executables.

```
ls bin/

#> atoiindex	  gmap.avx2	gsnapl			    iit_store
#> cmetindex	  gmap_build	gsnapl.avx2		    indexdb_cat
#> cpuid		  gmap_cat	gsnapl.nosimd		    md_coords
#> dbsnp_iit	  gmapindex	gsnap.nosimd		    psl_genes
#> ensembl_genes	  gmapl		gtf_genes		    psl_introns
#> fa_coords	  gmapl.avx2	gtf_introns		    psl_splicesites
#> get-genome	  gmapl.nosimd	gtf_splicesites		    sam_sort
#> gff3_genes	  gmap.nosimd	gtf_transcript_splicesites  snpindex
#> gff3_introns	  gmap_process	gvf_iit			    trindex
#> gff3_splicesites  gsnap		iit_dump		    vcf_iit
#> gmap		  gsnap.avx2	iit_get
```

# Start GSNAP alignment

Hahaha, well we've finally made it (after ~2 days of searching and installing). 

Mou found a tutorial link on GSNAP:

* [https://hbctraining.github.io/Intro-to-rnaseq-hpc-gt/lessons/08\_rnaseq\_workflow.html](https://hbctraining.github.io/Intro-to-rnaseq-hpc-gt/lessons/08_rnaseq_workflow.html)

The general format of the pipeline is:

```
(1) index genome -> (2) map reads to genome -> (3) get counts
```

The counts will be sent to Diffential Expression analysis programs.

## (1) Build index

This portion is still in progress...

```
GMAP_BIN=/project/project_name/software/gmap-2020-12-17/bin

${GMAP_BIN}/gmap_build -d <genome name> <path to genome fasta file>
```

Fetch Maize Reference (B73)

* NCBI Entry for Maize - [https://www.ncbi.nlm.nih.gov/assembly/GCF_902167145.1/](https://www.ncbi.nlm.nih.gov/assembly/GCF_902167145.1/)

Fetch the fna (fasta nucleotide) and the gff (general feature format) files.

Need to unzip the fasta file before `gmap_build` can use it. 

```
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/902/167/145/GCF_902167145.1_Zm-B73-REFERENCE-NAM-5.0/GCF_902167145.1_Zm-B73-REFERENCE-NAM-5.0_genomic.fna.gz
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/902/167/145/GCF_902167145.1_Zm-B73-REFERENCE-NAM-5.0/GCF_902167145.1_Zm-B73-REFERENCE-NAM-5.0_genomic.gff.gz
```

Index reference file. You may need to edit paths. 

```
GMAP_BIN=/project/project_name/software/gmap-2020-12-17/bin
${GMAP_BIN}/gmap_build \
 -d b73 \
 data_maize/ref/GCF_902167145.1_Zm-B73-REFERENCE-NAM-5.0_genomic.fna
```

* [gsnap_indexgenome.slurm](bin/gsnap_indexgenome.slurm)

# (2) map reads to index

Paired end reads must be fed into gsnap

```
ls data_maize/reads/* |\
  tr '\n' '\t'|\
  sed 's/_2.fastq.gz/_2.fastq.gz|/g'|\
  tr '|' '\n'|\
  awk '{print $1,$2}' > input.txt
```

Let's look at input.txt

```
data_maize/reads/SRR1573504_1.fastq.gz data_maize/reads/SRR1573504_2.fastq.gz
data_maize/reads/SRR1573505_1.fastq.gz data_maize/reads/SRR1573505_2.fastq.gz
data_maize/reads/SRR1573506_1.fastq.gz data_maize/reads/SRR1573506_2.fastq.gz
data_maize/reads/SRR1573507_1.fastq.gz data_maize/reads/SRR1573507_2.fastq.gz
data_maize/reads/SRR1573508_1.fastq.gz data_maize/reads/SRR1573508_2.fastq.gz
data_maize/reads/SRR1573509_1.fastq.gz data_maize/reads/SRR1573509_2.fastq.gz
data_maize/reads/SRR1573510_1.fastq.gz data_maize/reads/SRR1573510_2.fastq.gz
data_maize/reads/SRR1573511_1.fastq.gz data_maize/reads/SRR1573511_2.fastq.gz
data_maize/reads/SRR1573512_1.fastq.gz data_maize/reads/SRR1573512_2.fastq.gz
data_maize/reads/SRR1573513_1.fastq.gz data_maize/reads/SRR1573513_2.fastq.gz
data_maize/reads/SRR1573514_1.fastq.gz data_maize/reads/SRR1573514_2.fastq.gz
data_maize/reads/SRR1573515_1.fastq.gz data_maize/reads/SRR1573515_2.fastq.gz
data_maize/reads/SRR1573516_1.fastq.gz data_maize/reads/SRR1573516_2.fastq.gz
data_maize/reads/SRR1573517_1.fastq.gz data_maize/reads/SRR1573517_2.fastq.gz
data_maize/reads/SRR1573518_1.fastq.gz data_maize/reads/SRR1573518_2.fastq.gz
data_maize/reads/SRR1573519_1.fastq.gz data_maize/reads/SRR1573519_2.fastq.gz
data_maize/reads/SRR1573520_1.fastq.gz data_maize/reads/SRR1573520_2.fastq.gz
data_maize/reads/SRR1573521_1.fastq.gz data_maize/reads/SRR1573521_2.fastq.gz
data_maize/reads/SRR1573522_1.fastq.gz data_maize/reads/SRR1573522_2.fastq.gz
data_maize/reads/SRR1573523_1.fastq.gz data_maize/reads/SRR1573523_2.fastq.gz
data_maize/reads/SRR1573524_1.fastq.gz data_maize/reads/SRR1573524_2.fastq.gz
data_maize/reads/SRR1573525_1.fastq.gz data_maize/reads/SRR1573525_2.fastq.gz
data_maize/reads/SRR1573526_1.fastq.gz data_maize/reads/SRR1573526_2.fastq.gz
data_maize/reads/SRR1573527_1.fastq.gz data_maize/reads/SRR1573527_2.fastq.gz
```

# (3) get counts

## Install featureCount

Heh, this one was missing too.

* Install Instructions - [http://bioinf.wehi.edu.au/subread-package/](http://bioinf.wehi.edu.au/subread-package/)

Thankfully this is an already compiled binary. Ergo:

1. Download the `subread-2.0.1-Linux-x86_64.tar.gz` from sourceforge - [https://sourceforge.net/projects/subread/files/subread-2.0.1/](https://sourceforge.net/projects/subread/files/subread-2.0.1/)
2. scp file to Atlas

  ```
  # from local laptop, move file to Atlas
  scp subread-2.0.1-Linux-x86_64.tar.gz atlas:inbox/.
  ```
  
3. Move to software folder

  ```
  # From Atlas HPC
  mv ~/inbox/subread-2.0.1-Linux-x86_64.tar.gz /project/project_name/software/.
  cd /project/project_name/software
  tar -xzvf subread-2.0.1-Linux-x86_64.tar.gz
  cd subread-2.0.1-Linux-x86_64
  ls bin/*
  
  #> bin/exactSNP  bin/featureCounts  bin/subindel  bin/subjunc  bin/sublong  bin/subread-align  bin/subread-buildindex
  #> bin/utilities:
  #> detectionCall  flattenGTF  genRandomReads  propmapped  qualityScores  removeDup  repair  subread-fullscan  txUnique
  ```
  
4. Make sure program runs: `./bin/featureCounts`

Geh... samtools is missing, which requires two difficult to install libraries... the benefits of installing natively has gone down.

# Alternative: install everything in miniconda

Samtools required a few specific C libraries, ergo I gave up natively install and switched to miniconda.

## Install miniconda

Based on [https://conda.io/projects/conda/en/latest/user-guide/install/linux.html], install locally to Atlas HPC.

```
# Fetch the install script
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh

# Run the fetched script
bash Miniconda3-latest-Linux-x86_64.sh

# By default it places miniconda3 in home folder (remember 5gb limit)
# Ergo we move this to the project folder and link to home
mv ~/miniconda3 /project/project_folder/software/.
ln -s /project/project_folder/software/miniconda3 ~/.
```

Create an environment file, save it as `gsnap_env.yml`.

```
name: gsnap_env
channels:
  - conda-forge
  - bioconda
  - defaults
dependencies:
  - python=3.8
  - gmap
  - samtools      #<= notice you could probably list all tools
  - subread
```

And from the command line create the miniconda environment:

```
conda env create -f gsnap_env.yml
```

And enjoy the ease with which miniconda installs all dependencies for gsnap (`gmap`), samtools (`samtools`) and featureCounts (`featureCounts`). 

Then the tools are available when you activate the environment.

```
conda activate gsnap_env
samtools -v
gmap -v
featureCounts -v
```

The top of the slurm script will require a few extra lines before `conda activate` will work.

```
USER=jennifer.chang
source /home/${USER}/.bashrc
conda activate gsnap_env

## gsnap/samtools/featureCount commands here
```




