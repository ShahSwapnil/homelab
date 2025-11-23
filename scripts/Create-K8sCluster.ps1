.\Create-VM.ps1 -VMName "nsc-k8s-cp-01" -MacAddress "00155D00C70A" -RAM 5000 -HDSizeGB 40 -ProcessorCount 2
.\Create-VM.ps1 -VMName "nsc-k8s-wn-01" -MacAddress "00155D00C70C" -RAM 44000 -HDSizeGB 50 -SecondHDSizeGB 350 -ProcessorCount 5
.\Create-VM.ps1 -VMName "nsc-k8s-wn-02" -MacAddress "00155D00C70D" -RAM 44000 -HDSizeGB 50 -SecondHDSizeGB 350 -ProcessorCount 5
