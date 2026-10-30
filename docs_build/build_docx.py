#!/usr/bin/env python3
"""
Convert PRANA Markdown Report into a professionally formatted DOCX document.
"""

import os
import re
import sys
import docx
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_ALIGN_VERTICAL
from docx.oxml import OxmlElement, parse_xml
from docx.oxml.ns import nsdecls, qn

MD_PATH = "/home/sreeju/AndroidStudioProjects/prana/PRANA_Comprehensive_Project_Report.md"
DOCX_PATH = "/home/sreeju/AndroidStudioProjects/prana/PRANA_Comprehensive_Project_Report.docx"
DOCX_COPY_PATH = "/home/sreeju/Projects/prana-backend/PRANA_Comprehensive_Project_Report.docx"

# Color constants
COLOR_PRIMARY = RGBColor(14, 116, 144)    # Teal #0E7490
COLOR_SECONDARY = RGBColor(3, 105, 161)  # Sky Dark #0369A1
COLOR_TEXT = RGBColor(30, 41, 59)        # Slate #1E293B
COLOR_MUTED = RGBColor(100, 116, 139)    # Gray #64748B
COLOR_RED = RGBColor(220, 38, 38)        # Crimson #DC2626
HEX_HEADER_BG = "E2E8F0"
HEX_CODE_BG = "F8FAFC"
HEX_BORDER = "CBD5E1"

def set_cell_background(cell, hex_color):
    shading_elm = parse_xml(f'<w:shd {nsdecls("w")} w:fill="{hex_color}"/>')
    cell._tc.get_or_add_tcPr().append(shading_elm)

def set_cell_margins(cell, top=100, bottom=100, left=150, right=150):
    tcPr = cell._tc.get_or_add_tcPr()
    tcMar = parse_xml(f'<w:tcMar {nsdecls("w")}><w:top w:w="{top}" w:type="dxa"/><w:bottom w:w="{bottom}" w:type="dxa"/><w:left w:w="{left}" w:type="dxa"/><w:right w:w="{right}" w:type="dxa"/></w:tcMar>')
    tcPr.append(tcMar)

def set_table_borders(table, color="CBD5E1", sz="4", val="single"):
    tblPr = table._tbl.tblPr
    borders = parse_xml(
        f'<w:tblBorders {nsdecls("w")}>'
        f'  <w:top w:val="{val}" w:sz="{sz}" w:space="0" w:color="{color}"/>'
        f'  <w:bottom w:val="{val}" w:sz="{sz}" w:space="0" w:color="{color}"/>'
        f'  <w:left w:val="none"/>'
        f'  <w:right w:val="none"/>'
        f'  <w:insideH w:val="{val}" w:sz="{sz}" w:space="0" w:color="{color}"/>'
        f'  <w:insideV w:val="none"/>'
        f'</w:tblBorders>'
    )
    tblPr.append(borders)

def add_inline_formatted_text(paragraph, text, base_font_size=10.5, is_italic_base=False):
    # Regex to tokenize bold, code, and text
    tokens = re.split(r'(\*\*.*?\*\*|`.*?`|\*.*?\*)', text)
    for token in tokens:
        if not token:
            continue
        run = paragraph.add_run()
        run.font.name = "Calibri"
        run.font.size = Pt(base_font_size)
        run.font.color.rgb = COLOR_TEXT

        if token.startswith('**') and token.endswith('**') and len(token) >= 4:
            run.text = token[2:-2]
            run.bold = True
        elif token.startswith('`') and token.endswith('`') and len(token) >= 2:
            run.text = token[1:-1]
            run.font.name = "Consolas"
            run.font.size = Pt(base_font_size - 1)
            run.font.color.rgb = COLOR_PRIMARY
        elif token.startswith('*') and token.endswith('*') and len(token) >= 2:
            run.text = token[1:-1]
            run.italic = True
        else:
            run.text = token
            if is_italic_base:
                run.italic = True

