#!/usr/bin/env fish
# 
# Abbreviations for kubectl
#
# Copyright (c) 2022 Rich Lewis
# MIT License

set -g kubectl_abbr_version 0.1.0

# General
abbr k 'kubectl'
abbr kaf 'kubectl apply -f'
abbr keti 'kubectl exec -t -i'
abbr kcuc 'kubectl config use-context'
abbr kcsc 'kubectl config set-context'
abbr kcdc 'kubectl config delete-context'
abbr kccc 'kubectl config current-context'
abbr kcgc 'kubectl config get-contexts'
abbr kdel 'kubectl delete'
abbr kdelf 'kubectl delete -f'
abbr kpf "kubectl port-forward"
abbr kga 'kubectl get all'
abbr kgaa 'kubectl get all --all-namespaces'
abbr kl 'kubectl logs'
abbr klf 'kubectl logs -f'
abbr kls 'kubectl logs --since'
abbr klfs 'kubectl logs -f --since'
abbr klt 'kubectl logs -t'
abbr kcp 'kubectl cp'

# Pod management.
abbr kgp 'kubectl get pods'
abbr kgpa 'kubectl get pods --all-namespaces'
abbr kgpw 'kubectl get pods --watch'
abbr kgpwide 'kubectl get pods -o wide'
abbr kep 'kubectl edit pods'
abbr kdp 'kubectl describe pods'
abbr kdelp 'kubectl delete pods'
abbr kgpall 'kubectl get pods --all-namespaces -o wide'
abbr kgpl 'kubectl get pods -l'
abbr kgpn 'kubectl get pods -n'

# Service management.
abbr kgs 'kubectl get svc'
abbr kgsa 'kubectl get svc --all-namespaces'
abbr kgsw 'kubectl get svc --watch'
abbr kgswide 'kubectl get svc -o wide'
abbr kes 'kubectl edit svc'
abbr kds 'kubectl describe svc'
abbr kdels 'kubectl delete svc'

# Ingress management
abbr kgi 'kubectl get ingress'
abbr kgia 'kubectl get ingress --all-namespaces'
abbr kei 'kubectl edit ingress'
abbr kdi 'kubectl describe ingress'
abbr kdeli 'kubectl delete ingress'

# Namespace management
abbr kgns 'kubectl get namespaces'
abbr kens 'kubectl edit namespace'
abbr kdns 'kubectl describe namespace'
abbr kdelns 'kubectl delete namespace'
abbr kcn 'kubectl config set-context --current --namespace'

# ConfigMap management
abbr kgcm 'kubectl get configmaps'
abbr kgcma 'kubectl get configmaps --all-namespaces'
abbr kecm 'kubectl edit configmap'
abbr kdcm 'kubectl describe configmap'
abbr kdelcm 'kubectl delete configmap'

# Secret management
abbr kgsec 'kubectl get secret'
abbr kgseca 'kubectl get secret --all-namespaces'
abbr kdsec 'kubectl describe secret'
abbr kdelsec 'kubectl delete secret'

# Deployment management.
abbr kgd 'kubectl get deployment'
abbr kgda 'kubectl get deployment --all-namespaces'
abbr kgdw 'kubectl get deployment --watch'
abbr kgdwide 'kubectl get deployment -o wide'
abbr ked 'kubectl edit deployment'
abbr kdd 'kubectl describe deployment'
abbr kdeld 'kubectl delete deployment'
abbr ksd 'kubectl scale deployment'
abbr krsd 'kubectl rollout status deployment'

# Rollout management.
abbr kgrs 'kubectl get replicaset'
abbr kdrs 'kubectl describe replicaset'
abbr kers 'kubectl edit replicaset'
abbr krh 'kubectl rollout history'
abbr kru 'kubectl rollout undo'

# Statefulset management.
abbr kgss 'kubectl get statefulset'
abbr kgssa 'kubectl get statefulset --all-namespaces'
abbr kgssw 'kubectl get statefulset --watch'
abbr kgsswide 'kubectl get statefulset -o wide'
abbr kess 'kubectl edit statefulset'
abbr kdss 'kubectl describe statefulset'
abbr kdelss 'kubectl delete statefulset'
abbr ksss 'kubectl scale statefulset'
abbr krsss 'kubectl rollout status statefulset'

