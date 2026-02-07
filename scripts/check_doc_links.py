#!/usr/bin/env python3
"""
Documentation Link Checker
Validates all markdown links in documentation

Version: 1.0.0
Created: 2026-02-07
"""

import os
import sys
import re
from pathlib import Path
from typing import List, Dict, Set, Tuple
from urllib.parse import urlparse

# ANSI color codes
RED = '\033[0;31m'
GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
BLUE = '\033[0;34m'
NC = '\033[0m'  # No Color

class LinkChecker:
    """Checks markdown links for validity"""
    
    def __init__(self, docs_dir: str = "docs"):
        self.docs_dir = Path(docs_dir)
        self.project_root = self.docs_dir.parent
        self.errors: List[str] = []
        self.warnings: List[str] = []
        self.successes: List[str] = []
        self.checked_links: Set[str] = set()
        
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
        """Run all link checks. Returns 0 if valid, 1 if errors"""
        print("╔════════════════════════════════════════════════════════╗")
        print("║      Documentation Link Checker v1.0.0                ║")
        print("╚════════════════════════════════════════════════════════╝")
        print()
        
        if not self.docs_dir.exists():
            self.error(f"Documentation directory not found: {self.docs_dir}")
            return 1
            
        self.info(f"Checking links in: {self.docs_dir}")
        print()
        
        # Find all markdown files
        md_files = list(self.docs_dir.glob("**/*.md"))
        self.info(f"Found {len(md_files)} markdown files")
        print()
        
        # Check links in each file
        print("═══ Link Validation ═══")
        total_links = 0
        broken_links = 0
        
        for md_file in md_files:
            file_links, file_broken = self._check_file_links(md_file)
            total_links += file_links
            broken_links += file_broken
            
        # Print summary
        print()
        print("═══ Link Check Summary ═══")
        print(f"Total links checked: {total_links}")
        print(f"Broken links:        {broken_links}")
        print(f"Valid links:         {total_links - broken_links}")
        print()
        print(f"Successes: {len(self.successes)}")
        print(f"Warnings:  {len(self.warnings)}")
        print(f"Errors:    {len(self.errors)}")
        
        return 1 if self.errors else 0
        
    def _check_file_links(self, md_file: Path) -> Tuple[int, int]:
        """Check all links in a markdown file. Returns (total_links, broken_links)"""
        relative_path = md_file.relative_to(self.project_root)
        
        try:
            content = md_file.read_text(encoding='utf-8')
        except Exception as e:
            self.error(f"{relative_path}: Failed to read - {e}")
            return 0, 0
            
        # Find all markdown links: [text](url)
        links = re.findall(r'\[([^\]]+)\]\(([^)]+)\)', content)
        
        if not links:
            return 0, 0
            
        total_links = len(links)
        broken_links = 0
        
        for link_text, link_url in links:
            # Skip if already checked (for efficiency)
            link_key = f"{md_file}:{link_url}"
            if link_key in self.checked_links:
                continue
            self.checked_links.add(link_key)
            
            # Parse link
            if self._is_external_link(link_url):
                # External links - just validate format
                if not self._validate_external_link(link_url):
                    self.warning(f"{relative_path}: Invalid URL format: {link_url}")
                    broken_links += 1
            elif self._is_anchor_link(link_url):
                # Anchor links - validate target exists
                if not self._validate_anchor_link(md_file, link_url):
                    self.warning(f"{relative_path}: Broken anchor link: {link_url}")
                    broken_links += 1
            else:
                # Internal file links
                if not self._validate_internal_link(md_file, link_url):
                    self.error(f"{relative_path}: Broken link to {link_url}")
                    broken_links += 1
                    
        if broken_links == 0 and total_links > 0:
            self.success(f"{relative_path}: {total_links} links OK")
            
        return total_links, broken_links
        
    def _is_external_link(self, url: str) -> bool:
        """Check if URL is external (http/https)"""
        return url.startswith(('http://', 'https://'))
        
    def _is_anchor_link(self, url: str) -> bool:
        """Check if URL is an anchor link (#section)"""
        return url.startswith('#')
        
    def _validate_external_link(self, url: str) -> bool:
        """Validate external URL format"""
        try:
            result = urlparse(url)
            return all([result.scheme, result.netloc])
        except:
            return False
            
    def _validate_anchor_link(self, md_file: Path, anchor: str) -> bool:
        """Validate anchor link exists in current file"""
        try:
            content = md_file.read_text(encoding='utf-8')
            
            # Convert anchor to heading format
            # #my-section -> look for "## My Section" or similar
            target = anchor.lstrip('#').replace('-', ' ').lower()
            
            # Find all headings
            headings = re.findall(r'^#+\s+(.+)$', content, re.MULTILINE)
            
            for heading in headings:
                # Normalize heading for comparison
                normalized = heading.lower().replace(' ', '-')
                normalized = re.sub(r'[^\w-]', '', normalized)
                
                if normalized == anchor.lstrip('#'):
                    return True
                    
            return False
        except:
            return False
            
    def _validate_internal_link(self, md_file: Path, link_url: str) -> bool:
        """Validate internal file link exists"""
        # Remove anchor if present
        link_path = link_url.split('#')[0]
        
        if not link_path:
            return True  # Pure anchor link
            
        # Resolve relative to current file
        current_dir = md_file.parent
        target_path = (current_dir / link_path).resolve()
        
        # Check if file exists
        if target_path.exists():
            return True
            
        # Try relative to docs directory
        target_path = (self.docs_dir / link_path).resolve()
        if target_path.exists():
            return True
            
        # Try relative to project root
        target_path = (self.project_root / link_path).resolve()
        if target_path.exists():
            return True
            
        return False


def main():
    """Main entry point"""
    # Parse command line arguments
    docs_dir = sys.argv[1] if len(sys.argv) > 1 else "docs"
    
    # Create checker and run
    checker = LinkChecker(docs_dir)
    exit_code = checker.validate_all()
    
    sys.exit(exit_code)


if __name__ == "__main__":
    main()