def generate_docx():
    print("⏳ Parsing Markdown and generating DOCX...")
    with open(MD_PATH, "r", encoding="utf-8") as f:
        md_text = f.read()

    doc = docx.Document()

    # Set page layout to A4 with 1-inch margins
    for section in doc.sections:
        section.page_width = Inches(8.27)
        section.page_height = Inches(11.69)
        section.top_margin = Inches(1.0)
        section.bottom_margin = Inches(1.0)
        section.left_margin = Inches(1.0)
        section.right_margin = Inches(1.0)
        
        # Header & Footer setup
        header = section.header
        hp = header.paragraphs[0]
        hp.alignment = WD_ALIGN_PARAGRAPH.RIGHT
        hrun = hp.add_run("PRANA: Emergency Medical Identity Platform | Technical Documentation")
        hrun.font.name = "Calibri"
        hrun.font.size = Pt(8.5)
        hrun.font.color.rgb = COLOR_MUTED

        footer = section.footer
        fp = footer.paragraphs[0]
        fp.alignment = WD_ALIGN_PARAGRAPH.LEFT
        frun = fp.add_run("SSMRV College, Bengaluru — Department of Computer Applications (BCA)")
        frun.font.name = "Calibri"
        frun.font.size = Pt(8.5)
        frun.font.color.rgb = COLOR_MUTED

    lines = md_text.splitlines()
    in_code_block = False
    code_lines = []
    in_table = False
    table_lines = []

    def flush_table():
        nonlocal in_table, table_lines
        if not table_lines:
            return
        
        rows_data = []
        for line in table_lines:
            parts = [c.strip() for c in line.strip().strip('|').split('|')]
            if parts and not all(re.match(r'^:?-+:?$', p) for p in parts if p):
                rows_data.append(parts)
        
        if rows_data:
            num_cols = max(len(r) for r in rows_data)
            table = doc.add_table(rows=len(rows_data), cols=num_cols)
            table.alignment = WD_TABLE_ALIGNMENT.CENTER
            set_table_borders(table)

            for row_idx, row in enumerate(rows_data):
                is_header = (row_idx == 0)
                for col_idx in range(num_cols):
                    cell = table.cell(row_idx, col_idx)
                    set_cell_margins(cell, top=120, bottom=120, left=160, right=160)
                    if is_header:
                        set_cell_background(cell, HEX_HEADER_BG)
                    cell_text = row[col_idx] if col_idx < len(row) else ""
                    p = cell.paragraphs[0]
                    p.paragraph_format.space_before = Pt(1)
                    p.paragraph_format.space_after = Pt(1)
                    add_inline_formatted_text(p, cell_text, base_font_size=9.5 if not is_header else 10.0)
                    if is_header:
                        for run in p.runs:
                            run.bold = True
            doc.add_paragraph().paragraph_format.space_after = Pt(4)

        table_lines = []
        in_table = False

    def flush_code():
        nonlocal in_code_block, code_lines
        if not code_lines:
            return
        code_text = "\n".join(code_lines)
        p = doc.add_paragraph()
        p.paragraph_format.space_before = Pt(4)
        p.paragraph_format.space_after = Pt(6)
        p.paragraph_format.left_indent = Inches(0.2)
        run = p.add_run(code_text)
        run.font.name = "Consolas"
        run.font.size = Pt(8.5)
        run.font.color.rgb = RGBColor(15, 23, 42)
        code_lines = []
        in_code_block = False

    i = 0
    while i < len(lines):
        line = lines[i]

        # Check for page break marker
        if '<div style="page-break-after: always;"></div>' in line:
            if in_code_block: flush_code()
            if in_table: flush_table()
            doc.add_page_break()
            i += 1
            continue

        # Code block handler
        if line.strip().startswith('```'):
            if in_code_block:
                flush_code()
            else:
                if in_table: flush_table()
                in_code_block = True
            i += 1
            continue

        if in_code_block:
            code_lines.append(line)
            i += 1
            continue

        # Table handler
        if line.strip().startswith('|') and line.strip().endswith('|'):
            in_table = True
            table_lines.append(line)
            i += 1
            continue
        elif in_table:
            flush_table()

        stripped = line.strip()

        # Headings
        if stripped.startswith('# '):
            p = doc.add_paragraph()
            p.paragraph_format.space_before = Pt(18)
            p.paragraph_format.space_after = Pt(8)
            p.paragraph_format.keep_with_next = True
            run = p.add_run(stripped[2:])
            run.font.name = "Calibri"
            run.font.size = Pt(22)
            run.bold = True
            run.font.color.rgb = COLOR_PRIMARY
        elif stripped.startswith('## '):
            p = doc.add_paragraph()
            p.paragraph_format.space_before = Pt(14)
            p.paragraph_format.space_after = Pt(6)
            p.paragraph_format.keep_with_next = True
            run = p.add_run(stripped[3:])
            run.font.name = "Calibri"
            run.font.size = Pt(16)
            run.bold = True
            run.font.color.rgb = COLOR_SECONDARY
        elif stripped.startswith('### '):
            p = doc.add_paragraph()
            p.paragraph_format.space_before = Pt(10)
            p.paragraph_format.space_after = Pt(4)
            p.paragraph_format.keep_with_next = True
            run = p.add_run(stripped[4:])
            run.font.name = "Calibri"
            run.font.size = Pt(13)
            run.bold = True
            run.font.color.rgb = COLOR_TEXT
        elif stripped.startswith('#### '):
            p = doc.add_paragraph()
            p.paragraph_format.space_before = Pt(8)
            p.paragraph_format.space_after = Pt(3)
            p.paragraph_format.keep_with_next = True
            run = p.add_run(stripped[5:])
            run.font.name = "Calibri"
            run.font.size = Pt(11)
            run.bold = True
            run.italic = True
            run.font.color.rgb = COLOR_TEXT
        elif stripped.startswith('---'):
            # Horizontal rule -> subtle divider paragraph
            p = doc.add_paragraph()
            p.paragraph_format.space_before = Pt(6)
            p.paragraph_format.space_after = Pt(6)
        elif stripped.startswith('> '):
            # Blockquote
            p = doc.add_paragraph()
            p.paragraph_format.left_indent = Inches(0.3)
            p.paragraph_format.space_before = Pt(4)
            p.paragraph_format.space_after = Pt(4)
            add_inline_formatted_text(p, stripped[2:], base_font_size=10.0, is_italic_base=True)
        elif stripped.startswith('- ') or stripped.startswith('* '):
            p = doc.add_paragraph(style='List Bullet')
            p.paragraph_format.space_before = Pt(1)
            p.paragraph_format.space_after = Pt(2)
            add_inline_formatted_text(p, stripped[2:])
        elif re.match(r'^\d+\.\s', stripped):
            p = doc.add_paragraph(style='List Number')
            p.paragraph_format.space_before = Pt(1)
            p.paragraph_format.space_after = Pt(2)
            match = re.match(r'^\d+\.\s', stripped)
            add_inline_formatted_text(p, stripped[match.end():])
        elif stripped:
            p = doc.add_paragraph()
            p.paragraph_format.space_before = Pt(2)
            p.paragraph_format.space_after = Pt(5)
            p.paragraph_format.line_spacing = 1.15
            add_inline_formatted_text(p, stripped)

        i += 1

    if in_code_block: flush_code()
    if in_table: flush_table()

    print(f"💾 Saving generated DOCX to {DOCX_PATH}...")
    doc.save(DOCX_PATH)
    print(f"✅ Generated: {DOCX_PATH}")
    
    doc.save(DOCX_COPY_PATH)
    print(f"✅ Copied to: {DOCX_COPY_PATH}")

if __name__ == "__main__":
    generate_docx()
