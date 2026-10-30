#!/usr/bin/env python3
"""
Generate a professional academic PDF for PRANA Comprehensive Project Report using ReportLab.
"""

import os
import re
import sys
from reportlab.lib.pagesizes import A4
from reportlab.lib import colors
from reportlab.lib.units import inch
pt = 1
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak, KeepTogether, Image as RLImage, Preformatted
)
from reportlab.pdfgen import canvas

MD_PATH = "/home/sreeju/AndroidStudioProjects/prana/PRANA_Comprehensive_Project_Report.md"
PDF_PATH = "/home/sreeju/AndroidStudioProjects/prana/PRANA_Comprehensive_Project_Report.pdf"
PDF_COPY_PATH = "/home/sreeju/Projects/prana-backend/PRANA_Comprehensive_Project_Report.pdf"

# Image mappings
IMG_MAP = {
    "flutter_01.png": "/home/sreeju/AndroidStudioProjects/prana/flutter_01.png",
    "flutter_02.png": "/home/sreeju/AndroidStudioProjects/prana/flutter_02.png",
    "flutter_03.png": "/home/sreeju/AndroidStudioProjects/prana/flutter_03.png",
    "flutter_04.png": "/home/sreeju/AndroidStudioProjects/prana/flutter_04.png",
}

# Numbered canvas for "Page X of Y" and running headers
class NumberedCanvas(canvas.Canvas):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._saved_page_states = []

    def showPage(self):
        self._saved_page_states.append(dict(self.__dict__))
        self._startPage()

    def save(self):
        num_pages = len(self._saved_page_states)
        for state in self._saved_page_states:
            self.__dict__.update(state)
            self.draw_page_decorations(num_pages)
            super().showPage()
        super().save()

    def draw_page_decorations(self, page_count):
        if self._pageNumber == 1:
            # Suppress header and footer on cover page
            return

        self.saveState()
        self.setFont("Helvetica", 8)
        self.setFillColor(colors.HexColor("#64748B"))

        # Running Header
        self.drawString(54, 842 - 36, "PRANA: Emergency Medical Identity Platform — Technical Documentation")
        self.setStrokeColor(colors.HexColor("#E2E8F0"))
        self.setLineWidth(0.5)
        self.line(54, 842 - 42, 595 - 54, 842 - 42)

        # Running Footer
        self.line(54, 48, 595 - 54, 48)
        self.drawString(54, 34, "SSMRV College, Bengaluru — Department of Computer Applications (BCA)")
        page_text = f"Page {self._pageNumber} of {page_count}"
        self.drawRightString(595 - 54, 34, page_text)
        self.restoreState()

def clean_inline_markdown(text):
    # Convert <br> or <br/> to <br/>
    text = re.sub(r'<br\s*/?>', '<br/>', text)
    # Strip any unrecognized html tags like <div>, </div>
    text = re.sub(r'</?div[^>]*>', '', text)
    # Convert markdown links [text](url) -> <u>text</u>
    text = re.sub(r'\[(.*?)\]\(.*?\)', r'<u>\1</u>', text)
    # Convert bold **text** -> <b>text</b>
    text = re.sub(r'\*\*(.*?)\*\*', r'<b>\1</b>', text)
    # Convert italic *text* -> <i>\1</i>
    text = re.sub(r'\*(.*?)\*', r'<i>\1</i>', text)
    # Convert inline code `code` -> <font name="Courier" color="#0E7490">code</font>
    text = re.sub(r'`(.*?)`', r'<font name="Courier" color="#0E7490"><b>\1</b></font>', text)
    # Escape naked ampersands that aren't entities
    text = re.sub(r'&(?!(?:amp|lt|gt|quot|apos|nbsp);)', '&amp;', text)
    return text

