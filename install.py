#!/usr/bin/python3
"""Install the combined bar without replacing unrelated desktop settings."""
import argparse
import copy
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import time

PLUGIN_ID = 'io.github.adamritter.surface-studio'


def configure(original, previous=None, uninstall=False):
    config = copy.deepcopy(original)
    bar = config.setdefault('bar', {})
    if uninstall:
        if bar.get('id') == PLUGIN_ID:
            bar['id'] = previous or 'omarchy.bar'
        for entries in bar.get('layout', {}).values():
            if isinstance(entries, list):
                entries[:] = [e for e in entries if (e.get('id') if isinstance(e, dict) else e) != PLUGIN_ID]
        config['disabledPlugins'] = list(dict.fromkeys(config.get('disabledPlugins', []) + [PLUGIN_ID]))
    else:
        bar['id'] = PLUGIN_ID
        config['disabledPlugins'] = [p for p in config.get('disabledPlugins', []) if p != PLUGIN_ID]
    return config


def atomic_json(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, temp = tempfile.mkstemp(dir=path.parent, prefix='.' + path.name)
    try:
        with os.fdopen(fd, 'w') as out:
            json.dump(data, out, indent=2, ensure_ascii=False)
            out.write('\n')
        os.replace(temp, path)
    finally:
        if os.path.exists(temp):
            os.unlink(temp)


def ipc(*args):
    return subprocess.check_output(['omarchy-shell', *args], text=True, stderr=subprocess.DEVNULL, timeout=10).strip()


def snapshot():
    try:
        return json.loads(ipc('surface-studio', 'status'))
    except (subprocess.SubprocessError, ValueError):
        return None


def restore_preview(state):
    if not state:
        return
    for _ in range(40):
        now = snapshot()
        if now:
            for key, value in state['current'].items():
                if now['current'].get(key) != value:
                    result = ipc('surface-studio', 'preview', key, json.dumps(value))
                    if result != 'ok':
                        raise RuntimeError('Could not restore appearance setting: ' + key)
            return
        time.sleep(.25)
    raise RuntimeError('The bar did not expose Surface Studio; preview is preserved in the backup.')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--uninstall', action='store_true')
    args = parser.parse_args()
    root = Path(os.environ.get('XDG_CONFIG_HOME') or Path.home() / '.config') / 'omarchy'
    config_path = root / 'shell.json'
    # Do not silently replace a corrupt/missing config with an empty layout.
    original = json.loads(config_path.read_text())
    if ipc('shell', 'ping') != 'ok':
        raise RuntimeError('A running Omarchy shell is required.')
    destination = root / 'plugins' / PLUGIN_ID
    metadata_path = destination / '.installation.json'
    metadata = json.loads(metadata_path.read_text()) if metadata_path.exists() else {
        'previousBarId': original.get('bar', {}).get('id', 'omarchy.bar')
    }
    state = snapshot()
    backup = root / 'backups' / ('surface-studio-bundle-' + time.strftime('%Y%m%d-%H%M%S') + '-' + str(os.getpid()))
    backup.mkdir(parents=True)
    shutil.copy2(config_path, backup / 'shell.json')
    if state:
        atomic_json(backup / 'appearance-preview.json', state)
    if args.uninstall:
        atomic_json(config_path, configure(original, metadata['previousBarId'], True))
        ipc('shell', 'reloadConfig')
        if destination.exists():
            destination.rename(backup / 'plugin')
        ipc('shell', 'rescanPlugins')
        subprocess.run(['omarchy', 'restart', 'shell'], check=True)
        if metadata['previousBarId'] == 'adam.bar':
            restore_preview(state)
    else:
        source = Path(__file__).resolve().parent
        destination.parent.mkdir(parents=True, exist_ok=True)
        stage = Path(tempfile.mkdtemp(prefix='.surface-studio-', dir=root))
        try:
            for name in ('bar', 'studio'):
                shutil.copytree(source / name, stage / name)
            for name in ('manifest.json', 'README.md', 'UPSTREAM.md', 'LICENSE', 'install.py', 'build-shaders.sh'):
                shutil.copy2(source / name, stage / name)
            atomic_json(stage / '.installation.json', metadata)
            if destination.exists():
                destination.rename(backup / 'plugin')
            stage.rename(destination)
        finally:
            if stage.exists():
                shutil.rmtree(stage)
        try:
            atomic_json(config_path, configure(original))
            ipc('shell', 'rescanPlugins')
            ipc('shell', 'reloadConfig')
            subprocess.run(['omarchy', 'restart', 'shell'], check=True)
            for _ in range(40):
                try:
                    ready = json.loads(ipc(PLUGIN_ID, 'status'))
                    if ready.get('barId') == PLUGIN_ID and ready.get('editors', 0) > 0:
                        break
                except (subprocess.SubprocessError, ValueError):
                    pass
                time.sleep(.25)
            else:
                raise RuntimeError('The combined bar failed to load.')
            restore_preview(state)
        except Exception:
            atomic_json(config_path, original)
            destination.rename(backup / 'failed-plugin')
            if (backup / 'plugin').exists():
                (backup / 'plugin').rename(destination)
            ipc('shell', 'rescanPlugins')
            ipc('shell', 'reloadConfig')
            subprocess.run(['omarchy', 'restart', 'shell'], check=True)
            if original.get('bar', {}).get('id') in ('adam.bar', PLUGIN_ID):
                restore_preview(state)
            raise
    print(('Removed' if args.uninstall else 'Installed') + ' Surface Studio Bar. Backup: ' + str(backup))


if __name__ == '__main__':
    main()
