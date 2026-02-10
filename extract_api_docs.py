#!/usr/bin/env python3
"""
API Documentation Extractor for AI Workflow Automation
Parses shell script modules to extract comprehensive API documentation
"""

import os
import re
from pathlib import Path
from collections import defaultdict
from typing import List, Dict, Tuple

LIB_DIR = Path("/home/mpb/Documents/GitHub/ai_workflow/src/workflow/lib")
OUTPUT_FILE = Path("/home/mpb/Documents/GitHub/ai_workflow/docs/api/COMPLETE_API_REFERENCE.md")

# Module categories for organization
MODULE_CATEGORIES = {
    "ai_cache.sh": "AI & Caching",
    "ai_helpers.sh": "AI & Caching",
    "ai_personas.sh": "AI & Caching",
    "ai_prompt_builder.sh": "AI & Caching",
    "ai_validation.sh": "AI & Caching",
    "analysis_cache.sh": "AI & Caching",
    "change_detection.sh": "Core Infrastructure",
    "metrics.sh": "Core Infrastructure",
    "workflow_optimization.sh": "Core Infrastructure",
    "tech_stack.sh": "Core Infrastructure",
    "config.sh": "Configuration",
    "config_wizard.sh": "Configuration",
    "project_kind_config.sh": "Configuration",
    "project_kind_detection.sh": "Configuration",
    "git_automation.sh": "Git Operations",
    "git_cache.sh": "Git Operations",
    "git_submodule_helpers.sh": "Git Operations",
    "auto_commit.sh": "Git Operations",
    "batch_ai_commit.sh": "Git Operations",
    "file_operations.sh": "File Operations",
    "edit_operations.sh": "File Operations",
    "doc_section_extractor.sh": "Documentation",
    "doc_section_mapper.sh": "Documentation",
    "doc_template_validator.sh": "Documentation",
    "auto_documentation.sh": "Documentation",
    "changelog_generator.sh": "Documentation",
    "link_validator.sh": "Documentation",
    "validation.sh": "Validation & Testing",
    "enhanced_validations.sh": "Validation & Testing",
    "metrics_validation.sh": "Validation & Testing",
    "api_coverage.sh": "Validation & Testing",
    "code_example_tester.sh": "Validation & Testing",
    "deployment_validator.sh": "Validation & Testing",
    "step_execution.sh": "Step Management",
    "step_loader.sh": "Step Management",
    "step_metadata.sh": "Step Management",
    "step_registry.sh": "Step Management",
    "step_adaptation.sh": "Step Management",
    "step_validation_cache.sh": "Step Management",
    "step_validation_cache_integration.sh": "Step Management",
    "session_manager.sh": "Session & State",
    "backlog.sh": "Session & State",
    "summary.sh": "Session & State",
    "dependency_cache.sh": "Optimization",
    "dependency_graph.sh": "Optimization",
    "code_changes_optimization.sh": "Optimization",
    "docs_only_optimization.sh": "Optimization",
    "full_changes_optimization.sh": "Optimization",
    "conditional_execution.sh": "Optimization",
    "incremental_analysis.sh": "Optimization",
    "skip_predictor.sh": "Optimization",
    "ml_optimization.sh": "Optimization",
    "multi_stage_pipeline.sh": "Optimization",
    "workflow_profiles.sh": "Optimization",
    "performance.sh": "Performance & Monitoring",
    "performance_monitoring.sh": "Performance & Monitoring",
    "dashboard.sh": "Performance & Monitoring",
    "model_selector.sh": "AI Model Selection",
    "utils.sh": "Utilities",
    "colors.sh": "Utilities",
    "jq_wrapper.sh": "Utilities",
    "argument_parser.sh": "Utilities",
    "health_check.sh": "Utilities",
    "third_party_exclusion.sh": "Utilities",
    "version_bump.sh": "Utilities",
    "cleanup_handlers.sh": "Cleanup",
    "cleanup_template.sh": "Cleanup",
    "audio_notifications.sh": "User Experience",
    "precommit_hooks.sh": "Hooks",
}


def extract_module_purpose(file_path: Path) -> str:
    """Extract module purpose from header comments."""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
            
        for i, line in enumerate(lines):
            line = line.strip()
            
            # Skip shebang
            if line.startswith('#!'):
                continue
            
            # Skip empty comment lines
            if line == '#':
                continue
            
            # Extract first meaningful comment
            if line.startswith('#'):
                comment = line[1:].strip()
                if comment and not comment.startswith('-') and not comment.startswith('='):
                    return comment
            
            # Stop at first non-comment line
            if not line.startswith('#') and line:
                break
                
    except Exception as e:
        print(f"Error reading {file_path}: {e}")
    
    return ""


def extract_functions(file_path: Path) -> List[Tuple[str, int, List[str]]]:
    """Extract all function definitions with their line numbers and preceding comments."""
    functions = []
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        
        func_pattern = re.compile(r'^\s*(function\s+)?([a-zA-Z_][a-zA-Z0-9_]*)\s*\(\)')
        
        for i, line in enumerate(lines):
            match = func_pattern.match(line)
            if match:
                func_name = match.group(2)
                
                # Extract preceding comments
                comments = []
                j = i - 1
                while j >= 0 and lines[j].strip().startswith('#'):
                    comment = lines[j].strip()[1:].strip()
                    if comment:  # Skip empty comment lines
                        comments.insert(0, comment)
                    j -= 1
                
                functions.append((func_name, i + 1, comments))
        
    except Exception as e:
        print(f"Error parsing {file_path}: {e}")
    
    return functions


