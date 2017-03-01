FROM 		scratch
ADD 		public /app/public/
ENV		APPDIR /app
ADD		paas-monitor /
ADD		envconsul /

ENV		SERVICE_NAME paas-monitor
ENV		SERVICE_TAGS http

ENTRYPOINT 	[ "/paas-monitor", "-port", "1337" ]
EXPOSE 		1337
