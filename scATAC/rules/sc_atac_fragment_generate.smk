rule scatac_fragmentgenerate:
        input:
            bam = "Result/minimap2/{sample}/{sample}.sortedByPos.bam",
            r2 = "Result/fastq/{sample}/{sample}_R2.fastq"
        output:
            fragments = "Result/minimap2/{sample}/fragments.tsv"
        params:
            outdir = "Result/minimap2/{sample}"
        benchmark:
            "Result/Benchmark/{sample}_FragGenerate.benchmark" 
        shell:
            "python ../utils/scATAC_FragmentGenerate.py -B {input.bam} -b {input.r2} -O {params.outdir}"


if config["whitelist"]:
    rule scatac_barcodecorrect:
        input:
            r2 = "Result/fastq/{sample}/{sample}_R2.fastq",
            whitelist = config["whitelist"]
        output:
            bc_correct = "Result/minimap2/{sample}/barcode_correct.txt"
        params:
            outdir = "Result/minimap2/{sample}"
        benchmark:
            "Result/Benchmark/{sample}_BarcodeCorrect.benchmark" 
        shell:
            "python ../utils/scATAC_10x_BarcodeCorrect.py -b {input.r2} -B {input.whitelist} -O {params.outdir}"
else:
    rule scatac_barcodecorrect:
        input:
            r2 = "Result/fastq/{sample}/{sample}_R2.fastq",
        output:
            bc_correct = "Result/minimap2/{sample}/barcode_correct.txt"
        params:
            outdir = "Result/minimap2/{sample}"
        benchmark:
            "Result/Benchmark/{sample}_BarcodeCorrect.benchmark" 
        shell:
            "python ../utils/scATAC_10x_BarcodeCorrect.py -b {input.r2} -O {params.outdir}"        

rule scatac_fragmentcorrect:
    input:
        fragments = "Result/minimap2/{sample}/fragments.tsv",
        bc_correct = "Result/minimap2/{sample}/barcode_correct.txt"
    output:
        frag_count = "Result/minimap2/{sample}/fragments_corrected_count.tsv",
        frag_sort = "Result/minimap2/{sample}/fragments_corrected_sorted.tsv"
    params:
        outdir = "Result/minimap2/{sample}",
        frag_correct = "Result/minimap2/{sample}/fragments_corrected.tsv",
    benchmark:
        "Result/Benchmark/{sample}_FragCorrect.benchmark" 
    shell:
        """
        python ../utils/scATAC_FragmentCorrect.py -F {input.fragments} -C {input.bc_correct} -O {params.outdir}

        sort -k1,1 -k2,2 -k3,3 -k4,4 -V {params.frag_correct} > {output.frag_sort}

        bedtools groupby -i {output.frag_sort} -g 1,2,3,4 -c 4 -o count > {output.frag_count}
        """



