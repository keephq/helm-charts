# keep

![Version: 0.0.2](https://img.shields.io/badge/Version-0.0.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.2.1](https://img.shields.io/badge/AppVersion-0.2.1-informational?style=flat-square)

Keep Helm Chart

**Homepage:** <https://platform.keephq.dev/>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Shahar Glazner | <shahar@keephq.dev> | <https://github.com/shahargl> |
| Tal Borenstein | <tal@keephq.dev> | <https://github.com/talboren> |

## Source Code

* <https://github.com/keephq/helm-charts>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| backend.affinity | object | `{}` |  |
| backend.autoscaling.enabled | bool | `false` |  |
| backend.autoscaling.maxReplicas | int | `3` |  |
| backend.autoscaling.minReplicas | int | `1` |  |
| backend.autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| backend.enabled | bool | `true` |  |
| backend.env[0].name | string | `"SECRET_MANAGER_TYPE"` |  |
| backend.env[0].value | string | `"k8s"` |  |
| backend.env[1].name | string | `"PORT"` |  |
| backend.env[1].value | string | `"8080"` |  |
| backend.env[2].name | string | `"SECRET_MANAGER_DIRECTORY"` |  |
| backend.env[2].value | string | `"/state"` |  |
| backend.env[3].name | string | `"DATABASE_CONNECTION_STRING"` |  |
| backend.env[3].value | string | `"mysql+pymysql://root@keep-database:3306/keep"` |  |
| backend.env[4].name | string | `"PUSHER_APP_ID"` |  |
| backend.env[4].value | int | `1` |  |
| backend.env[5].name | string | `"PUSHER_APP_KEY"` |  |
| backend.env[5].value | string | `"keepappkey"` |  |
| backend.env[6].name | string | `"PUSHER_APP_SECRET"` |  |
| backend.env[6].value | string | `"keepappsecret"` |  |
| backend.env[7].name | string | `"PUSHER_HOST"` |  |
| backend.env[7].value | string | `"keep-websocket"` |  |
| backend.env[8].name | string | `"PUSHER_PORT"` |  |
| backend.env[8].value | int | `6001` |  |
| backend.image.pullPolicy | string | `"Always"` |  |
| backend.image.repository | string | `"us-central1-docker.pkg.dev/keephq/keep/keep-api"` |  |
| backend.image.tag | string | `"latest"` |  |
| backend.imagePullSecrets | list | `[]` |  |
| backend.ingress.annotations | object | `{}` |  |
| backend.ingress.className | string | `""` |  |
| backend.ingress.enabled | bool | `true` |  |
| backend.ingress.hosts[0].host | string | `"chart-example-backend.local"` |  |
| backend.ingress.hosts[0].paths[0].path | string | `"/"` |  |
| backend.ingress.hosts[0].paths[0].pathType | string | `"ImplementationSpecific"` |  |
| backend.ingress.tls | list | `[]` |  |
| backend.nodeSelector | object | `{}` |  |
| backend.openAiApi.enabled | bool | `false` |  |
| backend.openAiApi.openAiApiKey | string | `""` |  |
| backend.podAnnotations | object | `{}` |  |
| backend.podSecurityContext | object | `{}` |  |
| backend.replicaCount | int | `1` |  |
| backend.resources | object | `{}` |  |
| backend.route.enabled | bool | `false` |  |
| backend.route.host | string | `"chart-example-backend.local"` |  |
| backend.route.path | string | `"/"` |  |
| backend.route.tls | list | `[]` |  |
| backend.route.wildcardPolicy | string | `"None"` |  |
| backend.securityContext | object | `{}` |  |
| backend.service.port | int | `8080` |  |
| backend.service.type | string | `"ClusterIP"` |  |
| backend.tolerations | list | `[]` |  |
| database.affinity | object | `{}` |  |
| database.autoscaling.enabled | bool | `false` |  |
| database.enabled | bool | `true` |  |
| database.env[0].name | string | `"MYSQL_ALLOW_EMPTY_PASSWORD"` |  |
| database.env[0].value | string | `"yes"` |  |
| database.env[1].name | string | `"MYSQL_DATABASE"` |  |
| database.env[1].value | string | `"keep"` |  |
| database.env[2].name | string | `"MYSQL_PASSWORD"` |  |
| database.env[2].value | string | `nil` |  |
| database.image.pullPolicy | string | `"IfNotPresent"` |  |
| database.image.repository | string | `"mysql"` |  |
| database.image.tag | string | `"latest"` |  |
| database.imagePullSecrets | list | `[]` |  |
| database.nodeSelector | object | `{}` |  |
| database.podAnnotations | object | `{}` |  |
| database.podSecurityContext | object | `{}` |  |
| database.replicaCount | int | `1` |  |
| database.resources | object | `{}` |  |
| database.securityContext | object | `{}` |  |
| database.service.port | int | `3306` |  |
| database.service.type | string | `"ClusterIP"` |  |
| database.size | string | `"5Gi"` |  |
| database.storageClass | string | `""` |  |
| database.tolerations | list | `[]` |  |
| frontend.affinity | object | `{}` |  |
| frontend.autoscaling.enabled | bool | `false` |  |
| frontend.autoscaling.maxReplicas | int | `3` |  |
| frontend.autoscaling.minReplicas | int | `1` |  |
| frontend.autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| frontend.enabled | bool | `true` |  |
| frontend.env[0].name | string | `"NEXTAUTH_SECRET"` |  |
| frontend.env[0].value | string | `"secret"` |  |
| frontend.env[10].name | string | `"PUSHER_PORT"` |  |
| frontend.env[10].value | int | `6001` |  |
| frontend.env[11].name | string | `"PUSHER_APP_KEY"` |  |
| frontend.env[11].value | string | `"keepappkey"` |  |
| frontend.env[1].name | string | `"NEXTAUTH_URL"` |  |
| frontend.env[1].value | string | `"http://localhost:3000"` |  |
| frontend.env[2].name | string | `"API_URL"` |  |
| frontend.env[2].value | string | `"http://keep-backend:8080"` |  |
| frontend.env[3].name | string | `"NEXT_PUBLIC_API_URL"` |  |
| frontend.env[3].value | string | `""` |  |
| frontend.env[4].name | string | `"NEXT_PUBLIC_POSTHOG_KEY"` |  |
| frontend.env[4].value | string | `"phc_muk9qE3TfZsX3SZ9XxX52kCGJBclrjhkP9JxAQcm1PZ"` |  |
| frontend.env[5].name | string | `"NEXT_PUBLIC_POSTHOG_HOST"` |  |
| frontend.env[5].value | string | `"https://app.posthog.com"` |  |
| frontend.env[6].name | string | `"ENV"` |  |
| frontend.env[6].value | string | `"development"` |  |
| frontend.env[7].name | string | `"NODE_ENV"` |  |
| frontend.env[7].value | string | `"development"` |  |
| frontend.env[8].name | string | `"HOSTNAME"` |  |
| frontend.env[8].value | string | `"0.0.0.0"` |  |
| frontend.env[9].name | string | `"PUSHER_HOST"` |  |
| frontend.env[9].value | string | `"localhost"` |  |
| frontend.image.pullPolicy | string | `"Always"` |  |
| frontend.image.repository | string | `"us-central1-docker.pkg.dev/keephq/keep/keep-ui"` |  |
| frontend.image.tag | string | `"latest"` |  |
| frontend.imagePullSecrets | list | `[]` |  |
| frontend.ingress.annotations | object | `{}` |  |
| frontend.ingress.className | string | `""` |  |
| frontend.ingress.enabled | bool | `true` |  |
| frontend.ingress.hosts[0].host | string | `"chart-example.local"` |  |
| frontend.ingress.hosts[0].paths[0].path | string | `"/"` |  |
| frontend.ingress.hosts[0].paths[0].pathType | string | `"ImplementationSpecific"` |  |
| frontend.ingress.tls | list | `[]` |  |
| frontend.nodeSelector | object | `{}` |  |
| frontend.podAnnotations | object | `{}` |  |
| frontend.podSecurityContext | object | `{}` |  |
| frontend.replicaCount | int | `1` |  |
| frontend.resources | object | `{}` |  |
| frontend.route.enabled | bool | `false` |  |
| frontend.route.host | string | `"chart-example.local"` |  |
| frontend.route.path | string | `"/"` |  |
| frontend.route.tls | list | `[]` |  |
| frontend.route.wildcardPolicy | string | `"None"` |  |
| frontend.securityContext | object | `{}` |  |
| frontend.service.port | int | `3000` |  |
| frontend.service.type | string | `"ClusterIP"` |  |
| frontend.serviceAccount.annotations | object | `{}` |  |
| frontend.serviceAccount.create | bool | `true` |  |
| frontend.serviceAccount.name | string | `""` |  |
| frontend.tolerations | list | `[]` |  |
| fullnameOverride | string | `""` |  |
| nameOverride | string | `""` |  |
| namespace | string | `"default"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| websocket.affinity | object | `{}` |  |
| websocket.autoscaling.enabled | bool | `false` |  |
| websocket.autoscaling.maxReplicas | int | `3` |  |
| websocket.autoscaling.minReplicas | int | `1` |  |
| websocket.autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| websocket.enabled | bool | `true` |  |
| websocket.env[0].name | string | `"SOKETI_USER_AUTHENTICATION_TIMEOUT"` |  |
| websocket.env[0].value | int | `3000` |  |
| websocket.env[1].name | string | `"SOKETI_DEFAULT_APP_ID"` |  |
| websocket.env[1].value | int | `1` |  |
| websocket.env[2].name | string | `"SOKETI_DEFAULT_APP_KEY"` |  |
| websocket.env[2].value | string | `"keepappkey"` |  |
| websocket.env[3].name | string | `"SOKETI_DEFAULT_APP_SECRET"` |  |
| websocket.env[3].value | string | `"keepappsecret"` |  |
| websocket.image.pullPolicy | string | `"Always"` |  |
| websocket.image.repository | string | `"quay.io/soketi/soketi:1.4-16-debian"` |  |
| websocket.image.tag | string | `"latest"` |  |
| websocket.imagePullSecrets | list | `[]` |  |
| websocket.ingress.annotations | object | `{}` |  |
| websocket.ingress.className | string | `""` |  |
| websocket.ingress.enabled | bool | `false` |  |
| websocket.ingress.hosts[0].host | string | `"chart-example.local"` |  |
| websocket.ingress.hosts[0].paths[0].path | string | `"/"` |  |
| websocket.ingress.hosts[0].paths[0].pathType | string | `"ImplementationSpecific"` |  |
| websocket.ingress.tls | list | `[]` |  |
| websocket.nodeSelector | object | `{}` |  |
| websocket.podAnnotations | object | `{}` |  |
| websocket.podSecurityContext | object | `{}` |  |
| websocket.replicaCount | int | `1` |  |
| websocket.resources | object | `{}` |  |
| websocket.securityContext | object | `{}` |  |
| websocket.service.port | int | `6001` |  |
| websocket.service.type | string | `"ClusterIP"` |  |
| websocket.serviceAccount.annotations | object | `{}` |  |
| websocket.serviceAccount.create | bool | `true` |  |
| websocket.serviceAccount.name | string | `""` |  |
| websocket.tolerations | list | `[]` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.13.0](https://github.com/norwoodj/helm-docs/releases/v1.13.0)
