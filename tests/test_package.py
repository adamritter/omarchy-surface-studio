import json
from pathlib import Path
import unittest

ROOT = Path(__file__).parents[1]

class PackageTests(unittest.TestCase):
    def test_single_self_contained_plugin(self):
        manifest = json.loads((ROOT / 'manifest.json').read_text())
        self.assertEqual(manifest['id'], 'io.github.adamritter.surface-studio')
        self.assertEqual(list(ROOT.rglob('manifest.json')), [ROOT / 'manifest.json'])
        for entry in manifest['entryPoints'].values():
            self.assertTrue((ROOT / entry).is_file())
        self.assertNotIn('../adam.surface-studio', (ROOT / 'bar/Bar.qml').read_text())

    def test_preset_and_shaders_are_packaged(self):
        preset = json.loads((ROOT / 'presets/ray-glass.json').read_text())
        self.assertEqual(preset['version'], 1)
        self.assertTrue(preset['settings']['rayGlass'])
        for shader in ('gradient', 'shadow'):
            self.assertGreater((ROOT / f'studio/{shader}.frag.qsb').stat().st_size, 0)
