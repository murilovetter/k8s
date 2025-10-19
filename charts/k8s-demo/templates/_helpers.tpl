{{/*
Expand the name of the chart.
*/}}
{{- define "k8s-demo.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "k8s-demo.fullname" -}}
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
{{- define "k8s-demo.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "k8s-demo.labels" -}}
helm.sh/chart: {{ include "k8s-demo.chart" . }}
{{ include "k8s-demo.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "k8s-demo.selectorLabels" -}}
app.kubernetes.io/name: {{ include "k8s-demo.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Frontend labels
*/}}
{{- define "k8s-demo.frontend.labels" -}}
{{ include "k8s-demo.labels" . }}
app.kubernetes.io/component: frontend
{{- end }}

{{/*
Frontend selector labels
*/}}
{{- define "k8s-demo.frontend.selectorLabels" -}}
{{ include "k8s-demo.selectorLabels" . }}
app.kubernetes.io/component: frontend
{{- end }}

{{/*
Backend labels
*/}}
{{- define "k8s-demo.backend.labels" -}}
{{ include "k8s-demo.labels" . }}
app.kubernetes.io/component: backend
{{- end }}

{{/*
Backend selector labels
*/}}
{{- define "k8s-demo.backend.selectorLabels" -}}
{{ include "k8s-demo.selectorLabels" . }}
app.kubernetes.io/component: backend
{{- end }}

{{/*
Namespace
*/}}
{{- define "k8s-demo.namespace" -}}
{{- .Values.global.namespace | default "k8s-demo" }}
{{- end }}

{{/*
Default ingress paths
*/}}
{{- define "k8s-demo.ingress.paths" -}}
{{- $root := . -}}
{{- if .paths }}
{{- range .paths }}
- path: {{ .path }}
  pathType: {{ .pathType }}
  backend:
    service:
      name: {{ include "k8s-demo.fullname" $root }}-{{ .service }}
      port:
        number: {{- if eq .service "frontend" }} {{ $root.Values.frontend.service.port }}{{- else if eq .service "backend" }} {{ $root.Values.backend.service.port }}{{- else if eq .service "prometheus" }} 9090{{- else if eq .service "grafana" }} 3000{{- end }}
{{- end }}
{{- else }}
- path: /static
  pathType: Prefix
  backend:
    service:
      name: {{ include "k8s-demo.fullname" $root }}-frontend
      port:
        number: {{ $root.Values.frontend.service.port }}
- path: /prometheus
  pathType: Prefix
  backend:
    service:
      name: {{ include "k8s-demo.fullname" $root }}-prometheus-server
      port:
        number: 80
- path: /grafana
  pathType: Prefix
  backend:
    service:
      name: {{ include "k8s-demo.fullname" $root }}-grafana
      port:
        number: 80
- path: /api
  pathType: Prefix
  backend:
    service:
      name: {{ include "k8s-demo.fullname" $root }}-backend
      port:
        number: {{ $root.Values.backend.service.port }}
- path: /
  pathType: Prefix
  backend:
    service:
      name: {{ include "k8s-demo.fullname" $root }}-frontend
      port:
        number: {{ $root.Values.frontend.service.port }}
{{- end }}
{{- end }}

