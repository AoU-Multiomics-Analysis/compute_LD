version 1.0 

task ComputeLD {
    input {
        File pvar
        File psam
        File pgen
        File SampleList
        String Chromosome
        String OutPrefix
        Float WindowLDkb
        Float ThreshLD
    }
    
    String ShardPrefix  = OutPrefix + "_" + Chromosome
    command <<<
        first=$(head -n1 ~{SampleList})
        if [[ "$first" =~ [a-zA-Z] ]]; then
          tail -n +2 ~{SampleList} | awk '{print $1}' > keep_plink.txt
        else
          awk '{print $1}' ~{SampleList} > keep_plink.txt
        fi

        plink2 \
            --threads 32 \
            --chr ~{Chromosome} \
            --pvar ~{pvar} \
            --pgen ~{pgen} \
            --psam ~{psam} \
            --keep keep_plink.txt \
            --r2-unphased \
            --ld-window 999999 \
            --ld-window-kb ~{WindowLDkb} \
            --ld-window-r2 ~{ThreshLD} \
            --out ~{ShardPrefix}    
    >>>

   runtime {
        docker: "quay.io/biocontainers/plink2:2.0.0a.6.9--h9948957_0"
        disks: "local-disk 1000 SSD"
        memory: "64GB"
        cpu: "32"
    }
    
    output {
        File MatrixLD = "~{ShardPrefix}.vcor"
    }
}

workflow ComputeLDWorkflow {
    input {
        File pvar
        File psam
        File pgen
        File SampleList
        String OutPrefix
        Float WindowLDkb
        Float ThreshLD
    }
    
    Array[String] Chromosomes = ["chr1", "chr2", "chr3", "chr4", "chr5", "chr6", "chr7", "chr8", "chr9", "chr10", "chr11", "chr12", "chr13", "chr14", "chr15", "chr16", "chr17", "chr18", "chr19", "chr20", "chr21", "chr22"]
    scatter (Chromosome in Chromosomes) {
    call ComputeLD {
        input:
            pvar = pvar,
            psam = psam,
            pgen = pgen,
            Chromosome = Chromosome,
            OutPrefix = OutPrefix,
            SampleList = SampleList,
            WindowLDkb = WindowLDkb,
            ThreshLD = ThreshLD
        }
    }
    output {
        Array[File] OutputMatrixLD =  ComputeLD.MatrixLD 
    }
}
