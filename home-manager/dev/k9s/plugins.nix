{
  plugins = {
    # Debug container
    debug = {
      shortCut = "Shift-D";
      description = "Add debug container";
      dangerous = true;
      scopes = ["containers"];
      command = "bash";
      background = false;
      confirm = true;
      args = [
        "-c"
        "kubectl --kubeconfig=$KUBECONFIG debug -it --context $CONTEXT -n=$NAMESPACE $POD --target=$NAME --image=nicolaka/netshoot:v0.13 --share-processes -- bash"
      ];
    };

    # Flux - HelmRelease
    toggle-helmrelease = {
      shortCut = "Shift-T";
      confirm = true;
      scopes = ["helmreleases"];
      description = "Toggle suspend/resume HelmRelease";
      command = "bash";
      background = false;
      args = ["-c" ''suspended=$(kubectl --context $CONTEXT get helmreleases -n $NAMESPACE $NAME -o=custom-columns=TYPE:.spec.suspend | tail -1); verb=$([ $suspended = "true" ] && echo "resume" || echo "suspend"); flux $verb helmrelease --context $CONTEXT -n $NAMESPACE $NAME | less -K''];
    };

    reconcile-hr = {
      shortCut = "Shift-R";
      confirm = false;
      description = "Flux reconcile";
      scopes = ["helmreleases"];
      command = "bash";
      background = false;
      args = ["-c" "flux reconcile helmrelease --context $CONTEXT -n $NAMESPACE $NAME | less -K"];
    };

    get-suspended-helmreleases = {
      shortCut = "Shift-S";
      confirm = false;
      description = "Suspended Helm Releases";
      scopes = ["helmrelease"];
      command = "sh";
      background = false;
      args = ["-c" ''kubectl get --context $CONTEXT --all-namespaces helmreleases.helm.toolkit.fluxcd.io -o json | jq -r '.items[] | select(.spec.suspend==true) | [.metadata.namespace,.metadata.name,.spec.suspend] | @tsv' | less -K''];
    };

    # Flux - Kustomization
    toggle-kustomization = {
      shortCut = "Shift-T";
      confirm = true;
      scopes = ["kustomizations"];
      description = "Toggle suspend/resume Kustomization";
      command = "bash";
      background = false;
      args = ["-c" ''suspended=$(kubectl --context $CONTEXT get kustomizations -n $NAMESPACE $NAME -o=custom-columns=TYPE:.spec.suspend | tail -1); verb=$([ $suspended = "true" ] && echo "resume" || echo "suspend"); flux $verb kustomization --context $CONTEXT -n $NAMESPACE $NAME | less -K''];
    };

    reconcile-ks = {
      shortCut = "Shift-R";
      confirm = false;
      description = "Flux reconcile";
      scopes = ["kustomizations"];
      command = "bash";
      background = false;
      args = ["-c" "flux reconcile kustomization --context $CONTEXT -n $NAMESPACE $NAME | less -K"];
    };

    get-suspended-kustomizations = {
      shortCut = "Shift-S";
      confirm = false;
      description = "Suspended Kustomizations";
      scopes = ["kustomizations"];
      command = "sh";
      background = false;
      args = ["-c" ''kubectl get --context $CONTEXT --all-namespaces kustomizations.kustomize.toolkit.fluxcd.io -o json | jq -r '.items[] | select(.spec.suspend==true) | [.metadata.name,.spec.suspend] | @tsv' | less -K''];
    };

    # Flux - Sources
    reconcile-git = {
      shortCut = "Shift-R";
      confirm = false;
      description = "Flux reconcile";
      scopes = ["gitrepositories"];
      command = "bash";
      background = false;
      args = ["-c" "flux reconcile source git --context $CONTEXT -n $NAMESPACE $NAME | less -K"];
    };

    reconcile-helm-repo = {
      shortCut = "Shift-Z";
      description = "Flux reconcile";
      scopes = ["helmrepositories"];
      command = "bash";
      background = false;
      confirm = false;
      args = ["-c" "flux reconcile source helm --context $CONTEXT -n $NAMESPACE $NAME | less -K"];
    };

    reconcile-oci-repo = {
      shortCut = "Shift-Z";
      description = "Flux reconcile";
      scopes = ["ocirepositories"];
      command = "bash";
      background = false;
      confirm = false;
      args = ["-c" "flux reconcile source oci --context $CONTEXT -n $NAMESPACE $NAME | less -K"];
    };

    # Flux - Images
    reconcile-ir = {
      shortCut = "Shift-R";
      confirm = false;
      description = "Flux reconcile";
      scopes = ["imagerepositories"];
      command = "sh";
      background = false;
      args = ["-c" "flux reconcile image repository --context $CONTEXT -n $NAMESPACE $NAME | less -K"];
    };

    reconcile-iua = {
      shortCut = "Shift-R";
      confirm = false;
      description = "Flux reconcile";
      scopes = ["imageupdateautomations"];
      command = "sh";
      background = false;
      args = ["-c" "flux reconcile image update --context $CONTEXT -n $NAMESPACE $NAME | less -K"];
    };

    # Flux - Trace
    trace = {
      shortCut = "Shift-P";
      confirm = false;
      description = "Flux trace";
      scopes = ["all"];
      command = "bash";
      background = false;
      args = ["-c" ''resource=$(echo $RESOURCE_NAME | sed -E 's/ies$/y/' | sed -E 's/ses$/se/' | sed -E 's/(s|es)$//g'); flux trace --context $CONTEXT --kind $resource --api-version $RESOURCE_GROUP/$RESOURCE_VERSION --namespace $NAMESPACE $NAME | less -K''];
    };

    # Helm
    helm-default-values = {
      shortCut = "Shift-V";
      confirm = false;
      description = "Chart Default Values";
      scopes = ["helm"];
      command = "sh";
      background = false;
      args = ["-c" ''revision=$(helm history -n $NAMESPACE --kube-context $CONTEXT $COL-NAME | grep deployed | cut -d$'\t' -f1 | tr -d ' \t'); kubectl get secrets --context $CONTEXT -n $NAMESPACE sh.helm.release.v1.$COL-NAME.v$revision -o yaml | yq e '.data.release' - | base64 -d | base64 -d | gunzip | jq -r '.chart.values' | yq -P | less -K''];
    };

    # Utilities
    remove_finalizers = {
      shortCut = "Ctrl-F";
      confirm = true;
      dangerous = true;
      scopes = ["all"];
      description = "Remove all finalizers";
      command = "kubectl";
      background = true;
      args = ["patch" "--context" "$CONTEXT" "--namespace" "$NAMESPACE" "$RESOURCE_NAME.$RESOURCE_GROUP" "$NAME" "-p" ''{"metadata":{"finalizers":null}}'' "--type" "merge"];
    };

    krr = {
      shortCut = "Shift-K";
      description = "Get resource recommendations";
      scopes = ["deployments" "daemonsets" "statefulsets"];
      command = "bash";
      background = false;
      confirm = false;
      args = ["-c" ''LABELS=$(kubectl get $RESOURCE_NAME $NAME -n $NAMESPACE --context $CONTEXT --show-labels | awk '{print $NF}' | awk '{if(NR>1)print}'); krr simple --cluster $CONTEXT --selector $LABELS; echo "Press 'q' to exit"; while : ; do read -n 1 k <&1; if [[ $k = q ]] ; then break; fi; done''];
    };
  };
}
