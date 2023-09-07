{{/*
Expand the name of the chart.
*/}}
{{- define "django.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "django.fullname" -}}
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
{{- define "django.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "django.labels" -}}
helm.sh/chart: {{ include "django.chart" . }}
{{ include "django.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "django.selectorLabels" -}}
app.kubernetes.io/name: {{ include "django.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "django.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "django.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Default health check for deployments
*/}}
{{- define "django.defaultHealthCheck" -}}
livenessProbe:
  tcpSocket:
    port: 8080
readinessProbe:
  tcpSocket:
    port: 8080
{{- end }}

{{/*
Define default health check for deployments, if healthCheck is enabled then
use Values file values instead. 
*/}}
{{- define "django.healthCheck" -}}
{{- if .Values.healthCheck.enabled }}
  {{- with .Values.healthCheck.probes }}
    {{- toYaml . }}
  {{- end }}
{{- else}}
  {{- include "django.defaultHealthCheck" . }}
{{- end }}
{{- end }}

{{/*
If enabled, use configMapRef and secretRef in deployment.
*/}}
{{- define "django.envFrom" -}}
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

{{/*
Define a default shell command if .Values.cronjob.command is no defined
*/}}
{{- define "django.cronjobCommand" -}}
{{- if not .Values.cronjob.command }}
{{- $releaseName := .Release.Name }}
{{- printf "echo 'Hello from %s'" $releaseName }}
{{- else }}
{{ .Values.cronjob.command }}
{{- end }}
{{- end }}
