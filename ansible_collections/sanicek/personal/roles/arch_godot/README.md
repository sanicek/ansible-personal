# arch_godot

Installs the standard Godot Engine editor from Arch Linux's official repositories for GDScript game development. GDScript and Godot's script editor are built into the engine, so no additional language runtime or external editor is required.

This role does not install the C#/.NET-enabled `godot-mono` package, external code editors, art or audio tools, export templates, or create projects.

## Variables

- `arch_godot_packages`: packages to install (default: `godot`)

## Getting started

Launch the project manager:

```bash
godot
```

Create a project, select GDScript when adding scripts, and enable Git metadata in the project creation dialog. Godot's generated `.gitignore` excludes imported and generated project data.

Export templates must match the installed editor version. Install them when needed through **Editor > Manage Export Templates** rather than managing a version-specific template archive through this role.

Platform exports may require additional SDKs and tools. Add those separately when a project has a concrete export target such as Android or the web.
