# Global command `frame`

nixops_path := justfile_directory()
user := env("USER")
mgmt := "mgmt.milberry.org"
m1 := user + "@m1." + mgmt
kube := "kubectl --context milberry"
system := arch() + "-" + os()

import 'just/repo.just'
import 'just/deploy.just'
import 'just/backup.just'
import 'just/system.just'
import 'just/hardware.just'
import 'just/bench.just'

_default:
    @just --list --unsorted