# Node Management
abbr kgno 'kubectl get nodes'
abbr keno 'kubectl edit node'
abbr kdno 'kubectl describe node'
abbr kdelno 'kubectl delete node'

# PVC management.
abbr kgpvc 'kubectl get pvc'
abbr kgpvca 'kubectl get pvc --all-namespaces'
abbr kgpvcw 'kubectl get pvc --watch'
abbr kepvc 'kubectl edit pvc'
abbr kdpvc 'kubectl describe pvc'
abbr kdelpvc 'kubectl delete pvc'

# Service account management.
abbr kdsa 'kubectl describe sa'
abbr kdelsa 'kubectl delete sa'

# DaemonSet management.
abbr kgds 'kubectl get daemonset'
abbr kgdsw 'kubectl get daemonset --watch'
abbr keds 'kubectl edit daemonset'
abbr kdds 'kubectl describe daemonset'
abbr kdelds 'kubectl delete daemonset'

# CronJob management.
abbr kgcj 'kubectl get cronjob'
abbr kecj 'kubectl edit cronjob'
abbr kdcj 'kubectl describe cronjob'
abbr kdelcj 'kubectl delete cronjob'

# Job management.
abbr kgj 'kubectl get job'
abbr kej 'kubectl edit job'
abbr kdj 'kubectl describe job'
abbr kdelj 'kubectl delete job'

function kubectl_abbr_uninstall --on-event kubectl_abbr_uninstall
    set -e kubectl_abbr_version
    abbr -e k
    abbr -e kaf
    abbr -e keti
    abbr -e kcuc
    abbr -e kcsc
    abbr -e kcdc
    abbr -e kccc
    abbr -e kcgc
    abbr -e kdel
    abbr -e kdelf
    abbr -e kpf
    abbr -e kga
    abbr -e kgaa
    abbr -e kl
    abbr -e klf
    abbr -e kls
    abbr -e klfs
    abbr -e klt
    abbr -e kcp
    abbr -e kgp
    abbr -e kgpa
    abbr -e kgpw
    abbr -e kgpwide
    abbr -e kep
    abbr -e kdp
    abbr -e kdelp
    abbr -e kgpall
    abbr -e kgpl
    abbr -e kgpn
    abbr -e kgs
    abbr -e kgsa
    abbr -e kgsw
    abbr -e kgswide
    abbr -e kes
    abbr -e kds
    abbr -e kdels
    abbr -e kgi
    abbr -e kgia
    abbr -e kei
    abbr -e kdi
    abbr -e kdeli
    abbr -e kgns
    abbr -e kens
    abbr -e kdns
    abbr -e kdelns
    abbr -e kcn
    abbr -e kgcm
    abbr -e kgcma
    abbr -e kecm
    abbr -e kdcm
    abbr -e kdelcm
    abbr -e kgsec
    abbr -e kgseca
    abbr -e kdsec
    abbr -e kdelsec
    abbr -e kgd
    abbr -e kgda
    abbr -e kgdw
    abbr -e kgdwide
    abbr -e ked
    abbr -e kdd
    abbr -e kdeld
    abbr -e ksd
    abbr -e krsd
    abbr -e kgrs
    abbr -e kdrs
    abbr -e kers
    abbr -e krh
    abbr -e kru
    abbr -e kgss
    abbr -e kgssa
    abbr -e kgssw
    abbr -e kgsswide
    abbr -e kess
    abbr -e kdss
    abbr -e kdelss
    abbr -e ksss
    abbr -e krsss
    abbr -e kgno
    abbr -e keno
    abbr -e kdno
    abbr -e kdelno
    abbr -e kgpvc
    abbr -e kgpvca
    abbr -e kgpvcw
    abbr -e kepvc
    abbr -e kdpvc
    abbr -e kdelpvc
    abbr -e kdsa
    abbr -e kdelsa
    abbr -e kgds
    abbr -e kgdsw
    abbr -e keds
    abbr -e kdds
    abbr -e kdelds
    abbr -e kgcj
    abbr -e kecj
    abbr -e kdcj
    abbr -e kdelcj
    abbr -e kgj
    abbr -e kej
    abbr -e kdj
    abbr -e kdelj
end


