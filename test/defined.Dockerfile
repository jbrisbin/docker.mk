RUN echo hello >/etc/greeting
{{if defined .Env.GREETING}}
RUN echo " {{.Env.GREETING}}" >>/etc/greeting
{{endif}}
