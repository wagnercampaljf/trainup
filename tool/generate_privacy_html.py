#!/usr/bin/env python3
"""Gera docs/legal/politica-de-privacidade.html a partir do texto do app.

Fonte única: lib/features/settings/domain/privacy_policy.dart.
Uso: python3 tool/generate_privacy_html.py
"""

import html
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SOURCE = os.path.join(ROOT, 'lib', 'features', 'settings', 'domain', 'privacy_policy.dart')
OUTPUT = os.path.join(ROOT, 'docs', 'legal', 'politica-de-privacidade.html')


def constant(source, name):
    return re.search(rf"static const {name} = '([^']*)';", source).group(1)


def sections(source):
    block = source[source.index('sections = '):]
    pattern = re.compile(r"\(\s*'([^']*)',\s*((?:'[^']*'\s*)+),?\s*\)")
    return [
        (title, ''.join(re.findall(r"'([^']*)'", body)))
        for title, body in pattern.findall(block)
    ]


def main():
    with open(SOURCE, encoding='utf-8') as f:
        source = f.read()
    app = constant(source, 'appName')
    date = constant(source, 'effectiveDate')
    body = '\n'.join(
        f'    <h2>{html.escape(title)}</h2>\n    <p>{html.escape(text)}</p>'
        for title, text in sections(source)
    )
    page = f'''<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Política de Privacidade — {html.escape(app)}</title>
  <style>
    :root {{ --bg: #FAF8FF; --text: #1A1B21; --muted: #45464F; --accent: #2563EB; }}
    @media (prefers-color-scheme: dark) {{
      :root {{ --bg: #121318; --text: #E3E2E9; --muted: #C5C6D0; --accent: #8AB4FF; }}
    }}
    body {{ margin: 0; background: var(--bg); color: var(--text);
      font: 17px/1.6 system-ui, -apple-system, "Segoe UI", Roboto, sans-serif; }}
    main {{ max-width: 720px; margin: 0 auto; padding: 32px 16px 64px; }}
    h1 {{ font-size: 1.6rem; margin: 0 0 4px; }}
    h2 {{ font-size: 1.15rem; margin: 28px 0 6px; color: var(--accent); }}
    p {{ margin: 0; }}
    .date {{ color: var(--muted); font-size: .95rem; }}
  </style>
</head>
<body>
  <main>
    <h1>Política de Privacidade do {html.escape(app)}</h1>
    <p class="date">Vigência: {html.escape(date)}</p>
{body}
  </main>
</body>
</html>
'''
    os.makedirs(os.path.dirname(OUTPUT), exist_ok=True)
    with open(OUTPUT, 'w', encoding='utf-8') as f:
        f.write(page)
    print(f'OK: {len(sections(source))} seções → {os.path.relpath(OUTPUT, ROOT)}')


if __name__ == '__main__':
    main()
