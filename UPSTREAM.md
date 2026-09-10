# Upstream provenance

The bundled bar derives from the MIT-licensed Omarchy bar (https://github.com/omacom/omarchy), based on the local customization of commit `fed2d225` (2026-08-28). Omarchy copyright and license are retained in LICENSE. Surface Studio additions are Copyright (c) 2026 Adam Ritter under the same MIT license.

This is a complete bundled bar, not an inheriting wrapper. It works without the proposed upstream background-component hook. Upstream bar improvements must be reviewed and ported deliberately; installing an Omarchy update does not update this copy. The plugin imports the running shell's common UI components and therefore still depends on Omarchy's QML contracts.

Bundled changes include material backgrounds, custom borders, external shadows, an integrated editor, and the existing custom bar's hover/reveal and tray placement behavior. Network, tray and other separately installed widgets remain owned by their respective plugins.
