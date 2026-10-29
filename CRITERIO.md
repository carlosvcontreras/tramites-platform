1. En 10 líneas o menos, describe un Golden Path para este servicio: qué incluye, qué dejas fuera a propósito y cómo medirías si los equipos lo usan.

R/ En mi opinión para este servicio,lo esencial del Golden Path es usar plantillas justo como lo que está construido en el repo. Así cualquier equipo puede reciclarlo y aliviar la carga cognitiva. Mi repo fue construida de manera práctica y segura:

Dockerfile seguro, CI con escaneos, deploy sin llaves, Terraform y detección de drift.

El golden path seria tan sencillo apretar "Use this template", cambiar el código, abrir un PR, que el ci se marque en verde después hacer merge y finalmente queda desplegado.

Dejé por fuera bases de datos, Binary Authorization y múltiples ambientes para que la plantilla sea simple.

Para medir como se usan podemos ver el % de servicios que usan la plantilla, DORA: frecuencia de deploy, lead time y tasa de fallos. También debería reducirse los requests al equipo de DevOps para ayudar a desplegar código.

2. El servicio tiene que consultar un sistema on-premise (SOAP) y un servicio en AWS.
¿Cómo conectas las tres partes de forma segura? Considera costo y riesgo.

R/ En primer lugar yo necesitaría un documento de requerimientos y limitaciones para poder dar una orientación de arquitectura. Una vez tengamos bien definido los requerimientos podría decidir cuál es el camino más optimo para conectarlo de manera segura considerando costos y riesgos.

Una manera que investigué para hacerlo (Partiendo de que el SOAP no debe quedar expuesto a internet y que el servicio de AWS es una API administrada) para el On Premise es con HA VPN, Direct VPC egress y un firewall. 

Para AWS podríamos conectarnos por HTTPS. Yo usaría federación de identidad: un rol de AWS que confía en la service account de Cloud Run, igual que hice con WIF entre GitHub y GCP.

El mayor costo sería claramente el Cloud HA VPN. Sin embargo, insisto que sería de evaluar el escenario para decidir concretamente pero se justifica porque el mayor riesgo sería exponer el SOAP a internet.

3. ¿Qué controles pondrías para que un ambiente de desarrollo no gaste USD 2,000 en un fin de semana?

Lo más sencillo es reducirle las quotas a los proyectos de dev. Tener un budget es buena practica pero no funciona en tiempo real (los datos de facturación pueden llegar con horas de retraso) en cambio una quota limita al dev al momento.

Usaría instance schedules https://docs.cloud.google.com/compute/docs/instances/schedule-instance-start-stop#managing_instance_schedules para apagar entornos que no se usan los fines de semana. 

A mi parecer el trabajo de un devops también es optimizar los recursos que ya se consumen, no solo los que están por consumirse.
