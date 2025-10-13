#!/bin/bash

# 🚀 HPA Metrics Dashboard Creator
# This script creates a dashboard with real HPA metrics

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log function
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
    exit 1
}

# Banner
echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                📊 HPA METRICS DASHBOARD                     ║"
echo "║                                                              ║"
echo "║  Creates a dashboard with real HPA metrics from kube-state  ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Test HPA metrics
log "Testing HPA metrics availability..."
HPA_METRICS=$(kubectl exec deployment/grafana -n k8s-demo -- curl -s "http://prometheus:9090/api/v1/query?query=kube_horizontalpodautoscaler_status_current_replicas" | grep -o '"value":\[[^]]*\]' | wc -l)
if [ "$HPA_METRICS" -gt 0 ]; then
    success "HPA metrics are available! Found $HPA_METRICS HPA instances"
else
    error "HPA metrics not found"
fi

# Create HPA metrics dashboard
log "Creating HPA metrics dashboard..."

cat > /tmp/hpa-metrics-dashboard.json << 'EOF'
{
  "annotations": {
    "list": [
      {
        "builtIn": 1,
        "datasource": {
          "type": "grafana",
          "uid": "-- Grafana --"
        },
        "enable": true,
        "hide": true,
        "iconColor": "rgba(0, 211, 255, 1)",
        "name": "Annotations & Alerts",
        "type": "dashboard"
      }
    ]
  },
  "editable": true,
  "fiscalYearStartMonth": 0,
  "graphTooltip": 0,
  "id": null,
  "links": [],
  "liveNow": false,
  "panels": [
    {
      "datasource": {
        "type": "prometheus",
        "uid": "prometheus"
      },
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "palette-classic"
          },
          "custom": {
            "axisLabel": "",
            "axisPlacement": "auto",
            "barAlignment": 0,
            "drawStyle": "line",
            "fillOpacity": 0,
            "gradientMode": "none",
            "hideFrom": {
              "legend": false,
              "tooltip": false,
              "vis": false
            },
            "lineInterpolation": "linear",
            "lineWidth": 1,
            "pointSize": 5,
            "scaleDistribution": {
              "type": "linear"
            },
            "showPoints": "auto",
            "spanNulls": false,
            "stacking": {
              "group": "A",
              "mode": "none"
            },
            "thresholdsStyle": {
              "mode": "off"
            }
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": null
              },
              {
                "color": "red",
                "value": 80
              }
            ]
          },
          "unit": "short"
        },
        "overrides": []
      },
      "gridPos": {
        "h": 8,
        "w": 12,
        "x": 0,
        "y": 0
      },
      "id": 1,
      "options": {
        "legend": {
          "calcs": [],
          "displayMode": "list",
          "placement": "bottom"
        },
        "tooltip": {
          "mode": "single",
          "sort": "none"
        }
      },
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "editorMode": "code",
          "expr": "kube_horizontalpodautoscaler_status_current_replicas{namespace=\"k8s-demo\"}",
          "instant": false,
          "legendFormat": "{{horizontalpodautoscaler}} - Current",
          "range": true,
          "refId": "A"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "editorMode": "code",
          "expr": "kube_horizontalpodautoscaler_status_desired_replicas{namespace=\"k8s-demo\"}",
          "instant": false,
          "legendFormat": "{{horizontalpodautoscaler}} - Desired",
          "range": true,
          "refId": "B"
        }
      ],
      "title": "HPA Replicas (Current vs Desired)",
      "type": "timeseries"
    },
    {
      "datasource": {
        "type": "prometheus",
        "uid": "prometheus"
      },
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "palette-classic"
          },
          "custom": {
            "axisLabel": "",
            "axisPlacement": "auto",
            "barAlignment": 0,
            "drawStyle": "line",
            "fillOpacity": 0,
            "gradientMode": "none",
            "hideFrom": {
              "legend": false,
              "tooltip": false,
              "vis": false
            },
            "lineInterpolation": "linear",
            "lineWidth": 1,
            "pointSize": 5,
            "scaleDistribution": {
              "type": "linear"
            },
            "showPoints": "auto",
            "spanNulls": false,
            "stacking": {
              "group": "A",
              "mode": "none"
            },
            "thresholdsStyle": {
              "mode": "off"
            }
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": null
              },
              {
                "color": "red",
                "value": 80
              }
            ]
          },
          "unit": "short"
        },
        "overrides": []
      },
      "gridPos": {
        "h": 8,
        "w": 12,
        "x": 12,
        "y": 0
      },
      "id": 2,
      "options": {
        "legend": {
          "calcs": [],
          "displayMode": "list",
          "placement": "bottom"
        },
        "tooltip": {
          "mode": "single",
          "sort": "none"
        }
      },
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "editorMode": "code",
          "expr": "kube_horizontalpodautoscaler_spec_min_replicas{namespace=\"k8s-demo\"}",
          "instant": false,
          "legendFormat": "{{horizontalpodautoscaler}} - Min",
          "range": true,
          "refId": "A"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "editorMode": "code",
          "expr": "kube_horizontalpodautoscaler_spec_max_replicas{namespace=\"k8s-demo\"}",
          "instant": false,
          "legendFormat": "{{horizontalpodautoscaler}} - Max",
          "range": true,
          "refId": "B"
        }
      ],
      "title": "HPA Limits (Min vs Max Replicas)",
      "type": "timeseries"
    },
    {
      "datasource": {
        "type": "prometheus",
        "uid": "prometheus"
      },
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "palette-classic"
          },
          "custom": {
            "axisLabel": "",
            "axisPlacement": "auto",
            "barAlignment": 0,
            "drawStyle": "line",
            "fillOpacity": 0,
            "gradientMode": "none",
            "hideFrom": {
              "legend": false,
              "tooltip": false,
              "vis": false
            },
            "lineInterpolation": "linear",
            "lineWidth": 1,
            "pointSize": 5,
            "scaleDistribution": {
              "type": "linear"
            },
            "showPoints": "auto",
            "spanNulls": false,
            "stacking": {
              "group": "A",
              "mode": "none"
            },
            "thresholdsStyle": {
              "mode": "off"
            }
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": null
              },
              {
                "color": "red",
                "value": 80
              }
            ]
          },
          "unit": "short"
        },
        "overrides": []
      },
      "gridPos": {
        "h": 8,
        "w": 12,
        "x": 0,
        "y": 8
      },
      "id": 3,
      "options": {
        "legend": {
          "calcs": [],
          "displayMode": "list",
          "placement": "bottom"
        },
        "tooltip": {
          "mode": "single",
          "sort": "none"
        }
      },
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "editorMode": "code",
          "expr": "kube_deployment_status_replicas{namespace=\"k8s-demo\"}",
          "instant": false,
          "legendFormat": "{{deployment}} - Total",
          "range": true,
          "refId": "A"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "editorMode": "code",
          "expr": "kube_deployment_status_replicas_ready{namespace=\"k8s-demo\"}",
          "instant": false,
          "legendFormat": "{{deployment}} - Ready",
          "range": true,
          "refId": "B"
        }
      ],
      "title": "Deployment Replicas (Total vs Ready)",
      "type": "timeseries"
    },
    {
      "datasource": {
        "type": "prometheus",
        "uid": "prometheus"
      },
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "palette-classic"
          },
          "custom": {
            "axisLabel": "",
            "axisPlacement": "auto",
            "barAlignment": 0,
            "drawStyle": "line",
            "fillOpacity": 0,
            "gradientMode": "none",
            "hideFrom": {
              "legend": false,
              "tooltip": false,
              "vis": false
            },
            "lineInterpolation": "linear",
            "lineWidth": 1,
            "pointSize": 5,
            "scaleDistribution": {
              "type": "linear"
            },
            "showPoints": "auto",
            "spanNulls": false,
            "stacking": {
              "group": "A",
              "mode": "none"
            },
            "thresholdsStyle": {
              "mode": "off"
            }
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": null
              },
              {
                "color": "red",
                "value": 80
              }
            ]
          },
          "unit": "short"
        },
        "overrides": []
      },
      "gridPos": {
        "h": 8,
        "w": 12,
        "x": 12,
        "y": 8
      },
      "id": 4,
      "options": {
        "legend": {
          "calcs": [],
          "displayMode": "list",
          "placement": "bottom"
        },
        "tooltip": {
          "mode": "single",
          "sort": "none"
        }
      },
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "editorMode": "code",
          "expr": "up{job=\"backend\"}",
          "instant": false,
          "legendFormat": "Backend",
          "range": true,
          "refId": "A"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "editorMode": "code",
          "expr": "up{job=\"prometheus\"}",
          "instant": false,
          "legendFormat": "Prometheus",
          "range": true,
          "refId": "B"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "editorMode": "code",
          "expr": "up{job=\"kube-state-metrics\"}",
          "instant": false,
          "legendFormat": "Kube-State-Metrics",
          "range": true,
          "refId": "C"
        }
      ],
      "title": "Services Status",
      "type": "timeseries"
    }
  ],
  "refresh": "5s",
  "schemaVersion": 38,
  "style": "dark",
  "tags": ["kubernetes", "hpa", "metrics"],
  "templating": {
    "list": []
  },
  "time": {
    "from": "now-1h",
    "to": "now"
  },
  "timepicker": {},
  "timezone": "",
  "title": "HPA Metrics Dashboard",
  "uid": "hpa-metrics",
  "version": 1,
  "weekStart": ""
}
EOF

