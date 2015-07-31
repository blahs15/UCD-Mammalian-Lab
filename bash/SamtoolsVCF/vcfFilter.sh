#!/bin/bash

inputvcf=Dhole.1.vcf

noext=$(sed 's/.vcf//g' <<<$inputvcf )
outputvcf=$noext.filtered.vcf


# Take out allele frequencies that are less than 1
# Take out INDELs
    # includes INDEL tag in header
grep -v "AF1=0" < $inputvcf | grep -v "INDEL"  > $outputvcf