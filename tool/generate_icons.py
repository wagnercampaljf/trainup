#!/usr/bin/env python3
"""Gera os ícones do TrainUp (Android, iOS e lojas) a partir de uma geometria.

Conceito: uma barra com anilhas ("Train") levantada por uma seta para cima
("Up"); juntas formam a silhueta de um "T". Cores da identidade visual do app
(ver README, seção "Cores").

Requer python3 + pycairo (Ubuntu: `sudo apt install python3-cairo`).
Uso: python3 tool/generate_icons.py
"""

import json
import math
import os
import struct

import cairo

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RES = os.path.join(ROOT, 'android', 'app', 'src', 'main', 'res')
IOS_ICONSET = os.path.join(
    ROOT, 'ios', 'Runner', 'Assets.xcassets', 'AppIcon.appiconset'
)
BRANDING = os.path.join(ROOT, 'docs', 'branding')

# --- Identidade visual -------------------------------------------------------
BLUE_TOP = '#3B82F6'  # topo do degradê
BLUE = '#2563EB'  # azul elétrico da marca (primária)
BLUE_BOTTOM = '#1D4ED8'  # base do degradê
GREEN = '#4BE277'  # verde de progresso (a seta "Up")
WHITE = '#FFFFFF'

# --- Geometria do símbolo ----------------------------------------------------
# Unidades livres, y para baixo. Formas: ('rrect', x, y, w, h, raio) e
# ('tri', (x, y), (x, y), (x, y)) com cantos arredondados por um contorno.
BARBELL = [
    ('rrect', -320, -150, 640, 52, 26),  # barra
    ('rrect', -256, -269, 80, 290, 28),  # anilha grande esquerda
    ('rrect', 176, -269, 80, 290, 28),  # anilha grande direita
    ('rrect', -304, -224, 40, 200, 18),  # anilha pequena esquerda
    ('rrect', 264, -224, 40, 200, 18),  # anilha pequena direita
]
ARROW_TIP_ROUND = 24  # largura do contorno que arredonda a ponta da seta
ARROW = [
    ('tri', (0, -84), (120, 70), (-120, 70)),  # ponta (empurra a barra)
    ('rrect', -50, 40, 100, 210, 50),  # haste
]
GLYPH = BARBELL + ARROW


def _points(shape):
    if shape[0] == 'rrect':
        _, x, y, w, h, r = shape
        # Pontos extremos aproximados (cantos já arredondados).
        k = r * (1 - math.sqrt(0.5))
        return [
            (x + k, y + k), (x + w - k, y + k),
            (x + k, y + h - k), (x + w - k, y + h - k),
        ]
    pad = ARROW_TIP_ROUND / 2
    return [(px, py - pad if py < 0 else py + pad) for px, py in shape[1:]]


def _bounds():
    pts = [p for s in GLYPH for p in _points(s)]
    xs = [p[0] for p in pts]
    ys = [p[1] for p in pts]
    cx, cy = (min(xs) + max(xs)) / 2, (min(ys) + max(ys)) / 2
    radius = max(math.hypot(x - cx, y - cy) for x, y in pts)
    return cx, cy, radius


GLYPH_CX, GLYPH_CY, GLYPH_RADIUS = _bounds()

# Raio do símbolo como fração da metade visível do ícone. Mantém a mesma
# proporção visual no iOS (máscara arredondada) e no Android (máscaras do
# fabricante), dentro da zona segura do ícone adaptativo (66 dp).
GLYPH_FRACTION = 0.70


def _rgb(hex_color):
    v = int(hex_color[1:], 16)
    return ((v >> 16) & 255) / 255, ((v >> 8) & 255) / 255, (v & 255) / 255


# --- Desenho com cairo -------------------------------------------------------
def _shape_path(ctx, shape):
    if shape[0] == 'rrect':
        _, x, y, w, h, r = shape
        ctx.new_sub_path()
        ctx.arc(x + w - r, y + r, r, -math.pi / 2, 0)
        ctx.arc(x + w - r, y + h - r, r, 0, math.pi / 2)
        ctx.arc(x + r, y + h - r, r, math.pi / 2, math.pi)
        ctx.arc(x + r, y + r, r, math.pi, 3 * math.pi / 2)
        ctx.close_path()
    else:
        (x1, y1), (x2, y2), (x3, y3) = shape[1:]
        ctx.move_to(x1, y1)
        ctx.line_to(x2, y2)
        ctx.line_to(x3, y3)
        ctx.close_path()


def _fill_shapes(ctx, shapes, color):
    ctx.set_source_rgb(*_rgb(color))
    for shape in shapes:
        _shape_path(ctx, shape)
        if shape[0] == 'tri':
            ctx.fill_preserve()
            ctx.set_line_width(ARROW_TIP_ROUND)
            ctx.set_line_join(cairo.LINE_JOIN_ROUND)
            ctx.stroke()
        else:
            ctx.fill()


