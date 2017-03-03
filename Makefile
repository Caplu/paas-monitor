include Makefile.mk
REGISTRY_HOST=docker.io
USERNAME=mvanholsteijn
NAME=paas-monitor

IMAGE=$(REGISTRY_HOST)/$(USERNAME)/$(NAME)


pre-build: paas-monitor marathon-lb.json

post-release: check-release push-to-gcr
	if [[ -z $(GITHUB_API_TOKEN) ]] ; then echo "ERROR: GITHUB_API_TOKEN not set." ; exit 1 ; fi
	./release-to-github

push-to-gcr:
	docker tag $(IMAGE):$(VERSION) gcr.io/instruqt/$(NAME):$(VERSION)
	docker tag $(IMAGE):$(VERSION) gcr.io/instruqt/$(NAME):latest
	gcloud docker --project instruqt -- push gcr.io/instruqt/$(NAME):$(VERSION)
	gcloud docker --project instruqt -- push gcr.io/instruqt/$(NAME):latest

paas-monitor: paas-monitor.go
	docker run --rm \
	-v $(PWD):/src \
	centurylink/golang-builder

envconsul:
	curl -L https://github.com/hashicorp/envconsul/releases/download/v0.5.0/envconsul_0.5.0_linux_amd64.tar.gz  | tar --strip-components=1 -xvzf -

marathon-lb.json: marathon.json
	jq '. + { "labels": {"HAPROXY_GROUP":"external", "HAPROXY_0_VHOST":"paas-monitor.127.0.0.1.xip.io"}}' marathon.json > marathon-lb.json


clean:
	rm -rf paas-monitor envconsul