success "HPA metrics dashboard created"

# Final information
echo ""
echo "📊 HPA Metrics Dashboard:"
echo "========================="
echo ""
echo "✅ Dashboard created: /tmp/hpa-metrics-dashboard.json"
echo ""
echo "🔧 Import Instructions:"
echo "======================"
echo "1. Go to Grafana: http://k8s-demo.local/grafana"
echo "2. Login: admin / admin"
echo "3. Go to '+' > Import"
echo "4. Copy content from /tmp/hpa-metrics-dashboard.json"
echo "5. Paste in 'Import via panel json'"
echo "6. Click 'Load' and 'Import'"
echo ""
echo "📋 Dashboard Features:"
echo "====================="
echo "• HPA Replicas (Current vs Desired)"
echo "• HPA Limits (Min vs Max Replicas)"
echo "• Deployment Replicas (Total vs Ready)"
echo "• Services Status (Backend, Prometheus, Kube-State-Metrics)"
echo "• Real-time updates (5s refresh)"
echo ""
echo "🔍 Available HPA Metrics:"
echo "========================="
echo "• kube_horizontalpodautoscaler_status_current_replicas"
echo "• kube_horizontalpodautoscaler_status_desired_replicas"
echo "• kube_horizontalpodautoscaler_spec_min_replicas"
echo "• kube_horizontalpodautoscaler_spec_max_replicas"
echo "• kube_deployment_status_replicas"
echo "• kube_deployment_status_replicas_ready"
echo ""
echo "🚀 Test Auto-scaling:"
echo "===================="
echo "• Load Test: ./scripts/load-test.sh 300 50 60"
echo "• Watch HPA: kubectl get hpa -n k8s-demo -w"
echo "• Watch Pods: kubectl get pods -n k8s-demo -w"
echo ""

success "HPA metrics dashboard ready! 🎉"
echo ""
echo "🎯 Now you have REAL HPA metrics in Grafana!"
echo "   The dashboard will show actual HPA scaling data."