def _draw_glyph(ctx, center, visible_half, monochrome=None):
    scale = GLYPH_FRACTION * visible_half / GLYPH_RADIUS
    ctx.save()
    ctx.translate(*center)
    ctx.scale(scale, scale)
    ctx.translate(-GLYPH_CX, -GLYPH_CY)
    _fill_shapes(ctx, BARBELL, monochrome or WHITE)
    _fill_shapes(ctx, ARROW, monochrome or GREEN)
    ctx.restore()


def _background(ctx, size):
    gradient = cairo.LinearGradient(0, 0, size, size)
    gradient.add_color_stop_rgb(0, *_rgb(BLUE_TOP))
    gradient.add_color_stop_rgb(0.55, *_rgb(BLUE))
    gradient.add_color_stop_rgb(1, *_rgb(BLUE_BOTTOM))
    ctx.set_source(gradient)


def _rounded_square(ctx, size, radius):
    _shape_path(ctx, ('rrect', 0, 0, size, size, radius))


def render_full(size, alpha):
    """Ícone quadrado de fundo inteiro (iOS e lojas aplicam a máscara)."""
    fmt = cairo.FORMAT_ARGB32 if alpha else cairo.FORMAT_RGB24
    surface = cairo.ImageSurface(fmt, size, size)
    ctx = cairo.Context(surface)
    _background(ctx, size)
    ctx.paint()
    _draw_glyph(ctx, (size / 2, size / 2), size / 2)
    return surface


def render_legacy(size):
    """Ícone com cantos arredondados e transparência (Android 7.x)."""
    surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, size, size)
    ctx = cairo.Context(surface)
    margin = size / 48  # 1 dp de respiro, como nos ícones Material
    inner = size - 2 * margin
    ctx.translate(margin, margin)
    _rounded_square(ctx, inner, inner * 0.22)
    _background(ctx, inner)
    ctx.fill()
    _draw_glyph(ctx, (inner / 2, inner / 2), inner / 2)
    return surface


# --- Vetores Android (ícone adaptativo) -------------------------------------
def _fmt(v):
    return f'{v:.2f}'.rstrip('0').rstrip('.')


def _vector_path(shape, scale, dx, dy):
    def p(x, y):
        return _fmt((x - GLYPH_CX) * scale + dx), _fmt((y - GLYPH_CY) * scale + dy)

    if shape[0] == 'rrect':
        _, x, y, w, h, r = shape
        r = r * scale
        x0, y0 = p(x, y)
        x0, y0 = float(x0), float(y0)
        w, h = w * scale, h * scale
        return (
            f'M{_fmt(x0 + r)},{_fmt(y0)}h{_fmt(w - 2 * r)}'
            f'a{_fmt(r)},{_fmt(r)} 0,0 1,{_fmt(r)},{_fmt(r)}v{_fmt(h - 2 * r)}'
            f'a{_fmt(r)},{_fmt(r)} 0,0 1,{_fmt(-r)},{_fmt(r)}h{_fmt(-(w - 2 * r))}'
            f'a{_fmt(r)},{_fmt(r)} 0,0 1,{_fmt(-r)},{_fmt(-r)}v{_fmt(-(h - 2 * r))}'
            f'a{_fmt(r)},{_fmt(r)} 0,0 1,{_fmt(r)},{_fmt(-r)}z'
        )
    (a, b, c) = (p(*pt) for pt in shape[1:])
    return f'M{a[0]},{a[1]}L{b[0]},{b[1]}L{c[0]},{c[1]}z'


def _vector_group(shapes, color, scale, center):
    out = []
    for shape in shapes:
        data = _vector_path(shape, scale, center, center)
        stroke = ''
        if shape[0] == 'tri':
            stroke = (
                f'\n        android:strokeColor="{color}"'
                f'\n        android:strokeWidth="{_fmt(ARROW_TIP_ROUND * scale)}"'
                '\n        android:strokeLineJoin="round"'
            )
        out.append(
            '    <path\n'
            f'        android:fillColor="{color}"{stroke}\n'
            f'        android:pathData="{data}" />'
        )
    return out


VECTOR_HEADER = (
    '<?xml version="1.0" encoding="utf-8"?>\n'
    '<!-- Gerado por tool/generate_icons.py. Não edite à mão. -->\n'
    '<vector xmlns:android="http://schemas.android.com/apk/res/android"{extra}\n'
    '    android:width="108dp"\n'
    '    android:height="108dp"\n'
    '    android:viewportWidth="108"\n'
    '    android:viewportHeight="108">\n'
)


