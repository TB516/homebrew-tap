cask "t3-code" do
  arch intel: "x86_64"

  version "0.0.38"
  sha256 "1f1ccd922b2efaffd50447b028ee0d6e2525502905087cf8ae3fe41efebe346f"

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
    run "./t3-code.AppImage", args: ["--appimage-extract"], base: :staged_path, chdir: "."

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
