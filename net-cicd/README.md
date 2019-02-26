# NetDevOps CICD Lab 

> This workshop is designed to be run as a guided hands-on lab.  The instructions are not currently setup for independent execution.  

## Resources and Pre-Requisites

* [DevNet Mult-IOS Sandbox](https://devnetsandbox.cisco.com/RM/Diagram/Index/6b023525-4e7f-4755-81ae-05ac500d464a?diagramType=Topology)
* MacOS or Linux Workstation 

# Lab Setup 

1. Reserve a Sandbox
1. Connect to Sandbox VPN Connection 
1. SSH to the devbox and run this command to clone down the repo and setup the lab environment.  

	```bash
	curl -o setup.sh \
	  https://raw.githubusercontent.com/hpreston/ciscolive_workshops/master/net-cicd/setup.sh && \
	  chmod +x setup.sh && \
	  ./setup.sh
	```
	
	* It'll take several minutes to complete 

# Lab Guide

## Explore the Network

1. Navigate to [GitLab](http://10.10.20.20/developer/cicd-3tier). Checkout the diagram.
1. Open a terminal and clone down the repository locally.  

	```bash
	cd ~/
	git clone http://developer@10.10.20.20/developer/cicd-3tier
	cd cicd-3tier
	```

1. Configure the local git user for the repo.  

	```bash
	git config --local user.name "developer"
	git config --local user.email "developer@devnetsandbox.cisco.com"
	```

1. 	First setup local python environment 

	```bash
	python3.6 -m venv venv 
	source venv/bin/activate 
	pip install -r requirements.txt 
	```

1. Use virlutils to connect and see the test and prod networks.  

	```bash
	./localize.sh
	
	cd virl/test 
	virl nodes 
	
	cd ../prod 
	virl nodes 
	
	cd ../..
	```

	* Use `virl ssh NODE` to connect and checkout the configurations on devices 

1. Configuration Management is done with NSO and Ansible working together.  
	* Explore the files in `~/cicd-3tier/host_vars` and `~/cicd-3tier/site.yaml` for the playbooks and variables that drive configuration.  
	* Connect to NSO CLI to explore the current configurations. Credentials are `admin / admin`.

		```bash
		ssh admin@10.10.20.20 -p 2024 
		! change to Cisco CLI 
		switch cli 
		
		! Look at the configuration on test-dist1 
		show running-config devices device test-dist1 config 
		
		! Look at the configuration on core1
		show running-config devices device core1 config 
		
		! exit
		exit
		```
		
1. Let's suppose we made a change to the configuration and wanted to manually update the network.  
	
	* Run the Ansible Playbook against the test network. 

		```bash
		ansible-playbook -i inventory/test.yaml site.yaml
		```
		
	* Now run it against the prod network. 

		```bash
		ansible-playbook -i inventory/prod.yaml site.yaml
		```
	
	* _Note: You maynot see any changes made because we didn't actually update the configuration._ 

	* Then you'd need to run whatever manual verification steps necessary to make sure the configuration change was successful.  

## Building the NetDevOps CICD Pipeline 

Our goal now is to build a CICD workflow that will automatically verify proposed network changes, deploy changes to TEST, verify the TEST network is functioning, then prep and deploy to PROD.  

GitLab can act as a CICD build server as well as a source control server.  Let's set it up.  

### Initial Pipeline Setup 

1. Open up the code in Atom.  This can easily be done by typing `atom .` from the terminal within the `~/cicd-3tier` directory.  
1. Create a new file called `.gitlab-ci.yml` at the root of the repository.  

	```bash
	cd ~/cicd-3tier
	touch .gitlab-ci.yml
	```
	
1. Open this file up within Atom for editing.  It is blank to start.  

1. Our final pipeline will have 5 stages, but we're only putting the first one in for now.  To "lint" code involves checking for syntax and style problems.  In our case we will verify the ansible playbooks and variable files are valid.  Copy this into the `.gitlab-ci.yml` file.  

	```yaml
	stages:
	  - validate
	  - deploy_to_test
	  - deploy_to_prod
	  - verify_deploy_to_test
	  - verify_deploy_to_prod
	
	lint:
	  stage: validate
	  image: kecorbin/ansible:devel
	  script:
	    - ansible-playbook --syntax-check -i inventory/dev.yaml site.yaml
	    - ansible-playbook --syntax-check -i inventory/test.yaml site.yaml
	    - ansible-playbook --syntax-check -i inventory/prod.yaml site.yaml
	```

1. Add, commit and push this change to GitLab.  

	```bash
	git add .gitlab-ci.yml
	git commit -m "Initial pipeline file"
	git push 
	```
	
1. Let's talk about branches a bit.  

	* Run `git branch` and notice that you're on the `test` branch.  This branch corresponds to the configuration active on the TEST network.  
	* Run `git branch -a` and notice there is a branch called `remotes/origin/production`.  This branch corresponds to the PRODUCTION network configuration.  
	* Configuration changes should start in `test` and then be MERGED into `production` after proper testing. 
	* More on this in a bit.  

1. Open up GitLab and navigate to [CICD > Pipelines](http://10.10.20.20/developer/cicd-3tier/pipelines).  Watch the output of the pipeline run.  

1. Everything should look good and pass.  

### Automating Deployment and Testing of the TEST Network 

1. Add the below to the pipeline file.  This will run the same ansible playbook command to deploy the configuration to TEST.  It will also run a network validation using pyATS, Genie, and Robot.  

	```yaml
	deploy_to_test:
	  image: kecorbin/ansible:devel
	  stage: deploy_to_test
	  script:
	    - echo "Deploy to test env"
	    - ansible-playbook -i inventory/test.yaml site.yaml
	  environment:
	    name: test
	  only:
	    - test
	
	validate_test_environment:
	  image: ciscotestautomation/pyats:latest-robot
	  stage: verify_deploy_to_test
	  environment:
	    name: test
	  only:
	    - test
	  script:
	    - pwd
	    - cd tests
	    # important: need to add our current directory to PYTHONPATH
	    - export PYTHONPATH=$PYTHONPATH:$(pwd)
	    - robot --noncritical noncritical --variable testbed:./test_testbed.yml validation_tasks.robot
	
	  artifacts:
	      name: "pyats_robot_logs_${CI_JOB_NAME}_${CI_COMMIT_REF_NAME}"
	      when: always
	      paths:
	        - ./tests/log.html
	        - ./tests/report.html
	        - ./tests/output.xml
	```
	
1. Add, commit and push this change to GitLab.  

	```bash
	git add .gitlab-ci.yml
	git commit -m "Deploy and Test the TEST network."
	git push 
	```

1. Open up GitLab and navigate to [CICD > Pipelines](http://10.10.20.20/developer/cicd-3tier/pipelines).  Watch the output of the pipeline run.  

	* The pipeline will take a little longer this time as it is deploying the configuration to the TEST network, and then running the test cases.  

### Automating Deployment to Production 

1. Add the final part of the pipeline file.  This one will take care of the production deployment.  

	```yaml
	deploy_to_prod:
	  image: kecorbin/ansible:devel
	  stage: deploy_to_prod
	  script:
	    - echo "Deploy to prod env"
	    - ansible-playbook -i inventory/prod.yaml site.yaml
	  environment:
	    name: production
	  only:
	    - production
	  when: manual
	  allow_failure: false
	  only:
	  - production
	
	validate_prod_environment:
	  image: ciscotestautomation/pyats:latest-robot
	  stage: verify_deploy_to_prod
	  dependencies:
	    - deploy_to_prod
	  only:
	    - production
	  script:
	    - pwd
	    - cd tests
	    - export PYTHONPATH=$PYTHONPATH:$(pwd)
	    - robot --noncritical noncritical --variable testbed:./prod_testbed.yml validation_tasks.robot
	  artifacts:
	      name: "${CI_JOB_NAME}_${CI_COMMIT_REF_NAME}"
	      when: always
	      paths:
	        - ./tests/log.html
	        - ./tests/report.html
	        - ./tests/output.xml
	```
	
1. Add, commit and push this change to GitLab.  

	```bash
	git add .gitlab-ci.yml
	git commit -m "Production environment deployment."
	git push 
	```

1. Take a look at the [CICD > Pipeline](http://10.10.20.20/developer/cicd-3tier/pipelines) run that just went.  You'll see that the `deploy_to_test` and `validate_test_environment` ran rather than production.  This is because of the branches we looked at earlier.  

### Merging New Pipeline into Production 

1. In GitLab, open up [Merge Requests](http://10.10.20.20/developer/cicd-3tier/merge_requests).  
	* _Merge Requests are like Pull Requests in GitHub._ 
1. Create a new MR with source branch of test, and target of production.  
1. Explore the changes and other info in the interface, then Submit it.  
1. Then click "Merge" to complete the Merge.  
1. Now look at the new pipeline run, it'll be targeting the Production environment.  
1. You should see that the deploy phase is waiting for a manual "GO".  This is because of the line `when: manual` in the `deploy_to_prod` phase in the pipeline.  

## Using the Pipeline 

Now that the pipeline is up and working, let's put it to use.  

1. Navigate to [Issues in GitLab](http://10.10.20.20/developer/cicd-3tier/issues) and grab an issue to solve.  
1. Click "Create Merge Request".  This will create a new branch for you to work in, and then merge to TEST.  This allows individual developers to work locally in "Dev" environments and only send to Test when ready.  
1. In the Merge Request, click the "Checkout Branch" button.  GitLab gives you the exact commands to run locally on your workstation to checkout the branch.  Copy the commands from Step 1 and run in yoru local terminal.  
1. In Atom in the lower right corner you should see you are now in the new branch.  
1. You would now complete the changes to the *Network as Code* to fullfil the issue, and then check-in to GitLab.  Follow-along with the instructor to make these changes.  
1. When complete, you'll add, commit, and push to your new branch.  
1. Back in GitLab, you'll now finish the merge request by "Resolving WIP Status" (Work in Progress), and "Merging" into Test.  
1. This will then run the full TEST deployment.  If everything was updated successfully the dpeloyment should complete successfully and tests pass.  
1. And finally you'd do a Merge Request from `test` to `production` to complete the cycle.  

# Lab Cleanup

If you'd like to reset the sandbox to potentially run the lab again, follow these steps.  

1. End NSO and VIRL simulations, and delete the GitLab instance.  

	```bash
	make clean 
	``` 
	
1. Delete the workshops directory from the DevBox 

	```bash
	cd ~/
	rm -Rf workshops 
	```
	
1. Delete any local instances (ie on your own laptop) of the `cicd-3tier` repository.  
2. 