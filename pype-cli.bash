#!/bin/bash

# Configuration directory for storing state
CONFIG_DIR="$HOME/.pype-demo"
mkdir -p "$CONFIG_DIR"

# Default files
USER_FILE="$CONFIG_DIR/user.json"
CURRENT_PROJECT_FILE="$CONFIG_DIR/current_project.txt"
CURRENT_WORKFLOW_FILE="$CONFIG_DIR/current_workflow.txt"
CURRENT_METRIC_FILE="$CONFIG_DIR/current_metric.txt"

# Mock data files
PROJECTS_FILE="$CONFIG_DIR/projects.json"
WORKFLOWS_FILE="$CONFIG_DIR/workflows.json"
METRICS_FILE="$CONFIG_DIR/metrics.json"

# Create mock data if it doesn't exist
init_mock_data() {
  if [ ! -f "$PROJECTS_FILE" ]; then
    echo '[
      {"id": 1, "name": "Project1", "description": "First demo project"},
      {"id": 2, "name": "Project2", "description": "Second demo project"},
      {"id": 3, "name": "Project3", "description": "Third demo project"}
    ]' > "$PROJECTS_FILE"
  fi

  if [ ! -f "$WORKFLOWS_FILE" ]; then
    echo '[
      {"id": 1, "project_id": 1, "name": "workflow-a", "description": "A sample workflow"},
      {"id": 2, "project_id": 1, "name": "workflow-b", "description": "Another workflow"},
      {"id": 3, "project_id": 2, "name": "workflow-b", "description": "Project 2 workflow B"},
      {"id": 4, "project_id": 2, "name": "workflow-c", "description": "Project 2 workflow C"},
      {"id": 5, "project_id": 3, "name": "workflow-a", "description": "Project 3 workflow A"}
    ]' > "$WORKFLOWS_FILE"
  fi

  if [ ! -f "$METRICS_FILE" ]; then
    echo '[
      {"id": 1, "name": "accuracy_metric", "score": 0.92, "description": "Measures response accuracy against ground truth"},
      {"id": 2, "name": "relevance_metric", "score": 0.85, "description": "Evaluates response relevance to user query"},
      {"id": 3, "name": "safety_metric", "score": 0.89, "description": "Assesses content safety and policy adherence"}
    ]' > "$METRICS_FILE"
  fi
}

# Check if user is logged in
is_logged_in() {
  [ -f "$USER_FILE" ]
}

# Check if a project is selected
is_project_selected() {
  [ -f "$CURRENT_PROJECT_FILE" ]
}

# Check if a workflow is selected
is_workflow_selected() {
  [ -f "$CURRENT_WORKFLOW_FILE" ]
}

# Login command
login() {
  if is_logged_in; then
    echo "Already logged in. Use 'pype logout' first to login with a different account."
    return
  fi

  # For demo purposes, we'll just create a mock user
  local email=${1:-"user@example.com"}
  echo "{\"email\": \"$email\", \"logged_in\": true}" > "$USER_FILE"
  echo "Successfully logged in as $email"
}

# Logout command
logout() {
  if ! is_logged_in; then
    echo "Not logged in."
    return
  fi

  # Remove user file and current selections
  rm -f "$USER_FILE" "$CURRENT_PROJECT_FILE" "$CURRENT_WORKFLOW_FILE" "$CURRENT_METRIC_FILE"
  echo "Successfully logged out"
}

# List projects command
list_projects() {
  if ! is_logged_in; then
    echo "Not logged in. Use 'pype login' first."
    return 1
  fi

  local projects=$(cat "$PROJECTS_FILE" | jq -r '.[].name' | tr '\n' ', ')
  echo "${projects%,}"
}

# Select project command
select_project() {
  if ! is_logged_in; then
    echo "Not logged in. Use 'pype login' first."
    return 1
  fi

  local project_name=$1
  if [ -z "$project_name" ]; then
    echo "Error: Project name is required."
    return 1
  fi

  # Check if project exists
  local project_exists=$(cat "$PROJECTS_FILE" | jq -r ".[] | select(.name == \"$project_name\") | .id")
  if [ -z "$project_exists" ]; then
    echo "Error: Project '$project_name' not found."
    return 1
  fi

  echo "$project_exists" > "$CURRENT_PROJECT_FILE"
  echo "Selected $project_name"
}