def write_android_vectors():
    # Camada de 108 dp; a máscara mostra os 72 dp centrais (metade = 36 dp).
    scale = GLYPH_FRACTION * 36 / GLYPH_RADIUS
    drawable = os.path.join(RES, 'drawable')
    os.makedirs(drawable, exist_ok=True)

    foreground = (
        VECTOR_HEADER.format(extra='')
        + '\n'.join(
            _vector_group(BARBELL, WHITE, scale, 54)
            + _vector_group(ARROW, GREEN, scale, 54)
        )
        + '\n</vector>\n'
    )
    monochrome = (
        VECTOR_HEADER.format(extra='')
        + '\n'.join(_vector_group(GLYPH, WHITE, scale, 54))
        + '\n</vector>\n'
    )
    background = (
        VECTOR_HEADER.format(
            extra='\n    xmlns:aapt="http://schemas.android.com/aapt"'
        )
        + '    <path android:pathData="M0,0h108v108h-108z">\n'
        '        <aapt:attr name="android:fillColor">\n'
        '            <gradient\n'
        '                android:type="linear"\n'
        '                android:startX="0"\n'
        '                android:startY="0"\n'
        '                android:endX="108"\n'
        '                android:endY="108">\n'
        f'                <item android:offset="0" android:color="{BLUE_TOP}" />\n'
        f'                <item android:offset="0.55" android:color="{BLUE}" />\n'
        f'                <item android:offset="1" android:color="{BLUE_BOTTOM}" />\n'
        '            </gradient>\n'
        '        </aapt:attr>\n'
        '    </path>\n'
        '</vector>\n'
    )
    files = {
        'ic_launcher_foreground.xml': foreground,
        'ic_launcher_monochrome.xml': monochrome,
        'ic_launcher_background.xml': background,
    }
    for name, content in files.items():
        with open(os.path.join(drawable, name), 'w') as f:
            f.write(content)

    anydpi = os.path.join(RES, 'mipmap-anydpi-v26')
    os.makedirs(anydpi, exist_ok=True)
    with open(os.path.join(anydpi, 'ic_launcher.xml'), 'w') as f:
        f.write(
            '<?xml version="1.0" encoding="utf-8"?>\n'
            '<!-- Gerado por tool/generate_icons.py. Não edite à mão. -->\n'
            '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
            '    <background android:drawable="@drawable/ic_launcher_background" />\n'
            '    <foreground android:drawable="@drawable/ic_launcher_foreground" />\n'
            '    <monochrome android:drawable="@drawable/ic_launcher_monochrome" />\n'
            '</adaptive-icon>\n'
        )


def write_android_legacy():
    for density, size in {
        'mdpi': 48, 'hdpi': 72, 'xhdpi': 96, 'xxhdpi': 144, 'xxxhdpi': 192,
    }.items():
        render_legacy(size).write_to_png(
            os.path.join(RES, f'mipmap-{density}', 'ic_launcher.png')
        )


def write_ios():
    with open(os.path.join(IOS_ICONSET, 'Contents.json')) as f:
        images = json.load(f)['images']
    for image in images:
        points = float(image['size'].split('x')[0])
        scale = int(image['scale'].rstrip('x'))
        size = round(points * scale)
        # A Apple rejeita ícones com canal alfa: RGB sem transparência.
        render_full(size, alpha=False).write_to_png(
            os.path.join(IOS_ICONSET, image['filename'])
        )


def write_store_and_master():
    os.makedirs(BRANDING, exist_ok=True)
    _write_png_rgba(
        render_full(512, alpha=True),
        os.path.join(BRANDING, 'trainup-icon-play-512.png'),
    )
    render_full(1024, alpha=False).write_to_png(
        os.path.join(BRANDING, 'trainup-icon-appstore-1024.png')
    )
    svg = cairo.SVGSurface(os.path.join(BRANDING, 'trainup-icon.svg'), 1024, 1024)
    ctx = cairo.Context(svg)
    _background(ctx, 1024)
    ctx.paint()
    _draw_glyph(ctx, (512, 512), 512)
    svg.finish()


