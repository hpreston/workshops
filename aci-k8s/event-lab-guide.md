# ACI + Kubernetes Event Lab Guide

> **This lab guide is intended for use at in person events like Cisco Live and DevNet Create.**  

In the world of application development and micro services Kubernetes is fast becoming THE standard for an “infrastructure platform”.  Envisioned and kicked off by Google, and embraced by everyone from Amazon, Docker, Microsoft and Cisco, Kubernetes is being adopted by customers large and small. Strangely enough, core Kubernetes completely lacks any embedded network solution, leaving it open to the community and customers to fill, what an opportunity for network engineers and Cisco.  In this workshop, you’ll get hands on with the Cisco ACI Plugin to Kubernetes for integrating the application policy model directly into the applications running within Kubernetes.  You’ll see how the integration is established, dive into deploying applications with Kubernetes and ACI, and the operational visibility and power when these tools are combined.  When the session is over, you’ll be able to continue the exploration on your own leveraging the workshop resources and hosted platform provided by DevNet!


* [Lab Preparation](#lab-preparation)
* [ACI and Kubernetes Integration Walkthrough](#aci-and-kubernetes-integration-walkthrough)
* [No Policy Applications](#no-policy-application)
* [Namespace Segmentation Applications](#namespace-segmentation-applications)
* [Deployment Level Segmentation Applications](#deployment-level-segmentation-application)
* [Lab Cleanup](#lab-cleanup)

# Lab Preparation
First up, connect to your lab pod resources.    

1. Open a VPN Connection to the pod.  
2. ssh to the Developer Workstation for the pod.  

    ```bash
    ssh developer@IP-ADDRESS
    ```

1. Verify Kubernetes setup. 

	> Run from the SSH terminal to your Developer Workstation (DevBox)

	```bash
	# Ensure all are "Ready"
	kubectl get nodes
	
	# Make sure all are "Running"
	kubectl get pods --all-namespaces
	```

1. Open a web GUI connection to ACI at [https://10.10.20.12](https://10.10.20.12). Login as Pod user and navigate to `Tenants > kubesbx##` for your pod number.  


# ACI and Kubernetes Integration Walkthrough

1. From the web browser and APIC...
1. Navigate to `Tenants > kubesbxXX` for your assigned Pod number.
1. Expand `Application Profiles > kubernetes > EPGs`
1. You will see three `kube-` EPGs listed.  
    * `kube-default` - Where deployed pods without any explicit policy assignment
    * `kube-nodes` - Where the main "node-interface" for kubernetes master and nodes connect to fabric
    * `kube-system` - Where Kubernetes management elements are connected (ie kube-dns)

	> The `ns-myhero` EPG is used for Namespace Isolation and will be explored more in a bit. 

1. Explore the `Operational` view of `kube-nodes` to see what is present so far.

1. From your SSH connection to the devbox...
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

1. Back on the APIC...
1. Navigate to `Virtual Networking > Container Domains > Kubernetes > kubesbxXX` for your Pod.  
2. Expand out Nodes and Namespaces.  See how ACI has visibility into Kubernetes.  
3. Expand `kube-system > Deployments`

## Section Summary and Key Points

By running the ACI Integration scripts and preparation, the ACI fabric and policy are prepped with the VMM domain, Tenant, APs, EPGs, and BDs, needed for the integration.  It also creates a Kubernetes deployment file that can be applied to the Kubernetes cluster to start the `aci-containers-controller` deployment that will complete the integration.  


# No Policy Applications

One of the key values of the ACI K8s integration is that applications can be deployed to Kubernetes just like any other environment with no changes needed by the deveoloper.  

A basic, no-policy application has been deployed to your cluster.  Let's take a look at it.  

1. On the development ssh terminal...





<!--
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
-->


1. You can use the following commands to look at the components of the application.  
    * `kubectl get deployments`
    * `kubectl get pods`
    * `kubectl get services`
    * `kubectl describe pod PODID`

1. With `kubectl get services`, find the `EXTERNAL-IP` address for the `myhero-ui` service.  Open this address in another tab in your browser.  
1. The external-ip is available via the loadbalancing and NAT features of the ACI fabric.  
1. On the ACI GUI, navigate to `Tenants > common > Networking > External Routed Networks > sbx_shared_L3Out > Networks`.  
2. You'll see entries for `kubesbxXX_svc_default_myhero-app` and `kubesbxXX_svc_default_myhero-ui`
3. If you click on the UI entry and look under "Subnets" in the policy, you'll find the `EXTERNAL-IP` listed.  

1. Navigate to `Tenants > kubesbxXX > Application Profiles > kubernetes > Application EPGs > kube-default` and look at the Operational tab.  You'll see entries for each pod running including which node, IP, encap, etc.

<!--
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
-->
## Section Summary and Key Points

Here we saw how to deploy a Kubernetes application with no difference from any other K8s setup, and how ACI provides visibility and integrated load balancing.  

# Namespace Segmentation Applications

In many container platforms today, all deployed containers exist in a single "security segment".  Or if some segmentation is supported, it often requires different container hosts per "zone".  

One of the main benefits of the ACI Kubernetes Integration is the ability to have robust network segmentation applied.  

In this first type of segmentation, all pods within a **Kubernetes Namespace** exist in the same security zone and policy.  (Namespaces are a way to organize applications within Kubernetes, and allow for quotas and other policies).  Within ACI, this is done by creating a new EPG and linking it to the Kubernetes Namespace.  Then all pods deployed in the namespace will be part of this new EPG, and not the `kube-default` EPG.  

Your pod has an EPG that was created for Namespace Isolation.  Let's check it out. 

1. Check the APIC GUI, you will find an EPG `ns-myhero` under the `kubernetes` Application Profile.  
    * It is assigned the VMM domain for your Kubernetes setup
    * It has the standard contracts needed for K8s functionality

1. Now let's checkout the Kubernetes Namespace for `myhero`.  Remember Namespaces are organizational structures in Kubernetes that will hold objects.  

    ```bash
    kubectl get namespaces
    ```

1. The policy linkage between the EPG and the namespace is done with `annotations` in Kubernetes.  *Annotations are meta-data that Kubernetes itself does NOT use, but can be read by plugins and tools, such as CNI plugins.*  
1. Verify the annotation with `kubectl describe namespace myhero`.  Notice the Annotation value includes your Tenant name as well as the application profile and EPG names.  

    ```bash
    myhero
    Name:		myhero
    Labels:		<none>
    Annotations:	opflex.cisco.com/endpoint-group={"tenant": "kubesbx##", "app-profile": "kubernetes", "name": "ns-myhero"}
    Status:		Active

    No resource quota.

    No resource limits.
    ```

1. Verify that the application deployment in the namespace with these commands.  

    ```bash
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
    
    > Note: You also have the MyHero application running in the `default` namespace in "Cluster Isolation".

1. Let's verify the application is working.  Get the `EXTERNAL-IP` for myhero-ui and open a web tab to it.  

    ```bash
    kubectl -n myhero get service myhero-ui
    ```

1. In the APIC GUI, verify that the Pods show up in the Operational view for the `ns-myhero` EPG.  

1. Now let's verify that the segmentation is working as expected by trying to access one of the MyHero services from the "default" namespace.  

1. Open a second terminal window, and ssh into the Developer Workstation again (you'll want 2 terminals active).

2. On the new terminal, run this command to start and connect to a running container in the default namespace. *It may take a minute to launch*

    ```bash
    kubectl -n default run -i --tty trojanapp \
        --image=hpreston/devbox \
        --restart=Never --rm -- /bin/bash
    ```

1. You should now have a prompt like below.  You are in a running pod called "trojanapp" in the default namespace.  

    ```bash
    [root@trojanapp coding]#
    ```

1. In the first terminal window, run this command to verify the new pod and location in namespace "default".  *`-o wide` provides the IPs of the pods.* 

    ```bash
    kubectl get pods -n default -o wide

    NAME      READY     STATUS    RESTARTS   AGE
    trojanapp    1/1       Running   0          1m
    ```

1. In your "trojanapp" terminal, run this command to show that you can access the "Cluster Isolation" deployed version of Myhero.  

	```bash
	curl -H "key: SecureData" myhero-data/options
	```

	* That's not good... but that's why we run Cluster Isolation.  

1. In the other terminal, run this command to get the IPs for the services in the MyHero Namespace. ***We need to use IPs because DNS in Kubernetes is local to namespaces.***

	```bash
	kubectl -n myhero get services
	
	NAME           CLUSTER-IP        EXTERNAL-IP     PORT(S)          AGE
	myhero-app     192.168.220.237   172.20.20.196   80:32135/TCP     16m
	myhero-data    192.168.220.159   <nodes>         80:30486/TCP     16m
	myhero-mosca   192.168.220.22    <nodes>         1883:31861/TCP   16m
	myhero-ui      192.168.220.146   172.20.20.197   80:31298/TCP     16m
	```

1. On the second terminal with the trojanapp, try to make the API call to `myhero-data` using the `CLUSTER-IP`.  ***Use the IP from YOUR output.***

	```bash
	curl -H "key: SecureData" 192.168.220.159/options
	```

	* Use `Cntl-C` to cancel when it doesn't work.  

1. Great, we've shown that with Namespace Isolation you can't access resources from another Namespace.  But what about securing within a Namespace? 

1. Type `exit` to end the `trojanapp` container in the default namespace.  

2. Now start a new container, but this time in the `myhero` namespace.  This time we are simulating a compromised UI server. 

    ```bash
    kubectl -n myhero run -i --tty pwndui \
      --image=hpreston/devbox \
      --restart=Never --rm -- /bin/bash
    ```

1. On the first terminal, now check that `pwndui ` is running in `myhero`

    ```bash
    kubectl -n myhero get pods
    NAME                            READY     STATUS    RESTARTS   AGE
    pwndui                          1/1       Running   0          24s
    myhero-app-1608251026-crd3j     1/1       Running   0          15m
    myhero-app-1608251026-sw3zw     1/1       Running   0          15m
    myhero-app-1608251026-wn8wd     1/1       Running   0          15m
    myhero-data-2347389596-k4pt5    1/1       Running   0          15m
    myhero-ernst-3425573530-kck3d   1/1       Running   0          15m
    myhero-mosca-793212554-07xg5    1/1       Running   0          15m
    myhero-ui-240751480-67tsb       1/1       Running   0          15m
    myhero-ui-240751480-dz0wc       1/1       Running   0          15m
    ```

1. When the pwndui terminal starts, try to make the API call to `myhero-data` using the `CLUSTER-IP` again.  ***Use the IP from YOUR output.***

	```bash
	curl -H "key: SecureData" 192.168.220.159/options
	```

1. And now that we are in the same namespace, we can use DNS names again.  

	```bash
	curl -H "key: SecureData" myhero-data/options
	```

1. End the `pwndui` terminal. 

	```bash
	[root@pwndui coding]# exit
	```

1. We've shown that Namespace Isolation isn't enough to protect our data resources from compromised web servers (be honest, it'll happen.  With Deployment Isolation, we can protect against this.  


## Section Summary and Key Points

In this section we saw how we can use the ACI CNI plugin to provide network segmentation at the namespace level.  By having all running containers part of a single EPG in ACI, you have the full power of policy and operational visibility of ACI for all your micro-service applications.  

# Deployment Level Segmentation Applications

Namespace level segmentation is great, but many enterprises are looking for tighter security and segmentation.  What if the frontend web service for an application becomes compromised, controlling access to critical backend services like data can prevent a breach from spreading.  

In this section we'll see how the ACI CNI plugin provides the ability to segment at the Kubernetes Deployment level as well.  This is done be applying annotations to the deployment definition.  

1. On the APIC GUI, you'll find an Application Profile called `myhero` with EPGs for each of the application services.  
2. You can explore the application policy via the APIC GUI but the key element is that the `myhero-ui` EPG **cannot** directly communicate with the `myhero-data` EPG.  

1. In the devbox terminal, change to the `myhero-deployment-policy` application definition folder.  

    ```bash
    cd ~/ciscolive_workshops/aci-k8s/app_definitions/myhero-deployment-policy/
    ```

1. The install script will ask for your Pod Number, provide the 2 digit pod number when prompted.  *This is used to configure the Annotations to link the Kubernetes Deployments to the EPGs in your ACI Tenant.*

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

1. This script updates the policies on the Deployments for the Namespace Isolation demo to now be Deployment Isolation.  
1. Verify that the application is still running.  The IP shouldn't have changed, but as a reminder you can find the `EXTERNAL-IP` for the `myhero-ui`.
    * `kubectl -n myhero get deployments`
    * `kubectl -n myhero get pods`
    * `kubectl -n myhero get services`
1. In a web browser, navigate to the UI service to verify that it is running.  (Or just REFRESH the page that is still open)
1. In APIC, check the Operational details for the EPGs to see that the pods are where they belong.  
	* They pods will no longer be listed under the `ns-myhero` EPG 
	* You'll find the pods under the "myhero" Application profile.

1. Now let's verify the security segmentation is working as expected.  


1. Start a new instance of `pwndui` Annotated like it's a regular UI service.  Run these commands in the 2nd terminal you used for the `pwndui` and `trojanapp`.  

	```bash
	# Start a new pwndui as a deployment isolation setup
	kubectl -n myhero run -i --tty pwndui \
	--image=hpreston/devbox \
	--overrides='{
	    "apiVersion": "v1",
	    "metadata": {
	        "annotations": {
	            "opflex.cisco.com/endpoint-group": "{\"tenant\":\"kubesbx'${POD_NUM}'\",\"app-profile\":\"myhero\",\"name\":\"myhero-ui\"}"
	        }
	    }
	}' \
	--restart=Never --rm -- /bin/bash
	```

1. Use the APIC GUI to verify that both the `myhero-ui` and `pwndui` pods are showing up in the Operational view of the `myhero-ui` EPG.  

1. `myhero-ui` **SHOULD** be able to communicate with `myhero-app`.  Let's verify it.  From the interactive pod, run this command to make an API call.  

    ```bash
    [root@pwndui coding]# curl -H "key: SecureApp" myhero-app/options
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

1. `myhero-ui` **SHOULD NOT** be able to communicate with `myhero-data`.  Let's verify it.  From the interactive pod, run this command to make an API call. 

    ```bash
    [root@devbox coding]# curl -H "key: SecureData" myhero-data/options
    ^C
    ```

1. Exit out of the interactive pwndui container with `exit`.  


## Section Summary and Key Points

In this section we saw how we can use the ACI CNI plugin for Kubernetes to provide deployment level segmentation and security to applications.  

<!-- Use the master cleanup playbook to reset

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
-->
