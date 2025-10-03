#!/usr/bin/env python3
import io
import os
import re

root = os.path.join(os.path.dirname(__file__), '..')
root = os.path.normpath(root)

pattern = re.compile(r"\.withOpacity\(")

def replace_in_file(path):
    with io.open(path, 'r', encoding='utf-8') as f:
        s = f.read()
    changed = False
    i = 0
    out = ''
    while True:
        m = pattern.search(s, i)
        if not m:
            out += s[i:]
            break
        start = m.start()
        out += s[i:start]
        # find matching closing parenthesis from m.end()
        j = m.end()
        depth = 1
        while j < len(s) and depth > 0:
            if s[j] == '(':
                depth += 1
            elif s[j] == ')':
                depth -= 1
            j += 1
        if depth != 0:
            # unmatched, bail out and leave rest unchanged
            out += s[start:]
            break
        inner = s[m.end():j-1].strip()
        # create replacement: .withAlpha((<inner> * 255).round())
        replacement = f".withAlpha(({inner} * 255).round())"
        out += replacement
        changed = True
        i = j
    if changed:
        with io.open(path, 'w', encoding='utf-8') as f:
            f.write(out)
    return changed

changed_files = []
for dirpath, dirnames, filenames in os.walk(os.path.join(root, 'lib')):
    for fn in filenames:
        if fn.endswith('.dart'):
            full = os.path.join(dirpath, fn)
            try:
                if replace_in_file(full):
                    changed_files.append(os.path.relpath(full, root))
            except Exception as e:
                print('ERROR processing', full, e)

print('Modified files:')
for p in changed_files:
    print(p)
print('Done.')
