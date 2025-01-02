version 1.0

workflow SBayesRC_prs {

    meta {
        author: "Phuwanat"
        email: "phuwanat.sak@mahidol.edu"
        description: "SBayesRC PRS"
    }

     input {
        File pgen
        File psam
        File pvar
        File weight_file
        Int memSizeGB = 4
        Int threadCount = 2
        Int diskSizeGB = 20
	    String out_name
    }

    call run_checking { 
			input: pgen=pgen, psam=psam, pvar=pvar,weight_file = weight_file, memSizeGB=memSizeGB, threadCount=threadCount, diskSizeGB=diskSizeGB, out_name=out_name
	}

    output {
        Array[File] score_out = run_checking.score_out
    }

}

task run_checking {
    input {
        File weight_file
        File psam
        File pvar
        File pgen
        Int memSizeGB
        Int threadCount
        Int diskSizeGB
	    String out_name
        String plink_file = basename(pgen, ".pgen")
    }
    
    command <<<
    
    mv ~{psam} ~{plink_file}.psam
    mv ~{pvar} ~{plink_file}.pvar
    mv ~{pgen} ~{plink_file}.pgen
    
    Rscript -e "SBayesRC::prs(weight='~{weight_file}', genoPrefix='~{plink_file}', \
                       out='~{out_name}', genoCHR='')"

    >>>

    output {
        Array[File] score_out = glob("*.score.txt")
    }

    runtime {
        memory: memSizeGB + " GB"
        cpu: threadCount
        disks: "local-disk " + diskSizeGB + " HDD"
        docker: "phuwanat/sbayesrcmain:v1"  #"zhiliz/sbayesrc:0.2.6"
        preemptible: 1
    }

}
