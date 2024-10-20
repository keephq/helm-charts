{{/*
Expand the name of the chart.
*/}}
{{- define "keep.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "keep.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "keep.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "keep.labels" -}}
helm.sh/chart: {{ include "keep.chart" . }}
{{ include "keep.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "keep.selectorLabels" -}}
app.kubernetes.io/name: {{ include "keep.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "keep.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "keep.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Helper function to find an environment variable in the list
*/}}
{{- define "keep.findEnvVar" -}}
{{- $name := index . 0 -}}
{{- $values := index . 1 -}}
{{- if and $values.frontend $values.frontend.env -}}
  {{- range $values.frontend.env -}}
    {{- if eq .name $name -}}
      {{- .value -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Helper function for websocket host (relative)
*/}}
{{- define "keep.websocketPrefix" -}}
{{- coalesce .Values.websocket.ingress.prefix .Values.global.ingress.websocketPrefix "/websocket" -}}
{{- end -}}

{{/*
Helper function for backend host (relative)
*/}}
{{- define "keep.backendPrefix" -}}
{{- coalesce .Values.backend.ingress.prefix .Values.global.ingress.backendPrefix "/api" -}}
{{- end -}}

{{/*
Helper function for frontend host (relative)
*/}}
{{- define "keep.frontendPrefix" -}}
{{- coalesce .Values.frontend.ingress.prefix .Values.global.ingress.frontendPrefix "/" -}}
{{- end -}}

{{/*
Helper function for PUSHER_HOST
*/}}
{{- define "keep.pusherHost" -}}
{{- $pusherHost := include "keep.findEnvVar" (list "PUSHER_HOST" .) -}}
{{- if $pusherHost -}}
  {{- $pusherHost -}}
{{- else -}}
  {{- include "keep.websocketPrefix" . -}}
{{- end -}}
{{- end -}}

{{/*
Helper function for API_URL for the frontend
*/}}
{{- define "keep.apiUrl" -}}
{{- $apiUrl := include "keep.findEnvVar" (list "API_URL" .) -}}
{{- if $apiUrl -}}
  {{- $apiUrl -}}
{{- else -}}
  {{- include "keep.backendPrefix" . -}}
{{- end -}}
{{- end -}}