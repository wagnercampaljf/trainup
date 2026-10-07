#!/usr/bin/env python3
"""Gera o banner da Play Store (feature graphic 1024 x 500) do TrainUp.

Usa a mesma geometria e as cores do ícone (tool/generate_icons.py) e a fonte
Roboto que acompanha o Flutter SDK (nada é instalado no sistema).

Requer python3 + pycairo. Uso: python3 tool/generate_store_assets.py
"""

import os
import shutil
import sys
import tempfile


def _flutter_fonts_dir():
    root = os.environ.get('FLUTTER_ROOT')
    if not root:
        flutter = shutil.which('flutter') or os.path.expanduser(
            '~/development/flutter/bin/flutter'
        )
        root = os.path.dirname(os.path.dirname(os.path.realpath(flutter)))
    path = os.path.join(root, 'bin', 'cache', 'artifacts', 'material_fonts')
    if not os.path.isdir(path):
        sys.exit(f'Fontes do Flutter não encontradas em {path}')
    return path


# O fontconfig precisa enxergar a Roboto antes de o cairo ser carregado.
_conf = tempfile.NamedTemporaryFile('w', suffix='.conf', delete=False)
_conf.write(
    '<?xml version="1.0"?><!DOCTYPE fontconfig SYSTEM "fonts.dtd"><fontconfig>'
    f'<dir>{_flutter_fonts_dir()}</dir>'
    '<include ignore_missing="yes">/etc/fonts/fonts.conf</include>'
    '</fontconfig>'
)
_conf.close()
os.environ['FONTCONFIG_FILE'] = _conf.name

import cairo  # noqa: E402

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import generate_icons as icons  # noqa: E402

OUTPUT = os.path.join(icons.ROOT, 'docs', 'play-store', 'feature-graphic-1024x500.png')

TITLE = 'TrainUp'
TAGLINE_LINES = ['Sua ficha de treino e sua', 'evolução, sempre com você.']


def _text(ctx, text, size, weight, x, y, rgba):
    ctx.select_font_face('Roboto', cairo.FONT_SLANT_NORMAL, weight)
    ctx.set_font_size(size)
    ctx.set_source_rgba(*rgba)
    ctx.move_to(x, y)
    ctx.show_text(text)


def feature_graphic():
    w, h = 1024, 500
    surface = cairo.ImageSurface(cairo.FORMAT_RGB24, w, h)
    ctx = cairo.Context(surface)
    gradient = cairo.LinearGradient(0, 0, w, h)
    gradient.add_color_stop_rgb(0, *icons._rgb(icons.BLUE_TOP))
    gradient.add_color_stop_rgb(0.55, *icons._rgb(icons.BLUE))
    gradient.add_color_stop_rgb(1, *icons._rgb(icons.BLUE_BOTTOM))
    ctx.set_source(gradient)
    ctx.paint()

    # Ícone à esquerda, em "cartão" mais claro, para destacar o símbolo.
    card, cx, cy = 300, 230, 250
    ctx.save()
    ctx.translate(cx - card / 2, cy - card / 2)
    icons._rounded_square(ctx, card, card * 0.2237)
    ctx.set_source_rgba(1, 1, 1, 0.12)
    ctx.fill()
    ctx.restore()
    icons._draw_glyph(ctx, (cx, cy), card / 2)

    # Nome e chamada à direita (área central segura do banner).
    x = 440
    _text(ctx, TITLE, 112, cairo.FONT_WEIGHT_BOLD, x, 235, (1, 1, 1, 1))
    for i, line in enumerate(TAGLINE_LINES):
        _text(ctx, line, 38, cairo.FONT_WEIGHT_NORMAL, x + 4, 305 + i * 48,
              (1, 1, 1, 0.92))
    # Destaque verde (progresso) sob o nome.
    ctx.set_source_rgb(*icons._rgb(icons.GREEN))
    icons._shape_path(ctx, ('rrect', x + 4, 262, 120, 8, 4))
    ctx.fill()

    os.makedirs(os.path.dirname(OUTPUT), exist_ok=True)
    surface.write_to_png(OUTPUT)
    return OUTPUT


def main():
    try:
        path = feature_graphic()
    finally:
        os.unlink(_conf.name)
    w, h, color_type = icons._png_info(path)
    assert (w, h) == (1024, 500), (w, h)
    assert color_type == 2, 'banner deve ser PNG 24 bits sem alfa'
    print(f'OK: {os.path.relpath(path, icons.ROOT)}')


if __name__ == '__main__':
    main()
