{{/*
Expand the name of the chart.
*/}}
{{- define "nodejs.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "nodejs.fullname" -}}
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
{{- define "nodejs.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "nodejs.labels" -}}
helm.sh/chart: {{ include "nodejs.chart" . }}
{{ include "nodejs.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "nodejs.selectorLabels" -}}
app.kubernetes.io/name: {{ .Release.Name }}
app.kubernetes.io/instance: {{ include "nodejs.name" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "nodejs.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "nodejs.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Default health check for deployments
*/}}
{{- define "nodejs.defaultHealthCheck" -}}
livenessProbe:
  tcpSocket:
    port: 8080
readinessProbe:
  httpGet:
    path: /health
    port: 8080
{{- end }}

{{/*
Define default health check for deployments, if healthCheck is enabled then
use Values file values instead. 
*/}}
{{- define "nodejs.healthCheck" -}}
{{- if .Values.healthCheck.enabled }}
  {{- with .Values.healthCheck.probes }}
    {{- toYaml . }}
  {{- end }}
{{- else}}
  {{- include "nodejs.defaultHealthCheck" . }}
{{- end }}
{{- end }}

{{/*
If enabled, use configMapRef and secretRef in deployment.
*/}}
{{- define "nodejs.envFrom" -}}
{{- if and .Values.configmap.enabled .Values.secrets.enabled }}
envFrom:
- configMapRef:
    name: {{ .Release.Name }}
- secretRef:
    name: {{ .Release.Name }}
{{- else if .Values.configmap.enabled }}
envFrom:
- configMapRef:
    name: {{ .Release.Name }}
{{- else if .Values.secrets.enabled }}
envFrom:
- secretRef:
    name: {{ .Release.Name }}
{{- end }}
{{- end }}
