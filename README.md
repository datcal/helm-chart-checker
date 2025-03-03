# 🚀 Helm Chart Checker

![GitHub Workflow Status](https://github.com/datcal/helm-chart-checker/actions/workflows/release.yaml/badge.svg)

## 📌 Overview

This repository hosts the **Helm Chart Checker**, which allows you to **monitor and update Helm releases** in your Kubernetes cluster.  
It runs as a **CronJob** and checks for outdated Helm releases, notifying you via **Slack, Webhook, or Logs**.

---

## 🚀 Installation

### 1️⃣ Add the Helm Repository
```sh
helm repo add helm-checker https://datcal.github.io/helm-chart-checker/
helm repo update
```

### 2️⃣ Install the Chart
```sh
helm install my-checker helm-checker/helm-chart-checker
```

### 🔄 Upgrade the Chart
```sh
helm upgrade my-checker helm-checker/helm-chart-checker
```
---

## ⚙️ Configuration (`values.yaml`)
You can **override** these values during installation using `--set key=value` or by providing a custom `values.yaml` file.

### 🖥️ General Settings

| Key                  | Description                     | Default       |
|----------------------|---------------------------------|--------------|
| `image.repository`  | The container image repository | `alpine`     |
| `image.tag`        | The container image tag       | `latest`     |
| `image.pullPolicy`  | The image pull policy         | `IfNotPresent` |
| `schedule`         | Cron schedule for Helm version checks | `"* * * * *"` |

### 🔔 Alerting Options

| Key        | Description                          | Default  |
|------------|--------------------------------------|---------|
| `alertType` | Notification method: `"print"`, `"slack"`, or `"webhook"` | `"print"` |

#### 🔹 Slack Alerts

| Key              | Description                       | Default |
|-----------------|----------------------------------|---------|
| `slack.webhookUrl` | Slack Webhook URL               | `""`    |
| `slack.channel`   | Slack channel to send notifications | `""`    |
| `slack.username`  | Bot username for messages      | `""`    |
| `slack.iconEmoji` | Icon emoji for Slack messages | `""`    |

#### 🔹 Webhook Alerts

| Key            | Description                      | Default |
|---------------|----------------------------------|---------|
| `webhook.url` | Webhook endpoint to send notifications | `""`    |

---

## 📜 License

This project is licensed under the **MIT License**. See [LICENSE](LICENSE) for more details.
