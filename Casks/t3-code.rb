cask "t3-code" do
  arch intel: "x86_64"
  os linux: "linux"

  version "0.0.21"
  sha256 "79009fb24a65f8924ec9a618ee88180a2d190ae58d45c129b1e58c9e24bf2c24"

  depends_on arch: :x86_64

  url "https://github.com/pingdotgg/t3code/releases/download/v#{version}/T3-Code-#{version}-#{arch}.AppImage"
  name "T3 Code"
  desc "Minimal web GUI for coding agents"
  homepage "https://github.com/pingdotgg/t3code"

  livecheck do
    url :url
    strategy :github_latest
  end

  binary "squashfs-root/t3code", target: "t3code"
  artifact "squashfs-root/t3code.desktop",
           target: "#{ENV["XDG_DATA_HOME"] || "#{Dir.home}/.local/share"}/applications/t3code.desktop"
  artifact "squashfs-root/usr/share/icons/hicolor/1024x1024/apps/t3code.png",
           target: "#{ENV["XDG_DATA_HOME"] || "#{Dir.home}/.local/share"}/icons/hicolor/512x512/apps/t3code.png"

  preflight do
    appimage_name = "T3-Code-#{version}-#{arch}.AppImage"
    appimage = "#{staged_path}/#{appimage_name}"

    system("chmod", "+x", appimage)

    Dir.chdir(staged_path) do
      system("./#{appimage_name}", "--appimage-extract")
    end

    xdg_data_home = ENV["XDG_DATA_HOME"] || "#{Dir.home}/.local/share"
    FileUtils.mkdir_p("#{xdg_data_home}/applications")
    FileUtils.mkdir_p("#{xdg_data_home}/icons/hicolor/1024x1024/apps")

    desktop_file = "#{staged_path}/squashfs-root/t3code.desktop"
    desktop_contents = File.read(desktop_file)

    desktop_contents.gsub!(/^Exec=.*$/,
                           "Exec=env T3CODE_HOME=#{xdg_data_home}/t3code T3CODE_DISABLE_AUTO_UPDATE=1 #{HOMEBREW_PREFIX}/bin/t3code %U")
    desktop_contents.gsub!(/^Name=.*$/, "Name=T3 Code")
    desktop_contents.gsub!(/^X-AppImage-Version=.*\n/, "")

    File.write(desktop_file, desktop_contents)
  end

  zap delete: [
    "#{ENV["XDG_DATA_HOME"] || "#{Dir.home}/.local/share"}/t3code",
    "#{ENV["XDG_CONFIG_HOME"] || "#{Dir.home}/.config"}/t3code}",
  ]
end
