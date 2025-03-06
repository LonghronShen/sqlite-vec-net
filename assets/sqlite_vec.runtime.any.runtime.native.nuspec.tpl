<?xml version="1.0" encoding="utf-8"?>
<package xmlns="http://schemas.microsoft.com/packaging/2013/01/nuspec.xsd">
  <metadata minClientVersion="2.12">
    <id>sprintor.sqlite_vec.runtime.any.runtime.native</id>
    <version>${RELEASE_VERSION}</version>
    <title>sqlite_vec.runtime.any.runtime.native</title>
    <authors>longhronshen</authors>
    <owners>longhronshen</owners>
    <readme>docs\README.md</readme>
    <requireLicenseAcceptance>false</requireLicenseAcceptance>
    <license type="expression">MIT</license>
    <projectUrl>https://github.com/LonghronShen/sqlite_vec-net</projectUrl>
    <description>Native package for sqlite_vec.</description>
    <serviceable>true</serviceable>
    <dependencies>
      <dependency id="sprintor.sqlite_vec.runtime.ubuntu.20.04-arm64.runtime.native.GNU"
        version="${RELEASE_VERSION}" />
      <dependency id="sprintor.sqlite_vec.runtime.ubuntu.20.04-x64.runtime.native.GNU"
        version="${RELEASE_VERSION}" />
      <dependency id="sprintor.sqlite_vec.runtime.ubuntu.18.04-x86.runtime.native.GNU"
        version="${RELEASE_VERSION}" />
      <dependency id="sprintor.sqlite_vec.runtime.osx.12.6.5-x64.runtime.native.AppleClang"
        version="${RELEASE_VERSION}" />
      <dependency id="sprintor.sqlite_vec.runtime.win-arm64.runtime.native.MSVC"
        version="${RELEASE_VERSION}" />
      <dependency id="sprintor.sqlite_vec.runtime.win-x64.runtime.native.MSVC"
        version="${RELEASE_VERSION}" />
      <dependency id="sprintor.sqlite_vec.runtime.win-x86.runtime.native.MSVC"
        version="${RELEASE_VERSION}" />
    </dependencies>
  </metadata>
  <files>
    <file src="README.md" target="docs\" />
  </files>
</package>