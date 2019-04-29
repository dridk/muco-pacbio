configfile: "config.yml"



rule concat_all:
	input: 
		expand("{sample}.rename.fa", sample = config["SAMPLES"])

	output:
		"all_sample.fa"

	shell:
		"cat {input} > {output}"


rule trim_pos:
	input:
		"Lib1/{name}.fastq"
	output:
		"{name}_pos_strand.fastq"
	log:
		"{name}.trim.log"
	shell:
		"cutadapt -a {config[FORWARD_SEQ]}...{config[REVERSE_COMP_SEQ]} {input} -o {output} --trimmed-only > {log}"


rule trim_neg:
	input:
		"{name}.fastq"
	output:
		"{name}_neg_strand.fastq"
	log:
		"{name}.trim.log"
	shell:
		"cutadapt -a {config[FORWARD_COMP_SEQ]}...{config[REVERSE_SEQ]} {input} -o {output} --trimmed-only > {log}"

rule neg_complement:
	input:
		"{name}.fastq"
	output:
		"{name}.complement.fastq"
	shell:
		"seqkit seq -p {input} > {output}"

rule merge:
	input:
		pos = "{name}_pos_strand.fastq",
		neg = "{name}_neg_strand.complement.fastq"
	output:
		"{name}.merged.fastq"
	shell:
		"cat {input} > {output}"

rule fq2fa:
	input:
		"{name}.fastq"
	output:
		"{name}.fa"
	shell:
		"seqkit fq2fa {input} > {output}"


rule rename_fa:
	input:
		"{name}.merged.fa"
	output:
		"{name}.rename.fa"
	shell:
		"seqkit replace -p '(.+)' -r '{wildcards.name}_{{nr}} $1' {input} > {output}"



rule usearch:
	input:
		"{name}.merged.fa"
	output:
		"{name}.vsearch.txt"

	shell:
		"vsearch --usearch_global {input} --db gg.fa --id 0.97  --threads 30 --userout {output} --userfields query+target+id"
