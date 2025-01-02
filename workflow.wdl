version 1.0

workflow SBayesRC_prs {

    meta {
        author: "Phuwanat"
        email: "phuwanat.sak@mahidol.edu"
        description: "SBayesRC PRS"
    }

     input {
        File bed
        File bim
        File fam
        File weight_file
        Int memSizeGB = 4
        Int threadCount = 2
        Int diskSizeGB = 20
    }

    call run_checking { 
			input: bed=bed,bim=bim,fam=fam,weight_file = weight_file, memSizeGB=memSizeGB, threadCount=threadCount, diskSizeGB=diskSizeGB
	}

    output {
        Array[File] score_out = run_checking.score_out
    }

}

task run_checking {
    input {
        File weight_file
        File bed
        File bim
        File fam
        Int memSizeGB
        Int threadCount
        Int diskSizeGB
        String plink_file = basename(fam, ".fam")
    }
    
    command <<<
    
    mv ~{bed} ~{plink_file}.bed
    mv ~{bim} ~{plink_file}.bim
    mv ~{fam} ~{plink_file}.fam
    
    Rscript -e "SBayesRC::prs(weight='~{weight_file}', genoPrefix='~{plink_file}', \
                       out='prsrun', genoCHR='')"

    >>>

    output {
        Array[File] score_out = glob("*prsrun*")
    }

    runtime {
        memory: memSizeGB + " GB"
        cpu: threadCount
        disks: "local-disk " + diskSizeGB + " HDD"
        docker: "phuwanat/sbayesrcmain:v1"  #"zhiliz/sbayesrc:0.2.6"
        preemptible: 1
    }

}