# List workflows command
list_workflows() {
  if ! is_logged_in; then
    echo "Not logged in. Use 'pype login' first."
    return 1
  fi

  if ! is_project_selected; then
    echo "No project selected. Use 'pype project select --name \"Project Name\"' first."
    return 1
  fi

  local project_id=$(cat "$CURRENT_PROJECT_FILE")
  local workflows=$(cat "$WORKFLOWS_FILE" | jq -r ".[] | select(.project_id == $project_id) | .name" | tr '\n' ', ')
  echo "${workflows%,}"
}

# Select workflow command
select_workflow() {
  if ! is_logged_in; then
    echo "Not logged in. Use 'pype login' first."
    return 1
  fi

  if ! is_project_selected; then
    echo "No project selected. Use 'pype project select --name \"Project Name\"' first."
    return 1
  fi

  local workflow_name=$1
  if [ -z "$workflow_name" ]; then
    echo "Error: Workflow name is required."
    return 1
  fi

  local project_id=$(cat "$CURRENT_PROJECT_FILE")
  
  # Check if workflow exists for the selected project
  local workflow_id=$(cat "$WORKFLOWS_FILE" | jq -r ".[] | select(.project_id == $project_id and .name == \"$workflow_name\") | .id")
  if [ -z "$workflow_id" ]; then
    echo "Error: Workflow '$workflow_name' not found in the selected project."
    return 1
  fi

  echo "$workflow_id" > "$CURRENT_WORKFLOW_FILE"
  echo "Selected $workflow_name"
}

# Suggest metrics command
suggest_metrics() {
  if ! is_logged_in; then
    echo "Not logged in. Use 'pype login' first."
    return 1
  fi

  cat "$METRICS_FILE" | jq -r '.[] | "  \(.id). \(.name) (score: \(.score)) - \(.description)"'
}

# Select metric command
select_metric() {
  if ! is_logged_in; then
    echo "Not logged in. Use 'pype login' first."
    return 1
  fi

  local metric_id=$1
  if [ -z "$metric_id" ]; then
    echo "Error: Metric ID is required."
    return 1
  fi

  # Check if metric exists
  local metric_name=$(cat "$METRICS_FILE" | jq -r ".[] | select(.id == $metric_id) | .name")
  if [ -z "$metric_name" ]; then
    echo "Error: Metric with ID '$metric_id' not found."
    return 1
  fi

  echo "$metric_id" > "$CURRENT_METRIC_FILE"
  echo "Selected $metric_name"
  echo "What would you like to do with $metric_name?"
  echo "1. Align metric (test and refine with feedback)"
  echo "2. Break down metric into sub-components"
  echo "3. Edit metric definition"
  echo "Select an option (1-3):"
  read -r option

  case $option in
    1)
      align_metric
      ;;
    2)
      break_down_metric
      ;;
    3)
      edit_metric
      ;;
    *)
      echo "Invalid option"
      ;;
  esac
}

# Align metric (option 1)
align_metric() {
  local metric_id=$(cat "$CURRENT_METRIC_FILE")
  local metric_name=$(cat "$METRICS_FILE" | jq -r ".[] | select(.id == $metric_id) | .name")
  
  echo "Testing $metric_name on sample logs..."
  
  for i in {1..3}; do
    echo "Output for Log $i:"
    local score=$(awk "BEGIN {print 0.5 + 0.3*rand()}")
    echo "  Score: $score"
    echo "  Reasoning: \"Response addresses the main query but misses some context...\""
    echo "  Accept this score? (y/n):"
    read -r accept
    
    if [ "$accept" == "n" ]; then
      echo "  What should the score be? (0-1):"
      read -r new_score
      echo "  Reason for adjustment:"
      read -r reason
      echo "  Score adjusted to $new_score: \"$reason\""
    fi
  done
  
  echo "Metric aligned based on feedback"
}

