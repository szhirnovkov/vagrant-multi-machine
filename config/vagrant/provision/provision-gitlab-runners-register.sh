echo -e "\e[34m Gitlab runner registration - type shell \e[0m"
gitlab-runner register < /vagrant-data/register-shell-runners

echo -e "\e[34m Gitlab runner registration - type docker \e[0m"
    docker run -d --name gitlab-runner --restart always \
       -v /var/run/docker.sock:/var/run/docker.sock \
       -v /srv/gitlab-runner/config:/etc/gitlab-runner \
       gitlab/gitlab-runner:latest

    docker run -v /srv/gitlab-runner/config:/etc/gitlab-runner gitlab/gitlab-runner register \
       --non-interactive \
       --executor "docker" \
       --docker-image $IMAGE \
       --url "$URL" \
       --registration-token "$TOKEN" \
       --description "docker-runner" \
       --tag-list "docker" \
       --run-untagged="true" \
       --locked="false" \
       --access-level="not_protected"

