RUN apt-get update
RUN apt-get install -y python3-dev build-essential python3-pip {{index .Env "PKGS"}}