# Break down metric (option 2)
break_down_metric() {
  local metric_id=$(cat "$CURRENT_METRIC_FILE")
  local metric_name=$(cat "$METRICS_FILE" | jq -r ".[] | select(.id == $metric_id) | .name")
  
  echo "Breaking down $metric_name into sub-components:"
  echo "1. query_relevance - Measures relevance to specific query points"
  echo "2. context_adherence - Evaluates staying within context"
  echo "3. information_completeness - Assesses completeness of information"
  echo "Sub-metrics created and ready for use"
}

# Edit metric (option 3)
edit_metric() {
  local metric_id=$(cat "$CURRENT_METRIC_FILE")
  local metric_name=$(cat "$METRICS_FILE" | jq -r ".[] | select(.id == $metric_id) | .name")
  local description=$(cat "$METRICS_FILE" | jq -r ".[] | select(.id == $metric_id) | .description")
  
  echo "Opening simplified metric editor for $metric_name:"
  echo "Current definition: $description"
  echo "Enter new definition:"
  read -r new_definition
  
  # Update the metric definition in the file
  cat "$METRICS_FILE" | jq "map(if .id == $metric_id then .description = \"$new_definition\" else . end)" > "$CONFIG_DIR/temp.json"
  mv "$CONFIG_DIR/temp.json" "$METRICS_FILE"
  
  echo "Metric definition updated successfully"
}

# Deploy metric command
deploy_metric() {
  if ! is_logged_in; then
    echo "Not logged in. Use 'pype login' first."
    return 1
  fi

  local metric_name=$1
  if [ -z "$metric_name" ]; then
    echo "Error: Metric name is required."
    return 1
  fi

  # Check if metric exists
  local metric_exists=$(cat "$METRICS_FILE" | jq -r ".[] | select(.name == \"$metric_name\") | .id")
  if [ -z "$metric_exists" ]; then
    echo "Error: Metric '$metric_name' not found."
    return 1
  fi

  echo "Metric $metric_name deployed successfully"
}

# Main command handler
pype() {
  # Initialize mock data if it doesn't exist
  init_mock_data

  # Parse commands
  case "$1" in
    login)
      login "$2"
      ;;
    logout)
      logout
      ;;
    projects)
      case "$2" in
        list)
          list_projects
          ;;
        *)
          echo "Unknown projects subcommand. Available: list"
          ;;
      esac
      ;;
    project)
      case "$2" in
        select)
          if [ "$3" == "--name" ]; then
            select_project "$4"
          else
            echo "Usage: pype project select --name \"Project Name\""
          fi
          ;;
        *)
          echo "Unknown project subcommand. Available: select"
          ;;
      esac
      ;;
    workflows)
      case "$2" in
        list)
          list_workflows
          ;;
        *)
          echo "Unknown workflows subcommand. Available: list"
          ;;
      esac
      ;;
    workflow)
      case "$2" in
        select)
          if [ "$3" == "--name" ]; then
            select_workflow "$4"
          else
            echo "Usage: pype workflow select --name \"workflow-name\""
          fi
          ;;
        *)
          echo "Unknown workflow subcommand. Available: select"
          ;;
      esac
      ;;
    metrics)
      case "$2" in
        suggest)
          suggest_metrics
          ;;
        deploy)
          if [ "$3" == "--id" ]; then
            deploy_metric "$4"
          else
            echo "Usage: pype metrics deploy --id \"metric_name\""
          fi
          ;;
        *)
          echo "Unknown metrics subcommand. Available: suggest, deploy"
          ;;
      esac
      ;;
    metric)
      case "$2" in
        select)
          if [ "$3" == "--id" ]; then
            select_metric "$4"
          else
            echo "Usage: pype metric select --id <metric_id>"
          fi
          ;;
        *)
          echo "Unknown metric subcommand. Available: select"
          ;;
      esac
      ;;
    *)
      echo "Pype CLI Demo"
      echo "Available commands:"
      echo "  pype login"
      echo "  pype logout"
      echo "  pype projects list"
      echo "  pype project select --name \"Project Name\""
      echo "  pype workflows list"
      echo "  pype workflow select --name \"workflow-name\""
      echo "  pype metrics suggest"
      echo "  pype metric select --id <metric_id>"
      echo "  pype metrics deploy --id \"metric_name\""
      ;;
  esac
}

# If script is sourced, do nothing, if executed directly, handle arguments
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  pype "$@"
fi