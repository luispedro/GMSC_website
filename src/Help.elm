module Help exposing (..)
import Html exposing (..)
import Html.Attributes as HtmlAttr
import Html.Attributes exposing (..)
import Browser
import Dict
import Markdown
import View exposing (View)

import Bootstrap.CDN as CDN
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row

import Center

main: Program () () Never
main =
    Browser.document
    { init = \_ -> ((), Cmd.none)
    , update = \_ _ -> ((), Cmd.none)
    , subscriptions = \_ -> Sub.none
    , view = \_ ->
        { title = "GMSC:Help"
        , body =
            [ CDN.stylesheet
            , CDN.fontAwesome
            , Html.node "link"
                [ HtmlAttr.rel "stylesheet"
                , HtmlAttr.href "style.css"
                ]
                []
            , Grid.containerFluid []
                [ Grid.simpleRow
                    [ Grid.col []
                        [ header
                        , content
                        , Html.hr [] []
                        , footer
                        ]
                    ]
                ]
            ]
        }
    }

content : Html msg
content =
    span [id "help"]
        [Markdown.toHtml [] """
## Overview
The global microbial smORFs catalogue (GMSC) is an integrated, consistently-processed, smORFs catalogue of the microbial world, combining 63,410 publicly available metagenomes and 87,920 high-quality isolated microbial genomes from the [ProGenomes database](https://progenomes.embl.de/).

A total of 4.5 billion smORFs were used to build the catalog. After 100%-identity redundancy removal, we obtained a 100AA non-redundant catalog with 965 million sequences. Further, the smORFs were clustered at 90% amino acid identity resulting in 288 million 90AA smORFs catalog.

## Benefits and Features
**Integration:**

- GMSC is available as a web resource that displays each smORFs for browsing their integrated annotations:
  - clusters
  - taxonomy classification
  - habitat assignment
  - quality assessment
  - conserved domain annotation
  - cellular localization prediction

**Main purpose of GMSC**:
- Expand smORFs sets of global microbiomes with comprehensive annotation
- Analyse of ecological distribution patterns across taxonomy and global habitats
- Annotate smORFs of microbial genomes or genes with the resource

## Searching
GMSC-mapper is provided as a search tool to query sequences. Users can provide a genome or gene sequence and it will return a set of smORFs with complete annotations that match the 90AA smORFs in GMSC.

GMSC-mapper can also be downloaded and run locally, please see details in [Github page](https://github.com/BigDataBiology/GMSC-mapper)

figure

## Identifiers
smORFs in the catalog are identified with the scheme `GMSC10.100AA.XXX_XXX_XXX` or `GMSC10.90AA.XXX_XXX_XXX`. The initial `GMSC10` indicates the version of the catalog (Global Microbial smORFs Catalog 1.0). The `100AA` or `90AA` indicates the amino acid identity of the catalog. The `XXX_XXX_XXX` is a unique numerical identifier (starting at zero). Numbers were assigned in order of increasing number of copies. So that the greater the number, the greater number of copies of that peptide were present in the raw data. 
## Data acquistion
63,410 metagenomes published before January 1, 2020 were downloaded from the European Nucleotide Archive ([ENA](https://www.ebi.ac.uk/ena/browser/)). The criteria for selecting metagenomes are: 
- the taxonomic ID of the sample is 408169, that is, the taxonomic ID for metagenome, or the taxonomic ID is the descendant of 408169 in the taxonomic tree
- the library source field of experiments is "METAGENOMIC". Samples contain at least 2 million reads produced by Illumina instrument.

87,920 high-quality microbial genomes were downloaded from the [ProGenomes v2 database](https://progenomes.embl.de/).

## Construction of GMSC
A figure overview
#### Assembly of contigs and prediction of smORFs
The reads &gt; 60 bps were processed after trimming positions with quality &lt; 25 using [NGLess](https://github.com/ngless-toolkit/ngless). Filtered reads were assembled into contigs using [Megahit](https://github.com/voutcn/megahit).

We used a modified version of [Prodigal](https://github.com/hyattpd/Prodigal) to predict ORFs &gt;= 15 bps.  The ORFs that &lt;= 300 bps were considered smORFs.

#### Cluster generation
All predicted smORFs were removed redundancy with 100% amino acid sequence identity. Then they were clustered with 90% amino acid identity and 90% coverage using [Linclust](https://github.com/soedinglab/MMseqs2).

#### Taxonomy & Habitat annotation
** Taxonomy annotation:**

The taxonomy of assembled contigs encoding the small proteins was annotated using [MMSeqs2](https://github.com/soedinglab/MMseqs2) against the [GTDB database](https://gtdb.ecogenomic.org/). 

We recorded the taxonomy of smORFs based on the taxonomy of the contigs of metagenomes or genomes of [Progenome v2 database](https://progenomes.embl.de/) from which the smORFs were predicted. Subsequently, we assign taxonomy for 100AA and 90AA smORFs using the lowest common ancestor (LCA), ignoring the un-assigned rank to make it more specific.

**Habitat annotation:**

The metadata of samples was manually curated starting from annotations in the [NCBI Biosample database](https://www.ncbi.nlm.nih.gov/biosample/?term=) and corresponding manuscripts. Based on the environment ontology of [EMBL-EBI Ontology Lookup Service](https://www.ebi.ac.uk/ols4) and host identifier in [NCBI taxonomy database](https://www.ncbi.nlm.nih.gov/taxonomy/?term=), we defined 157 specific habitats classification in total and divided them into 8 major categories: mammal gut, anthropogenic, other-human, other-animal, aquatic, human gut, soil/plant, and other. 

We recorded the habitats of smORFs according to the samples they originated from.

#### Conserved domain annotation
The representative sequences of 90AA smORFs clusters were searched against [NCBI CDD database](https://www.ncbi.nlm.nih.gov/cdd/) by RPS-blast. Hits with an e-value maximum of 0.01 and at least 80% of coverage of PSSM's length were retained and considered significant.

#### Cellular localization prediction
[TMHMM2](https://services.healthtech.dtu.dk/services/TMHMM-2.0/) was run on the representative sequences of 90AA smORFs clusters. 

[SignalP-4.1](https://services.healthtech.dtu.dk/services/SignalP-4.1/) was run on the representative sequences of 90AA smORFs clusters both with 'gram+' and 'gram-' modes.

#### Quality assessment
- **Terminal check:** We checked for the presence of an in-frame STOP upstream of smORFs. As a smORF predicted at the start of a contig that is not preceded by an in-frame STOP codon risks being a false positive originating from an interrupted fragment.
- **Antifam:** We used HMMSearch to search smORFs against the [Antifam database](https://github.com/ebi-pf-team/antifam) to avoid spurious smORFs
- **RNAcode:** We used [RNAcode](https://github.com/ViennaRNA/RNAcode), a tool to predict the coding potential of sequences based on evolutionary signatures, to identify the coding potential of 90AA smORF families containing > 8 sequences. 
- **Metatranscriptomes:** We downloaded 221 sets of publicly available metatranscriptome data from the NCBI database paired with the metagenomic samples we used in our catalogue. We mapped reads against the representative smORFs of 90AA clusters by [BWA](https://github.com/lh3/bwa). The smORFs are considered to have transcriptional evidence only if they are mapped by reads across at least 2 samples. 
- **(Meta)Ribo-Seq:** We downloaded 142 publicly available (Meta)Ribo-Seq sets from the NCBI database.  We mapped reads against the representative smORFs of 90AA clusters by [BWA](https://github.com/lh3/bwa). The smORFs are considered to have translation evidence only if they are mapped by reads across at least 2 samples. 
- **Metaproteomes:** We downloaded peptide datasets from 108 metaproteome projects of the [PRIDE database](https://www.ebi.ac.uk/pride/). We exactly matched 100AA smORFs to the identified peptides of each project. If the total k-mer coverage of peptides on a smORF is greater than 50%, then the smORF is considered translated and detected.
""" ]

-- header


header : Html msg
header =
    let
        link target name =
            Grid.col []
                     [Html.a [href target] [Html.text name]
                     ]
    in div
        [id "topbar"]
        [Grid.simpleRow
            [ link "/home/" "Home"
            , link "/browse_data/" "Browse"
            , link "/downloads/" "Downloads"
            , link "/help/" "Help"
            , link "/about/" "About&Contact"
            ]
        ]

-- FOOTER


footer : Html msg
footer =
  div [id "footerbar"]
      [ a [][ text "Copyright (c) 2023 GMSC authors. All rights reserved."]
      ]