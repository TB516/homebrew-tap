cask "t3-code" do
  arch intel: "x86_64"
  os linux: "linux"

  version "0.0.21"
  sha256 "79009fb24a65f8924ec9a618ee88180a2d190ae58d45c129b1e58c9e24bf2c24"

  url "https://github.com/pingdotgg/t3code/releases/download/v#{version}/T3-Code-#{version}-#{arch}.AppImage"
  name "T3 Code"
  desc "Minimal web GUI for coding agents"
  homepage "https://github.com/pingdotgg/t3code"

  livecheck do
    url :url
    strategy :github_latest
  end

  binary "t3code-wrapper", target: "t3code"

  artifact "t3code.desktop",
           target: "#{ENV["XDG_DATA_HOME"] || "#{Dir.home}/.local/share"}/applications/t3code.desktop"

  artifact "t3code.png",
           target: "#{ENV["XDG_DATA_HOME"] || "#{Dir.home}/.local/share"}/icons/hicolor/1024x1024/apps/t3code.png"

  preflight do
    appimage_name = "T3-Code-#{version}-#{arch}.AppImage"
    appimage = "#{staged_path}/#{appimage_name}"

    system("chmod", "+x", appimage)
    Dir.chdir(staged_path) do
      system(appimage, "--appimage-extract")
    end

    xdg_data_home = ENV["XDG_DATA_HOME"] || "#{Dir.home}/.local/share"
    FileUtils.mkdir_p("#{xdg_data_home}/applications")
    FileUtils.mkdir_p("#{xdg_data_home}/icons/hicolor/1024x1024/apps")

    wrapper = "#{staged_path}/t3code-wrapper"
    File.write(wrapper, <<~SH)
      #!/bin/sh
      export T3CODE_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/t3code"
      export T3CODE_DISABLE_AUTO_UPDATE=1
      exec "#{HOMEBREW_PREFIX}/Caskroom/t3code/#{version}/#{appimage_name}" "$@"
    SH

    desktop_file = "#{staged_path}/t3code.desktop"
    FileUtils.mv("#{staged_path}/squashfs-root/t3code.desktop", desktop_file)

    desktop_contents = File.read(desktop_file)
    desktop_contents.gsub!(/^Exec=.*$/, "Exec=#{HOMEBREW_PREFIX}/bin/t3code %U")
    desktop_contents.gsub!(/^Name=.*$/, "Name=T3 Code")
    desktop_contents.gsub!(/^X-AppImage-Version=.*\n/, "")
    File.write(desktop_file, desktop_contents)

    FileUtils.mv(
      "#{staged_path}/squashfs-root/usr/share/icons/hicolor/1024x1024/apps/t3code.png",
      "#{staged_path}/t3code.png",
    )
  end

  postflight do
    FileUtils.rm_rf("#{staged_path}/squashfs-root")
  end

  zap delete: [
    "#{ENV["XDG_DATA_HOME"] || "#{Dir.home}/.local/share"}/t3code",
  ]
end