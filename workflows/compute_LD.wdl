version 1.0 

task ComputeLD {
    input {
        File pvar
        File psam
        File pgen
        File SampleList
        String OutPrefix
        Float WindowLDkb 
    }
    
    command <<<
        first=$(head -n1 ~{SampleList})
        if [[ "$first" =~ [a-zA-Z] ]]; then
          tail -n +2 ~{SampleList} | awk '{print $1}' > keep_plink.txt
        else
          awk '{print $1}' ~{SampleList} > keep_plink.txt
        fi

        plink2 \
            --threads 32 \
            --pvar ~{pvar} \
            --pgen ~{pgen} \
            --psam ~{psam} \
            --keep keep_plink.txt \
            --r2-unphased \
            --ld-window 999999 \
            --ld-window-kb ~{WindowLDkb} \
            --ld-window-r2 0 \
            --out ~{OutPrefix}
    >>>

   runtime {
        docker: "quay.io/biocontainers/plink2:2.0.0a.6.9--h9948957_0"
        disks: "local-disk 500 SSD"
        memory: "240GB"
        cpu: "32"
    }
    
    output {
        File MatrixLD = "~{OutPrefix}.vcor"
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
    }
    
    call ComputeLD {
        input:
            pvar = pvar,
            psam = psam,
            pgen = pgen,
            SampleList = SampleList,
            OutPrefix = OutPrefix,
            WindowLDkb = WindowLDkb
    }
    output {
        File OutputMatrixLD =  ComputeLD.MatrixLD 
    }
}
