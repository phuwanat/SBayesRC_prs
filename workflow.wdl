version 1.0

workflow SBayesRC_prs {

    meta {
        author: "Phuwanat"
        email: "phuwanat.sak@mahidol.edu"
        description: "SBayesRC PRS"
    }

     input {
        File ld
        File ma
        File annot
        Int diskSizeGB = 20
	    String out_prefix
    }

    call run_checking { 
			input: ld = ld, ma=ma, annot=annot, memSizeGB=memSizeGB, threadCount=threadCount, diskSizeGB=diskSizeGB, out_prefix=out_prefix
	}

    output {
        Array[File] out_files = run_checking.out_files
    }

}

task run_checking {
    input {
        File ld
        File annot
        File ma
        Int memSizeGB
        Int threadCount
        Int diskSizeGB
	    String out_prefix
        String ld_name = basename(ld, ".tar.xz")
        String annot_name = basename(annot, ".zip")
    }
    
    command <<<
    
    # Polygenic risk score
    ## Just a toy demo to calculate the polygenic risk score
    genoPrefix="test_chr{CHR}" # {CHR} means multiple genotype file.
    ## If just one genotype, input the full prefix genoPrefix="test"
    genoCHR="1-22" ## means {CHR} expands to 1-22 and X,
    ## if just one genotype file, input genoCHR=""
    output="test"
    Rscript -e "SBayesRC::prs(weight='${out_prefix}_sbrc.txt', genoPrefix='$genoPrefix', \
                       out='$output', genoCHR='$genoCHR')"
    ## test.score.txt is the polygenic risk score
    >>>

    output {
        Array[File] out_files = glob("*.score.txt")
    }

    runtime {
        memory: memSizeGB + " GB"
        cpu: threadCount
        disks: "local-disk " + diskSizeGB + " HDD"
        docker: "phuwanat/sbayesrcmain:v1"  #"zhiliz/sbayesrc:0.2.6"
        preemptible: 1
    }

}
