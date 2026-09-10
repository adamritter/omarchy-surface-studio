import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "omarchy.workspaces"

  readonly property int maxWorkspaces: 5
  readonly property real indicatorRadius: 6
  readonly property real indicatorXInset: 2
  readonly property real indicatorYInset: 6
  readonly property real pillSize: Math.max(0, barSize - indicatorYInset * 2)
  readonly property real appIconSize: Math.max(12, Math.min(16, pillSize - 8))
  readonly property color activeIndicatorColor: Color.foreground
  readonly property color activeTextColor:
    Math.abs(luminance(activeIndicatorColor) - luminance(Color.background))
      > Math.abs(luminance(activeIndicatorColor) - luminance(Color.foreground))
    ? Color.background : Color.foreground
  readonly property real trailingGap: vertical ? 0 : Style.spaceReal(1.5)

  function luminance(color) {
    return 0.299 * color.r + 0.587 * color.g + 0.114 * color.b
  }

  function workspaceById(id) {
    var values = Hyprland.workspaces.values
    for (var i = 0; i < values.length; i++) {
      if (values[i].id === id) return values[i]
    }
    return null
  }

  function workspaceIds() {
    var ids = []
    for (var id = 1; id <= maxWorkspaces; id++) ids.push(id)
    var values = Hyprland.workspaces.values
    for (var i = 0; i < values.length; i++) {
      var workspaceId = values[i].id
      if (workspaceId > 0 && ids.indexOf(workspaceId) === -1) ids.push(workspaceId)
    }
    ids.sort(function(left, right) { return left - right })
    return ids
  }

  function normalizedAppId(value) {
    var id = String(value || "").trim().toLowerCase()
    if (id.slice(-8) === ".desktop") id = id.slice(0, -8)
    return id
  }

  function workspaceApps(workspace) {
    var result = []
    var seen = ({})
    var values = workspace && workspace.toplevels
      ? workspace.toplevels.values : []
    for (var i = 0; i < values.length; i++) {
      var rawId = String(values[i] && values[i].appId || "").trim()
      var key = normalizedAppId(rawId)
      if (key === "" || seen[key] === true) continue
      seen[key] = true
      result.push({ id: rawId, key: key })
    }
    result.sort(function(left, right) {
      return left.key < right.key ? -1 : (left.key > right.key ? 1 : 0)
    })
    return result
  }

  function desktopIconName(app) {
    var values = DesktopEntries.applications.values || []
    for (var i = 0; i < values.length; i++) {
      var entry = values[i]
      var entryId = normalizedAppId(entry && entry.id)
      if (entryId === app.key || entryId.slice(-(app.key.length + 1)) === "." + app.key)
        return String(entry.icon || app.id)
    }
    return app.id
  }

  function iconSource(app) {
    var source = Quickshell.iconPath(desktopIconName(app), true)
    return source || Quickshell.iconPath("application-x-executable", true)
  }

  function appTooltip(apps) {
    if (!apps || apps.length === 0) return ""
    return apps.map(function(app) { return app.id }).join(" · ")
  }

  function focusWorkspace(id) {
    if (!bar) return
    bar.run("hyprctl dispatch "
      + Util.shellQuote("hl.dsp.focus({ workspace = \"" + id + "\" })"))
  }

  implicitWidth: grid.implicitWidth + trailingGap
  implicitHeight: grid.implicitHeight

  GridLayout {
    id: grid
    anchors.fill: parent
    anchors.rightMargin: root.trailingGap
    columns: root.vertical ? 1 : root.workspaceIds().length
    columnSpacing: root.vertical ? 0 : Style.space(1)
    rowSpacing: root.vertical ? Style.space(2) : 0

    Repeater {
      model: root.workspaceIds()

      Item {
        id: cell
        required property int modelData

        readonly property var workspace: root.workspaceById(modelData)
        readonly property var apps: root.workspaceApps(workspace)
        readonly property bool occupied: apps.length > 0
        readonly property bool focused: Hyprland.focusedWorkspace !== null
          && Hyprland.focusedWorkspace.id === modelData
        readonly property color contentColor: focused
          ? root.activeTextColor : Color.foreground

        implicitWidth: root.vertical ? root.barSize
          : Math.max(root.pillSize, contentRow.implicitWidth + Style.space(10))
            + root.indicatorXInset * 2
        implicitHeight: root.barSize

        Rectangle {
          anchors.centerIn: parent
          width: cell.width - root.indicatorXInset * 2
          height: root.pillSize
          color: cell.focused ? root.activeIndicatorColor : "transparent"
          radius: root.indicatorRadius
        }

        WidgetButton {
          anchors.fill: parent
          bar: root.bar
          labelVisible: false
          opacity: cell.occupied || cell.focused ? 1 : 0.5
          tooltipText: root.appTooltip(cell.apps)
          onPressed: function() { root.focusWorkspace(cell.modelData) }
        }

        RowLayout {
          id: contentRow
          anchors.centerIn: parent
          spacing: Style.space(3)

          Text {
            text: cell.modelData === 10 ? "0" : String(cell.modelData)
            color: cell.contentColor
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Style.font.body
            font.bold: cell.focused
            renderType: Text.NativeRendering
          }

          Repeater {
            model: cell.apps

            Image {
              required property var modelData
              source: root.iconSource(modelData)
              sourceSize.width: root.appIconSize
              sourceSize.height: root.appIconSize
              Layout.preferredWidth: root.appIconSize
              Layout.preferredHeight: root.appIconSize
              fillMode: Image.PreserveAspectFit
              smooth: true
            }
          }
        }
      }
    }
  }
}