def format_function_doc(func_name: str, line_num: int, comments: List[str]) -> str:
    """Format function documentation in markdown."""
    doc = f"### `{func_name}`\n\n"
    
    if comments:
        # Parse structured comments
        description = []
        parameters = []
        returns = []
        examples = []
        exit_codes = []
        notes = []
        
        current_section = description
        
        for comment in comments:
            comment_lower = comment.lower()
            
            if comment_lower.startswith('param'):
                current_section = parameters
                parameters.append(comment)
            elif comment_lower.startswith('return'):
                current_section = returns
                returns.append(comment)
            elif comment_lower.startswith('exit'):
                current_section = exit_codes
                exit_codes.append(comment)
            elif comment_lower.startswith('example'):
                current_section = examples
                examples.append(comment)
            elif comment_lower.startswith('note'):
                current_section = notes
                notes.append(comment)
            elif comment in ['---', '===', '']:
                continue
            else:
                current_section.append(comment)
        
        # Format description
        if description:
            doc += "**Description**: " + " ".join(description) + "\n\n"
        
        # Format parameters
        if parameters:
            doc += "**Parameters**:\n"
            for param in parameters:
                doc += f"- {param}\n"
            doc += "\n"
        
        # Format returns
        if returns:
            doc += "**Returns**: " + " ".join(returns) + "\n\n"
        
        # Format exit codes
        if exit_codes:
            doc += "**Exit Codes**:\n"
            for code in exit_codes:
                doc += f"- {code}\n"
            doc += "\n"
        
        # Format examples
        if examples:
            doc += "**Examples**:\n```bash\n"
            for example in examples:
                if not example.lower().startswith('example'):
                    doc += f"{example}\n"
            doc += "```\n\n"
        
        # Format notes
        if notes:
            doc += "**Notes**:\n"
            for note in notes:
                doc += f"- {note}\n"
            doc += "\n"
    else:
        doc += "*No documentation available*\n\n"
    
    doc += f"**Source Line**: {line_num}\n\n"
    doc += "---\n\n"
    
    return doc


def generate_toc(modules_by_category: Dict[str, List[Path]]) -> str:
    """Generate table of contents organized by category."""
    toc = "## Table of Contents\n\n"
    
    for category in sorted(modules_by_category.keys()):
        toc += f"### {category}\n\n"
        
        for module_path in sorted(modules_by_category[category]):
            module_name = module_path.name
            anchor = module_name.replace('.sh', '').replace('_', '-').lower()
            toc += f"- [{module_name}](#module-{anchor})\n"
        
        toc += "\n"
    
    toc += "---\n\n"
    return toc


def main():
    print("Extracting API documentation from library modules...")
    
    # Create output directory
    OUTPUT_FILE.parent.mkdir(parents=True, exist_ok=True)
    
    # Gather all modules
    modules = sorted([f for f in LIB_DIR.glob("*.sh") if not f.name.startswith("test_")])
    
    # Organize by category
    modules_by_category = defaultdict(list)
    for module in modules:
        category = MODULE_CATEGORIES.get(module.name, "Uncategorized")
        modules_by_category[category].append(module)
    
    # Count totals
    total_modules = len(modules)
    total_functions = 0
    
    print(f"Found {total_modules} modules")
    
    # Start building documentation
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as out:
        # Write header
        out.write("# Complete API Reference - AI Workflow Automation\n\n")
        out.write("> **Version**: 4.0.1  \n")
        out.write("> **Last Updated**: 2026-02-09  \n")
        out.write("> **Generated**: Auto-generated from source code  \n\n")
        out.write(f"**Total Modules**: {total_modules}  \n")
        
        # We'll update function count after processing
        function_count_pos = out.tell()
        out.write("**Total Functions**: [calculating...]  \n\n")
        
        # Write TOC
        out.write(generate_toc(modules_by_category))
        
        # Process each module by category
        module_count = 0
        for category in sorted(modules_by_category.keys()):
            for module_path in sorted(modules_by_category[category]):
                module_count += 1
                module_name = module_path.name
                
                print(f"Processing [{module_count}/{total_modules}] {module_name}...")
                
                # Module header
                anchor = module_name.replace('.sh', '').replace('_', '-').lower()
                out.write(f"## Module: {module_name}\n\n")
                out.write(f"**Location**: `src/workflow/lib/{module_name}`  \n")
                out.write(f"**Category**: {category}\n\n")
                
                # Module purpose
                purpose = extract_module_purpose(module_path)
                if purpose:
                    out.write(f"**Purpose**: {purpose}\n\n")
                
                # Extract and document functions
                functions = extract_functions(module_path)
                func_count = len(functions)
                total_functions += func_count
                
                out.write(f"**Functions**: {func_count}\n\n")
                
                if functions:
                    for func_name, line_num, comments in functions:
                        out.write(format_function_doc(func_name, line_num, comments))
                else:
                    out.write("*No public functions documented*\n\n")
                
                out.write("\n")
        
        # Update function count
        out.seek(function_count_pos)
        out.write(f"**Total Functions**: {total_functions}  \n")
    
    print(f"\n✓ API documentation generated: {OUTPUT_FILE}")
    print(f"  Total modules: {total_modules}")
    print(f"  Total functions: {total_functions}")
    print(f"  File size: {OUTPUT_FILE.stat().st_size / 1024:.1f} KB")


if __name__ == "__main__":
    main()
