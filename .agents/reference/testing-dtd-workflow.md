# Testing — DTD Automation Workflow

[Extracted from testing.md — DTD step-by-step procedure]

## Automated App Testing via DTD

When asked to test the Flutter app:

1. Call `get_flutter_app_dtd` (`serverpod` MCP) to obtain app DTD URI
2. Call `connect` (`dart_mcp_server_dtd` MCP) with returned URI
3. Use `flutter_driver_command` (`dart-mcp-server` MCP) to inspect widgets and navigate screens

## Widget Navigation Examples

### Tap a widget
```
flutter_driver_command(command: "tap", finderType: "ByText", text: "Login")
```

### Scroll to a widget
```
flutter_driver_command(command: "scroll", dx: "0", dy: "-500000", duration: "500000")
```

### Wait for widget
```
flutter_driver_command(command: "waitFor", finderType: "ByText", text: "Welcome", timeout: "5000")
```

### Get diagnostics tree
```
flutter_driver_command(command: "get_diagnostics_tree", finderType: "ByType", type: "Column")
```