def generate_pdf():
    print("⏳ Building PDF from Markdown using ReportLab...")
    with open(MD_PATH, "r", encoding="utf-8") as f:
        md_text = f.read()

    doc = SimpleDocTemplate(
        PDF_PATH,
        pagesize=A4,
        leftMargin=54,
        rightMargin=54,
        topMargin=54,
        bottomMargin=54
    )

    styles = getSampleStyleSheet()
    
    # Custom styles
    style_body = ParagraphStyle(
        'PranaBody',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=9.5,
        leading=13.5,
        textColor=colors.HexColor("#1E293B"),
        spaceAfter=5
    )

    style_h1 = ParagraphStyle(
        'PranaH1',
        fontName='Helvetica-Bold',
        fontSize=18,
        leading=22,
        textColor=colors.HexColor("#0E7490"),
        spaceBefore=14,
        spaceAfter=8,
        keepWithNext=True
    )

    style_h2 = ParagraphStyle(
        'PranaH2',
        fontName='Helvetica-Bold',
        fontSize=13,
        leading=17,
        textColor=colors.HexColor("#0369A1"),
        spaceBefore=10,
        spaceAfter=5,
        keepWithNext=True
    )

    style_h3 = ParagraphStyle(
        'PranaH3',
        fontName='Helvetica-Bold',
        fontSize=10.5,
        leading=14,
        textColor=colors.HexColor("#0F172A"),
        spaceBefore=8,
        spaceAfter=3,
        keepWithNext=True
    )

    style_code = ParagraphStyle(
        'PranaCode',
        fontName='Courier',
        fontSize=7.5,
        leading=9.5,
        textColor=colors.HexColor("#0F172A"),
        spaceBefore=3,
        spaceAfter=5
    )

    style_blockquote = ParagraphStyle(
        'PranaQuote',
        parent=style_body,
        fontName='Helvetica-Oblique',
        fontSize=9,
        leading=13,
        leftIndent=15,
        textColor=colors.HexColor("#334155")
    )

    style_bullet = ParagraphStyle(
        'PranaBullet',
        parent=style_body,
        leftIndent=15,
        firstLineIndent=-10,
        spaceAfter=2
    )

    style_table_cell = ParagraphStyle(
        'PranaTableCell',
        fontName='Helvetica',
        fontSize=8,
        leading=10.5,
        textColor=colors.HexColor("#1E293B")
    )

    style_table_header = ParagraphStyle(
        'PranaTableHeader',
        fontName='Helvetica-Bold',
        fontSize=8.5,
        leading=11,
        textColor=colors.HexColor("#0F172A")
    )

    story = []
    lines = md_text.splitlines()
    in_code = False
    code_lines = []
    in_table = False
    table_lines = []

    def flush_table():
        nonlocal in_table, table_lines
        if not table_lines:
            return
        
        rows = []
        for line in table_lines:
            parts = [c.strip() for c in line.strip().strip('|').split('|')]
            if parts and not all(re.match(r'^:?-+:?$', p) for p in parts if p):
                rows.append(parts)

        if rows:
            max_cols = max(len(r) for r in rows)
            table_data = []
            for row_idx, r in enumerate(rows):
                is_header = (row_idx == 0)
                row_cells = []
                for c_idx in range(max_cols):
                    val = r[c_idx] if c_idx < len(r) else ""
                    val_clean = clean_inline_markdown(val)
                    p_style = style_table_header if is_header else style_table_cell
                    p = Paragraph(val_clean, p_style)
                    row_cells.append(p)
                table_data.append(row_cells)

            # Available width = 475.0 pt
            avail_w = 475.0
            col_w = avail_w / max_cols

            t = Table(table_data, colWidths=[col_w] * max_cols)
            t.setStyle(TableStyle([
                ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor("#E2E8F0")),
                ('TEXTCOLOR', (0, 0), (-1, 0), colors.HexColor("#0F172A")),
                ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
                ('VALIGN', (0, 0), (-1, -1), 'TOP'),
                ('BOTTOMPADDING', (0, 0), (-1, -1), 2.5),
                ('TOPPADDING', (0, 0), (-1, -1), 2.5),
                ('LEFTPADDING', (0, 0), (-1, -1), 3),
                ('RIGHTPADDING', (0, 0), (-1, -1), 3),
                ('LINEBELOW', (0, 0), (-1, -1), 0.5, colors.HexColor("#CBD5E1")),
            ]))
            story.append(t)
            story.append(Spacer(1, 4))

        table_lines = []
        in_table = False

    def flush_code():
        nonlocal in_code, code_lines
        if not code_lines:
            return
        # Chunk code lines into blocks of max 30 lines so they flow across pages without LayoutError
        chunk_size = 30
        for c_idx in range(0, len(code_lines), chunk_size):
            chunk = code_lines[c_idx:c_idx + chunk_size]
            code_str = "\n".join(chunk)
            code_p = Preformatted(code_str, style_code)
            t = Table([[code_p]], colWidths=[475.0])
            t.setStyle(TableStyle([
                ('BACKGROUND', (0, 0), (-1, -1), colors.HexColor("#F8FAFC")),
                ('BOX', (0, 0), (-1, -1), 0.5, colors.HexColor("#E2E8F0")),
                ('LEFTPADDING', (0, 0), (-1, -1), 6),
                ('RIGHTPADDING', (0, 0), (-1, -1), 6),
                ('TOPPADDING', (0, 0), (-1, -1), 3),
                ('BOTTOMPADDING', (0, 0), (-1, -1), 3),
            ]))
            story.append(t)
            story.append(Spacer(1, 3))
        code_lines = []
        in_code = False

    idx = 0
    while idx < len(lines):
        line = lines[idx]

        # Page breaks
        if '<div style="page-break-after: always;"></div>' in line:
            if in_code: flush_code()
            if in_table: flush_table()
            story.append(PageBreak())
            idx += 1
            continue

        # Code block
        if line.strip().startswith('```'):
            if in_code:
                flush_code()
            else:
                if in_table: flush_table()
                in_code = True
            idx += 1
            continue

        if in_code:
            code_lines.append(line)
            idx += 1
            continue

        # Table
        if line.strip().startswith('|') and line.strip().endswith('|'):
            in_table = True
            table_lines.append(line)
            idx += 1
            continue
        elif in_table:
            flush_table()

        stripped = line.strip()

        # Check for screenshot image references (Figure 19.1, etc.)
        for img_key, img_path in IMG_MAP.items():
            if img_key in stripped and os.path.exists(img_path):
                try:
                    # Embed mobile screenshot scaled cleanly to 2.2 x 4.9 inches
                    rl_img = RLImage(img_path, width=2.0*inch, height=4.5*inch)
                    story.append(Spacer(1, 4))
                    story.append(rl_img)
                    story.append(Spacer(1, 4))
                except Exception as ex:
                    print(f"Notice: Image {img_key} embedding skipped: {ex}")

        # Headings
        if stripped.startswith('# '):
            story.append(Paragraph(clean_inline_markdown(stripped[2:]), style_h1))
        elif stripped.startswith('## '):
            story.append(Paragraph(clean_inline_markdown(stripped[3:]), style_h2))
        elif stripped.startswith('### '):
            story.append(Paragraph(clean_inline_markdown(stripped[4:]), style_h3))
        elif stripped.startswith('#### '):
            story.append(Paragraph(clean_inline_markdown(stripped[5:]), style_h3))
        elif stripped.startswith('> '):
            story.append(Paragraph(clean_inline_markdown(stripped[2:]), style_blockquote))
        elif stripped.startswith('- ') or stripped.startswith('* '):
            bullet_text = "&bull; " + clean_inline_markdown(stripped[2:])
            story.append(Paragraph(bullet_text, style_bullet))
        elif re.match(r'^\d+\.\s', stripped):
            match = re.match(r'^\d+\.\s', stripped)
            num_str = stripped[:match.end()]
            num_text = f"<b>{num_str}</b>" + clean_inline_markdown(stripped[match.end():])
            story.append(Paragraph(num_text, style_bullet))
        elif stripped.startswith('---'):
            story.append(Spacer(1, 6))
        elif stripped:
            story.append(Paragraph(clean_inline_markdown(stripped), style_body))

        idx += 1

    if in_code: flush_code()
    if in_table: flush_table()

    print("📄 Compiling PDF document with canvas page numbers...")
    doc.build(story, canvasmaker=NumberedCanvas)
    print(f"✅ Generated PDF: {PDF_PATH}")
    
    # Copy to prana-backend
    import shutil
    shutil.copyfile(PDF_PATH, PDF_COPY_PATH)
    print(f"✅ Copied to: {PDF_COPY_PATH}")

if __name__ == "__main__":
    generate_pdf()