def write_preview():
    """Prancha para revisão: máscaras, tamanhos pequenos e ícone temático."""
    w, h = 1500, 760
    surface = cairo.ImageSurface(cairo.FORMAT_RGB24, w, h)
    ctx = cairo.Context(surface)
    for x0, bg in ((0, '#F3F4F8'), (w / 2, '#121318')):
        ctx.set_source_rgb(*_rgb(bg))
        ctx.rectangle(x0, 0, w / 2, h)
        ctx.fill()

    def adaptive(cx, cy, visible, mask):
        # Camada de 108 dp com 72 dp visíveis; `visible` = tamanho visível.
        layer = visible * 108 / 72
        ctx.save()
        if mask == 'circle':
            ctx.arc(cx, cy, visible / 2, 0, 2 * math.pi)
        else:
            ctx.translate(cx - visible / 2, cy - visible / 2)
            _rounded_square(ctx, visible, visible * (0.5 if mask == 'squircle' else 0.22))
            ctx.translate(-(cx - visible / 2), -(cy - visible / 2))
        ctx.clip()
        ctx.save()
        ctx.translate(cx - layer / 2, cy - layer / 2)
        _background(ctx, layer)
        ctx.paint()
        ctx.restore()
        _draw_glyph(ctx, (cx, cy), visible / 2)
        ctx.restore()

    def ios(cx, cy, size):
        ctx.save()
        ctx.translate(cx - size / 2, cy - size / 2)
        _rounded_square(ctx, size, size * 0.2237)
        ctx.clip()
        _background(ctx, size)
        ctx.paint()
        _draw_glyph(ctx, (size / 2, size / 2), size / 2)
        ctx.restore()

    def themed(cx, cy, visible, dark):
        bg, fg = ('#C9E7DB', '#1C3D33') if not dark else ('#24453A', '#BDEBD7')
        ctx.save()
        ctx.arc(cx, cy, visible / 2, 0, 2 * math.pi)
        ctx.set_source_rgb(*_rgb(bg))
        ctx.fill()
        _draw_glyph(ctx, (cx, cy), visible / 2, monochrome=fg)
        ctx.restore()

    for half, dark in ((0, False), (w / 2, True)):
        ox = half
        ios(ox + 130, 150, 200)
        adaptive(ox + 370, 150, 200, 'circle')
        adaptive(ox + 610, 150, 200, 'squircle')
        # Tamanhos reais de tela (ícone da grade e notificações de lista).
        x = ox + 70
        for size in (96, 72, 60, 48, 40, 29):
            ios(x + size / 2, 400, size)
            x += size + 28
        x = ox + 70
        for size in (96, 72, 48):
            adaptive(x + size / 2, 560, size, 'circle')
            x += size + 28
        themed(ox + 520, 560, 96, dark)
        themed(ox + 640, 560, 72, dark)
    surface.write_to_png(os.path.join(BRANDING, 'trainup-icon-preview.png'))


def _write_png_rgba(surface, path):
    """Grava PNG RGBA (32 bits) mesmo para imagem opaca.

    O cairo grava imagens opacas como RGB de 24 bits; a especificação do ícone
    do Google Play pede PNG de 32 bits com canal alfa.
    """
    import zlib

    surface.flush()
    w, h, stride = surface.get_width(), surface.get_height(), surface.get_stride()
    data = surface.get_data()
    rows = []
    for y in range(h):
        row = bytearray(b'\x00')  # filtro "None"
        line = data[y * stride:y * stride + w * 4]
        for x in range(0, w * 4, 4):
            b, g, r, a = line[x], line[x + 1], line[x + 2], line[x + 3]
            if 0 < a < 255:  # desfaz a pré-multiplicação do cairo
                r, g, b = (min(255, c * 255 // a) for c in (r, g, b))
            row += bytes((r, g, b, a))
        rows.append(bytes(row))

    def chunk(kind, payload):
        body = kind + payload
        return struct.pack('>I', len(payload)) + body + struct.pack(
            '>I', zlib.crc32(body) & 0xFFFFFFFF
        )

    with open(path, 'wb') as f:
        f.write(b'\x89PNG\r\n\x1a\n')
        f.write(chunk(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 6, 0, 0, 0)))
        f.write(chunk(b'IDAT', zlib.compress(b''.join(rows), 9)))
        f.write(chunk(b'IEND', b''))


def _png_info(path):
    with open(path, 'rb') as f:
        head = f.read(26)
    width, height = struct.unpack('>II', head[16:24])
    color_type = head[25]
    return width, height, color_type


def main():
    write_android_vectors()
    write_android_legacy()
    write_ios()
    write_store_and_master()
    write_preview()
    # Conferência: tamanhos do iOS e ausência de alfa (tipo de cor 2 = RGB).
    with open(os.path.join(IOS_ICONSET, 'Contents.json')) as f:
        for image in json.load(f)['images']:
            points = float(image['size'].split('x')[0])
            expected = round(points * int(image['scale'].rstrip('x')))
            w, h, ct = _png_info(os.path.join(IOS_ICONSET, image['filename']))
            assert (w, h) == (expected, expected), image['filename']
            assert ct == 2, f'{image["filename"]} tem canal alfa'
    w, h, ct = _png_info(os.path.join(BRANDING, 'trainup-icon-play-512.png'))
    assert (w, h, ct) == (512, 512, 6), 'ícone do Play deve ser RGBA 512'
    print(f'OK: raio do símbolo {GLYPH_RADIUS:.0f} u, fração {GLYPH_FRACTION}')


if __name__ == '__main__':
    main()
