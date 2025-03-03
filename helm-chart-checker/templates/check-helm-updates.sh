{{- define "helm-chart-checker.script" -}}
#!/bin/sh

set -e
apk add --no-cache helm curl jq bash coreutils ncurses || true

if [ -n "$TERM" ]; then
  GREEN=$(tput setaf 2)
  YELLOW=$(tput setaf 3)
  RED=$(tput setaf 1)
  BLUE=$(tput setaf 4)
  RESET=$(tput sgr0)
else
  GREEN='\033[1;32m'
  YELLOW='\033[1;33m'
  RED='\033[1;31m'
  BLUE='\033[1;34m'
  RESET='\033[0m'
fi


echo -e "${BLUE}#############################"
echo -e "#  🚀 Helm Chart Checker   #"
echo -e "#############################${RESET}"
echo "Adding Helm repositories..."

helm repo add bitnami https://charts.bitnami.com/bitnami || true
helm repo add stable https://charts.helm.sh/stable || true
helm repo update || true


    
echo "Verifying repositories..."
helm repo list

echo "Checking for outdated Helm releases..."
helm list --all --output json | jq -r '.[] | "\(.name) \(.chart | split("-")[0]) \(.app_version)"' > /tmp/installed_charts.txt

if [ ! -s /tmp/installed_charts.txt ]; then
  echo -e "${YELLOW} ⚠️ No Helm releases found."
  exit 0
fi

# Initialize message
ALERT_MESSAGE="🚀 *Helm Chart Updates Check*\n"

echo -e "${BLUE}------------------------------"
echo -e "| Checking Helm Chart Versions |"
echo -e "------------------------------${RESET}"

while read -r line; do
  release_name=$(echo "$line" | awk '{print $1}')
  chart=$(echo "$line" | awk '{print $2}')
  installed_version=$(echo "$line" | awk '{print $3}')
  
  latest_version=$(helm search repo "$chart" --output json | jq -r '.[0].version' || echo "not_found")
 
  if [ -n "$latest_version" ] && [ "$latest_version" != "null" ]; then
    if printf "%s\n%s" "$installed_version" "$latest_version" | sort -V | tail -n1 | grep -q "$latest_version"; then
      if [ "$installed_version" != "$latest_version" ]; then
        echo -e "${RED}🚀 Update available for $release_name ($chart): $installed_version -> $latest_version${RESET}"
        ALERT_MESSAGE="$ALERT_MESSAGE 🚀 *Update available for $release_name ($chart)*: $installed_version -> $latest_version\n"
      else
        echo -e "${GREEN}✅ $release_name ($chart) is up-to-date: $installed_version${RESET}"
        ALERT_MESSAGE="$ALERT_MESSAGE ✅ *$release_name ($chart) is up-to-date*: $installed_version\n"
      fi
    else
      echo -e "${YELLOW}❌ Version comparison failed for $release_name ($chart): $installed_version vs. $latest_version${RESET}"
      ALERT_MESSAGE="$ALERT_MESSAGE ❌ *Version comparison failed for $release_name ($chart)*: $installed_version vs. $latest_version\n"
    fi
  else
    echo -e "${YELLOW}⚠️ Could not retrieve latest version for $release_name ($chart)${RESET}"
    ALERT_MESSAGE="$ALERT_MESSAGE ⚠️ *Could not retrieve latest version for $release_name ($chart)*\n"
  fi
done < /tmp/installed_charts.txt


echo -e "${BLUE}#############################"
echo -e "#  📢 Helm Check Completed  #"
echo -e "#############################${RESET}"
echo -e "$ALERT_MESSAGE"

if [ "$ALERT_TYPE" = "slack" ]; then
  echo "Sending alert to Slack..."
  curl -X POST -H 'Content-type: application/json' \
    --data "{\"channel\": \"$SLACK_CHANNEL\", \"username\": \"$SLACK_USERNAME\", \"icon_emoji\": \"$SLACK_ICON\", \"text\": \"$ALERT_MESSAGE\"}" \
    "$SLACK_WEBHOOK"
elif [ "$ALERT_TYPE" = "webhook" ]; then
  echo "Sending alert to Webhook..."
  curl -X POST -H 'Content-type: application/json' \
    --data "{\"message\": \"$ALERT_MESSAGE\"}" \
    "$WEBHOOK_URL"
else
  echo -e "${GREEN}📢 Results printed successfully.${RESET}"
fi
{{- end }}
