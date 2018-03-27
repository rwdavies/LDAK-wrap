rule all:
    input: "test.txt"

rule test:
    output: "test.txt"
    shell:  "echo hello world > test.txt"
