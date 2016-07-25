RUN ls / >/tmp/root.txt
RUN echo hello {{index .Env "HELLO"}} >/etc/greeting
{{template "reused" .}}
