# Pype CLI Demo

This is a fully functional demo of the Pype CLI that works with dummy data. It simulates all the functionality described in the command reference, allowing you to explore the workflow without connecting to a real backend.

## Prerequisites

- Bash shell environment
- `jq` command-line JSON processor
- Linux, macOS, or Windows with WSL (Windows Subsystem for Linux)

## Installation

1. Download the installation script:

```bash
curl -O https://raw.githubusercontent.com/Darkness447/pypedemo-cli/main/install.sh
# or save the install script to a file named install.sh
```

2. Make the script executable:

```bash
chmod +x install.sh
```

3. Run the installation script:

```bash
./install.sh
```

The script will:
- Create necessary configuration directories
- Install the `pype` command to your `~/.local/bin` directory
- Add `~/.local/bin` to your PATH if needed
- Check for required dependencies

## Quick Start

After installation, you can immediately start using the Pype CLI. Here's a quick workflow:

```bash
# Login to pype
pype login

# List available projects
pype projects list

# Select a project
pype project select --name "Project2"

# List workflows in the selected project
pype workflows list

# Select a workflow
pype workflow select --name "workflow-b"

# Suggest metrics
pype metrics suggest

# Select a metric
pype metric select --id 2
# Follow the interactive prompts to work with the metric

# Deploy a metric
pype metrics deploy --id "relevance_metric"

# Logout when finished
pype logout
```

## Available Commands

### Authentication

- `pype login` - Log in with a demo user account
- `pype logout` - Log out and clear session data

### Project Management

- `pype projects list` - List all available projects
- `pype project select --name "Project Name"` - Select a project to work with

### Workflow Management

- `pype workflows list` - List all workflows in the selected project
- `pype workflow select --name "workflow-name"` - Select a workflow to work with

### Metric Management

- `pype metrics suggest` - List available metrics with scores and descriptions
- `pype metric select --id <metric_id>` - Select a metric and interact with it
- `pype metrics deploy --id "metric_name"` - Deploy a metric

## Interactive Metric Options

When you select a metric using `pype metric select --id <metric_id>`, you'll be presented with three options:

1. **Align metric (test and refine with feedback)**
   - Tests the metric on sample logs
   - Allows you to accept or adjust the scores
   - Collects feedback for refinement

2. **Break down metric into sub-components**
   - Divides the metric into more specific sub-metrics
   - Shows the relationship between the components

3. **Edit metric definition**
   - Allows you to directly modify the metric's description
   - Updates the definition in the mock database

## Data Storage

The demo stores all data locally in the `~/.pype-demo` directory:

- `user.json` - Current user session
- `current_project.txt` - Selected project ID
- `current_workflow.txt` - Selected workflow ID
- `current_metric.txt` - Selected metric ID
- `projects.json` - Mock projects database
- `workflows.json` - Mock workflows database
- `metrics.json` - Mock metrics database

## Customization

You can customize the dummy data by directly editing the JSON files in the `~/.pype-demo` directory. For example, to add more projects:

1. Edit the projects database:
```bash
nano ~/.pype-demo/projects.json
```

2. Add new entries following the existing format:
```json
[
  {"id": 1, "name": "Project1", "description": "First demo project"},
  {"id": 2, "name": "Project2", "description": "Second demo project"},
  {"id": 3, "name": "Project3", "description": "Third demo project"},
  {"id": 4, "name": "MyNewProject", "description": "My custom project"}
]
```

You can similarly modify workflows and metrics to suit your demonstration needs.

## Uninstallation

To remove the Pype CLI Demo, run:

```bash
rm ~/.local/bin/pype
rm -rf ~/.pype-demo
```

## Troubleshooting

### Command not found

If you get a "command not found" error when running `pype`, make sure:

1. The installation completed successfully
2. `~/.local/bin` is in your PATH (you may need to restart your terminal)
3. The script is executable (`chmod +x ~/.local/bin/pype`)

### JSON parsing errors

If you see errors related to JSON parsing:

1. Verify that `jq` is installed: `which jq`
2. Check that the data files in `~/.pype-demo` contain valid JSON
3. If a file is corrupted, you can remove it and the CLI will recreate it with default values on the next run

### Interactive prompts not working

If the interactive prompts (like when selecting metric options) aren't working:

1. Make sure you're running in an interactive terminal
2. Some cloud shell environments or CI/CD pipelines may not support interactive input