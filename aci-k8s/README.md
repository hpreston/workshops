# ACI + Kubernetes Lab Guide
In the world of application development and micro services Kubernetes is fast becoming THE standard for an “infrastructure platform”.  Envisioned and kicked off by Google, and embraced by everyone from Amazon, Docker, Microsoft and Cisco, Kubernetes is being adopted by customers large and small. Strangely enough, core Kubernetes completely lacks any embedded network solution, leaving it open to the community and customers to fill, what an opportunity for network engineers and Cisco.  In this workshop, you’ll get hands on with the Cisco ACI Plugin to Kubernetes for integrating the application policy model directly into the applications running within Kubernetes.  You’ll see how the integration is established, dive into deploying applications with Kubernetes and ACI, and the operational visibility and power when these tools are combined.  When the session is over, you’ll be able to continue the exploration on your own leveraging the workshop resources and hosted platform provided by DevNet!

* [Lab Setup](#lab-setup)
* [ACI and Kubernetes Integration Walkthrough](#aci-and-kubernetes-integration-walkthrough)
* [No Policy Applications](#no-policy-application)
* [Namespace Segmentation Applications](#namespace-segmentation-application)
* [Deployment Level Segmentation Applications](#deployment-level-segmentation-application)
* [Lab Cleanup](#lab-cleanup)

# Lab Setup

1. Establish VPN connection to your assigned pod.  
2. Open a terminal window and SSH to the Development Workstation for your Pod.  The IP address, username and password are provided in your pod info.  

    ```bash
    ssh developer@IP-ADDRESS
    ```

1. Clone the sample lab code down to your workstation.  And change to the lab directory.  

    ```bash
    git clone https://github.com/hpreston/ciscolive_workshops
    cd ciscolive_workshops/aci-k8s
    ```

1. Create a Python virtual environment, activate, and install the requirements.  

    ```bash
    virtualenv venv
    source venv/bin/activate
    pip install -r requirements.txt
    ```

1. Create a copy of the Ansible host_vars template for the APIC.  

    ```bash
    cp host_vars/apic1.yaml.temp host_vars/apic1.yaml
    ```

1. Open the `host_vars/apic1.yaml` file and provide your pod username, password and number.  ***For `podnum`, just provide the 2 digit value. Example below***

    ```yaml
    username: hapresto
    password: yUkafiK
    podnum: "04"
    ```

3. From a web browser, connect to the APIC Controller at [https://10.10.20.12](https://10.10.20.12).  Use the username and password from your pod info.  

# ACI and Kubernetes Integration Walkthrough

1. From the web browser and APIC...
1. Navigate to `Tenants > kubesbxXX` for your assigned Pod number.
1. Expand `Application Profiles > kubernetes > EPGs`
1. You will see three EPGs listed.  
    * `kube-default` - Where deployed pods without any explicit policy assignment
    * `kube-nodes` - Where the main "node-interface" for kubernetes master and nodes connect to fabric
    * `kube-system` - Where Kubernetes management elements are connected (ie kube-dns)
1. Explore the `Operational` view of each EPG to see what is present so far.
2. Expand `Networking > Bridge Domains`.  You'll see two BDs configured.  
    * `kube-node-bd` provides IP space for the Kubernetes master and nodes.  
    * `kube-pod-bd` provides IP space for all running containers.   
1. From your SSH connection...
2. View the running pods from namespace `kube-system`.  

    ```bash
    kubectl -n kube-system get pods
    NAME                                              READY     STATUS    RESTARTS   AGE
    aci-containers-controller-3029831268-9hhdf        1/1       Running   0          7d
    aci-containers-host-3rjm1                         3/3       Running   0          7d
    aci-containers-host-bdm23                         3/3       Running   0          7d
    aci-containers-host-x9bqk                         3/3       Running   0          7d
    aci-containers-openvswitch-47cq6                  1/1       Running   0          7d
    aci-containers-openvswitch-549wd                  1/1       Running   0          7d
    aci-containers-openvswitch-qw11x                  1/1       Running   0          7d
    etcd-sbx04kube01.localdomain                      1/1       Running   0          7d
    kube-apiserver-sbx04kube01.localdomain            1/1       Running   0          7d
    kube-controller-manager-sbx04kube01.localdomain   1/1       Running   0          7d
    kube-dns-2617979913-wm0x9                         3/3       Running   0          7d
    kube-proxy-26rtt                                  1/1       Running   0          7d
    kube-proxy-4q1r3                                  1/1       Running   0          7d
    kube-proxy-phfft                                  1/1       Running   0          7d
    kube-scheduler-sbx04kube01.localdomain            1/1       Running   0          7d
    ```

    * The pods starting with `aci-containers` control the integration to ACI and provide the local network enforcement on each node.  
    * You'll see `kube-dns-` listed.  This provides internal cluster DNS resolution.  Also seen in the ACI interface.  
1. Run the command `kubectl -n kube-system logs aci-containers-controller-3029831268-9hhdf` but use the actual pod name for your pod.  This will show you the log messages for the CNI integration.  

    ```bash
    time="2018-07-30T19:52:48Z" level=info msg="Starting status server"
    time="2018-07-30T19:52:48Z" level=info msg="Connecting to APIC" host=10.10.20.12
    time="2018-07-30T19:52:49Z" level=info msg="Starting APIC full sync"
    time="2018-07-30T19:52:49Z" level=info msg="APIC full sync completed" deletes=0 updates=20
    ```

1. Back on the APIC...
1. Navigate to `Virtual Networking > Container Domains > Kubernetes > kubesbxXX` for your Pod.  
2. Expand out Nodes and Namespaces.  See how ACI has visibility into Kubernetes.  
3. Expand `kube-system > Deployments`

## Section Summary and Key Points

By running the ACI Integration scripts and preparation, the ACI fabric and policy are prepped with the VMM domain, Tenant, APs, EPGs, and BDs, needed for the integration.  It also creates a Kubernetes deployment file that can be applied to the Kubernetes cluster to start the `aci-containers-controller` deployment that will complete the integration.  


# No Policy Applications

One of the key values of the ACI K8s integration is that applications can be deployed to Kubernetes just like any other environment with no changes needed by the deveoloper.  Let's deploy a basic, no-policy application.  

1. On the development ssh terminal...
2. Change into the `myhero` `app_definition` directory.  

```bash
cd app_definitions/myhero

ls

myhero_app.yaml    myhero_install.sh  myhero_uninstall.sh
myhero_data.yaml   myhero_mosca.yaml  README.md
myhero_ernst.yaml  myhero_ui.yaml
```

1. Inside you will find `.yaml` files that provide the K8s application definitions for the micro-service application "MyHero".  There are also install and uninstall scripts.  
2. Look at the contents of the `myhero_data.yaml` definition.  This is a standard K8s definition with no ACI specific changes made.  
3. To install this application, the definitions need to be `applied` to the cluster.  This will build the `deployments` and `services` for the application.  
4. Take a look at the `myhero_install.sh` file and notice the `kubectl apply` commands.  This is what installs the application.  
    * *Note: The `myhero_ui` micro service needs to know the public address assigned to the `myhero-app` service to connect to. The install script updates the definition automatically before applying.*
5. Run the `myhero_install.sh` command.  

    ```bash
    ./myhero_install.sh

    Installing the MyHero Sample Application
    service "myhero-data" created
    deployment "myhero-data" created
    service "myhero-mosca" created
    deployment "myhero-mosca" created
    deployment "myhero-ernst" created
    service "myhero-app" created
    deployment "myhero-app" created
    service "myhero-ui" created
    deployment "myhero-ui" created
    ```

1. You can use the following commands to monitor the deployment and status.  
    * `kubectl get deployments`
    * `kubectl get pods`
    * `kubectl get services`
    * `kubectl describe pod PODID`

1. With `kubectl get services`, find the `EXTERNAL-IP` address for the `myhero-ui` service.  Open this address in another tab in your browser.  
1. The external-ip is available via the loadbalancing and NAT features of the ACI fabric.  
1. On the ACI GUI, navigate to `Tenants > common > Networking > External Routed Networks > sbx_shared_L3Out > Networks`.  
2. You'll see entries for `kubesbxXX_svc_default_myhero-app` and `kubesbxXX_svc_default_myhero-ui`
3. If you click on the UI entry and look under "Subnets" in the policy, you'll find the `EXTERNAL-IP` listed.  
4. The load-balancing is auto created by the CNI plugin.  Other policy elements to view are:
    * `Tenants > common > Policies > L4-L7 Policy Based Redirect`
    * `Tenants > common > Services > L4-L7`
        * `Service Graph Templates`
        * `Devices`
        * `Devices Selection Policies`
        * `Deployed Graph Instances`
1. Navigate to `Tenants > kubesbxXX > Application Profiles > kubernetes > Application EPGs > kube-default` and look at the Operational tab.  You'll see entries for each pod running including which node, IP, encap, etc.
1. Now uninstall the application so we can apply some policy.  From the ssh terminal.

    ```bash
    ./myhero_uninstall.sh

    Uninstalling the MyHero Demo Application
    service "myhero-ui" deleted
    service "myhero-app" deleted
    service "myhero-data" deleted
    service "myhero-mosca" deleted
    deployment "myhero-ui" deleted
    deployment "myhero-app" deleted
    deployment "myhero-ernst" deleted
    deployment "myhero-mosca" deleted
    deployment "myhero-data" deleted
    ```

1. Let's check the logs on the `aci-controller` again to see that it has been keeping ACI in sync with Kubernetes changes.

    ```bash
    # first to get the pod name
    kubectl -n kube-system get pods | grep aci-containers-controller

    aci-containers-controller-3029831268-9hhdf        1/1       Running   0          7d

    # Now use that name to retrieve the logs
    kubectl -n kube-system logs aci-containers-controller-3029831268-9hhdf
    ```

## Section Summary and Key Points

Here we saw how to deploy a Kubernetes application with no difference from any other K8s setup, and how ACI provides visibility and integrated load balancing.  

# Namespace Segmentation Applications

In many container platforms today, all deployed containers exist in a single "security segment".  Or if some segmentation is supported, it often requires different container hosts per "zone".  

One of the main benefits of the ACI Kubernetes Integration is the ability to have robust network segmentation applied.  

In this first type of segmentation, all pods within a **Kubernetes Namespace** exist in the same security zone and policy.  (Namespaces are a way to organize applications within Kubernetes, and allow for quotas and other policies).  Within ACI, this is done by creating a new EPG and linking it to the Kubernetes Namespace.  Then all pods deployed in the namespace will be part of this new EPG, and not the `kube-default` EPG.  

1. First we must create the EPG and associated policies within ACI.  To simplify this, an Ansible playbook is provided.  
2. On the SSH terminal, return back to the `ciscolive_workshops/aci-k8s` directory.  You should find 2 `.yaml` files.  

    ```bash
    ls *.yaml
    aci_myhero_app_setup.yaml  aci_namespace_setup.yaml
    ```

3. Run the `aci_namespace_setup.yaml` playbook.  

    ```bash
    ansible-playbook aci_namespace_setup.yaml

    PLAY [Setup Management EPG for Sandbox] ****************************************

    TASK [Create Namespace EPG] ****************************************************
    changed: [apic1]

    TASK [Add Kubernetes VMM Domain to EPG] ****************************************
    changed: [apic1]

    TASK [Add Standard Contracts] **************************************************
    changed: [apic1] => (item={u'type': u'consumer', u'name': u'icmp'})
    changed: [apic1] => (item={u'type': u'consumer', u'name': u'dns'})
    changed: [apic1] => (item={u'type': u'provider', u'name': u'health-check'})
    changed: [apic1] => (item={u'type': u'consumer', u'name': u'kubesbx04-l3out-allow-all'})

    PLAY RECAP *********************************************************************
    apic1                      : ok=3    changed=3    unreachable=0    failed=0
    ```

1. Check the APIC GUI, you should now have a new EPG `ns-myhero` under the `kubernetes` Application Profile.  
    * It is assigned the VMM domain for your Kubernetes setup
    * It has the standard contracts needed for K8s functionality

1. Now create the Kubernetes Namespace for `myhero`

    ```bash
    kubectl create namespace myhero

    kubectl get namespaces
    ```

1. Now you need to tell the ACI Controller to assign all pods to the EPG that was created.  This is done with `annotations` in Kubernetes.  Annotations are meta-data that Kubernetes itself does NOT use, but can be read by plugins and tools, such as CNI plugins.  
2. Use the following command **BUT UPDATED THE TENANT NAME** to provide the linkage.  

```bash
kubectl annotate namespace myhero \
  opflex.cisco.com/endpoint-group='{"tenant": "kubesbxXX", "app-profile": "kubernetes", "name": "ns-myhero"}' \
  --overwrite
```

1. Verify the annotation with `kubectl describe namespace myhero`

    ```bash
    myhero
    Name:		myhero
    Labels:		<none>
    Annotations:	opflex.cisco.com/endpoint-group={"tenant": "kubesbx04", "app-profile": "kubernetes", "name": "ns-myhero"}
    Status:		Active

    No resource quota.

    No resource limits.
    ```

    * If the tenant is listed as `"tenant": "kubesbxXX"` re-run the command with the correct tenant name

1. Now re-install the MyHero Application into the `myhero` namespace and EPG.  
2. Change into the `myhero-namespace-policy` app definition directory.  

    ```bash
    cd app_definitions/myhero-namespace-policy/
    ```

1. The only difference in this deployment is that the `kubectl apply` commands will specify `-n myhero` to deploy the application into the correct namespace.  Run `./myhero_install.sh` to install the application.  

    ```bash
    Installing the MyHero Sample Application
    service "myhero-data" created
    deployment "myhero-data" created
    service "myhero-mosca" created
    deployment "myhero-mosca" created
    deployment "myhero-ernst" created
    service "myhero-app" created
    deployment "myhero-app" created
    service "myhero-ui" created
    deployment "myhero-ui" created
    ```
1. Verify that the application is in the correct namespace with these commands.  

    ```bash
    # first check `default` namespace
    kubectl get pods

    No resources found.

    # now check the myhero namespace
    kubectl -n myhero get pods

    NAME                            READY     STATUS    RESTARTS   AGE
    myhero-app-1608251026-crd3j     1/1       Running   0          1m
    myhero-app-1608251026-sw3zw     1/1       Running   0          1m
    myhero-app-1608251026-wn8wd     1/1       Running   0          1m
    myhero-data-2347389596-k4pt5    1/1       Running   0          1m
    myhero-ernst-3425573530-kck3d   1/1       Running   0          1m
    myhero-mosca-793212554-07xg5    1/1       Running   0          1m
    myhero-ui-240751480-67tsb       1/1       Running   0          1m
    myhero-ui-240751480-dz0wc       1/1       Running   0          1m
    ```

1. Let's verify the application is still working.  Get the `EXTERNAL-IP` for myhero-ui and open a web tab to it.  

    ```bash
    kubectl -n myhero get service myhero-ui
    ```

1. In the APIC GUI, verify that the Pods show up in the Operational view for the `ns-myhero` EPG.  

1. Now let's verify that the segmentation is working as expected by trying to access one of the MyHero services from the "default" namespace.  
1. Open a second terminal window, and ssh into the Developer Workstation again (you'll want 2 terminals active).
2. On the new terminal, run this command to start and connect to a running container in the default namespace. *It may take a minute to launch*

    ```bash
    kubectl -n default run -i --tty devbox \
      --image=hpreston/devbox \
      --restart=Never --rm -- /bin/bash
    ```

1. You should now have a prompt like below.  You are in a running pod called "devbox" in the default namespace.  

    ```bash
    [root@devbox coding]#
    ```

1. In the first terminal window, run this command to verify the new pod and location.  

    ```bash
    kubectl get pods

    NAME      READY     STATUS    RESTARTS   AGE
    devbox    1/1       Running   0          1m
    ```

1. In the first terminal window, run this command to get the POD IPs for the MyHero Application.  Make a note of the IP assigned to one of the `myhero-app` pods.  

    ```bash
    kubectl -n myhero get pods -o wide
    NAME                            READY     STATUS    RESTARTS   AGE       IP             NODE
    myhero-app-1608251026-crd3j     1/1       Running   0          9m        10.204.0.167   sbx04kube02.localdomain
    myhero-app-1608251026-sw3zw     1/1       Running   0          9m        10.204.0.166   sbx04kube02.localdomain
    myhero-app-1608251026-wn8wd     1/1       Running   0          9m        10.204.1.38    sbx04kube03.localdomain
    myhero-data-2347389596-k4pt5    1/1       Running   0          9m        10.204.1.36    sbx04kube03.localdomain
    myhero-ernst-3425573530-kck3d   1/1       Running   0          9m        10.204.1.37    sbx04kube03.localdomain
    myhero-mosca-793212554-07xg5    1/1       Running   0          9m        10.204.0.165   sbx04kube02.localdomain
    myhero-ui-240751480-67tsb       1/1       Running   0          9m        10.204.0.168   sbx04kube02.localdomain
    myhero-ui-240751480-dz0wc       1/1       Running   0          9m        10.204.1.39    sbx04kube03.localdomain
    ```

1. On the second terminal with the running container, try to ping the IP of the `myhero-app` pod.  

    ```bash
    [root@devbox coding]# ping 10.204.0.167
    PING 10.204.0.167 (10.204.0.167) 56(84) bytes of data.
    ^C
    --- 10.204.0.167 ping statistics ---
    6 packets transmitted, 0 received, 100% packet loss, time 5000ms
    ```

1. Try to make an API call to the `myhero-app` service.  ***Replace the IP with the IP for your pod.***  Use `Cntl-C` to cancel when it doesn't work.  

    ```bash
    curl -H "key: SecureApp" 10.204.1.14:5000/options
    ```

1. Type `exit` to end the container in the default namespace.  
2. Now start a new container, but this time in the `myhero` namespace.  

    ```bash
    kubectl -n myhero run -i --tty devbox \
      --image=hpreston/devbox \
      --restart=Never --rm -- /bin/bash
    ```

1. On the first terminal, now check that `devbox` is running in `myhero`

    ```bash
    kubectl -n myhero get pods
    NAME                            READY     STATUS    RESTARTS   AGE
    devbox                          1/1       Running   0          24s
    myhero-app-1608251026-crd3j     1/1       Running   0          15m
    myhero-app-1608251026-sw3zw     1/1       Running   0          15m
    myhero-app-1608251026-wn8wd     1/1       Running   0          15m
    myhero-data-2347389596-k4pt5    1/1       Running   0          15m
    myhero-ernst-3425573530-kck3d   1/1       Running   0          15m
    myhero-mosca-793212554-07xg5    1/1       Running   0          15m
    myhero-ui-240751480-67tsb       1/1       Running   0          15m
    myhero-ui-240751480-dz0wc       1/1       Running   0          15m
```

1. Try to ping the IP for the myhero-app pod.  

    ```bash
    [root@devbox coding]#  ping 10.204.0.167
    PING 10.204.0.167 (10.204.0.167) 56(84) bytes of data.
    64 bytes from 10.204.0.167: icmp_seq=1 ttl=64 time=3.05 ms
    64 bytes from 10.204.0.167: icmp_seq=1 ttl=64 time=3.51 ms (DUP!)
    64 bytes from 10.204.0.167: icmp_seq=1 ttl=64 time=3.64 ms (DUP!)
    64 bytes from 10.204.0.167: icmp_seq=1 ttl=64 time=3.66 ms (DUP!)
    64 bytes from 10.204.0.167: icmp_seq=2 ttl=64 time=5.85 ms
    64 bytes from 10.204.0.167: icmp_seq=2 ttl=64 time=5.85 ms (DUP!)
    64 bytes from 10.204.0.167: icmp_seq=2 ttl=64 time=6.56 ms (DUP!)
    64 bytes from 10.204.0.167: icmp_seq=2 ttl=64 time=6.56 ms (DUP!)
    ^C
    --- 10.204.0.167 ping statistics ---
    2 packets transmitted, 2 received, +6 duplicates, 0% packet loss, time 1001ms
    rtt min/avg/max/mdev = 3.052/4.839/6.565/1.406 ms
    ```

1. And try the API call.  

    ```bash
    [root@devbox coding]# curl -H "key: SecureApp" 10.204.0.167:5000/options
    {
        "options": [
            "Captain Cloud",
            "Spider-Man",
            "Captain America",
            "Batman",
            "Superman",
            "Wonder Woman",
            "Deadpool",
            "Black Widow",
            "Iron Man",
            "Star-Lord",
            "Scarlet Witch",
            "Gamora"
        ]
    }
    ```

1. Exit out of the testing pod with `exit`

1. Now that this testing is done, go ahead and uninstall the application with the uninstall script.  

    ```bash
    ./myhero_uninstall.sh
    Uninstalling the MyHero Demo Application
    service "myhero-ui" deleted
    service "myhero-app" deleted
    service "myhero-data" deleted
    service "myhero-mosca" deleted
    deployment "myhero-ui" deleted
    deployment "myhero-app" deleted
    deployment "myhero-ernst" deleted
    deployment "myhero-mosca" deleted
    deployment "myhero-data" deleted
    ```

## Section Summary and Key Points

In this section we saw how we can use the ACI CNI plugin to provide network segmentation at the namespace level.  By having all running containers part of a single EPG in ACI, you have the full power of policy and operational visibility of ACI for all your micro-service applications.  

# Deployment Level Segmentation Applications

Namespace level segmentation is great, but many enterprises are looking for tighter security and segmentation.  What if the frontend web service for an application becomes compromised, controlling access to critical backend services like data can prevent a breach from spreading.  

In this section we'll see how the ACI CNI plugin provides the ability to segment at the Kubernetes Deployment level as well.  This is done be applying annotations to the deployment definition.  

1. Before we can deploy an application with deployment level segmentation, we need to have the ACI policy setup.  This means EPGs for each deployment (ie micro service), and associated contracts controlling policy.  
2. On the SSH terminal, return back to the `ciscolive_workshops/aci-k8s` directory.  You should find 2 `.yaml` files.  

    ```bash
    ls *.yaml
    aci_myhero_app_setup.yaml  aci_namespace_setup.yaml
    ```

3. Run the `aci_myhero_app_setup.yaml` playbook.  

    ```bash
    ansible-playbook aci_myhero_app_setup.yaml

    # OUTPUT EDITED FOR GUIDE
    PLAY [Setup Management EPG for Sandbox] ****************************************

    TASK [Create Filters] **********************************************************

    TASK [Create Filter Entries] ***************************************************

    TASK [Create Contracts] ********************************************************

    TASK [Create Contract Subjects] ************************************************

    TASK [Create Contract Subject Filters] *****************************************

    TASK [Create Application Profile] **********************************************

    TASK [Create EPGs] *************************************************************

    TASK [Bind Kubernetes Domain to EPG] *******************************************

    TASK [Setup Contracts on EPGs] *************************************************

    PLAY RECAP *********************************************************************
    apic1                      : ok=9    changed=4    unreachable=0    failed=0
    ```

1. On the APIC GUI, you'll find a new Application Profile called `myhero` with EPGs for each of the application services.  
2. You can explore the application policy via the APIC GUI but the key element is that the `myhero-ui` EPG **cannot** directly communicate with the `myhero-data` EPG.  
3. Change to the `myhero-deployment-policy` application definition folder.  

```bash
cd app_definitions/myhero-deployment-policy/
```

1. Take a look at the file `myhero_data.template`.  Under the `metadata` for the deployment, you'll see the `annotations` section.  Here is where this deployment will be tied to the desired EPG.  

    ```yaml
    ---
    apiVersion: extensions/v1beta1
    kind: Deployment
    metadata:
      name: myhero-data
      annotations:
        opflex.cisco.com/endpoint-group: '{"tenant":"kubesbxXX","app-profile":"myhero","name":"myhero-data"}'
    .
    .
    ```

1. Before the application definitions can be applied, the templates need to be updated for the correct tenant/pod number.  The install script will ask for your Pod Number, provide the 2 digit pod number when prompted.  

    ```bash
    # Example
    ./myhero_install.sh

    What is your Pod Number?
    04
    Pod Num: 04
    Installing the MyHero Sample Application
    service "myhero-data" created
    deployment "myhero-data" created
    service "myhero-mosca" created
    deployment "myhero-mosca" created
    deployment "myhero-ernst" created
    service "myhero-app" created
    deployment "myhero-app" created
    service "myhero-ui" created
    deployment "myhero-ui" created
    ```

1. Verify that the application is running and find the `EXTERNAL-IP` for the `myhero-ui`.
    * `kubectl -n myhero get deployments`
    * `kubectl -n myhero get pods`
    * `kubectl -n myhero get services`
1. In a web browser, navigate to the UI service to verify that it is running.  
2. In APIC, check the Operational details for the EPGs to see that the pods are where they belong.  
1. Now let's verify the security segmentation is working as expected.  
2. From the 2nd terminal window to the developer workstation, start an interactive container within the `myhero` namespace.  

    ```bash
    kubectl -n myhero run -i --tty devbox \
      --image=hpreston/devbox \
      --restart=Never --rm -- /bin/bash
    ```

1. It will initially be placed in the `ns-myhero` EPG that is linked to the namespace.  Use this command in the first terminal window to re-assign it to the `myhero-ui` EPG.  **YOU MUST CHANGE THE TENANT TO MATCH YOUR POD**

    ```bash
    kubectl -n myhero annotate pod devbox \
      opflex.cisco.com/endpoint-group='{"tenant":"kubesbxXX","app-profile":"myhero","name":"myhero-ui"}' \
      --overwrite
    ```

1. Use the APIC GUI to verify that both the `myhero-ui` and `devbox` pods are showing up in the Operational view of the `myhero-ui` EPG.  
1. On the first terminal, find the IP addresses for the running pods.  

    ```bash
    kubectl -n myhero get pods -o wide

    NAME                            READY     STATUS    RESTARTS   AGE       IP             NODE
    devbox                          1/1       Running   0          2m        10.204.1.45    sbx04kube03.localdomain
    myhero-app-1608251026-gq22b     1/1       Running   0          11m       10.204.1.44    sbx04kube03.localdomain
    myhero-data-2347389596-rd49m    1/1       Running   0          11m       10.204.1.42    sbx04kube03.localdomain
    myhero-ernst-3425573530-9svdq   1/1       Running   0          11m       10.204.1.43    sbx04kube03.localdomain
    myhero-mosca-793212554-4m35d    1/1       Running   0          11m       10.204.0.169   sbx04kube02.localdomain
    myhero-ui-125035626-0j1x2       1/1       Running   0          11m       10.204.0.170   sbx04kube02.localdomain
    ```

1. `myhero-ui` **SHOULD** be able to communicate with `myhero-app`.  Let's verify it.  From the interactive pod, run this command to make an API call.  *Update the IP to match your IP*

    ```bash
    [root@devbox coding]# curl -H "key: SecureApp" 10.204.1.44:5000/options
    {
        "options": [
            "Captain Cloud",
            "Spider-Man",
            "Captain America",
            "Batman",
            "Superman",
            "Wonder Woman",
            "Deadpool",
            "Black Widow",
            "Iron Man",
            "Star-Lord",
            "Scarlet Witch",
            "Gamora"
        ]
    }
    ```

1. `myhero-ui` **SHOULD NOT** be able to communicate with `myhero-data`.  Let's verify it.  From the interactive pod, run this command to make an API call.  *Update the IP to match your IP*

    ```bash
    [root@devbox coding]# curl -H "key: SecureData" 10.204.1.42:5000/options
    ^C
    ```

1. Now let's move the interactive container from `myhero-ui` to `myhero-app`, which should be able to communicate with `myhero-data`.  This is done by updating the annotation on the pod.  Run this command from the first terminal.  **YOU MUST CHANGE THE TENANT TO MATCH YOUR POD**

    ```bash
    kubectl -n myhero annotate pod devbox \
      opflex.cisco.com/endpoint-group='{"tenant":"kubesbxXX","app-profile":"myhero","name":"myhero-app"}' \
      --overwrite
    ```

1. Verify in the APIC GUI that `devbox` is now in the `myhero-app` EPG.  

1. On the interactive devbox pod, re-run the API call for data.  It should now work.  

    ```bash
    [root@devbox coding]# curl -H "key: SecureData" 10.204.1.42:5000/options
    {
        "options": [
            "Captain Cloud",
            "Spider-Man",
            "Captain America",
            "Batman",
            "Superman",
            "Wonder Woman",
            "Deadpool",
            "Black Widow",
            "Iron Man",
            "Star-Lord",
            "Scarlet Witch",
            "Gamora"
        ]
    }
    ```

1. Exit out of the interactive devbox container with `exit`.  

1. You can see the logs of all the annotation updates by running `kubectl -n kube-system logs aci-containers-controller-3029831268-9hhdf` again.  ***You need the actual name of your pod.  This is available with `kubectl -n kube-system get pods`***

    ```bash
    time="2018-08-07T15:34:35Z" level=info msg="Updated pod annotations" Eg="{\"tenant\":\"kubesbx04\",\"app-profile\":\"myhero\",\"name\":\"myhero-app\"}" Sg="[]" name=devbox namespace=myhero node=sbx04kube03.localdomain
    ```

1. Now uninstall the application.  

    ```bash
    ./myhero_uninstall.sh

    Uninstalling the MyHero Demo Application
    service "myhero-ui" deleted
    service "myhero-app" deleted
    service "myhero-data" deleted
    service "myhero-mosca" deleted
    deployment "myhero-ui" deleted
    deployment "myhero-app" deleted
    deployment "myhero-ernst" deleted
    deployment "myhero-mosca" deleted
    deployment "myhero-data" deleted
    ```

## Section Summary and Key Points

In this section we saw how we can use the ACI CNI plugin for Kubernetes to provide deployment level segmentation and security to applications.  

# Lab Cleanup

Follow these steps to reset the lab to start over.  

1. Run the Ansible playbook to remove additional policy elements created.  

    ```bash
    ansible-playbook aci_labcleanup.yaml

    PLAY [Cleanup ACI Objects from Lab] ********************************************

    TASK [Remove Namespace EPG] ****************************************************

    TASK [Remove Deployment Application Profile] ***********************************

    TASK [Remove Contracts] ********************************************************

    TASK [Remove Filters] **********************************************************

    PLAY RECAP *********************************************************************
    ```

1. Delete the `myhero` namespace from Kubernetes.

    ```bash
    kubectl delete namespace myhero
    ```

1. Remove lab code from Developer workstation by running these commands.  

    ```bash
    cd ~
    rm -Rf ciscolive_workshops
    ```
1. Disconnect from the Developer Workstation, and end the VPN connection.  
