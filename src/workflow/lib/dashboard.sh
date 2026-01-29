#!/bin/bash
set -euo pipefail

################################################################################
# Workflow Dashboard Module
# Version: 3.0.0
# Purpose: Generate interactive HTML dashboards from workflow metrics
#
# Features:
#   - Parse workflow logs to JSON metrics
#   - Generate interactive HTML reports
#   - Step duration visualizations
#   - Skip reason analytics
#   - Change impact analysis
#   - Historical comparisons
#   - Stakeholder-ready reports
#
# Output: Self-contained HTML dashboard with embedded CSS/JS
################################################################################

# Set defaults
WORKFLOW_HOME=${WORKFLOW_HOME:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}
PROJECT_ROOT="${PROJECT_ROOT:-$(pwd)}"
DASHBOARD_DIR="${PROJECT_ROOT}/.ai_workflow/dashboards"
METRICS_DIR="${PROJECT_ROOT}/.ai_workflow/metrics"

# ==============================================================================
# LOG PARSING
# ==============================================================================

# Parse workflow execution log to JSON
# Args: $1 = log_file
parse_workflow_log() {
    local log_file="$1"
    
    if [[ ! -f "$log_file" ]]; then
        print_error "Log file not found: $log_file"
        return 1
    fi
    
    local output="{}"
    
    # Extract workflow metadata
    local workflow_id=$(grep "Workflow ID:" "$log_file" | head -1 | awk -F': ' '{print $2}')
    local start_time=$(grep "Started:" "$log_file" | head -1 | awk -F': ' '{print $2}')
    local mode=$(grep "Mode:" "$log_file" | head -1 | awk -F': ' '{print $2}')
    
    # Extract step data
    local steps_json="[]"
    
    # Parse completed steps
    while IFS= read -r line; do
        if [[ "$line" =~ Step\ ([0-9]+):\ (.*) ]]; then
            local step_num="${BASH_REMATCH[1]}"
            local step_name="${BASH_REMATCH[2]}"
            
            # Try to find duration and validate it's a number
            local duration=$(grep -A 5 "Step $step_num:" "$log_file" | grep -oP 'Duration: \K[0-9]+' | head -1 || echo "0")
            duration=$(echo "$duration" | tr -d '[:space:]')
            duration=${duration:-0}
            [[ ! "$duration" =~ ^[0-9]+$ ]] && duration=0
            
            local status=$(grep -A 5 "Step $step_num:" "$log_file" | grep -oP 'Status: \K\w+' | head -1 || echo "unknown")
            
            steps_json=$(echo "$steps_json" | jq --arg num "$step_num" \
                --arg name "$step_name" \
                --argjson dur "$duration" \
                --arg stat "$status" \
                '. += [{"step": $num, "name": $name, "duration": $dur, "status": $stat}]')
        fi
    done < "$log_file"
    
    # Build complete JSON
    output=$(jq -n \
        --arg id "$workflow_id" \
        --arg start "$start_time" \
        --arg mode "$mode" \
        --argjson steps "$steps_json" \
        '{
            workflow_id: $id,
            start_time: $start,
            mode: $mode,
            steps: $steps
        }')
    
    echo "$output"
}

# ==============================================================================
# DASHBOARD GENERATION
# ==============================================================================

