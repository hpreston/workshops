lab: gitlab 3tier

clean: clean3tier cleangitlab

gitlab:
	cd gitlab && ./setup.sh && cd ..

3tier:
	-cd cicd-3tier && ./setup.sh && cd ..

clean3tier:
	-cd cicd-3tier && ./cleanup.sh & cd ..

cleangitlab:
	-cd gitlab && docker-compose down && cd ..
