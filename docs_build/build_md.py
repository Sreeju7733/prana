#!/usr/bin/env python3
"""
Build the master Markdown file for PRANA Comprehensive Project Report.
"""

import os
import sys

# Add current directory to path
sys.path.insert(0, os.path.dirname(__file__))

from content_frontmatter import FRONT_MATTER
from content_chapters_1_to_5 import CHAPTERS_1_TO_5
from content_chapters_6_to_10 import CHAPTERS_6_TO_10
from content_chapters_11_to_15 import CHAPTERS_11_TO_15
from content_chapters_16_to_20 import CHAPTERS_16_TO_20
from content_chapters_21_to_26 import CHAPTERS_21_TO_26
from content_appendices import APPENDICES

def build_markdown():
    sections = [
        FRONT_MATTER.strip(),
        CHAPTERS_1_TO_5.strip(),
        CHAPTERS_6_TO_10.strip(),
        CHAPTERS_11_TO_15.strip(),
        CHAPTERS_16_TO_20.strip(),
        CHAPTERS_21_TO_26.strip(),
        APPENDICES.strip(),
    ]
    
    full_text = "\n\n<div style=\"page-break-after: always;\"></div>\n\n".join(sections)
    
    words = len(full_text.split())
    lines = len(full_text.splitlines())
    chars = len(full_text)
    
    print(f"📊 Report Statistics:")
    print(f"   Words: {words:,}")
    print(f"   Lines: {lines:,}")
    print(f"   Characters: {chars:,}")
    
    # Destination 1: Workspace AndroidStudioProjects/prana
    dest1 = "/home/sreeju/AndroidStudioProjects/prana/PRANA_Comprehensive_Project_Report.md"
    with open(dest1, "w", encoding="utf-8") as f:
        f.write(full_text)
    print(f"✅ Written to: {dest1}")
    
    # Destination 2: Projects/prana-backend
    dest2 = "/home/sreeju/Projects/prana-backend/PRANA_Comprehensive_Project_Report.md"
    with open(dest2, "w", encoding="utf-8") as f:
        f.write(full_text)
    print(f"✅ Written to: {dest2}")

if __name__ == "__main__":
    build_markdown()