# Generate HTML dashboard
# Args: $1 = metrics_json, $2 = output_file
generate_dashboard() {
    local metrics_json="$1"
    local output_file="$2"
    
    mkdir -p "$(dirname "$output_file")"
    
    # Generate self-contained HTML with embedded CSS and JavaScript
    cat > "$output_file" << 'DASHBOARD_HTML'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AI Workflow Dashboard</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: #333;
            padding: 20px;
            min-height: 100vh;
        }
        
        .container {
            max-width: 1400px;
            margin: 0 auto;
        }
        
        header {
            background: white;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            margin-bottom: 30px;
        }
        
        h1 {
            color: #667eea;
            font-size: 2.5em;
            margin-bottom: 10px;
        }
        
        .subtitle {
            color: #666;
            font-size: 1.1em;
        }
        
        .metrics-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .metric-card {
            background: white;
            padding: 25px;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            transition: transform 0.2s;
        }
        
        .metric-card:hover {
            transform: translateY(-5px);
        }
        
        .metric-value {
            font-size: 2.5em;
            font-weight: bold;
            color: #667eea;
            margin: 10px 0;
        }
        
        .metric-label {
            color: #666;
            font-size: 0.9em;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        
        .chart-container {
            background: white;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            margin-bottom: 30px;
        }
        
        .chart-title {
            font-size: 1.5em;
            color: #333;
            margin-bottom: 20px;
            font-weight: 600;
        }
        
        .bar-chart {
            display: flex;
            flex-direction: column;
            gap: 15px;
        }
        
        .bar-item {
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .bar-label {
            min-width: 180px;
            font-weight: 500;
            color: #555;
        }
        
        .bar-container {
            flex: 1;
            height: 30px;
            background: #f0f0f0;
            border-radius: 15px;
            overflow: hidden;
            position: relative;
        }
        
        .bar-fill {
            height: 100%;
            background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
            border-radius: 15px;
            transition: width 0.5s ease;
        }
        
        .bar-value {
            min-width: 60px;
            text-align: right;
            font-weight: 600;
            color: #667eea;
        }
        
        .status-badge {
            display: inline-block;
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 0.85em;
            font-weight: 600;
            text-transform: uppercase;
        }
        
        .status-success { background: #d4edda; color: #155724; }
        .status-failed { background: #f8d7da; color: #721c24; }
        .status-skipped { background: #fff3cd; color: #856404; }
        
        table {
            width: 100%;
            border-collapse: collapse;
        }
        
        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        
        th {
            background: #f8f9fa;
            font-weight: 600;
            color: #667eea;
        }
        
        tr:hover {
            background: #f8f9fa;
        }
        
        footer {
            text-align: center;
            color: white;
            padding: 20px;
            margin-top: 30px;
        }
        
        @media (max-width: 768px) {
            .metrics-grid {
                grid-template-columns: 1fr;
            }
            
            .bar-label {
                min-width: 120px;
                font-size: 0.9em;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>🚀 AI Workflow Dashboard</h1>
            <p class="subtitle">Performance Analytics & Insights</p>
        </header>
        
        <div class="metrics-grid" id="metricsGrid"></div>
        
        <div class="chart-container">
            <h2 class="chart-title">Step Duration Analysis</h2>
            <div class="bar-chart" id="durationChart"></div>
        </div>
        
        <div class="chart-container">
            <h2 class="chart-title">Workflow Execution Details</h2>
            <table id="stepsTable">
                <thead>
                    <tr>
                        <th>Step</th>
                        <th>Name</th>
                        <th>Duration</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody></tbody>
            </table>
        </div>
        
        <footer>
            <p>Generated by AI Workflow Automation v3.0.0</p>
            <p>Last updated: <span id="timestamp"></span></p>
        </footer>
    </div>
    
    <script>
        // Embedded metrics data (replaced by generator)
        const METRICS_DATA = __METRICS_JSON__;
        
        // Initialize dashboard
        function initDashboard() {
            renderMetricCards();
            renderDurationChart();
            renderStepsTable();
            updateTimestamp();
        }
        
        function renderMetricCards() {
            const grid = document.getElementById('metricsGrid');
            const metrics = calculateMetrics();
            
            const cards = [
                { label: 'Total Duration', value: metrics.totalDuration + 's', icon: '⏱️' },
                { label: 'Steps Completed', value: metrics.stepsCompleted, icon: '✅' },
                { label: 'Steps Skipped', value: metrics.stepsSkipped, icon: '⏭️' },
                { label: 'Success Rate', value: metrics.successRate + '%', icon: '📊' }
            ];
            
            cards.forEach(card => {
                const div = document.createElement('div');
                div.className = 'metric-card';
                div.innerHTML = `
                    <div class="metric-label">${card.icon} ${card.label}</div>
                    <div class="metric-value">${card.value}</div>
                `;
                grid.appendChild(div);
            });
        }
        
        function renderDurationChart() {
            const chart = document.getElementById('durationChart');
            const steps = METRICS_DATA.steps || [];
            const maxDuration = Math.max(...steps.map(s => s.duration || 0));
            
            steps.forEach(step => {
                const duration = step.duration || 0;
                const percentage = maxDuration > 0 ? (duration / maxDuration) * 100 : 0;
                
                const item = document.createElement('div');
                item.className = 'bar-item';
                item.innerHTML = `
                    <div class="bar-label">Step ${step.step}: ${step.name}</div>
                    <div class="bar-container">
                        <div class="bar-fill" style="width: ${percentage}%"></div>
                    </div>
                    <div class="bar-value">${duration}s</div>
                `;
                chart.appendChild(item);
            });
        }
        
        function renderStepsTable() {
            const tbody = document.querySelector('#stepsTable tbody');
            const steps = METRICS_DATA.steps || [];
            
            steps.forEach(step => {
                const row = document.createElement('tr');
                const statusClass = `status-${step.status || 'unknown'}`;
                
                row.innerHTML = `
                    <td>${step.step}</td>
                    <td>${step.name}</td>
                    <td>${step.duration}s</td>
                    <td><span class="status-badge ${statusClass}">${step.status}</span></td>
                `;
                tbody.appendChild(row);
            });
        }
        
        function calculateMetrics() {
            const steps = METRICS_DATA.steps || [];
            const totalDuration = steps.reduce((sum, s) => sum + (s.duration || 0), 0);
            const stepsCompleted = steps.filter(s => s.status === 'success').length;
            const stepsSkipped = steps.filter(s => s.status === 'skipped').length;
            const successRate = steps.length > 0 ? Math.round((stepsCompleted / steps.length) * 100) : 0;
            
            return { totalDuration, stepsCompleted, stepsSkipped, successRate };
        }
        
        function updateTimestamp() {
            document.getElementById('timestamp').textContent = new Date().toLocaleString();
        }
        
        // Initialize on load
        document.addEventListener('DOMContentLoaded', initDashboard);
    </script>
</body>
</html>
DASHBOARD_HTML
    
    # Replace placeholder with actual metrics
    local escaped_json=$(echo "$metrics_json" | sed 's/"/\\"/g' | tr -d '\n')
    sed -i "s|__METRICS_JSON__|$metrics_json|g" "$output_file"
    
    print_success "Dashboard generated: $output_file"
    echo "$output_file"
}

# ==============================================================================
# METRICS EXTRACTION
# ==============================================================================

# Extract comprehensive metrics from current run
extract_current_metrics() {
    local metrics_file="${METRICS_DIR}/current_run.json"
    
    if [[ ! -f "$metrics_file" ]]; then
        print_warning "No current metrics file found"
        return 1
    fi
    
    cat "$metrics_file"
}

# Generate dashboard from current workflow
generate_current_dashboard() {
    local metrics=$(extract_current_metrics)
    local dashboard_file="${DASHBOARD_DIR}/current_dashboard.html"
    
    generate_dashboard "$metrics" "$dashboard_file"
}

# ==============================================================================
# DASHBOARD SERVER (OPTIONAL)
# ==============================================================================

# Serve dashboard on local HTTP server
# Args: $1 = dashboard_file, $2 = port (default: 8080)
serve_dashboard() {
    local dashboard_file="$1"
    local port="${2:-8080}"
    
    if [[ ! -f "$dashboard_file" ]]; then
        print_error "Dashboard file not found: $dashboard_file"
        return 1
    fi
    
    print_header "Starting Dashboard Server"
    print_info "Dashboard: http://localhost:$port"
    print_info "Press Ctrl+C to stop"
    
    # Use Python's built-in HTTP server
    if command -v python3 >/dev/null 2>&1; then
        cd "$(dirname "$dashboard_file")"
        python3 -m http.server "$port"
    elif command -v python >/dev/null 2>&1; then
        cd "$(dirname "$dashboard_file")"
        python -m SimpleHTTPServer "$port"
    else
        print_error "Python not found. Cannot start HTTP server."
        print_info "Open dashboard directly: file://$dashboard_file"
        return 1
    fi
}

# ==============================================================================
# EXPORTS
# ==============================================================================

export -f parse_workflow_log
export -f generate_dashboard
export -f extract_current_metrics
export -f generate_current_dashboard
export -f serve_dashboard

################################################################################
# End of Workflow Dashboard Module
################################################################################
