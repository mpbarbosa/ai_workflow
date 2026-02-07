#!/usr/bin/env python3
"""
API Documentation Validator
Validates structure and completeness of API documentation

Version: 1.0.0
Created: 2026-02-07
"""

import os
import sys
import re
from pathlib import Path
from typing import List, Dict, Tuple, Set

# ANSI color codes
RED = '\033[0;31m'
GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
BLUE = '\033[0;34m'
NC = '\033[0m'  # No Color

class APIDocValidator:
    """Validates API documentation structure and completeness"""
    
    def __init__(self, docs_dir: str = "docs/api"):
        self.docs_dir = Path(docs_dir)
        self.errors: List[str] = []
        self.warnings: List[str] = []
        self.successes: List[str] = []
        
    def error(self, msg: str) -> None:
        """Record an error"""
        self.errors.append(msg)
        print(f"{RED}✗ ERROR{NC}: {msg}", file=sys.stderr)
        
    def warning(self, msg: str) -> None:
        """Record a warning"""
        self.warnings.append(msg)
        print(f"{YELLOW}⚠ WARNING{NC}: {msg}", file=sys.stderr)
        
    def success(self, msg: str) -> None:
        """Record a success"""
        self.successes.append(msg)
        print(f"{GREEN}✓{NC} {msg}")
        
    def info(self, msg: str) -> None:
        """Print info message"""
        print(f"{BLUE}ℹ{NC} {msg}")
        
    def validate_all(self) -> int:
        """Run all validation checks. Returns 0 if valid, 1 if errors"""
        print("╔════════════════════════════════════════════════════════╗")
        print("║      API Documentation Validator v1.0.0               ║")
        print("╚════════════════════════════════════════════════════════╝")
        print()
        
        # Check if docs directory exists
        if not self.docs_dir.exists():
            self.info(f"API docs directory not found: {self.docs_dir}")
            self.info("Skipping API documentation validation (optional)")
            return 0
            
        self.info(f"Validating API documentation in: {self.docs_dir}")
        print()
        
        # Run validation checks
        self._validate_structure()
        self._validate_markdown_files()
        self._validate_code_examples()
        self._validate_cross_references()
        
        # Print summary
        print()
        print("═══ Validation Summary ═══")
        print(f"Successes: {len(self.successes)}")
        print(f"Warnings:  {len(self.warnings)}")
        print(f"Errors:    {len(self.errors)}")
        
        return 1 if self.errors else 0
        
    def _validate_structure(self) -> None:
        """Validate API documentation directory structure"""
        print("═══ Structure Validation ═══")
        
        # Check for README
        readme = self.docs_dir / "README.md"
        if readme.exists():
            self.success(f"API README found: {readme.name}")
        else:
            self.warning(f"API README not found: {readme}")
            
        # Count markdown files
        md_files = list(self.docs_dir.glob("**/*.md"))
        self.info(f"Found {len(md_files)} API documentation files")
        
        if len(md_files) == 0:
            self.warning("No API documentation files found")
        else:
            self.success(f"API documentation files present: {len(md_files)}")
            
    def _validate_markdown_files(self) -> None:
        """Validate markdown file structure"""
        print()
        print("═══ Markdown Structure Validation ═══")
        
        md_files = list(self.docs_dir.glob("**/*.md"))
        
        for md_file in md_files:
            relative_path = md_file.relative_to(self.docs_dir.parent)
            
            try:
                content = md_file.read_text(encoding='utf-8')
                
                # Check for title (# heading)
                if not re.search(r'^#\s+\w+', content, re.MULTILINE):
                    self.warning(f"{relative_path}: Missing top-level heading")
                else:
                    self.success(f"{relative_path}: Has title")
                    
                # Check for sections
                sections = re.findall(r'^##\s+(.+)$', content, re.MULTILINE)
                if len(sections) < 2:
                    self.warning(f"{relative_path}: Few sections ({len(sections)})")
                    
                # Check for code blocks
                code_blocks = re.findall(r'```(\w+)?\n', content)
                if code_blocks:
                    self.info(f"{relative_path}: Has {len(code_blocks)} code blocks")
                    
            except Exception as e:
                self.error(f"{relative_path}: Failed to read - {e}")
                
    def _validate_code_examples(self) -> None:
        """Validate code examples in documentation"""
        print()
        print("═══ Code Example Validation ═══")
        
        md_files = list(self.docs_dir.glob("**/*.md"))
        total_examples = 0
        invalid_examples = 0
        
        for md_file in md_files:
            relative_path = md_file.relative_to(self.docs_dir.parent)
            
            try:
                content = md_file.read_text(encoding='utf-8')
                
                # Find code blocks
                code_blocks = re.finditer(r'```(\w+)?\n(.*?)```', content, re.DOTALL)
                
                for match in code_blocks:
                    total_examples += 1
                    language = match.group(1)
                    code = match.group(2)
                    
                    # Check for language specification
                    if not language:
                        self.warning(f"{relative_path}: Code block without language")
                        invalid_examples += 1
                        
                    # Check for empty code blocks
                    if not code.strip():
                        self.warning(f"{relative_path}: Empty code block")
                        invalid_examples += 1
                        
            except Exception as e:
                self.error(f"{relative_path}: Failed to validate examples - {e}")
                
        if total_examples > 0:
            self.success(f"Validated {total_examples} code examples")
            if invalid_examples > 0:
                self.warning(f"{invalid_examples} code examples need improvement")
        else:
            self.info("No code examples found")
            
    def _validate_cross_references(self) -> None:
        """Validate cross-references between API docs"""
        print()
        print("═══ Cross-Reference Validation ═══")
        
        md_files = list(self.docs_dir.glob("**/*.md"))
        all_files = {f.stem for f in md_files}
        broken_refs = 0
        
        for md_file in md_files:
            relative_path = md_file.relative_to(self.docs_dir.parent)
            
            try:
                content = md_file.read_text(encoding='utf-8')
                
                # Find markdown links
                links = re.findall(r'\[([^\]]+)\]\(([^)]+)\)', content)
                
                for link_text, link_url in links:
                    # Check for internal .md references
                    if link_url.endswith('.md') and not link_url.startswith('http'):
                        # Extract filename
                        ref_file = Path(link_url).stem
                        if ref_file not in all_files:
                            self.warning(f"{relative_path}: Broken reference to {link_url}")
                            broken_refs += 1
                            
            except Exception as e:
                self.error(f"{relative_path}: Failed to validate references - {e}")
                
        if broken_refs == 0:
            self.success("All cross-references valid")
        else:
            self.warning(f"Found {broken_refs} broken cross-references")


def main():
    """Main entry point"""
    # Parse command line arguments
    docs_dir = sys.argv[1] if len(sys.argv) > 1 else "docs/api"
    
    # Create validator and run
    validator = APIDocValidator(docs_dir)
    exit_code = validator.validate_all()
    
    sys.exit(exit_code)


if __name__ == "__main__":
    main()
