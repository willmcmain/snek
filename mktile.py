#! /usr/bin/env python3
import sys

bits = {
    0: (0, 0),
    1: (1, 0),
    2: (0, 1),
    3: (1, 1)
}

def compile_line(ln):
    high = ''
    low = ''
    for pixel in ln:
        h, l = bits[pixel]
        high += str(h)
        low += str(l)

    return int(high, 2), int(low, 2)


def parse_line(ln):
    ln = ln.strip()[:8]
    ln = ln.replace('.', '0')
    ln = [int(x) for x in ln]
    for pixel in ln:
        assert pixel >= 0 and pixel <= 3
    return ln


def main(args):
    with open(args[1]) as f:
        result = []
        for ln in f:
            high, low = compile_line(parse_line(ln))
            result.append(high)
            result.append(low)
        print(','.join("${:02X}".format(r) for r in result))


if __name__ == '__main__':
    main(sys.argv)
