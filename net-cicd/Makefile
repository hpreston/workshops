lab: gitlab 3tier deploytest deployprod

clean: clean3tier cleangitlab

gitlab:
	-cd gitlab && ./setup.sh && cd ..

3tier:
	-cd cicd-3tier && ./setup.sh && cd ..

clean3tier:
	-cd cicd-3tier && ./cleanup.sh & cd ..

cleangitlab:
	-cd gitlab && docker-compose down && cd ..

deploytest:
	-cd cicd-3tier && ansible-playbook -i inventory/test.yaml site.yaml && cd ..

deployprod:
	-cd cicd-3tier && ansible-playbook -i inventory/prod.yaml site.yaml && cd ..
