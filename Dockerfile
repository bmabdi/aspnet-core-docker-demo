# Put common setup steps in an initial stage
FROM mcr.microsoft.com/mssql/server:2019-latest AS setup
ENV MSSQL_PID=Developer
ENV SA_PASSWORD=MssqlPass123 
ENV ACCEPT_EULA=Y           

FROM setup AS data
USER mssql
COPY COV_FROI.bak /  

RUN ( /opt/mssql/bin/sqlservr & ) | grep -q "Service Broker manager has started" \
    && /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P $SA_PASSWORD -Q 'RESTORE DATABASE COV_FROI FROM DISK = "/COV_FROI.bak" WITH MOVE "COV_FROI" to "/var/opt/mssql/data/COV_FROI.mdf", MOVE "COV_FROI_Log" to "/var/opt/mssql/data/COV_FROI_log.ldf", NOUNLOAD, STATS = 5' \
    && pkill sqlservr

FROM setup
COPY --from=data /var/opt/mssql /var/opt/mssql

COPY . /
USER root
RUN chmod +x /db-init.sh
CMD /bin/bash ./entrypoint.sh