FROM tomcat:10.1

COPY dist/LIBRARY_MANAGEMENT_SYSTEM.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080