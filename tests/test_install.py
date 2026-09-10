import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

spec = importlib.util.spec_from_file_location('installer', Path(__file__).parents[1] / 'install.py')
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)


class InstallTests(unittest.TestCase):
    def test_preserves_widget_settings_and_is_idempotent(self):
        old = {'bar': {'id': 'adam.bar', 'layout': {'right': [{'id': 'clock', 'format': 'HH:mm'}]}}, 'idle': {'lock': 300}, 'disabledPlugins': ['other', m.PLUGIN_ID]}
        new = m.configure(old)
        self.assertEqual(new['bar']['layout'], old['bar']['layout'])
        self.assertEqual(new['idle'], old['idle'])
        self.assertEqual(old['bar']['id'], 'adam.bar')
        self.assertEqual(new, m.configure(new))
        self.assertEqual(new['disabledPlugins'], ['other'])

    def test_uninstall_preserves_later_changes(self):
        config = {'bar': {'id': m.PLUGIN_ID, 'position': 'left', 'layout': {'left': [{'id': m.PLUGIN_ID}, {'id': 'new-widget'}]}}}
        result = m.configure(config, 'old.bar', True)
        self.assertEqual(result['bar']['id'], 'old.bar')
        self.assertEqual(result['bar']['position'], 'left')
        self.assertEqual(result['bar']['layout']['left'], [{'id': 'new-widget'}])
        config['bar']['id'] = 'another.bar'
        self.assertEqual(m.configure(config, 'old.bar', True)['bar']['id'], 'another.bar')

    def test_atomic_settings(self):
        with tempfile.TemporaryDirectory() as d:
            p = Path(d) / 'shell.json'
            m.atomic_json(p, {'name': 'Árnyék'})
            self.assertEqual(json.loads(p.read_text()), {'name': 'Árnyék'})
            self.assertEqual(len(list(Path(d).iterdir())), 1)

    def test_single_self_contained_plugin(self):
        root = Path(__file__).parents[1]
        manifest = json.loads((root / 'manifest.json').read_text())
        self.assertEqual(manifest['id'], m.PLUGIN_ID)
        self.assertEqual(list(root.rglob('manifest.json')), [root / 'manifest.json'])
        self.assertTrue((root / manifest['entryPoints']['bar']).is_file())
        self.assertNotIn('../adam.surface-studio', (root / 'bar/Bar.qml').read_text())
