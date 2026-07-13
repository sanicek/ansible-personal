# arch_rimworld_modding

Installs the minimal Arch Linux toolchain for RimWorld 1.6 mod builds: the official `dotnet-sdk` and `mono` packages. It does not install Steam, RimWorld, editors, asset tools, Doorstop, or create projects.

## Variables

- `arch_rimworld_modding_packages`: packages to install (default: `dotnet-sdk`, `mono`)
- `arch_rimworld_modding_framework_path`: Mono .NET Framework 4.7.2 reference assemblies (default: `/usr/lib/mono/4.7.2-api`)
- `arch_rimworld_modding_install_helper`: install the user build helper (default: `true`)
- `arch_rimworld_modding_helper_path`: helper path (default: `{{ user_home }}/.local/bin/rimworld-mod-build`)

## Building

Build directly from a mod project directory:

```bash
dotnet build --configuration Release -p:FrameworkPathOverride=/usr/lib/mono/4.7.2-api
```

Or use the installed helper, which supplies Release configuration and the framework path while forwarding additional `dotnet build` arguments safely. Caller options follow those defaults and can override them:

```bash
rimworld-mod-build
rimworld-mod-build --no-restore
rimworld-mod-build --configuration Debug
```

Ensure `~/.local/bin` is on your `PATH` before using the helper.

## Project example

RimWorld 1.6 mod assemblies use SDK-style `net472` projects. A minimal project can start as:

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net472</TargetFramework>
    <OutputPath>../../Assemblies/</OutputPath>
    <AppendTargetFrameworkToOutputPath>false</AppendTargetFrameworkToOutputPath>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="Krafs.Rimworld.Ref" Version="PIN_TO_YOUR_RIMWORLD_1_6_VERSION" />
    <!-- Add Lib.Harmony only when your mod needs it. -->
  </ItemGroup>
</Project>
```

NuGet dependencies are project-specific. Pin `Krafs.Rimworld.Ref` to the version matching the intended RimWorld 1.6 game version; do not rely on an unpinned latest version.

## Mod layout

Keep mod metadata and assets alongside the project output, for example:

```text
MyMod/
├── About/About.xml
├── Assemblies/MyMod.dll
├── Defs/
└── Source/MyMod/MyMod.csproj
```

Linux filesystems are case-sensitive. Match RimWorld folder and XML asset references exactly, including capitalization.
