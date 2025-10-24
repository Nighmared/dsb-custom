{{- define "socialnetwork.templates.baseService" }}

apiVersion: v1
kind: Service
metadata:
  name: {{ .Values.name }}
spec:
  type: {{ .Values.type | default .Values.global.serviceType }}
  ports:  
  {{- range .Values.ports }}
  - name: "{{ .port }}"
    port: {{ .port }}
    {{- if eq (int .port) 8080 8081 16686 }}
    nodePort: {{ .port }}
    {{- end }}
    {{- if .protocol}}
    protocol: {{ .protocol }}
    {{- end}}
    targetPort: {{ .targetPort }}
  {{- end}}
  selector:
    service: {{ .Values.name }} 

{{- end }}
