cask "t3-code" do
  arch intel: "x86_64"

  version "0.0.40"
  sha256 "8bf5fd44cb7fad0c43191d54fefdf974a8227d50505ecb8abcf76326209f264a"

  url "https://github.com/pingdotgg/t3code/releases/download/v#{version}/T3-Code-#{version}-#{arch}.AppImage"
  name "T3 Code"
  desc "Minimal web GUI for coding agents"
  homepage "https://github.com/pingdotgg/t3code"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on :linux
  depends_on arch: :x86_64

  rename "T3-Code-#{version}-#{arch}.AppImage", "t3-code.AppImage"

  binary "squashfs-root/t3code", target: "t3code"
  artifact "squashfs-root/t3code.desktop",
           target: "#{ENV["XDG_DATA_HOME"] || "#{Dir.home}/.local/share"}/applications/t3code.desktop"
  artifact "squashfs-root/usr/share/icons/hicolor/512x512/apps/t3code.png",
           target: "#{ENV["XDG_DATA_HOME"] || "#{Dir.home}/.local/share"}/icons/hicolor/512x512/apps/t3code.png"

  preflight_steps do
    set_permissions "t3-code.AppImage", "+x", recursive: false
    remove "squashfs-root", recursive: true
    run "/bin/sh", args: ["-c", "./t3-code.AppImage --appimage-extract >/dev/null"], chdir: "."

    inreplace "squashfs-root/t3code.desktop", /^Exec=.*$/,
              "Exec=env T3CODE_DISABLE_AUTO_UPDATE=1 {{HOMEBREW_PREFIX}}/bin/t3code %U"
    inreplace "squashfs-root/t3code.desktop", /^Name=.*$/, "Name=T3 Code"
    inreplace "squashfs-root/t3code.desktop", /^X-AppImage-Version=.*\n/, "", audit_result: false
  end

  zap trash: [
    ENV["T3CODE_HOME"] || "#{Dir.home}/.t3",
    "#{ENV["XDG_CONFIG_HOME"] || "#{Dir.home}/.config"}/t3code",
  ]
end
