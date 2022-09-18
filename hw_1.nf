params.results_dir = "results/"
SRA_list = params.SRA.split(",")

log.info ""
log.info "  Q U A L I T Y   C O N T R O L  "
log.info "================================="
log.info "SRA number         : ${SRA_list}"
log.info "Results location   : ${params.results_dir}"

process DownloadFastQ {
  publishDir "${params.results_dir}"

  input:
    val sra

  output:
    path "${sra}/*"

  script:
    """
    /content/sratoolkit.3.0.0-ubuntu64/bin/fastq-dump ${sra} -O ${sra}/ --gzip --split-3
    """
}

process QC {
  input:
    path data_set

  output:
    path "qc/*"

  script:
    """
    mkdir qc
    /content/FastQC/fastqc -o qc $data_set
    """
}

process MultiQC {
  publishDir "${params.results_dir}"

  input:
    path fc_results

  output:
    path "multiqc_report.html"

  script:
    """
    multiqc $fc_results
    """
}

workflow {
  data = Channel.of(SRA_list)
  DownloadFastQ(data)
  QC(DownloadFastQ.out)
  MultiQC(QC.out.collect())
}